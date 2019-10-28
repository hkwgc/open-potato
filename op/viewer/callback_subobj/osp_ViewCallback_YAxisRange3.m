function varargout=osp_ViewCallback_YAxisRange3(fcn,varargin)
% POTATo LAYOUT Callback Object
% Y-Axis Range Callback version 3.0
% $Id: osp_ViewCallback_YAxisRange3.m 360 2013-05-16 05:30:06Z Katura $


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
basicInfo.name   ='Y Axis-Range 3';
basicInfo.fnc    ='osp_ViewCallback_YAxisRange3';
% File Information
basicInfo.rver   ='$Revision: 3.0 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2021/05/11 00:41:18 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_YAxisRange3'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.name='Y Axis 3';
data.fnc ='osp_ViewCallback_YAxisRange3';
if ~isfield(data,'pos')
	data.pos =[0, 0.15, 0.1, 0.2];
	data.lim=[-1 1];
	data.tagName = 'YAxis3';
end
prompt={'Position : ','Default YLim','Tag name'};
def{1} = num2str(data.pos);
def{2} = num2str(data.lim);
def{3} = num2str(data.tagName);
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
data.tagName = inp{3};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_YAxisRange3(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'YAxisRange3';
CCD.CurDataValue = {'ylim'};
CCD.handle       = []; % Update
if isfield(obj,'tagName')
	CCD.tagName      = obj.tagName;
end

initstr='auto';
ah=axes;
curdata.Callback_YRange3.handles=ah;

x=[0 1 1 0 0];
if isfield(curdata,'ylim')
	y =curdata.ylim;
else
	y = obj.lim;
end

dW=boxArrowRatio;dWw=0.0;
%y(1)=y(1)-dW;
%y(2)=y(2)+dW;
y=y([1 1 2 2 1]);
yDL=y;yUL=y;

range  =fill(x,y,colF('bar'));

yDL([3 4])=y(1);
yUL([1 2 5])=y(3);
xDL=x;xDL(3)=xDL(3)-dW;xDL(4)=xDL(4)+dW;
xUL=x;xUL(2)=xUL(2)-dW;xUL(1)=xUL(1)+dW;xUL(5)=xUL(5)+dW;
rangeDL  =patch(xDL,yDL ,colF('arrow'));
rangeUL  =patch(xUL,yUL ,colF('arrow'));

editBox = ...
  uicontrol(hs.figure1,...
  'Style','edit', ...
  'String', subFormatStr(obj.lim), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', [pos(1)-pos(3)*1.25 pos(2)-0.05 pos(3)*2.5 0.03] , ...
  'TooltipString','input ylim.', ...
  'Tag','CCD_YAxisRange3', ...
  'Callback', 'osp_ViewCallback_YAxisRange3(''yaxis_EditBox'', gcbo)');

[r r1]=getRangeCorrected(y);
set(ah,'Ylim',r1);
set(rangeUL,'YData',[r1(2) r1(2) r(2) r(2) r1(2)]);
set(rangeDL,'YData',[r(1) r(1) r1(1) r1(1) r(1)]);

ud.max = -Inf;
ud.min =  Inf;
%ud.range =  curdata.Callback_YRange21.range;
curdata.Callback_YRange21.range = range;
ud.range = range;
ud.rangeDL=rangeDL;
ud.rangeUL=rangeUL;
ud.editBox = editBox;
ud.tagkey=osp_LayoutViewerTool('make_pathstr',curdata.path);
set(ah,'UserData',ud);
set(ud.editBox,'Userdata',ud);

cbd=getHandlesAx(ah);
sub_ResetColor(cbd);

set(ah,...
	'XTickLabelMode','manual', ...
	'XTickLabel','', ...
	'Color',[0.95 0.95, 0.95], ...
	'Position', pos, ...
	'YLimMode','manual',...
	'YLim', obj.lim);

set(ud.range,'Tag','range','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange3(''subYAxis_Down'', gcbo,''M'')']);
ud.rangeDL = rangeDL;
set(ud.rangeDL,'Tag','rangeDL','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange3(''subYAxis_Down'', gcbo,''D'')']);
ud.rangeUL = rangeUL;
set(ud.rangeUL,'Tag','rangeUL','LineStyle','none','ButtonDown', ...
	['osp_ViewCallback_YAxisRange3(''subYAxis_Down'', gcbo,''U'')']);

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
for idx=1:length(ud),
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subYAxis_Down(h,strMode)
cbd=getHandles(h);
ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

switch strMode
	case 'M'
	hcc=cbd.h;
	strFcn='osp_ViewCallback_YAxisRange3(''yaxisResize_Callback'', gcbf,''M'');';
	%strFcn='osp_ViewCallback_YAxisRange3(''yaxisMove_Callback'', gcbf);';		
	case 'U'
	hcc=cbd.hUL;
	strFcn='osp_ViewCallback_YAxisRange3(''yaxisResize_Callback'', gcbf,''U'');';
	case 'D'
	hcc=cbd.hDL;
	strFcn='osp_ViewCallback_YAxisRange3(''yaxisResize_Callback'', gcbf,''D'');';
end
ReRange(cbd);
set(hcc,'FaceColor',colF('Act'));

Stype=get(get(get(h,'Parent'),'Parent'),'SelectionType');
if strcmp(Stype,'extend'),
	set(hcc,'FaceColor',colF('ActShift'));
elseif strcmp(Stype,'alt'),
	set(hcc,'FaceColor',colF('ActAlt'));
end

set(gcbf,'WindowButtonMotionFcn', strFcn);

setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',colF('bar'));
set([cbd.hUL cbd.hDL],'FaceColor',colF('arrow'));
ReRange(cbd);

tmp=get(cbd.h,'YData');
update_curdata(get(ud.range,'UserData'),tmp([1 3]));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sub_ResetColor(cbd)
setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);
ReRange(cbd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_EditBox(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp=get(h,'userData');
cbd=getHandles(tmp.range);

ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

str=lower(get(h,'string'));
if ~isempty(strfind(str,'auto'))
	set(cbd.callbackaxes,'YLimMode','Auto');%- update ylim
	newYLIM=[0 0];
else
	newYLIM=eval(['[' str ']']);
	if isempty(newYLIM)
		yaxisMove(cbd,cbd.YData)
	end
	set(cbd.callbackaxes,'YLim',newYLIM);%- update ylim
end

%
%update_curdata(get(ud.range,'UserData'),ylim);
ReRange(cbd);

range=[min(newYLIM), max(newYLIM)];
 %yaxisResize_Callback(gcf,'U',range(2))
%yaxisMove(cbd,range);

%- Ylabel
s=get(cbd.ah,'YTickLabel');
s{1}=sprintf('%0.3f',min(newYLIM));
s{end}=sprintf('%0.3f',max(newYLIM));
set(cbd.ah,'YTickLabel',s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisResize_Callback(figh,strMode,varargin)
% Execute on Fill box Add
% Lower lim change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
if nargin==3
	dY=varargin{1};
else
	dY=cp(1,2) - cbd.cp0;
	if strcmp(get(figh,'SelectionType'),'extend'), dY=dY*10;
	elseif strcmp(get(figh,'SelectionType'),'alt'), dY=dY/10;end
end

ydata=cbd.YData;
switch strMode
	case 'D'
		ydata([1 2 5])= cbd.YData([1 2 5]) + dY;
		set(cbd.hDL,'YData',cbd.YDataDL + dY);
	case 'U'
		ydata([3 4])= cbd.YData([3 4]) + dY;
		set(cbd.hUL,'YData',cbd.YDataUL + dY);
	case 'M'
		ydata= cbd.YData + dY;
		set(cbd.hDL,'YData',cbd.YDataDL + dY);
		set(cbd.hUL,'YData',cbd.YDataUL + dY);
end
set(cbd.h,'YData',ydata);

s=get(cbd.ah,'YTickLabel');
s{1}=sprintf('%0.3f',min(ydata));
s{end}=sprintf('%0.3f',max(ydata));
set(cbd.ah,'YTickLabel',s);

range=[min(ydata), max(ydata)];
if range(1)==range(2),return;end
set(cbd.callbackaxes,'YLim',range(1:2));
set(cbd.editBox,'string',subFormatStr(range));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

if ~isempty(cbd.callbackaxes)
	Y0=get(cbd.callbackaxes(1),'YLim');
	if min(Y0)~=min(cbd.YData)
		cbd.YData(cbd.YData==min(cbd.YData))=min(Y0);
	end
	if max(Y0)~=max(cbd.YData)
		cbd.YData(cbd.YData==max(cbd.YData))=max(Y0);
	end
end

[r,r1]=getRangeCorrected(get(cbd.h,'YData'));
set(cbd.ah,'Ylim',r1);
set(cbd.hUL,'YData',[r1(2) r1(2) r(2) r(2) r1(2)]);
set(cbd.hDL,'YData',[r(1) r(1) r1(1) r1(1) r(1)]);

s1=sprintf('%0.2f',r(1));
s2=sprintf('%0.2f',r(2));
if sign(str2num(s1))*sign(str2num(s2))==-1
	set(cbd.ah,'YTick',[str2num(s1) 0 str2num(s2)]);
	set(cbd.ah,'YTickLabel',{s1,'0',s2});
elseif str2num(s1)==str2num(s2)
	return;
else
	set(cbd.ah,'YTick',[str2num(s1) str2num(s2)]);
	set(cbd.ah,'YTickLabel',{s1,s2});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cbd=getHandles(h)
cbd=getHandlesAx(get(h,'Parent'));

function cbd=getHandlesAx(h)

ud=get(h,'UserData');
cbd.h =ud.range;
cbd.hDL =ud.rangeDL;
cbd.hUL =ud.rangeUL;
cbd.editBox = ud.editBox;

cbd.ah =h;
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1,2);
cbd.YData = get(cbd.h,'YData');
cbd.YDataDL = get(cbd.hDL,'YData');
cbd.YDataUL = get(cbd.hUL,'YData');

%ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);
if isempty(cbd.callbackaxes)
	return;
end

Y0=get(cbd.callbackaxes(1),'YLim');
if min(Y0)~=min(cbd.YData)
	cbd.YData(cbd.YData==min(cbd.YData))=min(Y0);
end
if max(Y0)~=max(cbd.YData)
	cbd.YData(cbd.YData==max(cbd.YData))=max(Y0);
end

function str=subFormatStr(r1)
str=sprintf('%0.2f %0.2f',r1(1),r1(2));
function ratio=boxArrowRatio
ratio=0.07;
function col=colF(type)
switch lower(type)
	case 'bar'
		col=[0.8 0.8 0.8];
	case 'arrow'
		col=[0.7 0.7 0.7];
	case 'act'
		col=[1, 0.5, 0.5];
	case 'actshift'
		col=[1, 0.2, 0.7];		
	case 'actalt'
		col=[0.5, 0.5, 1];		
end

function  [r,r1]=getRangeCorrected(y)
r=[min(y) max(y)];
if r(1)==r(2)
	r=[-1 1];
end
r1=[r(1)-(r(2)-r(1))*boxArrowRatio, r(2)+(r(2)-r(1))*boxArrowRatio];

