function [hdata,data]=P3P_truncate_flagged_blocks(hdata,data)

tg=sum(hdata.flag,3)==0;% find ID for flag-off <-means good data 

data=data(tg,:,:,:);

hdata.stimTC2=hdata.stimTC2(tg,:);
hdata.stimkind=hdata.stimkind(tg,:);