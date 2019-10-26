function [data]=uc_BaseLineFitting(hdata,data,n,t)

t=t*(1000/hdata.samplingperiod);
t=ceil(t);%- bug fix TK 2011/04/13

if ndims(data)==3,
	%continuous
	data=calc(data,n,t);
else
	%block
	for i=1:size(data,1)
		data(i,:,:,:)=calc(squeeze(data(i,:,:,:)),n,t);
	end
	clear i
end

clear t n

%=== sub func
%  2010.12.9 : speed-up
function data=calc(data,n,t)
if 0
  data1=calc_old(data,n,t);
  data2=calc_new(data,n,t);
  xx=abs(data1-data2);
  disp(max(xx(:)));
else
  data=calc_new(data,n,t);
end


function data=calc_old(data,n,t)
	time=size(data,1);
	X=[1:t, time-t:time];
	for ch=1:size(data,2)
		for kind=1:size(data,3)
			P=polyfit(X,squeeze(data(X,ch,kind))',n);
			data(:,ch,kind)=data(:,ch,kind)-polyval(P,1:time)';
		end
  end
  
function data=calc_new(data,n,t)
if n==0
	time=size(data,1);
	X=[1:t, time-t:time];
  mv=mean(data(X,:,:));
  data=data-repmat(mv,[size(data,1),1,1]);
elseif n==1
	time=size(data,1);
	X=[1:t, time-t:time];
  x=[X', ones(size(X'))];
	for ch=1:size(data,2)
		for kind=1:size(data,3)
      y=squeeze(data(X,ch,kind));
			P=x\y;
      data(:,ch,kind)=data(:,ch,kind)-[1:time]'*P(1)-P(2);
		end
  end
else
	time=size(data,1);
	X=[1:t, time-t:time];
	for ch=1:size(data,2)
		for kind=1:size(data,3)
			P=polyfit(X,squeeze(data(X,ch,kind))',n);
			data(:,ch,kind)=data(:,ch,kind)-polyval(P,1:time)';
		end
  end
end
