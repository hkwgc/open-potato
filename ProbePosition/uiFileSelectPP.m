function varargout = uiFileSelectPP(varargin)
% UIFILESELECTPP is dialog-box to select OSP-Data for
% Probe-Position.
%
%  Syntax :
%   cactdata   = UIFILESELECTPP;
%   ccactadata = UIFILESELECTPP('MultiSelect',ture);
%
%  cactdata : Cell-Array of Set of ActiveData
%             (one set is
%
% Keybind of this GUI base on OSP-GUI rule.
%
%===================================
% Related Fucntions
%===================================
%
% Upper Function :
%    SETPROBEPOSITION, COPYPOSITIONDATA.
% Lower Function :
%    GUI_MAINFCN, REGEXPI, OSP_KEYBIND
%    and others.
%
% See also: GUIDE, GUIDATA, GUIHANDLES, GUI_MAINFCN,
%           OSP, SETPROBEPOSITION, COPYPOSITIONDATA
%
%===================================
% Known Bugs:
%===================================
%   When Multi-byte-Character in the Files,
%   warning occur and cannot find data correctly.
%   --> for warning
%   (Type "warning off REGEXP:multibyteCharacters.")
%   --> for miss some data,
%    use ASCII-CODE for DATA FILE.
%    give proper regexp function.

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %

% Warning!!
%   If you want to add more optional arguments,
%   2nd Argument cannot numerical.
%   Then Add Folloing help.
%  -------------------------------------
%   In MultiSelect Option :
%    you can not use 1 inspite of ture.
%  -------------------------------------
% ( or overwrite gui_mainfcn, when OSP running.)
%
% cf) GUI_MAINFCN (Revision 1.5) L.52


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% $Id: uiFileSelectPP.m 180 2011-05-19 09:34:28Z Katura $
%
% Original Author : M. Shoji
% Create : 2005.12.13
%
% Revision 1.4
%  New Syntax:
%   ccactadata = UIFILESELECTPP('MultiSelect',ture);
%   cf) Mail from TK at Fri, 17 Feb 2006 17:20:46
%
% Revision 1.5
%  Meeting on 15-May-2006 at Hitachi Advanced Research Laboratory.
%
% Revision 1.6 : 21-May-2006
%  Bug-Fix : Vague Design
%  Popup-Menu Return-Option

% Last Modified by GUIDE v2.5 21-May-2006 14:38:52

% == GUI sub-function Selector ==
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @uiFileSelectPP_OpeningFcn, ...
  'gui_OutputFcn',  @uiFileSelectPP_OutputFcn, ...
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
% == GUI Function Selector ==

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == -- GUI Fundamental Functions-- ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiFileSelectPP_OpeningFcn(hObject, eventdata, handles, varargin)
% Opening Function of uiFileSelectPP
%  Set Default Application-Data
%  Read Opening Arguments.
%  Default-Search of Files.
%=========================================
handles.output = [];
% In OSP GUI :
%  Shoji want fixed name for figure handle.
%  Confine to set figure1
handles.figure1=hObject;
guidata(hObject, handles);

% ==== Set Default Application-Data ====
setappdata(hObject,'MULTI_SELECT',false);
% ==== Argument Read ====
for idx=2:length(varargin)
  try,
    switch varargin{idx-1},
      case 'MultiSelect',
        if islogical(varargin{idx}),
          setappdata(hObject,'MULTI_SELECT',varargin{idx});
        else,
          warning('MULTI SELECT : INPUT LOGICAL');
        end
      otherwise,
        wraring('Unknown Property');
    end
  catch,
    h=errordlg({' [Platform] Error!' ,...
      ' Probe-Positon File Select GUI', ...
      '      Bad Opening Arguments.', ...
      C__FILE__LINE__CHAR});
    uiwait(h); return; % (No wait and Delete
  end
end


% === SETTING FIGURE-PROPERTY ===
% Figure Color Setting
set(handles.figure1,'Color', [1,1,1]);

% Multi Select or not.
msflag = getappdata(hObject,'MULTI_SELECT');
%if msflag,
if true,
  setappdata(hObject,'MULTI_SELECT',true);
  % Old - Format :: This Function is Remove!
  set(handles.pop_ReturnOpt,'Enable','on');
  set(handles.lsb_datalist,'MAX',10);
else,
  % --> default :: to confine Situation
  set(handles.pop_ReturnOpt,'Enable','inactive');
  set(handles.lsb_datalist,'MAX',1);
end

% === set Function-Name  %%added for reading RAW-DATA, 070131
if OSP_DATA('GET','isPOTAToRunning'),
  UseFnc='DataDef2_RawData';
else
  UseFnc='DataDef_SignalPreprocessor';
end
setappdata(handles.figure1, 'UseFunction', UseFnc);

% ==== Set NEED-VALUE ====
try,
  chk_FileGrouping_Callback(handles.chk_FileGrouping, [], handles)
catch,
  errordlg({' FILE SELECT : ', ['  ' lasterr]});
  % ( No wait and Delete)
  return;
end

% ==> WAIT FOR CANCEL/OK
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);

%===============================
function varargout = uiFileSelectPP_OutputFcn(hObject, eventdata, handles)
% Outputs from this function.
%===============================
varargout{1} = handles.output;
delete(handles.figure1);

function pop_ReturnOpt_Callback(hObject, eventdata, handles)
% This Popup-Menu is Determin, What User want to Select..
% This function is Dumy( Do nothing) now.
%   run when Return-Option poppu-menu is changed.

%===============================
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close function
%===============================
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  % --> return ->Opening Function
  %     --> OutputFcn
  uiresume(handles.figure1);
else
  % Delete this function.
  delete(handles.figure1);
end

%===============================
function figure1_KeyPressFcn(hObject, eventdata, handles)
% Define Key Press Function base on OSP-GUI rules.
%===============================

if isequal(get(hObject,'CurrentKey'),'escape')
  handles.output = [];
  guidata(hObject, handles);
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % --> return ->Opening Function
    %     --> OutputFcn
    uiresume(handles.figure1);
  else
    % Delete this function.
    delete(handles.figure1);
  end
end
%if isequal(get(hObject,'CurrentKey'),'return')
%  uiresume(handles.figure1);
%end
osp_KeyBind(hObject,[],handles,mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == GUI Exist Functions-- ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================
function psb_select_Callback(hObject, eventdata, handles)
% Execute on push Select-Button
%  Get Result From File
%===============================
lst=getappdata(handles.figure1,'SP_LIST');
ud = get(handles.lsb_datalist,'UserData');
vl = get(handles.lsb_datalist,'Value');
fncname=['@' getappdata(handles.figure1, 'UseFunction')];

out={};
% Grouping?
gpflag = get(handles.chk_FileGrouping,'Value');
% SingleSelect?
msflag = getappdata(handles.figure1,'MULTI_SELECT');
% Single File Output ?
popval = get(handles.pop_ReturnOpt,'Value');

if gpflag || ...
    isempty(msflag) || ...
    msflag~=1 || ...
    popval==2
  % Grouping : msflag
  for idx=1:length(vl),
    udl = cell2mat(ud(vl(idx)));
    lst2={};
    for idx0=1:length(udl),
      lst2{idx0}=lst(udl(idx0));
    end
    %out{idx} = struct('fcn',@DataDef_SignalPreprocessor,...
    %      'data',lst2);
    out{idx} = struct('fcn', fncname , 'data',lst2);
  end
else,
  % As a Single File
  lst2={};
  for idx=1:length(vl),
    udl = cell2mat(ud(vl(idx)));
    % GPFLAG==0 : udl(User-Data-List) must be scaler.
    lst2{end+1}=lst(udl);
  end
  if ~isempty(lst2)
    % Exist Output data
    out{1}=struct('fcn',fncname, 'data',lst2);
  end
end

handles.output =out;
guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  % Delete this function.
  delete(handles.figure1);
end
return;

%===============================
function psb_Cancel_Callback(hObject, eventdata, handles)
% Execute on push Select-Button
%  Get Result From File
%===============================
handles.output = [];
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  % Delete this function.
  delete(handles.figure1);
end
return;

%===============================
function lsb_datalist_Callback(hObject, eventdata, handles)
% --> Show Selected Data Information to lsb_datainfo
%===============================
lst=getappdata(handles.figure1,'SP_LIST');
ud = get(handles.lsb_datalist,'UserData');
vl = get(handles.lsb_datalist,'Value');
if isempty(vl)
  set(handles.lb_FileInfo,'String', {'== No Data=='});
  return;
end

vl = vl(1); % select 1st one
udl = cell2mat(ud(vl));

set(handles.lsb_datainfo,'Value',1);
% set(handles.lsb_datainfo,'String', ...
% 	  DataDef_SignalPreprocessor('showinfo',lst(udl(1))));
UseFnc=getappdata(handles.figure1, 'UseFunction');
str = eval([UseFnc '(''showinfo'',lst(udl(1)));']);
set(handles.lsb_datainfo,'String',str);
return;

%===============================
function chk_FileGrouping_Callback(hObject, eventdata, handles)
% Check box : File Grouping or not
%  == Reload Data ==
%===============================
%lst=DataDef_SignalPreprocessor('loadlist');
UseFnc=getappdata(handles.figure1, 'UseFunction');
lst = eval([UseFnc '(''loadlist'');']);
setappdata(handles.figure1,'SP_LIST',lst);
if isempty(lst),
  error('No Data to load. Make Signal Data at first!');
end
st={lst.filename};

if get(hObject,'Value')==1
  flg=zeros(size(st));
  st2={};
  ud ={};
  for idx=1:length(st),
    if flg(idx), continue; end
    [s, f, t] = regexpi(st{idx}, '(Probe[0-9]+)');

    if isempty(s),
      % Not a Multi Probe
      st2{end+1}=st{idx};
      ud{end+1} = idx;
    else,
      name = st{idx};
      pat = ['^' name(1:s-1), 'Probe[0-9]+' name(f+1:end) '$'];
      s2  = regexpi(st,pat);
      if iscell(s2),
        s2  = find(cellfun('isempty',s2)==0);
      else,
        if ~isempty(s2), s2=1;end
      end
      flg(s2)=1;
      str_idx = '[';
      name_idx = [];
      for idx2=1:length(s2),
        name = st{s2(idx2)};
        [s, f, t] = regexpi(name, '(Probe[0-9]+)');
        str_idx = [str_idx,' ',name(s+5:f),','];
        name_idx(end+1) = str2num(name(s+5:f));
      end
      str_idx(end) = ']';
      st2{end+1}= [name(1:s-1), 'Probe', str_idx, name(f+1:end)];
      ud{end+1} = s2;
      % Check
      name_idx=sort(name_idx);
      name_idx2 = [1:length(name_idx)]';
      if ~isequal(name_idx(:),name_idx2),
        % change to warning : 15-May-2006
        warndlg({'-------- [Platform] Warning !!! --------', ...
          '  Filen Name Warning  : ', ...
          '      Probe number is not continuous', ...
          '  File Name Pattern : ',...
          ['      ', pat, ], ...
          '  Exist Number      : ', ...
          ['      ', str_idx, ], ...
          '-------------------------------'});
      end
    end
  end
  st = st2;

  % Multi Select or not. --> Bug of ver 1.5
  msflag = getappdata(handles.figure1,'MULTI_SELECT');
  if msflag,
    imax=10;
  else,
    imax=1;
  end
  set(handles.pop_ReturnOpt,'Visible','off');
else,
  % This Funcion was Removed
  %set(handles.pop_ReturnOpt,'Visible','on');
  ud=num2cell(1:length(st));
  imax=10;
end

vl=get(handles.lsb_datalist,'Value');
wk=find(vl>length(st));
if ~isempty(wk),
  vl(wk)=[];
  if isempty(vl),vl=1;end
end
if imax==1 , vl=vl(1); end

set(handles.lsb_datalist,'String',st,'UserData',ud,'Value',vl, 'Max',imax);
lsb_datalist_Callback(handles.lsb_datalist,[], handles);


