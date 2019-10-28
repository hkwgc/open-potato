function hdata=P3P_MarkADD(hdata, A)

%-----------
%- version 1.0.1 bugfixed: new -> add..



if hdata.StimMode == -1
	hdata.StimMode  =A.MODE;
elseif hdata.StimMode ~= A.MODE
    warndlg(sprintf('stim/mark mode differs.\nThis filter was skipped.'),'Mark ADD');
    return;
end

%---
st=fix(str2num(A.ST)*1000/hdata.samplingperiod);
kind=str2num(A.Kind);
if length(st) ~= length(kind)
    if length(kind)==1
        kind=repmat(kind,[1 length(st)]);
    else
        warndlg(sprintf('Length of kind numbers differs.\nThis filter was skipped.'),'Mark ADD');
        return;
    end
end
%---

if A.MODE == 2 % BLOCK
    dur=fix(str2num(A.Dur)*1000/hdata.samplingperiod);
    if length(st) ~= length(dur)
        if length(dur)==1
            dur=repmat(dur,[1 length(st)]);
        else
            warndlg(sprintf('Length of duration numbers differs.\nThis filter was skipped.'),'Mark ADD');
            return;
        end
		end
		
		s=[kind;st;st+dur]';
		hdata.stim = cat(1,hdata.stim,s);
    
    for k=1:length(st)
        hdata.stimTC([st(k),st(k)+dur(k)])=kind(k);
    end
    
else % EVENT
		s=[kind;st;st]';
		hdata.stim = cat(1,hdata.stim,s);
    
    for k=1:length(st)
        hdata.stimTC(st(k))=kind(k);
    end
    
end