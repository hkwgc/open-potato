function [data,hdata]=uc_f_inv_fitting(data,hdata,A)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if A.fig figure;end
fc=fft(data(:,:,A.Kind));
sz_kind=size(data,3);
%data(:,:,end+1)=fc;hdata.TAGs.DataTag{end+1}='f_inv_fitted';
uf=size(fc,1)/10;
f1=A.f1;
x=1/uf:1/uf:f1;
ch=size(data,2);
for k=1:ch % ch loop
	if A.fig, subplot(ceil(sqrt(ch)),ceil(sqrt(ch)),k);hold on;end
	
	
	% real part
	fc1=fc(:,k);
	f=real(fc1);
	y=f(1:fix(uf*f1));y(find(y==0))=1;y=real(log(y))';
	p=polyfit(log(x),y,1);py=polyval(p,log(x));
	fr=f;
	%plot(log(x),y,'b');plot(log(x),py,'b:');plot(log(x),y-py,'r');
	if A.fig,
		plot(x,y,'b');plot(x,py,'b:');plot(x,y-py,'b-.');
	end
	f(1:fix(uf*f1))=f(1:fix(uf*f1))-exp(py');
	fr=f;

	% imaginary part
	f=imag(fc1);
	y=f(1:fix(uf*f1));y(find(y==0))=1;y=real(log(y))';
	p=polyfit(log(x),y,1);py=polyval(p,log(x));
	fi=f;
	
	if A.fig
		plot(x,y,'r');plot(x,py,'r:');plot(x,y-py,'r-.');
	end
	
	f(1:fix(uf*f1))=f(1:fix(uf*f1))-exp(py');

	f=fr+fi*i;
	d=real(ifft(f));
	data(:,k,A.Kind)=d;
end

if A.fig, legend({'real original','fitted','denoised','image original','fitted','denoised'});end