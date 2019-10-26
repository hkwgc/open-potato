function varargout = PlugInWrap_Flag2NaN(fcn, varargin)
% PlugiWrap Flag2NaN is set NaN to bad-data.
% 
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_Flag2NaN('createBasicIno');
%    Return Information for OSP Application.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_Flag2NaN('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Flag2NaN.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_Flag2NaN('createBasicIno',region, fdata)
%
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% $Id: PlugInWrap_Flag2NaN.m 180 2011-05-19 09:34:28Z Katura $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Masanori Shoji
% create : 2007.06.01
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
  basicInfo.name   = 'Flag to NaN-DATA_base';
  basicInfo.region = 2:3;
  DefineOspFilterDispKind;
  basicInfo.DispKind=F_DataChange;
  basicInfo.Description='Set Nan to data at Flag';
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin) %#ok
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Flag2NaN.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  ver  = '$Revision: 1.2 $';
  rver  = ver(11:end-1);
  try
      data.ver=str2double(rver);
  catch
      data.ver =1.0;
  end
  data0.argData=data;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata)  %#ok
% Make M-File of PlugInWrap_Flag2NaN
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Flag2NaN
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
  make_mfile('with_indent', '[data,hdata]=PlugInWrap_Flag2NaN(''exe0'',data,hdata);');
  make_mfile('with_indent', ' ');
  str='';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, hdata]=exe0(data,hdata) %#ok
%Set Nan
if ndims(data)==4
  flag=squeeze(sum(hdata.flag,1)); % Sum Other Flags
  flag=flag>=1; % reset 1;
  % Set NaN
  sz=size(flag);blklen=sz(1);
  for blk=1:blklen
    data(blk,:,flag(blk,:),:)=NaN;
  end
  % Clear Flag
  hdata.flag(:)=0;
elseif ndims(data)==3
  % Set NaN
  data(hdata.flag)=NaN;
  % Clear Flag
  hdata.flag(:)=false;
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
