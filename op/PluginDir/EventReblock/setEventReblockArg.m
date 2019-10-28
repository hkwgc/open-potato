function varargout = setEventReblockArg(varargin)
% SETEVENTREBLOCKARG M-file for setEventReblockArg.fig
%      SETEVENTREBLOCKARG by itself, creates a new SETEVENTREBLOCKARG or raises the
%      existing singleton*.
%
%      H = SETEVENTREBLOCKARG returns the handle to a new SETEVENTREBLOCKARG or the handle to
%      the existing singleton*.
%
%      SETEVENTREBLOCKARG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETEVENTREBLOCKARG.M with the given input arguments.
%
%      SETEVENTREBLOCKARG('Property','Value',...) creates a new SETEVENTREBLOCKARG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setEventReblockArg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setEventReblockArg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setEventReblockArg

% Last Modified by GUIDE v2.5 07-Nov-2005 13:41:01

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
                   'gui_OpeningFcn', @setEventReblockArg_OpeningFcn, ...
                   'gui_OutputFcn',  @setEventReblockArg_OutputFcn, ...
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

% --- Executes just before setEventReblockArg is made visible.
function setEventReblockArg_OpeningFcn(hObject, eventdata, handles, varargin)
argData   = [];
mfile_pre = '';

% get Default Argument-Data and 
% M-File to make Previous Block-Data.
if(nargin > 3)
	for index = 1:2:(nargin-3),
        if nargin-3==index break, end
        switch lower(varargin{index})
			case 'argdata'
				argData   = varargin{index+1};
			case 'mfile_pre'
				mfile_pre = varargin{index+1};
		end
	end
end

% Choose default command line output for setEventReblockArg
handles.output = [];
guidata(hObject, handles);

if isempty(mfile_pre),
	% need more data -> return [] and close.
	% See also Output function
	errordlg('No Mfile Exist');
	return;
end

set(handles.figure1,...
	'Units','normalized', ...
	'Position',[0, 0.05, 1, 0.8]);

try,
	make_axes(handles,mfile_pre);
	make_pop_stimKind(handles);

	if ~isempty(argData) && isstruct(argData),
		if isfield(argData,'kind'),
			kind= get(handles.pop_stimKind,'UserData');
			v   = find(kind==argData.kind);
			set(handles.pop_stimKind,'Value',v);
		end
		if isfield(argData,'pre'),
			set(handles.edt_pre, ...
				'UserData', argData.pre, ...
				'String', num2str(argData.pre));
		end
		if isfield(argData,'post'),
			set(handles.edt_post, ...
				'UserData', argData.post, ...
				'String', num2str(argData.post));
		end
	end	
	plot_area(handles);
catch,
	errordlg(lasterr);
	return;
end

% UIWAIT makes setEventReblockArg wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);


function varargout = setEventReblockArg_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
delete(handles.figure1);

% --- Executes on button press in psb_OK.
function psb_OK_Callback(hObject, eventdata, handles)
% OK button press
kind = get(handles.pop_stimKind,'UserData');
argData.kind = kind(get(handles.pop_stimKind,'Value'));

pre=get(handles.edt_pre,'UserData');
if isempty(pre), pre=1; end
argData.pre = pre;
pst=get(handles.edt_post,'UserData');
if isempty(pst), pst=1; end
argData.post = pst;

handles.output = argData;
guidata(hObject, handles);
uiresume(handles.figure1);

function psb_Cancel_Callback(hObject, eventdata, handles)
% Canncel button press
handles.output = [];
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
	uiresume(handles.figure1);
else
	delete(handles.figure1);
end

function figure1_KeyPressFcn(hObject, eventdata, handles)
if isequal(get(hObject,'CurrentKey'),'escape')
	% When "Escape" Key Pressed
	psb_Canncel_Callback(handles.psb_Cancel, [], handles);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
	% When "Retrun" Key Press
	psb_OK_Callback(handles.psb_OK, [], handles);
end    


function make_axes(handles,mfile_pre)
[data, hdata] = scriptMeval(mfile_pre, 'bdata', 'bhdata');
if isempty(data),
	error('No Block Data exist'); 
end
if ~isfield(hdata,'stimTC2'),
	error('No Stim-Data Exist');
end

setappdata(handles.figure1,'Header',hdata);
% setappdata(handles.figure1,'Data', data);

b      = size(data,1);
stimTC   = hdata.stimTC2;
ax_sz=[0.7, (0.8/b)];

ps = [0.2, (0.95-ax_sz(2))];
ps = [ps, ax_sz];
t  = 1:size(data,2);
t  = t' * hdata.samplingperiod/1000;
mx = max(stimTC(:));
for bid=1:b,
	figure(handles.figure1);
	tidx = find(stimTC(bid,:)~=0);
	axh(bid) = axes('Position',ps);
	plot(t(tidx),stimTC(bid,tidx),'rx');
	ax=zeros(1,4);
	ax(2)=t(end); ax(4)=mx;
	text(1, ax(4),['Block ' num2str(bid)]);
	ax(4)=ax(4)+0.5;
	ax(1)=0;ax(2)=t(end);
	axis(ax);
	ps(2) = ps(2) - ax_sz(2);
end
setappdata(handles.figure1,'AXES_HANDLER', axh);
return;

function plot_area(handles)

hd = getappdata(handles.figure1,'Header');
stimTC    = hd.stimTC2;

kind = get(handles.pop_stimKind,'UserData');
kind = kind(get(handles.pop_stimKind,'Value'));

t  = 1:size(stimTC,2);
t  = t' * hd.samplingperiod/1000;

pre=get(handles.edt_pre,'UserData');
if isempty(pre), pre=1; end
pst=get(handles.edt_post,'UserData');
if isempty(pst), pst=1; end

axh = getappdata(handles.figure1,'AXES_HANDLER');
arh = getappdata(handles.figure1,'AREA_HANDLER');
if ~isempty(arh),
	delete(arh);
end
arh=[];
y=[0; 0; 0.5; 0.5; 0];
for bid=1:size(stimTC,1),
	try,
		axes(axh(bid)); hold on;
		d = find(stimTC(bid,:) == kind);
		for idx=1:length(d),
			s = t(d(idx))-pre;
			e = t(d(idx))+pst;
			arh(end+1) = fill([s; e; e; s; s],y,[.5 .5 1]);
			set(arh(end),'EdgeColor',[0 .9 .9]);
			alpha(arh(end),0.5);
		end
	end
end
setappdata(handles.figure1,'AREA_HANDLER',arh);
% Plot - Selecting Area
return;

function pop_stimKind_Callback(hObject, eventdata, handles)
plot_area(handles);

function make_pop_stimKind(handles)
% Make StimKind Popup-Menu
hd = getappdata(handles.figure1,'Header');
stimTC    = hd.stimTC2;
stimTC    = stimTC(find(stimTC~=0));
stimTC    = round(stimTC);

mn = min(stimTC(:));
mx = max(stimTC(:));
ud = mn;
for dt=(mn+1):(mx-1)
	tmp=find(stimTC==dt);
	if ~isempty(tmp),
		ud(end+1)=dt;
	end
end
tmp=find(ud==mx);
if isempty(tmp),
	ud(end+1)=mx;
end

st={};
for dt=1:length(ud)
	st{end+1} = ['Stim : ' num2str(ud(dt))];
end	
if isempty(st),
	error('No Stim Data to select exist.'); 
else,
	set(handles.pop_stimKind, ...
		'String',st, ...
		'UserData', ud, ...
		'Value',1);
end
	
function edt_pre_Callback(hObject, eventdata, handles)
ck_stim(hObject,'Pre Stim',handles);
function edt_post_Callback(hObject, eventdata, handles)
ck_stim(hObject,'Post Stim',handles);

function ck_stim(hObject, name, handles)
% Check Post/Pre Stim-Time Changing OK?
try,
	set(hObject,'ForeGroundColor',[0 0 0]);
	d  = get(hObject,'String');
	ud = str2double(d);
	if (ud<0),
		error([name ' must be Positive-Number']);
	end
	set(hObject,'UserData',ud(1));
	plot_area(handles);
catch,
	set(hObject,'ForeGroundColor',[1 0 0]);
	uiwait(errordlg([name ' Setting Error.' lasterr]));
	ud=get(hObject,'UserData');
	if isempty(ud),
		set(hObject,'String','1');
	else
		set(hObject,'String',num2str(ud));
	end
end
