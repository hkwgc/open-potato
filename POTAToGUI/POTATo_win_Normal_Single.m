function varargout=POTATo_win_Normal_Single(fnc,varargin)
% POTATo Analysis-Status : Normal-Single Analysis
%  Analysis-GUI-sets, 
%  when Normal (P3-Mode), Number of Data is 1.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%  2010.11.01 : New!
%       2010_2_RA01-3
if nargout,
  [varargout{1:nargout}]=POTATo_win_SimpleMode(fnc,varargin{:});
else
  POTATo_win_SimpleMode(fnc,varargin{:});
end
