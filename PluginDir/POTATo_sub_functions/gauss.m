function g=gauss(n,FWHM)
%gauss(n,FWHM)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


g=zeros(n);
%m=n-1;
m=FWHM/sqrt(-log(0.5));
c=n-1;

for x=0:n-1
   for y=0:n-1
      g(x+1,y+1)=exp(-(((x-c/2)/m*2)^2+((y-c/2)/m*2)^2));
   end
end

s=sum(sum(g));
g=g/s;