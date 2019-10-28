function [y y2]=envelope(a)
y=[];
h=hilbert(a);
k=angle(h)>0;
tg=find(diff(k)==1);
if isempty(tg), return;end;
p=find((a(tg)-a(tg+1))<0);
tg(p)=tg(p)+1;
y=interp1(tg,a(tg),1:size(a),'spline');

if nargout==2
	k=angle(h)<0;
	tg=find(diff(k)==1);
	if isempty(tg), return;end;
	p=find((a(tg)-a(tg+1))<0);
	tg(p)=tg(p)+1;
	y2=interp1(tg,a(tg),1:size(a),'spline');
end



