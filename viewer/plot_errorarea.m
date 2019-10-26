function plot_errorarea(x, dat, step, c1, c2e,c2f, alpha);
%function plot_errorarea(x, dat, step, c1, c2e,c2f, alpha);
% input: 
%  x: x for plot
%  dat:data [ time, n ]
%  step: x step for errorarea x
%  c1: color of plot
%  c2e: color of errorarea edge, c2f: color of errorarea face
%  transp: transpearency of errorarea


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



szX=size(x,2);
stg=[1:step:szX];
pX=x(stg);
pY1=mean(dat(stg,:),2)'+std(dat(stg,:),[],2)';
pY2=mean(dat(stg,:),2)'-std(dat(stg,:),[],2)';
patch([pX pX(end:-1:1)],[pY1 pY2(end:-1:1)],size(pX,2),'edgecolor',c2e,'facecolor',c2f,'facealpha',alpha);
plot(x,mean(dat,2),c1,'linewidth',1)
