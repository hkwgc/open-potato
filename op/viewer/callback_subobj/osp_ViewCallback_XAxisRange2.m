function varargout=osp_ViewCallback_XAxisRange2(fcn,varargin)
% X-Axis Range Callback for OSP-Viewer by Axis
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_XAxisRange2.m 298 2012-11-15 08:58:23Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



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
%       Display-Name of the Plagin-Function.
%         'X Axis Range'
%       Myfunction Name
%         'vcallback_XAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='X Axis-Range (II)';
basicInfo.fnc    ='osp_ViewCallback_XAxisRange2';
% File Information
basicInfo.rver   ='$Revision: 1.5 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/04/16 04:17:59 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_XAxisRange2'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(varargin)
	data=varargin{1};
end
data.name='X Axis II';
data.fnc ='osp_ViewCallback_XAxisRange2';
if ~isfield(data,'pos')
	data.pos =[0, 0, 0.2, 0.1];
end
prompt={'Position : '};
pos{1} = num2str(data.pos);
flag=true;
while flag,
	pos = inputdlg({'Relative Position : '}, ...
		'Callback Position', 1,pos);
	if isempty(pos), break; end
	try
		pos0=str2num(pos{1});
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
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_XAxisRange2(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj)
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);

curdata.Callback_XRange2.handles= axes;
x0=0;x1=1;
if isfield(curdata,'Xrange')
	x0=curdata.Xrange(1);
	x1=curdata.Xrange(2);
end

x=[x0 x1 x1 x0 x0];
y=[ 0  0  1  1  0];
curdata.Callback_XRange2.range  =fill(x,y,[1 1 1]);

set(curdata.Callback_XRange2.handles,...
	'YTickLabel','', ...
	'YTickLabelMode','manual', ...
	'Color',[0.9 0.9 0.9], ...
	'Tag','Axes_XRange2',...
	'Position',pos);

ud.max = -Inf;
ud.min =  Inf;
ud.range =  curdata.Callback_XRange2.range;
set(curdata.Callback_XRange2.handles, ...
	'UserData',{ud});
set(ud.range,...
	'LineStyle','none',...
	'ButtonDown', ...
	['osp_ViewCallback_XAxisRange2(', ...
	'''xaxis_Down'', gcbo)']);
%      'LineWidth',10, ...
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setUserData(h,ud)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fh=get(h,'Parent');
try
	set(fh,'CurrentAxes',h);
catch
	axes(h);
end
ud0=get(h,'UserData');
ud1 = ud0{1};
flag=false;
if ud1.max<ud.default(2),
	flag=true;
	ud1.max=ud.default(2);
end
if ud1.min>ud.default(1),
	flag=true;
	ud1.min=ud.default(1);
end

if flag==true,
	XData=[ud1.min, ud1.max, ud1.max, ud1.min, ud1.min];
	set(ud1.range,...
		'XData',XData, ...
		'FaceColor',[0.6 0.6 0.6]);
	asize= ud1.max - ud1.min;
	
	axis([ud1.min-asize*0.2, ...
		ud1.max+asize*0.2, ...
		0, 1]);
end

try
	set(fh,'CurrentAxes',  ud.axes);
catch
	axes(ud.axes);
end

%- reset xlimit
xlim([ud1.min ud1.max]);

ud0{1}=ud1;

set(h,'UserData',{ud0{:}, ud});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxis_Down(h)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd.h  = h;
cbd.ah =get(h,'Parent');
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1);
cbd.XData = get(cbd.h,'XData');
r=[min(cbd.XData), max(cbd.XData)];
asize= r(2) - r(1);
asize=asize*0.1;

if cp0(1)< (r(1) + asize),
	% Select : Reft
	if asize~=0,
		cbd.id=find(cbd.XData < r(1)+asize);
	else
		cbd.id=[1 4 5];
	end
	set(cbd.h,'FaceColor',[0.8, 1, 0.9]);
	set(gcbf,'WindowButtonMotionFcn', ...
		['osp_ViewCallback_XAxisRange2(', ...
		'''xaxisResize_Callback'', gcbf);']);
	
elseif cp0(1)> (r(2) - asize),
	% Select : Reft
	if asize~=0,
		cbd.id=find(cbd.XData > r(2)-asize);
	else
		cbd.id=[2 3];
	end
	set(cbd.h,'FaceColor',[0.9, 1, 0.9]);
	set(gcbf,'WindowButtonMotionFcn', ...
		['osp_ViewCallback_XAxisRange2(', ...
		'''xaxisResize_Callback'', gcbf);']);
else
	set(cbd.h,'FaceColor',[0.8, 0.9, 1]);
	set(gcbf,'WindowButtonMotionFcn', ...
		['osp_ViewCallback_XAxisRange2(', ...
		'''xaxisMove_Callback'', gcbf);']);
end
setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisMove_Callback(figh)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
xdata= cbd.XData + cp(1) - cbd.cp0;
set(cbd.h,'XData',xdata);
range=[min(xdata), max(xdata)];
xaxisMove(cbd,range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisResize_Callback(figh)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
cbd.XData(cbd.id)=cp(1);
set(cbd.h,'XData',cbd.XData);
range=[min(cbd.XData), max(cbd.XData)];
xaxisMove(cbd,range)
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisMove(cbd,r)
% Move Real
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if r(2)==r(1),return;end
ud=get(cbd.ah,'UserData');
for idx=2:length(ud);
	if isfield(ud{idx},'ObjectID')
		% Execute for Common-Control Type
		% Get Data
		data = p3_ViewCommCallback('getData', ...
			ud{idx}.axes, ...
			ud{idx}.name, ud{idx}.ObjectID);
		obj=data.obj;
		% Delete handle
		for idxh = 1:length(data.handle),
			try
				if ishandle(data.handle(idxh)),
					delete(data.handle(idxh));
				end
			catch
				warning(lasterr);
			end % Try - Catch
		end
		% Draw
		feval(obj.fnc,'draw',data.axes, data.curdata, data.obj, ud{idx}.ObjectID);
	else
		set(gcbf,'CurrentAxes',ud{idx}.axes);
		p=axis;
		p(1:2)=r(1:2);
		axis(p);
	end
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

function flg=checkAxisStr(str)
% Get axis property
flg=0;   % ==Property
if strcmp(str, 'auto')==0 && ...
		strcmp(str, 'manual')==0 && ...
		strcmp(str, 'tight')==0 && ...
		strcmp(str, 'full')==0 && ...
		strcmp(str, 'default')==0 && ...
		strcmp(str, 'on')==0 && ...
		strcmp(str, 'off')==0 ,
	flg=1; % == Range
end
return;
