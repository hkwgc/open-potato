function varargout=Lparts_AreaTgl_Variables(fnc,varargin)
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
% $Id: Lparts_AreaTgl_Variables.m 180 2011-05-19 09:34:28Z Katura $

%================
% History
%================
% Revision 1.7
%   Bugfix : // modify definition of Default-Value of Data
%   Meeting on 19-Oct-2007 (Fri)
%   Changed on 22-Oct-2007 (Mon)

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
hs.lpoarea_tglbtn(2)=uicontrol(...
  hs.figure1,...
  'Units','pixels',...
  'Style','Togglebutton',...
  'String','Variables',...
  'Position',[502,399,60,20],...
  'Callback',...
  'Lparts_Area(''Tglchange'',gcbo,guidata(gcbf));'...
  );
%-------------------------------
% Text Tag Set
%-------------------------------
Areamenu_Row=2;
Areamenu_Ldiv=15;
Areamenu_Cdiv=4;
Areamenu_Now=Areamenu_Cdiv*(Areamenu_Row-1);
hs.lpoarea_vari_txtstyle=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+2,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Style');
hs.lpoarea_vari_txtrpos=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+3,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Relative-Pos');
hs.lpoarea_vari_txtdval=subuicontrol(hs.figure1,...
  Areamenu_Ldiv,Areamenu_Cdiv,Areamenu_Now+4,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Default Value');

% Make Control GUI
hs=MakeControl(hs,Areamenu_Row);

% Suspend This Property
Suspend(hs);
set(hs.lpoarea_tglbtn(2),'Visible','off');

function hs=MakeControl(hs,endrow)

[str, ud]=getControlList;

% Make Index Text
coldiv=6;
rowdiv=14;
for idx=1:length(str),
  hs.lpoarea_vari_txtidx(idx)=subuicontrol(hs.figure1,...
    rowdiv,coldiv,coldiv*(endrow+idx-1)+1,'Inner',...
    'Style','Text',...
    'HorizontalAlignment','left',...
    'String',str(idx));
end

% Make CheckBox
coldiv=20;
rowdiv=15.5;
for idx=1:length(str),
  hs.lpoarea_vari_chkidx(idx)=subuicontrol(hs.figure1,...
    rowdiv,coldiv,coldiv*(endrow+idx-1)+5,'Inner',...
    'Style','checkbox',...
    'Callback',...
    'Lparts_AreaTgl_Variables(''Vparts_control'',gcbf,gcbo,guidata(gcbf));'...
    );
end

% Make Popupmenu 
rowdiv=15;
coldiv=4;
for idx=1:length(str),
  hs.lpoarea_vari_popidx(idx)=subuicontrol(hs.figure1,...
    rowdiv,coldiv,coldiv*(endrow+idx-1)+2,'Inner',...
    'Style','popupmenu',...
    'HorizontalAlignment','left',...
    'String',{'None',ud{idx}.uicontrol{:,:}},...
    'BackgroundColor',[1, 1, 1],...
    'Userdata',1,...
    'Value',1,...
    'Callback',...
    'Lparts_AreaTgl_Variables(''Vpopup_control'',gcbo,guidata(gcbf));'...
    );
end

% Make Relative-pos
for idx=1:length(str),
  hs.lpoarea_vari_edtidx(idx)=subuicontrol(hs.figure1,...
    rowdiv,coldiv,coldiv*(endrow+idx-1)+3,'Inner',...
    'Style','Edit',...
    'HorizontalAlignment','left',...
    'String','0.00  0.00  1.00  1.00',...
    'BackgroundColor',[1, 1, 1],...
    'Callback',...
    'Lparts_AreaTgl_Variables(''Rpos_control'',gcbo,guidata(gcbf));');
end

% Make Default Value
for idx=1:length(str),
  hs.lpoarea_vari_btnidx(idx)=subuicontrol(hs.figure1,...
    rowdiv,coldiv,coldiv*(endrow+idx-1)+4,'Inner',...
  'Style','pushbutton',...
  'HorizontalAlignment','center',...
  'String','Set',...
  'Callback',...
  'Lparts_AreaTgl_Variables(''Input_ctrl_defval'',gcbo,guidata(gcbf));');
end
return;

function h=subhandle(hs)
% Sub-Handles
h=[...
    hs.lpoarea_vari_txtstyle;...
    hs.lpoarea_vari_txtrpos;...
    hs.lpoarea_vari_txtdval;...
    hs.lpoarea_vari_txtidx(:);...
    hs.lpoarea_vari_chkidx(:);...
    hs.lpoarea_vari_popidx(:);...
    hs.lpoarea_vari_edtidx(:);...
    hs.lpoarea_vari_btnidx(:);...
  ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');
% for id=1:length(hs.lpoarea_vari_chkidx),
%   set(hs.lpoarea_vari_chkidx(id),'Value',0);
% end

function Activate(hs)
% Activate
set(subhandle(hs),'Visible','on');
% CheckBox -> on  ... Visible on
% CheckBox -> off ... Visible off
for id=1:length(hs.lpoarea_vari_chkidx),
  if (get(hs.lpoarea_vari_chkidx(id),'Value') == 0),
    set(hs.lpoarea_vari_popidx(id),'Visible','off');
    set(hs.lpoarea_vari_edtidx(id),'Visible','off');
    set(hs.lpoarea_vari_btnidx(id),'Visible','off');
  else
    val=get(hs.lpoarea_vari_popidx(id),'Value');
    str=get(hs.lpoarea_vari_popidx(id),'String');
    if((strcmp(str(val),'menu') == 1) || ...
        (strcmp(str(val),'None') == 1)),
      set(hs.lpoarea_vari_edtidx(id),'Visible','off');
    else
      set(hs.lpoarea_vari_edtidx(id),'Visible','on');
    end
  end
end

function Vparts_control(fig,obj,hs)
clkidx=find(hs.lpoarea_vari_chkidx == obj);
nowval=get(obj,'Value');
setappdata(fig,'CurrentLPOischange',true);
if(nowval == 1),
  set(hs.lpoarea_vari_popidx(clkidx),'Visible','on');
  val=get(hs.lpoarea_vari_popidx(clkidx),'Value');
  Vpopup_control(hs.lpoarea_vari_popidx(clkidx),hs);
  set(hs.lpoarea_vari_btnidx(clkidx),'Visible','on');
elseif(nowval == 0),
  set(hs.lpoarea_vari_popidx(clkidx),'Visible','off');
  set(hs.lpoarea_vari_edtidx(clkidx),'Visible','off');
  set(hs.lpoarea_vari_btnidx(clkidx),'Visible','off');  
  Lparts_Manager('saveAndTreeAndOV',hs);
end
return;

function Vpopup_control(obj,hs)
clkidx=find(hs.lpoarea_vari_popidx == obj);
oldval=get(obj,'Userdata');
nowval=get(obj,'Value');
nowstr=get(obj,'String');
if((strcmp(nowstr(nowval),'menu') == 1) || ...
    (strcmp(nowstr(nowval),'None') == 1)),
  set(hs.lpoarea_vari_edtidx(clkidx),'Visible','off');
else
  set(hs.lpoarea_vari_edtidx(clkidx),'Visible','on');
end
if ~(oldval == nowval),
  set(obj,'Userdata',nowval);
  Lparts_Manager('saveAndTreeAndOV',hs);
  setappdata(hs.figure1,'CurrentLPOischange',true);
end
Lparts_Manager('saveAndTreeAndOV',hs);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================

%----------------------------
% Initialize
%----------------------------
% CObject Value
set(hs.lpoarea_vari_chkidx,'Value',0);
% Popup Value
set(hs.lpoarea_vari_popidx,'Value',1);
% Position
set(hs.lpoarea_vari_edtidx,...
  'String','0.00 0.00 1.00 1.00',...
  'Userdata',[0.00, 0.00, 1.00, 1.00],...
  'Visible','off');
% (other Initialization : See also Activate)
% I think it is better to move Above Initialization here...

%-----------------------------
% CObject Setting
%-----------------------------
pos=[];
str=getFunclist;
fnclst=getFunclist;
if isfield(LP,'CObject'),
  for idx=1:length(LP.CObject)
    % User Data Set
    strid=find(strcmp(LP.CObject{idx}.fnc,str));
    % expand loop: 2007.04.03 : shoji
    % -- is Common CObject? --
    if isempty(strid),continue;end
    strid=strid(1); % <<== Confine 1 (Must be 1)
    
    % - - - - - - - - - - - - - - -
    % set Position Value
    % - - - - - - - - - - - - - - -
    set(hs.lpoarea_vari_chkidx(strid),'Value',1);
    if isfield(LP.CObject{idx},'Position'),
      pos=LP.CObject{idx}.Position;
    elseif isfield(LP.CObject{idx},'position'),
      pos=LP.CObject{idx}.position;
    elseif isfield(LP.CObject{idx},'pos'),
      pos=LP.CObject{idx}.pos;
    end
    % Bug fix : 2007.04.03 : shoji
    set(hs.lpoarea_vari_edtidx(strid),...
      'String',num2str(pos,'%4.2f  '),...
      'Userdata',pos);
    
    % - - - - - - - - - - - - - - -
    % set Popup Value
    % - - - - - - - - - - - - - - -
    popstr=LP.CObject{idx}.SelectedUITYPE;
    popall=get(hs.lpoarea_vari_popidx(strid),'String');
    popid=find(strcmp(popstr,popall));
    % expand loop: 2007.04.03 : shoji
    if isempty(popid),
      warning('Unsupoerted uiStyle in Layout %s',popstr);
    end
    popid=popid(1); % <<== Confine 1 (Must be 1)
    set(hs.lpoarea_vari_popidx(strid),'Value',popid);
  end % CObject Loop
end % CObject Setting

%-----------------------------
% set Default Value
%-----------------------------
if isfield(LP,'Property'),
  %-----------------------------
  % set Select Data
  %-----------------------------
  if isfield(LP.Property,'SelectData'),
    % Bug fix : 2007.03.26 : shoji
    LP.Property.SelectData{2}=num2str(LP.Property.SelectData{2});
    LP.Property.SelectData{3}=num2str(LP.Property.SelectData{3});
    set(hs.lpoarea_vari_btnidx(1),'Userdata',LP.Property.SelectData);
    set(hs.lpoarea_vari_chkidx(1),'Value',1);
  else,
    set(hs.lpoarea_vari_btnidx(1),'Userdata',{'Auto';'1';'1'});
  end
  %-----------------------------
  % set Channel
  %-----------------------------
  if isfield(LP.Property,'Channel'),
    set(hs.lpoarea_vari_btnidx(2),'Userdata',{num2str(LP.Property.Channel)});
    set(hs.lpoarea_vari_chkidx(2),'Value',1);
  else,
    set(hs.lpoarea_vari_btnidx(2),'Userdata',{'1'});
  end
  %-----------------------------
  % set DataKind
  %-----------------------------
  if isfield(LP.Property,'DataKind'),
    set(hs.lpoarea_vari_btnidx(3),'Userdata',{num2str(LP.Property.DataKind)});
    set(hs.lpoarea_vari_chkidx(3),'Value',1);
  else,
    set(hs.lpoarea_vari_btnidx(3),'Userdata',{['1,2']});
  end
else
  set(hs.lpoarea_vari_btnidx(1),'Userdata',{'Auto';'1';'1'});
  set(hs.lpoarea_vari_btnidx(2),'Userdata',{'1'});
  set(hs.lpoarea_vari_btnidx(3),'Userdata',{['1,2']});
end

%=============================
function LP=getParts(hs,LP)
% Getter of Layout-Parts to GUI (5)
%=============================
[str, ud, fl]=getControlList;
fnclst=getFunclist;
%-----------------------------
% Property Setting
% Property Init
%-----------------------------
if isfield(LP,'Property')
  if isfield(LP.Property,'SelectData'),LP.Property=rmfield(LP.Property,'SelectData');end
  if isfield(LP.Property,'Channel'),LP.Property=rmfield(LP.Property,'Channel');end
  if isfield(LP.Property,'DataKind'),LP.Property=rmfield(LP.Property,'DataKind');end
end
%-----------------------------
% CObject Init
%-----------------------------
if isfield(LP,'CObject'),
  delidx=[];
  for idx=1:length(LP.CObject)
    for strid=1:length(fnclst)
      if strcmp(LP.CObject{idx}.fnc,fnclst{strid}),
        delidx(end+1)=idx;
      end
    end
  end
  LP.CObject(delidx)=[];
end

%-----------------------------
% Add CObject & Get Userdata
%-----------------------------
for idx=1:length(str)
  %- - - - - - -
  % checkbox off -> next CObject
  %- - - - - - -
  if ~get(hs.lpoarea_vari_chkidx(idx),'Value'),continue;end

  %- - - - - - -
  % get Default Value from Userdata(Button)
  %- - - - - - -
  btndata=[];
  btndata=get(hs.lpoarea_vari_btnidx(idx),'Userdata');
  if idx == 1,
    LP.Property.SelectData=btndata;
    LP.Property.SelectData{2}=str2num(LP.Property.SelectData{2});
    LP.Property.SelectData{3}=str2num(LP.Property.SelectData{3});
  elseif idx == 2,
    LP.Property.Channel=str2num(btndata{:});
  elseif idx == 3,
    LP.Property.DataKind=str2num(btndata{:});
  end

  %- - - - - - -
  % get popup Value
  %- - - - - - -
  val=get(hs.lpoarea_vari_popidx(idx),'Value');
  popall=get(hs.lpoarea_vari_popidx(idx),'String');
  popstr=popall{val};
  %- - - - - - -
  % popup style -> None ... next CObject
  %- - - - - - -
  if strcmp(popstr,'None'),continue;end
  
  %- - - - - - -
  % Make CObject (getaugument)
  %- - - - - - -
  cobj=feval(fl{idx},'getDefaultCObject');
  %- - - - - - -
  % popup style set
  %- - - - - - -
  cobj.SelectedUITYPE=popstr;
  cobj.uicontrol={ud{idx}.uicontrol{:,:}};
  %- - - - - - -
  % position set
  %- - - - - - -
  posdat=get(hs.lpoarea_vari_edtidx(idx),'Userdata');
  cobj.pos=posdat;
  %- - - - - - -
  % set CObject
  %- - - - - - -
  if isfield(LP,'CObject'),
    LP.CObject{end+1}=cobj;
  else
    LP.CObject={cobj};
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=getAllControl
out={'Data','Channel','Kind','TimeRange','TimePoint'};
return;

function out=getFunclist
out={'osp_ViewCallbackC_Data', ...
  'osp_ViewCallbackC_Channel', ...
  'osp_ViewCallbackC_DataKind', ...
  'osp_ViewCallbackC_TimePoint'...
  };
return;

function [str,ud,fncout]=getControlList
ctrlist=getAllControl;
fnc=getFunclist;
% - get data -
% info.uicontrol={'checkbox','listbox','radiobutton',...
% 'togglebutton', ...
% 'edit','popupmenu','slider', ...
% 'frame', ...
% 'pushbutton','text'};
ud={};
str={};
fncout={};
try
  for idx=1:length(fnc),
    try
      if ~exist(fnc{idx},'file'),continue;end
      info  = feval(fnc{idx}, 'createBasicInfo');
      u0    = info;
      s0    = info.name;
      if isfield(info,'uicontrol'),
        % if success to get all data
        [ud{end+1}, str{end+1}] = ...
          deal(u0,s0);
        fncout{end+1}=fnc{idx};
      else
        error([ s0 ': No Uicontrol Exist!!']);
      end
    catch
      % Now allow Error
      % warning(lasterr);
    end
  end
end

%=============================
% Default Value Setting (Area-Control)
%=============================
function Input_ctrl_defval(obj,hs)
% Search pushbutton's idx
nowidx=find(hs.lpoarea_vari_btnidx == obj);
nowstr=get(hs.lpoarea_vari_txtidx(nowidx),'String');

oldval=get(hs.lpoarea_vari_btnidx(nowidx),'userdata');

%------------------
% Make Input Dialog
%------------------
if strcmp(nowstr,'Select Data'),
  prompt={'Region ( ''Auto'' or ''Continuous'')';...
    'Continuous Data ID';...
    'Block ID'};
else
  prompt={'Default Value '};
end
if isempty(oldval),oldval={''};end

def=oldval;
dlgTitle=['Setting at ',nowstr{:}];
lineNo=1;
val=inputdlg(prompt,dlgTitle,lineNo,def);

% Cancel
if isempty(val),return;end

% Check is modify ?
%  --> use isequal (shoji)
flg=0;
for id=1:length(val),
  if strcmp(val{id},oldval{id}) == 0,
    flg=1;
    break;
  end
end

% if Modify, Set-Change Flag
if flg,
  set(hs.lpoarea_vari_btnidx(nowidx),'userdata',val);
  setappdata(hs.figure1,'CurrentLPOischange',true);
end
return;

function Rpos_control(obj,hs)
% get(hs.lpoarea_vari_edt)
idx=find(obj==hs.lpoarea_vari_edtidx);
posstr=get(hs.lpoarea_vari_edtidx(idx),'String');
pos=str2num(posstr);
if ~length(pos)==4,
  return;
end
oldpos=get(hs.lpoarea_vari_edtidx(idx),'Userdata');
flg=0;
for id=1:length(pos),
  if ~(pos(id) == oldpos(id)),
    flg=1;
    break;
  end
end
if flg,
  set(hs.lpoarea_vari_edtidx(idx),'Userdata',pos);
  Lparts_Manager('saveAndTreeAndOV',hs);
  setappdata(hs.figure1,'CurrentLPOischange',true);
end
return;