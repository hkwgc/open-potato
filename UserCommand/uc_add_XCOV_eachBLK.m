function [data,hdata]=uc_add_XCOV_eachBLK(data,hdata,k1,k2)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



sz=size(data);
k_sz=size(data,4);
data=cat(4,data,zeros(sz(1),sz(2),sz(3),size(k2,2)*size(k1,1)));

for L1=1:sz(3)%channel
	cnt_k=1;
	for L2=k2% kind2
		for L3=k1% kind1
			for blk=1:sz(1)% block
				XC=xcov(squeeze(data(blk,:,L1,L2)),squeeze(data(blk,:,L1,L3)),round(sz(2)/2),'coeff');
				data(blk,:,L1,sz(4)+cnt_k)=XC(1,1:sz(2));
			end
			cnt_k=cnt_k+1;
		end
	end
end

for i=k2
	for j=k1
		hdata.TAGs.DataTag{end+1}=sprintf('xcov-[%d,%d]',i,j);
	end
end

			