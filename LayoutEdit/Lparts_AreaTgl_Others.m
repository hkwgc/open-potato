function varargout=Lparts_AreaTgl_Others(fnc,varargin)
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
% $Id: Lparts_AreaTgl_Others.m 393 2014-02-03 02:19:23Z katura7pro $

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

%===============================
% Make Toggle Button
%===============================
hs.lpoarea_tglbtn(3)=uicontrol(...
  hs.figure1,...
  'Units','pixels',...
  'Style','Togglebutton',...
  'String','Others',...
  'Position',[562,399,60,20],...
  'Callback',...
  'Lparts_Area(''Tglchange'',gcbo,guidata(gcbf));'...
  );
%-------------------------------
% Script Input
%-------------------------------
Areamenu_Ldiv=30;
Areamenu_Cdiv=1;
Areamenu_Low=4;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_othe_txtscript=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Script');
Areamenu_Ldiv=15;
Areamenu_Cdiv=1;
Areamenu_Low=7;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
p=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'inner','getposition');
p(4)=p(4)*5;
hs.lpoarea_othe_edtscript=uicontrol(hs.figure1,...
  'style','edit',...
  'Position',p,...
  'HorizontalAlignment','left',...
  'BackgroundColor',[1, 1, 1],...
  'Callback','Lparts_AreaTgl_Others(''Callback_ScriptChange'',gcbf);',...
  'Max',2.0);
  
Areamenu_Low=9;
Areamenu_Cdiv=4;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_othe_btnscript=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','center',...
  'String','Sample Script',...
  'Callback',...
  'Lparts_AreaTgl_Others(''SampleVisible'',guidata(gcbf));'...
  );

Areamenu_Ldiv=5;
Areamenu_Low=4;
Areamenu_Cdiv=2;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_othe_txtsample=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'String',{'curdata.ch=16';'curdata.kind=[1,3]'}...
  );
% ==> Position Other Setting ==> 
% p.rposh = hs.lpoarea_othe_edtrpos;
% p.aposh = hs.lpoarea_othe_edtapos;
% p.data  = [1 1 1 1];
% set([hs.lpoarea_othe_edtrpos, hs.lpoarea_othe_edtapos;],'UserData',p);
% <== Position Other Setting <==

% Suspend This Property
Suspend(hs);
set(hs.lpoarea_tglbtn(3),'Visible','off');

function h=subhandle(hs)
% Sub-Handles
h=[...
    hs.lpoarea_othe_txtscript;...
    hs.lpoarea_othe_edtscript;...
    hs.lpoarea_othe_btnscript;...
    hs.lpoarea_othe_txtsample;...
  ];

function Callback_ScriptChange(hs)
% ghs=guihandles(hs);
% ghs.figure1=hs;
% Lparts_Manager('saveLPO',ghs);
% setappdata(hs,'CurrentLPOischange',true);
% LAYOUT=getappdata(hs, 'LAYOUT');
% LayoutPartsIO('set',ghs,LAYOUT,[]);

%TODO: Update Layout tree  TK@CRL 2012-05-15

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');

function Activate(hs)
% Activate
set(subhandle(hs),'Visible','on');
set(hs.lpoarea_othe_txtsample,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================
scrpt={''};
if isfield(LP,'Property') && isfield(LP.Property,'Script')
  scrpt=LP.Property.Script;
end
set(hs.lpoarea_othe_edtscript,'Value',1,'String',scrpt);
% Lparts_Manager('ChangeRPOS',hs.lpoarea_othe_edtrpos,hs,false);
% 
% setappdata(hs.figure1,'CurrentLPOdata',LP);

%=============================
function LP=getParts(hs,LP)
% Getter of Layout-Parts to GUI (5)
%=============================
LP.Property.Script = get(hs.lpoarea_othe_edtscript,'String');
% LP=getappdata(hs.figure1,'CurrentLPOdata');
% LP.NAME    =get(hs.lpoarea_othe_edtname,'String');
% ud=get(hs.lpoarea_othe_edtrpos,'UserData');
% LP.Position=ud.data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SampleVisible(hs)
set(hs.lpoarea_othe_txtsample,'Visible','on');
return;