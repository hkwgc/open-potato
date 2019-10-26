function varargout = ui_FilterPluginSelector(varargin)
% UI_FILTERPLUGINSELECTOR Make Filter-Plugin's Group.
%
%--------------------------------------------------------------------------
% Syntax:
%    issucces = ui_FilterPluginSelector;
%--------------------------------------------------------------------------
% Arguments:
%     issuccess : true/false,
%                 if ui_FilterPluginSelector Succes,
%                    return ture.
%                  else
%                     return false.
%--------------------------------------------------------------------------
%   
% See also: 
%            GUIDE, GUIDATA, GUIHANDLES.

% Last Modified by GUIDE v2.5 06-Jun-2007 13:45:36


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2007.06.06
% $Id: ui_FilterPluginSelector.m 180 2011-05-19 09:34:28Z Katura $
%
% Revition 1.1
%   new :


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code
%  (Launch Swich )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @ui_FilterPluginSelector_OpeningFcn, ...
  'gui_OutputFcn',  @ui_FilterPluginSelector_OutputFcn, ...
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
% Figure Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function ui_FilterPluginSelector_OpeningFcn(hObject, ev, handles, varargin)
% Opening Function ot the Figure.
%  1. Opening ...
%  2. get Filter Type
%  3. Load (All Filter List) and Setup APPDATA
%  4. Refrect 2<->3
%  5. Exit Opening.
%==========================================================================

%-------------------
% 1. Opening....
%-------------------
% is running?
handles.figure1=hObject; % My favorite..
isrunning=getappdata(hObject,'isrunning');
if ~isempty(isrunning)
  return;
end
setappdata(hObject,'isrunning',true);

%-------------------
%  2. get Filter Type
%-------------------
% Backup FILTER_RECIPE_GROUP_TYPE 
ftype=OSP_DATA('GET','FILTER_RECIPE_GROUP_TYPE');
% --> (Data ID== Inner 2)
setappdata(handles.figure1,'INI_FILTER_RECIPE_GROUP_TYPE',ftype);

%-------------------
%  3. Load (All Filter List) and Setup APPDATA
%-------------------
OSP_DATA('SET','FILTER_RECIPE_GROUP_TYPE','All');
[a.FilterList, a.wrapper, a.FilterAllowed, a.FilterDispKind, a.BookMarkString] =...
  OspFilterDataFcn('ListReset');
setappdata(handles.figure1,'FilterList_All',a);

%-------------------
%  4. Refrect 2<->3
%-------------------
% (Create & Call 
str={'Delete-List1','Delete-List2','Delete-List3'};
vl=find(strcmpi(str,ftype));
if isempty(vl),vl=1;end
set(handles.pop_filter_recipe_group_type,...
  'String',str,...
  'Value',vl);

pop_filter_recipe_group_type_Callback(...
  handles.pop_filter_recipe_group_type,ev,handles);

%-------------------
% 5. Exit Opening.
%-------------------
% Setup Default Output
handles.output = false;
% Update guidata
guidata(hObject, handles);
% waiting...
if 1
  set(handles.figure1,'WindowStyle','modal');
  uiwait(handles.figure1);
end

%==========================================================================
% --- Outputs from this function are returned to the command line.
function varargout = ui_FilterPluginSelector_OutputFcn(hObject, eventdata, handles)
%==========================================================================

varargout{1} = handles.output;
% --> indebuggin
if 1
  delete(hObject);
end

%==========================================================================
function psb_ok_Callback(hObject, eventdata, handles)
%==========================================================================
save_now(handles);
handles.output = true;
guidata(handles.figure1, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end

%==========================================================================
function psb_cancel_Callback(hObject, ev, handles)
% 
%==========================================================================

% Recover :: INI_FILTER_RECIPE_GROUP_TYPE
ftype=getappdata(handles.figure1,'INI_FILTER_RECIPE_GROUP_TYPE');
OSP_DATA('SET','FILTER_RECIPE_GROUP_TYPE',ftype);

% Do noting..
handles.output = false;
guidata(handles.figure1, handles);
% Delete
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List Update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function pop_filter_recipe_group_type_Callback(hObject, ev, handles)
%==========================================================================
a=getappdata(handles.figure1,'FilterList_All');
str=get(hObject,'String');
vl=get(hObject,'Value');
OSP_DATA('SET','FILTER_RECIPE_GROUP_TYPE',str{vl});

fname=OspFilterDataFcn('getDeleteListFilename');

if exist(fname,'file')
  load(fname);
  
  if isempty(wrapper)
    us={'Empty'};nlud={};
    nl=a.FilterList;usud=a;
  else
    [r,r2]=setdiff(a.wrapper,wrapper);
    
    nlud.FilterList=FilterList;
    nlud.wrapper=wrapper;
    nlud.FilterAllowed=FilterAllowed;
    nlud.FilterDispKind=FilterDispKind;
    
    nl=FilterList;
    if isempty(r)
      us={'Empty'};usud={};
    else
      r2=sort(r2);
      usud.FilterList=a.FilterList(r2);
      usud.wrapper=a.wrapper(r2);
      usud.FilterAllowed=a.FilterAllowed(r2);
      usud.FilterDispKind=a.FilterDispKind(r2);
      us=usud.FilterList;
    end
  end
else
  % New
  us=a.FilterList;usud=a;
  nl={'Empty'};nlud={};
end

set(handles.lbx_use_filter,'Value',[],'String',us,'UserData',usud);
set(handles.lbx_needless_filter,'Value',[],'String',nl,'UserData',nlud);
set([handles.psb_add,handles.psb_rm],'Enable','off');

%==========================================================================
function lbx_needless_filter_Callback(hObject, eventdata, handles)
% (pushbutton enable control)
%==========================================================================
vl=get(hObject,'Value');
ud=get(hObject','UserData');
if isempty(vl) || isempty(ud)
  set(handles.psb_add,'Enable','off');
else
  set(handles.psb_add,'Enable','on');
end

%==========================================================================
function lbx_use_filter_Callback(hObject, eventdata, handles)
% (pushbutton enable control)
%==========================================================================
vl=get(hObject,'Value');
ud=get(hObject','UserData');
if isempty(vl) || isempty(ud)
  set(handles.psb_rm, 'Enable','off');
else
  set(handles.psb_rm, 'Enable','on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List Modify
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fl=rmfilter(h)
% Remove Selected Filter from listbox
vl=get(h,'Value');
ud=get(h,'UserData');
if isempty(ud),fl=[];return;end

% Selected Filter List
fl.FilterList=ud.FilterList(vl);
fl.wrapper=ud.wrapper(vl);
fl.FilterAllowed=ud.FilterAllowed(vl);
fl.FilterDispKind=ud.FilterDispKind(vl);

% Remove from UserData
ud.FilterList(vl)=[];
ud.wrapper(vl)=[];
ud.FilterAllowed(vl)=[];
ud.FilterDispKind(vl)=[];
if isempty(ud.FilterList)
  set(h,'Value',[],'UserData',[],'String',{'Empty'});
else
  set(h,'Value',[],'UserData',ud,'String',ud.FilterList);
end

function addfilter(h,fl)
% Ad Filter to listbox
ud=get(h,'UserData');
if isempty(ud),
  set(h,'Value',[],'UserData',fl,'String',fl.FilterList);
  return;
end
if isempty(fl),return;end

ud.FilterList={ud.FilterList{:},fl.FilterList{:}};
ud.wrapper={ud.wrapper{:},fl.wrapper{:}};
ud.FilterAllowed={ud.FilterAllowed{:}, fl.FilterAllowed{:}};
ud.FilterDispKind=[ud.FilterDispKind, fl.FilterDispKind];
set(h,'Value',[],'UserData',ud,'String',ud.FilterList);

%==========================================================================
function psb_add_Callback(h, ev, handles)
%==========================================================================
fl=rmfilter(handles.lbx_needless_filter);
addfilter(handles.lbx_use_filter,fl);
set([handles.psb_add,handles.psb_rm],'Enable','off');

%==========================================================================
function psb_rm_Callback(h, ev, handles)
%==========================================================================
fl=rmfilter(handles.lbx_use_filter);
addfilter(handles.lbx_needless_filter,fl);
set([handles.psb_add,handles.psb_rm],'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_now(hs)

%---------------
% Type Define
%---------------
ftype=get(hs.pop_filter_recipe_group_type,'String');
ftype=ftype{get(hs.pop_filter_recipe_group_type,'Value')};
OSP_DATA('SET','FILTER_RECIPE_GROUP_TYPE',ftype);

%---------------
% get Save Name
%---------------
fname=OspFilterDataFcn('getDeleteListFilename');

%---------------
% get Save Data
%---------------
% --> Meeting on : 2007.06.11 : ( on tellephone )
ud=get(hs.lbx_needless_filter,'UserData');
% Bugfix 070801C : at 2007.08.02 by shoji.
if isempty(ud)
  if exist(fname,'file'), delete(fname); end
  return;
end
FilterList=ud.FilterList;
wrapper=ud.wrapper;
FilterAllowed=ud.FilterAllowed;
FilterDispKind=ud.FilterDispKind;

a=getappdata(hs.figure1,'FilterList_All');
BookMarkString=a.BookMarkString;
f=fieldnames(a);
if 0
  % Use in Save..
  disp(FilterList);
  disp(wrapper);
  disp(FilterAllowed);
  disp(FilterDispKind);
  disp(BookMarkString);
end

%---------------
% Save
%---------------
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,f{:},'-v6');
else
  save(fname,f{:});
end
