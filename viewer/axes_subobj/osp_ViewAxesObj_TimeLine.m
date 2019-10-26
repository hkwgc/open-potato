function varargout=osp_ViewAxesObj_TimeLine(fnc,varargin)
% Axes Plugin Object : Time-Line


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



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
info.MODENAME='Time-Line';
info.fnc     ='osp_ViewAxesObj_TimeLine';
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
data.str = 'Time-Line';
data.fnc = 'osp_ViewAxesObj_TimeLine';
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
	try,
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
obj=varargin{1};
str=['osp_ViewAxesObj_TimeLine(''timeline'', ', ...
		'h.axes, ', ...
		'[', num2str(obj.time), '], ', ...
		num2str(obj.style) ', curdata);'];
return;

function h=timeline(gca0,time,style, curdata,ObjectID,oldh),
% --> Using Current Data in plot <--
h=[];
if 0,
	% Unit of GCA must be sec.
	xlabel('time [sec]');
end
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

switch style,
	case 2,
	case 3,
	otherwise,
		% Line
		if style~=1,
			% Warning
			warning('Undefined Style :: Use 1');
		end
		time =time(:)';
		timeNaN=time; timeNaN(:)=NaN;
		x = [time; time; timeNaN];
		x = reshape(x,prod(size(x)),1);
		y = [rng(3); rng(4); NaN];
		y  = repmat(y,length(time),1);
		if nargin>=6 && ishandle(oldh),
		  set(oldh,'XData',x, 'YData',y);
      h.h=oldh;
		else
		  h.h=line(x,y);
		  set(h.h,'TAG','TimeLine', ...
			  'LineWidth',3, ...
			  'Color',[0 1 0], ...
			  'LineStyle','-.',...
			  'EraseMode','xor');
		end
end

%================================== 
%=      Common-Data Setting       =
%==================================
od=getappdata(gcf,'AXES_TimeLine_ObjectData');
odadd.handle = h.h; % Handles of connected function
odadd.style   = style;
odadd.time    = time;
odadd.curdata.dummy=[];
if exist('ObjectID','var'),
	od{ObjectID}=odadd;
else
	if isempty(od),
		od{1}=odadd;
		ObjectID=1;
  else
		od{end+1}=odadd;
		ObjectID=length(od);
	end
end
setappdata(gcf,'AXES_TimeLine_ObjectData',od);

% ==============================
% ==== Callback Setting List ===
% ==============================
%------------------------
%  Time Range
%------------------------
udadd.ObjectID=ObjectID;
udadd.axes=gca0;
if isfield(curdata,'Callback_TimeRange') && ...
		isfield(curdata.Callback_TimeRange,'handles') && ...
		ishandle(curdata.Callback_TimeRange.handles),
	% See also osp_view
	h0            = curdata.Callback_TimeRange.handles;
	udadd.str  = ['ud{idx}=osp_ViewAxesObj_TimeLine(' ...
			'''TimeChange'',ud{idx}, time);'];
	ud=get(h0,'UserData');
	ud{end+1}=udadd;
	set(h0,'UserData',ud);
end

%------------------------
%  Time Slider
%------------------------
if isfield(curdata,'Callback_2DImageTime') && ...
		isfield(curdata.Callback_2DImageTime,'handles') && ...
		ishandle(curdata.Callback_2DImageTime.handles),
	% See also osp_ViewCallback_2DImageTime
	h             = curdata.Callback_2DImageTime.handles;
	udadd.ObjectID=ObjectID;
	udadd.axes=gca0;
	udadd.str=['ud{idx}=osp_ViewAxesObj_TimeLine(' ...
			'''TimeChange'',ud{idx}, timepos,unit);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================
function ud=TimeChange(ud,time,unit)
% Change TimeRange  Callback of Time Range
%==================================
% Check,Change time range
if (nargin>=3),
	time = time/unit;
end
time(~isfinite(time))=[]; % Delete Finite Data
if isempty(time), return; end

%--> Object Data of PLOT-TEST <--
od = getappdata(gcf,'AXES_TimeLine_ObjectData');
od = od{ud.ObjectID};
curdata.dumy  =[];
ud.handle=timeline(ud.axes, time, od.style, ...
		   curdata, ud.ObjectID,od.handle);

