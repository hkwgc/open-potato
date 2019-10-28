function img_handle=Cube_Plot(img_handle, ydata, header, varargin),
% 3-D Image Ploting of Blain : 3-Cube Mode
%
% Syntax :
%   img_handle = Cube_Plot(img_handle, ydata, header, varargin);
%
%  -- Input --
%   img_handle : handles of Image
%                where img_handle.figure1 is figure handle
%                if img_handle is empty, make new figure.
%
%   ydata      : plot data
%
%   header     : header of 
%  
%  varargin is pari of Option and Value.
% = = = = = = = = = = = = = = = = = = = = 
%  BRAIN_TYPE : Plot Brain type
%        0 : MATLAB mri data
%        1 : circle
%
%  ColorAXIS : Color Axis
%
%  ColrMapID : ID of Color map
%     where ID of Color map is defined in
%     osp_set_colormap
%
% = = = = = = = = = = = = = = = = = = = = 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



  if isempty(img_handle),
    img_handle.figure1 = figure;
  end
  BRAIN_TYPE = 0;
  ColorAXIS  = [-1, 1];
  ColorMapID = 1; % Color map ID :in osp.
  for idx=2:2:length(varargin),
    eval([varargin{idx-1} ' = varargin{idx};']);
  end

  % -- Normal Image --
  % figure setup, I want to Menubar
  % set(image_h,'DoubleBuffer','on','Menubar','none')
  if ~isfield(img_handle,'AXES1'),
    img_handle.AXES1 = axes;
  end


  % ==================================
  % Brain Ploting
  % ==================================
  if ~isfield(img_handle,'BRAIN_DATA'),
    switch BRAIN_TYPE,
     case 1,
      % circle 
      bn=header.Pos.D3.Base.Nasion;
      bl=header.Pos.D3.Base.LeftEar;
      br=header.Pos.D3.Base.RightEar;
  
      % lr = br-l;
      % lrp2 = (br-l)/2;
      % cenlr = bl + lr2;
      % cen   = cenlr + 1/3 * (bn-cenlr);
      % where,
      % cenlr = (br+bl)/2;
      % cen   = 2/3 + cenlr + bn/3;
      % so,
      cen = (bn + bl + br)/3;cen=cen(:);
      r   = sqrt( sum((br-bl).*(br-bl)) );
      bph = plot3([bn(1); bl(1); br(1)], ...
          [bn(2); bl(2); br(2)], ...
          [bn(3); bl(3); br(3)], 'b.');
      clear bn br bl;
      %r   = r*1.15; % ( 30 [degree] + ,-> 2/sqrt(3);
      r = r*1.05;
      cen(3) = cen(3) - 0.4 * r;

      load('cubic_patch.mat','cubic_patch');
      cubic_patch.vertices = cubic_patch.vertices * r ...
          + repmat(cen',size(cubic_patch.vertices,1),1);
      
      img_handle.BRAIN_DATA = ...
          patch(cubic_patch);
      alpha(0.05);
      set(img_handle.BRAIN_DATA, ...
          'FaceColor','red', ...
          'EdgeColor','none');
      view(3);
     case 0,
      % MRI ...?
      % load mri;
      % .. Ref) setProbePosition.
      % TODO
      load mri;
      D=squeeze(D);
      x0=[1:size(D,1)]-size(D,1)/2; % origin set
      y0=[1:size(D,2)]-85;          % origin set
      z0=[1:size(D,3)]-4;           % origin set

      % Rate Set
      x0 = x0*160/length(x0);
      y0 = y0*160/length(x0);
      z0 = z0*160/length(x0);

      set(img_handle.figure1,'Render', 'OpenGL');
      Ds = smooth3(D);
      img_handle.BRAIN_DATA = ...
	  patch(isosurface(x0,y0,z0,Ds,5), ...
		'FaceColor', [1, .75, .7], ...
		'EdgeColor', 'none');
      alpha(0.7);
      view(3);

     otherwise,
      error('no brain type defined');
    end, % end of Brain switch 
  end
    
  % ==================================
  % Color setting..
  % ==================================
  % ColorAXIS;
  osp_set_colormap(ColorMapID);
  map = colormap;
  mapsz = size(map,1);
  mapunit = mapsz/(ColorAXIS(2) - ColorAXIS(1));
  

  % ==================================
  % Plot smal 3D-Cubic,
  % or Refresh Color-Data 
  % ==================================
  if isfield(img_handle,'CH_CUBE'),
    for idx=1:length(ydata),
	if isnan(ydata(idx)), continue; end
	if isnan(img_handle.CH_CUBE(idx)), continue; end

	mapidx  = round( (ydata(idx)-ColorAXIS(1)) * mapunit);
	if mapidx<=0, mapidx=1; end
	if mapidx>mapsz, mapidx=mapsz; end
	set(img_handle.CH_CUBE(idx), ...
	    'FaceColor', map(mapidx,:));
    end
  else,
    img_handle.CH_CUBE=[];
    load('cubic_patch.mat','cubic_patch');
    cubic_patch0 = cubic_patch;
    ch_pos3 = header.Pos.D3.P;

    for idx=1:size(ch_pos3,1),
      if isnan(ydata(idx)),
	img_handle.CH_CUBE(idx)=NaN;
	continue; 
      end

      cubic_patch0.vertices = cubic_patch.vertices * 4.5 ...
	  + repmat(ch_pos3(idx,:),size(cubic_patch.vertices,1),1);
      img_handle.CH_CUBE(idx) = ...
	  patch(cubic_patch0);
      mapidx  = round( (ydata(idx)-ColorAXIS(1)) * mapunit);
      if mapidx<=0, mapidx=1; end
      if mapidx>mapsz, mapidx=mapsz; end
      set(img_handle.CH_CUBE(idx), ...
	  'FaceColor', map(mapidx,:), ...
	  'LineStyle', 'none');
    end
    caxis(ColorAXIS); colorbar2;
  end
  
  % Lightnig
  if ~isfield(img_handle,'LIGHT_00'),
    img_handle.LIGHT_00 = lightangle(45,30);
    lighting phong;  
  end
    
return;
