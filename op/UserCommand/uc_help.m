function varargout = uc_help(varargin)
% UC_HELP : GUI for Searching User Command Function.
%      UC_HELP, by itself, creates a new UC_HELP or raises.
%
%      H = UC_HELP returns the handle to the UC_HELP.
%
%      UC_HELP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UC_HELP.M with the given input arguments.
%
%      UC_HELP('Property','Value',...) creates a new UC_HELP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uc_help_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uc_help_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 08-Mar-2006 08:59:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uc_help_OpeningFcn, ...
                   'gui_OutputFcn',  @uc_help_OutputFcn, ...
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

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2005.05.19
% $Id: uc_help.m 180 2011-05-19 09:34:28Z Katura $


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GUI Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uc_help_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for uc_help
handles.output = hObject;

set(hObject,'Color','white');

% Update handles structure
guidata(hObject, handles);

% make function list
Contents_function('DoOSP');

% 
if 0
	fl=Contents_function('data_io','FUNCTION_LIST');
	fl=struct_sort(fl,'Name');
	Contents_function('data_io','FUNCTION_LIST',fl);
	Contents_function('makeindex');
end

% locking
Contents_function('mlock');

% default search-result printing
psb_Search_Callback(handles.psb_Search, [], handles)

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Function
try,
  Contents_function('munlock');
end

function varargout = uc_help_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% List Box : Function List
function lbx_Function_Callback(hObject, eventdata, handles)
% View Selected Function's Information & Help
data=get(hObject,'UserData');
if isempty(data),
	set(handles.lbx_info,'String','no function selected','Value',1);
	set(handles.lbx_help,'String','no function selected','Value',1);
else
	val = get(hObject,'Value');
	data=data(val);
	
	s=help(data.Name);
	s2={}; sep=sprintf('\n');
	pos1 = 1;
	for idx=strfind(s,sep),
		s2{end+1} = s(pos1:idx);
		pos1=idx+1;
	end
	set(handles.lbx_help,'String',s2,'Value',1);
	set(handles.lbx_info,'String',Contents_function('getInfo', data),...
		'Value', 1);
end



function lbx_help_Callback(hObject, eventdata, handles)
function lbx_info_Callback(hObject, eventdata, handles)

function chk_Name_Callback(hObject, eventdata, handles)
function edit1_Callback(hObject, eventdata, handles)

function pop_Limit_CreateFcn(hObject, eventdata, handles)
% -- Type Setting --
Contents_Script_Header;
vl=find(TypeIDX==TYPEID_USERCOMMAND);
set(hObject,'String', TypeStr, 'UserData',TypeIDX,'Value',vl);

function pop_Limit_Callback(hObject, eventdata, handles)


function chk_group_search_Callback(hObject, eventdata, handles)
function pop_group_CreateFcn(hObject, eventdata, handles)
% -- Group Setting --
Contents_Script_Header;
set(hObject,'String', GroupStr, 'UserData',GroupIDX);
function pop_group_Callback(hObject, eventdata, handles)


% Search ->
function psb_Search_Callback(hObject, eventdata, handles)
% init
Contents_Script_Header;
TypeID  = TYPEID_ANY;
DirID   = DIRID_ANY;
GroupID = GROUPID_ANY;
NamePat = [];

% get TypeID
vl = get(handles.pop_Limit, 'Value');
ud = get(handles.pop_Limit, 'UserData');
TypeID = ud(vl);

% get Group ID
if get(handles.chk_group_search,'Value'),
	tmp=get(handles.pop_group,'UserData');
	GroupID = tmp(get(handles.pop_group,'Value'));
end

% get Name Pattern
if get(handles.chk_Name,'Value'),
	NamePat = get(handles.edit1,'String');
end

% Search
if isempty(NamePat)
	fl=Contents_function('getFLwithCondition',TypeID, DirID,GroupID);
else
	fl=Contents_function('getFLwithCondition',TypeID, DirID,GroupID, NamePat);
end

% Change FunctionList
if isfield(fl,'Name') && length(fl)>=1,
	val = get(handles.lbx_Function, 'Value');
	if val > length(fl), val = length(fl); end
	set(handles.lbx_Function, ...
		'UserData',fl, ...
		'String', {fl.Name}, ...
		'Value', val);
else
	set(handles.lbx_Function, ...
		'UserData',struct([]), ...
		'String', 'No File List exist', ...
		'Value', 1);
end
% Change Information & Help
lbx_Function_Callback(handles.lbx_Function, [],handles);



function psb_launchosphelp_Callback(hObject, eventdata, handles)
% @since 1.2
  h = handles.lbx_Function;
  data=get(h,'UserData');
  if isempty(data),
    set(handles.lbx_info,'String','No function selected','Value',1);
    set(handles.lbx_help,'String','No function selected','Value',1);
  else
    val = get(h,'Value');
    data=data(val);
	
    OspHelp(data.Name);
end


function psb_codeedit_Callback(hObject, eventdata, handles)
% Code Edit pushbutton
h = handles.lbx_Function;
data=get(h,'UserData');
if isempty(data),
	set(handles.lbx_info,'String','No function selected','Value',1);
	set(handles.lbx_help,'String','No function selected','Value',1);
else
	val = get(h,'Value');
	data=data(val);
	edit(data.Name);
end
