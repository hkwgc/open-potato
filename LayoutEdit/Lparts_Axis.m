function varargout=Lparts_Axis(fnc,varargin)
% Figure Layout-Parts Object


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
% $Id: Lparts_Axis.m 180 2011-05-19 09:34:28Z Katura $

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
hs.lpoaxis_txtname=subuicontrol(hs.figure1,...
  15,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpoaxis_edtname=subuicontrol(hs.figure1,...
  15,2,2+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','No-Name',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeName'',guidata(gcbf));');

%-------------------------------
% Relative - Position
%-------------------------------
hs.lpoaxis_txtrpos=subuicontrol(hs.figure1,...
  15,2,4+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Relative-Position');
% Use Original Callback
hs.lpoaxis_edtrpos=subuicontrol(hs.figure1,...
  15,2,4+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[0, 0, 1, 1]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeRPOS'',gcbo,guidata(gcbf));');

%-------------------------------
% Absolute  - Position
%-------------------------------
hs.lpoaxis_txtapos=subuicontrol(hs.figure1,...
  15,2,6+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Absolute-Position');
% Use Original Callback
hs.lpoaxis_edtapos=subuicontrol(hs.figure1,...
  15,2,6+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[1.00, 1.00, 1.00]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeAPOS'',gcbo,guidata(gcbf));');

% ==> Position Other Setting ==>
p.rposh = hs.lpoaxis_edtrpos;
p.aposh = hs.lpoaxis_edtapos;
p.data  = [1 1 1 1];
set([hs.lpoaxis_edtrpos, hs.lpoaxis_edtapos;],'UserData',p);
% <== Position Other Setting <==

% Suspend This Property
Suspend(hs);

function h=subhandle(hs)
% Sub-Handles
h=[...
  hs.lpoaxis_txtname;...
  hs.lpoaxis_edtname;...
  hs.lpoaxis_txtrpos;...
  hs.lpoaxis_edtrpos;...
  hs.lpoaxis_txtapos;...
  hs.lpoaxis_edtapos];

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
if isfield(hs, 'lpoaxis_edtrpos'),
  rh=hs.lpoaxis_edtrpos;
end
if isfield(hs, 'lpoaxis_edtapos'),
  ah=hs.lpoaxis_edtapos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================

% Name Property
if isfield(LP, 'NAME'),
  set(hs.lpoaxis_edtname,'String',LP.NAME);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpoaxis_edtname,'String','Untitled Axis');
end

% Figure-Position Property
ud = get(hs.lpoaxis_edtrpos,'UserData');
if isfield(LP, 'Position'),
  set(hs.lpoaxis_edtrpos,'String',  num2str(LP.Position,'%4.2f  '));
  ud .data = LP.Position;
  set(hs.lpoaxis_edtrpos,'UserData',ud);
else
  set(hs.lpoaxis_edtrpos,'String','[0, 0, 1, 1]');
  ud .data = [0 0 1 1];
  set(hs.lpoaxis_edtrpos,'UserData',ud);
end
Lparts_Manager('ChangeRPOS',hs.lpoaxis_edtrpos,hs,false);

setappdata(hs.figure1,'CurrentLPOdata',LP);

%=============================
function LP=getParts(hs)
% Getter of Layout-Parts to GUI (5)
%=============================
LP=getappdata(hs.figure1,'CurrentLPOdata');
LP.NAME    =get(hs.lpoaxis_edtname,'String');
ud=get(hs.lpoaxis_edtrpos,'UserData');
LP.Position=ud.data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
h=Lparts_Area('ov_draw',LP,pos,state);
