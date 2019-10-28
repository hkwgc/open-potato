function P3_WarningMessage(id, varargin)

%-
% P3 sub function for showing a warning message dialog.
%
%                                       TK@HCRL 2011-11-15
%-

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


str='';
switch id
	case 10001 %- uc_blocking.m
		str = sprintf('In reshaping to 4D data, negative time point was selected.\n4D data contains nan value(s).');
	case 10002 %- uc_blocking.m
		str = sprintf('In reshaping to 4D data, exceeding time point was selected.\n4D data contains nan value(s).');
	otherwise
		str = 'An undefined warning has occured.';
end

warndlg(str, 'P3 warning', 'modal');
