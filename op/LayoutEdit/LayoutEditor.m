function varargout = LayoutEditor(varargin)
% LayoutEditor is Window to Edit Layout of P3.
%
%      H = LAYOUTEDITOR returns the handle to a new LAYOUTEDITOR or the handle to
%      the existing singleton*.
%
%      LAYOUTEDITOR('Property','Value',...) creates a new LAYOUTEDITOR using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to LayoutEditor_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LAYOUTEDITOR('CALLBACK') and LAYOUTEDITOR('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LAYOUTEDITOR.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
% 
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% $Id: LayoutEditor.m 395 2014-03-13 03:48:22Z katura7pro $

% Last Modified by GUIDE v2.5 09-Jan-2008 09:55:40


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2006.11.16
% $Id: LayoutEditor.m 395 2014-03-13 03:48:22Z katura7pro $
%
% Revision : 1.28 :
%   Reset-Layout-List in P3 when saving LAYOUT.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launcher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @LayoutEditor_OpeningFcn, ...
  'gui_OutputFcn',  @LayoutEditor_OutputFcn, ...
  'gui_LayoutFcn',  [], ...
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
% GUI I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LayoutEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% Open : Set-up GUI/ Init ApplicationData/
% TODO : Ajust Position 
handles.figure1= hObject;
handles.output = hObject;

%============================
% Opening Check : 2007.04.05
%============================
if isfield(handles,'menu_info'), return;end

%============================
% Set up GUI's
%============================
% Change to Fixed Width
f=get(0,'FixedWidthFontName');
set(handles.lbx_layoutTree,...
  'FontName',f,'FontUnits','points','FontSize',9,...
  'Value', 1,...
  'String', 'FIGURE NAME', 'UserData' ,{[]});

% ...
set(handles.pop_partsType3, 'Visible','on', 'Value', 1);
set(handles.pop_controlKind, 'Visible','off');
set(handles.pop_visualObjectKind, 'Visible','off');

pos=get(handles.pop_partsType,'Position');
set(handles.pop_partsType2,'Position',pos);
set(handles.pop_partsType3,'Position',pos);
pos=get(handles.pop_controlKind,'Position');
set(handles.pop_spControlKind,'Position',pos);
set(handles.pop_visualObjectKind, 'Position',pos);

% Create Layout-Parts-GUI
if ~isfield(handles,'LPO_name'),
  % if there is no LP-GUI
  handles=Lparts_Manager('Create',handles);
  
  % Dock-Controls :: since MATLAB R2006a ::
  try
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver>13,
      set(hObject,'DockControls','off');
    end
  catch
    OSP_LOG('perr',...
      {'No Dock-Controls Property',...
        sprintf('MATLAB R %f \n',rver)});
  end  
end

% Create Menu
if ~isfield(handles,'menu_info'),
  % if there is no LP-GUI
  %handles.menu_info=uimenu(handles.figure1,'Label','&Info');
  %handles.menu_prev=uimenu(handles.menu_info,...
  handles.menu_prev=uimenu(handles.figure1,...
    'Label','&TestDraw',...
    'Callback','LE_testdraw(guidata(gcbf));');
  handles.menu_info=handles.menu_prev;
end

%=============================
% Open LayoutEditor OverView
%=============================
handles.fig_OverView = LE_OverView;

%=============================
% Ajust Position of Figure's
%=============================
% Add : 2007.04.05
set(0,'Units','Pixels');
p=get(0,'ScreenSize');
set(handles.fig_OverView,'Units','Pixels');
pov=get(handles.fig_OverView,'Position');
ple=get(handles.figure1,'Position');
%-------------------
% x-direction
%-------------------
% Over -->
%px=ple(1)+ple(3);
%if px>p(3),ple(1)=p(3)-ple(3);end
ple(1)=p(3)-ple(3);
% OV is left-hand
pov(1)=ple(1)-pov(3);
if pov(1)<1, pov(1)=1;end
% < centering?>
if ple(1)>30
  ple(1)=ple(1) - pov(1)/2;
  pov(1)=pov(1)/2;
end

%-------------------
% y-direction
%-------------------
ple(2)=p(4)-ple(4);
% < centering?>
if ple(2)>30,
  ple(2)=ple(2)/2;
end
% -> apply to OverView
pov(2)=ple(2);
pov(4)=ple(4);

% Update Position
set(handles.fig_OverView,'Position',pov);
set(handles.figure1,'Position',ple);
set(handles.fig_OverView,'Units','Normalized');

%=============================
% Update handles structure
%=============================
guidata(handles.figure1,handles);

%==============================
% Initialize Application-Data
%==============================
typeHs=[handles.pop_partsType, handles.pop_partsType2, handles.pop_partsType3];
Hs=[handles.pop_visualObjectKind, ...
  handles.pop_controlKind, handles.pop_spControlKind];
setappdata(handles.figure1, 'layoutTreeTypes', typeHs);
setappdata(handles.figure1, 'layoutTreePops',  Hs);
setappdata(handles.figure1, 'CurrentLayoutFname',[]);
setappdata(handles.figure1, 'CurrentLayoutisChange',false);


function varargout = LayoutEditor_OutputFcn(hObject, eventdata, handles)
% Output GUI Figure Handle (See also Opening function)
varargout{1} = handles.output;

function LayoutEditor_CloseRequestFcn(hObject, eventdata, handles)
% When Close Requese, make question 'is save?'
menu_close_Callback(handles.menu_close,[],handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Layout-Parts Adding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_addParts_Callback(h, e, handles,LPO)
% Add Layout-Parts
if 0,disp(h),disp(e);end
% Save current(F1)
Lparts_Manager('saveLPO',handles);
val=get(handles.lbx_layoutTree,'Value');

% Get Current Layout-Parts-Object and path
[cur,path]=LayoutPartsIO('get',handles);

%========================================================
% Add Layout-Parts-Object to Current-Layout-Parts-Object
%========================================================
if isempty(path),
  %-------------------
  % Add LPO to Figure
  %-------------------
  % get New LPO
  if nargin<4
    v=get(handles.pop_partsType3,'Value');
    ud=get(handles.pop_partsType3,'UserData');
    LPO=feval(ud{v}, 'getDefaultData');
  end
  % Add LPO
  if ~isfield(cur, 'vgdata'),
    cur.vgdata{1}=LPO;
    cur.FigureProperty.Name    ='Untitled';
  else
    cur.vgdata{end+1}=LPO;
  end
else
  if ~isfield(cur, 'MODE')
    errordlg({...
      '----------------',...
      ' Platform Error',...
      '----------------',...
      ' Could not connect Layout Tree',...
      C__FILE__LINE__CHAR},...
      'Platform3:LayoutEditor:Add-LPO','replace');
    return;
  end
  
  if strcmp(cur.MODE, 'ViewGroupArea'),
    %-------------------
    % Add LPO to Area
    %-------------------
    if nargin<4
      v=get(handles.pop_partsType,'Value');
    else
      % LPO must be Area/Axis
      %  or you must add SWITCH to set V
      v=1;
    end
    switch(v),
      case {1, 2} % New Area/Axis
        if nargin<4
          ud =get(handles.pop_partsType,'UserData');
          LPO=feval(ud{v}, 'getDefaultData');
        end
        % Set Property
        LPO.Name=['untitled a' num2str(length(cur.Object)+1)];
        % Add Area
        cur.Object{end+1}=LPO;
      case 3, % New Special control
        if nargin<4
          info=get(handles.pop_spControlKind,'UserData');
          contl=info{get(handles.pop_spControlKind,'Value')};
          LPO=feval(contl.fnc, 'getArgument',info);
          % cancel
          if isempty(LPO),return;end
        end
        % Set Property
        % Add control
        if ~isfield(cur,'CObject'),
          cur.CObject{1}=LPO;
        else
          cur.CObject{end+1}=LPO;
        end
      otherwise,
        errordlg({...
          '----------------',...
          ' Platform Error',...
          '----------------',...
          ' Unknown Layout-Parts Type to Add',...
          C__FILE__LINE__CHAR},...
          'Platform3:LayoutEditor:Add-LPO','replace');
        return;
    end %switch-end
  elseif strcmp(cur.MODE,'ViewGroupAxes'),
    %-------------------
    % Add LPO to Axis
    %-------------------
    if nargin<4
      info=get(handles.pop_visualObjectKind,'UserData');
      axes=info{get(handles.pop_visualObjectKind,'Value')};
      LPO=feval(axes.fnc,'getArgument',[]);
      % cancel
      if isempty(LPO),return;end
    end
    % Set Property
    cur.Object{end+1}=LPO;
  end
end

% Update and Make Tree
LayoutPartsIO('set',handles,cur,path);

% Re-Select New Value
reSelectLayoutEditor(handles,val);
return;

function reSelectLayoutEditor(hs,val)
%-------------------------
% Reset LParts
%-------------------------
Lparts_Manager('resetLPO',hs);
%-------------------------
% Select Layout-Parts
%-------------------------
if nargin>=2,
  set(hs.lbx_layoutTree,'Value',val);
end

selectedflag=lbx_layoutTree_Callback(hs.lbx_layoutTree,true,hs);
if selectedflag==false
  % TODO :
  % --> to recover data-set. ??
  % a. listing-up : when this error occur. (no?)
  % b. checking --> status/what user want to do
  % c. please mail to shoji.
  errordlg('Tree-Listbox Control-Variable might be broken!');
end

% --------------------------------------------------------------------
% --- Executes on selection change in lbx_layoutTree.
function selectedflag=lbx_layoutTree_Callback(hObject, eventdata, handles)
persistent isrun oldval0
if ~isempty(eventdata), oldval0=-1;end
selectedflag=false; % when Select Data : ture
%dbflag=false;

oldval=oldval0;
val=get(hObject,'Value');
oldval0=val; %#ok !! oldval0 is persistent!! so I use.

%  disp(' *** Clicked ! ***');
%  disp(get(handles.figure1,'SelectionType'));

if isequal(val,oldval)
  if strcmpi(get(handles.figure1,'SelectionType'),'open')
    % Double Click ===>
    % fprintf('-------------> Expand!! %d\n',val);
    % open/close
    reverseCurrentPartsExpandFlag(handles);
    % fprintf('<------------- Expand!! %d\n',val);
  else
    % Single Click & same Value
    % Do Nothing
  end
else
  % Value is Changed!
  if isrun
    % Now Single is running,
    %  so must be cancel..
    set(hObject,'Value',oldval);
    val=oldval;
  else
    isrun=true;
    try
      % Normal Single Click
      %fprintf('-------------> Select!! %d\n',val);
      %=========
      % F1 
      %=========
      % Save Current Layout-Parts-Object
      Lparts_Manager('saveLPO',handles);
      % Load Selected Layout-Parts
      [LP, path0, abspos]=LayoutPartsIO('get',handles);

      %=========
      % F3
      %=========
      % Set Layout-Parts-Object to GUI
      Lparts_Manager('setLPO',handles,LP,path0,abspos);
      
      % Show popup-menu (F2)
      init_layoutPops(handles,LP);
      % Redraw Over-View
      if ~ishandle(handles.fig_OverView),
        handles.fig_OverView=LE_OverView;
        guidata(handles.figure1,handles);
      end
      selectedflag=true; % Data was selected!
      
      % beta-gaki
      ud=get(hObject,'UserData');
      layoutpath=ud{get(hObject,'Value')};
      LAYOUT=LayoutPartsIO('get',handles,[]);
   
      % Add input-arugment handles
      %   2007.03.05 : shoji
      %    ==> to Lparts_Manager/setPosition
      %      (Flow No3 : OV/WindowsButtonUp to call F7 )
      LE_OverView('Redraw',...
        handles.fig_OverView,[],...
        guidata(handles.fig_OverView),...
        LAYOUT,layoutpath,handles);
     
    catch
      isrun=false; % isrun is persistent, so I need this code.
      disp(C__FILE__LINE__CHAR);
      rethrow(lasterror);
    end
    %fprintf('<------------- Select!! %d\n',val);
    isrun=false;
  end
end

oldval0=val;
return;

% --------------------------------------------------------------------
function menu_newLayout_Callback(hObject, eventdata, handles)
% Check Layout-Change-flag & Save 
menu_saveLayout_Callback(handles.menu_saveLayout,[],handles,false);
% load('NewLayout.mat','LAYOUT');
vdir=which('LayoutEditor');
pname=fileparts(vdir);
fname=[pname filesep 'NewLayout.mat'];
LayoutFile2AppLayout(handles, fname);
% Clear name of current Layout-file
setappdata(handles.figure1, 'CurrentLayoutFname',[]);

% Re-Select New Value
val=1;
reSelectLayoutEditor(handles,val);


% --------------------------------------------------------------------
function menu_openLayout_Callback(hObject, eventdata, handles,fname)
% Open Layout File
%   Check Layout-Change-flag & Save 

%--------------------
% Save before Layout
%--------------------
menu_saveLayout_Callback(handles.menu_saveLayout,[],handles,false);

if nargin<4
  %-------------------------
  % Open Layout by UIGETFILE
  %-------------------------
  % Output : FNAME
  vdir=which('LayoutEditor');
  pname=fileparts(vdir);
  
  curpwd = pwd;
  try
    cd([pname filesep '..' filesep 'LAYOUT']);  %%
  catch
    cd(pname);
  end
  try
    [fn, pn] = uigetfile('*.mat');
  catch
    cd(curpwd);
    rethrow(lasterr);
  end
  cd(curpwd);
  if fn==0, return;end % cancell
  fname = [pn filesep fn];
end

%------------------------------------------
% Read and Change LayourEditor innner table
%------------------------------------------
try
  LayoutFile2AppLayout(handles, fname);
catch
  errordlg({'Error :',lasterr},'Layout-File Loasing');
  return;
end  
%------------------------------------------
% Set name of current Layout-file
%------------------------------------------
setappdata(handles.figure1, 'CurrentLayoutFname', fname);

% Create list
create_layoutTreelist(handles);

%=== Re-Select Layout-Parts ===
reSelectLayoutEditor(handles,1);

%== set GUI title as LAYOUT file name
%set(handles.figure1,'name',['LE: ' fname]); % 080714TK@HARL
[pn fn]=fileparts(fname);
set(handles.figure1,'name',['LAYOUT EDITOR 1.0 beta: ' fn '.mat']); % full path is too long...

return;

% --------------------------------------------------------------------
function q=menu_saveLayout_Callback(hObject, eventdata, handles,cbflag)
%Save
q='save';
if nargin<4,cbflag=true;end

if getappdata(handles.figure1, 'CurrentLayoutisChange') || cbflag
  % Realy Save
  if ~cbflag,
    q=questdlg({'File is changed.', ' Do you want to save?'});
    if ~strcmpi(q,'yes'),return;end
  end

  fname=getappdata(handles.figure1, 'CurrentLayoutFname');
  if isempty(fname),
    q=menu_saveAs_Callback(handles.menu_saveAs,[],handles);
    return;
  end

  % SaveLPO
  Lparts_Manager('saveLPO',handles);
  % File save
  AppLayout2LayoutFile(handles, fname);

  % Clear Layout-change-flag
  setappdata(handles.figure1, 'CurrentLayoutisChange', false);
end
return;

% --------------------------------------------------------------------
function q=menu_saveAs_Callback(hObject, eventdata, handles)
q='Cancel';

% Realy SaveAs
curpwd = pwd;
try
  p=fileparts(which(mfilename));
  p0=[p filesep '..' filesep 'LAYOUT'];
  if exist(p0,'dir')
    cd(p0);
  end
	cfn=getappdata(handles.figure1, 'CurrentLayoutFname');
	if isempty(cfn), cfn='new.mat';end
  [fname pname]=uiputfile('*.mat', 'Save Layout File',cfn);% 080701TK@HARL
catch
  cd(curpwd);
  rethrow(lasterr);
end
cd(curpwd);
if (isequal(fname,0) || isequal(pname,0)),return;end
% SaveLPO
Lparts_Manager('saveLPO',handles);
% File Save
AppLayout2LayoutFile(handles, [pname fname]);
q='yes';
cd(curpwd);

% Set name of current Layout-file & Clear Layout-change-flag
setappdata(handles.figure1, 'CurrentLayoutFname', [pname fname]);
setappdata(handles.figure1, 'CurrentLayoutisChange', false);
set(handles.figure1,'name',['LE: ' pname fname]);%TK@HARL080714
return;

% --------------------------------------------------------------------
function menu_close_Callback(hObject, eventdata, handles)

q=menu_saveLayout_Callback(handles.menu_saveLayout,[],handles,false);
% Check cancel
if strcmpi(q,'cancel'),return;end

% Windows Close
if isfield(handles, 'fig_OverView') &&...
   ishandle(handles.fig_OverView),
  delete(handles.fig_OverView);
end
delete(handles.figure1);

% --------------------------------------------------------------------
function pop_partsType_CreateFcn(hObject, eventdata, handles)
str={'New area','New axis','New special control'};
ud={'ViewGroupArea','ViewGroupAxes'};
set(hObject, 'String', str, 'UserData', ud);

% --------------------------------------------------------------------
function pop_partsType_Callback(hObject, eventdata, handles)
hs=getappdata(handles.figure1, 'layoutTreePops');
for idx=1:length(hs),
  set(hs(idx), 'Visible', 'off');
end

val=get(hObject,'Value');
if val==3,
  set(handles.pop_spControlKind, 'Visible', 'on');
end

% --------------------------------------------------------------------
function pop_partsType3_CreateFcn(hObject, eventdata, handles)
str={'New area','New axis'};
ud={'ViewGroupArea','ViewGroupAxes'};
set(hObject, 'String', str, 'UserData', ud);

% --------------------------------------------------------------------
function pop_partsType2_Callback(hObject, eventdata, handles)
val=get(hObject,'Value');
if val==1,
  set(handles.pop_visualObjectKind, 'Visible', 'on');
end

% --------------------------------------------------------------------
function pop_visualObjectKind_CreateFcn(hObject, eventdata, handles)
% Renew :: Axis-Object List ::
%   List-up Axis-Object in LAYOUT/AxisObject & PluginDir.
%   When LayoutEditor Opened.
%-------------------------------   
% **** More Information  ****
%  Modified at 14-Nov-2007 11:30 by M.Shoji
%   Mail at 25-Oct-2007 12:41:22
tmpdir=pwd;
try
  %==================================
  % Search Files 
  %==================================
  % Input  : Axis-Object Directory
  % Output :
  %    files : Axis-Object List
  warning off REGEXP:multibyteCharacters
  % Old Code : viewer/axes_subobj
  path0 = OSP_DATA('GET','OSPPATH');

  [pp ff] = fileparts(path0); % added by K.Nakajo 20100301
  if( strcmp(ff,'WinP3')~=0 )
    path0=[path0 filesep '..'];
  end

  path1 = [path0 filesep 'viewer' filesep 'axes_subobj'];
  files1= find_file('^osp_ViewAxesObj_\w+.[mp]$',path1,'-i');
  % Layout\AxisObject
  path2 = [path0 filesep 'LAYOUT' filesep 'AxisObject'];
  files2= find_file('^LAYOUT_AO_\w+.[mp]$',path2,'-i');
  % PluginDir
  path3 = [path0 filesep 'PluginDir'];
  files3= find_file('^LAYOUT_AO_\w+.[mp]$',path3,'-i');
  % BenriButton
  path4 = [path0 filesep 'BenriButton'];
  files4= find_file('^LAYOUT_AO_\w+.[mp]$',path4,'-i');
  warning on REGEXP:multibyteCharacters

  files = {files1{:}, files2{:},files3{:},files4{:}};
  
  %==================================
  % Make User-Data (AO List)
  %==================================
  % Input : files
  % Output: ud,str
  ud={};str={};
  for idx=1:length(files),
    try
      % - get data -
      [pth, nm] = fileparts(files{idx});
      info  = feval(nm, 'createBasicInfo');
      % ==> Make List
      % !! setup str at fast, check info.MODENAME
      str{end+1}=info.MODENAME;
      ud{end+1} =info;
    catch
      warning(lasterr);
    end
  end
catch
  warning on REGEXP:multibyteCharacters
  cd(tmpdir); rethrow(lasterror);
end
if 0,disp(pth);end
cd(tmpdir);

%========
% Update
%========
set(hObject, 'String', str, 'UserData', ud);

% --------------------------------------------------------------------
function pop_spControlKind_CreateFcn(hObject, eventdata, handles)
% Renew :: (Special) Control-Object List ::
%   List-up Axis-Object in LAYOUT/ControlObject & PluginDir.
%   When LayoutEditor Opened.
%-------------------------------   
% **** More Information  ****
%  Modified at 14-Nov-2007 14:00 by M.Shoji
%   Mail at 25-Oct-2007 12:41:22

% == Pop Up Menu ==
% <-- Function List -->
tmpdir = pwd;
try
  %==================================
  % Search Files 
  %==================================
  % Input  : Axis-Object Directory
  % Output :
  %    files : Axis-Object List
  warning off REGEXP:multibyteCharacters
  % Old Code : viewer/axes_subobj
%  path0 = OSP_DATA('GET','OSPPATH'); path0=[path0 filesep '..'];

   path0 = OSP_DATA('GET','OSPPATH');
   [pp ff] = fileparts(path0);
   if( strcmp(ff,'WinP3')~=0 )
      path0=[path0 filesep '..'];
   end

  path1 = [path0 filesep 'viewer' filesep 'callback_subobj'];
  files1= find_file('^osp_ViewCallback_\w+.[mp]$',path1,'-i');
  % Layout\AxisObject
  path2 = [path0 filesep 'LAYOUT' filesep 'ControlObject'];
  files2= find_file('^LAYOUT_[C]?CO_\w+.[mp]$',path2,'-i');
  % PluginDir
  path3 = [path0 filesep 'PluginDir'];
  files3= find_file('^LAYOUT_[C]?CO_\w+.[mp]$',path3,'-i');
  % BenriButton
  path4 = [path0 filesep 'BenriButton'];
  files4= find_file('^LAYOUT_[C]C?O_\w+.[mp]$',path4,'-i');
  warning on REGEXP:multibyteCharacters
  files = {files1{:}, files2{:},files3{:},files4{:}};
  
  %==================================
  % Make User-Data (AO List)
  %==================================
  % Input : files
  % Output: ud,str
  ud={};str={};
  nolist={'osp_ViewCallback_ChannelPopup', ...
              'osp_ViewCallback_KindSelector'};
  for idx=1:length(files),
    try
      % - get data -
      [pth, nm] = fileparts(files{idx});
      if any(strcmpi(nm,nolist)), continue; end
      info  = feval(nm, 'createBasicInfo');
      % ==> Make List
      % !! setup str at fast, check info.MODENAME
      str{end+1}= info.name;
      ud{end+1} = info;
    catch
      warning(lasterr);
    end
  end
catch
  cd(tmpdir); rethrow(lasterror);
end
if 0,disp(pth);end
cd(tmpdir);

%========
% Update
%========
set(hObject, 'String', str, 'UserData', ud);

function [out, typ]=ClipBordIO(mode,handles,data)
persistent local_data;
mode=lower(mode);
switch mode
  case 'get'
    msg=nargchk(2,2,nargin);if msg,error(msg);end
    msg=nargoutchk(1,2,nargout);if msg,error(msg);end
    out=local_data;
    if isempty(out),
      typ='empty';
    elseif isfield(out,'MODE') && ...
        any(strcmpi(out.MODE,{'ViewGroupArea','ViewGroupData','ViewGroupAxes','ViewGroupGroup','ViewGoupCallback'}))
      % (Area)
      typ='Area';
    elseif isfield(out,'fnc')
      s=regexp(out.fnc,'osp_ViewCallback');
      if isempty(s)
        typ='Object';
      else
        typ='Control';
      end
    else
      typ='Unknown';
    end
  case 'set'
    msg=nargchk(3,3,nargin);if msg,error(msg);end
    msg=nargoutchk(0,0,nargout);if msg,error(msg);end
    local_data=data;
  otherwise
    error('ClipBord Need Get/Set');
end

% --------------------------------------------------------------------
function ctmenu_cut_Callback(hObject, eventdata, handles)
ctmenu_copy_Callback(handles.ctmenu_copy, [], handles);
ctmenu_delete_Callback(handles.ctmenu_delete, [], handles);

% --------------------------------------------------------------------
function ctmenu_copy_Callback(hObject, eventdata, handles)
% Save current(F1)
Lparts_Manager('saveLPO',handles);
% Get current Parts
[cur,path]=LayoutPartsIO('get',handles);
% Set Clip-bord
ClipBordIO('set',handles, cur);

% --------------------------------------------------------------------
function ctmenu_paste_Callback(hObject, eventdata, handles)
% Paste to ..

% :: (F1) ::
% Save current GUI to LAYOUT (5)->(1)
val=get(handles.lbx_layoutTree,'Value');
Lparts_Manager('saveLPO',handles);

% Get current Parts LPO from (1)
[cur,pt]=LayoutPartsIO('get',handles);

% Get ClipBord
[cb, typ]=ClipBordIO('get',handles);
if isempty(cb),
  warndlg('No Data to past. Clipboard is empty!'); return;
end
% Modify Past Position
if isfield(cb,'Position')
  p0=cb.Position;
  p0(1)=p0(1)+p0(3)*0.1;
  if p0(1)+p0(3)>1,p0(1)=0;end
  p0(2)=p0(2)-p0(4)*0.1;
  if p0(2)<0,p0(2)=0;end
  cb.Position=p0;
end

%== Past LPO Type ==
% typ='Area';
% typ='Object';
% typ='Control';
if (isempty(cur) || isfield(cur,'vgdata') ) && strcmp(typ,'Area')
  % Figure
  cur.vgdata{end+1}=cb;
elseif isfield(cur,'MODE') && strcmp(cur.MODE,'ViewGroupAxes') && strcmpi(typ,'Object')
  % Axes : Object Only
  cur.Object{end+1}=cb;
elseif  isfield(cur,'MODE') && strcmp(cur.MODE,'ViewGroupArea')
  % Area :
  if strcmpi(typ,'Area')
    cur.Object{end+1}=cb;
  elseif strcmpi(typ,'Control')
    cur.CObject{end+1}=cb;
  else
    errordlg({['Can not Past a ' typ ' in Area']},...
      'LayoutEdiotr : Past Error');
    return;
  end
else
  errordlg({['Can not Past a ' typ ]},...
    'LayoutEdiotr : Past Error');
end

% Update and Make Tree
LayoutPartsIO('set',handles,cur,pt);
%%%  for ChangeRPOS of cb ?? No effect....
% LParts_Manager('setLPO',handles,cb,cbpath,apos);
% Re-Select New Value
reSelectLayoutEditor(handles,val);

% --------------------------------------------------------------------
function ctmenu_delete_Callback(hObject, eventdata, handles)
val=get(handles.lbx_layoutTree,'Value');
[cur,path]=LayoutPartsIO('get',handles);
if length(path)==0,
  warndlg('Can not Remove Figure');return;
end
if length(path)==1,
  cur=[];
else
  endp=path(end);
  path=path(1:end-1);
  [c,path]=LayoutPartsIO('get',handles,path);
  if endp<0,
    c.CObject(-endp)=[];
  else
    c.Object(endp)=[];
  end
  cur=c;
end
% Update & Make Tree
path=LayoutPartsIO('set',handles,cur,path);

if val>1, val=val-1;end
% Re-Select New Value
reSelectLayoutEditor(handles,val);
return;

% --------------------------------------------------------------------
function ctmenu_up_Callback(hObject, eventdata, handles)
val=get(handles.lbx_layoutTree,'Value');
[cur,path]=LayoutPartsIO('get',handles);
if length(path)==0,
  warndlg('Can not Up Figure');return;
end
% check vg
if length(path)==1,
  ppath=[];
  [p,ppath]=LayoutPartsIO('get',handles,ppath);
  if path>1,
    p.vgdata(path-1:path)=p.vgdata(path:-1:path-1); 
  else
    warndlg('Can not Up selected-parts.');return;
  end
else
  endp=path(end);
  ppath=path(1:end-1);
  [p,ppath]=LayoutPartsIO('get',handles,ppath);
  % Move
  if abs(endp)>1,
    if endp<0,   %control
      p.CObject(-endp-1:-endp)=p.CObject(-endp:-1:-endp-1);
    else         %object
      p.Object(endp-1:endp)=p.Object(endp:-1:endp-1);
    end
  else 
    warndlg('Can not Up selected-parts.');return;
  end
end
% Update and Make Tree
ppath=LayoutPartsIO('set',handles,p,ppath);
% Get position of treeList
if path(end)>0,
  path(end)=path(end)-1;
else
  path(end)=path(end)+1;
end
val=search_pathTree(path,handles);
% Re-Select New Value
reSelectLayoutEditor(handles,val);

% --------------------------------------------------------------------
function ctmenu_down_Callback(hObject, eventdata, handles)
val=get(handles.lbx_layoutTree,'Value');
[cur,path]=LayoutPartsIO('get',handles);
if length(path)==0,
  warndlg('Can not Down Figure');return;
end
% check vg
if length(path)==1,
  ppath=[];
  [p,ppath]=LayoutPartsIO('get',handles,ppath);
  if path==length(p.vgdata),
    warndlg('Can not Down selected-parts.');return;
  else
    p.vgdata(path:path+1)=p.vgdata(path+1:-1:path);
  end
else
  endp=path(end);
  ppath=path(1:end-1);
  [p,ppath]=LayoutPartsIO('get',handles,ppath);
  % Move
  if endp<0,   %control
    if abs(endp)==length(p.CObject),
      warndlg('Can not Down selected-parts.');return;
    else
      p.CObject(-endp:-endp+1)=p.CObject(-endp+1:-1:-endp);
    end
  else         %object
    if endp==length(p.Object),
      warndlg('Can not Down selected-parts.');return;
    else
      p.Object(endp:endp+1)=p.Object(endp+1:-1:endp);
    end
  end
end
% Update and Make Tree
ppath=LayoutPartsIO('set',handles,p,ppath);
% Get position of treeList
if path(end)>0,
  path(end)=path(end)+1;
else
  path(end)=path(end)-1;
end
val=search_pathTree(path,handles);
% Re-Select New Value
reSelectLayoutEditor(handles,val);

% ==Inner function===================================================
% ** for popup-menu
% ---------------------------------------
function init_layoutPops(handles,cur)
hs=[getappdata(handles.figure1,'layoutTreeTypes') ,...
  getappdata(handles.figure1,'layoutTreePops')];
set(hs,'Visible','off');
set(handles.psb_addParts,'Enable','off');
% Icon Enable
set([handles.ico_area,handles.ico_axis],'Enable','off');
if isempty(cur),
  % (Un initialized)
  % set(handles.pop_partsType3,'Visible','on','Value',1);
  % set(handles.psb_addParts,'Enable','on');
elseif isfield(cur,'MODE'),
  if strcmp(cur.MODE, 'ViewGroupArea'),
    % Area
    set(handles.pop_partsType,'Visible','on','Value',1);
    set(handles.psb_addParts,'Enable','on');
    pop_partsType_Callback(handles.pop_partsType, [], handles);
    % ( Icon )
    set([handles.ico_area,handles.ico_axis],'Enable','on');
  elseif strcmp(cur.MODE,'ViewGroupAxes'),
    % Axes
    set(handles.pop_partsType2,'Visible','on','Value',1);
    set(handles.psb_addParts,'Enable','on');
    pop_partsType2_Callback(handles.pop_partsType2, [], handles);
  end
elseif isfield(cur,'vgdata'),
  % Figure
  set(handles.pop_partsType3,'Visible','on','Value',1);
  set(handles.psb_addParts,'Enable','on');
  % ( Icon )
  set([handles.ico_area,handles.ico_axis],'Enable','on');
end

return;

% ** for layoutTree List
% ---------------------------------------
function reverseCurrentPartsExpandFlag(handles)
% Get Current
[d, path]=LayoutPartsIO('get',handles);
if isfield(d, 'ExpandFlag'),
  d.ExpandFlag= ~d.ExpandFlag;
end
LayoutPartsIO('set',handles,d,path);
return;

% ** LAYOUT-fileI/O
% --------------------------------------------------------------------
function vgdata=LayoutFile2AppLayout(handles,fname)
%  Change LAYOUT-FILE ->LayoutEditor Inner table
%  fname : name of LAYOUT FILE
load (fname, 'LAYOUT');
if ~exist('LAYOUT','var') || ~isstruct(LAYOUT) || ~isfield(LAYOUT,'vgdata'),
  error(['Layout File Format Error.',...
    '   No LAYOUT-Data exist.']);
end
vgdata=LAYOUT.vgdata;

% change LayoutEditor innner table
for idx=1:length(vgdata),
  data=vgdata{idx};
  vgdata{idx}=changeToParts(data);
end
% Set appdata
LAYOUT.vgdata=vgdata;
LayoutPartsIO('set',handles,LAYOUT,[]);
setappdata(handles.figure1, 'CurrentLayoutisChange', false);
return;

function data=changeToParts(data)
data=ViewGroupArea('changeToArea',data);
if ~isfield(data, 'Object'),return; end
for idx=1:length(data.Object)
  d=data.Object{idx};
  d=changeToParts(d);
  data.Object{idx}=d;
end
return;

% --------------------------------------------------------------------
function AppLayout2LayoutFileIO(h,e,handles,fname)
AppLayout2LayoutFile(handles,fname)

function AppLayout2LayoutFile(handles,fname)
%  Change LayoutEditor Inner table->LAYOUT-FILE
% get appdata

LAYOUT=LayoutPartsIO('get',handles,[]);
if isempty(LAYOUT), error('Empty Layout Exception.');end
vgdata=LAYOUT.vgdata;
% change LayoutEditor innner table
for idx=1:length(vgdata),
  data=vgdata{idx};
  vgdata{idx}=changeToGroup(data);
end

LAYOUT.vgdata=vgdata;
LAYOUT.ver   =2.0;
%fProp = get(handles.psb_Figprop, 'UserData');
%if ~isempty(fProp),
%  LAYOUT.FigureProperty = fProp;
%else
%LAYOUT.FigureProperty = [];
%end
% Save LAYOUT
rver=OSP_DATA('GET', 'ML_TB');
rver=rver.MATLAB;
if rver>=14,
  save(fname, 'LAYOUT','-v6');
else
  save(fname, 'LAYOUT');
end

% --> POTATo's Layout Change
try
  if OSP_DATA
    h0=OSP_DATA('GET','POTATOMAINHANDLE');
    hs=guidata(h0);
    POTATo('menu_ResetLayout_Callback',hs.menu_ResetLayout,[],hs);
  end
catch
  errordlg({'Reset-Layout Error:',...
    '  Change-Platform-Layout in manual.'},...
    'Layout Editor : Reset Layout');
end
return;

function data=changeToGroup(data)
data=ViewGroupArea('changeToGroup',data);
if ~isfield(data, 'Object'),return; end
for idx=1:length(data.Object)
  d=data.Object{idx};
  d=changeToGroup(d);
  data.Object{idx}=d;
end
return;

% --------------------------------------------------------------------
function p=search_pathTree(path, handles)
fflag=false;
ud=get(handles.lbx_layoutTree,'UserData');
for p=2:length(ud),
  if length(path)==length(ud{p}),
    if path==ud{p},fflag=true;break;end
  end
end
if ~fflag,
  p=1;
  warndlg('Not found list-position of Path.');
end

function lbx_layoutTree_ButtonDownFcn(hObject, eventdata, handles)
% --> In Right-Click <--
if 0
  % Meeting on 08-Nov-2007
  clicktype=get(handles.figure1,'SelectionType');
  if ~strcmpi('normal',clicktype)
    % TODO : Update Value
    % Could not select Value
    % --> get value on selection....( a little difficult )
    %    Location might be depend on system's --
    tp=get(hObject,'ListboxTop');
    cp=get(handles.figure1,'CurrentPoint');
    %set(hObject,'Units',get(handles.figure1,'Units'));
    %p =get(hOjbect,'Position'); 
    p=[8.5676  124.5785  262.0270  275.5467];
    back=(cp(2)-p(2))/ (p(4)/19.5);
    val=round(tp  + (19.5 - back));
    maxval=length(get(hObject,'String'));
    if val>maxval,val=maxval;
    elseif val<=0,val=1;end
    set(hObject,'Value',val);
    lbx_layoutTree_Callback(hObject, eventdata, handles);
  end
end

%==========================================================================
% Icon I/O (create :: deleate soon)
%==========================================================================
function ico_cut_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_cut.bmp');
function ico_copy_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_copy.bmp');
function ico_past_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_past.bmp');
function ico_delete_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_delete.bmp');
function ico_down_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_down.bmp');
function ico_up_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_up.bmp');
function ico_area_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_AREA.bmp');
function ico_axis_CreateFcn(hObject, eventdata, handles)
seticonimage(hObject,'ico_AXIS.bmp');
function seticonimage(h,filename)
p=fileparts(which(mfilename));
fname=[p filesep filename];
[c,m]=imread(fname);
cdata=zeros([size(c),3]);
for y=1:size(c,2)
  for x=1:size(c,1)
    cdata(x,y,:)=m(double(c(x,y))+1,:);
  end
end
set(h,'CData',cdata);

%==========================================================================
% Icon I/O
%==========================================================================
if 0
  ico_cut_Callback(h, e, hs)
  ico_copy_Callback(h, e, hs)
  ico_past_Callback(h, e, hs)
  ico_delete_Callback(h, e, hs)
  ico_up_Callback(h, e, hs)
  ico_down_Callback(h, e, hs)
  ico_axis_Callback(h, e, hs)
  ico_area_Callback(h, e, hs)
end
function ico_cut_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_cut_Callback(hs.ctmenu_cut,e,hs);
function ico_copy_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_copy_Callback(hs.ctmenu_copy,e,hs);
function ico_past_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_paste_Callback(hs.ctmenu_paste,e,hs);
function ico_delete_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_delete_Callback(hs.ctmenu_delete,e,hs);

function ico_up_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_up_Callback(hs.ctmenu_up,e,hs);
function ico_down_Callback(h, e, hs)
if 0,disp(h);end
ctmenu_down_Callback(hs.ctmenu_down,e,hs);

function ico_axis_Callback(h, e, hs)
% Add Axis
if 0,disp(h);end
LPO=ViewGroupAxes('getDefaultData');
psb_addParts_Callback(hs.psb_addParts,e,hs,LPO);
if 0,disp(h);end
function ico_area_Callback(h, e, hs)
% Add Area
LPO=ViewGroupArea('getDefaultData');
psb_addParts_Callback(hs.psb_addParts,e,hs,LPO);
if 0,disp(h);end
