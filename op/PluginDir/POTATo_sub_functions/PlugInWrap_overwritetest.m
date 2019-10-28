function varargout = PlugInWrap_overwritetest(fcn, varargin)
% PlugiWrap Overwrite Test
% at channel that All Blocks in Channel.
% 
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_overwritetest('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_overwritetest('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_overwritetest.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_overwritetest('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% $Id: PlugInWrap_overwritetest.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
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
%         CONTINUOUS   : 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'zzz** Overwrite-Test **zzz';
  basicInfo.region = 2;
  DefineOspFilterDispKind;
  basicInfo.DispKind=F_DataChange;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_overwritetest.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  ver  = '$Revision: 1.1 $';
  %       1234567890123456
  ver  = ver(11:end-1);
  try,
      data.ver=str2num(rver);
  catch,
      data.ver =1.0;
  end
  data0.argData=data;
  varargout{1}=data0;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
% Make M-File of PlugInWrap_overwritetest
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_overwritetest.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  make_mfile('code_separator', 3);   % Level  3, code sep 
  make_mfile('with_indent', ['% == ' fdata.name ' ==']);
  make_mfile('with_indent', ['%    ' mfilename ' v' num2str(fdata.argData.ver)]);
  make_mfile('code_separator', 3);  % Level  3, code sep .
  make_mfile('with_indent', ' ');
  make_mfile('with_indent','if ~exist(''P3_RAWDATA_OVERWRITE_FLAG'',''var'')');
  make_mfile('with_indent','  P3_RAWDATA_OVERWRITE_FLAG=1;');
  make_mfile('with_indent','else');
  % 必要ならば dataも更新
  make_mfile('with_indent','  clear P3_RAWDATA_OVERWRITE_FLAG;');
  make_mfile('with_indent','  DataDef2_RawData(''save_ow'',hdata,data);');
  make_mfile('with_indent', ' msgbox(''Data and HData were updated !!'',''Confirmation'')');
  make_mfile('with_indent','end');

  str='';
return;

