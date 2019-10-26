function varargout=osp_ViewAxesObj_Label4ChannelROI(fnc,varargin)
% Axes Plugin Data : Draw Label
%
% Known bugs:
%
% bug report:
%

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
  info.MODENAME='Label for Channel ROI';
  info.fnc     ='osp_ViewAxesObj_Label4ChannelROI';
%  data.ver  = 1.00;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
% --- change ---
if length(varargin)>=1,
	data=varargin{1};
end
% Confine Default Value..
data.str = 'Label for ChannelROI';
data.fnc = 'osp_ViewAxesObj_Label4ChannelROI';
data.ver = 1.00;
% Default Data
if ~isfield(data,'Label'),	data.Label='???';end
if ~isfield(data,'Unit'),	data.Unit='points';end
if ~isfield(data,'Size'),	data.Size='12';end

% input dialog
a=inputdlg([{'Input label text'},{'Font Unit'},{'Font size'}],...
	'Label',1,[{data.Label},{data.Unit},{data.Size}]);
data.Label=a{1};
data.Unit=a{2};
data.Size=a{3};
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% See also VIEWGROUPAXES,
%          OSP_VAO_BACKGROUND_GETARGUMENTS.
str='osp_ViewAxesObj_Label4ChannelROI(''draw'', obj{idx},curdata,h.axes)';
return;

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function h=draw(obj,curdata,gca0)
if isfield(curdata,'ChannelROI')
	h=text(0,0.5,num2str(curdata.ChannelROI));
	set(h,'FontUnit',obj.Unit,'FontSize',str2num(obj.Size));
else
	h=text(0,0.5,'1');
	set(h,'FontUnit',obj.Unit,'FontSize',str2num(obj.Size));
end
axis off;

%------------------------
%  Checkin            
%------------------------
if isfield(curdata,'Callback_ChannelROI') && ...
		isfield(curdata.Callback_ChannelROI,'handles') && ...
		ishandle(curdata.Callback_ChannelROI.handles)
	CO_h = curdata.Callback_ChannelROI.handles;
	udadd.handle=h;
	udadd.axes=gca0;
	udadd.str=['ud{idx}=osp_ViewAxesObj_Label4ChannelROI(' ...
			'''CB_ChannelROI'',ud{idx}, curdata.SelectedChannelROI);'];
	ud=get(CO_h,'UserData');
	ud{end+1}=udadd;
	set(CO_h,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback from Controll
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud=CB_ChannelROI(ud, SelectedChannelROI)

str=sprintf('%d, ',SelectedChannelROI);
set(ud.handle,'String',str(1:end-2));
