function  varargout = PluginWrapPM_Sample(fcn, varargin)
% Sample Progrum of Multi-Processing-Plugin.
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and 'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = MPP_PlugIn_Sample('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = MPP_PlugIn_Sample('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  MPP_PlugIn_Sample('write',region, MPP)
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
% $Id: PluginWrapPM_Sample.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
mlist=FuncList;
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
    %--------> Special Function to Execute -------->
    %<-------- Special Function to Execute <--------
  case mlist
    [varargout{1:nargout}]=feval(fcn, varargin{:});
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
bi.name='Sample';
bi.version=0;
%--> suggested <--
bi.type  =0; % not defined now
bi.region=0; % not defined now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  data=getArgument(data, b_mfile)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Event_Reblock.
%     data.argData : Argument of Plug in Function.
%        argData.Format  : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mlist=FuncList;
tmp=menu('Choose Format to display Data.',mlist);
if isequal(tmp,2) || isequal(tmp,1),
  data.argData.Format=mlist{tmp};
else
  data=[];return;
end
if 0,type(b_mfile);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, data) 
% write make M-File to execute Multi-Plug-in of "Sample".
%  where data is as same as getArgument's data.
%
% There is two method to make M-File.
%   1. use function 'make_mfile'
%      make_mfile is opend at default, so you
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(region);end
str='';

make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' data.name ' ==']);
make_mfile('with_indent', ['%    ' mfilename  ' v1.0 ']);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');

% -- ( notion : debug) --
make_mfile('with_indent',...
  sprintf('[hdata,data]= %s(''%s'',hdata, data);',...
  mfilename,data.argData.Format));
make_mfile('with_indent',sprintf('load %s',datafilename));
make_mfile('with_indent', ' ');
return;


%##########################################################################
% Special Functions
%##########################################################################
%=====================================
function mlist=FuncList
% Function List of Main write
%=====================================
mlist={'TmpFile','Layout1'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Function (Main)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata,data]=TmpFile(hdata,data)
% Make temporality File
tp=checkdatatype(hdata,data);
dataassign(tp,hdata,data)
switch tp
  case 0,
    % 00(0) : Normal-Continuos
  case 1,
    % 01(1) : Normal-Block
  case 2,
    % 10(2) : Cell  -Continuous
  case 3,
    % 11(3) : Cell  -Block
end

function [hdata,data]=Layout1(hdata,data)
% View current-Data
tp=checkdatatype(hdata,data);
dataassign(tp,hdata,data)
switch tp
  case 0,
    % 00(0) : Normal-Continuos
  case 1,
    % 01(1) : Normal-Block
  case 2,
    % 10(2) : Cell  -Continuous
  case 3,
    % 11(3) : Cell  -Block
end

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

function fname=datafilename
% Data File Name
p=which(mfilename);
p=fileparts(p);
fname=[p filesep 'tmp_MA_Sample.mat'];

function dataassign(tp,hdata,data)
% -> Rename Data
switch tp
  case 0,
    % 00(0) : Normal-Continuos
    chdata={hdata};cdata={data};
    save(datafilename,'chdata','cdata');
    if 0,disp(chdata,cdata);end
  case 1,
    % 01(1) : Normal-Block
    bhdata=hdata;bdata=data;
    save(datafilename,'bhdata','bdata');
    if 0,disp(bhdata,bdata);end
  case 2,
    % 10(2) : Cell  -Continuous
    chdata=hdata;cdata=data;
    save(datafilename,'chdata','cdata');
    if 0,disp(chdata,cdata);end
  case 3,
    % 11(3) : Cell  -Block
    cb_hdata=hdata;cb_data=data;
    save(datafilename,'cb_hdata','cb_data');
    if 0,disp(cb_hdata,cb_data);end
end
