function [data,hdata]=POTATo_Sub_AddDataKind(data,hdata,newdata,name)
%-
%-[data,hdata]=POTATo_Sub_AddDataKind(data,hdata,newdata,name)
%-

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if ndims(data)==3 %- continuous
	data=cat(3,data,newdata);	
elseif ndims(data)==4 %- segmented
	data=cat(4,data,newdata);
end
hdata.TAGs.DataTag{end+1}=name;
