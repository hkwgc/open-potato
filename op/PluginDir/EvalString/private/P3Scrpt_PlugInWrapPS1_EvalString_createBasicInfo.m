% [Syntax] function  basicInfo= createBasicInfo


% Input Variable

%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




basicInfo.name   = 'EvalString';
basicInfo.region = [2  3];
% Display Kind :
% <- Filter Display Mode Variable :: Load
DefineOspFilterDispKind;
basicInfo.DispKind=0;
basicInfo.Version=2.0;

% Output Variable
vout1	= basicInfo;


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Output Variable
vout1	= basicInfo;

