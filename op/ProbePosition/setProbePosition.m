function varargout = setProbePosition(varargin)
% SETPROBEPOSITION M-file for setProbePosition.fig
%      This function Set/Edit Probe-Position Data of Signal-Data in OSP.
%      Data saved by the function have Position-Data,
%      and there User-Command-Data, Header of Continuous Data, have the
%      field 'Pos'.
%
%      SETPROBEPOSITION, by itself, creates a new SETPROBEPOSITION or raises the existing
%      singleton*.
%
%      H = SETPROBEPOSITION returns the handle to a new SETPROBEPOSITION or the handle to
%      the existing singleton*.
%
%      SETPROBEPOSITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETPROBEPOSITION.M with the given input arguments.
%
%      SETPROBEPOSITION('Property','Value',...) creates a new SETPROBEPOSITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setProbePosition_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setProbePosition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Reversion 1.10
%   We improved this function.
%   But the functions are not available for old Data-Format
%   And rest some bugs.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: setProbePosition.m 293 2012-09-27 06:11:14Z Katura $
% Reversion 1.10
%   We improved this function.
%   But the functions are not available for old Data-Format
%   And rest some bugs.
%
% Revision 1.25
%   Empty Probe Check Add
% Revision 1.36 : Modifyed by Tsuzuki
%                 & Marge
% Revision 1.39 : Bugfix 080115A
% Revision 1.40 : Add On-Grid button
% Revision 1.41 : Add Grid Display Function
%                 set Minimum of Grid
%                 Add Preview-Button

% Last Modified by GUIDE v2.5 22-Jan-2008 13:46:29

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @setProbePosition_OpeningFcn, ...
  'gui_OutputFcn',  @setProbePosition_OutputFcn, ...
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
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == -- GUI Fundamental Functions-- ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setProbePosition_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for setProbePosition
% Checked : 15-Dec-2005

set(handles.figure1,'WindowStyle','modal');

% -- Output Argument --
handles.output = hObject;

% uicontext menu
if 0
  % <-- Meating on 24-Jan-2006 -->
  handles=make_menu(hObject,handles);
  %- fix for menu that disappeared with modal mode
  v=get(handles.psb_preview);
  p=v.Position;
  h=uicontrol('Style','pushbutton','units',v.Units,'position',[p(1)+p(3)*1.5 p(2:4)],'string','Menu');
end
if ~isfield(handles,'contextmenu') || ~ishghandle(handles.contextmenu);
  hcm = uicontextmenu;
  handles = make_menu(hcm,handles);
  set(handles.axes1,'uiContextMenu',hcm);    % axes
  set(handles.figure1,'uicontextMenu',hcm);  % figure
end

% Update handles structure
guidata(hObject, handles);

% Default Value of Application Data
set(handles.figure1,'Color',[0.895 1 0.9895]);
set(handles.ckb_replace,'BackgroundColor',[0.895 1 0.9895]);

% === set Function-Name  %%added for reading RAW-DATA, 070131
if OSP_DATA('GET','isPOTAToRunning'),
  UseFnc='DataDef2_RawData';
else
  UseFnc='DataDef_SignalPreprocessor';
end
setappdata(handles.figure1, 'UseFunction', UseFnc);
% * * Load Data * *
psb_loaddata_Callback(hObject, [], handles)
return; % OpeningFcn

function figure1_KeyPressFcn(hObject, eventdata, handles)
% Key Pres Function
%  OSP Default Key-bind.
% Checked : 15-Dec-2005
try
  osp_KeyBind(hObject, eventdata, handles,mfilename);
end
return; % KeyPressFcn

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Function:
%  Change view of OSP-Main-Controller.
% Checked : 15-Dec-2005
try
  if OSP_DATA('GET','isPOTAToRunning')~=true,
    osp_ComDeleteFcn;
  end
catch
  % In spite of Error-Event, we must Delete
  warning(lasterror);
end

return; % DeleteFcn

function varargout = setProbePosition_OutputFcn(hObject, eventdata, handles)
% Return Value is handle of GUI,
%  --> See Also setProbePosition_OpeningFcn
%      handles.output was set in OpeningFcn
% Checked : 15-Dec-2005
varargout{1} = handles.output;
% Close at onece, if File is not opened.
% Since r1.8?
try
  dt  = getappdata(handles.figure1, 'OSP_SP_DATA');
  if isempty(dt),
    delete(hObject);
    % varargout{1} = [];
  end
catch
end
return; % OutputFcn

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close with Save-Question-Dialog
% Checked : 15-Dec-2005

% Before Closing ...
try
  % Save Result?
  save_flag = getappdata(handles.figure1, 'SAVE_FLAG');
  mod_flag  = getappdata(handles.figure1, 'MODYFY_FLAG');
  if isempty(save_flag) || save_flag==false || ...
      isempty(mod_flag) || mod_flag==true,
    % If not saved or modified ->
    bname = questdlg('Do you want to save as Continuous-Data?', ...
      'Closing...', ...
      'Yes', 'No', 'Yes');
    if strcmp(bname,'Yes'),
      % And Save? => Yes : Save
      psb_save_Callback(handles.psb_save,[],handles);
    end
  end
catch
  % In spite of Error-Event, we must close.
  warning(lasterr);
end

% Close Here
delete(handles.figure1);
return; % CloseRequestFcn

function figure1_ResizeFcn(hObject, eventdata, handles)
% When you Figure-Window is resized,
%  Not change Text Size, but change Axes Size (Width).
%
%  --> now not in use.
%      Normarized Function used.
% Checked : 15-Dec-2005

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=make_menu(hObject,handles)
% Special Menu : Top
pp             = uimenu(hObject,'Label','&Probe Position');
handles.menu_pp= pp;

%=========================
% --- Add Channel Text ---
%=========================
ct             =uimenu(pp,'Label','&Text of Channel');
handles.menu_ct=ct;
handles.menu_CTContinuous=...
  uimenu(ct,'Label','Continuous', ...
  'Checked','on', ...
  'Callback', ...
  'setProbePosition(''menu_CTContinuous'',gcbo,[],guidata(gcbo))');
handles.menu_CTProbe=...
  uimenu(ct,'Label','Probe', ...
  'Callback', ...
  'setProbePosition(''menu_CTProbe'',gcbo,[],guidata(gcbo))');
setappdata(handles.figure1,'ChannnelTextMode','Continuous');

%=========================
% --- Channel Color Mode ---
%=========================
% (Rendere Change is for View(print))
cc = uimenu(pp,'Label', '&Channel Color', ...
  'Checked','on', ...
  'Callback', ...
  ['hs=guidata(gcbf);' ...
  'if strcmp(get(gcbo,''Checked''),''on''),' ...
  '   set(gcbo,''Checked'',''off'');' ...
  '   setappdata(gcbf,''ChannelColorMode'',''print'');' ...
  '   set(gcbf,''Rendere'',''zbuffer'');' ...
  'else,' ...
  '   set(gcbo,''Checked'',''on'');' ...
  '   setappdata(gcbf,''ChannelColorMode'',''default'');' ...
  '   set(gcbf,''Rendere'',''OpenGL'');' ...
  'end;' ...
  'setProbePosition(''reload_probe'',gcbo,[],hs);']);
handles.menu_cc=cc;

if 0,
  % -0- if you want to add mode.. ---
  handles.menu_CC_D= ...
    uimenu(cc,'Label','Colored', ...
    'Callback', ...
    ['setappdata(gcbf,''ChannelColorMode'',''default'');' ...
    'hs=guidata(gcbf);' ...
    'set(hs.menu_CC_P,''Checked'',''off'');' ...
    'set(gcbo,''Checked'',''on'');' ...
    'setProbePosition(''reload_probe'',gcbo,[],hs);']);
  handles.menu_CC_P= ...
    uimenu(cc,'Label','Monotone', ...
    'Callback', ...
    ['setappdata(gcbf,''ChannelColorMode'',''default'');' ...
    'hs=guidata(gcbf);' ...
    'set(hs.menu_CC_D,''Checked'',''off'');' ...
    'set(gcbo,''Checked'',''on'');' ...
    'setProbePosition(''reload_probe'',gcbo,[],hs);']);
end

%=========================
% --- 2D to 3D --
%=========================
if 0,
  handles.menu_2to3=...
    uimenu(pp,'Label','2D to 3D', ...
    'Callback', ...
    'setProbePosition(''menu_2to3_Callback'', gcbo, [], guidata(gcbo));');
end

%=========================
% -- Mask Setting --
%=========================
msk = uimenu(pp,'Label','Mask Setting');
handles.menu_MSK=msk;
handles.menu_MSK_OFF=uimenu(msk,'Label','Mask off', ...
  'Callback', ...
  'setProbePosition(''menu_MSK_Callback'', gcbo, true, guidata(gcbo));');
handles.menu_MSK_ON=uimenu(msk,'Label','Mask on', ...
  'Callback', ...
  'setProbePosition(''menu_MSK_Callback'', gcbo, false, guidata(gcbo));');

%=========================
% -- Grid --
%=========================
handles.menu_2D_Grid=uimenu(pp,'Label','&Grid',...
  'UserData',5,...
  'Callback',...
  'setProbePosition(''menu_2D_Grid_Callback'', gcbo, [], guidata(gcbo));');


%=================
% Channel Mode
%=================
function ChannelTextSelect(hObject,handles)
hs = [handles.menu_CTProbe, ...
  handles.menu_CTContinuous];
set(hs,     'Checked','off');
set(hObject,'Checked','on');
reload_probe(handles);
function menu_CTContinuous(hObject,ev,handles)
setappdata(handles.figure1,'ChannnelTextMode','Continuous');
ChannelTextSelect(hObject,handles)
function menu_CTProbe(hObject,ev,handles)
setappdata(handles.figure1,'ChannnelTextMode','Probe');
ChannelTextSelect(hObject,handles)

function menu_2D_Grid_Callback(h,ev,hs)
% Grid Menu
if 0,disp(ev);end

% Check Mode
mod=get(hs.pop_mode,'String');
if ~strcmpi(mod,'2D')
  errordlg({' Grind is act on 2D mode'},' Grid Setting Error');
  return;
end

gunit0=get(h,'UserData');
% Default Value of Grid
if isempty(gunit0),gunit0=1;end
gunitstr={num2str(gunit0)};
while 1
  gunitstr=inputdlg({'Grind-Size:'},'2D-Grind Size',1,gunitstr);
  if isempty(gunitstr),gunit=gunit0;break;end
  try
    gunit=str2double(gunitstr{1});
  catch
    gunit=[];
  end
  
  if length(gunit)~=1
    waitfor(errordlg({'Inproper value for Grid'},'Grid Seting Error'));
  else
    % OK
    break;
  end
end
mg=1;
if gunit<mg
  waitfor(warndlg(['Minimum of Grid-Size is ' num2str(mg) '!']));
  gunit=mg;
end
set(h,'UserData',gunit);
set(0,'CurrentFigure',hs.figure1);
set(hs.figure1,'CurrentAxes',hs.axes1);
a=axis;
set(hs.axes1,'XTick',a(1):gunit:a(2))
set(hs.axes1,'YTick',a(3):gunit:a(4))

%======================
% Conversion 2D <-> 3D
%======================
%function menu_2to3_Callback(hObject,eventdata,handles)

%======================
% Mask Conversion
%======================
function menu_MSK_Callback(hObject,setdata,handles)
msk=get(handles.lbx_Channel_Data,'UserData');
msk(:)=setdata;
set(handles.lbx_Channel_Data,'UserData',msk);
reload_probe(handles);
reload_chdata(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- Window Button Control --
%    Position Change by GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% Call when Button Down on this Figure.
% Checked : 15-Dec-2005

%set(handles.figure1, 'DoubleBuffer', 'on');


% Not effective now..
% Only check --> comment out
% following code is for:
%   setting data for WindowButtomMotion.

%  setappdata(handles.figure1, 'DOWN_GCBO', gcbo);
%
%  mode = getappdata(handles.figure1,'BUTTON_MODE');
%  if isempty(mode), return; end;
%
%  switch mode,
%   case 'none',
%    return;
%   case '2D_Probe',
%   otherwise,
%    msg = sprintf(['=== OSP Error!! ===\n', ...
%		   '<<Not Defined Button Mode\n', ...
%		   '      %s>>\n'],mode);
%    errordlg(msg);return;
%  end
%
%  CurrentAxes = get(handles.figure1, 'CurrentAxes');
%  if ~isempty(CurrentAxes),
%    ax_p = get(CurrentAxes,'position');
%    ax_p_from_mous = get(handles.figure1,'CurrentPoint') - ax_p(1:2);
%    setappdata(handles.figure1, 'AXIS_POINT_FROM_MOUS',ax_p_from_mous);
%  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ButtonDownAt2DProbe(hObject,eventdata,handles,id),
% When 2D Probe Down
%  = This is ButtonDown Function of 2D Probe.
%  This setting is in internal function reload_probe.
%
% Set Application Data
%    * BUTTON_MODE   : 2D_Probe : for Window Motion
%    * MouseProbeVec : Vector Mouse -> ProbePosition
%                      is to calculate new position.
%
% Checked : 16-Dec-2005
% disp(['Probe ' num2str(id) ' selected!']);
%
% Modyfy  : 19-Dec-2005
%  Add Selecting Channel
%  Change Selected Probe

%st=get(handles.lbx_datalist, 'String');
stlg=get(handles.lbx_datalist, 'UserData');
%if id<=length(st) && id>0,
if id<=stlg && id>0,
  set(handles.lbx_datalist, 'Value',id);
  lbx_datalist_Callback(handles.lbx_datalist,[],handles);
else
  % Error Case
  msg = sprintf(['=== [Platform] Error!! ===\n', ...
    '<<Not Proper Probe Selected\n', ...
    '  Probe ID : %d>>\n'],id);
  errordlg(msg);return;
end

% Get default value.
pos = getappdata(handles.figure1,'Pos');
idx = pos.Group.ChData{id};
ax_cp = get(handles.axes1, 'CurrentPoint');

% for Channel Selection
% 19-Dec-2005
chpos = pos.D2.P(idx,:);
% Center is ax_cp
chpos = chpos - repmat(ax_cp(1,1:2),size(chpos,1),1);
r = chpos(:,1).^2 + chpos(:,2).^2;
[rmax, idx2]=min(r);
idx2 = idx(idx2);
set(handles.lbx_Channel_Data,'Value',idx2);

MouseProbeVec = ax_cp(1,1:2) -pos.D2.P(idx2,:);
% MoseProbeVec : The Vector is invariance
%                until Button Up!
setappdata(handles.figure1,'MouseProbeVec',MouseProbeVec);
% Mode : 2D-Probe is selected!
setappdata(handles.figure1, 'BUTTON_MODE', '2D_Probe');

try
  prb_act = getappdata(handles.figure1, 'PROBE_2DHANDLES_act');
  col=[0 0 0];
  msk=get(handles.lbx_Channel_Data,'UserData');
  if msk(idx2), col=[1 0 0]; end

  set(prb_act,...
    'Xdata',pos.D2.P(idx2,1), ...
    'Ydata',pos.D2.P(idx2,2), ...
    'MarkerEdgeColor',col);
end

% To speed up
%   Meeting on 02-Mar-2003
hnd2 = getappdata(handles.figure1, 'PROBE_2DHANDLES_TXT');
delete(hnd2);setappdata(handles.figure1, 'PROBE_2DHANDLES_TXT',[]);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ButtonDownAt3DChannel(hObject,eventdata,handles,id)
% When 3D Channel Down
%  = This is ButtonDown Function of 3D Channel.
%  This setting is in internal function reload_probe.
%
% Set Application Data
%    * BUTTON_MODE     : 3D_Channel : for Window Motion
%    * MouseChannelVec : Vector Mouse -> Channel
%                      is to calculate new position.
%
% Change Current Channel
%    * 'Value' of Channel-Data Listbox
%      (lbx_Channel_Data)
%
% Checked : 16-Dec-2005

% Modify : r1.10
% Read 3D-Postion Data from 'Pos'
pos = getappdata(handles.figure1, 'Pos');
ch_pos3 = pos.D3.P;
% Get Masking Channel
msk = get(handles.lbx_Channel_Data, 'UserData');

if id<=size(ch_pos3,1) && id>0,
  set(handles.lbx_Channel_Data, 'Value',id);
else
  % Error Case
  % Read Bound Array
  % ::: No Correspond Channel Data :::
  msg = sprintf(['=== [Platform] Error!! ===\n', ...
    '<<Not Proper Probe Selected\n', ...
    '  Probe ID : %d>>\n'],id);
  errordlg(msg);return;
end

% Set Vector : Mouse -> Channel Position
ax_cp = get(handles.axes1, 'CurrentPoint');
MouseChannelVec = ax_cp(1,1:3) -ch_pos3(id,:);
setappdata(handles.figure1,'MouseChannelVec',MouseChannelVec);
setappdata(handles.figure1, 'BUTTON_MODE', '3D_Channel');
return;

function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% Executes on mouse motion over figure - except title and menu.
% Move Object alog Mouse.
%
% Application-Date:
%   BUTTOM_MODE : 2D_Probe   : 2D Probe was Selected.
%                 3D_CHANNLE : 3D Channel was Selected.
%
% Checked : 15-Dec-2005
% Modify  : 16-Dec-2005 : Add Text of Channel 1
% Checked : 16-Dec-2005
% Modify  : 19-Dec-2005
% Get Selecting Mode.
mode = getappdata(handles.figure1,'BUTTON_MODE');
% No Mode Exist : Do nothing.
if isempty(mode),
  setappdata(handles.figure1, 'BUTTON_MODE', 'none');
  return;
end

try
  switch mode,
    case 'none',
      % No Mode Exist : Do nothing.
      return;
    case '2D_Probe',
      % === Get Essential Data ===
      id   =get(handles.lbx_datalist, 'Value');  % Selected Probe!
      chidx=get(handles.lbx_Channel_Data,'Value'); % Channel Index
      pos = getappdata(handles.figure1, 'Pos'); % Now Position
      idx = pos.Group.ChData{id};               % Index of Selected Channel
      % Channel Change Mode::
      % 19-Dec-2005 Add
      mode2 = get(handles.pop_2d_BUTTOM_MODE2,'Value');
      % ==== Position chaneg ====
      ax_cp         = get(handles.axes1, 'CurrentPoint'); % Current Point
      % 06-Feb-2006 : Bug :: From MATLAB ver 7.1 to ---
      %    ax_cp : is in axes
      a=axis;
      if (ax_cp(1,1)<a(1)),ax_cp(:,1)=a(1); end
      if (ax_cp(1,1)>a(2)),ax_cp(:,1)=a(2); end
      if (ax_cp(1,2)<a(3)),ax_cp(:,2)=a(3); end
      if (ax_cp(1,2)>a(4)),ax_cp(:,2)=a(4); end


      MouseProbeVec = getappdata(handles.figure1,'MouseProbeVec'); % Vector
      pos2          = ax_cp(1,1:2) - MouseProbeVec; % Vector : Moved
      posdiff       = pos.D2.P(chidx,:) - pos2;    % Vector : Difference
      gunit=get(handles.menu_2D_Grid,'UserData');
      % Change 2-Dimension Position.
      switch mode2,
        case 1,
          orgn = pos.D2.P(chidx,:);
          mved = round( (orgn - posdiff)/gunit)*gunit;
          posdiff2 = orgn-mved;
          
          pos.D2.P(idx,:) = pos.D2.P(idx,:) - repmat(posdiff2,[size(idx,2),1]);
        case 2,
          tmp = pos.D2.P(chidx,:) - posdiff;
          pos.D2.P(chidx,:) = round(tmp/gunit)*gunit;
          if 0
            fprintf('Move (%f,%f) --> (%f,%f) : gunit: %f\n',...
              tmp(1,1),tmp(1,2),...
              pos.D2.P(chidx(1),1),pos.D2.P(chidx(1),2),...
              gunit);
          end          
        otherwise,
          setappdata(handles.figure1,'BUTTON_MODE','none');
          errordlg('Undefined 2D Buttom Mode');
          return;
      end
      % Update "Position Data"
      setappdata(handles.figure1, 'Pos',pos);

      % ==== PlotChange ====
      hnd  = getappdata(handles.figure1, 'PROBE_2DHANDLES');
      hnd2 = getappdata(handles.figure1, 'PROBE_2DHANDLES_TXT');
      hnda = getappdata(handles.figure1, 'PROBE_2DHANDLES_act');
      hndm = getappdata(handles.figure1, 'PROBE_2DHANDLES_msk');

      hnd =hnd(id); hndm=hndm(id);
      set(hnda,...
        'Xdata',pos.D2.P(chidx,1), ...
        'Ydata',pos.D2.P(chidx,2));
      % Get Data
      % xdata=get(hnd,'XData'); ydata=get(hnd,'YData');
      msk = get(handles.lbx_Channel_Data, 'UserData');
      msked = find(msk(idx)==false);
      idx2 = idx(msked);
      idx(msked) = [];

      % Update Probe Position
      if ~isempty(idx),
        set(hnd,'XData',pos.D2.P(idx,1),'YData', pos.D2.P(idx,2));
      end
      if ~isempty(idx2),
        set(hndm,'XData',pos.D2.P(idx2,1),'YData', pos.D2.P(idx2,2));
      end
      % Change (Effective) Channel 1 Txe Position
      if 0,
        % Comment out -> to speed up
        %   Meeting on 02-Mar-2003
        try
          idx = pos.Group.ChData{id};
          set(hnd2(idx), ...
            {'Position'}, ...
            mat2cell([pos.D2.P(idx,:) zeros(length(idx),1)],ones(1,length(idx)),3));
        end
      end

      % Modify : Flag
      %   Change in Button-Up
      setappdata(handles.figure1, 'MODYFY_FLAG',true);
      % <-- Meating on 24-Jan-2006 -->
      % too late
      % disp2D_xy(handles); % display probe XY :

    case '3D_Channel',
      % === Get Essential Data ===
      id = get(handles.lbx_Channel_Data, 'Value'); % Index of Channel
      pos = getappdata(handles.figure1, 'Pos');    % Position Data
      ch_pos3 = pos.D3.P;  % 3D Position

      % ==== Position chaneg ====
      ax_cp = get(handles.axes1, 'CurrentPoint');
      MouseChannelVec = getappdata(handles.figure1,'MouseChannelVec');
      pos3 = ax_cp(1,1:3) -MouseChannelVec;
      posdiff = ch_pos3(id,:) - pos3; % Difference Between ..
      %disp(pos3);

      % ==== PlotChange ====
      prb = getappdata(handles.figure1, 'CHANNEL_3DHANDLES');
      % getdata
      xdata=get(prb(id), 'XDATA');
      ydata=get(prb(id), 'YDATA');
      zdata=get(prb(id), 'ZDATA');
      xdata = xdata - posdiff(1);
      ydata = ydata - posdiff(2);
      zdata = zdata - posdiff(3);
      % Update Channel Position
      set(prb(id),'XData',xdata,'YData', ydata,'ZData',zdata);
      ch_pos3(id,:)=pos3;
      pos.D3.P = ch_pos3;
      setappdata(handles.figure1, 'Pos',pos);

    otherwise,
      msg = sprintf(['=== [Platform] Error!! ===\n', ...
        '<<Not Defined Button Mode\n', ...
        '      %s>>\n'],mode);
      setappdata(handles.figure1, 'BUTTON_MODE', 'none');
      errordlg(msg);return;
  end
catch
  msg = {'[Platform] Set Probe Position : In Motion'};
  msg{end+1}=['  ' C__FILE__LINE__CHAR];
  msg{end+1}=lasterr;
  errordlg(msg);
  setappdata(handles.figure1, 'BUTTON_MODE', 'none');
end
return;

function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% Call when Button Up on this Figure.
%
% Application-Date:
%   BUTTOM_MODE : 2D_Probe   : 2D Probe was Selected.
%                 3D_CHANNLE : 3D Channel was Selected.
%
% Modify  : 17-Dec-2005 : Simplify
%                         by useing Button Motion Function.
% Checked : 17-Dec-2005

set(handles.figure1, 'DoubleBuffer', 'off');
mode = getappdata(handles.figure1,'BUTTON_MODE');
if (isempty(mode) || strcmp(mode,'none')), return; end;

try
  % Change Position :: Last ::
  figure1_WindowButtonMotionFcn(hObject, [], handles);
  if strcmp(mode,'2D_Probe'),
    % To speed up (text was deleted in Down function)
    % So replot
    %   Meeting on 02-Mar-2003
    reload_probe(handles);
    disp2D_xy(handles); % display probe XY :
  end
  % Change Button Mode : none
  setappdata(handles.figure1, 'BUTTON_MODE', 'none');
catch
  rethrow(lasterror);
end
% Channel Data List Change::
reload_chdata(handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- Create Functions --
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axes1_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% Confine : Axes have no object
%
% We need CLA function ::
%    -->  *.fig file might save some object automatically.
%         I think that
%              'loading' is quicker than 'ploting with loading',
%               so MATLAB Change automatically...
%
%         (My Environment is MATLAB R13, Unix version)
%
% Checked : 15-Dec-2005

% cla;
return;



% --------------------------------------------------------------------
function cMenu_ProbeData_Callback(hObject, eventdata, handles)
% When Right-Click (Right-Button Down! on )
%   on Data-List-Box (Probe List Box).
%
% Do nothing.
%
% Checked : 19-Dec-2005
%           Comment Out!
%
% 22-Aug-2005:
%    Change ProbeMode, Probe Position, Probe Size.
%    --> This function Moved GUI Edit-Text.
%
% 05-Dec-2005
%    This Functions removed.
%
% 19-Dec-2005
%    Comment Out and Add messages.
%    !! This Area will be removed soon. !!

% Do nothing : 22-Aug-2005
return;

%   dt  = getappdata(handles.figure1, 'OSP_SP_DATA');
%   pm  = getappdata(handles.figure1, 'PROBE_MODE');
%   pos = getappdata(handles.figure1, 'PROBE_2DPOS');
%   siz = getappdata(handles.figure1, 'PROBE_2DSIZE');
%
%   st  = get(handles.lbx_datalist, 'String');
%   ud  = get(handles.lbx_datalist, 'UserData');
%   vl  = get(handles.lbx_datalist, 'Value');
%
%   % Get Data Name
%   dname = ud{vl};
%
%   prompt={'Mode', 'Position(x)', 'Position(y)','Size(x)', 'Size(y)'};
%   def   ={num2str(pm(vl)), num2str(pos(vl,1)),  num2str(pos(vl,2)), ...
% 		  num2str(siz(vl,1)),  num2str(siz(vl,2))};
%    while 1,
% 	   def = inputdlg(prompt, ['Probe (' num2str(vl) ') : ' dname ], 1, def);
% 	   try,
% 		   if isempty(def), return; end
% 		   pm(vl)    = str2num(def{1});
% 		   pos(vl,1) = str2num(def{2});
% 		   pos(vl,2) = str2num(def{3});
% 		   siz(vl,1) = str2num(def{4});
% 		   siz(vl,2) = str2num(def{5});
% 		   break;
% 	   catch,
% 		   errordlg(lasterr);
% 	   end
%    end
%
%    % Change String Data
%    dstr = sprintf('%s: %d', ...
% 		  dname, pm(vl));
%   st{vl} = dstr;
%
%   % Update Data
%   set(handles.lbx_datalist, ...
% 	  'Value',     vl, ...
% 	  'UserData',  ud, ...
% 	  'String'  ,  st);
%   setappdata(handles.figure1, 'OSP_SP_DATA',dt);
%   setappdata(handles.figure1, 'PROBE_MODE',pm);
%   setappdata(handles.figure1, 'PROBE_2DPOS',pos);
%   setappdata(handles.figure1, 'PROBE_2DSIZE',siz);
%
%   % Change View (Reload)
%   psb_replot_Callback(handles.psb_replot, [], handles);

function lbx_datalist_Callback(hObject, eventdata, handles,initflag)
% Executes on selection change in lbx_datalist.
%   Data-List is List of Probe.
%   This Callback describe procedure
%          "Change Selecting Probe".
%
%   since 1.10 : Do nothing...
%   since 1.11 : Change Slide Size
% Checked : 17-Dec-2005
% Changed : 19-Dec-2005

% When you want to change the function,
% following variable might be useful.
% Thanks.
%
% -- Get Probe-ID --
%
% -- Position Data --
% Get default value.
% pos = getappdata(handles.figure1, 'Pos');

if nargin<4,initflag=false;end
% Current Probe Id
prbid = get(handles.lbx_datalist, 'Value');
%=======================================
% is Enable Probe?
% -- Bugfix : 2006.10.23 --
%=======================================
persistent myprbid
pos = getappdata(handles.figure1,'Pos');
% Check exist Data
ecode=false;
% Probe Exist
if isempty(pos),
  ecode=true;
  msg=' Listbox Error : Open Files at fast!';
end
if ~ecode && isempty(pos.Group.ChData{prbid}),
  ecode=true;
  msg=' No Channel In This Probe!';
end
if ecode,
  if isempty(myprbid),myprbid=1;end
  set(hObject,'Value',myprbid);
  % B061206D : to Help Dlg
  % when loading, not show help dlg
  if ~initflag,helpdlg(msg);end
  return;
end

%=======================================
% <-- Meeting on 19-Dec-2005 : start -->
%=======================================
% Probe-Size
psize = get(handles.sld_2dsize,'UserData');
set(handles.sld_2dsize,'Value',psize(prbid));
sld_2dsize_Callback(handles.sld_2dsize,[],handles);

% Probe Color
if 0
  hnd  = getappdata(handles.figure1, 'PROBE_2DHANDLES');
  if ~isempty(hnd),
    set(hnd,'MarkerFaceColor','white');
    set(hnd(prbid),'MarkerFaceColor',[1 .8 0]);
  end
end
% <-- Meeting on 19-Dec-2005 : end -->

% <-- Meating on 24-Jan-2006 -->
disp2D_xy(handles); % display probe XY :
myprbid=prbid;

function lbx_Channel_Data_Callback(hObject, eventdata, handles)
% Executes on selection in lbx_Channel_Data.
% Change Maske Data :
%   where Mask is Enable-Channel
%              or Disable-Channel
%
% Checked : 15-Dec-2005
vl  =  get(handles.lbx_Channel_Data, 'Value');
msk = get(handles.lbx_Channel_Data, 'UserData');
if msk(vl),
  msk(vl)=false;
else
  msk(vl)=true;
end
set(handles.lbx_Channel_Data, 'UserData',msk);
setappdata(handles.figure1, 'MODYFY_FLAG',true);

str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');

reload_chdata(handles);
if strcmp(str{val},'3D'),
  % Visible Off for Masked Channel
  prb = getappdata(handles.figure1, 'CHANNEL_3DHANDLES');
  if msk(vl),
    set(prb(vl),'Visible','on');
  else
    set(prb(vl),'Visible','off');
  end
else
  % This code is a little late.
  % --> it is better for ous to use Visible on/off.
  %     but it's make ous confuse when we edit Plot-data.
  %     20-Dec-2005
  reload_probe(handles);
end
return;

function disp2D_xy(handles)
% Display 2D XY.
%
% <-- Meating on 24-Jan-2006 -->
% T.K, M.S

% Mode Check:
% Execute when 2DMode
str=get(handles.pop_mode,'String');
vl =get(handles.pop_mode,'Value');
if ~strcmp(str{vl},'2D'),
  return; % Do nothing
end

% Get Current Probe
prbid = get(handles.lbx_datalist, 'Value');
% Position Data
pos = getappdata(handles.figure1,'Pos');
% Check exist Data
if isempty(pos),
  msg=' * Open Files at fast!';
  errordlg(msg); return;
end

% Index of Channel in the Probe 'vl'
ch = pos.Group.ChData{prbid};
% 2D Position of Channel (
d2 = pos.D2.P(ch(1),:);

x  = round(d2(1,1)*100)/100;
y  = round(d2(1,2)*100)/100;
set(handles.edt_2Dx,'String',num2str(x));
set(handles.edt_2Dy,'String',num2str(y));


function edt_2Dx_Callback(hObject, eventdata, handles)
move2Dpos(hObject,handles,1);
function edt_2Dy_Callback(hObject, eventdata, handles)
move2Dpos(hObject,handles,2);
function move2Dpos(hObject,handles,idx)
% Move 2Dposition
XX = get(hObject,'String');
try
  XX= str2double(XX);
catch
  errordlg(laster);
  return;
end

% Position Data
pos = getappdata(handles.figure1,'Pos');
% Check exist Data
if isempty(pos),
  msg=' * Open Files at fast!';
  errordlg(msg); return;
end

vl  = get(handles.lbx_datalist, 'Value');
% Index of Channel in the Probe 'vl'
ch = pos.Group.ChData{vl};
% 2D Position of Channel
d2 = pos.D2.P(ch,:);

% get Difference
dXX = d2(1,idx) - XX(1);
pos.D2.P(ch,idx)= d2(:,idx) - dXX;
setappdata(handles.figure1,'Pos',pos);

% Change View
reload_chdata(handles);
reload_probe(handles);


function pop_mode_Callback(hObject, eventdata, handles)
% Executes on selection change in pop_mode.
%   Changet '2D Mode'/'3D Mode'  in the Popupmenu.
%      : When Change Dimenstion Mode/
%         1. Change Enable Buttons (View ON/OFF)
%         2. Change View
%
% Checked : 17-Dec-2005
str = get(hObject,'String');
val = get(hObject,'Value');

% -- Enable/Disable Uicontrol --
hand_base = [handles.txt_Nasion, handles.edt_Nasion, ...
  handles.txt_LeftEar, handles.edt_LeftEar, ...
  handles.txt_RightEar, handles.edt_RightEar];
% Meeting on 24-Jan-2006
hand_2d  =[handles.txt_2dsize, handles.sld_2dsize, ...
  handles.txt_2Dsize, ...
  handles.psb_2d_size_1, handles.edt_2Dsize, ...
  handles.rot_invx, handles.psb_rotinvy, ...
  handles.psb_rot90, handles.psb_rot180, ...
  handles.psb_rotinv90, ...
  handles.edt_2Dx,handles.edt_2Dy, ...
  handles.txt_2Dx,handles.txt_2Dy];
%handles.psb_rotinv180, ...
%handles.pop_rotation,handles.psb_rotate, ...

%  handles.edt_2Dsize,handles.psb_2d_resize];

% Probe Buttom mode
if 1,
  hand_2d(end+1) = handles.pop_2d_BUTTOM_MODE2;
end


switch str{val},
  case '2D',
    % -- Rotation  'On'/'Off' Add since r1.10 ---
    set(hand_2d,'Visible', 'on');
    set(hand_base,'Visible','off');
  case '3D',
    % -- Rotation  'On'/'Off' Add since r1.10 ---
    set(hand_2d,'Visible', 'off');
    set(hand_base,'Visible','on');
end

% Reload : Chaneg Viwe
psb_replot_Callback(handles.psb_replot, [], handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_replot_Callback(hObject, eventdata, handles)
% Reload Data
%   Reload Axes, Probe, Channel Data.
% Check 20-Dec-2005

% mri-shape plot
reload_axes1(handles);

% Probe
reload_probe(handles);

% Data Change
reload_chdata(handles);

% 2D..? B061206B
str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');
if strcmp(str{val},'2D'),
  set(handles.figure1,'CurrentAxes',handles.axes1);
  view(2);
end

function reload_axes1(handles)
% Axes 1 Reload function.
% Check 20-Dec-2005
str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');

% get default size.
basic=getBasic(handles);

% select Current Axes
% and clean
set(handles.figure1,'CurrentAxes',handles.axes1);cla;

% MRI Load
load mri;   % matlab sample data of mri
D=squeeze(D);

% Modify Colormap
% Even thoug, we donot use special map now..
% (20-Dec-2005)
% This code is not inportant..
map(:,1)=1-map(:,2);
map(:,2)=1-map(:,2);
map(:,3)=1;

% Basic Figure in the axis.
% Now we do not change by Basic Information...
% TODO : if change occure in mri
%        Origin of the Axes and Image(Head) Position
% 20-Dec-2005
x0=[1:size(D,1)]-size(D,1)/2; % origin set
y0=[size(D,2):-1:1]-85;          % origin set
z0=[1:size(D,3)]-4;           % origin set
% Rate Set
% Todo : by NASION, EAR.
x0 = x0*160/length(x0);
y0 = y0*160/length(x0);
z0 = z0*160/length(x0);

switch str{val},
  case '2D',
    %set(handles.figure1,'Render', 'zbuffer');
    %set(handles.figure1,'Render', 'painters');
    %set(handles.figure1,'Render', 'OpenGL');
    if 0,
      view(2);
      return;
    end
    set(handles.figure1,'CurrentAxes',handles.axes1);
    % image(x0',y0',D(:,:,4));
    %image(x0',y0',ones(size(D(:,:,4),1), size(D(:,:,4),2)));
    axis on;grid on;
    view(2);
    set(handles.axes1,'YDir','normal')
    %axis tight
    %a=axis;
    %axis(a);
    axis equal;
    axis([-100 100 -100 100]);
    gunit=get(handles.menu_2D_Grid,'UserData');
    set(handles.axes1,'XTick',-100:gunit:100)
    set(handles.axes1,'YTick',-100:gunit:100)
    
  case '3D',
    % set surface
    % Use Open GL : for fast drawing..
    % set(handles.figure1,'Render', 'OpenGL');
    set(handles.figure1,'CurrentAxes',handles.axes1);
    Ds = smooth3(D);
    patch(isosurface(x0,y0,z0,Ds,5), ...
      'FaceColor', [1, .75, .65], ...
      'EdgeColor', 'none');
    alpha(0.7);
    view(3);
end

% Colormap Setting
mapsz(1)=size(map,1);
mapsz(2)=20;
setappdata(handles.figure1,'MAP_SZ2',mapsz);
map   = [map; [1, 1, 1]; hot(mapsz(2))];
colormap(map);
% ploat
% axis image

function reload_probe(varargin)
% select Current Axes
% and clean
if nargin==1,
  handles=varargin{1};
else,
  handles=varargin{3};
end
axes(handles.axes1);
hold on;

str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');
pos = getappdata(handles.figure1, 'Pos');

switch str{val},
  case '2D',
    % Default Axis
    prb     = getappdata(handles.figure1, 'PROBE_2DHANDLES');
    prb2    = getappdata(handles.figure1, 'PROBE_2DHANDLES_TXT');
    prb_act = getappdata(handles.figure1, 'PROBE_2DHANDLES_act');
    prb_msk = getappdata(handles.figure1, 'PROBE_2DHANDLES_msk');

    if ~isempty(prb) && any(ishandle(prb)),
      try, delete(prb); end
    end
    if ~isempty(prb2) && any(ishandle(prb2)),
      try, delete(prb2);end
    end
    if ~isempty(prb_act) && any(ishandle(prb_act)),
      try, delete(prb_act);end
    end
    if ~isempty(prb_msk) && any(ishandle(prb_msk)),
      try, delete(prb_msk);end
    end
    prb=[];prb2=[];prb_act=[];prb_msk=[];
    mapsz = getappdata(handles.figure1,'MAP_SZ2');
    msk   = get(handles.lbx_Channel_Data, 'UserData');

    %---------------
    % Channel Color
    %---------------
    % Default Color set
    fcl_actprb  = [1 .8 0]; % Face Color of Active Probe
    ecl_actprb  = [1 .8 0]; % Edge Color of Active Probe
    fcl_prb     = [1 1 1];
    ecl_prb     = [0 0 0];
    fcl_actch   = [1.0 0.2 0.2];
    ecl_actch   = [1.0 0.2 0.2];
    fcl_msk     = 'none';
    ecl_msk     = [0 0 0];
    % Modify by Color-mode
    cm = getappdata(handles.figure1, 'ChannelColorMode');
    if isempty(cm),
      cm='normal';
      setappdata(handles.figure1, 'ChannelColorMode',cm);
    end
    % if there is more mode, change following code
    % switch
    if strcmp(cm,'print'),
      fcl_actprb  = fcl_prb;
      ecl_actprb  = ecl_prb;
      fcl_actch   = fcl_prb;
      ecl_actch   = ecl_prb;
    end

    % Current Probe Index
    cpidx = get(handles.lbx_datalist, 'Value');
    for idx=1:length(pos.Group.ChData),
      % MaekerFaceColor
      %  When you want to change color,
      %  Change Also : lbx_datalist_Callback
      % Plot position.
      if (idx==cpidx),
        % Active Probe Color
        cl =fcl_actprb;
        cl2=ecl_actprb;
      else,
        % Normal Color
        cl =fcl_prb;
        cl2=ecl_prb;
      end
      ch = pos.Group.ChData{idx};
      msked   = find(msk(ch)==false);
      ch2 = ch(msked);
      ch(msked) = [];
      % Plot
      try
        if isempty(ch),
          % dumy
          prb(idx)=plot(pos.D2.P(1,1), pos.D2.P(1,2));
          set(prb(idx),'Visible','off');
        else
          prb(idx)  = plot(pos.D2.P(ch,1), pos.D2.P(ch,2));
          set(prb(idx),...
            'LineStyle','none', ...
            'MarkerSize',13, ...
            'Marker','o', ...
            'MarkerEdgeColor',cl2, ...
            'MarkerFaceColor',cl);
        end
        if isempty(ch2),
          % dumy
          prb_msk(idx)=plot(pos.D2.P(1,1), pos.D2.P(1,2));
          set(prb_msk(idx),'Visible','off');
        else
          prb_msk(idx)  = plot(pos.D2.P(ch2,1), pos.D2.P(ch2,2));
          set(prb_msk(idx),...
            'LineStyle','none', ...
            'MarkerSize',13, ...
            'Marker','o', ...
            'MarkerEdgeColor',ecl_msk, ...
            'MarkerFaceColor',fcl_msk);
        end
      catch
        error(['Cannot Prot Data : ', lasterr]);
      end
      set(prb(idx),...
        'ButtonDownFcn',...
        ['setProbePosition(' ...
        '''ButtonDownAt2DProbe'',gcbo,[],guidata(gcbo)', ...
        ', ' num2str(idx) ' )']);
      set(prb_msk(idx),...
        'ButtonDownFcn',...
        ['setProbePosition(' ...
        '''ButtonDownAt2DProbe'',gcbo,[],guidata(gcbo)', ...
        ', ' num2str(idx) ' )']);
    end % Probe Loop
    % add more plot
    achid = get(handles.lbx_Channel_Data, 'Value');
    prb_act=plot(pos.D2.P(achid,1),pos.D2.P(achid,2));
    cl = ecl_msk;
    if msk(achid)==true,
      cl= ecl_actch;
    end
    set(prb_act,...
      'LineStyle','none', ...
      'MarkerSize',13, ...
      'Marker','o', ...
      'MarkerEdgeColor',cl, ...
      'MarkerFaceColor',fcl_actch);
    set(prb_act, ...
      'ButtonDownFcn',...
      ['setProbePosition(' ...
      '''ButtonDownAt2DProbe'',gcbo,[],guidata(gcbo)', ...
      ', ' num2str(cpidx) ' )']);


    % Set Channel Text Strings
    % <-- Meating on 24-Jan-2006 -->
    ctmod= getappdata(handles.figure1, 'ChannnelTextMode');
    switch ctmod,
      case 'Probe',
        for idx=1:length(pos.Group.ChData),
          pstr=['_{P' num2str(idx) '}'];
          ch  = pos.Group.ChData{idx};
          och = pos.Group.OriginalCh{idx}; %Original Channel
          for idx2=1:length(ch),
            str =[num2str(och(idx2)) pstr];
            prb2(ch(idx2)) = text(pos.D2.P(ch(idx2),1),...
              pos.D2.P(ch(idx2),2), ...
              str);
            %['Ch ' num2str(idx2)]);
            set(prb2(ch(idx2)), ...
              'HorizontalAlignment','center',...
              'VerticalAlignment','middle', ...
              'Fontsize',8,...
              'Interpreter','tex');
          end % Channel
        end %Probe
        %case 'Continuous',
      otherwise,
        for idx2=1:size(pos.D2.P,1)
          prb2(idx2) = text(pos.D2.P(idx2,1),pos.D2.P(idx2,2), ...
            num2str(idx2));
          set(prb2(idx2), ...
            'HorizontalAlignment','center',...
            'VerticalAlignment','middle', ...
            'Fontsize',8);
        end
    end % Switch Channel Text String

    % Set Channel Text Callback
    if exist('prb2','var'),
      for idx=1:length(pos.Group.ChData),
        % Plot position.
        ch = pos.Group.ChData{idx};
        set(prb2(ch),...
          'ButtonDownFcn',...
          ['setProbePosition(' ...
          '''ButtonDownAt2DProbe'',gcbo,[],guidata(gcbo)', ...
          ', ' num2str(idx) ' )']);
      end
      msked = find(msk==false);
      % Remove .. for nnew
      if 0,
        if ~isempty(msked),
          set(prb2(msked),'Visible','off');
        end
      end
    end

    setappdata(handles.figure1, 'PROBE_2DHANDLES',prb);
    setappdata(handles.figure1, 'PROBE_2DHANDLES_act',prb_act);
    setappdata(handles.figure1, 'PROBE_2DHANDLES_msk',prb_msk);
    setappdata(handles.figure1, 'PROBE_2DHANDLES_TXT',prb2);

  case '3D',
    pos = getappdata(handles.figure1, 'Pos');
    ch_pos3 =pos.D3.P;
    prb     = getappdata(handles.figure1, 'CHANNEL_3DHANDLES');

    % Load Default sape
    msk = get(handles.lbx_Channel_Data, 'UserData');
    load('cubic_patch.mat','cubic_patch');
    cubic_patch0 = cubic_patch;

    if ~isempty(prb) && all(ishandle(prb)),
      % Changed Data
      val=get(handles.lbx_Channel_Data,'Value');
      for idx2=1:length(val)
        idx=val(idx2);
        delete(prb(idx));
        cubic_patch0.vertices = cubic_patch.vertices ...
          + repmat(ch_pos3(idx,:),size(cubic_patch.vertices,1),1);
        prb(idx) = patch(cubic_patch0);
        if msk(idx)==0,
          set(prb(idx),'Visible','off');
        end
        set(prb(idx),...
          'FaceColor',[1 0 0], ...
          'LineStyle','none', ...
          'ButtonDownFcn',...
          ['setProbePosition(' ...
          '''ButtonDownAt3DChannel'',gcbo,[],guidata(gcbo)', ...
          ', ' num2str(idx) ' )']);

      end
    else
      for idx=1:length(msk),
        cubic_patch0.vertices = cubic_patch.vertices ...
          + repmat(ch_pos3(idx,:),size(cubic_patch.vertices,1),1);
        prb(idx) = patch(cubic_patch0);
        if msk(idx)==0,
          set(prb(idx),'Visible','off');
        end
        set(prb(idx),...
          'FaceColor',[1 0 0], ...
          'LineStyle','none', ...
          'ButtonDownFcn',...
          ['setProbePosition(' ...
          '''ButtonDownAt3DChannel'',gcbo,[],guidata(gcbo)', ...
          ', ' num2str(idx) ' )']);

      end
      if exist('prb','var'),
        setappdata(handles.figure1, 'CHANNEL_3DHANDLES',prb);
      end
    end
    % shading faceted;
    axis auto;
end
return;

function changeview(handles)
return;

function reload_chdata(handles)
axes(handles.axes1);
hold on;

str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');
pos = getappdata(handles.figure1, 'Pos');
dlt = get(handles.lbx_Channel_Data, 'ListboxTop');
switch str{val},
  case '2D',
    ch_pos2= pos.D2.P;
    msk    = get(handles.lbx_Channel_Data, 'UserData');
    str2={};
    for idx = 1:size(ch_pos2,1),
      if msk(idx)==1,
        str2{idx} = sprintf('Ch(%3d) : o (%6.1f, %6.1f)', ...
          idx, ch_pos2(idx,1),ch_pos2(idx,2));
      else
        str2{idx} = sprintf('Ch(%3d) : x (%6.1f, %6.1f)', ...
          idx, ch_pos2(idx,1),ch_pos2(idx,2));
      end
    end
    if isempty(str2),
      set(handles.lbx_Channel_Data, ...
        'Value',1,...
        'String', 'No Channel exist in Data', ...
        'UserData',[]);
    else,
      set(handles.lbx_Channel_Data, ...
        'String', str2,...
        'UserData',msk, ...
        'ListboxTop',dlt);
    end

  case '3D',
    pos = getappdata(handles.figure1, 'Pos');
    ch_pos3 = pos.D3.P;
    msk = get(handles.lbx_Channel_Data, 'UserData');
    val = get(handles.lbx_Channel_Data, 'Value');
    for idx = 1:size(ch_pos3,1),
      if msk(idx)==1,
        str2{idx} = sprintf('Ch(%3d) : o (%6.1f, %6.1f, %6.1f)', ...
          idx, ch_pos3(idx,1),ch_pos3(idx,2), ch_pos3(idx,3));
      else
        str2{idx} = sprintf('Ch(%3d) : x (%6.1f, %6.1f, %6.1f)', ...
          idx, ch_pos3(idx,1),ch_pos3(idx,2), ch_pos3(idx,3));
      end
    end
    if val>idx, val=idx; end
    if val<0, val=1; end
    set(handles.lbx_Channel_Data, ...
      'Value',val,...
      'String', str2,...
      'UserData',msk, ...
      'ListboxTop',dlt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-Dimensional Position Modify
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position Change By push-button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_rotation_Callback(hObject, eventdata, handles)
% Do nothing ::
%  in r1. 9  : Do rotation
%  in r1.10  : Use following Push Button
return;

% Meeting on 24-Jan-2006
% Transfer Pusubuttons
function rot_invx_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',1);
psb_rotate_Callback(handles.psb_rotate, [], handles);
function psb_rotinvy_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',2);
psb_rotate_Callback(handles.psb_rotate, [], handles);
function psb_rot90_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',3);
psb_rotate_Callback(handles.psb_rotate, [], handles);
function psb_rot180_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',4);
psb_rotate_Callback(handles.psb_rotate, [], handles);
function psb_rotinv90_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',5);
psb_rotate_Callback(handles.psb_rotate, [], handles);
function psb_rotinv180_Callback(hObject, eventdata, handles)
set(handles.pop_rotation,'Value',4); % is as same as rot 180
psb_rotate_Callback(handles.psb_rotate, [], handles);

function psb_rotate_Callback(hObject, eventdata, handles)
% Execute on Button press in Transform(psb_rotate)
%    Transfrom Position-Data of 2D-Channel
%     along pop_rotation.
%
%  Input Data:
%     handles : Handles of the fugure Objects
%     hObject, eventdata : not in use..
%     'Value' of pop_rotation : Transfer Mode
%     'Value' of lbx_datalist : Transfer Probe
%      Position               : Position Infromation
%  Oupput Data: (Modify)
%      Position               : 2-Dimension Data
%
% Checked : 17-Dec-2005

% vl : Object Probe
vl  = get(handles.lbx_datalist, 'Value');
% c  : Transfer Mode (See alos String of pop_rotation )
%       1 : invert  X
%       2 : invert  Y
%       3 : rotate  90
%       4 : rotate 180
%       5 : rotate -90
c   = get(handles.pop_rotation,'Value');
% Position Data
pos = getappdata(handles.figure1,'Pos');

% Check exist Data
if isempty(pos),
  msg=' * Open Files at fast!';
  errordlg(msg); return;
end

% Index of Channel in the Probe 'vl'
ch = pos.Group.ChData{vl};
% 2D Position of Channel
d2 = pos.D2.P(ch,:);

% Move Origin of Transfer.
d20=  repmat(d2(1,:),[length(ch),1]);
d2 = d2 - d20;

switch c,
  case 1,
    % Invert to X
    d2 = [-d2(:,1),  d2(:,2)];
  case 2,
    % Invert to Y
    d2 = [d2(:,1),  -d2(:,2)];
  case 3,
    % Rotation 90
    d2 = [-d2(:,2),  d2(:,1)];
  case 4,
    % Rotation 180
    d2 = -d2;
  case 5,
    % Rotation -90
    d2 = [d2(:,2),  -d2(:,1)];
  otherwise,
    % Undefined Mode
    error(['Undefined Transfer Mode :' num2str(c)]);
end

% Undo : Change Origin of Transfer.
pos.D2.P(ch,:)= d2+d20;
setappdata(handles.figure1,'Pos',pos);

% Change View
reload_chdata(handles);
reload_probe(handles);
return;


function sld_2dsize_Callback(hObject, eventdata, handles)
% Executes on slider movement.
%   Change Probe Size.
%
% Checked : 19-Dec-2005
% Add : Meeting 19-Dec-2005, T. Katura, M. Shoji.

% get data
prbidx = get(handles.lbx_datalist,'Value');  % Probe Index
psize  = get(handles.sld_2dsize,'UserData'); % Probe Size
sz     = get(hObject,'Value'); % New Probe Size.

% Change
psb_2d_resize_Callback(hObject, eventdata, handles, prbidx, sz/psize(prbidx));

% Save Now Probe Size
psize(prbidx) = sz;
set(handles.sld_2dsize,'UserData',psize);
sz=round(sz*10)/10;
set(handles.edt_2Dsize,'String',num2str(sz));

function psb_2d_size_1_Callback(hObject, eventdata, handles)
% Execute on Button press in 2D Original Size (psb_2d_size_1)
%   Undo : Probe-Size
%
% Add : According to Meeting on 26-Dec-2005.
%       T. Katura, M. Shoji.
set(handles.sld_2dsize,'Value',1);
sld_2dsize_Callback(handles.sld_2dsize,[],handles);

function edt_2Dsize_Callback(hObject, eventdata, handles)
% Execute when 2-D Probe Size Edit-Text is Changed.
%   Check if String of "2-D Probe Size Edit-Text" is OK?
%
%  Input Data:
%     handles : Handles of the fugure Objects
%     hObject : Handle of "2-D Probe Size Edit-Text"
%     'String' of hObject   :"2-D Probe Size Edit-Text"
%     'UserData' of "2-D Probe Size Edit-Text"
%  Oupput Data: (Modify)
%     'UserData' of "2-D Probe Size Edit-Text"
%      --> User Data is Effective Data
%          of Size
%
% Checked : 17-Dec-2005
%
% Remove --> 19-Dec-2005 : 20:00
% This function replase by sld_2dsize_Callback
%
% Meeting 19-Dec-2005, T. Katura, M. Shoji.

% 2D Position Change
%   try,
%     siz_new = str2num(get(hObject,'String'));
%     if length(siz_new)~=1,
%       error('Number of Size String Error');
%     end
%     if siz_new<=0,
%       error('Size must be Positive');
%     end
%   catch,
%     ud = get(hObject,'UserData');
%     if isempty(ud), ud=1; end
%     ud = num2str(ud);
%     set(hObject,...
% 	'ForegroundColor','red', ...
% 	'String', ud);
%     errordlg(sprintf(['OSP Error!!!\n', ...
% 		      '<<Not Proper 2D Size>>\n', ...
% 		      '<<%s>>\n'], ...
% 		     lasterr));
%     return;
%   end
%   set(hObject,...
%       'ForegroundColor',[0 0 0], ...
%       'UserData',siz_new);

function psb_2d_resize_Callback(hObject, eventdata, handles, prbidx, sz)
% Execute on Button press in Resize 2D Probe (psb_2d_resize)
%  Resize 2D Probe the Transfrom Position-Data of 2D-Channel
%     along pop_rotation.
%
%  Input Data:
%     handles : Handles of the fugure Objects
%     hObject, eventdata : not in use..
%     'Value' of lbx_datalist : Transfer Probe
%      Position               : Position Infromation
%     sz       :  Multiple Size,
%  Oupput Data: (Modify)
%      Position               : 2-Dimension Data
%
% Checked : 17-Dec-2005

% multiple
% edt_2Dsize_Callback(handles.edt_2Dsize, [], handles)
% vl  = get(handles.lbx_datalist, 'Value');
% sz=get(handles.edt_2Dsize,'UserData');
pos = getappdata(handles.figure1,'Pos');
msg={};
if isempty(pos),
  msg{end+1}=' * Open Files at fast!';
end
if isempty(sz),
  msg{end+1}=' * Set Multiple Size at fast!';
end
if ~isempty(msg),
  errordlg(msg); return;
end
ch = pos.Group.ChData{prbidx};
d2 = pos.D2.P(ch,:);
d20=  repmat(d2(1,:),[length(ch),1]);
d2 = d2 - d20;
d2 = d2 * sz(1);
pos.D2.P(ch,:)= d2+d20;
setappdata(handles.figure1,'Pos',pos);

% Change View (Reload)
% psb_replot_Callback(handles.psb_replot, [], handles);
reload_probe(handles);
reload_chdata(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3-Dimensional Base Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function basic=getBasic(handles)
%-----------------------------
% Get Structure of Basic data
%-----------------------------
% Basic Data is as following,
%   basic.Nasion   : position of Nasion    (x,y,z);
%   basic.LefEar   : position of Left Ear  (x,y,z);
%   basic.RightEar : position of Right Ear (x,y,z);
basic.Nasion   = get(handles.edt_Nasion, 'UserData');
basic.LeftEar  = get(handles.edt_LeftEar, 'UserData');
basic.RightEar = get(handles.edt_RightEar, 'UserData');
return;

function data=edt_Nasion_Callback(hObject, eventdata, handles)
% check data
data=chk_3data(hObject,eventdata, handles,'Nasion');
function data=edt_LeftEar_Callback(hObject, eventdata, handles)
data=chk_3data(hObject,eventdata, handles,'Left Ear');
function data=edt_RightEar_Callback(hObject, eventdata, handles)
data =chk_3data(hObject,eventdata, handles,'RightEar');
function [data, msg]=chk_3data(hObject,eventdata, handles, inpname)
%-----------------------------
%  check 3Dimensional BasicData
%-----------------------------
str=get(hObject,'String');
msg=[];
try
  data= str2num(str);
  data=data(:);
  if ~isnumeric(data) || size(data,1)~=3,
    msg='String must be 3-numerical value';
  end
catch
  msg=lasterr;
end

if ~isempty(msg),
  % Error Case
  msg = sprintf('=== [Platform] Error!! ===\n<<inpname :%s,\n\t%s>>\n',...
    inpname,msg);
  data=[];
  set(hObject,'ForegroundColor','red');
  errordlg(msg);
else
  setappdata(handles.figure1, 'MODYFY_FLAG',true);
  % reset UserData
  set(hObject,'ForegroundColor','black');
  set(hObject,'UserData',data);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Othere
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function cMenu_MaskChannel_Callback(hObject, eventdata, handles)
% hObject    handle to cMenu_MaskChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% val=get(handles.lbx_Channel_Data, 'Value');
% val=get(handles.lbx_Channel_Data, 'Value');
%
str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');

vl  =  get(handles.lbx_Channel_Data, 'Value');
msk = get(handles.lbx_Channel_Data, 'UserData');

title = ['Channel(' num2str(vl) ')'];
prompt={'Mask'};
if msk(vl)==0,
  def   ={'x'};
else
  def   ={'o'};
end

if strcmp(str{val},'3D'),
  pos = getappdata(handles.figure1, 'Pos');
  ch_pos3 = pos.D3.P;
  prompt{end+1}='X';prompt{end+1}='Y';prompt{end+1}='Z';
  def{end+1}=num2str(ch_pos3(vl,1));
  def{end+1}=num2str(ch_pos3(vl,2));
  def{end+1}=num2str(ch_pos3(vl,3));
end

while 1,
  def = inputdlg(prompt, title, 1, def);
  try
    if isempty(def), return; end % canncel
    switch def{1},
      case 'o',
        msk(vl)       = true;
      case 'x',
        msk(vl)       = false;
      otherwise,
        error('[Platform] Error!!\n<< Mask Setting : Out of format\n');
    end

    if strcmp(str{val},'2D'), break; end
    ch_pos3(vl,1) = str2num(def{2});
    ch_pos3(vl,2) = str2num(def{3});
    ch_pos3(vl,3) = str2num(def{4});
    break;
  catch
    errordlg(lasterr);
  end
end

set(handles.lbx_Channel_Data, 'UserData',msk);

if strcmp(str{val},'3D'),
  pos.D3.P = ch_pos3;
  setappdata(handles.figure1, 'Pos',pos);
  reload_probe(handles);
end
% Data Change
reload_chdata(handles);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Input !!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_LoadPosFile_Callback(hObject, eventdata, handles)
% Executes on button press in Load Position File
% Load Position File

% Modify : 30-Mar-2006
%   (Position File)
%   DO : 1. Add Swich-Sentence by Version of ETG
%           (Modifyed etg_pos_fread)
%        2. Add Estimation,
%           from Source Position <--> Detector Position
%            to  Channel Position
%          Point-Out by Yanaka.
%

%-----------------------------------------
% Load Position File
%          & Convert
% (Source Position <--> Detector Position)
%    to  Channel Position
%-----------------------------------------
set(handles.figure1,'Visible','off');
try
  pos = etgpos_sd2ch;
catch
  set(handles.figure1,'Visible','on');
  errordlg(lasterr);
  return;
end
set(handles.figure1,'Visible','on');
% Cancel?
if isempty(pos), return; end
% debug mode?
if ischar(pos), return; end

%-------------------
%  Set Result!
%-------------------
% == Set Base Data ==
% Nasion
try
  set(handles.edt_Nasion,'String',...
    ['[' ...
    num2str(pos.D3.Base.Nasion(1)) ' ' ...
    num2str(pos.D3.Base.Nasion(2))  ' ' ...
    num2str(pos.D3.Base.Nasion(3)) ']']);
  edt_Nasion_Callback(handles.edt_Nasion, [], handles);
catch
  warning(lasterr);
end
% LeftEar
try
  set(handles.edt_LeftEar,'String',...
    ['['...
    num2str(pos.D3.Base.LeftEar(1)) ' ' ...
    num2str(pos.D3.Base.LeftEar(2)) ' ' ...
    num2str(pos.D3.Base.LeftEar(3)) ']']);

  edt_LeftEar_Callback(handles.edt_LeftEar, [], handles);
catch
  warning(lasterr);
end
% Right Ear
try
  set(handles.edt_RightEar,'String',...
    ['[' ...
    num2str(pos.D3.Base.RightEar(1)) ' ' ...
    num2str(pos.D3.Base.RightEar(2)) ' ' ...
    num2str(pos.D3.Base.RightEar(3)) ']']);
  edt_RightEar_Callback(handles.edt_RightEar, [], handles);
catch
  warning(lasterr);
end

% == Set 3D Position ==
% 3D Position Load
posX = getappdata(handles.figure1, 'Pos');
posX.D3.Base=pos.D3.Base;

if length(posX.Group.mode)~=length(pos.Group.mode),
  errordlg('Probe Number is not qual'); return;
end
for idx=1:length(posX.Group.mode),
  if 0 && posX.Group.mode(idx)~=pos.Group.mode(idx),
    warning(' * Mode is different!');
  end
  ocx=pos.Group.OriginalCh{idx};

  idx2=posX.Group.ChData{idx};
  idx3=pos.Group.ChData{idx};
  try
    posX.D3.P(idx2,:)=pos.D3.P(idx3(ocx),:);
  catch
    error(' * Unmutch Position!');
  end
end
setappdata(handles.figure1, 'Pos',posX);

% === Change View ===
str = get(handles.pop_mode,'String');
val = get(handles.pop_mode,'Value');
if strcmp('3D', str{val}),
  psb_replot_Callback(handles.psb_replot,[],handles);
end

return;

function bk=backup_data(handles)
% Backup Data
bk.OSP_SP_DATA      = getappdata(handles.figure1, 'OSP_SP_DATA');
bk.lbx_Channel_Data = get(handles.lbx_Channel_Data, 'UserData');
bk.lbx_datalistU    = get(handles.lbx_datalist, 'UserData');
bk.lbx_datalistS    = get(handles.lbx_datalist, 'String');
bk.APP_Pos          = getappdata(handles.figure1,'Pos');
bk.APP_SAVE_FLAG    = getappdata(handles.figure1, 'SAVE_FLAG');
bk.APP_MODYFY_FLAG  = getappdata(handles.figure1, 'MODYFY_FLAG');
bk.APP_CommonData   = getappdata(handles.figure1, 'CommonData');

function recover_data(handles,bk)
% Recover 
setappdata(handles.figure1, 'OSP_SP_DATA',bk.OSP_SP_DATA);
set(handles.lbx_Channel_Data, 'UserData',bk.lbx_Channel_Data);
set(handles.lbx_datalist, 'UserData',bk.lbx_datalistU);
set(handles.lbx_datalist, 'String',bk.lbx_datalistS);

setappdata(handles.figure1,'Pos',bk.APP_Pos);
setappdata(handles.figure1, 'SAVE_FLAG',bk.APP_SAVE_FLAG);
setappdata(handles.figure1, 'MODYFY_FLAG',bk.APP_MODYFY_FLAG);
setappdata(handles.figure1, 'CommonData',bk.APP_CommonData);


function psb_loaddata_Callback(hObject, eventdata, handles,actdata)
%-----------------------------
% Signal-Data Load Function.
%-----------------------------
% Reset Data and Load-Data
%
% Warning ::
% *** This is "Data-Input" Function. ***
%     Height Quality Required!
%
% Checked : 19-Dec-2005

%  -- Lock --
set(handles.figure1, 'Visible', 'off');
set(handles.lbx_Channel_Data, 'Value',1);

% === File Select  ===
% Changed : 28-Nov-2005
if nargin<=3
  try
    actdata=uiFileSelectPP;
  catch
    if ishandle(handles.figure1)
      set(handles.figure1,'Visible','on');
    end
    rethrow(lasterror);
  end
end
% -- Unlock --
set(handles.figure1,'Visible','on');
% Cancel
if isempty(actdata), return; end


bk=backup_data(handles); % Backup Data
% === Reset Data ===
if length(actdata)>=2,
  for idx=1:length(actdata);
    actdata2(idx)=actdata{idx};
  end
  actdata = actdata2;
else
  actdata = actdata{1};
end
setappdata(handles.figure1, 'OSP_SP_DATA',[]);
set(handles.lbx_Channel_Data, 'UserData',[]);
set(handles.lbx_datalist, 'UserData',[]);
set(handles.lbx_datalist, 'String',{});

% Remove Some Apprication Data
%  -> And Add Pos-Data
%    05-Dec-2005 : M. Shoji
Pos.ver  = 2.0;          % Add : 05-Dec-2005
Pos.D2.P = [];
Pos.D3.P = [];
Pos.D3.Base = getBasic(handles);
Pos.Group.ChData = {};
Pos.Group.mode   = [];
Pos.Group.OriginalCh  = {}; % Add : 05-Dec-2005
setappdata(handles.figure1,'Pos',Pos);
% Save   : Not saved
%  if loaded data have position data,
%  save flag is ture. See also Add-Probe
setappdata(handles.figure1, 'SAVE_FLAG',false);
% Modify : Not modifyed  Add : 17-Dec-2005
setappdata(handles.figure1, 'MODYFY_FLAG',false);
setappdata(handles.figure1, 'CommonData',[]);

% === Data Load ===
try
  for idx=1:length(actdata),
    addProbe(handles, actdata(idx));
  end
catch
  errordlg({ '[Platform] Error : ', lasterr});
  setappdata(handles.figure1, 'OSP_SP_DATA',[]); % 
  recover_data(handles,bk);
  return;
end

% === Reset View ===
% Change Selected Data
st=get(handles.lbx_datalist,'String');
vl=get(handles.lbx_datalist,'Value');
stlen = length(st);
if (stlen<vl), vl=stlen; end
ud=ones([1,stlen]);
set(handles.lbx_datalist,'Value',vl);
set(handles.sld_2dsize,'UserData',ud);
try
  cm  = getappdata(handles.figure1, 'CommonData');  
  if (cm.measuremode==-1),
    set(handles.ckb_replace,'Visible','off')
  end
catch
end
lbx_datalist_Callback(handles.lbx_datalist, [], handles,true);
% Reload
psb_replot_Callback(handles.psb_replot, [], handles);
return;

function addProbe(handles, actdata)
% Add 1 File to Present Data-List
%
% Checked : 19-Dec-2005

% get data already set
pos = getappdata(handles.figure1,'Pos'); % Position Data
msk = get(handles.lbx_Channel_Data, 'UserData'); % Mask Data
% Common Data Add. (10-Aug-2005)
% cm : Common Data in New Data.
%      This data must be same in some files.
%      If cm is different each other,
%      User mignt confused.
%      So make Error.
cm  = getappdata(handles.figure1, 'CommonData');

dt   = getappdata(handles.figure1, 'OSP_SP_DATA');
st   = get(handles.lbx_datalist, 'String');

if isempty(st), st={}; end

% Get Data Name
%dname = DataDef_SignalPreprocessor('getFilename',actdata.data.filename);
UseFnc=getappdata(handles.figure1,'UseFunction');
dname=eval([UseFnc '(''getFilename'',actdata.data.filename);']);
% Load Continuous Data.
[data, header] = uc_dataload(dname);
[p, dname] = fileparts(dname);

% === Set Initial Data ===
if header.measuremode==-1,
  % Edit Mode ::
  %   Load Data already have Position Data
  %   (Measure Mode is -1)
  %
  % Must be One Probe!!
  if ~isempty(st),
    error('[Platform] Error!! Multi File & Normal File Selected');
  end
  %if ~isfield(header.Pos,'ver'),
  %  error('Cannot Edit Old Pos-Data');
  %end
  pos = header.Pos;
  if ~isfield(pos,'D2') || ~isfield(pos.D2,'P') || ...
      ~isfield(pos,'D3') || ...
      ~isfield(pos.D3,'P') || ~isfield(pos.D3,'Base') || ...
      ~isfield(pos,'Group') || ...
      ~isfield(pos.Group,'ChData') || ~isfield(pos.Group,'mode') || ...
      ~isfield(pos.Group,'OriginalCh')
    error('Platform Error! Position Data - Format Error');
  end
  for idx=1:length(pos.Group.OriginalCh),
    st{end+1}   = [dname ': ' num2str(idx)];
  end
  msk      = true(1,size(pos.D2.P,1));

  cm.stim           = header.stim;
  cm.samplingperiod = header.samplingperiod;
  cm.timedata_num   = size(data,1);
  cm.datakind_num   = size(data,3);
  cm.measuremode    = -1; % for stop to load normal mode

  % Treatment :: !! Allready Saved !!
  savedNames.filename  = actdata.data.filename;
  savedNames.ID_number = actdata.data.ID_number;
  setappdata(handles.figure1,'SavedNames',savedNames);
  setappdata(handles.figure1, 'SAVE_FLAG',true);
  % ==> Add 30-Jan-2005
  % Copy Source : ON
  set(handles.psb_copy,'Visible','on');
else
  chnum0    = size(pos.D2.P,1);
  d_siz     = [1, 1];
  d_pos     = [0, 0];
  p0        = time_axes_position(header,d_siz, d_pos);
  p0 = p0(:,1:2);
  % Channel Interval Change
  % Change Size
  % dX = 10, dY=5
  dx=abs(p0(:,1)-p0(1,1));
  dx=dx+(dx==0);
  dx = min(dx);
  dy=abs(p0(:,2)-p0(1,2));
  dy=dy+(dy==0);
  dy = min(dy);
  p0(:,1) =  5*p0(:,1) ./dx;
  p0(:,2) =  5*p0(:,2) ./dy;

  % Change Position
  p0 = p0- 60 + size(pos.Group.mode,2)*25;
  pos.D2.P = [pos.D2.P; p0];

  [d_ch_pos3, d_msk] = getDefault_ch_pos3(header.measuremode, ...
    size(data,2));
  pos.D3.P = [pos.D3.P; d_ch_pos3];
  msk      = [msk, d_msk];
  pos.Group.mode        = [pos.Group.mode, header.measuremode];

  if header.measuremode==1,
    % Channel Mode 1
    % 2-Probe exist in one File!
    %   Probe 1:  1-12 Channel
    %   Probe 2: 13-24 Channel
    st{end+1}   = [dname ':1'];
    st{end+1}   = [dname ':2'];
    pos.Group.OriginalCh{end+1} = [ 1:12];
    pos.Group.ChData{end+1}= chnum0 + pos.Group.OriginalCh{end};
    pos.Group.OriginalCh{end+1} = [13:24];
    pos.Group.ChData{end+1}= chnum0 + pos.Group.OriginalCh{end};
    pos.Group.mode        = [pos.Group.mode, header.measuremode];

    % set double dt, because there is two Probe in the file.
    % -- Bug fixed : 19-Dec-2005 : --
    % where dt is Original Signal-Data.
    if isempty(dt),
      dt=actdata;
    else
      dt(end+1)=actdata;
    end

  else  % Measuremode Other
    st{end+1}   = dname;
    pos.Group.OriginalCh{end+1} = [ 1:size(p0,1)];
    pos.Group.ChData{end+1}= chnum0 + pos.Group.OriginalCh{end};
  end

  % === Check Dta ===
  % Set Common Data
  if isempty(cm),
    clear cm;
    cm.stim           = header.stim;
    cm.samplingperiod = header.samplingperiod;
    cm.timedata_num   = size(data,1);
    cm.datakind_num   = size(data,3);
    cm.measuremode    = 0; % for stop to load normal mode
  else
    % Check Common Data
    % If Common-Data is same exactly?
    msg = sprintf(['[Platform] Error!!\n' ...
      ' << Signal-Data Difference Format' ...
      ' Error>>\n']);
    if cm.measuremode==-1,
      error([msg '<<Load Error!! : MultiFile Include!>>']);
    end
    if ~all(cm.stim ==header.stim),
      error([msg '<<Stimulation-Timing Error!!>>']);
    end
    if cm.samplingperiod ~= header.samplingperiod,
      error([msg '<<Sampling Period Error!!>>']);
    end
    if cm.timedata_num  ~= size(data,1),
      error([msg '<<Time Data Size Error!!>>']);
    end
    if cm.datakind_num ~= size(data,3)
      error([msg '<<Data Kind Size Error!!>>']);
    end
  end % Check Common Data
end

if isempty(dt),
  dt=actdata;
else
  dt(end+1)=actdata;
end
setappdata(handles.figure1,'Pos',pos);
set(handles.lbx_datalist, ...
  'Value',     1, ...
  'String'  ,  st);
set(handles.lbx_datalist, 'UserData', length(st)); % Update each group name
set(handles.lbx_Channel_Data, 'UserData',msk);
setappdata(handles.figure1, 'OSP_SP_DATA',dt);

% Common Data Add. (10-Aug-2005)
setappdata(handles.figure1, 'CommonData',cm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Output !!!
%  Important :
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_save_Callback(hObject, eventdata, handles)
% Exchange Data and
%    Save - SignalPreprocessor-Data with Position Data
%    --> See also : Document about Position Data.
%
% Save Data
% Call when
%    * Push Button Down.
%    * Closeing-reques, and user want to Save.
%
% if nargout>=1
%   get-saving-data and not save
%
% TODO : 17-Dec-2005
%        Sorry, bugs might be rest...
% get data-type SignalPreprocessor or Raw-data
UseFnc=getappdata(handles.figure1,'UseFunction');
if strcmp(UseFnc,'DataDef2_RawData'),
  data_ver='3';
else
  data_ver='2';
end
set(handles.figure1,'Visible','off');
try
  % ===> See Also Signal Data <===
  dt  = getappdata(handles.figure1, 'OSP_SP_DATA');
  if isempty(dt),
    msgbox('No Data to save','Save');
    set(handles.figure1,'Visible','on'); return;
  end

  % == Making default  Position ==
  msk = get(handles.lbx_Channel_Data, 'UserData');
  mskidx=zeros(size(msk));chorder=mskidx;
  ii1=0;
  for ii0=1:length(msk)
    if msk(ii0)==1
      mskidx(ii0)=ii0-ii1;
    else
      ii1=ii1+1;
    end
  end

  % Get Position Data for each channel
  pos = getappdata(handles.figure1, 'Pos');
  bs  = getBasic(handles);
  pos.D3.Base = struct_merge0(pos.D3.Base,bs,0);

  usech    = find(msk(:));
  pos.D2.P =pos.D2.P(usech,:);
  pos.D3.P =pos.D3.P(usech,:);
  %======================================================================>>
  % Fast Data Load
  %======================================================================>>
  cidx2 =0;
  for idx=1:length(dt)
    % Load Data
    %[hdata, data]=DataDef_SignalPreprocessor('load',dt(idx).data);
    [hdata, data]=eval([UseFnc '(''load'',dt(idx).data);']);
    if hdata.measuremode==-1,
      cidx2=0;cidx=1;
      new_info = hdata.TAGs;
      for idx2 = 1: length(pos.Group.ChData)
        cidx = cidx2+1;
        ch   = pos.Group.OriginalCh{idx2};
        ch(msk(pos.Group.ChData{idx2})==0) = [];
        pos.Group.OriginalCh{idx2}=ch;
        cidx2 = cidx + length(ch)-1;
        pos.Group.ChData{idx2} = cidx:cidx2;
        %pos.Group.ChData{idx2} = mskidx(ch);
      end
      usech2=usech'*2; usech2=[(usech2-1);usech2];
      usech2=usech2(:)';%usech2=sort(usech2);
      % * Info Change..
      try
        new_info.plnum = length(pos.Group.ChData);
      end
      try
        new_info.adnummeasnum = new_info.adnummeasnum(1,usech2);
      end
      try
        new_info.wavelength = new_info.wavelength(1,usech2);
      end
      try
        new_info.adrange = new_info.adrange(1,usech2);
      end
      try
        new_info.ampgain = new_info.ampgain(1,usech2);
      end
      try
        new_info.d_gain = new_info.d_gain(1,usech2);
      end
      try
        new_info.data    = new_info.data(:,usech2);
      end
      sz=size(hdata.flag);sz(3)=length(usech);
      hdata.flag = hdata.flag(:,:,usech);
      hdata.TAGs=new_info;
      hdata.Pos=pos;
      data = data(:,usech,:);
      %DataDef_SignalPreprocessor('save_ow',hdata,data,2,dt(idx));
      eval([UseFnc '(''save_ow'',hdata,data,' data_ver ',dt(idx));']);
      set(handles.figure1,'Visible','on');
      setappdata(handles.figure1, 'Position',pos);
      setappdata(handles.figure1, 'Mask',msk);
      set(handles.psb_copy,'Visible','on');
      % Need :: Reload / delete : Bug fix : 13-Feb-2006
      delete(handles.figure1);
      return;
    end
    % Renew Channel Index(not masking),
    cidx = cidx2+1;
    ch0  = pos.Group.ChData{idx};
    ch   = pos.Group.OriginalCh{idx};
    msk0 = msk(pos.Group.ChData{idx})==0;
    ch0(msk0)=[];ch(msk0) = [];
    pos.Group.OriginalCh{idx}=ch;
    cidx2 = cidx + length(ch)-1;
    %pos.Group.ChData{idx} = cidx:cidx2;
    pos.Group.ChData{idx} = mskidx(ch0);
    chorder(cidx:cidx2)=mskidx(ch0);

    % Ignore un msked channel
    if isempty(ch), continue; end

    % Add new data
    new_info = hdata.TAGs;
    new_hdata = hdata;
    new_data = data(:,ch,:);
    ch2=ch*2; ch2=[(ch2-1);ch2 ];
    ch2=ch2(:)'; %ch2=sort(ch2);
    
    % * Info Change..
    try
      new_info.plnum = length(pos.Group.ChData);
    end
    try
      new_info.adnummeasnum = new_info.adnummeasnum(1,ch2);
    end
    try
      new_info.wavelength = new_info.wavelength(1,ch2);
    end
    try
      new_info.adrange = new_info.adrange(1,ch2);
    end
    try
      new_info.ampgain = new_info.ampgain(1,ch2);
    end
    try
      new_info.d_gain = new_info.d_gain(1,ch2);
    end
    try
      new_info.data    = new_info.data(:,ch2);
    end
    new_hdata.flag = hdata.flag(:,:,ch);
    new_hdata.measuremode = -1;
    break;
  end

  %======================================================================>>
  % after,
  %======================================================================>>
  for idx=idx+1:length(dt),
    % Renew Channel Index(not masking),
    cidx = cidx2+1;
    ch0  = pos.Group.ChData{idx};
    ch   = pos.Group.OriginalCh{idx};
    msk0 = msk(pos.Group.ChData{idx})==0;
    ch0(msk0)=[];ch(msk0) = [];
    ch2=ch*2; ch2=[ch2 (ch2-1)];
    ch2=sort(ch2);

    pos.Group.OriginalCh{idx}=ch;
    cidx2 = cidx + length(ch)-1;
    %pos.Group.ChData{idx} = cidx:cidx2;
    pos.Group.ChData{idx} = mskidx(ch0);
    chorder(cidx:cidx2)=mskidx(ch0);
    if isempty(ch), continue; end % Ignore un msked channel


    % Load Data
    %[hdata, data]=DataDef_SignalPreprocessor('load',dt(idx).data);
    [hdata, data]=eval([UseFnc '(''load'',dt(idx).data);']);
    % Add new data
    new_data(:,cidx:cidx2,:)         = data(:,ch,:); clear data;
    new_hdata.flag(:,:,cidx:cidx2)   = hdata.flag(:,:,ch);
    % stim, stimTC, StimMode, samplingperiod Must be Same;

    % * Info Change..
    try
      new_info.adnummeasnum = ...
        [new_info.adnummeasnum, hdata.TAGs.adnummeasnum(1,ch2)];
    end
    try
      new_info.wavelength = ...
        [new_info.wavelength, hdata.TAGs.wavelength(1,ch2)];
    end
    try
      new_info.adrange = ...
        [new_info.adrange, hdata.TAGs.adrange(1,ch2)];
    end
    try
      new_info.ampgain = ...
        [new_info.ampgain, hdata.TAGs.ampgain(1,ch2)];
    end
    try
      new_info.d_gain = ...
        [new_info.d_gain, hdata.TAGs.d_gain(1,ch2)];
    end
    try
      new_info.data(:,cidx*2-1:cidx2*2)   = hdata.TAGs.data(:,ch2);
    end
  end
  
  %======================================================================>>
  % Other Data Setting
  %======================================================================>>
  % Data size change,
  new_info.adnum = size(new_data,2)*2;
  new_info.chnum = size(new_data,2);

  % Other Data change
  new_info.ospsoftversion=2;
  new_info.measuremode   = -1; % new defined!

  %======================================================================>>
  % Re-sort
  %======================================================================>>
  chorder(chorder==0)=[];
  [x,chidx]=sort(chorder);
  data    = new_data(:,chidx,:); clear new_data;
  new_hdata.flag=new_hdata.flag(:,:,chidx);
  hdata        = new_hdata;
  chidx2=chidx*2; chidx2=[chidx2-1;chidx2];chidx2=chidx2(:)';
  try
    new_info.adnummeasnum = new_info.adnummeasnum(1,chidx2);
  end
  try
    new_info.wavelength = new_info.wavelength(1,chidx2);
  end
  try
    new_info.adrange = new_info.adrange(1,chidx2);
  end
  try
    new_info.ampgain = new_info.ampgain(1,chidx2);
  end
  try
    new_info.d_gain = new_info.d_gain(1,chidx2);
  end
  try
    new_info.data  = new_info.data(:,chidx2);
  end

  hdata.TAGs   = new_info; clear new_info;
  hdata.Pos    = pos;

  % === Data Save ===
  flg = getappdata(handles.figure1, 'SAVE_FLAG');
  if flg==false
    % ---------------------
    % Save New Signal-Data
    % Get Information of Data
    %  Since version 1.11
    % ---------------------
    prompt ={'File Name :', 'ID : '};
    name0=dt(1).data.filename;
    s=regexpi(name0,'Probe[0-9]');
    if ~isempty(s),  name0=name0(1:s(1));end
    def    ={name0,['POS' dt(1).data.ID_number]};

    %======> Tell Meating <=============
    % 2007.09.26
    % (Replace : Delete )
    flgr=get(handles.ckb_replace,'Value');
    if flgr
      % mail at 2008.08.12 (No Question-Dialog)
      OSP_DATA('SET','ConfineDeleteDataRD',false);  % Raw-Delete
      OSP_DATA('SET','ConfineDeleteDataSV',false);  % Ana-Delete
      for id0=1:length(dt)
        if id0==1
          % Get ANA - Filter Data
          try
            rf=FileFunc('getRelationFileName');
            clist = FileFunc('getChildren', rf,...
              DataDef2_RawData('reshapeName',dt(id0).data.filename));
            x=strmatch('ANA_',clist);
            if ~isempty(x)
              anad=FileFunc('getVariable',rf,clist{x(1)});
              anad=feval(anad.fcn,'load',anad.data);
            end
          catch
            disp('Load Recipe Error --')
          end
        elseif isequal(dt(id0).data,dt(id0-1).data)
          continue;
        end
        try
          eval([UseFnc '(''deleteGroup'',dt(id0).data.filename);']);
        catch
          disp(dt(id0).data);
          warning('could not delete file');
        end
      end
      OSP_DATA('SET','ConfineDeleteDataRD',true);  % Raw-Delete
      OSP_DATA('SET','ConfineDeleteDataSV',true);  % Ana-Delete
    end
    % ========================

    % Make New Active-Data
    msg =sprintf(['[ Platform ] Warning!!\n' ...
      '<< In Saving Signal-Data>>\n']);
    while 1,
      def = inputdlg(prompt, ...
        'Save as SignalData', ...
        1, def);
      % Cancel
      if isempty(def),
        set(handles.figure1,'Visible','on'); return;
      end

      % File Check
      %fname = DataDef_SignalPreprocessor('getFilename',def{1});
      fname=eval([UseFnc '(''getFilename'',def{1});']);
      if exist(fname,'file')
        errordlg([msg 'Same File Name exist']);
        continue;
      end

      hdata.TAGs.filename  = def{1};
      hdata.TAGs.ID_number = def{2};
      % OSP_DATA('SET','OSP_LocalData',ldata);
      OSP_DATA('SET','SP_Rename','-'); % Confine Rename Option!
      try
        %DataDef_SignalPreprocessor('save',hdata,data,2);
        if strcmp(UseFnc,'DataDef2_RawData'),
          anaData=DataDef2_RawData('save',hdata,data,3);
          if exist('anad','var')
            anaData.data.filterdata=anad.data(1).filterdata;
            DataDef2_Analysis('save_ow',anaData);
          end
        else
          DataDef_SignalPreprocessor('save',hdata,data,2);
        end
        % if succes to save
        if ~exist(fname,'file'),
          error([msg ...
            'OSP Error : Could not make Signal Data']);
        end

        break;
      catch
        errordlg(lasterr);
      end
    end % whiel 1 : Get Information..
    savedNames.filename  = hdata.TAGs.filename;
    savedNames.ID_number = hdata.TAGs.ID_number;
    setappdata(handles.figure1,'SavedNames',savedNames);
    
    set(handles.figure1,'Visible','on');
    % --> psb load fname--->
    ad.fcn=eval(['@' UseFnc]);
    ad.data=eval([UseFnc '(''loadlist'',hdata.TAGs.filename);']);
    psb_loaddata_Callback(handles.psb_loaddata,[], handles,{ad});
    return;
  else
    savedNames = getappdata(handles.figure1,'SavedNames');
    hdata.TAGs.filename  = savedNames.filename;
    hdata.TAGs.ID_number = savedNames.ID_number;
    %OSP_DATA('SET','OSP_LocalData',hdataldata);
    %DataDef_SignalPreprocessor('save_ow',hdata,data,2);
    eval([UseFnc '(''save_ow'',hdata,data,' data_ver ');']);
    %fname = DataDef_SignalPreprocessor('getFilename',savedNames.filename);
    fname=eval([UseFnc '(''getFilename'',savedNames.filename);']);
  end % New Data

catch
  set(handles.figure1,'Visible','on');
  rethrow(lasterror);
end
setappdata(handles.figure1, 'SAVE_FLAG',true);
setappdata(handles.figure1, 'MODYFY_FLAG',false);
set(handles.figure1,'Visible','on');
setappdata(handles.figure1, 'Position',hdata.Pos);
setappdata(handles.figure1, 'Mask',msk);
set(handles.psb_copy,'Visible','on');
return;  % Pushbutton, save

function psb_copy_Callback(hObject, eventdata, handles)
% Copy From other data.
%
% TODO : Reload Data
% Visible Off
set(handles.figure1,'Visible','off');
try
  % Check Save Situation
  saveflag = getappdata(handles.figure1, 'SAVE_FLAG');
  modflag  = getappdata(handles.figure1, 'MODYFY_FLAG');

  % Need Save ?
  if isempty(saveflag) || (saveflag==false) || ...
      isempty(modflag) || modflag==true,
    % Not Saved of Modfy
    bname = questdlg('Do you want to save as Signal-Data?', ...
      'Colsing...', ...
      'Yes', 'No', 'Yes');
    % if saved --> continue;
    if strcmp(bname,'No'),
      set(handles.figure1,'Visible','on'); return;
    end
    psb_save_Callback(handles.psb_save,[],handles);
    saveflag = getappdata(handles.figure1, 'SAVE_FLAG');
    modflag  = getappdata(handles.figure1, 'MODYFY_FLAG');
  end

  if isempty(saveflag) || (saveflag==false),
    % No Copy source Selected::
    % Not Saved
    error('Can not Select Copy-Source');
  end

  % <-- Waint -->
  savedNames=getappdata(handles.figure1,'SavedNames');
  if isempty(savedNames),
    error('Apprication Error : No Saved Information');
  end
  d=copyPositionData('CopySource',savedNames.filename);
  % TODO : Reload Data

catch
  % Not to holt (for view on)
  eh=errordlg(lasterr);
  waitfor(eh);
end
% Visible ON
set(handles.figure1,'Visible','on');
return;


%------------------------------------------------>
% ??
function pushbutton16_Callback(hObject, eventdata, handles)
disp('pushbutton 16');
function pushbutton17_Callback(hObject, eventdata, handles)
disp('pushbutton 17');
%<------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_MakeGroup_Callback(hObject, eventdata, handles)
% Make New Group 

% Get channel Position properties
p=getappdata(handles.figure1,'Pos');
% p=
%       ver: 2
%        D2: [1x1 struct]
%        D3: [1x1 struct]
%     Group: [1x1 struct]

tmp_st=get(handles.lbx_datalist,'String'); % Label
st ={}; st{1}=tmp_st{1};

dt=getappdata(handles.figure1, 'OSP_SP_DATA'); % Function and data
dt=dt(end);
% dt =
%      fcn: '@DataDef2_RawData'
%     data: [1x1 struct]

sz=get(handles.sld_2dsize,'UserData'); % Size?
sz=sz(end);

% Unify several group to the single data, AllCh
AllCh = [];
for i = 1:size(p.Group.ChData, 2)
  AllCh = [AllCh p.Group.ChData{i}];
end
AllCh = sort(AllCh);

% Input the number of group
Ans = inputdlg('Please input the number of group');
GroupNum = str2num(cell2mat(Ans));

for i = 1:GroupNum
  new_gname = inputdlg(['Please input the name of group ' num2str(i) '/' num2str(GroupNum)]);
  new_gname = cell2mat(new_gname); % Name the group
  
  new_ch = inputdlg(['Input the channel number for the group ' new_gname '. You can choose from the numbers, ' num2str(AllCh)]);
  new_ch = str2num(cell2mat(new_ch)); % Input the channel no. for the group
  
  [foo, ix] = intersect(AllCh, new_ch);
  AllCh(ix) = [];
  
  % I should carefully check Shoji-san's comment below.
  
  %%% ここで　ChDataのソートが必要 %%%
  % --> mskも変更しないといけない。
  % --> pos もソートし直す必要がある(p.D2.P, p.D3.P)
  %%%%==> 保存時に保存の仕方を工夫すれば↑は不要 %%%%%

  p.Group.MakeGroup=true; %<-- Make Group Data
  p.Group.ChData{i}=new_ch;
  p.Group.OriginalCh{i} = p.Group.ChData{i};
  p.Group.mode(i) = p.Group.mode(end);
  
  st{i} = new_gname;
  dt(i) = dt(end);
  sz(i) = sz(end);
end

p.Group.ChData(i+1:end) = [];
p.Group.OriginalCh(i+1:end) = [];
p.Group.mode(i+1:end) = [];
  
setappdata(handles.figure1, 'Pos' ,p);
set(handles.lbx_datalist, 'String', st); % Update each group name
set(handles.lbx_datalist, 'UserData', length(st)); % Update each group name
setappdata(handles.figure1, 'OSP_SP_DATA', dt); % Data copy
set(handles.sld_2dsize, 'UserData', sz); % UserData setting for resize
setappdata(handles.figure1, 'MODYFY_FLAG',true);

% Update the integrity of any other data
lbx_datalist_Callback(handles.lbx_datalist, [], handles,true);
psb_replot_Callback(handles.psb_replot, [], handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_OnGrid_Callback(h, e, handles) %#ok
% Grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% === Get Essential Data ===
pos = getappdata(handles.figure1, 'Pos'); % Now Position
gunit=get(handles.menu_2D_Grid,'UserData');
% Change 2-Dimension Position.
pos.D2.P = round(pos.D2.P/gunit)*gunit;
% Update "Position Data"
setappdata(handles.figure1, 'Pos',pos);
% Modify : Flag
%   Change in Button-Up
setappdata(handles.figure1, 'MODYFY_FLAG',true);

reload_probe(handles);
disp2D_xy(handles); % display probe XY :
% Channel Data List Change::
reload_chdata(handles);


function psb_preview_Callback(h, e, hs)
% Preview Current-Data

%========================================
% Make Dummy-Data
%========================================
%----------------------
% Read Position 
%----------------------
msk = get(hs.lbx_Channel_Data, 'UserData');
% Get Position Data for each channel
pos = getappdata(hs.figure1, 'Pos');
pos.D3.Base = getBasic(hs);

%pos.D2.P =pos.D2.P(msk==1,:);
%pos.D3.P =pos.D3.P(msk==1,:);

chnum=size(pos.D3.P,1);
data=reshape(linspace(0,100*pi,100*chnum*3),[100,chnum,3]);
%data=0.5*sin(data)+0.2*rand(size(data));
data=0.5*sin(data);
%----------------------
% Stim
%----------------------
header.stim      = zeros(2,3);
header.stim(1,1) = 10;
header.stim(1,2) = 11;
header.stim(1,3) = 1;
header.stim(2,1) = 90;
header.stim(2,2) = 91;
header.stim(2,3) = 1;
% set stimTC
header.stimTC = zeros(1,size(data,1));
header.stimTC([10,90])=1;
% set stimMode
header.StimMode = 1;    % =Event

%-----------
% Position
%-----------
header.measuremode=-1;
header.Pos = pos;

%-----------
% set flag
%-----------
header.flag     = false([1, size(data,1), size(data,2)]);

%--------------------
% set sampling_period
%--------------------
header.samplingperiod =100; % msec

%-----------
% set TAGs
%-----------
tags.DataTag     = {'Oxy','Deoxy','Total'};
tags.filename    = '';
tags.pathname    = '';
tags.ID_number   = 'Biopsy';  % set suitably
tags.age='0';                              % set suitably
tags.sex=1;                                 % set suitably,Male
tags.subjectname = 'anonymity';             % set suitably
tags.comment     = '';
tags.date        = now;
% Back-up Raw Data (if you want)
header.TAGs = tags;

%-----------
% Add : Member-Information
%-----------
MemberInfo = struct( ...
  'stim', ['Stimulation Data, ' ...
  '(Number of Stimulation, ' ...
  '[kind, start, end])'], ...
  'stimTC', ['Stimulation Timeing, ' ...
  '(1, time)'], ...
  'StimMode', ['Stimulation Mode, ' ...
  '1:Event, 2:Block'], ...
  'flag',  ['Flags, (kind, time, ch),  ' ...
  ' Now kind is only one, if 1, then Motion occur'], ...
  'measuremode', ' Measure Mode of ETG', ...
  'samplingperiod', 'sampling period [msec]', ...
  'TAGs', 'Other Data', ...
  'MemberInfo', 'This Data, Header fields Information');
header.MemberInfo = MemberInfo;

%========================================
% Load-Layout-File
%========================================
p=fileparts(which(mfilename));
layoutfile =[p filesep 'LAYOUT_Preview.mat'];
load(layoutfile,'LAYOUT');

%=================
% Draw
%=================
osp_LayoutViewer(LAYOUT,{header},{data});
%  Unused 
if 0,disp(h),disp(e);end
