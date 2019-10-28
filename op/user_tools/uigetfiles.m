function varargout = uigetfiles(varargin)
% UIGETFILES M-file for uigetfiles.fig
%      UIGETFILES, by itself, creates a new UIGETFILES or raises the existing
%      singleton*.
%
% varargout 1:  filenames -> Selected Filenames
%           2:  pathname  -> Selected Pathname
%           3:  selected type
%
%      UIGETFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIGETFILES.M with the given input arguments.
%
%      UIGETFILES(FILTERSPEC, TITLE)
%       creates a new UIGETFILES or raises the
%       existing singleton*.
%       FILTERSPEC must be cell
%         if filterspec is 1 dimen
%       otherwise, FILTERSPEC is as same as UIGETFILE's one.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES, UIGETFILE

% Edit the above text to modify the response to help uigetfiles

% Last Modified by GUIDE v2.5 18-Mar-2005 20:05:25

% Begin initialization code - DO NOT EDIT

% == History ==
% original author : Masanori Shoji
% create : 2005.03.18
% $Id: uigetfiles.m 180 2011-05-19 09:34:28Z Katura $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @uigetfiles_OpeningFcn, ...
  'gui_OutputFcn',  @uigetfiles_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     GUI Function                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function uigetfiles_OpeningFcn(hObject, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening Function            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.output = hObject; % Now We donnot use handles.out
setappdata(handles.figure1, 'StartDir', pwd);
setappdata(handles.figure1, 'FileNames',  0);
setappdata(handles.figure1, 'PathName',   0);

% Update handles structure
guidata(hObject, handles);

% ---------------
% Argument Check
% ---------------

% == Set FilterSpec ==
if nargin>=4
  filterspec = varargin{1};
  if ischar(filterspec)
    filterspec={filterspec};
  end

  % make Data
  file_filter_str={}; file_filter={};
  if size(filterspec,2)==2
    for id= 1:size(filterspec,1)
      file_filter{id}     = filterspec{id,1};
      file_filter_str{id} = filterspec{id,2};
    end
  else
    for id= 1:size(filterspec,1)
      file_filter{id}     = filterspec{id};
      file_filter_str{id} = filterspec{id};
    end
  end

  % Seting
  file_filter_str{end+1} = 'All Files';
  set(handles.pop_filetype, 'String', file_filter_str);
  set(handles.pop_filetype, 'UserData', file_filter);
end

% == Set Name of Figure ==
if nargin>=5
  try
    set(handles.figure1,'Name', varargin{2});
  catch
    set(handles.figure1,'Name', 'Name Setting Error: UiGetFiles');
  end
end

edit_path_Callback(handles.edit_path, [], handles);

% UIWAIT makes uigetfiles wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);
return;

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close function with uiresume
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close with UIRESUME
% See also UIRESUME.
try
  setappdata(handles.figure1, 'FileNames',  0);
  setappdata(handles.figure1, 'PathName',   0);
  stdir = getappdata(handles.figure1, 'StartDir');
  cd(stdir);
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    uiresume(handles.figure1);
  else
    delete(handles.figure1);
  end
catch
  delete(handles.figure1);
end
return;

function varargout = uigetfiles_OutputFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Outputs variable of the GUI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varargout 1:  filenames -> Selected Filenames
%           2:  pathname  -> Selected Pathname

try
  filenames = getappdata(handles.figure1, 'FileNames');
catch
  filename= 0;
end
try
  pathname  = getappdata(handles.figure1, 'PathName');
catch
  pathname  = 0;
end

varargout{1} = filenames;
if nargout>=2
  varargout{2} = pathname;
end
if nargout>=3
  try
    varargout{3} = get(handles.pop_filetype,'Value');
  catch
    varargout{3} = 0;
  end
end
delete(handles.figure1);
return;

function psb_open_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Result Getting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenames = get(handles.lbx_files, 'String');
id        = get(handles.lbx_files, 'Value');
flag      = get(handles.lbx_files, 'UserData');
if isempty(flag) || isempty(id),
  if isempty(id),warning('No Data Selected');end
  setappdata(handles.figure1, 'FileNames',  0);
else
  if isempty(filenames),
    % When GUI-calculation-speed is slower than manual setting,
    % this event is occur.
    %  In the case, open-push-button event is ignore.
    return;
  else
    %[filenames2{1:length(id)}] = deal(filenames{id});
    % Function, deal, is too bad.
    %   When we treat long cell-array, deal is not available.
    %   May be Limit number of varargout, varargin exist
    %     in Matlab R13.
    filenames2 = { filenames{id} };
  end
  setappdata(handles.figure1, 'FileNames',  filenames2);
  clear filenames;
end

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end

return;

function psb_cancel_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cancel : Put 0, 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setappdata(handles.figure1, 'FileNames',  0);
setappdata(handles.figure1, 'PathName',   0);
% figure1_CloseRequestFcn(handles.figure1, [], handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Path Seting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_browsdir_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brows, Change Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directory Setting
pathname = get(handles.edit_path,'String');
try, cd(pathname); end
pathname = uigetdir;

% Cancel
if pathname==0, return; end
% select error?
if ~exist(pathname,'dir'),
  errordlg(['No such a Directory : ' ...
    pathname], ...
    'Not a Directory');
  return;
end

% Set Data
set(handles.edit_path,'String',pathname);
edit_path_Callback(handles.edit_path,[], handles);

return;


function edit_path_CreateFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize Pathname
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now set pathname PWD (Present working directory)
set(hObject,'String',pwd);
return;

function edit_path_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathname = get(hObject,'String');
cd(pathname);

% Check Change
pathname0 = getappdata(handles.figure1, 'PathName');
if strcmp(pathname0, pathname)
  return;
end

if ~exist(pathname,'dir'),
  errordlg('No such a Directory','Not a Directory');
  set(hObject, 'String', pathname0);
  return;
end

% reset path
setappdata(handles.figure1, 'PathName', pathname);

% Change Directory Listbox
dirnames = dir(pathname);
dirnames([dirnames.isdir]==0) = [];
dirnames_name={dirnames.name};
set(handles.lbx_dir, 'Value',1, 'String', dirnames_name);

% Change File Listbox
pop_filetype_Callback(handles.pop_filetype, [], handles)
return;

function lbx_dir_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Directory by Selecting Directory List box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dirnames = get(handles.lbx_dir, 'String');
id       = get(handles.lbx_dir, 'Value');
if (id>length(dirnames)),id=1;end
dirname  = dirnames{id}; clear dirnames id;

% change default dir
pathname = getappdata(handles.figure1, 'PathName');
cd(pathname);

% is dir ?
if isdir(dirname)==0,
  errordlg([' Selected element (' ...
    dirname ...
    ') is not a directory'], ...
    'Not a Directory');
  return;
end

% Change dir
try
  cd(dirname);
catch
  error(['cd(''' dirname ''') :' lasterr]);
end
set(handles.edit_path,'String',pwd);
edit_path_Callback(handles.edit_path,[], handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  File Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lbx_files_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now Do nothing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pop_filetype_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset File Listbox, and Filter File-Filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_filter = get(hObject,'UserData');
id          = get(hObject,'Value');

pathname = getappdata(handles.figure1, 'PathName');
cd(pathname);

if length(file_filter) >= id
  filterspec=file_filter{id};
  filterspec = strrep(filterspec,' ', '');

  while ~isempty(filterspec)
    pos = strfind(filterspec,';');
    if isempty(pos)
      tmpfs = filterspec;
      filterspec=[];
    else
      if pos==1
        filterspec(1)=[];
        continue;
      end
      tmpfs = filterspec(1:pos-1);
      filterspec(1:pos)=[];
    end

    tmpnames = dir_ic(tmpfs);
    if exist('names','var') && ~isempty(names),
      names = [names; tmpnames];
    else
      names = tmpnames;
    end
  end

else
  % All files
  names = dir(pathname);
  names([names.isdir])=[];
end


% Setting Name & User Data : Select/notSelect flag
if ~exist('names','var') || isempty(names)
  set(handles.lbx_files, ...
    'Value',        1, ...
    'String',   {' -- No match Files --'}, ...
    'UserData', []);
else
  names_tmp=unique({names.name});
  set(handles.lbx_files, ...
    'Value',        [], ...
    'String',   names_tmp, ...
    'UserData',1);
end
return;

function edit2_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now Visible off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = dir_ic(filt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dir ignore case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ignore case
d = dir;
d([d.isdir])=[];
names = {d.name};

% start check
filt=strrep(filt,'*','[\D\d]*');
filt=[filt '$'];
s=regexpi(names,filt);
if isempty(s)
  d=struct([]); return;
end
if iscell(s)
  ck = cellfun('isempty',s);
  if ~isempty(ck)
    d(ck)=[];
  end
end

return;
