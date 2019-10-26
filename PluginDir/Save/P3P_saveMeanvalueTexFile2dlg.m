function varargout = P3P_saveMeanvalueTexFile2dlg(varargin)
% P3P_SAVEMEANVALUETEXFILE2DLG M-file for P3P_saveMeanvalueTexFile2dlg.fig

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3P_saveMeanvalueTexFile2dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @P3P_saveMeanvalueTexFile2dlg_OutputFcn, ...
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


function P3P_saveMeanvalueTexFile2dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for P3P_saveMeanvalueTexFile2dlg
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%--- set values
if ( nargin>3 ) && ( isfield(varargin{1},'periodList') )
    set(handles.edtSaveFileName,'String',varargin{1}.filename);
	set(handles.ppmKind,'value',varargin{1}.kind);
	set(handles.lbxPeriods,'String',varargin{1}.periodList);
	set(handles.cbxAOT,'value',varargin{1}.cbxAOT);
	set(handles.cbxOption,'value',varargin{1}.cbxOption);
	set(handles.ppmOption,'value',varargin{1}.ppmOption);	
	set(handles.cbxChOrder,'value',varargin{1}.cbxChOrder);
	setappdata(handles.figure1,'ChOrder',varargin{1}.ChOrderVal);
end

%-- get kind name from hdata
[hdata] = scriptMeval(varargin{2},'hdata');
set(handles.ppmKind,'String',hdata.TAGs.DataTag);

% UIWAIT makes P3P_saveMeanvalueTexFile2dlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

function btnAdd_Callback(hObject, eventdata, handles)
p1=get(handles.edtPeriodST,'string');
p2=get(handles.edtPeriodED,'string');

%-check
if isempty(p1) || isempty(p2)
	warndlg('enter start and end time.');
	return;
end
try
	t1=str2double(p1);
	t2=str2double(p2);
catch
	warndlg('enter Numeric value.');
	return;
end
if isnan(t1) || isnan(t2)
	warndlg('enter Numeric value.');
	return;
end

S=get(handles.lbxPeriods,'String');
S{end+1} = sprintf('%s to %s',p1,p2);
set(handles.lbxPeriods,'String',S);

% --- Executes on button press in btnDel.
function btnDel_Callback(hObject, eventdata, handles)
v=get(handles.lbxPeriods,'value');
S=get(handles.lbxPeriods,'String');
if v>1
	s1=S(1:v-1);
else
	s1=[];
end
if iscell(S) && ( v<length(S))
	s2=S(v+1:end);
else
	s2=[];
	set(handles.lbxPeriods,'value',max([1 v-1]));
end
set(handles.lbxPeriods,'String',[s1; s2]);



% --- Executes on button press in cbxAOT.
function cbxAOT_Callback(hObject, eventdata, handles)


function btnOK_Callback(hObject, eventdata, handles)
handles.output=[];
handles.output.filename=get(handles.edtSaveFileName,'String');
handles.output.kind=get(handles.ppmKind,'value');
handles.output.periodList=get(handles.lbxPeriods,'String');
handles.output.cbxAOT=get(handles.cbxAOT,'value');
handles.output.cbxOption=get(handles.cbxOption,'value');
handles.output.ppmOption=get(handles.ppmOption,'value');
handles.output.cbxChOrder=get(handles.cbxChOrder,'value');
handles.output.ChOrderVal=getappdata(handles.figure1,'ChOrder');
guidata(hObject,handles);
uiresume(handles.figure1);

function btnCancel_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = P3P_saveMeanvalueTexFile2dlg_OutputFcn(hObject, eventdata, handles)

if ~isempty(handles)
	varargout{1} = handles.output;
	close(handles.figure1);
else
	varargout{1}=[];
end

% --- Executes during object creation, after setting all properties.
function ppmKind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmKind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ppmKind.
function ppmKind_Callback(hObject, eventdata, handles)
% hObject    handle to ppmKind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ppmKind contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppmKind


% --- Executes during object creation, after setting all properties.
function edtSaveFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtSaveFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edtSaveFileName_Callback(hObject, eventdata, handles)

% --- Executes on button press in btnSelectFile.
function btnSelectFile_Callback(hObject, eventdata, handles)
[f p]=uiputfile({'*.txt;*.csv','text file (*.txt, *.csv)';'*.*','All files (*.*)'});
if isequal(f,0) || isequal(p,0)
	return
else
	set(handles.edtSaveFileName,'String', [p,f]);
end


% --- Executes during object creation, after setting all properties.
function edtPeriodST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPeriodST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtPeriodST_Callback(hObject, eventdata, handles)
% hObject    handle to edtPeriodST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPeriodST as text
%        str2double(get(hObject,'String')) returns contents of edtPeriodST as a double


% --- Executes during object creation, after setting all properties.
function edtPeriodED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPeriodED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtPeriodED_Callback(hObject, eventdata, handles)
% hObject    handle to edtPeriodED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPeriodED as text
%        str2double(get(hObject,'String')) returns contents of edtPeriodED as a double


% --- Executes during object creation, after setting all properties.
function lbxPeriods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbxPeriods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in lbxPeriods.
function lbxPeriods_Callback(hObject, eventdata, handles)
% hObject    handle to lbxPeriods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbxPeriods contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbxPeriods


% --- Executes on button press in btnAdd.

% --- Executes on button press in cbxOption.
function cbxOption_Callback(hObject, eventdata, handles)
% hObject    handle to cbxOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbxOption


% --- Executes during object creation, after setting all properties.
function ppmOption_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ppmOption.
function ppmOption_Callback(hObject, eventdata, handles)
% hObject    handle to ppmOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ppmOption contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppmOption


% --- Executes on button press in cbxChOrder.
function cbxChOrder_Callback(hObject, eventdata, handles)

if get(hObject,'value')
	h=getappdata(handles.figure1,'ChOrder');
	if isempty(h)
		h=inputdlg('Input channel order','Channel Order Change');
	else
		h=inputdlg('Input channel order','Channel Order Change',1,h);
	end
	setappdata(handles.figure1,'ChOrder',h);
end
