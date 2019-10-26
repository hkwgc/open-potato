function  varargout = MPP_PlugIn_Sample(fcn, varargin)
% Sample Ploulum of Multi-Processing-Plugin.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and 'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = MPP_PlugIn_Sample('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = MPP_PlugIn_Sample('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  MPP_PlugIn_Sample('write',region, MPP)
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
% Original author : Masanori Shoji
% create : 2007.04.19
% Reversion : 1.00
%
% $Id: MPP_PlugIn_Sample.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;
%===============================

function  bi = createBasicInfo
% Basic Information of this function

%--> mandatory <--
bi.name='Sample';
bi.version=0;
%--> suggested <--
bi.type  =0; % not defined now
bi.region=0; % not defined now


