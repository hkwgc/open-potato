function [data, header] = uc_smoothing(data,header,N,M)
% Add Raw data to User Command (Continuous-Data)
%
% Syntax:
% [data, header] = uc_addraw(data,header,N);
%
%   Where data and header must be continuous-data of
%  User-Commnad.
%   This function is available only ETG file format.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.07.21
% $Id: uc_smoothing.m 273 2012-03-12 05:45:33Z Katura $
%
% Reversion 1.00, Date 07.21
%   No check..

msg=nargchk(4,4,nargin);
if ~isempty(msg), error(msg), end
msg=nargoutchk(2,2,nargout);
if ~isempty(msg), error(msg), end
sz=size(data);
for m=1:M
	for i1=1:sz(1)
		for i3=1:sz(3)
			for i4=1:sz(4)
				tmp=conv(ones(1,N)/N,data(i1,:,i3,i4));
				data(i1,:,i3,i4)=tmp(fix(N/2):end-ceil(N/2));
			end
		end
	end
	data(:,1:ceil(N/2),:,:)=repmat(data(:,ceil(N/2)+1,:,:),[1 ceil(N/2) 1 1]);
	data(:,end-ceil(N/2)+1:end,:,:)=repmat(data(:,end-ceil(N/2)-1,:,:),[1 ceil(N/2) 1 1]);
end

return;
