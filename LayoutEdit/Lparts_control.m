function varargout=Lparts_control(fnc,varargin)
% Control  Layout-Parts Object


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2007.02.19
% $Id: Lparts_control.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fnc,
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create & GUI-Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================================
function hs=Create(hs)
% Create  Figure-Layout-Parts  Property Setting GUI
%===================================================

%-------------------------------
% Name
%-------------------------------
hs.lpocntl_txtname=subuicontrol(hs.figure1,...
  15,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpocntl_txtnamestr=subuicontrol(hs.figure1,...
  15,2,2+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left');

%-------------------------------
% Relative - Position
%-------------------------------
hs.lpocntl_txtrpos=subuicontrol(hs.figure1,...
  15,2,4+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'String','Relative-Position');
% Use Original Callback
hs.lpocntl_edtrpos=subuicontrol(hs.figure1,...
  15,2,4+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[0, 0, 1, 1]',...
  'BackgroundColor',[1, 1, 1],...
  'Visible','off',...
  'Callback',...
  'Lparts_Manager(''ChangeRPOS'',gcbo,guidata(gcbf));');

%-------------------------------
% Absolute  - Position
%-------------------------------
hs.lpocntl_txtapos=subuicontrol(hs.figure1,...
  15,2,6+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'String','Absolute-Position');
% Use Original Callback
hs.lpocntl_edtapos=subuicontrol(hs.figure1,...
  15,2,6+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[1.00, 1.00, 1.00]',...
  'BackgroundColor',[1, 1, 1],...
  'Visible','off',...
  'Callback',...
  'Lparts_Manager(''ChangeAPOS'',gcbo,guidata(gcbf));');

% ==> Position Other Setting ==>
p.rposh = hs.lpocntl_edtrpos;
p.aposh = hs.lpocntl_edtapos;
p.data  = [1 1 1 1];
set([hs.lpocntl_edtrpos, hs.lpocntl_edtapos;],'UserData',p);
% <== Position Other Setting <==

%-------------------------------
% control style
%-------------------------------
hs.lpocntl_txtStyle=subuicontrol(hs.figure1,...
  3,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','control style');
hs.lpocntl_popStyle=subuicontrol(hs.figure1,...
  3,2,2+2,'Inner',...
  'Style','PopupMenu',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_control(''ChangeStyle'',gcbo,guidata(gcbf));');

%-------------------------------
% Function
%-------------------------------
hs.lpocntl_txtfnc=subuicontrol(hs.figure1,...
  15,2,28+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Function');
% Use Original Callback
hs.lpocntl_txtfncstr=subuicontrol(hs.figure1,...
  15,2,28+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','');

% Suspend This Property
Suspend(hs);

function h=subhandle(hs)
% Sub-Handles
h=[...
  hs.lpocntl_txtname;...
  hs.lpocntl_txtnamestr;...
  hs.lpocntl_txtrpos;...
  hs.lpocntl_edtrpos;...
  hs.lpocntl_txtapos;...
  hs.lpocntl_edtapos;...
  hs.lpocntl_txtStyle;...
  hs.lpocntl_popStyle;...
  hs.lpocntl_txtfnc;...
  hs.lpocntl_txtfncstr];

function h=subPoshandle(hs)
% Sub-Handles
h=[...
  hs.lpocntl_txtrpos;...
  hs.lpocntl_edtrpos;...
  hs.lpocntl_txtapos;...
  hs.lpocntl_edtapos];

function h=sub2handle(hs)
% Sub-Handles
h=[...
  hs.lpocntl_txtname;...
  hs.lpocntl_txtnamestr;...
  hs.lpocntl_txtStyle;...
  hs.lpocntl_popStyle;...
  hs.lpocntl_txtfnc;...
  hs.lpocntl_txtfncstr];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');

function Activate(hs)
% Activate
if strcmp(get(hs.lpocntl_txtrpos,'Visible'),'off'),
  set(sub2handle(hs),  'Visible','on'); 
else
  set(subhandle(hs),'Visible','on');
end
%===> Confine (MATRAB Bug?) <===
if 1
  % 06-Apr-2007
  % To reflect setting... ? I do not know why.
  %  in GUI could not change....
  % when I touch lower-control to upper-control
  s=get(hs.lpocntl_popStyle,'String');
  v=get(hs.lpocntl_popStyle,'Value');
  set(hs.lpocntl_popStyle,'String',s,'Value',v);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return Position-handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rh,ah]=getPoshandle(hs)
rh=[];ah=[];
if isfield(hs, 'lpocntl_edtrpos'),
  rh=hs.lpocntl_edtrpos;
end
if isfield(hs, 'lpocntl_edtapos'),
  ah=hs.lpocntl_edtapos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================

% Name Property
if isfield(LP, 'name'),
  set(hs.lpocntl_txtnamestr,'String',LP.name);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpocntl_txtnamestr,'String','Untitled Control');
end

% Figure-Position Property
set(subPoshandle(hs),'Visible','off');
ud = get(hs.lpocntl_edtrpos,'UserData');
if isfield(LP, 'Position'),
  ud.data = LP.Position;
elseif isfield(LP, 'position'),
  ud.data = LP.position;
elseif isfield(LP, 'pos'),
  ud.data = LP.pos;
else
  ud.data =[];
end
% There is Position & Style 
if ~isempty(ud.data) && ...
    isfield(LP,'SelectedUITYPE') && ...
    ~any(strcmpi(LP.SelectedUITYPE,{'menu'}))
  set(hs.lpocntl_edtrpos,'String',  num2str(ud.data,'%4.2f  '));
  set(hs.lpocntl_edtrpos,'UserData',ud);
  set(subPoshandle(hs),'Visible','on');
  Lparts_Manager('ChangeRPOS',hs.lpocntl_edtrpos,hs,false);
end

% Function Property
if isfield(LP, 'fnc'),
  set(hs.lpocntl_txtfncstr,'String',LP.fnc);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpocntl_txtfnctr,'String','function''s name is empty');
end

% Style Property
if isfield(LP, 'uicontrol'),
  set(hs.lpocntl_popStyle,'String',LP.uicontrol,'Value',1);
  set(hs.lpocntl_popStyle,'UserData',LP.uicontrol{1});
  if isfield(LP, 'SelectedUITYPE'),
    idx=find(strcmpi(LP.uicontrol, LP.SelectedUITYPE));
    if ~isempty(idx),
      set(hs.lpocntl_popStyle,'Value',idx);
      set(hs.lpocntl_popStyle,'UserData',LP.SelectedUITYPE);
    end
  end
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpocntl_popStyle,'String',{});
end

% Function Property
if isfield(LP, 'fnc'),
  set(hs.lpocntl_txtfncstr,'String',LP.fnc);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpocntl_txtfnctr,'String','function''s name is empty');
end

setappdata(hs.figure1,'CurrentLPOdata',LP);

%=============================
function LP=getParts(hs)
% Getter of Layout-Parts to GUI (5)
%=============================
LP=getappdata(hs.figure1,'CurrentLPOdata');
LP.name    =get(hs.lpocntl_txtnamestr,'String');
ud=get(hs.lpocntl_edtrpos,'UserData');
if isfield(LP, 'Position'),
  LP.Position=ud.data;
elseif isfield(LP, 'position'),
  LP.position=ud.data;
elseif isfield(LP, 'pos'),
  LP.pos=ud.data;
end
LP.fnc    =get(hs.lpocntl_txtfncstr, 'String');
LP.SelectedUITYPE=get(hs.lpocntl_popStyle, 'UserData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function ChangeStyle(h,hs)
% Change control-style!!
%=============================
str=get(hs.lpocntl_popStyle,'String');
val=get(hs.lpocntl_popStyle,'Value');
style=str{val};
set(hs.lpocntl_popStyle,'UserData',style);
% Set Flag(4)
setappdata(hs.figure1,'CurrentLPOischange',true);

% 2007.04.06
if any(strcmpi(style,{'menu'})),
  set(subPoshandle(hs),'Visible','off');
else
  set(subPoshandle(hs),'Visible','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Over-View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function h=ov_draw(LP,pos,state)
% LP    : LayoutParts
% pos   : absolute-position of parents
% state : 0(normal)
%       : 1(same hierarchy LPO)
%       : 2(selected LPO)
%  h : figure-Handle of OverView
%================================
if isfield(LP,'Position'),
  lpos=LP.Position;
elseif isfield(LP,'position'),
  lpos=LP.position;
elseif isfield(LP,'pos'),
  lpos=LP.pos;
else
  % case position-less??
  lpos=[];
end
if isempty(lpos),h=[];return;end
% Checking Style
if isfield(LP,'SelectedUITYPE')
  if any(strcmpi(LP.SelectedUITYPE,{'menu'}))
    h=[];
    return;
  end
end

absp=LayoutPartsIO('getPosabs',lpos,pos);
x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1);absp(1)];
y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4);absp(2)];
if nargin<3,state=0;end
switch state
  case 0
    h = line(x,y);
    set(h,'Color',[0.8,0.8,0.8]);
  case 1
    h = fill(x,y,[0.94,1,0.83]);
    lw=get(h,'LineWidth');
    set(h,'EdgeColor',[0.4,0.9,0.4],...
      'LineStyle','--','LineWidth',lw*3);
  case 2
    h = fill(x,y,[0.8,1,0.5]);
    lw=get(h,'LineWidth');
    set(h,'EdgeColor',[1,0,0],'LineWidth',lw*4);
  case 3
    set(h,'Color',[0,0.7,0],'LineWidth',lw*4);
  otherwise
    warning('Undefined state');
end