function varargout = osp_FilterBookMark(varargin)
% OSP_FILTERBOOKMARK is GUI for Edit  Filter's Book-Mark.
%   This GUI is wrapper of OspFilterDataFcn('SaveBookMarkString')
%   !! This function Need OSP_DATA. ( i.e OSP ) !!
%
%---------------------------------------------
% Syntax  : (not gui_mainfunction/Callback)
%    flag = osp_FilterBookMark;
%
%    flag = ture  : Change BookMark.
%         = false : Not Change BookMark.
% 
% to confine Result,
%    list=OspFilterDataFcn('BookMarkString');
%---------------------------------------------
%
% This function is available since OSP : 2.10 (29-May-2006)
%
% See also: OSP, OSPFILTERDATA, OSPFILTERCALLBACKS,
%           GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help osp_FilterBookMark

% Last Modified by GUIDE v2.5 29-May-2006 14:27:55


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2006.05.15
% $Id: osp_FilterBookMark.m 180 2011-05-19 09:34:28Z Katura $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @osp_FilterBookMark_OpeningFcn, ...
                   'gui_OutputFcn',  @osp_FilterBookMark_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function osp_FilterBookMark_OpeningFcn(hObject, eventdata, handles, varargin)
% Opening Function ==: UIWAIT :==
%    Load Current Book-Mark & Filter 
%    and Set There variable


% No output Data
handles.output = false;

set(hObject,'Color',[0.824, 1, 0.824]);

% ===> Load Current BookMark <===
try,
    [FilterList, Regions, DispKind] = OspFilterDataFcn('getList');
    str = OspFilterDataFcn('BookMarkString');
    if isempty(str),
        str='Book Mark';
    end
    DefineOspFilterDispKind;
    mflg=bitand(DispKind,F_BOOKMARK);
catch,
    if ~exist(FilterList),
        errordlg({'OSP Error : Can not Load Filter-List'});
        % No uiwait : return false and Close.
        return;
    end
    if ~exist(str,'var'), str='Book Mark'; end
    if ~exist(useflag,'var'), 
        warndlg({'OSP Warning : BoolMark Load Error!', ...
                '  Use Default Vaule to Start '});
    end
end

%--- Update Data ---
set(handles.edt_name,'String',str);
setappdata(hObject,'FilterList',FilterList);

% Filter List : Redraw
redrawListbox(handles,find(~mflg),find(mflg)),

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes osp_FilterBookMark wait for user response (see UIRESUME)
if 1,
  set(handles.figure1,'WindowStyle','modal')
  uiwait(handles.figure1);
end

function varargout = osp_FilterBookMark_OutputFcn(hObject, eventdata, handles)
% Not Change : false 
% Change     : true
try
  varargout{1} = handles.output;
  delete(hObject);
catch
  varargout{1}=false;
end

function psb_ok_Callback(hObject, eventdata, handles)
% ===========
% Load Result
% ============
BookMarkString    =get(handles.edt_name,'String'); 
ud                = get(handles.lbx_mylist,'UserData');
% ============
% Save Result
% =============
OspFilterDataFcn('SaveBookMarkString',BookMarkString,ud);
% ==========
% Close
% ==========
handles.output = true; guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),uiresume(handles.figure1);
else, delete(handles.figure1); end

function psb_cancel_Callback(hObject, eventdata, handles)
% Output : Normal Close
handles.output = false; guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),uiresume(handles.figure1);
else, delete(handles.figure1); end


function psb_add_Callback(hObject, eventdata, handles)
% Add to List
% Load Data
nflg2=get(handles.lbx_all   ,'UserData'); nflg2=nflg2(:);
mflg2=get(handles.lbx_mylist,'UserData'); mflg2=mflg2(:);
val  =get(handles.lbx_all,'Value');
% 
if isempty(mflg2),
    mflg2=nflg2(val);
else,
    mflg2=[mflg2; nflg2(val)];
end
nflg2(val)=[];
redrawListbox(handles,nflg2,mflg2);

function psb_remove_Callback(hObject, eventdata, handles)
% Remove From List
% Load Data
nflg2=get(handles.lbx_all   ,'UserData'); nflg2=nflg2(:);
mflg2=get(handles.lbx_mylist,'UserData'); mflg2=mflg2(:);
val  =get(handles.lbx_mylist,'Value');
% 
if isempty(nflg2),
    nflg2=mflg2(val);
else,
    nflg2=[nflg2; mflg2(val)];
end
mflg2(val)=[];
redrawListbox(handles,nflg2,mflg2);

function redrawListbox(handles,nflg2,mflg2),
% Redraw List-Box
%------------------------
% Load Data set ( if need)
%------------------------
if nargin<1,
    nflg2=get(handles.lbx_all,'UserData');
end
if nargin<2
    mflg2=set(handles.lbx_mylist,'UserData');
end
FilterList=getappdata(handles.figure1,'FilterList');

%------------------------
% Set All
%------------------------
if isempty(nflg2),
    set(handles.lbx_all,'String','No Filter Rest.','UserData',[],'Value',1);
else,
    set(handles.lbx_all,'String',FilterList(nflg2),'UserData',nflg2,'Value',1);
end
% Marked List

if isempty(mflg2),
    set(handles.lbx_mylist,'String','No Entry Filter.','UserData',[],'Value',1)
else,
    set(handles.lbx_mylist,'String',FilterList(mflg2),'UserData',mflg2,'Value',1)
end
