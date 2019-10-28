function [hdata]=P3P_BlockGroupSelect(hdata,group)

hdata.stim = hdata.stim(eval(['hdata.TAGs.BlockGroup.' group ]),:);

hdata.stimTC(:)=0;
for loop=1:size(hdata.stim,1)
	hdata.stimTC(hdata.stim(loop,2))=hdata.stim(loop,1);
	hdata.stimTC(hdata.stim(loop,3))=hdata.stim(loop,1);
end
