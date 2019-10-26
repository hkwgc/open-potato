function varargout = POTATo(varargin)
% Open PoTATo is Platform of Transparent Analysis Tools for fNIRS
%  This function is a Main-Control GUI's M-File.
% 
% --------------------------------------------------------------------
% Open Platform of Transparent Analysis Tools for fNIRS (PoTATo)
%                                                       Version 3.9.0
% 
% 
% --------------------------------------------------------------------
%
% See also: P3, OSP,
%           GUIDE, GUIDATA, GUIHANDLES.
%

% =====================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% =====================================================================

%
% Open PoTATo was originally developped as 
% Platform for Optical Topography Analysis Tools (POTATo) 
% by Hitachi Advanced Research Laboratory and Hitachi ULSI Systems Co.,Ltd.
% Open PoTATo is modified from POTATo 3.8.50 and the earlier.
% 

% == POTATo History ==
% $Id: POTATo.m 404 2014-04-16 02:29:23Z katura7pro $
% Last Modified by GUIDE v2.5 14-Jun-2007 16:15:26

% 2010.10.29: 2010_2_RA01-1
%     Change P3-Mode Name and Control
%
% 2010.11.01: 2010_2_RA01-3
%     Add Research-Mode Status Toggle-Button 
%
% 2010.11.09: 2010_2_RC01-1
%     Research-1st State: 
%       if Same Recipe File Selected, enter Pre-Signle State
%
% 2010.11.24:
%     Search-File     : Accept Resarch-1st-Edit State
%
% 2010.11.25: 2010_2_RA06
%     Extended-Search : Accept Resarch-1st-Edit State
%
% 2011.01.06: Meeting on 2010.12.17
%     Extended-Search :
%       Key-popupmenu work in conjuction with Extended-Search

% Initiarize OSP ...
if ~OSP_DATA,
  %====================================
  % Path Setting by Startup.m
  %====================================
  % Get POTATo's Path
  p=fileparts(which('POTATo'));
  % Set Path 
  path0=pwd;
	if isdir(p)
		cd(p);
	end
  try
    %startup;
    P3_path;
    osp_ini_fin(1)
  catch
      
  end;
  cd(path0);
end

% Initiarize Launcher ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Depend on GUIDE version
% ======== Change for Debugging ============
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @POTATo_OpeningFcn, ...
                   'gui_OutputFcn',  @POTATo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if (nargin && ischar(varargin{1}))
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition & Grouping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcode=def_rcode
% Definition of Return-Code
rcode.RCODE_OK           = 0;
rcode.RCODE_WARNING      = 1;
rcode.RCODE_BAD_SOUCE    = 2;
rcode.RCODE_ERROR        = 4;
rcode.RCODE_SYSTEM_ERROR = 8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting Operation's
%-----------------------------------------------------------------
%  Opening Function,
%  Create Function,
%  Handle Control,
%  Load Default Setting's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function POTATo_OpeningFcn(hObject, ev, handles, varargin) %#ok
% POTATo Opeing Function 
% Executes just before POTATo is made visible.
global FOR_MCR_CODE;

% Initialize
% --> Output Initial Value <--
rcode=def_rcode;
output.rcode  =rcode.RCODE_OK; % 
output.hObject=hObject;

handles.figure1 = hObject; % My favorite Setting...
handles.output = output;

guidata(hObject, handles); % Update handles structure

% Running Check
try
  isrun=OSP_DATA('GET','isPOTAToRunning');
  if isempty(isrun),isrun=false;end
catch
  isrun=false;
end
try
  %====================================
  % Warning for Test-Mode
  %====================================
  if ~isrun
    p3ash=P3('getStatusHandle');
    s={'Opening Platform for Optical Topograhpy Analysis Toos'};
    if ~isempty(p3ash) && ishandle(p3ash)
      set(p3ash,'String',s);
      POTATo_About;
    end

    %======================================
    % Loading Local-User-Setting-Data,
    % Set Default Setting,
    % Initializeing Tools
    %======================================
    if ~isempty(p3ash) && ishandle(p3ash)
      s{end+1}='Initialize Seting File';
      set(p3ash,'String',s);
      POTATo_About;
    end
    POTATo_ini_fin(1,varargin{:}); % initialize POTATo
    cid='a';
    OSP_DATA('SET','CIRCULATION_ID',cid);
    OSP_LOG('msg',sprintf(' % ID : %d',cid));
    p=fileparts(which(mfilename));
    p=[p filesep 'check'];

		POTATo_About('Update');%- redraw for version info display.
		
    if isdir(p)
      chkmsg={}; a=dir([p filesep 'C*']);
      if length(a)==1 && length(a.name)==7
        name=int8(a.name);
        tmp=int8([5, -6,7,-15,2,-6,-16]);
        % MATLAB 6.5.1 is not support for int8 +
        try, chkmsg{end+1}=char(name+tmp);end %#ok<TRYNC,NOCOM>
      end
      if ~isempty(chkmsg), disp(char(chkmsg)); end
    end

  end

  osp=OSP_DATA('GET','MAIN_CONTROLLER');
  if ~isempty(osp.hObject) && ~ishandle(osp.hObject),
    rev = '$Revision: 1.79 $';
    rev(1)=' ';rev(end)='';
    wh=warndlg({['POTATo  ' rev],...
        ' POTATo might be destroy OSP-Running-State.',...
        ' Close OSP at first!'},['POTATo  ' rev]);
    waitfor(wh);
    % Set Error State and bye
    output.rcode=rcode.RCODE_ERROR;
    handles.output = output;
    guidata(hObject, handles); % Update handles structure
    return;
  end
  OSP_DATA('SET','POTAToMainHandle',hObject);
catch
  try
    OSP_LOG('err',lasterr);
  catch 
    h=errordlg([lasterr ...
        ' : may be OSP path Error.' ...
        ' please retry']);
		uiwait(h);
  end
  delete(hObject);
  rethrow(lasterror);
end

%================================
% Resize
%================================
try
  if ~isrun
    %=====================>
    % POTATo temporary Function
    %set(handles.menu_EditFilterList,'Enable','off');
    set(handles.menu_EditFilterList,'Visible','off');
    set(handles.menu_funchelp,'Visible','off');

    %<=====================
    % GUI Size Control
    va=get(handles.frm_viewArea,'pos');
    set(0,'Units','pixels'); % Confine ScreenSize is Pixes
    ss=get(0,'ScreenSize');  % Get Screan-Size
    pos=[(ss(3:4)-va(3:4))/2, va(3:4)]; % Centering
    set(hObject,'Position',pos);
    % Other Setting
    if isfield(handles,'menu_SA_copydata'),
      set(handles.menu_SA_copydata,'enable','off');
    end
    try
      set(handles.menu_ImportAir,'Visible','off');
    catch
    end
      
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
    
    % Key Press Function : since MATLAB R7
    if 0
    try
      % --> No effect...
      set(handles.edt_searchfile,'KeyPressFcn',...
        ['disp(''hoge'');',...
        'POTATo(''edt_searchfile_Callback'',gcbo,[],guidata(gcbf));']);
    catch
      % MATLAB Release 6.5.1 
      disp(lasterr);
    end
    end
  end
catch
  OSP_LOG('err',{'Opening Error Occur\n',lasterr});
end

%================================
% Font Setting ..
%================================
fn = get(0,'FixedWidthFontName');
hs =[handles.lbx_fileinfo,...
  handles.lbx_disp_fileList,...
  handles.lbx_ProjectInfo];
set(hs,'FontName',fn);

%================================
% Initialize P3-MODE
%================================
if ~isrun,
  % LOGO 
  if ~isempty(p3ash) && ishandle(p3ash)
    s{end+1}='Initialize P3- Mode';
    set(p3ash,'String',s);
    POTATo_About;
  end

  %=========================================
  % MODE-Menu Setting (GUI-Update)
  % 2010.10.29 : 2010_2_RA01-1
  %=========================================
  if ishandle(handles.menu_Setting)
    % Make MODE-MENU
    h0= uimenu('Parent',handles.menu_Setting,...
      'Label','P3 &MODE','TAG','P3_MODE');
    handles.P3_MODE=h0;
    
    % Change Name of MENU (Simple->Normal)
    set(handles.menu_simplemode,...
      'Parent',h0,'Label','&Normal Mode',...
      'Callback','POTATo(''menu_normalmode_Callback'',gcbo,[],guidata(gcbo))');

    % Add Menu : Research
    handles.menu_researchmode = ...
      uimenu('Parent',h0,'Label','&Research Mode',...
      'TAG','menu_researchmode',...
      'Callback','POTATo(''menu_researchmode_Callback'',gcbo,[],guidata(gcbo))');
    
    % Change Name of MENU (Advance->Developers)
    set(handles.menu_advmode,...
      'Parent',h0,'Label','&Developers Mode',...
      'Callback','POTATo(''menu_developersmode_Callback'',gcbo,[],guidata(gcbo))');
    if (FOR_MCR_CODE)
      % for Matlab-Compiler-Runtime Environment
      set(handles.menu_advmode,'Visible','off');
    end
  end
  
  %=========================================
  % Research-Mode GUI Setting
  % 2010.11.01 : 2010_2_RA01-3 (0)
  %=========================================
  if ~isfield(handles,'tgl_AnaStatus_Pre') ||  ...
      ~ishandle(handles.tgl_AnaStatus_Pre)
    % GUI for Hide
    handles.frm_AnaStatus=uicontrol(handles.figure1,...
      'Units','pixels','Position',[0 390 140 40],...
      'TAG','frm_AnaStatus',...
      'Style','text','Visible','off');
    %'Units','pixels','Position',[400 469 840 43],...
    % Make: Analysis-Status Toggle Button
    prop={'Units','pixels','style','toggle','Visible','off',...
      'BackgroundColor',[0.8 0.85 0.95],...
      'Callback','POTATo(''tgl_AnaStatus_Callback'',gcbo,[],guidata(gcbo))'};
    %pos= [9 392 42, 36];
    samesize=false;
    pos= [400 470 127, 20];
    if ~samesize
      pos(3) = 200;
    end
    handles.tgl_AnaStatus_Pre=uicontrol(handles.figure1,prop{:},...
      'String','Preprocess','Position',pos,...
      'TAG','tgl_AnaStatus_Pre');
    pos(1)=pos(1)+pos(3);
    if ~samesize
      pos(3)= 90;
    end
    handles.tgl_AnaStatus_1st=uicontrol(handles.figure1,prop{:},...
      'String','Summary',...
      'Position',pos,...
      'TAG','tgl_AnaStatus_1st');
    pos(1)=pos(1)+pos(3);
    if ~samesize
      pos(3)= 90;
    end
    handles.tgl_AnaStatus_2nd=uicontrol(handles.figure1,prop{:},...
      'String','Stat',...
      'Position',pos,...
      'TAG','tgl_AnaStatus_2nd');
    set(handles.frm_AnaStatus,'UserData',...
      [handles.tgl_AnaStatus_Pre,...
      handles.tgl_AnaStatus_1st,...
      handles.tgl_AnaStatus_2nd]);
  end

  %=========================================
  % Add File Number
  %  mail : 2011.02.10 16:08
  %=========================================
  try
    if ~isfield(handles,'txt_fileListNum') 
      % GUI for Hide
      handles.txt_fileListNum=uicontrol(handles.figure1,...
        'Units','pixels','Position',[108   372   111    13],...
        'TAG','txt_fileListNum',...
        'Style','text','Visible','off');
    end
  catch
  end
  
  % Help menu on
  if isfield(handles,'menu_Help') && ...
      ~isfield(handles,'menu_helphelp')
    hhelp= uimenu('Parent',handles.menu_Help,...
      'Label','&Help','TAG','menu_helphelp',...
      'Callback','POTATo_Help;');
    handles.menu_helphelp=hhelp;
  end
  
  guidata(hObject, handles); % Update handles structure
  
  try
    % Meeting on May-2007
    set(handles.menu_SearchProjectDir,'Visible','off');
  catch
    warning(lasterr);
  end
  btnh=findobj(handles.figure1,'Style','pushbutton');
  set(btnh,'BackgroundColor',get(handles.figure1,'Color'));
  setappdata(handles.figure1,'CurrentSelectFile',false);
  %=======================================>
  %  Adding GUI
  handles=P3_AdvMode_Init('make',handles);
  logmsg=OSP_DATA('GET','OSP_FILTER_WARNING');
  if ~isempty(logmsg)
    P3_AdvTgl_status('Logging',handles,...
      '---------------------','Plugin Warning:',...
      logmsg,'---------------------');
  end
  %<===========================================
  
  %----------------------------------------
  % Set hiPOTX/Simple/Normal/Advanced
  %----------------------------------------
  %==============================
  % Special.... (hiPOT-X-MODE)
  %==============================
  try
    % Check hiPOT-X MODE
    osp_path=OSP_DATA('GET','OspPath');
    if isempty(osp_path)
      osp_path=fileparts(which('POTATo'));
    end
    hipotxmode=false;
    if exist([osp_path filesep 'SimpleModeDir' filesep '.hiPotXMode'],'file')
      fid=fopen([osp_path filesep 'SimpleModeDir' filesep '.hiPotXMode'],'r');
      try
        hipotxpath=fgetl(fid);
        if exist(hipotxpath,'dir')
          hipotxmode=true;
        end
      catch
        fclose(fid);
        rethrow(lasterror);
      end
      fclose(fid);
    end
    if hipotxmode
      OSP_DATA('SET','HIPOTX_DATA_PATH',hipotxpath);
      OSP_DATA('SET','POTATO_HIPOTXMODE',true);
      set(handles.menu_simplemode,'Visible','off');
      %--------
      % Change by set MODE
      %--------
      ctrlhs=[handles.P3_MODE,...
        handles.menu_advmode,handles.menu_ProjectDirectory,...
        handles.menu_OpenProject, handles.menu_NewProject,...
        handles.menu_ModifyProject, handles.menu_CloseProject,...
        handles.menu_Bookmark_Filter,...
        handles.menu_DataImport handles.menu_DataDelete];
	ctrlhs=[ctrlhs, ...
		handles.menu_Edit,...
		handles.menu_Setting,...
		handles.menu_tools];
      set(ctrlhs,'Visible','off');
      P3_gui_SimpleMode('OpenProject',false);
      set(handles.menu_hiPOTXPrjUpdate,'Visible','on');
    else
      set(handles.menu_hiPOTXPrjUpdate,'Visible','off');   % confine
      set(handles.menu_simplemode,'Visible','on'); % confine
      OSP_DATA('SET','POTATO_HIPOTXMODE',false);
    end
  catch
    % hiPOTX-X-MODE: OFF 
    set(handles.menu_hiPOTXPrjUpdate,'Visible','off');   % confine
    set(handles.menu_simplemode,'Visible','on'); % confine
    set(handles.P3_MODE,'Visible','on');
    OSP_DATA('SET','POTATO_HIPOTXMODE',false);
  end

  %----------------------------------------
  % Start MODE Select
  %----------------------------------------
  p3mode=OSP_DATA('GET','POTATO_P3MODE');
  % defalult
  if isempty(p3mode) || isequal(p3mode,0), p3mode='Normal'; end
  if OSP_DATA('GET','POTATO_HIPOTXMODE'),p3mode='Normal'; end

  switch p3mode
    case 'Normal'
      menu_normalmode_Callback(handles.menu_simplemode,[],handles,false);
    case 'Research'
      menu_researchmode_Callback(handles.menu_researchmode,[],handles,false);
    case 'Developer'
      if (FOR_MCR_CODE)
        menu_normalmode_Callback(handles.menu_simplemode,[],handles,false);
      end
      menu_developersmode_Callback(handles.menu_advmode,[],handles,false);
    otherwise
      menu_normalmode_Callback(handles.menu_simplemode,[],handles,false);
      warning('[W] Unnkown MODE');
  end

  %----------------------------
  % Set Default Analysis State
  %----------------------------
  AnalysisState=getappdata(handles.figure1,'AnalysisSTATE');
  if isempty(AnalysisState),
    AnalysisState.mode=0;
    AnalysisState.function='POTATo_win_Empty';
    setappdata(handles.figure1,'AnalysisSTATE',AnalysisState);
  end
  
  %------------------------------------
  % Backup Data :: before changeing...
  %-----------------------------------
  prj=OSP_DATA('GET','PROJECT');
  
  %---------------------------
  % Reopen : Parent-Project 
  %---------------------------
  ChangeProjectParent(handles);
  
  %---------------------------
  % Reopen : Project 
  %---------------------------
  if ~isempty(p3ash) && ishandle(p3ash)
    s{end+1}='Open Project...';
    set(p3ash,'String',s);
    POTATo_About;
  end
  % for hiPTOX
  if OSP_DATA('GET','POTATO_HIPOTXMODE')
    OSP_DATA('SET','PROJECT',prj);
    menu_hiPOTXPrjUpdate(handles.menu_hiPOTXPrjUpdate,[],handles);
    % Update handles structure bug fix 20120925
    handles=guidata(hObject);
  else
    if ~isempty(prj)
      ChangeProject(handles,prj);
      % Update handles structure
      handles=guidata(hObject);
    end
  end

  %---------------------------  
  % Change Analsysis Mode
  %---------------------------  
  rcode=ChangeAnalysisMode(handles);
  % Update handles structure
  handles=guidata(hObject);
  if rcode,
    output.rcode=rcode.RCODE_ERROR;
    handles.output = output;
    guidata(hObject, handles); % Update handles structure
  end
end

%================================
%% Data UPdata
%================================
guidata(hObject, handles); % Update handles structure
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUT Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = POTATo_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% See Return Code & Set OUTPUT

%=====================
% OUTPUT Data Setting 
%=====================
if ~isempty(handles.output),
  output=handles.output;
  %---------------------
  % is Error?
  %---------------------
  if output.rcode>=2,
    % Delete POTATo
    delete(handles.output.hObject);
    handles.hObject=[];
  end
else
  % Error : 
  warning('[POTATo : System Error] *** POTATo NO-OUTPUT-DATA ***');
  try
    delete(hObject);
  catch
    warning('Close POTATo Error');
  end
  output.rcode  =rcode.SYSTEM_ERROR;
  output.hObject=[];
end

%=====================
%% Assign OUTPUT Data
%=====================
msg=nargoutchk(0,1,nargout);
if msg,warning(msg);end

% Set Handle
if nargout>=1,
  varargout{1}=output.hObject;
end

% Dumy OUTPUT
for idx=2:nargout,
  varargout{idx}=''; % Dumy Setting
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===========================================================
% Figure Close Request :Executes when user attempts to close POTATo.
function POTATo_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% Close Sub GUI
%  ( where we can cancel closing, normaly.)
%===========================================================

%---------------------
% -- Close Children --
try %#ok<TRYNC>
  % Save Data
  saveActiveData(handles);

  h=getappdata(handles.figure1,'SubGUI');
  if ~isempty(h),
    delete(h(ishandle(h)));
  end
  % help gui
  uihelp([],'close');
end
delete(hObject);

function POTATo_DeleteFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% --- Executes during object deletion, before destroying properties.
try %#ok<TRYNC>
  POTATo_ini_fin(2);   % Close :: Save-User-Data and so on.
  undostartup;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POTATo Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%====================================================================
% File Menu
%====================================================================
%---------------------------------
% Open Project
%---------------------------------
function psb_OpenProject_Callback(h,e,hs) %#ok<DEFNU>
menu_OpenProject_Callback(hs.menu_OpenProject, e, hs);
if 0,disp(h);end

function menu_OpenProject_Callback(hObject, eventdata, handles) %#ok<INUSL>
% Open Project

% Try to Save
saveActiveData(handles);

uiPOTAToProject('Action','Open');
prj=OSP_DATA('GET','PROJECT');
setappdata(handles.figure1,'CurrentSelectFile',true);
if ~isempty(prj)
  setappdata(handles.figure1,'CurrentSelectFile',false);
  ChangeProject(handles,prj);
end

%---------------------------------
% New Project
%---------------------------------
function psb_MakeProject_Callback(h,e,hs) %#ok<DEFNU>
menu_NewProject_Callback(hs.menu_NewProject, e, hs);
if 0,disp(h);end

function menu_NewProject_Callback(hObject, eventdata, handles) %#ok<INUSL>
% Make New Project

% Try to Save
saveActiveData(handles);

uiPOTAToProject('Action','New');
% Change Project!
prj=OSP_DATA('GET','PROJECT');
if ~isempty(prj)
  setappdata(handles.figure1,'CurrentSelectFile',false);
  ChangeProject(handles,prj);
end

%---------------------------------
% Close Project
%--------------------------------
function menu_CloseProject_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

% Try to Save
saveActiveData(handles);

OSP_DATA('SET','PROJECT',[]);
setappdata(handles.figure1,'CurrentSelectFile',false);
ChangeProject(handles);

%---------------------------------
% MergeProject
%---------------------------------
function menu_MergeProject_Callback(h,ev,hs) %#ok<INUSD,DEFNU>
P3_MergeProject0;
ChangeProject(hs);

%---------------------------------
% Modify Project
%---------------------------------
function menu_ModifyProject_Callback(hObject, ev, handles) %#ok<INUSD,DEFNU>

%---------------------------------
% Edit Project
%---------------------------------
function menu_propertty_Callback(hObject, ev, handles) %#ok<INUSL,DEFNU>

% Try to Save
saveActiveData(handles);

uiPOTAToProject('Action','Edit');
setappdata(handles.figure1,'CurrentSelectFile',true);
ChangeProject(handles);

%---------------------------------
% Delete Project
%---------------------------------
function menu_RemoveProject_Callback(h, ev, hs) %#ok<INUSL,DEFNU>
% Try to Save
saveActiveData(hs);
uiPOTAToProject('Action','Remove');
menu_CloseProject_Callback(hs.menu_CloseProject, ev, hs);


%---------------------------------
% Import Data
%---------------------------------
function psb_DataImport_Callback(h,e,hs) %#ok
menu_DataImport_Callback(hs.menu_DataImport,[],hs);

function menu_DataImport_Callback(hObject, ev, handles) %#ok
%h=signal_preprocessor;
% Open Preprocesor;
h=P3_preprocessor;
% ==> waint for closing Preprocessor.
set(h,'WindowStyle','modal')
uiwait(h);
if ~ishandle(handles.figure1),return;end
setappdata(handles.figure1,'CurrentSelectFile',true);
% ==> Project Data Reset!
renew_pop_filetype(handles);

%---------------------------------
% Delete Data
%---------------------------------
function menu_DataDelete_Callback(hObject, ev, handles) %#ok
%%setappdata(handles.figure1,'CurrentSelectFile',true);
% Check Open
prj=OSP_DATA('GET','PROJECT');
if isempty(prj),return;end

% Get Selected data
fileType= get(handles.pop_filetype,'UserData');
try
  fcn     = fileType{get(handles.pop_filetype,'Value')};
catch
  % no fcn
  return;
end
dtlist  = get(handles.lbx_fileList,'UserData');
val     = get(handles.lbx_fileList,'Value');

%-------------------------------
% Checking Unpopulated code...
%-------------------------------
% TODO : Unpopulated Function's
if any(strcmpi(fcn,...
    {'DataDef2_RawData',...
    'DataDef2_PreproPluginData'})),
  errordlg({fcn,'Delete Function is Unpopulated now'},...
    'P3 : Delete Error');
  return;
end

%----------------
% Execute Delete 
%----------------
% Enable Question Dilaog.
OSP_DATA('SET','ConfineDeleteDataSV',true);
% Data Loop
for idx=val(1:end),
  try
    switch fcn,
      case {'DataDef2_1stLevelAnalysis',...
          'DataDef2_Analysis',...
          'DataDef2_2ndLevelAnalysis',...
          'DataDef2_MultiAnalysis'},
        % Execute Delete Group
        feval(fcn,'deleteGroup',dtlist(idx));
      otherwise,
        errordlg({fcn,'Delete Function is Unpopulated now'},...
          'P3 : Delete Error');
    end
  catch
    errordlg(...
      {'Delete Error : ',...
      ['  Function : ' fcn],...
      ['  ' lasterr]},...
      'P3 : Delete Error');
  end
end

%------------
% Update list
%------------
% ==> Project Data Reset!
renew_pop_filetype(handles);
return;
function menu_hiPOTXPrjUpdate(h,ev,hs) %#ok
P3_gui_SimpleMode('hiPOTXPrjUpdate',hs);
ChangeProject(hs); %ChangeProject(hs,prj);

%---------------------------------
% Export Project
%---------------------------------
function menu_ExportProject_Callback(hObject, ev, handles) %#ok

% Try to Save
saveActiveData(handles);

uiPOTAToProject('Action','Export');
ChangeProject(handles);

%---------------------------------
% Import Project
%---------------------------------
function menu_ImportProject_Callback(hObject, ev, handles) %#ok

% Try to Save
saveActiveData(handles);

uiPOTAToProject('Action','Import');
ChangeProject(handles);

%--------------------------------------------------------------------------
function menu_ImportAir_Callback(hObject, eventdata, handles) %#ok
% Import Air Project
%--------------------------------------------------------------------------
AirData2P3Project;
% --> Import : to Refresh
ChangeProject(handles);


%====================================================================
% Edit Menu
%====================================================================
%---------------------------------
% Setting 
%---------------------------------
function menu_Setting_Callback(hObject, ev, handles) %#ok
function menu_diff_limits_Callback(hObject, eventdata, handles) %#ok
% Set Differency limits between Blocking.
flg=true;

lim=OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT');
while flg
  strlim=inputdlg({['Set ' ...
    OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT_TAG')]}, ...
    'Block  Setting : STIM DIFF LIMIT', ...
    1,{num2str(lim)});
  if isempty(strlim), return; end
  try
    lim=str2double(strlim{1});
    flg=false;
	catch
		errordlg(lasterr);
	end
end
OSP_DATA('SET','OSP_STIMPERIOD_DIFF_LIMIT',lim);


function menu_Bookmark_Filter_Callback(hObject, ev, handles) %#ok
% Edit Bookmark : 
flg=osp_FilterBookMark;
if ~flg,return;end
%- - - - - - - - -
%  refresh-Lists.
%- - - - - - - - -
OspFilterCallbacks('pop_FilterList_CreateFcn',...
  handles.pop_FilterList,ev,handles);
OspFilterCallbacks('pop_FilterDispKind_CreateFcn',...
  handles.pop_FilterDispKind,ev,handles);
%- - - - - - - - -
%   Draw-now
%- - - - - - - - -
OspFilterCallbacks('pop_FilterDispKind_Callback',...
  handles.pop_FilterDispKind,ev,handles);


function menu_EditFilterList_Callback(hObject, ev, handles) %#ok
% Select Effective Plugin's

flg=ui_FilterPluginSelector;
if ~flg,return;end
%- - - - - - - - -
%  refresh-Lists.
%- - - - - - - - -
OspFilterCallbacks('pop_FilterList_CreateFcn',...
  handles.pop_FilterList,ev,handles);
OspFilterCallbacks('pop_FilterDispKind_CreateFcn',...
  handles.pop_FilterDispKind,ev,handles);
%- - - - - - - - -
%   Draw-now
%- - - - - - - - -
OspFilterCallbacks('pop_FilterDispKind_Callback',...
  handles.pop_FilterDispKind,ev,handles);

%---------------------------------
% Set Project Parent Directory
%---------------------------------
function psb_ProjectDir_Callback(h,ev,hs) %#ok
menu_ProjectDirectory_Callback(hs.menu_ProjectDirectory, ev, hs)
if 0,disp(h);end
function menu_ProjectDirectory_Callback(h, ev, handles)
prjp = OSP_DATA('GET','PROJECTPARENT');
if isempty(prjp),
  prjp=pwd;
else
  % Try to Save
  saveActiveData(handles);
end
dir = uigetdir(prjp);
% Cancel Check
if isequal(dir,0),return;end 
% Change Project-Parent-Directory
ChangeProjectParent(handles, dir);
if 0,disp(h);disp(ev);end
return;

%---------------------------------
% Search Project Parent Directory
%---------------------------------
function menu_SearchProjectDir_Callback(hObject, ev, handles) %#ok
prjp = OSP_DATA('GET','PROJECTPARENT');
if ~isempty(prjp),
  % Try to Save
  saveActiveData(handles);
end
h=P3_searchPrj;
waitfor(h);
ChangeProject(handles);

% =====================================================================
% Menu : Setting/P3-Mode
%        2010_2_RA01-1 (4)
% =====================================================================
function r=menu_P3_MODE_OFF(h,hs)
% menu-P3 MODE OFF 

% Check 
r=strcmpi(get(h,'Checked'),'on');
if r, return; end
% OFF All DATA
menu_normalmode_off(hs);
menu_researchmode_off(hs)
menu_developersmode_off(hs)

% Close othere
uihelp([],'close');

%----------------------------------------------------------------
%  Normal
%----------------------------------------------------------------
function menu_normalmode_Callback(h,ev,hs,eflg) %#ok
% Change to Normal-MODE
if nargin<=3,eflg=true;end

% Other MODE MODE Must be "OFF"
if (menu_P3_MODE_OFF(h,hs))
  return;
end

% <<=== Change to Simple Mode ===>>
set(h,'Checked','on');
OSP_DATA('SET','POTATO_P3MODE','Normal');
P3_AdvTgl_status('Logging',hs,'[Normal Mode] : Start.');
changePOTAToWinColor(hs,[0.7529    0.7529    0.7529]);
n='Open PoTATo: Open Platform of Transparent Analysis Tools for fNIRS ';
set(hs.figure1,'Name',n);

% Simple Menu-Rehash
try
  P3_gui_SimpleMode('pop_SIMPLE_recipe_rehash',hs); % Rehash
catch
  disp(C__FILE__LINE__CHAR); % ... error
end

% SELECT FILE
if eflg
  setappdata(hs.figure1,'CurrentSelectFile',true);
  renew_pop_filetype(hs);
end


function menu_normalmode_off(hs)
% <<=== Change to Advenced Mode ===>>
set(hs.menu_simplemode,'Checked','off');


%----------------------------------------------------------------
%  Research MODE
%----------------------------------------------------------------
function flg=menu_researchmode_Callback(h,ev,hs,eflg) %#ok
% Change to Normal-Research
if nargin<=3,eflg=true;end

% Other MODE MODE Must be "OFF"
if (menu_P3_MODE_OFF(h,hs))
  return;
end

% <<=== Change to Research Mode ===>>
set(h,'Checked','on');
OSP_DATA('SET','POTATO_P3MODE','Research');
P3_AdvTgl_status('Logging',hs,'[Research Mode] : Start.');
changePOTAToWinColor(hs,[0.9 0.95 1]);
n='[Research] Open PoTATo: Open Platform of Transparent Analysis Tools for fNIRS ';
set(hs.figure1,'Name',n);

% SELECT FILE
if eflg
  setappdata(hs.figure1,'CurrentSelectFile',true);
  renew_pop_filetype(hs);
end

%------------------------------------
% Special-Case : Open Status-Toggle
%        2010_2_RA01-3 (1)
%------------------------------------
try
  h0=hs.frm_AnaStatus;
  h1=get(h0,'UserData');
  set([h0, h1],'Visible','on');
  vs=cell2mat(get(h1,'Value'));
  hh=h1(vs==1); 
  if isempty(hh), hh=h1(1); end % Default : Pre
  tgl_AnaStatus_Callback(hh(1),[],hs);
catch
  % This Status might be never executed.
  warning('Open Analysis Status Toggle Error(2010_2_RA01-3)');
end

% %======================
% %- SHOW WARNING MESSAGE 
% msg=sprintf('"Research mode" is still UNSTABLE.\nPlease be careful when using this mode.\n(2011-06-01)');
% warndlg(msg,'Research mode warning','modal');
%----commented TK@CRL 2012-12-11 


function menu_researchmode_off(hs)
% Off Research-Mode
set(hs.menu_researchmode,'Checked','off');
%------------------------------------
% Special-Case : Close Status-Toggle
%        2010_2_RA01-3 (1)
%------------------------------------
try
  h0=hs.frm_AnaStatus;
  h1=get(h0,'UserData');
  set([h0, h1],'Visible','off');
catch
  % This Status might be never executed.
  warning('Open Analysis Status Toggle Error(2010_2_RA01-3)');
end


%----------------------------------------------------------------
%  Developers MODE
%----------------------------------------------------------------
function flg=menu_developersmode_Callback(h,ev,hs,eflg) %#ok
% Advanced Mode Selected
% eflg : execute Change Selecting-File
%        where eflg is true at default.
%        :: in opening mode, use flag=false
if nargin<=3,eflg=true;end

% Other MODE MODE Must be "OFF"
if (menu_P3_MODE_OFF(h,hs))
  return;
end

% <<=== Change to Simple Mode ===>>
set(h,'Checked','on');
OSP_DATA('SET','POTATO_P3MODE','Developer');
%OSP_DATA('SET','POTATO_ADVANCEDMODE',true);
P3_AdvTgl_status('Logging',hs,'[Developer] : Start.');
set(hs.tgl_AdvanceMode,'Value',true);  %OLD-CODE

%---------
% Real:: Color and change .
%---------
c=[0.8667    0.7176    0.7176];
changePOTAToWinColor(hs,c);
n='[Developer] Open PoTATo: Open Platform of Transparent Analysis Tools for fNIRS ';
set(hs.figure1,'Name',n);
set(adv_specialhs(hs),'Visible','on');

% Reslect
if eflg
  setappdata(hs.figure1,'CurrentSelectFile',true);
  renew_pop_filetype(hs);
end

function menu_developersmode_off(hs)
% Exit Developer MODE
set(hs.menu_advmode,'Checked','off');
set(hs.tgl_AdvanceMode,'Value',false); %OLD-CODE
%==========================
% Change Data-Type
%==========================
vl0=get(hs.lbx_fileList,'Value');
if vl0>2,vl0=1;end
set(hs.lbx_fileList,'Max',1,'Value',vl0);

%-------------------------
% OLD-MENU=CODE xxx NG xxx
%-------------------------
function flg=menu_simplemode(h,ev,hs,exeflag) %#ok
% Simple-Mode Selected
error('OLD CODE');

function flg=menu_AdvMode(hObject,ev,handles,exeflag) %#ok
% Advanced Mode Selected
error('OLD CODE');


%====================================================================
% Tool Menu
%====================================================================
function menu_EditLayout_Callback(h,ev,hs) %#ok
% Layout Editor (New)
lh=LayoutEditor;
lhs=guidata(lh);
LayoutEditor('menu_newLayout_Callback',lhs.menu_newLayout,[],lhs);
if 0,disp(h);disp(hs);disp(ev);end

function menu_ResetLayout_Callback(h,ev,hs) %#ok
% Layout Editor (New)
POTATo_win_Empty('ChangeLayout');
if strcmpi(get(hs.lbx_disp_fileList,'Visible'),'on')
  lbx_fileList_Callback(hs.lbx_fileList, [], hs);
end
if 0,disp(h);disp(ev);end

function menu_PositionSet_Callback(h,ev,hs) %#ok
% Launch Position-Setting
P3_AdvTgl_status('Logging',hs,'[Position Setting] : Open & waiting....');
h=setProbePosition;
waitfor(h);
setappdata(hs.figure1,'CurrentSelectFile',true);
P3_AdvTgl_status('Logging',hs,'[Position Setting] : Done');
POTATo('ChangeProject_IO',hs.figure1,[],hs);
if 0,disp(h);disp(hs);end

function menu_RepairProject(h,ev,hs) %#ok
% Open Repair Project
if 0,disp(h);disp(ev);end
uc_P3_ProjectManage;
setappdata(hs.figure1,'CurrentSelectFile',true);
ChangeProject(hs);

function psb_extended_search_Callback(h,ev,hs) %#ok
menu_data_Selector_Callback(hs.menu_data_Selector,ev,hs) %#ok
function menu_data_Selector_Callback(h,ev,hs) %#ok
% Open/Close Data-Selector
if 0,
  disp(ev);
  disp(' 2 : Open/Close');
  disp(C__FILE__LINE__CHAR);
end

% Launch-Check
ck=get(h,'Checked');

if strcmpi(ck,'off')
  c=get(hs.figure1,'Color');
  %--------------------------------
  % Launch Search (Extend) Window
  %--------------------------------
  ud.figh=P3_ExtendedSearch;
  if isempty(ud.figh)
    errordlg('No Data to search','Extended Search:Open');
    return;
  end
  set(h,'Checked','on','UserData',ud);
  subh=getappdata(hs.figure1,'SubGUI');
  subh(end+1)=ud.figh;
  setappdata(hs.figure1,'SubGUI',subh); % for Delete
  
  %- - - - - - - - - - -
  % Close Text-Search
  %- - - - - - - - - - -
  set(hs.txt_ExtendedSearchKey,'Visible','on'); % now popup
  set(hs.frm_maskSearchArea,'Visible','on','BackgroundColor',c);
  
  %--------------------------------------------------
  %  ++ Add for Resaerch 1st ++
  %--------------------------------------------------
  rflh=[];                        % Research-Mode 1st File-List
  if isfield(hs,'lbx_R1st_fileList')
    rflh=hs.lbx_R1st_fileList;
    if ~ishandle(rflh) || strcmpi('off',get(rflh,'Visible'))
      rflh=[];
    end
  end
  if ~isempty(rflh)
    P3_gui_Research_1st('pop_R1st_SummarizedDataList_Callback',hs);
  else
    searchtxt2extsearch(hs); % Search-Text => extend search
  end
  
  
elseif strcmpi(ck,'on')
  %--------------------------------
  % Close Search (Extend) Window
  %--------------------------------
  ud=get(h,'UserData');
  try
    delete(ud.figh);
    ud.figh=[];
  catch
  end
  set(h,'Checked','off','UserData',ud);
  %- - - - - - - - - - -
  % Re-Open Text-Search
  %- - - - - - - - - - -
  set([hs.txt_ExtendedSearchKey,hs.frm_maskSearchArea],'Visible','off');
  set(hs.edt_searchfile,'String','');
  %edt_searchfile_Callback(hs.edt_searchfile,[],hs);
  pop_filetype_Callback(0); % Reset Popup Menu;
  pop_filetype_Callback(hs.pop_filetype,[],hs);
  
end

%====================================================================
% Help Menu
%====================================================================
function menu_AboutPOTATo_Callback(hObject, ev, handles) %#ok
% About POTATo
ams=get(hObject,'UserData'); % About Menu is Open?
if ~isempty(ams)  && ishandle(ams),
  set(0,'CurrentFigure',ams);
  return; 
end

ver=OSP_DATA('GET','POTAToVersion');
if isempty(ver), ver='xxxx';end
if isnumeric(ver), ver=num2str(ver);end
try
  % If you want to change Color of "About OSP"
  % OSP_About('Ver',1.00, 'AddInfo',adinfo,'BgC',[0.8 .8 1]);
  oah=POTATo_About('Ver',ver);
  %oah=POTATo_About;
catch
  % Error : Easy Print
  oah=msgbox({'POTATo : ',...
      sprintf('                  Version %s',ver),...
      '(c) 2019,', ...
      '  National Institute of ', ...
      '  Advanced Industrial Science and Technology (AIST),', ...
      '  Powered By MATLAB (R)'},...
    'About POTATo');
end
%   AboutH       : [] or About OSP  Handle
% TODO : Sub-GUI-handles
% setappdata(handles.figure1,'AboutH',oah);
set(hObject,'UserData',oah); % About Menu is Open?

function str=get_ResearchStatus(hs)
% Get Status in Research Mode
% 2010_2_RA01-3
h0=hs.frm_AnaStatus;
h1=get(h0,'UserData');
vs=cell2mat(get(h1,'Value'));
hh=h1(vs==1);
if isempty(hh), hh=h1(1); end % Default : Pre
str=get(hh(1),'String');

function tgl_AnaStatus_Callback(h,ev,hs) %#ok
% Change Analysis-Status Toggle
% NOT Reentrant!!
persistent reent;

if ~isempty(reent) && reent
  % if re-entrant --> Do nothing
  if get(h,'Value')==0
    set(h,'Value',1);
  else
    set(h,'Value',0);
  end
  return;
end
reent=true; %#ok
try
  tgl_AnaStatus_Callback0(h,hs);
catch
end
reent=false;

function tgl_AnaStatus_Callback0(h,hs) 
% Change Analysis-Status Toggle
h0=hs.frm_AnaStatus;

h1=get(h0,'UserData');
try
  myid=h1==h;
  v=get(h1(myid),'Value');
  if (v==0), 
    set(h,'Value',1);
    return;  
  end
catch
end

%------------------
% Dinamic Size...
%------------------
pos= [400 470 127, 20];
lng = 200; shrt=90;
% Pre
ch=hs.tgl_AnaStatus_Pre;
if (h==ch)
  pos(3)=lng; vl=1;
  str='Preprocess';
else
  pos(3)=shrt; vl=0;
  str='Pre';
end
set(ch,'Position',pos,'String',str,'Value',vl);
pos(1)=pos(1)+pos(3);

% 1st
ch=hs.tgl_AnaStatus_1st;
if (h==ch)
  pos(3)=lng;vl=1;
  str='Summary Statistics Computation';
else
  pos(3)=shrt;vl=0;
  str='Summary';
end
set(ch,'Position',pos,'String',str,'Value',vl);
pos(1)=pos(1)+pos(3);

% 2nd
ch=hs.tgl_AnaStatus_2nd;
if (h==ch)
  pos(3)=lng; vl=1;
  str='Statistical Test';
else
  pos(3)=shrt;vl=0;
  str='Stat';
end
set(ch,'Position',pos,'String',str,'Value',vl);
%renew_pop_filetype(hs);

% Apply Extended Search
udx0=get(hs.menu_data_Selector,'UserData');

% backup
tmp=get(h,'UserData');
set(h,'UserData','CHANGING_ANALYSIS_STATUS');
try
  ChangeAnalysisMode(hs);
  
  % Apply Extended Search
  if (h~=hs.tgl_AnaStatus_1st)
    udx=get(hs.menu_data_Selector,'UserData');
    % Extended Search is enable?
    if ~isempty(udx0) && ~isempty(udx0.figh) && ishandle(udx0.figh)
      if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
        % is not edit-mode?
        hsp=guidata(udx.figh);
        P3_ExtendedSearch('pop_SOkey_Callback',hsp.pop_SOkey,[],hsp);
      end
    end
  end
catch
end
set(h,'UserData',tmp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROJECT & Data Control's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbx_ProjectInfo_Callback(hObject, ev, handles) %#ok
% Do nothing now

function pop_filetype_CreateFcn(hObject, ev, handles) %#ok
% Create File-Type popupmenu === Definition of File-Type in POTATo
set(hObject,'Visible','off');
return;

function renew_pop_filetype(handles)
% Thi function set File-Type according to 
% Current Project.

%==========================
%% Data Type Mode
%==========================
%data.str='Raw';
%data.fnc='DataDef2_Raw';
prj0=OSP_DATA('get','PROJECTPARENT');
prj=OSP_DATA('get','PROJECT');
old_val = get(handles.pop_filetype,'Value');

if ~isempty(prj0) && ~isempty(prj),
  data.str='Analysis';
  data.fnc='DataDef2_Analysis';
  
  %is-Addvancedmode
  if get(handles.tgl_AdvanceMode,'Value'),
    if 1
      data(end+1).str='Multi-Analysis';
      data(end).fnc  ='DataDef2_MultiAnalysis';
    end
    
    data(end+1).str='1st Level Analysis';
    data(end).fnc  ='DataDef2_1stLevelAnalysis';
    
    data(end+1).str='2nd Level Analysis';
    data(end).fnc  ='DataDef2_2ndLevelAnalysis';
  end
else
  data=[];
end

%==========================
% Get File List
%==========================
str2={};fnc2={};msg={' POTATo Error in Data-File :'};
flg=false;
for idx=1:length(data),
  try
    dlist = feval(data(idx).fnc,'loadlist');
    
    % Checking Pouupmenu List
    if ~isempty(dlist),
      if strcmp(data(idx).str,'1st Level Analysis'),
        flg=true;
      end
    elseif ~flg || ~strcmp(data(idx).str,'2nd Level Analysis')
      % Empty && 
      %  ( there is no 1st-lvl || no-2nd lvl)
      continue;
    end
    
    % Add Data
    str2{end+1}=data(idx).str;
    fnc2{end+1}=data(idx).fnc;
  catch
    msg{end+1}='  Data-Definition (2) Error :';
    msg{end+1}=['  ' lasterr];
  end
end
if length(msg)>1,
  errordlg(msg,'Potat Error');
end

%==========================
% Set File-Control GUI's
%==========================
hs0=[handles.edt_searchfile,...
  handles.txt_searchfile,...
  handles.lbx_disp_fileList,...
  handles.txt_fileList,...
  handles.pop_fileinfo,...
  handles.lbx_fileinfo,...
  handles.txt_fileinfo];
len=length(str2);
if len==0,
  set(handles.pop_filetype,...
    'Style','text',...
    'String',{'No-Data-Available.'},...
    'ListboxTop',1,...
    'Value',1,...
    'UserData',fnc2);
  if isempty(prj) || isempty(prj0),
    set(handles.pop_filetype,'Visible','off');
    set(handles.txt_filetype,'Visible','off');
    set(handles.psb_DataImport,  'Visible','off')
  else
    set(handles.pop_filetype,'Visible','on');
    set(handles.txt_filetype,'Visible','on');
    set(handles.psb_DataImport,  'Visible','on')
  end
  set(hs0, 'Visible', 'off');
elseif len==1,
  set(handles.pop_filetype,...
    'Style','text',...
    'String',str2,...   
    'Value',1,...
    'Visible','on',...
    'UserData',fnc2);
  set(handles.txt_filetype,'Visible','on');
  set(handles.psb_DataImport,  'Visible','off')
  set(hs0,'Visible', 'on');
else
  set(handles.pop_filetype,...
    'Style','popupmenu',...
    'String',str2,...
    'Value',1,...
    'Visible','on',...
    'UserData',fnc2);
  set(handles.txt_filetype,'Visible','on');
  set(handles.psb_DataImport,  'Visible','off')
  set(hs0,'Visible', 'on');
end

% --> same popup selected
if length(str2)>=old_val,
  set(handles.pop_filetype,'Value',old_val);
end
%=======================
% Select New File Type
%=======================
pop_filetype_Callback(0); % Reset Popup Menu;
pop_filetype_Callback(handles.pop_filetype,[],handles);

function pop_filetype_Callback(hObject, eventdata, handles) %#ok
% Change File-Type
persistent oldval;
if nargin==1,oldval=hObject;return;end

%----------------------
% Checking Reopen
%----------------------
val = get(hObject,'Value');
% Value was changed?
if ~isempty(oldval) && isequal(oldval,val),return;end

%----------------------
% Data Selection..
%----------------------
% Mak File List box :::
% ---> will be move filetype-select Callback!
datadef2=get(hObject,'UserData');
if ~isempty(datadef2),
  datadef2=datadef2{val};
  dlist = feval(datadef2,'loadlist');
  if isempty(dlist),
    % => Empty Data-List
    set(handles.lbx_fileList,...
      'Value',1, ...
      'String','No-Data Exist.', ...
      'UserData',{});
  else
    if isfield(dlist,'name'),
      fileliststr={dlist.name};
    elseif isfield(dlist,'filename'),
      fileliststr={dlist.filename};
    elseif isfield(dlist,'Tag'),
      fileliststr={dlist.Tag};
    elseif isfield(dlist,'Name'),
      fileliststr={dlist.Name};
    else
      fileliststr={'Unknown Tag Name', C__FILE__LINE__CHAR};
      dlist={};
    end
    set(handles.lbx_fileList,...
      'String',fileliststr, ...
      'Value',1, ...
      'UserData',dlist);
  end
else
  dlist={};
  set(handles.lbx_fileList,...
    'Value',1, ...
    'String','No-Data Exist.', ...
    'UserData',{});
end

% ==> Visible On/Off
htmp=[handles.lbx_disp_fileList,handles.txt_fileList];
if isempty(dlist)
  set(htmp,'Visible','off');
else
  set(htmp,'Visible','on');
end

%-----------------------
% Setting of Maximum
%-----------------------
% Update 2010_2_RA01-3 (2)
p3mode=OSP_DATA('GET','POTATO_P3MODE');
switch p3mode
	case 'Normal'
		if OSP_DATA('GET','POTATo_HIPOTXMODE')
			mx=1;
		else
			mx=10;
		end
  case 'Research'
    mx=10;
  case 'Developer'
    mx=10;
    str=get(hObject,'String');
    switch str{val},
      case {'Multi-Analysis','2nd Level Analysis'},
        mx=1;
    end
  otherwise
    mx=1;
end
set([handles.lbx_disp_fileList,handles.lbx_fileList],'Max',mx);

%----------------------
% Search-Extend Mode
%----------------------
udx=get(handles.menu_data_Selector,'UserData');
if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
  if 0
    disp(' 3 : Rest-Data-Category');
    disp(C__FILE__LINE__CHAR);
  end
  % Change Category
  hsp=guidata(udx.figh);
  P3_ExtendedSearch('changeDataCategoly',udx.figh,val,hsp);
  if ishandle(udx.figh)
    % Change Color
    c=get(handles.figure1,'Color');
    P3_ExtendedSearch('changeColor',udx.figh,c,hsp);
    % Change Visible of Key-Text
    if strcmpi('DataDef2_2ndLevelAnalysis',datadef2)
      set(handles.txt_ExtendedSearchKey,'Visible','off');
    else
      set(handles.txt_ExtendedSearchKey,'Visible','on');
    end
  end
end

%----------------------
% Change Data Selection
%----------------------
if 0
  reset_lbx_disp_fileList2(handles);
else
  reset_lbx_disp_fileList(handles);
end
rcode=lbx_disp_fileList_Callback(handles.lbx_disp_fileList, [], handles);
if rcode~=0, set(hObject,'Value',oldval);return;end
oldval=val;



function reset_lbx_disp_fileList2(handles)
% Value & Serch Key is not change..
vl=get(handles.lbx_disp_fileList,'Value');
edt_searchfile_Callback(handles.edt_searchfile, [], handles,false);
st=get(handles.lbx_disp_fileList,'String');
vl(vl==0)=[];vl(vl>length(st))=[];
mx=get(handles.lbx_disp_fileList,'Max');
if length(vl)>mx, vl=vl(1:mx); end
if ~isempty(vl)
  set(handles.lbx_disp_fileList,'Value',vl);
end  


%==========================================================================
function reset_lbx_disp_fileList(handles)
% Reset Listbox named "Display-File"
%==========================================================================
dflh=handles.lbx_disp_fileList;
flh =handles.lbx_fileList;
set(handles.edt_searchfile,'String','');
% --> String : Copy
set(dflh,'String',get(flh,'String'));
ud=get(flh,'UserData');
if isempty(ud)
  set(flh ,'Visible','off');
  set(dflh,'Visible','off');
else
  set(dflh,'Visible','on');
  set(dflh,'UserData',1:length(ud),'Value',1);
end

%==========================================================================
function rcode=lbx_disp_fileList_Callback(hObject, ev, handles,newstr)
% Display : File List 
%==========================================================================

% persistent h;
% persistent myque;
% if isempty(h) || ~ishandle(h)
%   h=uicontrol('Visible','off','UserData',false);
%   myque  =0;
% end

% Change...
rcode=0;
if nargin>=4,
  lbx_fileList_Callback(handles.lbx_fileList, ev, handles,newstr);
  return;
end

%---------------
% Lock
%---------------
% myque = myque+1; % Grown-up
% if myque>100000,myque=0;end
% myid=myque; % Number of myid
% waitfor(h,'UserData',false);
% % Execute Last Input --> run
% if (myque~=myid),dixp('xx');return;end
% 
% set(h,'UserData',true);

%----------------
% Real..File Reserect!
%---------------
vl=get(hObject,'Value');
id=get(hObject,'UserData');
vl(max(vl(:))>length(id))=[];
if isempty(vl)
  set(hObject,'Value',1);
else
  set(hObject,'Value',vl);
end
set(handles.lbx_fileList, 'Value',id(vl));
rcode=lbx_fileList_Callback(handles.lbx_fileList, ev, handles);

%---------------
% Unlock
%---------------
% set(h,'UserData',false);

%==========================================================================
function rcode=lbx_fileList_Callback(hObject, ev, handles,newstr) %#ok
% Data Selection
persistent oldstring;
% Meeting on 20-Apr-2007 : 2.3 (for Popup-Value)
persistent oldval;
%==========================================================================

% --> for setting
if nargin>=4, oldstring=newstr;return;end

strs=get(hObject,'String');
% ==> Current Select File : to Redraw.
if getappdata(handles.figure1,'CurrentSelectFile') && ...
    ~isempty(oldstring) && ischar(oldstring)
  vl=find(strcmp(strs,oldstring));
  if ~isempty(vl),
    if get(hObject,'Max')>1
      set(hObject,'Value',vl);
    else
      set(hObject,'Value',vl(1));
    end
  end
  %--> Reselect !!
  setappdata(handles.figure1,'CurrentSelectFile',false);
  strs0= get(handles.lbx_disp_fileList,'String');
  vl0  = find(strcmp(strs0,oldstring));
  if length(vl)~=length(vl0)
    set(handles.edt_searchfile,'String','');
    edt_searchfile_Callback(handles.edt_searchfile,[],handles);
    rcode=0;
    return;
  end
  if ~isempty(vl0)
    set(handles.lbx_disp_fileList,'Value',vl0);
  end
end
setappdata(handles.figure1,'CurrentSelectFile',false);

rcode=ChangeAnalysisMode(handles);
% For Reselect in Change Analysis Mode
if rcode==3,return;end
if rcode==2
  % Cancel to Change
  vl=find(strcmp(strs,oldstring));
  if ~isempty(vl),
    if get(hObject,'Max')>1
      set(hObject,'Value',vl);
    else
      set(hObject,'Value',vl(1));
    end
  end
  return;
end

% Get Function
id=get(hObject,'Value');
fnc=get(handles.pop_filetype,'UserData');
iseffectivedata=false;
if ~isempty(fnc)
  fnc=fnc{get(handles.pop_filetype,'Value')};
  st=get(hObject,'String');
  dl=get(hObject,'UserData');
  if length(dl)>=max(id(:)),
    try
      vl=1;
      if ~isempty(oldval)
        [tmp vl]=setdiff(id,oldval);
        if isempty(vl),
          vl=1;
        else
          vl=vl(1);
        end
      end
      oldval=id;
    catch
      disp(C__FILE__LINE__CHAR);
      disp(lasterr);
    end
    set(handles.pop_fileinfo,...
      'String',st(id),...
      'UserData',id,...
      'Value',vl);
    pop_fileinfo_Callback(handles.pop_fileinfo,[],handles,true);
    iseffectivedata=true;
  end
end
htmp=[handles.lbx_fileinfo,handles.pop_fileinfo,handles.txt_fileinfo];
if iseffectivedata
  set(htmp,'Visible','on');
else
  set(htmp,'Visible','off');
end

if ~isempty(id)
  if iscell(strs),
    oldstring=strs{id(1)};
  else
    oldstring=strs;
  end
end

function pop_fileinfo_Callback(hObject, eventdata, handles,wk)
% Show Information of File
% !!Warning !!
%   Default Callback bad in 1st-Lvl-Ana,
%   This Function is not Calback function.
if nargin>=4 && wk==true
  cb=get(hObject,'Callback');
  if strcmpi(cb(1:27),'POTATo_win_1stLevelAnalysis')
    POTATo_win_1stLevelAnalysis('pop_fileinfo_Callback',hObject, eventdata, handles);
    return;
  end    
end
fnc=get(handles.pop_filetype,'UserData');
fnc=fnc{get(handles.pop_filetype,'Value')};
id =get(hObject,'UserData');
id =id(get(hObject,'Value'));
dl =get(handles.lbx_fileList,'UserData');
vl =get(handles.lbx_fileinfo,'Value');
str=feval(fnc,'showinfo',dl(id));
if length(str)<vl,vl=length(str);end
set(handles.lbx_fileinfo,...
  'Value',vl,'String',str);

%==========================================================================
% Search Execution..
%==========================================================================
function edt_searchfile_Callback(hObject, ev, handles,flag)
% Search Matching Files
%    Modify Meeting on 16-Nov-2007
%--------------------------------------------------------------------------
if 0,disp(ev);end
if nargin<3
  handles=guidata(hObject);
end
dflh=handles.lbx_disp_fileList; % Display-File-List
flh =handles.lbx_fileList;      % Effective File-List
rflh=[];                        % Research-Mode 1st File-List
if isfield(handles,'lbx_R1st_fileList')
  rflh=handles.lbx_R1st_fileList;
  if ~ishandle(rflh) || strcmpi('off',get(rflh,'Visible'))
    rflh=[];
  end
end

ss=get(hObject,'String'); % Search-Patern Strings
if isempty(rflh)
  fl=get(flh,'String');
  if ~isempty(ss)
    p=strfind(ss,' ');
    p0=1;
    vl=1:length(fl);
    %---------------------------
    % Loop : Search Pattern List
    %---------------------------
    for idx=1:length(p)+1
      % Search Matching-Data

      % Warning for programmer:
      %   REGEXP : use format of MATLAB 6.5.1.
      %   ( Check Output format in 6.5.1)
      if p0>length(ss),break;end
      if idx==(length(p)+1)
        s = regexpi(fl(vl),ss(p0:end));
      else
        s = regexpi(fl(vl),ss(p0:p(idx)-1));
        p0=p(idx)+1;
      end
      if iscell(s)
        vl=vl(~cellfun('isempty',s));
      else
        if isempty(s)
          vl=[];
        else
          vl=vl(s);
        end
      end
      % -- (&) --
      %vl=intersect(vl,vl0);
      if isempty(vl),break;end
    end

    %----------------------------------
  else
    vl=1:length(fl);
  end

  set(dflh,'Value',1,'UserData',vl);
  if isempty(vl),
    % No Match
    set(dflh,'String',{'No - Match Files'});
  else
    % Exist
    set(dflh,'String',fl(vl));
  end
  
  if nargin<4 || flag
    try
      % Select All: 2010_2_RA06-2
      as=getappdata(handles.figure1,'AnalysisSTATE');
      if as.mode==54
        set(dflh,'Value',1:length(vl));
      end
    catch
    end
    lbx_disp_fileList_Callback(dflh,[],handles);
  end
else
  % Research-Mode 1st (New)
  try
    % Get Summarized Data Information
    mydata=get(handles.psb_R1st_RecipeCheck,'UserData');
    mydata=mydata.Default;

    vl=1:length(mydata.StringDisplay);
    % Search-Patern Strings
    if ~isempty(ss)
      p=strfind(ss,' ');
      p0=1;
      %---------------------------
      % Loop : Search Pattern List
      %---------------------------
      for idx=1:length(p)+1
        % Search Matching-Data
        
        % Warning for programmer:
        %   REGEXP : use format of MATLAB 6.5.1.
        %   ( Check Output format in 6.5.1)
        if p0>length(ss),break;end
        if idx==(length(p)+1)
          s = regexpi(mydata.StringFiles(vl),ss(p0:end));
        else
          s = regexpi(mydata.StringFiles(vl),ss(p0:p(idx)-1));
          p0=p(idx)+1;
        end
        if iscell(s)
          vl=vl(~cellfun('isempty',s));
        else
          if isempty(s)
            vl=[];
          else
            vl=vl(s);
          end
        end
        % -- (&) --
        %vl=intersect(vl,vl0);
        if isempty(vl),break;end
      end
    end      
    if isempty(vl)
      set(rflh,'Value',1,...
        'String','No Match Files',...
        'UserData',[2 -1]);
    else
      set(rflh,'Value',1:length(vl),...
        'String',mydata.StringDisplay(vl),...
        'UserData',mydata.UserData(:,vl));
    end
    if nargin<4 || flag
      P3_gui_Research_1st('lbx_R1st_fileList_Callback',handles);
    end
  catch
  end
end

%--------------------------------------------------------------------------
function searchfile_ext_Callback(hObject, mylist, handles,flag) %#ok
% Search Matching Files Extend
%--------------------------------------------------------------------------
dflh=handles.lbx_disp_fileList; % Display-File-List
flh =handles.lbx_fileList;      % Effective File-List
% - - - - - - - - - - - - - - - - - - - - - - - -
% for Research-Mode 1st-Edit State
% - - - - - - - - - - - - - - - - - - - - - - - -
rflh=[];                        % Research-Mode 1st File-List
if isfield(handles,'lbx_R1st_fileList')
  rflh=handles.lbx_R1st_fileList;
  if ~ishandle(rflh) || strcmpi('off',get(rflh,'Visible'))
    rflh=[];
  end
end

if ~isempty(rflh)
  if nargin<=3
    flag=false;
  end
  P3_gui_Research_1st('ext_search',handles,mylist,flag);
  return
end

% - - - - - - - - - - - - - - - - - - - - - - - -
% Update Display List
% - - - - - - - - - - - - - - - - - - - - - - - -
fl=get(flh,'String');
if ~isempty(mylist)
  vl=[];
  list=mylist.data;
  %---------------------------
  % Loop : Search Pattern List
  %---------------------------
  for idx=1:length(list)
    % Search Matching-Data
    addid=find(strcmp(list{idx},fl));
    if ~isempty(addid)
      vl(end+1)=addid;
    end
  end
  %----------------------------------
  fl2    = mylist.str;
else
  vl=1:length(fl);
end

% Select Value (after search)
vl0=get(dflh,'Value');
set(dflh,'UserData',vl);
%set(dflh,'Value',1,'UserData',vl);
if isempty(vl),
  % No Match
  set(dflh,'Value',1,'String',{'No - Match Files'});
else
  % Exist
  if exist('fl2','var')
    vl0(vl0>length(fl2))=[];if isempty(vl0),vl0=1;end
    set(dflh,'Value',vl0,'String',fl2);
  else
    vl0(vl0>length(fl))=[];if isempty(vl0),vl0=1;end
    set(dflh,'Value',vl0,'String',fl(vl));
  end
end
if nargin<4 || flag
  try
    % Select All: 2010_2_RA06-2
    as=getappdata(handles.figure1,'AnalysisSTATE');
    if as.mode==54
      % Meeting on 2011.01.14
      ck=get(handles.tgl_AnaStatus_1st,'USERDATA');
      if ~strcmp(ck,'CHANGING_ANALYSIS_STATUS')
        set(dflh,'Value',1:length(vl));
      end
    end
  catch
  end
  lbx_disp_fileList_Callback(dflh,[],handles);
end

%--------------------------------------------------------------------------
function ExtendedSearchKey_keypoupuCB(h,ev,hs) %#ok
% Callback : popupmenu..
%  parent: uicontrol
%--------------------------------------------------------------------------
udx=get(hs.menu_data_Selector,'UserData');
if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
  v=get(h,'Value');
  hsp=guidata(udx.figh);
  set(hsp.pop_SOkey,'Value',v);
  P3_ExtendedSearch('pop_SOkey_Callback',hsp.pop_SOkey,[],hsp);
  figure(udx.figh);
end

%--------------------------------------------------------------------------
function searchtxt2extsearch(hs) 
% Search --> Extend Search
% since 2011.04.20
%--------------------------------------------------------------------------
st=get(hs.edt_searchfile,'String');
if isempty(st), return;end % do nothing
if iscell(st),st=st{1};end

try
  % Check Extended Search..
  udx=get(hs.menu_data_Selector,'UserData');
  if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
    sep=strfind(st,' ');nsep=length(sep)+1;
    idkey=DataDef2_Analysis('getIdentifierKey'); % (filename)
    % - - - - - - - - - - - - - - - - - -
    % Make-Search-Key
    % - - - - - - - - - - - - - - - - - -
    skey.Type ='Bracket';
    skey.Relop='And';
    skey.Not  =0;
    skey.list   =cell([1, nsep]);
    so.Type   = 'SearchOption';
    so.Relop  = 'And';
    so.Not    = 0;
    so.String = '';
    so.key    =idkey;
    so.KeyType='Text';
    so.SortType='Regexp';
    so.SortValue='';

    ini=1;
    for ii=1:nsep-1
      tmp=st(ini:sep(ii)-1);
      ini=sep(ii)+1;
      so.String = tmp;
      so.SortValue=so.String;
      skey.list{ii}=so;
    end
    tmp=st(ini:end);
    so.String = tmp;
    so.SortValue=so.String;
    skey.list{nsep}=so;

    % - - - - - - - - - - - - - - - - - - 
    % Apply SerKey to P3-Extended Search
    % - - - - - - - - - - - - - - - - - - 
    hsp=guidata(udx.figh);
    P3_ExtendedSearch('UpdateSearchKey',hsp.figure1,{skey},hsp);
  end
catch
  errordlg({'Extended Search Error:', lasterr},'Extended Searc');
end

set(hs.edt_searchfile,'String','');

%==========================================================================
% CHANGE Project
%==========================================================================
function ChangeProjectParentIO(h,p,handles) %#ok
ChangeProjectParent(handles, p)

function ChangeProjectParent(handles, PTH)
% Check parent-directory..
% and Reset State of POTATo GUI.
global WinP3_EXE_PATH;

%==================================
% Try to Save
%==================================
saveActiveData(handles);

%==================================
% Check Path & Set Path OSP_DATA
%==================================
if exist('PTH','var'),
  % Set OSP-Data
  OSP_DATA('SET', 'PROJECTPARENT', PTH);
else
  % Get Current Path
  PTH=OSP_DATA('GET', 'PROJECTPARENT');
end
%-- Loging --
OSP_LOG('msg',...
  sprintf(['=======================================\n',...
  ' Project-Parent-Directory was changed \n',...
  '     : %s\n',...
  '=======================================\n'],PTH));

if isempty(PTH)
	if isempty(WinP3_EXE_PATH)
		p=fileparts(which('POTATo'));
	else
		p=WinP3_EXE_PATH;
	end
	PTH= [p filesep 'Projects'];
	OSP_DATA('SET', 'PROJECTPARENT',PTH);
	uc_P3_ProjectManage('Fix Path');
end

if ~isempty(PTH) && ~exist(PTH,'dir'),
  %--------------------------------------
  % if no Project-Path exist on this HDD,
  %    Set Empty and Continue Setting...
  %--------------------------------------
  PTH='';
  OSP_DATA('SET', 'PROJECTPARENT', '');
  warndlg({...
      'POTATo-Directory : No Such a Directory ',...
      ['                   ' PTH],...
      '                   POTATo Make Path Empty.'},...
      'Path Setting Error : xxxxxx');
end

%=====================
% Initialize Menu
%=====================
% TODO: List up!
mh=[handles.menu_ModifyProject,...
  handles.menu_NewProject,...
  handles.menu_DataImport,...
  handles.menu_DataDelete,...
  handles.menu_OpenProject, ...
  handles.menu_OpenProject,...
  handles.menu_CloseProject];
if isempty(PTH),
  set(handles.psb_ProjectDir,'Visible','on');
  set(mh,'Enable','off');
else
  set(handles.psb_ProjectDir,'Visible','off');
  set(mh,'Enable','on');
end

%==================================
% Check Path & Set Path OSP_DATA
%==================================
OSP_DATA('SET', 'PROJECT',''); % Make Project Empty!
ChangeProject(handles);

function ChangeProject_IO(hObject,ev,handles, prj) %#ok
% ==> External I/O for Callback
if nargin<=3,
  ChangeProject(handles);
elseif nargin<=4,
  % Try to Save
  saveActiveData(handles);

  % Change Project
  ChangeProject(handles, prj);
end
function ChangeProjectIO(h,ev,handles) %#ok
% Try to Save
saveActiveData(handles);
ChangeProject(handles);
function ChangeProject(handles, prj)
% Check Project
% and Reset State of POTATo GUI.
global FOR_MCR_CODE;

%==================================
% Get Argument: Project
%==================================
if ~exist('prj','var'),
  % Get Current Path
  prj=OSP_DATA('GET', 'PROJECT');
else
  OSP_DATA('SET', 'PROJECT',prj);
end
%-- Logging --
if isempty(prj),
  OSP_LOG('msg',...
    sprintf(['=== Project is changinge ===\n',...
    '     : "Empty"']));
else
  OSP_LOG('msg',...
    sprintf(['=== Project is changinge ===\n',...
    '     : %s'],prj.Name));
  % Logging 2
  P3_Project_History('open');
end

%--> Air Reload/Check
LastAirProject('CheckIn');

%==================================
% Check Project-Parent
%==================================
pth=OSP_DATA('GET', 'PROJECTPARENT');
if isempty(pth) || ~exist(pth,'dir'),
  %--------------------------------------
  % if no Project-Path exist on this HDD,
  %--------------------------------------
  %if ~isempty(prj),
  p=fileparts(which('POTATo'));
  help_html=[p filesep 'OspData' filesep 'Help_ProjectDirectory.htm'];
  if exist(help_html,'file') 
    if ~FOR_MCR_CODE
      helpview(help_html);
    else
      eval(['!' help_html]);
    end
  else
    hh=helpdlg(...
      { '                 Welcome to Platform 3',...
        ' -- Open PoTATo: Open Platform of Transparent Analysis Tools for fNIRS  --',...
        ' Start by selecting Project-Directory.', ...
        '  To Select Project-Directory,',...
        '  Please select ''Edit'' -> ''Project Directory'' from menu'},...
      'Welcome to Platform 3');
    waitfor(hh);
  end
  pth='';prj='';

end

%=============================================
% Check Consistent : Project-Parent & Project
%=============================================
if ~isempty(prj),
  try
    %-----------------
    % Get Project-List
    %-----------------
    projectListFile=[pth filesep 'ProjectData.mat'];
    load(projectListFile, 'ProjectData');
    if exist('ProjectData','var')
      plist={ProjectData.Name};
    end
    if all(strcmp(prj.Name, plist)==0),
      error('No much Project.');
    end
  catch
    prj='';
    OSP_DATA('SET', 'PROJECT',prj);
    errordlg(...
      {'POTATo : Project-Consistent Check Error',...
      '          in getting Project Data',...
      lasterr},...
      'POTATo Error');
  end
end

%=====================
% Initialize Menu
%=====================
% TODO: List up!
mh=[handles.menu_DataImport,...
    handles.menu_DataDelete,...
    handles.menu_CloseProject,...
    handles.menu_ModifyProject];
%,...handles.menu_property,...
%  handles.menu_ExportProject];
mh2=[handles.psb_OpenProject,handles.psb_MakeProject];
if isempty(prj),
  if ~isempty(pth)
    set(mh2,'Visible','on');
    Project=POTAToProject('LoadData');
    if isempty(Project)
      set(mh2(1),'Visible','off');
    end      
  end
  set(mh,'Enable','off');
else
  set(mh2,'Visible','off');
  set(mh,'Enable','on');
end

%=====================
% Initialize Data
%=====================
% TODO: List up!
mh=handles.menu_CloseProject;
if isempty(prj),
  set(mh,'Enable','off');
else
  set(mh,'Enable','on');
end

%=====================
% Vislble of Project
%=====================
try
  set(handles.lbx_ProjectInfo,...
    'String',POTAToProject('Info'));
catch
  set(handles.lbx_ProjectInfo,...
    'String',lasterr);
end
hs0=[handles.lbx_ProjectInfo,handles.txt_ProjectInfo];
if isempty(prj),
  % Change Project-Open window
  set(hs0, 'Visible', 'off');
  P3_AdvTgl('SuspendAll',handles);
else
  %=====================
  % Initialize Menu
  %=====================
  set(hs0,'Visible', 'on');
  set(handles.advtgl_status,'Value',0);
  P3_AdvTgl('ChangeTgl',handles.advtgl_status,handles);
end

%================================================
% File - Data - Type Selection
%================================================
renew_pop_filetype(handles)

%================================================
%  Old-version check
%================================================
if ~isempty(prj)
  try
    % isempty Project?
    x=DataDef2_RawData('loadlist');
    if ~isempty(x) 
      f=FileFunc('getRelationFileName');
      s=load(f);
      if ~isfield(s,'Relation')
        disp('############################################################')
        disp('## PROJECT FORMAT TRANSFER (3.2X to 3.3)                 ###')
        disp('############################################################')
        uc_P3_ProjectManage('CheckRelation');
      end
    end
  catch
    errordlg({'Old-Version Transfer Error',...
      '  Please Execute Project-Repair (Tool-menu)'},...
      'P3 Project-Format Transfer Error');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis Area Controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h_adv_visible=adv_specialhs(hs)
% Advanced-Mode Special Visible on/off Control Handles
%  ON  : In tgl_AdvanceMode_Callback
%  Off : File Select
h_adv_visible=[...
  hs.psb_export_workspace,...
  hs.psb_MakeMfile,...
  hs.ckb_Draw,...
  hs.psb_EditLayout];

function changePOTAToWinColor(handles,c)
% Change Color
h=findobj(handles.figure1,'style','text');
h(end+1)=handles.frm_AnalysisArea;
h(end+1)=handles.frm_draw;
h2=findobj(handles.figure1,'style','Checkbox');
h=[h(:); h2(:)];
set(h,'BackgroundColor',c);
% Other -- try to 
try
  set(handles.advfrm,'BackgroundColor',c);
end
if 1
  try
    h0=findobj(handles.figure1,'style','togglebutton');
    tg=get(h0,'TAg');
    set(h0(strmatch('advtgl_',tg)),'BackgroundColor',c);
  end
end
set(handles.figure1,'Color',c);
set(handles.pop_filetype,'BackgroundColor',[1 1 1]);

function tgl_AdvanceMode_Callback(hObject, ev, handles,exeflag) %#ok
% Advanced Mode On/Off
error('OLD CODE');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis Area Controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcode=ChangeAnalysisModeIO(h,ev,handles) %#ok
rcode=ChangeAnalysisMode(handles);
function rcode=ChangeAnalysisMode(handles)
% Change Analysis Mode Control
%disp('------------------------------------------------');
rcode=0;
%==================================
% Get P3-MODE
%==================================
p3mode=OSP_DATA('GET','POTATO_P3MODE');

%==================================
% Get Analysing State
%==================================
as=getappdata(handles.figure1,'AnalysisSTATE');
if isempty(as),
  as.mode=0;
  as.function='POTATo_win_Empty';
end

%==================================
% Save Modifyed Data
%==================================
ad=getappdata(handles.figure1,'ActiveDataModSTATE');
if ~isempty(ad) && ad==true,
  try
    msg=feval(as.function,'SaveData',handles);
    if msg,
      a=questdlg({'Save-Data: Error Occur',...
        ['msg : ' msg],...
        '',...
        ' Do you want to continue Change Status?'},...
        'Error Occur',...
        'Yes','No','Yes');
      if strcmp(a,'No'),
        rcode=2;
        return;
      end
    end
  catch
    disp(lasterr);
    disp(['TODO : Save Active Data!' C__FILE__LINE__CHAR]);
  end
end
%----------------------------
% Reset : Modify Flag.
%----------------------------
setappdata(handles.figure1,'ActiveDataModSTATE',false);

%==================================
% Suspend : Analysis-Mode
%==================================
try
  feval(as.function,'Suspend',handles);
catch
  disp(lasterr);
  disp(['TODO : MOVE Function!' C__FILE__LINE__CHAR]);
end

%==================================
% Advanced Mode Change
%==================================
try
  feval(as.function,'DisConnectAdvanceMode',handles);
catch
  disp(lasterr);
  disp(['TODO : Disconnect Advanced Mode!' C__FILE__LINE__CHAR]);
end

%==================================
% Select Analysis State!
%==================================
if strcmpi(get(handles.pop_filetype,'Visible'),'off') || ...
  isempty(OSP_DATA('get','Project')) || ...
    isempty(OSP_DATA('get','PROJECTPARENT')),
  %-----------------------------
  % No Analysis-Mode
  %-----------------------------
  as.mode=0;
  as.function='POTATo_win_Empty';
else
  try
    switch p3mode
      case 'Normal'
        %******************************
        % Change Normal Mode Status
        % 2010-RA01-2 (2)
        %******************************
        dataid  =get(handles.lbx_fileList,'Value');
        dataud  =get(handles.lbx_fileList,'UserData');
        if isempty(dataud),dataid=[];end
        if isempty(dataid) || (length(dataid)==1 && dataid==0)
          as.mode=0;
          as.function='POTATo_win_Empty';
        else
          % Check Number of Data.
          if length(dataid)==1
            % Single-Mode
            as.mode=41;
            as.function='POTATo_win_Normal_Single';
          else
            as.mode=42;
            as.function='POTATo_win_Normal_Group';
          end
        end
      case 'Research'
        %******************************
        % Change Research Mode Status
        % 2010-RA01-2 (2)
        %******************************
        stat1=get_ResearchStatus(handles);
        switch stat1
          case {'Pre','Preprocess'}
            dataid  =get(handles.lbx_fileList,'Value');
            dataud  =get(handles.lbx_fileList,'UserData');
            if isempty(dataud),dataid=[];end
            dataid(dataid==0)=[];
            if (isempty(dataid))
              as.mode=0;
              as.function='POTATo_win_Empty';
            elseif (length(dataid)==1)
              as.mode=51;
              as.function='POTATo_win_Research_PreSingle';
            else
              % 2010-RC01-1
              % Check Recipe
              fcn=get(handles.pop_filetype,'UserData');
              fcn=fcn{get(handles.pop_filetype,'Value')};
              ll=length(dataid);
              issamerecipe=true;
              tmp1=feval(fcn,'load',dataud(dataid(1)));
              rcp1=tmp1.data.filterdata;
              for ii=2:ll
                tmp2=feval(fcn,'load',dataud(dataid(ii)));
                try
                  if ~isequal(rcp1,tmp2.data.filterdata)
                    issamerecipe=false;
                    break;
                  end
                catch
                  issamerecipe=false;
                  break;
                end
              end
              if issamerecipe
                as.mode=53;
                as.function='POTATo_win_Research_PreBatch';
              else
                as.mode=52;
                as.function='POTATo_win_Research_PreMix';
              end
            end
          case {'Summary',...
              'Summary Statistics Computation',...
              '1st'}
            fcn=get(handles.pop_filetype,'UserData');
            if isempty(fcn)
              as.mode=0;
              as.function='POTATo_win_Empty';
            else
              as.mode=54;
              as.function='POTATo_win_Research_1st';
            end
          case {'Statistical test','Statistical Test','Stat','2nd'}
            fcn=get(handles.pop_filetype,'UserData');
            if isempty(fcn)
              as.mode=0;
              as.function='POTATo_win_Empty';
            else
              as.mode=57;
              as.function='POTATo_win_Research_2nd';
            end
          otherwise
            error(['   Unknown Status  : ' stat1]);
        end
      case 'Developer'
        %------------------------------
        % Selecting Analysis State
        % as.mode 1,2,...
        %------------------------------
        filetypestr=get(handles.pop_filetype,'String');
        filetype=get(handles.pop_filetype,'Value');
        filetypestr=filetypestr{filetype};
        fnc        =get(handles.pop_filetype,'UserData');
        if ~isempty(fnc),
          fnc        = fnc{filetype};
        end

        dataid  =get(handles.lbx_fileList,'Value');
        dataud  =get(handles.lbx_fileList,'UserData');
        if isempty(dataud),dataid=[];end
        datalen = length(dataid);

        if isempty(dataid) || (length(dataid)==1 && dataid==0)
          %--> No Data
          if ~strcmp('2nd Level Analysis',filetypestr),
            filetypestr='No-Data-Available.';
          end
        end
        switch filetypestr,
          %case 'Raw', %1
          case 'Analysis', %2
            ismakemult=get(handles.advpsb_MultiAna,'UserData');
            if ismakemult
              % ==> if there is flag/ alwasy launch Make Multi Anaysis
              as.mode=7;
              as.function='POTATo_win_Make_MultiAnalysis';
            elseif datalen==1,
              as.mode=1;
              as.function='POTATo_win_SingleAnalysis';
            else
              %-----------------------------
              % Checking Same Recipe
              % => Multi Ana ? Batch Mode ?
              %-----------------------------
              issamefmd=true;
              data0=feval(fnc,'load',dataud(dataid(1)));
              % B070419A : version difference
              if 1
                % B070420I : compair by string.
                s0=OspFilterDataFcn('getInfo',data0.data.filterdata);
                for idx=2:datalen
                  datao = feval(fnc,'load',dataud(dataid(idx)));
                  s     = OspFilterDataFcn('getInfo',datao.data(end).filterdata);
                  if ~isequal(s,s0)
                    issamefmd=false;break;
                  end
                end
              else
                if ~isfield(data0.data.filterdata,'HBdata')
                  data0.data.filterdata.HBdata={};
                end
                for idx=2:datalen
                  datao = feval(fnc,'load',dataud(dataid(idx)));
                  % B070419A : version difference
                  if ~isfield(datao.data.filterdata,'HBdata')
                    datao.data.filterdata.HBdata={};
                  end
                  if ~isequal(data0.data.filterdata,datao.data.filterdata),
                    issamefmd=false;break;
                  end
                end
              end
              % - - - - - - - - - - -
              % Set Analysis Mode
              % - - - - - - - - - - -
              if issamefmd,
                as.mode=2;
                as.function='POTATo_win_BatchMode';
              else
                % Make Multi-Analysis Mode.
                % Meeting on 13-Apr-2007
                as.mode=7;
                as.function='POTATo_win_Make_MultiAnalysis';
                if 0
                  % Meeting on 16-Feb-2007
                  helpdlg(...
                    {'[P3] : ',...
                    '---------------------------------------------',...
                    '   Different Recipes should not be applied'},...
                    '[P3] Unpopulated Bord');
                  as.mode=0;
                  as.function='POTATo_win_Empty';
                  setappdata(handles.figure1,'AnalysisSTATE',as);
                  setappdata(handles.figure1,'CurrentSelectFile',true)
                  lbx_fileList_Callback(handles.lbx_fileList, [], handles);
                  rcode=3;
                  return;
                end
              end
            end
          case 'Multi-Analysis', %3
            as.mode=3;
            as.function='POTATo_win_MultiAnalysis';
          case '1st Level Analysis', %4
            if 0
              %if get(handles.advpsb_2ndLvlAna,'UserData');
              % Comment Out :
              % Meeting at 2007.03.09 (Fri).
              as.mode=6;
              as.function='POTATo_win_2ndLevelAnalysis_exe';
            else
              as.mode=4;
              as.function='POTATo_win_1stLevelAnalysis';
            end
          case '2nd Level Analysis', %5
            as.mode=5;
            as.function='POTATo_win_2ndLevelAnalysis';
          case 'No-Data-Available.',
            as.mode=0;
            as.function='POTATo_win_Empty';
          otherwise,
            error(['   Unknown File-Type : ' filetypestr]);
        end
      otherwise % P3-Mode Switch
        % Error Case (for debug)
        error(['   Unknown P3-Mode : ' p3mode]);
    end % P3-Mode Switch
  catch
    %******************************
    % Error Case (for debug)
    %******************************
    as.mode=0;
    as.function='POTATo_win_Empty';
    errordlg(...
      {'[POTATo System-Error] : ',lasterr},...
      'POTATo System-Error');
  end
end
% -- Message --
OSP_LOG('msg',...
  sprintf(['[Select Analysis-Mode]\n',...
  '      Number   : %d\n',...
  '      Function : %s\n'],as.mode,as.function));
% === Save Analsysis State ===
setappdata(handles.figure1,'AnalysisSTATE',as);

%------------------------------------
% Special-Case : Empty for ResearchMode
%------------------------------------
if strcmpi(p3mode,'Research')
  h0=handles.frm_AnaStatus;
  h1=get(h0,'UserData');
  if as.mode==0
    set([h0, h1],'Visible','off');
  else
    set([h0, h1],'Visible','on');
  end
end

%==================================
% Save GUI Change
%==================================
if as.mode==0,
  getSaveGUI(handles);
  h=getOutGUI(handles);set(h,'Visible','off');
else
  getSaveGUI(handles);
  h=getOutGUI(handles);set(h,'Visible','on');
end

%==================================
% Viewer GUI Change
%==================================
if as.mode==0,
  h=getViewerGUI(handles);set(h,'Visible','off');
else
  h=getViewerGUI(handles);set(h,'Visible','on');
  feval(as.function,'ChangeLayout',handles);
end

%==================================
% Advanced Mode Change
%==================================
if get(handles.tgl_AdvanceMode,'Value'),
  try
    feval(as.function,'ConnectAdvanceMode',handles);
  catch
    disp(lasterr);
    disp(['TODO : Connect Advanced Mode!' C__FILE__LINE__CHAR]);    
  end
else
  set(adv_specialhs(handles),'Visible','off');
end

%==================================
% Change LAYOUT ::
%==================================
feval(as.function,'Activate',handles);
P3_AdvTgl_status('Logging',handles,...
  ['[ANA-Stat] : ' as.function(12:end)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=getOutGUI_IO(h,ev,hs) %#ok
h=getOutGUI(hs);
function h=getOutGUI(hs)
h=[hs.psb_MakeMfile,hs.psb_export_workspace,hs.ckb_Draw];

function h=getSaveGUI(hs)
% Return List of Save-GUI'S
%h=[hs.psb_save, hs.psb_MakeMfile];
set(hs.psb_save,'Visible','off');
h=hs.psb_MakeMfile;


%==================================
function rcode=saveActiveData(handles)
% Save Modifyed Data
%==================================
rcode=0;
as=getappdata(handles.figure1,'AnalysisSTATE');
ad=getappdata(handles.figure1,'ActiveDataModSTATE');
if ~isempty(ad) && ad==true,
  try
    msg=feval(as.function,'SaveData',handles);
    if msg,
      a=questdlg({'Error Occur',...
        ['msg : ' msg],...
        '',...
        ' Do you want to continue Change Status?'},...
        'Error Occur',...
        'Yes','No');
      if strcmp(a,'No'),
        rcode=2;
        return;
      end
    end
  catch
    disp(lasterr);
    disp(['TODO : Save Active Data!' C__FILE__LINE__CHAR]);
  end
  % Reset : Modify Flag.
  setappdata(handles.figure1,'ActiveDataModSTATE',false);
end

function rcode=psb_save_Callback(hObject, ev, handles) %#ok
rcode=saveActiveData(handles); 

function psb_MakeMfile_Callback(hObject, ev, handles) %#ok
% Save as M-File
% In POTATo, Connect to Viewer --> 

% Save Data
saveActiveData(handles); 

% Make Mfile
as=getappdata(handles.figure1,'AnalysisSTATE');
try
  msg=feval(as.function,'MakeMfile',handles);
  if msg,error(msg);end
catch
  errordlg(lasterr,'POTATo Error');
end

function psb_export_workspace_Callback(h,ev,hs) %#ok<INUSL,DEFNU>
% Export

% Save Data
P3_AdvTgl_status('Logging',hs,'[Exporting...] : Save Data ...');
saveActiveData(hs);

% Make Mfile
P3_AdvTgl_status('Logging',hs,'[Exporting...] : Making Data-Script ...');
as=getappdata(hs.figure1,'AnalysisSTATE');
try
  % Evaluate...
  P3_AdvTgl_status('Logging',hs,'[Exporting...] : Evaluating ...');
  msg=feval(as.function,'Export2WorkSpace',hs);
  if ~isempty(msg),errordlg(msg);end
catch
  errordlg(lasterr,'POTATo Error');
end
% Evaluate...
P3_AdvTgl_status('Logging',hs,'[Exporting...] : Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Viewer-Control-GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=getViewerGUI_IO(h,ev,hs) %#ok<INUSL,DEFNU>
h=getViewerGUI(hs);
if 0,disp(h),disp(ev);end
function h=getViewerGUI(hs)
% Return List of Viewer-GUI'S
h=[hs.psb_drawdata, hs.pop_Layout,hs.psb_EditLayout,hs.frm_draw];

function psb_drawdata_Callback(hObject, ev, handles) %#ok<INUSL,DEFNU>
% Draw!!

% Save Data
saveActiveData(handles); 

% Darw-Now
P3_AdvTgl_status('Logging',handles,...
  '[Draw    ] : now drawing.');

as=getappdata(handles.figure1,'AnalysisSTATE');
try
  msg=feval(as.function,'DrawLayout',handles);
  if msg,rethrow(msg);end
catch
  if exist('msg','var')
    errordlg(msg,'POTATo Error');
  else
    errordlg(lasterr,'POTATo Error');
  end
  %--> with Error Message
  P3_AdvTgl_status('Logging',handles,...
    '[Draw    ] : Exception occurs in drawing.');
  return;
end
% Message
P3_AdvTgl_status('Logging',handles,...
  '[Draw    ] : Done.');

function pop_Layout_CreateFcn(hObject, ev, handles) %#ok<INUSD,DEFNU>
% Layout-List!
set(hObject,'BackgroundColor','white');
function pop_Layout_Callback(h, ev, hs) %#ok<DEFNU>
% save Application-Data 'P3_BeforeLayout'
if 1, return;end
if 0,disp(ev);end
layoutfiles=get(h,'UserData');
v=get(h,'Value');
if length(layoutfiles)>v,
  setappdata(hs.figure1,'P3_BeforeLayout',layoutfiles{v});
end

function psb_EditLayout_Callback(h,ev,hs) %#ok<DEFNU>
% Edit Layout
lh=LayoutEditor;
lf=get(hs.pop_Layout,'UserData');
vl=get(hs.pop_Layout,'Value');
if length(lf)<vl,
  errordlg('No Layout to Edit');return;
end
fname=lf{vl};
if isempty(fname) || ~exist(fname,'file')
  errordlg('Broken Layout File');
  return;
end
lhs=guidata(lh);
LayoutEditor('menu_openLayout_Callback',lhs.menu_openLayout,[],lhs,fname);
if 0,disp(h);disp(ev);end
