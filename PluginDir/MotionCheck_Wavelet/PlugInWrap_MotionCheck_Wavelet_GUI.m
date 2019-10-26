function varargout = PlugInWrap_MotionCheck_Wavelet_GUI(fcn, varargin)
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
%         BLOCK  : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Motion Check [ Wavelet ]*GUI';
  basicInfo.region = [3];
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
  if isfield(data0, 'argData')
    % Use Setting Value.
    % ( Change )
    data = data0.argData;
  else
    data = [];
  end

  % Default Value for start
  if ~isfield(varargin{1},'argData'),
    varargin{1}.argData.SC=7;
    varargin{1}.argData.TH =41;
	varargin{1}.argData.Kind=1;
  end

data=dlgPlugInWrap_MotionCheckWavelet_Arg1(varargin{:});

if ~isempty(data),data0.argData=data;
else data0=[];end
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
  A=fdata.argData;
  make_mfile('with_indent', ['% == ' fdata.name ' ==']);
  make_mfile('with_indent', sprintf('[hdata]=uc_MotionCheck_Wavelet(data,hdata,%s,%s,%d);',A.SC,A.TH,A.Kind));
  make_mfile('code_separator', 3); % Level 12, code sep .
  make_mfile('with_indent', ' ');
  str='';

return;
