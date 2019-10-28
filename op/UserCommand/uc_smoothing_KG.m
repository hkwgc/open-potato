function [data, header] = uc_smoothing(data,header,FWHM,M)
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
% $Id: uc_smoothing_KG.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.00, Date 07.21
%   No check..

  msg=nargchk(4,4,nargin);
  if ~isempty(msg), error(msg), end
  msg=nargoutchk(2,2,nargout);
  if ~isempty(msg), error(msg), end
  sz=size(data);
  
  x=-FWHM*1.5:FWHM*1.5; 
  s=FWHM/sqrt(8*log(2));
  G=(1/sqrt(2*pi)/s*exp(-x.^2/2/s^2));
  N=size(G,2);
  if ndims(data)==4,
	  for m=1:M
		  for i1=1:sz(1)
			  for i3=1:sz(3)
				  for i4=1:sz(4)
					  tmp=conv(G,data(i1,:,i3,i4));
					  data(i1,:,i3,i4)=tmp(fix(N/2):end-ceil(N/2));
				  end
			  end
		  end
		  data(:,1:ceil(N/2),:,:)=repmat(data(:,ceil(N/2)+1,:,:),[1 ceil(N/2) 1 1]);
		  data(:,end-ceil(N/2)+1:end,:,:)=repmat(data(:,end-ceil(N/2)-1,:,:),[1 ceil(N/2) 1 1]);
	  end			  
  elseif ndims(data)==3,
	  for m=1:M
		  for i2=1:sz(2)
			  for i3=1:sz(3)
				  tmp=conv(G,data(:,i2,i3));
				  data(:,i2,i3)=tmp(fix(N/2):end-ceil(N/2));
			  end
		  end
		  data(1:ceil(N/2),:,:)=repmat(data(ceil(N/2)+1,:,:),[ceil(N/2) 1 1]);
		  data(end-ceil(N/2)+1:end,:,:)=repmat(data(end-ceil(N/2)-1,:,:),[ceil(N/2) 1 1]);
	  end			  
  else
	  error('The number of dimmension in data must be 3 or 4.') ;
  end	  
  
  return;
