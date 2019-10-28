function varargout = uiOspProject(varargin)
% UIOSPPROJECT M-file for uiOspProject.fig
%      UIOSPPROJECT, by itself, creates a new UIOSPPROJECT or raises the existing
%      singleton*.
%
%      H = UIOSPPROJECT returns the handle to a new UIOSPPROJECT or the handle to
%      the existing singleton*.
%
%      UIOSPPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIOSPPROJECT.M with the given input arguments.
%
%      UIOSPPROJECT('Property','Value',...) creates a new UIOSPPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uiOspProject_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uiOspProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Edit the above text to modify the response to help uiOspProject

% Last Modified by GUIDE v2.5 25-Jul-2005 18:51:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiOspProject_OpeningFcn, ...
                   'gui_OutputFcn',  @uiOspProject_OutputFcn, ...
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


% --- Executes just before uiOspProject is made visible.
function uiOspProject_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for uiOspProject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

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


% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = uiOspProject_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit_name_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

function edit_name_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');


function edit_path_Callback(hObject, eventdata, handles)


% --- Executes on button press in psb_brows.
function psb_brows_Callback(hObject, eventdata, handles)
dirname=get(handles.edit_path,'String');
if ~isempty(dirname) && iscell(dirname)
    dirname=dirname{1};
end
if ~isempty(dirname) && exist(dirname,'dir')
    dirname = uigetdir(dirname);
else
    dirname = uigetdir;
end
if isstr(dirname)
    set(handles.edit_path,'String',dirname);
end


% --- Executes during object creation, after setting all properties.
function edit_ope_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');


function edit_ope_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_date_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');


function edit_date_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_coment_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

% --- Executes during object creation, after setting all properties.
function pop_action_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');


function pop_action_Callback(hObject, eventdata, handles)
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
  [f, p] = uigetfile('*.osp_prj', 'Load Import Data');
  if isequal(f,0) || isequal(p,0),
    setappdata(handles.figure1,'ImportFileData',[]);
  else,
    improt_filedata.fname = f;
    improt_filedata.path  = p;
    setappdata(handles.figure1,'ImportFileData',improt_filedata);
  end

 otherwise,
  Project=OspProject('LoadData');
  if isempty(Project)
    errordlg([' No Project Data. ' ...
	      ' Make ''New'' Project at First!']);  
    return;
  end
  if length(Project)~=1
    Names=cell(length(Project),1);
    for id = 1:length(Project)
      Names{id} = Project(id).Name;
    end 
  else
    Names=Project.Name;
  end
  id=get(handles.pop_namelist,'Value');
  if (id>length(Names)) id=length(Names); end
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
   set(handles.ckb_remove_subname,'Visible','on','Value',1);
 else,
   set(handles.ckb_remove_subname,'Visible','off');
 end
return;

% --- Executes during object creation, after setting all properties.
function pop_namelist_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

% --- Executes on selection change in pop_namelist.
function pop_namelist_Callback(hObject, eventdata, handles)
Project=OspProject('LoadData');
idx=get(hObject,'Value');
if idx>length(Project), idx=length(Project);end
setProjectData(Project(idx),handles);



% --- Executes on button press in psb_action.
function psb_action_Callback(hObject, eventdata, handles)
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
        pj = OspProject('Add', pj);
        if isempty(pj)
            return;
        end
        
    % =============
    case 'Open'
    % =============
        OspProject('Select',...
            get(handles.pop_namelist,'Value'));

    % =============
    case 'Remove'
    % =============
        OspProject('Remove',...
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
        pj = OspProject('Replace', ...
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
	[f p] = osp_uiputfile('*.osp_prj', ...
			      'Save Block Data', ...
			      ['Project' pj.Name datestr(now,30)]);
	if (isequal(f,0) || isequal(p,0)), return; end
	filename = [p filesep f];
        
        OspProject('Export', ...
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
	  errordlg(sprintf(['OSP Error!!!\n' ...
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
        pj = OspProject('Add', pj);
        if isempty(pj)
	  return;
        end

        OspProject('Import', pj, ...
		   import_filedata.fname, ...
		   import_filedata.path);
		   

    % =============        
    otherwise
    % =============
        OSP_LOG('perr',[ mfilename ...
                ' : Error Action  Button Name']);
        error('Undefined Action Button Name');

end

% Close 
figure1_CloseRequestFcn(handles.figure1,...
    eventdata, handles);
return;


function pj=getProjectData(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Project Data From GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    handles = guihandles(gcbo);
end

pj.Name = get(handles.edit_name,'String');
if iscell(pj.Name)
    pj.Name=pj.Name{1};
end

pj.Path = get(handles.edit_path,'String');
if iscell(pj.Path)
    pj.Path=pj.Path{1};
end
if ~exist(pj.Path,'dir')
  [pl1, pl2]=fileparts(pj.Path);
  if ~exist(pl1,'dir') || exist(pj.Path,'file'),
    errordlg(['Path must be a directory.' ...
	      ' No path ' pj.Path ...
	      'exist']);
    try,
      set(handles.edit_path,'ForegroundColor',[1 0 0]);
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
function edit_coment_ButtonDownFcn(hObject, eventdata, handles)

return;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in psb_close.
function psb_close_Callback(hObject, eventdata, handles)
figure1_CloseRequestFcn(handles.figure1,...
    eventdata, handles);
return;


