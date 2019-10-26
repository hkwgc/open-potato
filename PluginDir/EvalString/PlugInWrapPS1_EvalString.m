% EvalString is Plug-in Function of POTATo.
%   "EvalString" execute given-string in Analysis M-File.
%    In the string, POTATo-Data, hdata & data, is available.

% TEST__NAME Function of Wrapper of Plag-In Function
%
% You may use  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = EvalString('createBasicIno');
%
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%     if allowed Region-Number  is either Continuos and Blocks
%        set basic_info.region=[2, 3];
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = EvalString('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @EvalString.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.A: Input evaluatable strings
%
%     mfilename : M-File, before PlugInWrap-TEST__NAME.
%
% ** write **
% Syntax:
%  str = EvalString('createBasicIno',region, fdata)
%
%  Make M-File, correspond to Plug-in function.
%  by usinge make_mfile.
%  if str, out-put by str.
%
% See also OSPFILTERDATAFCN.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Reversion : 1.00
%

%======== Launch Switch ========

% function varargout = PlugInWrap_EvalString(fcn, varargin)
% converted by
%   $Id: $
%   Date: 25-Mar-2014 19:17:14


% Input Variable
fcn	= vin1;
varargin=cell(1,nin-2+1);
for ii=2:nin
  varargin{ii-2+1}=eval(sprintf('vin%d',ii));
end

if strcmp(fcn,'createBasicInfo'),
varargout{1} = P3_PluginEvalScript('PlugInWrapPS1_EvalString','createBasicInfo');
	return;
end

if nargout,
[varargout{1:nargout}] = P3_PluginEvalScript('PlugInWrapPS1_EvalString',fcn, varargin{:});
else
P3_PluginEvalScript('PlugInWrapPS1_EvalString',fcn, varargin{:});
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======

% Output Variable
for ii=1:nout
  eval(sprintf('vout%d=varargout{ii-1+1};',ii));
end

