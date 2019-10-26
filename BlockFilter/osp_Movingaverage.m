function [data] = osp_Movingaverage(data,N)
% osp_Movingaverage
% using convolution version


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : TK
% create : 2005.12.14
% $Id: osp_Movingaverage.m 284 2012-05-11 07:44:46Z Katura $
%

msg=nargchk(2,2,nargin);
if ~isempty(msg), error(msg), end
msg=nargoutchk(1,1,nargout);
if ~isempty(msg), error(msg), end
if (N==1), return; end % Do nothing

sz=size(data);
st=fix(N/2)+1;
if ndims(data)==4 % for block data
	ed=st+size(data,2)-1;
	for i1=1:sz(1)
		for i3=1:sz(3)
			for i4=1:sz(4)
				tmp=conv(ones(1,N)/N,data(i1,:,i3,i4));
				data(i1,:,i3,i4)=tmp(fix(N/2):end-ceil(N/2));
			end
		end
	end

elseif ndims(data)==3 % for continuous data
	ed=st+size(data,1)-1;
	for i2=1:sz(2)
		for i3=1:sz(3)
			tmp=conv(ones(1,N)/N,[data(:,i2,i3); repmat(data(end,i2,i3),[N 1])]);
			data(:,i2,i3)=tmp(st:ed);
		end
	end

else % averaging on 1st dimension
	sz=size(data);
	for i2=1:prod(sz(2:end))
		data(:,i2)=convn(data(:,i2),ones(N,1)/N,'same');
	end

end
return;
