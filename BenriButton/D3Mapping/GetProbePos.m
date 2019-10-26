function varargout = GetProbePos(varargin)
% GetProbePos.m -- Programmatic main function to set up a GUI
%
% Create a figure that will have a uitable, axes and checkboxes
%figure('Units','pixels',...

try
  fid=fopen(varargin{1},'r');
catch
  msgbox(lasterr);
  msgbox('Close GetProbePos Window');
  return;
end
[Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
fclose(fid);

handles.figure1=figure('Position', [0, 75, 800, 560],...
       'Name', 'Get Probe Positions',...  % Title figure
       'NumberTitle', 'off',... % Do not show figure number
       'MenuBar', 'none');      % Hide standard menu bar menus
setappdata(handles.figure1,'RadioButtonHandles',[]);
setappdata(handles.figure1,'EditTextHandles',[]);
setappdata(handles.figure1,'EditTextTagNo',1);
setappdata(handles.figure1,'listb2_handle',[]);
setappdata(handles.figure1,'listb3_handle',[]);
%set(handles.figure1,'CloseRequestFcn','closereq');
set(handles.figure1,'CloseRequestFcn',{@close_Callback,handles});

popup_strings={'(3x3)x2:ETG100','4x4:ETG100','3x5:ETG100','8x8:ETG700','4x4:ETG700',...
  '3x5:ETG700','3x11:ETG700','2x10:WOT-System','2x8:WOT-Sysytem','2x4:WOT-System',...
  'other'};
handles.popup1=uicontrol(handles.figure1,'Style', 'popupmenu',...
          'Units', 'normalized',...
          'Position', [.0 .94 .2 .03],...
          'String', popup_strings,...
          'Value', 1,...
          'Callback', {@popupmenu1_Callback, handles});

handles.popup2=uicontrol(handles.figure1,'Style', 'popupmenu',...
          'Units', 'normalized',...
          'Position', [.25 .94 .1 .03],...
          'String', {'0-deg','90-deg','180-deg','270-deg'},...
          'Value', 1,...
          'Callback', {@popupmenu2_Callback, handles});
        
handles.pushb1=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.22 .88 .1 .03],...
          'String', 'Add Probe',...
          'Callback', {@pushbutton1_Callback, handles, popup_strings});
        
handles.pushb2=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.35 .88 .1 .03],...
          'String', 'Remove Probe',...
          'Callback', {@pushbutton2_Callback, handles});

handles.pushb_read_refpos=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.40 .94 .1 .03],...
          'String', 'Read Ref Pos',...
          'Callback', {@pushbutton_read_refpos_Callback, handles});

handles.pushb_get_refpos=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.52 .94 .1 .03],...
          'String', 'Get Ref Pos',...
          'Callback', {@pushbutton_get_refpos_Callback, handles});
        
handles.head_surface=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.64 .94 .1 .03],...
          'String', 'Disp HeadSurf',...
          'Callback', {@pushbutton_head_surface_Callback, handles});
        
handles.pushb_save=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.76 .94 .1 .03],...
          'String', 'Save',...
          'Callback', {@pushbutton_save_Callback, handles});

handles.pushb_cancel=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.88 .94 .1 .03],...
          'String', 'Close',...
          'Callback', {@pushbutton_cancel_Callback, handles});

handles.listb1=uicontrol(handles.figure1,'Style', 'listbox',...
          'Units', 'normalized',...
          'Position', [.0 .79 .2 .09],...
          'String', {''},...
          'Callback', {@listbox1_Callback, handles});
setappdata(handles.listb1,'Lines',0);

%handles.text1=uicontrol(handles.figure1,'Style', 'text',...
%          'Units', 'normalized',...
%          'Position', [.7 0.94 .2 .03],...
%          'String', [],...
%          'Value', 1);
handles.SelectProbe=uicontrol(handles.figure1,'Style', 'text',...
          'Units', 'normalized',...
          'Position', [.0 .97 .2 .03],...
          'String', 'SelectProbe',...
          'BackgroundColor',[0.8 0.8 0.8],...
          'Value', 1);
handles.Angle=uicontrol(handles.figure1,'Style', 'text',...
          'Units', 'normalized',...
          'Position', [.25 .97 .1 .03],...
          'String', 'Angle',...
          'BackgroundColor',[0.8 0.8 0.8],...
          'Value', 1);
%handles.Position=uicontrol(handles.figure1,'Style', 'text',...
%          'Units', 'normalized',...
%          'Position', [.7 0.97 .2 .03],...
%          'String', 'Position(std)',...
%          'BackgroundColor',[0.8 0.8 0.8],...
%          'Value', 1);
handles.ProbeList=uicontrol(handles.figure1,'Style', 'text',...
          'Units', 'normalized',...
          'Position', [.0 .88 .2 .03],...
          'String', 'ProbeList',...
          'BackgroundColor',[0.8 0.8 0.8],...
          'Value', 1);
%remember component handles
User.filename='';
GuiAppli.open_flag=0;
setappdata(handles.figure1,'User',User);
setappdata(handles.figure1,'Serial',Serial);
setappdata(handles.figure1,'Std_Ref',Std_Ref);
setappdata(handles.figure1,'GuiAppli',GuiAppli);
setappdata(handles.figure1,'Navigation',Navigation);

setappdata(handles.figure1,'popup1_handle',handles.popup1);
setappdata(handles.figure1,'popup2_handle',handles.popup2);
setappdata(handles.figure1,'pushb1_handle',handles.pushb1);
setappdata(handles.figure1,'pushb2_handle',handles.pushb2);
setappdata(handles.figure1,'listb1_handle',handles.listb1);
setappdata(handles.figure1,'ProbePos',[]);
setappdata(handles.figure1,'Positions',[]);
setappdata(handles.figure1,'CurrentLine',0);
%setappdata(handles.figure1,'text1_handle',handles.text1);
setappdata(handles.figure1,'popup_strings',popup_strings);
setappdata(handles.figure1,'Angle_handle',handles.Angle);
setappdata(handles.figure1,'ProbePositions_handle',[]);
setappdata(handles.figure1,'pushb_cancel_handle',handles.pushb_cancel);
setappdata(handles.figure1,'pushb_save_handle',handles.pushb_save);
setappdata(handles.figure1,'flag_modify_data',0);
guidata(handles.figure1, handles);

try
  OpenSerialPort(handles.figure1, handles);
catch
  msgbox(lasterr);
  msgbox('Close Get Probe Pos Window.');
  return;
end

handles.pushb_reconnect=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.01 .01 .1 .03],...
          'String', 'Reconnect',...
          'Callback', {@pushb_reconnect_Callback, handles});

function pushbutton_read_refpos_Callback(hObject, eventdata, handles)
% Select position file(.pos)
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
    return;
end
% Read Position File & Make Afine-Matrix
fpath = fullfile(dpath, fname);
fid=fopen(fpath,'r');
[User RefPoints] =Ref_file_read(fid);
User.filename=fname;
fclose(fid);

setappdata(handles.figure1,'User',User);
setappdata(handles.figure1,'RefPoints',RefPoints);
Std_Ref = getappdata(handles.figure1,'Std_Ref');

CalcAffineMatrix(Std_Ref, RefPoints, handles);

function CalcAffineMatrix(Std_Ref, RefPoints, handles)

O = [RefPoints.LeftEar; RefPoints.RightEar; RefPoints.Nasion; RefPoints.Back; RefPoints.Top];
Aos = affine_trans('make_mat', O);
Aso = affine_trans('make_inv', O);
Aso_size = affine_trans('get_size_part', Aso);

setappdata(handles.figure1,'Aos',Aos);
setappdata(handles.figure1,'Aso_size',Aso_size);


function pushbutton_head_surface_Callback(hObject, eventdata, handles)
User = getappdata(handles.figure1,'User');
if strcmp(User.filename,'')
  msgbox('Perform ''Read Ref Pos'' or ''Get Ref Pos'' previously');
  return;
end

GuiAppli = getappdata(handles.figure1,'GuiAppli');

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
Aso_size = getappdata(handles.figure1,'Aso_size');

if(GuiAppli.open_flag == 1)
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
end

if(~exist(HS_Vertex,'file') || ~exist(HS_Edge,'file') || ...
        ~exist(BS_Vertex,'file') || ~exist(BS_Edge,'file') )
	msgbox('Head & Brain Vertex-Edge File(s) not exist. Display Head Surface cancelled.');
    GuiAppli.open_flag=0;
    return;
end
[Shmem hShare]=SetShareMem4GUI(Aso_size,HS_Vertex,HS_Edge,BS_Vertex,BS_Edge);
%Aso_part==Aso_size*Aso_rot

% Open GUI
current_dir = pwd;
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  GuiAppli_GetProbePos=['WinP3_mcr\' GuiAppli.GetProbePos];
else
    GuiAppli_GetProbePos=GuiAppli.GetProbePos;
end
CreateProcess(GuiAppli_GetProbePos);

cd(current_dir);

setappdata(handles.figure1,'Shmem',Shmem);
setappdata(handles.figure1,'hShare',hShare);
GuiAppli.open_flag = 1;
setappdata(handles.figure1,'GuiAppli',GuiAppli);


function pushbutton_get_refpos_Callback(hObject, eventdata, handles)
sp=getappdata(handles.figure1,'SerialPort');
fclose(sp);

ret = get_refpoints_on_the_fly('IniFile','BenriButton\D3Mapping\ini\D3_ini.txt');
if(ret==1)
  dpath = 'BenriButton\D3Mapping\ref\';
  fname = 'current.ref';
  fpath = fullfile(dpath, fname);
  try
    fid=fopen(fpath,'r');
  catch
    msgbox(lasterr);
    return;
  end
  [User RefPoints] =Ref_file_read(fid);
  User.filename=fname;
  fclose(fid);
  setappdata(handles.figure1,'User',User);
  setappdata(handles.figure1,'RefPoints',RefPoints);
  Std_Ref = getappdata(handles.figure1,'Std_Ref');

  CalcAffineMatrix(Std_Ref, RefPoints, handles);

end

%try
%  OpenSerialPort(handles.figure1, handles);
%catch
%  msgbox(lasterr);
%  delete(get(0,'CurrentFigure'));
%  return;
%end

sp=getappdata(handles.figure1,'SerialPort');
fopen(sp);
fclose(sp);
fopen(sp);

%
% pushb_reconnect_Callback()
%
function pushb_reconnect_Callback(hObject, eventdata, handles)
sp=getappdata(handles.figure1,'SerialPort');
fclose(sp);
fopen(sp);
%sp.BytesAvailableFcnMode = 'terminator';
%sp.BytesAvailableFcn = {@ReadCallBack,handles.figure1,handles};

function pushbutton_cancel_Callback(hObject, eventdata, handles)
selection = questdlg('Close Window?','Canceling','Close','No','Close');
GuiAppli = getappdata(handles.figure1,'GuiAppli');
switch selection
  case 'Close'
    if(GuiAppli.open_flag==1)
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
    end
    try
      CloseSerialPort(hObject, handles);
      delete(get(0,'CurrentFigure'));
    catch
      delete(get(0,'CurrentFigure'));
    end
  case 'No'
    return;
end

function pushbutton_save_Callback(hObject, eventdata, handles)
ProbePos=getappdata(handles.figure1,'ProbePos');
current_line = getappdata(handles.figure1,'CurrentLine');
if current_line > 0
  Positions = getappdata(handles.figure1,'Positions');
  ProbePos{current_line,4} = Positions;
  if( (ProbePos{current_line,1}>=1)&&(ProbePos{current_line,1}<=10) )
    line_in_listb3=get(getappdata(handles.figure1,'listb3_handle'),'Value');
    ProbePos{current_line,5} = line_in_listb3;
  elseif(ProbePos{current_line,1}==11)
    line_in_listb2=get(getappdata(handles.figure1,'listb2_handle'),'Value');
    ProbePos{current_line,5} = line_in_listb2;
  end
  setappdata(handles.figure1,'ProbePos',ProbePos);
  
  if( IsFilledData(ProbePos, current_line) )
    val = get(hObject,'Value');
    setappdata(handles.figure1,'listb1',val);
    guidata(hObject, handles);
    User = getappdata(handles.figure1,'User');
    RefPoints = getappdata(handles.figure1,'RefPoints');
    current_dir = pwd;
    osp_path=OSP_DATA('GET','OspPath');
    if isempty(osp_path)
      osp_path=fileparts(which('POTATo'));
    end
    [pp ff] = fileparts(osp_path);
    if( strcmp(ff,'WinP3')~=0 )
      try
        cd('WinP3_mcr\BenriButton\D3Mapping\pos');
      catch
        error(['Cannot find a directory : ' 'WinP3_mcr\BenriButton\D3Mapping\pos' ': current is ' current_dir]);
        return;
      end
    else
      cd('BenriButton\D3Mapping\pos');
    end

    [fname, dpath, findex] = uiputfile('*.pos','Specify File Name','new.pos');
    cd(current_dir);
    if findex~=0 
      fpath = fullfile(dpath, fname);
      fid=fopen(fpath,'w');
      Pos_file_save(fid, User, RefPoints, ProbePos);
      fclose(fid);
      setappdata(handles.figure1,'flag_modify_data',0);
    else
      msgbox('pos-data not saved');
    end
  else
    msgbox('Not measured all positions');
    setappdata(handles.figure1,'listb1',current_line);
    set(getappdata(handles.figure1,'listb1_handle'),'Value',current_line);
  end
else
  msgbox('No data to save');
end

function exclusive_rdb(hObject,handles)
% Radio-Button On/Off control
Positions = getappdata(handles.figure1,'Positions');
rbh = getappdata(handles.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);

if(ny>0)
  for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          set(rbh(ix,iy,iz),'Value',0);
          idx = (iz-1)*ny*nx + (iy-1)*nx + ix;
          mod_x = mod(ix,2); mod_y = mod(iy,2);
          [row col]=size(Positions{idx});
          if(col>0)
            if(mod_y==1)
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.75 0.75]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[0.75 1.0 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              end
            else
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[0.75 1.0 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.75 0.75]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              end
            end
          else
            if(mod_y==1)
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.5]);
                set(rbh(ix,iy,iz),'FontWeight','normal');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[0.0 1.0 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','normal');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              end
            else
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[0.0 1.0 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','normal');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.5]);
                set(rbh(ix,iy,iz),'FontWeight','normal');
                set(rbh(ix,iy,iz),'FontSize',9.0);
              end
            end
          end
          if(rbh(ix,iy,iz)==hObject)
            if(mod_y==1)
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.25 0.25]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',12.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[0.0 0.5 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',12.0);
              end
            else
              if(mod_x==1)
                set(rbh(ix,iy,iz),'BackgroundColor',[0.0 0.5 1.0]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',12.0);
              else
                set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.25 0.25]);
                set(rbh(ix,iy,iz),'FontWeight','bold');
                set(rbh(ix,iy,iz),'FontSize',12.0);
              end
            end
          end
        end
      end
  end
end
set(hObject,'Value',1);

function [ix iy iz h]=getCurrentPosHandler(handles)
% get Current Position
rbh = getappdata(handles.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
if(ny>0)
  for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          if(get(rbh(ix,iy,iz),'Value')==1)
            h=rbh(ix,iy,iz);
            return;
          end
        end
      end
  end
end
h=0;
return;

function setNext_rdb(handles)
% get Current Position
rbh = getappdata(handles.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
[ix iy iz h]=getCurrentPosHandler(handles);

seq_no = (iz-1)*ny*nx+(iy-1)*nx+ix +1; % +1 : next
seq_no = mod((seq_no-1),nx*ny*nz) + 1;
iz = floor((seq_no-1)/(ny*nx))+1; mod_no = seq_no - (iz-1)*(ny*nx);
iy = floor((mod_no-1)/(nx))+1; ix = mod_no - (iy-1)*nx;
exclusive_rdb(rbh(ix,iy,iz),handles);
line = (iz-1)*(nx*ny) + (iy-1)*nx + ix;
h_listb3 = getappdata(handles.figure1,'listb3_handle');
set(h_listb3,'Value',line);


function setpos(hs,pos)
% Set Position
[ix iy iz h]=getCurrentPosHandler(hs);
rbh = getappdata(hs.figure1,'RadioButtonHandles');
Positions = getappdata(hs.figure1,'Positions');
[nx ny nz] = size(rbh);
seq_no = (iz-1)*ny*nx+(iy-1)*nx+ix;
Positions{seq_no} = [pos(1) pos(2) pos(3)];
setappdata(hs.figure1,'Positions',Positions);

%
% function rdb_Callback() : for radio button for detection seqence
%
function rdb_Callback(h, eventdata, hs)
exclusive_rdb(h,hs);
h_listb3 = getappdata(hs.figure1,'listb3_handle');
rbh = getappdata(hs.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
[ix iy iz h]=getCurrentPosHandler(hs);
line = (iz-1)*(nx*ny) + (iy-1)*nx + ix;
set(h_listb3,'Value',line);


function delete_rb_handles(handles)
rbh = getappdata(handles.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
if(ny>0)
  for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          delete(rbh(ix,iy,iz));
        end
      end
  end
end
setappdata(handles.figure1,'RadioButtonHandles',[]);

%
% function delete_edit_handles() : for Probe Name Editing
%
function delete_edit_handles(handles)
edith = getappdata(handles.figure1,'EditTextHandles');
[nx ny] = size(edith);
if(nx>0)
  for ix=1:1:nx
      for iy=1:1:ny
        delete(edith(ix,iy));
      end
  end
end
setappdata(handles.figure1,'EditTextHandles',[]);

%
% function delete_edit_handles() : for Probe Name Editing
%
function delete_pushb3_handles(handles)
h_pushb3 = getappdata(handles.figure1,'pushb3_handle');
[nx ny] = size(h_pushb3);
if(nx>0)
  for ix=1:1:nx
      for iy=1:1:ny
        delete(h_pushb3(ix,iy));
      end
  end
end
setappdata(handles.figure1,'pushb3_handle',[]);


%
% function delete_listb2_handles() : for coordinate list for other device
%
function delete_listb2_handles(handles)
listb2 = getappdata(handles.figure1,'listb2_handle');
[nx ny] = size(listb2);
if(nx>0)
  for ix=1:1:nx
      for iy=1:1:ny
        delete(listb2(ix,iy));
      end
  end
end
setappdata(handles.figure1,'listb2_handle',[]);

%
% function delete_listb3_handles() : for coordinate list for ordinal device
%
function delete_listb3_handles(handles)
listb3 = getappdata(handles.figure1,'listb3_handle');
[nx ny] = size(listb3);
if(nx>0)
  for ix=1:1:nx
      for iy=1:1:ny
        delete(listb3(ix,iy));
      end
  end
end
setappdata(handles.figure1,'listb3_handle',[]);

%
% function delete_ProbePositions_handles() : text box
%
function delete_ProbePositions_handles(handles)
h_ProbePositions = getappdata(handles.figure1,'ProbePositions_handle');
[nx ny] = size(h_ProbePositions);
if(nx>0)
  for ix=1:1:nx
      for iy=1:1:ny
        delete(h_ProbePositions(ix,iy));
      end
  end
end
setappdata(handles.figure1,'ProbePositions_handle',[]);


%
% function popupmenu1_Callback() : for mode selection popup
%
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
setappdata(handles.figure1,'popupmenu1',val);
guidata(hObject, handles);

switch val
  case 11
    TagNo = getappdata(handles.figure1,'EditTextTagNo');
    %setappdata(handles.figure1,'EditTextTagNo',TagNo);
    edith = getappdata(handles.figure1,'EditTextHandles');
    [nx ny] = size(edith);
    if(nx==0)
      handles.edit1=uicontrol(handles.figure1,'Style', 'edit',...
          'Units', 'normalized',...
          'Position', [.25 .94 .1 .03],...
          'String', {num2str(TagNo)},...
          'Callback', {@edit1_Callback, handles});
      setappdata(handles.figure1,'EditTextHandles',handles.edit1);
      h_Angle = getappdata(handles.figure1,'Angle_handle');
      set(h_Angle,'String','TagName');
      guidata(hObject, handles);
    end
%    c = 'Enter Probe Name';
%    h = msgbox(c);

  otherwise
  h_Angle = getappdata(handles.figure1,'Angle_handle');
  set(h_Angle,'String','Angle');
  delete_edit_handles(handles);
end

%
% function edit1_Callback() : for Probe Name editing
%
function edit1_Callback(hObject, eventdata, handles)

%
% function listbox1_Callback() : for Probe set List
%
function listbox1_Callback(hObject, eventdata, handles)
ProbePos=getappdata(handles.figure1,'ProbePos');
prev_line = getappdata(handles.figure1,'CurrentLine');
if prev_line > 0
  Positions = getappdata(handles.figure1,'Positions');
  ProbePos{prev_line,4} = Positions;
  if( (ProbePos{prev_line,1}>=1)&&(ProbePos{prev_line,1}<=10) )
    line_in_listb3=get(getappdata(handles.figure1,'listb3_handle'),'Value');
    ProbePos{prev_line,5} = line_in_listb3;
  elseif(ProbePos{prev_line,1}==11)
    line_in_listb2=get(getappdata(handles.figure1,'listb2_handle'),'Value');
    ProbePos{prev_line,5} = line_in_listb2;
  end
  setappdata(handles.figure1,'ProbePos',ProbePos);
  
  val = get(hObject,'Value');
  if( IsFilledData(ProbePos, prev_line) )
    setappdata(handles.figure1,'listb1',val);
    % Redraw new current detecting figure
    guidata(hObject, handles);
    redraw_Probe_Layout(handles, val);
    setappdata(handles.figure1,'CurrentLine',val);
    guidata(hObject, handles);
  elseif(prev_line~=val)
    msgbox('Not measured all positions');
    setappdata(handles.figure1,'listb1',prev_line);
    set(getappdata(handles.figure1,'listb1_handle'),'Value',prev_line);
  end
  ProbePos=getappdata(handles.figure1,'ProbePos');
  set(getappdata(handles.figure1,'popup1_handle'),'Value',ProbePos{val,1});
  if(ProbePos{val,1}==11) % other case
    edith = getappdata(handles.figure1,'EditTextHandles');
    [nx ny] = size(edith);
    if(nx==0)
      handles.edit1=uicontrol(handles.figure1,'Style', 'edit',...
          'Units', 'normalized',...
          'Position', [.25 .94 .1 .03],...
          'Callback', {@edit1_Callback, handles});
      setappdata(handles.figure1,'EditTextHandles',handles.edit1);
    end
    set(getappdata(handles.figure1,'EditTextHandles'),'String',ProbePos{val,2});
  else
    set(getappdata(handles.figure1,'popup2_handle'),'Value',ProbePos{val,2});
    delete_edit_handles(handles);
  end
end

function ret=IsFilledData(ProbePos, line)
ret=1;
Positions = ProbePos{line,4};
if(isempty(Positions))
  ret=0;
  return;
end
mode = ProbePos{line,1};
n_xyz = ProbePos{line,3};
switch mode
  case {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    data_points = n_xyz(1)*n_xyz(2)*n_xyz(3);
    [row col]=size(Positions);
    if(col < data_points)
      ret=0;
      return;
    end
    for index=1:1:data_points
      [row col] = size(Positions{index});
      if( col <3 )
        ret=0;
        return;
      end
    end
  case {11}
    [row col] = size(Positions);
    if( col <=0 )
      ret=0;
      return;
    end
end

%
% function pushbutton2_Callback() : for Remove Probe button
%
function pushbutton2_Callback(hObject, eventdata, handles)
line = get(getappdata(handles.figure1,'listb1_handle'),'Value');
h_listbox1=getappdata(handles.figure1,'listb1_handle');
ProbePos=getappdata(handles.figure1,'ProbePos');
Lines = getappdata(h_listbox1,'Lines');
if Lines>= line
  ListCellArray=get(h_listbox1,'String');
  for l=line:1:Lines-1
    ListCellArray(l,1)=ListCellArray(l+1,1);
    ProbePos(l,:) = ProbePos(l+1,:);
  end
%  ListCellArray(Lines,1)=cellstr('');
  ListCellArray=ListCellArray(1:Lines-1,1);
  ProbePos = ProbePos(1:Lines-1,:);
  set(h_listbox1,'String',ListCellArray);
  setappdata(h_listbox1,'Lines',Lines-1);
  if Lines==line
    if Lines>1
      set(getappdata(handles.figure1,'listb1_handle'),'Value',line-1);
    end
  end
end
setappdata(handles.figure1,'ProbePos',ProbePos);
val = get(getappdata(handles.figure1,'listb1_handle'),'Value');
setappdata(handles.figure1,'listb1',val);
guidata(hObject, handles);

redraw_Probe_Layout(handles, val);

setappdata(handles.figure1,'CurrentLine',val);
if(isempty(ProbePos))
  delete_ProbePositions_handles(handles);
  setappdata(handles.figure1,'CurrentLine',0);
end
guidata(hObject, handles);
  
%
% function pushbutton1_Callback() : for Add Probe push button
%
function pushbutton1_Callback(hObject, eventdata, handles, popup_strings)
ProbePos=getappdata(handles.figure1,'ProbePos');
current = getappdata(handles.figure1,'CurrentLine');
if(current > 0)
  Positions = getappdata(handles.figure1,'Positions');
  ProbePos{current,4} = Positions;
  if( (ProbePos{current,1}>=1)&&(ProbePos{current,1}<=10) )
    line_in_listb3=get(getappdata(handles.figure1,'listb3_handle'),'Value');
    ProbePos{current,5} = line_in_listb3;
  elseif(ProbePos{current,1}==11)
    line_in_listb2 = get(getappdata(handles.figure1,'listb2_handle'),'Value');
    ProbePos{current,5} = line_in_listb2;
  end
  setappdata(handles.figure1,'ProbePos',ProbePos);
  
  h_listbox1=getappdata(handles.figure1,'listb1_handle');
  if( IsFilledData(ProbePos, current) )
    val = get(h_listbox1,'Value');
    setappdata(handles.figure1,'listb1',val);
    guidata(h_listbox1, handles);
  else
    msgbox('Not measured all positions');
    setappdata(handles.figure1,'listb1',current);
    set(h_listbox1,'Value',current);
    return;
  end
end

setappdata(handles.figure1,'Positions',[]);

val = get(getappdata(handles.figure1,'popup1_handle'),'Value');
val2 = get(getappdata(handles.figure1,'popup2_handle'),'Value');
angle=(val2-1)*pi/2;
cos_ = cos(angle); sin_ = sin(angle);

delete_rb_handles(handles);
delete_listb2_handles(handles);
delete_listb3_handles(handles);
delete_pushb3_handles(handles);
h_listbox1=getappdata(handles.figure1,'listb1_handle');
Lines = getappdata(h_listbox1,'Lines');
ListCellArray=get(h_listbox1,'String');
line = get(h_listbox1,'Value');
if Lines==0, line=0;, end

for l=Lines:-1:line+1
  ListCellArray(l+1,1) = ListCellArray(l,1);
  ProbePos(l+1,:) = ProbePos(l,:);
end

if val==11
  ProbeName = get(getappdata(handles.figure1,'EditTextHandles'),'String');
  ListCellArray(line+1,1)=cellstr([popup_strings{val} '  :  ' ProbeName{1}]);
  ProbePos{line+1,1} = val; ProbePos{line+1,2} = ProbeName{1};
  TagNo = getappdata(handles.figure1,'EditTextTagNo');
  TagNo = TagNo;
  setappdata(handles.figure1,'EditTextTagNo',TagNo);
  set(getappdata(handles.figure1,'EditTextHandles'),'String', {num2str(TagNo)});
else
  ListCellArray(line+1,1)=cellstr([popup_strings{val} '  :  ' num2str((val2-1)*90)]);
  ProbePos{line+1,1} = val; ProbePos{line+1,2} = val2;
end
set(h_listbox1,'String',ListCellArray);
set(h_listbox1,'Value',Lines+1);
setappdata(handles.figure1,'CurrentLine',line+1);
setappdata(h_listbox1,'Lines',Lines+1);

switch val
  case {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    %c = str{val};
    %h = msgbox(c);
    switch val
      case 1
        nx=3; ny=3; nz=2; measure_mode=1; size_x_norm=0.7; size_y_norm=0.7;
      case 2
        nx=4; ny=4; nz=1; measure_mode=2; size_x_norm=0.7; size_y_norm=0.7;
      case 3
        nx=5; ny=3; nz=1; measure_mode=3; size_x_norm=0.7; size_y_norm=0.7;
      case 4
        nx=8; ny=8; nz=1; measure_mode=50; size_x_norm=0.7; size_y_norm=0.7;
      case 5
        nx=4; ny=4; nz=1; measure_mode=51; size_x_norm=0.7; size_y_norm=0.7;
      case 6
        nx=5; ny=3; nz=1; measure_mode=52; size_x_norm=0.7; size_y_norm=0.7;
      case 7
        nx=11; ny=3; nz=1; measure_mode=54; size_x_norm=0.7; size_y_norm=0.7;
      case 8
        nx=10; ny=2; nz=1; measure_mode=200; size_x_norm=0.7; size_y_norm=0.2;
      case 9
        nx=8; ny=2; nz=1; measure_mode=201; size_x_norm=0.7; size_y_norm=0.2;
      case 10
        nx=4; ny=2; nz=1; measure_mode=202; size_x_norm=0.7; size_y_norm=0.2;
    end
    for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          Positions{(iz-1)*ny*nx+(iy-1)*nx+ix}=[];
        end
      end
    end
    setappdata(handles.figure1,'Positions',Positions);
    ProbePos{line+1,4}=Positions;
    ProbePos{line+1,3}=[nx ny nz];
    layout_positions = time_axes_position_D3(measure_mode, [size_x_norm size_y_norm], [0.1 0.1]);
    [size_layout_positions col] = size(layout_positions);
    max_xx = max(layout_positions(1:size_layout_positions,1));
    min_xx = min(layout_positions(1:size_layout_positions,1));
    max_yy = max(layout_positions(1:size_layout_positions,2));
    min_yy = min(layout_positions(1:size_layout_positions,2));
    center_x = (max_xx-min_xx)/2.0 + min_xx;
    center_y = (max_yy-min_yy)/2.0 + min_yy;
    
    for iz=1:1:nz
      start_idx = (iz-1)*(size_layout_positions/nz)+1;
      end_idx = start_idx + (size_layout_positions/nz) -1;
      min_x = min(layout_positions(start_idx:end_idx,1));
      max_x = max(layout_positions(start_idx:end_idx,1));
      min_y = min(layout_positions(start_idx:end_idx,2));
      max_y = max(layout_positions(start_idx:end_idx,2));
      step_x = (max_x-min_x)/(nx-1);
      step_y = (max_y-min_y)/(ny-1);
      for iy=1:1:ny
        for ix=1:1:nx
          index_no = (iz-1)*ny*nx+(iy-1)*nx+ix;
          no_str=sprintf('%d',index_no);
          %pos_x = ((iz-1)*nx+ix-1)/((nx+1)*(nz))+0.15+(iz-1)*0.1-0.5;
          %pos_y = (ny-iy)/((ny+2)*(nz))+0.0+0.4-0.5;
          %x_position = pos_x*cos_-pos_y*sin_;
          %y_position = pos_x*sin_+pos_y*cos_;
          pos_x = min_x + step_x*(ix-1);
          pos_y = max_y - step_y*(iy-1);
          x_position = (pos_x-center_x)*cos_-(pos_y-center_y)*sin_ + 0.6;
          y_position = (pos_x-center_x)*sin_+(pos_y-center_y)*cos_ + 0.5;
          rbh(ix,iy,iz) = uicontrol(handles.figure1, 'Style', 'radiobutton',...
            'Units', 'normalized',...
            'String',no_str,...
            'Value',0,...
            'Position',[x_position y_position 0.05 0.05]);

          mod_x = mod(ix,2); mod_y = mod(iy,2);
          if(mod_y==1)
            if(mod_x==1)
              set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.5]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            else
              set(rbh(ix,iy,iz),'BackgroundColor',[0.5 1.0 1.0]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            end
          else
            if(mod_x==1)
              set(rbh(ix,iy,iz),'BackgroundColor',[0.5 1.0 1.0]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            else
              set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.5]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            end
          end
        end
      end
    end
    for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          set(rbh(ix,iy,iz),'Callback',{@rdb_Callback,handles});
          index_no = (iz-1)*ny*nx+(iy-1)*nx+ix;
          position_strings{index_no}=sprintf('%3d:',index_no);
        end
      end
    end
    setappdata(handles.figure1,'RadioButtonHandles',rbh);
    
    
    handles.listb3=uicontrol(handles.figure1,'Style', 'listbox',...
          'Units', 'normalized',...
          'Position', [.0 .04 .2 .7],...
          'String', position_strings,...
          'Callback', {@listbox3_Callback, handles});
    exclusive_rdb(rbh(1,1,1),handles)
    guidata(hObject, handles);
    setappdata(handles.figure1,'listb3_handle',handles.listb3);
    setappdata(handles.listb3,'Lines',nx*ny*nz);
    guidata(hObject, handles);
    
  otherwise
    nx=1; ny=1; nz=1;
    Positions=[];
    setappdata(handles.figure1,'Positions',Positions);

    handles.listb2=uicontrol(handles.figure1,'Style', 'listbox',...
          'Units', 'normalized',...
          'Position', [.0 .04 .2 .7],...
          'String', {'(Insert TopLine)'},...
          'Callback', {@listbox2_Callback, handles});
    setappdata(handles.figure1,'listb2_handle',handles.listb2);
    setappdata(handles.listb2,'Lines',1);
    handles.pushb3=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.25 .69 .1 .03],...
          'String', 'Remove Pos',...
          'Callback', {@pushbutton3_Callback, handles});
    setappdata(handles.figure1,'pushb3_handle',handles.pushb3);
    guidata(hObject, handles);
    ProbePos{line+1,3}=[nx ny nz];
end
h_ProbePositions = getappdata(handles.figure1,'ProbePositions_handle');
[x_row y_col] = size(h_ProbePositions);
if( x_row==0 )
    handles.ProbePositions=uicontrol(handles.figure1,'Style', 'text',...
          'Units', 'normalized',...
          'Position', [.0 .74 .2 .03],...
          'String', 'ProbePositions',...
          'BackgroundColor',[0.8 0.8 0.8],...
          'Value', 1);
    setappdata(handles.figure1,'ProbePositions_handle',handles.ProbePositions);
end
ProbePos{line+1,4}=Positions;
ProbePos{line+1,5}=1;
setappdata(handles.figure1,'ProbePos',ProbePos);

%
% function listbox3_Callback() : select line in list-box3(ordinal_probe_pos_list)
%
function listbox3_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
rbh = getappdata(handles.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
iz = floor((line-1)/(nx*ny))+1;
mod_z = mod((line-1),(nx*ny))+1;
iy = floor((mod_z-1)/(nx))+1;
ix = mod((mod_z-1),nx)+1;
exclusive_rdb(rbh(ix,iy,iz),handles);

%
% function listbox2_Callback() : select line in list-box2(other_probe_pos_list)
%
function listbox2_Callback(hObject, eventdata, handles)

%
% function popupmenu2_Callback() : specfing angle of device array
%
function popupmenu2_Callback(hObject, eventdata, handles)
popupmenu1_Callback(handles.popup1, eventdata, handles);
current_line = getappdata(handles.figure1,'CurrentLine');
popup1_select = getappdata(handles.figure1,'popupmenu1');
if(current_line<1)
  return;
end
ProbePos=getappdata(handles.figure1,'ProbePos');
if( popup1_select~=ProbePos{current_line,1} )
  return;
end
val = get(hObject,'Value');
ProbePos{current_line,2}=val;
Positions = getappdata(handles.figure1,'Positions');
ProbePos{current_line,4} = Positions;
if( (ProbePos{current_line,1}>=1)&&(ProbePos{current_line,1}<=10) )
  line_in_listb3=get(getappdata(handles.figure1,'listb3_handle'),'Value');
  ProbePos{current_line,5} = line_in_listb3;
elseif(ProbePos{current_line,1}==11)
  line_in_listb2 = get(getappdata(handles.figure1,'listb2_handle'),'Value');
  ProbePos{current_line,5} = line_in_listb2;
end  
setappdata(handles.figure1,'ProbePos',ProbePos);
redraw_Probe_Layout(handles, current_line);
h_listbox1=getappdata(handles.figure1,'listb1_handle');
ListCellArray = get(h_listbox1,'String');
popup_strings = getappdata(handles.figure1,'popup_strings');
ListCellArray(current_line,1)=cellstr([popup_strings{ProbePos{current_line,1}} '  :  ' num2str((val-1)*90)]);
set(h_listbox1,'String',ListCellArray);

%
% function pushbutton3_Callback() : Remove Pos button
%
function pushbutton3_Callback(hObject, eventdata, handles)
h_listb2 = getappdata(handles.figure1,'listb2_handle');
Positions = getappdata(handles.figure1,'Positions');
line = get(h_listb2,'Value');
if line > 1
  Lines = getappdata(h_listb2,'Lines');
  ListCellArray2=get(h_listb2,'String');
  for l=line+1:1:Lines
    ListCellArray2(l-1,1)=ListCellArray2(l,1);
    Positions{l-2} = Positions{l-1};
  end
%  ListCellArray2(Lines,1)=cellstr('');
  ListCellArray2=ListCellArray2(1:Lines-1,1);
  Positions = Positions(1:Lines-2);
  set(h_listb2,'Value',line-1);
  set(h_listb2,'String',ListCellArray2);
  setappdata(h_listb2,'Lines',Lines-1);
  setappdata(handles.figure1,'Positions',Positions);
  guidata(h_listb2,handles);
end


function setpos_in_listbox2(hs,pos)
h_listb2 = getappdata(hs.figure1,'listb2_handle');
Positions = getappdata(hs.figure1,'Positions');
line = get(h_listb2,'Value');
Lines = getappdata(h_listb2,'Lines');
ListCellArray2=get(h_listb2,'String');
s_data = sprintf('(% 5.1f,% 5.1f,% 5.1f)',pos(1),pos(2),pos(3));
if Lines>=(line+1)
  for l=Lines:-1:(line+1)
    ListCellArray2(l+1,1)=ListCellArray2(l,1);
    Positions{l}=Positions{l-1};
  end
end
ListCellArray2(line+1,1)=cellstr(s_data);
Positions{line}=[pos(1) pos(2) pos(3)];

set(h_listb2,'String',ListCellArray2);
set(h_listb2,'Value',line+1);
setappdata(h_listb2,'Lines',Lines+1);
setappdata(hs.figure1,'Positions',Positions);
guidata(h_listb2,hs);

function setpos_in_listbox3(hs,pos)
h_listb3 = getappdata(hs.figure1,'listb3_handle');
rbh = getappdata(hs.figure1,'RadioButtonHandles');
[nx ny nz] = size(rbh);
[ix iy iz h]=getCurrentPosHandler(hs);
line = (iz-1)*(nx*ny) + (iy-1)*nx + ix;
set(h_listb3,'Value',line);
ListCellArray2=get(h_listb3,'String');
s_data = sprintf('%3d:(% 5.1f,% 5.1f,% 5.1f)',line,pos(1),pos(2),pos(3));
ListCellArray2(line,1)=cellstr(s_data);
Positions = getappdata(hs.figure1,'Positions');
Positions{line}=[pos(1) pos(2) pos(3)];

set(h_listb3,'String',ListCellArray2);
setappdata(hs.figure1,'Positions',Positions);
guidata(h_listb3,hs);

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
   listb1_handle = getappdata(hs.figure1,'listb1_handle');
   Lines = getappdata(listb1_handle,'Lines');
   if Lines > 0
      ProbePos=getappdata(hs.figure1,'ProbePos');
      current = getappdata(hs.figure1,'CurrentLine');
      %val = get(getappdata(hs.figure1,'popup1_handle'),'Value');
      val = ProbePos{current,1};

      % switch by val(Probe Type): otherwise==11
      if val==11
        %setpos_in_listbox2(hs,c_pos); %by Nakajo 100222
        setpos_in_listbox2(hs,pos);
      else
        setpos(hs,pos);
        %setpos_in_listbox3(hs,c_pos); %by Nakajo 100222
        setpos_in_listbox3(hs,pos);
        setNext_rdb(hs);
      end
      setappdata(hs.figure1,'flag_modify_data',1);
   end
%   ipc_connect(2,c_pos(1),c_pos(2),c_pos(3));
   GuiAppli = getappdata(hs.figure1,'GuiAppli');
   if(GuiAppli.open_flag==1)
      Aos=getappdata(hs.figure1,'Aos');
      s_pos = affine_trans('translate', Aos, pos);
      Aso_size=getappdata(hs.figure1,'Aso_size');
      o_pos = affine_trans('observed_size_translate', Aso_size, s_pos);
      ipc_connect(1,o_pos(1,1),o_pos(1,2),o_pos(1,3));
   end
end

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
flag_modify_data = getappdata(handles.figure1,'flag_modify_data');
if(flag_modify_data==1)
  selection = questdlg('Close Window?','Closing','Save&Close','Close','No','Save&Close');
else
  selection = questdlg('Close Window?','Closing','Close','No','Close');
end
GuiAppli = getappdata(handles.figure1,'GuiAppli');
switch selection
  case 'Save&Close'
  h_pushb_save = getappdata(handles.figure1,'pushb_save_handle');
  pushbutton_save_Callback(h_pushb_save, eventdata, handles);
  %really saved?
  flag_modify_data = getappdata(handles.figure1,'flag_modify_data');
  if(flag_modify_data==0)
    if(GuiAppli.open_flag==1)
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
    end
    try
      CloseSerialPort(hObject, handles);
      delete(get(0,'CurrentFigure'))
    catch
      delete(get(0,'CurrentFigure'))
    end
  end
  
  case 'Close'
    % Stop Measurement
    if(GuiAppli.open_flag==1)
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

%
% function redraw_Probe_Layout() : for Redraw
%
function redraw_Probe_Layout(handles, line)
delete_rb_handles(handles);
delete_listb2_handles(handles);
delete_listb3_handles(handles);
delete_pushb3_handles(handles);

popup_strings=getappdata(handles.figure1,'popup_strings');
ProbePos=getappdata(handles.figure1,'ProbePos');

if( isempty(line) || isempty(ProbePos) )
  return;
end

Positions = ProbePos{line,4};
setappdata(handles.figure1,'Positions',Positions);

val = ProbePos{line,1};
if( val==11 )
  ProbeName = ProbePos{line,2};
else
  val2 = ProbePos{line,2};
  angle=(val2-1)*pi/2;
  cos_ = cos(angle); sin_ = sin(angle);
end

h_listbox1=getappdata(handles.figure1,'listb1_handle');
Lines = getappdata(h_listbox1,'Lines');

switch val
  case {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    sizes = ProbePos{line,3};
    nx=sizes(1); ny=sizes(2); nz=sizes(3);
    switch val
      case 1
        measure_mode=1; size_x_norm=0.7; size_y_norm=0.7;
      case 2
        measure_mode=2; size_x_norm=0.7; size_y_norm=0.7;
      case 3
        measure_mode=3; size_x_norm=0.7; size_y_norm=0.7;
      case 4
        measure_mode=50; size_x_norm=0.7; size_y_norm=0.7;
      case 5
        measure_mode=51; size_x_norm=0.7; size_y_norm=0.7;
      case 6
        measure_mode=52; size_x_norm=0.7; size_y_norm=0.7;
      case 7
        measure_mode=54; size_x_norm=0.7; size_y_norm=0.7;
      case 8
        measure_mode=200; size_x_norm=0.7; size_y_norm=0.2;
      case 9
        measure_mode=201; size_x_norm=0.7; size_y_norm=0.2;
      case 10
        measure_mode=202; size_x_norm=0.7; size_y_norm=0.2;
    end
    layout_positions = time_axes_position_D3(measure_mode, [size_x_norm size_y_norm], [0.1 0.1]);
    [size_layout_positions col] = size(layout_positions);
    max_xx = max(layout_positions(1:size_layout_positions,1));
    min_xx = min(layout_positions(1:size_layout_positions,1));
    max_yy = max(layout_positions(1:size_layout_positions,2));
    min_yy = min(layout_positions(1:size_layout_positions,2));
    center_x = (max_xx-min_xx)/2.0 + min_xx;
    center_y = (max_yy-min_yy)/2.0 + min_yy;
    
    for iz=1:1:nz
      start_idx = (iz-1)*(size_layout_positions/nz)+1;
      end_idx = start_idx + (size_layout_positions/nz) -1;
      min_x = min(layout_positions(start_idx:end_idx,1));
      max_x = max(layout_positions(start_idx:end_idx,1));
      min_y = min(layout_positions(start_idx:end_idx,2));
      max_y = max(layout_positions(start_idx:end_idx,2));
      step_x = (max_x-min_x)/(nx-1);
      step_y = (max_y-min_y)/(ny-1);
      for iy=1:1:ny
        for ix=1:1:nx
          index_no = (iz-1)*ny*nx+(iy-1)*nx+ix;
          no_str=sprintf('%d',index_no);
          pos_x = min_x + step_x*(ix-1);
          pos_y = max_y - step_y*(iy-1);
          x_position = (pos_x-center_x)*cos_-(pos_y-center_y)*sin_ + 0.6;
          y_position = (pos_x-center_x)*sin_+(pos_y-center_y)*cos_ + 0.5;
          rbh(ix,iy,iz) = uicontrol(handles.figure1, 'Style', 'radiobutton',...
            'Units', 'normalized',...
            'String',no_str,...
            'Value',0,...
            'Position',[x_position y_position 0.05 0.05]);

          mod_x = mod(ix,2); mod_y = mod(iy,2);
          if(mod_y==1)
            if(mod_x==1)
              set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.75]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            else
              set(rbh(ix,iy,iz),'BackgroundColor',[0.0 1.0 1.0]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            end
          else
            if(mod_x==1)
              set(rbh(ix,iy,iz),'BackgroundColor',[0.0 1.0 1.0]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            else
              set(rbh(ix,iy,iz),'BackgroundColor',[1.0 0.5 0.75]);
              set(rbh(ix,iy,iz),'FontWeight','normal');
              set(rbh(ix,iy,iz),'FontSize',9.0);
            end
          end
        end
      end
    end
    set(rbh(1,1,1),'Value',1);
    [row_pos col_pos] = size(Positions);
    for iz=1:1:nz
      for iy=1:1:ny
        for ix=1:1:nx
          set(rbh(ix,iy,iz),'Callback',{@rdb_Callback,handles});
          index_no = (iz-1)*ny*nx+(iy-1)*nx+ix;
          col_pos_data=0; row_pos_data=0;
          if(col_pos>=index_no)
            [row_pos_data col_pos_data] = size(Positions{index_no});
          end
          if(col_pos_data>=3)
            pos = Positions{index_no};
            position_strings{index_no}=sprintf('%3d:(%5.1f,%5.1f,%5.1f)',index_no,pos(1),pos(2),pos(3));
          else
            position_strings{index_no}=sprintf('%3d:',index_no);
          end
        end
      end
    end
    setappdata(handles.figure1,'RadioButtonHandles',rbh);
    
    handles.listb3=uicontrol(handles.figure1,'Style', 'listbox',...
          'Units', 'normalized',...
          'Position', [.0 .04 .2 .7],...
          'String', position_strings,...
          'Callback', {@listbox3_Callback, handles});
    guidata(handles.figure1, handles);
    setappdata(handles.figure1,'listb3_handle',handles.listb3);
    setappdata(handles.listb3,'Lines',nx*ny*nz);
    guidata(handles.figure1, handles);
    line_in_listb3 = ProbePos{line,5};
    % include rdb select
    set(handles.listb3,'Value',line_in_listb3);
    listbox3_Callback(handles.listb3, [], handles);
    
  otherwise
    handles.listb2=uicontrol(handles.figure1,'Style', 'listbox',...
          'Units', 'normalized',...
          'Position', [.0 .04 .2 .7],...
          'String', {'(Insert TopLine)'},...
          'Callback', {@listbox2_Callback, handles});
    setappdata(handles.figure1,'listb2_handle',handles.listb2);
    setappdata(handles.listb2,'Lines',1);
    handles.pushb3=uicontrol(handles.figure1,'Style', 'pushbutton',...
          'Units', 'normalized',...
          'Position', [.25 .69 .1 .03],...
          'String', 'Remove Pos',...
          'Callback', {@pushbutton3_Callback, handles});
    setappdata(handles.figure1,'pushb3_handle',handles.pushb3);
    guidata(handles.figure1, handles);
    print_positions_in_listbox2(handles.listb2,handles,Positions);
    set(handles.listb2,'Value',ProbePos{line,5});
end
h_ProbePositions = getappdata(handles.figure1,'ProbePositions_handle');
[x_row y_col] = size(h_ProbePositions);
if( x_row==0 )
    handles.ProbePositions=uicontrol(handles.figure1,'Style', 'text',...
          'Units', 'normalized',...
          'Position', [.0 .74 .2 .03],...
          'String', 'ProbePositions',...
          'BackgroundColor',[0.8 0.8 0.8],...
          'Value', 1);
    setappdata(handles.figure1,'ProbePositions_handle',handles.ProbePositions);
end
setappdata(handles.figure1,'ProbePos',ProbePos);


function print_positions_in_listbox2(h_listb2,hs,Positions)
[row col] = size(Positions);
ListCellArray = get(h_listb2,'String');
for idx=1:1:col
  pos = Positions{idx};
  [pos_row pos_col] = size(pos);
  if(pos_col>=3)
    s_data = sprintf('(% 5.1f,% 5.1f,% 5.1f)',pos(1),pos(2),pos(3));
    ListCellArray(idx+1,1)=cellstr(s_data);
  end
end
set(h_listb2,'String',ListCellArray);
setappdata(h_listb2,'Lines',col+1);
guidata(h_listb2,hs);
