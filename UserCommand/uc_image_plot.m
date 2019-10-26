function varargout = uc_image_plot(header, data, idim, varargin),
% Image Plot for User Command Data
%
%  [h, strPlotData]=uc_image_plot(header, data, idim, varargin)
%
% --- Input ---
%   header : Header of User Command Data 
% 
%   data   : Data parts of User Command Data 
% 
%   idim   : Dimension of image (2 or 3).
% 
% varargin is parir of Option and Value.
% = = = = = = = = = = = = = = = = = = = =
%  FigBGcolor : [0.75 0.75 0.75];  
%      Figure Background Color
% 
%  PlotKind   : 1:size(data,ndims(data)); 
%      Plot Data-Kind
%
%  DC_OPTION  : ''
%       Data Change option.
%       Data-Option : listed in pop_data_chaneg_v1.
%      'HB data', 'FFT Power', 'FFT Phase' and so on.
%
%  PlotTime  : 1
%    Time of Image.
%
%  MEAN_PERIOD: 1
%    Value that used in image,
%    is mean-value of around MEAN_PERIOD.
%
%  MODE : 'POINTS'
%    Image Mode :
%        'POINTS' ,
%        'INTERPED',
%        'smmoth POINTS',
%        or '3D cubic'.
%   
%  INTERP_METHOD : 'linear'
%     When Mode is INTERPED,
%     set interpolate method.
%     INTERP_METHOD is as same as 
%     GRIDDATA's method.
%
%  INTERP_STEP : 3
%     When Mode is INTERPED,
%     Image's Mesh Grid size is
%     Original size multiple INTERP_STEP
%
%  ColorMap0 : 1
%      Color Map ID of Image.
%      This Number is defined in
%      "OSP_SET_COLORMAP".
%
%  CAXIS_ZERO: 0
%      Is Center of CAXIS Zero?
%        0 : No, it is not.
%        1 : Yes, it is.
%
%  CMAX_AXIS : -- auto --
%       Setting of Maximum of Color-Axis.
%       when this is empty, automatic.
%       when scaler use caxis = [CMIN_AXIS CMAX_AXIS]
%
%  CMIN_AXIS : -- auto --
%        Setting of Minimum of Color-Axis.
%       when this is empty, automatic.
%       when scaler use caxis = [CMIN_AXIS CMAX_AXIS]
%
%  MASK_CH : []
%       Select MASK, that value set 0.
%
%  AXES_TITLE: ''
%       AXES Titie if there.
%
% = = = = = = = = = = = = = = = = = = = =
%
% --- Output ---
%  h           : 
%    handles of axes, figure.
%  strPlotData : 
%    Structure of Plot Data.
%    ... not string, sory for bad naming.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See also SIGNAL_VIEWER, PLOT_HBDATA,
%           UC_DATALOAD, UC_BLOCKING, 
%           UC_IMAGE, Cube_Plot.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.07.20
% $Id: uc_image_plot.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.2
%   Multi Probe OK.
%   3D Cubic Mode OK.

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  = === Argument Check ====  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % * number o arrgument is 2-103.
  msg=nargchk(2, 103, nargin);
  if ~isempty(msg), error(msg); end

  % * Image Dimension is 2 in default.
  if nargin<3, 
    idim = 2; 
  else,
    try,
      if ~idim==2 && i~dim==3,
	error('Dimension of Image must be 2 or 3');
      end
    catch,
      rethrow(lasterror);
    end
  end
  

  % * Option must be pair
  n = length(varargin);
  if bitget(n,1)==1
    error('Invalid option/value pair arguments');
  end
  clear n msg; % clear variabel.

  % data information
  if ndims(data)~=3 && ndims(data)~=4
    error(['Dimension of DATA matrix is in corerct.' ...
            ' : ' num2str(ndims(data))]);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % === Default Option Setting ===
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Variable been able to set directory by Argument. 
  argvars    = {'FigBGcolor', ...
		'DC_OPTION', ...
		'PlotKind', ...
		'PlotTime', ...
		'MEAN_PERIOD', ...
		'MODE', ...
		'INTERP_METHOD', ...
		'INTERP_STEP', ...
		'ColorMap0', ...
		'CAXIS_ZERO', ...
		'CMAX_AXIS', ...
		'CMIN_AXIS', ...
		'MASK_CH', ...
		'AXES_TITLE', ...
		'MultiProbeID', ... % dumy
		'ChannelDistribution' ... % dumy
	       }; 
  %'STIMPLOT', ...

  % Figure Background Color 
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  FigBGcolor = [0.75 0.75 0.75];         % default : gray
  % Stimulation Plot On/Off 
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  STIMPLOT   = 'off';
  % DC_OPTION : Data-Change-Option
  %~~~~~~~~~~~~~~~~~~~
  DC_OPTION = '';
  % Plot Kind
  %~~~~~~~~~~
  PlotKind   = 1:size(data,ndims(data)); % Default Plot all 
  % Plot Time
  %~~~~~~~~~~
  PlotTime   = 1;
  % MEAN_PERIOD : use around value
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MEAN_PERIOD = 1;
  % MODE : Image Mode
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MODE = 'POINTS';
  % INTERP_METHOD : how to interp
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  INTERP_METHOD = 'linear';
  % INTERP_STEP : how many interp
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  INTERP_STEP = 3;
  % ColorMap0 : (colormap number for osp)
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ColorMap0 = 1;
  % CAXIS_ZERO : Is Center of CAXIS Zero?
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  CAXIS_ZERO = 0;
  % CMAX_AXIS : Manual setting of Maximum of Color-Axis.
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  CMAX_AXIS=[];
  % CMAX_AXIS : Manual setting of Minimum of Color-Axis.
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  CMIN_AXIS=[];
  % MASK_CH : Un-used Channel.
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MASK_CH=[];
  % AXES_TITLE : AXES_TITLE on/off
  %~~~~~~~~~~~~~~~~~~~
  AXES_TITLE = 'off';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ===     Read Options     ===  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for id = 1:2:length(varargin)

    % Setting Variable
    if any(strcmp(argvars, varargin{id})),
      eval([varargin{id} ' = varargin{id+1};']);continue;
    end
    
    switch varargin{id}
     otherwise,
      error(['Undefined Option : ' varargin{id}]);
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ========= Start From Here ========= 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % **************
  % * Make Ydata *
  % **************

  % ---------------------------
  % * Block Data : Mean Block 
  % --------------------------
  if ndims(data)==4,
    %--- 
    data = uc_blockmean(data, header);
  end

  % ---------------------
  % * Data Change Option
  % ---------------------
  % If Data change Option
  axis_label.x ='time [sec]';
  axis_label.y ='HB data';
  unit = 1000/header.samplingperiod;
  if ~isempty(DC_OPTION),
    % === Plot Data Option ==
    [data , axis_label, unit] ...
	= pop_data_change_v1(DC_OPTION, data,...
			     axis_label, unit);
    header.sampleperiod = 1000/unit; 
  end
  clear DC_OPTION unit;
  
  % ------------------------
  % * get Data at Plot Time 
  % ------------------------
  % time_s = round(PlotTime - MEAN_PERIOD/2);
  % time_e = round(time_s   + MEAN_PERIOD-1);
  time_s = PlotTime - fix(MEAN_PERIOD/2);
  time_e = PlotTime + fix(MEAN_PERIOD/2);
  if (time_s < 1) time_s=1; end
  %if (time_e < 1) time_e=1; end
  if (time_e > size(data,1)) time_e=size(data,1); end
  ydata = nan_fcn('mean', data(time_s:time_e,:,:), 1);
  sz = size(ydata); sz(1)=[]; if length(sz)==1, sz(2)=1; end
  ydata = reshape(ydata,sz);
  clear PlotTime MEAN_PERIOD time_s time_e sz data;

  % ---------------------------
  % * Set 0 to Un-used Channel.
  % ---------------------------
  if ~isempty(MASK_CH),
    tmp = find(MASK_CH<=0);
    if ~ismepty(tmp), MASK_CH(tmp)=[]; end
    tmp = find(MASK_CH>size(ydata,1));
    if ~ismepty(tmp), MASK_CH(tmp)=[]; end
    ydata(MASK_CH,:)=0;
  end
  clear MASK_CH;

  % ---------------------------
  % Make Image Data 
  %  and get max & min.
  % ---------------------------
  cmax=-Inf; cmin=Inf;
  switch MODE,
   case 'POINTS',
     mode=1;
   case 'INTERPED',
    mode=2;
   case 'smmoth POINTS',
    mode=3;
   case '3D cubic',
    if idim==3,
      mode=4;
    else,
      msg=sprintf(['OSP Error!!!\n' ...
		   ' << Inputed Image mode : 3D cubic    >>\n' ...
		   ' <<  is undefined,                   >>\n' ...
		   ' << when Dimension of image is not 3 >>\n']);
      error(msg);
    end % if, else -> Dimension of image is not 3.
   otherwise,
    msg=sprintf(['OSP Error!!!\n' ...
		 ' << Inputed Image mode : %s >>\n' ...
		 ' <<  is undefined in UC_IMAGE_PLOT>>\n'], ...
		MODE);
    error(msg);
  end
  c={}; x={};y={}; 
  if mode~=4,
    for pkind=PlotKind,
      [c0, x0, y0]=osp_chnl2imageM(ydata(:,pkind)', header, ...
				   mode, INTERP_STEP, INTERP_METHOD);
      for plnum=1:length(c0),
	c{end+1}=c0{plnum}; x{end+1}=x0{plnum}; y{end+1}=y0{plnum};
	cmax = max([cmax; c{end}(:)]);
	cmin = min([cmin; c{end}(:)]);
      end
    end
  else,
    cmax = max(ydata(:));
    cmin = min(ydata(:));
    c{1} = ydata;
  end
  clear ydata c0 x0 y0;

  % if there is CAXIS input.
  if ~isempty(CMAX_AXIS),
    cmax = CMAX_AXIS;
    cmin = CMIN_AXIS;
    if cmax < cmin,
      tmp  = cmax; cmax = cmin; cmin = tmp;
    end
  end
  if cmax==cmin,
    cmax = cmax + 1; cmin = cmin - 1;
  end

  % Zero fix?
  if CAXIS_ZERO,
    cmax = max([abs(cmax) abs(cmin)]);
    cmin = -cmax;
  end

  % ****************
  %   Start Ploting 
  % ****************
  % ---------------------------
  % Make New Figure
  % ---------------------------
  % set name.
  name = 'Untitled';
  if isfield(header.TAGs,'filename'),
    name = header.TAGs.filename;
    if iscell(name),name=name{1};end
  end
  h.figure1 = figure;
  set(h.figure1, ...
      'units',  'normalized', ...
      'Color',  FigBGcolor, ...
      'TAG'  ,  'UC_IMAGE_PLOT_FIG', ...
      'NAME' ,  name);

  % ---------------------------
  % Plot axis
  % ---------------------------
  sz = length(PlotKind);
  if idim==3 && mode==4,
    % Cubic Mode 
    % @since 1.2
    try,
        h=Cube_Plot(h,c{1}, header, ...
            'ColorAXIS', [cmin,cmax], ...
            'ColorMapID', ColorMap0);
    catch,
      close(image_h);
      msg = sprintf(['OSP Error!!!\n' ...
                     ' << Plot Error      >>\n' ...
                     ' << %s >>\n'], ...
                    lasterr);
      errordlg(msg);
      return;
    end
  elseif idim==3, 
    % === 3D plot ===
    h.axes0 = axes;
    set(h.axes0,'Clim',[cmin, cmax]);
    set(h.figure1, ...
        'Renderer', 'OpenGL', ...
        'units', 'pixels');
    ecode = hbimage3d_plot('new',h.axes0, h.figure1);
    if ecode~=0,
      error('Plot Error');
    end

    % Probe Shape
    tmp = struct('x',80,'y',80);

    % set Probe size
    shape.size=tmp;
    % set Probe Curvature-Radius
    shape.cr=tmp; 

    
    plist  = [40 30 130; ...
	      40 130 130];

    for plnum=1:length(c),
      if plnum<size(plist,1),
	p.point=plist(plnum,:); % Probe Position.
      else,
	p.point=plist(end,:); % Probe Position.
      end

      hbimage3d_plot('setphbid', h.axes0,plnum);
      hbimage3d_plot('plot', h.axes0, ...
		     c{plnum}', ...
		     shape,p);
      h.plane(plnum)   = hbimage3d_plot('getPrbH', h.axes0);
    end
    colorbar2;
    title([header.TAGs.DataTag{PlotKind(1)}]);

  else,
    % === 2D plot ===
    plnum0 = round(length(c)/sz); % must be integer
    planeID = 1;
    for ii=1:sz
      htmp = subplot(sz, 1, ii);
      h    = setfield(h,['axes' num2str(ii)],htmp);
      hold on;
      for plnum=1:plnum0,
          ih=imagesc(x{planeID},y{planeID}, ...
              c{planeID}',[cmin, cmax]);
          set(ih,'Tag',sprintf('Image%d',planeID));
          planeID = planeID+1;
      end
      colorbar2;
      axis auto;
      axis image;
      axis off
      title(header.TAGs.DataTag{PlotKind(ii)});
    end
    uimenu_Osp_Graph_Option(h.figure1);
  end

  % set colormap
  osp_set_colormap(ColorMap0);
  
  % Output
  if nargout>=1,
    varargout{1}=h;
  end
return;
