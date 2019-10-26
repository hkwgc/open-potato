function varargout=osp_ViewAxesObj_part_FFT(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_part_FFT is "View-Axes-Object",
% so osp_ViewAxesObj_part_FFT is based on the rule.
%
% osp_ViewAxesObj_part_FFT use "Common-Callback", 
% so osp_ViewAxesObj_part_FFT is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax : 
%   osp_ViewAxesObj_part_FFT
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax : 
% varargout=osp_ViewAxesObj_part_FFT(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_part_FFT.m 364 2013-06-26 01:12:45Z Katura $

% == Warning !! ==
% When you want to edit this function,
%  you must be based on View-Axes-Object rules.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No argument : Help : (Defined in View-Axes-Object )
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='FFT (part)';
info.fnc     ='osp_ViewAxesObj_part_FFT';
% Useing Common-Callback-Object
info.ccb     = {'Data',...
  'Channel', ...
  'Kind', ...
  'TimeRange'};
% No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% --- for change ---
if length(varargin)>=1 && ~isempty(varargin{1})
  data=varargin{1};
else
	data.str = 'FFT (part)';
	data.fnc = 'osp_ViewAxesObj_part_FFT';
	data.ver = 1.00;
	data.dcoption='FFT Power';
end
if ~isfield(data,'a')
	a.prompt{1}='Spectrum type';
	a.defans{1}{1}={'FFT Power';'FFT Amplitude'};
	a.defans{1}{2}=2;	
else
	a=data.a;
end
a.a=subP3_inputdlg(a.prompt,'input dialog',1,a.defans);
data.dcoption = a.a{1}{2};

% get Default Value
if 0
  % Set X-Range (Default)
  data.xrange='auto';
else
  % Cancel
  data=[];
end

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
str=['osp_ViewAxesObj_part_FFT(''draw'', ', ...
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

% Load Current Data
%axes(gca0);
f=curdata.gcf;
%===========================
[hdata,data]=...
  osp_LayoutViewerTool('getCurrentData',f,curdata);
% Channel Required!
data = data(:,curdata.ch,:); % Remove Unused Data

%-----------------
% Get Time Range 
%-----------------
xrange=[1,size(data,1)];
if isfield(curdata,'Callback_XRange') && ...
    isfield(curdata.Callback_XRange,'handles') && ...
    ishandle(curdata.Callback_XRange.handles),
  axisv=osp_ViewCallback_XAxisRange('getAxisValue',curdata.Callback_XRange.handles);
  
  if isnumeric(axisv),
    % Numerical Value
    xrange=round(axisv*1000/hdata.samplingperiod);
  else
    % String (auto/tight .. and so on
  end  
  if xrange(1)>xrange(2),xrange=xrange([2,1]);end
  if xrange(1)<=0,xrange(1)=1;end
  if xrange(2)>size(data,1),xrange(2)=size(data,1);end
end

% --> 
if isfield(curdata,'Callback_XRange2') && ...
    isfield(curdata.Callback_XRange2,'handles') && ...
    ishandle(curdata.Callback_XRange2.handles),
  ud=get(curdata.Callback_XRange2.handles,'UserData');
  h00=ud{1}.range;
  xd=get(h00,'XData');
  xrange=round([min(xd(:)),max(xd(:))]*1000/hdata.samplingperiod);
  if xrange(1)<=0,xrange(1)=1;end
  if xrange(2)>size(data,1),xrange(2)=size(data,1);end
end

data = data(xrange(1):xrange(end),:,:);

%===========================
%    Line Property 
%===========================
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  linepropflag=true;
else
  linepropflag=false;
end
%---------------
% Default Color
%---------------
a=size(data);a=a(end);
if a<10; a=10;end
%dcol=hot(round(a));
dcol=copper(a);
dcol(1:3,:)=[1, 0, 0; ...
	     0, 0, 1; ...
	     0, 0, 0];

%===========================
% Data Change Option ...
%===========================
axis_label.x='time [sec]';
axis_label.y='HB data';
unit = 1000/hdata.samplingperiod;
try
  % Mode Transfer
  [data, axis_label, unit] = ...
    pop_data_change_v1(obj.dcoption, data, axis_label, unit);
  if unit==0
    unit=1; data=zeros([0, 1, size(data,3)]);
  end
  hdata.samplingperiod=1000/unit;
catch
  warning(['OSP Warning : Data Change Error Occur! ' ...
    C__FILE__LINE__CHAR ...
    ' ' lasterr]);
end
%-------------------
% Line TAG Setting..
%-------------------
if strcmpi(obj.dcoption,'HB data'),
  tag_head=[curdata.region(1) '_' obj.dcoption(1:2)];
else
  tag_head=[curdata.region(1) '_' obj.dcoption([1,4])];
end

%===========================
%--- Axes Setting --
%===========================
% Axis Setting
if 1,
  xlabel(axis_label.x);
  ylabel(axis_label.y);
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
else
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

for kind=curdata.kind,
  if isempty(data),continue;end
  % -- Draw --
  h.h(end+1)=line(t,data(:,1,kind));
  h.tag{end+1}=[tag_head hdata.TAGs.DataTag{kind}];

  % -- Line Property of Kind --
  lp0=0;
  if linepropflag,
    try
      for lp=1:length(curdata.lineprop),
        f=strcmp(hdata.TAGs.DataTag{kind},curdata.lineprop{lp}.name);
        if f, lp0=lp; break; end
      end
    catch
      if ~exist('lp','var')
        lp=0;
      end
    end
  end
  if (lp0~=0), 
    lpx=curdata.lineprop{lp}; 
  else 
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
    
    % Apply Line-Property : 2007.03.25 
    %  => (If there )
    P3_ApplyLineProperty(curdata,h.h(end),hdata,kind);
end

%=== context menu for log plot
if ~exist('ObjectID','var'),
  uimenu(curdata.uicontext_axes1,'Label','Log axis (x)','Separator','on','Callback','osp_ViewAxesObj_part_FFT(''LogX'')');
  uimenu(curdata.uicontext_axes1,'Label','Log axis (y)','Separator','off','Callback','osp_ViewAxesObj_part_FFT(''LogY'')');
end
%===

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_part_FFT';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
    h.h, myName, ...
    gca0, curdata, obj, ObjectID);
  return;
else
  p3_ViewCommCallback('CheckIn', ...
    h.h, myName, ...
    gca0, curdata, obj);
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

function LogX(varargin)
	if strcmp(get(gcbo,'checked'),'on')
		set(gcbo,'checked','off');set(gca,'xScale','Linear');
	else
		set(gcbo,'checked','on');set(gca,'xScale','log');
	end
function LogY(varargin)
	if strcmp(get(gcbo,'checked'),'on')
		set(gcbo,'checked','off');set(gca,'yScale','Linear');
	else
		set(gcbo,'checked','on');set(gca,'yScale','log');
	end
	
