function varargout=LAYOUT_CCO_UIControl(fcn,varargin)
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% autohr : TK
% create : 25-Nov-2013
%
% ver. 0
%------------->

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
basicInfo.name   ='UI Control';
basicInfo.fnc    ='LAYOUT_CCO_UIControl';
% File Information
basicInfo.rver   ='$Revision: 0 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/02 11:29:58 $';
basicInfo.date([1,end])   =[];

basicInfo.cvfname  = {'P3UIControl'};
basicInfo.uicontrol= {'pushbutton'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vdata=getArgument(varargin)
% Set vdata
%     vdata.name    : 'defined in createBasicInfo'
%     vdata.fnc     :  this Function name
%     vdata.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vdata=createBasicInfo;
DefVal{1}={{'pushbutton','edit','popupmenu','checkbox','listbox'},1};
DefVal{2} = 'var';
DefVal{3} = '0';
DefVal{4} = '';
DefVal{5} = '';%- Create eval
DefVal{6} = '';%- Callback eval
%DefVal{7} = 'top';
%DefVal{8} = 'y';

v=varargin{1};
if isfield(varargin{1},'Style'), DefVal{1}{2}=v.Style{1}; end
if isfield(varargin{1},'Name'), DefVal{2}=v.Name; end
if isfield(varargin{1},'Value'), DefVal{3}=v.Value; end
if isfield(varargin{1},'String'), DefVal{4}=v.String; end
if isfield(varargin{1},'CreateEval'), DefVal{5}=v.CreateEval; end
if isfield(varargin{1},'CallBackEval'), DefVal{6}=v.CallBackEval; end
%if isfield(varargin{1},'LabelPos'), DefVal{7}=v.LabelPos; end
%if isfield(varargin{1},'DoCallback'), DefVal{8}=v.DoCallback; end

if isfield(varargin{1},'pos'), vdata.pos=v.pos;
else,	vdata.pos =[0, 0, 0.9, 0.1];
end



flag=true;
while flag,
	STR = subP3_inputdlg({'UI Style',...
		'Variable name', 'Default value','String','Create eval string','Callback eval string'}, ...
		'Settings', 2, DefVal);
	if isempty(STR), break; end
	flag=false;
end
% Canncel
if flag,
	vdata=[]; return;
end

% OK
vdata.Style = STR{1};
vdata.Name = STR{2};
vdata.Value = STR{3};
vdata.String = STR{4};
vdata.CreateEval = STR{5};
vdata.CallBackEval = STR{6};

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_UIControl(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = ['UIControl_' obj.Name];
CCD.CurDataValue = {'Data'};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;

% % Set position of Time slider, Time edit, Time-Step popup components
% if strcmp(lower(obj.LabelPos), 'left')
% 	pos1(1:4) = [pos(1)+pos(3)/2       pos(2)            pos(3)/2       pos(4)];
% 	pos2(1:4) = [pos(1)                pos(2)            pos(3)/2       pos(4)];
% else %- Top
% 	pos2(1:4) = [pos(1)                pos(2)+pos(4)/2   pos(3)       pos(4)/2];
% 	pos1(1:4) = [pos(1)                pos(2)            pos(3)       pos(4)/2];
% end

% %=====================
% % Set Special User Data
% % <- User Data 1 is Special ->
% %=====================
% Edit
%curdata.Callback_2DImageTime.handles= ...
% if ~isfield(obj, 'Style')
% 	obj.UIType='edit';
% end
% if strcmpi(obj.UIType,'edit')
% 	str=obj.DefVal;
% else
% 	str=obj.String;
% end

CCD.handle= ...
	uicontrol(hs.figure1,...
	'Style',obj.Style{2}, ...
	'String', obj.String, ...
	'BackgroundColor',[1 1 1], ...
	'Units','normalized', ...
	'Position', pos, ...
	'TooltipString','Variable Edit', ...
	'Tag',CCD.Name, ...
	'Callback', ...
	'LAYOUT_CCO_UIControl(''Callback'',gcbo)');

% %- Label text
% if isfield(obj,'Label')
% 	txtStr=obj.Label;
% else
% 	txtStr = obj.VarName;
% end

% if isfield(obj,'DoCallback')
% 	if strcmpi(obj.DoCallback,'y')||strcmpi(obj.DoCallback,'yes')
% 		%txtStr = ['*' txtStr ''];
% 		curdata.UIControl_DoCallback_flag.(obj.VarName) = true;
% 	else
% 		set(CCD.handle,'backgroundcolor',[0.8 0.9 1]);
% 		curdata.UIControl_DoCallback_flag.(obj.VarName) = false;
% 		txtStr = ['(' txtStr ')'];
% 	end
% end
%-

%=== Create Eval
V.curdata=curdata;
V.pos=pos;
V.handle=CCD.handle;
eval(obj.CreateEval);
%===========

% % Text
% CCD.handle_txt_time = ...
% 	uicontrol(hs.figure1,...
% 	'Style','text','String', txtStr, ...
% 	'Units','normalized', ...
% 	'BackgroundColor', get(hs.figure1,'Color'),...
% 	'Position', pos2, ...
% 	'HorizontalAlignment', 'left');
% %-----

% Set handles to Time-UserData{1}
%set(CCD.handle, 'UserData', {obj.VarName});
set(CCD.handle, 'UserData', {obj});

curdata.(obj.Name) = subMake_ValueStr(CCD.handle);

if isfield(curdata,'CommonCallbackData')
	curdata.CommonCallbackData{end+1}=CCD;
else
	curdata.CommonCallbackData={CCD};
end
return;

function s=subRefineInputValue(s)
%- check and refine input value
if isempty(str2num(s))
	%- for string
	%s=['''' s ''''];
	s=s;
else
	%- for numeric
	try
		s = eval([s ';']);
	catch %- is vector?
		try
			s = eval(['[' s '];']);
		catch %- impossible to understand
			errordlg(sprintf('Input value ''%s'' is wrong.',valuestr), 'Error value', 'modal');
			s = nan;
			return;
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Callback(h)
% Execute on Kind-Selector Edit-Text
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

%=== Callback Eval
V.myData=subMake_ValueStr(h);
eval(ud{1}.CallBackEval);
%============

for idx=2:length(ud),
	% Get Data
	vdata = p3_ViewCommCallback('getData', ...
		ud{idx}.axes, ...
		ud{idx}.name, ud{idx}.ObjectID);
	
	%= Update ===================
	fn=fieldnames(V);
	tg=strcmp(fn,'myData');
	vdata.cudata.(ud{1}.Name) = V.myData;
	for k=find(~tg)'
		vdata.curdata.(fn{k}) = V.(fn{k});
	end
	%=========================
	
	%- execute callbacks?
	if isfield(vdata.curdata,'UIControl_DoCallback_flag') && ...
			isfield(vdata.curdata.UIControl_DoCallback_flag,ud{1}.VarName) &&...
			~vdata.curdata.UIControl_DoCallback_flag.(ud{1}.VarName)
		%- update curdata
		p3_ViewCommCallback('Update',vdata.handle, ud{idx}.name, ud{idx}.axes, vdata.curdata, vdata.obj,idx);
	else
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
end

return;

function valuestr=subMake_ValueStr(h)
	
ud=get(h,'UserData');

switch lower(ud{1}.Style{2})
	case 'edit'
		valuestr = get(h,'String');
		valuestr=subRefineInputValue(valuestr);
	case {'popupmenu','listbox'}
		valuestr.Value = get(h,'Value');
		valuestr.String = get(h,'String');	
		valuestr.Select = valuestr.String(valuestr.Value,:);
		valuestr.Select = strrep(valuestr.Select,' ','');
	case 'checkbox'
		valuestr.Value = get(h,'Value');
	case 'pushbutton'
		valuestr='';
end


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
