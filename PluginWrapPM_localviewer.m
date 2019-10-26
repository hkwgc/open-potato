function  varargout = PluginWrapPM_localviewer(fcn, varargin)
% Viewer for Multi-Analysis Data (Local).
%   This function was System Plugin.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PluginWrapPM_localviewer('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = PluginWrapPM_localviewer('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  PluginWrapPM_localviewer('write',region, MPP)
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
% create : 2007.04.19
% Reversion : 1.00
%
% $Id: PluginWrapPM_localviewer.m 180 2011-05-19 09:34:28Z Katura $


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
bi.name='Local Viewer';
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.argdata.LayoutFile='nothing';

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
make_mfile('code_separator',1);
make_mfile('with_indent','% Viewer');
make_mfile('code_separator',1);
make_mfile('with_indent',...
  sprintf('load(''%s'',''LAYOUT'');',data.argData.LayoutFile));
make_mfile('with_indent',...
  'POTATo_win_MultiAnalysis(''p3view'',LAYOUT,hdata,data);');
return;

function l=FuncList
l={''};

