function varargout = P3P_saveMeanvalueTexFiledlg(varargin)
% P3P_SAVEMEANVALUETEXFILEDLG M-file for P3P_saveMeanvalueTexFiledlg.fig
%      P3P_SAVEMEANVALUETEXFILEDLG, by itself, creates a new P3P_SAVEMEANVALUETEXFILEDLG or raises the existing
%      singleton*.
%
%      H = P3P_SAVEMEANVALUETEXFILEDLG returns the handle to a new P3P_SAVEMEANVALUETEXFILEDLG or the handle to
%      the existing singleton*.
%
%      P3P_SAVEMEANVALUETEXFILEDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in P3P_SAVEMEANVALUETEXFILEDLG.M with the given input arguments.
%
%      P3P_SAVEMEANVALUETEXFILEDLG('Property','Value',...) creates a new P3P_SAVEMEANVALUETEXFILEDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before P3P_saveMeanvalueTexFiledlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to P3P_saveMeanvalueTexFiledlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help P3P_saveMeanvalueTexFiledlg

% Last Modified by GUIDE v2.5 07-Jul-2010 10:21:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3P_saveMeanvalueTexFiledlg_OpeningFcn, ...
                   'gui_OutputFcn',  @P3P_saveMeanvalueTexFiledlg_OutputFcn, ...
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


% --- Executes just before P3P_saveMeanvalueTexFiledlg is made visible.
function P3P_saveMeanvalueTexFiledlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to P3P_saveMeanvalueTexFiledlg (see VARARGIN)

% Choose default command line output for P3P_saveMeanvalueTexFiledlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%---
if isfield(varargin{1},'period')
    set(handles.edtPeriod,'String',varargin{1}.period);
    set(handles.edtFile,'String',varargin{1}.filename);
end

% UIWAIT makes P3P_saveMeanvalueTexFiledlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

    

% --- Outputs from this function are returned to the command line.
function varargout = P3P_saveMeanvalueTexFiledlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1);


% --- Executes during object creation, after setting all properties.
function edtPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to edtPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPeriod as text
%        str2double(get(hObject,'String')) returns contents of edtPeriod as a double


% --- Executes during object creation, after setting all properties.
function edtFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtFile_Callback(hObject, eventdata, handles)

% --- Executes on button press in btnFile.
function btnFile_Callback(hObject, eventdata, handles)
[f p]=uiputfile({'*.txt;*.csv','text file (*.txt, *.csv)';'*.*','All files (*.*)'});
if f~=0
    set(handles.edtFile,'String', [p f]);
end


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
handles.output=[];
handles.output.period=get(handles.edtPeriod,'String');
handles.output.filename=get(handles.edtFile,'String');
guidata(hObject,handles);
%varargout{1}=get(handles.edtPeriod,'String');
%varargout{2}=get(handles.edtFile,'String');
uiresume(handles.figure1);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)

uiresume(handles.figure1);
