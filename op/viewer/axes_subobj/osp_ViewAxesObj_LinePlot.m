function varargout=osp_ViewAxesObj_LinePlot(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_LinePlot is "View-Axes-Object",
% so osp_ViewAxesObj_LinePlot is based on the rule.
%
% osp_ViewAxesObj_LinePlot use "Common-Callback", 
% so osp_ViewAxesObj_LinePlot is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax : 
%   osp_ViewAxesObj_LinePlot
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax : 
% varargout=osp_ViewAxesObj_LinePlot(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_LinePlot.m 298 2012-11-15 08:58:23Z Katura $

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
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Line Plot';
  info.fnc     ='osp_ViewAxesObj_LinePlot';
  % Useing Common-Callback-Object
   info.ccb     = {'Data',...
 	  'Channel', ...
 	  'Kind', ...
 	  'stimkind',...
 	  'TimeRange'};
%info.ccb = 'all';
  % No TimePoint
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
  data.str = 'Line Plot';
  data.fnc = 'osp_ViewAxesObj_LinePlot';
  data.ver = 1.00;
  % Figure
  fh=figure('MenuBar','none', 'Units','Characters');
  p=get(fh,'Position');
  p(3:4)=[80,10];set(fh,'Position',p);
  set(fh,'Units','Normalized');
  set(fh,'DeleteFcn','error(''Push OK / Cancel'');');
  % Title
  th = uicontrol('Style','Text', ...
		 'Units','Normalized', ...
		 'Position',[5,80,90,15]/ 100, ...
		 'String','Data Change Option', ...
		 'HorizontalAlignment','left');
  % Popup Menu
  pstr = {'HB data','FFT Power', 'FFT Phase', 'FFT Magnitude'};
  val=1;
  try,
    if isfield(data,'dcoption'),
      val  = find(strcmp(data.dcoption,pstr));
      if isempty(val), val=1; end
    end
  end
  ph = uicontrol('Style','popupmenu', ...
		 'Units','Normalized', ...
		 'BackgroundColor',[1 1 1], ...
		 'Position',[10,50,70,20]/ 100, ...
		 'String', pstr, ...
		 'Value', val);
	  
  % OK button
  oh = uicontrol('Units','Normalized', ...
		 'Position',[30,10,20,20]/ 100, ...
		 'BackgroundColor',[1 1 1], ...
		 'String', 'OK', ...
		 'Callback', ...
		 ['set(gcbf,''DeleteFcn'','''');'...
		  'set(gcbf,''UserData'',true);']);
  ch = uicontrol('Units','Normalized', ...
		 'Position',[60,10,20,20]/ 100, ...
		 'BackgroundColor',[1 1 1], ...
		 'String', 'Cancel', ...
		 'Callback', ...
		 ['set(gcbf,''DeleteFcn'','''');'...
		  'set(gcbf,''UserData'',false);']);
  waitfor(fh,'DeleteFcn','');
  if ishandle(fh),
    flg = get(fh,'UserData');
    % Cancel
    if flg, 
      data.dcoption=pstr{get(ph,'Value')};
    else,
      data=[]; 
    end
    delete(fh);
  else,
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
str=['osp_ViewAxesObj_LinePlot(''draw'', ', ...
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
% Get Channel Data!
% Speedup By T.K 2006.10.15
%===========================
%if 0,
% if isfield(curdata,'tmp_data'),
%   hdata = curdata.tmp_hdata;
%   data  = curdata.tmp_data; %(:,curdata.ch,:); % Remove Unused Data 
% else,
%   [hdata,data] = osp_LayoutViewerTool('getCurrentData',f,curdata);
%   % Channel Required!
%   data = data(:,curdata.ch,:); % Remove Unused Data 
% end

[hdata,data] = osp_LayoutViewerTool('getCurrentData',f,curdata);

h.h=[];h.tag={}; 
if iscell(data)
	col = [1 0 0; 0 .7 0; 0 0 1; 1 .6 0; 0 .7 .5;.8 0 .6;];
	for k=1:length(data)
		h=sub_DrawLine(h, data{k}(:,curdata.ch,:), hdata, gca0, curdata, obj);
		set(h.h(end),'Color',col(mod(curdata.stimkind(k)+5,6)+1,:));
	end

else
	h=sub_DrawLine(h, data(:,curdata.ch,:), hdata, gca0, curdata, obj);
end

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_PlotTest_ObjectData';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', h.h, myName, gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', h.h, myName, gca0, curdata, obj);
end


%================================================================
function h = sub_DrawLine(h, data, hdata, gca0, curdata, obj)

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
if 0,
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
else,
  t0=1:size(data,1);
  t = t0/unit;
end
data = data(t0,:,:);

%==================================
% Draw
%==================================
% Kind is in a Data-Range? 
tmp_kind= find((curdata.kind<=0) + (curdata.kind>size(data,3)));
if ~isempty(tmp_kind),curdata.kind(tmp_kind)=[];end

for kind=curdata.kind,
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
		  %??
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
  
  % Apply Line-Property : 2007.03.25
  %  => (If there )
  
  P3_ApplyLineProperty(curdata,h.h(end),hdata,kind);
 

end
if ~exist('ObjectID','var')
	set(gca0,'xlim',[t(1),t(end)]);
end
