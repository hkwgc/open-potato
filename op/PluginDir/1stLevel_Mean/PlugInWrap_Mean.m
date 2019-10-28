function varargout = PlugInWrap_Mean(fcn, varargin)
% Test Function of 1st-Level-Analysi Plugin.
%
% "1st-Level-Analysi Plugin" is as same as
%  Ordinal Filter Plugin, except
%  "Filter-Disp-Kind" and "write-Function''s" behavior.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and 'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_Mean('createBasicIno');
%    Return Information for OSP Application.
%  where : basicInfo.DispKind must be equal to "F_1stLvlAna";
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_Mean('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_Mean.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_Mean('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
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
% create : 2007.02.14
% Reversion : 1.00
%
% Reversion 1.00, Date 07.21
%   No check..

%======== Launch Switch ========
switch fcn,
  case 'createBasicInfo',
    varargout{1} = createBasicInfo;
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
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
%       DispKind :: Add Kind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   = 'Test-Function of 1st-Lvl-Ana';
basicInfo.region = 3;
% ==> Version : Must be
ver = '$Revision: 1.2 $';
ver([1:13,end])=[];
try
  basicInfo.Version = str2double(ver);
catch
  basicInfo.Version =1;
end
% Display Kind :
% <- Filter Display Mode Variable :: Load
DefineOspFilterDispKind;
basicInfo.DispKind=F_1stLvlAna;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_Mean.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = varargin{1}; % Filter Data
data.HOGE='1';
data0.argData=data;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata)
% Make M-File of PlugInWrap_Mean
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_Mean.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ========================
% Load Setting..
% ========================
basicInfo= createBasicInfo;

% Header
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', ['%    File    : ' mfilename]);
make_mfile('with_indent', ['%    Version : ' num2str(basicInfo.Version)]);
make_mfile('with_indent',  '% This Code is 1st-Level-Analysis Execution.');
make_mfile('with_indent',  '% so this code is not apper in Ordinal M-File');
make_mfile('code_separator', 3);  % Level  3, code sep .

% Exeute
make_mfile('with_indent',['[fhdata,fdata] = flafnc_mean(''make'',hdata,data,' fdata.argData.HOGE ');']);
make_mfile('with_indent', 'DataDef2_1stLevelAnalysis(''save'',fhdata,fdata);');
make_mfile('code_separator', 3); % Level 3, code separator
make_mfile('with_indent', ' ');

str='';
return;
