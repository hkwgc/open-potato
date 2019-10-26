function blkdata=mkblkydata2(data,stmdat,stnum,endnum,vecaxisx,flag)
% Make Blkdata
%
% Memo : Bug
% -- time might be change -- 
% if Selected Block1 is not equal to Block2
%
%  Data    : 4D Filltered HB-data : Block1 x Time x Channel x HBtype
%  stmdata : Stimilation timing matrix Block2 x Time   
%  stnum   : Start-number in Original-Data matrix Block2 x Time
%  endnum  : End  -number in Original-Data matrix Block2 x Time
% vecaxisx : time in Original-Data
%   flag   : not effective - any number

% Comment : 21-Oct-2004

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



dumd=zeros(size(data,1),size(data,2),size(data,3)+2,size(data,4));
tmp1=zeros(endnum(1)-stnum(1)+1,length(endnum));
tmp2=tmp1;

for i=1:length(stnum)
    tmp1(:,i)=vecaxisx(stnum(i):stnum(i)+endnum(1)-stnum(1))';
    if flag==0
        tmp2(:,i)=stmdat(:,i);
    else
        tmp2(:,i)=stmdat(:,1);
    end
end
for i=1:size(dumd,1)
    for ii=1:size(dumd,4)
        dumd(i,:,1,ii)=tmp1(:,i);
        dumd(i,:,end,ii)=tmp2(:,1);
    end
end

dumd(:,:,2:end-1,:)=data;

blkdata=permute(dumd, [2 3 1 4]);

% === Grep Result 27-Dec-2004 ===
% Analysis/statistical_analysis.m
% 215:blkdata=mkblkydata2(BCW_MB,BCW_MBP.modstim,BCW_MBP.stnum,BCW_MBP.endnum,vecaxisx,1);
% 266:blkdata=mkblkydata2(BCW_MB,BCW_MBP.modstim,BCW_MBP.stnum,BCW_MBP.endnum,vecaxisx,1);
% 
% viewer/plot_stat2.m
% 280:blkdata=mkblkydata2(data,BCW_MBP.modstim,BCW_MBP.stnum,BCW_MBP.endnum,vecaxisx,1);
