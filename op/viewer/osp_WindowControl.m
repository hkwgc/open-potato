function varargout = osp_WindowControl(fnc,varargin)
% Set WindowButtonDownFcn/WindowButtonMotionFcn/WindowButtonUpFcn.
%  For Signal-Viewer II


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2006.06.18
% $Id: osp_WindowControl.m 180 2011-05-19 09:34:28Z Katura $

% Help When there is no Argument.
if nargin==0,
  % use eval to avoid compile error
  eval(['OspHelp' mfilename]);return;
end

% Launch Box
if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
        feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common Simple-Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function s=info
% Information of This Fucntion
%================================
s={mfilename};
s{end+1}='   $Revision: 1.1 $';
s{end+1}='   $Date: 2006/06/20 14:21:44 $';

%=============================================
function h=myerrordlg(ErrorString, DlgName,varargin)
% Wrapper of Error-Dialog ::: In this Function
%=============================================
s=info;
if nargin<1,
  ErrorString='Error : No Error Message...';
end
if nargin<2
  DlgName=['Error : ' mfilename];
end
msg={'=========== OSP Window Control ===========', ...
     s{:}};
if iscell(ErrorString)
  msg= {msg{:} ,ErrorString{:}};
else,
  msg{end+1}=ErrorString;
end
msg{end+1}='==========================================';
if nargin<=2,
  h=errordlg(msg,DlgName);
else,
  h=errordlg(msg,DlgName,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function init(figh,mode,varargin)
% Figure Information's
%================================
%-----------------
% Argument Check
%-----------------
msg=nargchk(1,10,nargin);
if ~isempty(msg), myerrordlg(msg);return; end
if nargin<2,mode=1;end

% 1st argument is figure handle ?
if ~ishandle(figh) || ...
      ~strcmpi(get(figh,'Type'),'figure');
  msg={' Error : 1st Argument ', ...
       '         Not Figure Handle'};
  myerrordlg(msg);
  return; 
end

%------------------
% Common Operation
%------------------
set(figh,'DoubleBuffer','on');

switch mode,
 otherwise,
  % On/Off : NoControl
  % Reset Window Control Id
  set(figh,'WindowButtonUpFcn',...
	   'set(gcbf,''WindowButtonMotionFcn'','''');');
  set(figh,'WindowButtonMotionFcn', '');
%  set(figh,'WindowButtonDownFcn',...
%	   ['wcid=getappdata(gcbf,''WINDOW_CNTRL_ID'');', ...
%	    'if isempty(wcid),return;end;', ...
%	    'osp_WindowControl', ...
%	    '(''ButtonDownFcn'', gcbf,wcid,', ...
%	    'guihandles(guidata))']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Default Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function AddMotionFcn(h,wcid,handles),
%================================

%================================
function ButtonDownFcn(h,wcid,handles),
% osp Button Down Function (for Default Mode)
%
%================================

%================================
function ButtonMotionFcn(h,wcid,handles),
% osp Button Motion Function (for Default Mode)
%
%================================

  

