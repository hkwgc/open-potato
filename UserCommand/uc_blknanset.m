function [data,hdata]=uc_blknanset(data,hdata)
% UC_BLKNANSET set NaN at non-effective point in Block-Data.
%  where non-effective mean where unused flag is on.
%
% Syntax:
%   data=uc_blknanset(data,hdata);
%
%   Input :
%    data  : Block Data
%    hdata : Header of Block-Data
%
%  Output:
%    data : Block-Data.
%           Include NaN
%
%  See also NaN.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% author : Masanori Shoji
% create : 2005.12.20
% $Id: uc_blknanset.m 180 2011-05-19 09:34:28Z Katura $


flag = hdata.flag; clear hdata;
flag = squeeze(sum(flag,1));
flag = flag>=1;

for blk=1:size(flag,1),
  ch = find(flag(blk,:)==true);
  if ~isempty(ch),
    data(blk,:,ch,:)=NaN;
  end
end

