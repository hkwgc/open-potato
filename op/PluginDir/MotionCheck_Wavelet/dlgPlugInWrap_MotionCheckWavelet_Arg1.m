function varargout = dlgPlugInWrap_MotionCheckWavelet_Arg1(varargin)
% Last Modified by GUIDE v2.5 22-Feb-2007 14:03:19

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
                   'gui_OpeningFcn', @dlgPlugInWrap_MotionCheckWavelet_Arg1_OpeningFcn, ...
                   'gui_OutputFcn',  @dlgPlugInWrap_MotionCheckWavelet_Arg1_OutputFcn, ...
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

% --- Executes just before dlgPlugInWrap_MotionCheckWavelet_Arg1 is made visible.
function dlgPlugInWrap_MotionCheckWavelet_Arg1_OpeningFcn(hObject, eventdata, handles, varargin)
H=handles;
H.output = [];
guidata(hObject, H);

[bdata, bhdata] = scriptMeval(varargin{2},'bdata','bhdata');
if iscell(bdata)
	if size(bdata)==[1 1]
		bdata=bdata{1};bhdata=bhdata{1};
	else
		errordlg({'Data size error !','Only single file is available.'},'TDDICA Data ERROR');
		return;
	end
end
setappdata(H.figure1,'bdata',bdata);
setappdata(H.figure1,'bhdata',bhdata);
set(H.ppmKind,'string',bhdata.TAGs.DataTag);
if isfield(varargin{1},'argData')
	A=varargin{1}.argData;
	set(H.ppmKind,'value',A.Kind);
	set(H.edtSC,'string',A.SC);
	set(H.edtTH,'string',A.TH);
end

uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = dlgPlugInWrap_MotionCheckWavelet_Arg1_OutputFcn(hObject, eventdata, handles)
try
	varargout{1} = handles.output;
	uiresume(handles.figure1);
	D=getappdata(gcf,'D');
	if isfield(D,'cFIGs')
		for i=1:length(D.cFIGs)
			try
				close(D.cFIGs(i));
			catch,end
		end
	end
	delete(handles.figure1);
catch,  
	varargout{1}=[];
end;

function btnTest_Callback(hObject, eventdata, handles)
% Test
D=getappdata(handles.figure1,'D');

bdata=getappdata(handles.figure1,'bdata');
bhdata=getappdata(handles.figure1,'bhdata');
D=getappdata(handles.figure1,'D');

SC=str2num(get(handles.edtSC,'string'));
TH=str2num(get(handles.edtTH,'string'));
KD=get(handles.ppmKind,'value');
CH=str2num(get(handles.edtCH,'string'));

bhdata0=bhdata;
bhdata.flag=bhdata.flag(:,:,CH);
[bhdata,h_fig]=uc_MotionCheck_Wavelet(bdata(:,:,CH,:),bhdata,SC,TH,KD,...
	str2num(get(handles.edtTestScale,'string')),get(handles.ppmDispM,'value'));

if ~isfield(D,'cFIGs'),D.cFIGs=[];end
%D.cFIGs(end+1)=figure;
if exist('h_fig','var'), 
	D.cFIGs=[D.cFIGs h_fig];
end    

% % show result bar graph
% if get(handles.ppmDispM,'value')==1% channel order
% 	bar(~squeeze(bhdata.flag)','stacked');axis tight;shading faceted;set(gca,'xticklabel',num2str(CH'),'XTickLabelMode','Auto');
%     xlabel('Channel');ylabel('Block');
% else %block order
% 	bar(sum(~bhdata.flag,3));axis tight;
%     xlabel('Block number');ylabel('survived channel number')
% end
setappdata(handles.figure1,'D',D);


function figure1_CreateFcn(hObject, eventdata, handles)
% on Create
% D.hFig=figure('numbertitle','off','resize','on');
% setappdata(handles.figure1,'D',D);


function pushbutton2_Callback(hObject, eventdata, handles)
% OK
H=handles;
D=getappdata(H.figure1,'D');
RET.Kind=get(H.ppmKind,'value');
RET.SC=get(H.edtSC,'string');
RET.TH=get(H.edtTH,'string');
H.output = RET;

D=getappdata(handles.figure1,'D');
%if isfield(D,'cFIGs'),close(D.cFIGs(find(ishandle(D.cFIGs))));end% close Opened Figure(s)
%close(findobj('TAG','MotionCheckWavelet'));
guidata(hObject, H);
uiresume(H.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% on Close
D=getappdata(handles.figure1,'D');
if isfield(D,'cFIGs'),
    for k=1:size(D.cFIGs,2),try,close(D.cFIGs(k));end;end% close Opened Figure(s)
end
close(findobj('TAG','MotionCheckWavelet'));
delete(hObject);  

% --- Executes on selection change in ppmMode.
function ppmMode_Callback(hObject, eventdata, handles)
% Mode Select
H=handles;
HL=[];
switch get(H.ppmMode,'value')
	case 1 % all ICs as Channel data
		HL(end+1)=H.edtCompNum;
		HL(end+1)=H.text2;
		HL(end+1)=H.pushbutton3;
		set(HL,'enable','off');
	case 2% Add ICs as Kind
		HL(end+1)=H.edtCompNum;
		HL(end+1)=H.text2;
		set(HL,'enable','on');HL=[];
		HL(end+1)=H.pushbutton3;
		set(HL,'enable','off');
	case 3% Recon
		HL(end+1)=H.edtCompNum;
		HL(end+1)=H.text2;
		HL(end+1)=H.pushbutton3;
		set(HL,'enable','on');
end



% --- Executes during object creation, after setting all properties.
function edtTestScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTestScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtTestScale_Callback(hObject, eventdata, handles)
% hObject    handle to edtTestScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTestScale as text
%        str2double(get(hObject,'String')) returns contents of edtTestScale as a double


