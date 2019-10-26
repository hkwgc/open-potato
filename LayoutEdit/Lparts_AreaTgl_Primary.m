function varargout=Lparts_Areatgl_Primary(fnc,varargin)
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
% $Id: Lparts_AreaTgl_Primary.m 180 2011-05-19 09:34:28Z Katura $

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
hs.lpoarea_tglbtn(1)=uicontrol(...
  hs.figure1,...
  'Units','pixels',...
  'Style','Togglebutton',...
  'String','Primary',...
  'Position',[442,399,60,20],...
  'Callback',...
  'Lparts_Area(''Tglchange'',gcbo,guidata(gcbf));'...
  );
%===============================
% Make Popup Menu
%===============================
Areamenu_Low=2;
Areamenu_Ldiv=15;
Areamenu_Cdiv=2;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_popdistmode=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',{'Simple Area';'Channel Order Area'},...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Distribution_Visible'',gcbo,guidata(gcbf));'...
  );
str  ={'Normal','Normal0', 'Array(Square)','Array(2 Columns)'};
udstr={'Normal','Normal0', 'Square','2Columns'};
hs.lpoarea_prim_popchorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',str,...
  'Userdata',udstr,...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Distribution_Callback'',guidata(gcbf));'...
  );
%-------------------------------
% Name
%-------------------------------
Areamenu_Low=4;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtname=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpoarea_prim_edtname=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','No-Name',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeName'',guidata(gcbf));');

%-------------------------------
% Relative - Position
%-------------------------------
Areamenu_Low=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtrpos=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Relative-Position');
% Use Original Callback
hs.lpoarea_prim_edtrpos=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[0, 0, 1, 1]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeRPOS'',gcbo,guidata(gcbf));');

%-------------------------------
% Absolute  - Position
%-------------------------------
Areamenu_Low=6;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtapos=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Absolute-Position');
% Use Original Callback
hs.lpoarea_prim_edtapos=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[1.00, 1.00, 1.00]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeAPOS'',gcbo,guidata(gcbf));');

%-------------------------------
% tag-order on/off
%-------------------------------
Areamenu_Low=8;
Areamenu_Cdiv=3.5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_cbxlineprop=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','checkbox',...
  'HorizontalAlignment','left',...
  'String','Line Property',...
  'Value',0,...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Lineprop_Visible'',gcbo,guidata(gcbf));'...
  );

%-------------------------------
% tag-order set (radiobutton)
%-------------------------------
Areamenu_Low=9;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_rdtagorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','radiobutton',...
  'HorizontalAlignment','left',...
  'String','Tag',...
  'Value',1,...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Activate_Tagorder'',gcbo,guidata(gcbf));'...
  );
hs.lpoarea_prim_rdorderorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','radiobutton',...
  'HorizontalAlignment','left',...
  'String','Number',...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Activate_Tagorder'',gcbo,guidata(gcbf));'...
  );
%-------------------------------
% tag-order set (Edit & [+][-])
%-------------------------------
ud.min=4;
ud.max=50;
Areamenu_Low=10;
Areamenu_Cdiv=2.5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_edtorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'BackgroundColor',[1, 1, 1],...
  'Userdata',ud...
  );
Areamenu_Ldiv=30;
Areamenu_Low=19;
Areamenu_Cdiv=10;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_btnplusorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','left',...
  'String','+',...
  'Callback',...
  'Lparts_AreaTgl_Primary(''PlusMinus_Callback'',gcbo,guidata(gcbf));'...
  );
Areamenu_Low=20;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_btnminusorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','left',...
  'String','-',...
  'Callback',...
  'Lparts_AreaTgl_Primary(''PlusMinus_Callback'',gcbo,guidata(gcbf));'...
  );

%-------------------------------
% tag-order set (pushbutton)
%-------------------------------
Areamenu_Ldiv=15;
Areamenu_Low =15; %Areamenu_Low=12;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_btnaddorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','left',...
  'String','Add',...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Addbtn_Callback'',guidata(gcbf));'...
  );
Areamenu_Ldiv=15;
Areamenu_Low =13; %Areamenu_Low=12;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_btndelorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','left',...
  'String','Delete',...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Deletebtn_Callback'',guidata(gcbf));'...
  );
%-------------------------------
% tag-order set (list)
%-------------------------------
Areamenu_Ldiv=5;
Areamenu_Low=5;
Areamenu_Cdiv=2.5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_listorder=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+1,'Inner',...
  'Style','listbox',...
  'HorizontalAlignment','left',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''Listbox_Callback'',gcbo,guidata(gcbf));'...
  );
p0 = get(hs.lpoarea_prim_btndelorder, 'Position');
pc = get(hs.lpoarea_prim_listorder, 'Position');
pc(2)=p0(2)+p0(4);
set(hs.lpoarea_prim_listorder, 'Position',pc);

%-------------------------------
% line property (colorbottun)
%-------------------------------
Areamenu_Ldiv=30;
Areamenu_Low=16;
Areamenu_Cdiv=10;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtcolor=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+7,'Inner',...
  'Style','text',...
  'HorizontalAlignment','center',...
  'String','Color'...
  );
Areamenu_Ldiv=15;
Areamenu_Low=9;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_btncolor=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+7,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','left',...
  'BackgroundColor',[0, 0, 0],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''LineProp_Callback'',gcbo,guidata(gcbf));'...
  );

%-------------------------------
% line property (Marker popup)
%-------------------------------
Areamenu_Ldiv=30;
Areamenu_Low=20;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtmarker=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+4,'Inner',...
  'Style','text',...
  'HorizontalAlignment','center',...
  'String','Marker'...
  );
hs.lpoarea_prim_txtmarkersize=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','text',...
  'HorizontalAlignment','center',...
  'String','Marker Size'...
  );
Areamenu_Ldiv=15;
Areamenu_Low=11;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);


markerstr={'none','.','o','x','+','*','s','d','v','^','<','>','p','h'};
userstr={'none','.','o','x','+','*','square','diamond','v','^','<','>','pentagram','hexagram'};
hs.lpoarea_prim_popmarker=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+4,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',markerstr,...
  'BackgroundColor',[1, 1, 1],...
  'Userdata',userstr,...
  'Callback',...
  'Lparts_AreaTgl_Primary(''LineProp_Callback'',gcbo,guidata(gcbf));'...
  );
markerstr={'1','3','6','9','12','15','18','21','24','27','30'};
hs.lpoarea_prim_popmarkersize=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',markerstr,...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''LineProp_Callback'',gcbo,guidata(gcbf));'...
  );

%-------------------------------
% line property (style popup)
%-------------------------------
Areamenu_Ldiv=30;
Areamenu_Low=24;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
hs.lpoarea_prim_txtstyle=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+4,'Inner',...
  'Style','text',...
  'HorizontalAlignment','center',...
  'String','Style'...
  );
hs.lpoarea_prim_txtstylesize=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','text',...
  'HorizontalAlignment','center',...
  'String','Style Size'...
  );
Areamenu_Ldiv=15;
Areamenu_Low=13;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
markerstr={'-',':', '-.','--','none'};
hs.lpoarea_prim_popstyle=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+4,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',markerstr,...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_AreaTgl_Primary(''LineProp_Callback'',gcbo,guidata(gcbf));'...
  );
markerstr={'1/8','1/4','2/4','3/4','4/4','5/4',...
  '6/4','7/4','8/4','3','4','5','6','7'};
usernum={0.125,0.25',0.5,0.75,1,1.25,1.5,1.75,2,3,4,5,6,7};
hs.lpoarea_prim_popstylesize=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'Inner',...
  'Style','popupmenu',...
  'HorizontalAlignment','left',...
  'String',markerstr,...
  'BackgroundColor',[1, 1, 1],...
  'Userdata',usernum,...
  'Callback',...
  'Lparts_AreaTgl_Primary(''LineProp_Callback'',gcbo,guidata(gcbf));'...
  );

%-------------------------------
% line property (setting preview)
%-------------------------------
Areamenu_Ldiv=15;
Areamenu_Low=9;
Areamenu_Cdiv=5;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Low-1);
p=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+5,'inner','getposition');
set(0,'CurrentFigure',hs.figure1);
hs.lpoarea_prim_axespreview=axes;
p(4)=p(4)*2;
set(hs.lpoarea_prim_axespreview,...
  'Units','pixels',...
  'Position',p,...
  'XTick',[],'Ytick',[],...
  'XtickMode','manual',...
  'YtickMode','manual',...
  'Color',[1, 1, 1],...
  'NextPlot','replacechildren');
x=0:0.2:1;
y=x;
set(hs.figure1,'CurrentAxes',hs.lpoarea_prim_axespreview);
lcolor=get(hs.lpoarea_prim_btncolor,'BackgroundColor');
set(hs.lpoarea_prim_axespreview,...
  'ColorOrder',lcolor,...
  'XTick',[],'YTick',[]);
plot(x,y);

% ==> Position Other Setting ==>
pp.rposh = hs.lpoarea_prim_edtrpos;
pp.aposh = hs.lpoarea_prim_edtapos;
pp.data  = [1 1 1 1];
set([hs.lpoarea_prim_edtrpos, hs.lpoarea_prim_edtapos;],'UserData',pp);
% <== Position Other Setting <==

% Suspend This Property
Suspend(hs);
set(hs.lpoarea_tglbtn(1),'Visible','off');

function h=subhandle(hs)
% Sub-Handles
h=[...
    hs.lpoarea_prim_popdistmode;...
    hs.lpoarea_prim_popchorder;...
    hs.lpoarea_prim_txtname;...
    hs.lpoarea_prim_edtname;...
    hs.lpoarea_prim_txtrpos;...
    hs.lpoarea_prim_edtrpos;...
    hs.lpoarea_prim_txtapos;...
    hs.lpoarea_prim_edtapos;...
    hs.lpoarea_prim_cbxlineprop;...
    hs.lpoarea_prim_rdtagorder;...
    hs.lpoarea_prim_rdorderorder;...
    hs.lpoarea_prim_edtorder;...
    hs.lpoarea_prim_btnplusorder;...
    hs.lpoarea_prim_btnminusorder;...
    hs.lpoarea_prim_btnaddorder;...
    hs.lpoarea_prim_btndelorder;...
    hs.lpoarea_prim_listorder;...
    hs.lpoarea_prim_txtcolor;...
    hs.lpoarea_prim_btncolor;...
    hs.lpoarea_prim_txtmarker;...
    hs.lpoarea_prim_txtmarkersize;...
    hs.lpoarea_prim_popmarker;...
    hs.lpoarea_prim_popmarkersize;...
    hs.lpoarea_prim_txtstyle;...
    hs.lpoarea_prim_txtstylesize;...
    hs.lpoarea_prim_popstyle;...
    hs.lpoarea_prim_popstylesize;...
    hs.lpoarea_prim_axespreview;...
  ];

function h=subhandle_lineprop(hs),
h=[...
  hs.lpoarea_prim_rdtagorder;...
  hs.lpoarea_prim_rdorderorder;...
  hs.lpoarea_prim_edtorder;...
  hs.lpoarea_prim_btnplusorder;...
  hs.lpoarea_prim_btnminusorder;...
  hs.lpoarea_prim_btnaddorder;...
  hs.lpoarea_prim_btndelorder;...
  hs.lpoarea_prim_listorder;...
  hs.lpoarea_prim_txtcolor;...
  hs.lpoarea_prim_btncolor;...
  hs.lpoarea_prim_txtmarker;...
  hs.lpoarea_prim_txtmarkersize;...
  hs.lpoarea_prim_popmarker;...
  hs.lpoarea_prim_popmarkersize;...
  hs.lpoarea_prim_txtstyle;...
  hs.lpoarea_prim_txtstylesize;...
  hs.lpoarea_prim_popstyle;...
  hs.lpoarea_prim_popstylesize;...
  hs.lpoarea_prim_axespreview;...
  ];
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');
if ~isempty(get(hs.lpoarea_prim_axespreview,'Children')),
  set(get(hs.lpoarea_prim_axespreview,'Children'),'Visible','off');
end

function Activate(hs),
% Activate
set(subhandle(hs),'Visible','on');
% DistributionMode on/off
Distribution_Visible(hs.lpoarea_prim_popdistmode,hs)
% Line Prop on/off
Lineprop_Visible(hs.lpoarea_prim_cbxlineprop,hs);
return;

function Distribution_Visible(obj,hs)
val=get(obj,'Value');
if val == 1,
  set(hs.lpoarea_prim_popchorder,'Visible','off');
else
  set(hs.lpoarea_prim_popchorder,'Visible','on');
end
Distribution_Callback(hs);
return;

function Distribution_Callback(hs),
setappdata(hs.figure1,'CurrentLPOischange',true);
return;

function Lineprop_Visible(obj,hs),
val=get(obj,'Value');
hdl=subhandle_lineprop(hs);
set(hdl,'Visible','on');
if val,
  rb1=get(hs.lpoarea_prim_rdorderorder,'Value');
  rb2=get(hs.lpoarea_prim_rdtagorder,'Value');
  if(rb1+rb2 == 0),
    set(hs.lpoarea_prim_rdtagorder,'Value',1);
    rb1=1;
  end
  if(rb1 == 1),
    obj=hs.lpoarea_prim_rdorderorder;
  elseif(rb2 ==1),
    obj=hs.lpoarea_prim_rdtagorder;
  end
  Activate_Tagorder(obj,hs)
  if ~isempty(get(hs.lpoarea_prim_axespreview,'Children')),
    set(get(hs.lpoarea_prim_axespreview,'Children'),'Visible','on');
  end
else
  set(hdl,'Visible','off');
  if ~isempty(get(hs.lpoarea_prim_axespreview,'Children')),
    set(get(hs.lpoarea_prim_axespreview,'Children'),'Visible','off');
  end
end

return;

function Activate_Tagorder(obj,hs)
selectrd=get(obj,'String');

if(strcmp(selectrd,'Tag') == 1),
  % Radio button's value
  set(hs.lpoarea_prim_rdtagorder,'Value',1);
  set(hs.lpoarea_prim_rdorderorder,'Value',0);
  % suspend gui's for "Number"
  set(hs.lpoarea_prim_btnplusorder,'Visible','off');
  set(hs.lpoarea_prim_btnminusorder,'Visible','off');
  % activate gui's for "Tag"
  set(hs.lpoarea_prim_btnaddorder,'Visible','on');
  set(hs.lpoarea_prim_btndelorder,'Visible','on');
  set(hs.lpoarea_prim_listorder,'Visible','on');

  % ==> Move Edit-Text to Proper Position
  p=subuicontrol(hs.figure1,15,2.5,33.5,'Inner','getposition');
  set(hs.lpoarea_prim_edtorder,'Position',p);
elseif(strcmp(selectrd,'Number') == 1),
  % Radio button's value
  set(hs.lpoarea_prim_rdtagorder,'Value',0);
  set(hs.lpoarea_prim_rdorderorder,'Value',1);
  % activate gui's for "Number"
  set(hs.lpoarea_prim_btnplusorder,'Visible','on');
  set(hs.lpoarea_prim_btnminusorder,'Visible','on');
  % suspend gui's for "Tag"
  set(hs.lpoarea_prim_btnaddorder,'Visible','off');
  set(hs.lpoarea_prim_btndelorder,'Visible','off');
  set(hs.lpoarea_prim_listorder,'Visible','off'); 
  % ==> Move Edit-Text to Proper Position
  p=subuicontrol(hs.figure1,15,2.5,23.5,'Inner','getposition');
  set(hs.lpoarea_prim_edtorder,'Position',p);
end
Lineprop_Setting(hs);
return;

function Lineprop_Setting(hs),
% test code
rdval=get(hs.lpoarea_prim_rdtagorder,'Value');
% rdval == 1 -> tag
% rdval == 0 -> order
if rdval,
  prop=getLineProp(hs);
  ud=get(hs.lpoarea_prim_rdtagorder,'Userdata');
  set(hs.lpoarea_prim_listorder,'String',{ud.Name});
  nl=get(hs.lpoarea_prim_listorder,'Value');
  str=get(hs.lpoarea_prim_listorder,'String');
  set(hs.lpoarea_prim_edtorder,'String',str{nl});
  uprop=ud(nl).Property;
  setLineProp(hs,uprop);
  
  set(hs.lpoarea_prim_btncolor,'BackGroundColor',uprop{2});
  
  nval=find(strcmp(get(hs.lpoarea_prim_popmarker,'String'),uprop{4})==1);
  if isempty(nval),
    mstr=get(hs.lpoarea_prim_popmarker,'Userdata');
    nval=find(strcmp(mstr,uprop{4})==1);
  end
  set(hs.lpoarea_prim_popmarker,'Value',nval);
  nval=find(strcmp(get(hs.lpoarea_prim_popmarkersize,'String'),num2str(uprop{6}))==1);
  set(hs.lpoarea_prim_popmarkersize,'Value',nval);
  
  nval=find(strcmp(get(hs.lpoarea_prim_popstyle,'String'),uprop{8})==1);
  set(hs.lpoarea_prim_popstyle,'Value',nval);
  
  dat=cell2mat(get(hs.lpoarea_prim_popstylesize,'Userdata'));
  [nval,ni]=min(abs( dat-uprop{10} ));
  set(hs.lpoarea_prim_popstylesize,'Value',ni);
else,
  edtud=get(hs.lpoarea_prim_edtorder,'Userdata');
  nstr=get(hs.lpoarea_prim_edtorder,'String');
  try,
    val=str2num(nstr);
  catch,
    val=edtud.min;
  end
  if isempty(val),val=edtud.min;end

  set(hs.lpoarea_prim_edtorder,'String',val);
  ud=get(hs.lpoarea_prim_rdorderorder,'Userdata');
  if length(ud) < val,
    prop={'Color',[0 0.5 0.75],...
      'Marker','>',...
      'MarkerSize',3,...
      'LineStyle','-',...
      'LineWidth',0.5};
    ud{end+1}=prop;
    set(hs.lpoarea_prim_rdorderorder,'Userdata',ud);
    setappdata(hs.figure1,'CurrentLPOischange',true);
  end

  uprop=ud{val};
  setLineProp(hs,uprop);

  set(hs.lpoarea_prim_btncolor,'BackGroundColor',uprop{2});
  a=char(get(hs.lpoarea_prim_popmarker,'String'));
  
  nval=find(strcmp(get(hs.lpoarea_prim_popmarker,'String'),uprop{4})==1);
  if isempty(nval),
    mstr=get(hs.lpoarea_prim_popmarker,'Userdata');
    nval=find(strcmp(mstr,uprop{4})==1);
  end
  set(hs.lpoarea_prim_popmarker,'Value',nval);
  nval=find(strcmp(get(hs.lpoarea_prim_popmarkersize,'String'),num2str(uprop{6}))==1);
  set(hs.lpoarea_prim_popmarkersize,'Value',nval);
  
  nval=find(strcmp(get(hs.lpoarea_prim_popstyle,'String'),uprop{8})==1);
  set(hs.lpoarea_prim_popstyle,'Value',nval);
  
  dat=cell2mat(get(hs.lpoarea_prim_popstylesize,'Userdata'));
  [nval,ni]=min(abs( dat-uprop{10} ));
  set(hs.lpoarea_prim_popstylesize,'Value',ni);

end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================

%----------------------
% Name Property
%----------------------
if isfield(LP, 'NAME'),
  set(hs.lpoarea_prim_edtname,'String',LP.NAME);
else
  % Default
  disp(C__FILE__LINE__CHAR);
  set(hs.lpoarea_prim_edtname,'String','Untitled Axis');
end
 
%----------------------
% Figure-Position Property
%----------------------
ud = get(hs.lpoarea_prim_edtrpos,'UserData');
if isfield(LP, 'Position'),
  set(hs.lpoarea_prim_edtrpos,'String',  num2str(LP.Position,'%4.2f  '));
  ud .data = LP.Position;
  set(hs.lpoarea_prim_edtrpos,'UserData',ud);
else
  set(hs.lpoarea_prim_edtrpos,'String','[0, 0, 1, 1]');
  ud .data = [0 0 1 1];
  set(hs.lpoarea_prim_edtrpos,'UserData',ud);
end
Lparts_Manager('ChangeRPOS',hs.lpoarea_prim_edtrpos,hs,false);

%----------------------
% DistributionMode Set
%----------------------
if strcmp(LP.DistributionMode,'Simple Area');
  LP.DistributionMode=[''];
end
if isempty(LP.DistributionMode),
    set(hs.lpoarea_prim_popdistmode,'Value',1);
    set(hs.lpoarea_prim_popchorder,'Value',1);
else
    set(hs.lpoarea_prim_popdistmode,'Value',2);
    ud=get(hs.lpoarea_prim_popchorder,'UserData');
    vl=find(strcmpi(ud,LP.DistributionMode));
    if length(vl)==0,vl=1;end
    set(hs.lpoarea_prim_popchorder,'Value',vl(1));
end

%----------------------
% Line Property
%----------------------
% Listbox Init
set(hs.lpoarea_prim_listorder,'Value',1);
set(hs.lpoarea_prim_rdtagorder,'Value',1);
set(hs.lpoarea_prim_rdorderorder,'Value',0);
% --> LineProperty Default Value
prop0={'Color',[1 0 0],...
  'Marker','none',...
  'MarkerSize',6,...
  'LineStyle','-',...
  'LineWidth',0.5};
tagdef(1).Name     ='Oxy';
tagdef(1).Property =prop0;
prop0{2}=[0 0 1];
tagdef(2).Name     ='Deoxy';
tagdef(2).Property =prop0;
prop0{2}=[0 0 0];
tagdef(3).Name     ='Total';
tagdef(3).Property =prop0;
orderdef=cell(3,1);
if isfield(LP,'Property') && isfield(LP.Property,'LineProperty')
  % Load Property & set it to UserData.
  set(hs.lpoarea_prim_cbxlineprop,'Value',1);
  if isfield(LP.Property.LineProperty,'TAG'),
    set(hs.lpoarea_prim_rdtagorder,'UserData',LP.Property.LineProperty.TAG);
  else
    set(hs.lpoarea_prim_rdtagorder,'UserData',tagdef);
  end
  if isfield(LP.Property.LineProperty,'ORDER'),
    set(hs.lpoarea_prim_rdorderorder,'UserData',LP.Property.LineProperty.ORDER);
  else
    set(hs.lpoarea_prim_rdorderorder,'UserData',orderdef);
  end
else
  % Set Initial-Value to Userdata 
  set(hs.lpoarea_prim_cbxlineprop,'Value',0);
  set(hs.lpoarea_prim_rdtagorder,'UserData',tagdef);
  set(hs.lpoarea_prim_rdorderorder,'UserData',orderdef);
end

%Listbox DefaultValue
set(hs.lpoarea_prim_listorder,'Visible','off');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function LP=getParts(hs,LP)
% Getter of Layout-Parts to GUI (5)
%=============================
LP.NAME=get(hs.lpoarea_prim_edtname,'String');
ud=get(hs.lpoarea_prim_edtrpos,'UserData');
LP.Position=ud.data;

%----------------------
% DistributionMode Get
%----------------------
ud=[];
val=get(hs.lpoarea_prim_popdistmode,'Value');
if val == 2
  chval=get(hs.lpoarea_prim_popchorder,'Value');
  str=get(hs.lpoarea_prim_popchorder,'Userdata');
  LP.DistributionMode=str{chval};
else
  % --> Add for Distribute Mode : 2007.03.25/shoji
  %     : Bug fix
  LP.DistributionMode='';
end

%----------------------
% Line Property
%----------------------
ckval=get(hs.lpoarea_prim_cbxlineprop,'Value');
if ckval,
  udtag=get(hs.lpoarea_prim_rdtagorder,'UserData');
  udord=get(hs.lpoarea_prim_rdorderorder,'UserData');
  LP.Property.LineProperty.TAG=udtag;
  LP.Property.LineProperty.ORDER=udord;
else
  % --> Add for Delete Line Property : 2007.03.25/shoji
  if isfield(LP,'Property') && isfield(LP.Property,'LineProperty')
    LP.Property=rmfield(LP.Property,'LineProperty');
  end
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LineProp_Callback(obj,hs)
str=get(obj,'String');
% Line Color Set from pushbutton
if isempty(str),
  val=uisetcolor(get(hs.lpoarea_prim_btncolor,'BackgroundColor'));
  % Button Color Set
  set(hs.lpoarea_prim_btncolor,'BackgroundColor',val);
  % Line Color Set
  chd=get(hs.lpoarea_prim_axespreview,'Children');
  set(chd,'Color',val);
% Line Style or Marker Set from popupmenu
else
  switch str{1}
    % Maker Style Set
    case 'none'
      val=get(hs.lpoarea_prim_popmarker,'Value');
      str=get(hs.lpoarea_prim_popmarker,'String');
      chd=get(hs.lpoarea_prim_axespreview,'Children');
      set(chd,'Marker',str{val});
    % Maker Style Size Set
    case '1'
      val=get(hs.lpoarea_prim_popmarkersize,'Value');
      str=get(hs.lpoarea_prim_popmarkersize,'String');
      chd=get(hs.lpoarea_prim_axespreview,'Children');
      set(chd,'MarkerSize',str2num(str{val}));
    %Line Style Set
    case '-'
      val=get(hs.lpoarea_prim_popstyle,'Value');
      str=get(hs.lpoarea_prim_popstyle,'String');
      chd=get(hs.lpoarea_prim_axespreview,'Children');
      set(chd,'LineStyle',str{val});
    %Line Style Size Set
    case '1/8'
      val=get(hs.lpoarea_prim_popstylesize,'Value');
      str=get(hs.lpoarea_prim_popstylesize,'String');
      chd=get(hs.lpoarea_prim_axespreview,'Children');
      set(chd,'LineWidth',str2num(str{val}));
    otherwise
      return;
  end
end
set(hs.lpoarea_prim_axespreview,'Children',chd);
prop=getLineProp(hs);
ival=get(hs.lpoarea_prim_rdtagorder,'Value');
if ival,
  val=get(hs.lpoarea_prim_listorder,'Value');
  ud=get(hs.lpoarea_prim_rdtagorder,'Userdata');
  ud(val).Property=prop;
  set(hs.lpoarea_prim_rdtagorder,'Userdata',ud);
  setappdata(hs.figure1,'CurrentLPOischange',true);
else,
  val=str2num(get(hs.lpoarea_prim_edtorder,'String'));
  ud=get(hs.lpoarea_prim_rdorderorder,'Userdata');
  ud{val}=prop;
  set(hs.lpoarea_prim_rdorderorder,'Userdata',ud);
  setappdata(hs.figure1,'CurrentLPOischange',true);
end
return;

function out=getLineProp(hs)
chd=get(hs.lpoarea_prim_axespreview,'Children');
props=LinePropKind;
proplen=length(props);
out=cell(1,proplen*2);
for idx=1:proplen
  out{2*idx-1}=props{idx};
  out{2*idx}=get(chd,props{idx});
end
return;

function setLineProp(hs,prop),
chd=get(hs.lpoarea_prim_axespreview,'Children');
proplen=length(prop);
for idx=1:2:proplen
  set(chd,prop{idx},prop{idx+1})
end
set(hs.lpoarea_prim_axespreview,'Children',chd);
return;

function out=LinePropKind
out={'Color','Marker','MarkerSize','LineStyle','LineWidth'};
return;

function Addbtn_Callback(hs),
nstr=get(hs.lpoarea_prim_edtorder,'String');
sstr=get(hs.lpoarea_prim_listorder,'String');
% Input Check (Null Input -> mesgbox)
if isempty(nstr),
  msgbox('Please Input character! Can''t Add to List!!','Input Error','warn');
  val=get(hs.lpoarea_prim_listorder,'Value');
  set(hs.lpoarea_prim_edtorder,'String',sstr{val});
  return;
end
val=sum(strcmp(nstr,sstr));
if val,
  msgbox('Input TAG exists a list. Please Input Other TAG','Input Error','warn');
  return;
end

% New Prop Set
ud=get(hs.lpoarea_prim_rdtagorder,'UserData');
udlen=length(ud);
aprop={'Color',[1 0 1],...
  'Marker','>',...
  'MarkerSize',6,...
  'LineStyle','-',...
  'LineWidth',1.0};
ud(udlen+1).Name=nstr;
ud(udlen+1).Property=aprop;
set(hs.lpoarea_prim_listorder,'String',{sstr{:},nstr});
set(hs.lpoarea_prim_listorder,'Value',udlen+1);
set(hs.lpoarea_prim_rdtagorder,'UserData',ud);
setappdata(hs.figure1,'CurrentLPOischange',true);
Listbox_Callback(hs.lpoarea_prim_listorder,hs);

return;

function Deletebtn_Callback(hs),
val=get(hs.lpoarea_prim_listorder,'Value');
ud=get(hs.lpoarea_prim_rdtagorder,'Userdata');
ud(val)=[];
str={ud.Name};
if length(ud) < val,val=length(ud);end
set(hs.lpoarea_prim_listorder,'Value',val);
set(hs.lpoarea_prim_listorder,'String',str);

% Set Userdata & Lineprop
set(hs.lpoarea_prim_rdtagorder,'Userdata',ud);
setappdata(hs.figure1,'CurrentLPOischange',true);
Listbox_Callback(hs.lpoarea_prim_listorder,hs);

return;

function Listbox_Callback(obj,hs),
% Delete Button Control
val=get(obj,'Value');
sstr=get(hs.lpoarea_prim_listorder,'String');
if isempty(sstr),
  ustr=get(hs.lpoarea_prim_rdtagorder,'UserData');
  sstr={ustr.Name};
end
set(hs.lpoarea_prim_edtorder,'String',sstr{val});
% Line Property Set
Lineprop_Setting(hs);
% Delete Control
if val < 4,
  set(hs.lpoarea_prim_btndelorder,'Enable','off');
  return;
else
  set(hs.lpoarea_prim_btndelorder,'Enable','on');
end
return;

function PlusMinus_Callback(obj,hs),
str=get(obj,'String');
val=str2num(get(hs.lpoarea_prim_edtorder,'String'));
ud=get(hs.lpoarea_prim_edtorder,'Userdata');
if strcmp(str,'+'),
  val=val+1;
else,
  val=val-1;
end
if val < ud.min,val=ud.min;end
if val > ud.max,val=ud.max;end
set(hs.lpoarea_prim_edtorder,'String',val)
Lineprop_Setting(hs);
return;