function varargout=osp_ViewAxesObj_StimLine(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_StimLine is "View-Axes-Object",
% so osp_ViewAxesObj_StimLine is based on the rule.
%
% osp_ViewAxesObj_StimLine use "Common-Callback", 
% so osp_ViewAxesObj_StimLine is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax : 
%   osp_ViewAxesObj_StimLine
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax : 
% varargout=osp_ViewAxesObj_StimLine(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_StimLine.m 298 2012-11-15 08:58:23Z Katura $



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

switch fnc
	case 'createBasicInfo'
		varargout{1}=createBasicInfo;
	case 'getArgument'
		varargout{1}=getArgument(varargin{:});
	case 'drawstr'
		varargout{1}=drawstr(varargin{:});
	case 'draw'
		varargout{1}=draw(varargin{:});
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
  info.MODENAME='Marker Line';
  info.fnc     ='osp_ViewAxesObj_StimLine';
  % Useing Common-Callback-Object
  % ==> Redraw by All CO : Becase Line Must be Tight by Axes
  info.ccb     = {'Data',...
	  'Channel', ...
	  'Kind', ...
	  'TimeRange'};
  info.Version = 1.0;
  % No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% --- for change ---
  if length(varargin)>=1,
    data=varargin{1};
  end
  data.str = 'Marker Line';
  data.fnc = 'osp_ViewAxesObj_StimLine';
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
str=['osp_ViewAxesObj_StimLine(''draw'', ', ...
     'h.axes ,curdata, obj{idx});'];
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
%===========================
% Get Channel Data!
%===========================
f=curdata.gcf;
hdata=osp_LayoutViewerTool('getCurrentDataRaw',f,curdata);

%==================================
% Makeing Draw-Data
%==================================
unit = hdata.samplingperiod/1000;
stim = hdata.stim;
if size(stim,2)==3,
	% Continuos
	stim_kind = stim(:,1);
	stim(:,1)=[];
else
	% Block
	stim_kind    = zeros(size(stim,1),1);
	stim_kind(:) = hdata.stimkind(1);
end
stim = stim*unit;

% Kind Loop
uk=unique(stim_kind);
%------------
% Make Color Correspond to Kind
%------------
col=gray(length(uk)+2);
col(:,2)=1; % Green Base.

%------------
% Make Range of Line
%------------
set(f,'CurrentAxes',gca0);
% use tight?
if isfield(curdata,'ylim')
	set(gca0,'Ylim',curdata.ylim);
else
	axis tight
end
r=axis(gca0);
%r0=[r(3);(r(3)+r(4))/2;r(4)];
r0=[r(3),r(4)];
%---------
% init output
%---------
h.h   = [];
h.tag = {};
for iblk = 1:size(stim,1),
	if ((stim(iblk,2)-stim(iblk,1))<0.001),
		% when Event..
		h.h(end+1)   = local_plot(stim(iblk,1),r0);
		h.tag{end+1} = sprintf('EventMark_%d',stim_kind(iblk));
		set(h.h(end),'Tag',h.tag{end},'Marker','diamond');
		% Apply Line-Property : 2007.03.25
		P3_ApplyLineProperty(curdata,h.h(end),h.tag{end},4);
	else
		% Block
		% --> Start
		h.h(end+1)   = local_plot(stim(iblk,1),r0);
		h.tag{end+1} = sprintf('StartMark_%d',stim_kind(iblk));
		set(h.h(end),'Tag',h.tag{end},'Marker','>');
		% Apply Line-Property : 2007.03.25
		P3_ApplyLineProperty(curdata,h.h(end),h.tag{end},4);
		
		% --> Stop 
		h.h(end+1)   = local_plot(stim(iblk,2),r0);
		h.tag{end+1} = sprintf('EndMark_%d',stim_kind(iblk));
		set(h.h(end),'Tag',h.tag{end},'Marker','square');
		% Apply Line-Property : 2007.03.25
		P3_ApplyLineProperty(curdata,h.h(end),h.tag{end},4);
	end
end

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_StimLine_ObjectData';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
		       h.h, myName, ...
		       gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', ...
		       h.h, myName, ...
		       gca0, curdata, obj);
end
function h=local_plot(t,r)
% Local Plot function
h=line([t;t],r);
set(h,...
	'LineStyle','-', ...
	'LineWidth',0.5, ...
	'Color',[0.3,0.9,0.7]);
return;
