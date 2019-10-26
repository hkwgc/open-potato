function varargout = PlugInWrap_Pack(fcn, varargin)
% PlugiWrap performs memory garbage collection.
%   * This Plugin never change Data.
%   * This Plugin need no setting.
% 
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_Pack('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_Pack('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Pack.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_Pack('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% $Id: PlugInWrap_Pack.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2006.04.10
% Revision : 1.00



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
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Garbage Collection';
  basicInfo.region = [2 3];
  DefineOspFilterDispKind;
  basicInfo.DispKind=F_Control;
  basicInfo.Description='Garbage Collection';
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Pack.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = varargin{1}; % Filter Data
ver  = '$Revision: 1.2 $';
ver  = ver(11:end-1);
try
  data.ver=str2double(ver);
catch
  data.ver =1.0;
end
data0.argData=data;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
% Make M-File of PlugInWrap_Pack
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is PlugInWrap_Pack.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', ['%    ' mfilename ' v' num2str(fdata.argData.ver)]);
make_mfile('with_indent', '% Warning : This Plugin work on MATLAB R2006a or earlier');
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');
make_mfile('with_indent', 'rver=OSP_DATA(''GET'',''ML_TB'');rver=rver.MATLAB;');
make_mfile('with_indent','if rver < 16,');
make_mfile('with_indent', '   cwd = pwd; cd(tempdir);');
make_mfile('with_indent', '   pack;  cd(cwd);');
make_mfile('with_indent', 'end');
make_mfile('with_indent', ' ');
str='';
return;
