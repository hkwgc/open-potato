function osp_g_ttest_bar( data );
%
% osp_g_ttest_bar( data )
% bar plot for ttest results
% sub-routine for cod_subplot_*.m
%
% IN:
% data(3,1,3): ([ t-value, p-value, h-value], selected channel, [Oxy, Deoxy, Total])
%
% 030623 tk

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



bar( squeeze(data));
cmp=zeros(3,3);cmp(1,1)=1;cmp(2,3)=1;colormap(cmp);
set(gca, 'XTick',[1:3], 'XTickLabel', {'t','p','H',''})
