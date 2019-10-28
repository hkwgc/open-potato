function varargout=osp_ViewAxesObj_EvalScript(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: osp_ViewAxesObj_EvalScript.m 297 2012-11-14 07:25:01Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History =-
% 2007.10.01 : Bugfix for MATLAB 6.5.1
% 2007.11.12 : Add Multi-Script (Meeting on 08-Nov-2007)

%====================
% In no input : Help
%====================
if nargin==0,  OspHelp(mfilename); return; end

%====================
% Swhich by Function
%====================
switch fnc
  case 'createBasicInfo',
    % Basic Information
    varargout{1}=createBasicInfo;
  case 'getArgument',
    varargout{1}=getArgument(varargin{:});
  case 'drawstr',
    varargout{1} = drawstr(varargin{:});
  case 'draw'
    % Callback for Common:
    varargout{1} = draw(varargin{:});
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fnc, varargin{:});
    else
      feval(fnc, varargin{:});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='Script';
% --> @ funciton is difficult to save ..
%       R13<->R14 is different.
info.fnc     ='osp_ViewAxesObj_EvalScript';
info.ver  = 1.00;
info.ccb     = 'all';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data)
% Set up : 2D-Image Axes-Object Data
%          (or change )
%
% Open Initial value setting GUI
bi=createBasicInfo;
data.str = bi.MODENAME;
data.fnc = bi.fnc;
data.ver = bi.ver;
op.Resize='on';
op.WindowStyle='normal';
op.Interpreter='none';

def={'',''};
if isfield(data,'script')
  def{1}=char(data.script);
end
if isfield(data,'script_Draw')
  def{2}=char(data.script_Draw);
end
s=inputdlg(...
  {'Script for making the figure (only once)',...
  'Script for re-drawing the figure'},...
  'Evaluate Script',10,def,op);
if isempty(s),data=[];return;end
data.script      = cellstr(s{1});
data.script_Draw = cellstr(s{2});
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
str=['eval([obj{idx}.script{:}]);',...
  'osp_ViewAxesObj_EvalScript(''draw'',' ...
  'h.axes, curdata, obj{idx});'];
if 0,disp(varargin);end
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
% This Script is for ..

% Default Output Data
hout.h=[];
hout.tag={};
% New Type??
if ~isfield(objdata,'script_Draw'),return;end

% dumy data to use Evaluate String
obj={objdata};idx=1; if 0,disp(obj{idx});end
h.axes=gca0;
set(curdata.gcf,'CurrentAxes',gca0);
eval([objdata.script_Draw{:}]);

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_Evaluate_Script';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', hout.h, myName, gca0, curdata, objdata, ObjectID);
  return;
else
  p3_ViewCommCallback('CheckIn', hout.h, myName, gca0, curdata, objdata);
end

%=========================================
% Special Callback Setting
%=========================================
% curdata.kind
udadd.axes     = gca0;
udadd.name     = myName;
x=getappdata(curdata.gcf,myName);
udadd.ObjectID = length(x);
%  X - Range
if isfield(curdata,'Callback_XRange') && ...
    isfield(curdata.Callback_XRange,'handles') && ...
    ishandle(curdata.Callback_XRange.handles),
  % See also osp_view
  hx            = curdata.Callback_XRange.handles;
  ud=get(hx,'UserData');
  ud{end+1}=udadd;
  set(hx,'UserData',ud);
end

%  X - Range
if isfield(curdata,'Callback_XRange2') && ...
    isfield(curdata.Callback_XRange2,'handles') && ...
    ishandle(curdata.Callback_XRange2.handles),
  % See also osp_view
  hx2            = curdata.Callback_XRange2.handles;
  ud=get(hx2,'UserData');
  ud{end+1}=udadd;
  set(hx2,'UserData',ud);
end

