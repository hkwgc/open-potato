function data=P3P_Flag2Zero(hdata,data)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


tg=squeeze(sum(hdata.flag,1))>0;

for k=1:size(data,3)
	tmp=data(:,:,k);
	tmp(tg)=0;
	data(:,:,k)=tmp;
end