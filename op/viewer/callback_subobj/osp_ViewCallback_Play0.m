function varargout=osp_ViewCallback_Play0(fcn,varargin)
% Common-Callback-Object, Change TimeRange, in Signal-ViewerII.
%
% This function is Common-Callback-Object of OSP-Viewer II.
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% $Id: osp_ViewCallback_Play0.m 180 2011-05-19 09:34:28Z Katura $
%
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 05-Jun-2006


%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Play Movie (test)';
basicInfo.fnc    ='osp_ViewCallback_Play0';
% File Information
basicInfo.rver   ='$Revision: 1.4 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/04/25 01:59:44 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_Play0'};
basicInfo.uicontrol={'menu'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectBlockChannel.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=varargin{1};
data.name='Play Movie (test)';
data.fnc ='osp_ViewCallback_Play0';
data.SelectedUITYPE='menu';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_Play0(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj,newflag),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%========================
% Load TimeRange
%========================
size=osp_LayoutViewerTool('getCurrentSize',curdata);

%=====================
% Waring : Overwrite
%=====================
if isfield(curdata,'CCallback_Play0'),
  warndlg({'========= OSP Warning =========', ...
    ' Common Time-Range Callback : Over-Write', ...
    '  Confine your Layout.', ...
    '==============================='});
end

%---------------------
% (Need Time Axes now)
%---------------------
%---------------------
% (Need Time Axes now)
%---------------------
flg_old_timeslider=false;
if isfield(curdata,'Callback_2DImageTime') && ...
    isfield(curdata.Callback_2DImageTime,'handles') && ...
    ishandle(curdata.Callback_2DImageTime.handles)
  flg_old_timeslider=true;
end
% current Time Slider
flg_timeslider=[];
if isfield(curdata,'CommonCallbackData')
  for id1=1:length(curdata.CommonCallbackData)
    CCD=curdata.CommonCallbackData{id1};
    if strcmpi(CCD.Name,'TimePoint')
      flg_timeslider(end+1)=id1;
    end
  end
end
if flg_old_timeslider==false && isempty(flg_timeslider)
  % No Time-Slider
  return;
end


%===================
% Make Control GUI
%===================
switch lower(obj.SelectedUITYPE),
  case 'menu',
    % === Menu ===
    if flg_old_timeslider
      % old time-slider
      ud=get(curdata.Callback_2DImageTime.handles, 'UserData');
      ud=ud{1};
      ud(end+1)=hs.figure1;
      %set(ud(1:3),'Visible','off');
      curdata.CCallback_Play0.handles=...
        uimenu(curdata.menu_callback,'Label','&Play0', ...
        'TAG', 'CCallback_Play0', ...
        'UserData',ud, ...
        'Callback', ...
        ['osp_ViewCallback_Play0(''ExeCallback'','...
        'gcbo,[],guidata(gcbo))']);
    end
    
    % --> new slider
    hh=[];
    for idx=1:length(flg_timeslider)
      hh(end+1)=...
        curdata.CommonCallbackData{flg_timeslider(idx)}.handle;
    end
    if ~isempty(hh)
      curdata.CCallback_save_avi0.handles=...
        uimenu(curdata.menu_callback,'Label','&Play1', ...
        'TAG', 'CCallback_Play1', ...
        'UserData',hh, ...
        'Callback', ...
        'osp_ViewCallback_Play0(''ExeCallback1'',gcbo,guidata(gcbo))');
    end
    
  otherwise,
    errordlg({'====== OSP Error ====', ...
      ['Undefined Mode :: ' obj.SelectedUITYPE], ...
      ['  in ' mfilename], ...
      '======================='});
end % End Make Control GUI

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,eventdata,handles)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================
% Update Channel!
%================
% -- Default Setting ---
hs=get(hObject,'UserData');
databkup.hs =hs;
databkup.cb =get(hObject,'Callback');
t=1;
tmax = get(hs(1),'Max');
tbak = get(hs(1),'Value');

% === Makeing Stop Button ===
% Stop-Button(Dumy)
sbh=uicontrol(hs(end),'Visible','off');
set(hObject, ...
  'UserData',sbh,...
  'Callback',...
  'sbh=get(gcbo,''UserData'');delete(sbh);');

% hObject : Menu
set(hObject,'Label', 'Stop');


% === Play Start ===
for idx=t:10:tmax,
  set(hs(1),'Value',idx);
  osp_ViewCallback_2DImageTime('sld_time_Callback',hs(1),[],handles);
  drawnow;
  if ~ishandle(sbh),break;end
end
if ishandle(sbh),delete(sbh);end
set(hs(1),'Value',tbak);
set(hObject,'UserData',databkup.hs, 'Callback',databkup.cb);
% hObject : Menu
set(hObject,'Label', 'Play0');
osp_ViewCallback_2DImageTime('sld_time_Callback',hs(1),[],handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback1(hObject,handles)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================
% Update Channel!
%================
% -- Default Setting ---
hs=get(hObject,'UserData');
databkup.hs =hs;
databkup.cb =get(hObject,'Callback');
databkup.lbl=get(hObject,'Label');
t=1;
tmax = get(hs(1),'Max');
tbak = ones(1,length(hs(1)));
for idx=1:length(hs)
  tbak(idx)=get(hs(idx),'Value');
end

tmp=get(hs,'SliderStep')*tmax;
tinterval=tmp(1);

% === Makeing Stop Button ===
% Stop-Button(Dumy)
set(hs,'Visible','off');
% hObject : Menu
sbh=uicontrol(handles.figure1,'Visible','off');
set(hObject, ...
  'Label', 'Stop',...
  'UserData',sbh,...
  'Callback',...
  'sbh=get(gcbo,''UserData'');delete(sbh);');


% === Play Start ===
for idx=t:tinterval:tmax,
  for id2=1:length(hs)
    try
      set(hs(id2),'Value',idx);
      LAYOUT_CCO_TimePiont('sld_time_Callback',hs(id2));
    catch
    end
  end
  drawnow;
  if ~ishandle(sbh),break;end
end
if ishandle(sbh),delete(sbh);end

set(hObject,...
  'UserData',databkup.hs, 'Callback',databkup.cb,'Label',databkup.lbl);
for idx=1:length(hs)
  if ~ishandle(hs(idx)),continue;end
  set(hs(idx),'Visible','on',...
    'Value',tbak(idx));
  LAYOUT_CCO_TimePiont('sld_time_Callback',hs(idx));
end
