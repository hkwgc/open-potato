function varargout = set_refpoints(varargin)
% SET_REFPOINTS M-file for set_refpoints.fig
%      SET_REFPOINTS, by itself, creates a new SET_REFPOINTS or raises the
%      existing
%      singleton*.
%
%      H = SET_REFPOINTS returns the handle to a new SET_REFPOINTS or the handle to
%      the existing singleton*.
%
%      SET_REFPOINTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SET_REFPOINTS.M with the given input arguments.
%
%      SET_REFPOINTS('Property','Value',...) creates a new SET_REFPOINTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before set_refpoints_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to set_refpoints_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help set_refpoints

% Last Modified by GUIDE v2.5 03-Feb-2010 19:20:31

%====================================================
% Begin initialization code - DO NOT EDIT
%====================================================
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @set_refpoints_OpeningFcn, ...
                   'gui_OutputFcn',  @set_refpoints_OutputFcn, ...
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
%====================================================
% End initialization code - DO NOT EDIT
%====================================================

%====================================================
% Figure Control
%====================================================
function set_refpoints_OpeningFcn(hObject, eventdata, handles, varargin)
% 
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
          delete(handles.figure1);
          return;
        end
        [Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
        fclose(fid);
    end
  end
else
  msgbox('IniFile is not specified.');
  delete(handles.figure1);
  return;
end
setappdata(handles.figure1,'Serial',Serial);

setappdata(handles.figure1,'Name','');
setappdata(handles.figure1,'ID','');
setappdata(handles.figure1,'Sex','Male');
setappdata(handles.figure1,'Age','0');
setappdata(handles.figure1,'Comment','');
  
setappdata(handles.txt_Cz,'MeasureCount',0);
setappdata(handles.txt_Nz,'MeasureCount',0);
setappdata(handles.txt_AR,'MeasureCount',0);
setappdata(handles.txt_Iz,'MeasureCount',0);
setappdata(handles.txt_AL,'MeasureCount',0);

try
  OpenSerialPort(handles.figure1, handles);
catch
  msgbox(lasterr);
  msgbox('Cannot Open Specified SerialPort.');
  delete(handles.figure1);
  return;
end

%set(handles.figure1,'CloseRequestFcn','closereq');
set(handles.figure1,'CloseRequestFcn',{@close_Callback,handles});

guidata(hObject, handles);

% UIWAIT makes set_refpoints wait for user response (see UIRESUME)
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
	%s.BytesAvailableActionCount = 40;
	%s.BytesAvailableActionMode = 'byte';
	%s.BytesAvailableAction = 'instraction';

    %s.OutputEnptyFcn = {@ReadCallBack,h,handles};
    %s.ErrorFcn = {@serial_reconnect,handles};
%    fprintf(s,'Y');
%    fprintf(s,'u');
%    fprintf(s,'E');
%    CtrlD=char(4);
%    fprintf(s,CtrlD);
%    fprintf(s,'C');
    dev3dpos('ini2click',s);
    fclose(s);
    fopen(s);

function close_Callback(hObject, eventdata, handles)
selection = questdlg('Close Figure?','Closing','Yes','No','Yes');

switch selection
  case 'Yes'
    % Stop Measurement
    s=getappdata(handles.figure1,'SerialPort');
%    CtrlY=char(25);
%    fprintf(s,CtrlY);
    dev3dpos('go2ini',s);
    fclose(s)

    delete(get(0,'CurrentFigure'))

  case 'No'
    return;
  otherwise
    return;
end

function varargout = set_refpoints_OutputFcn(hObject, eventdata, handles)
%
% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1}=handles.output;

%====================================================
% Object Control
%====================================================
function exclusive_rdb(h,hs)
% Radio-Button On/Off control
set([hs.rdb_Cz,hs.rdb_nz,hs.rdb_AR,hs.rdb_Iz,hs.rdb_AL],'Value',0);
set([hs.rdb_Cz,hs.rdb_nz,hs.rdb_AR,hs.rdb_Iz,hs.rdb_AL],'BackgroundColor',[0.925 0.914 0.847]);
set(h,'Value',1);
set(h,'BackgroundColor',[0.0 0.5 1.0]);

function ret=getCurrentPosHandler(hs)
% get Current Position [Nz, AL, ...]
rdb_hs=[hs.rdb_Cz,hs.rdb_nz,hs.rdb_AR,hs.rdb_Iz,hs.rdb_AL];
txt_hs=[hs.txt_Cz,hs.txt_Nz,hs.txt_AR,hs.txt_Iz,hs.txt_AL];
dst_hs=[hs.dist_Cz,hs.dist_Nz,hs.dist_AR,hs.dist_Iz,hs.dist_AL];
for ii=1:length(rdb_hs)
    if (get(rdb_hs(ii),'Value')==1)
        h=txt_hs(ii); d=dst_hs(ii);
        ret = [h d];
        return;
    end
end
h=0; d=0;
ret = [h d];
return;

function setNext_rdb(hs)
rdb_hs=[hs.rdb_Cz,hs.rdb_nz,hs.rdb_AR,hs.rdb_Iz,hs.rdb_AL];
for ii=1:length(rdb_hs)
    if (get(rdb_hs(ii),'Value')==1)
        if(ii==length(rdb_hs))
            i_next=1;
        else
            i_next=ii+1;
        end
        exclusive_rdb(rdb_hs(i_next),hs);
        return;
    end
end

function setpos(handle,pos,hs)
% Set Position
h = handle(1); d = handle(2);
MeasureCount=getappdata(h,'MeasureCount');
if(MeasureCount==0)
    set(h,'String',sprintf('(% 5.1f,% 5.1f,% 5.1f)',pos(1),pos(2),pos(3)));
    set(h,'BackgroundColor',[0.925 0.914 0.847]);
    set(h,'ForegroundColor',[0 0 0]);

    setappdata(h,'Measure2',pos);
    setappdata(h,'MeasureCount',1);
    if(d~=hs.dist_Cz)
        if(getappdata(hs.txt_Cz,'MeasureCount')~=0)
            posCz=getappdata(hs.txt_Cz,'Measure2');
            diff = sqrt((posCz(1)-pos(1))^2+(posCz(2)-pos(2))^2+(posCz(3)-pos(3))^2 );
            set(d,'String',sprintf('%5.1f',diff));
        end
    end
else
    measure1 = getappdata(h,'Measure2');
    distance = sqrt((measure1(1)-pos(1))^2+(measure1(2)-pos(2))^2+(measure1(3)-pos(3))^2 );
    set(h,'String',sprintf( '(% 5.1f,% 5.1f,% 5.1f)\n(% 5.1f,% 5.1f,% 5.1f)\n delta: % 6.2f',...
            measure1(1),measure1(2),measure1(3),pos(1),pos(2),pos(3),...
            distance ));
%    if(distance <= 1.0 )
    if(distance <= str2num(get(hs.tolerance,'String')) )
        set(h,'BackgroundColor',[0.667 1.0 0.667]);
        set(h,'ForegroundColor',[0 0 0]);
    else
        set(h,'BackgroundColor',[1 0.75 0.75]);
        set(h,'ForegroundColor',[0.25 0 0]);
    end
    
    setappdata(h,'Measure1',measure1);
    setappdata(h,'Measure2',pos);
    if(d~=hs.dist_Cz)
        if(getappdata(hs.txt_Cz,'MeasureCount')~=0)
            posCz=getappdata(hs.txt_Cz,'Measure2');
            diff = sqrt((posCz(1)-pos(1))^2+(posCz(2)-pos(2))^2+(posCz(3)-pos(3))^2 );
            set(d,'String',sprintf('%5.1f',diff));
        end
    end
    setappdata(h,'MeasureCount',2);
end

function rdb_nz_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);
function rdb_AL_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);
function rdb_Cz_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);
function rdb_AR_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);
function rdb_Iz_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);


%====================================================
% Start / Stop Measurement
%====================================================
function tog_start_Callback(h, eventdata, hs)
% 
if get(h,'Value')==1
    % Start Measure
    %s=serial('com3');
    %s=serial('com1','BaudRate',115200,'Parity','none');
    s=serial('com3','BaudRate',115200,'Parity','none');
    fopen(s);
    %readasync(s);
    setappdata(hs.figure1,'SerialPort',s);
    set(h,'String','Stop'); % OK

    % TODO: set Event
    s.BytesAvailableFcnMode = 'terminator';
    s.BytesAvailableFcn = {@ReadCallBack,h,hs};
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

else
    % Stop Measurement
    s=getappdata(hs.figure1,'SerialPort');
%    CtrlY=char(25);
%    fprintf(s,CtrlY);
    dev3dpos('go2ini',s);
    fclose(s)
    set(h,'String','Start'); % OK
end

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
   setpos(getCurrentPosHandler(hs),pos,hs);
   setNext_rdb(hs);   
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(h, eventdata, hs)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setpos(getCurrentPosHandler(hs),[0 1 2],hs);

%=======
% --- Executes on button press in tog_start.
% hObject    handle to tog_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tog_start




% --- Executes on button press in rdb_Cz.
%function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to rdb_Cz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdb_Cz


% --- Executes on button press in rdb_AR.
%function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to rdb_AR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdb_AR


% --- Executes on button press in rdb_Iz.
%function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to rdb_Iz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdb_Iz


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save button
Name = getappdata(handles.figure1,'Name');
Id = getappdata(handles.figure1,'ID');
Sex = getappdata(handles.figure1,'Sex');
Age = getappdata(handles.figure1,'Age');
Comment = getappdata(handles.figure1,'Comment');
if((strcmp(Name,''))||(strcmp(Id,'')))
    message=sprintf('Not specified User Information.\nSet User Information\n');
    msgbox(message);
    return;
end
pos_name=['Cz' 'Nz' 'AR' 'Iz' 'AL'];
MeasureCount(5)=getappdata(handles.txt_AL,'MeasureCount');
MeasureCount(4)=getappdata(handles.txt_Iz,'MeasureCount');
MeasureCount(3)=getappdata(handles.txt_AR,'MeasureCount');
MeasureCount(2)=getappdata(handles.txt_Nz,'MeasureCount');
MeasureCount(1)=getappdata(handles.txt_Cz,'MeasureCount');

max_count=max(MeasureCount); min_count=min(MeasureCount);
if((max_count==1) && (min_count==1))
    method = 1;
elseif( min_count==0 )
    message=sprintf('Not measured position detected.\nMeasure all positions\n');
    msgbox(message);
    return;
else
    [OK_cancel method] = SelectingDataMethod();
    if(strcmp(OK_cancel,'cancel'))
        return;
    end
end
if(method==1)
%pos_Cz, pos_Nz, pos_Iz, pos_AR, pos_AL
    if(MeasureCount(1)==2)
        pos_Cz=getappdata(handles.txt_Cz,'Measure1');
    else
        pos_Cz=getappdata(handles.txt_Cz,'Measure2');
    end
    if(MeasureCount(2)==2)
        pos_Nz=getappdata(handles.txt_Nz,'Measure1');
    else
        pos_Nz=getappdata(handles.txt_Nz,'Measure2');
    end
    if(MeasureCount(3)==2)
        pos_AR=getappdata(handles.txt_AR,'Measure1');
    else
        pos_AR=getappdata(handles.txt_AR,'Measure2');
    end
    if(MeasureCount(4)==2)
        pos_Iz=getappdata(handles.txt_Iz,'Measure1');
    else
        pos_Iz=getappdata(handles.txt_Iz,'Measure2');
    end
    if(MeasureCount(5)==2)
        pos_AL=getappdata(handles.txt_AL,'Measure1');
    else
        pos_AL=getappdata(handles.txt_AL,'Measure2');
    end
elseif(method==2)
    pos_Cz=getappdata(handles.txt_Cz,'Measure2');
    pos_Nz=getappdata(handles.txt_Nz,'Measure2');
    pos_AR=getappdata(handles.txt_AR,'Measure2');
    pos_Iz=getappdata(handles.txt_Iz,'Measure2');
    pos_AL=getappdata(handles.txt_AL,'Measure2');
else
%average
    if(MeasureCount(1)==2)
        pos_Cz=mean([getappdata(handles.txt_Cz,'Measure1');getappdata(handles.txt_Cz,'Measure2')],1);
    else
        pos_Cz=getappdata(handles.txt_Cz,'Measure2');
    end
    if(MeasureCount(2)==2)
        pos_Nz=mean([getappdata(handles.txt_Nz,'Measure1');getappdata(handles.txt_Nz,'Measure2')],1);
    else
        pos_Nz=getappdata(handles.txt_Nz,'Measure2');
    end
    if(MeasureCount(3)==2)
        pos_AR=mean([getappdata(handles.txt_AR,'Measure1');getappdata(handles.txt_AR,'Measure2')],1);
    else
        pos_AR=getappdata(handles.txt_AR,'Measure2');
    end
    if(MeasureCount(4)==2)
        pos_Iz=mean([getappdata(handles.txt_Iz,'Measure1');getappdata(handles.txt_Iz,'Measure2')],1);
    else
        pos_Iz=getappdata(handles.txt_Iz,'Measure2');
    end
    if(MeasureCount(5)==2)
        pos_AL=mean([getappdata(handles.txt_AL,'Measure1');getappdata(handles.txt_AL,'Measure2')],1);
    else
        pos_AL=getappdata(handles.txt_AL,'Measure2');
    end
end    

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

ret=Ref_file_save(Name, Id, Sex, Age, Comment, pos_Cz, pos_Nz, pos_Iz, pos_AR, pos_AL);
cd(current_dir);
if(ret==1)
    close_Callback(hObject, eventdata, handles);
else
    return;
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear button
setappdata(handles.txt_Cz,'Measure1',0.0); setappdata(handles.txt_Cz,'Measure2',0.0);
setappdata(handles.txt_Nz,'Measure1',0.0); setappdata(handles.txt_Nz,'Measure2',0.0);
setappdata(handles.txt_AR,'Measure1',0.0); setappdata(handles.txt_AR,'Measure2',0.0);
setappdata(handles.txt_Iz,'Measure1',0.0); setappdata(handles.txt_Iz,'Measure2',0.0);
setappdata(handles.txt_AL,'Measure1',0.0); setappdata(handles.txt_AL,'Measure2',0.0);

setappdata(handles.txt_Cz,'MeasureCount',0); set(handles.txt_Cz,'String','');
setappdata(handles.txt_Nz,'MeasureCount',0); set(handles.txt_Nz,'String','');
setappdata(handles.txt_AR,'MeasureCount',0); set(handles.txt_AR,'String','');
setappdata(handles.txt_Iz,'MeasureCount',0); set(handles.txt_Iz,'String','');
setappdata(handles.txt_AL,'MeasureCount',0); set(handles.txt_AL,'String','');

set(handles.dist_Cz,'String',''); set(handles.txt_Cz,'BackgroundColor',[1.0 1.0 0.502]);
set(handles.dist_Nz,'String',''); set(handles.txt_Nz,'BackgroundColor',[1.0 1.0 0.502]);
set(handles.dist_AR,'String',''); set(handles.txt_AR,'BackgroundColor',[1.0 1.0 0.502]);
set(handles.dist_Iz,'String',''); set(handles.txt_Iz,'BackgroundColor',[1.0 1.0 0.502]);
set(handles.dist_AL,'String',''); set(handles.txt_AL,'BackgroundColor',[1.0 1.0 0.502]);

setappdata(handles.figure1,'Name','');
setappdata(handles.figure1,'ID','');
setappdata(handles.figure1,'Sex','Male');
setappdata(handles.figure1,'Age','0');
setappdata(handles.figure1,'Comment','');

exclusive_rdb(handles.rdb_Cz,handles);

% --- Executes on button press in pushbutton5.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% close button
close_Callback(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tolerance as text
%        str2double(get(hObject,'String')) returns contents of tolerance as a double
recalc_tolerance(handles);

function recalc_tolerance(hs)
tol = str2num(get(hs.tolerance,'String'));
txt_hs=[hs.txt_Cz,hs.txt_Nz,hs.txt_AR,hs.txt_Iz,hs.txt_AL];
dst_hs=[hs.dist_Cz,hs.dist_Nz,hs.dist_AR,hs.dist_Iz,hs.dist_AL];

for ii=1:1:5
  h = txt_hs(ii); d = dst_hs(ii);
  MeasureCount=getappdata(h,'MeasureCount');
  if(MeasureCount==2)
    measure2= getappdata(h,'Measure2');
    measure1 = getappdata(h,'Measure1');
    distance = sqrt((measure1(1)-measure2(1))^2+(measure1(2)-measure2(2))^2+(measure1(3)-measure2(3))^2 );
    if(distance <= str2num(get(hs.tolerance,'String')) )
        set(h,'BackgroundColor',[0.667 1.0 0.667]);
        set(h,'ForegroundColor',[0 0 0]);
    else
        set(h,'BackgroundColor',[1 0.75 0.75]);
        set(h,'ForegroundColor',[0.25 0 0]);
    end
  end
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
name = getappdata(handles.figure1,'Name');
id = getappdata(handles.figure1,'ID');
sex = getappdata(handles.figure1,'Sex');
age = getappdata(handles.figure1,'Age');
comment = getappdata(handles.figure1,'Comment');
[flag,name,id,sex,age,comment] = UserInfo('Name',name,'ID',id,'Sex',sex,'Age',age,'Comment',comment);
if(strcmp(flag,'OK'))
  setappdata(handles.figure1,'Name',name);
  setappdata(handles.figure1,'ID',id);
  setappdata(handles.figure1,'Sex',sex);
  setappdata(handles.figure1,'Age',age);
  setappdata(handles.figure1,'Comment',comment);
end


