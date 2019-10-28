function varargout=LAYOUT_CCO_StimMarkSelect(fcn,varargin)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% autohr : TK
% create : 22-07-2010
%
%------------->

% Help for noinput
if nargin==0,  fcn='help';end

%====================
% Swhich by Function
%====================
switch fcn
  case {'help','Help','HELP'},
    OspHelp(mfilename);
  case {'createBasicInfo','getDefaultCObject','drawstr','getArgument'},
    % Basic Information
    varargout{1} = feval(fcn, varargin{:});
  case 'make',
    varargout{1} = make(varargin{:});
  case 'ExeCallback'
    ExeCallback(varargin{:});
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
%===============================
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         '2DImage Time'
%       Myfunction Name
%         'vcallback_2DImageTime'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Stim mark select';
basicInfo.fnc    ='LAYOUT_CCO_StimMarkSelect';
% File Information
basicInfo.rver   ='$Revision: 1.0 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/07/22  $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname  = {'StimMarkSelect'};
basicInfo.uicontrol= {'listbox'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.name='Stim mark select';
data.fnc ='LAYOUT_CCO_StimMarkSelect';
data.pos =[0, 0, 0.05, 0.1];
DefVal{1} = '1';
DefVal{2} = num2str(data.pos);

v=varargin{1};
if isfield(varargin{1},'DefVal'), DefVal{1}=v.DefVal; end
if isfield(varargin{1},'pos'), DefVal{2}=num2str(v.pos); end

flag=true;
while flag,
  STR = inputdlg({'Default value', 'Relative Position : '}, ...
    'Settings', 2, DefVal);
  if isempty(STR), break; end
  try
    pos0=str2num(STR{2});
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);continue;
    end
  catch
    h=errordlg({'Input Proper Number:',lasterr});
    waitfor(h); continue;
  end
  flag=false;
end
% Canncel
if flag,
  data=[]; return;
end

% OK
data.pos =pos0;
data.DefVal = STR{1};

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_StimMarkSelect(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'StimKind';
CCD.CurDataValue = {'stimkind'};
CCD.handle       = []; % Update

%- get stim mark(s) from hdata
hdata=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);

%- Because this CCO is only for Blocked-data,
%- if hdata is not for BDATA, do nothing and return.
%if ~isfield(hdata,'stimkind'), return;end
if strcmpi(curdata.region,'continuous')
	return
end
%------------------------------------------------

try
	uniquemarks=unique(hdata.stimkind);
	xstr= uniquemarks;
	try
		if isnumeric(str2num(obj.DefVal))
			stimkind=str2num(obj.DefVal);
		else
			stimkind=1;
		end
	catch
		stimkind=1;
	end
	%stimIDX=find(xstr==stimkind); %-Bug: when stimkind's length >1.
	stimIDX = find(ismember(xstr, stimkind));
	xxstr={};
	for xx=1:length(xstr)
		xxstr{end+1}=sprintf('Mark : %d',xstr(xx));
	end
	xstr=xxstr;
	if ~isempty(stimIDX)
		%stimIDX=stimIDX(1);
	else
		stimIDX=1; % dumy 1
		stimkind=uniquemarks(stimIDX);
		%xstr='NG';
	end
catch
	stimIDX=1;
	xstr='NG: Not Block';
end
%---

pos=getPosabs(obj.pos,apos);

%=====================

%curdata.Callback_2DImageTime.handles= ...
CCD.handle = ...
  uicontrol(hs.figure1,...
  'Style','listbox', ...
  'String', xstr, ...
  'Value', stimIDX,...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', pos, ...
  'TooltipString','select mark(s)', ...
  'Tag','CCD_StimMarkSelect', ...
  'Max',10^10,...
  'Callback', 'LAYOUT_CCO_StimMarkSelect(''Callback'',gcbo)');

%- menu option
curdata.Callback_StimKindSelectMenuParent.handles=...
  uimenu(curdata.menu_callback,'Label','&Stim kind select', ...
  'TAG', 'Callback_StimKindSelectMenuParent');

curdata.Callback_StimKindSelectMenu.handles(1)=...
	uimenu(curdata.Callback_StimKindSelectMenuParent.handles,'Label','&Averaging', ...
	'Checked','on',...
	'TAG', 'Callback_StimKindSelectMenuAveraging',...
	'UserData',{CCD.handle},...
	'Callback', 'LAYOUT_CCO_StimMarkSelect(''Callback_MenuOption'',gcbo)');
UD1.stimkind = uniquemarks;
UD1.handle_MenuOption = curdata.Callback_StimKindSelectMenu.handles(1);

% Set handles to Time-UserData{1}
%CCD.handle= curdata.Callback_2DImageTime.handles;
set(CCD.handle, 'UserData', {UD1});

%- set to curdata
curdata.stimkind = stimkind;

if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Callback(h)
% Execute on Mark-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    timepos  : time  index
%    unit     : time-unit of Cdata
ud=get(h,'UserData');
value = get(h,'Value');
UD1 = ud{1};
stimkind = UD1.stimkind(value);

%- check average option state in menu
if strcmp( get(UD1.handle_MenuOption,'Checked'), 'on' )
	flag_Averaging = true;
else
	flag_Averaging = false;
end

for idx=2:length(ud),
  % Get Data
  vdata = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  
  % Update
  vdata.curdata.stimkind = stimkind;
  vdata.curdata.flag.InterMarkAveraging = flag_Averaging;
  
  % Delete handle
  for idxh = 1:length(vdata.handle),
    try
      if ishandle(vdata.handle(idxh)),
        delete(vdata.handle(idxh));
      end
    catch
      warning(lasterr);
    end % Try - Catch
  end
  
  % Evaluate (Draw)
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end % Try - Catch
end
return;


%========================================
function Callback_MenuOption(h)

if strcmp(get(h,'Checked'),'on')
	set(h,'checked','off');
else
	set(h,'checked','on');
end

ud=get(h,'UserData');
Callback(ud{1});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
