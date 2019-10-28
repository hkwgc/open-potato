function varargout = P3_uiFLAselect(varargin)
% P3_UIFLASELECT is Launch GUI for Selecting 1st-Lvl-Ana Data of P3.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% $Id: P3_uiFLAselect.m 180 2011-05-19 09:34:28Z Katura $

% Last Modified by GUIDE v2.5 22-Feb-2008 15:23:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3_uiFLAselect_OpeningFcn, ...
                   'gui_OutputFcn',  @P3_uiFLAselect_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Setting Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P3_uiFLAselect_OpeningFcn(hObject, ev, hs, varargin)
% Set Argument & Waiting for User-responce.
%  
% Opening function of this GUI.
hs.output  = {};
hs.figure1 = hObject;

if strcmpi(get(hs.pop_1stLvlFnc,'Visible'),'off')
  % sometiog wrong. (No 1st-Lvl-Ana Plugin exist)
  %     --> Close GUI at onece.
  errordlg({'No 1st-Level-Analysis Data'});
  hs.output={};guidata(hObject,hs); % Cancel
  return;
end

%========================================
% Set GUI Argument
%========================================

% TODO : Change Button _(..)_


%========================================
% 1st-Lvl-Ana Setting
%========================================
pop_1stLvlFnc_Callback(hs.pop_1stLvlFnc,ev,hs);


%========================================
% At the end... 
%   -> Start GUI! (^^:)
%========================================
% Update handles structure
guidata(hObject, hs);
ud=get(hs.pop_1stLvlFnc,'UserData');
% wait for user response (see UIRESUME)
if ~isempty(ud)
  uiwait(hs.figure1);
else
  errordlg({'No 1st-Level-Analysis Data'});
  hs.output={};guidata(hObject,hs); % Cancel
  %disp('Debugging Mode !! Do not wait for user-response');
end

%============================================================
function pop_1stLvlFnc_CreateFcn(h, e, hs)
% Search 1st-Level-Analysis Function & Setting Popupmenu
%============================================================

%-----------------------------
% Load Using 1st-Lvl-Ana Plugin
%-----------------------------
fl=DataDef2_1stLevelAnalysis('loadlist');
if isempty(fl),
  set(h,'Visible','off','UserData',[]);
  return;
end
fncs=unique({fl.function}); % Get Unique Function


str={};fnc={};
for idx=1:length(fncs)
  try
    % Getting Display Name.
    bi=feval(fncs{idx},'createBasicInfo');
    str{end+1}=bi.name;
    fnc{end+1}=fncs{idx};
  catch
    % Error Occur:
    disp(['[E] : Function : ' fncs{idx}]);
    disp( '      Could not read String..');
    disp(['      ' lasterr]);
  end
end

if isempty(str)
  errordlg('No 1st-Lvel-Analysis Plugin!');
  set(h,'Visible','off','UserData',[]);
else
  set(h,'Value',1,'String',str,'UserData',fnc,'Visible','on');
  pop_1stLvlFnc_Callback(0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI I/O Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = P3_uiFLAselect_OutputFcn(h,ev,hs)
% Get default command line output from handles structure
varargout{1} = hs.output;
if 1,
  % Ordinal (proper path)
  delete(hs.figure1);
else
  % Debugging path
  if isequal(get(hs.figure1,'waitstatus'),'waiting'),
    uiresume(hs.figure1);
  end
  warning('OUTPUT : Dug Mode is running');
end

%================================
function figure1_CloseRequestFcn(h,ev,hs)
% Close function with uiresume
% ==> is as sampe as OK Button
%================================
% 070420E : OK to Cancel
%psb_ok_Callback(h,ev,hs);
psb_cancel_Callback(h,ev,hs);

%================================
function psb_cancel_Callback(h,ev,hs)
% Cancel : Exit GUI with empty
%================================
hs.output={};guidata(hs.figure1,hs);
%---------
% Exit GUI
%---------
if isequal(get(hs.figure1,'waitstatus'),'waiting'),
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end

%================================
function psb_ok_Callback(h,ev,hs)
% OK : MakeGroup & Exit GUI.
%================================

%-------------
% Make Group
%-------------
%<-- getting Grou
hs.output={}; 
fcs=getappdata(hs.figure1,'FileControlStruct');
ics=getappdata(hs.figure1,'InnerControlStruct');
files=fcs.data(fcs.check);
if ~isempty(ics),
  ck=ics.check & ics.visible;
  key0=get(hs.pop_InnerKey,'String');
  key0=key0{get(hs.pop_InnerKey,'Value')};
end

for idx=length(files):-1:1
  wk.Files=files(idx);
  % TODO : Set Inner Data
  if ~isempty(ics),
    wk.Inner.Key=key0;
    wk.Inner.Val=ics.val(ck(idx,:));
  end
  tmp0(idx)=wk;
end

% Load Function
fnc=get(hs.pop_1stLvlFnc,'UserData');
fnc=fnc{get(hs.pop_1stLvlFnc,'Value')};

%--> assign to output data
tmp.function=fnc;
if exist('tmp0','var')
  tmp.groups=tmp0;
else
  tmp.groups.empty=[];
end
hs.output=tmp;
guidata(hs.figure1,hs);
%---------
% Exit GUI
%---------
if isequal(get(hs.figure1,'waitstatus'),'waiting'),
  uiresume(hs.figure1);
else
  disp('assign data named ''tmp''!');
  assignin('base','tmp',tmp)
  delete(hs.figure1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change -> 1st Lvel Plugin 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_1stLvlFnc_Callback(h, ev, hs)
% Making File/Key and so on..
persistent oldval;
if nargin==1,oldval=h;return;end

vl=get(h,'Value');
if isequal(vl,oldval),return;end
oldval=vl;
%=======================
% Load Files
%=======================
% 1st-Lvl-Ana Function (Wrapper)
fnc=get(h,'UserData');fnc=fnc{vl};
%=======================
% Setup SearchKey
%=======================
fname=DataDef2_1stLevelAnalysis('getLocalSearchKeyFileName',fnc);
load(fname,'SearchKey');
setappdata(hs.figure1,'SearchKey',SearchKey);

% Update File Search-Key
keys=fieldnames(SearchKey.F);
v=get(hs.pop_key1,'Value');
if v>length(keys),v=length(keys);end
set(hs.pop_key1,'Value',v,'String',keys);
pop_key1_Callback(hs.pop_key1,[],hs);

% Update Inner Search-Key
if isfield(SearchKey,'I')
  set(hs.psb_chmod,'Visible','on');
else
  set(hs.psb_chmod,'Visible','off');
end


%=======================
% Making File List
%=======================
fl=DataDef2_1stLevelAnalysis('loadlist');
usedata=fl(strcmpi({fl.function},fnc));
fcs=getappdata(hs.figure1,'FileControlStruct');
if isempty(fcs)
  fcs.num        = 0; % Number of Made.
  fcs.end        = 1; % File Index Start// not in use
  fcs.files      =[]; % Handle of File-Text
  fcs.checkboxes =[]; % Handle of Checkbox
end
fcs.start      = 1; % File Index Start
fcs.data       = usedata;
fcs.check      = true(length(usedata),1);
fcs.ID         = [usedata.ID];

ResetFileSelectScrollBar(hs,usedata);

% Make File handle
subuicontrol(get(hs.frm_files,'Position'));
for idx=(fcs.num+1):min(length(usedata),10)
  fcs.files(idx)=subuicontrol(hs.figure1,10,1,idx,1,'Inner',...
    'Style','Text','HorizontalAlignment','Right',...
    'TAG',sprintf('txt_%dthfile',idx));
end
% Make Checkbox handle
subuicontrol(get(hs.frm_checkboxes,'Position'));
for idx=(fcs.num+1):min(length(usedata),10)
  fcs.checkboxes(idx)=subuicontrol(hs.figure1,10,1,idx,1,'Inner',...
    'Style','Checkbox','HorizontalAlignment','Left','Value',1,...
    'TAG',sprintf('ckb_%dth_data',idx),...
    'UserData',idx,...
    'String','',...
    'Callback',...
    'P3_uiFLAselect(''SelectCheckbox'',gcbo,[],guidata(gcbf));');
end
fcs.num=min(length(usedata),10);
set([fcs.files(1:fcs.num);fcs.checkboxes(1:fcs.num)],'Visible','on');
setappdata(hs.figure1,'FileControlStruct',fcs);


%=======================
% Update Data
%=======================
ChangeFilePos(hs)

%=========================================
function ChangeFilePos(hs)
% Change File-Position and change view
%=========================================
fcs=getappdata(hs.figure1,'FileControlStruct');
set([fcs.files(:);fcs.checkboxes(:)],'Visible','off');

idx2=fcs.start-1;
for idx=1:min(10,length(fcs.data)-idx2)
  idx2=idx2+1;
  set(fcs.files(idx),...
    'String',fcs.data(idx2).name,...
    'Visible','on');
  if fcs.check(idx2),
    set(fcs.files(idx),'BackgroundColor',[0.9 0.9 1]);
  else
    set(fcs.files(idx),'BackgroundColor',[0.7 0.7 0.7]);
  end
  set(fcs.checkboxes(idx),...
    'Value',fcs.check(idx2),...
    'Visible','on');
end


%=====================================
function psb_selectall_Callback(h,ev,hs)
% Use All Files-
%=====================================
fcs=getappdata(hs.figure1,'FileControlStruct');
fcs.check(:)=true;
setappdata(hs.figure1,'FileControlStruct',fcs);
ChangeFilePos(hs);

%=====================================
function psb_Invert_Callback(h, ev, hs)
% Invert Flag
%=====================================
fcs=getappdata(hs.figure1,'FileControlStruct');
fcs.check=fcs.check==false;
setappdata(hs.figure1,'FileControlStruct',fcs);
ChangeFilePos(hs);

%=====================================
function SelectCheckbox(h,ev,hs)
% Change Select Checkbox,
%  --> Modify File-Control-Structure (Check)
%      And Change View
%=====================================
idx=get(h,'UserData');
fcs=getappdata(hs.figure1,'FileControlStruct');
fcs.check(fcs.start+idx-1)=logical(get(h,'Value'));
setappdata(hs.figure1,'FileControlStruct',fcs);
ChangeFilePos(hs);

%=========================================
function pop_key1_Callback(h,ev,hs)
% Change Key --> Change Value &
%=========================================

% Get Search Key
SearchKey=getappdata(hs.figure1,'SearchKey');
key=get(h,'String');key=key{get(h,'Value')};
% get Value Correspond to "key"
val=getfield(SearchKey.F,key);
val=val.key;

% Value to String
str={};
for idx=1:length(val),
  str{end+1}=P3_ldisp0(val{idx},10);
end

% Update Vals
v=get(hs.pop_val1,'Value');
if v>length(str),v=length(str);end
set(hs.pop_val1,'Value',v,'String',str);

function pop_val1_Callback(hObject, eventdata, handles)
% Do nothing


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radio - Button Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h, ope]=rdbgroup1(hs,h0)
% Radio Button Group 1 I/O
h   = [hs.rdb_and1,hs.rdb_or1];
ope = {'and',      'or'};
if nargin==1,return;end
set(h,'Value',0);set(h0,'Value',1);

function rdb_and1_Callback(h,ev,hs)
% control radiobutton <--> link to or1
rdbgroup1(hs,h);
function rdb_or1_Callback(h,ev,hs)
% control radiobutton <--> link to and1
rdbgroup1(hs,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unpopulated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_relop_Callback(h,ev,hs)
% Execute Logical Operation

% Get Search Key
SearchKey=getappdata(hs.figure1,'SearchKey');
key=get(hs.pop_key1,'String');
key=key{get(hs.pop_key1,'Value')};
% get Value Correspond to "key"
data= getfield(SearchKey.F,key);
vl  = get(hs.pop_val1,'Value');
% ==> Check Valu
id  = data.ID{vl};
fcs=getappdata(hs.figure1,'FileControlStruct');
[a,i0,iu]=intersect(id,fcs.ID);
me  = false(size(fcs.check));
me(iu) = true;

% Get Operation Type
[hx,ope]=rdbgroup1(hs);
h0=findobj(hx,'Value',1);
ope=ope{hx==h0};
switch ope
  case 'and'
    fcs.check = fcs.check & me;
  case 'or',
    fcs.check = fcs.check | me;
  otherwise
    error('Proguram Error : Undefined Operation %s',ope);
end
setappdata(hs.figure1,'FileControlStruct',fcs);
ChangeFilePos(hs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Control Functions (Inner / Filer Search)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=getHandleXX(hs,mode)
% For get Handle..
switch mode
  case 'File',
    h =[hs.txt_Value1          ,...
        hs.txt_SearchKey       ,...
        hs.psb_relop           ,...
        hs.frm_relop           ,...
        hs.rdb_or1             ,...
        hs.rdb_and1            ,...
        hs.psb_selectall       ,...
        hs.psb_Invert          ,...
        hs.pop_val1            ,...
        hs.pop_key1];
  case 'Inner',
    h  =[hs.pop_InnerKey     ,...
        hs.txt_InnerKey      ,...
        hs.psb_innerright    ,...
        hs.psb_innerleft];
  case 'Other',
    h =[hs.frm_checkboxes      ,...
        hs.frm_files           ,...
        hs.frm_InnerKeyCheckbox,...
        hs.frm_InnerKey];
  case 'Common',
    h = [hs.text3               ,...
        hs.text2               ,...
        hs.text1               ,...
        hs.psb_chmod           ,...
        hs.psb_ok              ,...
        hs.psb_cancel          ,...
        hs.pop_1stLvlFnc];
  otherwise
    error('Unknown Mode for getHandeXX : %s',mode);
end
    
function psb_chmod_Callback(h,ev,hs)
% Change 
str=get(h,'String');

if strcmpi(str,'Inner'),
  exceedInnerMode(hs)
  if 0,
    % TODO : 
    % --> backToFilemode 
    set(h,'Visible','off');
  else
    set(h,'String','Back')
  end
else
  backToFilemode(hs)
  set(h,'String','Inner');
end

%================================
function exceedInnerMode(hs)
% File-Select Mode to Inner-Data.
%================================

%==> Off File-Control
set(getHandleXX(hs,'Inner'),'Visible','on');
set(getHandleXX(hs,'File'),'Visible','off');
fcs=getappdata(hs.figure1,'FileControlStruct');
set([fcs.files(:);fcs.checkboxes(:)],'Visible','off');
set(hs.pop_1stLvlFnc,'Enable','inactive');

%=======================
% Setup SearchKey
%=======================
% Load
SearchKey=getappdata(hs.figure1,'SearchKey');
% Update File Search-Key
keys=fieldnames(SearchKey.I);
v=get(hs.pop_InnerKey,'Value');
if v>length(keys),v=length(keys);end
set(hs.pop_InnerKey,'Value',v,'String',keys);

%=======================
% Making Inner List
%=======================
ics=getappdata(hs.figure1,'InnerControlStruct');
if isempty(ics)
  ics.m=0;        % Number of Raw
  ics.n=0;        % Number of Column
  ics.mstart=1;   % Raw-Start Index
  ics.nstart=1;   % Column-Start
  ics.files=[];   % File Handles
  ics.checkboxes=[]; % Checkbox Handles
  ics.tcheckboxes=[]; % Title Checkbox Handles
end
ics.data=fcs.data(fcs.check);
ics.check=[];
ics.ID  =fcs.ID(fcs.check);
ics.val = [];

%== Reset Scrollbar
ResetFileSelectScrollBar(hs,ics.data);

% Make Inner-File handle
subuicontrol(get(hs.frm_files,'Position'));
for idx=(ics.m+1):min(length(ics.data),10)
  ics.files(idx)=subuicontrol(hs.figure1,10,1,idx,1,'Inner',...
    'Style','Text','HorizontalAlignment','Right',...
    'TAG',sprintf('txt_%dthinner',idx));
end

ics.m=min(length(ics.data),10);
setappdata(hs.figure1,'InnerControlStruct',ics);
%=======================
% Update Data
%=======================
pop_InnerKey_Callback(hs.pop_InnerKey,[],hs);
ChangeInnerPos(hs);


%================================
function backToFilemode(hs)
% Inner-Data to File-Select Mode
%================================
set(getHandleXX(hs,'Inner'),'Visible','off');
set(getHandleXX(hs,'File'),'Visible','on');
ics=getappdata(hs.figure1,'InnerControlStruct');
set([ics.files(:);ics.checkboxes(:);ics.tcheckboxes(:)],'Visible','off');
ChangeFilePos(hs);
% Reset File Select Scrollbar
fcs=getappdata(hs.figure1,'FileControlStruct');
ResetFileSelectScrollBar(hs, fcs.data);
%
set(hs.pop_1stLvlFnc,'Enable','on');
setappdata(hs.figure1,'InnerControlStruct',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unpopulated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_InnerKey_Callback(h, ev,hs)
% Get Search Key
SearchKey=getappdata(hs.figure1,'SearchKey');
key=get(h,'String');key=key{get(h,'Value')};
% get Value Correspond to "key"
key=getfield(SearchKey.I,key);
val=key.key;

%=======================
% Making Inner List
%=======================
ics=getappdata(hs.figure1,'InnerControlStruct');
ics.val = val;
% Make Title Checkbox handle
subuicontrol(get(hs.frm_InnerKey,'Position'));
for n=(ics.n+1):min(length(val),5)
  ics.tcheckboxes(n)=subuicontrol(hs.figure1,1,5,1,n,'Inner',...
    'Style','Checkbox','HorizontalAlignment','Right',...
    'TAG',sprintf('ckb_%dthtitle',n),...
    'BackgroundColor',[0.7,0.7,0.6],...
    'UserData',n,...
    'Value',1,...
    'Callback',...
    'P3_uiFLAselect(''SelectInnerTCheckbox'',gcbo,[],guidata(gcbf));');
end
% Make Sub Checkbox Handle
subuicontrol(get(hs.frm_InnerKeyCheckbox,'Position'));
for m=1:ics.m,
  for n=(ics.n+1):min(length(val),5)
    ics.checkboxes(m,n)=subuicontrol(hs.figure1,10,5,m,n,'Inner',...
      'Style','Checkbox','HorizontalAlignment','Right',...
      'TAG',sprintf('ckb_%d_%d_inner',m,n),...
      'UserData',[m,n],...
      'Callback',...
      'P3_uiFLAselect(''SelectInnerCheckbox'',gcbo,[],guidata(gcbf));');
  end
end

ics.n=min(length(val),10);
ics.check=true(length(ics.ID),length(val));
ics.tcheck=true(1,length(val));
ics.visible=false(length(ics.ID),length(val));
for n=1:length(val)
  [a,i0,iu]=intersect(key.ID{n},ics.ID);
  ics.visible(iu,n) = true;
end

setappdata(hs.figure1,'InnerControlStruct',ics);
ChangeInnerPos(hs);

function SelectInnerCheckbox(h,ev,hs)
% Change Local Checkbox
ics=getappdata(hs.figure1,'InnerControlStruct');
v=get(h,'UserData');
ics.check(ics.mstart+v(1)-1,ics.nstart+v(2)-1)=get(h,'Value');
setappdata(hs.figure1,'InnerControlStruct',ics);
ChangeInnerPos(hs);
function SelectInnerTCheckbox(h,ev,hs)
% Title Line Selected
ics=getappdata(hs.figure1,'InnerControlStruct');
n=get(h,'UserData');
ics.check(:,ics.nstart+n-1)=get(h,'Value');
setappdata(hs.figure1,'InnerControlStruct',ics);
ChangeInnerPos(hs);


function ChangeInnerPos(hs)
ics=getappdata(hs.figure1,'InnerControlStruct');
set([ics.files(:);ics.checkboxes(:);ics.tcheckboxes(:)],'Visible','off');

% Make Inner-File handle
m0=ics.mstart-1;
mm =1:min(length(ics.data)-m0,10);
for m=mm
  m0=m0+1;
  set(ics.files(m),'Visible','on',...
    'String',ics.data(m0).name);
end
mm0=ics.mstart:m0;

% Make Inner-Value
n0=ics.nstart-1;
nn =1:min(length(ics.val)-n0,5);
for n=nn,
  n0=n0+1;
  set(ics.tcheckboxes(n),'Visible','on',...
    'String',P3_ldisp0(ics.val{n0},10));
%  'Value',ics.tcheck(n0));
  
end
nn0=ics.nstart:n0;

ck=ics.check(mm0,nn0);
hx=ics.checkboxes(mm,nn);
vb=ics.visible(mm0,nn0);
set(hx(ck),'Value',1,'BackgroundColor',[0.7,0.7, 0.8]);
set(hx(~ck),'Value',0,'BackgroundColor',[0.7, 0.7, 0.7]);
set(hx(vb),'Visible','on');
set(hx(~vb),'Visible','off');

% =========================
% InnerKey Position Button Control
% =========================
if ics.nstart<=1,
  set(hs.psb_innerleft,'Visible','off');
else
  set(hs.psb_innerleft,'Visible','on');
end
if n==1
  set(hs.psb_innerright,'Visible','off');
else
  set(hs.psb_innerright,'Visible','on');
end

function psb_innerleft_Callback(h,ev,hs)
% SK LEft
ics=getappdata(hs.figure1,'InnerControlStruct');
ics.nstart=ics.nstart-1;
setappdata(hs.figure1,'InnerControlStruct',ics);
ChangeInnerPos(hs);

function psb_innerright_Callback(h,ev,hs)
% SK Right
ics=getappdata(hs.figure1,'InnerControlStruct');
ics.nstart=ics.nstart+1;
setappdata(hs.figure1,'InnerControlStruct',ics);
ChangeInnerPos(hs);





% --- Executes during object creation, after setting all properties.
function sld_filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function sld_filelist_Callback(h, ev, hs)
% File Select Slidebar
if strcmp(get(hs.psb_chmod,'String'),'Inner')
  fcs=getappdata(hs.figure1,'FileControlStruct');
  fcs.start=get(h,'max')-round(get(h,'value'))+1;
  setappdata(hs.figure1,'FileControlStruct',fcs);
  ChangeFilePos(hs);
else
% File List Down
  ics=getappdata(hs.figure1,'InnerControlStruct');
  ics.mstart=get(h,'max')-round(get(h,'value'))+1;
  setappdata(hs.figure1,'InnerControlStruct',ics);
  ChangeInnerPos(hs);
end
%=======================================================
%=======================================================
function ResetFileSelectScrollBar(hs, usedata)

  udlng=length(usedata)-10;
  if length(usedata)>10
    set(hs.sld_filelist,'Max',udlng,'Value',udlng,'SliderStep',[1/udlng max([1 1/udlng*10])],'Visible','on');
  else
    set(hs.sld_filelist,'Visible','off');
  end