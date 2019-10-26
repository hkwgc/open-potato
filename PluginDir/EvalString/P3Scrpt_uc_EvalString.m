
% function [data,hdata]=uc_EvalString(data,hdata,A)
% converted by
%   $Id: $
%   Date: 25-Mar-2014 19:17:14


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% Input Variable
data	= vin1;
hdata	= vin2;
A	= vin3;


eval(A);

% Output Variable
vout1	= data;
vout2	= hdata;

