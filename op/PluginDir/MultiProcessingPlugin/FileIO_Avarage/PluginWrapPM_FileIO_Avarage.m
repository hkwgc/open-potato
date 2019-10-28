function  varargout = PluginWrapPM_FileIO_Avarage(fcn, varargin)
% Translation from Cell (Block / Continuous ) to Block Data.
%   ===== P3.1.6 : Multi-Processing-Plugin. =====
%
%  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and 'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PluginWrapPM_FileIO_Avarage('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = PluginWrapPM_FileIO_Avarage('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  PluginWrapPM_FileIO_Avarage('write',region, MPP)
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
% $Id: PluginWrapPM_FileIO_Avarage.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
    %--------> Special Function to Execute -------->
    if 0, ExeAverage;end
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
bi.name='File I/O Mode : Average';
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

%==============================
% Out put Result.
%==============================
mpp.wrap=mfilename;

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
make_mfile('with_indent',...
  sprintf('[data,hdata]=%s(''ExeAverage'',savefilenames);',mfilename));
make_mfile('with_indent', ' ');
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
function [data,hdata]=ExeAverage(filelist)
% Check
%=====================================
if isempty(filelist),
  error('No FileList Exist');
end
if 0,data0=[];hdata0=[];end
load(filelist{1},'data0','hdata0');
data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);
if ndims(data0)==4
  hdata=hdata0;
  % Block
  datanum=sum(~isnan(data0));
  data0(isnan(data0))=0;
  data=sum(data0);
  sz=size(data);
  for idx=2:length(filelist)
    load(filelist{idx},'data0','hdata0');
    data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);
    datanum0=sum(~isnan(data0));
    data0(isnan(data0))=0;
    data0=sum(data0);
    sz0=size(data0);
    if ~isequal(sz0(3:end),sz(3:end))
      warning('Current Version : Data size must be same');
      disp([' Data size of ' filelist{1} ':'])
      disp(sz);
      disp([' Data size of ' filelist{idx} ':'])
      disp(size(data0));
      continue;
    end
    if sz0(2)==sz(2)
      datanum=datanum+datanum0;
      data=data0+data;
    elseif sz0(2)>sz(2)
      datanum=datanum+datanum0(1,1:sz(2),:,:);
      data   =data   +data0(1,1:sz(2),:,:);
    else
      datanum(1,1:sz0(2),:,:)=datanum(1,1:sz0(2),:,:)+datanum0;
      data(1,1:sz0(2),:,:)   =data(1,1:sz0(2),:,:)   +data0;
    end
  end
  data=data./(datanum+(datanum==0));
  % --> Ajust 
  fsz=size(hdata.flag);
  if fsz(2)>1,
    try, hdata.stimTC2(2:end,:)=[];end
    try, hdata.stimkind(2:end,:)=[];end
    dn=sum(sum(datanum),4);
    try,dn=reshape(dn,[1,1,fsz(3)]);end
    try, hdata.flag=(dn==0);end
  end
  
else
  % Continuous
  datanum=~isnan(data0)+0;
  data0(isnan(data0))=0;
  data=data0;
  sz=size(data);
  for idx=2:length(filelist)
    load(filelist{idx},'data0','hdata0');
    data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);
    datanum0=~isnan(data0);
    data0(isnan(data0))=0;
    sz0=size(data0);
    if ~isequal(sz0(2:end),sz(2:end))
      warning('Current Version : Data size must be same');
      disp([' Data size of ' filelist{1} ':'])
      disp(sz);
      disp([' Data size of ' filelist{idx} ':'])
      disp(size(data0));
      continue;
    end
    if sz0(1)==sz(1)
      datanum=datanum+datanum0;
      data=data0+data;
    elseif sz0(1)>sz(1)
      datanum=datanum+datanum0(1:sz(1),:,:);
      data   =data   +data0(1:sz(1),:,:);
    else
      datanum(1:sz0(1),:,:)=datanum(1:sz0(1),:,:)+datanum0;
      data(1:sz0(1),:,:)   =data(1:sz0(1),:,:)   +data0;
    end
  end
  hdata=hdata0;
  hdata.flag=false(size(hdata.flag));
  data=data./(datanum+(datanum==0));
end

