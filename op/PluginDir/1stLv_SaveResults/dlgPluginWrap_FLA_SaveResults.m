function varargout = dlgPluginWrap_FLA_SaveResults(varargin)
% DLGPLUGINWRAP_FLA_SAVERESULTS M-file for dlgPluginWrap_FLA_SaveResults.fig
%      DLGPLUGINWRAP_FLA_SAVERESULTS, by itself, creates a new DLGPLUGINWRAP_FLA_SAVERESULTS or raises the existing
%      singleton*.
%
%      H = DLGPLUGINWRAP_FLA_SAVERESULTS returns the handle to a new DLGPLUGINWRAP_FLA_SAVERESULTS or the handle to
%      the existing singleton*.
%
%      DLGPLUGINWRAP_FLA_SAVERESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DLGPLUGINWRAP_FLA_SAVERESULTS.M with the given input arguments.
%
%      DLGPLUGINWRAP_FLA_SAVERESULTS('Property','Value',...) creates a new DLGPLUGINWRAP_FLA_SAVERESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dlgPluginWrap_FLA_SaveResults_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dlgPluginWrap_FLA_SaveResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dlgPluginWrap_FLA_SaveResults

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% Last Modified by GUIDE v2.5 21-Jul-2003 20:03:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dlgPluginWrap_FLA_SaveResults_OpeningFcn, ...
                   'gui_OutputFcn',  @dlgPluginWrap_FLA_SaveResults_OutputFcn, ...
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


% --- Executes just before dlgPluginWrap_FLA_SaveResults is made visible.
function dlgPluginWrap_FLA_SaveResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dlgPluginWrap_FLA_SaveResults (see VARARGIN)

% Choose default command line output for dlgPluginWrap_FLA_SaveResults
H=handles;
H.output = [];
guidata(hObject, H);

[chdata, bhdata] = scriptMeval(varargin{2},'chdata','bhdata');

if isempty(chdata)
	warndlg('??? chdata is empty!');return
end

CHNUM=size(chdata{1}.flag,3);

if isempty(bhdata)
	if iscell(chdata)
		if size(chdata)==[1 1]
			RES=chdata{1}.Results;
		else
			errordlg({'Data size error !','Only single file is available.'},'TDDICA Data ERROR');
			return;
		end
	end
else
	RES=bhdata.Results;
end

S=POTATo_sub_CheckStruct (RES,CHNUM);
% sz=size(chdata{1}.flag,2);
% S=cat(2,S,POTATo_sub_CheckStruct (RES,sz));
% if ~isempty(bhdata)
% 	sz=size(bhdata.stimTC,2);
% 	S=cat(2,S,POTATo_sub_CheckStruct (RES,sz));
% end

set(H.lbxList,'string',S);
flgS=zeros(1,length(S));
setappdata(H.figure1,'flgS',flgS);

set(H.txtSel,'string',sprintf('selected 0/%d',length(S)));

uiwait(handles.figure1);% wait


% --- Outputs from this function are returned to the command line.
function varargout = dlgPluginWrap_FLA_SaveResults_OutputFcn(hObject, eventdata, handles)

try
	varargout{1} = handles.output;
	uiresume(handles.figure1);
	delete(handles.figure1);
catch, 
	varargout{1}=[];
end;

% Button OK
function pushbutton1_Callback(hObject, eventdata, handles)

H=handles;
flgS=getappdata(H.figure1,'flgS');
v=get(H.lbxList,'value');
S=cellstr(get(H.lbxList,'string'));

A.ITEMs=[];
sstr=' <--------------- SELECTED';
for i=find(flgS)
	tmp=S{i};
	A.ITEMs{end+1}=tmp(1:end-length(sstr));
end
handles.output=A;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on selection change in lbxList.
function lbxList_Callback(hObject, eventdata, handles)

H=handles;
flgS=getappdata(H.figure1,'flgS');
mv=get(hObject,'value');
S=cellstr(get(hObject,'string'));

sstr=' <--------------- SELECTED';
for i=1:length(mv)
	v=mv(i);
	tmp=S{v};
	if flgS(v)
		S{v}=tmp(1:end-length(sstr));
	else
		S{v}=[tmp sstr];
	end
	flgS(v)=( flgS(v)==0 );
end
	
set(H.lbxList,'string',S);
set(H.txtSel,'string',sprintf('selected %d/%d',sum(flgS),length(S)));

setappdata(H.figure1,'flgS',flgS);

