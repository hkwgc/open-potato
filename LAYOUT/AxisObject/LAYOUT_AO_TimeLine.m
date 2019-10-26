function varargout=LAYOUT_AO_TimeLine(fnc,varargin)
% Axes Plugin Object : Time-Line

% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='Time Line2';
info.fnc     ='LAYOUT_AO_TimeLine';
%  data.ver  = 1.00;
info.ccb     ={'TimeRange','TimePoint'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% --- for change ---
if length(varargin)>=1,
  data=varargin{1};
end

% Set up : Plot Data
data.str = 'Time-Line v2';
data.fnc = 'LAYOUT_AO_TimeLine';
data.ver = 1.00;
if ~isfield(data,'time'),
  data.time= 1.00;
end
if ~isfield(data,'style'),
  data.style= 1;
end

prompt = {'Default Time [sec] :', 'Style(1-3):'};
def    = {num2str(data.time), num2str(data.style)};

flg=true;
while flg,
  flg=false;
  def = inputdlg(prompt,'Time Line Arguments', 1,def);
  if isempty(def), data={}; return; end
  try
    % Check 1st Argument
    data.time     = str2num(def{1});
    if isempty(data.time),
      error('Time must be numerical');
    end

    % Check 2nd Argument
    data.style    = round(str2num(def{2}));
    if length(data.style)~= 1,
      error('Style : Select One value');
    end

    if (data.style<=0) || (data.style>=4),
      error('Unknown Style : range from 1 to 3');
    end
  catch
    h=errordlg({'Input Variable Error. : ', ...
      ['   ' lasterr]});
    waitfor(h);
    flg=true;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% Object : obj.data ==
%          'Continous'/ 'Block' obj.mode ==
%
% See also osp_ViewAxesObject_TimeLine/getArgument
if 0,obj=varargin{1};end
str=['LAYOUT_AO_TimeLine(''draw'', ', ...
  'h.axes ,curdata, obj{idx})'];
if 0,
  str=['LAYOUT_AO_TimeLine(''timeline'', ', ...
    'h.axes, ', ...
    '[', num2str(obj.time), '], ', ...
    num2str(obj.style) ', curdata);'];
end
return;

function h=draw(gca0, curdata,obj, ObjectID)
% --> Using Current Data in plot <--
h=[];

try
  if isfield(curdata,'gcf'),
    set(curdata.gcf,'CurrentAxes',gca0);
  else
    set(gcbf,'CurrentAxes',gca0);
  end
catch
  axes(gca0);
end

rng=axis;
% Read TimePoint
if isfield(curdata,'TimePoint')
  time=curdata.TimePoint;
else
  time=obj.time;
  curdata.TimePoint = time;
end
time =time(:)';
timeNaN=time; timeNaN(:)=NaN;
x = [time; time; timeNaN];
x = reshape(x,prod(size(x)),1);
if isfield(curdata,'ylim')
	y=[curdata.ylim';NaN];
else
	y = [rng(3); rng(4); NaN];
end
y  = repmat(y,length(time),1);

%---
if isfield(obj,'flagRetain') && (obj.flagRetain) && ...
		isfield(obj,'RetainedObjectHandle') && ishandle(obj.RetainedObjectHandle)
	set(obj.RetainedObjectHandle, 'XData', x);
	set(obj.RetainedObjectHandle, 'YData', y);
	h.h = obj.RetainedObjectHandle;
else
	switch obj.style,
		case 1,
			v.LineWidth=1;
			v.Color=[0.8 .5 1];
			v.LineStyle = '-';
			v.EraseMode = 'xor';
		case 2,
			v.LineWidth=2;
			v.Color=[0 0 0];
			v.LineStyle = ':';
			v.EraseMode = 'none';
		case 3,
			v.LineWidth=1;
			v.Color=[1 0.5 0.5];
			v.LineStyle = ':';
			v.EraseMode = 'xor';
		otherwise,
			warning('Undefined Style :: Use 1/2/3');
	end
	
	h.h=line(x,y);
	set(h.h,'TAG','TimeLine2', ...
		'LineWidth',v.LineWidth, ...
		'Color',v.Color, ...
		'LineStyle',v.LineStyle,...
		'EraseMode',v.EraseMode);
end

if ~isfield(curdata,'TimePoint0') || (curdata.TimePoint0 == 1)
	set(h.h,'visible','off');
else
	set(h.h,'visible','on');
end 
%------------------------
obj.flagRetain = true; %-
%------------------------

%==================================
%=      Common-Data Setting       =
%==================================
myName='LAYOUT_AO_TimeLine_ObjectData';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
    h.h, myName, ...
    gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', ...
    h.h, myName, ...
    gca0, curdata, obj);
end
