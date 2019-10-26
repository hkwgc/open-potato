function varargout = UI_INNERKEY_Cp2CB(varargin)
% UI_INNERKEY_Cp2CB M-file for UI_INNERKEY_Cp2CB.fig
%      UI_INNERKEY_Cp2CB, by itself, creates a new UI_INNERKEY_Cp2CB or raises the existing
%      singleton*.
%
%      H = UI_INNERKEY_Cp2CB returns the handle to a new UI_INNERKEY_Cp2CB or the handle to
%      the existing singleton*.
%
%      UI_INNERKEY_Cp2CB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI_INNERKEY_Cp2CB.M with the given input arguments.
%
%      UI_INNERKEY_Cp2CB('Property','Value',...) creates a new UI_INNERKEY_Cp2CB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UI_INNERKEY_Cp2CB_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UI_INNERKEY_Cp2CB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI_INNERKEY_Cp2CB

% Last Modified by GUIDE v2.5 12-May-2007 22:03:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UI_INNERKEY_Cp2CB_OpeningFcn, ...
                   'gui_OutputFcn',  @UI_INNERKEY_Cp2CB_OutputFcn, ...
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


% --- Executes just before UI_INNERKEY_Cp2CB is made visible.
function UI_INNERKEY_Cp2CB_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for UI_INNERKEY_Cp2CB
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
Group=varargin{1};
GPD=varargin{2};

if length(GPD)~=1, warndlg('GPD length is not 1. please check.');end
if ~isfield(GPD,'DataTags'), warndlg('GPD.DataTags not found. please check.');end

set(handles.lbxG1,'String',GPD.DataTags);
set(handles.txtG1,'string',sprintf('total: %d',length(GPD.DataTags)));

dpt=0;
for i=1:length(GPD.DataTags)
	s=GPD.DataTags{i};
	pos=findstr(s,'.');
	if isempty(pos), warndlg('no structuer in results. please check.','SLA error');return;end
	if dpt<length(pos)+1, dpt=length(pos)+1;end
end

F=cell(1,dpt);
Ftg=cell(1,dpt);
for i=1:length(GPD.DataTags)
	s=GPD.DataTags{i};
	pos=findstr(s,'.');
	if isempty(pos), warndlg('no structuer in results. please check.','SLA error');return;end
	pos1=[1 pos+1];
	pos2=[pos-1 length(s)];
	for j=1:length(pos1)
		num=strcmp(F{j},s(pos1(j):pos2(j)));
		if ~(num)
			F{j}{end+1}=s(pos1(j):pos2(j));
			Ftg{j}{end+1}=i;
		else
			Ftg{j}{num}(end+1)=i;
		end
	end
	GPD.F=F;
	GPD.Ftg=Ftg;
end

s=[];for i=1:dpt,s{end+1}=sprintf('Field #%d',i);end
set(handles.lbxFNum,'string',s);
set(handles.lbxFName,'string',GPD.F{1});

setappdata(handles.figure1, 'Group', Group);
setappdata(handles.figure1, 'GPD', GPD);

% UIWAIT makes UI_INNERKEY_Cp2CB wait for user response (see UIRESUME)
 uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = UI_INNERKEY_Cp2CB_OutputFcn(hObject, eventdata, handles) 
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


function btnOK_Callback(hObject, eventdata, handles)
H=handles;
GPD=getappdata(H.figure1,'GPD');
H.output=GPD;
guidata(hObject, H);
uiresume(H.figure1);

function btnToCB_Callback(hObject, eventdata, handles)
H=handles;
Group=getappdata(H.figure1,'Group');
GPD=getappdata(H.figure1,'GPD');
% make strings for clipboard
D=[];
for i=GPD.Selected
    F=GPD.DataPoss{i}.FileNum;
    P=GPD.DataPoss{i}.DataPos;
    for j=1:length(P)
        D=[D sprintf('%s\t',GPD.DataTags{i}) ...
            sprintf('%f\t',Group.fdata{F}(:,P(j))) sprintf('\n')];
    end
end
clipboard('copy',D); %To Clipboard!

function lbxFNum_Callback(hObject, eventdata, handles)
H=handles;
GPD=getappdata(H.figure1,'GPD');

set(H.lbxFName,'value',1);
set(H.lbxFName,'string',GPD(1).F{get(H.lbxFNum,'value')});


% --- Executes on selection change in lbxFiltering.
function lbxFiltering_Callback(hObject, eventdata, handles)

function rdb1_Callback(hObject, eventdata, handles)
% logic mode change

set(handles.rdbAND,'value',0);
set(handles.rdbOR,'value',0);
set(hObject,'value',1);

function btnRemove_Callback(hObject, eventdata, handles)
% Remove filtering item
H=handles;
GPD=getappdata(H.figure1,'GPD');
v=get(H.lbxFiltering,'value');
s=cellstr(get(H.lbxFiltering,'string'));

if v==0, return;end

n=ones(1,length(s));n(v)=0;
n=find(n);
if isempty(n)
	s='';
	if isfield(GPD,'Filtering'),
		GPD=rmfield(GPD,'Filtering');
	end
	%set(H.lbxFiltering,'value',1);
else
	s=s(n);
	GPD.Filtering=GPD.Filtering(n,:);
	

end

if v>length(s) && ~isempty(s)
	v=v-1;
	set(H.lbxFiltering,'value',v);
end
set(H.lbxFiltering,'string',s);
setappdata(handles.figure1, 'GPD', GPD); % save

% update
if ~isempty(n)
	% filtering execute
	FilteringExecute(handles)
end


function btnFAdd_Callback(hObject, eventdata, handles)
% Filtering ADD
H=handles;
GPD=getappdata(H.figure1,'GPD');
nF=get(H.lbxFNum,'value');
sN0=get(H.lbxFName,'string');
nN=get(H.lbxFName,'value');

if get(H.rdbAND,'value'), sLG=' -><- ';else sLG=' <--> ';end
if get(H.cbxNOT,'value'), sLG2='[NOT]';else sLG2='';end

S=get(H.lbxFiltering,'string');
if ~isfield(GPD,'Filtering'), GPD=setfield(GPD,'Filtering',[]);end
for i=nN
	sN=sN0{i};
	s=sprintf('%s Filed#%d: %s %s',sLG, nF, sN, sLG2);
	S{end+1}=s;
	GPD.Filtering(end+1,:)=[nF,i,strcmp(sLG,' -><- '),~isempty(sLG2)];% [Filed#,Member#,Logic(1:AND 0:OR),Logic(1:NOT)]
end
set(H.lbxFiltering,'string',S);
set(H.lbxFiltering,'value',length(S));

setappdata(handles.figure1, 'GPD', GPD); % save

% filtering execute
FilteringExecute(handles)

%=====================================================================
function FilteringExecute(handles)
H=handles;
GPD=getappdata(H.figure1,'GPD');

%selectflag=ones(1,size(GPD.fdata{1},2));
selectflag=zeros(1,length(GPD.DataTags));
num1=ones(size(selectflag));

for i=1:size(GPD.Filtering,1)
	n=GPD.Filtering(i,:);
	sF=GPD.F{n(1)}{n(2)};
	Ftg=GPD.Ftg{n(1)}{n(2)};
	
	if n(4)==1 % NOT
		filtertag=num1;
		filtertag(Ftg)=0;
	else 
		filtertag=num1*0;
		filtertag(Ftg)=1;
	end
	
	if n(3)==1 % AND
		
		selectflag=selectflag & filtertag;
	elseif n(3)==0 % OR
		selectflag=selectflag | filtertag;
	end
end

GPD.Selected=find(selectflag);
setappdata(handles.figure1, 'GPD', GPD); % save

%set(H.lbxG2,'string',GPD.fhdata{1}.DataTag(selectflag));
set(H.lbxG2,'string',GPD.DataTags(selectflag));
set(H.txtG2,'string',sprintf('%d/%d selected.', sum(selectflag), length(selectflag)));
	
	


