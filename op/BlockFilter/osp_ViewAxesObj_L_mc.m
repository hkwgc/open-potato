function varargout=osp_ViewAxesObj_L_mc(fnc,varargin)
% Axes Plugin Object : Plot Motion Check Data
% 
% osp_ViewAxesObj_L_mc is "View Axes Object"
%   Callback : Common-Callback


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2006.04.05
% $Id: osp_ViewAxesObj_L_mc.m 298 2012-11-15 08:58:23Z Katura $

% Rivision 1.3 :
%    Common - Call back Mod -


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
  info.MODENAME='MotionCheck';
  info.fnc     ='osp_ViewAxesObj_L_mc';
  info.ccb ={'Channel','TimeRange'};
%  data.ver  = 1.00;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
% --- for change ---
% --> Never Used <--
  data.str = 'Motion Check Object(Special AxesObject for MC) !';
  data.fnc = 'osp_ViewAxesObj_L_mc';
  data.ver = 1.30;
  data.data='Continuous';
  data.dcoption='HB data';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% String to Draw This-Axes-Object
%
% See also osp_ViewAxesObject_PlotTest/getArgument,
%          ViweGroupAxes/exe,
%          p3_ViewCommCallback.
str=['osp_ViewAxesObj_L_mc(''draw'', ', ...
     'h.axes, curdata, obj{idx})'];
return;

function h=draw(gca0,curdata,obj,ObjectID)
% Draw / Redraw Motion-Check Axes-Object
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

% --> Line Property <---
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  linepropflag=true;
else,
  linepropflag=false;
end
% Default Color
a=max(curdata.kind(:));
if a<10; a=10;end
dcol=hot(a);
% Original - Color
dcol(1:3,:)=[1, 0, 0; ...
	     0, 0, 1; ...
	     0, 0, 0];
% Check Data - Color
dcol2= dcol + 0.3;
dcol2(find(dcol2>1))=1;
% Motion Check Color
dcol3= dcol - 0.3;
dcol3(find(dcol3<0))=0;
dcol3(3,:) = [.5, .5, .2];

%=================
% Makke Plot Data
%=================
[hdata,data]=getCurrentData(gcf);
unit = 1000/hdata.samplingperiod;
% Axis Setting
if 0,
  xlabel('time [sec]');
  ylabel('HB data');
end

% Time Check
t0=1:size(data,1);
t=(t0 -1)*hdata.samplingperiod/1000;
t=t(:)';

% Plot Data
data = data(t0,:,:);

%==================================
% Plot
%==================================
h.h=[];
fhs=guihandles(gcf);
if isfield(fhs,'edt_Kind'),
    kind=get(fhs.edt_Kind,'UserData');
else,
    kind=curdata.kind;
end
kind=kind(:)';
ch=curdata.ch;
%hdata.Result.MC.CheckData
%hdata.Result.MC.FlagData
%hdata.flag
% Kind Loop
for idx=1:length(kind),
  akind=kind(idx);
  tg=hdata.TAGs.DataTag{akind};
  % Original 
  h.h(end+1)=plot(t,data(t0,ch,akind));
  set(h.h(end), ...
      'Color',dcol(akind,:), ...
      'TAG', tg);
  % Check Data
  h.h(end+1)=plot(t,hdata.Result.MC.CheckData{idx}(t0,ch));
  set(h.h(end), ...
      'Color',dcol2(akind,:), ...
      'TAG', [tg ' Filtered Data']);
  % Error Data
  tmp=hdata.Result.MC.FlagData{idx};
  tidx=find(tmp(:,ch)==1);
  if ~isempty(tidx),
      h.h(end+1)= ...
          plot(t(tidx),hdata.Result.MC.CheckData{idx}(tidx,ch));
      set(h.h(end), ...
          'LineStyle', 'none', ...
          'TAG', [tg ' Motion Poiont'], ...
          'Marker','x', ...
          'MarkerEdgeColor',dcol3(akind,:), ...
          'MarkerSize',26);
  end
end

axis tight

%==================================
%=      Common-Data Setting       =
%==================================
myName='AXES_MotionCheck';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
		       h.h, myName, ...
		       gca0, curdata, obj, ObjectID);
  return;
else,
  ObjectID=p3_ViewCommCallback('CheckIn', ...
				h.h, myName, ...
				gca0, curdata, obj);
end

% ==============================
% ==== Callback Setting List ===
% ==============================
%------------------------
%  Re MotionCheck
%------------------------
if isfield(curdata,'psb_mc_view') && ...
      ishandle(curdata.psb_mc_view),
  % See also osp_view
  %ucadd.handle  = h.h;
  udadd.ObjectID= ObjectID;
  udadd.axes=gca0;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_L_mc(' ...
		'''motioncheck'',ud{idx});'];
  ud=get(curdata.psb_mc_view,'UserData');
  ud{end+1}=udadd;
  set(curdata.psb_mc_view,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================
function ud=motioncheck(ud)
% Channel Change
% Callback of Channel Popupmenu
%==================================
axes(ud.axes);
myName='AXES_MotionCheck';
%--> Object Data <--
data=p3_ViewCommCallback('getdata', ud.axes, myName, ud.ObjectID);

try,
  delete(data.handle);
  %cla
catch
  warning(['Miss Delete Function : ', ...
	   'Operating Speed might be too fast to redraw.']);
end
draw(data.axes,data.curdata, data.obj,ud.ObjectID);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata,data]=getCurrentData(figh,varargin)
% Get Continuous Data : From FD_MotionCheck
hs=guidata(figh);
[hdata,data]= ...
    FD_MotionCheck_getArgument('getCurentData',...
			       figh, [],hs);
% Add Result
hdata.Result.MC.CheckData= ...
    getappdata(figh,'CheckData');
hdata.Result.MC.FlagData = ...
    getappdata(figh,'FlagData');
hdata.flag=getappdata(figh,'MCResult');
