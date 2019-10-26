function varargout=LAYOUT_AO_2DChannelLabel(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: LAYOUT_AO_2DChannelLabel.m 266 2012-02-07 01:57:52Z Katura $

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
info.MODENAME='2D Channel Label';
info.fnc     ='LAYOUT_AO_2DChannelLabel';
info.ver     = 1.0;
info.ccb     = {'Data','DataKind','TimePoint0','ImageProp'};
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
  'LAYOUT_AO_2DChannelLabel(''draw'', h.axes,', ...
  ' curdata, obj{idx})'];
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
% Plot 2D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};

% Set Default Value
% if nargin<=3
%   curdata=potato_lao_image('ApplyDefaultCurdata',curdata,objdata);
% end

[hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);
imageData=potato_lao_image('makeImageData',hdata,data,curdata);
  
for i=1:size(imageData.Position,1)
	hout.h(end+1)=text(imageData.Position(i,1),imageData.Position(i,2),num2str(i));
end

%======================================
%=      Common-Callback Setting       =
% (temp)
%======================================
if exist('ObjectID','var'),
  potato_lao_image('SetCallback',hout,gca0,curdata,objdata,ObjectID);
else
  potato_lao_image('SetCallback',hout,gca0,curdata,objdata);
end

