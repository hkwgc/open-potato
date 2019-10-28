function varargout = PlugInWrap_AddRaw(fcn, varargin)
% Add Raw-Data at the end of data, when ETG-format.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_AddRaw('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_AddRaw('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_AddRaw('createBasicIno',region, fdata)
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
% original author : Masanori Shoji
% create : 2005.07.21
% Reversion : 1.00
%
% Reversion 1.00, Date 07.21
%   No check..

%======== Launch Switch ========
if nargin==0
  POTATo_Help(mfilename);
end

  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%       DispKind :: Add Kind 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Merge Raw signal';
  basicInfo.region = 2;
  % Display Kind :
  % <- Filter Display Mode Variable :: Load
  DefineOspFilterDispKind; 
  basicInfo.DispKind=F_DataChange;
  basicInfo.Description='Load Raw-Data (for ETG format-Data)';
  basicInfo.ResizeOption.Kind='+2';
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin),
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  data.ver = 1.00;
  data0.argData=data;
  varargout{1}=data0;
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
  make_mfile('code_separator', 3);   % Level  3, code sep 
  make_mfile('with_indent', ['% == ' fdata.name ' ==']);
  make_mfile('with_indent', ['%    ' mfilename ' v' num2str(fdata.argData.ver)]);
  make_mfile('code_separator', 3);  % Level  3, code sep .
  make_mfile('with_indent', ' ');
  make_mfile('with_indent', '[data, hdata]=uc_addraw(data,hdata);');

  make_mfile('with_indent', ' ');
  make_mfile('code_separator', 3); % Level 3, code separator
  make_mfile('with_indent', ' ');

  str='';

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ******************************
% ********* Delete *************
% ******************************
%===============================
%  Now Not in Use. 
%===============================
function exe(varargin),
% Error -> OSP version 1.50
  error(['Defined nothing about exe command.', ...
	 mfilename ' is for OSP version 1.50']);
  % we can ignore this function,
  % if donot mind setting of error-comment.
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
