function nx=normalization(x,varargin)
% nx=normalization(x,dim)
% nx = ( x - mean(x) ) ./ (max(x) - min(x))
%
%                                              by TK@HARL 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin>1
	dim=varargin{1};
else
	dim=1;
end

minX=min(x,[],dim);
maxX=max(x,[],dim);
spX=maxX-minX;

aveX=mean(x,dim);

sz=size(x);
sz([1:ndims(x)]~=dim)=1;
nx = (x-repmat(aveX,sz))./repmat(spX,sz);

