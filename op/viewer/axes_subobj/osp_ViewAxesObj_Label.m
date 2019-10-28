function varargout=osp_ViewAxesObj_Label(fnc,varargin)
% Axes Plugin Data : Draw Label
%
% Known bugs:
%
% bug report:
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
  info.MODENAME='Label';
  info.fnc     ='osp_ViewAxesObj_Label';
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
data.str = 'Label';
data.fnc = 'osp_ViewAxesObj_Label';
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
str='osp_ViewAxesObj_Label(''draw'', obj{idx},curdata)';
return;

function h=draw(obj,curdata)

h=text(0,0.5,obj.Label);
set(h,'FontUnit',obj.Unit,'FontSize',str2num(obj.Size));

axis off;