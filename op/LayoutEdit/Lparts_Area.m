function varargout=Lparts_Area(fnc,varargin)
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
% $Id: Lparts_Area.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fnc,
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'ChangeTgl',
    ChangeTgl(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create & GUI-Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=getAreaFunclist
% Function List
out = {...
    @Lparts_AreaTgl_Primary,...
    @Lparts_AreaTgl_Variables,...
    @Lparts_AreaTgl_Others};
return;
%==================================================
function hs=Create(hs)
% Create  Figure-Layout-Parts  Property Setting GUI
%===================================================
Lparts_AreaTgl=getAreaFunclist;

for idx=1:length(Lparts_AreaTgl)
  hs=feval(Lparts_AreaTgl{idx},'Create',hs);
end
return;

function Suspend(hs)
Lparts_AreaTgl=getAreaFunclist;
% Suspend : Visible off
for idx=1:length(Lparts_AreaTgl)
  feval(Lparts_AreaTgl{idx},'Suspend',hs);
  set(hs.lpoarea_tglbtn(idx),'Visible','off');
  set(hs.lpoarea_tglbtn(idx),'Value',0)
end
return;

function Activate(hs)
Lparts_AreaTgl=getAreaFunclist;
% Activate
tglsum=0;
for idx=1:length(Lparts_AreaTgl)
  set(hs.lpoarea_tglbtn(idx),'Visible','on');
  tmpsum=get(hs.lpoarea_tglbtn(idx),'Value');
  tglsum=tglsum+tmpsum;
end
if(tglsum == 0),
  set(hs.lpoarea_tglbtn(1),'Value',1)
end
for idx=1:length(Lparts_AreaTgl)
  if(get(hs.lpoarea_tglbtn(idx),'Value') == 1),
    feval(Lparts_AreaTgl{idx},'Activate',hs);
  end
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return Position-handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rh,ah]=getPoshandle(hs)
rh=[];ah=[];
if isfield(hs, 'lpoarea_prim_edtrpos'),
  rh=hs.lpoarea_prim_edtrpos;
end
if isfield(hs, 'lpoarea_prim_edtapos'),
  ah=hs.lpoarea_prim_edtapos;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% % Set Layout-Parts to GUI (5)
% %=============================
% 
setappdata(hs.figure1,'CurrentLPOdata',LP);
fnclst=getAreaFunclist;
for idx=1:length(fnclst),
  feval(fnclst{idx},'setParts',hs,LP);
end
return;

% %=============================
function LP=getParts(hs)
% % Getter of Layout-Parts to GUI (5)
% %=============================
LP=getappdata(hs.figure1,'CurrentLPOdata');
% Page Loop
% : Update Layout-Parts
fnclst=getAreaFunclist;
for idx=1:length(fnclst),
  LP=feval(fnclst{idx},'getParts',hs,LP);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Tglchange(obj,hs)
selecttgl=get(obj,'String');
Suspend(hs);
set(hs.lpoarea_tglbtn,'Value',0);
for idx=1:length(hs.lpoarea_tglbtn),
  if(strcmp(selecttgl,get(hs.lpoarea_tglbtn(idx),'String')) == 1)
    set(hs.lpoarea_tglbtn(idx),'Value',1);
  end
end
Activate(hs);
return;

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
lpos=LP.Position;
absp=LayoutPartsIO('getPosabs',lpos,pos);
if state==0,
  d=0.005;
  absp(1:2)=absp(1:2)-d;
  absp(3:4)=absp(3:4)+2*d;
end
x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1);absp(1)];
y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4);absp(2)];
if nargin<3,state=0;end
switch state
  case 0
    h = line(x,y);
    set(h,'Color',[0.8,0.8,0.8]);
  case 1
    h = line(x,y);
    lw=get(h,'LineWidth');
    set(h,'Color',[0,0,1],...
      'LineStyle','--',...
      'LineWidth',lw*3);
  case 2
    h = line(x,y);
    lw=get(h,'LineWidth');
    set(h,'Color',[1,0,0],...
      'LineWidth',lw*4);
  case 3
    h = fill(x,y,[0.95 0.95 1]);
    %set(h,'LineStyle','none');
    set(h,'EdgeColor',[0.8,0.8,0.8]);
  otherwise
    warning('Undefined state');
end
