function varargout = uiPOTAToProject(varargin)
% UIPOTATOPROJECT M-file for uiPotatoProject.fig
%      UIPOTATOPROJECT, by itself, creates a new UIPOTATOPROJECT or raises the existing
%      singleton*.
%
%      H = UIPOTATOPROJECT returns the handle to a new UIPOTATOPROJECT or the handle to
%      the existing singleton*.
%
%      UIPOTATOPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIPOTATOPROJECT.M with the given input arguments.
%
%      UIPOTATOPROJECT('Property','Value',...) creates a new UIPOTATOPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uiPotatoProject_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uiPotatoProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uiPotatoProject


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%##########################################################################
% Begin initialization code 
%##########################################################################
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @uiPotatoProject_OpeningFcn, ...
  'gui_OutputFcn',  @uiPotatoProject_OutputFcn, ...
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
%##########################################################################
% End initialization code
%##########################################################################

%##########################################################################
% Open/Close Control
%##########################################################################
function uiPotatoProject_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% Open and Setup --> wait for responce
handles.output = hObject;
guidata(hObject, handles);

%-------------
% Get Arguent
%-------------
%  :: Action :: 
for ii=1:2:length(varargin)-1
  prop=varargin{ii};
  value=varargin{ii+1};
  switch prop
    case 'Action'
      act=get(handles.pop_action,'String');
      val = strmatch(value,act);
      if ~isempty(val)
        set(handles.pop_action,'Value',val(1));
      end
  end
end
% 
pop_action_Callback(handles.pop_action, [], handles);

msg=getappdata(handles.figure1,'ErrorMessage');
if msg,
  errordlg(msg,'Project Open Error');
else
  set(handles.figure1,'WindowStyle','modal')
  uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = uiPotatoProject_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% Opening
if ~isempty(handles),
  varargout{1} = handles.output;
  delete(hObject);
end


function edit_name_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>

% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
set(hObject,'BackgroundColor','white');
eflag=false;
try
  p=OSP_DATA('GET','PROJECTPARENT');
  if isempty(p), eflag=true;end
catch
  eflag=true;
end
if eflag
  setappdata(gcbf,'ErrorMessage',...
    'No-Project Data Path : Select Project Directory from Edit-Menu at first!');
else
  setappdata(gcbf,'ErrorMessage','');
end



function edit_path_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


% --- Executes on button press in psb_brows.
function psb_brows_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
dirname=get(handles.edit_path,'String');
if ~isempty(dirname) && iscell(dirname)
  dirname=dirname{1};
end
if ~isempty(dirname) && exist(dirname,'dir')
  dirname = uigetdir(dirname);
else
  dirname = uigetdir;
end
if ischar(dirname)
  set(handles.edit_path,'String',dirname);
end

function edit_ope_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function edit_date_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>


function pop_action_Callback(hObject, eventdata, handles) %#ok<INUSL>
% ==== Action Mode Setting ===
contents=get(handles.pop_action, 'String');
idx     =get(handles.pop_action, 'Value');

% == Action Button String ==
set(handles.psb_action,...
  'String',contents{idx},...
  'enable','off');

% == Control Enable ==
h=[handles.edit_name, ...
  handles.edit_path,...
  handles.edit_ope,...
  handles.edit_coment,...
  handles.psb_brows];

switch contents{idx},
  case {'New', 'Edit','Import'}
    set(h,'enable','on');
  otherwise
    set(h,'enable','inactive');
end

% == Name list reload ==
set(handles.pop_namelist,...
  'Visible','off');

switch contents{idx},
  case 'New',
    set(handles.edit_date,  'String',datestr(now));

  case 'Import',
    set(handles.edit_date,  'String',datestr(now));
    [f, p] = uigetfile('*.zip', 'Load Import Data');
    if isequal(f,0) || isequal(p,0),
      setappdata(handles.figure1,'ImportFileData',[]);
      return;
    else
      improt_filedata.fname = f;
      improt_filedata.path  = p;
      setappdata(handles.figure1,'ImportFileData',improt_filedata);
    end
    f=strrep(f,'.zip','');
    set(handles.edit_name,  'String',f);
    set(handles.edit_coment,'String','Import Project');

  otherwise,
    Project=POTAToProject('LoadData');
    if isempty(Project)
      errordlg([' No Project Data. ' ...
        ' Make ''New'' Project at First!']);
      % in opening :: close...
      setappdata(gcbf,'ErrorMessage',...
        ''' Make ''New'' Project at First!');
      return;
    end
    Names = {Project.Name};
    cpj = OSP_DATA('GET','PROJECT');
    if ~isempty(cpj)
      try
        id= strmatch(cpj.Name,Names,'exact');
        if isempty(id),
          id=1;
        else
          id=id(1);
        end
      catch
        id=1;
      end
    else
      id=get(handles.pop_namelist,'Value');
    end
    if (id>length(Names))
      id=length(Names);
    end
    set(handles.pop_namelist,...
      'Value', id, ...
      'String',Names,...
      'Visible','on');
    pop_namelist_Callback(...
      handles.pop_namelist,[],...
      handles);
end

set(handles.psb_action,'enable','on');


% Remove SubjectName
if strcmp(contents{idx},'Export'),
  %set(handles.ckb_remove_subname,'Visible','on','Value',1);
  set(handles.ckb_remove_subname,'Visible','off','Value',0);
else
  set(handles.ckb_remove_subname,'Visible','off','Value',0);
end
return;
% --- Executes on selection change in pop_namelist.
function pop_namelist_Callback(hObject, eventdata, handles) %#ok<INUSL>
Project=POTAToProject('LoadData');
idx=get(hObject,'Value');
if idx>length(Project), idx=length(Project);end
setProjectData(Project(idx),handles);



% --- Executes on button press in psb_action.
function psb_action_Callback(hObject, eventdata, handles) %#ok<DEFNU>
action=get(hObject,'String');

switch action
  % =============
  case 'New'
    % =============
    pj=getProjectData; % Get Project Data from GUI
    if isempty(pj)
      return;
    end

    % Set
    try
      pj = POTAToProject('Add', pj);
    catch
      errordlg({'Make Project Error',lasterr});
    end
    if isempty(pj)
      return;
    end

    % =============
  case 'Open'
    % =============
    POTAToProject('Select',...
      get(handles.pop_namelist,'Value'));

    % =============
  case 'Remove'
    % =============
    POTAToProject('Remove',...
      get(handles.pop_namelist,'Value'));
    contents=get(handles.pop_namelist,'String');
    if length(contents) >= 2
      pop_action_Callback(handles.pop_action,[],handles);
      return;
    end


    % =============
  case 'Edit'
    % =============
    pj=getProjectData; % Get Project Data from GUI
    if isempty(pj)
      return;
    end

    % Set
    pj = POTAToProject('Replace', ...
      get(handles.pop_namelist,'Value'), pj);
    if isempty(pj)
      return;
    end

    % =============
  case 'Export'
    % =============
    pj=getProjectData; % Get Project Data from GUI
    if isempty(pj)
      return;
    end

    % -- File name Get --
    [f p] = osp_uiputfile('*.zip', ...
      'File name for exported project', ...
      ['Project' pj.Name datestr(now,30)]);
    if (isequal(f,0) || isequal(p,0)), return; end
    filename = [p filesep f];

    POTAToProject('Export', ...
      get(handles.pop_namelist,'Value'), filename, ...
      get(handles.ckb_remove_subname,'Value'));

    % =============
  case 'Import'
    % =============
    pj=getProjectData; % Get Project Data from GUI
    if isempty(pj)
      return;
    end

    % Data Expand:
    import_filedata=getappdata(handles.figure1, ...
      'ImportFileData');
    if isempty(import_filedata),
      errordlg(sprintf(['P3 Error!!!\n' ...
        '<<  No improt Data exist >>\n']));
      % reload
      pop_action_Callback(handles.pop_action, [], handles);

      import_filedata=getappdata(handles.figure1, ...
        'ImportFileData');
      % cancel?
      if isempty(import_filedata),
        figure1_CloseRequestFcn(handles.figure1,...
          eventdata, handles);
        return;
      end
    end

    % Set
    pj = POTAToProject('Add', pj);
    if isempty(pj)
      return;
    end
  
    uiP3ProjectImport('Project',pj,'ImportFile',import_filedata);
    % POTAToProject('Import', pj, import_filedata.fname,import_filedata.path);


    % =============
  otherwise
    % =============
    OSP_LOG('perr',[ mfilename ...
      ' : Error Action  Button Name']);
    error('Undefined Action Button Name');

end

% Close
figure1_CloseRequestFcn(handles.figure1,[], handles);
return;


function pj=getProjectData(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Project Data From GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
  handles = guihandles(gcbo);
end
pj.Ver  = 2.0;
pj.Name = get(handles.edit_name,'String');
if iscell(pj.Name)
  pj.Name=pj.Name{1};
end
pj.Path = get(handles.edit_path,'String');
if iscell(pj.Path)
  pj.Path=pj.Path{1};
end

%------------------------------
% Get Project-Parent(path)
% and Set project.Path
if isempty(pj.Path) || strcmp(pj.Path, 'Edit Text'),
  pp = OSP_DATA('GET','PROJECTPARENT');
  if isempty(pp),
    a=questdlg({'There is no Project-Parent Directory Named', ...
      'Do you want to Make Directory?'}, ...
      'Make Directory?', ...
      'Yes', 'No','Yes');
    if isempty(a) || ~strcmp(a,'Yes'),
      pj=[]; return;
    end
    [f1,pp] =uigetfiles;
    if (pp==0),pj=[];return;end
    % make Parent Directory %
    [pl1, pl2]=fileparts(pp);
    [success0, msg]=mkdir(pl1,pl2);
    if ~success0,
      errordlg(msg);
      pj=[]; return;
    end
    OSP_DATA('SET','PROJECTPARENT', pp);
  end
  pj.Path=pp;
end
%------------------------------

if ~exist(pj.Path,'dir')
  [pl1, pl2]=fileparts(pj.Path);
  if ~exist(pl1,'dir') || exist(pj.Path,'file'),
    errordlg(['Path must be a directory.' ...
      ' No path ' pj.Path ...
      'exist']);
    try
      set(handles.edit_path,'ForegroundColor',[1 0 0]);
    catch
    end
    pj=[];
    return;
  end
  a=questdlg({['There is no Directory Named ' pl2], ...
    'Do you want to Make Directory?'}, ...
    'Make Directory?', ...
    'Yes', 'No','Yes');
  if isempty(a) || ~strcmp(a,'Yes'),
    pj=[]; return;
  end
  % make Directory
  [success0, msg]=mkdir(pl1,pl2);
  if ~success0,
    errordlg(msg);
    pj=[]; return;
  end
end

pj.CreateDate=now;
pj.Operator = get(handles.edit_ope,'String');
if iscell(pj.Operator)
  pj.Operator=pj.Operator{1};
end

pj.Comment  = get(handles.edit_coment,'String');
return;

function pj=setProjectData(pj, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Project Data From GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <= 1
  handles = guihandles(gcbo);
end
set(handles.edit_name,  'String',pj.Name);
set(handles.edit_path,  'String',pj.Path);
set(handles.edit_date,  'String',datestr(pj.CreateDate));
set(handles.edit_ope,   'String',pj.Operator);
set(handles.edit_coment,'String',pj.Comment);
return;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_coment.
function edit_coment_ButtonDownFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

return;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL>
% Hint: delete(hObject) closes the figure
try
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    uiresume(handles.figure1);
  else
    delete(handles.figure1);
  end
catch
  delete(hObject);
end

% --- Executes on button press in psb_close.
function psb_close_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
figure1_CloseRequestFcn(handles.figure1,...
  eventdata, handles);
return;


