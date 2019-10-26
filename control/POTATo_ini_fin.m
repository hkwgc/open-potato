function POTATo_ini_fin(type,varargin)
% POTATo Initialize & Finalize Function
%    + User Setting Data I/O.
%    + Data-Initialize.
%    + Logging Fucntion Initialize.
%    + Current-System-Setting.
%
% -------------------------------------
%  Platform for Optical Topography 
%                       Analysis Tools.
% -------------------------------------
%    
% osp_ini_fin(type,varargin)
%  type : 1-> initialize
%         2-> final
%  varargin  : To be defined in a future version
%
% *************
% Lower Link
% *************
%    OSP_LOG  : Loggin Function
%    OSP_DATA : OSP Data
%
% *************
% Upper Link
% *************
%    OSP     : OSP main function
%
% -----------------------------------------
% To be defined in a future version of OSP
%   Set up File


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original auther : Masanori Shoji
% create : 2004.12.21
% $Id: POTATo_ini_fin.m 405 2014-04-22 09:08:52Z katura7pro $
%

%state=OSP_DATA;

switch type
  case 1      % initiarize
    %if state~=0, return; end
    startFcn(varargin{:});
    
  case 2      % close
    clearOsp;
    
  otherwise
    OSP_LOG('perr', mfilename, ...
      {[' In ''POTATo_ini_fin'' : ' datestr(now)]; ...
        ' Undefined type Inputed'});
    errordlg(['Program Error : ' mfilename ' Undefined type']);
end
  
% Memory garbage
try
  rver=OSP_DATA('GET','ML_TB');
  if isempty(rver),
    rver=200; % no garvage correction
  else
    rver=rver.MATLAB;
  end
  if rver<16 
    cwd = pwd; cd(tempdir);
    pack;  cd(cwd);
  end
catch
  if exist('cwd','var'), cd(cwd); end
  warning('Garbage Collection done unsuccessfully');
end

%%%%%%%%%
% Start %
%%%%%%%%%
% wb_h : Waiting Bar Handle
% vargin : Launch argument
function startFcn(varargin)
% Startup, Data Initialization
global FOR_MCR_CODE;
%FOR_MCR_CODE=true; %- for making MCR
FOR_MCR_CODE=false; %- for normal mode

%=======================
% Initialize Function
%=======================
%-------------
% Set Log File
%-------------
if OSP_LOG('isnew'),
  if 0
    OSP_LOG('open');
  else
    % With Debug Mode
    OSP_LOG('open','Debug_Mode', true,...
      'log','POTATo.log',...
      'error','POTAToError.log',...
      'dbg','POTAToDebug.log');
  end
else
  OSP_LOG('msg',' ====> Launch POTATo! ');
  OSP_LOG('close');
  OSP_LOG('open','Debug_Mode', true,...
    'log','POTATo.log',...
    'error','POTAToError.log',...
    'dbg','POTAToDebug.log');
end
%-------------
% Make Data
%-------------
OSP_DATA('OPEN');

% Load Init Data
% Set Initial Data
OSP_DATA('SET',...
  'POTAToVersion','3.9.0',...
  'Version','2.5.2',...
  'Project',[],...
  'File',[],...
  'isPOTAToRunning',true);

%---------------------------------
% Check MATLAB TOOLBOX & Version
%---------------------------------
if 0   % You can set 0, if you do not mind lack of Toolbox Version in Error message.
  tmp=ver;
  mtver=OSP_DATA('GET','ML_TB'); % Matlab ToolBox
  mtver0 = version('-release');
  a=regexpi(mtver0,'[^0-9.]');
  if isempty(a),
    %  Relase 13, 14
    mtver.MATLAB=int8(str2double(mtver0)); % Add
  else
    try
      [s e]=regexpi(mtver0,'[0-9][0-9][0-9][0-9][ab]');
      pls=str2double(mtver0(s:e-1))-2005;
      if strcmp(mtver0(e),'b'),pls=pls+0.5;end
      mtver.MATLAB=14+pls; %,, R2006a::
    catch
      mtver.MATLAB=20; % Unknown Version...
    end
  end
  
  for ii=1:length(tmp)
    switch tmp(ii).Name
      case 'Signal Processing Toolbox'
        mtver.SignalProcessing=tmp(ii);
      case 'Statistics Toolbox'
        mtver.Statistics=tmp(ii);
      case 'Wavelet Toolbox'
        mtver.Wavelet=tmp(ii);
    end
  end
  OSP_DATA('SET','ML_TB',mtver); % Matlab ToolBox
end

%==============================
% Other Data (Argument Import)
%==============================
% Argument Translate
ospvarg=struct([]);
for vid=1:2:length(varargin)
  try
    ospvarg.(varargin{vid})=varargin{vid+1};
  catch
  end
end
OSP_DATA('SET','OspArguments',ospvarg);
OSP_LOG('msg', {...
  ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% '; ...
    ' % Open PoTATo : Version 3.9.0';...
  [' %   Start at : ' date]});
if (FOR_MCR_CODE)
  OSP_LOG('msg',' %   Powerd by Matlab Compiler Runtime');
else
  OSP_LOG('msg',' %   Powerd by Matlab');
end
OSP_LOG('msg',' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');  

%==============================
% Load  User-Setting Data
%==============================
try, SetingData('load'); end
return;
        
%%%%%%%%%%%%
% Closing %
%%%%%%%%%%%%
function clearOsp
% Finalization

%==========================
% Save  User-Setting Data
%==========================
try, SetingData('save'); end

%==========================
% Bug fix and so on.....
%==========================
try
  FileFunc('ConfineRelationFile');
end

%==========================
% Log out
%==========================

%-----------------
% Last Comment
%-----------------
try
  OSP_LOG('msg', ...
    {' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ', ...
      [' %    Done at : ' datestr(now)] ,...
      ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% '});
catch
  fprintf(1,[...
    ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n', ...
    ' %    Done at : %s\n',...
    ' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n'], datestr(now));
end

%=============================
% Finalize Function 
%=============================
%-----------------
% Data Close
%-----------------
OSP_LOG('close');
OSP_DATA('CLOSE');
return;


function SetingData(fcn)
%%%%%%%%%%%%%%%%%%%%%%%%
% SettingData('save');
%   save setting
% SettingData('load');
%   load setting
%%%%%%%%%%%%%%%%%%%%%%%%
global FOR_MCR_CODE;
global WinP3_EXE_PATH;

% ‰Šú‰»ƒtƒ@ƒCƒ‹
if FOR_MCR_CODE && ~isempty(WinP3_EXE_PATH)
    fname = [WinP3_EXE_PATH filesep 'setting' filesep 'POTAToSettingInfo.mat'];
else
    fname=OSP_DATA('GET','OspPath');
    fname = [fname filesep 'ospData' filesep 'POTAToSettingInfo.mat'];
end

fcn2 =eval(['@' fcn]);
varnm = {'PROJECT', 'PROJECTPARENT', ...
  'WORK_DIRECTORY', 'HELP_LANG', ...
  'OSP_STIMPERIOD_DIFF_LIMIT',...
  'POTATO_P3MODE',...
  'FILTER_RECIPE_GROUP_TYPE',...
  'P3_BENRIBUTTON_FUNCTION'};


warning off all;
% Get Version of MATLAB
try
  rver=OSP_DATA('GET','ML_TB');
  if isfield(rver,'MATLAB'),
    rver=rver.MATLAB;
  end
catch
  rver=0;
end

% Load Data
if strcmp(fcn, 'save')
  msgOK{1}=sprintf(' === SAVE Data List ===');
  msgNG   ={' --- NG List ---'};
  for varid = 1: length(varnm)
    try
      eval([varnm{varid} '= OSP_DATA(''GET'',varnm{varid});']);
      msgOK{end+1}=varnm{varid};
    catch
      %disp('[Warning] : POTATo Data Load Error');
      msgNG{end+1}=varnm{varid};
    end
  end
end

try
  if rver>=14 && strcmp(fcn,'save'),
    % save as MAT-File Version 6
    % Mode : 01-Aug-2005.
    feval(fcn2,fname,varnm{:},'-v6');
  else
    feval(fcn2,fname,varnm{:});
  end
catch
  %disp('[Warning] : POTATo Data Save Error');
end

% Set Data
if strcmp(fcn, 'load')
	
	%------------------------
	%-- default setting for first time
	if ~exist('PROJECTPARENT','var')
        p=fileparts(which('POTATo'));
        if FOR_MCR_CODE && ~isempty(WinP3_EXE_PATH)
            PROJECTPARENT= [WinP3_EXE_PATH filesep 'Projects'];
        else
            PROJECTPARENT= [p filesep 'Projects'];
        end
        load([p filesep 'ospData' filesep 'POTATo_Default_PROJECTSetting']);
        PROJECT.Path = PROJECTPARENT;
	end
	
  msgOK{1}=sprintf(' === LOAD Data List ===');
  msgNG   ={' --- NG List ---'};
  for varid = 1: length(varnm)
    try
      eval(['OSP_DATA(''SET'',varnm{varid},' varnm{varid} ');']);
      msgOK{end+1}=varnm{varid};
    catch
      msgNG{end+1}=varnm{varid};
    end
  end
  % --> Restore  ADVANCED MODE <--
  if FOR_MCR_CODE
    OSP_LOG('msg',' Developers MODE is off : cause MCR-CODE');
  end
end



OSP_LOG('msg',msgOK);
if length(msgNG)>1, OSP_LOG('msg',msgNG);end
warning on all;
return;
