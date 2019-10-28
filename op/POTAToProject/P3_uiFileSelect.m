function varargout = P3_uiFileSelect(varargin)
% P3_UIFILESELECT M-file for P3_uiFileSelect.fig
%      P3_UIFILESELECT, by itself, creates a new P3_UIFILESELECT or raises the existing
%      singleton*.
%
%      H = P3_UIFILESELECT returns the handle to a new P3_UIFILESELECT or the handle to
%      the existing singleton*.
%
%      P3_UIFILESELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in P3_UIFILESELECT.M with the given input arguments.
%
%      P3_UIFILESELECT('Property','Value',...) creates a new P3_UIFILESELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before P3_uiFileSelect_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 12-Mar-2008 10:00:19


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.01.17
% $Id: P3_uiFileSelect.m 180 2011-05-19 09:34:28Z Katura $

% ** Import From uiFileSelect Revision 1.15 **

% ###################################
%  List of Apprication Data
% ###################################
%   "DataDefFcn"  :  Data Defined Function
%   "DataList"    :  Data List ( File List )
%   "SearchKey"   :  SearchKeys ( Structure of key & word)

% -- Open Main Controller --
% Check if OSP_Main Controller is opened
try
  isrun=OSP_DATA('GET','isPOTAToRunning');
catch
  isrun=false;
end
if ~isrun
  warndlg('Please Open P3 at First!','Cannot OPEN');
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_uiFileSelect_OpeningFcn, ...
  'gui_OutputFcn',  @P3_uiFileSelect_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ******************************************* %
%            Opening Function                 %
% ******************************************* %
function P3_uiFileSelect_OpeningFcn(hObject, ev, handles, varargin)
% Open P3_uiFileSelect
%    1. transrate Varargin
%    2. Load Data Correspond to pop_FileType
if 0,disp(ev);end

% try means that
% Opening Function Never-make Error, because gui_mainfcn
% may be confuse-filehandles.
% Like Open function..
try
  handles.output = hObject;
  guidata(hObject, handles);
  set([handles.psb_dmy_select,handles.psb_select],'Visible','off');
  set([handles.psb_dmy_cancel,handles.psb_cancel],'String','Close');

  % ** Variable Argument Setting **
  for argid=2:2:length(varargin)
    prop = varargin{argid-1};
    val  = varargin{argid}; %#ok
    switch prop
      otherwise,
        error('Unknown Arguments');
    end
  end

  %% Load Data Correspond to pop_FileType
  pop_FileType_Init(handles.pop_FileType,'',handles);
  pop_FileType_Callback(handles.pop_FileType, [], handles);
catch
  errordlg([ 'In P3_uiFileSelect Opening Function :'...
    lasterr]);
end

return;


% ******************************************* %
%             Create Function                 %
% ******************************************* %
function lb_FileInfo_CreateFcn(hObject, ev, hs) %#ok
set(hObject,'FontName','FixedWidth');

% ******************************************* %
%                Display                      %
% ******************************************* %
function lb_FileList_Callback(hObject, eventdata, handles) %#ok
% Displya selected data.
persistent vals_old;
if nargin==0,vals_old=0;return;end
% one data
filelist=get(handles.lb_FileList,'String');
vals = get(handles.lb_FileList,'Value');
filelist=filelist{vals(end)};
if isequal(vals_old,vals),return;end
vals_old=vals;

% Set Active Data
actdata.fcn  = getappdata(handles.figure1,'DataDefFcn');

data=getappdata(handles.figure1,'DataList'); % GetOriginalData
mainkey = feval(actdata.fcn,'getIdentifierKey');
mkeylist = ...
  eval(['{data.' mainkey '}']);   % Get main KeyList
dataid = find(strcmp(filelist,mkeylist));
if isempty(dataid)
  % errordlg(['Cannot Find ''' filelist ''' from data']);
  actdata=[];
elseif length(dataid)~=1
  errordlg(['Data is broken : '...
    'Too many  ''' filelist ...
    '''in the Data File.']);
  return;
else
  actdata.data=data(dataid);
end
% setappdata(handles.figure1,'ActiveData',actdata);

set(handles.lb_FileInfo,'Value',1);
if isempty(actdata)
  set(handles.lb_FileInfo,'String', {'== No Data=='});
else
  set(handles.lb_FileInfo,'String', ...
    feval(actdata.fcn,'showinfo',actdata.data));
end

% Select POTATo's Data-Selection
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);
if 0
  disp(' 9 : POTATo''s Data-Select');
  disp(C__FILE__LINE__CHAR);
end
set(pmhs.lbx_disp_fileList,'Value',vals);
POTATo('lbx_disp_fileList_Callback',pmhs.lbx_disp_fileList,[],pmhs);
return;


function lb_FileInfo_Callback(hObject, eventdata, handles)
return;

% ******************************************* %
%                Search                       %
% ******************************************* %
function pop_FileType_Init(h,Category,hs)
% Initialize popupmenu named "pop_FilteType"
%  --> Move File Categoly
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);
str=get(pmhs.pop_filetype,'String');

if ~isempty(Category)
  if isnumeric(Category)
    val=round(Category);
  else
    val=find(strcmp(Category,str));
  end
else
  val=get(pmhs.pop_filetype,'Value');
end
if val>length(str),val=length(str);end
set(h,'UserData',get(pmhs.pop_filetype,'UserData'),...
  'Value',val,'String',str);
set(hs.lb_FileList,'Max',get(pmhs.lbx_disp_fileList,'Max'));
if 0,disp(hs);disp('hs is dummy variable');end
setappdata(hs.pop_FileType, 'OLD_FTYPE','');


function pop_FileType_Callback(hObject, eventdata, handles)
% == File Type Select ==
%  Data is File-Type dependent
%  So link to Data Definition
%   --> Restart P3_uiFileSelect
%   Here set Application Data "DataDefFcn"
%                             "DataList"
str0 = get(hObject,'String');
fcn0 = get(hObject,'UserData');
fid  = get(hObject,'Value');
fcn  = fcn0{fid};

% local-data:  Befor Selection id check
str_old=getappdata(hObject, 'OLD_FTYPE');
if strcmpi(str0{fid},str_old),  return;  end
setappdata(hObject, 'OLD_FTYPE',str0{fid});
lb_FileList_Callback;
if 0
  disp(' 5 : Rest-Data-Category');
  disp(C__FILE__LINE__CHAR);
end

%% Select Data Define Function
if exist(fcn,'file')
  fcn=eval(['@' fcn]);
else
  errordlg([' Not Defined Data-format.' ...
    ' Function ' fcn ' is not exist.'...
    'Select another Data or Press Escape-Key.']);
  gui_buttonlock('lock',handles.figure1,...
    hObject);
  return;
end
gui_buttonlock('unlock',handles.figure1);
setappdata(handles.figure1,'DataDefFcn', fcn);

% Load DataList
data = feval(fcn,'loadlist');
setappdata(handles.figure1,'DataList', data);

if isempty(data)
  if length(fcn0)>=2,
    fcn0(fid) =[];
    str0(fid) =[];
    if fid>length(fcn0),
      fid=length(fcn0);
    end
    set(hObject, 'UserData',fcn0,'String',str0,'Value', fid);
    setappdata(hObject, 'OLD_FTYPE',[]);
    pop_FileType_Callback(hObject, [], handles)
    return;
  end
  errordlg({[' No Data found in ' ftype], ...
    'Select another Data or Press Escape-Key.'});
  gui_buttonlock('lock',handles.figure1,...
    hObject);
  return;
end

% Reset File List
mainkey = feval(fcn,'getIdentifierKey');
mkeylist = ...
  eval(['{data.' mainkey '}']);   % Get main KeyList
set(handles.lb_FileList,...
  'Value',1, ...
  'String',mkeylist);
lb_FileList_Callback(handles.lb_FileList, [], handles);

% Reset Search-Sort Key
setappdata(handles.figure1,'SearchKeys', []);
[keylist, searchKeyExpl]=feval(fcn,'getKeys');
set(handles.pop_SortKey,  'Value', 1, 'String',keylist);   % sort
for ii=1:length(keylist)
  keylist{ii} = ['  ' keylist{ii}];
end
set(handles.lb_Search_Key,'Value', 1, 'String',keylist);   % search
setappdata(handles.lb_Search_Key, 'SearchKeyExample',searchKeyExpl);
lb_Search_Key_Callback(handles.lb_Search_Key, eventdata, handles);

% Apply to POTATo
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);
set(pmhs.pop_filetype,'Value',fid);
POTATo('pop_filetype_Callback',pmhs.pop_filetype,[],pmhs);

return;

function lb_Search_Key_Callback(hObject, eventdata, handles)
keyexamples=getappdata(hObject, 'SearchKeyExample');
keys=get(handles.lb_Search_Key,'String');
key = keys{get(handles.lb_Search_Key,'Value')}; clear keys;
key = key(3:end);
try
  example = getfield(keyexamples,key);
catch
  example='No example';
  disp(lasterr);
end
set(handles.edit_SearchKey,'String',example);


function edit_SearchKey_Callback(hObject, eventdata, handles)

function psb_search_Callback(hObject, eventdata, handles)
mark='o ';
key= get(handles.lb_Search_Key,'String');
id = get(handles.lb_Search_Key,'Value');

% Make Search Key
addskey.key = key{id}(3:end);
addskey.cnd = get(handles.edit_SearchKey,'String');

% Search and reset Searching Key
skey=getappdata(handles.figure1,'SearchKeys');

if isempty(skey)
  skeyaddpoint=1;
  skey=addskey;
else
  if strncmp(key{id},mark,2)
    % Skey Addition Point
    skeyaddpoint = find(strcmp({skey.key},addskey.key));
    if isempty(skeyaddpoint)
      error([' Program Error -> Key Search can not find old key,' ...
        ' then new find key']);
      skeyaddpoint=length(skey)+1;
    elseif length(skeyaddpoint)~=1
      warning([' Program Error -> Key Search too many key found,' ...
        ' then refresh']);
      skey(skeyaddpoint(2:end)) = []; % clean
      skeyaddpoint=skeyaddpoint(1);
    end
  else
    skeyaddpoint=length(skey)+1;
  end
  skey(skeyaddpoint) = addskey;
end
setappdata(handles.figure1,'SearchKeys',skey);

% Execute Search   & Refrkesh File Listbox
try
  search_and_refresh(handles);
  % OK : set listbox 'o '
  key{id}(1:2) = mark;
  set(handles.lb_Search_Key,'String',key);
catch
  errordlg(lasterr);
  % error : Do not set listbox 'o'
  %         Remove Sets Search Key
  skey(skeyaddpoint) = []; % clear
  setappdata(handles.figure1,'SearchKeys',skey);
end


function psb_reset_Callback(hObject, eventdata, handles)
mark='o ';
key= get(handles.lb_Search_Key,'String');
id = get(handles.lb_Search_Key,'Value');
if ~strncmp(key{id},mark,2)
  msgbox('No search Condition: Select Marking data','Information');
  return;
end

% List Box Refrsh
key{id}(1:2) = '  ';
set(handles.lb_Search_Key,'String',key);

% Search and reset Searching Key
skey=getappdata(handles.figure1,'SearchKeys');
if isempty(skey)
  error([' Program Error -> already refreshed']);
end

% Skey Remove Point
skeyrmpoint = find(strcmp({skey.key},key{id}(3:end)));
if isempty(skeyrmpoint)
  error([' Program Error -> already refreshed']);
elseif length(skeyrmpoint)~=1
  warning([' Program Error -> Key Search too many key found,' ...
    ' then refresh']);
end
skey(skeyrmpoint) = []; % clean
setappdata(handles.figure1,'SearchKeys',skey);
search_and_refresh(handles);

return;

function search_and_refresh(handles)
% Search

% Get Data Defined  Function
fcn = getappdata(handles.figure1,'DataDefFcn');

% Load DataList
data = getappdata(handles.figure1,'DataList');

% Search and reset Searching Key
skey=getappdata(handles.figure1,'SearchKeys');

for key=skey
  % get Data
  KeyData = ...
    eval(['{data.' key.key '}']);   % Get main KeyList

  if isnumeric(KeyData{1})
    % === Numerical Data ===
    KeyData=cell2mat(KeyData);

    % -- cnd Read --
    if ~isempty(strfind(lower(key.key),'sex'))
      switch key.cnd
        case {'Male','male', '''Male''','''male'''}
          cnd=0;
        case {'female','Female', '''female''','''Female'''}
          cnd=1;
        otherwise
          error(['Sex Input : ' ...
            'Data Input format like follows'...
            ' ''Male'' or ''Female''']);
      end
    else
      try
        cnd =eval(key.cnd);
      catch
        % Separator is ;
        if ~isempty(strfind(lower(key.key),'date'))
          error(['Numerical Input : ' ...
            'Data Input format like follows '...
            '{''23-Jan-01'', ''24-Jan-01''}' ...
            ' or ''24-Jan-01''']);
        else
          error(['Numerical Input : ' ...
            'Data Input format like follows [10 20] or 10']);
        end
      end
    end



    % special-case ( Date )
    if ~isempty(strfind(lower(key.key),'date'))
      if iscell(cnd)
        cndi(2)=datenum(cnd(2));
        cndi(1)=datenum(cnd(1));
        cnd=cndi; clear cndi;
      else
        cnd0(1)=datenum(cnd);     % from  0:00
        cnd0(2)=cnd0(1)+1.0;      % to   24:00
        cnd=cnd0; clear cnd0;
      end
    end

    if length(cnd)==1
      % Match Just
      if isempty(strfind(lower(key.key),'sex'))
        % for normal matching
        rslt = find( KeyData == cnd);
      else
        % for Sex (See ot_dataload)
        % 1     : female
        % other : male
        if cnd == 1
          rslt = KeyData == 1;  % Search Female
        else
          rslt= find( KeyData~=1 );      % Search Male
        end
      end
    else
      % Range
      cnd=sort(cnd);	cnd(2)=cnd(end); % Sort
      rslt = find( (cnd(1) <= KeyData)  & (KeyData <= cnd(2)));
    end
  else

    % === Strings ===
    rslt = regexp(KeyData, key.cnd);
    if length(KeyData)==1
      if ~isempty(rslt), rslt=1;end
    else
      rslt = find(cellfun('isempty',rslt)==0);
    end
  end

  if isempty(rslt)
    data=[];
    break;
  else
    data=data(rslt);
    clear KeyData;
  end
end

if isempty(data)
  % No data to Plot
  set(handles.lb_FileList,...
    'Value',1, ...
    'String',{' == Not Muching Data == '});
  mkeylist={};
else
  % Reset File List
  mainkey = feval(fcn,'getIdentifierKey');
  mkeylist = ...
    eval(['{data.' mainkey '}']);   % Get main KeyList
  set(handles.lb_FileList,...
    'Value',1, ...
    'String',mkeylist);
end

%--------------------
% POTATo List Change
%-------------------
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);
if 0
  disp(' 8 : Rest-Data-Category');
  disp(C__FILE__LINE__CHAR);
end
POTATo('searchfile_ext_Callback',handles.figure1,mkeylist,pmhs)

lb_FileList_Callback(handles.lb_FileList, [], handles);

return;

function [skey, skeypoint]=getSearchKey(key)
skey=getappdata(handles.figure1,'SearchKeys');

if isempty(skey)
  skeypoint=[];
else
  skeypoint = strcmp({skey.key},key{id});
end

return;

% ******************************************* %
%                Sort                         %
% ******************************************* %
function pop_SortKey_Callback(hObject, eventdata, handles)
return;
function psb_sort_Callback(hObject, eventdata, handles)

% sort Original Data
key=get(handles.pop_SortKey, 'String');  % Get SortKey
data=getappdata(handles.figure1,'DataList'); % GetOriginalData

data=struct_sort(data, key{get(handles.pop_SortKey, 'Value')});
setappdata(handles.figure1,'DataList',data); % GetOriginalData

% refresh
search_and_refresh(handles);
return;

% ******************************************* %
%             Close Function                  %
% ******************************************* %
function varargout = P3_uiFileSelect_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function psb_select_Callback(hObject, eventdata, handles)
filelist=get(handles.lb_FileList,'String');
vals = get(handles.lb_FileList,'Value');
filelist=filelist{vals(end)};

% Set Active Data
fcn  = getappdata(handles.figure1,'DataDefFcn');
filelist=get(handles.lb_FileList,'String');
vals = get(handles.lb_FileList,'Value');

data    = getappdata(handles.figure1,'DataList'); % GetOriginalData
mainkey = feval(fcn,'getIdentifierKey');
mkeylist = ...
  eval(['{data.' mainkey '}']);   % Get main KeyList
for val0 = vals(:)',
  filelist0=filelist{val0};
  % Set Active Data
  actdata0.fcn  = getappdata(handles.figure1,'DataDefFcn');
  dataid = find(strcmp(filelist0 ,mkeylist));
  if isempty(dataid)
    % errordlg(['Cannot Find ''' filelist ''' from data']);
    continue;
  elseif length(dataid)~=1
    errordlg({'Data was broken : ',...
      ['Too many  ''' filelist{dataid(1)} ...
      ''' in the Data File.'], ...
      'Selected First One'});
    actdata0.data=data(dataid(1));
    %continue;
  else
    actdata0.data=data(dataid);
  end

  if exist('actdata','var'),
    actdata(end+1) = actdata0;
  else,
    actdata        = actdata0;
  end

end

if ~exist('actdata','var'),
  actdata = [];
end

%actdata=getappdata(handles.figure1,'ActiveData');
OSP_DATA('SET','ActiveData', actdata);  % reset
delete(handles.figure1);
return;


function psb_cancel_Callback(hObject, eventdata, handles)
%OSP_DATA('SET','ActiveData',[]);  % reset
delete(handles.figure1);
return;

function psb_help_Callback(hObject, eventdata, handles)
% Show Help
OspHelp(mfilename);
return;


%
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% File Lock
try
  %disp('Close');
  delete(hObject);
catch
  delete(gcbf);
end
function figure1_DeleteFcn(hObject, eventdata, handles)
% File Lock
try
  pmh =OSP_DATA('GET','POTATOMAINHANDLE');
  pmhs=guidata(pmh);
  set(pmhs.menu_data_Selector,'Checked','on');
  POTATo('menu_data_Selector_Callback',pmhs.menu_data_Selector,[],pmhs);
catch
  delete(gcbf);
end


function psb_Detail_Callback(hObject, eventdata, handles)
%===> View Setting <==
%since 1.11

%
h_search=[handles.text10, ...
  handles.psb_cancel, ...
  handles.psb_help, ...
  handles.psb_reset, ...
  handles.txt_Serch_explane, ...
  handles.lb_Search_Key, ...
  handles.text8, ...
  handles.psb_search, ...
  handles.edit_SearchKey, ...
  handles.text5, ...
  handles.frm_Search];
%  handles.psb_select, ...
%
h_normal=[hObject, ...
  handles.psb_dmy_cancel, ...
  handles.psb_dmy_help, ...
  handles.psb_sort, ...
  handles.pop_SortKey, ...
  handles.pop_FileType, ...
  handles.txt_FileInfo, ...
  handles.txt_flist, ...
  handles.lb_FileInfo, ...
  handles.text3, ...
  handles.frm_Sort, ...
  handles.lb_FileList];
%handles.psb_dmy_select, ...

fp = get(handles.figure1,'Position');

mode=get(hObject,'UserData');
switch mode,
  case 1,
    % --- Hide ---
    set(h_search,'Units','pixel');
    set(hObject,'UserData',0,'String', 'Show Detail');
    set(h_search,'Visible','off');
    for h0=h_normal,
      p=get(h0,'Position');p(2)=p(2)-0.5;
      set(h0,'Position',p);
    end
    set(h_normal,'Units','pixel');
    fp(2)=fp(2)+fp(4)*0.5;
    fp(4)=fp(4)*0.5;
    set(handles.figure1,'Position',fp);

  case 0,
    % --- Show Detail ---
    set(hObject,'UserData',1,'String', 'Hide Detail');

    if fp(4)>0.45,
      fp(4)=0.45;
      set(handles.figure1,'Position',fp);
    end
    set(h_search,'Units','pixel');

    % not in Resize
    set(h_normal,'Units','pixel');
    fp(2)=fp(2)-fp(4);
    if fp(2)<0.05, fp(2)=0.05; end
    fp(4)=fp(4)*2;
    set(handles.figure1,'Position',fp);

    set(h_normal,'Units','normalized');
    for h0=h_normal,
      p=get(h0,'Position');p(2)=p(2)+0.5;
      set(h0,'Position',p);
    end

    set(h_search,'Visible','on');

  otherwise,
    errordlg('Error : No-mode');
end

set([h_normal,h_search],'Units','normalized');


