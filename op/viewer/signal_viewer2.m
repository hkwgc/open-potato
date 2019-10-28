function varargout = signal_viewer2(varargin)
% SIGNAL_VIEWER2 Application M-file for Viewer of OSP Data version 1.0
%
%    FIG = SIGNAL_VIEWER2 launch signal_viewer2 GUI.
%    SIGNAL_VIEWER2('callback_name', ...) invoke the named callback.
%
%    Signal Viewer can view OSP Data with View Options,
%    but can not edit Data. All Option in  Signal Viewer
%    is not affect to other GUI in OSP.
%
%    Signal Viewer also get Result of Signal-View.
%
% ------------------
%   For Programmer  
% ------------------
%
% * Overview of SIGNAL_VIEWER2
%   Functions in SIGNAL_VIEWER2 is classificated by following parts
%     A. OSP Connection
%     B. Select Data-File(OSP-Data)
%     C. Filter Manager
%     D. Layout Manager
%     E. View Execution.
%     X. Common Tool of SIGNAL_VIEWER2
%
% * Available Data in SIGNAL_VIEWER2 
%  Data that can available in SIGNAL_VIEWER2 is
%  defined in DataDef_***.m, and that include
%  common interface for uiFileSelect and Signal_viewer.
%  So If you want to add available data, please make
%  DataDef Function at first.
%
% See also: GUIDATA, UIFILESELECT, DATA

% Last Modified by GUIDE v2.5 13-May-2006 14:54:04


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 07-Feb-2006
% $Id: signal_viewer2.m 180 2011-05-19 09:34:28Z Katura $
% 
% Revision 1.01, 07-Feb-2006
%    Import from Signal-Viewer R1.38
%    Change along Signal-View R1.38->R1.40
%    Remove unused functions.
%    Add New functions.
%
% Revision 1.02, 10-Feb-2006
%    Modify components name of signal_viewer2
%
% Revision 1.03, 10-Feb-2006
%    Add Save-Layout Function
%    Blush-up : Delete some functions that is not in use.
%               Check consistent.

if nargin == 0,  % LAUNCH GUI
        %%%%%%%%%%%%%%%%%%%%%%%%
	% == Opening Function ==
        %%%%%%%%%%%%%%%%%%%%%%%%
	fig = openfig(mfilename,'reuse');
	set(fig,'Color','white');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	handles.figure1=fig; % to easy refarence..
	guidata(fig, handles);

	%---------------------
	% Change Status of OSP
	%---------------------
	% ( A. OSP Connection)
        mc = OSP_DATA('GET','MAIN_CONTROLLER');
        ah=getappdata(mc.hObject,'ActiveModule');
	% Check Active Module
        if ~isempty(ah) && isstruct(ah),
	  ah=ah.gui;
	  if ~isempty(ah) && ishandle(ah) && ...
		strcmp('Block Filter',get(ah,'Name'))
	    delete(ah);
	  end
	end

	% Delete other viewer
  svh=getappdata(mc.hObject,'Viewer');
  if ~isempty(svh) && ishandle(svh),
    delete(svh);
    setappdata(mc.hObject,'Viewer',[]);
  end
  
  % Update OSP Main Controler View
  setappdata(mc.hObject,'Viewer2',fig);
  OSP('reloadView',mc.hObject,mc.eventdata,mc.handles);

  % V3
  svh=getappdata(mc.hObject,'Viewer3');
  if ~isempty(svh) && ishandle(svh),
    delete(svh);
    setappdata(mc.hObject,'Viewer3',[]);
  end  
  
        %%%%%%%%%%%%%%%%%%%%%%%%
	% ===== OutputFcn  =====
        %%%%%%%%%%%%%%%%%%%%%%%%
	if nargout>=1,
	  varargout{1}=fig;
	end
	
elseif ischar(varargin{1})
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% INVOKE NAMED SUBFUNCTION OR CALLBACK
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
	  OSP_LOG('err',lasterr, 'Loading Filter Data');
	  fname=varargin{1};
	  errordlg(...
          {[' Error Occur :' fname ], ...
              lasterr});
	end
end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is smple_3d_tgl structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. SMPLE_3D_TGL copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A. OSP Connection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function signal_viewer2_DeleteFcn(hObject, eventdata, handles)
% ---------------------------------------
% Delete Function of the SIGNAL_VIEWER2
%  Change Main-Controller view
% ---------------------------------------
try
  lpph = getappdata(handles.figure1,'LinePlotPropertyHandle');
  if ~isempty(lpph) && ishandle(lpph),
    delete(lpph);
  end

  tt_help_h = getappdata(handles.figure1, 'TtestHelpH');
  if ~isempty(tt_help_h) && ishandle(tt_help_h),
    try, delete(tt_help_h); end
  end

  mc=OSP_DATA('GET','MAIN_CONTROLLER');
  OSP('reloadView',mc.hObject,mc.eventdata,mc.handles,'rmViewer2');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B. Select Data-File(OSP-Data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = file_select_psb_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Add OSP File for plot to the List
%    by Selecting uiFileSelect
% ---------------------------------------

  ini_actdata = OSP_DATA('GET', 'ActiveData'); % For swap

  %  -- Lock --
  set(handles.figure1, 'Visible', 'off');

  % === File Select  ===
  try
    %fs_h = uiFileSelect('DataDif', { 'SignalPreprocessor', 'GroupData','TTest'}, ...
	fs_h = uiFileSelect('DataDif', { 'SignalPreprocessor', 'GroupData'}, ...
			'SetMax', 10);
    waitfor(fs_h);
  catch
    set(handles.figure1,'Visible','on');
    rethrow(lasterror);
  end

  % -- Unlock --
  set(handles.figure1,'Visible','on');

  actdata = OSP_DATA('GET','ACTIVEDATA');
  OSP_DATA('SET','ACTIVEDATA',ini_actdata);

  if isempty(actdata), return; end

  % Open from File Select Push button
  % set fopen_flg=1
  % 06-Jun-2005, M.Shoji
  for idx=1:length(actdata),
    addFile(handles, actdata(idx),1);
  end

return;

function addFile_Callback(hObject,eventdata, handles, actdata)
% ---------------------------------------
%  Add OSP File for plot to the List by Callback 
%    This function is dummy function.
%    This is useful for you, when add file from other GUI.
% ---------------------------------------
addFile(handles, actdata);

function addFile(handles, actdata,fopen_flg)
% ---------------------------------------
%  MAIN Function of Adding OSP File for plot to the List.
%   This Function is call from 
%        file_select_psb_Callback and addFile_Callback.
%   
%   Add actdata to the List and Change Button Enable/Disable 
% ---------------------------------------
  dt=get(handles.lsb_datalist, 'UserData');
  st=get(handles.lsb_datalist, 'String');

  % Make Header information
  fcnstr = char(func2str(actdata.fcn));
  fcnstr = fcnstr(9:end); % Remove DataDef_
  head   = fcnstr(regexp(fcnstr,'[A-Z]')); % Get Large-Charactor

  % Get Data Name
  idfld = feval(actdata.fcn, 'getIdentifierKey');
  dname = getfield(actdata.data,idfld);

  dstr = [head ' : ' dname];

  id = length(dt)+1;
  if id==1
    st={dstr};
    dt=actdata;
  else
    samestr = find(strcmp(st,dstr));
    if isempty(samestr)
      st{id} = dstr;
      dt(id) = actdata; 
    else
      id = samestr(1);
	  if exist('fopen_flg','var') && fopen_flg==1,
		  warndlg(' Selected Data is already opened');
	  end
    end
  end

  set(handles.lsb_datalist, ...
      'Value', id, ...
      'UserData', dt, ...
      'String', st);

  % Change Selected Data
  lsb_datalist_Callback(handles.lsb_datalist, [], handles);
return;

    
function varargout = file_remove_psb_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Remove OSP File for plot from the List.
%   Remove Selecting File and re-select other file
% ---------------------------------------
  st=get(handles.lsb_datalist, 'String');
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');

  if isempty(dt)
    warndlg(' No Data to remove');
    return;
  end
  
  st(tg)=[];  dt(tg)=[];
  if isempty(dt)
    st = {'-- No Data --'};
  end
  if tg > length(st)
    tg=length(st);
  end

  set(handles.lsb_datalist, ...
      'Value', tg, ...
      'String', st, ...
      'UserData', dt);
  % Change Selected Data
  lsb_datalist_Callback(handles.lsb_datalist, [], handles);

return;

function varargout = lsb_datalist_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
% Change Button Enable/Disable 
%   Correspond to the Data format
% ---------------------------------------

% Select file and show file information

  % Load Selected File
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');

  if length(dt) < tg
    set(handles.lsb_datainfo, ...
	'Value', 1, ...
	'String', {'-- No Data Selected --'});
    setappdata(handles.figure1, 'LocalActiveData',[]);
    OspFilterCallbacks('LocalActiveDataOff', h,[],handles);
    return;
  end

  % Temp for recover data
  actdata_tmp = OSP_DATA('GET', 'ActiveData');

  % Active Data
  actdata = dt(tg); clear dt tg;
  setappdata(handles.figure1, 'LocalActiveData',actdata);
  OspFilterCallbacks('LocalActiveDataOn', h,[],handles);
  dtype   = func2str(actdata.fcn);

  try

    % Viewer Setting
    info={}; lineinfo=[];  % Default Setting

    set(handles.radio_all,'value',1, 'Visible', 'off');
    set(handles.radio_select, 'value', 0, 'Visible', 'off');
    set(handles.selectnum_edit, 'visible', 'off'); 
	
    % not in use ---> move to DataListBox select
    % Load Selected File
    dt=get(handles.lsb_datalist, 'UserData');
    tg=get(handles.lsb_datalist, 'Value');
    if length(dt) < tg,  return;  end
	 
    switch dtype

      % ********************** 
     case 'DataDef_SignalPreprocessor'
      % ********************** 

      % === Data Print ===
      info = feval(actdata.fcn, 'showinfo', actdata.data);

      % -- Reset, Filter List --
      OspFilterCallbacks('set',handles.figure1, []);

      % ********************** 
     case 'DataDef_GroupData'
      % ********************** 
      actdata.data = feval(actdata.fcn, 'load', actdata.data);
      % === Viewer Setting ===
      set(handles.radio_all, 'Visible', 'on');
      set(handles.radio_select,  'Visible', 'on');

      % === Data Print ===
      [info, lineinfo] = feval(actdata.fcn, ...
			       'showblocks', actdata.data);
			   
      % -- Reset, Filter List --
	  % Load Selected File
	 try
		 if ~isempty(actdata.data.data),
			 gd = actdata.data.data(end);
			 OspFilterCallbacks('set',handles.figure1, gd.filterdata);
		 else,
			 OspFilterCallbacks('set',handles.figure1, []);
		 end
	 catch
		 OSP_LOG('err',lasterr, 'Loading Filter Data');
		 rethrow(lasterror);
	 end

      % ********************** 
     case 'DataDef_TTest'
      % ********************** 
      plttyp{1}='block-mean-value';
      set(handles.pop_plotmode,'String',plttyp)
      set(handles.pop_datachaneg, ...
	  'Enable','inactive', ...
	  'Value',1);
      pop_datachaneg_Callback(handles.pop_datachaneg, [], handles);
      info = feval(actdata.fcn, 'showinfo', actdata.data);
      
      % ********************** 
     otherwise
      % ********************** 
      info = feval(actdata.fcn, 'showinfo', actdata.data);
    end % Data type Switch

    set(handles.lsb_datainfo, ...
	'Value'    , 1, ...
	'String'   , info, ...
	'UserData' , lineinfo);
  catch
    OSP_LOG('err', lasterr ,['Setting Signal Viewer II' dtype]);
    errordlg({' Data Load Error', lasterr}); 
  end

  % Reload Active Data
  OSP_DATA('SET', 'ActiveData', actdata_tmp);
  lsb_datainfo_Callback(handles.lsb_datainfo, [], handles);

  % add for open_lineplot_prop,
  %  @since 1.01
  lpph = getappdata(handles.figure1,'LinePlotPropertyHandle');
  if ~isempty(lpph) && ishandle(lpph),
    dt=get(handles.lsb_datalist, 'UserData');
    tg=get(handles.lsb_datalist, 'Value');
    if tg>length(dt),dt=[]; else, dt=dt(tg); end
    handles2 = guihandles(lpph);
    osp_lineplot_prop('setTitleAvailableData',lpph,[],handles2,dt);
    % @since 1.01,
    %  -> send front LinePlotProperty GUI.
    figure(lpph);
  end

  % Set lbx_InnerLayout infomation
  % --------------------------------------------
  % Get VIEW.LAYOUT data from header or default 
  % --------------------------------------------
  key = getSignalView2Option(handles);
  [data, header]= make_ucdata(key,handles);
  if ~isfield(header,'VIEW') || ~isfield(header.VIEW, 'LAYOUT') || ...
	isempty(header.VIEW.LAYOUT),
    header.VIEW.LAYOUT=defaultLAYOUT;
   end
  innerstr={};
  for i=1:length(header.VIEW.LAYOUT),
    if isfield(header.VIEW.LAYOUT{i}, 'vgdata'),
      innerstr{end+1}=header.VIEW.LAYOUT{i}.vgdata{1}.NAME;
    else
      innerstr{end+1}='Untitled';
    end
  end
  val=length(innerstr);
  set(handles.lbx_InnerLayout, 'String',  innerstr);
  set(handles.lbx_InnerLayout, 'Value',   val);
  set(handles.lbx_InnerLayout, 'UserData',header.VIEW.LAYOUT );
  % Update overview
  lbx_InnerLayout_Callback(handles.lbx_InnerLayout,[],handles);
  % --------------------
  % Update lsb_datalist 
  % --------------------
  [sflg, msg]=replaceLayout(header.VIEW.LAYOUT, handles);
  %  Error check
  if (~sflg),
    h=errordlg(msg);waitfor(h);
    return;
  end
return;

function layout=defaultLAYOUT()
% ------------------------------------------
% Load defauit LayoutFile,and Set LayoutData
%  return LayoutData
% ------------------------------------------
   layout={};
   osppath     = OSP_DATA('GET','OspPath');
   defaultpath = [osppath filesep 'ospData'];
   list        = dir([defaultpath filesep 'LAYOUT*.mat']);
   for i=1:length(list),
     lfile  = [defaultpath filesep list(i).name];
     load(lfile, 'LAYOUT');
     if ~exist('LAYOUT'),
       warndlg(' Could''nt get default LAYOUT-Data.');
     else
       layout{end+1}=LAYOUT;
     end
   end
return;

function lsb_datainfo_Callback(hObject, eventdata, handles)
% ---------------------------------------
% Filter Data Reload 
%  if there is Filter Data in Load Data
%    Load Filter Data
% ---------------------------------------
% Delete useless code. : 05-Jan-2006
  id = get( handles.lsb_datainfo,'Value');
  set(handles.selectnum_edit,'String',num2str(id));
return;

function selectnum_edit_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  If there are some sub-data in the data
%   Select by edit selectnum_edit
% ---------------------------------------

  % Get Numbe of Select Max
  n   = str2num(get( handles.selectnum_edit,'String'));
  if isempty(n), n=1; end

  % Now Selected Number Change
  nstr = length(get( handles.lsb_datainfo,'String'));
  nstr2 = find(n>nstr);
  if ~isempty(nstr2)
    strnum = num2str(n(nstr2));
    warndlg(['Over flow Value : ' strnum]);
    n(nstr2) = [];
  end

  set(handles.lsb_datainfo,'Value',n);

return;

function varargout = radio_all_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Change Enable / Disable for sub-data selection
% ---------------------------------------

  if get(h,'value')
    % selected
    set( handles.radio_select, 'value', 0);
    set( handles.selectnum_edit, 'visible', 'off');  
    set( handles.lsb_datainfo,'Max',100);
  else
    % unselected
    set( handles.radio_select, 'value', 1);
    set( handles.selectnum_edit, 'visible', 'on'); 
    selectnum_edit_Callback(handles.selectnum_edit, eventdata, handles)
  end

function varargout = radio_select_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Change Enable / Disable for sub-data selection
% ---------------------------------------

  if get(h,'value')
    % unselected
    if get( handles.radio_all, 'value')==1
      set( handles.radio_all, 'value', 0);
      id = get( handles.lsb_datainfo,'Value');
      set(handles.selectnum_edit,'String',num2str(id));
    end
    set( handles.selectnum_edit, 'visible', 'on'); 
    selectnum_edit_Callback(handles.selectnum_edit, eventdata, handles)
  else
    % unselected
    set( handles.radio_all, 'value', 1);
    set( handles.selectnum_edit, 'visible', 'off');
    set( handles.lsb_datainfo,'Max',100);
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C. Filter Manager : Extended Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Since : 1.01
function SaveGroupData(hObject,eventdata,handles)
% Call from OspFilteCallbacks
  % Load Selected File
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');

  if length(dt) < tg
    set(handles.lsb_datainfo, ...
	'Value', 1, ...
	'String', {'-- No Data Selected --'});
    setappdata(handles.figure1, 'LocalActiveData',[]);
    OspFilterCallbacks('LocalActiveDataOff', h,[],handles);
    return;
  end

  actdata = dt(tg);
  dtype   = func2str(actdata.fcn);
  if ~strcmp(dtype,'DataDef_GroupData'),
    return;
  end
	 
  fmd = OspFilterCallbacks('get',handles.figure1,0);
  if ~isfield(actdata.data,'data') || ...
          isempty(actdata.data)
      actdata.data = DataDef_GroupData('load', actdata.data);
  end

  if ~isempty(actdata.data.data)
      actdata.data.data(end).filterdata=fmd;
      
      actdata.data = DataDef_GroupData('save_ow',actdata.data);
      dt(tg)=actdata;
      set(handles.lsb_datalist, 'UserData',dt);
  end
  setappdata(handles.figure1,'SAVE_GROUP',false);

  main_h = OSP_DATA('GET','MAIN_CONTROLLER');
  main_h = main_h.hObject;
  vh=getappdata(main_h,'Viewer');
  if ~isempty(vh) && ishandle(vh),delete(vh); end

  ah=getappdata(main_h,'ActiveModule');
  if isempty(ah) || ~isstruct(ah), return; end
  ah=ah.gui;
  if ~isempty(ah) && ishandle(ah) && ...
		  strcmp('Block Filter',get(ah,'Name')),
	  delete(ah);
  end

function ReladFMD(hObject,ed,handles, actdata)
% Call from OspFilteCallbacks
% Reload FileManage Data
% ---> Comment out <--- 5-Nov-2005
return;
dt=get(handles.lsb_datalist, 'UserData');
st=get(handles.lsb_datalist, 'String');
vl=get(handles.lsb_datalist, 'Value');

% Make Header information
fcnstr = char(func2str(actdata.fcn));
fcnstr = fcnstr(9:end); % Remove DataDef_
head   = fcnstr(regexp(fcnstr,'[A-Z]')); % Get Large-Charactor

% Get Data Name
idfld = feval(actdata.fcn, 'getIdentifierKey');
dname = getfield(actdata.data,idfld);
dstr  = [head ' : ' dname];

ck    = strcmp(st{vl},dstr);
if ck==0, return; end
dt(vl)= actdata;
set(handles.lsb_datalist, 'UserData', dt);
% Change Selected Data
lsb_datalist_Callback(handles.lsb_datalist, [], handles);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D. Layout Manager
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbx_InnerLayout_Callback(hObject, eventdata, handles)
% ----------------------
%   Update Overview     
% ----------------------
 
  % ----------------
  % Get LAYOUT-Data 
  % ----------------
  innerstr=get(handles.lbx_InnerLayout, 'String');
  val     =get(handles.lbx_InnerLayout, 'Value');
  layout  =get(handles.lbx_InnerLayout, 'UserData');  % header.VIEW.LAYOUT
  % ----------------
  % Check selected  
  % ----------------
  if isempty(val) || val==0,return;end;
  if length(val)>1,
    warndlg('Please select one from LAYOUT list');
    return;
  end
  % ----------------
  % Update overview 
  % ----------------
  vgdata=layout{val}.vgdata;
  axh=handles.ax_OverView;
  axes(axh); cla;
  axis manual; axis([0 1 0 1]); hold on;
  pos=[0 0 1 1];
  overview_child(pos,vgdata,axh);
return;

function overview_child(pos,vgdata,axh)
% -----------------------------------------
% Function for Change OverView
%  Import from LayoutManager ->reload_child
%
% pos    : Plot Position.
% vgdata : Current View Group Data.
% axh    : Plot Axes.
% -----------------------------------------
  for idx =1:length(vgdata)
    % Get Basic Information
    info=feval(vgdata{idx}.MODE,'getBasicInfo');

    % View Box
    lpos=vgdata{idx}.Position;
    absp=getPosabs(lpos,pos);
    x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1)];
    y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4)];
    axes(axh); % To Confine Axes.
    h = fill(x,y,info.col);
    % Set Callback & User Data
    set(h,'LineStyle', ':', ...
	  'EdgeColor', [1 0 0]);
    % Can be down?
    if info.down,
      overview_child(absp,vgdata{idx}.Object,axh);
    end
  end
return;

function lpos=getPosabs(lpos,pos),
% -----------------------------------------
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% -----------------------------------------
  lpos([1,3]) = lpos([1,3])*pos(3);
  lpos([2,4]) = lpos([2,4])*pos(4);
  lpos(1:2)   = lpos(1:2)+pos(1:2);
return;

function psb_modify_Callback(hObject, eventdata, handles)
%----------------------------------------
% Update LayoutData or Update LayoutFile 
%----------------------------------------
  % Get 
  val     =get(handles.lbx_InnerLayout, 'Value');
  layout  =get(handles.lbx_InnerLayout, 'UserData');  % header.VIEW.LAYOUT

  path    =get(handles.psb_ChangeLayoutDir, 'UserData');

  % Check
  if length(val)>1,
    warndlg('Please select one from LAYOUT-Data list');
    return;
  end
  set(handles.figure1, 'Visible', 'off');
  % Start LayoutManager & Update Layout Data
  if ~isempty(layout),
    update_lbx_InnerLayout(handles,path);
  else
    update_pop_layoutfile(handles,path);
  end
  set(handles.figure1, 'Visible', 'on');
  
return;

function update_lbx_InnerLayout(handles, path)
%-----------------------------------------------
% Update Layout-Data, File-DataList
% Reload LayoutFile
%
%  Set lbx_InnerLayout
%  Set lsb_datalist
%  path: Current Layout-Data path
%-----------------------------------------------
  innerstr = get(handles.lbx_InnerLayout, 'String');
  val      = get(handles.lbx_InnerLayout, 'Value');
  layout   = get(handles.lbx_InnerLayout, 'UserData');  % header.VIEW.LAYOUT
  % Open LayoutManager and Update
  %layout=layout{val};
  try
    if ~isempty(path),
      ret=LayoutManager('LAYOUT', layout{val}, 'LayoutPath', path);
    else
      ret=LayoutManager('LAYOUT', layout{val});
    end
    if ~isempty(ret),
      layout{val}=ret;
      innerstr{val}=layout{val}.vgdata{1}.NAME;
      set(handles.lbx_InnerLayout, 'String',   innerstr);
      set(handles.lbx_InnerLayout, 'UserData', layout);
      % tmp; testcode 
      %warndlg({C__FILE__LINE__CHAR, 'Debug'});
      [sflg, msg] = replaceLayout(layout,handles);
      %  Error check
      if (~sflg),
	h=errordlg(msg);
	waitfor(h); return;
      end
    end
    % Update pop_layoutfile <=FileSaves
    reload_layoutfile(handles, path);
  catch
    h=errordlg('Could not Update Layout-Data.');
    waitfor(h);
    set(handles.figure1, 'Visible', 'on');
    return;
  end
return;

function update_pop_layoutfile(handles, path)
%-----------------------------------------------------
% Load LayoutFile, Update LayoutData, Save LayoutFile 
% Reload LayoutFile
%
%  Set pop_layoutfile
%  path: Current Layout-Data path
%-----------------------------------------------------
  % Get pop_Layoutfile
  filestr  = get(handles.pop_layoutfile, 'String');
  fval     = get(handles.pop_layoutfile, 'Value');
  %  pop_layout:userdata{}={'full path','default'or empty}
  fullpath = get(handles.pop_layoutfile, 'UserData');
  % -------------------------
  % Check default LayoutFile 
  % -------------------------
  if length(fullpath{fval})>1,
    h=errordlg(['Could not change Layout-File of Default' ...
		' directory.']);
    waitfor(h);return;
  end
  fpath       = fullpath{fval}{1};
  [pname, fname, ext]=fileparts(fpath);
  % Open LayoutManager and Update
  load(fpath, 'LAYOUT');
  if ~exist('LAYOUT'),
    h=errordlg('Could not load LAYOUT-Data.');
    waitfor(h);   return;
  end
  try
    if ~isempty(path),
      ret=LayoutManager('LAYOUT', LAYOUT, 'LayoutPath', path);
    else
      ret=LayoutManager('LAYOUT', LAYOUT);
    end
    if ~isempty(ret),
      LAYOUT=ret;
      % Save
      rver=OSP_DATA('GET','ML_TB');
      rver=rver.MATLAB;
      if rver >= 14,
	save(fpath, 'LAYOUT', '-v6'); % save as Version 6
      else
	save(fpath, 'LAYOUT');
      end
    end
    % Update pop_layoutfile <=FileSaves
    reload_layoutfile(handles, path);
  catch
    h=errordlg('Could not Save Layout-Data.');
    waitfor(h);
    set(handles.figure1, 'Visible', 'on');
    return;
  end
return;

function psb_ChangeLayoutDir_Callback(hObject, eventdata, handles)
%------------------------------------
% Update Current Layout-Data path    
%
%  Set pop_ChangeLayoutDir 
%  Set pop_layoutfile 
%------------------------------------

  % Change Directory
  osppath     = OSP_DATA('GET','OspPath');
  try,
    ldir = uigetdir(osppath);
    if isequal(ldir,0), return;end
  catch,
  end
  % Set path
  set(handles.psb_ChangeLayoutDir, 'UserData', ldir);
  % Reload pop_layoutfile
   reload_layoutfile(handles, ldir);
return;

function reload_layoutfile(handles, path)
%---------------------------------------------------
% Update LayoutFile List of Current LayoutFile Path 
% 
%  Set pop_layoutfile 
%  path: Current Layout-Data path 
%---------------------------------------------------
   fstr = get(handles.pop_layoutfile, 'String');
   %  userdata{}={'full path','default'or empty}
   ud   = get(handles.pop_layoutfile, 'UserData');

   % -------------------------
   % Check default LayoutFile 
   % -------------------------
   for i=length(ud):-1:1,
     if length(ud{i})<2,
       ud(i)=[]; fstr(i)=[];
     end
   end
   % ------------------------------
   % Check LAYOUT-Data format file 
   % ------------------------------
   list = dir([path filesep 'LAYOUT*.mat']);
   if ~isempty(list),
     for i=1:length(list),
       [p f e]    = fileparts(list(i).name);
       fstr{end+1}= f;
       ud{end+1}  = {[path filesep list(i).name]};
     end
   end
   set(handles.pop_layoutfile, 'String',   fstr);
   set(handles.pop_layoutfile, 'UserData', ud);
   set(handles.pop_layoutfile, 'Value',    1);
return;

function psb_AddLayout_Callback(hObject, eventdata, handles)
%---------------------------------------------------
% Load popupmenu LayoutFile, Add to LayoutData List
%
%  Set lbx_InnerLayout
%  Update lsb_datalist 
%---------------------------------------------------
  % -----------------------------
  % Check lsb_datalist selecting 
  % -----------------------------
  val=get(handles.lsb_datalist, 'Value');
  ud =get(handles.lsb_datalist, 'UserData');
  if isempty(ud),
    errordlg('Select DataList.');
    return;
  end
  % Get lbx_InnerLayout
  innerstr = get(handles.lbx_InnerLayout, 'String');
  layout   = get(handles.lbx_InnerLayout, 'UserData');
  ival     = get(handles.lbx_InnerLayout, 'Value');
  % Get pop_Layoutfile
  filestr  = get(handles.pop_layoutfile, 'String');
  fval     = get(handles.pop_layoutfile, 'Value');
  %  userdata{}={'full path','default'or empty}
  fullpath = get(handles.pop_layoutfile, 'UserData');
  fpath    = fullpath{fval}{1};
  load(fpath, 'LAYOUT');
  if ~exist('LAYOUT'),
    errordlg('Could not load LAYOUT-Data.');
    return;
  end
  % Set lbx_InnerLayout
  if isfield(LAYOUT, 'vgdata'),
    innerstr{end+1}=LAYOUT.vgdata{1}.NAME;
  else
    innerstr{end+1}='Untitled';
  end
  layout{end+1}=LAYOUT;
  set(handles.lbx_InnerLayout, 'String', innerstr);
  set(handles.lbx_InnerLayout, 'UserData', layout);
  ival = length(layout);
  set(handles.lbx_InnerLayout, 'Value', ival);

  % --------------------
  % Update lsb_datalist 
  % --------------------
  [sflg, msg]=replaceLayout(layout, handles);
  %  Error check
  if (~sflg),
    h=errordlg(msg);waitfor(h);
    return;
  end
return;

function pop_layoutfile_CreateFcn(hObject, eventdata, handles)
% ----------------------------------------------------------------
% Create popupmenu LayoutFile 
%
%  Set Default LayoutFile(OSP/ospData/LAYOUTXXXXXX.mat) to 
%                                                  pop_layoutfile 
% ----------------------------------------------------------------
  %-------------------------
  % Load default LayoutFile 
  %-------------------------
  fstr={};  ud={};
  osppath     = OSP_DATA('GET','OspPath');
  defaultpath = [osppath filesep 'ospData'];
  list = dir([defaultpath filesep 'LAYOUT*.mat']);
  if ~isempty(list),
    for i=1:length(list),
      [p f e]    = fileparts(list(i).name);
      fstr{end+1}= f;
      ud{end+1}  = {[defaultpath filesep list(i).name], 'default'};
    end
  end
  % Set LAYOUT-Data of DefaultDirectory
  if ~isempty(fstr) && ~isempty(ud),
    set(hObject, 'String', fstr);
    %  userdata{}={'full path','default'or empty}
    set(hObject, 'UserData', ud);
    set(hObject, 'Value', 1);
  end
return;

function psb_InitialProperty_Callback(hObject, eventdata, handles)
  % Not support yet.
return;

function psb_DeleteLayout_Callback(hObject, eventdata, handles)
%---------------------------------------------------
% Delete from LayoutData List
%
%  Set lbx_InnerLayout, Update overview
%  Update lsb_datalist 
%---------------------------------------------------
  % -----------------------------
  % Check lsb_datalist selecting 
  % -----------------------------
  val=get(handles.lsb_datalist, 'Value');
  if isempty(val),
    errordlg('Select DataList.');
    return;
  end
  % Get lbx_InnerLayout
  innerstr = get(handles.lbx_InnerLayout, 'String');
  layout   = get(handles.lbx_InnerLayout, 'UserData');
  value    = get(handles.lbx_InnerLayout, 'Value');
  % Check lbx_InnerLayout
  if isempty(value),return;end
  if length(layout)==1 && value==1,
    warndlg(' Could not delete last.');
    return;
  end
  if value>0,
    innerstr(value)=[];
    layout(value)=[];
    if length(innerstr)<value,value=length(innerstr);end
  end
  set(handles.lbx_InnerLayout, 'String', innerstr);
  set(handles.lbx_InnerLayout, 'UserData', layout);
  set(handles.lbx_InnerLayout, 'Value', value);
  % Update overview
  lbx_InnerLayout_Callback(handles.lbx_InnerLayout,[],handles);
  % --------------------
  % Update lsb_datalist 
  % --------------------
  [sflg, msg]=replaceLayout(layout, handles);
  %  Error check
  if (~sflg),
    h=errordlg(msg);waitfor(h);
    return;
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E. View Execution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%========================
% Save Data
% Doc (View.doc: section 5.3, id == I)
%========================
function psb_save_timeData_Callback(hObject, eventdata, handles)
% ---------------------------------------
% Make Plot data & Save Plot Data, 
% Save Directory is use WORK_DIRECTORY in  default
%
% output data is User-Command-Data
% ---------------------------------------

  % -- SignalViewOption Get --
  key = getSignalView2Option(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end

  try,
    [data, header] = make_ucdata(key,handles);
  catch,
    OSP_LOG('note', ...
	    ' Can not save : cannot make data to save', ...
	    lasterr);
  end
  
  % -- File name Get --
  [f p] = osp_uiputfile('*.mat', ...
	  'Save Block Data', ...
	  ['BlockData' datestr(now,30)]);
  if (isequal(f,0) || isequal(p,0)), return; end
  filename = [p filesep f];

  % Save
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    % save as Version 6
    save(filename, 'data','header','-v6');
  else
    save(filename, 'data','header');
  end
return;

%========================
% Make Mfile
% Doc (View.doc: section 5.3, id == II)
%========================
function mfile_tmp = make_pre_mfile(key,handles),
% Make Plot Data
  plot_func = func2str(key.actdata.fcn);
  % Make User Data
  switch lower(plot_func),
   case {'datadef_signalpreprocessor', 'datadef_groupdata'},
    fname0  = feval(key.actdata.fcn, 'make_mfile',key);
   otherwise,
    % data=[]; header=[];
    error(['Undefined Data for viewer : ' plot_func]);
  end

  % ==== Add Plot ===
  [fid, mfile_tmp] = make_mfile('fopen',fname0,'a');
  try,
    % osp_LayoutViewer.m
    make_mfile('code_separator', 1);
    make_mfile('as_comment', 'OSP Signal Viewer II');
    make_mfile('code_separator', 1);
    % Setup Bdata Option
    switch lower(plot_func),
     case 'datadef_signalpreprocessor', 
      make_mfile('with_indent',...
		 sprintf('LAYOUT=chdata{1}.VIEW.LAYOUT{%d};',...
			 get(handles.lbx_InnerLayout, 'Value')));
      make_mfile('with_indent',...
		 {'h=osp_LayoutViewer(LAYOUT,chdata,cdata);'});
     case 'datadef_groupdata',
      make_mfile('with_indent',...
		 sprintf('LAYOUT=bhdata.VIEW.LAYOUT{%d};',...
			 get(handles.lbx_InnerLayout, 'Value')));
      make_mfile('with_indent',...
		 {'h=osp_LayoutViewer(LAYOUT,chdata,cdata, ...', ...
		  '  ''bhdata'',bhdata, ''bdata'', bdata);'});
     otherwise,
      error(['Undefined Data for viewer : ' plot_func]);
    end
    make_mfile('with_indent',' ');
    
    % Figure Controller Add
    make_mfile('as_comment','% Launch Figure-Controller');
    make_mfile('with_indent','fc=figure_controller;');
    make_mfile('with_indent','hs=guidata(fc);');
    make_mfile('with_indent','try,');
    make_mfile('indent_fcn','down');
    make_mfile('with_indent',['figure_controller('...
		    ,'''setFigureHandle'',h.figure1,[],hs);']);
    make_mfile('indent_fcn','up');
    make_mfile('with_indent','end');
  catch,
    make_mfile('fclose');
    edit(mfile_tmp);
    rethrow(lasterror);
  end
  make_mfile('fclose');
return;

function psb_mfile_plot_data_Callback(hObject, eventdata, handles)
% -- SignalViewOption Get --
  key = getSignalView2Option(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  
  % -- File name Get --
  [f p] = osp_uiputfile('*.m', ...
			'Output M-File Name', ...
			['osp_Signal_Viewer2_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel

  % == Make M-File ==
  fname = [p filesep f];  key.fname=fname;
  fname0 = make_pre_mfile(key,handles);
  %edit(fname);

%========================
% Draw : Open osp_LayoutViewer
% Doc (View.doc: section 5.3, id == III)
%========================
function varargout=psb_draw_Callback(h, eventdata, handles,varargin)
% Open osp_LayoutViewer
% ---------------------------------------

  if ~isempty(varargin) || nargout>=1,
    errordlg(' Data I/O Error');
    return;
  end

  % -- SignalViewOption Get --
  key = getSignalView2Option(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  % filename : tmp-name
  if isfield(key,'fname'),key=rmfield(key,'fname');end 

  % == Make M-File ==
  fname0 = make_pre_mfile(key,handles);
  scriptMeval(fname0);
  delete(fname0);
return;

function psb_close_Callback(hObject, eventdata, handles)
%---------------------------------------------------
% Close  of signal_viewer2
%---------------------------------------------------
   % To signal_viewer2_DeleteFcn
   delete(handles.signal_viewer2);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X. Common Tool of SIGNAL_VIEWER2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  -- Contents of Common Tool of SIGNAL_VIEWER2--
%  1. Get Signal View2 : Select Data Key. 
%    key = getSignalView2Option(handles)
%
%  2. Replace LAYOUT-DATA
%    [sflg, msg] = replaceLayout(cellLAYOUT,handles, key);
%
%   3. Make UserCommand Data
%    [data, header]= make_ucdata(key,handles);
%

function key = getSignalView2Option(handles)
% ---------------------------------------
%  Common Signal Viewer Option Setting Function
% ---------------------------------------
% -- Get SignalViewOption --
% key.actdata
% key.filterManage

  %  ==== Load Data ====
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');

  if length(dt) < tg
    key=struct([]); return;
  end

  % * Active Data
  actdata = dt(tg); clear dt tg;

  % * Make Time-Data Option
  filterManage = OspFilterCallbacks('get', handles.figure1);
  dtype   = func2str(actdata.fcn);

  % ---> Select Block <---
  if strcmp(dtype,'DataDef_GroupData');
    actdata.data = DataDef_GroupData('load', actdata.data);
    tmpdata = actdata.data.data;
    % * Re Make Selection Data
    if get(handles.radio_select, 'value')
      id0 = get(handles.lsb_datainfo,'Value');
      li  = get(handles.lsb_datainfo,'UserData');
      id1 = 1:size(li,1);
      id1(id0) = [];
      for id2 = length(id1):-1:1
	id = id1(id2);
	if any(li(id,:)==0), continue; end
	if isfield(tmpdata(li(id,1)).stim,'ver'),
	  tmpdata(li(id,1)).stim.flag(li(id,2:3),:) = logical(1);
	else,
	  tmpdata(li(id, 1)).stim.StimData(li(id,2)).stimtime(li(id,3)).chflg(:) ...
	      = logical(0);
	end
      end
    end

    % Remove Unused Data
    for id = length(tmpdata):-1:1
      if isfield(tmpdata(id).stim,'ver'),
	if ~strcmp(tmpdata(id).stim.ver,'1.50'),
	  error(['Unknown version ' ...
		 tmpdata(id).stim.ver]);
	end
      else,
	for id2 = length(tmpdata(id).stim.StimData):-1:1
	  if length(tmpdata(id).stim.StimData(id2).stimtime)==0 
	    tmpdata(id).stim.StimData(id2)=[];
	  end
	end
	if length(tmpdata(id).stim.StimData) == 0
	  tmpdata(id)=[];
	end
      end
    end % Data Loop Remove
    
    if isempty(tmpdata)
      actdata=[];
    else
      [tmpdata.filterdata] = deal(filterManage);
      actdata.data.data = tmpdata;
    end % isempty?
  end % ---> Select Block <---

  key.actdata          = actdata;
  key.filterManage      = filterManage;
return;

function [sflg, msg] = replaceLayout(caLayout,handles, key)
% Replace Layout-Data in the File
%    Input Variable :
%        caLayout   : Cell Array of LAYOUT
%        key        : key of save-data
%                    (if there is no key, get by 
%                     use getSignalView2Option) 
%    Output Variable :
%         sflag : success -> true/false
%         msg   : error message( if there)
%
% @since 1.03
%
sflg=false; msg=['Unknown Error'];

%-------------------
% information Check0
%-------------------
dt=get(handles.lsb_datalist, 'UserData');
tg=get(handles.lsb_datalist, 'Value');
if length(dt)<tg,
  error('No Data-File Selected');
end

%----------------
% Arguments Check
%----------------
msg0=nargchk(2,3,nargin);
if ~isempty(msg0),
  msg=msg0; return;
end
if nargin==2,
  key = getSignalView2Option(handles);
end

%-------------------------
% <- Replace  Data File ->
%-------------------------
try
  % DataDef_ Check
  fcnstr = char(func2str(key.actdata.fcn));
  flst ={'DataDef_SignalPreprocessor', ...
	 'DataDef_GroupData'};
  ck = find(strcmp(flst,fcnstr));
  if isempty(ck),
    error([' Data : '  fcnstr ' is undefined']);
  end

  % Execute Replace
  feval(key.actdata.fcn, 'ReplaceViewLayout',...
	caLayout,key.actdata);
catch
  msg = lasterr;return;
end

%-------------------------------
% <- Replace  Data List box   ->
%   User-Data 
%  Bugfix : 060217A : No1
%-------------------------------
dt0=dt(tg);

% < For Signal-Data >
%  there is noting to do now.

% < For Group-Data >
if isfield(dt0.data,'VLAYOUT'),
  dt0.data.VLAYOUT=caLayout;
  dt(tg)=dt0;
end
set(handles.lsb_datalist, 'UserData', dt);

% Success End
if nargout>=1,
  sflg=true; msg='';
end


function [data, header] = make_ucdata(key,handles),
% Make User-Command-Data
  plot_func = func2str(key.actdata.fcn);
  % Make User Data
  switch lower(plot_func),
   case {'datadef_signalpreprocessor', 'datadef_groupdata'},
      [data, header]  = feval(key.actdata.fcn, 'make_ucdata',key);
   case 'datadef_ttest',
    data_tmp = DataDef_TTest('load',key.actdata.data); 
    data = data_tmp.data.Data;
    header.measuremode = data_tmp.data.MeasureMode;
    header.TAGs.DataTag= data_tmp.data.Tag;
    % unit is uniqe:
    % 1: t-value, 2: p-value, ...
    header.samplingperiod = 1;
    
   otherwise,
    % data=[]; header=[];
    error(['Undefined Data for viewer : ' plot_func]);
  end
return;


function ax_OverView_CreateFcn(hObject, eventdata, handles)
axis off


