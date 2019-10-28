function varargout=Lparts_object(fnc,varargin)
% AxisObject Layout-Parts Object


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
% $Id: Lparts_object.m 180 2011-05-19 09:34:28Z Katura $

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
hs.lpoobj_txtname=subuicontrol(hs.figure1,...
  15,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpoobj_txtnamestr=subuicontrol(hs.figure1,...
  15,2,2+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left');

%-------------------------------
% Argument
%-------------------------------
f=get(0,'FixedWidthFontName');
hs.lpoobj_lbxArgument=subuicontrol(hs.figure1,...
  3,1,2,'Inner',...
  'FontName',f,...
  'Style','ListBox',...
  'BackgroundColor',[1, 1, 1]);
% Use Original Callback
hs.lpoobj_psbModify=subuicontrol(hs.figure1,...
  15,2,22+2,'Inner',...
  'Style','PushButton',...
  'HorizontalAlignment','left',...
  'String','Modify',...
  'Callback',...
  'Lparts_object(''modifyArgument'',gcbo,guidata(gcbf));');

%-------------------------------
% Function
%-------------------------------
hs.lpoobj_txtfnc=subuicontrol(hs.figure1,...
  15,2,28+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Function');
% Use Original Callback
hs.lpoobj_txtfncstr=subuicontrol(hs.figure1,...
  15,2,28+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','');

% Suspend This Property
Suspend(hs);

function h=subhandle(hs)
% Sub-Handles
h=[...
  hs.lpoobj_txtname;...
  hs.lpoobj_txtnamestr;...
  hs.lpoobj_lbxArgument;...
  hs.lpoobj_psbModify;...
  hs.lpoobj_txtfnc;...
  hs.lpoobj_txtfncstr];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');

function Activate(hs)
% Activate
set(subhandle(hs),'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return Position-handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rh,ah]=getPoshandle(hs)
rh=[];ah=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================

% Name Property
if isfield(LP, 'str'),
  set(hs.lpoobj_txtnamestr,'String',LP.str);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpoobj_txtnamestr,'String','Untitled AxisObject');
end

% Argument Property
lbxstr=field2lbx_str(LP);
set(hs.lpoobj_lbxArgument,'String',lbxstr,'Value',1);
set(hs.lpoobj_lbxArgument, 'UserData', LP);

% Function Property
if isfield(LP, 'fnc'),
  set(hs.lpoobj_txtfncstr,'String',LP.fnc);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpoobj_txtfnctr,'String','function''s name is empty');
end
setappdata(hs.figure1,'CurrentLPOdata',LP);

%=============================
function LP=getParts(hs)
% Getter of Layout-Parts to GUI (5)
%=============================
LP=getappdata(hs.figure1,'CurrentLPOdata');
data=get(hs.lpoobj_lbxArgument,'UserData');
if ~isempty(data),
  LP=data; 
end
LP.str    =get(hs.lpoobj_txtnamestr,'String');
LP.fnc    =get(hs.lpoobj_txtfncstr, 'String');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function modifyArgument(h,hs)
% modify button!!
%=============================

%--> Bugfix : 2007.05.23 shoji
%    (Change is enable)
data=get(hs.lpoobj_lbxArgument,'UserData');
fnc=get(hs.lpoobj_txtfncstr,'String');
try
  data=feval(fnc,'getArgument',data);
catch
end
if isempty(data),return;end
lbxstr=field2lbx_str(data);
set(hs.lpoobj_lbxArgument,'String',lbxstr,'Value',1);
set(hs.lpoobj_lbxArgument,'UserData',data);
% Set Flag(4)
setappdata(hs.figure1,'CurrentLPOischange',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inner function of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function str=field2lbx_str(data)
%=============================
%str={};
if isempty(data),return;end

if isempty(data),return;end

if isfield(data,'str'),
  data=rmfield(data,'str');
end
if isfield(data,'fnc'),
  data=rmfield(data,'fnc');
end
str=OspDataFileInfo(0,1,data);

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
x  =[pos(1);pos(1)+pos(3);pos(1)+pos(3);pos(1);pos(1)];
y  =[pos(2);pos(2);pos(2)+pos(4);pos(2)+pos(4);pos(2)];

if nargin<3,state=0;end
% Draw Axis-area
switch state
  case 1
    h=fill(x,y,[1,1,0.8]);
    lw=get(h,'LineWidth');
    set(h,'LineStyle','none',...
      'EdgeColor',[1 0 0]);    
  case {2,3}
    h=fill(x,y,[1,0.95,0.7]);
    lw=get(h,'LineWidth');
    set(h,'LineStyle','none',...
      'EdgeColor',[1 0 0]);
  otherwise
    h=[];
end
return;
