function varargout=LAYOUT_AO_TimeSeriesPlot(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: LAYOUT_AO_TimeSeriesPlot.m 298 2012-11-15 08:58:23Z Katura $

% == History =-
% 2006.10.18 :: Change Colormap by menu.
%  Disable 'v_colormap' field  ;; Property


% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch fnc
  case {'help','Help'}
    OspHelp(mfilenam);
  case 'createBasicInfo'
    varargout{1}=createBasicInfo;
  case 'getArgument'
    varargout{1}=getArgument(varargin{1});
  otherwise
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
info.MODENAME='hdata.TimeSeries Plot';
info.fnc     ='LAYOUT_AO_TimeSeriesPlot';
info.ver     = 1.0;
info.ccb     = {'Data','DataKind','TimePoint0','ImageProp','TimeSeriesSelecter'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data)
% Set up : 2D-Image Axes-Object Data

info = createBasicInfo;
% Open Initial value setting GUI
data.str = info.MODENAME;
data.fnc = info.fnc;
data.ver = info.ver;
if ~isfield(data,'region')
  data.region ='auto';
end
if data.ver>1.1
  return;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok 
str=[...
  'LAYOUT_AO_TimeSeriesPlot(''draw'', h.axes,', ...
  ' curdata, obj{idx})'];
return;

%==================================================
function h=draw(gca0, curdata, obj, ObjectID)

h=[];

if ~isfield(curdata,'TimeSeriesSelecter'), return;end

try
  if isfield(curdata,'gcf'),
    set(curdata.gcf,'CurrentAxes',gca0);
  else
    set(gcbf,'CurrentAxes',gca0);
  end
catch
  axes(gca0);
end

[hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);
clear data;
TS=curdata.TimeSeriesSelecter;
eval(sprintf('d=hdata.TimeSeries.%s;',TS.TSstr{TS.ID}));
x=1:length(d);
x=x.*hdata.samplingperiod/1000;
h.h=plot(x,d,'k');

%==================================
%=      Common-Data Setting       =
%==================================
myName='LAYOUT_AO_TimeSeriesPlot_ObjectData';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
    h.h, myName, ...
    gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', ...
    h.h, myName, ...
    gca0, curdata, obj);
end




