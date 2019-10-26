function [data, header] = uc_smoothing(data,header,Kind)
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
% $Id: uc_Flag2Kind.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.00, Date 07.21
%   No check..

  msg=nargchk(3,3,nargin);
  if ~isempty(msg), error(msg), end
  msg=nargoutchk(2,2,nargout);
  if ~isempty(msg), error(msg), end
  sz=size(data);
  
  a=data(:,:,Kind);
  b=squeeze(header.flag);
  c=a.*b;
  c(find(c==0))=NaN;
  data(:,:,end+1)=c;
  header.TAGs.DataTag{end+1}='Flag';
   
  return;
