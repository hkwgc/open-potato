function varargout=LAYOUT_CCO_VarEdit(fcn,varargin)
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% autohr : TK
% create : 25-Nov-2007
%
% ver. 2.01 (2013-07-29)
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
basicInfo.name   ='Variable Edit';
basicInfo.fnc    ='LAYOUT_CCO_VarEdit';
% File Information
basicInfo.rver   ='$Revision: 1.2 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/02 11:29:58 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname  = {'VarEdit'};
basicInfo.uicontrol= {'edit'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vdata=getArgument(varargin)
% Set vdata
%     vdata.name    : 'defined in createBasicInfo'
%     vdata.fnc     :  this Function name
%     vdata.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vdata.name='Variable Edit';
vdata.fnc ='LAYOUT_CCO_VarEdit';
vdata.pos =[0, 0, 0.9, 0.1];
DefVal{1}='edit';
DefVal{2} = 'var';
DefVal{3} = '0';
DefVal{4} = '';
DefVal{5} = 'Label';
DefVal{6} = num2str(vdata.pos);
DefVal{7} = 'top';
DefVal{8} = 'y';

v=varargin{1};
if isfield(varargin{1},'UIType'), DefVal{1}=v.UIType; end
if isfield(varargin{1},'VarName'), DefVal{2}=v.VarName; end
if isfield(varargin{1},'DefVal'), DefVal{3}=v.DefVal; end
if isfield(varargin{1},'String'), DefVal{4}=v.String; end
if isfield(varargin{1},'Label'), DefVal{5}=v.Label; end
if isfield(varargin{1},'pos'), DefVal{6}=num2str(v.pos); end
if isfield(varargin{1},'LabelPos'), DefVal{7}=v.LabelPos; end
if isfield(varargin{1},'DoCallback'), DefVal{8}=v.DoCallback; end

flag=true;
while flag,
	STR = inputdlg({'UIType(edit/popupmenu/checkbox/listbox)',...
		'Variable name', 'Default value','String', 'Label text', 'Relative Position : ',...
		'Label position (Top/Left)','Do callback function (y/n)'}, ...
		'Settings', 2, DefVal);
	if isempty(STR), break; end
	try
		pos0=str2num(STR{6});
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
	vdata=[]; return;
end

% OK
vdata.pos =pos0;
vdata.UIType = STR{1};
vdata.VarName = STR{2};
vdata.DefVal = STR{3};
vdata.String = STR{4};
vdata.Label = STR{5};
vdata.LabelPos = STR{7};
vdata.DoCallback = STR{8};

% rename
vdata.name_Label=sprintf('%s(%s)',vdata.name,vdata.VarName);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_VarEdit(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

% for version 
if ~isfield(obj,'UIType')
	obj.UIType='edit';
end

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = ['VarEdit_' obj.VarName];
CCD.CurDataValue = {obj.VarName, 'VarEdit'};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;

% Set position of Time slider, Time edit, Time-Step popup components
if strcmp(lower(obj.LabelPos), 'left')
	pos1(1:4) = [pos(1)+pos(3)/2       pos(2)            pos(3)/2       pos(4)];
	pos2(1:4) = [pos(1)                pos(2)            pos(3)/2       pos(4)];
else %- Top
	pos2(1:4) = [pos(1)                pos(2)+pos(4)/2   pos(3)       pos(4)/2];
	pos1(1:4) = [pos(1)                pos(2)            pos(3)       pos(4)/2];
end

% %=====================
% % Set Special User Data
% % <- User Data 1 is Special ->
% %=====================
% Edit
%curdata.Callback_2DImageTime.handles= ...

if strcmpi(obj.UIType,'edit')
	str=obj.DefVal;
else
	str=obj.String;
end

CCD.handle= ...
	uicontrol(hs.figure1,...
	'Style',obj.UIType, ...
	'String', str, ...
	'BackgroundColor',[1 1 1], ...
	'Units','normalized', ...
	'Position', pos1, ...
	'TooltipString','Variable Edit', ...
	'Tag','CCD_VarEdit', ...
	'Callback', ...
	'LAYOUT_CCO_VarEdit(''Edit_Callback'',gcbo)');

%- Label text
if isfield(obj,'Label')
	txtStr=obj.Label;
else
	txtStr = obj.VarName;
end

if isfield(obj,'DoCallback')
	if strcmpi(obj.DoCallback,'y')||strcmpi(obj.DoCallback,'yes')
		%txtStr = ['*' txtStr ''];
		curdata.VarEdit_DoCallback_flag.(obj.VarName) = true;
	else
		set(CCD.handle,'backgroundcolor',[0.8 0.9 1]);
		curdata.VarEdit_DoCallback_flag.(obj.VarName) = false;
		txtStr = ['(' txtStr ')'];
	end
end
%-

% Text
CCD.handle_txt_time = ...
	uicontrol(hs.figure1,...
	'Style','text','String', txtStr, ...
	'Units','normalized', ...
	'BackgroundColor', get(hs.figure1,'Color'),...
	'Position', pos2, ...
	'HorizontalAlignment', 'left');
%-----

% Set handles to Time-UserData{1}
%set(CCD.handle, 'UserData', {obj.VarName});
set(CCD.handle, 'UserData', {obj});

curdata.(obj.VarName) = subMake_ValueStr(CCD.handle);

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
function Edit_Callback(h)
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

valuestr=subMake_ValueStr(h);

for idx=2:length(ud),
	% Get Data
	vdata = p3_ViewCommCallback('getData', ...
		ud{idx}.axes, ...
		ud{idx}.name, ud{idx}.ObjectID);
	
	% Update
	vdata.curdata.(ud{1}.VarName) = valuestr;
	
	%- execute callbacks?
	if isfield(vdata.curdata,'VarEdit_DoCallback_flag') && ...
			isfield(vdata.curdata.VarEdit_DoCallback_flag,ud{1}.VarName) &&...
			~vdata.curdata.VarEdit_DoCallback_flag.(ud{1}.VarName)
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

switch lower(ud{1}.UIType)
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
