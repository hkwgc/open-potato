function varargout = PlugInWrap_Ttest(fcn, varargin)
% "t test" is Plug-in Function of POTATo.
%   "t test" perfome T-Test.

% T-Test, Fileter-Plug-In Function.
%
% ** CREATE BASIC INFORMATION **
%   Return Information of this Function.
% Syntax:
%  basic_info = PlugInWrap_AddTTest('createBasicIno');
%
%    basic_info.name :
%       Display-Name == 'T Test (Add)'
%    basic_info.region :
%       Region Number that this function is available.
%         BLOCKDATA    : 3
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = PlugInWrap_AddTTest('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_MaxDivide.
%     filterData.argData : Argument of Plug in Function.
%                   --> See also UITTEST2
%     mfilename : M-File, before PlugInWrap-AddTTest execute.
%
% ** write **
% Syntax:
%  str = PlugInWrap_AddTTest('write',region, fdata)
%
%  Make M-File, correspond to Plug-in function.
%  by usinge make_mfile.
%  if str, out-put by str.
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
% create : 2006.02.15
% $Id: PlugInWrap_Ttest.m 304 2013-01-25 09:44:55Z Katura $
%

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
function  basicInfo= createBasicInfo,
% Definition of this Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   = 't test';
basicInfo.region = 3;
DefineOspFilterDispKind;
basicInfo.DispKind=F_DataChange;
basicInfo.Description='T-Test : Make Results';
basicInfo.version=1.5;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin),
% Set Option of T-Test
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_AddTTest.
%     filterData.argData : Argument of Plug in Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <-- Get Filter-Data-Arguments -->
data0 = varargin{1}; % Filter Data
if isfield(data0, 'argData')
  % Use Setting Value.
  % ( ececute on click : Change button )
  data = data0.argData;
else
  % No-Argument in the data
  % ( execute on click : Add button )
  data = [];
end

% Before - Data -
if nargin>=2 && exist(varargin{2},'file'),
  mfile_pre = varargin{2};
else,
  mfile_pre = '';
end

data=uiTtest4('argData',data,'Mfile_Pre',mfile_pre); %GUI:Expand of period setting
%data=uiTtest2('argData',data,'Mfile_Pre',mfile_pre);
%data=uiTtest2(data,mfile_pre);
if isempty(data), data0=[];
else,             data0.argData=data; end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata)
% Make M-File of PlugInWrap_uiTtest4
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_MaxDivide.
%     filterData.argData : Argument of Plug in Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rev = '$Revision: 1.9 $'; rev([1,end])=[];  % using uiTtest4 GUI
%rev = '$Revision: 1.9 $'; rev([1,end])=[];
dd  = '$Date : $';    dd([1,end])=[];

%===========================================================
% <-- Header -->
%===========================================================
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', ['%    ' rev]);
make_mfile('with_indent', ['%    ' dd]);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');

%===========================================================
% Region Check
%===========================================================
if ~strcmp(region,'BlockData') && ~strcmp(region,'Multi')
  make_mfile('with_indent', ...
    ['%ERROR : ' ...
    C__FILE__LINE__CHAR]);
  make_mfile('with_indent', 'errordlg(''T-Test Error'');');
  errordlg({'OSP Error : ', ...
    ' T-Test try to Execute in Un-Blocked-Region', ...
    ' Ignore T-Test'});
  str='';
  return;
end

%===========================================================
% Making Data Set (with peack search )
%===========================================================
argData=fdata.argData;
periodData=argData.Period;
if isfield(periodData, 'detailSet') && periodData.detailSet==true,
  %-------------------------
  % Period: detailSet(true)
  %-------------------------
  % Create idx1_list, idx2_list
  tags = periodData.TAGs;
  idx1_diff = []; idx2_diff = [];
  idx1_list={};   idx2_list={};
  for k_idx=1:length(tags), % kinds size
    idx1=periodData.idx1;
    idx2=periodData.idx2;
    if isfield(periodData, tags{k_idx}),
      t    = getfield(periodData, tags{k_idx});
      if isfield(t, 'idx1'), idx1 = getfield(t, 'idx1');end
      if isfield(t, 'idx2'), idx2 = getfield(t, 'idx2');end
    end
    idx1_diff=[idx1_diff diff(idx1)+1];
    idx2_diff=[idx2_diff diff(idx2)+1];

    idx1_list{end+1} = idx1;
    idx2_list{end+1} = idx2;
  end
  % Get Max of index's diff
  idx1_max = max(idx1_diff);
  idx2_max = max(idx2_diff);

  % < Start Operation >
  % Clear datap1,2
  make_mfile('with_indent', '% Initialize datap1, datap2');
  make_mfile('with_indent', 'period_size=size(data);');
  make_mfile('with_indent', ...
    sprintf('period_size(2)=%d;',idx1_max));
  make_mfile('with_indent', 'datap1=zeros(period_size);');
  make_mfile('with_indent', 'datap1=datap1.*NaN;');
  make_mfile('with_indent', ...
    sprintf('period_size(2)=%d;',idx2_max));
  make_mfile('with_indent', 'datap2=zeros(period_size);');
  make_mfile('with_indent', 'datap2=datap2.*NaN;');

  % get Period
  make_mfile('with_indent', '% Test Period1, Period2');
  for k_idx=1:length(tags), % kinds size
    make_mfile('with_indent', ...
      sprintf('datap1(:,%d:%d,:,%d)=data(:,%d:%d,:,%d);',...
      1,idx1_diff(k_idx),k_idx,...
      idx1_list{k_idx}(1),idx1_list{k_idx}(2),k_idx));

    make_mfile('with_indent', ...
      sprintf('datap2(:,%d:%d,:,%d)=data(:,%d:%d,:,%d);',...
      1,idx2_diff(k_idx),k_idx,...
      idx2_list{k_idx}(1),idx2_list{k_idx}(2),k_idx));
  end % kind loop end
  make_mfile('with_indent', ' ');
  make_mfile('code_separator', 5);
  make_mfile('with_indent', ' ');

  % Execute Peack Search
  if isfield(argData,'PeakSearch') && ...
      argData.PeakSearch.enable==true;
    if argData.PeakSearch.period==1,
      % Select Area is Period 1
      make_mfile('with_indent', '% Peak Search for period 1');
      for k_idx=1:length(tags), % kinds size
        % make Peak-Search for Period1
        make_mfile('with_indent', ...
          sprintf(['temp_data1=' ...
          'osp_peaksearch(data,' ...
          '[%d,%d], [%d,%d]);'], ...
          idx1_list{k_idx}(1), idx1_list{k_idx}(2),...
          argData.PeakSearch.SearchArea.idx(1), ...
          argData.PeakSearch.SearchArea.idx(2)));
        make_mfile('with_indent', ...
          sprintf('datap1(:,%d:%d,:,%d)=temp_data1(:,:,:,%d);', ...
          1,idx1_diff(k_idx),k_idx,k_idx));
      end
    end
    if argData.PeakSearch.period==2,
      % Select Area is Period 2
      make_mfile('with_indent', '% Peak Search for Period2');
      for k_idx=1:length(tags), % kinds size
        % make Peak-Search for Period2
        make_mfile('with_indent', ...
          sprintf(['temp_data2=' ...
          'osp_peaksearch(data,' ...
          '[%d,%d], [%d,%d]);'], ...
          idx2_list{k_idx}(1), idx2_list{k_idx}(2),...
          argData.PeakSearch.SearchArea.idx(1), ...
          argData.PeakSearch.SearchArea.idx(2)));
        make_mfile('with_indent', ...
          sprintf('datap2(:,%d:%d,:,%d)=temp_data2(:,:,:,%d);', ...
          1,idx2_diff(k_idx),k_idx,k_idx));
      end
    end
  end
  %----- periodData.detailSet(true) --- end
else
  %-------------------------
  % Period: detailSet(false)
  %-------------------------
  % < Start Operation >
  % get Period
  make_mfile('with_indent', '% Test Period1');
  make_mfile('with_indent', ...
    sprintf('datap1=data(:,%d:%d,:,:);',...
    argData.Period.idx1(1), ...
    argData.Period.idx1(2)));
  make_mfile('with_indent', '% Test Period2');
  make_mfile('with_indent', ...
    sprintf('datap2=data(:,%d:%d,:,:);',...
    argData.Period.idx2(1), ...
    argData.Period.idx2(2)));


  make_mfile('with_indent', ' ');
  make_mfile('code_separator', 5);
  make_mfile('with_indent', ' ');

  % Execute Peack Search
  if isfield(argData,'PeakSearch') && ...
      argData.PeakSearch.enable==true;
    if argData.PeakSearch.period==1,
      % Select Area is Period 1
      make_mfile('with_indent', '% Peak Search for period 1');
      make_mfile('with_indent', ...
        sprintf(['datap1=' ...
        'osp_peaksearch(data,' ...
        '[%d,%d], [%d,%d]);'], ...
        argData.Period.idx1(1), ...
        argData.Period.idx1(2),...
        argData.PeakSearch.SearchArea.idx(1), ...
        argData.PeakSearch.SearchArea.idx(2)));
    else
      % Select Area is Period 2
      make_mfile('with_indent', '% Peak Search for period 2');
      make_mfile('with_indent', ...
        sprintf(['datap2=' ...
        'osp_peaksearch(data,' ...
        '[%d,%d], [%d,%d]);'], ...
        argData.Period.idx2(1), ...
        argData.Period.idx2(2),...
        argData.PeakSearch.SearchArea.idx(1), ...
        argData.PeakSearch.SearchArea.idx(2)));
    end
  end
end  %----- periodData.detailSet(false) --- end

%===========================================================
% Bugfix : B061219A: ==> 
%===========================================================
make_mfile('with_indent','for bid=1:size(datap1,1)');
make_mfile('with_indent','  badch=find(hdata.flag(1,bid,:));');
make_mfile('with_indent','  datap1(bid,:,badch,:)=NaN;');
make_mfile('with_indent','  datap2(bid,:,badch,:)=NaN;');
make_mfile('with_indent','end');
 
%===========================================================
% Execute TTest!
%===========================================================
if argData.Option.ttest,
  make_mfile('with_indent', '% ==== T Test ===');
  make_mfile('with_indent', 'hdata.Results.ttest=...');
  make_mfile('with_indent', ...
    sprintf('   uiTtest2_ttest(datap1,datap2,%f,hdata);',...
    argData.Option.threshold));
  make_mfile('with_indent', ' ');
end
if argData.Option.ranksum,
  make_mfile('with_indent', '% ==== Wilcoxon Rank Sum Test ===');
  make_mfile('with_indent', 'hdata.Results.ranksum=...');
  make_mfile('with_indent', ...
    sprintf('   uiTtest2_ranksum(datap1,datap2,%f);',...
    argData.Option.threshold));
  make_mfile('with_indent', ' ');
end

make_mfile('with_indent', ' ');
make_mfile('code_separator', 5);
make_mfile('with_indent', ' ');


str='';

return;
