function [data, header] = uc_addraw(data,header)
% Add Raw data to User Command (Continuous-Data)
%
% Syntax:
% [data, header] = uc_addraw(data,header);
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
% $Id: uc_addraw.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.00, Date 07.21
%   No check..

  msg=nargchk(2,2,nargin);
  if ~isempty(msg), error(msg), end
  msg=nargoutchk(2,2,nargout);
  if ~isempty(msg), error(msg), end

  % checking data
  if ndims(data)~=3,
    error('The number of dimmension in data must be 3.') 
  end

  if ~isstruct(header),
    error('Header must be Structure');
  end
  if ~isfield(header,'TAGs'),
    error('Rack of TAGs in header');
  end
  tag = header.TAGs;
  if ~isfield(tag, 'data'),
    disp(tag);
    error('Could not find Raw data in header.TAGs.data');
  end
  if ~isfield(tag, 'DataTag'),
    disp(tag);
    error('Could not find DataTag in header.TAGs.DataTag');
  end

  size_of_hb  = size(data);
  size_of_raw = size(tag.data);
  if (2*size_of_hb(2))~= (size_of_raw(2)) || size_of_hb(1)~=size_of_raw(1),
    %disp(size_of_hb); disp(size_of_raw);
    errordlg('No Raw Data Exist','UC Add Raw');
    return;
  end
  data(:,:,end+1)=tag.data(:,1:2:size_of_raw(2)-1);
  header.TAGs.DataTag{end+1} = 'Raw 780 nm';

  data(:,:,end+1)=tag.data(:,2:2:size_of_raw(2));
  header.TAGs.DataTag{end+1} = 'Raw 830 nm';

return;
