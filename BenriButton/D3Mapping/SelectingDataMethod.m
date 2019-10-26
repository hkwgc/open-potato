function varargout = SelectingDataMethod(varargin)
% SELECTINGDATAMETHOD M-file for SelectingDataMethod.fig
%      SELECTINGDATAMETHOD, by itself, creates a new SELECTINGDATAMETHOD or raises the existing
%      singleton*.
%
%      H = SELECTINGDATAMETHOD returns the handle to a new SELECTINGDATAMETHOD or the handle to
%      the existing singleton*.
%
%      SELECTINGDATAMETHOD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTINGDATAMETHOD.M with the given input arguments.
%
%      SELECTINGDATAMETHOD('Property','Value',...) creates a new SELECTINGDATAMETHOD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectingDataMethod_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectingDataMethod_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectingDataMethod

% Last Modified by GUIDE v2.5 04-Feb-2010 17:53:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectingDataMethod_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectingDataMethod_OutputFcn, ...
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


% --- Executes just before SelectingDataMethod is made visible.
function SelectingDataMethod_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectingDataMethod (see VARARGIN)

% Choose default command line output for SelectingDataMethod
handles.output = hObject;

set(handles.figure1,'CloseRequestFcn',{@close_Callback,handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectingDataMethod wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectingDataMethod_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
SelectedMethod=getCurrentPosHandler(handles);
varargout{1} = getappdata(handles.figure1,'OK_cancel');
varargout{2} = SelectedMethod;
delete(get(0,'CurrentFigure'));

function exclusive_rdb(h,hs)
% Radio-Button On/Off control
set([hs.First,hs.Second,hs.Average],'Value',0);
set(h,'Value',1);

function ret=getCurrentPosHandler(hs)
% get Current Position [Nz, AL, ...]
rdb_hs=[hs.First,hs.Second,hs.Average];
for ii=1:length(rdb_hs)
    if (get(rdb_hs(ii),'Value')==1)
        ret = ii;
        return;
    end
end
ret = 0;
return;

% --- Executes on button press in First.
function First_Callback(hObject, eventdata, handles)
% hObject    handle to First (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of First
exclusive_rdb(hObject,handles);

% --- Executes on button press in Second.
function Second_Callback(hObject, eventdata, handles)
% hObject    handle to Second (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Second
exclusive_rdb(hObject,handles);

% --- Executes on button press in Average.
function Average_Callback(hObject, eventdata, handles)
% hObject    handle to Average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Average
exclusive_rdb(hObject,handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.figure1,'OK_cancel','OK');
uiresume




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.figure1,'OK_cancel','cancel');
uiresume;

function varargout = close_Callback(hObject, eventdata, handles)
setappdata(handles.figure1,'OK_cancel','cancel');
uiresume;


