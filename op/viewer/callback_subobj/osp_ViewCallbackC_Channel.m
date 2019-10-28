function varargout=osp_ViewCallbackC_Channel(fcn,varargin)
% Set Control Callback Object, Channel Modify, in Signal-ViewerII.
%
% This function is Common-Callback-Object 
% for POTATo (ver 3.1.8 )
%
% $Id: osp_ViewCallbackC_Channel.m 393 2014-02-03 02:19:23Z katura7pro $


% == History ==
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 25-Apr-2006
%
%--------------->
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
    % Basic Information and so on.
    varargout{1} = feval(fcn, varargin{:});
    
  case 'getArgument',
    error('[P] Program Error! This Control is System Defined Function');
    
  case 'make',
    % Make GUI
    varargout{1} = make(varargin{:});
  case 'pop_Callback'
    % Callback
    pop_Callback(varargin{:});
    
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Channel';
basicInfo.fnc    ='osp_ViewCallbackC_Channel';
% File Information
basicInfo.rver   ='$Revision: 1.4 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2007/11/20 08:05:20 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'Channel'};
basicInfo.uicontrol={'popupmenu','listbox'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getDefaultCObject
data.name='Channel Popup';
data.fnc ='osp_ViewCallbackC_Channel';
data.SelectedUITYPE='popupmenu';
data.pos =[0, 0, 0.1, 0.1];
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallbackC_Channel(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj)
% Make Current Data
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'Channel';
CCD.CurDataValue = {'ch','Channel'};
CCD.handle       = []; % Update

%=====================
% Get Channel Size
%=====================
[hdata,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata); %#ok , ~, versionŒÝŠ·
chlen=size(data,2);

%=====================
% Make Uicontrol!
%=====================
pos=getPosabs(obj.pos,apos);
switch lower(obj.SelectedUITYPE),
  case 'popupmenu',
	  %--------------------------
    CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style',obj.SelectedUITYPE, ...
      'BackgroundColor',[1 1 1], ...
      'Units','normalized', ...
      'Position',pos, ...
      'Tag','CCallback_Channel', ...
      'TooltipString','Select Channel', ...
      'Callback', ...
      'osp_ViewCallbackC_Channel(''pop_Callback'',gcbo)');
    
    % Setup String
    str=cell(1,chlen);
	for idx=1:chlen
      str{idx}=['Ch ' num2str(idx)];
	end
	if curdata.ch>chlen
		curdata.ch=chlen;
	end	
    set(CCD.handle,...
      'String',str, ...
      'Value',curdata.ch);
  
  case 'listbox',
	  %--------------------------
	CCD.handle       = ...
      uicontrol(hs.figure1,...
      'Style',obj.SelectedUITYPE, ...
      'BackgroundColor',[1 1 1], ...
      'Units','normalized', ...
      'Position',pos, ...
	  'Max',2,...
      'Tag','CCallback_Channel', ...
      'TooltipString','Select Channel', ...
      'Callback', ...
      'osp_ViewCallbackC_Channel(''pop_Callback'',gcbo)');
    
    % Setup String
    str=cell(1,chlen);
    for idx=1:chlen
      str{idx}=['Ch ' num2str(idx)];
    end
	if any(curdata.ch>chlen)
		curdata.ch=chlen;
	end
    set(CCD.handle,...
      'String',str, ...
      'Value',curdata.ch);
  otherwise,
    errordlg({'====== OSP Error ====', ...
      ['Undefined Mode :: ' obj.SelectedUITYPE], ...
      ['  in ' mfilename], ...
      '======================'});
    delete(curdata.CCallback_Channel.handles);
    curdata=rmfield(curdata,'CCallback_Channel');
end
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_Callback(h)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ud=get(h,'UserData');
%================
% Update Channel!
%================
st=get(h,'Style');
switch lower(st),
  case {'popupmenu','listbox'}
    ch = get(h,'Value');
  otherwise,
    ch = 1;
end

%===================
% ReDraw : Callback!
%===================
funcStr='vdata.curdata.ch = varargin{1};';
p3_ViewCommCallback('redrawAO',ud(1:end),funcStr,ch);



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
