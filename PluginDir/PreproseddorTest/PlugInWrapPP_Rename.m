function varargout = PlugInWrapPP_Rename(fcn, varargin)
% Test Function of Wrapper of Plag-In Function 
%  This Function Rename
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrapPP_Rename('createBasicIno');
%
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  Data = PlugInWrap_MaxDivision('getArgument',Data);
%
%     Data.name    : Display Name =='defined in createBasicInfo'
%     Data.wrap    : Name of this Function, 
%                    that is 'PlugInWrapPP_Rename'.
%     Data.argData : Argument of Plug in Function.
%                    now nothing.
%
% ** write **
% Syntax:
%  str = PlugInWrapPP_Rename('createBasicIno',region, fdata)
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
% Original author : Masanori Shoji
% create : 2007.01.30
% $Id: PlugInWrapPP_Rename.m 180 2011-05-19 09:34:28Z Katura $
%

%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else
    feval(fcn, varargin{:});
  end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Rename';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(data,varargin)
% Set Argument of this Wrapper (write).
%
%     Data.name    : Display Name =='defined in createBasicInfo'
%     Data.wrap    : Name of this Function, 
%                    that is 'PlugInWrapPP_Rename'.
%     Data.argData : Argument of Plug in Function.
%                    now nothing.
%
%     varargin     : Empty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==> confine this function
data0=createBasicInfo;
data.name=data0.name;
data.wrap=mfilename;
% where Do nothing.
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, data) 
% Make M-File of PlugInWrapPP_Rename
%
%    data is as same as getArgument.
%    region is not in use, at 30-Jan-2007.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Header
make_mfile('code_separator', 3);
make_mfile('with_indent', ['% ' mfilename]);
make_mfile('code_separator', 3);

% Rename by Input-Dialog
make_mfile('with_indent', 'name2=inputdlg({''DataName:''},''Rename'',1,{hdata.TAGs.filename});');
make_mfile('with_indent', 'if ~isempty(name2),');
make_mfile('with_indent', '   hdata.TAGs.filename=name2{1};');
make_mfile('with_indent', 'end');

str='';
return;

