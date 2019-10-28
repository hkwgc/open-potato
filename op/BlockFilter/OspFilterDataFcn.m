function varargout = OspFilterDataFcn(mode, varargin)
% Filter Data Definition of OSP
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 2.50
% !! Change !! Filter-Data-Manage Definition
% -------------------------------------
%
% OspFilterDataFcn;
%    Launch Help of 'FilterDataFcn', See also
%
% [FilterList Regions] = OspFilterDataFcn('getList');
%   return Available Filter-List
%          And Exist Region-List
%
% ar = OspFilterDataFcn('getAllowRegion',FilterName);
%    get Allow-Region of FilterName
%
% [FilterDataManager, index] = OspFilterDataFcn('makeData',fdm, filtername);
%   Add 'Filter-Data' to "Filter-Data-Manager"
%     * fdm is original "Filter-Data-Manager"
%          , if fdm is empty, new fdm
%     * filtername is adding 'Filter-Data' name
%     * FilterDataManager, return value,
%         is created "Filter-Data-Manager"
%     * index  is index of Adding Data Position
%        if no data to add(setup canceled), return null
%        index is vector,
%             col 1 : Region Index
%             col 2 : Filter Index(in Region)
%             col 3 : Data index, alway 0 in this case
%
% FilterData = OspFilterDataFcn('fixData', FilterData);
%   fix FilterData.
%   This Function will wait for User Input.
%
% [info, linfo] = OspFilterDataFcn('getInfo',fdm);
%   Return cell Stirngs that discribe Information of fdm
%     info is information of fdm
%     linfo is fdm-index corespond to information-line
%            linfo is matrix  Line x index
%            index is as same as 'makeData' definition
%
%
% ======= Definition of Filter Data Manage =======
% classify Filter Data in Region
%  FilterDataManage.Raw          : Filtering for Raw Data
%                                 ( not in use)
%  FilterDataManage.HBdata       : Filtering for HB Data
%  FilterDataManage.BlockPeriod  : Block Size for Blocking.
%                                  ( since rv 1.6, OSP version 1.10)
%                   BlockPeriod(1) : Pre  stimulation time [sec]
%                   BlockPeriod(2) : Post stimulation time [sec]
%  FilterDataManage.BlockData    : Filtering for Blocked Data
%  !! HBdata, BlockData, Raw is Cell !! since 1.12
%
% ======= Definition of Filter Data =======
% Specify Filter
%   filterData.name    : filter name
%   filterData.wrap    : filter-wraper Function-Pointer
%   filterData.argData : Argument of Function
%
%   -- in Setting --
%   filterData.enable  :  Enable flag
%                         'on'  : useing
%                         'off' : suspend the data
%
% See also OSPFILTERMAIN, OSPHELP.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2005.01.30
% $Id: OspFilterDataFcn.m 404 2014-04-16 02:29:23Z katura7pro $
%

% Revision 1.6
%    New Filter :
%         Motion Check.
%         Resize-Block.
%
%    Change Definition of FilterDataManage:
%       new filed : BlockPeriod  : Block Size for Blocking.
%                   BlockPeriod(1) : Pre  stimulation time [sec]
%                   BlockPeriod(2) : Post stimulation time [sec]
%
% Revision 1.14
%    Find PluginWrap :: Child
% Revision 1.15
%    BookMark : Add ( verion 0)
% Revision (SVN) xx
%    Change Help  :: 2012/07/30

% -- removed --
% [filedName, id]  = OspFilterDataFcn('getDataId',fdm, info, line);
%   Get Field name of fdm and id correspond to info{line}
%     * field name : Field name of fdm
%                    if line is not a Data, null
%     * id         : is FilterData ID, if no
%                    if line is not a Data, 0
%

% argument check
if nargin<0,
  OspHelp('FilterDataFcn');
end

% *************************************************
%       Set   HERE  : If you Add Filter
% *************************************************

% -- 'Filter Data Manage' classify Filter Data in Region --
% -- Region Definition --
Regions={'Raw', 'HBdata', 'BlockData'};

if ~strcmpi(mode,'ListReset')
  [FilterList, wrapper, FilterAllowed, FilterDispKind, BookMarkString] = ...
    list_io(Regions);
end

% *************************************************
%       End of Setting
%           Regions setting is in getInfo
% *************************************************

switch mode
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'ListReset',
    % Reset (search )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [varargout{1:nargout}]=list_io(Regions,'reset');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'FuncHelp',
    % ar = OspFilterDataFcn('FuncHelp',FilterName);
    %    get Allow-Region of FilterName
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    id = find(strcmp(FilterList,varargin{1}));
    if isempty(id)
      error(['No such a Filter : ' char(varargin{1})]);
    end
    try
      if ~ischar(wrapper{id});
        fn=func2str(wrapper{id});
      else
        fn=wrapper{id};
      end
      %OspHelp(fn);
      sfh=gcbf;uihelp(fn);figure(sfh);
      %set(0,'currentFigure',sfh)

		catch
			errordlg(['Error : ' lasterr],'Help Error');
      %help OspFilterDataFcn
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'getAllowRegion'
    % ar = OspFilterDataFcn('getAllowRegion',FilterName);
    %    get Allow-Region of FilterName
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    id = find(strcmp(FilterList,varargin{1}));
    if isempty(id)
			%--- try without [beta] mark
			id = find(strcmp(FilterList,[getDefString_forBeta varargin{1}]));
			if isempty(id)
				error(['No such a Filter : ' char(varargin{1})]);
			end
    end
    varargout{1} = FilterAllowed{id};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'getInfo',
    % [info, linfo] = OspFilterDataFcn('getInfo',fdm);
    % Get Information (--> FMD Listbox )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [varargout{1}, varargout{2}] = getInfo(varargin{1},...
      Regions,FilterList);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'makeData'
    % [FilterDataManager, index] =
    %  OspFilterDataFcn('makeData',fdm, filtername,fpos);
    %   Add 'Filter-Data' to "Filter-Data-Manager"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fdm          = varargin{1}; % Filter Data Manager
    filData.name = varargin{2}; % Filter Data-Name
    b_mfile      = varargin{3}; % mfile for
    % Input Filter-Data Position (since r1.12)
    if length(varargin)>=4,
      fpos =varargin{4};
    else
      fpos = [-1, -1, -1]; % default : replace
    end

    %---------------------------------
    % Get Filter-Data from Filter-Name
    %---------------------------------
    id = find(strcmp(FilterList,filData.name));
    if isempty(id)
      error(['No such a Filter : ' filData.name]);
    end
    % Pointer of Filter-Data
    filData.wrap = wrapper{id}; % PlugiWrap_* / FilterDef_*

    % ==> Get Argument From FilterDef / PluginWrap function.
    filData = P3_PluginEvalScript(filData.wrap,'getArgument',filData, b_mfile); % Get Data
    if isempty(filData)
      % User : Cancel :
      varargout{1} = fdm;
      varargout{2} = [];
      return;
    end
    % Add Enable Setting
    filData.enable='on';
		filData=subVersionVariableCheck(filData);%- 2013-01-24 TK@CRL

    %---------------------------------
    % Get Insert Region
    %---------------------------------
    rgn_id  = FilterAllowed{id};
    rgn_id(rgn_id==1)=[]; % remove 1
    % 
    if any(rgn_id~=fpos(1)),
      rgn_id=rgn_id(1); % Set Region ID
    else
      % Input Region
      rgn_id=fpos(1); % Set Region ID
    end
    if rgn_id==-1,
      Regions{end+1}='TimeBlocking';
      fdm.block_enable=true;
      rgn_id=length(Regions);
      fdm.BlockPeriod = filData.argData.BlockPeriod;
    end

    % Set to Filter Manage Data ( fmd )
    flt_ps = 1;       % Set Filter - Position
    if isempty(fdm),
      % New : Filter Data Manager
      %--> since 1.12 : Struct to Cell
      fdm = struct(Regions{rgn_id},{filData});
    elseif isfield(fdm,Regions{rgn_id}),
      % Add to Existing Region :
      %--> since 1.12 : Struct to Cell
      % tmp = getfield(fdm,Regions{rgn_id});
      tmp = fdm.(Regions{rgn_id});
      if isempty(tmp)
        tmp= {filData};
      else
        if isstruct(tmp),
          % Change Struct to Cell;
          tmp0={};
          for tidx=1:length(tmp),tmp0{tidx}=tmp(tidx); end
          tmp = tmp0;
        end
        if strcmp(Regions{rgn_id},'TimeBlocking')
          tmp= {filData};
        else
          tmp{end+1} = filData;
        end
      end
      % fdm = setfield(fdm,Regions{rgn_id},tmp);
      fdm.(Regions{rgn_id})=tmp;
      flt_ps=length(tmp);
    else
      % Add New Region :
      %--> since 1.12 : Struct to Cell
      % fdm = setfield(fdm,Regions{rgn_id},{filData});
      fdm.(Regions{rgn_id})={filData};
    end
    varargout{1} = fdm;
    if nargout>=2 
      if rgn_id==length(Regions),
        varargout{2} = [3, 0, 0];
      else
        varargout{2} = [rgn_id, flt_ps, 0];
      end
    end

  case 'fixData'
    % FilterData = OspFilterDataFcn('fixData', FilterData);
    %   fix FilterData.
    filData = varargin{1};
    b_mfile = varargin{2}; % mfile for
    if ~isfield(filData,'name') || ~isfield(filData,'wrap')
      OSP_LOG('err', ...
        '2nd Argument Error : Out-of  Filter Data Format');
      error('2nd Argument Error : Out-of  Filter Data Format');
    end
    filData = P3_PluginEvalScript(filData.wrap,'getArgument',filData, b_mfile);
    if isfield(filData, 'enable')
      filData.enable='on';
		end
		filData=subVersionVariableCheck(filData);%- 2013-01-24 TK@CRL
    varargout{1} = filData;

  case 'getList'
    % FilterList = OspFilterDataFcn('getList');
    varargout{1} = FilterList;
    if nargout>=2
      varargout{2} = Regions;
    end
    if nargout>=3,
      varargout{3} = FilterDispKind;
    end

  case 'getDataId',
    OSP_LOG('perr','Removed Mode Called');

  case 'BookMarkString',
    varargout{1}=BookMarkString;
  otherwise,
    if nargout,
      [varargout{1:nargout}] = feval(mode, varargin{:});
    else
      feval(mode, varargin{:});
    end
end
% Reset List
if strcmpi(mode,'SaveBookMarkString'),
  list_io(Regions, 'reset');
end

return;


function [info, linfo] = getInfo(fdm,Regions, FilterList)
% Make Information of fdm:
%   info is information of fdm
%   linfo is fdm-index corespond to information-line
%       linfo is matrix  Line x indexkind
%                integer of fdm-idx,
%          col 1 : Regions Index
%          col 2 : Filter Index
%          col 3 : Exprain-id ( 0 : not explain )

% -- Initiarize  --
%  Regions Explain
% !!! Warning : length(Regions)==length(rgstr)
rgstrBlocking = '---  Blocking  ---';
rgstrBlockingDisabled = '( Blocking disabled ) <<< <<< <<<';

rgstr={'---- Information of Filter ----', ...
  '[     ANALYSIS RECIPE     ]', rgstrBlocking };

line=1; info={}; linfo=[];

% Region Loop
for rg = 2:length(Regions)

  % Get FilterData
  if isfield(fdm,Regions{rg}),
    fdata = getfield(fdm,Regions{rg});
  else
    % No Region.
    %   OSP ver1.5, 9th Meeting ->
    %   Ready for Continuous-Data
    if rg>2 && ~isfield(fdm,'BlockPeriod'), continue; end		% Blocking is not Print
    fdata = [];
  end

  % Print Region Header
  if strcmp(rgstr{rg},rgstrBlocking) && ...
      isfield(fdm,'block_enable') && fdm.block_enable==0,
    info{end+1}=rgstrBlockingDisabled;
  else
    info{end+1}=rgstr{rg};
  end
  linfo(line,:)=[rg 0 0];
  line=line+1;

  % add 10-Jun-2005 22:00
  %   Block Period Setting
  if strcmp(Regions{rg},'BlockData'),    % Blocking
    if ~isfield(fdm,'BlockPeriod'),
      fdm.BlockPeriod = BlockPeriodInputdlg;
      if isempty(fdm.BlockPeriod),
        fdm.BlockPeriod = [5, 15];
      end
    end
    %   Print Data-info in a line.
    %   OSP ver1.5, 9th Meeting.
    if isfield(fdm,'TimeBlocking') && ...
        ~isempty(fdm.TimeBlocking) && ...
        isfield(fdm.TimeBlocking{1},'argData') && ...
        ~isempty(fdm.TimeBlocking{1}.argData)
      % P3 Blocking
      argchr='    > ';
      argstrct=fdm.TimeBlocking{1}.argData;
      argname = fieldnames(argstrct);
      % Argument List Loop
      for agid = 1:length(argname)
        argvar = getfield(argstrct,argname{agid});
        if isnumeric(argvar)
          % Numeric?
          argvar = argvar(:);
          tmp = num2str(argvar');
          if length(argvar)~=1
            tmp = [ '[' tmp ']'];
          end
          argvar = tmp;
        elseif isstruct(argvar),
          % Structure?
          tmp=fieldnames(argvar);
          argvar='struct(';
          for idx2=1:length(tmp),
            argvar=[argvar tmp{idx2} ', '];
          end
          if isempty(tmp),
            argvar='Empty-Structure';
          else
            argvar(end-1)=')';
          end
        elseif iscell(argvar),
          tmp = '{';
          for tmpsz=size(argvar),
            tmp = [tmp num2str(tmpsz(1)) 'x'];
          end
          tmp(end) = '}';
          argvar = tmp;
        end
        argchr =[argchr argname{agid} ':' ...
          argvar ', '];
      end % Argument Data Loop
      %<---------
    else
      % ==> Normal Blocking (OSP Blocking)
      argchr=['   -> Pre Stim : ' num2str(fdm.BlockPeriod(1)) ...
        '   -> PostStim : ' num2str(fdm.BlockPeriod(2))];
    end
    info{end+1}=argchr;
    linfo(line,:)=[rg 0 1];   line=line+1;
  end

  %-----------
  if isstruct(fdata),
    warning('Old Code : Exsit');
    fdata0={};
    for fd = 1:length(fdata),
      fdata0{fd}=fdata(fd);
    end
    fdata=fdata0;
  end
  % Filter Data Loop
  for fd = 1:length(fdata)

    % Print Filter Name
    %   filterData.enable  :  Enable flag
    fdata0 = fdata{fd};
    if strcmp(fdata0.enable,'on')
      info{end+1}=[' o ' fdata0.name];
    else
      info{end+1}=[' x ' fdata0.name];
    end
    linfo(line,:)=[rg fd 0];
    line=line+1;

    
    % Print Filter Name
    if ~isfield(fdata0,'argData') || ...
        isempty(fdata0.argData),
      argchr = '    >  No Argument';
    else
      argstrct= fdata0.argData;
      if ~isstruct(argstrct),
        error('Argument Data Must be Structure');
      end
      argchr='    > ';
      argname = fieldnames(argstrct);
      % Argument List Loop
      for agid = 1:length(argname)
        argvar = getfield(argstrct,argname{agid});
        if isnumeric(argvar)
          % Numeric?
          argvar = argvar(:);
          tmp = num2str(argvar');
          if length(argvar)~=1
            tmp = [ '[' tmp ']'];
          end
          argvar = tmp;
        elseif isstruct(argvar),
          % Structure?
          tmp=fieldnames(argvar);
          argvar='struct(';
          for idx2=1:length(tmp),
            argvar=[argvar tmp{idx2} ', '];
          end
          if isempty(tmp),
            argvar='Empty-Structure';
          else
            argvar(end-1)=')';
          end
        elseif iscell(argvar),
          tmp = '{';
          for tmpsz=size(argvar),
            tmp = [tmp num2str(tmpsz(1)) 'x'];
          end
          tmp(end) = '}';
          argvar = tmp;
        end
        argchr =[argchr argname{agid} ':' ...
          argvar ', '];
      end % Argument Data Loop
    end
    info{end+1}=argchr;
    linfo(line,:)=[rg fd 1];
    line=line+1;
  end % Filter Data Loop
end % Region Loop

return;

function fname=getDeleteListFilename(str)
% Delete List File-Name
if nargin<1
  str=OSP_DATA('GET','FILTER_RECIPE_GROUP_TYPE');
end
p=OSP_DATA('GET','OspPath');
fname=[p filesep 'ospData' filesep ...
  'P3_FilterPlugin_DeleteList_' str(end) '.mat'];
return;

function varargout = list_io(Regions, varargin)
% *************************************************
%       Renew for Plug-in function
% *************************************************
% 05-Jul-2005.
% M.Shoji
global WinP3_EXE_PATH;
persistent list_singleton_;
persistent FilterList wrapper FilterAllowed FilterDispKind;
persistent BookMarkString;

OSP_LOG('msg','Filter list I/O Called');
%==> Singleton <==
if ~isempty(list_singleton_) && isempty(varargin),
  % Return : When List exist.
  if nargout>=1,
    varargout{1} = FilterList;
  end
  if nargout>=2,
    varargout{2} = wrapper;
  end
  if nargout>=3,
    varargout{3} =  FilterAllowed;
  end
  if nargout>=4,
    varargout{4} =  FilterDispKind;
  end
  if nargout>=5,
    varargout{5} =  BookMarkString;
  end
  return;
end
list_singleton_=true;
OSP_LOG('msg','start');
% ===> 1st Call
%       or Option's in List_io

%mlock;  % Locking Data

% -- 'Filter Data Manage' classify Filter Data in Region --
% -- Region Definition --
% Regions={'Raw', 'HBdata', 'BlockData'};

% *************************************************
% Default Filter's Setting
% *************************************************
% ========= Filter Data Definition ==========
% -- Filter Name --
FilterList= {...
  'Blocking', ...
  'MovingAverage', ...
  'Polyfit-Difference' , ... % when change, change also FilterDef_
  'Baseline Correction',...
  'Motion Check', ...        % Motion Check
  'Band Filter', ...
  'PCA', ...
  'Merge PCA Data', ... % Add PCA-Data to last data-kind
  'Resize Block'...
  };
%       'butterworth(bpf)', ... % when change, change also FilterDef_
%       'butterworth(bsf)', ... % when change, change also FilterDef_
%       'butterworth(hpf)', ... % when change, change also FilterDef_
%       'butterworth(lpf)', ... % when change, change also FilterDef_
%       'box for fft', ...
% -- Corresponding FilterWrapper --
wrapper ={ ...
  @FilterDef_TimeBlocking,...
  @FilterDef_MovingAverage,...
  @FilterDef_LocalFitting,...
  @FilterDef_LocalFitting, ...
  @FilterDef_MotionCheck, ...
  @FilterDef_BandFilter, ...
  @FilterDef_PCA, ...
  @FilterDef_Merge_PCA, ...
  @FilterDef_ResizeBlock...
  };
%     @FilterDef_Butter, ...
%     @FilterDef_Butter, ...
%     @FilterDef_Butter, ...
%     @FilterDef_Butter, ...
%     @FilterDef_FFT, ...


% Filter Allowed Region ( define by the filter )
BLOCKING=-1;
rawid=1; hbid=2; blockid=3;
FilterAllowed ={ ...
  BLOCKING        , ...
  [       hbid, blockid], ...% Moving-Average
  [       hbid, blockid], ...% Polifit-Diff
  [             blockid], ...% Local-Fitting
  [       hbid         ], ...% Motion Check
  [       hbid, blockid], ...% Band Filter
  [       hbid, blockid], ...% PCA
  [       hbid         ], ...
  [             blockid]};
%     [       hbid, blockid], ...
%     [       hbid, blockid], ...
%     [       hbid, blockid], ...
%     [       hbid, blockid], ...
%     [       hbid, blockid], ...
DefineOspFilterDispKind; % <- Filter Display Mode Variable :: Load
FilterDispKind = [ ...
  (F_Blocking              ), ...
  bitor(F_General,F_TimeSeries), ...
  bitor(F_General,F_TimeSeries), ...
  bitor(F_General,F_TimeSeries), ...
  bitor(F_General,F_Flag), ...
  bitor(F_General,F_TimeSeries), ...% Band Filter
  (F_TimeSeries), ...
  (F_DataChange), ...
  (F_DataChange)];
%       (F_General + F_TimeSeries), ...
%       (F_General + F_TimeSeries), ...
%       (F_General + F_TimeSeries), ...
%       (F_General + F_TimeSeries), ...
%       (F_General + F_TimeSeries), ...

OSP_LOG('msg','setup default');
% *************************************************
% Plugin Setting
% *************************************************
% + Search Plugin &Set
% osp_path   = fileparts(which('OSP'));
logmsg ={}; % Log
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
%plugin_path = [osp_path filesep '..' filesep 'PluginDir'];

[pp, ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  plugin_path = [osp_path filesep '..' filesep 'PluginDir'];
  ismcr=false;
else
  plugin_path = [osp_path filesep 'PluginDir'];
  ismcr=true;
end
OSP_LOG('msg',['Search path:' plugin_path]);

if isempty(WinP3_EXE_PATH)
  plugin_path2=plugin_path;
else
  plugin_path2=[WinP3_EXE_PATH filesep 'PluginDir'];
end
OSP_LOG('msg',['Search path2:' plugin_path2]);

tmpdir = pwd;
try
  cd(plugin_path);
  % Search Plugin
  files=find_file('^PlugInWrap_\w+.[mp]$', plugin_path,'-i');
  files2 = find_file('^PlugInWrapP1_\w+.[mp]$', plugin_path,'-i');
  files={files{:}, files2{:}};
  %============================================
  % Set Plugin-File ( Found by upper find_file)
  %============================================
  for idx=1:length(files),
    try
      % -- Get Function  - Name --
      [pth, nm] = fileparts(files{idx});
      % In the Directory ..
      cd(pth);
      % --- Wrapper ---
      % Get Function Pointer
      nm2 = eval(['@' nm]);

      % -----------------
      % Get Basic Infor!
      % -----------------
      bi = P3_PluginEvalScript(nm2,'createBasicInfo');
      % Check data
      if ~isfield(bi,'name') || ~isfield(bi,'region'),
        error([nm ...
          ': Return-val of createBasicInfo'...
          ': Too few field']);

      end

      % --- FilterList ---
      % Get Display Name
      x=find(strcmp(FilterList,bi.name));
      if ~isempty(x),
        rnmid=0;
        while 1,
          rnmid=rnmid+1;
          rname=sprintf('%s (%d)',bi.name,rnmid);
          x=find(strcmp(FilterList,rname));
          if isempty(x), break;end
        end
        logmsg{end+1} =sprintf('Rename : %s to %s', ...
          bi.name, rname);
        bi.name=rname;
      end

      % --- Display-Kind ---
      if isfield(bi,'DispKind'),
        dkind=bi.DispKind(1);
      else
        % Default : not defined
        dkind=0;
      end

      %---------------
      % Add to List
      % (If no error)
      %---------------
      FilterAllowed{end+1} = bi.region;
      FilterList{end+1}    = bi.name;
      wrapper{end+1}       = nm2;
      FilterDispKind(end+1)= dkind;
    catch
      warning(lasterr);
    end
  end % File1/2　Roop

  %----------------
  %  Plugin Script
  files = find_file('^PlugInWrapPS1_\w+.[mp]$', plugin_path2,'-i');
  nfd   =length(FilterList);
  ngidx      =[];
  for idx=1:length(files),
    try
      % -- Get Function  - Name --
      [pth, nm] = fileparts(files{idx});
      % In the Directory ..
      cd(pth);

      % -----------------
      % Get Basic Infor!
      % -----------------
      bi = P3_PluginEvalScript(nm,'createBasicInfo');
      % Check data
      if ~isfield(bi,'name') || ~isfield(bi,'region'),
        error([nm ...
          ': Return-val of createBasicInfo'...
          ': Too few field']);

      end

      % --- FilterList ---
      % Get Display Name
      if ismcr
        % MCR版： 不要データ削除
        x=find(strcmp(FilterList(1:nfd),bi.name));
        if ~isempty(x),
          ngidx=union(ngidx, x); % 重なっているため削除する
        end
        if any(strcmp(FilterList(nfd+1:end),bi.name));
          continue; % 同じものあり
        end
      else
        % 通常版：表示名を変える
        x=find(strcmp(FilterList,bi.name));
        if ~isempty(x),
          rnmid=0;
          while 1,
            rnmid=rnmid+1;
            rname=sprintf('%s (%d)',bi.name,rnmid);
            x=find(strcmp(FilterList,rname));
            if isempty(x), break;end
          end
          logmsg{end+1} =sprintf('Rename : %s to %s', ...
            bi.name, rname);
          bi.name=rname;
        end
      end
      
      % --- Display-Kind ---
      if isfield(bi,'DispKind'),
        dkind=bi.DispKind(1);
      else
        % Default : not defined
        dkind=0;
      end

      %---------------
      % Add to List
      % (If no error)
      %---------------
      FilterAllowed{end+1} = bi.region;
      FilterList{end+1}    = bi.name;
      wrapper{end+1}       = nm;
      FilterDispKind(end+1)= dkind;
    catch
      warning(lasterr);
    end
  end % File3　Roop
  
  % Delete NG Filter
  FilterAllowed(ngidx) = [];
  FilterList(ngidx)    = [];
  wrapper(ngidx)       = [];
  FilterDispKind(ngidx)= [];
  
catch
  cd(tmpdir);
  rethrow(lasterror);
end

cd(tmpdir);
try
  % mail : 2010.12.22 --> Displayh in advtgl_status
  if ~isempty(logmsg)
    OSP_DATA('SET','OSP_FILTER_WARNING',logmsg);
  else
    OSP_DATA('SET','OSP_FILTER_WARNING','');
  end
catch
  if ~isempty(logmsg),warndlg(logmsg);end
end

%---> Check WHITE LIST <---  by TK@CRL 2012/01/06
W_List={'Blocking','MovingAverage','Polyfit-Difference','Baseline Correction','Motion Check','Band Filter',...
	'1stLv: save .Results','NFRI: 1stLv Contrast','Amplitude Thresholding','Baseline fitting','EvalString',...
	'Motion Check [ Wavelet ]','Motion Check [ Wavelet ]*GUI',...
	'Block Channel Selector','Mark Edit','Set zero level','Simple T-Test',...
	'Smoothing (kernel:gauss)','Store Mean value to .Results','Flag to Kind',...
	'1stLv: Save TDD-ICA results','1stLv: Simple t-test','t test',...
	'Save Data to XLS file', 'Save Value to Text File', 'Normalize',...
	};

for k=1:length(FilterList)
	if ~any(strcmp(FilterList{k},W_List))
		FilterList{k}=[getDefString_forBeta FilterList{k}];
	end
end

%---> Fuction Pointer to string <----
% To Save
for idx=length(wrapper):-1:1,
  if ~ischar(wrapper{idx})
    wrapper{idx}=func2str(wrapper{idx});
  end
end

% *************************************************
% Add Book-Mark
% *************************************************
if exist('FilterBookMarkData.mat','file'),
  load('FilterBookMarkData.mat','BookMarkString','BookMarkFilterName');
  flag=false;
  for idx=1:length(BookMarkFilterName),
    idx2=find(strcmpi(wrapper,BookMarkFilterName{idx}));
    if ~isempty(idx2),
      FilterDispKind(idx2)=FilterDispKind(idx2)+F_BOOKMARK;
      flag=true;
    end
  end
  if ~flag,FilterBookMarkData='';end
end

% *************************************************
% Delete File
% *************************************************
% Swich Type (User Makinge)
try
  type=OSP_DATA('GET','FILTER_RECIPE_GROUP_TYPE');
catch
  type='All';
end
if isempty(type),type='All';end


if ~strcmpi('ALL',type)
  try
    % Load -->
    fname=getDeleteListFilename(type);
    if ~exist(fname,'file')
      error('Unknown Filter Recipe Group Type');
    end
    dlist=load(fname);
  
    % Loop for delete file
    for idx=1:length(dlist.wrapper)
      % Is there same wrapper?
      a=find(strcmpi(wrapper,dlist.wrapper{idx}));
      if ~isempty(a)
        name0=dlist.FilterList{idx};
        % Remove foot ( foce to remove)
        if length(name0)>=4, name0(end-3:end)=[];end
        % Is Same Name?
        a2=strmatch(name0,FilterList(a));
        if ~isempty(a2)
          % Delete Filter
          didx=a(a2);
          FilterList(didx)=[];
          wrapper(didx)=[];
          FilterAllowed(didx)=[];
          FilterDispKind(didx)=[];
        end
      end
    end
  catch
    warndlg(...
      {[' Deleat Filter List : ' type],...
      '  --> Error Occur ',...
      ['     ' lasterr]},'Could not Delete.','replace');
  end
end

% *************************************************
% Sort! : Add 
% *************************************************
try
  [FilterList, idx]=sort(FilterList);
  wrapper=wrapper(idx);
  FilterAllowed=FilterAllowed(idx);
  FilterDispKind=FilterDispKind(idx);
catch
  warning('Plugin Sort Error');
end

% *************************************************
% Delete Same Name Wrapper!
% *************************************************
[x,i]=unique(wrapper);
i=setdiff(1:length(wrapper),i);
if ~isempty(i)
  msg={'Duplicate Function List : (Overwrite)'};
  realerror=[];
  for idx=i(:)'
    x=which(wrapper{idx},'-ALL');
    if length(x)==1,continue;end
    msg{end+1}=' ==================';
    for idx2=1:length(x)
      msg{end+1}=[' - ' x{idx2}];
    end
    
    dd=find(strcmpi(wrapper,wrapper{idx}));
    if length(dd)~=length(x) || ...
        isempty(strmatch('plugin',lower(wrapper{idx})))
      msg{end}='xxx Upset Path xxx';
      for idx2=dd(:)'
        msg{end+1}=[' ? ' FilterList{idx2}];
      end
    else
      bi=P3_PluginEvalScript(wrapper{idx},'createBasicInfo');
      for idx2=dd(:)'
        if strcmpi(bi.name,FilterList{idx2})
          msg{end+1}=[' o ' FilterList{idx2}];
        else
          msg{end+1}=[' x ' FilterList{idx2}];
          realerror(end+1)=idx2;
        end
      end
    end
    msg{end+1}=' ==================';
  end
  if ~isempty(realerror)
    FilterList(realerror)=[];
    wrapper(realerror)=[];
    FilterAllowed(realerror)=[];
    FilterDispKind(realerror)=[];
    errordlg(msg,'Filter-Recipe Error','replace');
  end
end

% *************************************************
%       End of Setting
%           Regions setting is in getInfo
% *************************************************
if nargout>=1,
  varargout{1} = FilterList;
end
if nargout>=2,
  varargout{2} = wrapper;
end
if nargout>=3,
  varargout{3} =  FilterAllowed;
end
if nargout>=4,
  varargout{4} =  FilterDispKind;
end
if nargout>=5,
  varargout{5} =  BookMarkString;
end

return;

function SaveBookMarkString(BookMarkString,list)
% Save BookMark
[FilterList, wrapper] = list_io;

for idx=length(list):-1:1,
  if ischar(wrapper{list(idx)});
    BookMarkFilterName{idx}=wrapper{list(idx)};
  else
    BookMarkFilterName{idx}=func2str(wrapper{list(idx)});
  end
end
if isempty(list),BookMarkFilterName={};end
try
  op = OSP_DATA('GET','OSPPATH');
  fname=[op filesep 'ospData' filesep 'FilterBookMarkData.mat'];
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(fname,'BookMarkString','BookMarkFilterName','-v6');
  else
    save(fname,'BookMarkString','BookMarkFilterName');
  end
catch
  errordlg(lasterr);
  return;
end

%---
function s=getDefString_forBeta
 s='|?| ';
 
%== subroutine
function s=subVersionVariableCheck(s)
%- 2013-01-24
%- TK@CRL

if isempty(s), return;end

strCn={'ver','version'};
%- adding version info
bi=P3_PluginEvalScript(s.wrap,'createBasicInfo');
f=fieldnames(bi);
tg=find(ismember(lower(f),strCn));
if isempty(tg)
	s.argData.ver = '?';
else
	s.argData.ver = bi.(f{tg});
end

%- sorting field order. 'ver' to the first.
f=fieldnames(s.argData);
tg=find(ismember(lower(f),strCn));
tg=tg(1);
f={f{tg},f{1:length(f)~=tg}}';
s.argData=orderfields(s.argData,f);
