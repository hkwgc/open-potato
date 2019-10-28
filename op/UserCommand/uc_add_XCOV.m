function [cdata,chdata]=uc_add_XCOV(cdata,chdata,k1,k2,DelayTime)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




sz=size(cdata);
XC=zeros(DelayTime*2+1,sz(2),size(k1,2)*size(k2,2));

cnt=1;
for L1=k1%kind1
	for L2=k2%kind2
		for L3=1:sz(2)%ch
			XC(:,L3,cnt)=xcov(squeeze(cdata(:,L3,L1)),squeeze(cdata(:,L3,L2)),DelayTime,'coeff');
			cnt=cnt+1;
		end
	end
end

chdata.TAGs.XCOV.XC=XC;
chdata.TAGs.XCOV.k1=k1;
chdata.TAGs.XCOV.k2=k2;
chdata.TAGs.XCOV.DelayTime=DelayTime;
