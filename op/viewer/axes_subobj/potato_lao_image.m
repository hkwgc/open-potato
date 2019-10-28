function varargout=potato_lao_image(fnc,varargin)
% Functions for POTATo : Layout Axis Object for Image
%  Syntax :
%     varargout=potato_lao_image(fnc,varargin)
%     varargin/varargout is depend on fnc,
%     fnc is Sub-Function of this function


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin==0,fnc='help';end

switch fnc
	case 'makeAOdata'
		% varargin = varargout = Axis-Object-Data
		varargout{1}=osp_vao_2Dimage_getargument('AxesObject',varargin{1});
	case 'ApplyDefaultCurdata'
		[varargout{1:nargout}] = ApplyDefaultCurdata(varargin{:});
	case 'makeImageData'
		[varargout{1:nargout}] = makeImageData(varargin{:});
	case 'SimpleDraw'
		[varargout{1:nargout}] = SimpleDraw(varargin{:});
	case 'Draw3D'
		[varargout{1:nargout}] = Draw3D(varargin{:});
		
	case 'SetCallback'
		[varargout{1:nargout}] = SetCallback(varargin{:});
	case 'ImageCallback'
		if nargout>=1
			[varargout{1:nargout}] = ImageCallback(varargin{:});
		else
			ImageCallback(varargin{:});
		end
	case 'ch23dimageXX'
		if nargout>=1
			[varargout{1:nargout}] = ch23dimageXX(varargin{:});
		else
			ch23dimageXX(varargin{:});
		end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=ApplyDefaultCurdata(curdata,objdata)
% Apply Default Value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(objdata,'region') && ~strcmpi(objdata.region,'auto'),
	curdata.region = objdata.region;
end

%======================
% Get Image Properties
%======================
if ~isfield(objdata,'image2Dprop') || ...
		isempty(objdata.image2Dprop),
	if isfield(curdata,'ImageProp')
		return;
	else
		curdata.ImageProp.dummy=[];
		return;
	end
end
% TimePoint0 Property
if isfield(objdata.image2Dprop,'v_timeposition')
	if ~isfield(curdata,'TimePoint0')
		curdata.TimePoint0=objdata.image2Dprop.v_timeposition;
	end
	objdata.image2Dprop=rmfield(objdata.image2Dprop,'v_timeposition');
end

if ~isfield(curdata,'ImageProp')
	curdata.ImageProp=objdata.image2Dprop;
	return;
end

%========================================
% Marge Image Property curdata & objdata
%========================================
img0=curdata.ImageProp;
img1=objdata.image2Dprop;
fn0 = fieldnames(img0);
fn1 = fieldnames(img1);
% check update data
myf = setdiff(fn1,fn0);
for idx=1:length(myf)
	img0.(myf{idx})=img1.(myf{idx});
end
curdata.ImageProp=img0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imageData=makeImageData(hdata,data,curdata,is3D)
% Make Image-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
	is3D=false;
end
if isfield(curdata,'ImageProp')
	image2Dprop=curdata.ImageProp;
else
	image2Dprop.dumy=[];
end

if is3D
	if ~isfield(hdata.Pos,'MNID3') && ~isfield(hdata.Pos,'D3')
		error('3D Plot need 3D-Position Data');
	end
	try
		if ~isfield(hdata.Pos,'MNID3')
			% Make Affine Transformation Matirix
			imageData.AffineMAT=affine_trans('make_mat',hdata.Pos.D3.Base);
		end
	catch
		error('Could not get Affine Matrix');
	end
end


% ------------
% Kind Select
% ------------
plot_kind=curdata.kind(1);
% Remove
if ndims(data)==3
	data_kind1=data(:,:,plot_kind);
	try
		imageData.KindName= hdata.TAGs.DataTag{plot_kind};
	catch
		imageData.KindName= 'No-Name';
	end
elseif ndims(data)==2
	data_kind1=data(:,:);
  if size(data_kind1,2)==1,data_kind1=data_kind1';end
  imageData.KindName='Unknown';
else
	error('Error : Too large Dimensions of data ');
end
clear data;

% ------------
% Mask ch data
% ------------
if isfield(image2Dprop,'mask_channel') && ...
		~isempty(image2Dprop.mask_channel),
	data_kind1(:, image2Dprop.mask_channel)=0;
end

% ---------------
% Time Mean
%   data_kind1 to ydata
% ---------------
% Get 2d-Image Property : time
if isfield(curdata,'TimePoint0'),
	timepos        = curdata.TimePoint0;
	% ===> Time pos Check <===
	if timepos> size(data_kind1,1),
		error(' Selecting Time-Index is too large');
	end
else
	timepos        = 1;
end

if isfield(image2Dprop,'v_MP'),
	v_MP           = image2Dprop.v_MP;
else
	v_MP           = 1;% default = 1 (not 50) TK
end

% get single time point data
v_tstart = timepos-fix(v_MP/2);
v_tend   = timepos+fix(v_MP/2);
if (v_tstart<1 ), v_tstart=1; end
if (v_tend>size(data_kind1,1) ),
	v_tend=size(data_kind1,1);
end


% ---------------
% ÉtÉâÉOîΩâf
% ---------------
if ~isfield(hdata,'flag') || isfield(hdata,'stimkind')
  % Block ::  [Type, Block, Channel] --> sumÇ≈îΩâfçœÇ›
  dataFlag=zeros(size(data_kind1,2),1);
else
  % Continuous:: [Type, Time, Channel]
  dataFlag=hdata.flag; % Continuous Flag :: 
	if size(dataFlag,2)>1
    try
      tidx=v_tstart:v_tend;
      dataFlag=sum(dataFlag(:,tidx,:),2);
    catch
      % î≠ê∂ÇµÇ»Ç¢ÇÕÇ∏
      dataFlag=dataFlag(:,1,:);
    end
	end
end

ydata = nan_fcn('mean',data_kind1(v_tstart:v_tend, :), 1 );
sz=size(ydata); sz(1)=[];
if length(sz)==1, sz(2)=1; end
ydata=reshape(ydata,sz); % Squeeze

%======
%Apply flag
%======
ydata(dataFlag~=0)=inf;


%==
imageData.ydata=ydata;
%==

%============================
% Color Axis Setting
%============================
% Color-Axis
% setup Color-Axis
% get Color-Axis Max & Min
if isfield(image2Dprop,'v_axisAuto') && ...
		isequal(image2Dprop.v_axisAuto,1),
	% automatic mode
	v_axMax=max(ydata(dataFlag==0));
	v_axMin=min(ydata(dataFlag==0));
else
	% Setting Value
	% -- Color-Axis (max) --
	if isfield(image2Dprop,'v_axMax'),
		v_axMax        = image2Dprop.v_axMax;
	else
		v_axMax=max(ydata(:));
	end
	% -- Color-Axis (min) --
	if isfield(image2Dprop,'v_axMin'),
		v_axMin        = image2Dprop.v_axMin;
	else
		v_axMin=min(ydata(:));
	end
end
% Confine range of caix is not 0
if isnan(v_axMax), v_axMax=0; end
if isnan(v_axMin), v_axMin=0; end
if (v_axMax==v_axMin),
	v_axMax=v_axMax+0.5;
	v_axMin=v_axMin-0.5;
end

% Set Pseude Colro-Axis Caling
if isfield(image2Dprop,'v_zerofix') && ...
		isequal(image2Dprop.v_zerofix,1)
	cmax = max([abs(v_axMin), abs(v_axMax)]);
	cmin = -cmax;
else
	cmax=v_axMax;
	cmin=v_axMin;
end
imageData.Caxis=[cmin, cmax];
if isempty(imageData.Caxis)
	imageData.Caxis=[-1 1];
end

%============================
% Interporation Setting
%============================
% Get value of Image-property
% Interpolation mode
%    1 : Not interpolation
%    2 : Use function interp
%    3 : Smooth Point
%( for osp_chnl2imageM)
if isfield(image2Dprop,'image_mode_ind'),
	imageData.image_mode     = image2Dprop.image_mode_ind;
else
	imageData.image_mode     = 4;
end

if imageData.image_mode==2
	% Interpolation x time
	if isfield(image2Dprop,'v_interpstep'),
		imageData.interpstep   = image2Dprop.v_interpstep;
	else
		imageData.interpstep   = 3;
	end
	% Interpolation method
	% See also interp2
	if isfield(image2Dprop,'interpmethod'),
		imageData.interpmethod = image2Dprop.interpmethod;
	else
		imageData.interpmethod = 'cubic';
	end
else
	imageData.interpstep=NaN;
	imageData.interpmethod='none';
end

imageData.Position=time_axes_position(hdata);
if 0 && isfield(hdata,'Pos')
	imageData.PositionXX=hdata.Pos;
end
if imageData.image_mode<=3
	% -- Normal Image --
	if is3D==false
		% Real  Image Map
		[RealImageMap.c, RealImageMap.x, RealImageMap.y]=...
			osp_chnl2imageM(imageData.ydata',...
			hdata, imageData.image_mode, ...
			imageData.interpstep, imageData.interpmethod);
		imageData.RealImageMap=RealImageMap;
		
		% Real Surf Map
		l=length(RealImageMap.c);
		RealSurfMap.c=cell([1,l]);
		RealSurfMap.x=cell([1,l]);
		RealSurfMap.y=cell([1,l]);
		for idx=1:l
			% Mod x
			x =RealImageMap.x{idx};
			if length(x)==1
				dx=0.5;
			else
				dx=(x(end)-x(1))/(length(x)-1);
			end
			x=x-dx/2;x(end+1)=x(end)+dx;
			RealSurfMap.x{idx}=x;
			
			% Mod y
			x =RealImageMap.y{idx};
			if length(x)==1
				dx=0.5;
			else
				dx=(x(end)-x(1))/(length(x)-1);
			end
			x=x-dx/2;x(end+1)=x(end)+dx;
			RealSurfMap.y{idx}=x;
			
			% Mod c
			sz=size(RealImageMap.c{idx});
			c = zeros(sz+1);
			c(1:end-1,1:end-1)=RealImageMap.c{idx};
			% c(c==0)=NaN;
			RealSurfMap.c{idx}=c;
		end
		imageData.RealSurfMap=RealSurfMap;
	else
		% Levitate: 2010.10.13
		if isfield(curdata,'MNI3DLevitate'),
			imageData.MNI3DLevitate=curdata.MNI3DLevitate;
		else
			imageData.MNI3DLevitate=10; % 50mm
		end
		% Real  Image Map
		if isfield(hdata.Pos,'MNID3')
			% MNI : POS Data Format
			psn      = hdata.Pos.MNID3.P;
			% Get Levitate Length
			try
				ll=imageData.MNI3DLevitate;
			catch
				ll=0;
			end
			[c{1},x{1},y{1},z{1}]=...
				ch23dimageXX(ydata,psn,imageData.image_mode,...
				imageData.interpstep, imageData.interpmethod,ll);
		else
			l=length(hdata.Pos.Group.ChData);
			
			c=cell([1,l]);
			x=cell([1,l]);
			y=cell([1,l]);
			z=cell([1,l]);
			ydata=imageData.ydata';
			for idx=1:l
				ch_lst    = hdata.Pos.Group.ChData{idx};
				ydata_tmp = ydata(ch_lst);
				% Affine-Transformation
				%    USE by MATRIX : imageData.AffineMAT;
				psn = affine_trans('translate',...
					imageData.AffineMAT,hdata.Pos.D3.P(ch_lst,:));
				[c{idx}, x{idx}, y{idx}, z{idx}] = ...
					ch23dimageXX(ydata_tmp,psn,imageData.image_mode,...
					imageData.interpstep, imageData.interpmethod);
			end
		end
		RealImageMap.c=c;
		RealImageMap.x=x;
		RealImageMap.y=y;
		RealImageMap.z=z;
		imageData.RealImageMap=RealImageMap;
		
		% Real Surf Map ( Centering )
		l=length(RealImageMap.c);
		if 0
			% TODO : Convolution
			RealSurfMap.c=cell([1,l]);
			RealSurfMap.x=cell([1,l]);
			RealSurfMap.y=cell([1,l]);
			RealSurfMap.z=cell([1,l]);
			for idx=1:l
				% Mod x
				x =RealImageMap.x{idx};
				if length(x)==1
					dx=0.5;
				else
					dx=(x(end)-x(1))/(length(x)-1);
				end
				x=x-dx/2;x(end+1)=x(end)+dx;
				RealSurfMap.x{idx}=x;
				
				% Mod y
				x =RealImageMap.y{idx};
				if length(x)==1
					dx=0.5;
				else
					dx=(x(end)-x(1))/(length(x)-1);
				end
				x=x-dx/2;x(end+1)=x(end)+dx;
				RealSurfMap.y{idx}=x;
				
				% Mod c
				sz=size(RealImageMap.c{idx});
				c = zeros(sz+1);
				c(1:end-1,1:end-1)=RealImageMap.c{idx};
				% c(c==0)=NaN;
				RealSurfMap.c{idx}=c;
			end
		else
			RealSurfMap.c=c;
			RealSurfMap.x=x;
			RealSurfMap.y=y;
			RealSurfMap.z=z;
		end
		
		imageData.RealSurfMap=RealSurfMap;
		% Alpha
		if ~isfield(image2Dprop,'PatchImageProp')
			imageData.PatchImageProp.Alpha=1.0;
			imageData.PatchImageProp.EdgeColor=[0.8 0.8 0.8];
			imageData.PatchImageProp.EdgeSize=0.03;
		else
			imageData.PatchImageProp=image2Dprop.PatchImageProp;
			if ~isfield(imageData.PatchImageProp,'Alpha')
				imageData.PatchImageProp.Alpha=1.0;
			end
			if ~isfield(imageData.PatchImageProp,'EdgeColor')
				imageData.PatchImageProp.EdgeColor=[0.8 0.8 0.8];
			end
			if ~isfield(imageData.PatchImageProp,'EdgeSize')
				imageData.PatchImageProp.EdgeSize=0.03;
			end
		end
	end
elseif  imageData.image_mode==4
	% -- Patch Image --
	% set Property
	if is3D
		if ~isfield(hdata.Pos,'MNID3') && ~isfield(hdata.Pos,'D3')
			error('3D Plot need 3D-Position Data');
		end
		% Afine-Transfer
		if isfield(hdata.Pos,'MNID3')
			% Get MNI
			imageData.Position3D=hdata.Pos.MNID3.P;
		else
			% Make Affine
			imageData.Position3D=affine_trans('translate',...
				imageData.AffineMAT,hdata.Pos.D3.P);
		end
	end
	if ~isfield(image2Dprop,'PatchImageProp')
		imageData.PatchImageProp.Alpha=1.0;
		imageData.PatchImageProp.EdgeColor=[0.8 0.8 0.8];
		imageData.PatchImageProp.EdgeSize=0.03;
	else
		imageData.PatchImageProp=image2Dprop.PatchImageProp;
		if ~isfield(imageData.PatchImageProp,'Alpha')
			imageData.PatchImageProp.Alpha=1.0;
		end
		if ~isfield(imageData.PatchImageProp,'EdgeColor')
			imageData.PatchImageProp.EdgeColor=[0.8 0.8 0.8];
		end
		if ~isfield(imageData.PatchImageProp,'EdgeSize')
			imageData.PatchImageProp.EdgeSize=0.03;
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hout=SimpleDraw(gca0,curdata,imageData,hout)
% Simple Draw-Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(0,'CurrentFigure',curdata.gcf);
if isfield(imageData,'Caxis')
	set(gca0,'CLim',imageData.Caxis);
end
if imageData.image_mode<=3
	% -- Normal Image --
	% Real  Image Map
	if 0
		c0=imageData.RealImageMap.c;
		x0=imageData.RealImageMap.x;
		y0=imageData.RealImageMap.y;
	else
		c0=imageData.RealSurfMap.c;
		x0=imageData.RealSurfMap.x;
		y0=imageData.RealSurfMap.y;
	end
	set(curdata.gcf,'CurrentAxes',gca0);
	hold on;
	for plid = 1: length(c0),
		sz=size(c0{plid});
		set(curdata.gcf,'CurrentAxes',gca0);
		hout.h(end+1)=surf(x0{plid}, y0{plid}, ...
			zeros(sz(end:-1:1)),c0{plid}');
		hout.tag{end+1}=['IMG_Probe' num2str(plid)];
		set(hout.h(end),'Tag',hout.tag{end},'LineStyle','none');
		try
			set(curdata.gcf,'CurrentAxes',gca0);
			qflag = getappdata(curdata.gcf,'IMAGE_QUIVER');
			if ~isempty(qflag) && qflag && imageData.image_mode~=3
				x=x0{plid};y=y0{plid};
				[fx,fy]=gradient(c0{plid}',x(2)-x(1), y(2)-y(1));
				hout.h(end+1:end+2)=quiver(x,y,fx,fy);
				hout.tag{end+1}=['QVR1_Probe' num2str(plid)];
				set(hout.h(end-1),'Color','Red','Tag',hout.tag{end});
				hout.tag{end+1}=['QVR2_Probe' num2str(plid)];
				set(hout.h(end),'Color','Red','Tag',hout.tag{end});
			else
				if (imageData.image_mode~=3)
					setappdata(curdata.gcf,'IMAGE_QUIVER',false);
				end
			end
		catch
			warning('Quiver Error'); %#ok
		end
	end
	% Enable Contol : 2007.06.26
	if isfield(curdata,'menu_TextValue')
		set(curdata.menu_TextValue,'Enable','off');
	end
else
	% Tell at 2007.05.22 12:54 <--> 13:50 update..
	%  mail --> to confine
	% --> Plot <--
	if 0 && isfield(imageData,'PositionXX')
		psn=imageData.PositionXX.D2.P;
	else
		psn=imageData.Position;
	end
	
	set(curdata.gcf,'CurrentAxes',gca0);
	hold on;
	
	pip=imageData.PatchImageProp;
	
	theta=linspace(0,2*pi,20);
	x0=pip.EdgeSize*cos(theta);y0=pip.EdgeSize*sin(theta);
	
	
	for idx=1:size(psn,1)
		hout.h(end+1)=fill(x0+psn(idx,1),y0+psn(idx,2),imageData.ydata(idx));
		set(hout.h(end),'LineStyle','-',...
			'LineWidth',pip.EdgeSize,...
			'EdgeColor',pip.EdgeColor);
		if ~isfinite(imageData.ydata(idx))
			set(hout.h(end),'LineStyle',':','FaceColor','none')
		end
		alpha(hout.h(end),pip.Alpha);
		
		% Draw Text :: 2007.06.26
		if isfield(curdata,'menu_TextValue')
			set(curdata.menu_TextValue,'Enable','on');
			if strcmpi(get(curdata.menu_TextValue,'Checked'),'on')
				d=0.1;
				mx=max(psn(:,[1,2]));mn=min(psn(:,[1,2]));
				mx=mx+d;mn=mn-d;
				hout.h(end+1)=line([mn(1);mx(1)],[mn(2);mx(2)]);
				set(hout.h(end),'LineStyle','none'); % Dumy
				hout.h(end+1)=text(psn(idx,1),psn(idx,2),...
					num2str(imageData.ydata(idx),'%6.2f'));
			end
		end
		% Draw Channel number
		if isfield(curdata,'menu_ImageChannelNumber')
			set(curdata.menu_ImageChannelNumber,'Enable','on');
			if strcmpi(get(curdata.menu_ImageChannelNumber,'Checked'),'on')
				d=0.1;
				mx=max(psn(:,[1,2]));mn=min(psn(:,[1,2]));
				mx=mx+d;mn=mn-d;
				hout.h(end+1)=line([mn(1);mx(1)],[mn(2);mx(2)]);
				set(hout.h(end),'LineStyle','none'); % Dumy
				hout.h(end+1)=text(psn(idx,1),psn(idx,2),num2str(idx));
				set(hout.h(end),'HorizontalAlignment','center');
			end
		end
	end
	setappdata(curdata.gcf,'IMAGE_QUIVER',false);
end

%===================
% Axis Outer Setting
%===================
caxis(imageData.Caxis);
% 2006.10.18 :: Change Colormap by menu.
%if isfield(image2Dprop,'v_colormap'),
%	osp_set_colormap(image2Dprop.v_colormap,gca0);
%end

%---------080416TK
% if strcmp(curdata.region,'Block'),
%   title(['Block : ' imageData.KindName]);
% else
%   title(['Continuous : ' imageData.KindName]);
% end
%---------------

% color bar setting : If you want
%axis auto;
axis image;
axis off;
%colorbar;

function hout=Draw3D(gca0,curdata,imageData,hout)
% Simple Draw-Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(0,'CurrentFigure',curdata.gcf);
if isfield(imageData,'Caxis')
	set(gca0,'CLim',imageData.Caxis);
end
if imageData.image_mode<=3
	% -- Normal Image --
	% Real  Image Map
	c0=imageData.RealSurfMap.c;
	x0=imageData.RealSurfMap.x;
	y0=imageData.RealSurfMap.y;
	z0=imageData.RealSurfMap.z;
	set(curdata.gcf,'CurrentAxes',gca0);
	hold on;
	pip=imageData.PatchImageProp; % Patch-Image Data;;
	for plid = 1: length(c0),
		sz=size(c0{plid});
		set(curdata.gcf,'CurrentAxes',gca0);
		hout.h(end+1)=...
			surf(x0{plid},y0{plid},z0{plid},c0{plid}',...
			'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
		hout.tag{end+1}=['IMG_3DProbe' num2str(plid)];
		set(hout.h(end),'Tag',hout.tag{end},'LineStyle','none');
		alpha(hout.h(end),pip.Alpha);
	end
	% Enable Contol : 2007.06.26
	if isfield(curdata,'menu_TextValue')
		set(curdata.menu_TextValue,'Enable','off');
	end
else
	%
	psn=imageData.Position3D;
	set(curdata.gcf,'CurrentAxes',gca0);
	hold on;
	pip=imageData.PatchImageProp;
	% Color Setting..
	caxis(imageData.Caxis);
	map     = colormap;
	mapsz   = size(map,1);
	mapunit = mapsz/(imageData.Caxis(2)-imageData.Caxis(1));
	
	% Cubic-Patch
	load('cubic_patch.mat','cubic_patch');
	cubic_patch0 = cubic_patch;
	
	cv = cubic_patch.vertices * pip.EdgeSize *100;
	for idx=1:size(psn,1)
		if ~isfinite(imageData.ydata(idx))
			continue;
		end
		
		% Size & Position Modification
		cubic_patch0.vertices = cv + repmat(psn(idx,:),size(cubic_patch.vertices,1),1);
		hout.h(end+1) = patch(cubic_patch0);
		
		mapidx  = round( (imageData.ydata(idx)-imageData.Caxis(1)) * mapunit);
		if mapidx<=0, mapidx=1; end
		if mapidx>mapsz, mapidx=mapsz; end
		set(hout.h(end), ...
			'FaceColor', map(mapidx,:), ...
			'LineStyle', 'none');
		alpha(hout.h(end),pip.Alpha);
		
		% Draw Text :: 2007.06.26
		if isfield(curdata,'menu_TextValue')
			set(curdata.menu_TextValue,'Enable','on');
			if strcmpi(get(curdata.menu_TextValue,'Checked'),'on')
				d=0.1;
				mx=max(psn(:,[1,2]));mn=min(psn(:,[1,2]));
				mx=mx+d;mn=mn-d;
				hout.h(end+1)=line([mn(1);mx(1)],[mn(2);mx(2)]);
				set(hout.h(end),'LineStyle','none'); % Dumy
				hout.h(end+1)=text(psn(idx,1),psn(idx,2),...
					num2str(imageData.ydata(idx),'%6.2f'));
			end
		end
	end
	setappdata(curdata.gcf,'IMAGE_QUIVER',false);
end

%===================
% Axis Outer Setting
%===================
caxis(imageData.Caxis);
% 2006.10.18 :: Change Colormap by menu.
%if isfield(image2Dprop,'v_colormap'),
%	osp_set_colormap(image2Dprop.v_colormap,gca0);
%end

%---------080416TK
% if strcmp(curdata.region,'Block'),
%   title(['Block : ' imageData.KindName]);
% else
%   title(['Continuous : ' imageData.KindName]);
% end
%---------------

% color bar setting : If you want
%axis auto;
axis image;
axis off;
%colorbar;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ObjectID = SetCallback(hout,gca0,curdata,objdata,ObjectID)
% Callback Checkin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myName='AXES_ImageData';
%---------------------------------------
% Common Callback Check-in
%---------------------------------------
if exist('ObjectID','var'),
	firstflag=false;
	p3_ViewCommCallback('Update', ...
		hout.h, myName, ...
		gca0, curdata, objdata, ObjectID);
else
	firstflag=true;
	ObjectID=p3_ViewCommCallback('CheckIn', ...
		hout.h, myName, ...
		gca0, curdata, objdata);
end

%---------------------------------------
% added (Special :: 2D-Image for C-Axis
%---------------------------------------
if firstflag,
	% Bug fix : 2007.12.14
	if isfield(curdata,'Callback_2DImageColor') && ...
			isfield(curdata.Callback_2DImageColor,'handles') && ...
			ishandle(curdata.Callback_2DImageColor.handles),
		% color-map-axis initialize
		axs=get(curdata.Callback_2DImageColor.handles,'UserData');
		%  2007.02.09 Shoji >>
		if isempty(axs),
			axs=gca0;
		else
			axs(end+1)=gca0;
		end
		set(curdata.Callback_2DImageColor.handles,'UserData',axs);
	end
end

if isfield(curdata,'Callback_2DImageColor') && ...
		isfield(curdata.Callback_2DImageColor,'handles') && ...
		ishandle(curdata.Callback_2DImageColor.handles)
	cmh = curdata.Callback_2DImageColor.handles;
	axs = get(cmh,'UserData');
	% Execute Only Last Data
	%if ~exist('ObjectID','var') || ObjectID==length(axs)
  if 1 % Enable multi-c-axis
		axs(~ishandle(axs))=[];
		if ~isempty(axs)
			clim=get(axs,'Clim');
			if iscell(clim), clim=cell2mat(clim);end
			clim=[min(clim(:)),max(clim(:))];
			set(axs,'Clim',clim);
		end
		% Set Clim to Axes
		set(cmh,'UserData',axs);
		
		% Set Clim to ColorMap Axes
		ytick=get(cmh,'YTick');
		xtick=get(cmh,'XTick');
		unit=100;
		if isempty(ytick)
			set(cmh,'XTickLabel',...
				round(unit*linspace(clim(1),clim(2),length(xtick)))/unit);
		else
			set(cmh,'YTickLabel',...
				round(unit*linspace(clim(1),clim(2),length(ytick)))/unit);
		end
	end
end
% << 2007.02.09 Shoji

if ~firstflag,return;end
% =========================================================================
% =                   Special Callback Setting List                       =
% =========================================================================

udadd.axes     = gca0;
udadd.ObjectID = ObjectID;
udadd.name     = myName;
udadd.str2     = [objdata.fnc,...
	'(''draw'',vdata.axes, vdata.curdata, vdata.obj, ud.ObjectID);'];
%'(''draw'',data.axes, data.curdata, data.obj, ud.ObjectID);'];

% --> always
udadd.str      = [mfilename '(''ImageCallback'',ud{idx});'];

%----------------------------
% Uimenu : Text-Value
%   2007.06.26 : shoji -->
%----------------------------
% ( 1 to 1 Control )
if isfield(curdata,'menu_TextValue') && ishandle(curdata.menu_TextValue)
	set(curdata.menu_TextValue,...
		'UserData', {udadd}, ...
		'Callback',...
		['ck=get(gcbo,''Checked'');'...
		'if strcmpi(ck,''on''),'...
		'   set(gcbo,''Checked'',''off'');'...
		'else,'...
		'   set(gcbo,''Checked'',''on'');'...
		'end;'...
		'ud=get(gcbo,''UserData'');' ...
		'idx=1;'...
		'eval(ud{1}.str);']);
end

if isfield(curdata,'menu_ImageChannelNumber') && ishandle(curdata.menu_ImageChannelNumber)
	set(curdata.menu_ImageChannelNumber,...
		'UserData', {udadd}, ...
		'Callback',...
		['ck=get(gcbo,''Checked'');'...
		'if strcmpi(ck,''on''),'...
		'   set(gcbo,''Checked'',''off'');'...
		'else,'...
		'   set(gcbo,''Checked'',''on'');'...
		'end;'...
		'ud=get(gcbo,''UserData'');' ...
		'idx=1;'...
		'eval(ud{1}.str);']);
end


%---------------------------
% Uimenu : Block / Continous
%----------------------------
% ( 1 to 1 Control )
if isfield(curdata,'menu_current') && ...
		~isempty(getappdata(curdata.gcf,'BHDATA'))
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''region'',od.curdata.region);'];
	uimenu(curdata.menu_current,...
		'Label', '2D Image DataType', ...
		'UserData', udadd, ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
		'od=getappdata(gcbf,''AXES_PlotTest_2DImageData'');' ...
		'od = od{ud.ObjectID};' ...
		'try,delete(od.handle);end;' ...
		'r=menu(''Chose Block'',''Continuous'',''Block'');' ...
		'if r==1, od.curdata.region=''Continuous'';' ...
		'else, od.curdata.region=''Block'';end;' ...
		'eval(ud.str);']);
end

%------------------------
%  Image Mode
%------------------------
if isfield(curdata,'Callback_2DImageMode') && ...
		isfield(curdata.Callback_2DImageMode,'handles') && ...
		ishandle(curdata.Callback_2DImageMode.handles),
	% See also osp_ViewCallback_2DImageMode
	h             = curdata.Callback_2DImageMode.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.image_mode_ind'', mode, '...
		'''ImageProp.PatchImageProp'', piprop);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Method
%------------------------
if isfield(curdata,'Callback_2DImageMethod') && ...
		isfield(curdata.Callback_2DImageMethod,'handles') && ...
		ishandle(curdata.Callback_2DImageMethod.handles),
	% See also osp_ViewCallback_2DImageMode
	h             = curdata.Callback_2DImageMethod.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.interpmethod'', method);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Step
%------------------------
if isfield(curdata,'Callback_2DImageStep') && ...
		isfield(curdata.Callback_2DImageStep,'handles') && ...
		ishandle(curdata.Callback_2DImageStep.handles),
	% See also osp_ViewCallback_2DImageMode
	h             = curdata.Callback_2DImageStep.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_interpstep'', step);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Channel Mask
%------------------------
if isfield(curdata,'Callback_2DImageMaskCh') && ...
		isfield(curdata.Callback_2DImageMaskCh,'handles') && ...
		ishandle(curdata.Callback_2DImageMaskCh.handles),
	% See also osp_ViewCallback_2DImageMaskCh
	h             = curdata.Callback_2DImageMaskCh.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.mask_channel'', maskch);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Mean Period
%------------------------
if isfield(curdata,'Callback_2DImageMeanP') && ...
		isfield(curdata.Callback_2DImageMeanP,'handles') && ...
		ishandle(curdata.Callback_2DImageMeanP.handles),
	% See also osp_ViewCallback_2DImageMeanP
	h             = curdata.Callback_2DImageMeanP.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_MP'', meanp);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Axis Auto
%------------------------
if isfield(curdata,'Callback_2DImageAuto') && ...
		isfield(curdata.Callback_2DImageAuto,'handles') && ...
		ishandle(curdata.Callback_2DImageAuto.handles),
	% See also osp_ViewCallback_2DImageAuto
	h             = curdata.Callback_2DImageAuto.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_axisAuto'', val);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageMin') && ...
		isfield(curdata.Callback_2DImageMin,'handles') && ...
		ishandle(curdata.Callback_2DImageMin.handles),
	% See also osp_ViewCallback_2DImageAuto
	h             = curdata.Callback_2DImageMin.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_axMin'', val);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageMax') && ...
		isfield(curdata.Callback_2DImageMax,'handles') && ...
		ishandle(curdata.Callback_2DImageMax.handles),
	% See also osp_ViewCallback_2DImageAuto
	h             = curdata.Callback_2DImageMax.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_axMax'', val);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

if isfield(curdata,'Callback_2DImageZerofix') && ...
		isfield(curdata.Callback_2DImageZerofix,'handles') && ...
		ishandle(curdata.Callback_2DImageZerofix.handles),
	% See also osp_ViewCallback_2DImageAuto
	h             = curdata.Callback_2DImageZerofix.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_zerofix'', zerofix);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%------------------------
%  Time Slider (or edit)
%------------------------
if isfield(curdata,'Callback_2DImageTime') && ...
		isfield(curdata.Callback_2DImageTime,'handles') && ...
		ishandle(curdata.Callback_2DImageTime.handles),
	% See also osp_ViewCallback_2DImageTime
	h             = curdata.Callback_2DImageTime.handles;
	udadd.str= [mfilename '(''ImageCallback'',ud{idx},'...
		'''ImageProp.v_timeposition'', timepos);'];
	ud=get(h,'UserData');
	ud{end+1}=udadd;
	set(h,'UserData',ud);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud=ImageCallback(ud, varargin)
% Image - Callback (is as same as Common-Callback
% Callback of
%  fdname  : name of Property
%  value   : value of Property
%  (property : name of image2Dprop field
%       ex. image_mode_ind,v_interpstep,.....)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get Callback Data
vdata=p3_ViewCommCallback('getData',ud.axes,ud.name,ud.ObjectID);
%--> Object Data of PLOT-TEST <--
for idx=2:2:length(varargin)
	try
		eval(['vdata.curdata.' varargin{idx-1} '=varargin{idx};']);
	catch
		warning(C__FILE__LINE__CHAR);
	end
end
%ImageProp.(fdname)=value;

try
	delete(vdata.handle(ishandle(vdata.handle)));
catch
	warning(C__FILE__LINE__CHAR);
end

% Check,draw, update color-map-axis
try
	eval(ud.str2);
catch
	warning(C__FILE__LINE__CHAR);
	rethrow(lasterror);
	testimage(vdata.axes, vdata.curdata, vdata.obj ,ud.ObjectID);
end
return;

function [c x y z] = ch23dimageXX(ydata,psn,image_mode,v_interpstep, v_interpmethod,ll)

% -- TODO : mode 1, 3

% ã…ç¿ïWånÇ…ïœä∑
[th,phi,r] = cart2sph(psn(:,1),psn(:,2),psn(:,3));

% Add to Levitate ..
if (nargin>=6)
	r = r + ll;
end

%--------------
% íºåÇ≥ÇπÇÈ
%--------------
% Original th-phi
cx=polyfit(th,phi,1);  % íºê¸ãﬂéóÅ@-> cx(1) * th + cx(2) = phi
% Ç±ÇÃåXÇ´ï™ÅAãtâÒì]Ç≥ÇπÇÈ
beta=atan(cx(1));
% -É¿âÒì]çsóÒ
rmat=[cos(-beta), -sin(-beta); sin(-beta), cos(-beta)];
% âÒì]ÇµíuÇ´ä∑Ç¶ÇÈ
tmp=rmat*[th phi]'; th=tmp(1,:)';phi=tmp(2,:)';


p=[th, phi, r];
th  = sort(th);
phi = sort(phi);

dth  = th(end)-th(1);
dphi = phi(end)-phi(1);

% Grid
[dmax, idx]=max(diff(th));
if (dth>1.5*pi && dmax>0.5*pi)
	th0=p(:,1);
	th0(th0<=th(idx)) = th0(th0<=th(idx))+2*pi;
	p(:,1)=th0;
	th = sort(th0);
	dth= th(end)-th(1);
end
% Grid
[dmax, idx]=max(diff(phi));
if (dphi>1.5*pi && dmax>0.5*pi)
	phi0=p(:,2);
	phi0(phi0<=phi(idx)) = phi0(phi0<=phi(idx))+2*pi;
	p(:,2)=phi0;
	phi = sort(phi0);
	dphi= phi(end)-phi(1);
end


dth=dth*0.05;dphi=dphi*0.05;
th  = round(th/dth) ;th =unique(th) *dth;
phi = round(phi/dphi);phi=unique(phi)*dphi;
th0 =linspace(th(1)-dth,th(end)+dth,length(th)*2+3)';
phi0=linspace(phi(1)-dphi,phi(end)+dphi,length(phi)*2+3)';

%dth = min(diff(th0))  * 0.5;
%dphi= min(diff(phi0)) * 0.5;

switch image_mode % switch Image Mode
	case 1 % Image Mode = POINTS
		error('TODO: No- POINTS Mode Supported');
	case 3 % Image Mode = smooth POINTS
		error('TODO: No- SMOOTH POINTS Mode Supported');
	case 2 % Image Mode = INTERPED
		%x = linspace(th(1),th(end), round(length(phi0)*v_interpstep));
		x = linspace(th0(1),th0(end), round(length(th0)*v_interpstep));
		df= x(2)-x(1);
		x = [x(1)-df, x, x(end)+df];
		
		%y= linspace(phi(1),phi(end), round(length(phi0)*v_interpstep));
		y= linspace(phi0(1),phi0(end), round(length(phi0)*v_interpstep));
		df = y(2)-y(1);
		y = [y(1)-df, y, y(end)+df];
		
		% [x3,y3]=meshgrid(x,y(end:-1:1));
		[x3,y3]=meshgrid(x,y);
		try
			r3 =griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod);
			v  =griddata(p(:,1), p(:,2), ydata', x3, y3, v_interpmethod);
		catch
			% -- Error in Relase 2006a ?
			r3 = griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod, ...
				{'Qt','Qbb','Qc','Qz'});
			v  = griddata(p(:,1), p(:,2), ydata', x3, y3, v_interpmethod, ...
				{'Qt','Qbb','Qc','Qz'});
		end
		%----> Un Rotate
		% Original th-phi
		% Rotate
		% íºåópÇ…âÒì]ÇµÇƒÇ¢ÇΩÇ‡ÇÃÇñﬂÇ∑
		rmat=[cos(beta), -sin(beta); sin(beta), cos(beta)];
		tmp=rmat*[x3(:) y3(:)]';
		x3(:)=tmp(1,:);y3(:)=tmp(2,:);
		%<-------------------------
		% ã…ç¿ïWÇ©ÇÁíºåç¿ïWÇ÷
		%<-------------------------
		[x,y,z]=sph2cart(x3,y3,r3);
		c      =v; % ÉJÉâÅ[É}ÉbÉvÇÕïœçXÇ»Çµ
		% error(sprintf('Image Plot does not support measuremode %d.',probe_mode));
		
	otherwise,
		% ===== Error message add =====
		if image_mode==4,
			errordlg({'Image Mode 4 is special value,', ...
				' there is no image to plot'});
		end
		error(['Image Mode(' num2str(image_mode) ')' ...
			' is out of range (1, 2, 3)']);
end % end of switch Image Mode

c = c';
return;





