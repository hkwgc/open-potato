function [data,hdata]=P3P_Envelope(data,hdata,kind)

kn=size(data,3)+1;
for ch=1:size(data,2)

	a=data(:,ch,kind);
	y=envelope(a);
	data(:,ch,kn)=y;
end

hdata.TAGs.DataTag{end+1}=['Envelope: ' hdata.TAGs.DataTag{kind}];
