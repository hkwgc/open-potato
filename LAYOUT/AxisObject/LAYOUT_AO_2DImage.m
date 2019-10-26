function varargout=LAYOUT_AO_2DImage(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: LAYOUT_AO_2DImage.m 311 2013-02-27 05:36:27Z Katura $

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
info.MODENAME='2D Image (2.0)';
info.fnc     ='LAYOUT_AO_2DImage';
info.ver     = 2.0;
info.ccb     = {'Data','DataKind','TimePoint0','ImageProp','stimkind'};
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
if ~isfield(data,'image2Dprop') || ~isfield(data.image2Dprop,'v_MP')
    data.image2Dprop.v_MP = 50;
end
% Open dialog, Get properties of 2D-Image
try
  data=potato_lao_image('makeAOdata',data);
catch
  % When Error occur
  errordlg({'--------------------------',...
    '[Platform Error] :', ...
    '--------------------------',...
    '  >> in 2D Image Axes-Object : getArgument', lasterr});
  data=[]; return;
end
% other 2D image property
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok 
str=[...
  'LAYOUT_AO_2DImage(''testimage'', h.axes,', ...
  ' curdata, obj{idx})'];
return;

function hout=draw(gca0, curdata, objdata, ObjectID) %#ok
if isempty(curdata.kind), curdata.kind=1;end
hout=testimage(gca0, curdata, objdata, ObjectID);

function hout=testimage(gca0, curdata, objdata, ObjectID)
% Plot 2D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};

% Set Default Value
% if nargin<=3
%   curdata=potato_lao_image('ApplyDefaultCurdata',curdata,objdata);
% end


%---> Additional Menu ; 2007.06.26
if isfield(curdata,'menu_current') && ~exist('ObjectID','var')
  % Make
  mtv=uimenu(curdata.menu_current,'Label','Text-Value');
  curdata.menu_TextValue=mtv;  % <--- to Common  - Control
  mtv=uimenu(curdata.menu_current,'Label','Channel number');
  curdata.menu_ImageChannelNumber=mtv;  % <--- to Common  - Control
end


try
  %======================
  % Make Data
  %======================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);

  %-- for small hdata
  if ~isfield(hdata,'measuremode')
	  hdata.measuremode=-1;
  end
  if ~isfield(hdata,'flag')
	  hdata.flag=zeros(1,1,size(data,2));
  end  
  %-------------------
  
  % Make Image Data
  % <--->
  imageData=potato_lao_image('makeImageData',hdata,data,curdata);
  clear hdata data;

  %=====================
  %=   Draw Image      =
  %=====================
  hout=potato_lao_image('SimpleDraw',gca0,curdata,imageData,hout);

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

