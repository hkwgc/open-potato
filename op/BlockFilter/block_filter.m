function varargout = block_filter(varargin)
% BLOCK_FILTER is GUI to set OSP-Data to filtering Information
%
% BLOCK_FILTER Application M-file for block_filter.fig
%    FIG = BLOCK_FILTER launch block_filter GUI.
%    BLOCK_FILTER('callback_name', ...) invoke the named callback.
%
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 13-May-2006 15:16:27

% 
% == History ==
%  -> Import block_controller 
% $Id: block_filter.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.23 :
%      Blush up
%      Change : Thinking way of Stimulation-Data-Structure
%
% Reversion 1.31:
%       Bug fix :
%         in Viewer connection,
%         I made some bugs, and fixed now.
%
% Revision 1.38 :
%       Change-Stimulation Data -- Version.
%       1.50 to 2.00
%       We will apply 2.50 soon.



% (.. Default : Old GUIDE ..)
if nargin == 0  % LAUNCH GUI
  fig = openfig(mfilename,'reuse');
  % set(fig,'Color',[1 .9 .9]);
	
  % Generate a structure of handles to pass to callbacks, and store it. 
  handles = guihandles(fig);
  guidata(fig, handles);
  
  if nargout > 0
    varargout{1} = fig;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  =============== Opening Function  ==============  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %  Load Osp Active Data
  %
  %----------------------------
  % Create : 27-Jan-2005 
  % author : Masanori Shoji
  %----------------------------
  
  % === Load Check ===
  try
    mc = OSP_DATA('GET','MAIN_CONTROLLER');
    if isempty(mc)
      error('OSP Main Controller  : Not opened');
    end
    af = OSP_DATA('GET','ACTIVE_FLAG');
    if bitget(af,3)==0
      error(' MAIN Controller is not Locked');
    end
    OSP_DATA('SET','OSP_LocalData',[]);
  catch
    msg = {' == OSP Main Controller ==', ...
	   '  Open from OSP Main Controller  ', ...
	   ' ', ...
	   ['  ' lasterr]};
    errordlg(msg,'Block Filter Opening Function');
    OSP_LOG('err',msg);
    delete(fig)
    return;
  end
  OSP_LOG('msg',' ');
  OSP_LOG('msg',' Launch Block-Filter : ');
  OSP_LOG('msg','   $Id: block_filter.m 180 2011-05-19 09:34:28Z Katura $');
  
  ad = OSP_DATA('GET','ACTIVEDATA');
  fcnname = func2str(ad.fcn);
  switch fcnname
   case 'DataDef_SignalPreprocessor'
    OSP_LOG('msg',...
	    ['  Data : Signal-Data : ' ad.data.filename]);
    setLocalActiveData(fig);
   case 'DataDef_GroupData'
    enable_data('off',handles);
    OSP_LOG('msg',...
	    ['  Data : Group-Data : ' ad.data.Tag]);
    setLocalActiveDataGroup(fig);
   otherwise
    OSP_LOG('perr',[' Undefined Active Data type : ' fcnname]);
    delete(fig);
  end
  
  set(fig,'Render','zbuffer');
  
  % Get The File
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist) || id==0, return; end

  % -- Close Viewer --
  % Launch Viewer
  mc = OSP_DATA('GET','MAIN_CONTROLLER');
  flag=false;
  sv_handle = getappdata(mc.hObject,'Viewer');
  if ~isempty(sv_handle) && ishandle(sv_handle),
    flag=true;
    delete(sv_handle);
  end
  sv_handle = getappdata(mc.hObject,'Viewer2');
  if ~isempty(sv_handle) && ishandle(sv_handle),
    flag=true;
    delete(sv_handle);
  end
  sv_handle = getappdata(mc.hObject,'Viewer3');
  if ~isempty(sv_handle) && ishandle(sv_handle),
    flag=true;
    delete(sv_handle);
  end
  if flag,
    OSP('reloadView',mc.hObject,mc.eventdata,mc.handles,'rmViewer');
  end
elseif ischar(varargin{1})
  % INVOKE NAMED SUB-FUNCTION OR CALLBACK
  OSP_LOG('dbg',['Load : ' varargin{1}]);
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switch-yard
    else
      feval(varargin{:}); % FEVAL switch-yard
    end
  catch
    disp(lasterr);
    disp(varargin{1});
    if length(varargin)~=4,
      disp(varargin{end});
    end
    OSP_LOG('perr', lasterr, varargin{1});
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Create Function           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Background of Graph 
function axes_graphBack_CreateFcn(hObject, eventdata, handles)
  axes(hObject);
  set(hObject, 'Color','none');
  h=fill([0 1 1 0 0],[0 0 1 1 0],[.7 .8 .9]);
  set(h,'EdgeColor',[0.8 0.8 0.8]);
  axis([0 1 0 1]);axis off;
  h=text(0.01,1,'Graph',...
	 'BackgroundColor',[.7 .8 .9]);
return;

% Background of Edit-of Group
%  --> in Version 6.0 we cannot overlap  
function axes5_CreateFcn(hObject, eventdata, handles)
  axes(hObject);
  set(hObject, 'Color','none');
  h=fill([0 1 1 0 0],[0 0 1 1 0],[1 1 .9]);
  set(h,'EdgeColor',[0.7 0.7 0.7]);
  axis([0 1 0 1]);axis off;
  h=text(0.1,1,'Edit : Element of Group',...
	 'BackgroundColor',[1 1 .9]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = psb_file_select_Callback(h, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%
% Select file
%%%%%%%%%%%%%%%
  
  ini_actdata = OSP_DATA('GET','ACTIVEDATA'); % swapping.
  
  % -- Lock --
  set(handles.figure1,'Visible','off');

  % === File Select  ===
  try
    fs_h = uiFileSelect('DataDif',{'SignalPreprocessor'});
    waitfor(fs_h);
  catch
    set(handles.figure1,'Visible','on');
    rethrow(lasterror);
  end

  % -- Unlock --
  set(handles.figure1,'Visible','on');

  % Cancel Check
  actdata = OSP_DATA('GET','ACTIVEDATA'); 
  if isempty(actdata), 
    OSP_DATA('SET','ACTIVEDATA',ini_actdata); 
    return;
  end

  % Apply Active Data
  setLocalActiveData(handles.figure1);
return;

function setLocalActiveData(fig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Active Data to Block Filter GUI
%
% fig : Figure Handles of BlockFilter
%
% Create Date : 27-Jan-2005
% author      : M. Shoji
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
  handles = guihandles(fig);
  actdata = OSP_DATA('GET','ACTIVEDATA');

  % ======== Check Active Data ===========
  if isempty(actdata)
    msg = {' == No Active Data ==', ...
	   '   Program Error : No Active Data Exist.' ...
	   '     please try again from OSP'};
    errordlg(msg,'Block Filter Opening Function');
    OSP_LOG('perr',msg);
    delete(fig);
    return;
  end

  % ======== Reload ===========
  %  -- Reload Name --
  try
    idnt = feval(actdata.fcn,'getIdentifierKey');
    idnt = getfield(actdata.data,idnt);
    if iscell(idnt), idnt=idnt{1}; end
    set(handles.txt_Filename,'String',idnt);
  catch
    OSP_LOG('err',['Name Set Error : ' lasterr]);
    set(handles.txt_Filename,'String','LoadError');
  end

  enable_data('on', handles);

  % Reload Information 
  % ---> remove this area 
  %      same data in OSP MAIN
  try
    % Load Active Data
    [header,data]=DataDef_SignalPreprocessor('load',actdata);  % Load File
    ch = size(data,2);
    % 04-Jun2005, Add more Application data for always using data
    setappdata(fig, 'SamplingPeriod',header.samplingperiod);
    setappdata(fig, 'DATA_SIZE', size(data));
    clear header data;

    % Make String 
    str={};
    for tg=1:ch
      str{end+1}=num2str(tg);
    end

    % Make Value
    chini = get(handles.pop_channel,'Value');
    if chini > ch,  chini=ch;  end

    set(handles.pop_channel,...
	'Value',chini,...
	'String',str);
    clear str chini ch;
  end

  %  -- Reload Stimulation Marks --
  try
    axes(handles.axes1); cla;
    plot_HB(handles);
    axis tight; ax = axis; 
    axh = ax(4) - ax(3); sz = axh *0.2;
    ax(4)=ax(4)+sz; ax(3)=ax(3)-sz;
    axis(ax);
  end
  try
    reset_psb_Callback(handles.reset_psb, [], handles);
  end

  % ========== if There is no Stimulation Data =======

  % =========== Data Reset ============
  % Motion Check Data Reset
  setappdata(handles.figure1,'MotionBlockMark',[]);
  set(handles.psb_plotchnum,'Visible','off');
  
return;

function enable_data(mode, handles, handle2)
  handle = ...
      [   handles.invert_psb, ...
          handles.reset_psb, ...
          handles.psb_plotchnum, ...
          handles.psb_SelectBlock, ...
          handles.motion_chk, ...
          handles.pop_channel];

  if exist('handle2','var')
    handle = handle2;
  end
  set(handle, 'Enable',mode);
return;

function figure1_CloseRequestFcn(hObject, eventdata, handles)
  delete(hObject);
return;

function figure1_DeleteFcn(hObject, eventdata, handles)
  try
	  % Save Group Data
	  file_save_psb_Callback(handles.file_save_psb, [], handles);
  end
  try
	  osp_ComDeleteFcn;
  end
return;

%| ABOUT CALLBACKS:
%| GUIDE automatically appends sub-function prototypes to this file, and 
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
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Removed Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_capture_psb_Callback(h, e,hs)
disp(h);disp(e);disp(hs);
error('This Function was removed');
function motion_chk_Callback(h, e,hs)
disp(h);disp(e);disp(hs);
error('This Function was removed : Filter Function.');
function sd_3sigma_Callback(h, e,hs)
disp(h);disp(e);disp(hs);
error('This Function was removed : Filter Function');


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Marker Search Callback
% --------------------------------------------------------------------
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Stimulation Markers Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% since Reversion : 1.23.
%  Block-Filter's Internal Data of Stimulation
%
% Application Data of Stimulation.
%  * 'OriginalStimulation'
%     Original Stimulation Data
%      2-D matrix, [stim_number, 2], 
%                    1st column : StimKind
%                    2nd column : Stim-timing
%
%  * 'DiffStimulation'
%     Difference from OriginalStimulation
%      2-D matrix, [stim_number, 1], 
%                    1st column : Difference from Original one
%
%  * 'FlagStimulation'
%     Flag of Stimulation
%      2-D matrix, [stim_number, ch_numebr], 
%                    if value is 0, use the block.
%                    if value is 1, never use the block.


% --------------------------------------------------------------------
function varargout = reset_psb_Callback(h, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Default Stimulation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Reset Function : Make Stimulation Data From ETG Data :
%%   -> is as same as ppmMode : ( needless pushbutton )
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata),
    error(' No Effective Data exist.');
  end
  [header,data]=DataDef_SignalPreprocessor('load',actdata);  % Load File
  % Make Stimulation Time
  smpl_pld=header.samplingperiod;% sampling period [ms]
  st= str2num( get(handles.edt_prestim, 'String') )  * 1000/smpl_pld;
  ed= str2num( get(handles.edt_poststim, 'String') )    * 1000/smpl_pld;
  % rx= str2num( get(handles.rlx_edt, 'String') )           * 1000/smpl_pld;

  stimTC = header.stimTC(:);
  ostim = find(stimTC>0);
  ostim = ostim(:);

  % Original Stimulation Data
  ostim = [stimTC(ostim), ostim];
  setappdata(handles.figure1,'OriginalStimulation', ostim);

  % Difference between dstim
  dstim = zeros(size(ostim,1),1);
  setappdata(handles.figure1,'DiffStimulation', dstim);

  % Flag of Stimulation
  sflag  = false([size(ostim,1),size(data,2)]);
  setappdata(handles.figure1,'FlagStimulation', sflag);

  % Make Strings of Marker-Listbox
  new_listbox_marker(handles);

  % Plot Marker
  plot_Mark(handles);
return;

%  -- Call back ---
function ppmMode_Callback(h, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change mode .. renew
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dstim = getappdata(handles.figure1,'DiffStimulation');
  if isempty(dstim),
    reset_psb_Callback(handles.figure1, [] , handles);
  else,
    % Make Strings of Marker-Listbox
    new_listbox_marker(handles);
    % Plot Marker
    plot_Mark(handles);
  end
return;

function new_listbox_marker(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Renew Marker Label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Data :
%   [index1, start_time1, end_time1; 
%    index2, start_time2, end_time2; ...]
%  where index 1, or 2 is stimulation number

  % ===== Get Stimulation Data ====
  ostim = getappdata(handles.figure1,'OriginalStimulation');
  dstim = getappdata(handles.figure1,'DiffStimulation');
  sflag = getappdata(handles.figure1,'FlagStimulation');

  [stim_kind, stim_out, flag, idx] = ...
      patch_stim(ostim, get(handles.ppmMode,'Value'), ...
		 sflag, dstim);

  vl=get(handles.lbx_Marker, 'Value');
  vl(find(vl>size(idx,1)))=[];
  if isempty(vl), vl=size(idx,1); end

  set(handles.lbx_Marker, ...
      'Value', vl, ...
      'userdata', [idx, stim_out]);

  % ==== Make Strings ====
  str={};
  for id = 1:size(idx,1),
    str{id} = get_lbxMarkerString(handles,id);
  end

  if isempty(str),
    str = 'No Stimulation Exist';
  end
  set(handles.lbx_Marker, 'String',str);

  % update Relax Max
  changeRelaxMax(handles);
return;

function str = get_lbxMarkerString(handles,id),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List Box String maker
%  stimData : Stimulation Data
%  idx      : target Stimulation Data
%  line_no  : Sirial Number of Stimulation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % --------------
  %  Get Now Data 
  % --------------
  ud    = get(handles.lbx_Marker, 'UserData');
  ostim = getappdata(handles.figure1,'OriginalStimulation');
  sflag = getappdata(handles.figure1,'FlagStimulation');
  unit  = 1000.0/getappdata(handles.figure1, 'SamplingPeriod');
  
  sflag = sflag(ud(id,1),:) | sflag(ud(id,2),:);
  if all(sflag),
    tmp = ' x ';
  elseif any(sflag),
    tmp = 'mix';
  else,
    tmp = ' o ';
  end

  switch get(handles.ppmMode,'Value'),
   case 1 
    % Event
    str = ...
	sprintf('%s[%03d]<%02d>: %8.1f', ...
		tmp,id , ostim(ud(id,1),1), ...
		ud(id,3) /unit);

   case 2
    % Block
    str = ...
	sprintf(['%s[%03d]<%02d>: %8.1f ' ...
		 'To %8.1f ( Diff : %8.1f )'], ...
		tmp, id, ostim(ud(id,1),1), ...
		ud(id,3)/unit, ud(id,4)/unit, (ud(id,4)-ud(id,3))/unit);
   otherwise,
    error('Stimulation Mode Error');
  end

return;

function marker_search_Callback(h, eventdata, handles, varargin)
  disp(' Removed Function');
  OSP_LOG('perr', 'Removed Function Called');
return;


% --------------------------------------------------------------------
function varargout = lbx_Marker_Callback(h, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List box --> Selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (get(handles.cbxChangeOnSelect, 'Value') )
    sub_invert(handles);
  end
  plot_Mark(handles);
  stim_edit_view(handles);
return;

function lbx_Marker_ButtonDownFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List box --> Selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  lbx_Marker_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function varargout = invert_psb_Callback(h, eventdata, handles, varargin)
%invert
  sub_invert(handles);
  plot_Mark(handles);
return;

% --------------------------------------------------------------------
function varargout = sub_invert(handles)
% Change Selected Channel Flags

  % Load Stimulation
  ud    = get(handles.lbx_Marker, 'UserData');
  tg    = get(handles.lbx_Marker, 'Value');
  st    = get(handles.lbx_Marker, 'String');
  sflag = getappdata(handles.figure1,'FlagStimulation');

  unit  = 1000.0/getappdata(handles.figure1, 'SamplingPeriod');

  for id=tg,
    sflag0 = sflag(ud(id,1),:) | sflag(ud(id,2),:);
    if all(sflag0),
      sflag(ud(id,1),:) = false(size(sflag(ud(id,1),:)));
    else,
      sflag(ud(id,1),:) = true(size(sflag(ud(id,1),:)));
      if ud(id,1) ~= ud(id,2),
	sflag(ud(id,2),:) = sflag(ud(id,1),:);
      end
    end
    if ud(id,1) ~= ud(id,2),
      sflag(ud(id,2),:) = sflag(ud(id,1),:);
    end
    setappdata(handles.figure1,'FlagStimulation',sflag);

    st{id} = get_lbxMarkerString(handles,id);
  end

  set(handles.lbx_Marker, 'String',st);

  % update Relax Max
  changeRelaxMax(handles);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulation timing change!
% since  : block_filter r1.23
% since  : OSP ver1.17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_stimPlus_Callback(hObject, eventdata, handles)
  n=edt_pm_unit_Callback(handles.edt_pm_unit, [], handles);
  stimChange(handles,+n);
return;
function psb_stimMinus_Callback(hObject, eventdata, handles)
  n=edt_pm_unit_Callback(handles.edt_pm_unit, [], handles);
  stimChange(handles,-n);
return;

function stimChange(handles,n),
% Change Selected Stimulation Block --> + n [point]

  % Load Stim Data;
  dstim = getappdata(handles.figure1,'DiffStimulation');

  tg = get(handles.lbx_Marker, 'Value');
  ud = get(handles.lbx_Marker, 'UserData');

  for id=tg
    dstim(ud(id,1)) = dstim(ud(id,1)) + n(1);
    if ud(id,1) ~= ud(id,2),
      dstim(ud(id,2)) = dstim(ud(id,2)) + n(1);
    end
  end
  setappdata(handles.figure1,'DiffStimulation',dstim);

  new_listbox_marker(handles);
  plot_Mark(handles);
  stim_edit_view(handles),
return;

function n=edt_pm_unit_Callback(hObject, eventdata, handles)
  try,
    n=str2double(get(hObject,'String'));
  catch,
    warndlg(['Stimulation Change rate : ' lasterr]);
    n=1;
  end
  stim_edit_view(handles);
return;	

function stim_edit_view(handles),
% Enable / Disable  push-button, '+'/'-'; 
  try,
    n=str2double(get(handles.edt_pm_unit,'String'));
  catch,
    n=1;
  end

  % Load Stim Data;
  ostim = getappdata(handles.figure1,'OriginalStimulation');
  dstim = getappdata(handles.figure1,'DiffStimulation');
  stim      = ostim(:,2) + dstim;
  stim_kind = ostim(:,1);
  clear ostim dstim;

  tg = get(handles.lbx_Marker, 'Value');
  ud = get(handles.lbx_Marker, 'UserData');
  tg = ud(tg,1:2); tg=tg(:)';
  clear ud;
  sz = getappdata(handles.figure1, 'DATA_SIZE');

  % Default
  set(handles.psb_stimPlus,'enable','on');
  set(handles.psb_stimMinus,'enable','on');

  for id0 = tg,
    if id0~=size(stim,1),
      % Get Upper Stimulation Time of
      upper = stim(id0+1);
    else,
      upper=sz(1); % Max of Time-Point
    end

    % p_time = cunow_time + n 
    p_time = stim(id0) + n;
    if p_time>= upper,
      set(handles.psb_stimPlus,'enable','off');
    end
    
    if id0~=1,
      lower=stim(id0-1);
    else,
      lower=0;
    end
    m_time = stim(id0) - n;
    if m_time <= lower,
      set(handles.psb_stimMinus,'enable','off');
    end
  end
  
return;

function varargout = psb_SelectBlock_Callback(h, eventdata, handles, varargin) 
% marker select mode

  % === Load Data ===
  sorgn = getappdata(handles.figure1, 'OriginalStimulation');
  sdiff = getappdata(handles.figure1, 'DiffStimulation');
  sflag = getappdata(handles.figure1, 'FlagStimulation');

  st = get(handles.lbx_Marker, 'String');
  idx= get(handles.lbx_Marker, 'UserData');
  
  % ********* Search Series *********
  if get(handles.ckb_SelectSerial,'Value')
    % === get Select Key ===
    selectkey = get(handles.edt_SelectSerial,'String');
    % Now : series number is as same as line
    sSeries =str2num(selectkey);      % OK
    ck = [find(sSeries>length(idx)); ...
	  find(sSeries<=0)];
    if ~isempty(ck), sSeries(ck)=[]; end

    tg_tmp = zeros(length(idx),1);
    tg_tmp(sSeries) = 1;
    if exist('tg','var')
      tg_tmp = tg + tg_tmp;
      tg = tg_tmp==2;
    else
      tg =tg_tmp;
    end
  end

  % ********* Search Kind *********
  if get(handles.ckb_SelectKind,'Value')
    selectkey = get(handles.edt_SelectKind,'String');
    sKind = str2num(selectkey);

    %type(Kind) <?>
    kind=sorgn(idx(:,1),1);
    tg_tmp = zeros(length(idx),1);
    for kind_num = sKind
      kind_idx = find(kind==kind_num); % must be scalar
      if isempty(kind_idx)
	warndlg([' No Kind ' num2str(kind_num) ' exist.']);
	continue;
      end
      tg_tmp(kind_idx) = 1;
    end

    if exist('tg','var')
      tg_tmp = tg + tg_tmp;
      tg = tg_tmp==2;
    else
      tg =tg_tmp;
    end

  end

  if exist('tg','var')
    tg = find(tg);
  else
    tg = [1:length(idx)]';
  end

  % ===== Over/Under flow Check ====
  if isempty(tg)
    errordlg('No matching data found');
    OSP_LOG('err', ' BlockFilter Mark Select', ...
	    [' Select Key : ' selectkey]);
  else
    set(handles.lbx_Marker, 'Value',tg);
    plot_Mark(handles);
  end
return;


function psb_plotchnum_Callback(hObject, eventdata, handles)
% Plot mark, in each channel
  StimInfo = getappdata(handles.figure1, 'StimInfo');
  stimData = StimInfo.StimData;
  clear StimInfo;

  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata),
    error(' No Effective Data exist.');
  end
  [header,data]=DataDef_SignalPreprocessor('load',actdata);  % Load File
  chnum=size(data,2);
  clear header data;


  [stimkind0{1:length(stimData)}] = deal(stimData.kind);
  stimkind0 = [stimkind0{:}];
  
  s = zeros(chnum(1), max(stimkind0(:)));
  blocknum=0;
  for stimdata1 = stimData
    blocknum = blocknum + length(stimdata1.stimtime);
    stimkind = stimdata1.kind;
    [sumchflg{1:length(stimdata1.stimtime)}] = ...
	deal(stimdata1.stimtime.chflg);
    sumchflg = cell2mat(sumchflg);
    s(:,stimkind) = sum( sumchflg,2);
	clear sumchflg;
  end

  if any(s)==0
    msgbox(sprintf('No Available Data'), ...
	   'Motion Check Result');
  end

  h0=figure;
  bar(s,'stacked');

  % Make tick
  num = round(chnum/5);if num==0, num=1;end
  xtick0 = [0:num:chnum]; xtick0(1)=1;
  if xtick0(end)~=chnum, 
      if (chnum-xtick0(end))<bitshift(num,-1)
          xtick0(end)=chnum; 
      else  
          xtick0(end+1)=chnum; 
      end
  end
  
  num = round(blocknum/5); if num==0, num=1;end
  ytick0 = [0:num:blocknum];
  if ytick0(end)~=blocknum
      if (blocknum-ytick0(end))<bitshift(num,-1)
          ytick0(end)=blocknum;
      else  
          ytick0(end+1)=blocknum;
      end
  end

  
  % Setvalue
  set(h0,...
      'NumberTitle','off', ...
      'Name',' Selecting Stimulation Mark',...
      'Color',[0.8, 0.8, 0.2]);
  set(gca, ...
      'Xtick',xtick0,...
      'Ytick',ytick0);
  axis([0, chnum+1, 0, blocknum]);
  title(' Motion Check Result');
  xlabel(' Channel Number ');
  ylabel(' Available Data Number');
return;

  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   View Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pop_channel_Callback(hObject, eventdata, handles)
  axes(handles.axes1); cla;
  plot_HB(handles);
  axis tight; ax = axis; 
  axh = ax(4) - ax(3); sz = axh *0.2;
  ax(4)=ax(4)+sz; ax(3)=ax(3)-sz;
  axis(ax);
  plot_Mark(handles);

% --------------------------------------------------------------------
function varargout = plot_psb_Callback(h, eventdata, handles, varargin)
  disp('Removed : plot pushbutton');
  OSP_LOG('perr', 'Removed Function Called');
return;

function plot_HB(handles)
% Change : (Data-Format)

% Load Data
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata),
    error(' No Effective Data exist.');
  end
  [header,data]=DataDef_SignalPreprocessor('load',actdata);  % Load File
  
  % set argument
  ch       = get(handles.pop_channel, 'value');
  smpl_pld = header.samplingperiod;
  unit = 1000/smpl_pld;
  hb_kind = [1:size(data,3)]; % All Print

  % ordinary Put HBdata to Plot
  strHBdata.data = data(:,ch,:); clear data;
  ch=1;
  strHBdata.tag  = header.TAGs.DataTag;
  % TODO : Color Setting
  clear header;

  % plot HB Data
  plot_HBdata(handles.axes1, ch, unit, hb_kind,strHBdata);
return;

function plot_Mark(handles)
  % ==================== 
  % Get Stimulation Data 
  % ==================== 
  ud = get(handles.lbx_Marker, 'UserData');

  ostim = getappdata(handles.figure1,'OriginalStimulation');
  dstim = getappdata(handles.figure1,'DiffStimulation');
  sflag = getappdata(handles.figure1,'FlagStimulation');
  unit  = 1000.0/getappdata(handles.figure1, 'SamplingPeriod');

  stim_kind = ostim(:,1);
  clear ostim;

  ch   = get(handles.pop_channel, 'value');


  % ==================== 
  % Axes Setting
  % ==================== 
  axes(handles.axes1); 
  
  % Height get
  tg = get(handles.lbx_Marker, 'Value');
  ax = axis;


  % ==================== 
  % Make Effective stim
  % ==================== 
  sflag = sflag(:,ch);

  rm_h = findobj(handles.axes1,'Tag', 'StimArea');
  if ~isempty(rm_h), delete(rm_h); end;
  for id = 1:size(ud,1),
    if sflag(ud(id,1)) || sflag(ud(id,2))
      continue;
    end

    tc1 = ud(id,3:4)/unit;
    if (tc1(2)-tc1(1) < 0.001),
      tc1 = mean(tc1(:)) + [-0.005 0.005]; 
    end
    h_p = fill(tc1([1 1 2 2 1]), ...
	       ax([3 4 4 3 3]), ...
	       [0.7, 1.0, 0.7]);
    set(h_p, 'Tag', 'StimArea', ...
	     'LineStyle', 'none');
    alpha(h_p,0.07);
  end
  
  % ==================== 
  % Plot Selected Stimulation
  % ==================== 
  % height = ax(3) + 0.95 * (ax(4) - ax(3));
  height = 0.95 * ax(4) + 0.05 * ax(3);

  plot_stim=[];
  for id=tg(:)',
      if ud(tg,1)~=ud(tg,2),
          plot_stim = [plot_stim, ...
                  linspace(ud(id, 3), ud(id, 4),10)];
      else,
          plot_stim = [plot_stim, ud(id,3)];
      end
  end
    
  % Remove Function
  rm_h = findobj(handles.axes1,'Tag', 'SelectedMarker');
  if ~isempty(rm_h), delete(rm_h); end
  h = plot(plot_stim(:)./unit, repmat(height,length(plot_stim),1), 'mp');
  set(h,'Tag', 'SelectedMarker');

return;


% --- Executes on button press in psb_legend.
function psb_legend_Callback(hObject, eventdata, handles)
  lh=legend;
  if isempty(lh)
    tag_legend(handles.axes1);
  else
    delete(lh);
  end
return;

function uiMenu_editaxes_Callback(hObject, eventdata, handles)
  tmp.ax = handles.axes1;
  uiEditAxes('arg_handle',tmp);

function uiconMenu_graph_Callback(hObject, eventdata, handles)


% --- Executes on button press in psb_viewer.
function psb_viewer_Callback(hObject, eventdata, handles)
% Launch Signal-Viewer and set view-data to current Group Data 

  % Save Data (to reload groupdata)
  file_save_psb_Callback(handles.file_save_psb, [], handles);

  % Get The File
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist) || id==0, return; end

  % Launch Viewer
  mc = OSP_DATA('GET','MAIN_CONTROLLER');
  OSP('psb_view_Callback',mc.handles.psb_view, [], mc.handles);

  % make setting data.
  actdata.fcn  = @DataDef_GroupData;
  actdata.data = gdatalist(id);

  % set view-data to current Group Data 
  sv_handles = guidata(getappdata(mc.hObject,'Viewer3'));
  signal_viewer3('addFile_Callback', ...
		[],[],sv_handles, actdata)
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Fille Grouping                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setLocalActiveDataGroup(fig, iniact)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Active Data Group to Block Filter GUI
% Create Date : 09-Feb-2005
% author      : M. Shoji
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
  handles = guihandles(fig);
  actdata = OSP_DATA('GET','ACTIVEDATA');

  % ======== Check Active Data ===========
  if isempty(actdata)
    msg = {' == No Active Data ==', ...
	   '   Program Error : No Active Data Exist.' ...
	   '     please try again from OSP'};
    errordlg(msg,'Block Filter Opening Function');
    OSP_LOG('perr',msg);
    delete(fig);
    return;
  end

  % Apply Active Data
  gdata = DataDef_GroupData('load');
  % new 04-Jun-2005 : Add BasicData
%   if isfield(gdata,'BasicData') && ~isempty(gdata.BasicData),
%     bd = gdata.BasicData;
%     % !! TODO , change try to isfield.
%     try,
%       setappdata(handles.figure1, 'SamplingPeriod', bd.sampleperiod);
%     end
%     % -- Set Pre-Post Stimulation Data --
%     try
%       set(handles.edt_prestim,'String',num2str(bd.relax(1)));
%     end
%     try
%       set(handles.edt_poststim,'String',num2str(bd.relax(2)));
%     end
%     try
%       setappdata(handles.figure1,'StimulationRange',bd.StimRange);
%     end
%   end

  % ======== Reload ===========
  %  -- Reload Data ---
  keyfldname = DataDef_GroupData('getIdentifierKey');
  keyname    = getfield(gdata, keyfldname);

  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  st        = get(handles.pop_groupname, 'String');

  id2       = find(strcmp(keyname, st));
  if isempty(id2)
    % new : load
    if isempty(gdatalist)
        gdatalist=gdata;
        st={keyname};
        set(handles.pop_groupname,'Visible','on');
    else
        gdatalist(end+1)=gdata;
        st{end+1}=keyname;
    end
    id2 = length(gdatalist);
    
  else
    % exist : overwrite
    %  Question
    sure0 = questdlg({' Selected File is Already opened', ...
		      '   Edit Data will be overwrote, are you sure?'}, ...
		     'Open Group Data', ...
		     'Yes', 'No', 'No');
    if strcmp(sure0,'No'), return; end;

    gdatalist(id2) = gdata;
  end

  set(handles.pop_groupname, ...
      'UserData', gdatalist, ...
      'Value', id2, ...
      'String', st);
  pop_groupname_Callback(handles.pop_groupname, [], handles);

  if ~isempty(gdata.data)
    psb_LoadData_Callback(...
	handles.psb_LoadData, [], handles);
  else
	  if nargin == 2
		  OSP_DATA('SET','ACTIVEDATA',iniact);
	  end
  end
  
return;

% --- Executes on selection change in pop_channel.
function psb_groupFileOpen_Callback(hObject, eventdata, handles)
  ini_actdata = OSP_DATA('GET','ACTIVEDATA'); % swapping.
  
  % -- Lock --
  set(handles.figure1,'Visible','off');

  % === File Select  ===
  try
    fs_h = uiFileSelect('DataDif',{'GroupData'});
    waitfor(fs_h);
  catch
    set(handles.figure1,'Visible','on');
    rethrow(lasterror);
  end

  % -- Unlock --
  set(handles.figure1,'Visible','on');

  % Cancel Check
  actdata = OSP_DATA('GET','ACTIVEDATA'); 
  if isempty(actdata), 
    OSP_DATA('SET','ACTIVEDATA',ini_actdata);     
    return;
  end
  setLocalActiveDataGroup(handles.figure1, ini_actdata);

return;

% --------------------------------------------------------------------
function varargout = file_save_psb_Callback(h, eventdata, handles, varargin)
% save as
  gdatalist = get(handles.pop_groupname, 'UserData');
  id0       = get(handles.pop_groupname, 'Value');
  if id0 > length(gdatalist) || id0==0
    set(handles.lbx_DataList, ...
	'Value',1, 'String',{'No Grouping Data'}, ...
	'UserData',[]);
    errordlg('Can not save Group Data');
    return;
  end
  gdata=gdatalist(id0);

%   % new 04-Jun-2005 : Add BasicData
%   % -- BasicData will be remoend soon.  --
%   %    07-Jun-2005
%   try,
%     bd.sampleperiod = getappdata(handles.figure1, 'SamplingPeriod');
%     % -- Set Pre-Post Stimulation Data --
%     ps=str2double(get(handles.edt_prestim,'String'));
%     pe=str2double(get(handles.edt_poststim,'String'));
%     if ~isempty(ps) && ~isempty(pe),
%       bd.relax = [ps, pe];
%     else
%       error('Inproper Relaxing Time'); return;
%     end
%     bd.StimRange    = getappdata(handles.figure1,'StimulationRange');
%   catch,
%     osp_LOG('warn','Setting BasicData', lasterr);
%     bd = struct([]);
%   end
%   gdata.BasicData = bd;

  if ~isempty(gdata.data),
    gdata.data(end).filterdata =  OspFilterCallbacks('get', handles.figure1);
  end
  gdatalist(id0) = gdata;

  for id=1:length(gdatalist),
    try
      gdatalist(id) = DataDef_GroupData('save_ow',gdatalist(id));
    catch
      errordlg(lasterr);
    end
  end
  set(handles.pop_groupname, 'UserData',gdatalist);
  
  if 1,
    OspFilterCallbacks('set',handles.figure1, ...
		       gdatalist(id0).data(end).filterdata);
  end
return;

function psb_saveas_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Block-Data as Cell/Struct 
% Create Date : 17-Feb-2005
% author      : M. Shoji
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % -- Renew Data ( saving Data ) --
  file_save_psb_Callback(handles.file_save_psb, [], handles);

  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist) || id==0, return; end

  gdata=gdatalist(id); clear gdatalist;
  if isempty(gdata.data),
    errordlg('No Save Data exist'); return;
  end

  % -- File name Get --
  [f p] = osp_uiputfile('*.mat', ...
			'Save Block Data', ...
			['BlockData' datestr(now,30)]);
  if (isequal(f,0) || isequal(p,0)), return; end
  filename = [p filesep f];

  % Make UserCommand Block Data
  actdata.fcn  = @DataDef_GroupData;
  actdata.data = gdata;
  key.actdata = actdata;
  [data, hdata] = DataDef_GroupData('make_ucdata', key);

  % save
  save(filename, 'data','hdata');

return;


  

function pop_groupname_Callback(hObject, eventdata, handles)
  set(handles.ppmMode, 'ButtonDownFcn',[],'Enable','on');
  
  % Data Load
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist) || id==0
    set(handles.lbx_DataList, ...
	'Value',1, 'String',{'No Grouping Data'}, ...
	'UserData',[]);
    setappdata(handles.figure1, 'LocalActiveData',[]);
    OspFilterCallbacks('LocalActiveDataOff', hObject,[],handles);
    return;
  end
  
  gdata=gdatalist(id);
  lactdata.fcn = @DataDef_GroupData;
  lactdata.data = gdata;
  setappdata(handles.figure1, 'LocalActiveData',lactdata);
  OspFilterCallbacks('LocalActiveDataOn', hObject,[],handles);
  
  % change 
  [st, linedata]=DataDef_GroupData('showblocks',gdata);
  if isempty(st), % TODO 
    set(handles.lbx_DataList, ...
	'Value',1, 'String',{'No Data in Groupdata'}, ...
	'UserData',[]);
    setappdata(handles.figure1, 'LocalActiveData',[]);
    OspFilterCallbacks('LocalActiveDataOff', hObject,[],handles);
    return;
  end

  id = get(handles.lbx_DataList, 'Value');
  if id > length(st)
    id = length(st);
  end
  set(handles.lbx_DataList, ...
      'Value',id, ...
      'String',st, ...
      'Userdata', linedata);
return;


function psb_makenewGroup_Callback(hObject, eventdata, handles,varargin)
  % Set New Group Data
  try
      if ~isempty(varargin),
          % Original Data
          actdata = OSP_DATA('GET','ActiveData');
          idfld   = feval(actdata.fcn,'getIdentifierKey');
          gdata =DataDef_GroupData('NewGroup',getfield(actdata.data, idfld));
          clear actdata;
      else,
          gdata =DataDef_GroupData('NewGroup');
      end
  catch
    errordlg(lasterr); return;
  end
  if isempty(gdata), return;  end

  % Adding
  gdatalist = get(handles.pop_groupname, 'UserData');
  if isempty(gdatalist)
    gdatalist = gdata;
  else
    gdatalist(end+1) = gdata;
  end
  id = length(gdatalist);

  % Update
  st        = get(handles.pop_groupname, 'String');
  fld = DataDef_GroupData('getIdentifierKey');
  if iscell(st)
    st{id} = getfield(gdata,fld);
  else
    st = {getfield(gdata,fld)};
  end
  set(handles.pop_groupname, ...
      'UserData', gdatalist, ...
      'Visible', 'on', ...
      'Value' , id, ...
      'String', st);
  pop_groupname_Callback(handles.pop_groupname, [], handles);
return;
  
function psb_delGroup_Callback(hObject, eventdata, handles)

  % Get Values Removing
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist), 
	  errordlg(' No Data exist to remove');return; 
  end
  st = get(handles.pop_groupname, 'String');

  % - Confine -
  sure0 = questdlg({'Block Filter Version 1.30 :', ...
		    '  We Delete Group Data completely.', ...
		    'Are you sure?'}, ...
		   'Delete Group', ...
		   'Yes', 'No', 'Yes');
  if strcmp(sure0,'No'), return; end
  
  % Removing
  id2 = 1:length(gdatalist);
  id2(id) = [];
  % --> since 1.30
  % Delete From List And Data And there children.
  DataDef_GroupData('deleteGroup',gdatalist(id).Tag);
  gdatalist(id) = [];
  if isempty(id2)
    st2={'No Grouping Data'}; id=1;
  else
    [st2{1:length(id2)}] = deal(st{id2});
  end
  clear id2;

  if id > length(st2), id = length(st2); end

  % Update
  set(handles.pop_groupname, ...
      'UserData', gdatalist, ...
      'Value' , id, ...
      'String', st2);
  if isempty(gdatalist)
    set(handles.pop_groupname, 'Visible', 'off');
  end
  pop_groupname_Callback(handles.pop_groupname, [], handles);
return;

function psb_removedata_Callback(hObject, eventdata, handles)

  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist)
	  errordlg('No data to remove'); return;
  end
  linedata  =  get(handles.lbx_DataList, 'Userdata');
  id2       = get(handles.lbx_DataList, 'Value');
  if id2 > length(linedata)
    errordlg(' No Data Selected'); return;
  end
  gdatalist(id).data(linedata(id2)) = [];

  set(handles.pop_groupname, 'UserData',gdatalist);
  pop_groupname_Callback(handles.pop_groupname, [], handles);
return;


% function axes_AddToGroup_ButtonDownFcn(hObject, eventdata, handles)
function psb_addtogroup_Callback(hObject, eventdata, handles)

  % == Get Group Data ==
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist)
    % No Group Data
    ans0 = questdlg({'No Group Data', ...
		     'Make new group data?'},...
		    'Make New Group', 'Yes','No','Yes');
    if strcmp(ans0, 'No'), return; end
    % Make New Group
    psb_makenewGroup_Callback(handles.psb_makenewGroup, [], handles,1)
    gdatalist = get(handles.pop_groupname, 'UserData');
    id        = get(handles.pop_groupname, 'Value');
    if id > length(gdatalist), return; end % Cancel
  end
  gdata=gdatalist(id);
  
  % Original Data
  actdata = OSP_DATA('GET','ActiveData');
  idfld   = feval(actdata.fcn,'getIdentifierKey');
  data.name = getfield(actdata.data, idfld);
  clear actdata;

  % Filter Data
  data.filterdata  = OspFilterCallbacks('get', handles.figure1);
  
  % Stimulation Data
  % there is old data
  % Removed 1.23 Stim
  % data.stim = getappdata(handles.figure1, 'StimInfo');
  % since reversion 1.23
  % 2-Sep-2005
  stim_diff.ver  = '1.50';
  stim_diff.tag  = ['Stim of this version is ' ...
		  'Differences to original stimulation.'];  
  stim_diff.type = get(handles.ppmMode, 'Value');
  stim_diff.orgn = getappdata(handles.figure1, 'OriginalStimulation');
  stim_diff.diff = getappdata(handles.figure1, 'DiffStimulation');
  stim_diff.flag = getappdata(handles.figure1, 'FlagStimulation');
  data.stim = stim_diff;
  
  % Get Motion Check
  % there is old data
  % Removed 1.23 MotioncCheck
  data.motioncheck = [];
  if isempty(gdata.data)
    gdata.data = data;
  else
    gdata.data(end+1)=data;
  end
  setappdata(handles.figure1,'CDATA_ID',length(gdata.data));
  
  if id<=1,
      gdatalist=gdata;
  else,
    gdatalist(id)=gdata;
  end
  
  set(handles.pop_groupname, 'UserData', gdatalist);
  % Re load
  pop_groupname_Callback(handles.pop_groupname, [], handles);
  % Save Group Data
  file_save_psb_Callback(handles.file_save_psb, [], handles);

return;


% function axes_LoadData_ButtonDownFcn(hObject, eventdata, handles)
function psb_LoadData_Callback(hObject, eventdata, handles)

  % -- Get Load Value --
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist)
    errordlg('No data to Load'); return;
  end
  gdata=gdatalist(id);
  linedata  =  get(handles.lbx_DataList, 'Userdata');
  id2       =  get(handles.lbx_DataList, 'Value');

  if id2 > length(linedata)
    errordlg(' No Data to Load'); return;
  end
  setappdata(handles.figure1,'CDATA_ID',linedata(id2));
  loaddata = gdata.data(linedata(id2));
  loaddata.filterdata = gdata.data(end).filterdata;

  % --- Original Data ----
  actdata.fcn  = @DataDef_SignalPreprocessor;
  actdata.data = feval(actdata.fcn,'loadlist',loaddata.name);
  OSP_DATA('SET','ActiveData',actdata);
  clear actdata;
  setLocalActiveData(handles.figure1);  % Plot

  % --- Filter Data ---
  OspFilterCallbacks('set',handles.figure1, loaddata.filterdata);

  % --- Stimulation Data ---
  try,
	  set(handles.ppmMode,'Value',loaddata.stim.type);
  end
  if isfield(loaddata.stim,'ver'),
	  stim = loaddata.stim;
	  setappdata(handles.figure1, 'OriginalStimulation', stim.orgn);
	  setappdata(handles.figure1, 'DiffStimulation',stim.diff);
	  setappdata(handles.figure1, 'FlagStimulation',stim.flag);
  else ,
	  set(handles.ppmMode,'Value',loaddata.stim.type);
	  reset_psb_Callback(handles.figure1, [] , handles);
	  org   = getappdata(handles.figure1,'OriginalStimulation');
	  sflag = getappdata(handles.figure1, 'FlagStimulation');
	  for aStimData=loaddata.stim.StimData,
		  for astimtime=aStimData.stimtime,
			  i_s = find(org(:,2)==astimtime.iniStim);
			  if isempty(i_s), continue; end
			  sflag(i_s,:) = ~astimtime.chflg';
			  i_f = find(org(:,2)==astimtime.finStim);
			  if isempty(i_f), continue; end
			  if (i_s ~= i_f),
				  sflag(i_f,:) = ~astimtime.chflg';
			  end
		  end % Block
	  end % Kind
	  setappdata(handles.figure1, 'FlagStimulation',sflag);
  end

  new_listbox_marker(handles); % Make Strings of Marker-Listbox
  plot_Mark(handles); % Plot Marker
  
  % --- Get Motion Check ---
  if isfield(loaddata,'motioncheck') && ~isempty(loaddata.motioncheck)
	  % ~~ Old Mode ~~ version 1.0
	  mc = loaddata.motioncheck;  % for tmp
	  % Update
	  set(handles.chb_motioncheck_apply,'Value',1)
	  setappdata(handles.figure1, 'MotionCheckArgument',mc);
	  set(handles.hp_freq,'String', num2str(mc.highpath));
	  set(handles.lp_freq,'String', num2str(mc.lowpath));
	  if isnumeric(mc.criterion)
		  set(handles.chkBase,'String',num2str(mc.criterion));
		  set(handles.sd_3sigma,'Value',0);
	  else
		  set(handles.sd_3sigma,'Value',1);
	  end
	  unitinv   = 1/mc.unit;            %  ->Print Unit
	  st        = mc.PreStim  * unitinv;
	  ed        = mc.PostStim * unitinv;
	  set(handles.edt_prestim, 'String', num2str(st));
	  set(handles.edt_poststim,   'String', num2str(ed));
  end
return;

function changeRelaxMax(handles)
% Change Relaxing time Max and Min
% Create by Masanori Shoji at 03-Jun-2005

% get Stimulation Data
  ud = get(handles.lbx_Marker, 'UserData');
  ostim = getappdata(handles.figure1,'OriginalStimulation');
  sflag = getappdata(handles.figure1,'FlagStimulation');

  % == get StimTiming Matrix ==
  % Initialize  StimTiming Matrix
  if isempty(ud),
    stimtime_list=[];
    set([handles.txt_premax, handles.txt_postmax],...
	'String','(-)');
  else,
    stimtime_list = [ostim(ud(:,1),1), ud(:,3:4)];
  end

  stim_interval = stimtime_list(:,[2,3])';
  sz            = getappdata(handles.figure1, 'DATA_SIZE');
  stim_interval = [0; ...
		   stim_interval(:);...
		   sz(1)];
  stim_interval = diff(stim_interval);
  stim_interval = stim_interval(1:2:end);
  
  stim_kind      = zeros(size(stim_interval,1),2);
  stim_kind(1,2) = NaN;stim_kind(end,1) = NaN;
  stim_kind([1:end-1],1) = stimtime_list(:,1);
  stim_kind([2:end],  2) = stimtime_list(:,1);

  unit_inv    = getappdata(handles.figure1, 'SamplingPeriod')/1000.;

  get_kind   = find(~isnan(stim_kind));
  if isempty(get_kind),
    set([handles.txt_premax, handles.txt_postmax],...
	'String','(-)');
    return;
  end  
  get_kind = stim_kind(get_kind);
  
  tmp = find(stim_kind(:,1)==get_kind(1));
  start_max  = min(stim_interval(tmp));
  set(handles.txt_premax, ...
      'String',sprintf('%4.1f',start_max*unit_inv));

  tmp = find(stim_kind(:,2)==get_kind(1));
  end_max    = min(stim_interval(tmp));
  set(handles.txt_postmax, ...
      'String',sprintf('%4.1f',end_max*unit_inv));
  
  % Change minimum Stimulation
  % add : 04-Jun-2005
  stim_list2 = stimtime_list(:,3) - stimtime_list(:,2);
  mx = max(stim_list2(:));
  mn = min(stim_list2(:));
  if mx*unit_inv*1000 > (mn*unit_inv*1000+OSP_STIMPERIOD_DIFF_LIMIT),
    warndlg('stimulation time is so different.');
  end
  setappdata(handles.figure1,'StimulationRange',mx * unit_inv);
  
return;


function psb_make_mfile_Callback(hObject, eventdata, handles)
% Make M-File Output Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output M-File                                    %
%--------------------------------------------------%
%  Author      : Masanori Shoji.                   %
%  Create Date : 17-Jun-2005                       %
%  since       : block_filter r1.21                %
%  since       : OSP ver1.10                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Renew Data ( saving Data )
  file_save_psb_Callback(handles.file_save_psb, [], handles);
  
  % Get Group-Data
  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  if id > length(gdatalist) || id==0, return; end
  gdata = gdatalist(id); clear gdatalist;

  % -- File name Get --
  [f p] = osp_uiputfile('*.m', ...
			'Output M-File Name', ...
			['osp_v1_10_Group_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel

  % == Open M-File ==
  fname = [p filesep f];
   try,
	[fid, fname] = make_mfile('fopen', fname,'w');
    GroupData2Mfile(gdata);
  catch,
    make_mfile('fclose');
    rethrow(lasterror);
  end

  % == Close M-File ==
  make_mfile('fclose');
  
return;


% --------------------------------------------------------------------
function menu_diff_limits_Callback(hObject, eventdata, handles)
% hObject    handle to menu_diff_limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flg=true;

lim=OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT');
while flg
	strlim=inputdlg({['Set ' ...
				OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT_TAG')]}, ...
		'Block  Setting : STIM DIFF LIMIT', ...
		1,{num2str(lim)});
	if isempty(strlim), return; end
	try,
		lim=str2double(strlim{1});
		flg=false;
	catch,
		errordlg(lasterr);
	end
end
OSP_DATA('SET','OSP_STIMPERIOD_DIFF_LIMIT',lim);
changeRelaxMax(handles);


function SaveGroupData(h, eventdata, handles, varargin)
% Call from OspFilteCallbacks
% main_h=OSP; ( errof if current dir is..)
gdatalist = get(handles.pop_groupname, 'UserData');
id0       = get(handles.pop_groupname, 'Value');
if id0 > length(gdatalist) || id0==0
    set(handles.lbx_DataList, ...
        'Value',1, 'String',{'No Grouping Data'}, ...
        'UserData',[]);
    errordlg(' No Group Data');
    return;
end
gdata=gdatalist(id0);

if ~isempty(gdata.data),
    gdata.data(end).filterdata =  OspFilterCallbacks('get', handles.figure1);
end
gdatalist(id0) = DataDef_GroupData('save_ow',gdata);
set(handles.pop_groupname, 'UserData',gdatalist);
setappdata(handles.figure1,'SAVE_GROUP',false); % For Filter Change
% ---> comment out <----
% 5-Dec-2005
main_h = OSP_DATA('GET','MAIN_CONTROLLER');
main_h = main_h.hObject;
vh=getappdata(main_h,'Viewer');
if ~isempty(vh) && ishandle(vh),delete(vh);end
vh=getappdata(main_h,'Viewer2');
if ~isempty(vh) && ishandle(vh),delete(vh); end

function ReloadFMD(hObject,evendata, handles,actdata)
% Reload FileManage Data
% ---> comment out <----
% 5-Dec-2005
return;
% ======== Check Active Data ===========
  if isempty(actdata)
    return;
  end

  % ======== Reload ===========
  %  -- Reload Data ---
  keyfldname = DataDef_GroupData('getIdentifierKey');
  keyname    = getfield(actdata.data, keyfldname);

  gdatalist = get(handles.pop_groupname, 'UserData');
  id        = get(handles.pop_groupname, 'Value');
  st        = get(handles.pop_groupname, 'String');
  ck        = strcmp(keyname, st(id));
  if ck==0,return; end

  % Reload FMD
  gdatalist(id) =actdata.data;

  set(handles.pop_groupname, 'UserData', gdatalist);
  OspFilterCallbacks('set',...
      handles.figure1, ...
      actdata.data.data(end).filterdata);
  
return;
