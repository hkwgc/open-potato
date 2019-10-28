function [data,hdata]=P3P_CopyData(data,hdata,kinds)
% [data,hdata]=P3P_CopyData(data,hdata,kinds)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


dn=hdata.TAGs.DataTag;
for k=1:length(kinds)
	nm=getNewName(dn,kinds(k));
	
	if ndims(data)==3
		newdata=data(:,:,kinds(k));
	else
		newdata=data(:,:,:,kinds(k));
	end	
	[data,hdata]=POTATo_Sub_AddDataKind(data,hdata,newdata,nm);
	
end

function nm=getNewName(dn,n,varargin)

if nargin==2
	n2=1;
else
	n2=varargin{1};
end

if isempty(find(strcmp(dn,[dn{n} '_' num2str(n2)]), 1))
	nm=[dn{n} '_' num2str(n2)];
else
	nm=getNewName(dn,n,n2+1);
end


	


	


