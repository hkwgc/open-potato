function [hdata]=P3P_SetBlockGrouping(hdata,blockA, blockB,flagApplyTo)

if ~isempty(blockA)
    hdata.TAGs.BlockGroup.A = blockA;
end

if ~isempty(blockB)
    hdata.TAGs.BlockGroup.B = blockB;
end

if flagApplyTo == 1
    %reset
    hdata.stim(:,1)=0;
    hdata.stimTC(:)=0;
    %apply A
    hdata.stim(hdata.TAGs.BlockGroup.A,1)=1;
    hdata.stimTC(hdata.stim(hdata.TAGs.BlockGroup.A,2))=1;
    hdata.stimTC(hdata.stim(hdata.TAGs.BlockGroup.A,3))=1;
    %apply B
    hdata.stim(hdata.TAGs.BlockGroup.B,1)=2;
    hdata.stimTC(hdata.stim(hdata.TAGs.BlockGroup.B,2))=2;
    hdata.stimTC(hdata.stim(hdata.TAGs.BlockGroup.B,3))=2;
    
    tg = find(hdata.stim(:,1) > 0);
    hdata.stim = hdata.stim(tg,:);    
end
    
    