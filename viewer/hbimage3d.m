function varargout = hbimage3d(varargin)
% HBIMAGE3D M-file for hbimage3d.fig
%      HBIMAGE3D, by itself, creates a new HBIMAGE3D or raises the existing
%      singleton*.
%
%      H = HBIMAGE3D returns the handle to a new HBIMAGE3D or the handle to
%      the existing singleton*.
%
%      HBIMAGE3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HBIMAGE3D.M with the given input arguments.
%
%      HBIMAGE3D('Property','Value',...) creates a new HBIMAGE3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hbimage3d_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hbimage3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hbimage3d


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 10-Nov-2004 14:08:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hbimage3d_OpeningFcn, ...
                   'gui_OutputFcn',  @hbimage3d_OutputFcn, ...
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


% --- Executes just before hbimage3d is made visible.
function hbimage3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hbimage3d (see VARARGIN)

% Choose default command line output for hbimage3d
handles.output = hObject;
basec=[0.843 1 1];

hb3.fig=figure;hb3.ax=axes;
set(hb3.fig,...
	'Renderer' ,'OpenGL',...
	'Units'    ,'pixels',...
	'Position' ,[240 60 654 654],...
	'Color'    ,basec,...
	'Tag'      ,'HB_IMAGE_3D_Ver1.11_TAG',... %% Dont Edit
	'Name'     ,'HB Image 3D Version 1.00');
ecode=hbimage3d_plot('new',hb3.ax,hObject);

%
setappdata(hObject,'hb3fig',hb3);
set(hObject,'Color',basec);

% Update handles structure
guidata(hObject, handles);
if ecode~=0
	try
		close(hb3.fig);
	end
	delete(hObject);
end
% UIWAIT makes hbimage3d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hbimage3d_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edt_crlat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_crlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_crlat_Callback(hObject, eventdata, handles)
% hObject    handle to edt_crlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_crlat as text
%        str2double(get(hObject,'String')) returns contents of edt_crlat as a double


% --- Executes during object creation, after setting all properties.
function edt_crlong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_crlong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_crlong_Callback(hObject, eventdata, handles)
% hObject    handle to edt_crlong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_crlong as text
%        str2double(get(hObject,'String')) returns contents of edt_crlong as a double


% --- Executes during object creation, after setting all properties.
function edt_pslat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_pslat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_pslat_Callback(hObject, eventdata, handles)
% hObject    handle to edt_pslat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_pslat as text
%        str2double(get(hObject,'String')) returns contents of edt_pslat as a double


% --- Executes during object creation, after setting all properties.
function edt_pslong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_pslong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_pslong_Callback(hObject, eventdata, handles)
% hObject    handle to edt_pslong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_pslong as text
%        str2double(get(hObject,'String')) returns contents of edt_pslong as a double


% --- Executes on button press in chb_pposition.
function chb_pposition_Callback(hObject, eventdata, handles)
% hObject    handle to chb_pposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chb_pposition


% --- Executes during object creation, after setting all properties.
function edt_px_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_px (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_px_Callback(hObject, eventdata, handles)
% hObject    handle to edt_px (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_px as text
%        str2double(get(hObject,'String')) returns contents of edt_px as a double


% --- Executes during object creation, after setting all properties.
function edt_py_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_py (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_py_Callback(hObject, eventdata, handles)
% hObject    handle to edt_py (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_py as text
%        str2double(get(hObject,'String')) returns contents of edt_py as a double


% --- Executes during object creation, after setting all properties.
function edt_pz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_pz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_pz_Callback(hObject, eventdata, handles)
% hObject    handle to edt_pz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_pz as text
%        str2double(get(hObject,'String')) returns contents of edt_pz as a double


% --- Executes on button press in psb_up.
function psb_up_Callback(hObject, eventdata, handles)
% hObject    handle to psb_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angl=get(handles.edt_slantunit,'String');
hb3=getappdata(handles.figure1,'hb3fig');
ecode=hbimage3d_plot('slant',hb3.ax,'u',angl);
return

% --- Executes on button press in psb_right.
function psb_right_Callback(hObject, eventdata, handles)
% hObject    handle to psb_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angl=get(handles.edt_slantunit,'String');
hb3=getappdata(handles.figure1,'hb3fig');
ecode=hbimage3d_plot('slant',hb3.ax,'r',angl);
return


% --- Executes on button press in psb_left.
function psb_left_Callback(hObject, eventdata, handles)
% hObject    handle to psb_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angl=get(handles.edt_slantunit,'String');
hb3=getappdata(handles.figure1,'hb3fig');
ecode=hbimage3d_plot('slant',hb3.ax,'l',angl);
return


% --- Executes on button press in psb_down.
function psb_down_Callback(hObject, eventdata, handles)
% hObject    handle to psb_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angl=get(handles.edt_slantunit,'String');
hb3=getappdata(handles.figure1,'hb3fig');
ecode=hbimage3d_plot('slant',hb3.ax,'d',angl);
return


% --- Executes on button press in psb_movie.
function psb_movie_Callback(hObject, eventdata, handles)
% hObject    handle to psb_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in psb_save.
function psb_save_Callback(hObject, eventdata, handles)
% hObject    handle to psb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in psb_pposition.
function psb_pposition_Callback(hObject, eventdata, handles)
% hObject    handle to psb_pposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ecode=-1;
position=getposition(hObject, eventdata, handles);
if isempty(position), return;end;
try
	hb3=getappdata(handles.figure1,'hb3fig');
	ecode=hbimage3d_plot('plot',hb3.ax,[],position);
end
if ecode ~= 0
	errordlg([' Cannot Plot (PositionChange) : ' lasterr]);
	return;
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hb3=getappdata(hObject,'hb3fig');
try
	close(hb3.fig);
end

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Executes during object creation, after setting all properties.
function edt_slantunit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_slantunit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edt_slantunit_Callback(hObject, eventdata, handles)
% hObject    handle to edt_slantunit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_slantunit as text
%        str2double(get(hObject,'String')) returns contents of edt_slantunit as a double

function p=getposition(hObject, eventdata, handles)
% Get- Position Data
try
	p.point(1)=str2num(get(handles.edt_px,'String'));
	p.point(2)=str2num(get(handles.edt_py,'String'));
	p.point(3)=str2num(get(handles.edt_pz,'String'));
catch
	errordlg(' Prob-Position Must be Numerical');
	p=[]; return;
end
%% if Slant Renew Slant
p.slant=[0 0];

return;

%%%%%%%%%%%%%%%%%%%%%%%
function reload_setingPosition(hObject,eventdata,handles,x,y,z)
if get(handles.tgl_pposition,'Value')==0
	return;
end
try
	x1=sprintf('%7.2f ',x);	y1=sprintf('%7.2f ',y);	z1=sprintf('%7.2f ',z);
	
	%	h.base=hbimage3d;
	h.base=hObject;
	h.x=findobj(h.base,'Tag','edt_px');
	h.y=findobj(h.base,'Tag','edt_py');
	h.z=findobj(h.base,'Tag','edt_pz');
	
	set(h.x,'String',x1); set(h.y,'String',y1); set(h.z,'String',z1);
end
return;

% --- Executes on button press in tgl_pposition.
function tgl_pposition_Callback(hObject, eventdata, handles)
% hObject    handle to tgl_pposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tgl_pposition

%%%%%%%%%%%%%%%%%%%%%
% Set HB Data
%%%%%%%%%%%%%%%%%%%%%
function set_HB_Data(hObject, eventdata, handles,...
	hbdata, id, tag,varargin)
ecode=-1;
hb3=getappdata(handles.figure1,'hb3fig');

if nargin<6
	errordlg('Set HB DATA : Too few Argument');
	return;
end

% Set Popmenue
try
	data=get(handles.pop_prbid,'String');
	data{id}=tag;
	set(handles.pop_prbid,'Value',id);
	set(handles.pop_prbid,'String',data);
	if id >1
		set(handles.pop_prbid,'Visible','on');
	end
catch
	errordlg(['Can not Set Prob Data PopupMenue' lasterr]);return;
end

rcode=hbimage3d_plot('setphbid',hb3.ax,id);
if rcode~=0, return; end
prb_h=hbimage3d_plot('getPrbH',hb3.ax);
if isempty(prb_h)
	shape=getshape(hObject, eventdata, handles);
	if isempty(shape), return;end
	switch id
		case 1
			p.point=[40 30 130];
		case 2
			p.point=[40 130 130];
		case 3
			p.point=[170 80 100];
		case 4
			p.point=[20 80 130];
		otherwise
			p.point=[170+(id-3)*20 80 130];
	end
	ecode=hbimage3d_plot('plot',hb3.ax,hbdata,shape,p);
else
	ecode=hbimage3d_plot('plot',hb3.ax,hbdata);
	if ecode == 1
		shape=getshape(hObject, eventdata, handles);
		ecode=hbimage3d_plot('plot',hb3.ax,hbdata,shape);
	end
end

if ecode == 1
 	errordlg([' Cannot Plot : Program-Error' lasterr]);
 	return;
end

% Set Othe Data
prb_h=hbimage3d_plot('getPrbH',hb3.ax); % Get Plot Prob-Data Handle
try
	if nargin>=7
		set(hb3.ax,'Clim',varargin{1});
	end
end
try
	if nargin>=8
		caxis(hb3.ax,varargin{2});
		% colorbar(hb3.ax);
	end
end
try
	if nargin>=9
		osp_set_colormap(varargin{3});
	end
end


%
return;


% --- Executes on selection change in pop_prbid.
function pop_prbid_Callback(hObject, eventdata, handles)
% hObject    handle to pop_prbid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_prbid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_prbid
hb3=getappdata(handles.figure1,'hb3fig');
id = get(hObject,'Value');
rcode=hbimage3d_plot('setphbid',hb3.ax,id);
if rcode~=0, return; end
prb_h=hbimage3d_plot('getPrbH',hb3.ax);
if isempty(prb_h)
	data=get(hObject,'String');
	errordlg([' Error : No Prob Data for '' ' data{id} ' '' !']);
	set(hObject,'Value',1);
	hbimage3d_plot('setphbid',hb3.ax,1);
end
return;

% --- Executes during object creation, after setting all properties.
function pop_prbid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_prbid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %--- Get Shape Structure ---
% function shape=getshape(hObject, eventdata, handles)
% % Shape : Shape of the Ploting plane
% %   size.x : Size of the plane  x [??] <- unit of brain figure : now 30
% %   size.y : 
% %   cr.x   :  Curvature-Radius of x
% %   cr.y   :  Curvature-Radius of y
% %           ( Curvature of x and y is 1/rx, 1/ry respectively. )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shape=getshape(hObject, eventdata, handles)
% Get-Size Data
try
	shape.size.x=str2num(get(handles.edt_pslat,'String'));
	shape.size.y=str2num(get(handles.edt_pslong,'String'));
catch
	errordlg(' Prob-Size Must be Numerical');
	shape=[]; return;
end
if shape.size.x<=0 || shape.size.y<=0
	errordlg(' Prob-Size must be Positive')
	shape=[]; return;
end

% Set-Curvature-Radius
try
	shape.cr.x=str2num(get(handles.edt_crlat,'String'));
	shape.cr.y=str2num(get(handles.edt_crlong,'String'));
catch
	errordlg(' Curvature-Radius Must be Numerical');
	shape=[]; return;
end
if shape.cr.x<=0 || shape.cr.y<=0
	errordlg(' Curvature Radius must be Positive')
	shape=[]; return;
end

% Size Check
if (pi*shape.cr.x < shape.size.x) || (pi*shape.cr.y < shape.size.y) 
	errordlg(' Error : pi*Curvature Radius < Size')
	shape=[]; return;
end	


% --- Executes on button press in psb_makeProb.
function psb_makeProb_Callback(hObject, eventdata, handles)
% hObject    handle to psb_makeProb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ecode=-1;
shape=getshape(hObject, eventdata, handles);
if isempty(shape), return;end;
try
	hb3=getappdata(handles.figure1,'hb3fig');
	ecode=hbimage3d_plot('plot',hb3.ax,[],shape);
end
if ecode ~= 0
	errordlg([' Cannot Plot (ShapeChange) : ' lasterr]);
	return;
end


