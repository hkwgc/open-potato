function varargout=POTATo_win_Normal_Group(fnc,varargin)
% POTATo Analysis-Status : Normal-Group Analysis
%  Analysis-GUI-sets, 
%  when Normal (P3-Mode), multi-data.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
%  2010.11.02 : New! (2010_2_RA01-3)
%  2010.11.02 : Add GUI

%======== Launch Switch ========
switch fnc,
  case 'Suspend',
    Suspend(varargin{:});
    
  case 'Activate',
    Activate(varargin{:});    
    
  case {'DisConnectAdvanceMode','SaveData','Export2WorkSpace','ConnectAdvanceMode'},
    % (mean Do nothing)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
    
  case {'pop_NGroup_recipe_Callback',...
      'psb_NGroup_help_Callback',...
      'psb_NGroup_InstallRecipe_Callback',...
      'psb_NGroup_Execute_Callback'}
    % GUI
    if nargout,
      [varargout{1:nargout}] = feval(fnc, varargin{:});
    else
      feval(fnc, varargin{:});
    end
    
  otherwise
    try
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
      else
        feval(fnc, varargin{:});
      end
    catch
      % --> Undefined Function : Use Default Function
      if nargout,
        [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
      else
        POTATo_win(fnc,varargin{:});
      end
    end
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make GUI & Handle Control
function h=myhs(hs)
% For Debug Print
% hs
h=[hs.txt_NGroup_recipe,hs.pop_NGroup_recipe,...
  hs.txt_NGroup_description, hs.lbx_NGroup_description,...
  hs.psb_NGroup_help,...
  hs.psb_NGroup_InstallRecipe,...
  hs.psb_NGroup_Execute];
  
%h=hs.([mfilename '_TODO']);

%**************************************************************************
function hs=create_win(hs)
% Make GUI's for Normal-Group Status

% TODO Debug Message
hs.([mfilename '_TODO'])=uicontrol(hs.figure1,...
  'Units','pixels','Position',[150 480 250 20],...
  'Style','text','Visible','off',...
  'String',['TODO: ' mfilename]);

%-----------------------
% Setting 
%-----------------------
c=get(hs.figure1,'Color');
prop_t={'Units','pixels','style','text',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c};
prop={'Units','pixels'};
sx1=414; % start x (with indent 1)
sx2=431; % start x (with indent 2)
%-----------------------
% Make GUI
%-----------------------
% Recipe 
tag='txt_NGroup_recipe';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Group-Recipe: ',...
  'Position',[sx1 442 321 21]);
tag='pop_NGroup_recipe';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String','Group-Recipe',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx2 421 320 20]);

% Description
tag='txt_NGroup_description';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Description: ',...
  'Position',[sx1 391 321 21]);

tag='lbx_NGroup_description';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String',{'Group-Recipe:','',...
  ' filter',' blocking',' 1st: xxx',' Display Correlation'},...
  'Position',[sx2 115 320 276]);
% Install Recipe

% Help
tag='psb_NGroup_help';
hs.(tag)=uicontrol(hs.figure1,'TAG',tag,...
  'Units','pixels',...
  'style','pushbutton',...
  'String','Help',...
  'Enable','off',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[637 391 114 21]);

% Install
tag='psb_NGroup_InstallRecipe';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','Install Recipe',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[637 81 114 21]);

p=get(hs.psb_drawdata,'Position');
tag='psb_NGroup_Execute';
hs.(tag)=uicontrol(hs.figure1,'TAG',tag,...
  'Units','pixels',...
  'style','pushbutton',...
  'String','Execution',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',p);
guidata(hs.figure1,hs); % save

recipe_Create(hs);

%**************************************************************************
function Suspend(hs)
% Suspend Window : Visible off
h=myhs(hs);
set(h,'Visible','off');

%**************************************************************************
function Activate(hs)
% Activate Single-Analysis Mode!
if ~isfield(hs,[mfilename '_TODO']) || ~ishandle(hs.([mfilename '_TODO']))
  hs=create_win(hs);
elseif 0
  % for debug
  try %#ok
    delete(myhs(hs));
  end
  hs=create_win(hs);
  disp('debug');
  disp(C__FILE__LINE__CHAR);
end
h=myhs(hs);
set(h,'Visible','on');

h0=POTATo('getViewerGUI_IO',hs.figure1,[],hs);
set(h0,'Visible','off');

% Update 
pop_NGroup_recipe_Callback(hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recipe Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function recipe_Create(hs)
% 
h=hs.pop_NGroup_recipe;

p0=OSP_DATA('GET','OspPath');
if isempty(p0)
  p0=fileparts(which('POTATo'));
end

[pp ff] = fileparts(p0); %#ok
if( strcmpi(ff,'WinP3')~=0 )
  recipepath = [p0 filesep '..' filesep];
else
  recipepath = [p0 filesep];
end
recipepath=[recipepath 'SimpleModeDir' filesep 'Recipe'];

try
  recipes=find_file('^GroupRecipe.mat$',recipepath,'-i');
  strs={};
  udata={};
  for idx=1:length(recipes)
    p0   = fileparts(recipes{idx}); % Path
    rcp  = load(recipes{idx});
    % check
    if  ~isfield(rcp,'Filter_Manager') || ...
        ~isfield(rcp,'SummaryFunction') || ...
        ~isfield(rcp,'StatFunction')
      fprintf(2,'[W] Bad Format File for GroupRecipe : %s',recipes{idx});
      continue;
    end
    if  ~exist([p0 filesep 'Summary_Arg.mat'],'file')  || ...
        ~exist([p0 filesep 'Stat_Arg.mat'],'file')
      fprintf(2,'[W] No Arguments-File %s',recipes{idx});
      continue;
    end

    if ~isfield(rcp,'Name') || strcmp(rcp.Name,'P3-Recipe')
      [p00 rcp.Name]=fileparts(p0); %#ok
    end
    strs{end+1}  = rcp.Name;
    udata{end+1} = p0;
  end
  if isempty(strs)
    strs='No Group Recipe';
    set(hs.psb_NGroup_Execute,'Enable','off');
    set(hs.lbx_NGroup_description,'Value',1,'String','No Recipe');
  else
    set(hs.psb_NGroup_Execute,'Enable','on');
  end
  set(h,'Value',1,'String',strs);
  set(h,'UserData',udata);
catch
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end

function recipe_Rehash(hs)
% Rehash Recipe
h=hs.pop_NGroup_recipe;
% backup current recipe-name
name=get(h,'String');
if iscell(name)
  name=name{get(h,'Value')};
end
recipe_Create(hs)

name2=get(h,'String');
v=find(strcmp(name,name2));
if ~isempty(v)
  set(h,'Value',v(1));
end
pop_NGroup_recipe_Callback(hs);

function [rcp, SSarg, STarg]=getRecipe(hs)
% get recipe
h=hs.pop_NGroup_recipe;
v=get(h,'Value');
udata=get(h,'UserData');
if length(udata)<v
  rcp=[];
  return;
end
rcp=load([udata{v} filesep 'GroupRecipe.mat']);
if nargout>=2
  LoadData=load([udata{v} filesep 'Summary_Arg.mat']);
  SSarg=LoadData.ExeData;
end
if nargout>=3
  LoadData=load([udata{v} filesep 'Stat_Arg.mat']);
  STarg=LoadData.ArgData;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI'S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_NGroup_recipe_Callback(hs)
%=====================
% Get Recipe Path : udata{v}
%=====================
h=hs.pop_NGroup_recipe;
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
  rcp=getRecipe(hs);
  try
    info = OspFilterDataFcn('getInfo',rcp.Filter_Manager);
    strs={strs{:} ,...
      '---Recipe---',...
      info{:},...
      '[ Summary Statistics Computation ]', ...
      ['    ' rcp.SummaryFunction],...
      '[ Statistical Test ]', ...
      ['    ' rcp.StatFunction]};
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
set(hs.lbx_NGroup_description,'Value',1,'String',strs);

%=====================
% Setup Help-Button
%=====================
h_enable='off';
h_udata='';
if exist([udata{v} filesep 'Description.pdf'],'file')
  h_enable='on';
  h_udata=[udata{v} filesep 'Description.pdf'];
elseif exist([udata{v} filesep 'Description.html'],'file')
  h_enable='on';
  h_udata=[udata{v} filesep 'Description.html'];
end
set(hs.psb_NGroup_help,...
  'Enable',h_enable,'UserData',h_udata);

function psb_NGroup_help_Callback(hs)
% Disp function Help
f=get(hs.psb_NGroup_help,'UserData');
if ~isempty(f)
  POTATo_Help(f);
end

function psb_NGroup_InstallRecipe_Callback(hs)
% Install Recipe 
[f p]=uigetfile({'*.zip','Zipped Recipe'},'Zipped Recipe');
% Cancell ?
if isequal(f,0) || isequal(p,0)
  return;
end
% Inatall
try
  osp_path=OSP_DATA('GET','OspPath');
  if isempty(osp_path)
    osp_path=fileparts(which('POTATo'));
  end
  [pp ff] = fileparts(osp_path); %#ok
  if( strcmp(ff,'WinP3')~=0 )
    recipepath = [osp_path filesep '..' filesep];
  else
    recipepath = [osp_path filesep];
  end
  recipepath=[recipepath 'SimpleModeDir' filesep 'Recipe'];
  unzip(fullfile(p,f),recipepath);
catch
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end

% Update recipe
recipe_Rehash(hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function datar=makeSS(hs,exefnc,fmd,ArgData)
% Make Summary Statistic Data
%  (Summary Statistic Conputation)

%--------------------------
% Get Ana-Files
%-------------------------
% get DataDef (II) Function
fcn=get(hs.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
end
fcn=fcn{get(hs.pop_filetype,'Value')};

% Get Data Files
filedata=get(hs.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
end
%vls=get(hs.lbx_disp_fileList,'UserData');
vls=get(hs.lbx_fileList,'Value');

%--------------------------
% Make Real Part
%-------------------------
datar.nfile    = length(vls);
datar.AnaFiles = cell([1,datar.nfile]);
if datar.nfile>=5
  wh=waitbar(0,'Loading Analysis Data','WindowStyle','Modal');
  try
    set(wh,'Name','Loading Data');
    set(wh,'CloseRequestFcn','');
  catch
  end
  try
    wi=1/datar.nfile;
    for ii=1:datar.nfile
      datar.AnaFiles{ii}=feval(fcn,'load',filedata(vls(ii)));
      datar.AnaFiles{ii}.data.filterdata=fmd;
      waitbar(wi*ii,wh);
    end
  catch
    delete(wh);
    rethrow(lasterror);
  end
  delete(wh);
else
  % Load Ana-Files
  for ii=1:datar.nfile
    datar.AnaFiles{ii}=feval(fcn,'load',filedata(vls(ii)));
    datar.AnaFiles{ii}.data.filterdata=fmd;
  end
end

% Add ArgData
datar.ExeData=ArgData;

%-------------------------------
% Get Summarized Data
%-------------------------------
datar=feval(exefnc,'execute',datar);


function psb_NGroup_Execute_Callback(hs)
% Execute...
[rcp,SSarg,STarg]=getRecipe(hs); % get Recipe
if isempty(rcp)
  errordlg('No Recipe to Execute');return;
end

% Make SS Data (Real)
try
  SS=makeSS(hs,rcp.SummaryFunction,rcp.Filter_Manager,SSarg);
catch
  errordlg(lasterr);
  return;
end

% Perform Statistical Test
r=feval(rcp.StatFunction,'execute',{SS},STarg);
if (r.error)
  errordlg(r.error,'T-Test Error');
  return;
end

