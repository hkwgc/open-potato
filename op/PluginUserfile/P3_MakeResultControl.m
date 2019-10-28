function varargout = P3_MakeResultControl(varargin)
% data=P3_MAKERESULTCONTROL('Property',Value,...);
%  Open Result-Control Draw-Setting Window, and
%  return data, structure discribed Result-Draw-Setting.
%
% --- Available Property --
%  DefaultValue   :
%     Defalut value of Result-Draw-Setting Structure.
%
% See also: GUIDE, GUIDATA, GUIHANDLES,
%           P3_wizard_plugin_P_Foption,
%           osp_ViewAxesObj_DrawResult.

% Last Modified by GUIDE v2.5 10-Jan-2008 10:53:21


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launcher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_MakeResultControl_OpeningFcn, ...
  'gui_OutputFcn',  @P3_MakeResultControl_OutputFcn, ...
  'gui_LayoutFcn',  [] , ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Launcher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Window I/O Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P3_MakeResultControl_OpeningFcn(hObject, e, handles, varargin)
% Set Default-Value & wait for User-Responce
if 0,disp(e);end

handles.output = [];

%--------------------
% get Argument
%--------------------
if(nargin > 3)
  msg={};
  for index = 1:2:(nargin-3),
    if nargin-3==index, break, end
    if ~ischar(varargin{index}),
      msg{end+1}=sprintf('Property Name Must be String');
      continue;
    end
    switch varargin{index}
      case 'DefaultValue'
        %--------------------
        % set Default Value
        %--------------------
        setDefaultValue(handles,varargin{index+1});
      otherwise
        % Make Error Messange
        msg{end+1}=sprintf('Unknown Property : %s',varargin{index});
    end
  end

  %--------------------
  % Popup Warning Dialog
  %--------------------
  if ~isempty(msg)
    wh=warndlg(msg);
    waitfor(wh);
  end
end

%------------------------
% Wait for user response
%------------------------
% Update handles structure
guidata(hObject, handles);
% waiting...
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);
if 0,
  figure1_CloseRequestFcn;
  figure1_KeyPressFcn;
  setDefaultValue;
end


function figure1_CloseRequestFcn(h, e, hs)
% Close with Cancel
if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
if 0,disp(h);disp(e);end

function figure1_KeyPressFcn(h, e, hs)
% When Escape Key Press, Close figure.
key=get(h,'CurrentKey');
switch lower(key)
  case 'escape'
    % Close Figure with "" Cancel ""
    if isequal(get(h, 'waitstatus'), 'waiting')
      uiresume(h);
    else
      delete(h);
    end
end
if 0,disp(e);disp(hs);end

function varargout = P3_MakeResultControl_OutputFcn(h, e, hs)
% Get default command line output from handles structure
varargout{1} = hs.output;
% The figure can be deleted now
delete(hs.figure1);
if 0,disp(h);disp(e);end
if 0,
  % output data : See also
  psb_ok_Callback;
  pushbutton2_Callback
end


%==========================================================================
function psb_ok_Callback(h, e, hs)
% Gather Result and resume.
%==========================================================================

%===================
% Gather Result
%===================
% get Name
name=get(hs.edt_Name,'String');
if ~isvarname(name)
  errordlg('Result-Data Name is not Variable-Name');
  return;
end
%  Initialize Data
if ~isempty(hs.output)
  data=hs.output;
end
data.name=name;

% get Draw-Function
[data,msg]=getDrawString(hs,data);
if msg,errordlg(msg);return;end
% get Draw-Function
[data,msg]=getDrawFunction(hs,data);
if msg,errordlg(msg);return;end
% get Control Data
[data,msg]=getControl(hs,data);
if msg,errordlg(msg);return;end
%--------------------
% Set up Output-Data
%--------------------
hs.output = data;
guidata(hs.figure1, hs);

%===================
% Resume
%===================
uiresume(hs.figure1);
if 0,disp(h);disp(e);end

%==========================================================================
function pushbutton2_Callback(h, e, hs)
% Cancel Button
%==========================================================================
hs.output = [];
guidata(hs.figure1, hs);
uiresume(hs.figure1);
if 0,disp(h);disp(e);end

%==========================================================================
function setDefaultValue(hs,data)
% Set Default-Value
%==========================================================================
hs.output = data;
guidata(hs.figure1, hs);
msg={};
try
  set(hs.edt_Name,'String',data.name);
catch
  msg{end+1}=' Data Name is wrong';
end
% set Draw-Function
msg0=setDrawString(hs,data);
if msg0,msg{end+1}=msg0;end
% set Draw-Function
msg0=setDrawFunction(hs,data);
if msg0,msg{end+1}=msg0;end
% set Control Data
msg0=setControl(hs,data);
if msg0,msg{end+1}=msg0;end

% ==================
% Warning Messanges
% ==================
if ~isempty(msg)
  wh=warndlg(msg,'Default-Data Setting');
  waitfor(wh);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edt_Name_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Setting Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function [data,msg]=getDrawString(hs,data)
% Get Draw String
%==========================================================================
msg='';
v=get(hs.pop_DS,'Value');
switch v
  case 1
    % Data Name
    n=0;
    if get(hs.ckb_DS_X,'Value')
      n=n+1;
      data.DataName.X=get(hs.edt_DS_X,'String');
    end
    if get(hs.ckb_DS_Y,'Value')
      n=n+1;
      data.DataName.Y=get(hs.edt_DS_Y,'String');
    end
    if get(hs.ckb_DS_Z,'Value')
      n=n+1;
      data.DataName.Z=get(hs.edt_DS_Z,'String');
    end
    if n==0
      data=[];
      msg='No Data to determin Data(X,Y,Z)';
    end

  case 2
    s=get(hs.edt_DS_Script,'String');
    if iscell(s),s=strcat(s{:});end
    data.DataString=s;
    
  otherwise
    data=[];msg='Un Defined Data-Setting Mode';
end

%==========================================================================
function msg=setDrawString(hs,data)
% Set Draw String
%==========================================================================
msg='';
if isfield(data,'DataString')
  set(hs.pop_DS,'Value',2);
  if iscell(data.DataString)
    set(hs.edt_DS_Script,'String',data.DataString);
  else
    if size(data.DataString,1)>=2
      set(hs.edt_DS_Script,'String',cellstr(data.DataString));
    else
      set(hs.edt_DS_Script,'String',{data.DataString});
    end
  end
elseif isfield(data,'DataName')
  set(hs.pop_DS,'Value',1);
  if isfield(data.DataName,'X')
    set(hs.ckb_DS_X,'Value',1);
    set(hs.edt_DS_X,'String',data.DataName.X);
  end
  if isfield(data.DataName,'Y')
    set(hs.ckb_DS_Y,'Value',1);
    set(hs.edt_DS_Y,'String',data.DataName.Y);
  end
  if isfield(data.DataName,'Z')
    set(hs.ckb_DS_Z,'Value',1);
    set(hs.edt_DS_Z,'String',data.DataName.Z);
  end
else
  msg='Undefined Data-Setting Mode';
end
pop_DS_Callback(hs.pop_DS,[],hs)

%==========================================================================
function pop_DS_Callback(h,e,hs)
% Change Visible of Children
%==========================================================================

% All control visible off
hs_Name  =[hs.ckb_DS_X,hs.ckb_DS_Y,hs.ckb_DS_Z,...
  hs.edt_DS_X,hs.edt_DS_Y,hs.edt_DS_Z];
hs_Script=[hs.edt_DS_Script,hs.txt_DS_Script];
set([hs_Name,hs_Script],'Visible','off');

% Selected control visible on
v=get(h,'Value');
switch v
  case 1
    set(hs_Name,'Visible','on');
  case 2
    set(hs_Script,'Visible','on');
  otherwise
end
if 0,disp(e);end

%==========================================================================
% DS : Name
%==========================================================================
function ckb_DS_X_Callback(h,e,hs)
function ckb_DS_Y_Callback(h,e,hs)
function ckb_DS_Z_Callback(h,e,hs)
function edt_DS_X_Callback(h,e,hs)
function edt_DS_Z_Callback(h,e,hs)
function edt_DS_Y_Callback(h,e,hs)

%==========================================================================
% DS : Script
%==========================================================================
function edt_DS_Script_Callback(h,e,hs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function [data,msg]=getDrawFunction(hs,data)
% get Draw Function
%==========================================================================
msg='';
v=get(hs.pop_DF,'Value');
switch v
  case 1
    % Data-Type
    s=get(hs.pop_DF_type,'String');
    data.DrawType=s{get(hs.pop_DF_type,'Value')};
  case 2
    % Draw-String
    s=get(hs.edt_DF_Script,'String');
    if iscell(s),s=strcat(s{:});end
    data.DrawString=s;
  otherwise
    msg='Undefined Draw-Function';
    data=[];
end

%==========================================================================
function msg=setDrawFunction(hs,data)
% Set Draw Function
%==========================================================================
msg='';
if isfield(data,'DrawString')
  set(hs.pop_DF,'Value',2);
  if iscell(data.DrawString)
    s=data.DrawString;
  else
    if size(data.DrawString,1)>=2
      s=cellstr(data.DrawString);
    else
      s={data.DrawString};
    end
  end
  set(hs.edt_DF_Script,'String',s);
elseif isfield(data,'DrawType'),
  set(hs.pop_DF,'Value',1);
  s=get(hs.pop_DF_type,'String');
  v=find(strcmpi(s,data.DrawType));
  if ~isempty(v), set(hs.pop_DF_type,'Value',v); end
else
  msg='Undefined Draw-Function';
end
pop_DF_Callback(hs.pop_DF,[],hs);
%==========================================================================
function pop_DF_Callback(h,e,hs)
% Change Visible of Children
%==========================================================================

% All control visible off
hs_type  =[hs.pop_DF_type];
hs_Script=[hs.edt_DF_Script,hs.txt_DF_Script];
set([hs_type,hs_Script],'Visible','off');

% Selected control visible on
v=get(h,'Value');
switch v
  case 1
    set(hs_type,'Visible','on');
  case 2
    set(hs_Script,'Visible','on');
  otherwise
end
if 0,disp(e);end

%==========================================================================
% DF : Fixed Function
%==========================================================================
function pop_DF_type_Callback(h,e,hs)

%==========================================================================
% DF : Script
%==========================================================================
function edt_DF_Script_Callback(h,e,hs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,msg]=getControl(hs,data)
% get Control
msg='';
lctrl=get(hs.lbx_CTRL,'UserData');
if ~isempty(lctrl)
  data.Control=lctrl;
end
function msg=setControl(hs,data)
% set Control
msg='';
if isfield(data,'Control')
  str={};
  lctrl=data.Control;
  for idx=1:length(lctrl)
    ctrl=lctrl{idx};
    str{idx} =sprintf('%s\t:%s',ctrl.varname,ctrl.mode);
  end
  set(hs.lbx_CTRL,'UserData',lctrl,'String',str);
  lbx_CTRL_Callback(hs.lbx_CTRL,[],hs);
end

function ctrl=getCtrl(hs)
% Get Ctrol-Data from GUI

% Name 
ctrl.varname =get(hs.edt_CTRL_Name,'String');
% Check
if ~isvarname(ctrl.varname)
  ctrl=[];
  errordlg({'Error : ',' Control Name is not Varialble Name'},...
    'Control-Setting Error');
  return;
end

% Type : 
type0=get(hs.pop_CTRL_Type,'String');
ctrl.mode=type0{get(hs.pop_CTRL_Type,'Value')};

% Value String : 
tmp     =get(hs.edt_CTRL_Value,'String');
ctrl.variable.tmp=tmp;
ctrl.variable.val=eval(tmp,'[];');
if isempty(ctrl.variable.val)
  ctrl=[];
  errordlg({'Value Error:','Value is empty'},...
    'Control-Setting Error');
  return;
end
if ~iscell(ctrl.variable.val)
  ctrl.variable.val={ctrl.variable.val};
end
ctrl.variable.str=cell(1,length(ctrl.variable.val));
for idx=1:length(ctrl.variable.val)
  try
    if isnumeric(ctrl.variable.val{idx})
      ctrl.variable.str{idx}=num2str(ctrl.variable.val{idx}(1));
    else
      ctrl.variable.str{idx}=ctrl.variable.val{idx};
    end
  catch
    ctrl.variable.str{idx}=sprintf('%d : Data',idx);
  end
end
ctrl.DefaultValueString=sprintf('%s=''%s'';',...
  ctrl.varname,ctrl.variable.str{1});

% Get Position with Error-Check
[pos,msg]=get_CTRL_Position(hs);
if isempty(pos)
  ctrl=[];
  errordlg({'Position Error:',msg},...
    'Control-Setting Error');
  return;
end
ctrl.Position=pos;

function setCtrl(hs,ctrl)
% Set Ctrol-Data To GUI
set(hs.edt_CTRL_Name,'String',ctrl.varname);

v=strmatch(ctrl.mode,get(hs.pop_CTRL_Type,'String'));
if length(v)==1
  set(hs.pop_CTRL_Type,'Value',v);
end

if isfield(ctrl.variable,'tmp')
  s=ctrl.variable.tmp;
else
  s='{';
  for idx=1:length(ctrl.variable.str)
    s=[s '''' ctrl.variable.str{idx} ''','];
  end
  s(end)='}';
end
set(hs.edt_CTRL_Value,'String',s);

if isnumeric(ctrl.Position)
  s=num2str(ctrl.Position);
  set(hs.edt_CTRL_Position,'String',s);
  set(hs.pop_CTRL_Position,'Value',6); % <-- Array
else
  v=find(strcmpi(ctrl.Position,get(hs.pop_CTRL_Position,'String')));
  set(hs.pop_CTRL_Position,'Value',v);
end
pop_CTRL_Position_Callback(hs.pop_CTRL_Position,[],hs);

function lbx_CTRL_Callback(h,e,hs)
% Control-Listbox's Callback :
%   -- Select Control --
lctrl=get(h,'UserData');
v    =get(h,'Value');
if v>length(lctrl),return;end
setCtrl(hs,lctrl{v});
if 0,disp(e);end

function psb_CTRL_Add_Callback(h,e,hs)
% Add Control

% Get Control
ctrl=getCtrl(hs);
if isempty(ctrl),return;end
lctrl=get(hs.lbx_CTRL,'UserData');
str  =get(hs.lbx_CTRL,'String');
% Modify String & Add Control
str0 =sprintf('%s\t:%s',ctrl.varname,ctrl.mode);
if isempty(lctrl),
  lctrl={ctrl};
  str  ={str0};
else
  lctrl{end+1}=ctrl;
  str{end+1}  =str0;
end
% Update Control
set(hs.lbx_CTRL,'Value',length(str),'UserData',lctrl,'String',str);
if 0,disp(h);disp(e);end

function psb_CTRL_Change_Callback(h,e,hs)
% Change Control
% Get Control
ctrl=getCtrl(hs);
if isempty(ctrl),return;end
lctrl=get(hs.lbx_CTRL,'UserData');
v    =get(hs.lbx_CTRL,'Value');
if length(lctrl)<v,return;end

str  =get(hs.lbx_CTRL,'String');
% Modify String & Add Control
str0 =sprintf('%s\t:%s',ctrl.varname,ctrl.mode);
lctrl{v}=ctrl;
str{v}  =str0;

set(hs.lbx_CTRL,'UserData',lctrl,'String',str);
if 0,disp(h);disp(e);end

function psb_CTRL_Remove_Callback(h,e,hs)
% Remove Control

% get Current Control
h0 = hs.lbx_CTRL;
lctrl=get(h0,'UserData');
v    =get(h0,'Value');
if v>length(lctrl)
  errordlg('Conuld not Remove Empty Data');
  return;
end
% Remove Control
lctrl(v)=[];
str  =get(h0,'String');
str(v)=[];
% Update Control
if isempty(str),  str={'-- Empty --'}; end
if v>length(str), v=length(str);       end
set(h0,'Value',v,'UserData',lctrl,'String',str);
if 0,disp(h);disp(e);end

function edt_CTRL_Name_Callback(h,e,hs)
function edt_CTRL_Value_Callback(h,e,hs)
function pop_CTRL_Type_Callback(h,e,hs)

function [pos,msg]=get_CTRL_Position(hs)
% [pos,msg]=get_CTRL_Position(hs)
% Get Position of Control
%  get Control position
%  
msg='';
s=get(hs.pop_CTRL_Position,'String');
pos=s{get(hs.pop_CTRL_Position,'Value')};
if strcmpi(pos,'array')
  s=get(hs.edt_CTRL_Position,'String');
  s=str2num(s);
  if length(s)~=3,
    pos=[];msg='Position Need 3 Integer';
    return;
  end
  pos0=osp_ViewAxesObj_DrawResult('mat2pos',s(1),s(2),s(3));
  if min(pos0)<0 || max(pos0)>1
    pos=[];msg='Position Array is out of range';
    return;
  end
  pos=s;
end

function pop_CTRL_Position_Callback(h,e,hs)
% Check Visible on/off
s=get(h,'String');
if strcmpi(s{get(h,'Value')},'array')
  set(hs.edt_CTRL_Position,'Visible','on');
else
  set(hs.edt_CTRL_Position,'Visible','off');
end
if 0,disp(e);end

function edt_CTRL_Position_Callback(h,e,hs)
% Position Array : check Position-Array


