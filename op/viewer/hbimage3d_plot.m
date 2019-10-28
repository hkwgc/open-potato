function ecode=hbimage3d_plot(mthd,actax,varargin)
%
% Plot HB-Data to 3D
%  ecode=hbimage3d_plot(mthd,actax,varargin)
%  
% methd  : Method of hbimage3d_plot
% actax  : act axes
% vargin : Hbdata, Map, Shape, Position
% ecode  : Error-Code  0: success
%
% hbdata: HB data for 2-D [ x y kind ]=size(hbdata) kind 1-2 ( or none)
%   where x is Longtitude, y is Latitude
%   kind must be none, in this version:: plot style is not dot
%
% Shape : Shape of the Prob
%   size.x : Size of the Prob  x [??] <- unit of brain figure : now 30
%   size.y : 
%   cr.x , cr.y :  Curvature-Radius of x and y:
%           ( Curvature of x and y is 1/cr.x, 1/cr.y respectively. )
%
% Position : Position of the Prob
%    point  : position [x y z]
%    --> if no point -> polar  : position in polar [ r theta phi]
%    slant   : [theta phi]
%             Theta is Longitutude slant, Phi is Latitude slant
%    
% -----------------------------------------
%  'new' is create fucntion:
%      ecode=hbimage3d_plot('new',actax,gui_handle);
%       gui_handle is Control-GUI-Handle 
%  ----
%   'plot' is plot
%      ecode=hbimage3d_plot('plot',actax,hbdata);
%      ecode=hbimage3d_plot('plot',actax,hbdata, Shape);
%      ecode=hbimage3d_plot('plot',actax,hbdata, Map);
%      ecode=hbimage3d_plot('plot',actax,hbdata, (Shape/Map),Position);
%     if hbdata=[] : Donot Change hbdata
% ----
%	'setphbid' is Set Present HB Data ID
%      ecode=hbimage3d_plot('setphbid',actax,id);
%
%  ----
%	'getPrbH' is Set Present HB Data ID
%      PRESENT_HB_DATA_Handle = hbimage3d_plot('getPrbH',actax);
%
%  ----
%  'ppoint' is reload Position Pointer
%      hbimage3d_plot('ppoint',actax)  (' ButtonDownFcn of Brain' )
%              Move(or Set) Position Pointer
%                to Mouse-Button-Doun-Point
%      hbimage3d_plot('ppoint',actax,'ppoint')  (' ButtonDownFcn of ppoint' )
%              ReMove Position Pointer
%      hbimage3d_plot('ppoint',actax,Position) (' For Button "Setting Position")
%             Move PositionPointer to Position
%
%   ---
%   'pshape' : Make Prob-Shape
%     hbimage3d_plot('pshape',actax,Shape,n,m);
%            Make Result Plane nxm mesh
%              Curvature-Radius is shape.cr 
%              from Rectangle,that size is shape.size.
%     hbimage3d_plot('pshape',actax,Shape,Map);
%            Make Result Plane From Map
%       
%
%  ---
%   'movie' : Color-Change ONLY ( for Fast-Writing )
%        -- 
%  ---
%   'slant' : Rotate Prob through angle Deg about an axis Direction
%     hbimage3d_plot('slant',actax,Direction, Deg);
%       Direction : 
%           'u' or 'd' or 'r' or 'l' is Special-Direction 
%           following format available 
%           [x y z] (Cartesian coordinates) 
%           [theta phi] (Sherical coordinate)
%        -> See also ROTATE


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Date   : 28-Oct-2004
% original author : shoji-masanori@hitachi-ul.co.jp
%
% History :
% 2004:
%  28-Oct : new For test
%  29-Oct : -- rotate check --
%  08-Nov : add 'pplot'
ecode = 0;

% Init Plot data ( read value ) & check
if nargin < 2
	errordlg('HB image 3D plot Error : Too few aruguments');
	ecode=-1; return;
end
if ~ishandle(actax)
	errordlg('HB image 3D plot Error : 2nd argument must be Handles');
	ecode=-1; return;
end

phbid=getappdata(actax,'PresentHBdata');
if any([isempty(phbid) ~isnumeric(phbid)])
	setappdata(actax,'PresentHBdata',1);
end
clear phbid;



%%%%%%%%%%%%% Main Program %%%%%%%%%%%%%%%%%
switch mthd
	case 'new'
		if nargin == 3 && ishandle(varargin{1})
			setappdata(actax,'ctrlgui',varargin{1});
		else
			errordlg(' HB-Image3d Plot : No Control-GUI Handle for ''new'' method');
			ecode=-1; return;
		end
		
		ecode=plotbrain(actax);    % Make Brain
		if ecode ~= 0,	return;	end
		PositionPoint(actax);      % Make Position Point
		set_quasiText;             % Coment of 'quasi 3d view'
		
		
	case 'plot'
		ecode=PlotMain(actax,varargin{:});
		
	case 'ppoint'
		PositionPoint(actax,varargin{:});
		
	case 'pshape'
		ecode=ProbShape(actax, varargin{:});
		
	case 'slant'
		ecode=SlantProb(actax,varargin{:});
		
	case 'setphbid'
		phbid=varargin{1};
		if ~isempty(phbid) && isnumeric(phbid) && length(phbid)==1
			setappdata(actax,'PresentHBdata',phbid);
		else
			errordlg(' HB Data ID must be numeric');
			ecode=-1;
		end
		
	case 'getPrbH'
		phbid=getappdata(actax,'PresentHBdata');
		prb_h=[];
		try
			prb_h=getappdata(actax,'ProbHandl');
			if ~isempty(prb_h) && length(prb_h)>=phbid && ishandle(prb_h(phbid))
				prb_h=prb_h(phbid);
			else
				prb_h=[];
			end
		end
		ecode = prb_h;        %% !! Return : PRESENT_HB_DATA_Handle
		return;
		
	otherwise
		errordlg([' HB image 3D plot Error : ' mthd ' is not defined method']);
		ecode = -1;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Translator
% -- Check Argument Type --
%  type = -1: Error
%          0: Not Structure
%          1: Shape
%          2: Position
%          3: Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function type=argtrns(argx)
type=-1;
if nargin==0
	errordlg('Argument Translat Error');
	type=-1;return;
end

if isstruct(argx)==0, type==0; return; end

%Shape
if isfield(argx,'cr')== 1
	cr = argx.cr;
	if any([isfield(cr,'x')==0  isfield(cr,'y')==0])
		errordlg('Argument : Structure Shape : Error');
	end
	% If there is not size Use-Map/Default
	type=1;return;
end

% Map
if any([isfield(argx,'x')  isfield(argx,'y')])
	type=3; return;
end

% Other
type=2;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   'plot' is plot
%      PlotMain(actax,hbdata);
%      PlotMain(actax,hbdata,Position);
%      PlotMain(actax,hbdata,Shape);
%      PlotMain(actax,hbdata,Map);
%      PlotMain(actax,hbdata,(Shape/Map),Position);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ecode=PlotMain(actax,varargin);
ecode=-1;
if nargin < 2, errordlg('Too Few Arguments : Plot Main');return;end;

phbid=getappdata(actax,'PresentHBdata');
prb_h0=[];prb_h=[];
try
	prb_h=getappdata(actax,'ProbHandl');
	if ~isempty(prb_h) && length(prb_h)>=phbid && ishandle(prb_h(phbid))
		prb_h0=prb_h(phbid);
	end
end
probChangeFlg=0;  % ( probChangeFlg==2) ? Not-change : Changed ;

hbdata=varargin{1};
if isempty(hbdata) 
	if isempty(prb_h0)
		errordlg(' HBimage3D Plot : No HB-Data');return;
	end
	hbdata=get(prb_h0,'CData');
end


[hbd, mxsize, mysize] = gethcbmap(hbdata);

shape=[];map=[];position=[];
for ii=2: nargin-1
	type=argtrns(varargin{ii});
	switch type
		case 0
			% Nothing To Do
		case 1
			shape=varargin{ii};
		case 2
			position=varargin{ii};
		case 3
			map=varargin{ii};
		otherwise
			errordlg('Not Defined Arguments : Plot Main');return;
	end
end

% Make Prob Shape
if ~isempty(map) && ~isempty(shape)
	errordlg(' Too many Shape Information :\nShape & Map Data exist');
	return;
end
ecode2=0;
if ~isempty(map) 
	ecode2=ProbShape(actax,map);
elseif ~isempty(shape)
	ecode2=ProbShape(actax,shape,mxsize,mysize); 
else
	if ~isempty(prb_h0) && ~isempty(varargin{1})
		hbdata2=get(prb_h0,'CData');
		%% Need Shape Error
		if size(hbdata2) ~= size(hbdata)
			ecode = 1;	return;
		end
	end
	probChangeFlg=1;  % ( probChangeFlg==1) ? Changed : not-change;
end
if ecode2 ~= 0,	return; end;
dsd=getappdata(actax,'DefaultProbData');
dsd=dsd(phbid);
if isempty(dsd)	errordlg(' Could not Creat Prob ');return;end;

% ** Make Posion Data **
sph_p=[];
if any([isempty(position)  ~isfield(position,'point')])
	probChangeFlg=probChangeFlg+1;  % ( probChangeFlg==2) ? Not-change : Change;
	if isempty(prb_h0)
		try
			% Default Position
			ppoint=findobj(actax,'Tag','positionpoint');
			sph_p =getappdata(ppoint,'Sherical_Coordinate_Point');
			position.point(1)=get(ppoint,'XData');
			position.point(2)=get(ppoint,'YData');
			position.point(3)=get(ppoint,'ZData');
		catch
			errordlg(['No Position Data :  ' lasterr]);return;
		end
	else
		sph_p=getappdata(prb_h0,'Sherical_Coordinate_Point');
	end
end
% Change to Shericqal Coordinate_Point
cntr=getappdata(actax,'Center');
if isempty(sph_p) 
	try
		cp0 = position.point - cntr;
		[sph_p.theta, sph_p.phi, sph_p.r]...
			= cart2sph(cp0(1),cp0(2),cp0(3));
	catch
		errordlg('Position Structure Error');return;
	end
end


%% Plot
%% If Positionis (r, theta, phi)
% h=surf(px+r, py, pz);rotate(h,[0 1 0],phi);rotate(h,[0 0 1],theta);
try
	axes(actax);
	if isempty(prb_h0)
		% cntr=getappdata(actax,'Center');   % Alredy Read
		prb_h0=surf(dsd.x+sph_p.r, dsd.y, dsd.z,hbd);  
		rotate(prb_h0,[0 -1 0],sph_p.phi   *180/pi,cntr);
		rotate(prb_h0,[0 0 1],sph_p.theta *180/pi,cntr);
		set(prb_h0,...
			'Tag','ProbData',...
			'LineStyle','none',...
			'FaceAlpha',[0.5]);
%			'EdgeAlpha',[0.1],...			
%			'EdgeColor',[0 0 1],...
		alpha(prb_h0,0.3);
		probChangeFlg=-1;
	else
		set(prb_h0,'CData',hbd);
		if probChangeFlg~=2
			probChangeFlg=-1;
			%  Not-change : Change;
			set(prb_h0,'XData',dsd.x+sph_p.r,...
				'YData',dsd.y, 'ZData',dsd.z);  
			rotate(prb_h0,[0 -1 0],sph_p.phi   *180/pi,cntr);
			rotate(prb_h0,[0 0 1],sph_p.theta *180/pi,cntr);
		end
	end
catch
	errordlg(' Present HB Data ID Error'); return;
end

setappdata(prb_h0,'Sherical_Coordinate_Point',sph_p);
dphi=sph_p.phi*180/pi;dtheta=sph_p.theta*180/pi;
slantaxis.long=[180+dtheta 90-dphi];
slantaxis.lat=[90+dtheta 0];
setappdata(prb_h0,'Slant_Axis',slantaxis); % Axis For Slant

% Slant Plane
if probChangeFlg==-1
	% Get Slant Data
	slantdata=[];
	if any([isempty(position)  ~isfield(position,'slant')])
		if ~isempty(prb_h0)
			slantdata=getappdata(prb_h0,'SlantData'); % Axis For Slant
		end
	else
		if isnumeric(position.slant)
			if length(position.slant(:))==2
				slantdata=position.slant(:);
			end
		end
	end
	if isempty(slantdata)
		slantdata=[0 0];
	end
	ecode1=0;
	if slantdata(1) ~= 0
		ecode1=SlantProb(actax,'r',slantdata(1));
		% if ecode1~=1, return; end
	end
	if slantdata(2) ~= 0 && ecode1==0
		ecode1=SlantProb(actax,'d',slantdata(2));
		% if ecode1~=1, return; end
	end
	setappdata(prb_h0,'SlantData',slantdata); % Axis For Slant
end  % End of Slant

prb_h(phbid)=prb_h0;
setappdata(actax,'ProbHandl',prb_h);

try
	ppoint=findobj(actax,'Tag','positionpoint');
	set(ppoint,'Visible','off');
end
ecode = 0; return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Shape of Result Plane
%     ProbShape(actax,Shape,n,m);
%            Make Result Plane nxm mesh
%              Curvature-Radius is shape.cr 
%              from Rectangle,that size is shape.size.
%     ProbShape(actax,Shape,Map);
%            Make Result Plane From Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ecode=ProbShape(actax,varargin)
%-- Argument Check --
ecode=0;
if any([nargin < 3  nargin >5])
	errordlg('Too Few or Many Arguments. For SheatShape');
	ecode=-1; return;
end

% Set 2D Map & Size
if nargin == 3
	% Read Map
	map=varargin{1};
	if any([~isfield(map,'x')  ~isfield(map,'y')])
		errodlg('Input Argument Map : Must be Structure x & y');
		ecode=-1; return;
	end
	% Centering
	xmin=min(map.x(:)); ymin=min(map.y(:));
	xmax=max(map.x(:)); ymax=max(map.y(:));
	hsizex=(xmax - xmin)/2; hsizey=(ymax - ymin)/2;
	map.x=map.x - hsizex;   map.y=map.y - hsizey;
	% Size Change
	if isfield(shape,'size')
		if isfield(shape.size,'x')
			map.x = map.x * ( shape.size.x / (hsizex*2) );
			hsizex = shape.size.x/2;
		end
		if isfield(shape.size,'y')
			map.y = map.y * ( shape.size.y / (hsizey*2) );
			hsizey = shape.size.y/2;
		end
	end
else
	shape=varargin{1};
	if any([1~=prod(size(varargin{2}))  1~=prod(size(varargin{3}))])
		errordlg('Input Argument N, M : Must be Scalar');
		ecode=-1; return;
	end
	n=varargin{2};m=varargin{3};
	
	% Set Half-Prob-Size
	if ~isfield(shape,'size')
		hsizex=50;
		hsizey=50;
	else
		if ~isfield(shape.size,'x')
			hsizex=50;
		else
			hsizex=shape.size.x/2;
		end
		if ~isfield(shape.size,'y')
			hsizey=hsizex/2;
		else 
			hsizey=shape.size.y/2;
		end
	end
	
	%  ** Shape & mesh size ** 
	px0  = linspace(-hsizex,hsizex,n); 
	py0  = linspace(hsizey,-hsizey,m); 
	clear n m;
	[map.x map.y] = meshgrid(px0,py0); 
	clear px0 py0;
end

brnr=getappdata(actax,'BrainRadius');

try, rx=shape.cr.x; catch rx=max(brnr);end
try, ry=shape.cr.y; catch ry=max(brnr);end
if any([pi*rx < hsizex   pi*ry < hsizey])
	errordlg(' Error : Reason : pi * Prob Curvature < Prob Size ')
	ecode=-1;return;
end
px0 =rx * sin( map.x / rx );
py0 =ry * sin( map.y / ry );
% --- Make Template Result Plane --
pz0 = rx * cos( map.x / rx ) + ry * cos( map.y / ry );
pz0 = pz0 - max(pz0(:));
%% Change Default Direction: 
% Now x , y is a data of no meaning Codinates
%     __ Y
%    |*
%    X
%
% But X is Longtitude Data and Y is Longtitude : X Latitude
%      z
%      |____ y
%  x  /
%   *     <- Position :   
% Default Position : 
cntr=getappdata(actax,'Center');
dpd0.x = pz0+cntr(1); dpd0.y = px0+ cntr(2); dpd0.z = py0 +cntr(3);
clear px0 py0 pz0 brnr;
%% If Positionis (r, theta, phi)
% h=surf(px+r, py, pz);rotate(h,[0 1 0],phi);rotate(h,[0 0 1],theta);
phbid=getappdata(actax,'PresentHBdata');
dpd=getappdata(actax,'DefaultProbData');
if ~isempty(phbid) && ~isempty(dpd),
	dpd(phbid) = dpd0;
else,
	dpd = dpd0;
	setappdata(actax,'PresentHBdata',1);
end
setappdata(actax,'DefaultProbData',dpd);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Color Data correspond to HB-Density
%
% Input
%   HB - Data : Density of HB Data   ( Smoothing data )
%
% Output
%   HBD CData : Color-Data correspond to HB-Density
%   mxsize    : Plot Data Mesh-size of x
%   mysize    : Plot Data Mesh-size of y
%
% Date 29-Oct-2004
%  Feature : Read raw-HBDATA & use   GRIDDATA3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hbd, mxsize, mysize] = gethcbmap(hbdata)
hbsz=size(hbdata);
if length(hbsz) >= 3, error('hbdata Dimention is 2 ro 3');end;
mxsize=hbsz(2); mysize=hbsz(1);
hbd=hbdata;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Color Data correspond to HB-Density
%
% Input
%    SlantProb(actax,varargin{:})
%      =
%    SlantProb(actax,Direction,Deg)
%       Deg:
%       Direction : 
%           'u' or 'd' or 'r' or 'l' is Special-Direction 
%           following format available 
%           [x y z] (Cartesian coordinates) 
%           [theta phi] (Sherical coordinate)
%        -> See also ROTATE
%    -- APP-Data
%       actax : 'PresentHBdata' : Now Prob-Data(HBdata) ID
%                'ProbHandl'    : Prob Data Handl 
%                'Center'       : Brain Center
%       ProbHandl : prb_h -> ProbHandl(PresentHBdata)
%                   'Slant_Axis':Axis of rotation For Slant
%                    'Sherical_Coordinate_Point'
%slantdata=getappdata(prb_h0,'SlantData'); % Axis For Slant
%setappdata(prb_h0,'SlantData',slantdata); % Axis For Slant
%
% Output
%      ecode : Error Code
% Date 10-Nov-2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ecode=SlantProb(actax,varargin)
% Init
ecode=-1;

% Check
if nargin ~=3, errordlg('Slant : Too few or many arguments');return;end
direction=varargin{1};angle=varargin{2};
if any([isempty(direction)  isempty(angle)])
	errordlg(' Empty : Direction or Angle');return;
end

% Get Prob-Data Handle
phbid=getappdata(actax,'PresentHBdata');
prb_h=hbimage3d_plot('getPrbH',actax);
if any([isempty(prb_h)  ~ishandle(prb_h)])
	errordlg('No Prob-Data to Slant');return;
end

% Deg Check
if ~isnumeric(angle) 
	try 
		angle=str2num(angle);
	catch
		errordlg('Slant Unit must be Numerical');
		return;
	end
end

% Determin Axis of Rotation & Renew SlantData
slantdata=getappdata(prb_h,'SlantData'); % Axis For Slant
if isempty(slantdata)
	slantdata=[0 0];
end
if ischar(direction)
	slantaxis=getappdata(prb_h,'Slant_Axis'); % Axis For Slant
	switch direction
		case {'u', 'U'}
			% direction=slantaxis.lat + [180 0];
			direction=slantaxis.lat;
			angle = angle * -1;  % Change 
			slantdata(2) = slantdata(2)+angle;
		case {'d', 'D'}
			direction=slantaxis.lat;
			slantdata(2) = slantdata(2)+angle;
		case {'r', 'R'}
			direction=slantaxis.long;
			slantdata(1) = slantdata(1)+angle;
		case {'l', 'L'}
			%direction=slantaxis.long *(-1);
			direction=slantaxis.long;
			angle = angle * -1;  % Change 
			slantdata(1) = slantdata(1)+angle;
		otherwise
			errordlg('Slant : Direction is out of format');
			return;
	end
% If you want to check, Make Folloing 
% else
%	if isnumeric(direction(:)) ...
end
setappdata(prb_h,'SlantData',slantdata); % Axis For Slant

% Slant Heare
try
	cntr=getappdata(actax,'Center');
	sph_p=getappdata(prb_h,'Sherical_Coordinate_Point');
	[orgn(1), orgn(2), orgn(3)] = ...
		sph2cart(sph_p.theta,sph_p.phi,sph_p.r);
	orgn=orgn + cntr;

	rotate(prb_h,direction,angle,orgn);
catch
	errordlg(['Slant : Rotate Error    ' lasterr]);
end
ecode = 0; return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotbrain : Plot Brain Figure
%
% Input
%   HB - Data : Density of HB Data   ( Smoothing data )
%
% Output
%   HBD CData : Color-Data correspond to HB-Density
%   mxsize    : Plot Data Mesh-size of x
%   mysize    : Plot Data Mesh-size of y
%
% Date 29-Oct-2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ecode=plotbrain(ax);
% --- Plot Brain ---
% -- Seting Information ( #define fo C)
braindata='p2.mat';
brnclr=[0.98 0.98 0.98]; % definition of Brain color
ecode =0;

% Plot
try
	XX=load(braindata);      % read Data (p2)
	axes(ax);
	brainh=patch(XX.p2);
	clear XX braindata;       % XX : to protect ecode,brnclr
catch
	errordlg([' Brain Plot Error : ' lasterr]);
	ecode = -1;
	return;
end
% xlabel('x');ylabel('y');zlabel('z');
view(3);camlight;lighting gouraud;
axis tight;figsz=axis;
cntr= reshape(figsz,2,3);
brnr = diff(cntr); 
brnr = brnr./2;                     % Brain Radius
cntr = cntr(1,:) + brnr;            % Center of Brain
setappdata(ax,'Center',cntr);
setappdata(ax,'BrainRadius',brnr);
alpha(0.8);
axis auto;axis vis3d;
xlabel(' X axis');ylabel(' Y axis');zlabel(' Z axis');
set(ax,'Box','on');
set(brainh,...
	'Tag','BrainFace',...
	'facecolor',brnclr,...
	'edgecolor','none',...
	'ButtonDown','hbimage3d_plot(''ppoint'',gca);');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position-Pointer : Control 
%    re-load Position Pointer
%
% Date 02-Nov-2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PositionPoint(ax,varargin)

ppoint=findobj(ax,'Tag','positionpoint');

if isempty(ppoint)
	% New PositionPointer
	axes(ax);hold on;
	ppoint=plot3(0,0,0,'ro');              % Default Position
	set(ppoint,...
		'MarkerSize',10,...                 % Marker 
		'MarkerFaceColor',[1 0 0],...
		'Visible','off',...                 % Only Set Value
		'Tag', 'positionpoint',...
		'ButtonDown','hbimage3d_plot(''ppoint'',gca,''ppoint'');');
	return;
else
	% Double Selection
	if nargin==2 && strcmp(varargin{1},'ppoint') && strcmp(get(ppoint,'Visible'),'on')
		set(ppoint,'Visible','off');
		return;
	end
end

% Change Position
cp=get(gca,'currentpoint');        % get Position
%% Make Real Point 
%% ( If Version 7 -> we can use datacursormode & get (x,y,z)
brainh=findobj(ax,'Tag','BrainFace');
bx=get(brainh,'XData');by=get(brainh,'YData');bz=get(brainh,'ZData');
cp2=diff(cp);

% --
% % mode 1:
% %bx=bx(:,1);by=by(:,1);bz=bz(:,1);
% bx1=bx(:)-cp(1,1);by1=by(:)-cp(1,2);bz1=bz(:)-cp(1,3); % centering
% [theta, phi, r]=cart2sph(bx1,by1,bz1);
% [theta0 phi0 r0]=cart2sph(cp2(1),cp2(2),cp2(3));
% % theta check
% thup = find( theta < theta0+0.1);
% thdn = find( theta(thup) > theta0-0.1);
% thr  = thup(thdn);
% 
% phup = find(phi(thr ) < phi0 + 0.1);
% phdn = find(phi(phup) > phi0 - 0.1);
% phr  = thr(phup(phdn));
% if isempty(phr)
% 	return;   % Error - Cannot cat
% end
% % Debug Print
% if 1
% 	testh.fig=figure;
% 	set(testh.fig,'Renderer','OpenGL');
% 	plot3([0 cp2(1)],[0 cp2(2)],[0 cp2(3)],'r')
% 	hold on;
% 	testh.thr=plot3(bx1(thr),by1(thr),bz1(thr),'bo');
% 	set(testh.thr,'MarkerSize',[1]);
% 	testh.phr=plot3(bx1(phr),by1(phr),bz1(phr),'go');
% end
% cpr  = min(r(phr));
% % Radius + 5
% brnr=getappdata(ax,'BrainRadius');
% cp0  = cpr * cp2/norm(cp2) + cp(1,:) -brnr;
% [theta, phi, r]          = cart2sph(cp0(1),cp0(2),cp0(3));
% [cpx(1), cpx(2), cpx(3)] = sph2cart(theta,phi,r+5);
% cpx = cpx + brnr;

% mode 2:
%% bx=bx(:,1);by=by(:,1);bz=bz(:,1);
bx1=bx(:)-cp(1,1);by1=by(:)-cp(1,2);bz1=bz(:)-cp(1,3); % centering
[th0, ph0, nrm_cp2] = cart2sph(cp2(1),cp2(2),cp2(3));
% Rotate the0
tr_unit=1;    % Searching Range Unit  #define ( ~ size(bx)/brnr(x) *100)
tr_end  = tr_unit * 30;
costh0=cos(th0);sinth0=sin(th0);
bx2 = costh0*bx1 + sinth0*by1;
by2 = costh0*by1 - sinth0*bx1;
clear bx1 by1;
trange=[];tr=tr_unit;
while length(trange) < 10
	trange=find(abs(by2) < tr);
	tr = tr+tr_unit;
	if tr > tr_end
		if isempty(trange)
			return;    % Too Far Vertex
		else
			break;
		end
	end
end
bx2=bx2(trange); bz2=bz1(trange); % by3=by2(trange); 
clear bz1;

% Rotate ph0
cosph0=cos(ph0);sinph0=sin(ph0);
bx3 = cosph0*bx2 + sinph0*bz2; 
bz3 = cosph0*bz2 - sinph0*bx2;
clear bx2 bz2;
prange=[];tr2=tr_unit;
while isempty(prange)
	prange=find(abs(bz3) < tr2);
	tr2=tr2+tr_unit;
	if tr2 > tr && isempty(prange)
		return;        % Too Far Vertex
	end
end
clear bz3;

% Debug Print
if 0
	figure;
	set(gcf,'Renderer','OpenGL');hold on;
	plot3(cp(:,1),cp(:,2),cp(:,3),'r');
	th=plot3(bx(trange),by(trange),bz(trange),'bo');
	set(th,'MarkerSize',[1]);
	plot3(bx(trange(prange)),...
		by(trange(prange)),...
		bz(trange(prange)),'go');
end

% Get Pointing Position
cpr  = min(bx3(prange));
cp0  = cpr * cp2/nrm_cp2 + cp(1,:);
clear bx3;

% Radius + rdelta
rdelta=20;    % #define 
%brnr=getappdata(ax,'BrainRadius');
cntr=getappdata(ax,'Center');
cp0= cp0-cntr;
[theta, phi, r]          = cart2sph(cp0(1),cp0(2),cp0(3));
[cpx(1), cpx(2), cpx(3)] = sph2cart(theta,phi,r+rdelta);
cpx = cpx + cntr;
sph_p.theta=theta; sph_p.phi=phi; sph_p.r=r+rdelta;
setappdata(ppoint,'Sherical_Coordinate_Point',sph_p);

% Change Point
set(ppoint,...
	'XData',cpx(1),'YData',cpx(2),'ZData',cpx(3),...
	'Visible','on');

try
	fig0=getappdata(ax,'ctrlgui');
	hbimage3d('reload_setingPosition',...
		fig0,[],guihandles(fig0),...
		cpx(1),cpx(2),cpx(3));
end


%
% Sub axes
%
function set_quasiText(varargin)
msg={'\fontsize{10}{\bf quasi 3D View : \fontsize{8}}', ...
		'   Probe position does not correspond', ...
		'   to real space coordinate'};

if nargin==1 && ishandle(varargin{1})
	try
		axes(varargin{1});
		title(msg);
	end
	return;
end
try
	set(gcf,'NextPlot','add');
	dumaxes=axes('Visible','off','Tag','dumy_axes');
	tx1= text(0.68,-0.069, msg);
catch
	lasterr
end
return;
