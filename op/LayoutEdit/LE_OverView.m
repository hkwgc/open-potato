function varargout = LE_OverView(varargin)
% LE_OVERVIEW M-file for LE_OverView.fig
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Edit the above text to modify the response to help LE_OverView

% Last Modified by GUIDE v2.5 06-Mar-2007 22:40:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @LE_OverView_OpeningFcn, ...
  'gui_OutputFcn',  @LE_OverView_OutputFcn, ...
  'gui_LayoutFcn',  [], ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure Control Function's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LE_OverView_OpeningFcn(hObject, ev, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for LE_OverView
handles.output = hObject;
handles.figure1=hObject; % My-favorite
% Update handles structure
guidata(hObject, handles);
set(hObject,'Renderer','OpenGL');

%-------------------
% Load Resize-Image
%-------------------
p=fileparts(which(mfilename));
[data, c,a]=imread([p filesep 'resize.png']);
for x=1:size(data,1)
  for y=1:size(data,2)
    tmp=double(data(x,y))+1;
    c2(x,y,:)=c(tmp,:);
  end
end
setappdata(handles.figure1,'ResizeImageColor',c2);
if isempty(a)
  a=ones(size(data))*0.8;
  for x=1:size(data,1)
    a(x,1:end-x)=0;
  end
end
setappdata(handles.figure1,'ResizeAplhaMap',a);

function varargout = LE_OverView_OutputFcn(h, ev, handles)
% Output is Figure-Handle : See aoso OpeningFcn
varargout{1} = handles.output;

if 0,disp(h);disp(ev);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do noting..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw Axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Redraw(h,ev,handles,LAYOUT,layoutpath,le_handles)
% dummy function
%    set(handles.txt_dummy,'String', num2str(layoutpath));
if 0,disp(h);disp(ev);end
%============================
% Initalize Status 
%============================
hs0.fig=handles.figure1;
hs0.ax=handles.axes_OverView;

if 0
  % high speed
  set(0,'CurrentFigure',hs0.fig);
else
  % since 2007.04.05 (low-speed)
  % bring the window to front.
  figure(hs0.fig);
end
set(hs0.fig,'CurrentAxes',hs0.ax);
cla
hold on
axis([0 1 0 1]);
pos=[0 0 1 1];

% Get View-Group
%  Draw-Childre (vgdata) & get-Draw-Object-Handles
LAYOUT.vgdata=reload_child(pos,LAYOUT.vgdata,hs0,[],layoutpath);
setappdata(hs0.fig,'LAYOUT',LAYOUT); % with handle
setappdata(hs0.fig,'CurrentPath',layoutpath);
if nargin>=6
  % ==> for WindowsButtonUP function ::
  setappdata(hs0.fig,'LayoutEditorHandles',le_handles);
end

%=====>
% Control - GUI's
%<====
makeControlGUI(guidata(hs0.fig));

function makeControlGUI(hs)
% Make Control GUI for ..
% Upper : Redraw/ChangePossition
c0=getappdata(hs.figure1,'ControlHandles');
if isempty(c0),
  c0.move=false;
  c0.resize=false;
  c0.resize2=false;
end

LAYOUT=getappdata(hs.figure1,'LAYOUT');
npath =getappdata(hs.figure1,'CurrentPath');
[str,ap]=LayoutPartsIO('layoutpath2evalstr',npath,LAYOUT);
LP=eval(str);
pos=getLPpos(LP);
hsx=[c0.move,c0.resize,c0.resize2];
if isempty(pos) || ~any(ishandle(LP.h))
  set(hsx(ishandle(hsx)),'Visible','off');
  return;
end
set(hsx(ishandle(hsx)),'Visible','on');

ap2=getPosabs(pos,ap);  % Absolute Position

% make Move GUI
x  =[ap2(1);ap2(1)+ap2(3);ap2(1)+ap2(3);ap2(1);ap2(1)];
y  =[ap2(2);ap2(2);ap2(2)+ap2(4);ap2(2)+ap2(4);ap2(2)];

if ishandle(c0.move)
  ctrlh.move=c0.move;
  set(ctrlh.move,'XDATA',x,'YDATA',y);
else
  set(0,'CurrentFigure',hs.figure1);
  set(hs.figure1,'CurrentAxes',hs.axes_OverView);
  ctrlh.move=line(x,y);
  lw=get(ctrlh.move,'LineWidth');
  set(ctrlh.move,...
    'Color',[1 0 0],...
    'LineWidth',lw*4);
  if 0
    % Comment out 04-Apr-2007 
    %    Move to LE_OverView_WindowButtonDownFcn
    set(ctrlh.move,...
      'ButtonDownFcn', ...
      'LE_OverView(''Control_ButtonDown'', gcbo, [], guidata(gcbo))');
  end
end

% make Resize GUI
dsz=0.05; % Default Size
%p0=get(hs.figure1,'Position');
dszx=dsz;
dszy=dsz;
del=0.002;
ap2(1:2)=ap2(1:2)+del;
ap2(3:4)=ap2(3:4)-2*del;
x2 = [ap2(1)+ap2(3), ap2(1)+ap2(3),ap2(1)+ap2(3)-max(min(ap2(3),dszx),0.02)];
y2 = [ap2(2), ap2(2)+max(min(ap2(4),dszy),0.02),ap2(2)];

if ishandle(c0.resize),
  % Move
  ctrlh.resize=c0.resize;
  set(ctrlh.resize,'XDATA',x2,'YDATA',y2);
  ctrlh.resize2=c0.resize2;
  if ishandle(ctrlh.resize2)
    set(ctrlh.resize,'Visible','off');
    c=getappdata(hs.figure1,'ResizeImageColor');
    set(ctrlh.resize2,...
      'XDATA',linspace(x2(3),x2(1),size(c,1)),...
      'YDATA',linspace(y2(2),y2(1),size(c,1)));
  end
else
  set(0,'CurrentFigure',hs.figure1);
  set(hs.figure1,'CurrentAxes',hs.axes_OverView);
  ctrlh.resize=fill(x2,y2,[0 0 0]);
  set(ctrlh.resize,'LineStyle','none','Visible','off');
  
  c=getappdata(hs.figure1,'ResizeImageColor');
  a=getappdata(hs.figure1,'ResizeAplhaMap');
  ctrlh.resize2=image(linspace(x2(3),x2(1),size(c,1)),linspace(y2(2),y2(1),size(c,2)),c);
  if ~isempty(a)
    set(ctrlh.resize2,'AlphaDataMapping','scaled','AlphaData',a);
  end
  if 0
    % Comment out 04-Apr-2007 
    %    Move to LE_OverView_WindowButtonDownFcn
    set(ctrlh.resize,...
      'ButtonDownFcn', ...
      'LE_OverView(''Control_ButtonDown'', gcbo, [], guidata(gcbo))');
  end
end
setappdata(hs.figure1,'ControlHandles',ctrlh);

% Send to front
h=get(hs.axes_OverView,'Children');
idm=find(h==ctrlh.move);
id0=1:length(h);
if ~isempty(idm)
  h=h([idm, 1:idm-1, idm+1:end]);
end
idr=find(h==ctrlh.resize);
if ~isempty(idr)
  h=h([idr, 1:idr-1, idr+1:end]);
end
set(hs.axes_OverView,'Children',h);

function moveControlGUI(hs,ap2)
% Move Control GUI.
%  is as same as makeControlGUI,  but so simple.
ctrlh=getappdata(hs.figure1,'ControlHandles');

% move Move GUI
x  =[ap2(1);ap2(1)+ap2(3);ap2(1)+ap2(3);ap2(1);ap2(1)];
y  =[ap2(2);ap2(2);ap2(2)+ap2(4);ap2(2)+ap2(4);ap2(2)];

set(ctrlh.move,'XDATA',x,'YDATA',y);

% move Resize GUI
% make Resize GUI
dsz=0.05; % Default Size
%p0=get(hs.figure1,'Position');
dszx=dsz;
dszy=dsz;
del=0.002;
ap2(1:2)=ap2(1:2)+del;
ap2(3:4)=ap2(3:4)-2*del;
x2 = [ap2(1)+ap2(3), ap2(1)+ap2(3),ap2(1)+ap2(3)-max(min(ap2(3),dszx),0.02)];
y2 = [ap2(2), ap2(2)+max(min(ap2(4),dszy),0.02),ap2(2)];
set(ctrlh.resize,'XDATA',x2,'YDATA',y2);
set(ctrlh.resize,'Visible','off');
if ishandle(ctrlh.resize2)
  c=getappdata(hs.figure1,'ResizeImageColor');
  set(ctrlh.resize2,...
    'XDATA',linspace(x2(3),x2(1),size(c,1)),...
    'YDATA',linspace(y2(2),y2(1),size(c,1)));
end
  
function [mod, pointer]=whichControlGUI(hs)
% Cursor exist Which GUI 
mod='none';
pointer='arrow';

%--------------
% Loading Data
%--------------
ctrlh=getappdata(hs.figure1,'ControlHandles');
if isempty(ctrlh),return;end
if ~ishandle(ctrlh.resize),return;end
if strcmpi(get(ctrlh.resize2,'Visible'),'off'),return;end

pos =get(hs.figure1,'CurrentPoint');
dlt=0.01; % Setting 
%--------------
% On Resize Control?
%--------------
try
  if ishandle(ctrlh.resize)
    x=get(ctrlh.resize,'XDATA');
    y=get(ctrlh.resize,'YDATA');
    if pos(1)<=(x(1)+dlt) && pos(1)>=(x(3)-dlt) && ...
        pos(2)<=(y(2)+dlt) && pos(2)>=(y(1)-dlt), 
      p = pos - [x(3),y(1)]; % Vector (bottom left to point)
      t = [x(1)-x(3),y(2)-y(1)]; % Vector (Diagonal)
      p(end+1)=0;t(end+1)=0;
      % Outre product
      c=cross(t,p);
      if c(3)<0
        % counter clockwise
        mod='resize';
        pointer='botr';
        return;
      end
    end
  end
catch
  % No Resize Control (may be)
  % Not Select
end

%--------------
% On Move Control?
%--------------
dlt=[-dlt dlt];
try
  if ishandle(ctrlh.move)
    x=get(ctrlh.move,'XDATA'); l=dlt+x(1);r=dlt+x(2);
    y=get(ctrlh.move,'YDATA'); b=dlt+y(1);t=dlt+y(3);
    if (pos(1)>l(1) && pos(1)<l(2) && pos(2)>b(1) && pos(2)<t(2)) || ...
        (pos(1)>r(1) && pos(1)<r(2) && pos(2)>b(1) && pos(2)<t(2)) || ...
        (pos(1)>l(1) && pos(1)<r(2) && pos(2)>t(1) && pos(2)<t(2)) || ...
        (pos(1)>l(1) && pos(1)<r(2) && pos(2)>b(1) && pos(2)<b(2))
      mod='move';
      pointer='fleur';
      return;
    end
  end
catch
  % No Move Control (may be)
  % not Select
end
  
function vgdata=reload_child(pos,vgdata,hs0,cvgp,cvgp0)
% pos    : Plot Position.
% vgdata : Current View Group Data.
% axh    : Plot Axes.
% cvgp   : Current ViweGroup Data Path.
% Copy --> signal_viewer2 : overview_child
set(0,'CurrentFigure',hs0.fig);

for idx =1:length(vgdata)
  % Get Default Data
  lpos=vgdata{idx}.Position;
  absp=getPosabs(lpos,pos);  
  
  %==============================
  % Draw Object (Area/Axes)
  %==============================
  set(0,'CurrentFigure',hs0.fig);
  set(hs0.fig,'CurrentAxes',hs0.ax);
  h=Lparts_Manager('ov_draw',...
    vgdata{idx},pos,cvgp0,[cvgp, idx]);
  vgdata{idx}.h=h;
  info=feval(vgdata{idx}.MODE,'getBasicInfo');

  %==============================
  % Draw Callabck-Object
  %==============================
  if isfield(vgdata{idx},'CObject'),
    for cidx=1:length(vgdata{idx}.CObject)
      set(0,'CurrentFigure',hs0.fig);
      set(hs0.fig,'CurrentAxes',hs0.ax);
      h=Lparts_Manager('ov_draw',...
        vgdata{idx}.CObject{cidx},absp,cvgp0,...
        [cvgp, idx, -cidx]);
      vgdata{idx}.CObject{cidx}.h=h;
    end
  end
    
  % Can be down?
  if info.down,
    % View-Gruop
    vgdata{idx}.Object=reload_child(absp,vgdata{idx}.Object,hs0,[cvgp, idx],cvgp0);
  else
    if ~isempty(vgdata{idx}.Object),
      h=Lparts_Manager('ov_draw',...
        vgdata{idx}.Object{1},absp,cvgp0,...
        [cvgp, idx]);
      vgdata{idx}.Object{1}.h=h;
    end
    % Axes-Object
    if 0 && isequal(cvgp0(1:end-1),[cvgp idx]) && cvgp0(end)>0,
      vgdata{idx}.Object{cvgp0(end)}.h=Lparts_Manager('ov_draw',...
        vgdata{idx}.Object{cvgp0(end)},absp,cvgp0,cvgp0);
    end
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position Change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vgdata=DeleteChildren(vgdata)
% !! vgdata is not modify !!
%  only Read! <-- at 2007.04.02 : Bug fix
for idx =1:length(vgdata)
  %==============================
  % Delete Object (Area/Axes)
  %==============================
  try, delete(vgdata{idx}.h(ishandle(vgdata{idx}.h)));  end
  info=feval(vgdata{idx}.MODE,'getBasicInfo');

  %==============================
  % Delete Callabck-Object
  %==============================
  if isfield(vgdata{idx},'CObject'),
    for cidx=1:length(vgdata{idx}.CObject)
      try,delete(vgdata{idx}.CObject{cidx}.h(ishandle(vgdata{idx}.CObject{cidx}.h)));end
    end
  end
  % Can be down?
  if info.down,
    % View-Gruop
    DeleteChildren(vgdata{idx}.Object);
  else
    if ~isempty(vgdata{idx}.Object),
      try, delete(vgdata{idx}.Object{1}.h(ishandle(vgdata{idx}.Object{1}.h)));end
      end
  end
end

function ChangePossition(h,ev,hs,posdata)
% Change Possition by LayoutEditor
LAYOUT=getappdata(hs.figure1,'LAYOUT');
[str, ap]=LayoutPartsIO('layoutpath2evalstr',posdata.path,LAYOUT);
eval(['LP=' str ';']);
LP=setLPpos(LP,posdata.pos);
% Delete Group handles
LP=deleteGroupHs(LP);
% Draw Group handles
LP=drawGroupHs(LP,hs,ap,posdata);
eval([str '=LP;']);
setappdata(hs.figure1,'LAYOUT',LAYOUT);
makeControlGUI(hs);

function LP=deleteGroupHs(LP)
if isfield(LP,'h') && any(ishandle(LP.h))
  delete(LP.h(ishandle(LP.h)));
end
if isfield(LP,'CObject'),
  for cidx=1:length(LP.CObject)
    if isfield(LP.CObject{cidx},'h')
      delete(LP.CObject{cidx}.h(ishandle(LP.CObject{cidx}.h)));
    end
  end
end
if isfield(LP,'Object'),
  info=feval(LP.MODE,'getBasicInfo');
  if info.down,
    LP.Object=DeleteChildren(LP.Object);
  else
    if ~isempty(LP.Object) && isfield(LP.Object{1},'h')
      delete(LP.Object{1}.h(ishandle(LP.Object{1}.h)));
    end
  end
end

function LP=drawGroupHs(LP,hs,ap,posdata)
hs0.fig=hs.figure1;
hs0.ax=hs.axes_OverView;
set(0,'CurrentFigure',hs.figure1);
set(hs.figure1,'CurrentAxes',hs.axes_OverView);

% Absolute Position of LP
ap2=getPosabs(posdata.pos,ap); 
if isfield(LP,'CObject'),
    for cidx=1:length(LP.CObject)
      set(0,'CurrentFigure',hs0.fig);
      set(hs0.fig,'CurrentAxes',hs0.ax);
      h=Lparts_Manager('ov_draw',...
        LP.CObject{cidx},ap2,posdata.path,...
        [posdata.path, -cidx]);
      LP.CObject{cidx}.h=h;
    end
end
if isfield(LP,'Object'),
  info=feval(LP.MODE,'getBasicInfo');
  if info.down,
    LP.Object=reload_child(ap2,LP.Object,hs0,posdata.path,posdata.path);
  else
    if ~isempty(LP.Object) && ~isempty(LP.Object{1})
      h=Lparts_Manager('ov_draw',...
        LP.Object{1},ap2,posdata.path(1:end),...
        posdata.path);
      LP.Object{1}.h=h;
    end
  end
end
% Own
LP.h = Lparts_Manager('ov_draw',...
  LP,ap,posdata.path,posdata.path);


function LP=setLPpos(LP,pos)
% Set Position to LP
if isfield(LP, 'Position'),
  LP.Position=pos;
elseif isfield(LP, 'position'),
  LP.position=pos;
elseif isfield(LP, 'pos'),
  LP.pos=pos;
end

function pos=getLPpos(LP)
% Set Position to LP
if isfield(LP, 'Position'),
  pos=LP.Position;
elseif isfield(LP, 'position'),
  pos=LP.position;
elseif isfield(LP, 'pos'),
  pos=LP.pos;
else
  pos=[];
end

function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
  lpos([1,3]) = lpos([1,3])*pos(3);
  lpos([2,4]) = lpos([2,4])*pos(4);
  lpos(1:2)   = lpos(1:2)+pos(1:2);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Button Motion I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isrun=LE_OverView_WindowButtonMotionFcn(hObject, eventdata, handles)
% Windows Button Motion Function !
%  => Switch by ButtonMotionMode
%     :: 'move'   : Move LPO
%     :: 'resize' : Resize LPO
persistent isrunXX
persistent disperr
isrun=true;

if isempty(disperr),disperr=0;end
if isempty(isrunXX),isrunXX=false;end
isrun=false;
if isrunXX;return;end

isrunXX=true;
try
  mod=getappdata(hObject,'ButtonMotionMode');
  if isempty(mod),mod='none';end
  % Get Current-Point
  cp=get(hObject, 'CurrentPoint');
  % ==> Make Limit
  %  Meeting on 05-Apl-2007
  cp(cp<0)=0;cp(cp>1)=1;

  switch mod
    case 'none',
      [mod, point]=whichControlGUI(handles);
      set(handles.figure1,'Pointer',point);      
    case 'move',
      p=getMovepos(handles, cp);
    case 'resize',
      p=getResizepos(handles, cp);
    otherwise,
      if ~bitget(disperr,1),
        disperr=bitset(disperr,1);
         disp(C__FILE__LINE__CHAR);
        disp(['Undefined ButtonMotionMode : ' mode]);
      end     
  end
catch
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end
isrunXX=false;
isrun=false;


function LE_OverView_WindowButtonUpFcn(hObject, ev, hs)
% When Button Up :
mod=getappdata(hObject,'ButtonMotionMode');
if strcmpi(mod,'none') || isempty(mod),return;end
% => confine Execute 1 time 
%    cause GuiPosition is not initialized..(bug fix 2007.04.06)
LE_OverView_WindowButtonMotionFcn(hObject, ev, hs);
setappdata(hObject,'ButtonMotionMode','none');
% Waiting for Last Move
while LE_OverView_WindowButtonMotionFcn(hObject, [], hs),end
% Get Position by MouseUp
pos=getappdata(hObject,'GuiPosition');
% Call set Position
lehs=getappdata(hs.figure1,'LayoutEditorHandles');
if ~isempty(lehs) && isfield(lehs,'figure1') && ishandle(lehs.figure1)
  Lparts_Manager('setPosition',lehs,pos);
end
%Draw 
posdata.path=getappdata(hs.figure1,'CurrentPath');
LAYOUT=getappdata(hs.figure1,'LAYOUT');
[str,ap]=LayoutPartsIO('layoutpath2evalstr',posdata.path,LAYOUT);
% apos to rpos
pos(3:4)   = pos(3:4)./ap(3:4);
pos(1:2)   = pos(1:2)-ap(1:2);
pos(1:2)   = pos(1:2)./ap(3:4);
posdata.pos=pos;
eval(['LP=' str ';']);
LP=setLPpos(LP,posdata.pos);
LP=drawGroupHs(LP,hs,ap,posdata);
eval([str '=LP;']);
setappdata(hs.figure1,'LAYOUT',LAYOUT);

makeControlGUI(hs);

function LE_OverView_WindowButtonDownFcn(hObject, ev, hs)
% When Button Down :
Control_ButtonDown(hObject,ev,hs)

function Control_ButtonDown(hObject,eventdata,hs)
ctrlh=getappdata(hs.figure1,'ControlHandles');
if isempty(ctrlh) || ~ishandle(ctrlh.move),return;end
% Set Down-Position
setappdata(hs.figure1,'MDownXData',get(ctrlh.move,'XDATA'));
setappdata(hs.figure1,'MDownYData',get(ctrlh.move,'YDATA'));
setappdata(hs.figure1,'MDownPoint',get(hs.figure1,'CurrentPoint'));

% Set mode
if 0,
  if isequal(ctrlh.move,hObject),
    mode='move';
  elseif isequal(ctrlh.resize,hObject)
    mode='resize';
  else
    mode='none';
  end
else
  p=get(hs.figure1,'Pointer');
  switch lower(p),
    case 'botr',
      if ~ishandle(ctrlh.resize),return;end
      mode='resize';
    case 'fleur',
      mode='move';
    case 'arrow',
      mode='none';
    otherwise
      warning('Undefined Pointer Mode');
      mode='none';
  end
end
setappdata(hs.figure1,'ButtonMotionMode',mode);
if strcmpi(mode,'none'),return;end
% Delete 
posdata.path=getappdata(hs.figure1,'CurrentPath');
LAYOUT=getappdata(hs.figure1,'LAYOUT');
str=LayoutPartsIO('layoutpath2evalstr',posdata.path,LAYOUT);
eval(['LP=' str ';']);
deleteGroupHs(LP);


try
  [str,ap]=LayoutPartsIO('layoutpath2evalstr',posdata.path,LAYOUT);
  setappdata(hs.figure1,'ParentPOS',ap);
  if 0,disp(str);end
catch
  setappdata(hs.figure1,'ParentPOS',[0 0 1 1]);
end


function pos=getMovepos(hs, cp)
xdata=getappdata(hs.figure1,'MDownXData');
ydata=getappdata(hs.figure1,'MDownYData');
pt   =getappdata(hs.figure1,'MDownPoint');

x=min(xdata);
y=min(ydata);
w=max(xdata)-min(xdata);
h=max(ydata)-min(ydata);

pos=[x+(cp(1)-pt(1)) y+(cp(2)-pt(2)) w h];

% Range Check
p0=getappdata(hs.figure1,'ParentPOS');
if pos(1)<p0(1),pos(1)=p0(1);end
if pos(2)<p0(2),pos(2)=p0(2);end
if (pos(1)+w)>(p0(1)+p0(3)),
  pos(1)=max(p0(1),p0(1)+p0(3)-w);
end
if (pos(2)+h)>(p0(2)+p0(4)),
  pos(2)=max(p0(2),p0(2)+p0(4)-h);
end

% Draw Control
moveControlGUI(hs,pos);
setappdata(hs.figure1,'GuiPosition',pos);
return;


function pos=getResizepos(hs, cp)
xdata=getappdata(hs.figure1,'MDownXData');
ydata=getappdata(hs.figure1,'MDownYData');
pt   =getappdata(hs.figure1,'MDownPoint');
x=min(xdata);
y=min(ydata);
x2=max(xdata);
y2=max(ydata);
w=x2-x;
h=y2-y;
if w==0
  new_w=cp(1)-x;
else
  new_w=(cp(1)-x)*w/(pt(1)-x);
end
if h==0
  new_h=y2-cp(2);
else
  new_h=(y2-cp(2))*h/(y2-pt(2));
end

if new_w<0,x=x-(abs(new_w));new_w=abs(new_w);end
if new_h<0,
  y=y2;new_h=abs(new_h);
else
  y=y2-new_h;
end

% Range Check
p0=getappdata(hs.figure1,'ParentPOS');
if x<p0(1),
  new_w=new_w-(p0(1)-x);
  x=p0(1);
end
if y<p0(2)
  new_h=new_h-(p0(2)-y);
  y=p0(2);
end
if (x+new_w)>(p0(1)+p0(3))
  new_w=p0(1)+p0(3)-x;
end
if (y+new_h)>(p0(2)+p0(4))
  new_h=p0(2)+p0(4)-y;
end
pos=[x y new_w new_h];

% Draw Control
moveControlGUI(hs,pos);
setappdata(hs.figure1,'GuiPosition',pos);
return;
