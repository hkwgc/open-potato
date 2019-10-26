function [patch_h, txt_h]=patch_arrow(ax_h, txt,type);
% Plot Arrow
%
% Syntax : 
% [patch_h, txt_h]=patch_arrow(ax_h, txt,type);
%
%  plot Patch Allow to ax_h with text
%  ax_h is axes handle to plot.
%   default new axes.
%  txt is charactor of plotting,
%   default is null
%  type is plot type,
%   if type is 'leftnormal',
%   path shape is Left arow, or right allow. 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



  % Default Argument
  if nargin < 1, figure; ax_h=axes; end
  if nargin < 2, txt=' '; end
  if nargin < 3, type=' '; end

  
  axes(ax_h); cla; hold on;
  axis off;
  axis([0 1 0 1]);
  set(ax_h, 'Color','none')

  % Plot Patch
  switch type
   case 'leftnormal'
     x = [  1; 0.4; 0.5;   0; 0.5; 0.4;   1;   1];
     y = [0.3; 0.3; 0.0; 0.5;   1; 0.7; 0.7; 0.3];
     patch_h = patch(x-0.02, y+0.03, [1 1 0.9]); % right
     set(patch_h,'LineStyle','none');
     patch_h = patch(x+0.03, y-0.04, [0.3 0.3 0.3]); % shadow
     set(patch_h,'LineStyle','none');
     c = [.9 .9 .6];

    % Default arrow
   otherwise
     x = [  0; 0.6; 0.5;   1; 0.5; 0.6;   0;   0];
     y = [0.3; 0.3; 0.0; 0.5;   1; 0.7; 0.7; 0.3];
     patch_h = patch(x-0.02, y+0.03, [1 1 0.9]); % right
     set(patch_h,'LineStyle','none');
     patch_h = patch(x+0.03, y-0.04, [0.3 0.3 0.3]); % shadow
     set(patch_h,'LineStyle','none');
     c = [.9 .9 .6];
  end
  patch_h = patch(x, y, c);
  set(patch_h, 'LineStyle','none');

  % text
  txt_h = text(0.02, 0.5,txt);

  
  


