function varargout=Lparts_special_control(fnc,varargin)
% Special-control Layout-Parts Object


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
% $Id: Lparts_special_control.m 393 2014-02-03 02:19:23Z katura7pro $

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
hs.lpospecon_txtname=subuicontrol(hs.figure1,...
  15,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpospecon_txtnamestr=subuicontrol(hs.figure1,...
  15,2,2+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left');

%-------------------------------
% Relative - Position
%-------------------------------
hs.lpospecon_txtrpos=subuicontrol(hs.figure1,...
  15,2,4+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'String','Relative-Position');
% Use Original Callback
hs.lpospecon_edtrpos=subuicontrol(hs.figure1,...
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
hs.lpospecon_txtapos=subuicontrol(hs.figure1,...
  15,2,6+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'Visible','off',...
  'String','Absolute-Position');
% Use Original Callback
hs.lpospecon_edtapos=subuicontrol(hs.figure1,...
  15,2,6+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[1.00, 1.00, 1.00]',...
  'BackgroundColor',[1, 1, 1],...
  'Visible','off',...
  'Callback',...
  'Lparts_Manager(''ChangeAPOS'',gcbo,guidata(gcbf));');

%-------------------------------
% Modify Button
%-------------------------------
f=get(0,'FixedWidthFontName');
hs.lpospecon_lbxArgument=subuicontrol(hs.figure1,...
  3,1,2,'Inner',...
  'FontName',f,...
  'Style','ListBox',...
  'BackgroundColor',[1, 1, 1]);
% Use Original Callback
hs.lpospecon_psbModify=subuicontrol(hs.figure1,...
  15,2,22+2,'Inner',...
  'Style','PushButton',...
  'HorizontalAlignment','left',...
  'String','Modify',...
  'Callback',...
  'Lparts_special_control(''modifyArgument'',gcbo,guidata(gcbf));');

% ==> Position Other Setting ==>
p.rposh = hs.lpospecon_edtrpos;
p.aposh = hs.lpospecon_edtapos;
p.data  = [1 1 1 1];
set([hs.lpospecon_edtrpos, hs.lpospecon_edtapos;],'UserData',p);
% <== Position Other Setting <==

%-------------------------------
% Function
%-------------------------------
hs.lpospecon_txtfnc=subuicontrol(hs.figure1,...
  15,2,28+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Function');
% Use Original Callback
hs.lpospecon_txtfncstr=subuicontrol(hs.figure1,...
  15,2,28+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','');

% Suspend This Property
Suspend(hs);

function h=subhandle(hs)
% Sub-Handles
h=[...
  hs.lpospecon_txtname;...
  hs.lpospecon_txtnamestr;...
  hs.lpospecon_txtrpos;...
  hs.lpospecon_edtrpos;...
  hs.lpospecon_txtapos;...
  hs.lpospecon_edtapos;...
  hs.lpospecon_lbxArgument;...
  hs.lpospecon_psbModify;...
  hs.lpospecon_txtfnc;...
  hs.lpospecon_txtfncstr];

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
if isfield(hs, 'lpospecon_edtrpos'),
  rh=hs.lpospecon_edtrpos;
end
if isfield(hs, 'lpospecon_edtapos'),
  ah=hs.lpospecon_edtapos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP,posrewrite)
% Set Layout-Parts to GUI (5)
%=============================
if nargin<=2
  posrewrite=false;
end

% Name Property
if isfield(LP, 'name'),
  set(hs.lpospecon_txtnamestr,'String',LP.name);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpospecon_txtnamestr,'String','Untitled Control');
end

% Argument Property
lbxstr=field2lbx_str(LP);
set(hs.lpospecon_lbxArgument,'String',lbxstr,'Value',1);
set(hs.lpospecon_lbxArgument, 'UserData', LP);

% Figure-Position Property
ud = get(hs.lpospecon_edtrpos,'UserData');
if isfield(LP, 'Position'),
  set(hs.lpospecon_edtrpos,'String',  num2str(LP.Position,'%4.2f  '));
  ud.data = LP.Position;
  set(hs.lpospecon_edtrpos,'UserData',ud);
elseif isfield(LP, 'position'),
  set(hs.lpospecon_edtrpos,'String',  num2str(LP.position,'%4.2f  '));
  ud.data = LP.position;
  set(hs.lpospecon_edtrpos,'UserData',ud);
elseif isfield(LP, 'pos'),
  set(hs.lpospecon_edtrpos,'String',  num2str(LP.pos,'%4.2f  '));
  ud.data = LP.pos;
  set(hs.lpospecon_edtrpos,'UserData',ud);
else
  set(hs.lpospecon_edtrpos,'String','[0, 0, 1, 1]');
  ud.data = [0 0 1 1];
  set(hs.lpospecon_edtrpos,'UserData',ud);
end
Lparts_Manager('ChangeRPOS',hs.lpospecon_edtrpos,hs,posrewrite);

% Function Property
if isfield(LP, 'fnc'),
  set(hs.lpospecon_txtfncstr,'String',LP.fnc);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpospecon_txtfnctr,'String','function''s name is empty');
end

% Function Property
if isfield(LP, 'fnc'),
  set(hs.lpospecon_txtfncstr,'String',LP.fnc);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpospecon_txtfnctr,'String','function''s name is empty');
end

setappdata(hs.figure1,'CurrentLPOdata',LP);

function LP=setPos(LP,hs)
%
ud=get(hs.lpospecon_edtrpos,'UserData');
try
  LP.pos=ud.data;
catch
end

% confine
if isfield(LP, 'Position'),
  LP.Position=ud.data;
elseif isfield(LP, 'position'),
  LP.position=ud.data;
end
return;

%=============================
function LP=getParts(hs)
% Getter of Layout-Parts to GUI (5)
%=============================

%LP=getappdata(hs.figure1,'CurrentLPOdata');
LP=get(hs.lpospecon_lbxArgument,'UserData');
LP.name    =get(hs.lpospecon_txtnamestr,'String');
LP=setPos(LP,hs);
LP.fnc    =get(hs.lpospecon_txtfncstr, 'String');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function modifyArgument(h,hs)
% modify button!!
%=============================

%--> Bugfix : 2007.05.23 shoji
%    (Change is enable)
data=get(hs.lpospecon_lbxArgument,'UserData');
data=setPos(data,hs);
fnc=get(hs.lpospecon_txtfncstr,'String');
try
  data=feval(fnc,'getArgument',data);
catch
  data=[];
  errordlg({'-------------------------------',...
    '[Layout-Control-Object Error]',...
    '-------------------------------',...
    ['   ' fnc ': getArgument'],...
    ['    ' lasterr]},'Layout-Control-Object Error');
end
if isempty(data),return;end
% Restore:
if 1
  setParts(hs,data,true)
else
  lbxstr=field2lbx_str(data);
  set(hs.lpospecon_lbxArgument,'String',lbxstr,'Value',1);
  set(hs.lpospecon_lbxArgument,'UserData',data);
end
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

if isfield(data,'str'),
  data=rmfield(data,'str');
end
if isfield(data,'fnc'),
  data=rmfield(data,'fnc');
end
if isfield(data,'name')
  data=rmfield(data,'name');
end
if isfield(data,'name_Label')
  data=rmfield(data,'name_Label');
end
if isfield(data, 'Position'),
  data=rmfield(data,'Position');
elseif isfield(data, 'position'),
  data=rmfield(data,'position');
elseif isfield(data, 'pos'),
  data=rmfield(data, 'pos');
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
h=Lparts_control('ov_draw',LP,pos,state);
