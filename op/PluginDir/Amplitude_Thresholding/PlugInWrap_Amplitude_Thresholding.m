function varargout = PlugInWrap_Amplitude_Thresholding(fcn, varargin)
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
% original author : Takusige Katura
% create : 2005.12.12
% Reversion : 1.00
%
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
%         BLOCK   : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Amplitude Thresholding';
  basicInfo.region = [2 3];
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
  if isempty(data) || ~isfield(data,'Max'),
    data.Max=0.3;
    data.kind=1;
  end

  % Display Prompt words
  prompt = {' Enter : Amplitude threshold',' Enter : Kind forthretholding'};
  % Default value
  def    = {num2str(num2str(data.Max)),num2str(data.kind)};
  def = inputdlg(prompt, data0.name, 1, def);
  if isempty(def),
	  data=[]; return; %while
  else
	  data.Max=str2num(def{1});
	  data.kind=str2num(def{2});
  end

  data.ver = 1.00;
  data0.argData=data;
  varargout{1}=data0;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  A=fdata.argData;
  make_mfile('with_indent', ['% == ' fdata.name ' ==']);
  make_mfile('with_indent', sprintf('[data, hdata]=uc_Amplitude_Thresholding(data,hdata,%d,%d);',A.Max,A.kind));
  make_mfile('code_separator', 3); % Level 12, code sep .
  make_mfile('with_indent', ' ');
  str='';

return;
