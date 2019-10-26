function hdata=P3P_MarkSelect(hdata, A)
%-----------
%- version 1.0.2
%- TK@CRL 2013-05-07
%- 1.0.1 bug fixed. 2013-07-16
%- 1.0.2 bug fixed. 2014-01-17
%-----------


stimKind=hdata.stim(:,1);

switch A.MODE
	case 'Mark tag'
		u=unique(stimKind);		
		%tg=stimKind==u(A.TargetTag);
		tg=ismember(stimKind,u(A.TargetTag));%- debug TK@CRL 17-Jan-2014
	case 'Mark order'
		tg=A.TargetIDX;
end

hdata.stim=hdata.stim(tg,:);
hdata.stimTC=zeros(1,length(hdata.stimTC));
hdata.stimTC(hdata.stim(:,2))=hdata.stim(:,1);
hdata.stimTC(hdata.stim(:,3))=hdata.stim(:,1);
