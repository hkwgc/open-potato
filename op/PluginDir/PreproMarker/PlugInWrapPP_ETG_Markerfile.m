function varargout = PlugInWrapPP_ETG_Markerfile(fcn, varargin)
% Test Function of Wrapper of Plag-In Function 
%  This Function Rename
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrapPP_ETG_Markerfile('createBasicIno');
%
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  Data = PlugInWrap_MaxDivision('getArgument',Data);
%
%     Data.name    : Display Name =='defined in createBasicInfo'
%     Data.wrap    : Name of this Function, 
%                    that is 'PlugInWrapPP_ETG_Markerfile'.
%     Data.argData : Argument of Plug in Function.
%                    now nothing.
%
% ** write **
% Syntax:
%  str = PlugInWrapPP_ETG_Markerfile('createBasicIno',region, fdata)
%
%  Make M-File, correspond to Plug-in function.
%  by usinge make_mfile.
%  if str, out-put by str.
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
% original author : Masanori Shoji
% create : 2007.01.30
% $Id: PlugInWrapPP_ETG_Markerfile.m 180 2011-05-19 09:34:28Z Katura $
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
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   = 'ETG7000: Marker Extend File';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data,varargin)
% Set Argument of this Wrapper (write).
%
%     Data.name    : Display Name =='defined in createBasicInfo'
%     Data.wrap    : Name of this Function, 
%                    that is 'PlugInWrapPP_ETG_Markerfile'.
%     Data.argData : Argument of Plug in Function.
%                    now nothing.
%
%     varargin     : Empty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==> confine this function
data0=createBasicInfo;
data.name=data0.name;
data.wrap=mfilename;
% Initalize-argData is in getArgument_ETG_MarkFile.
if isfield(data,'argData')
  data.argData=getArgument_ETG_MarkFile(data.argData);
else
  data.argData=getArgument_ETG_MarkFile;
end
% Cancel Check
if isempty(data.argData),data=[];end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, data) 
% Make M-File of PlugInWrapPP_ETG_Markerfile
%
%    data is as same as getArgument.
%    region is not in use, at 30-Jan-2007.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Header
make_mfile('code_separator', 3);
make_mfile('with_indent', ['% ' mfilename]);
make_mfile('code_separator', 3);

data=data.argData;
make_mfile('with_indent', ...
  sprintf('hdata=%s(''Exe'',hdata,data,%f,''%s'',...',...
  mfilename,...
  data.Threshold,...
  data.FileName.Method));

if isfield(data.FileName,'String')
  make_mfile('with_indent', ...
    sprintf('           ''NamePattern'',''%s'',...',data.FileName.String));
end
if data.ConfineResult
  make_mfile('with_indent', ...
    sprintf('           ''ConfineResult'',true);'));
else
  make_mfile('with_indent','           );');
end

str='';
if 0,disp(data);end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hdata=Exe(hdata,data,threshold,filenamemethod,varargin)
% Execute Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============
% Set Arugument
%===============
NamePattern='';
exeview=false;
for idx=1:2:length(varargin)
  switch varargin{idx}
    case 'NamePattern'
      NamePattern=varargin{idx+1};
    case 'ConfineResult'
      exeview=true;
    otherwise
      fprintf(2,'[W] Undefined Option : %s\n',varargin{idx});
  end
end

%===============
% Get filename
%===============
switch filenamemethod
  case 'uigetfile'
    prjp = OSP_DATA('GET','PROJECTPARENT');
    cwd  = pwd;
    try
      if ~isempty(prjp)
        cd(prjp);
      end
      [fname pname]=uigetfile({'*.csv','ETG Mark File'},...
        'ETG : Mark Data File');
    catch
      cd(cwd);
    end
    if ~isempty(prjp)
      cd(cwd);
    end
    % Cancle ?
    if isequal(fname,0) || isequal(pname,0), return;end
    % Conbine
    fname=[pname filesep fname];
    
  case 'from Data-Name'
    [p,f,ext]=fileparts(hdata.TAGs.filename);
    if 0,disp(p);disp(ext);end
    p=hdata.TAGs.pathname;
    fname=strrep(NamePattern,'%s',f);
    fname=[p filesep fname];
    
  otherwise
    error('Undefined File-Name-Method');
end

%==================
% Read File
%==================
% Open
[fid,msg]=fopen(fname,'r');
if fid<0,error(msg);end

try
  stim=readMarkFile(fid,threshold);
catch
  fclose(fid);
  rethrow(lasterror);
end
% Close
fclose(fid);

%==================
% Apply Stim
%==================
% Modify stimTC:
a=find(stim.stimTC);
aidx=find(diff(a)==1)+1;
stim.stimTC(a(aidx))=0;

if length(hdata.stimTC)~=length(stim.stimTC)
  warndlg({' Read Stim Length is different!',...
    sprintf('  * Original : %6.2f sec',...
    length(hdata.stimTC)*hdata.samplingperiod/1000),...
    sprintf('  * New      : %6.2d sec',...
    length(stim.stimTC)*hdata.samplingperiod/1000)},...
    'Warning: Stim-File Confuse');
  if length(hdata.stimTC)>length(stim.stimTC)
    hdata.stimTC(1:length(stim.stimTC))=stim.stimTC;
    hdata.stimTC(length(stim.stimTC)+1:end)=0;
  else
    hdata.stimTC=stim.stimTC(1:length(hdata.stimTC));
  end
else
  hdata.stimTC=stim.stimTC;
end

hdata=uc_makeStimData(hdata,stim.StimMode);

%==================
% View & Edit
%==================
if exeview
  % Open Mark Setting
  h0  = P3_MarkSetting;
  hs0 = guidata(h0);
  P3_MarkSetting('setContinuousData',h0,[],hs0,hdata,data);
  set(hs0.psb_ok,'Visible','on');
  waitfor(hs0.psb_ok,'Visible','off');
  if ishandle(h0),
    hdata=P3_MarkSetting('getContinuousData',h0,[],hs0);
    delete(h0);
  end
end

%==========================================================================
function stim=readMarkFile(fid,threshold)
% Read Mark-File
%==========================================================================

stim.StimMode=1;
% ------------
% Read Header 
% ------------
while 1
  tline = fgetl(fid);
  if ~ischar(tline),
    error('No Header exist.');
  end
  %disp(tline);
  if strncmp(tline,'EXT_AD',5),break,end
  
  % --> Checking Data
  if strncmp(tline,'StimType',8)
    if strfind(tline(9:end),'EVENT')
      stim.StimMode=1; % Event
    else
      stim.StimMode=2; % Block
    end
  end
end

% for debug
if 0, spos=ftell(fid); end

% ----------------
% Make Data-Format
% ----------------
ttitle=strread(tline,'%s','delimiter',',');
fmt='';
tid=[];chid=[];rnum=1;
for idx=1:length(ttitle)
  if strmatch('CH',ttitle{idx})
    fmt=[fmt '%f32']; % Read single
    chid(end+1)=rnum;
    rnum=rnum+1;
  elseif strmatch('Time',ttitle{idx})
    if 0
      fmt=[fmt '%d8%d8%d8']; % Read int 8 = hh:mm:ss
      tid=rnum:rnum+2;
      rnum=rnum+3;
    else
      fmt=[fmt '%*s'];
    end
  else
    fmt=[fmt '%*d'];  % Skip
  end
end

% ----------------
% Read Data
% ----------------
%c=textscan(fid,fmt,'delimiter',',:');
c=textscan(fid,fmt,'delimiter',',');

% ----------------
% Change To Mark
% ----------------
switch length(chid)
  case 1,
    stim.stimTC=c{chid(1)}>threshold;
  case 2,
    stim.stimTC=c{chid(1)}>threshold+2*(c{chid(2)}>threshold);
  otherwise
    error('Format Error : Too many Ch Data');
end

if 0
  disp(c{tid});
end








