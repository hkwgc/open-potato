function varargout=LAYOUT_AO_2DImage_Plus(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image2Dprop
% $Id: LAYOUT_AO_2DImage_Plus.m 180 2011-05-19 09:34:28Z Katura $

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

if 0,
  drawstr;
  draw;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='2D Image (1.5+)';
% --> @ funciton is difficult to save ..
%       R13<->R14 is different.
info.fnc     ='LAYOUT_AO_2DImage_Plus';
%  data.ver  = 1.00;
info.ccb     = {'Data','DataKind','TimePoint0','ImageProp'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data)
% Set up : 2D-Image Axes-Object Data

% Open Initial value setting GUI
data.str = '2D Image (1.5+)';
data.fnc = 'LAYOUT_AO_2DImage_Plus';
data.ver = 1.00;
if ~isfield(data,'region')
  data.region ='auto';
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
function str = drawstr(varargin)
str=[...
  'LAYOUT_AO_2DImage_Plus(''testimage'', h.axes,', ...
  ' curdata, obj{idx})'];
if 0,disp(varargin);end
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
if isempty(curdata.kind), curdata.kind=1;end
hout=testimage(gca0, curdata, objdata, ObjectID);

function hout=testimage(gca0, curdata, objdata, ObjectID)
% Plot 2D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};

% Set Default Value
if nargin<=3
  curdata=potato_lao_image('ApplyDefaultCurdata',curdata,objdata);
  %---> Additional Menu ; 2007.06.26
  if isfield(curdata,'menu_current') 
    % Make
    curdata.menu_TextValue=uimenu(curdata.menu_current,...
      'Label','Text-Value');
  end
end


try
  %======================
  % Make Data
  %======================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);

  % Make Image Data
  % <--->
  imageData=potato_lao_image('makeImageData',hdata,data,curdata);

  %=====================
  %=   Draw Image      =
  %=====================
  hout=potato_lao_image('SimpleDraw',gca0,curdata,imageData,hout);
  if 1
  if ~isequal(imageData.image_mode,4)
    try
      curdataback=curdata;
      curdata.ImageProp.image_mode_ind=4;
      imageData=potato_lao_image('makeImageData',hdata,data,curdata);
      hout=potato_lao_image('SimpleDraw',gca0,curdata,imageData,hout);
    catch
      curdata=curdataback;
      rethrow(lasterror);
    end
    curdata=curdataback;
  end
  end

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
%======================================
if exist('ObjectID','var'),
  potato_lao_image('SetCallback',hout,gca0,curdata,objdata,ObjectID)
else
  potato_lao_image('SetCallback',hout,gca0,curdata,objdata);
end

