function varargout = UserInfo(varargin)
% USERINFO M-file for UserInfo.fig
%      USERINFO, by itself, creates a new USERINFO or raises the existing
%      singleton*.
%
%      H = USERINFO returns the handle to a new USERINFO or the handle to
%      the existing singleton*.
%
%      USERINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERINFO.M with the given input arguments.
%
%      USERINFO('Property','Value',...) creates a new USERINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserInfo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserInfo

% Last Modified by GUIDE v2.5 03-Feb-2010 15:27:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInfo_OutputFcn, ...
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


% --- Executes just before UserInfo is made visible.
function UserInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInfo (see VARARGIN)

% Choose default command line output for UserInfo
handles.output = hObject;

if(nargin > 3)
  for index=1:2:(nargin-3),
    if nargin-3==index, break, end
    switch lower(varargin{index})
      case 'name'
        set(handles.Name,'String',varargin{index+1});
      case 'id'
        set(handles.ID,'String',varargin{index+1});
      case 'sex'
        if(strcmp(varargin{index+1},'Male') )
          set(handles.Sex,'Value',1);
        else
          set(handles.Sex,'Value',2);
        end
      case 'age'
        set(handles.Age,'String',varargin{index+1});
      case 'comment'
        set(handles.Comment,'String',varargin{index+1});
    end
  end
end

%set(handles.figure1,'CloseRequestFcn','closereq');
set(handles.figure1,'CloseRequestFcn',{@close_Callback,handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserInfo wait for user response (see UIRESUME)
uiwait(handles.figure1);

function varargout = close_Callback(hObject, eventdata, handles)
setappdata(handles.figure1,'OK_cancel','cancel');
uiresume;

% --- Outputs from this function are returned to the command line.
function varargout = UserInfo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = getappdata(handles.figure1,'OK_cancel');
varargout{2} = get(handles.Name,'String');
varargout{3} = get(handles.ID,'String');
%varargout{4} = get(handles.Sex,'String');
if(get(handles.Sex,'Value')==1)
  varargout{4} = 'Male';
else
  varargout{4} = 'Female';
end
varargout{5} = get(handles.Age,'String');
varargout{6} = get(handles.Comment,'String');
delete(get(0,'CurrentFigure'));

% --- Executes during object creation, after setting all properties.
function Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Name_Callback(hObject, eventdata, handles)
% hObject    handle to Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Name as text
%        str2double(get(hObject,'String')) returns contents of Name as a double


% --- Executes during object creation, after setting all properties.
function ID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ID_Callback(hObject, eventdata, handles)
% hObject    handle to ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ID as text
%        str2double(get(hObject,'String')) returns contents of ID as a double


% --- Executes on button press in Sex.
function Sex_Callback(hObject, eventdata, handles)
% hObject    handle to Sex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sex


% --- Executes during object creation, after setting all properties.
function Age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Age_Callback(hObject, eventdata, handles)
% hObject    handle to Age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Age as text
%        str2double(get(hObject,'String')) returns contents of Age as a double
string_value = get(hObject,'String');
[value,OK] = str2num(string_value);
if(OK==0)
  set(hObject,'String','0');
end


% --- Executes during object creation, after setting all properties.
function Comment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Comment_Callback(hObject, eventdata, handles)
% hObject    handle to Comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Comment as text
%        str2double(get(hObject,'String')) returns contents of Comment as a double


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
uiresume




