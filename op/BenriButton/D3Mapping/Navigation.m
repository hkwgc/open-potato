function varargout = Navigation(varargin)
% NAVIGATION M-file for Navigation.fig
%      NAVIGATION, by itself, creates a new NAVIGATION or raises the existing
%      singleton*.
%
%      H = NAVIGATION returns the handle to a new NAVIGATION or the handle to
%      the existing singleton*.
%
%      NAVIGATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NAVIGATION.M with the given input arguments.
%
%      NAVIGATION('Property','Value',...) creates a new NAVIGATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Navigation_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Navigation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Navigation

% Last Modified by GUIDE v2.5 16-Feb-2010 16:39:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Navigation_OpeningFcn, ...
                   'gui_OutputFcn',  @Navigation_OutputFcn, ...
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


% --- Executes just before Navigation is made visible.
function Navigation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Navigation (see VARARGIN)

% Choose default command line output for Navigation
handles.output = hObject;

if(nargin > 3)
  for index=1:2:(nargin-3),
    if nargin-3==index, break, end
    switch lower(varargin{index})
      case 'inifile'
        IniFile=varargin{index+1};
        try
          fid=fopen(IniFile,'r');
        catch
          msgbox(lasterr);
          return;
        end
        [Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
        fclose(fid);
    end
  end
else
  msgbox('IniFile is not specified. Navigation Ended');
  delete(handles.figure1);
  return;
end

% Select reference point file(.ref)
current_dir = pwd;
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  try
    cd('WinP3_mcr\BenriButton\D3Mapping\ref');
  catch
    error(['Cannot find a directory : ' 'WinP3_mcr\BenriButton\D3Mapping\ref' ': current is ' current_dir]);
    return;
  end
else
  cd('BenriButton\D3Mapping\ref');
end

[fname, dpath] = uigetfile('*.ref');
cd(current_dir);
if fname==0
  %delete(get(0,'CurrentFigure'));
  delete(handles.figure1);
  msgbox('Ref Points File is not specified. Navigation Ended');
  return;
end
% Read Position File & Make Afine-Matrix
fpath = fullfile(dpath, fname);
fid=fopen(fpath,'r');
[User RefPoints] =Ref_file_read(fid);
User.filename=fname;
fclose(fid);

O = [RefPoints.LeftEar; RefPoints.RightEar; RefPoints.Nasion; RefPoints.Back; RefPoints.Top];
Aos = affine_trans('make_mat', O);
Aso = affine_trans('make_inv', O);
Aso_size = affine_trans('get_size_part', Aso);

current_dir = pwd;
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  HS_Vertex=['WinP3_mcr\' GuiAppli.HeadSurfaceVertex];
  HS_Edge=['WinP3_mcr\' GuiAppli.HeadSurfaceEdge];
  BS_Vertex=['WinP3_mcr\' GuiAppli.BrainSurfaceVertex];
  BS_Edge=['WinP3_mcr\' GuiAppli.BrainSurfaceEdge];
else
  HS_Vertex=GuiAppli.HeadSurfaceVertex;
  HS_Edge=GuiAppli.HeadSurfaceEdge;
  BS_Vertex=GuiAppli.BrainSurfaceVertex;
  BS_Edge=GuiAppli.BrainSurfaceEdge;
end
[Shmem hShare]=SetShareMem4GUI(Aso_size,HS_Vertex,HS_Edge,BS_Vertex,BS_Edge);
cd(current_dir);
%Aso_part==Aso_size*Aso_rot
setappdata(handles.figure1,'Shmem',Shmem);
setappdata(handles.figure1,'hShare',hShare);
if(~exist(HS_Vertex,'file') || ~exist(HS_Edge,'file') || ...
        ~exist(BS_Vertex,'file') || ~exist(BS_Edge,'file') )
    CloseShareMem(handles);
    msgbox('Head & Brain Vertex-Edge File(s) not exist. Navigation Stopped');
    delete(handles.figure1);
    return;
end

% Open GUI
current_dir = pwd;
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  GuiAppli.Navigation=['WinP3_mcr\' GuiAppli.Navigation];
end
CreateProcess(GuiAppli.Navigation);

cd(current_dir);

setappdata(handles.figure1,'Aos',Aos);
setappdata(handles.figure1,'Aso_size',Aso_size);

setappdata(handles.figure1,'User',User);
setappdata(handles.figure1,'RefPoints',RefPoints);
setappdata(handles.figure1,'Serial',Serial);

if(~exist(Navigation.HeadSurfaceFile,'file'))
    CloseShareMem(handles);
    msgbox('Head-Surface File not exist. Navigation Stopped');
    delete(handles.figure1);
    return;
end

s=load(Navigation.HeadSurfaceFile);
if(~isfield(s,'x') || ~isfield(s,'y') || ~isfield(s,'z'))
    CloseShareMem(handles);
    msgbox('Head-Surface File not contain x,y,z filed(s). Navigation Stopped');
    delete(handles.figure1);
    return;
end
hs_data=struct('xallHEM',[],'yallHEM',[],'zallHEM',[]);
hs_data.xallHEM = s.x;
hs_data.yallHEM = s.y;
hs_data.zallHEM = s.z;
setappdata(handles.figure1,'HeadSurfaceData',hs_data);
min_z_in_head = min(hs_data.zallHEM);
setappdata(handles.figure1,'min_z_in_head',min_z_in_head);

H_sphere=GetBrainFuncFromStylus('MakeHash',hs_data);
setappdata(handles.figure1,'HeadSurfaceHash',H_sphere);

BrainDic1_file=Navigation.BrainDicFile1;
if(~exist(BrainDic1_file,'file'))
    CloseShareMem(handles);
    msgbox('BrainMap1 File not exist. Navigation Stopped');
    delete(handles.figure1);
    return;
end
BrainDic1=load(BrainDic1_file);
if(~isfield(BrainDic1,'Data') || ~isfield(BrainDic1,'Label') || ~isfield(BrainDic1,'MapName'))
    CloseShareMem(handles);
    msgbox('BrainMap1 File not contain Data,Label,MapName filed(s). Navigation Stopped');
    delete(handles.figure1);
    return;
end
setappdata(handles.figure1,'BrainDic1',BrainDic1);
setappdata(handles.figure1,'Dic1MapName',BrainDic1.MapName);
set(handles.text3,'String',BrainDic1.MapName);

BrainDic2_file=Navigation.BrainDicFile2;
if(~exist(BrainDic2_file,'file'))
    CloseShareMem(handles);
    msgbox('BrainMap1 File not exist. Navigation Stopped');
    delete(handles.figure1);
    return;
end
BrainDic2=load(BrainDic2_file);
if(~isfield(BrainDic2,'Data') || ~isfield(BrainDic2,'Label') || ~isfield(BrainDic2,'MapName'))
    CloseShareMem(handles);
    msgbox('BrainMap2 File not contain Data,Label,MapName filed(s). Navigation Stopped');
    delete(handles.figure1);
    return;
end
setappdata(handles.figure1,'BrainDic2',BrainDic2);
setappdata(handles.figure1,'Dic2MapName',BrainDic2.MapName);
set(handles.text2,'String',BrainDic2.MapName);

try
  OpenSerialPort(handles.figure1, handles);
catch
  CloseShareMem(handles);
  msgbox(lasterr);
  msgbox('Serial Port Open Error: Navigation Ended');
  delete(handles.figure1);
  return;
end
setappdata(handles.figure1,'StylusMode','click');
%set(handles.figure1,'CloseRequestFcn','closereq');
set(handles.figure1,'CloseRequestFcn',{@close_Callback,handles});

interval_timer = timer('TimerFcn', {@Timer_Callback, handles}, 'Period',1.0);
set(interval_timer,'ExecutionMode','fixedDelay');
setappdata(handles.figure1,'interval_timer',interval_timer);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Navigation wait for user response (see UIRESUME)
%uiwait(handles.figure1);

function OpenSerialPort(hObject, handles)
    Serial = getappdata(handles.figure1,'Serial');

    %s=serial('com3','BaudRate',115200,'Parity','none');
    s=serial(Serial.Port, 'BaudRate', Serial.BaudRate, 'Parity', Serial.Parity);
    fopen(s);
    %readasync(s);
    setappdata(handles.figure1,'SerialPort',s);

    % TODO: set Event
    s.BytesAvailableFcnMode = 'terminator';
    s.BytesAvailableFcn = {@ReadCallBack,hObject,handles};
    %s.OutputEnptyFcn = {@ReadCallBack,h,hs};
%    fprintf(s,'Y');
%    fprintf(s,'u');
%    fprintf(s,'E');
%    CtrlD=char(4);
%    fprintf(s,CtrlD);
%    fprintf(s,'C');
    dev3dpos('ini2click',s);
    fclose(s);
    fopen(s);

function CloseSerialPort(hObject, handles)
    s=getappdata(handles.figure1,'SerialPort');
%    CtrlY=char(25);
%    fprintf(s,CtrlY);
    dev3dpos('go2ini',s);
    fclose(s);

function CloseShareMem(handles)
Shmem=getappdata(handles.figure1,'Shmem');
hShare=getappdata(handles.figure1,'hShare');
ret = CloseShareMem4GUI(Shmem,hShare);

function close_Callback(hObject, eventdata, handles)
selection = questdlg('Close Figure?','Closing','Yes','No','Yes');

switch selection
  case 'Yes'
    % Stop Measurement
    try
      ipc_close_window();
    catch
      msgbox(lasterr);
    end
    try
      CloseShareMem(handles);
    catch
      msgbox(lasterr);
    end
    try
      CloseSerialPort(hObject, handles)
      delete(get(0,'CurrentFigure'))
    catch
      delete(get(0,'CurrentFigure'))
    end
    
  case 'No'
    return;
  otherwise
    return;
end

% --- Outputs from this function are returned to the command line.
function varargout = Navigation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%====================================================
% Asyncronous Read CallBack
%====================================================
function ReadCallBack(s, event, h, hs)
% s:serial port, event:eventdata, h:graph top object, hs:graph objects

[ret pos]=dev3dpos('readpos',s);
if( ret < 0 )
   return;
elseif( ret==1 )
   return;
else
   Aos=getappdata(hs.figure1,'Aos');
   s_pos = affine_trans('translate', Aos, pos);
   min_z_in_head=getappdata(hs.figure1,'min_z_in_head');
   if(s_pos(1,3)<(min_z_in_head-10))
      s_pos(1,3)=min_z_in_head-10;
   end
   c_pos(1)=s_pos(1,1); c_pos(2)=s_pos(1,2); c_pos(3)=s_pos(1,3);

   heads = getappdata(hs.figure1,'HeadSurfaceData');
	 H_sphere = getappdata(hs.figure1,'HeadSurfaceHash');

	 %indeces=GetNearestNumPoints(H_sphere,heads.xallHEM,heads.yallHEM,heads.zallHEM,c_pos(1),c_pos(2),c_pos(3),360);
   indeces=GetBrainFuncFromStylus('GetNearest',H_sphere,heads,c_pos,360);
   [num_row num_col] = size(indeces);
	 if( num_col <=0 )
	  	return;
   end
   xxx(1)=heads.xallHEM(indeces(1));
   yyy(1)=heads.yallHEM(indeces(1));
   zzz(1)=heads.zallHEM(indeces(1));

   af2 = GetBrainFuncFromStylus('GetCenter',heads,indeces);
%  norm_vec = [round(xxx(1)-af2(1)) round(yyy(1)-af2(2)) round(zzz(1)-af2(3)) ];
  norm_vec = [round(c_pos(1)-af2(1)) round(c_pos(2)-af2(2)) round(c_pos(3)-af2(3)) ];
  
  BrainDic1=getappdata(hs.figure1,'BrainDic1');
  [Dic1_row Dic1_col] = size(BrainDic1.Data);
  BrainDic2=getappdata(hs.figure1,'BrainDic2');
  [Dic2_row Dic2_col] = size(BrainDic2.Data);
  
%  index=GetIndexOnBrainSurface(BrainDic1.Data, [xxx(1) yyy(1) zzz(1)], norm_vec, 30 );
%  index=GetIndexOnBrainSurface(BrainDic1.Data, [c_pos(1) c_pos(2) c_pos(3)], norm_vec, 30 );
  index = GetBrainFuncFromStylus('GetIndexOnBrain',BrainDic1.Data, c_pos, norm_vec, 30);
  if( (index > 0) && (index <= Dic1_row) )
  
	  stylus_position = sprintf('( %6.1f, %6.1f, %6.1f)',c_pos(1),c_pos(2),c_pos(3));
	  headsurf_position = sprintf('( %6.1f, %6.1f, %6.1f)',xxx(1),yyy(1),zzz(1));
	  brain_position = sprintf('( %6.1f, %6.1f, %6.1f)',...
	    round(BrainDic1.Data(index,1)),round(BrainDic1.Data(index,2)),round(BrainDic1.Data(index,3)));
	  %strings = sprintf('%s\n%s\n%s',stylus_position,headsurf_position,brain_position);
	  Dic1_Label = BrainDic1.Label{BrainDic1.Data(index,4)};
	  
	  
%	  index=GetIndexOnBrainSurface(BrainDic2.Data, [xxx(1) yyy(1) zzz(1)], norm_vec, 30 );
%	  index=GetIndexOnBrainSurface(BrainDic2.Data, [c_pos(1) c_pos(2) c_pos(3)], norm_vec, 30 );
    index = GetBrainFuncFromStylus('GetIndexOnBrain',BrainDic2.Data, c_pos, norm_vec, 30);
	  if( (index > 0) && (index <= Dic2_row) )
		  Dic2_Label = BrainDic2.Label{BrainDic2.Data(index,4)};
		  
		  set(hs.BROD,'String',Dic2_Label);
		  set(hs.AAL,'String',Dic1_Label);
		  set(hs.stylus_position_text,'String',stylus_position);
      set(hs.head_position_text,'String',headsurf_position);
      set(hs.brain_position_text,'String',brain_position);

		  xx2 = BrainDic2.Data(index,1);
          yy2 = BrainDic2.Data(index,2);
          zz2 = BrainDic2.Data(index,3);
          Aso_size=getappdata(hs.figure1,'Aso_size');
          o_pos=affine_trans('observed_size_translate', ...
                  Aso_size, [xxx(1) yyy(1) zzz(1)]);

          %ret=WriteShareMem4GUI(Shmem,hShare,Std_Stylus,Std_Head,Std_Brain);
          Std_Stylus = c_pos;
          Std_Head(1) = xxx(1); Std_Head(2) = yyy(1); Std_Head(3) = zzz(1);
          Std_Brain(1) = xx2; Std_Brain(2) = yy2; Std_Brain(3) = zz2;
          Shmem=getappdata(hs.figure1,'Shmem');
          hShare=getappdata(hs.figure1,'hShare');
          ret=WriteShareMem4GUI(Shmem,hShare, Std_Stylus, Std_Head, Std_Brain);
          if(ret~=0)
              return;
          end
          % Window Event Send
		%  ipc_connect(1,xxx(1),yyy(1),zzz(1)); % on Surface
          ipc_connect(2,xx2,yy2,zz2); % on Brain
          ipc_connect(1,o_pos(1,1),o_pos(1,2),o_pos(1,3)); % on Surface
		  
		%%  fopen(sp);
		%    sp.BytesAvailableFcn = {@ReadCallBack,h,hs};
	  end
  end
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   serial_reconnect(hObject, eventdata, handles);
%
%
function serial_reconnect(hObject, eventdata, handles)
   sp = getappdata(handles.figure1,'SerialPort');
   fclose(sp);
   fopen(sp);
 

% --- Executes on button press in mode_transit_toggle.
function mode_transit_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to mode_transit_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mode_transit_toggle
state = get(hObject,'Value');%setappdata(handles.figure1,'StylusMode','click');
if state==1
% click -> auto
  s = getappdata(handles.figure1,'SerialPort');
%  fprintf(s,'c');
%  CtrlD=char(4);
%  fprintf(s,CtrlD);
  dev3dpos('click2point',s);
  fclose(s);
  
  setappdata(handles.figure1,'StylusMode','auto');
  set(hObject,'String','Auto -> Click');
  guidata(hObject,handles);
  
  fopen(s);
  interval_timer = getappdata(handles.figure1,'interval_timer');
  start(interval_timer);
%  fprintf(s,'P\n'); % first only
else
% auto -> click
  interval_timer = getappdata(handles.figure1,'interval_timer');
  stop(interval_timer);
  s = getappdata(handles.figure1,'SerialPort');
%  CtrlD=char(4);
%  fprintf(s,CtrlD);
%  fprintf(s,'C');
  dev3dpos('point2click',s);
  fclose(s);
  
  setappdata(handles.figure1,'StylusMode','click');
  set(hObject,'String','Click -> Auto');
  guidata(hObject,handles);
  
  fopen(s);
end


function Timer_Callback(obj, event, handles)
  s = getappdata(handles.figure1,'SerialPort');
%  fprintf(s,'P');
  dev3dpos('getpoint',s);

