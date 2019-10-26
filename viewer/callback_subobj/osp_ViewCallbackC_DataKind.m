function varargout=osp_ViewCallbackC_DataKind(fcn,varargin)
% Control Callback Object, Select Data-Kind, in Signal-ViewerII.
%
% This function is Common-Callback-Object
% for POTATo (ver 3.1.8 )
%
% $Id: osp_ViewCallbackC_DataKind.m 298 2012-11-15 08:58:23Z Katura $


% == History ==
%
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 05-Jun-2006
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
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Data Kind';
basicInfo.fnc    ='osp_ViewCallbackC_DataKind';
% File Information
basicInfo.rver   ='$Revision: 1.8 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/26 13:29:15 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'Kind'};
basicInfo.uicontrol={'listbox','popupmenu',...
  'menu','edit'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getDefaultCObject
data.name='Data Kind';
data.fnc ='osp_ViewCallbackC_DataKind';
data.SelectedUITYPE='popupmenu';
data.pos =[0, 0, 0.1, 0.1];
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallbackC_DataKind(''make'',handles, abspos,' ...
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
CCD.Name         = 'Kind';
CCD.CurDataValue = {'kind','Kind','DataKind','TimePoint'};
CCD.handle       = []; % Update

%========================
% Load Kind Information
%========================
[hdata,data]=osp_LayoutViewerTool('getCurrentDataRaw',hs.figure1,curdata);
kindlen = size(data,ndims(data));
if kindlen<=1,
  warndlg({'============== P3 Warning ==============', ...
    '  Too few Data-Kind', ...
    '  to make Data-Kind Select Control GUI', ...
    '========================================='});
  return;
end

%=====================
% Make Uicontrol!
%=====================
if isfield(obj,'pos'),
  pos=getPosabs(obj.pos,apos); % Position Transfer
end
cl0=get(hs.figure1,'Color'); % Plot Color
% Forground Color
if sum(cl0(:))<1,
  cll=[1 1 1];
else
  cll=[0 0 0];
end

% --> For String
kindtag = hdata.TAGs.DataTag;
for idx=length(kindtag)+1:kindlen
  kindtag{idx}='Undefined Kind';
end
% --> For initial Value
kindval=curdata.kind;
kindval(kindval>kindlen)=[];
if isempty(kindval),kindval=1;end

%===================
% Make Control GUI
%===================
switch lower(obj.SelectedUITYPE),
  case 'listbox',
    % === List Box ===
    CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style','listbox', ...
      'BackgroundColor',cl0, ...
      'ForegroundColor',cll,...
      'Units','normalized', ...
      'Position',pos, ...
      'Max',10, ...
      'String',kindtag, ...
      'Value', kindval, ...
      'Tag','CCallback_DataKind', ...
      'TooltipString','Data-Kind Listbox', ...
      'Callback', ...
      'osp_ViewCallbackC_DataKind(''ExeCallback'',gcbo,''val'')');
      

  case 'popupmenu',
    % === PopupMenu ===
    CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style','popupmenu', ...
      'BackgroundColor',cl0, ...
      'ForegroundColor',cll,...
      'Units','normalized', ...
      'Position',pos, ...
      'Max',10, ...
      'String',kindtag, ...
      'Value', kindval(1), ...
      'Tag','CCallback_DataKind', ...
      'TooltipString','Data-Kind Popup Menu', ...
      'Callback', ...
      'osp_ViewCallbackC_DataKind(''ExeCallback'',gcbo,''val'')');

  case 'menu',
    % === Menu ===
    if isfield(curdata,'menu_callback'),
      ud1.h=...
        uimenu(curdata.menu_callback,'Label','Data &Kind', ...
        'TAG', 'CCallback_DataKind');
      ud1.h2=[];
      CCD.handle       = ud1.h;
      for idx=1:kindlen,
        % User Data=
        ud1.h2(idx)=uimenu(ud1.h,'Label',...
          ['&' num2str(idx) kindtag{idx}], ...
          'Callback', ...
          'osp_ViewCallbackC_DataKind(''ExeCallback'',gcbo,''parent'')');
      end
      set(ud1.h2(kindval),'Checked','on');
      set(ud1.h,'UserData',{ud1});
    end

  case 'edit',
    % === edit ===
      CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style','edit', ...
      'BackgroundColor',cl0, ...
      'Units','normalized', ...
      'Position',pos, ...
      'Max',10, ...
      'String',num2str(kindval), ...
      'Tag','CCallback_DataKind', ...
      'TooltipString','Data-Kind Edit-Text', ...
      'Callback', ...
      'osp_ViewCallbackC_DataKind(''ExeCallback'',gcbo,''string'')');

  otherwise,
    errordlg({'====== OSP Error ====', ...
      ['Undefined Mode :: ' obj.SelectedUITYPE], ...
      ['  in ' mfilename], ...
      '======================='});
    delete(curdata.CCallback_DataKindl.handles);
    curdata=rmfield(curdata,'CCallback_DataKind');
end % End Make Control GUI

if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,type)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================
% Update Channel!
%================
% -- Default Setting ---
kind = 1;idx0 = 1;
% Get Kind and Start Index of UserData
%  Switch :: Defined in Callback :: Style
switch type,
  case 'val',
    % Kind == Value
    kind = get(hObject,'Value');
  case 'string',
    % Kind == String
    try
      kind = str2num(get(hObject,'String'));
      set(hObject,'ForegroundColor',[0 0 0]);
    catch
      errordlg({'========== P3 Error ===========', ...
        ' Edit-Text Callback Kind : Input Kind-Number', ...
        '================================='});
      set(hObject,'ForegroundColor',[1 0 0]);
      return;
    end
  case 'parent',
    % Kind : Parent
    c=get(hObject,'Checked');
    if strcmpi(c,'on')
      c='off';
    else
      c='on';
    end
    set(hObject,'Checked',c);
    % ==> Convert hObject :: Parent
    hObject=get(hObject,'Parent');
    ud=get(hObject,'UserData');
    ud1=ud{1};
    idx0=2;
    c=get(ud1.h2,'Checked');
    kind= find(strcmpi(c,'on'));
    kind=kind(:)';
end

%===================
% ReDraw : Callback!
%===================
ud=get(hObject,'UserData');

funcStr='vdata.curdata.kind = varargin{1};';
ud=p3_ViewCommCallback('redrawAO',ud(idx0:end),funcStr,kind);

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
