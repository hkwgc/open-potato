function image_h = uc_image(header, data, varargin)
% Make Image of User-Command-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See also SIGNAL_VIEWER, HBIMAGE3D_PLOT,
%           OSP_IMAGEVIEW, UC_DATALOAD, 
%           UC_BLOCKING, UC_PLOT_DATA.
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
% create : 2005.04.29
% $Id: uc_image.m 180 2011-05-19 09:34:28Z Katura $

  % -- Pre Image-plotting  --
  % ( Do at dirst, to save memory )
  if ndims(data)==4,
    % Select plot stimkind
    if ~exist('stimkind','var'),
      stimkind=header.stimkind(1);
    end
    if ~all(stimkind==header.stimkind)
      warning(['Plot Stimulation Kind is ' ...
               num2str(stimkind) 'only.']);
    end

    data = uc_blockmean(data,header.stimkind, stimkind);
    mem_garbage;
  elseif ndims(data)~=3,
    error(['Dimension of DATA matrix is in corerct.' ...
	   ' : ' num2str(ndims(data))]);
  end

  % === Open Image ===
  image_h = osp_imageview;

  % == set image data ==
  setappdata(image_h, 'xdata', 1:size(data,1));
  setappdata(image_h, 'ydata', data);
  setappdata(image_h, 'HEADER', header);
  setappdata(image_h, 'measuremode', header.measuremode);
  clear data;

  % == set up osp_imageview
  set(image_h, 'Name', 'Image View : by uc_image');

  % -- Initiarize --
  osp_imageview('init_imageview', image_h, [], guidata(image_h));

return;

function varargout=make_imagedata(header)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Image Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------
%  Plot Image and set Application Data for Image
%  And Default Plot.
%
%  Setting Appricasion Data is following
%    ImagePlotKind  : Plot-Kind
%    measuremode    : Mesuremode -> channel position
%    xdata          : xdata is time span
%    ydata          : ydata is Image Data
% ---------------------------------------


function mem_garbage()
% memory garbage
rver=OSP_DATA('GET','ML_TB');
if isempty(rver),
  rver=200; % no garvage correction
else
  rver=rver.MATLAB;
end
if rver<16
  cwd = pwd; cd(tempdir);
  pack;  cd(cwd);
end
