function varargout = OSP(varargin)

error('OSP was not work well, in this System : Use P3 insted of OSP!');

%  OSP Main Controller GUI : OSP Start form here
% 
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.06
% -------------------------------------
%
% OSP M-file for OSP.fig
%   OSP.fig is OSP Main Controller GUI.
%   To execute OSP, start from here.
%  
% Launcher Box of OSP Functions
%    
%
% OSP Main Controller is Control OSP.
%   There is following role 
%        & Lower-Linked [M-file]
%    + Initialize OSP
%      [osp_ini_fin.m]
%      [startup.m] ' in the ospdir
%    + File ( Data ) Managing 
%      [osp_data_manager.m]
%    + Launch Other Function
%      [osp_select_file.m]
%      [osp_interplete_data.m]
%      [signal_preprocessor.m]
%      [block_filter.m]
%      [data_group.m]
%      [statistical_analysis.m]
%      [signal_viewer.m]
%    + Show Application State
%      -in this file -
%    + Signal-Viewer <-> Other Function
%      Collaboration
%      -in this file -
%    + Set Preferences
%      ( in the future version)
%    + Closing OSP
%      [osp_ini_fin.m]
%    + Using Systems
%      [OSP_DATA.m] 
%      [OSP_LOG.m]
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 13-Sep-2006 13:05:41


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2004.10.14
% $Id: OSP.m 180 2011-05-19 09:34:28Z Katura $
%

% === Programing Information ===
% * Application-Defined Data
%   ActiveModule : Structure of Active Module
%                  psb : Pushed Button Handle
%                  gui : GUI Handle
%   Viewer       : [] or Signal-Viewer Handle
%   Viewer2      : [] or Signal-Viewer2 Handle
%   Viewer3      : [] or Signal-Viewer3 Handle
%   AboutH       : [] or About OSP  Handle

% -------------------------------------
% Depend on GUIDE version
% -------------------------------------
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OSP_OpeningFcn, ...
                   'gui_OutputFcn',  @OSP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% -------------------------------------

%%%%%%%%%%%%%%%%
%  Open        %
%%%%%%%%%%%%%%%%
% =============================
% Opening Function
% =============================
function OSP_OpeningFcn(hObject, eventdata, handles, varargin)
% - Input -
% hObject    handle to figure
% eventdata  Not in Use
% handles    structure with handles and user data (see GUIDATA)
% varargin   Propatry 

% --- Setup Output ---
% Output for OSP
handles.output = hObject;
guidata(hObject, handles); % update

isnew=~(OSP_DATA);   % Open Flag
try
    if isnew, pathcheck; end   % Path Check &
    
    osp_ini_fin(1,varargin{:}); % initialize
    
    mcdata.hObject=hObject; 
    mcdata.eventdata=[];
    mcdata.handles=handles;
    OSP_DATA('SET','MAIN_CONTROLLER',mcdata);
catch
    try
        OSP_LOG('err',lasterr);
    catch 
        errordlg([lasterr ...
                ' : may be OSP path Error.' ...
                ' please retry']);
        pathcheck;
    end
    try, delete(hObject); end
    rethrow(lasterror);
end

% === Change Version ===
try
    ver=OSP_DATA('GET','Version');
    if isempty(ver), ver='xxxx';end
    if isnumeric(ver), ver=num2str(ver);end
    set(handles.txt_ver,'String',['Ver ' ver]);
end

if isnew
  % Set Color & Setting
  set(hObject,'Color',[1 1 1]);
  setColor(hObject,eventdata,handles);
  rdb_prjct_Callback(handles.rdb_prjct, [], handles);
end
return; % End
% =============================
% Create Function 
% =============================
function pop_filetype_CreateFcn(hObject, eventdata, handles)
startup; % Confine : start up
st={'SignalPreprocessor Data', ...
        'Group Data', ...
        'Filter Data'};
ud={'DataDef_SignalPreprocessor', ...
    'DataDef_GroupData', ...
    'DataDef_FilterData'};
% DataDef_TTest};
set(hObject,'String',st,'UserData',ud);

%%%%%%%%%%%%%%%%
%  Close       %
%%%%%%%%%%%%%%%%
function figure1_DeleteFcn(hObject, eventdata, handles)
try
    osp_ini_fin(2);   % Close
    undostartup;
end
    
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% -- Active Data Check --
actf = OSP_DATA('GET','ACTIVE_FLAG');
if ~isempty(actf) && actf~=0
  ans0 = questdlg('OSP in Active, Do you want to Close?', ...
		  'OSP Closing', ...
		  'Yes','No','No');
  if strcmp(ans0,'No')
    return;
  end
  clear ans0 actf;
end

% -- Close Children --
try
    oah=getappdata(handles.figure1,'AboutH');
    delete(oah);
end
try
    amh=getappdata(handles.figure1,'ActiveModule');
    if ~isempty(amh) && ishandle(amh.gui)
        delete(amh.gui);
    end
end
try
    svh=getappdata(handles.figure1,'Viewer');
    delete(svh);
end
try
    svh=getappdata(handles.figure1,'Viewer2');
    delete(svh);
end
try
    svh=getappdata(handles.figure1,'Viewer3');
    delete(svh);
end

delete(hObject);

%%%%%%%%%%%%%%%%
%  Out Put     %
%%%%%%%%%%%%%%%%
function varargout = OSP_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output; % may be not in use

%%%%%%%%%%%%%%%%
%  Menu Code  %
%%%%%%%%%%%%%%%%
% =============================
% File Menu
% =============================
function mnuFile_Callback(hObject, eventdata, handles)

% -----------------------------
% Close OSP
% -----------------------------
function mnuFileClose_Callback(hObject, eventdata, handles)
%figure1_CloseRequestFcn(gcf, [], handles);
% close;
figure1_CloseRequestFcn(handles.figure1, [], handles);

% =============================
% Project Menu
% =============================
function mnuProject_Callback(hObject, eventdata, handles)

% -----------------------------
% New Project
% -----------------------------
function mnuFileNew_Callback(hObject, eventdata, handles)
waitfor(uiOspProject('Action','New'));
rdb_prjct_Callback(handles.rdb_prjct, [], handles);

% -----------------------------
% Open Project
% -----------------------------
function mnuFileOpen_Callback(hObject, eventdata, handles)
waitfor(uiOspProject('Action','Open'));
rdb_prjct_Callback(handles.rdb_prjct, [], handles);

% -----------------------------
% Export Project
% -----------------------------
function mnuPrjExport_Callback(hObject, eventdata, handles)
waitfor(uiOspProject('Action','Export'));
rdb_prjct_Callback(handles.rdb_prjct, [], handles);

% -----------------------------
% Import Project
% -----------------------------
function mnuPrjImport_Callback(hObject, eventdata, handles)
waitfor(uiOspProject('Action','Import'));
rdb_prjct_Callback(handles.rdb_prjct, [], handles);

% -----------------------------
% Search Project
% -----------------------------
function mnuPrjSearch_Callback(hObject, eventdata, handles)
  waitfor(searchPrj);
  rdb_prjct_Callback(handles.rdb_prjct, [], handles);
return;

% -----------------------------
% Delete Signal Data in current Project 
% Date : 17-Dec-2005
% -----------------------------
function menu_deleteSignalData_Callback(hObject, eventdata, handles)
% == Select Delete Function ==
try
  fs_h = uiFileSelect('DataDif', { 'SignalPreprocessor'}, 'SetMax', 10);
  waitfor(fs_h);
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata), return; end
	
	OSP_DATA('SET','ConfineDeleteDataSV',true);
	% Open from File Select Push button
	for idx=1:length(actdata),
		actdata0=actdata(idx);
		DataDef_SignalPreprocessor('deleteGroup',actdata0.data.filename);
	end
	OSP_DATA('SET','ConfineDeleteDataSV',false);
catch
	msg = {'OSP Main Controller : Signal Data Delete'};
	msg{end+1}=['  ' C__FILE__LINE__CHAR];
	msg{end+1}=lasterr;
	errordlg(msg);
end
% Close Active Data
% Close Figure :: Project might be changed.
msg=close_figure(handles,0);
OSP_DATA('SET','ACTIVEDATA',[]);

% -----------------------------
% Delete Signal Data in current Project 
% Date : 17-Dec-2005
% Date : 19-Dec-2005 
%   Modyfy : 
% -----------------------------
function menu_deleteGroupData_Callback(hObject, eventdata, handles)
% == Select Delete Function ==
try
	fs_h = uiFileSelect('DataDif', { 'GroupData'}, 'SetMax', 10);
	waitfor(fs_h);
	actdata = OSP_DATA('GET','ACTIVEDATA');
	if isempty(actdata), return; end

	OSP_DATA('SET','ConfineDeleteDataGD',true);
	% Open from File Select Push button
	for idx=1:length(actdata),
		actdata0=actdata(idx);
		DataDef_GroupData('deleteGroup',actdata0.data.Tag);
	end
	OSP_DATA('SET','ConfineDeleteDataGD',false);
catch
	msg = {'OSP Main Controller : Group Data Delete'};
	msg{end+1}=['  ' C__FILE__LINE__CHAR];
	msg{end+1}=lasterr;
	errordlg(msg);
end
% Close Figure :: Project might be changed.
msg=close_figure(handles,0);
OSP_DATA('SET','ACTIVEDATA',[]);

% =============================
% Setting Menu
% =============================
function menuFBM_Callback(hObject, eventdata, handles)
% Filter Setting Menu;
flg=osp_FilterBookMark;
if flg,
    msg=close_figure(handles,0);
end

% =============================
% Help Menu
% =============================
function mnuHelp_Callback(hObject, eventdata, handles)

% -----------------------------
% Open "About OSP" 
% -----------------------------
function mnuHelpAbout_Callback(hObject, eventdata, handles)

% Rock
ams=getappdata(handles.figure1,'AboutMenueState');
if ~isempty(ams)  && ams==1
    return;
end
setappdata(handles.figure1,'AboutMenueState',1);

adinfo={'Main Controller Information', ...
        ' Last Modify Day:'          , ...
        '     15-May-06'             , ...
        ' Bugs :'                    , ...
        '   masanori.shoji.qk@hitachi.com'};
ver=OSP_DATA('GET','Version');
if isempty(ver), ver='xxxx';end
if isnumeric(ver), ver=num2str(ver);end
try
    % If you want to change Color of "About OSP"
    % OSP_About('Ver',1.00, 'AddInfo',adinfo,'BgC',[0.8 .8 1]);
	oah=OSP_About('Ver',ver, 'AddInfo',adinfo);
catch
    % Error : Easy Print
    bcinfo={'OSP : Optical Topography', ...
            '             Signal Processor',...
            sprintf('                  Version %s',ver),...
            ' (c) 2019,', ...
            '     National Institute of Advanced Industrial Science and Technology,', ...
            '     Powered By Matlab'};
    msgbox(sprintf('%s\n%s\n%s\n\n%s\n%s\n\n\t%s', ...
        bcinfo{1},bcinfo{2},bcinfo{3},bcinfo{4},bcinfo{5},bcinfo{6}), ...
        'About OSP');  % Title
end
%   AboutH       : [] or About OSP  Handle
setappdata(handles.figure1,'AboutH',oah);
% Unlock
setappdata(handles.figure1,'AboutMenueState',0);

%%%%%%%%%%%%%%%%
%  Call Back   %
%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Print Data Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -----------
% Project (Abstruct)
% -----------
function rdb_prjct_Callback(hObject, eventdata, handles)
% You can set null for hObject
  if isempty(hObject)
    hObject=handles.rdb_prjct;
  end
  set([handles.lbx_fileList; ...
          handles.lbx_fileinfo; ...
          handles.pop_filetype], ...
      'Visible','off');
  set(handles.listbox1,'Value',1, 'Visible','on');
  
  set(hObject,'Value',1);
  set(handles.rdb_filelist,'Value',0);
  %set(handles.rdb_actdata,'Value',0);
  
  pj_old_Path = get(hObject,'UserData');
  pj=OSP_DATA('get','PROJECT');

  if isempty(pj)
     set(handles.listbox1,'String',...
         {' No Project Opened',...
             '  ''Open''/''New'' Project from File menu'});
     return;
  end

  try,  
    set(hObject,'UserData',pj.Path);
  end

  try
    set(hObject,'String',['Project : ' pj.Name]);
  end
  try
    msg = OspProject('Info');
    set(handles.listbox1,'String',msg);
  catch
    set(handles.listbox1,'String',...
        {' Can not Print Information of Project', ...
		    lasterr});
  end
  
  if ~strcmp(pj_old_Path, pj.Path),
	  close_figure(handles,0);
  end
return;

% -----------
% Project (File List)
% -----------
function rdb_filelist_Callback(hObject, eventdata, handles)
% --> Show File List 
if isempty(hObject), hObject=handles.filelist;end

% Check Project is available?
pj_old_Path = get(hObject,'UserData');
pj=OSP_DATA('get','PROJECT');
if isempty(pj)
    set(handles.listbox1,'String',...
        {' No Project Opened',...
            '  ''Open''/''New'' Project from File menu'});
    errordlg(' No Active Project Exist');
    set(handles.rdb_filelist,'Value',0);
    return;
end

% Visible On / Off
set([handles.lbx_fileList; ...
        handles.lbx_fileinfo; ...
        handles.pop_filetype], ...
    'Visible','on');
set(handles.listbox1,'Visible','off');

set(handles.rdb_filelist,'Value',1);
set(handles.rdb_prjct,'Value',0);
pop_filetype_Callback(handles.pop_filetype,[], handles);


function pop_filetype_Callback(hObject, eventdata, handles)
fcn=get(hObject,'UserData');
vl =get(hObject,'Value');
data = feval(fcn{vl},'loadlist');
if isempty(data),
    set(handles.lbx_fileList,...
        'String','No Data Exist', ...
        'Value',1, ...
        'UserData',[]);
else,
    if isfield(data,'filename'),
        str={data.filename};
    elseif isfield(data,'Tag'), 
        str={data.Tag};
    else,
        str={'Unknown Tag Name', ...
                C__FILE__LINE__CHAR};
    end
    set(handles.lbx_fileList,...
        'String',str, ...
        'Value',1, ...
        'UserData',data);
end
lbx_fileList_Callback(handles.lbx_fileList,[],handles);

function lbx_fileList_Callback(hObject, eventdata, handles)
% Load Data
vl  =get(hObject,'Value');
data=get(hObject,'UserData');
% Load Function
fcn=get(handles.pop_filetype,'UserData');
fcn=fcn{get(handles.pop_filetype,'Value')};
try,
    if length(data)<vl,
        error('Not effective Data');
    end
    str=feval(fcn,'showinfo',data(vl));
catch,
    str=lasterr;
end
set(handles.lbx_fileinfo,'String',str,'Value',1);

% ------------
% Active Data
% ------------
function rdb_actdata_Callback(hObject, eventdata, handles)
% You can set null for hObject
% ==> Do nothing!!
%     This function Fill be removed soon!
return;
  if isempty(hObject)
    hObject=handles.rdb_actdata;
  end
  

  % ==  Reset Radio Buttons ==
  set(handles.rdb_prjct,'Value',0);
  set(hObject,'Value',1);
  set(handles.listbox1,'Value',1);

  % ==  Reset Radio Buttons ==
  actData=OSP_DATA('GET','ActiveData');
  if ~isempty(actData) && ~isempty(actData(end).fcn)
    actData = actData(end);
    % -- when active data exist --
    try
      idnt = feval(actData.fcn,'getIdentifierKey');
      idnt = getfield(actData.data,idnt);
      set(hObject,'String',['Active Data : ' idnt]);
    catch
      OSP_LOG('err',['Active Data Name Set Error : ' lasterr]);
    end

    try
      set(handles.listbox1,'String', ...
			feval(actData.fcn,'showinfo',actData.data));
    catch
      OSP_LOG('err','Active Data String Set Error');
      set(handles.listbox1,'String',{' Can not open ActiveData ', ...
		    lasterr});
    end % catch

  else

    % -- no active Data --
    set(hObject,'String','Active Data : -----');
    set(handles.listbox1,'String', ...
		      {'== No Active Data Exist ==' ...
		       'Load File at First!'});

  end % Actdata exist
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Launch Button
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function code = LaunchModule(module_h,handles, p_fnc, ddif)
%==========================
% Launch Button Starting    
%==========================
% Input
%    module  : Handle of Launch button
%    handles : Handles of OSP
%    p_fnc   : Pointer of Launch Function 
%    ddif    : Data Define Function Identfier
%              if 'none' , use Default
%              if not null, not Open uiFileSelect
%   
% Output
%    code    : Return Code
%              -1 -> In active ( NG )
%               0 -> Continue  (OK)
%               1 -> Alredy Launch (OK)
%               2 -> Canncel (OK)

  code = 0;
  
  % ===  Active Data Check  ===
  actf = OSP_DATA('GET','ACTIVE_FLAG');
  if ~isempty(actf) && actf~=0
    % Make Messages
    acttag = OSP_DATA('GET','ACTIVE_FLAG_TAG');
    msg = {'== Now OSP is Active ==', ...
	   ' OSP Button can launch other GUI'};
    for bitid = 1: length(acttag)-1
      if 1==bitget(actf,bitid)
	msg{end+1}=['   ' acttag{bitid+1}];
      end
    end
    msgbox(msg,' Now OSP is Active ','warn')
    code = -1;
    return;
  end
  
   % == Check Project 
  pj=OSP_DATA('get','PROJECT');
  if isempty(pj)
    errordlg({' No Project Opened',...
             '  ''Open''/''New'' Project from File menu'});
     return;
  end
  
  % === Delete Before GUI ===
  amh=getappdata(handles.figure1,'ActiveModule');
  if ~isempty(amh) && ~isempty(amh.gui)
	  if amh.psb==module_h && ishandle(amh.gui)
		  figure(amh.gui);  % top
		  code = 1;
		  return;
	  end
	  try, delete(amh.gui);end
  end


  % === Lock ===
  % --- Set Active is ON --
  OSP_DATA('SET','ACTIVE_FLAG', bitset(actf,3,1));
  %% Warning : You must set bitset(actf,3,0)
  %%           when launch data

  % --- Lock OSP GUI ---
  try
    gui_buttonlock('lock',handles.figure1,module_h);
    set(module_h,'Enable','inactive');
  catch
    code = -1; tmp = lasterror;
    LaunchModuleEnd(module_h,handles);
    rethrow(tmp);
  end


  % === New File Select =====
  try
    if ~isempty(ddif) 
      % --- Open FileSelector ---
      if strcmp(ddif,'none')
	fs_h = uiFileSelect;
      else
	fs_h = uiFileSelect('DataDif',ddif);
      end

      % --- waiting for File Selector Close ---
      set(handles.figure1,...
	  'WindowButtonDownFcn',...
	  'msgbox(''Select File, At First!'',''In Active'')');
      try
	waitfor(fs_h);
      end
      set(handles.figure1,...
	  'WindowButtonDownFcn',[]);
      actdata = OSP_DATA('GET','ACTIVEDATA');

      % --- Print Data ---
      set(handles.rdb_actdata,'Value',0); %% GUI PRINT
      rdb_actdata_Callback(handles.rdb_actdata, [], handles);

      % --- Check Return Value ---
      if isempty(actdata)
	% Cancel
	code = 2;
	LaunchModuleEnd(module_h,handles);
	return;
      end

    end
  catch
    code = -1; tmp = lasterror;
    LaunchModuleEnd(module_h,handles);
    rethrow(tmp);
  end

  
  % === Launch & Set Acitve Module Data ===
  try
    h_fnc=feval(p_fnc);
    amh.psb=module_h; amh.gui=h_fnc;
    setappdata(handles.figure1,'ActiveModule',amh);
  catch
    code = -1;tmp=lasterror;
    LaunchModuleEnd(module_h,handles);
    rethrow(tmp);
  end

  LaunchModuleEnd(module_h,handles);
return;

function LaunchModuleEnd(module_h,handles)
% === Unlock ===
% Enable Push Button
  actf=OSP_DATA('GET','ACTIVE_FLAG');
  OSP_DATA('SET','ACTIVE_FLAG', bitset(actf,3,0));
  gui_buttonlock('unlock',handles.figure1);
  reloadView(module_h,[],handles);  %reload
return;

% ============================================
%  Executes on button press in psb_sp.
% ============================================
function psb_sp_Callback(hObject, eventdata, handles)
% Launch Signal Preprocessor
  OSP_DATA('SET','ACTIVEDATA',[]);
  code = LaunchModule(hObject,handles,@signal_preprocessor,[]);
return;

% ============================================
%  Executes on button press in psb_sp.
% ============================================
function psb_ps_Callback(hObject, eventdata, handles)
  OSP_DATA('SET','ACTIVEDATA',[]);
  code = LaunchModule(hObject,handles, @setProbePosition, []);
return;

% ============================================
%  Executes on button press in psb_bf.
% ============================================  
function psb_bf_Callback(hObject, eventdata, handles)
  code = LaunchModule(hObject,handles,...
		      @block_filter,...
		      {'GroupData','SignalPreprocessor'});
return;

% ============================================
%  Executes on button press in psb_dg.
% ============================================  
function psb_dg_Callback(hObject, eventdata, handles)
set(hObject,'Enable','inactive');
amh=getappdata(handles.figure1,'ActiveModule');
if ~isempty(amh) && amh.psb~=hObject
    try, delete(amh.gui); end
end

amh.psb=hObject;
amh.gui=sets_creator;      % *** temp ***

setappdata(handles.figure1,'ActiveModule',amh);
reloadView(hObject,eventdata,handles);  %reload
set(hObject,'Enable','on');

% ============================================
%  Executes on button press in psb_sa.
% ============================================  
function psb_sa_Callback(hObject, eventdata, handles)
  code = LaunchModule(hObject,handles,@statistical_analysis,{'GroupData'});
return;

function psb_export_spm_Callback(hObject, eventdata, handles)
  code = LaunchModule(hObject,handles,@otimgtrns, {'SignalPreprocessor'});
return;

% ============================================
%  Executes on button press in psb_view.
% ============================================  
function psb_view_Callback(hObject, eventdata, handles)
% Open Viewer (3)
set(hObject,'Enable','inactive');
try
    vh=getappdata(handles.figure1,'Viewer3');
    if isempty(vh)
        vh=signal_viewer3;
    else
        % 2nd Click to Viewer Active
        if ~ishandle(vh)
            vh=signal_viewer3;
        else
            figure(vh);
        end
    end
catch
    set(hObject,'Enable','on');
    rethrow(lasterror);
end
set(hObject,'Enable','on');

% ============================================
%  Executes on button press in psb_ospview.
% ============================================  
function psb_ospviewer_Callback(hObject, eventdata, handles)
% Open Viewer II (Edit)
set(hObject,'Enable','inactive');
try
    vh=getappdata(handles.figure1,'Viewer2');
    if isempty(vh)
        vh=signal_viewer2;
    else
        % 2nd Click to Viewer Active
        if ~ishandle(vh)
            vh=signal_viewer2;
        else
            figure(vh);
        end
    end
catch
    set(hObject,'Enable','on');
    rethrow(lasterror);
end
set(hObject,'Enable','on');

% ============================================
%  Executes on button press in psb_oldviewer.
% ============================================  
function psb_oldviewer_Callback(hObject, eventdata, handles)
% Open Viewer (Old Viewer)
set(hObject,'Enable','inactive');
try
    vh=getappdata(handles.figure1,'Viewer');
    if isempty(vh)
        vh=signal_viewer;
    else
        % 2nd Click to Viewer Active
        if ~ishandle(vh)
            vh=signal_viewer;
        else
            figure(vh);
        end
    end
catch
    set(hObject,'Enable','on');
    rethrow(lasterror);
end
set(hObject,'Enable','on');


%%%%%%%%%%%%%%%%%%%%
%  View            %
%%%%%%%%%%%%%%%%%%%%
% ========================
%  Logo 
% ========================
%function axes1_CreateFcn(hObject, eventdata, handles)
%osp_logo(hObject); % logo plot
%return;

%=========
% Setting MatLab path
%=========
function pathcheck(path0)
% load OSP pathcheck
if nargin==0
    path0=pwd;
end
% If no path
try
    fn=which('OSP');
    if iscell(fn), fn=fn{1}; end
    ospPath=fileparts(fn);
end
cd(ospPath);
try
    startup;
end
cd(path0);
return;

%===============
% Set GUI Color 
%===============
function setColor(hObject,eventdata,handles)
% Set Color & Text-Property
bc=get(handles.figure1,'Color');
h0=findobj(handles.figure1,'Style','text');
%h1=findobj(handles.figure1,'Style','frame');
%h0(end+1:end+length(h1))=h1;
h0(end+1)=handles.frm_filedata;

for h_i=h0;
  set(h_i,'BackgroundColor',bc);
end
return;

%===============
% Logo Color change
%===============
function plotAxes(hObject,eventdata,handles,varargin)
try
    mode=varargin{1};
catch
    mode=[];
end
try
    bc=get(handles.figure1,'Color');
    osp_logo(hObject,mode,bc); % logo plot
end
return;

%================================
% reloadView
% Reload MainController View
%   Active Viewer Frame
%   Active PushButton Frame
%================================
function reloadView(hObject,eventdata,handles, varargin)
% - Input -
% handles    structure with handles and user data (see GUIDATA)
% Apprication Data
%   ActiveModule : Active Module Handle
%   Viewer       : [] or Signal-Viewer Handle
%   Viewer2      : [] or Signal-Viewer2 Handle
%
% --
% Do not use hObject, eventdata!
% --
% if you want to Add Line,
%   Change only psb_h & frmV_h & frmP_h
%  if frm == NaN
%    Don't Set any more
%

% Get Appdata
amh=getappdata(handles.figure1,'ActiveModule');
svh=getappdata(handles.figure1,'Viewer');
svh2=getappdata(handles.figure1,'Viewer2');
svh3=getappdata(handles.figure1,'Viewer3');
if isempty(amh), amh.gui=NaN; amh.psb=NaN; end
try,
	if ~ishandle(amh.gui),
		amh.gui=NaN; amh.psb=NaN; 
		setappdata(handles.figure1,'ActiveModule',[]);
	end
end

% Get Varargin 
if ~isempty(varargin)
	for ii=1:length(varargin)
		switch varargin{ii}
			case 'rmViewer'   % Viewer Removed
        svh=[];setappdata(handles.figure1,'Viewer',svh);
			case 'rmViewer2'  % Viewer2 Removed
				svh2=[];setappdata(handles.figure1,'Viewer2',svh2);
      case 'rmViewer3'  % Viewer3 Removed
        svh3=[];setappdata(handles.figure1,'Viewer3',svh3);
			case 'rmAM'     % Active Module Removed
        amh=[];setappdata(handles.figure1,'ActiveModule',amh);
        amh.gui=NaN;amh.psb=NaN;
      otherwise
        error(sprintf('Operation Error for OSP:reloadView : %s\n ',varargin{ii}));
    end
	end
end

% Handles
% psb_h=[handles.psb_sp, handles.psb_ps, handles.psb_bf, ...
% 		handles.psb_dg, handles.psb_sa];
% frmV_h=[handles.frm_view, handles.frm_ps_view, handles.frm_ospview, ...
% 		handles.frm_dg_view, handles.frm_sp_act2_view]; % ViewFrame
% frmP_h=[handles.frm_sp_act, handles.frm_ps_view, handles.frm_bf_act, ...
% 		handles.frm_dg_act, NaN ]; % Active PushbuttonFrame

% -- 
% Check Handles Definition
%  !! if you already Checked,
%        you can comment out
% l1=length(psb_h); l2=length(frmV_h); l3=length(frmP_h);
% if l1 ~=l2 || l2~=l3;
%     msg.message='ActiveViewFrame Handles Setting Error';
%     msg.identifier=[];
%     OSP_LOG('perr',msg.messange);
%     rethrow(msg);
% end

% Set View
if isnan(amh.psb)
	bc=[1 1 1];
else
	bc=[1 1 .85];   % Background
end

%======================
% Active Module : Frame
%======================
psb.handle = handles.psb_sp;
psb.frmV   = [];
psb.frmP   = [handles.frm_sp_act, handles.frm_sp_act2];

psb(2).handle  = handles.psb_ps;
psb(2).frmV    = []; % is equal to SignalPreprocessor
psb(2).frmP    = handles.frm_ps_act;

psb(3).handle  = handles.psb_bf;
psb(3).frmV    = [];
psb(3).frmP    = handles.frm_bf_act;

psb(4).handle  = handles.psb_sa;
psb(4).frmV    = []; % No plot data
psb(4).frmP    = []; % handles.frm_sa_act;

% --> Push Button 
for id=1:length(psb),
	if ~isnan(amh.psb) && psb(id).handle==amh.psb % Active Pushbutton
		bc=[1 1 1];  % Change Background Color White
		if ~isempty(psb(id).frmV),
			if  ~isempty(svh)
				set(psb(id).frmV,'Visible','on');
			else
				set(psb(id).frmV,'Visible','off');
			end
		end
		if ~isempty(psb(id).frmP)
			set(psb(id).frmP,'BackgroundColor',[1 .3 .3]);
		end
	else % Active Pushbutton
		if ~isempty(psb(id).frmV)
			set(psb(id).frmV,'Visible','off');
		end
		if ~isempty(psb(id).frmP)
			set(psb(id).frmP,'BackgroundColor',bc);
		end
	end
end

%======================
% Active Viewer : Frame
%======================
if  ~isempty(svh3)
  set(handles.frm_view,'Visible','on');
else
  set(handles.frm_view,'Visible','off');
end

if  ~isempty(svh2)
  set(handles.frm_ospview,'Visible','on');
else
  set(handles.frm_ospview,'Visible','off');
end

if  ~isempty(svh)
  set(handles.frm_oldview,'Visible','on');
else
  set(handles.frm_oldview,'Visible','off');
end


% --- Executes during object creation, after setting all properties.
function ax_logo_CreateFcn(hObject, eventdata, handles)
osp_logo(hObject);
set(hObject,...
    'Tag','ax_logo',...
    'Callback',...
    'OSP(''plotAxes'',gcbo,[],guidata(gcbo))');


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
if strcmp(get(hObject,'CurrentKey'),'escape')
  return;
end
osp_KeyBind(hObject,eventdata,handles,'OSP');


function msg=close_figure(handles,level)
% Close OSP related figure.
% handles : OSP-MainController Figure,
% level   : Closing Level ( now level is not define)
% 17-Dec-2005

msg={};
% Close Active Module
try
	amh=getappdata(handles.figure1,'ActiveModule');
	if ~isempty(amh) && ishandle(amh.gui)
		delete(amh.gui);
	end
catch
	msg{end+1}=lasterr;
end
% Close Viewer
try
	svh=getappdata(handles.figure1,'Viewer');
	delete(svh);
catch
	msg{end+1}=lasterr;
end
% Close Viewer
try
	svh=getappdata(handles.figure1,'Viewer2');
	delete(svh);
catch
	msg{end+1}=lasterr;
end

% close rest figure
if level>100
	close all
end



