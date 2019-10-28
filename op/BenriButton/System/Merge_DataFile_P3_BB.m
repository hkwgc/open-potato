function str=Merge_DataFile_P3_BB(hs)

str='Merge Data Files';
if nargin<=0,return;end

%========================
% Set Basic Data-Function
%========================
if OSP_DATA('GET','isPOTAToRunning'),
  ddf=@DataDef2_RawData;
else
  ddf=@DataDef_SignalPreprocessor;
end
setappdata(hs.figure1, 'DataDefFunction', ddf);

%========================
actdata=uiFileSelectPP('MultiSelect',true);

[hdata1,data1]=feval(getappdata(hs.figure1, 'DataDefFunction'),'load',actdata{1}.data);
hdata = hdata1;

[hdata2,data2]=feval(getappdata(hs.figure1, 'DataDefFunction'),'load',actdata{2}.data);

ret = subCheckConsistency(hdata1, hdata2);
if ~isempty(ret)
	errordlg(ret, 'Merge error', 'modal');
	return;
end

hdata = subJoinHData(hdata, hdata1, hdata2);
hdata = subAdjustTimePoint(hdata, hdata1, hdata2);

data2(1,:,:)=nan;%- put nan at joint
data = cat(1, data1, data2);
%-raw signals
hdata.TAGs.data = cat(1,hdata1.TAGs.data,hdata2.TAGs.data);

%- save new data file
OSP_DATA('SET','SP_Rename','-'); % Confine Rename Option!
hdata.TAGs.filename = ['Merged_' hdata.TAGs.filename];
%hdata.TAGs.ID_number = hdata.TAGs.ID_number;
feval(getappdata(hs.figure1, 'DataDefFunction'), 'save', hdata, data);

%- update data list
POTATo('ChangeProject_IO',hs.figure1,[],hs);




function ret = subCheckConsistency(hd1,hd2)
%*** Check consistency
ret=[];
vstr = {'StimMode', 'stimMode', 'samplingperiod', 'measuremode'};
for k=1:length(vstr)
	if isfield(hd1,vstr{k}) && hd1.(vstr{k}) ~= hd2.(vstr{k})
		ret{end+1}=[vstr{k} ' is different.'];
	end
end

%- ch number
if size(hd1.flag,3) ~= size(hd2.flag,3)
	ret{end+1}='channel number is different.';
end
%- kind number
if length(hd1.TAGs.DataTag) ~= length(hd2.TAGs.DataTag)
	ret{end+1}='kind number is different.';
end

function hd = subJoinHData(hd, hd1,hd2)
%*** Join data
hd2.stimTC(1,1)=nan;%- put nan at joint
hd.stimTC = cat(2, hd1.stimTC, hd2.stimTC);

%hd2.flag(:,1,:)=nan;%- put nan at joint//nan is not logical value.
hd.flag = cat(2, hd1.flag, hd2.flag);

if ~isfield(hd,'MergeDataInfo')
	hd.MergeDataInfo.DataLengths=[];
	hd.MergeDataInfo.DataLengths(end+1) = length(hd1.stimTC);
end
hd.MergeDataInfo.DataLengths(end+1) = length(hd2.stimTC);

hd.MergeDataInfo.PutNanAtJointPoint = 'Yes';

function hd = subAdjustTimePoint(hd, hd1, hd2)
%*** Adjust time point
adjTP = length(hd1.stimTC);

%- stim [blocknum,3]
hd2.stim(:,1) = hd2.stim(:,1); %- mark kind
hd2.stim(:,2) = hd2.stim(:,2)+adjTP; %- time points for mark start
hd2.stim(:,3) = hd2.stim(:,3)+adjTP; %- time points for mark end
hd.stim = cat(1, hd1.stim, hd2.stim);

hd.MergeDataInfo.ModifyMarkKind = 'No';%-

%!!!!! TODO !!!!
%*** 
%- TAGs [struct]
%- MemberInfo [struct]

%- Pos [struct]
%--- ver [1]
%--- D2 [S]
%--- D3 [S]
%--- Group [S]
%--- MIND [S]

%- BlockInfo [struct]
%--- Mode [C]
%--- Parameters [S]