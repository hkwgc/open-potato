function osp_ini_fin(type,varargin)
% OSP Data I/O Function
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.13
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
% Original auther : Masanori Shoji
% create : 2004.12.21
% $Id: osp_ini_fin.m 180 2011-05-19 09:34:28Z Katura $
%

state=OSP_DATA;

switch type
    case 1      % initiarize
        if state~=0, return; end
        startFcn(varargin{:});
        
    case 2      % close
        clearOsp;
        
    otherwise
        OSP_LOG('perr', mfilename, ...
            {[' In ''osp_ini_fin'' : ' datestr(now)]; ...
                ' Undefined type Inputed'});
        errordlg(['Program Error : ' mfilename ' Undefined type']);
        return;
end

%%%%%%%%%
% Start %
%%%%%%%%%
% wb_h : Waiting Bar Handle
% vargin : Launch argument
function startFcn(varargin)

% -- For OSP_LOG --
% Set Log File
if 0
	OSP_LOG('open');
else,
  % With Debug Mode
  OSP_LOG('open','Debug_Mode', true);
end

OSP_DATA('OPEN');

% Load Init Data
% Set Initial Data
OSP_DATA('SET',...
    'Version','2.5.30.2',...
    'Project',[],...
    'File',[]);

% Check MATLAB TOOLBOX
if 1   % You can set 0, if you do not mind lack of Toolbox Version in Error message.
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
        if strcmpi(mtver0(e),'b')
          pls=pls+0.5;
        end
        mtver.MATLAB=14+pls;
      catch
        mtver.MATLAB=20; % Unknown Version
        disp('Unknown: MATLAB Release ');
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

% Argument Translate
if length(varargin)~=0
    wbr=0.5/ length(varargin);
end
ospvarg=struct([]);
for vid=1:2:length(varargin)
    pnm =varargin{vid};   %Propaty
    pvl =varargin{vid+1};
    ospvarg=setfield(ospvarg,pnm,pvl);
end
OSP_DATA('SET','OspArguments',ospvarg);

OSP_LOG('msg', ...
	{' ------------------------------------------- '; ...
	 ' OSP  : Version 2.5.30.2';...
	 '';...
	 ['    Start at : ' datestr(now)] ;...
	 ' ------------------------------------------- '});

% Load  Assumed Data
try, SetingData('load'); end
return;



%%%%%%%%%%%%
% Closing %
%%%%%%%%%%%%
function clearOsp
try
  if ~OSP_LOG('isnew')
    OSP_LOG('msg', ...
      {' ------------------------------------------- ', ...
        ['    Done at : ' datestr(now)] ,...
        ' ------------------------------------------- '});
  end
end
% Save  Assuming Data
try, SetingData('save'); end
OSP_LOG('close');
OSP_DATA('CLOSE');

return;


function SetingData(fcn) %#ok
% not in use.
%  replaced by POTATo_ini_fin's one
return;
