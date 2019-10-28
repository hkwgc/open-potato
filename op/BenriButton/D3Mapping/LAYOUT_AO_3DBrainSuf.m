function varargout=LAYOUT_AO_3DBrainSuf(fnc,varargin)
% Axes Plugin Data : Default Image
%               This have GUI for Initialize Image Properties.
%
%
% Axes Object :
%     Special - Member of Axes-Object Data : image3Dprop
% $Id: LAYOUT_AO_3DBrainSuf.m 180 2011-05-19 09:34:28Z Katura $

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
info.MODENAME='3D BrainSurf';
info.fnc     ='LAYOUT_AO_3DBrainSuf';
info.ver     = 1.0;
info.ccb     = {};
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
  'LAYOUT_AO_3DBrainSuf(''draw'', h.axes,', ...
  ' curdata, obj{idx})'];
return;

function hout=draw(gca0, curdata, objdata, ObjectID)
% Plot 3D Axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output : initiarized
hout.h=[];
hout.tag={};

IniFile='\ini\D3_ini.txt';

try
  fid=fopen(IniFile,'r');
catch
  error(['Ini-File not opend: ' IniFile]);
  return;
 end

[Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
fclose(fid);
[pp ff] = fileparts(D3View.BrainSurfaceFile);

%s=load('BrainSurfEdgeMNI.mat');
s=load(ff);
x= s.x;
y= s.y;
z= s.z;

%hout.h=plot3(x,y,z,'.');
%hout.tag={'3DHeadSurf'};
%view(3);

[th,phi,r] = cart2sph(x,y,z);

%k=7;
k=D3View.BrainResolutionIn2Power;
n=2^k-1;
thetaI = pi*((-n-2):2:(n+2))/n;
phiI = (pi/2)*((-n-2):2:(n+2))'/n;
warning off all
rI = griddata(th,phi,r,thetaI,phiI,'nearest');
%rI = griddata(th,phi,r,thetaI,phiI,'linear');
warning on all

for i=-n:2:n
    ii=(i+n+4)/2;
    phi_s = (pi/2)*(i)/n;
    for j=-n:2:n
        jj=(j+n+4)/2;
        theta_s = pi*(j)/n;
        r_s = rI(ii,jj);
        X(ii-1,jj-1) = r_s*cos(phi_s)*cos(theta_s);
        Y(ii-1,jj-1) = r_s*cos(phi_s)*sin(theta_s);
        Z(ii-1,jj-1) = r_s*sin(phi_s);
    end
end

C = zeros(size(Z))+0.8;


% trial
surf1 = surf(X,Y,Z,C);
s=patch(surf2patch(surf1));
delete(surf1);
%s=surf2patch(surf(X,Y,Z,C));
set(s,'FaceColor',[0.5 0.5 0.5])
set(s,'EdgeColor','none')
set(s,'facealpha',1.0);
daspect([1 1 1])
%axis tight
axis vis3d
view(-50,30)
camlight left
camlight right

set(s,'facealpha',1.0);
p=get(s,'Parent');
set(p,'Visible','off');
size(C);
hout.h  =s;
hout.tag={'3DHeadSurf'};

if 0
s=surf(X,Y,Z,C,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
shading faceted;
daspect([1 1 1])
axis tight
view(-50,30)
camlight left
set(s,'facealpha',1.0);
p=get(s,'Parent');
set(p,'Visible','off');
size(C);

hout.h  =s;
hout.tag={'3DHeadSurf'};

end

