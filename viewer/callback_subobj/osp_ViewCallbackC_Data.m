function varargout=osp_ViewCallbackC_Data(fcn,varargin)
% Set Control Callback Object, Data Modify, in Signal-ViewerII.
%
% This function is Common-Callback-Object
% for POTATo (ver 3.1.8 )
%
% $Id: osp_ViewCallbackC_Data.m 298 2012-11-15 08:58:23Z Katura $

% == History ==
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 25-Apr-2006
%
%------------->
% 2007.11.12
%  Modify for Common-Control Design-20071108


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Help for noinput
if nargin==0,  fcn='help';end

%====================
% Swhich by Function
%====================
switch fcn
  case {'help','Help','HELP'},
    OspHelp(mfilename);
  case {'createBasicInfo','getDefaultCObject','drawstr'},
    % Basic Information
    varargout{1} = feval(fcn, varargin{:});
  case 'getArgument',
    error('[P] Program Error! This Control is System Defined Function');
  case 'make',
    varargout{1} = make(varargin{:});
  case 'ExeCallback'
    ExeCallback(varargin{:});
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
%===============================
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Data Popup'
%       Myfunction Name
%         'vcallback_DataPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Select Data';
basicInfo.fnc    ='osp_ViewCallbackC_Data';
% File Information
basicInfo.rver   ='$Revision: 1.6 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2007/11/20 08:05:21 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'Data'};
basicInfo.uicontrol={'menu', 'pushbutton'};
return;

function data=getDefaultCObject
% Default Argument of ..
data.name='Data Select';
data.fnc ='osp_ViewCallbackC_Data';
data.SelectedUITYPE='menu';
data.pos = [0,  0,  0.1,  0.1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallbackC_Data(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
if 0,disp(varargin{1});end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj)
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'Data';
CCD.CurDataValue = {'region','cid0','bid0','Data'};
CCD.handle       = []; % Update

%=====================
% Make Uicontrol!
%=====================
switch lower(obj.SelectedUITYPE),
  case 'pushbutton',
    pos=getPosabs(obj.pos,apos);

    %=====================
    % Make Push-Button
    %=====================
    CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style',obj.SelectedUITYPE, ...
      'String','Data Change', ...
      'BackgroundColor',[1 1 1], ...
      'Units','normalized', ...
      'Position',pos, ...
      'Tag','CCallback_Data', ...
      'TooltipString','Select Data', ...
      'Callback', ...
      ['osp_ViewCallbackC_Data(''ExeCallback'','...
      'gcbo,guidata(gcbo))']);

  case 'menu',
    % === Menu ===
    if isfield(curdata,'menu_callback'),
      CCD.handle       = ...
        uimenu(curdata.menu_callback,'Label','Select &Data', ...
        'TAG', 'CCallback_Data', ...
        'Callback', ...
        ['osp_ViewCallbackC_Data(''ExeCallback'','...
        'gcbo,guidata(gcbo))']);
    else
      warndlg('No Menu to Add');
    end

  otherwise,
    errordlg('No Mode to Make CurrentData');
end
set(CCD.handle,'UserData',{curdata});
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,handles)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(hObject,'UserData');
curdata=ud{1};
figh=handles.figure1;

%==============================
% get Data Current Situation
%==============================
bhdata=getappdata(figh,'BHDATA');
if isempty(bhdata),
  region_str={'Continuous'};
else
  region_str={'Continuous','Block'};
end
region_id=find(strcmpi(curdata.region,region_str));
if isempty(region_id),
  warndlg({'OSP Common View-Callback Object : Data', ...
    'Current Data -> ', ...
    [' Undefined Region : ' curdata.region], ...
    '  Use Continuous for Default..'});
  region_id=1;
end


%==============================
% Open Select Data Figure
%==============================
fh=figure('MenuBar','none', 'Units','Characters');
setappdata(fh, 'SignalViewII_Fig',figh);

set(fh,'Units','characters','Visible','off');
p=get(fh,'Position');
p(3:4)=[80,10];set(fh,'Position',p);
set(fh,'Units','Normalized');
set(fh,'DeleteFcn','warndlg(''Closed with no action'');');
% -- Region Popup --
ph = uicontrol('Style','popupmenu', ...
  'Units','Normalized', ...
  'BackgroundColor',[1 1 1], ...
  'Position',[10,70,60,20]/ 100, ...
  'String', region_str, ...
  'Value', region_id, ...
  'Callback', ...
  ['vl=get(gcbo,''Value'');', ...
  'hx=getappdata(gcbf,''MyHandle'');', ...
  'for idx=1:2,', ...
  '  if idx==vl,' ...
  '    set(hx{idx},''Visible'',''on'');', ...
  '  else,', ...
  '    set(hx{idx},''Visible'',''off'');', ...
  '  end,', ...
  'end']);

% -- Continous --
str={};
for idx=1:curdata.cidmax,
  str{idx}=['Data IDX ' num2str(idx)];
end
ch = uicontrol('Style','popupmenu', ...
  'Units','Normalized', ...
  'BackgroundColor',[1 1 1], ...
  'Position',[10,50,70,20]/ 100, ...
  'String', str, ...
  'Value', curdata.cid0, ...
  'Visible', 'on');
hx{1}=ch;
% -- Block --
str={};
for idx=1:curdata.bidmax,
  str{idx}=['Block IDX ' num2str(idx)];
end
bh = uicontrol('Style','popupmenu', ...
  'Units','Normalized', ...
  'BackgroundColor',[1 1 1], ...
  'Position',[10,50,70,20]/ 100, ...
  'String', str, ...
  'Value', curdata.bid0,...
  'Visible', 'on');
hx{2}=bh;
setappdata(fh,'MyHandle',hx);
%  set(hx{region_id},'Visible', 'on');
if region_id==1
  set(bh,'Visible','off');
else
  set(ch,'Visible','off');
end

% OK button
uicontrol('Units','Normalized', ...
  'Position',[30,10,20,20]/ 100, ...
  'BackgroundColor',[1 1 1], ...
  'String', 'OK', ...
  'Callback', ...
  ['set(gcbf,''DeleteFcn'','''');'...
  'set(gcbf,''UserData'',true);']);
uicontrol('Units','Normalized', ...
  'Position',[60,10,20,20]/ 100, ...
  'BackgroundColor',[1 1 1], ...
  'String', 'Cancel', ...
  'Callback', ...
  ['set(gcbf,''DeleteFcn'','''');'...
  'set(gcbf,''UserData'',false);']);
set(fh,'Visible','on');
waitfor(fh,'DeleteFcn','');

%=====================
% Get GUI Setting
%=====================
% Cancel...
if ~ishandle(fh),return; end
flg = get(fh,'UserData');
% Cancel
if ~flg, delete(fh);return; end

%----------------------
% Getting Reuslt of GUI
%-----------------------
curdata.region=region_str{get(ph,'Value')};
curdata.cid0=get(ch,'Value');
curdata.bid0=get(bh,'Value');
% !! Update current Curdata !! (Local)
ud{1}=curdata;
set(hObject,'UserData',ud);
delete(fh);

set(0,'CurrentFigure',figh)
%===================
% ReDraw : Callback!
%===================
for idx=2:length(ud),
  % Get Data
  data = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  % Data Update
  data.curdata.region = curdata.region;
  data.curdata.cid0  = curdata.cid0;
  data.curdata.bid0  = curdata.bid0;

  % Delete handle
  delete(data.handle(ishghandle(data.handle)));
  for idxh = 1:length(data.handle),
    try
      if ishandle(data.handle(idxh)),
        delete(data.handle(idxh));
      end
    catch
      warning(lasterr);
    end % Try - Catch
  end
  
  % Evaluate (Draw)
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end % Try - Catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
