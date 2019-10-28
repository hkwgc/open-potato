function varargout = PlugInWrap_Nan2Zero(fcn, varargin)
% PlugiWrap Zero-Flags set zero to data
% at channel that All Blocks in Channel.
% 
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_ZeroClear('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_ZeroClear('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_ZeroClear.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_ZeroClear('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% $Id: PlugInWrap_Nan2Zero.m 258 2011-12-22 07:39:18Z Katura $


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
% modified: 2011.12.20 (TK)
% Revision : 1.01



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
  basicInfo.name   = 'Replace NaN by Zero';
  basicInfo.region = 3;
  DefineOspFilterDispKind;
  basicInfo.DispKind=F_DataChange;
  basicInfo.Description='Replace NaN by Zero';
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_ZeroClear.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  ver  = '$Revision: 1.01 $';
  ver  = ver(11:end-1);
  try,
      data.ver=str2num(rver);
  catch,
      data.ver =1.01;
  end
  data0.argData=data;
  varargout{1}=data0;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
% Make M-File of PlugInWrap_ZeroClear
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_ZeroClear.
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
  make_mfile('with_indent', '[data, hdata]=PlugInWrap_Nan2Zero(''exe0'',data,hdata);');
  make_mfile('with_indent', ' ');
  str='';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, hdata]=exe0(data,hdata)
% Zero Clear
flag=hdata.flag;
if ndims(flag)~=3
	warndlg('hdata.flag is not 3D matrix.','ERROR: Replace NaN by Zero');
	return;
end

flag=sum(hdata.flag,1); % Sum Other Flags
sz=size(flag);
flag = reshape(flag,[sz(2) sz(3)]);% To avoid vectorization, we use reshape. not squeeze.

flag(flag>=1)=1; % reset 1;
flag=sum(flag,1);
sz  = size(data);

chidx = flag==sz(1);% to logical. sz(1):number of repeated tasks (block num)

% Zero Clear
hdata.flag(:,:,chidx)=0;
data(:,:,chidx,:)=0;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
