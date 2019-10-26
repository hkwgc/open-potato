function varargout = PlugInWrap_FLA_SaveResults(fcn, varargin)
% == History ==
% author : TK
% create : 2007.04.22
% Reversion : 1.00
%
% Reversion 1.00, Date 07.21
%   No check..

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


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
basicInfo.name   = '1stLv: save .Results';
basicInfo.region = [3];
% ==> Version : Must be
ver = '$Revision: 1.1 $';
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
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data0 = varargin{1}; % Filter Data
% data.HOGE='1';
% data0.argData=data;

data0 = varargin{1}; % Filter Data

d1=dlgPluginWrap_FLA_SaveResults(varargin{:});

data0.argData=d1;

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata)
% Make M-File of PlugInWrap_AddRaw
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_AddRaw.
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
A=fdata.argData;

for i=1:length(A.ITEMs)
	make_mfile('with_indent', sprintf('S{%d} = ''%s'';', i, A.ITEMs{i}));
end
make_mfile('with_indent',['[fhdata,fdata] = flafnc_SaveResults(''make'',hdata,data,S);']);

make_mfile('with_indent', 'DataDef2_1stLevelAnalysis(''save'',fhdata,fdata);');
make_mfile('code_separator', 3); % Level 3, code separator
make_mfile('with_indent', ' ');

str='';
return;
