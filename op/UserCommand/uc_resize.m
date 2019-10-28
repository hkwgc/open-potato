function [data, hdata]  = uc_resize(data,hdata, BlockPeriod),
% UC_RESIZE is resize Block-Data of UserCommand.
%
% Syntax:
%   [data, hdata]  = uc_resize(data,hdata, BlockPeriod).
%
% Input Arguments:
% Output Arguments:
%
% See also, FILTER_DEF_RESIZEBLOCK, UC_BLOCKING.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.06.22
% $Id: uc_resize.m 180 2011-05-19 09:34:28Z Katura $
%
% reversion : 
%

  % Argument Check
  msg = nargchk(3,3,nargin);
  if ~isempty(msg), error(msg); end

  if ndims(data)<4,
    error(' Dimension of data is smaller than 4');
  end

  ostim = hdata.stim;	% Original Stimulation Timing.
  % get New-STIMulation data in sampling-period unit.
  nstim = round(BlockPeriod * 1000/hdata.samplingperiod);
  sz    = size(data);

  % Set Effective time-data for new block-data.
  tdata(1) = ostim(1) - nstim(1)+1;
  tdata(2) = ostim(2) + nstim(2)+1;

  % Data Range Check.
  if tdata(1)<=0, 
    warning('New Block : PreStim-Period is so long.');
    tdata=1; 
  end

  if tdata(2) > sz(2),
    warning('New Block : PostStim-Period is so long.');
    tdata(2) = sz(2);
  end

  % set new block-data.
  data  = data(:,[tdata(1):tdata(2)], :,:);
  hdata.stimTC = hdata.stimTC(1,[tdata(1):tdata(2)]);
  hdata.stim=[nstim(1) , ...
	      (ostim(2) - tdata(1) +1)];

return;



