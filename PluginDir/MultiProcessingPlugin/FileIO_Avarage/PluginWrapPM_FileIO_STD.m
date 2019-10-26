function  varargout = PluginWrapPM_FileIO_STD(fcn, varargin)
% Standard deviation of Each-Files from Avarage
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = PluginWrapPM_FileIO_STD('createBasicIno');
%    Return Information for P3.
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  MPP = PluginWrapPM_FileIO_STD('getArgument',MPP, mfilename);
%     MPP is as same as
% ** write **
% Syntax:
%  PluginWrapPM_FileIO_STD('write',region, MPP)
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
% $Id: PluginWrapPM_FileIO_STD.m 293 2012-09-27 06:11:14Z Katura $

%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
    %--------> Special Function to Execute -------->
    if 0, getSD;end
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
bi.name='File I/O Mode : Standard deviation';
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
%make_mfile('with_indent', ' ');

%=========================
% Blocking Data
%=========================
make_mfile('with_indent',...
  sprintf('[hdata,sd]=%s(''getSD'',savefilenames,data,hdata);',mfilename));
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
function [hdata,data,sd]=getSD(filelist,varargin)
% Get SD
%=====================================

if isempty(filelist),
  error('No FileList Exist');
end

% get Average
if 1
  [data,hdata]=PluginWrapPM_FileIO_Avarage('ExeAverage',filelist);
else
  if nargin<3
    [data,hdata]=PluginWrapPM_FileIO_Avarage('ExeAverage',filelist);
  else
    data= varargin{1};
    hdata= varargin{2};
  end
end

if 0,data0=[];end
load(filelist{1},'data0','hdata0');
data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);

if ndims(data0)==4
  % (debug)
  %dbg_t=10;dbg_ch=2; dbg_kind=1;            % Debug
  %dbg_data=data0(:,dbg_t,dbg_ch,dbg_kind);  % Debug
  % Block
  datanum=sum(~isnan(data0));
  v=data0- repmat(data,[size(data0,1),1,1,1]);
  v(isnan(data0))=0;
  sd=sum(v.*v);
  sz=size(sd);
  % Loop
  for idx=2:length(filelist)
    load(filelist{idx},'data0','hdata0');
    data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);
    %dbg_data=[dbg_data(:);data0(:,dbg_t,dbg_ch,dbg_kind)]; % Debug
    datanum0=sum(~isnan(data0));
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
      v=data0-repmat(data,[size(data0,1),1,1,1]);
      v(isnan(v))=0;
      sd =sd +  sum(v.*v);
    elseif sz0(2)>sz(2)
      datanum=datanum+datanum0(1,1:sz(2),:,:);
      v      =data0(:,1:sz(2),:,:)-repmat(data,[size(data0,1),1,1,1]);
      v(isnan(v))=0;
      sd =sd +  sum(v.*v);
    else
      datanum(1,1:sz0(2),:,:)=datanum(1,1:sz0(2),:,:)+datanum0;
      v      =data0 -repmat(data(1,1:sz0(2),:,:),[size(data0,1),1,1,1]);
      v(isnan(v))=0;
      sd(1,1:sz0(2),:,:)=sd(1,1:sz0(2),:,:) + sum(v.*v);
    end
  end
  divtmp = datanum-1;
  divtmp(divtmp<=0)=1;
  sd  = sqrt(sd./divtmp);
  sd(datanum==1) =0;
  sd(datanum==0) =NaN;
  hdata.Results.FileIO_SD=sd;
  % Debug
  %disp(std(dbg_data(:)));             % Debug
  %disp(sd(1,dbg_t,dbg_ch,dbg_kind));  % Debug
else
  % (debug)
  %dbg_t=10;dbg_ch=2; dbg_kind=1;            % Debug
  %dbg_data=data0(dbg_t,dbg_ch,dbg_kind);  % Debug
  % Continuous
  datanum=~isnan(data0)+0;
  v=data0- data;
  v(isnan(data0))=0;
  sd=v.*v;
  sz=size(sd);
  
  for idx=2:length(filelist)
    load(filelist{idx},'data0','hdata0');
    data0   = PlugInWrap_Flag2NaN('exe0',data0,hdata0);
    %dbg_data=[dbg_data(:);data0(dbg_t,dbg_ch,dbg_kind)]; % Debug
    datanum0=~isnan(data0);
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
      v=data0- data;
      v(isnan(data0))=0;
      sd=sd+v.*v;
    elseif sz0(1)>sz(1)
      datanum=datanum+datanum0(1:sz(1),:,:);
      v   =data0(1:sz(1),:,:)-data;
      v(isnan(data0))=0;
      sd=sd+v.*v;
    else
      datanum(1:sz0(1),:,:)=datanum(1:sz0(1),:,:)+datanum0;
      v      =data0-data(1:sz0(1),:,:);
      v(isnan(data0))=0;
      sd(1:sz0(1),:,:)=sd(1:sz0(1),:,:) + v.*v;
    end
  end
  divtmp = datanum-1;
  divtmp(divtmp<=0)=1;
  sd  = sqrt(sd./divtmp);
  sd(datanum==1) =0;
  sd(datanum==0) =NaN;
  hdata.Results.FileIO_SD=sd;
  % Debug
  %disp(std(dbg_data(:)));             % Debug
  %disp(sd(dbg_t,dbg_ch,dbg_kind));  % Debug
end

