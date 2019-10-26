function [data, header] = uc_smoothing(data,header,PStime)
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
% $Id: uc_AdjustPrescan4BSdata.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.00, Date 07.21
%   No check..

  msg=nargchk(3,3,nargin);
  if ~isempty(msg), error(msg), end
  msg=nargoutchk(2,2,nargout);
  if ~isempty(msg), error(msg), end
  sz=size(data);
  
  tmp1=data(1:end-PStime+1,:,1:3);
  tmp2=data(PStime:end,:,4:end);
  data=cat(3,tmp1,tmp2); 
  
  return;
