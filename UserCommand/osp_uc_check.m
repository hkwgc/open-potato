function osp_uc_check(header)
% checking data

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



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