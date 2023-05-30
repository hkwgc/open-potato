function varargout = preproSNIRF(fcn, varargin)
% Preprocessor Function of SNIRF data Fromat:
%   This Format Read Shared Near Infrared Spectroscopy Format (SNIRF).
%   (https://github.com/fNIRS/snirf)
%   Plug-in Format Version beta1
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproSNIRF('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproSNIRF('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproSNIRF('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproSNIRF('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproSNIRF('Execute', filename)
%  Continuous Data.
%
%  OT_LOCAL_DATA = preproSNIRF('ExecuteOld', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%
% See also OSPFILTERDATAFCN.


% ======================================================================
% Copyright(c) 2023, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% SNIRF format loading routine
% DATE:2023-01-30
% WRITTEN:H. Kawaguchi
%
% Update: 2023-05-30 
%   

%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
if 0
  % Entry function
  createBasicInfo;
  getFunctionInfo;
  CheckFile;
  getFileInfo;
  Execute;
  ExecuteOld;
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproETG7000('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='SNIRF';
basicInfo.Version  =0.1;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
%rver = '$Revision: 1.15 $';
rver = '$Revision: 0.1 $';%- TK@HARL 20110225
[s,e]= regexp(rver, '[0-9.]');
try
  basicInfo.Version = str2double(rver(s(1):e(end)));
catch
  basicInfo.Version =1.0;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=getFilterSpec
% ** CREATE BASIC INFORMATION **
% Syntax:
%  filterspec = preproETG7000('getFilterSpec');
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*.snirf','shared NIRS format';...
  '*.snirf', 'snirf files'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi = createBasicInfo;
dd = '$Date: 2023/01/30 15:17 $';
dd([1:6, end]) = [];

str={'=== SNRF Format ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date     : ' dd]};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = preproSNIRF('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pname, fname,ext] = fileparts(filename);

flag = true;
msg=[];

% Check Extension
if strcmpi(ext,{'.snirf'})==0,
  % Extend
  msg='Extension Error';
  flag = false;
  return;
end

% Currently, no more check

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str =getFileInfo(filename)
% ** get Information of file  **
% Syntax:
%  str =
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str =[' SNIRF : ' filename];;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproSNIRF('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data =read_snirf(filename);
[data,hdata]=snirf2op(data);


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data, hdata] = snirf2op(snirf)
% convert voltage to oxy and deoxy hb and Get Pos
[data, hdata] = nirs2data(snirf.nirs);

% samplingperiod
samplingperiod = ...
    mean(snirf.nirs.data.time(2:end)-snirf.nirs.data.time(1:end-1))...
    * 1000; % sec to msec
hdata.samplingperiod = samplingperiod;

% stim

% stimTC
stimTC = zeros(size(snirf.nirs.data.time));

if isfield(snirf.nirs,'stim')
    nStim = numel(snirf.nirs.stim);
    nEachStim = zeros(nStim,1);
    for n = 1: nStim
        nEachStim(n) = size(snirf.nirs.stim(n).data,2);
    end
    stim = zeros(sum(nEachStim),3);
    cnt = 1;
    for n = 1: nStim
        idx = cnt:cnt+nEachStim(n)-1;
        stim(idx,1) = n;
        stim(idx,2) = 1000*snirf.nirs.stim(n).data(1,:)';
        stim(idx,3) = stim(idx,2) + 1000*snirf.nirs.stim(n).data(2,:)';
        cnt = cnt + nEachStim(n);
    end
    stim = sortrows(stim,2);
    stim(:,2) = ceil(stim(:,2)/samplingperiod);
    stim(:,3) = floor(stim(:,3)/samplingperiod);

    hdata.stim = stim;

    % stimTC
    for n = 1:size(stim,1)
        stimTC(stim(n,2):stim(n,3)) = stim(n,1);
    end

else
    warning('Cannot find stim.');
    hdata.stim=[];
end

hdata.stimTC = stimTC;

% StimMode
hdata.StimMode = 2;

% flag
hdata.flag = false(1,size(data,1),size(data,2));

% TAG
hdata.TAGs = nirs2TAGs(snirf);


return






function TAGs = nirs2TAGs(snirf)
TAGs = snirf.nirs.metaDataTags;
TAGs.TimeUnit = 'ms';

[dirName,fileName,fileExt] = fileparts(snirf.fileName);
TAGs.filename = fileName;
TAGs.dirname = dirName;
TAGs.fileExt = fileExt;
TAGs.ID_number = TAGs.SubjectID;
TAGs.subjectname = TAGs.SubjectID;
TAGs.comment = 'none';
TAGs.age = '0';
TAGs.sex = 0;
TAGs.date = datenum(...
    [TAGs.MeasurementDate,' ', TAGs.MeasurementTime],...
    'yyyy-mm-dd HH:MM:SS');
TAGs.data = snirf.nirs.data.dataTimeSeries;
TAGs.DataTag = {'Oxy'  'Deoxy'  'Total'};
TAGs.wavelength = snirf.nirs.probe.wavelengths;

pr = snirf.nirs.probe;
TAGs.probe=pr;


if isfield(snirf.nirs,'stim')
    st = snirf.nirs.stim;
    st = rmfield(st,'data');
    TAGs.stim = st;
end



function [data, hdata]= nirs2data(nirs);
%%
mlist = nirs.data.MeasurementList;

fullChList = [mlist.sourceIndex;mlist.detectorIndex]';
unqChList  = unique(fullChList,'rows');
pigm     = {'oxyHb', 'deoxyHb', 'totalHb'};

% data [timepoints, channel, type] 
nData = size(nirs.data.dataTimeSeries,2);
nCh   = size(unqChList,1);
nPigm = numel(pigm);
data = zeros(nData, nCh, nPigm);

% wavelength List
wl = nirs.probe.wavelengths;
nWl = numel(wl);

% Convert data to delta Hb
for n = 1:size(unqChList,1)
    ch = unqChList(n,:);
    dataID = find((fullChList(:,1)==ch(1)) & (fullChList(:,2)==ch(2))); % 1: sourceIndex, 2: detectorIndex
    I = zeros(nData,nWl);
    for m = 1:numel(dataID)
        wlID = mlist(dataID(m)).wavelengthIndex;
        I(:,wlID)  = nirs.data.dataTimeSeries(dataID(m), :);
    end
    data(:,n,:)=p3_chbtrans(I, wl, 1); % Intensity to potato Data 
end


% total Hb
% data = cat(3,data,sum(data,3));


probe = nirs.probe;

D2.P = zeros(nCh,2);
D3.P = zeros(nCh,3);
D3.Base = zeros(3,3); % Nz, AL(A1), AR(A2)


% POS structure 

for n = 1:size(unqChList,1)
    ch = unqChList(n,:);
    sid = ch(1);
    did = ch(2);
    if isfield(probe,'sourcePos3D') && isfield(probe,'detectorPos3D')
        spos = probe.sourcePos3D(:,sid);
        dpos = probe.detectorPos3D(:,did);
        cpos = 0.5*(spos + dpos);
        D3.P(n,:) = cpos';
        D3.PS(n,:) = spos';
        D3.PD(n,:) = dpos';
    end

    if isfield(probe,'sourcePos2D') && isfield(probe,'detectorPos2D')
        spos = probe.sourcePos2D(:,sid);
        dpos = probe.detectorPos2D(:,did);
        cpos = 0.5*(spos + dpos);
        D2.P(n,:) = cpos';
        D2.PS(n,:) = spos';
        D2.PD(n,:) = dpos';
    else
        if isfield(probe,'sourcePos3D') && isfield(probe,'detectorPos3D')
            D2.P(n,:) = D3.P(n,1:2);
            D2.PS(n,:) = D3.PS(n,1:2);
            D2.PD(n,:) = D3.PD(n,1:2);
        end
    end
end

if isfield(probe,'landmarkLabels') && isfield(probe,'landmarkPos3D')
    % Nz(Nasion)
    idx = FindLandmarkLabelIndex(probe.landmarkLabels,{'Nz','Nasion','NASION','NZ'});
    D3.Base(1,:) = probe.landmarkPos3D(:,idx)';
    % AL
    idx = FindLandmarkLabelIndex(probe.landmarkLabels,{'AL','A1','123','LPA'});
    D3.Base(2,:) = probe.landmarkPos3D(:,idx)';
    % AR
    idx = FindLandmarkLabelIndex(probe.landmarkLabels,{'AR','A2','124','RPA'});
    D3.Base(3,:) = probe.landmarkPos3D(:,idx)';
end

lenCoef = GetCoefLehgthUnitToMillimetre(nirs.metaDataTags.LengthUnit);

D3.Base = D3.Base.*lenCoef;
D2.P  = D2.P.*lenCoef;
D2.PS = D2.PS.*lenCoef;
D2.PD = D2.PD.*lenCoef;
D3.P  = D3.P.*lenCoef;
D2.PS = D2.PD.*lenCoef;
D2.PD = D2.PS.*lenCoef;

Pos.D2 = D2;
Pos.D3 = D3;
Pos.Group.ChData = {1:size(Pos.D3,1)};
Pos.Group.mode = 99;
Pos.Group.OriginalCh = 1:size(Pos.D3,1);
hdata.measuremode = -1;
hdata.Pos = Pos;

return




function idx = FindLandmarkLabelIndex(labels,str)
for n=1:numel(str)
    idx = find(strcmp(labels,str{n}));
    if ~isempty(idx)
        break;
    end
end
if isempty(idx)
   warning(['Cannot find ' str{1}]);
end

return

function val = MolExtCoeff(lambda, spec)
% Matcher et al., Analytical Biochemistry Volume 227, Issue 1, May 1995, Pages 54-68
%%
wl      = [760, 850];
% cm-1, mM-1
e.oxyHb   = [0.6096, 1.1596];
e.deoxyHb = [1.6745, 0.7861];

coeff = e.(spec);

idx = (wl ==lambda);
if any(idx)
    val = coeff(idx);
else
    error('out of wavelangth range')
end

function c = GetCoefLehgthUnitToMillimetre(str)

switch str
    case 'm'; c = 1000;
    case 'cm';c = 10;
    case 'mm';c = 1;
end