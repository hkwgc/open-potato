function varargout = statistical_analysis(varargin)
% STATISTICAL_ANALYSIS M-file for OSP Statistical Analysis GUI.
%      STATISTICAL_ANALYSIS, by itself, 
%            creates new  STATISTICAL_ANALYSIS
%            or raises the existing singleton*.
%
%      H = STATISTICAL_ANALYSIS 
%       returns the handle to lbx_BlockList new STATISTICAL_ANALYSIS or the handle to
%       the existing singleton*.
%
%      STATISTICAL_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATISTICAL_ANALYSIS.M with the given input arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 02-Mar-2005 18:52:16

% $Id: statistical_analysis.m 180 2011-05-19 09:34:28Z Katura $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @statistical_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @statistical_analysis_OutputFcn, ...
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     GUI  Figure1 Functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function statistical_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% ---------------------------------------
%  Opnig function of Statistical Analysis
%   Do nothing special
% ---------------------------------------
  handles.output = hObject;
  guidata(hObject, handles);

  set(hObject,'Color','white');

  % Active Data Set
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if ~isempty(actdata),
    % Apply Active Data
    addGroupFile(handles, actdata);
  end
  pop_Analylsis_Callback(handles.pop_Analylsis, eventdata, handles)
  
return;


function varargout = statistical_analysis_OutputFcn(hObject, eventdata, handles)
% ---------------------------------------
%  Out put is GUI-handle of Statistical Analysis
% ---------------------------------------
  varargout{1} = handles.output;


function figure1_DeleteFcn(hObject, eventdata, handles)
% ---------------------------------------
%  Delete Function of Statistical Analysis
%     Change Main-Controller view state
% ---------------------------------------
  try
    osp_ComDeleteFcn;
  catch
    OSP_LOG('perr',lasterr, ' Delete Error : osp ComDeleteFcn');
  end
return;

function figure1_KeyPressFcn(hObject, eventdata, handles)
% ---------------------------------------
%  Common Key Bind Setting
%     Identfier name is statistical_analysis
% ---------------------------------------

  osp_KeyBind(hObject,[],handles, mfilename);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Data Selection
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function psb_Rmdata_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Remove Data From Group Data List-box
%     Remove From the List
% ---------------------------------------
  % Lode Data
  gd = get(handles.lbx_groupdata, 'Userdata');
  st = get(handles.lbx_groupdata, 'String');
  id = get(handles.lbx_groupdata, 'Value');

  % Number Check
  if length(gd) < id
    warndlg(' No remove Data')
    return;  % No Data 
  end

  % Remove
  gd(id)=[];
  id2 = [1:length(st)]; id2(id)=[];
  if isempty(id2)
    st = {' Load Group Data'};
  else
    [st2{1:length(id2)}] = deal(st{id2}); st=st2; 
  end

  % ID Overflow Check
  if id > length(st)
    id = length(st);
  end

  % Update data
  set(handles.lbx_groupdata, ...
      'UserData', gd, ...
      'Value', id, ...
      'String', st);

  % If you want not to Output Warndlg,
  lbx_groupdata_Callback(handles.lbx_groupdata, [], handles);  

return;


function psb_fopen_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Add GroupData to the List by using uiFileSelect
% ---------------------------------------

  ini_actdata = OSP_DATA('GET','ACTIVEDATA'); % swapping.

  % -- Lock --
  set(handles.figure1,'Visible','off');

  % === File Select  ===
  try
    fs_h = uiFileSelect('DataDif',{'GroupData'},'SetMax',10);
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

  for id = 1: length(actdata),
    actdata0 = actdata(id);
    if isempty(actdata0), continue; end
    try,
      % Apply Active Data
      addGroupFile(handles, actdata0);
    catch,
      warning(lasterr);
      OSP_LOG('err',lasterr);
    end
  end
  OSP_DATA('SET','ACTIVEDATA',actdata0);
  return;

return;

function addGroupFile(handles, actdata)
% ---------------------------------------
%  Add GroupData to the List Main ( State Chaneg)
% ---------------------------------------
  gd = get(handles.lbx_groupdata, 'Userdata');
  st = get(handles.lbx_groupdata, 'String');
  id = length(gd) + 1;

  % Set Print Name
  idfld = feval(actdata.fcn, 'getIdentifierKey');
  dname = getfield(actdata.data,idfld);

  % Load File
  gdata = feval(actdata.fcn, 'load', actdata.data);

  % Renew Data
  if any(strcmp(st,dname)) && ~isempty(gd) 
    % Already open
    warndlg(' Selected Data is already opened');
    id = find(strcmp(st,dname));
    id = id(1);
  else
    % Add Data
    if isempty(gd)
      st = {dname};
      gd = {gdata};
    else
      st{id} = dname;
      gd{id} = gdata;
    end
  end

  % Set & Reload
  set(handles.lbx_groupdata, ...
      'Userdata', gd, ...
      'String', st, ...
      'Value', id);
  lbx_groupdata_Callback(handles.lbx_groupdata, [], handles);
return;

function lbx_groupdata_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Change Data Information
% ---------------------------------------

  % Load Data
  gd = get(handles.lbx_groupdata, 'Userdata');
  id = get(handles.lbx_groupdata, 'Value');

  % Number Check
  % List-Box of BlockList Renew
  if ~isempty(gd)
    % Get Information
    [st, linedata, kind_list] = DataDef_GroupData('showblocks',gd{id(1)});

    id2 = get(handles.lbx_BlockList, 'Value');
    over = find(id2 > length(st));
    if ~isempty(over)
      id2(over) = [];
      if isempty(id2), id2=1; end
    end

  else
    id2 = 1;
    st  = {'-- No Group Data --'};
    linedata = [0 0 0];
  end

  set(handles.lbx_BlockList, ...
      'Value', id2, ...
      'String', st, ...
      'UserData', linedata);

  %  Popupmenu, Stimulation-Kind, renew 
  if exist('kind_list', 'var') && ~isempty(kind_list)
    kind_list=sort(kind_list);
    set(handles.pop_stimkind, ...
	'Value', 1, ...
	'string', cellstr(num2str(kind_list(:))));
  else
    set(handles.pop_stimkind, ...
	'Value', 1, ...
	'string', {'-'});
  end

  %  Minimum PresStim Setup

return;

function radio_all_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Use Data Select Radio Button Value control
% ---------------------------------------

  if get(handles.radio_all, 'Value')
    set(handles.radio_select, 'Value',0);
  else
    set(handles.radio_select, 'Value',1);
  end
return;

function radio_select_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Use Data Select Radio Button Value control
% ---------------------------------------
  if get(handles.radio_select, 'Value')
    set(handles.radio_all, 'Value',0);
  else
    set(handles.radio_all, 'Value',1);
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Make Analysis Data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gdl = getGroupDataList(handles)
% ----------------------
%  Get Select Block
% ----------------------
  % Load Group Data
  gdl = get(handles.lbx_groupdata, 'Userdata');
  id  = get(handles.lbx_groupdata, 'Value');
  gdl = gdl{id(1)};

  % Filter is Last One
  [gdl.data.filterdata] = deal(gdl.data(end).filterdata);
  
  if get(handles.radio_select, 'Value')
	  % -- Selected Data Load ---
	  id0 =  get(handles.lbx_BlockList, 'Value');
	  li  =  get(handles.lbx_BlockList, 'UserData');
	  
	  id1 = 1:size(li,1);
	  id1(id0)=[];
	  for id2 = length(id1):-1:1
		  id = id1(id2);
		  if any(li(id,:)==0), continue; end
		  if isfield(gdl.data(li(id,1)).stim,'ver'),
			  gdl.data(li(id,1)).stim.flag(li(id,2:3),:) = true;
		  else,	  
			  gdl.data(li(id,1)).stim.StimData(li(id,2)).stimtime(li(id,3)) ...
				  = [];
		  end
	  end
	  
	  % Remove Unused Data
	  for id = length(gdl.data):-1:1,   % Loop file
		  % Loop stimdata
		  if isfield(gdl.data(id).stim,'ver'),
			  if ~strcmp(gdl.data(id).stim.ver,'1.50'),
				  error(['Unknown version ' gdl.data(id).stim.ver]);
			  end
		  else,
			  for id2 = length(gdl.data(id).stim.StimData):-1:1
				  % Remove none data kind 
				  if length(gdl.data(id).stim.StimData(id2).stimtime)==0
					  gdl.data(id).stim.StimData(id2)=[];
				  end
			  end
			  % remove none data file
			  if length(gdl.data(id).stim.StimData) == 0
				  gdl.data(id)=[];
			  end
		  end
	  end % Data Loop Remove
	  if isempty(gdl.data)
		  gdl=[]; return;
	  end
  end

  % --- Selected Kind ---
  if 0,
	  if strcmpi(get(handles.pop_stimkind,'Visible'),'on')
		  usekind = get(handles.pop_stimkind,'String');
		  usekind = char(usekind{get(handles.pop_stimkind,'Value')});
		  if strcmp(usekind,'-')
			  gdl=[]; return;
		  else
			  usekind = str2num(usekind);
		  end
	  else
		  usekind = gdl.data(1).stim.StimData(1).kind;
	  end
	  % Delete Other kind
	  for fid=length(gdl.data):-1:1
		  for kid = length(gdl.data(fid).stim.StimData):-1:1
			  if gdl.data(fid).stim.StimData(kid).kind ~= usekind
				  gdl.data(fid).stim.StimData(kid) = [];
			  end
		  end
		  % remove none data file
		  if length(gdl.data(fid).stim.StimData) == 0
			  gdl.data(fid)=[];
		  end
	  end
  end
  if isempty(gdl.data)
    gdl=[]; return;
  end
  
return;

%function [block,bkind,tag,astimtimes, unit,measuremode] = make_block(handles)
function [data, hdata] = make_block(handles)
% ---------------------------------------
%  Make Block Data Correspond to Setting
%    Read Selected Data
%         Seting Relax
%    And Make block
%  Format of Return Values is as same as
%        that of datablocking('getMultiBlock')
% ---------------------------------------

  % ***  Make Selected Group-Data-List ***
  gdl = getGroupDataList(handles);
  if isempty(gdl)
    errordlg('No Effective Data Selected.')
    return;
  end
  
  if 0, 
	  % OSP version 1.00 : Old source
	  % *** Set Relaxing time ***
	  [pre0 post0 unit] = datablocking('getMinRelax', gdl);
	  % Load Pre-Post Stimulation Time, with unit
	  pre  = str2num(get(handles.edit_prestim, 'String')) * unit;
	  post = str2num(get(handles.edit_poststim,'String')) * unit;
	  % Select Minimum Stimulation
	  if pre0~=0 && pre0 < pre,
		  pre  = pre0; 
		  warndlg(['Setting Pre-Stimulation Value is ', ...
				  'Longer than that of Grouping Data Minimum']);
	  end
	  if post0~=0 && post0 < post,
		  post = post0;
		  warndlg(['Setting Post-Stimulation Value is ', ...
				  'Longer than that of Grouping Data Minimum']);
	  end
	  relax=[pre post];
	  clear pre pre0 post post0;
	  
	  %  *** Make Blockdata ***
	  [block bkind tag astimtimes, measuremode] = ...
		  datablocking('getMultiBlock',gdl, relax);
  else,
	  % OSP version 1.10 : after
	  %   2005.06.27
	  
	  % == Open M-File ==
	  fname = fileparts(which('OSP'));
	  fname = [fname filesep 'ospData' filesep];
	  fname = [fname 'gd_mt_' datestr(now,30) '.m'];
	  [fid, fname] = make_mfile('fopen', fname,'w');
	  try,
		  GroupData2Mfile(gdl);
	  catch,
		  make_mfile('fclose');
		  rethrow(lasterror);
	  end
	  % == Close M-File ==
	  make_mfile('fclose');
	  
	  [data, hdata] = scriptMeval(fname, 'bdata', 'bhdata');
	  delete(fname);
  end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Launch Analysis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_Analylsis_CreateFcn(hObject, eventdata, handles)
% ---------------------------------------
% Set Analysis List
% ---------------------------------------
  analysis_key = {'T-test','PCA','PCA 2nd'};
  analysis_fcn = {@uiTtest, @uiPCA, @uiPCA2};

  % --Add Plugin GUI
  try,
	  [analysis_key, analysis_fcn] = ...
		  check_analysisPlugin(analysis_key, analysis_fcn);
  catch,
	  warning(lasterr);
  end

  set(hObject, ...
      'String',analysis_key, ...
      'UserData', analysis_fcn, ...
      'Value', 1);
return;
      
function [nkeys, nfcns] = check_analysisPlugin(keys, fcns)
  % ********  Search Plugin ********
  osp_path    = fileparts(which('OSP'));
  plugin_path = [osp_path filesep 'APluginGuiDir'];

  tmpdir = pwd;
  try,
    cd(plugin_path);

    files = dir('PluginGui_*.m');
    for idx=1:length(files),
      try,
	[pth, nm, ex] = ...
	    fileparts(files(idx).name);
	nm2 = eval(['@' nm]);
	[name, type] = feval(nm2,'createBasicInfo');

	keys{end+1}    = name;
	fcns{end+1}    = nm2;
      catch,
	warning(lasterr);
      end
    end
  catch,
    cd(tmpdir);
    rethrow(lasterror);
  end
  nkeys = keys;
  nfcns = fcns;
  cd(tmpdir);
return;

function pop_Analylsis_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Change Data Information 
%  % now Do nothing
% ---------------------------------------
return;


function psb_Analysis_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Analysis 
% ---------------------------------------
  %analysisfnc = getappdata(handles.pop_Analylsis,'Userdata');

  % Make Block
  %[block,bkind,tag,astimtimes, unit, measuremode] = ...
  [data, hdata] = make_block(handles);
    
  % Get Analysis Function
  fcn = get(handles.pop_Analylsis, 'UserData');
  fcn = fcn{get(handles.pop_Analylsis, 'Value')};

  % Launch Analysis GUI
  figh = feval(fcn);
  feval(fcn,'SetValue',figh, [], guidata(figh), ...
	data, hdata);
  clear block bkind tag astimtimes;

return;

function psb_helpanalysis_Callback(hObject, eventdata, handles)
% ---------------------------------------
%  Show Help of corresponding Analysis 
% ---------------------------------------
  fcn = get(handles.pop_Analylsis, 'UserData');
  id  = get(handles.pop_Analylsis, 'Value');
  fcnname = func2str(fcn{id});
  OspHelp(fcnname);
return;
  
