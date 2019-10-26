function varargout = signal_viewer(varargin)
% SIGNAL_VIEWER Application M-file for Viewer of OSP Data version 1.0
%
%    FIG = SIGNAL_VIEWER launch signal_viewer GUI.
%    SIGNAL_VIEWER('callback_name', ...) invoke the named callback.
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
% * Overview of SIGNAL_VIEWER
%   Functions in SIGNAL_VIEWER is classificated by following parts
%     A. Plot Data Selection 
%     B. Common Signal Viewer Option
%     C. HB x time / fft-result Plot
%     D. Image plot
%  
%
% * Available Data in SIGNAL_VIEWER 
%  Data that can available in SIGNAL_VIEWER is
%  defined in DataDef_***.m, and that include
%  common interface for uiFileSelect and Signal_viewer.
%  So If you want to add available data, please make
%  DataDef Function at fast.
%
%
% See also: GUIDATA, UIFILESELECT, DATA


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Last Modified by GUIDE v2.5 11-May-2006 23:52:22

% == History ==
% author : ??
% create : ??
% $Id: signal_viewer.m 180 2011-05-19 09:34:28Z Katura $
% 
% Reversion 1.15, 23-May-2005 
%    Add LinePlotproperty.
%    Use uiwait.
%
% Reversion 1.16, 
%    Change LinePlotproperty
%    As Object include Data.
%
% Reversion 1.22,
%    Apply Position-Data
%
% Reversion 1.34
%    Add : SaveGroupData

if nargin == 0  % LAUNCH GUI

	% == Opening Function ==
	fig = openfig(mfilename,'reuse');
	set(fig,'Color','white');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	handles.figure1 = fig;
	guidata(fig, handles);
	set_lineprop(handles);

	if nargout > 0
		varargout{1} = fig;
	end

	%---------------------
	% Chaneg Status of OSP
  %---------------------
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
  svh=getappdata(mc.hObject,'Viewer2');
  if ~isempty(svh) && ishandle(svh),
    delete(svh);
    setappdata(mc.hObject,'Viewer2',[]);
  end
  
  % V3
  svh=getappdata(mc.hObject,'Viewer3');
  if ~isempty(svh) && ishandle(svh),
    delete(svh);
    setappdata(mc.hObject,'Viewer3',[]);
  end    

	% Update OSP Main Controler View
	setappdata(mc.hObject,'Viewer',fig);
	OSP('reloadView',mc.hObject,mc.eventdata,mc.handles);
	
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
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


function main_strns_fig_DeleteFcn(hObject, eventdata, handles)
% ---------------------------------------
% Delete Function of the SIGNAL_VIEWER
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
  OSP('reloadView',mc.hObject,mc.eventdata,mc.handles,'rmViewer');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     A. Plot Data Selection 
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
%     set(handles.r78_chb, 'Value',0, 'Visible','off');
%     set(handles.r83_chb, 'Value',0, 'Visible','off');
%     set(handles.mrk_chb, 'Value',0, 'Enable','off');

    set(handles.radio_all,'value',1, 'Visible', 'off');
    set(handles.radio_select, 'value', 0, 'Visible', 'off');
    set(handles.selectnum_edit, 'visible', 'off'); 
    set(handles.pop_datachaneg,'Enable','on');
	
    % not in use ---> move to DataListBox select
    % Load Selected File
    dt=get(handles.lsb_datalist, 'UserData');
    tg=get(handles.lsb_datalist, 'Value');
    if length(dt) < tg,  return;  end
	 
    switch dtype

      % ********************** 
     case 'DataDef_SignalPreprocessor'
      % ********************** 

      % === Viewer Setting ===
      set(handles.pop_plotmode, ...
	  'Value',1, ...
	  'String','time');

      set(handles.mrk_chb,'Value',1, 'Enable','on');  

      % === Data Print ===
      info = feval(actdata.fcn, 'showinfo', actdata.data);

      % -- Reset, Filter List --
      OspFilterCallbacks('set',handles.figure1, []);

      % ********************** 
     case 'DataDef_GroupData'
      % ********************** 
      actdata.data = feval(actdata.fcn, 'load', actdata.data);
      % === Viewer Setting ===
      set(handles.pop_plotmode, ...
	  'Value',1, ...
	  'String','time-block')
      set(handles.radio_all, 'Visible', 'on');
      set(handles.radio_select,  'Visible', 'on');
      set(handles.mrk_chb, 'Value',1, 'Enable','on');

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
    OSP_LOG('err', lasterr ,['Setting Signal Viewer ' dtype]);
    errordlg({' Data Load Error', lasterr}); 
  end

  % Reload Active Data
  OSP_DATA('SET', 'ActiveData', actdata_tmp);
%   if ~isempty(actdata_tmp) && ~isempty(actdata_tmp.fcn)
%     feval(actdata_tmp.fcn, 'load'); % not effective::
%   end

  lsb_datainfo_Callback(handles.lsb_datainfo, [], handles);

  % add for open_lineplot_prop,
  %  @since 1.16
  lpph = getappdata(handles.figure1,'LinePlotPropertyHandle');
  if ~isempty(lpph) && ishandle(lpph),
    dt=get(handles.lsb_datalist, 'UserData');
    tg=get(handles.lsb_datalist, 'Value');
    if tg>length(dt),dt=[]; else, dt=dt(tg); end
    handles2 = guihandles(lpph);
    osp_lineplot_prop('setTitleAvailableData',lpph,[],handles2,dt);
    % @since 1.17,
    %  -> send front LinePlotProperty GUI.
    figure(lpph);
  end

  % Image Mode change
  % @since 1.25
  reload_image_modetype(handles);
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
%     B. Common Signal Viewer Option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_stimkind_reload_Callback(hObject, eventdata, handles)
% Reload Tag
% TODO :
%  hObject    handle to psb_stimkind_reload (see GCBO)

  key = getSignalViewOption(handles);
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

  str   = header.TAGs.DataTag;
  if isempty(str),
	  error('No Tags exist');
  end
  
  str = char(str);
  str = [repmat(' x ',size(str,1),1), str];
  str = cellstr(str);
  
  val   = get(handles.lsb_stimkind,'Value');
  if isfield(header,'VIEW') && ...
	isfield(header.VIEW,'lineprpo')
    ud = header.VIEW.lineprpo;
  else,
    ud    = get(handles.lsb_stimkind,'UserData');
    if ~isstruct(ud), ud=[]; end
  end
  col=[1, 0, 0; 0, 0, 1; 0 0 0];

  if ~isempty(ud),
    lineprop = ud;
  end
  for skind_idx=1:length(ud)
    lineprop{skind_idx}.use   = logical(0);
  end
  for skind_idx=(length(ud)+1):size(str,1),
    lineprop{skind_idx}.use   = logical(0);
    lineprop{skind_idx}.color = [0 0 1];
    lineprop{skind_idx}.style = '-';
    lineprop{skind_idx}.mark  = 'none';
    lineprop{skind_idx}.LineWidth= 0.5;
    lineprop{skind_idx}.MarkerSize= 6;
  end
  if val>size(str,1), val=size(str,1); end
	  
  set(handles.lsb_stimkind,'String',   str);
  set(handles.lsb_stimkind,'Value',    val);
  set(handles.lsb_stimkind,'UserData', lineprop);


% --- Executes during object creation, after setting all properties.
function lsb_stimkind_CreateFcn(hObject, eventdata, handles)

  udata={};

  udata{1}.use   = logical(0);
  udata{1}.color = [1 0 0];
  udata{1}.style = '-';
  udata{1}.mark  = 'none';
  udata{1}.LineWidth= 0.5;
  udata{1}.MarkerSize= 6;

  udata{2}.use   = logical(0);
  udata{2}.color = [0 0 1];
  udata{2}.style = '-';
  udata{2}.mark  = 'none';
  udata{2}.LineWidth= 0.5;
  udata{2}.MarkerSize= 6;

  udata{3}.use   = logical(1);
  udata{3}.color = [0 0 0];
  udata{3}.style = '-';
  udata{3}.mark  = 'none';
  udata{3}.LineWidth= 0.5;
  udata{3}.MarkerSize= 6;


  set(hObject,'String', {' x Oxy', ' x Deoxy', ' o Total'}, ...
	      'UserData',udata, ...
	      'Value',1);


% --- Executes during object creation, after setting all properties.
function lsb_stimkind_Callback(hObject, eventdata, handles)
% Stimulation Data

  str   = get(hObject,'String');
  val   = get(hObject,'Value');
  udata = get(hObject,'UserData');

  if length(udata)<val,
      return;
  end
  
  tmp=str{val};
  if udata{val}.use,
    udata{val}.use=false;
    tmp(2) = 'x';
  else,
    udata{val}.use=true;
    tmp(2) = 'o';
  end
  str{val} = tmp;
  
  set(hObject,'String',str,'UserData',udata);
  set_lineprop(handles);
return;

function set_lineprop(handles),
% Line Property --> to GUI
  if isempty(handles), return; end
  vl=get(handles.lsb_stimkind,'Value');
  ud=get(handles.lsb_stimkind,'UserData');
  ud=ud{vl};
  
  if isfield(ud,'mark'),
      str=get(handles.pop_LineMark,'String');
      vl0=find(strcmp(str,ud.mark)==1);
      if ~isempty(vl0)
          set(handles.pop_LineMark,'Value',vl0);
      end
  end
  if isfield(ud,'style'),
      str=get(handles.pop_LineStyle,'String');
      vl0=find(strcmp(str,ud.style)==1);
      if ~isempty(vl0)
          set(handles.pop_LineStyle,'Value',vl0);
      end
  end
  if isfield(ud,'color')
    set(handles.frame_Color,'BackgroundColor',ud.color);
  end      
  if isfield(ud,'LineWidth'),
    vl0=get(handles.pop_LineWidth,'UserData');
    vl1=find(vl0==ud.LineWidth);
    if ~isempty(vl1)
      set(handles.pop_LineWidth,'Value',vl1);
    end
  end
  % MakerSize
  if isfield(ud,'MarkerSize'),
    vl0=get(handles.pop_MarkerSize,'UserData');
    vl1=find(vl0==ud.LineWidth);
    if ~isempty(vl1)
      set(handles.pop_MarkerSize,'Value',vl1);
    end
  end

return;

function pop_LineMark_Callback(hObject, eventdata, handles)
  vl=get(handles.lsb_stimkind,'Value');
  ud=get(handles.lsb_stimkind,'UserData');
  ud0=ud{vl};

  str=get(handles.pop_LineMark,'String');
  ud0.mark = str{get(handles.pop_LineMark,'Value')};
  ud{vl}=ud0;
  set(handles.lsb_stimkind,'UserData',ud);
function pop_MarkerSize_Callback(hObject, eventdata, handles)
% Set LineMarker Size
%  udata{3}.MarkerSize= 6;
  vl=get(handles.lsb_stimkind,'Value');
  ud=get(handles.lsb_stimkind,'UserData');
  ud0=ud{vl};

  vll=get(handles.pop_MarkerSize,'UserData');
  ud0.MarkerSize = vll(get(handles.pop_MarkerSize,'Value'));
  ud{vl}=ud0;
  set(handles.lsb_stimkind,'UserData',ud);

function pop_LineWidth_Callback(hObject, eventdata, handles)
% Set LineWidth 
%  udata{3}.LineWidth= 0.5;
  vl=get(handles.lsb_stimkind,'Value');
  ud=get(handles.lsb_stimkind,'UserData');
  ud0=ud{vl};

  vll=get(handles.pop_LineWidth,'UserData');
  ud0.LineWidth = vll(get(handles.pop_LineWidth,'Value'));
  ud{vl}=ud0;
  set(handles.lsb_stimkind,'UserData',ud);

function pop_LineStyle_Callback(hObject, eventdata, handles)
  vl=get(handles.lsb_stimkind,'Value');
  ud=get(handles.lsb_stimkind,'UserData');
  ud0=ud{vl};

  str=get(handles.pop_LineStyle,'String');
  ud0.style = str{get(handles.pop_LineStyle,'Value')};
  ud{vl}=ud0;
  set(handles.lsb_stimkind,'UserData',ud);

function psb_ColorDataKind_Callback(hObject, eventdata, handles)
  cl=uisetcolor(get(handles.frame_Color,'BackgroundColor'));

  if ~isequal(cl,0),
    vl=get(handles.lsb_stimkind,'Value');
    ud=get(handles.lsb_stimkind,'UserData');
    ud0=ud{vl};

    ud0.color = cl;
    ud{vl}=ud0;
    set(handles.lsb_stimkind,'UserData',ud);
    set(handles.frame_Color,'BackgroundColor',cl);
  end

  
function key = getSignalViewOption(handles)
% ---------------------------------------
%  Common Signal Viewer Option Setting Function
% ---------------------------------------
% -- Get SignalViewOption --
% key.actdata
% key.filterManage
% key.plot_kind

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
  plot_kind    = [];
  ud    = get(handles.lsb_stimkind, 'UserData');
  for idx=1:length(ud),
    ud0 = ud{idx}; 
    if ud0.use,
      plot_kind(end+1)=idx;
    end
  end
  % plot_kind    = find(plot_kind);
  % plot_kind    = plot_kind(:)';
  
  dtype   = func2str(actdata.fcn);
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
				  tmpdata(li(id,1)).stim.StimData(li(id,2)).stimtime(li(id,3)).chflg(:) ...
					  = logical(0);
			  end
		  end
	  end
	
	  % Remove Unused Data
	  for id = length(tmpdata):-1:1
		  if isfield(tmpdata(id).stim,'ver'),
			  if ~strcmp(tmpdata(id).stim.ver,'1.50'),
				  error(['Unknown version ' tmpdata(id).stim.ver]);
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
  end

  key.actdata          = actdata;
  key.filterManage      = filterManage;
  key.plot_kind         = plot_kind;  

return;

function mfile_tmp = make_pre_mfile(key,handles),
  plot_func = func2str(key.actdata.fcn);
  % Make User Data
  switch lower(plot_func),
   case {'datadef_signalpreprocessor', 'datadef_groupdata'},
      mfile_tmp  = feval(key.actdata.fcn, 'make_mfile',key);
   otherwise,
    % data=[]; header=[];
    error(['Undefined Data for viewer : ' plot_func]);
  end

  % set AdditionalData
  st =get(handles.lsb_stimkind,'String');
  ud =get(handles.lsb_stimkind,'UserData');
  [fid, fname1] = make_mfile('fopen',mfile_tmp,'a');
  try,
    make_mfile('code_separator', 1);
    make_mfile('as_comment', 'Viewer : Line Property');
    make_mfile('code_separator', 1);
    
    make_mfile('with_indent','lineprop={};');
    for idx=1:length(ud),
      make_mfile('with_indent',['% Kind : ' st{idx}]);
      ud0=ud{idx};
      flg=0;
      if isempty(ud0) || ~isstruct(ud0), continue; end
      if isfield(ud0,'color'),
	flg=1;
	make_mfile('with_indent',...
		   sprintf('tmp.color=[%f,%f,%f];',...
           ud0.color(1),...
           ud0.color(2),...
           ud0.color(3)));
      end
      if isfield(ud0,'style'),
	flg=1;
	make_mfile('with_indent',...
		   ['tmp.style=''' ud0.style ''';']);
      end
      if isfield(ud0,'mark'),
	flg=1;
	make_mfile('with_indent',...
		   ['tmp.mark=''' ud0.mark ''';']);
      end
      % Marker Size
      %  udata{3}.MarkerSize= 6;
      if isfield(ud0,'MarkerSize'),
	flg=1;
	make_mfile('with_indent',...
		   ['tmp.MarkerSize=' num2str(ud0.MarkerSize) ';']);
      end
      % Line Width
      %  udata{3}.LineWidth= 0.5;
      if isfield(ud0,'LineWidth'),
	flg=1;
	make_mfile('with_indent',...
		   ['tmp.LineWidth=' num2str(ud0.LineWidth) ';']);
      end

      if flg,
	make_mfile('with_indent', ...
		   ['lineprop{' num2str(idx) '} = tmp;']);
	make_mfile('with_indent', 'clear tmp');
      end
    end
    make_mfile('with_indent','hdata.VIEW.lineprop=lineprop;');
    
  catch,
    make_mfile('fclose');
    %edit(fname);
    rethrow(lasterror);
  end
  make_mfile('fclose');
  
return;

function [data, header] = make_ucdata(key,handles),
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

  ud =get(handles.lsb_stimkind,'UserData');
  header.VIEW.lineprop = ud;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     C. HB x time / fft-result Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_datachaneg_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Call back of DataChange popupmenu
%  This popupmenu select Additional Data exchange option.
%
%   In FFT, we use X-axis Freaquency so Stimulation Timing
%   can not plot. Here Select Enable/Disable by the data
% 
% ---------------------------------------

  id  = get(hObject,'Value');
  if id~=1,
    set(handles.mrk_chb, ...
	'Value',0,...
	'Enable', 'off');
   elseif ~strcmp(get(handles.mrk_chb, 'Enable'),'on')
      fd  = get(handles.lsb_datalist,'Userdata');
      fid = get(handles.lsb_datalist,'Value');
      if length(fd)>=fid
	fname=func2str(fd(fid).fcn);
	if strcmp(fname,'DataDef_SignalPreprocessor') || ...
	      strcmp(fname,'DataDef_GroupData')
	  set(handles.mrk_chb, 'Enable', 'on');
        end
      end
  end
return;

function [data , axis_label, unit] = pop_datachange_exe(dc_option,data, axis_label, unit)
% ---------------------------------------
% pop_datachange_exe is the discreate Selected DataChange-popupmenu
%
% dc_option is 
%  dc_option = get(handles.pop_datachaneg,'String');
%  dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
%
% transform of data along the 1st dimension by 
%  data, 3 Dimensional data, is Time x HB data x HBkind.
%
% Unit of Output data will be chaneg,
% so we output not only transfar data
% but also unit and axis_label 
% ---------------------------------------
  [data,axis_label, unit] = ...
      pop_data_change_v1(dc_option,data, axis_label, unit);
return;



function tgl_setLPprop_Callback(hObject, eventdata, handles)
% Line Prop Propertty Setting
% @since 1.15
% Change in 1.16, for Signal Protting. 

  % Enable value of this object.
  %  12-Jul-2005 :  M.Shoji
  val  = get(hObject,'Value');
  lpph = getappdata(handles.figure1,'LinePlotPropertyHandle');

  if val, % Open
    if isempty(lpph) || ~ishandle(lpph),
      dt=get(handles.lsb_datalist, 'UserData');
      tg=get(handles.lsb_datalist, 'Value');
      if tg>length(dt), dt=[]; else,dt=dt(tg);end
      lpph = osp_lineplot_prop;
      handles2 = guihandles(lpph);
      osp_lineplot_prop('setTitleAvailableData',lpph,[],handles2,dt);
      osp_lineplot_prop('setUpperGUI',handles.figure1,[],handles2);
      setappdata(handles.figure1,'LinePlotPropertyHandle',lpph);
    else,
      axes(lpph);
    end
  else, % Close
    if ~isempty(lpph) && ishandle(lpph),
      delete(lpph);
    end
  end
return;

function plot_arg = tgl_getLPprop(handles),
% get Line Plot Property
%  @since 1.15
% change 1.16
  plot_arg = {};
  lpph = getappdata(handles.figure1,'LinePlotPropertyHandle');
  if isempty(lpph) || ~ishandle(lpph),
    return;
  end
  
  % -- SignalViewOption Get --
  key = getSignalViewOption(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  
  % @since 1.16
  handles2 = guihandles(lpph);
  prop = osp_lineplot_prop('getAll',lpph,[],handles2);
  if isempty(prop), return; end

  % Special case
  if isfield(prop,'TitleFig'),
    data=key.actdata.data;
    prop.TitleFig = eval(prop.TitleFig);
  end

  % set arguments
  s=fieldnames(prop);
    
  for id=1:length(s),
    plot_arg{end+1}=s{id};
    plot_arg{end+1}=getfield(prop,s{id});
  end
return;



function psb_save_timeData_Callback(hObject, eventdata, handles)
% ---------------------------------------
% Make Plot data & Save Plot Data, 
% Save Directory is use WORK_DIRECTORY in  default
%
% output data is following 
%    strPlotData  : strPlotData.data is ploting data
%                   strPlotData.tag  is HB-Kind
%                   See also plot_HBdata
%
%    axis_label :  Axis Label of each data
%                  in this version there is some axis-unit
%                  example 
%                    x-axis have 2  time, frequency
%
%    unit        : unit of x-axis, 
%                  A Data point correspond to 1/unit.
%
%    actdata     : Information of Original Data Name 
%
% ---------------------------------------
  % -- SignalViewOption Get --
  key = getSignalViewOption(handles);
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
    save(filename, ...
	 'data', ...
	 'header', ...
	 '-v6'); % save as Version 6
  else
    save(filename, ...
	 'data', ...
	 'header');
  end
  
return;
  

function psb_mfile_plot_data_Callback(hObject, eventdata, handles)
% -- SignalViewOption Get --
  key = getSignalViewOption(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  plot_kind = key.plot_kind;
  if isempty(plot_kind),
    errordlg('No HB Kind to plot'); return;
  end
  
  % -- File name Get --
  [f p] = osp_uiputfile('*.m', ...
			'Output M-File Name', ...
			['osp__Viewer_rv19_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel

  % == Open M-File ==
  fname = [p filesep f];  key.fname=fname;
  fname0 = make_pre_mfile(key,handles);
  
  % Add Plot .. 
  [fid, fname1] = make_mfile('fopen',fname0,'a');
  try,
	  make_mfile('code_separator', 1);
	  make_mfile('as_comment', 'Viewer : Line Plot');
	  make_mfile('code_separator', 1);
	  
	  dc_option = get(handles.pop_datachaneg,'String');
	  dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
	  
	  if get(handles.mrk_chb, 'Value')==1,  stimplot = 'area';
	  else, stimplot = 'off'; end
	  
	  make_mfile('with_indent', 'h=uc_plot_data(hdata, data, ...');
	  make_mfile('indent_fcn','down');
	  make_mfile('with_indent', '''FigBGcolor'',  [1 1 1], ...');
	  make_mfile('with_indent', '''AXES_TITLE'',''on'', ...');
	  make_mfile('with_indent',['''DC_OPTION'',''' dc_option ''', ...']);
	  make_mfile('with_indent',['''STIMPLOT'', ''' stimplot  ''', ...']);
	  plot_arg = tgl_getLPprop(handles);
	  if ~isempty(plot_arg),
		  for idx=1:2:length(plot_arg),
			  tmp = plot_arg{idx+1};
			  if isnumeric(tmp),
				  tmp =['[' num2str(tmp) ']'];
			  else
				  if iscell(tmp),
					  tmp = tmp{1};
				  end
				  tmp = ['''' tmp ''''];
			  end  
			  make_mfile('with_indent',['''' plot_arg{idx}, ''', ' tmp ' , ...']);
		  end
	  end
	  make_mfile('with_indent',['''PlotKind'', [' num2str(plot_kind) ']);']);
	  make_mfile('indent_fcn','up');

	  % Figure Controller Add
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
	  %edit(fname);
	  rethrow(lasterror);
  end
  make_mfile('fclose');
  %edit(fname);



function varargout=pltexe_btn_Callback(h, eventdata, handles,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Time x HB / FFT result %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------
% Make Plot Data
%
%  Normary, pltexe_btn_Callback is
%  Call back of DataChange popupmenu
%    Make Data & Plot
%
% varargout = pltexe_btn_Callback(h, eventdata, handles, 'Nofig')
% varargout = pltexe_btn_Callback(h, eventdata, handles, 'Nofig',key)
%  if there is key input, signal_input option by key
%   only make Data for plot, and return data for plt
%  This is used in save-plot-data, image-push-button
%  varargout is following
%    1 : strHBdata
%    2 : axis_label
%    3 : unit
%    4 : actdata
%    5 : measure_mode
%    6 : stimInfo
%
% ---------------------------------------

 if ~isempty(varargin) || nargout>=1,
   errordlg(' Data I/O Error');
   return;
 end

  % -- SignalViewOption Get --
  key = getSignalViewOption(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end

  plot_kind = key.plot_kind;
  if isempty(plot_kind),
    errordlg('No HB Kind to plot'); return;
  end
  
  plot_func = func2str(key.actdata.fcn);
  
  [data, hdata] = make_ucdata(key,handles); 

  % Case Ploting Strat
  switch lower(plot_func),
   case {'datadef_signalpreprocessor', 'datadef_groupdata'},
    dc_option = get(handles.pop_datachaneg,'String');
    dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
		  
    if get(handles.mrk_chb, 'Value')==1,  stimplot = 'area';
    else, stimplot = 'off'; end
	
	plot_arg = tgl_getLPprop(handles);
    try,
        if isempty(plot_arg),
            h=uc_plot_data(hdata, data, ...
                'FigBGcolor',  [1 1 1], ...
				'DC_OPTION', dc_option, ...
                'STIMPLOT', stimplot, ...
                'PlotKind', plot_kind);
	    fc=figure_controller;
	    hs=guidata(fc);
		try,
			figure_controller('setFigureHandle',h.figure1,[],hs);
		end
        else,
            h=uc_plot_data(hdata, data, ...
                'FigBGcolor',  [1 1 1], ...
                'DC_OPTION', dc_option, ...
                'STIMPLOT', stimplot, ...
                'PlotKind', plot_kind, plot_arg{:});
	    fc=figure_controller;
	    hs=guidata(fc);
		try,
			figure_controller('setFigureHandle',h.figure1,[],hs);
		end
        end
    catch,
        errordlg(lasterr);return;
    end
    return;


   case 'datadef_ttest',  
	   errordlg('T-Test plot was removed..');
	   return;
   otherwise,
	   errordlg('Un-known error : undefined data-type');
	   return;
  end   % Case Ploting End
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     D. Image plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------
% Image Setting 
%----------------------
function smple_3d_tgl_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  View if 3D plot is On/Off
%  and reset Apprication data IMAGE_HANDLE
% ---------------------------------------
% Check Box : 3D Plot or not

  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');

  % Clear Data
  setappdata(handles.figure1, 'ImagePlotKind', []);
  % setappdata(handles.figure1, 'ImagePlotType', []);
  setappdata(handles.figure1, 'measuremode', []);
  setappdata(handles.figure1, 'HEADER', []);
  setappdata(handles.figure1, 'xdata', []);
  setappdata(handles.figure1, 'ydata', []);

  if get(hObject,'Value')==0
    % change color
    set(hObject, 'BackgroundColor', ...
		 get(handles.frame8, 'BackgroundColor'));
    set(handles.image_psb, 'BackgroundColor', ...
		      get(handles.save_avi_psb, 'BackgroundColor'));

    % delete image_handle
    try
      if ~isempty(image_h) && ishandle(image_h)
	hbimage3d('figure1_CloseRequestFcn',image_h, [], guihandles(image_h));
	rmappdata(handles.figure1, 'IMAGE_HANDLE');
      end
    end
    
  else
    % change color
    set(hObject,'BackgroundColor',[ 1 .843 .843]);
    set(handles.image_psb,'BackgroundColor',[1 .843 .843]);
    
    % delete image_handle
    if ~isempty(image_h) && ishandle(image_h)
        close(image_h);
        rmappdata(handles.figure1, 'IMAGE_HANDLE');
    end
  end

  reload_image_modetype(handles);
  
return;

% --------------------------------------------------------------------
function varargout = ppmImgmode_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Change Enable / Disable by Image Mode
% ---------------------------------------
% Image Mode Change
  interped_h = [handles.txtppmInterpMethod, ...
		handles.edtInterpMatrix, ...
		handles.txtInterpMatrix, ...
		handles.ppmInterpMethod];

  if get(h, 'Value')==2,
    set(interped_h,'Enable','on');
  else,
    set(interped_h,'Enable','off');
  end

return;

function reload_image_modetype(handles),
% Image Mode change
% @since 1.25

  vl=get(handles.ppmImgmode,'Value');
  if (vl > 3) vl=3; end;

  image_mode_str = {'POINTS', 'INTERPED', 'smooth POINTS'};
  if get(handles.smple_3d_tgl,'Value')==1, 
      [d,h]=make_ucdata(getSignalViewOption(handles),handles);
      if h.measuremode==-1,
          image_mode_str{end+1} = '3D cubic';
      end
  end

  set(handles.ppmImgmode,...
      'Value', vl, ...
      'String', image_mode_str);
return;


% --------------------------------------------------------------------
function varargout = cbxAxisAuto_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Change Enable / Disable by for Auto-Axis(color)
% ---------------------------------------
% Axis Setting
  axisset_h = [handles.edtAxisMax, ...
	       handles.edtAxisMin, ...
	       handles.text49, ...
	       handles.text50];
  
  % Axis Auto Checkbox
  if get(h,'Value')
    set(axisset_h,'Enable','off');	
  else
    set(axisset_h,'Enable','on');	
  end
return;

function varargout = ppmSldSpeed_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Set Slidbar Step correspond to the Data
% ---------------------------------------

  plttype_value = getappdata(handles.figure1, 'ImagePlotType');
  xdata         = getappdata(handles.figure1, 'xdata');
  if isempty(plttype_value) || isempty(xdata)
    warndlg('Image Data have been made yet');
    return;
  end
  
 sld_v = get( handles.sldPos, 'Value');
 if sld_v<=0, sld_v=1; end
 
 switch plttype_value % Plot type
  case 3 % Plot type = t-test
   if sld_v>7, sld_v=7; end
   set( handles.sldPos, ...
	'Value',sld_v,  ...
	'Min', 1,       ...
	'Max', 7,       ...
	'SliderStep', [ 1/6 1/6 ]);
  otherwise	
   sldsp=2^(get( handles.ppmSldSpeed,'Value')-1);%Slide Speed
   stepOfButton = sldsp/size(xdata,2);
   if stepOfButton>1, stepOfButton = 1; end % This is rate, so 0 to 1
   if sld_v>size(xdata,2), sld_v=size(xdata,2); end
   set(handles.sldPos, ...
       'Value',sld_v,  ...
       'Min', 1,       ...
       'Max', size(xdata,2), ...
       'SliderStep', [ stepOfButton 0.05]);
 end
  
 set( handles.edtPos, 'String','1');
return;


%----------------------
% Image Ploting
%----------------------
function varargout = image_psb_Callback(h, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------
%  Plot Image and set Application Data for Image
%  And Default Plot.
% 
%  Setting Appricasion Data is following
%    ImagePlotKind  : Plot-Kind
%    ImagePlotType  : Plot-Type
%    measuremode    : Mesuremode -> channel position 
%    xdata          : xdata is time span
%    ydata          : ydata is Image Data
% ---------------------------------------
  tt_help_h = getappdata(handles.figure1, 'TtestHelpH');
  if ~isempty(tt_help_h) && ishandle(tt_help_h),
    try, delete(tt_help_h); end
  end

  % -- Special Check : Plot Kind is one --
  key = getSignalViewOption(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  plot_kind = key.plot_kind;
  kind_num = length(plot_kind);
  if get(handles.smple_3d_tgl,'Value')==0
    if kind_num<1,
      errordlg('Please select one or more signal.');return;
    end
  else
    if length(kind_num) ~= 1
      errordlg('Please select one signal.'); return;
    end
  end
  clear kind_num;

  % --- Load Plot Data ---
  % tmp_dco = get(handles.pop_datachaneg,'Value');
  % Comment Out : Image can be use:  Change by shoji at 30-May-2005.
  % set(handles.pop_datachaneg,'Value',1);   % HB Data only
  try,
    [data, header] = make_ucdata(key,handles);
    % Block Data ?
    if ndims(data)==4,
      data = uc_blockmean(data,header);
    end
  catch,
    OSP_LOG('note',' Can not make data to image', lasterr);
    % set(handles.pop_datachaneg,'Value',tmp_dco); clear tmp_dco;
    return;
  end
  % set(handles.pop_datachaneg,'Value',tmp_dco); clear tmp_dco;

  if isfield(header,'samplingperiod'),
    unit=1000/header.samplingperiod;
  else,
    unit = 1;
    warning('no samplingperiod');
  end

  % data chage option
  axis_label.x ='time [sec]';
  axis_label.y ='HB data';
  dc_option = get(handles.pop_datachaneg,'String');
  dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
  [data,axis_label, unit] = ...
      pop_data_change_v1(dc_option,data, axis_label, unit);
  
  % --- Make Plot Data ---
  xdata = 0:1/unit:((size(data, 1)-1)/unit);
  ydata = data;

  plot_func = func2str(key.actdata.fcn);
  if strcmpi(plot_func,'DataDef_TTest'),
    set( handles.ppmSldSpeed, ...
	 'Value',1, ...
	 'Enable', 'inactive');
    set( handles.edtMeanPeriod, ...
	 'String', '1', ...
	 'Enable', 'inactive');
    % T-Test Setting
    set( handles.edtAxisMax, 'String', '1');
    set( handles.edtAxisMin, 'String', '0');
    set( handles.cbxAxisAuto, 'Value', 1);
    header.TAGs.DataTag = {'Oxy', 'Deoxy', 'Total'};
    plttype_value = 3;
    tt_help_h = osp_imageview_ttest_help;
    setappdata(handles.figure1, 'TtestHelpH',tt_help_h);
  else
    set( handles.ppmSldSpeed,   'Enable', 'on');
    set( handles.edtMeanPeriod, 'Enable', 'on');
    plttype_value = 1;
  end
  
  % Update Image Data
  setappdata(handles.figure1, 'ImagePlotKind', plot_kind);
  setappdata(handles.figure1, 'ImagePlotKindTag',header.TAGs.DataTag(plot_kind));
  setappdata(handles.figure1, 'ImagePlotType', plttype_value);
  % setappdata(handles.figure1, 'measuremode', header.measuremode);
  setappdata(handles.figure1, 'HEADER', header);
  setappdata(handles.figure1, 'xdata',xdata);
  setappdata(handles.figure1, 'ydata',ydata);
  clear strPlotData;  
  
  % Slider Setting 
  ppmSldSpeed_Callback(handles.ppmSldSpeed, [],handles);

  % Image Plot 
  sldPos_Callback(h, eventdata, handles);
  
  set( handles.sldPos, 'enable', 'on');

% --------------------------------------------------------------------
function varargout = sldPos_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
%  Plot Image to the figure IMAGE_HANDLE
%  Slider Value is correspond to  the Time
% 
% Load IMAGE Option and Reflect IMAGE_HANDLE & Plot
% ---------------------------------------

  % Display Corresponding Time : EdtPos
  timepos=round(get(handles.sldPos,'Value'));
  set( handles.edtPos, 'String', num2str(timepos));

  % pop_plotmode = getappdata(handles.figure1, 'ImagePlotType');

  % Load Image Data
  plot_kind     = getappdata(handles.figure1, 'ImagePlotKind');
  plot_kind_tag = getappdata(handles.figure1, 'ImagePlotKindTag');
  xdata         = getappdata(handles.figure1, 'xdata');
  ydata         = getappdata(handles.figure1, 'ydata');
  % measuremode   = getappdata(handles.figure1, 'measuremode');
  header        = getappdata(handles.figure1, 'HEADER');

  if isempty(plot_kind) || isempty(xdata) || ...
	isempty(ydata) || isempty(header)
    errordlg('Make Image at First!'),return;
  end


  % Mask ch data
  mask_channel = str2num(get(handles.edtMaskCh, 'String'));
  if ~isempty(mask_channel)
    % ydata(:, mask_channel, :)=NaN;
    ydata(:, mask_channel, :)=0;
  end

  % get single time point data
  v_MP     = str2num( get(handles.edtMeanPeriod, 'String') );
  v_tstart = timepos-fix(v_MP/2);
  v_tend   = timepos+fix(v_MP/2);
  if (v_tstart<1 ), v_tstart=1;, end
  if (v_tend>size(ydata,1) ), v_tend=size(ydata,1); end

  ydata = nan_fcn('mean',ydata(v_tstart:v_tend, :, :), 1 );
  sz=size(ydata); sz(1)=[]; 
  if length(sz)==1, sz(2)=1; end
  ydata=reshape(ydata,sz); % Squeeze

  % setup Axis
  if get(handles.cbxAxisAuto, 'Value')
    v_axMax=max(ydata(:));
    v_axMin=min(ydata(:));
    set(handles.edtAxisMax, 'String', num2str(v_axMax));
    set(handles.edtAxisMin, 'String', num2str(v_axMin));
  else
    v_axMax=str2num(get(handles.edtAxisMax, 'String'));
    v_axMin=str2num(get(handles.edtAxisMin, 'String'));
  end
  if (v_axMax==v_axMin), v_axMax=v_axMax+1;end


  % convert channel to image
  image_mode     = get(handles.ppmImgmode', 'Value');
  v_interpstep   = str2num( get(handles.edtInterpMatrix, 'String' ) );
  v_interpmethod = get(handles.ppmInterpMethod, 'String');
  v_interpmethod = char(v_interpmethod(get(handles.ppmInterpMethod, 'Value')));

  % Set Pseude Colro-Axis Ccaling
  if get(handles.cbxZerofix,'Value')
    cmin = -max([abs(v_axMin), abs(v_axMax)]);
    cmax = max([abs(v_axMin),  abs(v_axMax)]);
  else
    cmax=v_axMax;
    cmin=v_axMin;
  end
  if isnan(cmax)
    v_axMax=0.01; v_axMin=0;
    cmax = 0; cmin = 0;
  end


  if get(handles.smple_3d_tgl,'Value')==0
    % ===== 2D Image ====
    
    % Figure Setup
    image_h       = getappdata(handles.figure1, 'IMAGE_HANDLE');
    if isempty(image_h) || ~ishandle(image_h) || ~strcmp('OSP_IMAGE_FIG',get(image_h,'Tag')),
      image_h=figure;
	  set(image_h,'Tag', 'OSP_IMAGE_FIG');
      setappdata(handles.figure1, 'IMAGE_HANDLE', image_h);
      uimenu_Osp_Graph_Option(image_h); % Add : uimenu
    else
      figure(image_h);
    end

    % -- Normal Image --
    % figure setup, I want to Menubar
    % set(image_h,'DoubleBuffer','on','Menubar','none')
    osp_set_colormap(get(handles.ppmColormap,'Value'));
	
    sz=length(plot_kind);
    % color bar setting
    colorbar_char = getColorbarFcn;
	
    for i=1:sz
      [c0, x0, y0]=osp_chnl2imageM(ydata(:,plot_kind(i))',...
				   header, image_mode, ...
				   v_interpstep, v_interpmethod);
               
      % Plot Multi-plane
      ax_h=subplot(sz,1,i);
      % set(ax_h,'YDir','reverse');
      hold on;
      for plid = 1: length(c0),
          ih=imagesc(x0{plid}, y0{plid}, ...
              c0{plid}',[v_axMin, v_axMax]);
          set(ih,'Tag',sprintf('Image%d',plid));
      end
      caxis([cmin,cmax]); eval(colorbar_char);
      title(plot_kind_tag{i});
      axis auto;
      axis image;
      axis off;
    end
  elseif image_mode==4,
    % ===== 3D Image ====
    % Image Mode ==4 : 

    % Current-Figure Setup
    image_h       = getappdata(handles.figure1, 'IMAGE_HANDLE');
    if isempty(image_h) || ~ishandle(image_h) || ...
	  ~strcmp('OSP_3CUBE_IMAGE_FIG',get(image_h,'Tag')) || ...
	  isempty(getappdata(image_h,'HANDLES_IMG')),
      image_h=figure;
      set(image_h,'Tag', 'OSP_3CUBE_IMAGE_FIG');
      setappdata(handles.figure1, 'IMAGE_HANDLE', image_h);
    else
      % set image_h to Current-Figure
      figure(image_h);
    end
    img_handle=getappdata(image_h,'HANDLES_IMG');
    img_handle.figure1 = image_h; % Not to become empty.

    % -- Normal Image --
    % figure setup, I want to Menubar
    % set(image_h,'DoubleBuffer','on','Menubar','none')
    osp_set_colormap(get(handles.ppmColormap,'Value'));

    try,
      img_handle=Cube_Plot(img_handle,ydata, header, ...
			   'ColorAXIS', [cmin,cmax], ...
			   'ColorMapID', ...
			   get(handles.ppmColormap,'Value')); 

    catch,
      close(image_h);
      msg = sprintf(['OSP Error!!!\n' ...
		     ' << Plot Error      >>\n' ...
		     ' << %s >>\n'], ...
		    lasterr);
      errordlg(msg);
      return;
    end
    setappdata(image_h,'HANDLES_IMG',img_handle);
  else
    % ===== 3D Image ====

    % Figure Setup
    image_h       = getappdata(handles.figure1, 'IMAGE_HANDLE');
    if isempty(image_h) || ...
	  ~ishandle(image_h) || ...
	  strcmp('OSP_3CUBE_IMAGE_FIG',get(image_h,'Tag')),
      initflg=1;
      try
	image_h=hbimage3d;
	setappdata(handles.figure1,'IMAGE_HANDLE',image_h);
      end
    else
      initflg=0;
    end
    if isempty(image_h) || ~ishandle(image_h)
      msg = sprintf(['OSP Error!!\n', ...
		     '<< Cannot open 3D-Image >>\n', ...
		     '   %s'], lasterr);
      error(msg);
      return;
    end

    [c0, x0, y0] =osp_chnl2imageM(ydata(:,1)',...
				  header, image_mode, ...
				  v_interpstep, v_interpmethod);
    % Plot Multi-plane
    for plid = 1: length(c0),
      Tag = ['Plane_' num2str(plid)];
      hbimage3d('set_HB_Data',image_h, eventdata, guihandles(image_h),...
		c0{plid}',...                       % HB-Color
		plid,Tag,...                     % Plot ID & Tag
		[v_axMin, v_axMax],...              % Clim
		[cmin,cmax],...                     % for caxis
		get(handles.ppmColormap,'Value'));  % ColorMap
    end

  end
return;

% ---- Save ----
function varargout = save_jpg_psb_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
% Save Image as jpg / bmp / tif
%  if you want to save other type, 
%   use File & export
% ---------------------------------------

  
  % Image Handle
  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');
  if isempty(image_h) || ~ishandle(image_h)
    errordlg('No Image to save');return;
  end

  % PUT FILENAME
  wd = OSP_DATA('GET','WORK_DIRECTORY');
  if isempty(wd), wd=pwd; end
  tmpdir = pwd;
  cd(wd);
  [f p] = uiputfile({'*.jpg'; '*.bmp'; '*.tif'}, 'Save Plot File', ...
		    'signal_view_result.mat');
  if isequal(f,0) || isequal(p,0)
	cd(tmpdir);
    return; % cancel
  end
  cd(p); wd = pwd; % Not to save relative path
  OSP_DATA('SET','WORK_DIRECTORY',wd);
  cd(tmpdir);

  % save
  saveas(image_h, [wd filesep f]);
return;


% --------------------------------------------------------------------
function varargout = save_avi_psb_Callback(h, eventdata, handles, varargin)
% ---------------------------------------
% Save Image as AVI
%  This is make Movie, in the process
%   view Moview.
% ---------------------------------------

  % Image Handle
  image_h = getappdata(handles.figure1, 'IMAGE_HANDLE');
  if isempty(image_h) || ~ishandle(image_h)
    errordlg('No Image to save');return;
  end
  
  if get(handles.smple_3d_tgl,'Value')==1

    % Chage image_h Here!
    hb3 = getappdata(image_h, 'hb3fig');
    image_h = hb3.fig; clear hb3;
    % check
    if isempty(image_h) || ~ishandle(image_h)
      errordlg('No Image to save');return;
    end
  end

  % set(handles.sldPos, 'Value',1); % set start frame postition 
  v_speed=2^(get(handles.ppmSldSpeed,'Value')-1);         % get frame speed
  v_frameend=size(getappdata(handles.figure1,'xdata'), 2);% get frame end
    
  % === Temporary Data Save ===
  v_pushpos = get(handles.sldPos,'Value'); % tmporary
  unttmp = get(image_h,'Units');
  postmp = get(image_h,'Position');

  % Save 	
  wd = OSP_DATA('GET','WORK_DIRECTORY');
  if isempty(wd) || ~isdir(wd), wd=pwd; end
  tmpdir = pwd;
  cd(wd);
  % get save file name
  [f p]=uiputfile('*.avi', ...
		  'Save AVI-File', ...
		  'Untitled.avi');
  if isequal(f,0) || isequal(p,0)
    cd(tmpdir);
    return; % cancel
  end
  cd(p); wd = pwd; % Not to save relative path
  OSP_DATA('SET','WORK_DIRECTORY',wd);
  cd(tmpdir);

  % ========== Size Change ===============
  ajust_moviesize(image_h);

  % Open Movie
  movF=avifile([wd filesep f]);     % prepare for AVI file
	
  try
    % Waitbar Setting
    timeidx0 = 1:v_speed:v_frameend;
    now_time=0; add_time = 1/length(timeidx0); 
    w_h=waitbar(0,sprintf('Time : %10d',0),...
		'Name','Making Movie',...
		'Color',[.8 1 .8]);

    im_pos = get(image_h,'Position');
   set(w_h,'Units', get(image_h,'Units'));
    wb_pos = get(w_h,'Position');
    wb_pos(1) = im_pos(1);
    wb_pos(2) = im_pos(2)-wb_pos(4);
    wb_pos(3) = wb_pos(3)*1.3;
    set(w_h,'Position',wb_pos);
	% in MATLAB version 7.0.0.19920 (R14)
	% Above command not run, but run in debugger
	% Pause time may depend on PC.
	pause(0.5);
	
    uh=uicontrol(w_h, ...
		 'units','normalized','position',[10.5/13 0.1 2/13 0.5], ...
		 'Style', 'pushbutton', 'String', 'Stop', ...
		 'Callback','delete(gcbo);', ...
		 'BackgroundColor',[.3 .7 .7]);

    for timeidx=timeidx0;
      % figure(handles.figure1);
      if ~ishandle(uh), break; end
      now_time=now_time+add_time;
      waitbar(now_time,w_h, ...
	      sprintf('Time : %10d',timeidx));
      set(handles.sldPos,'Value',timeidx); % set frame postition     
      sldPos_Callback(handles.sldPos,[], handles);
      mov1=getframe(image_h);
      drawnow;
	  % mov1=im2frame(image_h);
      movF=addframe(movF,mov1);
    end
  catch
    % close(w_h); movF=close(movF);
	errordlg({lasterr, ...
			' Frame Size may be so large.', ...
			' Resize Figure and try again'});
    % rethrow(lasterror);
  end

  % close
  close(w_h);
  % Print Information ? no ;
  movF=close(movF);   % close AVI file
  disp(movF);

  % === Temporary Data Save ===
  set(image_h,'Position',postmp);
  set(image_h,'Units',unttmp);

  % figure(handles.figure1);
  set(handles.sldPos,'Value',v_pushpos); % pop start frame postition 
  sldPos_Callback(handles.sldPos,[], handles);
  
return;


function ajust_moviesize(image_h,varargin)
%=================================================
% Ajust Image (image_h) Size for Movie
%   image_h is Figure-Handle of Ajust Image 
%   varargin is dummy, not in use
%=================================================
 im_pos = get(image_h,'Position');
 imup=0;
 if im_pos(3) > 640, im_pos(3)=640; end
 if im_pos(4) > 480, imup=im_pos(4)-480;im_pos(4)=480; end
 im_pos(2) = im_pos(2)+imup;
 set(image_h,'Position',im_pos);
return;

function colorbar_fcn = getColorbarFcn()
% matlab ver7.0.0 colorbar axes size
  try
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      colorbar_fcn = 'colorbar2(''EastOutside'');';
    else
      colorbar_fcn = 'colorbar';  
    end
  catch
    warning(lasterr);
    colorbar_fcn = 'colorbar';
  end
return;



function psb_mfile_image_Callback(hObject, eventdata, handles)
% -- Special Check : Plot Kind is one --
  key = getSignalViewOption(handles);
  if ~isfield(key,'actdata') || isempty(key.actdata)
    errordlg(' No Dtata to Plot'); return;
  end
  plot_kind = key.plot_kind;
  kind_num = length(plot_kind);
  if get(handles.smple_3d_tgl,'Value')==0
    if kind_num<1,
      errordlg('Please select one or more signal.');return;
    end
  else
    if length(kind_num) ~= 1
      errordlg('Please select one signal.'); return;
    end
  end
  clear kind_num;
  
  % -- File name Get --
  [f p] = osp_uiputfile('*.m', ...
			'Output M-File Name', ...
			['osp_Viewer_rv19_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel

  % == Open M-File ==
  fname = [p filesep f];  key.fname=fname;
  mfile_tmp = make_pre_mfile(key,handles);

   % Add Plot .. 
  [fid, fname1] = make_mfile('fopen',fname,'a');
  try,
    make_mfile('code_separator', 1);
    make_mfile('as_comment', 'Viewer : Image Plot');
    make_mfile('code_separator', 1);
    
    dc_option = get(handles.pop_datachaneg,'String');
    dc_option = dc_option{get(handles.pop_datachaneg,'Value')};
	  
    if get(handles.mrk_chb, 'Value')==1,  stimplot = 'area';
    else, stimplot = 'off'; end
    
    if get(handles.smple_3d_tgl,'Value')==0,
      make_mfile('with_indent', ...
		 'h=uc_image_plot(hdata, data, 2, ...');
    else,
      make_mfile('with_indent', ...
		 'h=uc_image_plot(hdata, data, 3, ...');
    end
    make_mfile('indent_fcn','down');
    make_mfile('with_indent', '''FigBGcolor'',  [1 1 1], ...');
    make_mfile('with_indent',...
	       ['''DC_OPTION'',''' ...
		dc_option ...
		''', ...']);
    make_mfile('with_indent',...
	       ['''PlotKind'', [' ...
		num2str(plot_kind) ...
		'], ...']);
    
    % time
    timepos=round(get(handles.sldPos,'Value'));
    make_mfile('with_indent',...
	       ['''PlotTime'', ' ...
		num2str(timepos) ...
		', ...']);
    make_mfile('with_indent',...
	       ['''MEAN_PERIOD'', ' ...
		get(handles.edtMeanPeriod, 'String') ...
		', ...']);

    % Interp --,
    image_mode     = get(handles.ppmImgmode', 'String');
    image_mode     = image_mode{get(handles.ppmImgmode, 'Value')};
    make_mfile('with_indent',['''MODE'', ''' image_mode ''' , ...']);
    if strcmpi(image_mode,'interped'),
      v_interpmethod = get(handles.ppmInterpMethod, 'String');
      v_interpmethod = char(v_interpmethod(get(handles.ppmInterpMethod, 'Value')));
      make_mfile('with_indent', ...
		 ['''INTERP_METHOD'', ''' ...
		  v_interpmethod ...
		  ''', ...']);
      make_mfile('with_indent',...
		 ['''INTERP_STEP'', '...
		  get(handles.edtInterpMatrix,'String') ...
		  ', ...']);
    end
	  
    % Color's
    make_mfile('with_indent',...
	       ['''ColorMap0'', ' ...
		num2str(get(handles.ppmColormap,'Value')) ...
		', ...']);
    make_mfile('with_indent',...
	       ['''CAXIS_ZERO'', ' ...
		num2str(get(handles.cbxZerofix,'Value')) ...
		', ...']);
    if ~get(handles.cbxAxisAuto, 'Value'),
      make_mfile('with_indent', ...
		 ['''CMAX_AXIS'', ' ...
		  get(handles.edtAxisMax, 'String') ...
		  ', ...']);
      make_mfile('with_indent',...
		 ['''CMIN_AXIS'', ' ...
		  get(handles.edtAxisMin, 'String') ...
		  ', ...']);
    end
    
    % Data Mask
    make_mfile('with_indent',...
	       ['''MASK_CH'', [' ...
		get(handles.edtMaskCh, 'String')...
		'], ...']);
    % Other Option 
    make_mfile('with_indent','''AXES_TITLE'', ''off'');');
	make_mfile('indent_fcn','up');

    % Figure Controller Add
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
    % edit(fname);
    rethrow(lasterror);
  end
  make_mfile('fclose');
  % edit(fname);
  
return;

% Since : 1.34
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
  % Reload LayoutData
  actdata.data = DataDef_GroupData('load', actdata.data);


  if ~isempty(actdata.data.data)
      actdata.data.data(end).filterdata=fmd;
      
      actdata.data = DataDef_GroupData('save_ow',actdata.data);
      dt(tg)=actdata;
      set(handles.lsb_datalist, 'UserData',dt);
  end

  setappdata(handles.figure1,'SAVE_GROUP',false);

  % ---> Comment out <--- 5-Nov-2005
  % main_h = OSP;  % error for currentdirectory is ...
  main_h = OSP_DATA('GET','MAIN_CONTROLLER');
  main_h = main_h.hObject;

  
  vh=getappdata(main_h,'Viewer2');
  if ~isempty(vh) && ishandle(vh),delete(vh); end

  ah=getappdata(main_h,'ActiveModule');
  if isempty(ah) || ~isstruct(ah), return; end
  ah=ah.gui;
  if ~isempty(ah) && ishandle(ah) && ...
		  strcmp('Block Filter',get(ah,'Name'))
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

