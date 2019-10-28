function varargout=osp_ViewAxesObj_TimeSeries(fnc,varargin)
% Control Function to Draw "Time-Seriese" in Viewer II
%
% osp_ViewAxesObj_TimeSeries is "View-Axes-Object",
% so osp_ViewAxesObj_TimeSeries is based on the rule.
%
% osp_ViewAxesObj_TimeSeries use "Common-Callback", 
% so osp_ViewAxesObj_TimeSeries is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax : 
%   osp_ViewAxesObj_TimeSeries
%     Open Help of the Function for user.
%
% === Other  ===
% Syntax : 
% varargout=osp_ViewAxesObj_TimeSeries(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_TimeSeries.m 298 2012-11-15 08:58:23Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == Warning !! ==
% When you want to edit this function,
%  you must be based on View-Axes-Object rules.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No argument : Help : (Defined in View-Axes-Object )
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
  info.MODENAME='Time Series';
  info.fnc     ='osp_ViewAxesObj_TimeSeries';

  % --> All Change <-- 
  %  More ...
  % Useing Common-Callback-Object
  info.ccb     = {'Channel', ...
		  'Kind', ...
		  'TimeRange'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
% --- for change ---
  if length(varargin)>=1,
    data=varargin{1};
  end
  data.str = 'Time Series';
  data.fnc = 'osp_ViewAxesObj_TimeSeries';
  data.ver = 1.00;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% DrawStr : 
%
% See also osp_ViewAxesObject_PlotTest/getArgument,
%          ViweGroupAxes/exe,
%          p3_ViewCommCallback.
str=['osp_ViewAxesObj_TimeSeries(''draw'', ', ...
     'h.axes ,curdata, obj{idx})'];
return;

function h=draw(gca0, curdata,obj, ObjectID)
% Draw / Redraw Line-Axes-Object
%
% GCA0      : The Draw Axeis( Usually Current Axis);
% CURDATA   : Current Data in Drawing.
%             Defined in ViewerII -> 
%             rf). osp_LayoutViewer
% OBJ       : This Axes-Object.
%             Made in subfunction getArgument.
% OBJECT_ID : When draw   : There is no ObjectID.
%             When Redraw : INDEX of Redraw Object.
%             This variable for CommonCallabck.

% Get Current Data
axes(gca0);f=gcf;

% Get TimeSeriesSetting
tss= osp_vao_TimeSereiseSetting(f,curdata);
if isempty(tss), return; end

hdata=osp_LayoutViewerTool('getCurrentDataRaw',f,curdata);
% :: Plot Data ::
data = tss.TimeSeriesData{tss.Selected}.Data;

%--- Axes Setting --
% Axis Setting
if 0,
  xlabel('Time');
  ylabel(tss.TimeSeriesName{tss.Selected});
end

%------------------
% Time Range Change
%------------------
unit=1000/hdata.samplingperiod;
t0=1:size(data,tss.TimeSeriesData{tss.Selected}.TimeAxis);
t=(t0 -1)/unit;
% Time Range Require!
of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];
if isempty(tss.DataFunction), return; end
data = eval(tss.DataFunction);
if isempty(data), return; end

%==================================
% Draw
%==================================
h.h=plot(t,data);
h.tag=tss.TimeSeriesName(tss.Selected);
set(h.h(end), ...
    'TAG', h.tag{end}, ...
    tss.LinePropList{:});

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_PlotTest_ObjectData';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
		       h.h, myName, ...
		       gca0, curdata, obj, ObjectID);
else,
  p3_ViewCommCallback('CheckIn', ...
		       h.h, myName, ...
		       gca0, curdata, obj);
end
