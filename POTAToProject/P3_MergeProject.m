function varargout = P3_MergeProject(varargin)
% P3_MERGEPROJECT M-file for P3_MergeProject.fig
%      P3_MERGEPROJECT, by itself, creates a new P3_MERGEPROJECT or raises the existing
%      singleton*.
%
%      H = P3_MERGEPROJECT returns the handle to a new P3_MERGEPROJECT or the handle to
%      the existing singleton*.
%
%      P3_MERGEPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in P3_MERGEPROJECT.M with the given input arguments.
%
%      P3_MERGEPROJECT('Property','Value',...) creates a new P3_MERGEPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before P3_MergeProject_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to P3_MergeProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help P3_MergeProject

% Last Modified by GUIDE v2.5 22-May-2008 14:47:25


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3_MergeProject_OpeningFcn, ...
                   'gui_OutputFcn',  @P3_MergeProject_OutputFcn, ...
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


% --- Executes just before P3_MergeProject is made visible.
function P3_MergeProject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to P3_MergeProject (see VARARGIN)

% Choose default command line output for P3_MergeProject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes P3_MergeProject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = P3_MergeProject_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function lbx_MergeProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbx_MergeProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in lbx_MergeProject.
function lbx_MergeProject_Callback(hObject, eventdata, handles)
% hObject    handle to lbx_MergeProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbx_MergeProject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbx_MergeProject


% --- Executes on button press in psb_Merge.
function psb_Merge_Callback(hObject, eventdata, handles)
% hObject    handle to psb_Merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edt_Name_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Name as text
%        str2double(get(hObject,'String')) returns contents of edt_Name as a double



function edt_Operator_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Operator as text
%        str2double(get(hObject,'String')) returns contents of edt_Operator as a double


% --- Executes during object creation, after setting all properties.
function edt_Comment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_Comment_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Comment as text
%        str2double(get(hObject,'String')) returns contents of edt_Comment as a double


% --- Executes on button press in psb_Cancel.
function psb_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to psb_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in psb_Add.
function psb_Add_Callback(hObject, eventdata, handles)
% hObject    handle to psb_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in psb_Remove.
function psb_Remove_Callback(hObject, eventdata, handles)
% hObject    handle to psb_Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


