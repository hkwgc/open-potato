function varargout=osp_ViewAxesObj_L_bf(fnc,varargin)
% Axes Plugin Object : Plot Band-Filter Data
% 
% osp_ViewAxesObj_L_bf is "View Axes Object"
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
% $Id: osp_ViewAxesObj_L_bf.m 298 2012-11-15 08:58:23Z Katura $

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
  info.MODENAME='BandFilter';
  info.fnc     ='osp_ViewAxesObj_L_bf';
  info.ccb ={'TimeRange','Channel','Kind'};
%  data.ver  = 1.00;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
% --- for change ---
% --> Never Used <--
  data.str = 'Band Filter Object(Special AxesObject for BandFilter) !';
  data.fnc = 'osp_ViewAxesObj_L_bf';
  data.ver = '$Revision: 1.2 $';
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
str=['osp_ViewAxesObj_L_bf(''draw'', ', ...
     'h.axes, curdata, obj{idx})'];
return;

function h=draw(gca0,curdata,obj,ObjectID)
% Draw / Redraw BandFilter Axes-Object
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

%===========================
%    Line Property 
%===========================
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  linepropflag=true;
else,
  linepropflag=false;
end
%---------------
% Default Color
%---------------
a=max(curdata.kind(:));
if a<10; a=10;end
dcol=hot(a);
dcol(1:3,:)=[1, 0, 0; ...
	     0, 0, 1; ...
	     0, 0, 0];

%=================
% Get Filterd data
%=================
[hdata,data]=getCurrentData(gcf);

%===========================
% Data Change Option ...
%===========================
axis_label.x='time [sec]';
axis_label.y='HB data';
unit = 1000/hdata.samplingperiod;
try,
  % Mode Transfer
  [data, axis_label, unit] = ...
      pop_data_change_v1(obj.dcoption, data, axis_label, unit);
  hdata.samplingperiod=1000/unit;
catch,
  warning(['OSP Warning : Data Change Error Occur! ' ...
	   C__FILE__LINE__CHAR ...
	   ' ' lasterr]);
end
%-------------------
% Line TAG Setting..
%-------------------
if strcmpi(obj.dcoption,'HB data'),
  tag_head=[curdata.region(1) '_' obj.dcoption(1:2)];
else,
  tag_head=[curdata.region(1) '_' obj.dcoption([1,4])];
end

%===========================
% Time Range Change
%===========================
if strcmp(axis_label.x,'time [sec]'),
  t0=1:size(data,1);
  t=(t0 -1)/unit;
  % Time Range Require!
  of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
  uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];
else,
  t0=1:size(data,1);
  t = t0/unit;
end
data = data(t0,:,:);

%==================================
% Draw
%==================================
h.h=[];
h.tag={}; 
% Kind is in a Data-Range? 
tmp_kind= find((curdata.kind<=0) + (curdata.kind>size(data,3)));
if ~isempty(tmp_kind),curdata.kind(tmp_kind)=[];end
% get current channel
ch=curdata.ch;
for kind=curdata.kind,
  % -- Draw --
  h.h(end+1)=line(t,data(:,ch,kind));
  h.tag{end+1}=[tag_head hdata.TAGs.DataTag{kind}];

  % -- Line Property of Kind --
  lp0=0;
  if linepropflag,
    try,
      for lp=1:length(curdata.lineprop),
	f=strcmp(hdata.TAGs.DataTag{kind},curdata.lineprop{lp}.name);
	if f, lp0=lp; break; end
      end
    end
  end
  if (lp0~=0), 
    lpx=curdata.lineprop{lp}; 
  else, 
    lpx.style='-';
    lpx.mark='none';
    lpx.color=dcol(kind,:);
  end

  %-------------------
  % Set Line Property
  %-------------------
  set(h.h(end),...
      'LineStyle',lpx.style,...
      'Marker',lpx.mark, ...
      'Color',lpx.color, ...
      'MarkerEdgeColor',lpx.color, ...
      'MarkerFaceColor',lpx.color, ...
      'TAG', h.tag{end});
%      'EraseMode','xor',...
end

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_BandFilter';
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

%------------------------
%  Set UserData(Callback calling) to Apply-button 
%------------------------
if isfield(curdata,'psb_mc_view') && ...
      ishandle(curdata.psb_mc_view),
  % See also osp_view
  %ucadd.handle  = h.h;
  udadd.ObjectID= ObjectID;
  udadd.axes=gca0;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_L_bf(' ...
		'''bandFilter'',ud{idx});'];
  ud=get(curdata.psb_mc_view,'UserData');
  ud{end+1}=udadd;
  set(curdata.psb_mc_view,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================
function ud=bandFilter(ud)
% Channel Change
% Callback of Channel Popupmenu
%==================================
axes(ud.axes);
myName='AXES_BandFilter';
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
% Get Band Filterd Data : From FD_BandFilter
hs=guidata(figh);
% [hdata,data]= ...
%     FD_BandFilter_getArgument('getCurentData',...
% 			       figh, [],hs)% [hdata,data]= ...
[hdata,data]= ...
    FD_BandFilter_getArgument('getCurrentBFdata',...
			       figh, [],hs);
