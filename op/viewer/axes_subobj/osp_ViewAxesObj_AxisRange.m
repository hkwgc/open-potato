function varargout=osp_ViewAxesObj_AxisRange(fnc,varargin)
% Axes Plugin Data : Change Axis-X-Range,Y-Range
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Axis-Change';
  info.fnc     ='osp_ViewAxesObj_AxisRange';
%  data.ver  = 1.00;
% info.ccb     = {'Data',...
%   'DataKind'};
info.ccb ='all';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
  data.str = 'Axis-Change';
  data.fnc = 'osp_ViewAxesObj_AxisRange';
  data.ver = 1.00;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
str='osp_ViewAxesObj_AxisRange(''setCallback'',h.axes,curdata)';
%str='osp_ViewAxesObj_AxisRange(''draw'',h.axes,curdata,obj{idx})';
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
%hout=setCallback(gca0, curdata);
% Update is needless!! 
hout=[];
%osp_ViewCallback_XAxisRange2('xaxisResize_Callback',curdata.gcf);

function h=setCallback(gca0, curdata),
% curdata.time
% curdata.kind
flg_usecom=false; % User Common-Callback?
udadd.axes   = gca0; % Axes
udadd.default=axis;  % Default Axis

% ==============================
% ==== Callback Setting List ===
% ==============================
%------------------------
%  X - Range
%------------------------
if isfield(curdata,'Callback_XRange') && ...
      isfield(curdata.Callback_XRange,'handles') && ...
      ishandle(curdata.Callback_XRange.handles),
  % See also osp_view
  flg_usecom=true;
  h             = curdata.Callback_XRange.handles;
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end
h=[];

%------------------------
%  X - Range 2
%------------------------
if isfield(curdata,'Callback_XRange2') && ...
    isfield(curdata.Callback_XRange2,'handles'),
  % See also osp_view
  flg_usecom=true;
  for idx=1:length(curdata.Callback_XRange2.handles),
    h             = curdata.Callback_XRange2.handles(idx);
    if ~ishandle(h), continue; end
    osp_ViewCallback_XAxisRange2('setUserData',h,udadd);
  end
end
h=[];

%------------------------
%  Y - Range
%------------------------
if isfield(curdata,'Callback_YRange') && ...
      isfield(curdata.Callback_YRange,'handles') && ...
      ishandle(curdata.Callback_YRange.handles),
  % See also osp_view
  flg_usecom=true;
  h             = curdata.Callback_YRange.handles;
  ud=get(h,'UserData');
  ud{end+1}=udadd;
  set(h,'UserData',ud);
end
h=[];

%==================================
%=      Common-Data Setting       =
%==================================
myName='AXES_AXIS_CHANGE';
if flg_usecom 
  p3_ViewCommCallback('CheckIn', ...
    [], myName, ...
    gca0, curdata, getArgument);
end

