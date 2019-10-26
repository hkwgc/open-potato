function [data,hdata]=uc_EvalString(data,hdata,A)
% [data,hdata]=uc_EvalString(data,hdata,A)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

eval(A);

