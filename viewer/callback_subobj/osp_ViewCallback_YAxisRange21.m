function varargout=osp_ViewCallback_YAxisRange21(fcn,varargin)
% Y-Axis Range Callback for OSP-Viewer by Axis
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_YAxisRange21.m 389 2013-12-27 01:37:36Z katura7pro $


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
else,
	feval(fcn, varargin{:});
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%       Display-Name of the Plagin-Function.
%         'X Axis Range'
%       Myfunction Name
%         'vcallback_YAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Y Axis-Range (II)''';
basicInfo.fnc    ='osp_ViewCallback_YAxisRange21';
% File Information
basicInfo.rver   ='$Revision: 1.1 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/05/07 00:41:18 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_YAxisRange21'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(varargin)
	data=varargin{1};
end
data.name='Y Axis II''';
data.fnc ='osp_ViewCallback_YAxisRange21';
if ~isfield(data,'pos')
	data.pos =[0, 0.15, 0.1, 0.2];
	data.lim=[-1 1];
end
prompt={'Position : ','Default YLim'};
def{1} = num2str(data.pos);
def{2} = num2str(data.lim);
flag=true;

while flag,
	inp = inputdlg(prompt, ...
		'Callback Position', 1,def);
	if isempty(inp), break; end
	try,
		pos0=str2num(inp{1});
		if ~isequal(size(pos0),[1,4]),
			wh=warndlg('Number of Input Data must be 4-numerical!');
			waitfor(wh);continue;
		end
		if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
			wh=warndlg('Input Position Value between 0.0 - 1.0.');
			waitfor(wh);continue;
		end
		lim0=str2num(inp{2});
		if lim0(1)>lim0(2),
			wh=warndlg('Input YLim Value as ''ymin  ymax''.');
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
data.pos = pos0;
data.lim = lim0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_YAxisRange21(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'YAxisRange21';
CCD.CurDataValue = {'ylim'};
CCD.handle       = []; % Update


initstr='auto';
ah=axes;
curdata.Callback_YRange21.handles=ah;

x=[0 1 1 0 0];
if isfield(curdata,'ylim')
	y =curdata.ylim;
else
	y = obj.lim;
end
if y(1)>0, y(1)=y(1)*1.2;,
else, y(1)=y(1)*0.8;end
if y(2)>0, y(2)=y(2)*0.8;,
else, y(2)=y(2)*1.2;end
y=y([1 1 2 2 1]);
yDL=y;yUL=y;

yDL([3 4])=y(1)-0.3;
yUL([1 2 5])=y(3)+0.3;
range  =fill(x,y,[0.7 0.7, 0.7]);
xDL=x;xDL(3)=xDL(3)-0.3;xDL(4)=xDL(4)+0.3;
xUL=x;xUL(2)=xUL(2)-0.3;xUL(1)=xUL(1)+0.3;xUL(5)=xUL(5)+0.3;
rangeDL  =patch(xDL,yDL ,[0.6 0.6, 0.7]);
rangeUL  =patch(xUL,yUL ,[0.6 0.6, 0.7]);

r=[min(y) max(y)];
r1=[r(1)-[r(2)-r(1)]*0.1, r(2)+[r(2)-r(1)]*0.1];
set(ah,'Ylim',r1);
set(rangeUL,'YData',[r1(2) r1(2) r(2) r(2) r1(2)]);
set(rangeDL,'YData',[r(1) r(1) r1(1) r1(1) r(1)]);

set(ah,...
	'XTickLabelMode','manual', ...
	'XTickLabel','', ...
	'Color',[0.95 0.95, 0.95], ...
	'Position', pos, ...
	'YLimMode','manual',...
	'YLim', obj.lim);

ud.max = -Inf;
ud.min =  Inf;
%ud.range =  curdata.Callback_YRange21.range;
curdata.Callback_YRange21.range = range;
ud.range = range;
ud.rangeDL=rangeDL;
ud.rangeUL=rangeUL;
ud.tagkey=osp_LayoutViewerTool('make_pathstr',curdata.path);
set(ah,'UserData',ud);

set(ud.range,'Tag','range','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange21(''yaxis_Down'', gcbo)']);
ud.rangeDL = rangeDL;
set(ud.rangeDL,'Tag','rangeDL','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange21(''yaxis_Down_DL'', gcbo)']);
ud.rangeUL = rangeUL;
set(ud.rangeUL,'Tag','rangeUL','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange21(''yaxis_Down_UL'', gcbo)']);

%   %-- setup figure events for Shift key check
%   f1=get(hs.figure1,'KeyPressFcn');
%   set(hs.figure1, 'KeyPressFcn', [f1 'osp_ViewCallback_YAxisRange21(''yaxis_KeyPress'', gcbo);']);
axis tight;

curdata.ylim = [obj.lim(1) obj.lim(2)];

CCD.handle = range;
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end

return;

%------------------
function update_curdata(ud,Y_LIM)
for idx=2:length(ud),
  % Get Data
  vdata = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  
  % Update
  vdata.curdata.ylim = Y_LIM;
  
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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function yaxis_KeyPress(h),
% % Execute on Fill box Add
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get(h,'CurrentCharacter')
% t=1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_Down(h),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(get(h,'Parent'),'UserData');
cbd.h =ud.range;
cbd.hDL =ud.rangeDL;
cbd.hUL =ud.rangeUL;

cbd.ah =get(h,'Parent');
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1,2);
cbd.YData = get(cbd.h,'YData');
cbd.YDataDL = get(cbd.hDL,'YData');
cbd.YDataUL = get(cbd.hUL,'YData');

ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

Y0=get(cbd.callbackaxes(1),'YLim');
if min(Y0)~=min(cbd.YData)
	cbd.YData(cbd.YData==min(cbd.YData))=min(Y0);
end
if max(Y0)~=max(cbd.YData)
	cbd.YData(cbd.YData==max(cbd.YData))=max(Y0);
end

% r=[min(cbd.YData), max(cbd.YData)];
% asize= r(2) - r(1);
% asize=asize*0.1;

set(cbd.h,'FaceColor',[0.95, 0.95, .95]);

Stype=get(get(get(h,'Parent'),'Parent'),'SelectionType');
if strcmp(Stype,'extend'),
	set(cbd.h,'FaceColor',[1, 0.4, 0.4]);
elseif strcmp(Stype,'alt'),
	set(cbd.h,'FaceColor',[0.7, 0.8, 1]);
end

ReRange(cbd);
set(gcbf,'WindowButtonMotionFcn', ...
	['osp_ViewCallback_YAxisRange21(', ...
	'''yaxisMove_Callback'', gcbf);']);

setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);
ReRange(cbd);

update_curdata(get(ud.range,'UserData'),ylim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_Down_UL(h)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(get(h,'Parent'),'UserData');
cbd.h =ud.range;
cbd.hDL =ud.rangeDL;
cbd.hUL =ud.rangeUL;

cbd.ah =get(h,'Parent');
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1,2);
cbd.YData = get(cbd.h,'YData');
cbd.YDataUL = get(cbd.hUL,'YData');

ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

ReRange(cbd);
set(cbd.hUL,'FaceColor',[0.8, 0.6, 0.6]);
set(cbd.h,'FaceColor',[0.9, 0.7, 0.7]);

Stype=get(get(get(h,'Parent'),'Parent'),'SelectionType');
if strcmp(Stype,'extend'),
	set(cbd.hUL,'FaceColor',[1, 0.4, 0.4]);
elseif strcmp(Stype,'alt'),
	set(cbd.hUL,'FaceColor',[0.7, 0.8, 1]);
end

set(gcbf,'WindowButtonMotionFcn', ...
	['osp_ViewCallback_YAxisRange21(', ...
	'''yaxisResize_CallbackUL'', gcbf);']);

setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);
set(cbd.hUL,'FaceColor',[0.7 0.7, 0.7]);
ReRange(cbd);

update_curdata(get(ud.range,'UserData'),ylim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_Down_DL(h)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(get(h,'Parent'),'UserData');
cbd.h =ud.range;
cbd.hDL =ud.rangeDL;
cbd.hUL =ud.rangeUL;

cbd.ah =get(h,'Parent');
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1,2);
cbd.YData = get(cbd.h,'YData');
cbd.YDataDL = get(cbd.hDL,'YData');

ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

ReRange(cbd);
set(cbd.hDL,'FaceColor',[0.8, 0.6, 0.6]);
set(cbd.h,'FaceColor',[0.9, 0.7, 0.7]);

Stype=get(get(get(h,'Parent'),'Parent'),'SelectionType');
if strcmp(Stype,'extend'),
	set(cbd.hDL,'FaceColor',[1, 0.4, 0.4]);
elseif strcmp(Stype,'alt'),
	set(cbd.hDL,'FaceColor',[0.7, 0.8, 1]);
end

set(gcbf,'WindowButtonMotionFcn', ...
	['osp_ViewCallback_YAxisRange21(', ...
	'''yaxisResize_CallbackDL'', gcbf);']);

setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);
set(cbd.hDL,'FaceColor',[0.7 0.7, 0.7]);
ReRange(cbd);

update_curdata(get(ud.range,'UserData'),ylim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisMove_Callback(figh),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
dY=cp(1,2) - cbd.cp0;
if strcmp(get(figh,'SelectionType'),'extend'), dY=dY*10;
elseif strcmp(get(figh,'SelectionType'),'alt'), dY=dY/10;end
ydata= cbd.YData + dY;
set(cbd.h,'YData',ydata);
set(cbd.hDL,'YData',cbd.YDataDL + dY);
set(cbd.hUL,'YData',cbd.YDataUL + dY);
range=[min(ydata), max(ydata)];
yaxisMove(cbd,range)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisResize_CallbackDL(figh),
% Execute on Fill box Add
% Lower lim change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
dY=cp(1,2) - cbd.cp0;
if strcmp(get(figh,'SelectionType'),'extend'), dY=dY*10;
elseif strcmp(get(figh,'SelectionType'),'alt'), dY=dY/10;end
%cbd.YData([1 2 5])=cp(1,2);
ydata=cbd.YData;
ydata([1 2 5])= cbd.YData([1 2 5]) + dY;
set(cbd.h,'YData',ydata);
set(cbd.hDL,'YData',cbd.YDataDL + dY);

s=get(cbd.ah,'YTickLabel');
s{1}=sprintf('%0.3f',min(ydata));
set(cbd.ah,'YTickLabel',s);

range=[min(ydata), max(ydata)];
yaxisMove(cbd,range)
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisResize_CallbackUL(figh),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
dY=cp(1,2) - cbd.cp0;
if strcmp(get(figh,'SelectionType'),'extend'), dY=dY*10;
elseif strcmp(get(figh,'SelectionType'),'alt'), dY=dY/10;end
%cbd.YData([1 2 5])=cp(1,2);
ydata=cbd.YData;
ydata([3 4])= cbd.YData([3 4]) + dY;
set(cbd.h,'YData',ydata);
set(cbd.hUL,'YData',cbd.YDataUL + dY);

s=get(cbd.ah,'YTickLabel');
s{end}=sprintf('%0.3f',max(ydata));
set(cbd.ah,'YTickLabel',s);

range=[min(ydata), max(ydata)];
yaxisMove(cbd,range)
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisMove(cbd,r)
% Move Real
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if r(1)==r(2),return;end
set(cbd.callbackaxes,'YLim',r(1:2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos),
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

function flg=checkAxisStr(str),
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ReRange(cbd)
r=[min(get(cbd.h,'YData')), max(get(cbd.h,'YData'))];
r1=[r(1)-[r(2)-r(1)]*0.1, r(2)+[r(2)-r(1)]*0.1];
set(cbd.ah,'Ylim',r1);
set(cbd.hUL,'YData',[r1(2) r1(2) r(2) r(2) r1(2)]);
set(cbd.hDL,'YData',[r(1) r(1) r1(1) r1(1) r(1)]);

s1=sprintf('%0.2f',r(1));
s2=sprintf('%0.2f',r(2));
if sign(str2num(s1))*sign(str2num(s2))==-1
	set(cbd.ah,'YTick',[str2num(s1) 0 str2num(s2)]);
	set(cbd.ah,'YTickLabel',{s1,'0',s2});
else
	set(cbd.ah,'YTick',[str2num(s1) str2num(s2)]);
	set(cbd.ah,'YTickLabel',{s1,s2});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
