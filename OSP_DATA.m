function varargout=OSP_DATA(method, varargin)
% OSP Data Manager
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
% -------------------------------------
%
% OSP Data Manager:
%  state=OPS_DATA : return OSP Data State
%    state
%         0 : Not open
%         1 : open
%
%  OSP_DATA('OPEN')
%    open OSP_DATA & lock
%
%  OSP_DATA('CLOSE')
%    clear OSP_DATA & unlock
%
%  OSP_DATA('SET',name,value)
%     Set Data
%  OSP_DATA('SET',name1,value1,name2,value2, ....)
%
%  value=OSP_DATA('GET',name)
%    Get Data
%  [value1, value2,...] = OSP_DATA('GET',name1, name2, ...)
%
%  Here  name is a variable name.
%  % wrote extensively on variable
%  %   in the Excel sheet. -> 'OspData.xls'
%
%  OSP_DATA('All')
%     For Debug
%     You can get All Variable that Checked in.
%     STATE is OSP Data State
%     osp   is defined data
%     other is not defined data in initialize
%
%



%
% Copyright(c) 2019, National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
%


% == History ==
% create : 2004.10.14

% Revition 1.19 :
%   Adding : FILTER_RECIPE_GROUP_TYPE

%%%%%%%%%%%%%%%%%%
% Argument Check
%%%%%%%%%%%%%%%%%%%
if nargin==0
	varargout{1}=datamanage('STATE');
	return;
end

%%%%%%%%%%%%%%%
% Method Check
%%%%%%%%%%%%%%%
method=upper(method);
switch method
	case 'SET'
		if mod(nargin-1,2)~=0
			msg=[' In OSP DATA :'...
				' Argument Error For Set : '...
				'OSP_DATA(''SET'',''Name'',''Value'',...) '];
			OSP_LOG('perr',msg);error(msg);
		end
		dbg=false;
		if dbg,
			fp=fopen('OSP_DATA.log','a');
			st = dbstack;
			for id = 2:length(st)
				try
					fprintf(fp, ' %s : %d\n', st(id).name, st(id).line);
				catch
					fprintf(fp,' Unknown : --\n');
				end
			end
		end
		for ii=1:2:length(varargin)
			datamanage(varargin{ii},varargin{ii+1});
			if dbg,
				fprintf(fp,'Set %s',varargin{ii});
				if ischar(varargin{ii+1})
					fprintf(fp,' : %s\n',varargin{ii+1});
				else
					fprintf(fp,'\n');
				end
			end
		end
		if dbg,fclose(fp);end
		
	case 'GET'
		if (nargin-1) ~= nargout
			msg=' In OSP DATA : Argument Error For Get';
			OSP_LOG('perr',msg);error(msg);
		end
		for ii=1:nargout
			varargout{ii}=datamanage(varargin{ii});
		end
		
	case {'OPEN','CLOSE'}
		if nargin~=1  || nargout~=0
			msg=' In OSP DATA : Argument Error For Get';
			OSP_LOG('perr',msg);error(msg);
		end
		datamanage(method);
		
	case {'ALL'}  % For Debug /
		if nargin~=1
			msg=' In OSP DATA : Argument Error For Get';
			OSP_LOG('perr',msg);error(msg);
		end
		varargout{1}=datamanage(method);
		
	otherwise
		msg=' Argument Error';
		OSP_LOG('perr', msg);  error(msg);
end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=datamanage(name,data)
persistent STATE OSP_STRUCT_DATA OTHER;

% initialize
if isempty(STATE),  STATE=0;    end
name=upper(name);

% Special : Method
switch name
	case 'STATE'
		data=STATE;
		return;
		
	case 'OPEN'
		mlock;
		STATE=1;
		if isempty(OSP_STRUCT_DATA)
			% ==== OSP_STRUCT_DATA Definition ====
			OSP_STRUCT_DATA=newOSPstruct;
		end
		ts=(10000000-OSP_STRUCT_DATA.CIRCULATION_ID)+ floor(now);
		OTHER.TMP_STATUS=ts/1000;
		return;
		
	case 'CLOSE'
		STATE=0;
		OSP_STRUCT_DATA=[]; OTHER=[];
		munlock;
		return;
		
	case {'ALL'}  % For Debug /
		data.state  = STATE;
		data.osp    = OSP_STRUCT_DATA;
		data.other  = OTHER;
		return;
end

% -- evaluate string --
if isfield(OSP_STRUCT_DATA,name)
	% Do not Make new field in OSP_STRUCT_DATA
	str=['OSP_STRUCT_DATA.' name];
else
	str=['OTHER.' name];
end

if nargin == 2
	%  Set Data
	eval([str '=data;']);
else
	% Get Data
	
	% No Data
	if STATE~=1,   data=[];  return; end
	
	% get data
	if isfield(OSP_STRUCT_DATA,name)  || isfield(OTHER,name)
		data=eval([str ';']);
	else
		% Error : No Data
		msg = sprintf('OSP_DATA : Not Defined Data : %s',name);
		OSP_LOG('err',msg);
		msg2=fieldnames(OSP_STRUCT_DATA);
		msgx={msg,'OSP Structure :', msg2{:}};
		if isstruct(OTHER)
			msg2=fieldnames(OTHER);
			msgx={msgx{:}, 'Other Data : ', msg2{:}};
		end
		OSP_LOG('warn',msgx);
		warndlg(msg);
		data=[];
	end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define OSP_STRUCT
%
%  If you Add or Change OSP_STRUCT
%    Change Document :
%       1: Function OSP_DATA
%       2: About OSP version 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=newOSPstruct

%%%%%%%%%%%%%%%%%
% Version
%   & currency
%%%%%%%%%%%%%%%%%
data.VERSION_TAG='OSP Software Version';
data.VERSION=[];

% -- Tool Box --
data.ML_TB_TAG=' MatLab Toolbox Versions';
mtv.SignalProcessing=[];
mtv.Statistics=[];
mtv.Wavelet=[];
data.ML_TB=mtv;
clear mtv;

% --- Default Setting include ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OSP Main  Controller Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.OSPPATH_TAG=' OSP Main Controller Path';
ospPath=which('OSP');
if iscell(ospPath)
	ospPath=ospPath{1};
end
data.OSPPATH=fileparts(ospPath);

%%%%%%%%%%%%%%%%%
% Color Setting
%%%%%%%%%%%%%%%%%
data.OSP_COLOR_TAG='OSP Color Data number';
data.OSP_COLOR=[];    % numerical value


% --- Normal Defind Data ---
%%%%%%%%%%%%%%%%%
% Main Data
%%%%%%%%%%%%%%%%%
data.MAIN_CONTROLLER_TAG='Main Controller : handles, event';
mc.hObject=[];              % Handle of Mainc-Controller
mc.eventdata=[];            % Allways null in this Matlab Version
mc.handles=[];              % Handles of Mainc-Controller
data.MAIN_CONTROLLER=mc;
clear mc;

%%%%%%%%%%%%%%%%%
% File Manager
%%%%%%%%%%%%%%%%%
% --- Project ---
data.PROJECTPARENT='';
data.PROJECTPARENT_TAG='Project-Parent-Directory :POTATo';
data.PROJECT_DATA_DIR=[filesep 'OspDataDir'];  % Define
data.PROJECT_TAG='Project Data';
pj.index =[];       % Index of Project  : int
pj.Name=[];         % Project Name : *char
pj.Path=[];         % Project Path : *char
pj.CreateDate=[];   % Create Date  : date number( See Now)
pj.Operator=[];     % Project Manager Name : *char
pj.Comment=cell(0); % Comment       : Cell array
data.PROJECT=pj;
clear pj;

% --- ActiveData ---
data.ACTIVEDATA_TAG='Active Data';
ad.data=[];         % Data
ad.fcn=[];          % DataDefined Function
data.ACTIVEDATA=ad;
clear ad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Active Flags ( to lock )
%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.ACTIVE_FLAG_TAG={'Active Flag',...
	'bit 1 : File Set Active.', ...
	'bit 2 : Calculation Running',...
	'bit 3 : Module Launcing'};
data.ACTIVE_FLAG=0;

%%%%%%%%%%%%%%%%%
% Local Data
%%%%%%%%%%%%%%%%%
data.OSP_LOCALDATA_TAG='OSP Data in active';
data.OSP_LOCALDATA=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Signal Preprocessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.SP_ANONYMITY_TAG= ...
	{'Signal Preprocessor: 1: Not Read Subject Name', ...
	'Logical'};
data.SP_ANONYMITY=false;
data.SP_Rename_TAG='Rename Option';
data.SP_Rename='-';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter Data
data.FILTER_MANAGER_TAG='OSP Filter Manager Data';
data.FILTER_MANAGER=[];

data.FILTER_RECIPE_GROUP_TYPE_TAG='';
data.FILTER_RECIPE_GROUP_TYPE='All';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Blocking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OSP_STIMPERIOD_DIFF_LIMIT
data.OSP_STIMPERIOD_DIFF_LIMIT_TAG = 'Limit of Stimulation Period Difference [m sec]';
data.OSP_STIMPERIOD_DIFF_LIMIT     = 999999999;

%%%%%%%%%%%%%%%%%
% Give Arguments
%%%%%%%%%%%%%%%%%
data.OSPARGUMENTS=[];

%%%%%%%%%%%%%%%%%%%%
% Directory's
%%%%%%%%%%%%%%%%%%%%
data.WORK_DIRECTORY_TAG = ...
	['USERs working directory ', ...
	'to save figure, Mat-file and so on.'];
data.WORK_DIRECTORY     =[];

data.RECIPE_DIRECTORY_TAG = 'Directory that save Recipe.';
data.RECIPE_DIRECTORY ='';

data.HELP_LANG_TAG = 'Language of Help document';
data.HELP_LANG = 'ja';

%%%%%%%%%%%%%%%%%%%%
% POTATo Setting
%%%%%%%%%%%%%%%%%%%%
data.ISPOTATORUNNING=false;
%data.POTATO_SIMPLEMODE=true;
%data.POTATO_ADVANCEDMODE=false;
%data.POTATO_P3MODE='Normal';
data.POTATO_P3MODE='Research';
%data.POTATO_P3MODE='Developer';
data.P3_BENRIBUTTON_FUNCTION='';

data.CIRCULATION_ID =20130313;
return;


