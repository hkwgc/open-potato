function varargout = preproAIR(fcn, varargin)
% Preprocessor Function of AIR ControlCenter Fromat: (One File)
%   This Format Read AIR-ControlCenter.
%   And Plug-in Format Version 1.3
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproAIR('createBasicInfo');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproAIR('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproAIR('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproAIR('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproAIR('Execute', filename)
%  Continuous Data.
%
% See also OSPFILTERDATAFCN.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% AIR format loading routine
% DATE:07.01.20
% WRITTEN:Y.
%
% Inprot form Upper ot_datalod.
% create : 2005.12.21
% $Id: preproAIR.m,v 1.6 2008/09/24 02:18:58 shoji Exp $
%
% Revition 1.3 : 
%   Modify :: Read *.

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
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproAIR('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='AIR ControlCenter(Single-File)';
basicInfo.Version  =1.0;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
rver = '$Revision: 1.6 $';
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
%  filterspec = getFilterSpec;
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*.airmset','AIR Setting-Data';'*.airMeasure','AIR Measure-Data'};
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi = createBasicInfo;
dd = '$Date: 2008/09/24 02:18:58 $';
dd([1:6, end]) = [];
str={'=== AIR ControlCenter Format ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date     : ' dd], ...
  ' ------------------------ ', ...
  '  Binary    : (for version 1.0)', ...
  '  Extension : airmset',...
  ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = preproAIR('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=[];flag=true;
[pname, fname,ext] = fileparts(filename);
% Check Extension
if ~any(strcmpi(ext,{'.airmset','.airMeasure'}))
  % Extend
  msg='Extension Error';
  flag = false;
  return;
end

% debug for execute
% data=readMeasureFile(filename);

% Check 1st Line
% finfo=dir(filename);
[fid,message] = fopen(filename, 'r', 'l');
if fid == -1
  % Cannot Open
  msg=message;
  flag = false;
  return;
end
% Read Header
ver     = sprintf('%s',fread(fid,8,'*char'));
%keyword = sprintf('%s',fread(fid,16,'*char'));
fclose(fid);

ver=ver(1:4);   % ADD 2014.04.23

% File Format Check!!
if ~any(strcmpi(ver,'1.00'))
    if ~any(strcmpi(ver,'2.00'))
        msg  = sprintf('Unknown Version %s',ver);
        flag = false;
    return;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
%  [hdata, data] = preproAIR('Execute', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[data, hdata]=readMeasureFile(filename);
[p,f,e]=fileparts(filename);
mode=find(strcmpi(e,{'.airmset','.airMeasure'}));
if isempty(mode),error('No-Measure-File Found');end
if mode==1
  % Read Setting Data
  sdata=readAirSettingFile(filename);
%   mesfile0=dir([p filesep f '.airMeasure']);
  p0f0=[p filesep f(1,1:17) 'PC.airMeasure'];
  p0f1=[p filesep f(1,1:17) 'TE.airMeasure'];
  mesfile0=dir(p0f0);
  mesfile1=dir(p0f1);

%   if length(mesfile0)~=1
%   if (length(mesfile0)+length(mesfile1))==0
%     error('No-Measure-File Found');
%   end
%   mesfile =[p filesep mesfile0.name];
  if length(mesfile1)==1
    mesfile =[p filesep mesfile1.name];
  elseif length(mesfile0)==1
    mesfile =[p filesep mesfile0.name];
  else
    error('No-Measure-File Found');
  end
else
  sdata=dumySdata;
  mesfile =filename;
end
% Read
[hdata,data]=readAirSaveMeasureFile(mesfile,sdata);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str =getFileInfo(filename)
% ** get Information of file  **
% Syntax:
%  str =
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str ={[' Format AIR ControlCenter : ' filename]};

% Check 1st Line
%finfo=dir(filename);
[fid,message] = fopen(filename, 'r', 'l');
if fid == -1
  error(message);return;
end
ver=sprintf(fread(fid,8,'*char'));
keyword=sprintf(fread(fid,16,'*char'));

% Check Data-Size by File-Size
%datasize=floor(finfo.bytes-24)/136;
fclose(fid);

str{end+1} = ['  Version : ' ver];
str{end+1} = ['  KeyWord : ' keyword];
%str{end+1} = ['  Data Num: ' num2str(datasize)];
str{end+1} = ['  Channel Num : ' '28'];
return;

function sdata=dumySdata()
% Dumy Data
sdata.HEADGEARINFO.State.sProbeMode=1;
sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LlowWave =791000;
sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LhighWave=850000;
sdata.USERINFO.cID ='dumy';
sdata.USERINFO.cAge='00y00m00';
sdata.USERINFO.cSex='Male';
sdata.USERINFO.cName='someone';
sdata.USERINFO.cComment='No Comment';



