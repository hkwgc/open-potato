function varargout=LAYOUT_AO_3DImage(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image3Dprop
% $Id: LAYOUT_AO_3DImage.m 180 2011-05-19 09:34:28Z Katura $

% == History =-
% 2010/02/20 :: Copy & modify from LAYOUT_AO_2DImage.m .

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
info.MODENAME='3D Image (1.0)';
info.fnc     ='LAYOUT_AO_3DImage';
info.ver     = 1.0;
info.ccb     = {'Data','DataKind','TimePoint0','ImageProp'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data)
% Set up : 3D-Image Axes-Object Data

info = createBasicInfo;
% Open Initial value setting GUI
data.str = info.MODENAME;
data.fnc = info.fnc;
data.ver = info.ver;
if ~isfield(data,'region')
  data.region ='auto';
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok 
str=[...
  'LAYOUT_AO_3DImage(''testimage'', h.axes,', ...
  ' curdata, obj{idx})'];
return;

function hout=draw(gca0, curdata, objdata, ObjectID) %#ok
if isempty(curdata.kind), curdata.kind=1;end
hout=testimage(gca0, curdata, objdata, ObjectID);

function hout=testimage(gca0, curdata, objdata, ObjectID)
% Plot 3D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};

%---> Additional Menu ; 2007.06.26
if isfield(curdata,'menu_current') && ~exist('ObjectID','var')
  % Make
  mtv=uimenu(curdata.menu_current,...
    'Label','Text-Value');
  curdata.menu_TextValue=mtv;  % <--- to Common  - Control
end


try
  %======================
  % Make Data
  %======================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);

  % Make Image Data
  % <--->
  imageData.image_mode = 100; % 3D MODE
  imageData=potato_lao_image('makeImageData',hdata,data,curdata,true);
  clear hdata data;

  %=====================
  %=   Draw Image      =
  %=====================
  hout=potato_lao_image('Draw3D',gca0,curdata,imageData,hout);

catch
  set(curdata.gcf,'CurrentAxes',gca0);%axes(gca0)
  a=axis; a(3)=a(3) + a(4)/2;
  str = sprintf('Error : \n  %s',lasterr);
  hout.h(end+1)=text(a(1),a(3),str);
  hout.tag{end+1}= 'ErrorText';
  set(hout.h(end),'EdgeColor','Red', ...
    'Interpreter','none', ...
    'Tag', 'ErrorText');
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

function hout=plotCubic(gca0,curdata,imageData,hout)
