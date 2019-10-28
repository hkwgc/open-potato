function varargout=P3_gui_SimpleMode(fcn, varargin)
% P3: Multi-Analysis Recipe's Edit GUI.
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% author : Masanori Shoji
% create : 2010.03.12
%
% $Id: P3_gui_SimpleMode.m 398 2014-03-31 04:36:46Z katura7pro $
%
% 2010.10.20:
%   Bugfix : B101020B 
%     No-Description Data Display-Function

if nargin<=0,OspHelp(mfilename);return;end

switch fcn
  case {'pop_SIMPLEM_recipe_CreateFcn',...
      'pop_SIMPLEM_recipe_Callback',...
      'psb_SIMPLEM_help_Callback',...
      'pop_SIMPLE_recipe_rehash',...
      'psb_SIMPLEM_InstallRecipe_Callback',...
      'getRecipe',...
      'getLAYOUTs'}
    % OK Function
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case 'OpenProject'
    if nargout,
      [varargout{1:nargout}] = OpenProject(varargin{:});
    else
      OpenProject(varargin{:});
    end
  case 'hiPOTXPrjUpdate'
    hiPOTXPrjUpdate(varargin{:});
  otherwise,
    error('Unpopulated Function : %s',fcn);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=OpenProject(exeflg,handles)
% 
msg='';
% getpath
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end

%---------------------
% Open Project Parent
%---------------------
prjppath = [osp_path filesep 'Projects'];
if exeflg
  % Execute :
  POTATo('ChangeProjectParentIO',handles.figure1,prjppath,handles);
else
  % Set Data (not open project here)
  OSP_DATA('SET', 'PROJECTPARENT',prjppath);
end

%---------------------
% Open Project 
%---------------------
myProjectName ='bundle001'; % 
Project=POTAToProject('LoadData');
try
  pjidx=strmatch(myProjectName,{Project.Name},'exact');
catch
  pjidx=[];
end
  

%-------------------------
% Open Project (if there)
%-------------------------
if ~isempty(pjidx)
  % There is Project
  POTAToProject('Select',pjidx);
  if exeflg
    POTATo('ChangeProject_IO',handles.figure1,[],handles,prj);
    %ChangeProject(handles, prj);
  else
    OSP_DATA('SET','PROJECT',Project(pjidx));
  end
  return; % Open & Return;
end

%-------------------------
% Make New Project
%-------------------------
% (Our Project Setting)
pj.Ver  = 2.0;
pj.Name =myProjectName;
pj.Path =prjppath;
pj.CreateDate=now;
pj.Operator = 'POTATo User';
pj.Comment  = 'Bundle Edition';

pj=POTAToProject('Add',pj);
if isempty(pj),
  error('Could not Make Project');
end
if exeflg
  POTATo('ChangeProject_IO',handles.figure1,[],handles,pj);
else
  OSP_DATA('SET','PROJECT',pj);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hiPOTXPrjUpdate(hs)
% Automatically load newly-arrived files at hiPOTX-Directory.

%-----------------------
% Load 'Load File List'
%-----------------------
pj=OSP_DATA('GET','PROJECT');
if isempty(pj), return; end
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
prjpath = [osp_path filesep 'Projects' filesep pj.Name filesep];
lfname  =[prjpath 'LoadFileList.mat'];

try
  load(lfname);
catch
  LoadFileList={};
end

%-----------------------
% Find Target Files
%-----------------------
hipotxpath=OSP_DATA('GET','HIPOTX_DATA_PATH');
fs=find_file('.ktmset$',hipotxpath,'-i');

% Get List (Do not read)
loadlist=setdiff(fs,LoadFileList);
% Update  'Load File List'
LoadFileList = union(fs,LoadFileList); %#ok :: will be save

%--------------------------
% Setup for Import
%--------------------------
xx=which('tmp_plugin');
try
  if exist(xx,'file'), delete(xx);end
catch
end
%tmp=OSP_DATA('GET','SP_Rename');
OSP_DATA('SET','SP_Rename','OriginalName');

% Confile Delete 
num=length(loadlist);
if (num==0), return; end

%---------------------------
% Start : Reading...
%---------------------------
h = waitbar(0,'Read hiPOTX Dir...');
for idx=1:num
  preprocessor_otsigtrnschld2(loadlist{idx},'prepro_hiPOT_X');
  waitbar(idx/num,h);
end
close(h);
%OSP_DATA('SET','SP_Rename',tmp);

%---------------------------
% Save Load-File-List
%---------------------------
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(lfname, 'LoadFileList','-v6');
else
  save(lfname, 'LoadFileList');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_SIMPLEM_recipe_CreateFcn(h,e,hs)
% Create RECIPE :: in Booting...
% ** DO NOTING **
%  1. Search Recipe for SIMPLE-MODE
%  2. Select Recipe
global WinP3_EXE_PATH;

if isempty(WinP3_EXE_PATH)
	osp_path=OSP_DATA('GET','OspPath');
	if isempty(osp_path)
		osp_path=fileparts(which('POTATo'));
	end
	recipepath = [osp_path filesep];
else
  recipepath=[WinP3_EXE_PATH filesep];
end
recipepath=[recipepath 'SimpleModeDir' filesep 'Recipe'];

try
  recipes=find_file('^Recipe.mat$',recipepath,'-i');
  strs={};
  udata={};
  for idx=1:length(recipes)
    p0   = fileparts(recipes{idx}); % Path
    rcp  = load(recipes{idx});
    % check
    if ~isfield(rcp,'Filter_Manager')
      fprintf(2,'[W] Bad Format File for Recipe : %s',recipes{idx});
    end
    if ~isfield(rcp,'Name') || strcmp(rcp.Name,'P3-Recipe')
      [p00 rcp.Name]=fileparts(p0);
    end
    strs{end+1}  = rcp.Name;
    udata{end+1} = p0;
  end
  set(h,'String',strs);
  set(h,'UserData',udata);
catch
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_SIMPLEM_InstallRecipe_Callback(h,e,hs)
% Open Ziped Recipe-Dir File & Expand it
global WinP3_EXE_PATH;

[f p]=uigetfile({'*.zip','Zipped Recipe'},'Zipped Recipe-Dir');
% Cancell ?
if isequal(f,0) || isequal(p,0)
  return;
end
% Install
try
	if isempty(WinP3_EXE_PATH)
		osp_path=OSP_DATA('GET','OspPath');
		if isempty(osp_path)
			osp_path=fileparts(which('POTATo'));
		end
		recipepath = [osp_path filesep];
	else
		recipepath=[WinP3_EXE_PATH filesep];
	end
	recipepath=[recipepath 'SimpleModeDir' filesep 'Recipe'];
	
  unzip(fullfile(p,f),recipepath);
catch
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end
% Rehash
pop_SIMPLE_recipe_rehash(hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_SIMPLE_recipe_rehash(hs)
% (when data-reselect...)
% --> need speed

h=hs.pop_SIMPLEM_recipe;
name=get(h,'String');
name=name{get(h,'Value')};
pop_SIMPLEM_recipe_CreateFcn(hs.pop_SIMPLEM_recipe,[],hs);

name2=get(h,'String');
v=find(strcmp(name,name2));
if ~isempty(v)
  set(h,'Value',v(1));
end
pop_SIMPLEM_recipe_Callback(h,[],hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_SIMPLEM_recipe_Callback(h,e,hs) %#ok event (not in use)
% Run When Recipe Popup-Menu Change.
% - Change Description-string, 
%   &      Layout-set
clear e;
%=====================
% Get Recipe Path : udata{v}
%=====================
v=get(h,'Value');
udata=get(h,'UserData');
if length(udata)<v
  return;
end

%=====================
% Change Description
%=====================
% * get Description File
fp=fopen([udata{v} filesep 'Description.txt'],'r');
if (fp<=0)
  % If no Description File, Display ... ( B101020B ) 
  strs={'No Description File.'};
  load([udata{v} filesep 'Recipe.mat'],'Filter_Manager');
  try
    info = OspFilterDataFcn('getInfo',Filter_Manager);
    strs={strs{:} '' '---Recipe---' info{:}};
  catch
    strs={strs 'xx'};
  end
else
  strs={};
  try
    while 1
      t=fgetl(fp);
      if ~ischar(t),break;end
      strs{end+1}=t;
    end
  catch
    strs{end+1}='Error Occur :';
  end
  fclose(fp);
end
if isempty(strs), strs={'No Description'}; end
set(hs.lbx_SIMPLEM_discription,'Value',1,'String',strs);

%=====================
% Change Layout-List
%=====================
POTATo_win_SimpleMode('ChangeLayout',hs);

%=====================
% Setup Help-Button
%=====================
if ~isfield(hs,'psb_SIMPLEM_help')
  return; %
end
h_enable='off';
h_udata='';
if exist([udata{v} filesep 'Description.pdf'],'file')
  h_enable='on';
  h_udata=[udata{v} filesep 'Description.pdf'];
elseif exist([udata{v} filesep 'Description.html'],'file')
  h_enable='on';
  h_udata=[udata{v} filesep 'Description.html'];
end
set(hs.psb_SIMPLEM_help,...
  'Enable',h_enable,'UserData',h_udata);

function psb_SIMPLEM_help_Callback(hs)
% Disp function Help
f=get(hs.psb_SIMPLEM_help,'UserData');
if ~isempty(f)
  POTATo_Help(f);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcp=getRecipe(hs)
% get recipe
h=hs.pop_SIMPLEM_recipe;
v=get(h,'Value');
udata=get(h,'UserData');
if length(udata)<v
  rcp=[];
  return;
end
rcp=load([udata{v} filesep 'Recipe.mat']);

function lst=getLAYOUTs(hs)
% get recipe
h=hs.pop_SIMPLEM_recipe;
v=get(h,'Value');
udata=get(h,'UserData');
if length(udata)<v
  lst=[];
  return;
end
lst=find_file('^LAYOUT\w+.mat$', udata{v},'-i');


