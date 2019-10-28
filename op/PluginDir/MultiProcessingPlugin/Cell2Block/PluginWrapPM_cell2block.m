function  varargout = PluginWrapPM_cell2block(fcn, varargin)
% Translation from Cell (Block / Continuous ) to Block Data.
%   ===== P3.1.6 : Multi-Processing-Plugin. =====
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and 'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PluginWrapPM_cell2block('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = PluginWrapPM_cell2block('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  PluginWrapPM_cell2block('write',region, MPP)
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
% create : 2007.04.19
% Reversion : 1.00
%
% $Id: PluginWrapPM_cell2block.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
    %--------> Special Function to Execute -------->
    %<-------- Special Function to Execute <--------
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  bi = createBasicInfo
% Basic Information of this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--> mandatory <--
bi.name='Cell to Block';
bi.version=1;
%--> suggested <--
bi.type  =0; % not defined now
bi.region=0; % not defined now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  mpp=getArgument(mpp, b_mfile)
% Set Data
%     mpp.name    : 'defined in createBasicInfo'
%     mpp.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Event_Reblock.
%     mpp.argData : Argument of Plug in Function. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if you want to Before ( P3 formated Data )
% Use Script M-Evaluate.
if 0,disp(b_mfile); end

%==========================
% Initialize Argument-Data 
%==========================
if isfield(mpp, 'argData')
  data = mpp.argData;
  if ~isfield(data,'Marker')
    data.Marker='All';
  end
else
  data.BlockPeriod=[5,15];
  data.Marker='All';
end

%==============================
% Setting argument of Blocking
%==============================
[data.BlockPeriod,data.Marker] ...
  = BlockPeriodInputdlg(data.BlockPeriod,'',data.Marker);

%==============================
% Out put Result.
%==============================
if isempty(data.BlockPeriod),
  mpp=[]; % Cancel
else
  mpp.wrap=mfilename;
  mpp.argData=data;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, mpp) 
% Make M-File for write make M-File to execute "Cell 2 Block".
%  where data is as same as getArgument's data.
%
% There is two method to make M-File.
%   1. use function 'make_mfile'
%      make_mfile is opend at default, so you
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(region);end
str='';

%=========================
% Write Header
%=========================
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' mpp.name ' ==']);
make_mfile('with_indent', ['%    ' mfilename  ' v1.0 ']);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');

%=========================
% Blocking Data
%=========================
fdata0   = mpp.argData;
% Mark
braketflag=false;
if isfield(fdata0,'Marker')
  if isnumeric(fdata0.Marker)
    s=num2str(fdata0.Marker);
    if length(fdata0.Marker)>1
      braketflag=true;
    end
  else
    s=['''' fdata0.Marker ''''];
  end
else
  s='''All''';
end
if braketflag
  make_mfile('with_indent',sprintf('mrk=[%s];',s));
else
  make_mfile('with_indent',sprintf('mrk=%s;',s));
end

%=========================
% Checking Data
%=========================
make_mfile('with_indent',...
  sprintf('tp=%s(''checkdatatype'',hdata,data);',mfilename));
make_mfile('with_indent', 'switch tp');

make_mfile('indent_fcn','down');
make_mfile('with_indent', 'case 3, % Cell-Block');
make_mfile('indent_fcn','down');
make_mfile('with_indent', ...
  {sprintf('[data, hdata] = uc_joinblock(data, hdata,%f,%f,mrk);', ...
  fdata0.BlockPeriod(1), fdata0.BlockPeriod(2)), ...
  ' '});


make_mfile('indent_fcn','up');
make_mfile('with_indent', 'case 2, % Cell-Continuous');
make_mfile('indent_fcn','down');
make_mfile('with_indent', ...
  {sprintf('[data, hdata] = uc_blocking(data, hdata,%f,%f,mrk);', ...
  fdata0.BlockPeriod(1), fdata0.BlockPeriod(2)), ...
  ' '});

make_mfile('indent_fcn','up');
make_mfile('with_indent', 'otherwise');
make_mfile('indent_fcn','down');
make_mfile('with_indent', 'error(''Current-Data-Format (hdata) is out of format'')');
make_mfile('indent_fcn','up');

make_mfile('indent_fcn','up');
make_mfile('with_indent', 'end');


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Function (Tool)
%--------------------------------------------------------------------------
%  Syntax : tp=checkdatatype(hdata,data)
%     --> Check Data-Type
%  Syntax : renameData(tp)
%     --> Rename Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=====================================
function tp=checkdatatype(hdata,data)
% Check
% tp   :  01(1) : Normal-Block
%         11(3) : Cell  -Block
%         00(0) : Normal-Continuos
%         10(2) : Cell  -Continuous
%=====================================
%tp=zeros(1,1,'uint8');
tp=0;
isDcell =iscell(hdata);
if isDcell
  tp=bitset(tp,2);
  if ~isempty(data) && ndims(data{1})==4
    tp=bitset(tp,1);
  end
else
  if ndims(data)==4
    tp=bitset(tp,1);
  end
end