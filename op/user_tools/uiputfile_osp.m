function varargout = uiputfile_osp(varargin)
% UIPUTFILE for OSP (local change.)
%      UIPUTFILE_OSP, by itself, creates a new UIPUTFILE_OSP or raises the existing
%      singleton*.
%
% Syntax :
% [FILENAME, PATHNAME, FILTERINDEX] =
%        UIPUTTFILE_OSP(FILTERSPEC, TITLE, FILE)
%
% is as same as uiputfile.
%
% Syntax :
% [FILENAME, PATHNAME, FILTERINDEX] =
%        UIPUTTFILE_OSP(FILTERSPEC, TITLE, FILE,'FixedDirectory', dir)
%   Directory : Can not Chnage.
%
% Syntax :
% [FILENAME, PATHNAME, FILTERINDEX] =
%        UIPUTTFILE_OSP(FILTERSPEC, TITLE, FILE,'TopLevelDirectory', dir)
%   Set TopLevel Directory :
%        Can-not move upper directory.
%
% Syntax :
% [FILENAME, PATHNAME, FILTERINDEX] =
%        UIPUTTFILE_OSP(FILTERSPEC, TITLE, FILE, ...
%                       'TopLevelDirectory', dir, ...
%                       'MAXIMUMDEPTH', maxdepth);
%   Set TopLevel Directory :
%        Can-not move upper directory.
%   And There is maxdepth from Top-Level-Directory;
%
% See also: GUIDE, GUIDATA, GUIHANDLES, UIPUTFILE

% Edit the above text to modify the response to help uiputfile_osp

% Last Modified by GUIDE v2.5 29-Nov-2005 11:17:46

% Begin initialization code - DO NOT EDIT

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.03.18
% $Id: uiputfile_osp.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.4 : Add Top-Level-Direcotry
% Revision 1.5 : Blush-up
%                Modify TopLevelDirectory-Definition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Laounch GUI                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @uiputfile_osp_OpeningFcn, ...
  'gui_OutputFcn',  @uiputfile_osp_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     GUI Function                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiputfile_osp_OpeningFcn(hObject, eventdata, handles, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening Function            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.output = hObject; % Now We donnot use handles.out
setappdata(handles.figure1, 'StartDir', pwd);
setappdata(handles.figure1, 'FileNames',  0);
setappdata(handles.figure1, 'PathName', pwd);

% For TopLevel Directory
setappdata(handles.figure1,'TopLevelDirectory','');
setappdata(handles.figure1, 'MaxDepth',     []);

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
  if isempty(file_filter_str),
    file_filter_str{end+1} = 'All Files';
  end
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

% == Default Name ==
if nargin>=6
  try
    set(handles.edit_filename,'String', varargin{3});
  catch
    set(handles.edit_filename,'String', 'Untitled');
  end
end

% == Other Option ==
maxdepth=[];
fflag=false;tflag=false;

for id=5:2:length(varargin),
  try
    optname=varargin{id-1};
    switch upper(optname),
      case 'FIXEDDIRECTORY',
        if fflag,
          warning('Double Defined : Fixed Derictory');
        end
        fflag=true;
        if exist(varargin{id},'dir'),
          set(handles.psb_browsdir,'Visible','off');
          set(handles.edit_path, ...
            'String',varargin{id}, ...
            'Enable', 'inactive');
          set(handles.lbx_dir,'Enable','inactive');
          msg=localChangeDirectory(handles,pathname);
          if ~isempty(msg), errordlg(msg);end
        else
          warning('Fixed Direcotry Error: No such a directory');
        end

      case 'TOPLEVELDIRECTORY',
        % -- Disable Change Directory --
        if tflag,
          warning('Double Defined : Fixed Directory');
        end
        tflag=true;
        if ~ischar(varargin{id}),
          warning('Top-Level Direcotry must be charactor.');
        else
          switch varargin{id}
            case {'on','On','ON'}
              tld = pwd; if strcmp(tld(end),filesep), tld(end)=[];end
              setappdata(handles.figure1,'TopLevelDirectory',tld);
            case {'NO','No','no'}
              % Do nothing
            otherwise
              if isdir(varargin{id})
                tld = varargin{id};
                if strcmp(tld(end),filesep), tld(end)=[];end
                setappdata(handles.figure1,'TopLevelDirectory',tld);
              end
          end
        end

      case 'MAXIMUMDEPTH',
        % Maximum depth :: from top level
        if ~isnumeric(varargin{id}),
          warning('Maximum Depth must be natural number');
          continue;
        end
        if length(varargin{id})~=1,
          warning('Too many Maximum Depth');
          continue;
        end

        if varargin{id}<1
          warning('Max Depth must be natural number');
          continue;
        end
        if ~isempty(maxdepth)
          warning('Double Defined : Max Depth : Over write');
        end
        maxdepth=varargin{id};
        setappdata(handles.figure1, 'MaxDepth',  maxdepth);

      otherwise,
        warning(['Unknown option : ' optname]);
    end
  catch
    warning(['Error : ' lasterr]);
  end
end

edit_path_Callback(handles.edit_path, [], handles);

% Check
if tflag && fflag,
  warning('Ignore Top-Level-Directory : becoause Fixed Flag');
end
if ~tflag && ~isempty(maxdepth),
  warning(' Ingore Max Depth : because no Top-Level-Directory');
end

% UIWAIT makes uiputfile_osp wait for user response (see UIRESUME)
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
  stdir = getappdata(handles.figure1, 'StartDir');
  cd(stdir);
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    uiresume(handles.figure1);
  end
end
delete(handles.figure1);
return;

function varargout = uiputfile_osp_OutputFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Outputs variable of the GUI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varargout 1:  filenames -> Selected Filenames
%           2:  pathname  -> Selected Pathname

filenames = getappdata(handles.figure1, 'FileNames');
pathname  = getappdata(handles.figure1, 'PathName');

varargout{1} = filenames;
if nargout>=2
  varargout{2} = pathname;
end
if nargout>=3
  varargout{3} = get(handles.pop_filetype,'Value');
end
delete(handles.figure1);
return;

function psb_save_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Result Getting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename=...
  edit_filename_Callback(handles.edit_filename, [], handles);
if isempty(filename),
  errordlg('Not Match Pattern');
  return;
end
pathname  = getappdata(handles.figure1, 'PathName');
fullname  =[pathname filesep filename];
if exist(fullname,'file'),
  a=questdlg('File Already Exist. Do you want to Over-write?',...
    'Over-wreite?', 'Yes','No','Yes');
  if strcmp(a,'No'); return; end
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
pathname = getappdata(handles.figure1, 'PathName');
try, cd(pathname); end
pathname = uigetdir;

% Cancel
if pathname==0, return; end

%----------------
% Change Direcoty
%----------------
msg=localChangeDirectory(handles,pathname);
if ~isempty(msg), errordlg(msg);end
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

%----------------
% Change Direcoty
%----------------
msg=localChangeDirectory(handles,pathname);
if ~isempty(msg),
  errordlg(msg);
  return;
end
return;

function lbx_dir_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Directory by Selecting Directory List box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dirnames = get(handles.lbx_dir, 'String');
id       = get(handles.lbx_dir, 'Value');
dirname  = dirnames{id}; clear dirnames id;

%----------------
% Change Direcoty
%----------------
pathname = getappdata(handles.figure1, 'PathName');
msg=localChangeDirectory(handles,[pathname filesep dirname]);
if ~isempty(msg), errordlg(msg);end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=localChangeDirectory(handles,pwdx)
% Change Directory of The GUI
%  Syntax : msg=localChangeDirectory(handles,pwdx)
%
%     msg : empty : OK
%            or   :   Error Message
%
%     handles : GUI Data
%     pwdx    : Change Directory
%
% Date : 2006.06.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(2,2,nargin);
if ~isempty(msg);return; end

% Original Path (Must be Current Direcotyro)
pwd0=getappdata(handles.figure1, 'PathName');

%-------------------
% Directory Check
%-------------------
% is directory ?
if ~isdir(pwdx),
  msg={' Selected Directory : Not a Directory', ...
    ['     ' pwdx]};
  localChangeDirectory(handles,pwd0); % Reset Data
  return;
end

%--------------------------
% Top Level Directory Check
%--------------------------
tld = getappdata(handles.figure1, 'TopLevelDirectory');
% Check Top-Level-Directory
if ~isempty(tld),
  msg0 ={' Top Level Directory : ', ['   ' tld], ...
    ' Selected Direcotry  : ', ['   ' pwdx]};

  %-------------------
  % Replase '..' & '.'
  %-------------------
  try
    cd(pwdx);pwdx=pwd;
  catch
    msg={msg0{:}, ' Unknown Error : ', lasterr};
    localChangeDirectory(handles,pwd0); % Reset Data
    return;
  end

  %-----------------
  % Directory Charactor (Ignore case / not)
  %-----------------
  if ispc,   %windows
    strfunc=@strcmpi;
  else, % Unix
    strfunc=@strcmp;
  end

  %--------------------------
  % Top Level Directory Check
  %--------------------------
  tld_len= length(tld);
  if length(pwdx)<tld_len,
    msg={msg0{:}, ' Error : Superior Directory'};
    localChangeDirectory(handles,pwd0); % Reset Data
    return;
  end
  if ~feval(strfunc, tld, pwdx(1:tld_len)),
    msg={msg0{:}, ' Error : Different Top-Level Directory'};
    localChangeDirectory(handles,pwd0); % Reset Data
    return;
  end

  %-----------------------
  % Check Maximum-Depth
  %-----------------------
  maxdp  = getappdata(handles.figure1, 'MaxDepth');
  if ~isempty(maxdp),
    % To Check maximum-depth
    if (strcmp(pwdx(end), filesep)),
      pwdx(end)=[];
    end

    % Check Maximum Depth
    if length(pwdx)~=tld_len,
      sp = strfind(pwdx(tld_len+1:end), filesep);
      if length(sp)>maxdp,
        msg={msg0{:}, ' Error : Over Maximum Depth'};
        localChangeDirectory(handles,pwd0); % Reset Data
        return;
      end
    end
  end % End Check Maximum Depth
end % Check Top-Level-Directory

%------------
% Change dir
%------------
try
  cd(pwdx);
catch
  msg={['cd(''' pwdx ''') :' ],  lasterr};
  localChangeDirectory(handles,pwd0); % Reset Data
  return;
end
set(handles.edit_path,'String',pwdx);
setappdata(handles.figure1, 'PathName', pwdx);

% Change Directory Listbox
dirnames = dir(pwdx);
isdir_dirnames=[dirnames.isdir];
dirnames(isdir_dirnames==0) = []; clear isdir_dirnames;
dirnames_name = {dirnames.name};
set(handles.lbx_dir, 'Value',1, 'String', dirnames_name);

% Change File Listbox
pop_filetype_Callback(handles.pop_filetype, [], handles)
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  File Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lbx_files_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Edit File Name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
st= get(hObject,'String');
vl= get(hObject,'Value');
if length(vl)==1,
  set(handles.edit_filename,'String',st{vl});
  set(handles.edit_filename,'String',st{vl});
end
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
  [isdir_names{1:length(names)}] = deal(names.isdir);
  isdir_names = [isdir_names{:}];
  names(isdir_names) = []; clear isdir_names;
end


% Setting Name & User Data : Select/notSelect flag
if ~exist('names','var') || isempty(names)
  set(handles.lbx_files, ...
    'Value',        1, ...
    'String',   {' -- No match Files --'}, ...
    'UserData', []);
else
  [names_tmp{1:length(names)}] = deal(names.name);
  set(handles.lbx_files, ...
    'Value',        1, ...
    'String',   names_tmp, ...
    'UserData',1);
end
return;

function filename=edit_filename_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Pattern
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename='';
file_filter = get(handles.pop_filetype,'UserData');
id          = get(handles.pop_filetype,'Value');
if length(file_filter)<=id,
  file_filter = file_filter(id);
  filepattern = strrep(file_filter,'*','[\w\W]*');
  filename0 = get(hObject,'String');
  if ispc,
    s = regexpi(filename0,filepattern);
  else
    s = regexp(filename0,filepattern);
  end
  if ~isempty(s),
    filename=filename0;
    setappdata(handles.figure1, 'FileNames',filename);
  end
end

function d = dir_ic(filt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dir ignore case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  % may be same
  d=dir(filt);
  return;
end

% ignore case
d = dir;
d(find([d.isdir]))=[];
names = {d.name};

% start check
sep = strfind(filt,'*');
if ~isempty(sep) && sep(1)~=1
  s=regexpi(names,['^' filt([1:sep(1)])]);
  if isempty(s)
    d=struct([]); return;
  end
  if iscell(s)
    ck = cellfun('isempty',s);
    if ~isempty(ck)
      d(ck)=[];names(ck)=[];
    end
  end
end

for id = 1:length(sep)-1, % may be no
  s=regexpi(names,filt([(sep(id)+1):(sep(id+1)-1)]));
  if isempty(s)
    d=struct([]); return;
  end
  if iscell(s)
    ck = cellfun('isempty',s);
    if ~isempty(ck)
      d(ck)=[];names(ck)=[];
    end
  end
end

% end check
if (sep(end)~=length(filt)),
  if isempty(sep)
    pat=['^' filt '$'];
  else
    pat = [filt([(sep(end)+1):end]) '$'];
  end
  s=regexpi(names, pat);
  if isempty(s)
    d=struct([]);
  end
  if iscell(s)
    ck = cellfun('isempty',s);
    if ~isempty(ck)
      d(ck)=[];names(ck)=[];
    end
  end
end
return;
