function varargout = ViewGroupCallback_subgui_pos(varargin)
% VIEWGROUPCALLBACK_SUBGUI_POS is GUI to edit Callback-Object-Data position by GUI.
%  Syntax :
%    cObjectData=ViewGroupCallback_subgui_pos_OpeningFcn('cObject',cObjectData);
%
%  if cancel : cObjectData is Empty.
%  This function Change Position only.
%
% See also: GUIDE, GUIDATA, GUIHANDLES, VIEWGROUPCALLBACK.

% Edit the above text to modify the response to help ViewGroupCallback_subgui_pos

% Last Modified by GUIDE v2.5 10-Mar-2006 09:20:12


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
                   'gui_OpeningFcn', @ViewGroupCallback_subgui_pos_OpeningFcn, ...
                   'gui_OutputFcn',  @ViewGroupCallback_subgui_pos_OutputFcn, ...
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Opening, Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ViewGroupCallback_subgui_pos_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before ViewGroupCallback_subgui_pos is made visible.
% Opening Function : set argh_handle
% This function need cObject or Delete at onece.

% Choose default command line output for ViewGroupCallback_subgui_pos
% Default Output-Data is Empty;
handles.output = [];
handles.f      = hObject; % to simpley
guidata(hObject, handles);

%===========================
% Argument Read
%===========================
cObject=[];
try,for ii=1:2:length(varargin)-1
		switch lower(varargin{ii})
			case 'cobject',
				cObject=varargin{ii+1};
			otherwise,
				disp(' -- Unknown Property --');
				disp(varargin{:});
		end % End Switch
	end % End varargin Loop
catch
	% in getting Argument.
	warndlg({'Error Occur in Reading cObject',lasterr});
end
if isempty(cObject),
	errordlg('No Callback-Object to Edit!');
	return; % with no uiwait! == Delete now!
end

% == Set Data ==
setCObject(handles,cObject);

% UIWAIT makes ViewGroupCallback_subgui_pos wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);

function ax_bg_CreateFcn(hObject, eventdata, handles)
% Back-Ground Axes is for Drag Mouse
axes(hObject);axis off
set(hObject,'Color','none');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = ViewGroupCallback_subgui_pos_OutputFcn(hObject, eventdata, handles)
% Retrun Callback-Object-Data
% if cancel : empty ( default : empty)
varargout{1} = handles.output;delete(handles.f);

function psb_OK_Callback(hObject, eventdata, handles)
% Output cObjectData
handles.output = getCObject(handles);
guidata(hObject, handles);
if isequal(get(handles.f, 'waitstatus'), 'waiting'),uiresume(handles.f);
else, delete(handles.f); end

function psb_Cancel_Callback(hObject, eventdata, handles)
% Output : Empty
handles.output = [];
guidata(hObject, handles);
if isequal(get(handles.f, 'waitstatus'), 'waiting'),uiresume(handles.f);
else, delete(handles.f); end

%%%%%%%%%%%%%%%%%%%%
% Ordering
%%%%%%%%%%%%%%%%%%%%
%===================
% Ordering : R<->L
%===================
function edit_x_Callback(hObject, eventdata, handles)
function psb_oright_Callback(hObject, eventdata, handles)
function psb_oleft_Callback(hObject, eventdata, handles)
%===================
% Ordering : T<->B
%===================
function edit_y_Callback(hObject, eventdata, handles)
function psb_otop_Callback(hObject, eventdata, handles)
function psb_obottom_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%
% Size Ordering
%%%%%%%%%%%%%%%%%%%%
%===================
% Ordering Width
%===================
function edit_width_Callback(hObject, eventdata, handles)
function psb_width_Callback(hObject, eventdata, handles)
%===================
% Ordering Heigth
%===================
function edit_heitht_Callback(hObject, eventdata, handles)
function psb_height_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%
% Data I/O
%%%%%%%%%%%%%%%%%%%%
function setCObject(handles,cObject),
% Set CObject to GUI
%   This function called from Opening Function.

pflag=[]; pidx=[]; pos=[];pfname={}; str={};
for idx=1:length(cObject),
	co=cObject{idx};
	pflag(idx)=false;
	str{end+1}=co.name;
	for pnm={'pos','Position','position'},
		if isfield(co,pnm{1}),
			pflag(idx)=true;
			pidx(end+1)=idx;
			pfname{end+1}=pnm{1};
			pos = [pos; eval(['co.' pnm{1}])];
			break;
		end
	end
end

% User Data of DataList Box
ud.posflag=pflag;   % Position On/Off
ud.pidx   = pidx;   % Position On Index
ud.pfname = pfname; % Position-Field-Name
ud.pos    = pos;    % Position
ud.h      = [];     % Handle of Fill
%ud.cflag    = false(size(pflag));  % Changed Flag
ud.cObject=cObject;
% now this value is not used.. see
setappdata(handles.f,'InputData',ud);
set(handles.lbx_datalist,'UserData',ud, 'String',str,'value',1);
drawcObject(handles);
lbx_datalist_Callback(handles.lbx_datalist,[],handles);

function cObject=getCObject(handles)
ud=get(handles.lbx_datalist,'UserData');
cObject=ud.cObject;
for idx=1:length(ud.pidx),
    cObject{ud.pidx(idx)}=setfield(cObject{ud.pidx(idx)},...
        ud.pfname{idx},ud.pos(idx,:));
    % disp(cObject{idx});
end
function cObject=lbx_datalist_Callback(h, e, hs)
% Change Selecting Height
% Color Setting,
c0 = [0.7, 0.7, 0.7]; % Not Selecting
c0e= [0.3, 0.3, 0.3];
ca = [1.0, 0.7, 0.7]; % Selecting
cae= [1.0, 0.0, 0.0]; 
ud=get(h,'UserData');
vl=get(h,'Value');
for pidx=1:length(ud.pidx),
	if isempty(find(vl==ud.pidx(pidx))),
		set(ud.h(pidx),'FaceColor',c0, 'EdgeColor',c0e);
	else,
		set(ud.h(pidx),'FaceColor',ca, 'EdgeColor',cae);
	end
end

function drawcObject(handles)
% Draw Setting...
%  --> Remove & Redraw...
%      this function might be Call in setCObject only..
ud=get(handles.lbx_datalist,'UserData');
vl=get(handles.lbx_datalist,'Value');

%------------------
% Delete Old ud ... 
%  ud.h is empty for opening..
%------------------
for idx=1:length(ud.h),
	if isfield(ud.h(idx)),
		delete(ud.h(idx));
	end
end
ud.h=[];

%------------------
% Draw
%------------------
axes(handles.ax_Main); hold on
c0 = [0.7, 0.7, 0.7]; % Default Color
for pidxidx=1:length(ud.pidx),
	a=ud.pos(pidxidx,:);
	h=fill(...
		[a(1);a(1);a(1)+a(3);a(1)+a(3);a(1)],...
		[a(2);a(2)+a(4);a(2)+a(4);a(2);a(2)],c0);
	set(h,'UserData',pidxidx);
	ud.h(pidxidx)=h;
end
axis([0,1,0,1]);
set(handles.lbx_datalist,'UserData',ud);
% Change Data Property..
set(ud.h, ...
	'Marker','square', ...
	'MarkerSize', 3, ...
	'ButtonDownFcn', ...
	'ViewGroupCallback_subgui_pos(''cObjectButtonDown'',gcbo,[],guidata(gcbo))');
% for debug... Delete This
assignin('base','co0',ud.cObject);

function uic_COinfo_Callback(hObject, eventdata, handles)
% Callback of : uicontextmenu of lbx_datalist.
%   displShow Information of Selecting cObject
%   This is for debug...
val=get(handles.lbx_datalist,'Value');
ud=get(handles.lbx_datalist,'UserData');
cObject=ud.cObject;
selectingCObject=cObject{val};
openvar('selectingCObject');

%%%%%%%%%%%%%%%%%%%%
% GUI Windows Motion
%%%%%%%%%%%%%%%%%%%%
function cObjectButtonDown(h,e,handles)
% CObject Selected!

% Initiarized
setappdata(handles.f,'WindowState',[]);
cpos=get(handles.ax_Main,'CurrentPoint');cpos=[cpos(1,1),cpos(1,2)];
ud      = get(handles.lbx_datalist,'UserData');
pidxidx = get(h,'UserData');
pidx    = ud.pidx(pidxidx);

% Select cObject Change..
set(handles.lbx_datalist,'Value',pidx);
lbx_datalist_Callback(handles.lbx_datalist,[],handles);

% get Couner
x0      = get(h,'XData'); x=x0([3,2]); % x=[right, left]
y0      = get(h,'YData'); y=y0(1:2); % y=[bottom,top]
d0      = getappdata(handles.f,'Delta');
if isempty(d0), d0=0.2; end
dx      = (x(2)-x(1)) * d0; % size selected
dy      = (y(2)-y(1)) * d0; % size selected
if dx<0.01, dx=0.01; end
if dy<0.01, dy=0.01; end

% Check Selected Position
lineflag = false(1,4);
if cpos(1)> (x(1)-dx) && cpos(1)< (x(1)+dx),
	% Right Selected
	lineflag(1)=true;
end	
if cpos(1)> (x(2)-dx) && cpos(1)< (x(2)+dx),
	% Left Selected
	lineflag(2)=true;
end	
if cpos(2)> (y(2)-dy) && cpos(2)< (y(2)+dy),
	% Top Selected
	lineflag(3)=true;
end	
if cpos(2)> (y(1)-dy) && cpos(2)< (y(1)+dy),
	% Bottom Selected
	lineflag(4)=true;
end	
if 0,
	msgbox(sprintf([...
			'C =(%0.3g,%0.3g)\n' ...
			'd =(%0.3g,%0.3g)\n' ...
			'LB=(%0.3g,%0.3g)\n' ...
			'RT=(%0.3g,%0.3g)\n'], ...
		cpos(1),cpos(2),...
		dx,dy, ...
		x(2),y(2),...
		x(1),y(1)));
end

%===================
% Change Window State
%===================
% Corner?
wsdata.h        = h;
wsdata.color    = get(h,'FaceColor');
wsdata.StartPos = cpos;
if any(lineflag(1:2)) && any(lineflag(2:4)),
	% Size Change
	set(h,'FaceColor',[1 .3 .3]);
	setappdata(handles.f,'WindowState','Size');
	if lineflag(1),  	wsdata.x=x(2);
	else,               wsdata.x=x(1); end
	if lineflag(3),		wsdata.y=y(1);
	else,       		wsdata.y=y(2); end
else,
	% Move
	set(h,'FaceColor',[.3 .3 1]);
	setappdata(handles.f,'WindowState','Move');
	wsdata.vec= cpos;
	wsdata.x  = x0;
	wsdata.y  = y0;
	wsdata.max = 1-[max(x0(:)), max(y0(:))];
	wsdata.min = -[min(x0(:)), min(y0(:))];
end
setappdata(handles.f,'WindowStateData',wsdata);

	
function figure1_WindowButtonUpFcn(h, e, hs)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ws =getappdata(hs.f,'WindowState');
wsd=getappdata(hs.f,'WindowStateData');
if isempty(ws), return; end
try,
	switch ws,
		case {'Size','Move'},
			figure1_WindowButtonMotionFcn(h, e, hs);
			set(wsd.h,'FaceColor',wsd.color);
			% make Position Data..
			x=get(wsd.h,'XData');y=get(wsd.h,'YData');
			pos=[min(x(:)), min(y(:)), max(x(:)), max(y(:))];
			pos(3:4)=pos(3:4)-pos(1:2);
			% get set psotion
			idx=get(wsd.h,'UserData');
			ud      = get(hs.lbx_datalist,'UserData');
			ud.pos(idx,:)=pos;
			set(hs.lbx_datalist,'UserData',ud);
	end
catch,
	errordlg('Up Error');
end
setappdata(hs.f,'WindowState',[]);



function figure1_WindowButtonMotionFcn(h, e, hs)
% Window Button Motion : 
%    Change Selected Object Position/Size
if isempty(hs), return; end
ws=getappdata(hs.figure1,'WindowState');
if isempty(ws) || strcmp(ws,'error'), return; end

cpos=get(hs.ax_Main,'CurrentPoint');cpos=[cpos(1,1),cpos(1,2)];
wsd=getappdata(hs.f,'WindowStateData');
try,
	switch ws,
		case 'Size',
			%--------------
			% Size Change!!
			%--------------
			% Range Check
			cpos = cpos.*( cpos>0 );
			cpos = (cpos.*( cpos<1 )) +( cpos>1);
			
			% --- Set for X ---
			x = sort([wsd.x,cpos(1)]);
			x = x([1,1,2,2,1]);

			% --- Set for Y ---
			y = sort([wsd.y,cpos(2)]);
			y = y([1,2,2,1,1]);

			set(wsd.h,'XData',x, 'YData',y);
			
		case 'Move',
			% Move
			% Vector of : Cpos->x 
			%wsdata.vec=[x0(1),y0(1)] - cpos;
			vec = cpos-wsd.vec;
			if vec(1)>wsd.max(1)
				vec(1)=wsd.max(1);
			elseif vec(1)<wsd.min(1)
				vec(1)=wsd.min(1);
			end
			if vec(2)>wsd.max(2)
				vec(2)=wsd.max(2);
			elseif vec(2)<wsd.min(2)
				vec(2)=wsd.min(2);
			end
			x = wsd.x+vec(1);
			y = wsd.y+vec(2);
			set(wsd.h,'XData',x, 'YData',y);
	end
catch,
	% Error Occur
	setappdata(h.f,'WindowState','error');
end
