function varargout = P3_MultiProcessingFunction(mode, varargin)
% Definition of Multi-Processing Function at P3.
% This function Manage Multi-Processing Plugin-Function.
% What I mean, there is 3 function as following.
%    * List-up  : Mult-Processing-Plugin.
%    * Edit     : Edit Mult-Processing-Function-List.
%                 Add/Change Mult-Processing-Plugin.
%    * Inform   : Tell status of Mult-Processing-Function-List.
%
% In current P3 revision, is 3.02  /  3.1.0, 
% we do not have specific Idia of feature Analysis metod.
% So This function is so soft cording.
%
% To Help : P3_MultiProcessingFunction
% To Use  : P3_MultiProcessingFunction(subfunction,options)
%
%-------------------------------------------------------
% Data Design
%-------------------------------------------------------
% There is 3 Types of data.
%   MPPL : Mult-Processing-Plugin List.
%   MPP  : Mult-Processing-Plugin.
%   MPF  : Mult-Processing-Functions for Execution.
%          (MPF consisted of many MPP)
%-------------------------------------------------------
% subfunction list
%-------------------------------------------------------
% ....


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
% $Id: P3_MultiProcessingFunction.m 304 2013-01-25 09:44:55Z Katura $

% Help
if nargin<=0, mode='help';end
if strcmpi(mode,'help')
  OspHelp(mfilename);
  return;
end

% ***********
%  Get MPFL
% ***********
% -- Region Definition --
% ( in P3.1.0, only one region )
Regions={'default'};
mpfl=list_io(Regions);

switch mode
  case 'Regions'
    varargout{1}=Regions;
  case 'ListReset',
    % Reset (search ) -> return MPFL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    varargout{1}=list_io(Regions,'reset');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'FuncHelp',
    % OspFilterDataFcn('FuncHelp',FilterName);
    %    get Allow-Region of FilterName
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    id = find(strcmp({mpfl.name},varargin{1}));
    if isempty(id)
      error(['No such a Filter : ' char(varargin{1})]);
    end
    fn=func2str(mpfl(id).wrapper);
    %OspHelp(fn);
    sfh=gcbf;uihelp(fn);figure(sfh);
    %set(0,'currentFigure',sfh)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'getInfo',
    % [info, linfo] = OspFilterDataFcn('getInfo',MPF);
    % Get Information (--> MPF Listbox )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [varargout{1}, varargout{2}] = getInfo(varargin{1},...
      Regions,mpfl);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'makeData'
    % [FilterDataManager, index] =
    %  OspFilterDataFcn('makeData',fdm, filtername,fpos);
    %   Add 'Filter-Data' to "Filter-Data-Manager"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fdm          = varargin{1}; % Filter Data Manager
    name         = varargin{2}; % Filter Data-Name
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
    id = find(strcmp({mpfl(:).name},name));
    if ~isempty(id)
      % Multi Plugin
      filData      = mpfl(id);
      filData.wrap = mpfl(id).wrapper;
    else
      % Normal Filter-Plugin
      [ffl, wrapper] = OspFilterDataFcn('list_io');
      id=find(strcmp(ffl,name));
      if isempty(id)
        error(['No such a Filter : ' name]);
      end
      filData.name = name;
      filData.wrap = wrapper{id};
    end

    %---------------------------------
    % Get Argument From FilterDef / PluginWrap function.
    %---------------------------------
    filData = feval(filData.wrap,'getArgument',filData, b_mfile); % Get Data
    if isempty(filData)
      % User : Cancel :
      varargout{1} = fdm;
      varargout{2} = [];
      return;
    end
    % Add Enable Setting
    filData.enable='on';

    %---------------------------------
    % Get Insert Region
    % TODO : ----->> Make Design
    %---------------------------------
    rgn_id  = 1; % <-- Not in need
    % Set to Filter Manage Data ( fmd )
    flt_ps = Inf;       % Set Filter - Position

    %---------------------------------
    % Filter Data Manager Update!
    %---------------------------------
    if isempty(fdm),
      % New : Filter Data Manager
      %--> since 1.12 : Struct to Cell
      fdm = struct(Regions{rgn_id},{{filData}});
    elseif isfield(fdm,Regions{rgn_id}),
      % Add to Existing Region :
      %--> since 1.12 : Struct to Cell
      tmp = eval(['fdm.' Regions{rgn_id} ';']);
      if isempty(tmp),
        flt_ps = 1;   % Set Filter - Position
        tmp= {filData};
      else
        if isstruct(tmp),
          % Change Struct to Cell;
          tmp0={};
          for tidx=1:length(tmp),tmp0{tidx}=tmp(tidx); end
          tmp = tmp0;
        end
        if flt_ps==1
          tmp={filData, tmp{:}};
        elseif flt_ps>=length(tmp)
          tmp{end+1} = filData;
          flt_ps=length(tmp);
        else
          tmp={tmp{1:flt_ps-1}, filData, tmp{flt_ps:end}};
        end
      end
      if 0,disp(tmp);end
      eval(['fdm.' Regions{rgn_id} '=tmp;']);
      
    else
      % Add New Region :
      %--> since 1.12 : Struct to Cell
      eval(['fdm.' Regions{rgn_id} '= {filData};']);
    end
    
    varargout{1} = fdm;
    if nargout>=2 
      varargout{2} = [rgn_id, flt_ps, 0];
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
    filData = feval(filData.wrap,'getArgument',filData, b_mfile);
    if isfield(filData, 'enable')
      filData.enable='on';
    end
    varargout{1} = filData;

  case 'getList'
    % FilterList = OspFilterDataFcn('getList');
    varargout{1} = mpfl;

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


function [info, linfo] = getInfo(fdm,Regions, mpfl)
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
rgstr={'---- Make Multi-Data ----'};

line=1; info={}; linfo=[];

% Region Loop
for rg = 1:length(Regions)

  % Get FilterData
  if isfield(fdm,Regions{rg}),
    fdata = getfield(fdm,Regions{rg});
  else
    % No Region.
    fdata = {};
  end

  % Print Region Header
  info{end+1}=rgstr{rg};
  linfo(line,:)=[rg 0 0];
  line=line+1;

  % Filter Data Loop
  for fd = 1:length(fdata)
    % - - - - - - - - - - - -
    % Print Filter Name
    % - - - - - - - - - - - -
    %   filterData.enable  :  Enable flag
    fdata0 = fdata{fd};
    if strcmp(fdata0.enable,'on')
      info{end+1}=[' o ' fdata0.name];
    else
      info{end+1}=[' x ' fdata0.name];
    end
    linfo(line,:)=[rg fd 0];
    line=line+1;

    % - - - - - - - - - - - -
    % Print Argument
    % - - - - - - - - - - - -
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
        argvar = argstrct.(argname{agid});
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
            tmp = [num2str(tmpsz(1)) 'x'];
          end
          tmp(end) = '}';
          argvar = tmp;
        end
        argchr =[argchr argname{agid} ':' ...
          argvar ', '];
      end % Argument Data Loop
      info{end+1}=argchr;
      linfo(line,:)=[rg fd 1];
      line=line+1;
    end
  end % Filter Data Loop
end % Region Loop

return;



function MPPL = list_io(Regions, varargin)
% *************************************************
%       Renew for Plug-in function
% *************************************************
% 19-Apr-2007.
% M.Shoji

persistent list_singleton_;
persistent MPPL0;
DefineOspFilterDispKind;

%==> Singleton <==
if ~isempty(list_singleton_) && isempty(varargin),
  % Return : When List exist.
  MPPL=MPPL0;
  return;
end
list_singleton_=true;

%mlock;  % Locking Data

% *************************************************
% Search Multi-Processing Plugin Function
% *************************************************
% + Search Plugin &Set
logmsg ={}; % Log
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
% Meeting on 2007.04.27 --> See also Plugin-Function-Name
%plugin_path = [osp_path filesep 'MultiProcessingPlugin'];
%plugin_path = [osp_path filesep '..' filesep 'PluginDir'];

[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  plugin_path = [osp_path filesep '..' filesep 'PluginDir'];
else
  plugin_path = [osp_path filesep 'PluginDir'];
end

% Search Plugin
files=find_file('^PluginWrapPM_\w+.[mp]$', plugin_path,'-i');

%============================================
% Set Plugin-File ( Found by upper find_file)
%============================================
MPPL.name   ='Sample (dumy)';
MPPL.type   =0;
MPPL.region =0;
MPPL.version=0;
MPPL.wrapper=@PluginWrapPM_Sample;

for idx=1:length(files),
  % -- Get Function  - Name --
  [pth, nm] = fileparts(files{idx});
  % In the Directory ..
  if 0,cd(pth);end
  try
    % -- defalt --
    MPP.name   ='Sample';
    MPP.type   =F_MultAna;
    MPP.region =0;
    MPP.version=0;
    MPP.wrapper=@MPP_PlugIn_Sample;

    % --- Wrapper ---
    % Get Function Pointer
    MPP.wrapper=eval(['@' nm]);
    
    % -----------------
    % Get Basic Info!
    % -----------------
    bi = feval(MPP.wrapper,'createBasicInfo');
    % Check data
    if ~isfield(bi,'name') || ~isfield(bi,'version')
      error([nm ...
        ': Return-val of createBasicInfo'...
        ': Too few field']);
    end
    MPP.name=bi.name;
    if isfield(bi,'type'), MPP.type = bitor(bi.type,F_MultAna); end
    if isfield(bi,'region'), MPP.region = bi.region; end
    MPP.version=bi.version;
    
    % --- FilterList ---
    % Get Display Name
    x=find(strcmp({MPPL.name},bi.name));
    if ~isempty(x),
      NameList={MPPL.name};
      rnmid=0;
      while 1,
        rnmid=rnmid+1;
        rname=sprintf('%s (%d)',bi.name,rnmid);
        x=find(strcmp(NameList,rname));
        if isempty(x), break;end
      end
      logmsg{end+1} =sprintf('Rename : %s to %s', ...
        bi.name, rname);
      MPP.name=rname;
    end
    MPPL(idx)=MPP;
  catch
    warndlg(lasterr);
  end
end

if ~isempty(logmsg),
  warndlg(logmsg,'In making a list of Multi Plug-in','replace');
end

% *************************************************
% Sort! by name
% *************************************************
try
  MPPL=struct_sort(MPPL,'name');
catch
  disp('Plugin Sort Error');
end
MPPL0=MPPL;
if 0, disp(Regions);end

return;



