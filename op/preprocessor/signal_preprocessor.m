function varargout = signal_preprocessor(varargin)
% SIGNAL_PREPROCESSOR Application M-file for signal_preprocessor.fig
%    FIG = SIGNAL_PREPROCESSOR launch signal_preprocessor GUI.
%    SIGNAL_PREPROCESSOR('callback_name', ...) invoke the named callback.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 12-Jun-2006 17:08:47
% $Id: signal_preprocessor.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.12
%   OSP_version 1.0 data can be Read.
%   BugFix : Error message
%
% Revision 1.15
%   Add Anonymity 
%
% Revvision 1.16
%   Add Rename Option
%
% Revision 1.17
%   Add : Signal Preprocessor Execute Functions
%     --> for plug-in
%
% Revision 2.4
%   Date 28-Dec-2006
%
% Revision 2.6
%    Add Auto Select-Checkbox
%    Meeting on 10-Jan-2006: TK & MS
%
% Rivision 1.34
%    Delete : when execute Done

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% ==== Opening Function of SP ===
	% Use system color scheme for figure:
	set(fig,'Color',[1 1 1]);
	OSP_DATA('SET','SP_ANONYMITY',true); % since 1.15
	OSP_DATA('SET','SP_Rename','-'); % since 1.16

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	% since 2.6 : 
	pop_OpenMode_Callback(handles.pop_OpenMode, [], handles);
    
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

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


function main_strns_fig_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
function main_strns_fig_DeleteFcn(hObject, eventdata, handles)
try,
  OSP_DATA('SET','SP_ANONYMITY',logical(0)); % since 1.15
  OSP_DATA('SET','SP_Rename','-'); % since 1.16
  osp_ComDeleteFcn;
end
% --- Executes on key press over main_strns_fig with no controls selected.
function main_strns_fig_KeyPressFcn(hObject, eventdata, handles)
osp_KeyBind(hObject, eventdata, handles,mfilename);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==== ETG Data Select ====
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ================================
function varargout = file_select_psb_Callback(h, eventdata, handles, varargin)
% Execute on press File Open Push button.
% File Open
% ================================

  % -----
  % Check existing Preprocessor Function  
  % -----
  funcs=get(handles.lbx_PreproFunction, 'UserData');
  if isempty(funcs),
    errordlg('No  Preprocessor Opration Function Selected.');
    return;
  end
  
  %---------------------
  %   File Select 
  %---------------------
  % Set Working-Directory for "uigetfile" 
  % is Project Directory
  % Backup "current working directory" to recover
  pwdtmp=pwd;                          
	
  % -- Project --
  pj=OSP_DATA('GET','PROJECT');        % Open Project Data
  if isempty(pj)     
    % if there is no Project --> Error
    errordlg({'OSP Error!!', ...
	      '  There is no Current-Project (Data-Directory).', ...
	      '  Open Project at first!', ...
	      '    :: Open OSP Main-Controller --> ', ...
	      '       Select File-Menu : Project -->', ...
	      ['       I/O -> "New Project"/' ...
	       '"Open Project"/"ImportProject"'], ...
	      '        "Search Project"'});
    return;
  end
  % Default Directory in 'uigetfiles'
  %   is Project-Directory.
  cd(pj.Path);

  % --> Current 
  % [fn pn]=uigetfile('*.dat');
  %[fn pn]=uigetfile('*.dat; *.mea; *.csv');          % Changed by
  %Atsumori,Hitachi,July 1-2 2004
  [fn pn]=uigetfiles({'*.dat; *.mea; *.csv; s_*.mat; HB_*.mat; *.txt', ...
		      'All Signaldata';...
		      's_*.mat', 'VER0.x Signal Data'; ...
		      'HB_*.mat', 'VER1.0 Signal Data'; ...
		      '*.dat', 'Dat Files'; ...
		      '*.mea', 'Mea Files'; ...
		      '*.csv', 'CSV Files'; ...
		      '*.txt', 'Shimadzu-Format or Text'}, ...
		     'SignalViewer File Select');
  %			'CD_*.mat', 'VER2.0 Continuous Data'; ...	   
  
  % Recover Current Working Directory
  cd(pwdtmp);                            

  % -----------------
  %  Check And Store
  %     : Open File 
  % ------------------
  % Check Cancel : Added by Shoji, 12-Oct-2004
  if isequal(fn,0) | isequal(pn,0)       
    return;
  end

  % Get Current FileList Information
  filelist = get(handles.drnm_strns_lsb, 'String');
  funclist = get(handles.drnm_strns_lsb, 'UserData');
  for id=1: length(fn)
    % Make File Name with Full-Path.
    fullpath=[pn filesep fn{id}];

    % - check Same Name - Added by Shoji, 12-Oct-2004
    cmp= strcmp(filelist(:),fullpath);
    if sum(cmp)>0
      % If Selected File in uigetfiles is already Listed.
      msg=sprintf('Following File is already listed!\n\n\t%s',fn{id}); 
      errordlg(msg);
      continue;
    end
    
    % Selected-File Listing.
    % - Add file to the list & Change Selected File -
    %%filelist{end+1}=fullpath;                                % Add

    % ================================================
    % File Check & Add
    % - Add file to the list & Change Selected File -
    % Preprocessor Function (Conversion Function )
    %  List-Loop
    %  Modified : Reversion 1.17
    % ================================================
    flg = false;
    for fidx=1: length(funcs)
      % Check : 
      %   Function 'funcs{fidx}' is available?
      [flg, msg] = feval(funcs{fidx}, 'CheckFile', fullpath);
      if flg==true,
	% Available :
	%   Add to the List 
	%   with Preprocessor loop
	if isempty(funclist),
	  filelist{1}=fullpath;
	  funclist{1}=funcs{fidx};
	else
	  filelist{end+1}=fullpath;
	  funclist{end+1}=funcs{fidx};
	end                            % 
	break; % exit : Function Loop
      end % Available
    end % Function Loop ( Function List)

    if (flg==false),
      % No Available Preprocessor Function exist.
      % Add : 28-Dec-2005
      warndlg({'No Available Preprocessor-Functions!', ...
	       ['   File Name : ' fn{id}]});
    end
  end % File List(Uigetfiles)

  if ~isempty(filelist),
    % Update File-List
    set(handles.drnm_strns_lsb, ...
	'String',  filelist, ...
	'Value',   length(filelist), ...
	'UserData',funclist);
    % ==> get file infomation
    drnm_strns_lsb_Callback(h, eventdata, handles, varargin);
  end
  return;


% ================================
%  File Remove
% ================================
function varargout = file_remove_psb_Callback(h, eventdata, handles, varargin)

%file remove
st=get(handles.drnm_strns_lsb, 'String');
tg=get(handles.drnm_strns_lsb, 'Value');
ud=get(handles.drnm_strns_lsb, 'UserData');    % function name

if length(st)==0, errordlg(' No file to remove');return; end
try
  st(tg)=[];
  ud(tg)=[];
catch
  errordlg('Cannot remove');return;
end

val=tg-1;

set(handles.drnm_strns_lsb, 'Value', val+(val==0));
set(handles.drnm_strns_lsb, 'String', st);
set(handles.drnm_strns_lsb, 'UserData', ud);
set(handles.outvar_strns_lsb,'Value',1,'String','- Removed -');  % Added by Shoji 13-Oct-2004
% if you want to Redraw File Information, 
% uncomment following code
%  -> Shoji 26-Jan-2005
%     uncomment for Active Data, and change
if length(st)~=0
  drnm_strns_lsb_Callback(h, eventdata, handles, varargin);
else
  OSP_DATA('SET','ActiveData',[]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = exec_strns_psb_Callback(h, eventdata, handles, varargin)
% === Execute Conversion ===
% Date : 28-Dec-2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % --- get Translation List ---
  filelist=get(handles.drnm_strns_lsb, 'String');
  funclist=get(handles.drnm_strns_lsb, 'UserData');
  listsz=length(filelist);
  if isempty(funclist),
    errordlg(' No files to convert!');return;
  end

  % --- Start Lock  ---
  gui_buttonlock('lock',gcf,h);
  set(h,'Enable','inactive');
  actFlag = OSP_DATA('GET','ACTIVE_FLAG');
  OSP_DATA('SET','ACTIVE_FLAG',bitset(actFlag,2));
  try,
    % Transrate each of file in the list
    last_file=[];
    for i0=1:listsz
      set(handles.drnm_strns_lsb, 'value', i0)
      setActiveData(filelist{i0});
      acd = OSP_DATA('get', 'ActiveData');
      
      % Ignore Converted Data.
      % ( If Same-Named Data exist in the list,
      %   Continue..)
      sp_rename=OSP_DATA('GET','SP_Rename'); % since 1.16
      if strcmp(sp_rename,'-') && ~isempty(acd)
	warndlg({' ==== Data may be  already exist ====', ...
		 '  Same-name File exist in the Project', ...
		 '     Case 1 : The file already converted.',  ...
		 '       if you want to remake, remove at first' ,...
		 '     Case 2 : Same Name File, but different data',...
		 '       Change File-Name to unique-name'}, ...
		[' Saving ' filelist{i0}]);
	last_file=filelist{i0};
	continue;
      end
      
      try
	endflg=otsigtrnschld2(filelist{i0},funclist{i0});
	% endflg=otsigtrnschld(filelist{i0});
	last_file=filelist{i0};
      catch
	msg=sprintf('Convert Error : %s\n\n%s\n', ...
		    filelist{i0}, ...
		    lasterr);
	errordlg(msg);
	continue;
      end
      if endflg==true, break; end    % To Stop translation
    end

    setActiveData(last_file);
  catch
    errordlg({'OSP Error : ', ...
	      ['  ' lasterr]})
  end
  % --- Unlock ---
  OSP_DATA('SET','ACTIVE_FLAG',bitset(actFlag,2,0));
  gui_buttonlock('unlock',handles.main_strns_fig);
  unlock_local(handles);

  %----------
  % Delete Now
  % since r1.34 :
  %    mail from TK at  Wed, 28 Jun 2006 15:43:04
  %----------
  % Warning Edit Button Can not be use..
  return;
  OSP_DATA('SET','SP_ANONYMITY',logical(0)); % since 1.15
  OSP_DATA('SET','SP_Rename','-'); % since 1.16
  osp_ComDeleteFcn;
  delete(handles.main_strns_fig);

  % Reset Input Name Id (now: but , it will be ...)
  % chk_Rename_Callback(handles.chk_Rename,[],handles); 
return;


% --------------------------------------------------------------------
function varargout = pltexe_btn_Callback(h, eventdata, handles, varargin)
% --> Delete on 28-Dec-2005

% --------------------------------------------------------------------
function varargout = drnm_strns_lsb_Callback(h, eventdata, handles, varargin)
%file list box
%When you click a file from this file list box, the file information is 
%displayed on file information list box.??

filelist = get(handles.drnm_strns_lsb, 'String');
id       = get(handles.drnm_strns_lsb, 'Value');
funclist = get(handles.drnm_strns_lsb, 'UserData');
if id<1, return;end
if isempty(funclist) || isempty(filelist), return; end
fullname = filelist{id(1)};

[pathname, filename]=pathandfilename(fullname);

% Add Error case display by Shoji 14-Oct-2004
try
      str = feval(funclist{id(1)}, 'getFileInfo', fullname);
%%  [hdata, data] = feval(funclist{id(1)}, 'Execute', fullname);
%%   OSP_DATA('SET','OSP_LocalData',ldata);
      if isempty(str), 
	str ={ 'No Comment Exist '}
      end
      set(handles.outvar_strns_lsb,'Value',1,'String',str);
catch
	msg=sprintf('--- Selected file is Out-of-ETG-format ---\n\n%s\n  File :%s',...
		    lasterr,filename);
	errordlg(msg);
	set(handles.outvar_strns_lsb,'Value',1,'String',msg);
	return;
end

setActiveData(fullname);
return;  

%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==== Fileter Option ====
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Removed Following Functions
% Date : 28-Dec-2005
%  function varargout = cbxMovingAverage_Callback(h, eventdata, handles, varargin)
%  function varargout = cbxFitting_Callback(h, eventdata, handles, varargin)
%  function varargout = frqflt_valu_Callback(h, eventdata, handles, varargin)
%  function varargout = outvar_strns_lsb_Callback(h, eventdata, handles, varargin)


%%%%%%%%%%%%%%%%%
% Edit HB Data
%%%%%%%%%%%%%%%%%
function psb_HB_EDIT_Callback(hObject, eventdata, handles)
% Edit HB Data
% 05-Jan-2006 ,  M. Shoji 

% Read Active Data
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata)
    warndlg({' No files to Edit!', ...
	     '  Select Convert Data'}, ...
	    '  HB Edit Button : Warning ');
    return;
  end
  [header, data]=DataDef_SignalPreprocessor('load',actdata);
  % --- Start Lock  ---
  gui_buttonlock('lock',handles.main_strns_fig,hObject);
  set(hObject,'Enable','inactive');
  af = OSP_DATA('GET','ACTIVE_FLAG');
  OSP_DATA('SET','ACTIVE_FLAG',bitset(af,2));

  % === Edit HB Data  ===
  try
    idx_chb=[1:length(header.TAGs.DataTag)];
    idx_chb(3)=[];   % Total Clean up
	
    [data DataTag]= ...
	OSP_DataEdit('Data',data(:,:,idx_chb), ...
		     'Tag', {'Time','Channel', 'Data-Kind'},...
		     'TagDim3', {header.TAGs.DataTag{idx_chb}},...
		     'EditNum',16); 
  catch
    OSP_LOG('err',lasterr);
  end
  % --- End Lock ---
  OSP_DATA('SET','ACTIVE_FLAG',af);
  gui_buttonlock('unlock',handles.main_strns_fig)
  unlock_local(handles);
  
  % == Remake Total ==
  if size(data,3) > 2
    data(:,:,4:end+1)=data(:,:,3:end);
    header.TAGs.DataTag{4:length(DataTag)+1} = ...
	DataTag{3:end}
  end
  data(:,:,3)=data(:,:,1)+data(:,:,2); % Make Total

  % == Save Data ==
  DataDef_SignalPreprocessor('save_ow',header,data,2,actdata);
return;

%% when unlock, re lock if grouping-Data exist
function unlock_local(handles)
% cbxFitting_Callback(handles.cbxFitting, [], handles);
% cbxMovingAverage_Callback(handles.cbxMovingAverage, [], handles);
% frqflt_valu_Callback(handles.frqflt_valu, [], handles);
return;


% --- Executes during object creation, after setting all properties.
function outvar_strns_lsb_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'FontName','FixedWidth');




function comment = setActiveData(fullpath)
% Set Active Data from Filename
% --- SetActiveData --
% And 

  % Clear Current Acitevke Data.
  comment=[];
  OSP_DATA('SET','ACTIVEDATA',[]);

  %Input Check
  if isempty(fullpath)
    comment='No File Selected';
    return;
  end
  % get filename
  [pathname, filename]=pathandfilename(fullpath);
  
  % Get File List Data
  file_list = DataDef_SignalPreprocessor('loadlist');
  if isempty(file_list)
    comment=' No Signal Preprocessor Data';
    return;
  end
  fnames = {file_list.filename};
  %[fnames{1:length(file_list)}] = deal(file_list.filename);

  rslt = find(strcmp(fnames, filename));
  if isempty(rslt)
    comment=' No Converted Data ';
    return;
  end

  if length(rslt)~=1
    error('File List is broken');
  end

  actdata.fcn = @DataDef_SignalPreprocessor;
  actdata.data = file_list(rslt(1));
  OSP_DATA('SET','ACTIVEDATA',actdata);

  %% if set view OSP
  mc = OSP_DATA('GET','MAIN_CONTROLLER');
  set(mc.handles.rdb_actdata,'Value',0);
  OSP('rdb_actdata_Callback',mc.handles.rdb_actdata,[],mc.handles);


function chk_anonymity_Callback(hObject, eventdata, handles)
% Set Anonymity
  v = get(hObject,'Value');
  OSP_DATA('SET','SP_ANONYMITY',logical(v));



function chk_Rename_Callback(hObject, eventdata, handles)
% Renane Option
%  Use/ not use
set(handles.edit_Rename,'Visible','off');
if get(hObject,'Value'),
    str={'InputName', ...
            'OriginalName', ...
            'Date', ...
            'DataLength', ...
            'ID'};
    v = get(handles.pop_Rename,'UserData');
    if isempty(v), v=1; end
    OSP_DATA('SET','SP_Rename',str{v});
    set(handles.pop_Rename, ...
        'Value', v, ...
        'String', str, ...
        'Enable','on');
    if v==1,
        edit_Rename_Callback(handles.edit_Rename,[],handles);
    end
else
    OSP_DATA('SET','SP_Rename','-');
    set(handles.pop_Rename,...
        'Value', 1, ...
        'String',{'-'}, ...
        'Enable','off');
end

function edit_Rename_CreateFcn(hObject, eventdata, handles)
% Set Default String of Input --- Rename --
set(hObject,'String',date)

function edit_Rename_Callback(hObject, eventdata, handles)
% Set Input-Name
set(hObject,'Visible','on');
% My Input Name
in0.str=get(hObject,'String');
in0.id =0;
OSP_DATA('SET','SP_Rename_IN',in0);


function pop_Rename_Callback(hObject, eventdata, handles)
set(hObject,'UserData',get(hObject,'Value'));
chk_Rename_Callback(handles.chk_Rename, [], handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Signal Preprocessor 
%    Execute Functions
%    22-Dec-2005
%    since r1.16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - - - - - - - - -
% Create Functions
%  == Reset Mode ==
% - - - - - - - - -

function pop_OpenMode_CreateFcn(hObject, eventdata, handles)
% Execute during Opne-Mode-Popupmenu Creation, 
%    after setting all properties in figure.
%
% Open File Mode is Mode used in
%    file_select_psb_Callback
% Now we have only one-mode. 
%
% See also : file_select_psb_Callback
% Date : 22-Dec-2005
  set(hObject,'String',{'1'});

function pop_PreproFunction_CreateFcn(hObject, eventdata, handles)
% Start with Opne File Mode 1.
% Date : 22-Dec-2005
  pop_PreproFunction_Callback(hObject, [], handles,1);

function lbx_PreproFunction_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% And Call from pop_OpenMode_Callback, when refresh Data.
% See also : pop_OpenMode_Callback
% Date : 22-Dec-2005
  set(hObject,...
	  'Value',1, ...
      'String',{'----'}, ...
      'UserData',[]);
  if ~isempty(handles) && isstruct(handles) && ...
		  isfield(handles,'lbx_InfoPreproFunction') && ...
		  ishandle(handles.lbx_InfoPreproFunction)
	  set(handles.lbx_InfoPreproFunction,'String',{'--- No Function Selected ---'});
  end
function lbx_InfoPreproFunction_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% And Call from pop_OpenMode_Callback, when refresh Data.
% See also : pop_OpenMode_Callback
% Date : 22-Dec-2005
  set(hObject,'Value',1,'String',{'--- No Function Selected ---'});

% - - - - - - - - -
% Mode Selected
% - - - - - - - - -
function pop_OpenMode_Callback(hObject, eventdata, handles)
% Execute when OpenMode is changed.
% Change Open Mode : Refresh
% Date : 22-Dec-2005
  vl = get(hObject,'Value');
  % Change Mode ( Function List )
  pop_PreproFunction_Callback(handles.pop_PreproFunction, [], handles,vl);
  % Reset List Box : 10-Jan-2006 Change
  chk_AutoPreproFunction_Callback(handles.chk_AutoPreproFunction,[],handles);
return;

function chk_AutoPreproFunction_Callback(hObject, eventdata, handles)
% Execute when check-box : Auto preprocessor-Function OpenMode is clicked.
%  or OpenMode is call back
% Change Open Mode : Refresh
% Date : 10-Jan-2006
  lbx_PreproFunction_CreateFcn(handles.lbx_PreproFunction,...
	  [], handles);
  lbx_InfoPreproFunction_CreateFcn(handles.lbx_InfoPreproFunction,...
	  [], handles);
  v =get(hObject,'Value');
  h2= handles.pop_PreproFunction;
  if v==1,
	  % get Defalut-Value.
	  id =get(h2,'Value');
	  % Get Function List
	  fnc=get(h2,'UserData');

	  % Set All Function Available..
	  for idx=1:length(fnc),
		  try,
			  set(h2,'Value',idx);
			  pop_PreproFunction_Callback(h2,[],handles);
		  end
	  end
	  set(h2,'Visible','off','Value',id);
	  set(handles.lbx_PreproFunction,'Value',1);
	  % Set InfoPreproFunction
	  lbx_PreproFunction_Callback(handles.lbx_PreproFunction, [], ...
				     handles);
  else,
	  set(h2,'Visible','on');
  end

function lbx_PreproFunction_Callback(hObject, eventdata, handles)
% Execute When Selected Prepro-Execution-Function Change.
  id =get(hObject,'Value');
  fnc=get(hObject,'UserData');
  if length(fnc)<id,
    return;
  end
  try,
    str = feval(fnc{id},'getFunctionInfo');
    set(handles.lbx_InfoPreproFunction,...
	'Value', 1, ...
	'String',str);
  catch,
    set(handles.lbx_InfoPreproFunction,...
	'Value', 1, ...
	'String',...
	{'Error Occur : ', ...
	 '  No Information Exist.', ...
	 ['  ' lasterr]});
  end
  

function lbx_InfoPreproFunction_Callback(hObject, eventdata, handles)
% ... Sorry : Do nothing now::--> remove Callback from .fig
% Date : 22-Dec-2005


function pop_PreproFunction_Callback(hObject, eventdata, handles, id)
% Execute When Popupmenu-PreproFunction Change.
%              Create-Function, Mode..
if nargin==4,
  ospPath=OSP_DATA('GET','OSPPATH');
  path0 = pwd;
  %path1 = [ospPath filesep '..' filesep 'preprocessor' filesep];
  [pp ff] = fileparts(ospPath);
  if( strcmp(ff,'WinP3')~=0 )
    path1 = [ospPath filesep '..' filesep 'preprocessor' filesep];
  else
    path1 = [ospPath filesep 'preprocessor' filesep];
  end
  fnc   = {};
  str   = {};
  try
    cd(path1);
    % --- Search Files ---
    % Old-Code : Replase find_file at 2006.10.3
    files=find_file('^prepro\w+.[mp]$', path1,'-i');
    % d1=dir('prepro*.m');
    % d2=dir('prepro*.p');
    % d=[d1;d2];

    for idx=1:length(files),
      [p,f,e]=fileparts(files{idx});
      try,
	cd(p);
	fnc0 = eval(['@' f]);
	bi   = feval(fnc0,'createBasicInfo');
	if (id==bi.OpenKind),
	  if isempty(find(strcmp(str, bi.DispName))),
	    str{end+1}=bi.DispName;
	    fnc{end+1}=fnc0;
	  end
	end
      catch,
	errordlg({'OSP Error!!', ...
		  ['Function : ' f], ...
		  '    createBasicInfo Error', ...
		  ['    ' lasterr]});
      end
    end
  catch,
    errordlg({'OSP Error!!',lasterr});
  end
  cd(path0); 
  if isempty(str),
    str = {'-- No Function Exist --'};
  end
  set(hObject,...
      'Value',1, ...
      'String', str, ...
      'UserData',fnc);
else,
  vl  = get(hObject,'Value');
  str = get(hObject,'String');
  fnc = get(hObject,'UserData');
  str = str{vl};
  fnc = fnc{vl};
  str2 = get(handles.lbx_PreproFunction,'String');
  fnc2 = get(handles.lbx_PreproFunction,'UserData');
  if isempty(fnc2),
    vl2=1;
    str2={str};
    fnc2={fnc};
  else,
    if isempty(find(strcmp(str2, str))),
      str2{end+1}=str;
      fnc2{end+1}=fnc;
    end
    vl2 = length(str2);
  end
  set(handles.lbx_PreproFunction,...
       'Value', vl2, ...
       'String', str2, ...
       'UserData', fnc2);
  lbx_PreproFunction_Callback(handles.lbx_PreproFunction,...
			      [], handles)
end


function psb_delPreproFunction_Callback(hObject, eventdata, handles)
% Delete Preprocessor Function From list

% Handle of Function List-Box
h_fl = handles.lbx_PreproFunction;
id =get(h_fl,'Value');
fnc=get(h_fl,'UserData');
str=get(h_fl,'String');
if length(fnc)<id,
	return;
end

% Remove Selecting Function from the List.
fnc(id)=[];
str(id)=[];
if isempty(fnc),
	% Show -> Empty 
	lbx_PreproFunction_CreateFcn(h_fl,[],handles);
else
	% ID Check.. not to select overfllow data.
	if (id>length(fnc)), id = length(fnc); end
	% Update Function-List
	set(h_fl,'Value',id,'UserData',fnc, 'String',str);
	% Change Information of selecting function
	lbx_PreproFunction_Callback(h_fl,[],handles);
end




