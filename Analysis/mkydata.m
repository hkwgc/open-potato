function ydata=mkydata(data,stmdat)
% YDATA=mkydata(DATA,STMDATA) : Make Y-data
%
%  for Operation  ::: See Type :::
%
% -- Usage in plot_stat2 -
%
% - Input -
%   DATA is HB-data corresponds to 
%    1. [ Time Channel HBtype] = size(data)
%    2. [Block Time Channel HBtype] = size(data)
%     where HBtype is 3
%
%   STMDATA is Stimilation TiMing DATA
%    [ Block Time] = size(data)
%      
% - Oputput -
%    YDATA : 3D-data Time x Channel x Type 
%       if Type is 1-HBtype (=3)
%          HB-data average of Block : [ Time Channel HBtype] 
%       if Type is HBtype+1 (=4) 
%          STMDATA ( stimilation timing) of 1-st Block

% Comment : Added 21-Oct-2004

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if length(size(data))==3
    y=zeros(size(data,1), size(data,2), 4); 
    y(:,:,1:3)=data;
    y(:,:,4)=repmat(stmdat,[1 size(data,2)]) ;
else
    data0=zeros(size(data,2),size(data,3),size(data,4));
    data0=squeeze(mean(data,1));
    y=zeros(size(data,2), size(data,3), 4); 
    y(:,:,1:3)=data0;
    y(:,:,4)=repmat(stmdat(:,1),[1 size(data,3)]) ;
end

ydata=y;

% === Grep Result 27-Dec-2004 ===
% Analysis/statistical_analysis.m
%    :113:ydata=mkydata(BCW_MB,BCW_MBP.modstim);
%    :367:% ydata=mkydata(BCW_MB,BCW_MBP.modstim);
% 
% viewer/plot_stat2.m
%    :281:ydata=mkydata(data,BCW_MBP.modstim);
% 
% viewer/signal_viewer.m
%    :532:    ydata=mkydata(signal.chb,signal.modstim);
%    :538:    ydata=mkydata(BCW_MB,BCW_MBP.modstim);
