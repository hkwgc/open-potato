function diff_lim = OSP_STIMPERIOD_DIFF_LIMIT()
% OSP STIMPERIOD DIFF LIMIT
%  I/O of OSP-Stimulation Period Difference Limit
%  To Confine Old version of OSP...
%
% See also: OSP_DATA, BLOCK_FILTER, UC_BLOCKING, 
%           OSP_INI_FIN.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.11.07
% $Id: OSP_STIMPERIOD_DIFF_LIMIT.m 180 2011-05-19 09:34:28Z Katura $

try
	diff_lim = OSP_DATA('GET','OSP_STIMPERIOD_DIFF_LIMIT');
catch
	diff_lim = 999999999;
end
if isempty(diff_lim),
	diff_lim = 999999999;
end
return
