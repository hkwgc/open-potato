function varargout = PlugInWrap_PeakSearch(fcn, varargin)
% Execute Peak-Search
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PlugInWrap_PeakSearch('createBasicIno');
%    Return Information for POTATo.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_PeakSearch('getArgument',filterData, mfilename);
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_PeakSearch.
%     filterData.argData : Argument of Plug in Function.
%        argData.ver : version of This file
%
%     mfilename : M-File, before PlugInWrap-AddRaw.
%
% ** write **
% Syntax:
%  str = PlugInWrap_PeakSearch('createBasicIno',region, fdata)
%  Make M-File of adding Raw
%
% See also OSPFILTERDATAFCN.

% $Id: PlugInWrap_PeakSearch.m 208 2011-06-08 02:07:19Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2010.12.28
% Revision : 1.00

%======== Launch Switch ========
switch fcn
  case {'createBasicInfo','getArgument','write'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  otherwise
    error('Not Implemented Function : %s',fcn);
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
basicInfo.name   = 'Peak Search';
basicInfo.region = 3;
DefineOspFilterDispKind;
basicInfo.DispKind=F_DataChange & F_General;
basicInfo.DispKind=basicInfo.DispKind & F_NOTALL; % Do not listup
basicInfo.Description='Peak Search';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin)
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_PeakSearch.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = varargin{1}; % Filter Data
if isfield(data0, 'argData')
  data = data0.argData;
else
  % No-Argument in the data
  data = [];
end

% Before - Data -
if nargin>=2 && exist(varargin{2},'file'),
  mfile_pre = varargin{2};
else
  mfile_pre = '';
end

%GUI:Expand of period setting
data=dlgPlugInWrap_PeakSearch('argData',data,'Mfile_Pre',mfile_pre); 
if isempty(data), 
  data0=[];
else
  data0.argData=data; 
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) %#ok
% Make M-File of PlugInWrap_PeakSearch
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is PlugInWrap_PeakSearch.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');
make_mfile('with_indent', 'unit=1000/hdata.samplingperiod;');
make_mfile('with_indent', sprintf('area=round([%f,%f]*unit)+(hdata.stim(1)-1);',...
  fdata.argData.Period(1),fdata.argData.Period(2)));
make_mfile('with_indent',sprintf('sarea=round([%f,%f]*unit);',...
  fdata.argData.FlexTerm(1),fdata.argData.FlexTerm(2)));
make_mfile('with_indent', 'psdata=osp_peaksearch(data,area,sarea);');
str='';
return;
