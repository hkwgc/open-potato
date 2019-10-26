function v=stmedian(d,A)
%- A.averaging: data number for averaging 
%- A.resampling: multiple
%- A.dim: dimension for median

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% sz=size(d);
% d=d(:);

%=== Remove Nan
%d(isnan(d))=[];

% %=== Remove ourliers
% P=POTATo_sub_FiveNumberSummaries(d);
% while 1
% 	P1=POTATo_sub_FiveNumberSummaries(P.innerMember2);
% 	if abs(P1.Max-P.Max)+abs(P1.Min-P.Min)<0.0001, break;end
% 	P=P1;
% end
% d=P1.innerMember2;



%=== Resampling x10
sz=size(d);
rps=ones(1,length(sz));
rps(A.dim)=A.resampling*A.averaging;
d=repmat(d,rps);

str=[];
for k=1:ndims(d)
	if k==A.dim
		str=[str sprintf('randperm(%d),',size(d,A.dim))];
	else
		str=[str ':,'];
	end
end
str=str(1:end-1);
d=eval(sprintf('d(%s)',str));


str=[];
for k=1:ndims(d)
	if k==A.dim
		str=[str '%d %d '];
	else
		str=[str num2str(sz(k)) ' '];
	end
end
str=sprintf(str,sz(A.dim)*A.resampling,A.averaging);
d=eval(sprintf('reshape(d,[%s])',str));

d=squeeze(nanmean(d,A.dim+1));

%=== Median
v=squeeze(nanmedian(d, A.dim));



