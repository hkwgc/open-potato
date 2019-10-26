function [mean_block, std_block, se_block]=uc_blockmean(data, header, stimkind)
% Make Block Mean Data
%
% Function for User Command Data.
%
% Syntax:
% [mean_block, std_block]= ...
%  uc_blockmean(data, header ,stimkind)
%
%  data is 4 dimensional matrix,
%    block  x time x channel x datakind
%
% header is UserCommand Header data of Block
%
% stimkind is Stimulation kind that use for mean.
%  ( if ignore, set default )
%---
% mean_block is mean value of block.
%
% std_block is of block.
%
% See also NAN_FCN.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.04.29
% $Id: uc_blockmean.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.3
%   Change Input Argument,
%   Add Use Data Selection.
%
% Revision 1.5
%   Bugfix 06116B

if nargout==0, return; end

% -- Argument Check --
msg=nargchk(2, 3, nargin);
if ~isempty(msg), error(msg); end

if ndims(data)~=4
  error(['Invarid Dimmension of Block Data for '...
    mfilename '.']);
end


% --- Select User Data  --
flg_tmp = sum(header.flag,1);
flg_tmp = flg_tmp~=0;
for bid=size(data,1):-1:1,
  flg_tmp0 = flg_tmp(1,bid,:);
  if all(flg_tmp0==0),
    continue;
  end
  if all(flg_tmp0(1,1,:)),
    % fprintf(1,' Remove block, No. %d\n', bid);
    header.stimkind(bid)=[];
    header.flag(:,bid,:)=[];
    data(bid,:,:,:)=[];
  else
    data(bid,:,flg_tmp0(1,1,:)==1,:)=NaN;
  end
end

if size(data,1) < 1
  warning('No data to mean');
  mean_block=[]; std_block=[];
  return;
end

% Select : Stimulation Kind
if nargin< 3,
  % If there is no Argument about Stimulation-Kind,
  %   -- Mean All Data --
  % !! DR P3_0003 !!
  
  %nonplot_block = [];
  selectedBlock = 1:length(header.stimkind);
  stimkind = header.stimkind(1);
  %--------------------------------
  % Warning for Different Stim Kind
  %--------------------------------
  if 0 %- warning off by TK@HARL 20100728 ***
  if ~all(stimkind==header.stimkind),
    stimkindstr = sprintf(' %d,',header.stimkind);
    stimkindstr(1)='[';stimkindstr(end)=']';
    warning(['\t''mean'' executed over different '...
      'stim kind!\n'...
      '\t\tStim Kind was %s\n'...
      '\t\tPlease Check\n'],stimkindstr);
  end
  end
  %***
else
	selectedBlock = ismember(header.stimkind, stimkind);
end

if ~isempty(selectedBlock)
	data=data(selectedBlock,:,:,:);
else
	warning('No data to mean\n');
	mean_block=[]; std_block=[];
	return;
end	
% if ~isempty(nonplot_block),
%   data(nonplot_block,:,:,:)=[];
% end

% if size(data,1) < 1
%   warning('No data to mean\n');
%   mean_block=[]; std_block=[];
%   return;
% end

if size(data,1) == 1,
  % we know dimension of data is 4.
  sz=size(data); sz(1)=[];
  mean_block=reshape(data,sz);
  std_block=[];
  return;
end

%%%%%%%%%%%%%%%%%%%%
% Mean
%%%%%%%%%%%%%%%%%%%%
mean_block = nan_fcn('mean', data, 1);
sz=size(mean_block); sz(1)=[];
if length(sz)==1, sz(2)=1; end
mean_block = reshape(mean_block,sz);

if nargout==1, return; end

%%%%%%%%%%%%%%%%%%%%
% Calculate SD 
%%%%%%%%%%%%%%%%%%%%
[std_block  datanum]= nan_fcn('std0', data,1);
if length(sz)==1, sz(2)=1; end
std_block = reshape(std_block,sz);
if nargout==2, return; end

%%%%%%%%%%%%%%%%%%%%
% Calculate SE
%%%%%%%%%%%%%%%%%%%%
se_block  = std_block./sqrt(permute(datanum + (datanum==0),[2 3 4 1]));
return;
