%===========
% Last modified: 080908 TK@HARL
%

function [hdata]=P3P_StoreMeanValueToResults(hdata,data,st,ed)

% sort
if (st<=ed),
  st1=st; ed1=ed;
else
  st1=ed; ed1=st;
end
st1=round(st1*1000/hdata.samplingperiod);
ed1=round(ed1*1000/hdata.samplingperiod);
if st1<1
	st1=1;
	ed1=ed1+1;
end
if ndims(data)==3
  if ed1>size(data,1),ed1=size(data,1);end
elseif ndims(data)==4
  if ed1>size(data,2),ed1=size(data,2);end
end
period = st1:ed1;

  
%continuous
if ndims(data)==3
	for kind=1:size(data,3)
		mv=nan_fcn('mean',data(period,:,kind),1);
		tag=['Mean.' hdata.TAGs.DataTag{kind}];
		sp=findstr(tag,' '); tag(sp)='_';
		hdata = POTATo_sub_AddResults(hdata, tag, mv);

		sd=nan_fcn('std0',data(period,:,kind),1);
		tag=['sd.' hdata.TAGs.DataTag{kind}];
		sp=findstr(tag,' '); tag(sp)='_';
		hdata = POTATo_sub_AddResults(hdata, tag, sd);
	end

%blocked
elseif ndims(data)==4
	for kind=1:size(data,4)
		mv=zeros(size(data,1),size(data,3));
		for blk=1:size(data,1)
			mv(blk,:)=squeeze(nan_fcn('mean',data(blk,period,:,kind)))';
			tag=['MV.' hdata.TAGs.DataTag{kind} sprintf('.block%d',blk)];
			sp=findstr(tag,' '); tag(sp)='_';
			hdata = POTATo_sub_AddResults(hdata, tag, mv(blk,:));
		end
		tag=['MV.' hdata.TAGs.DataTag{kind} '.meanOverAllBlocks'];
		hdata = POTATo_sub_AddResults(hdata, tag, mean(mv,1));
		tag=['MV.' hdata.TAGs.DataTag{kind} '.sdOverAllBlocks'];
		hdata = POTATo_sub_AddResults(hdata, tag, std(mv,[],1));
	end	
end

	