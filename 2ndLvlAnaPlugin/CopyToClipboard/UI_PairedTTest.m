function varargout = UI_PairedTTest(varargin)
% UI_PAIREDTTEST M-file for UI_PairedTTest.fig
%      UI_PAIREDTTEST, by itself, creates a new UI_PAIREDTTEST or raises the existing
%      singleton*.
%
%      H = UI_PAIREDTTEST returns the handle to a new UI_PAIREDTTEST or the handle to
%      the existing singleton*.
%
%      UI_PAIREDTTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI_PAIREDTTEST.M with the given input arguments.
%
%      UI_PAIREDTTEST('Property','Value',...) creates a new UI_PAIREDTTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UI_PairedTTest_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UI_PairedTTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI_PairedTTest

% Last Modified by GUIDE v2.5 26-Apr-2007 18:25:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UI_PairedTTest_OpeningFcn, ...
                   'gui_OutputFcn',  @UI_PairedTTest_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before UI_PairedTTest is made visible.
function UI_PairedTTest_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for UI_PairedTTest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
GPD=varargin{1};
if length(GPD)~=2, 
	warndlg('Please select [ 2 groups ].');
	return;
end

GPD(1).FileNum=length(GPD(1).fdata);
GPD(2).FileNum=length(GPD(2).fdata);

% FD=fieldnames(GPD.fhdata{1}.Results.SimpleT_Test);
% for i=1:GPD.FileNum
% 	for j=1:length(FD)
% 		eval(['tmp=GPD.fhdata{i}.Results.SimpleT_Test.' FD{j} ';']);
% 		eval(['GPD.R.' FD{j} '{i}=tmp;']);
% 	end
% end

% % mean over all
% FD=fieldnames(GPD.R);
% for i=1:length(FD)
% 	tmp=eval(['GPD.R.' FD{i}]);
% 	FD2=fieldnames(eval(['GPD.R.' FD{i} '{1}']));
% 	for j=1:length(FD2)
% 		if ~iscell(eval(['GPD.R.' FD{i} '{1}.' FD2{j}]))
% 			tmp=[];
% 			for k=1:GPD.FileNum
% 				tmp(k,:)=eval(['GPD.R.' FD{i} sprintf('{%d}.',k) FD2{j}]);
% 			end
% 			eval(['GPD.mR.' FD{i} '_' FD2{j} '=mean(tmp,1);']);
% 		end
% 	end
% end
for i=1:2
	GPD(i).DataTags=[];
	GPD(i).DataPoss=[];
	%make new DataTag
	for j0=1:GPD(i).FileNum
		str=GPD(i).fhdata{j0}.DataTag(:);
		for j=1:length(str)
			GPD(i).DataTags{end+1}=sprintf('FILE%d.%s',j0,str{j});
			GPD(i).DataPoss{end+1}.FileNum=j0;
			GPD(i).DataPoss{end}.DataPos=GPD(i).fhdata{j0}.DataPos{j};			
		end
	end
% 	for j0=1:GPD(i).FileNum
% 		%make new DataTag
% 		
% 		str=GPD(i).fhdata{j0}.DataTag(:);
% 		for j=1:length(str)
% 			S{end+1}=sprintf('%03d: File%d.%s',j,j0,str{j});
% 			GPD(i).fhdata{j0}.DataTag{j}=sprintf('File%d.%s',j0,str{j});
% 		end
% 	end
	set(eval(sprintf('handles.lbxG%d',i)),'String',GPD(i).DataTags);
	set(eval(sprintf('handles.txtG%d',i)),'string',sprintf('total: %d',length(str)));
end


setappdata(handles.figure1, 'GPD', GPD);

% UIWAIT makes UI_PairedTTest wait for user response (see UIRESUME)
 uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = UI_PairedTTest_OutputFcn(hObject, eventdata, handles) 
try
	varargout{1} = handles.output;
	uiresume(handles.figure1);
	delete(handles.figure1);
catch, 
	varargout{1}=[];
end;


% --- Executes on button press in btnTest.
function btnTest_Callback(hObject, eventdata, handles)
% hObject    handle to btnTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function btnExit_Callback(hObject, eventdata, handles)

guidata(hObject, handles);
uiresume(handles.figure1);

function lbxFNum_Callback(hObject, eventdata, handles)
H=handles;
GPD=getappdata(H.figure1,'GPD');

set(H.lbxFName,'value',1);
set(H.lbxFName,'string',GPD(1).F{get(H.lbxFNum,'value')});

function btnSelect1_Callback(hObject, eventdata, handles)
% Select1
H=handles;
GPD=getappdata(H.figure1,'GPD');

GPD=UI_INNERKEY(GPD(1));




% --- Executes on selection change in lbxFiltering.
function lbxFiltering_Callback(hObject, eventdata, handles)
% hObject    handle to lbxFiltering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lbxFiltering contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbxFiltering

% --- Executes on button press in cbxNOT.
function cbxNOT_Callback(hObject, eventdata, handles)
% hObject    handle to cbxNOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbxNOT

% --- Executes on button press in cbxNOT.
function rdb1_Callback(hObject, eventdata, handles)

set(handles.rdbAND,'value',0);
set(handles.rdbOR,'value',0);
set(hObject,'value',1);


function btnFAdd_Callback(hObject, eventdata, handles)
% Filtering ADD
H=handles;
GPD=getappdata(H.figure1,'GPD');
nF=get(H.lbxFNum,'value');
sN0=get(H.lbxFName,'string');
nN=get(H.lbxFName,'value');

if get(H.rdbAND,'value'), sLG='+';else sLG='or';end
if get(H.cbxNOT,'value'), sLG2='[NOT]';else sLG2='';end

S=get(H.lbxFiltering,'string');
%if ~isfield(GPD(1),'Filtering'), 
for i=nN
	sN=sN0{i};
	s=sprintf('[%s]Filed#%d: %s %s',sLG, nF, sN, sLG2);
	S{end+1}=s;
	GPD.Filtering{end+1}
end
set(H.lbxFiltering,'string',S);



