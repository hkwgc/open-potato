function osp_plots( d )
% osp_plots( d ) is plot for PCA
%  call from uiPCA.m.
%  osp_plots(PC(end:-1:1,:))
%
%  -- in old OSP version,
%     call from statistical_analysis.
%
% This comment was added in  24-May-2005.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% author : ?
% create : ?
% $Id: osp_plots.m 180 2011-05-19 09:34:28Z Katura $

f=0.95;
y=size(d,1);
if y>50, msgbox(sprintf('Too much LOWs: %d !',y),'ERROR','error');return;end
dy=f/(y-0);
m1=max(max(d));
m2=min(min(d));
for i=1:y
	subplot('position',[1-f 1-dy*(i-0)-dy*(1-f) f*f dy*f])
	plot(d(i,:))
	axis([ 1 size(d,2) m2 m1]);
	if i~=y, set(gca,'XTickLabel',[], 'YTickLabel', []);end
	ylabel(num2str(i));
end

	
