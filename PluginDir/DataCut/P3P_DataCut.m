function [hdata, data]=P3P_DataCut(hdata,data, st, ed)

if strcmp(st,'0'), S=1;
else S=eval(st)*1000/hdata.samplingperiod;
end

if strcmp(ed,'end'), E=size(data,1);
else E=eval(ed)*1000/hdata.samplingperiod;
end
	
P=[S:E];

data=data(P,:,:);
hdata.stimTC=hdata.stimTC(1,P);
hdata.flag=hdata.flag(1,P,:);
