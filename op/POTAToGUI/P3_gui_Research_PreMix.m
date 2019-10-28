function varargout=P3_gui_Research_PreMix(fcn, varargin)
% P3: Research-Mode, Pre-Mix Status GUI Control
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% otriginal author : Masanori Shoji
% create : 2010.11.05
%
% $Id: P3_gui_Research_PreMix.m 180 2011-05-19 09:34:28Z Katura $
%
% 2010.11.05 : New! (2010_2_RA02-2)
%    Reversion 1.1 :
%   OspFilterCallbacks

if nargin<=0,OspHelp(mfilename);return;end

switch fcn
  case {'create_win',...
      'UpdateRecipe',...
      'lbx_RPMix_RecipeGroup_Update',...
      'lbx_RPMix_RecipeGroup_Callback',...
      'psb_RPMix_RecipeGroup_Callback',...
      'psb_RPMix_RecipeGroup_Edit_Callback',...
      'pop_RPMix_AnaFile_Callback',...
      'psb_RPMix_EF_Change_Callback',...
      'psb_RPMix_EF_Enable_Callback',...
      'psb_RPMix_EF_Disable_Callback',...
      'psb_RPMix_EF_Remove_Callback',...
      'psb_RPMix_GrandAveragePlot_Callback',...
      }
    % OK Function
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case ''
    % Now not Execute
    return;
  otherwise,
    error('Unpopulated Function : %s',fcn);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hs=create_win(hs)
% Make GUI for Research Pre Multi-Data
% Upper Link : POTATo_win_Research_PreMix/Activate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------
% Setting 
%-----------------------
c=get(hs.figure1,'Color');
prop_t={'style','text','Units','pixels',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c};
prop={'Units','pixels'};

xsize0=360;  % Width of Area
sx0=410; % start x (with indent 0)
sx1=414; % start x (with indent 1)
sx2=431; % start x (with indent 2)
ix=10;    % Interval of x
iy= 3;    % Interval of y

%-----------------------
% Make GUI
%-----------------------
% Title
tag='txt_RPMix_title';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Different Recipes Control Mode',...
  'Position',[sx0 449 xsize0 19]);

% Recipe Group
y=440;
dy=20; y=y-dy-iy; xsize=150;
tag='lbx_RPMix_RecipeGroup';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'Recipe 1 (1/2)','Recipe 2 (1/2)'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx1 y xsize dy]);
tag='psb_RPMix_RecipeGroup_Edit';
sx3=sx1+xsize+ix;
xsize = (xsize0-(sx3-sx1)-2*ix)/2;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','Edit',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
tag='psb_RPMix_RecipeGroup';
sx3=sx3+xsize+ix;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','Apply to all',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
%  'Position',[sx1+xsize+ix y+dy-25 xsize 25]);


% Recipe's  Info
dy=170; y=y-dy-iy;xsize=xsize0*2/3;
tag='lbx_RPMix_AnaFileInfo';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String',{'Empty'},...
  'Position',[sx1 y xsize dy]);
sx3=sx1+xsize+ix;
xsize = xsize0/3-ix;
tag='pop_RPMix_AnaFile';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String',{'No-Data'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

% Enabel Filters
dy0=100; ny=y-dy0-iy;
tag='frm_RPMix_EditableFilters';
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','frame',...
  'Position',[sx1 ny xsize0 dy0]);
% Title
dy=20; y=y-dy-iy-7;
tag='txt_RPMix_EF_title';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Editable Filters: ',...
  'Position',[(sx1+sx2)/2 y 102 dy]);
% Pouup menu
dy=20; y=y-dy-iy; xsize=200;
tag='pop_RPMix_EF_function';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'Band Filter','Moving Average'},...
  'Position',[sx2 y xsize dy]);
% Change
dy=20; sx3=sx2+xsize+ix;
xsize = xsize0-(sx3-sx1)-ix;
tag='psb_RPMix_EF_Change';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton','String','Change',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
y=y-dy-iy;
tag='psb_RPMix_EF_Enable';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton','String','Enable',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize/2 dy]);
tag='psb_RPMix_EF_Disable';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton','String','Disable',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3+xsize/2 y xsize/2 dy]);
y=y-dy-iy;
tag='psb_RPMix_EF_Remove';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton','String','Remove',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

% Grand Avarage
tag='psb_RPMix_GrandAveragePlot';
p=get(hs.psb_drawdata,'Position');
p(3)=70;p(1)=p(1)-p(3)-5;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'FontUnit','pixels','FontSize',10,...
  'String','Plot Average',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',p);
%  'Position',[sx2 ny-25-iy xsize0-2*(sx2-sx1) 25]);

guidata(hs.figure1,hs); % save


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateRecipe(hs)
% Make GUI for Research Pre Multi-Data
% Upper Link : POTATo_win_Research_PreMix/Activate
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update Recipe-Group
lbx_RPMix_RecipeGroup_Update(hs); 
% Update pop_RPMix_FF_function
pop_RPMix_FF_function_init(hs); % (Innter)
% Update Analysis-File List Popupmenu
%pop_RPMix_AnaFile_init(hs); %(Inner)
%pop_RPMix_AnaFile_Callback(hs);
lbx_RPMix_RecipeGroup_Callback(hs);

s=get(hs.lbx_RPMix_RecipeGroup,'String');
if length(s)==1
  psb_RPMix_RecipeGroup_Edit_Callback(hs);
end

%==========================================================================
function lbx_RPMix_RecipeGroup_Update(hs)
% Update Recipe Group
%==========================================================================
RPreMixData=getappdata(hs.figure1, 'RPreMixData');

% Init Data
ll=length(RPreMixData.Recipe);
str  ={};    % Display String
udata={};    % User-Data
idx  =1;     % Recipe Index (for count up)
ntot =0;     % Total Number 
used =false([1,ll]); % is count up?
% Loop for Recipe
for ii=1:ll
  % Already Checked?
  if (used(ii)), continue;end

  % Same Recipe Count up...
  tmp=RPreMixData.Recipe{ii};
  mylist=ii;
  for jj=ii+1:ll
    if (used(jj)), continue;end
    % TODO: Nan is as Different ...(See also isequal)
    if isequal(tmp,RPreMixData.Recipe{jj})
      used(jj)=true;
      mylist(end+1)=jj;
    end
  end
  udata{end+1} = mylist;
  % Summarize
  n=length(mylist);
  str{end+1}=sprintf('Recipe %d, (% 3d/% 3d)',idx,n,ll);
  idx=idx+1;
  % Check end
  ntot=ntot+n;
  if (ntot >=ll), break;end
end
vl=get(hs.lbx_RPMix_RecipeGroup,'Value');
if (vl>length(str)),vl=length(str);end
set(hs.lbx_RPMix_RecipeGroup,'Value',vl,'String',str,'UserData',udata);

%==========================================================================
function lbx_RPMix_RecipeGroup_Callback(hs)
% Select Recipe
%==========================================================================

% Update GUI(1): pop_RPMix_AnaFile
%  2010_2_RC05-04
pop_RPMix_AnaFile_update(hs)

% Update GUI(2): lbx_RPMix_AnaFileInfo
%  2010_2_RC05-04
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
vl   =get(hs.lbx_RPMix_RecipeGroup,'Value');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');

info = OspFilterDataFcn('getInfo',RPreMixData.Recipe{udata{vl}(1)});
set(hs.lbx_RPMix_AnaFileInfo,'Value',1,'String',info);
%disp(['TUDO: ' C__FILE__LINE__CHAR]);


%==========================================================================
function pop_RPMix_FF_function_init(hs)
% Update pop_RPMix_FF_function
%==========================================================================
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');

% Get Grouped Recipe
ll=length(udata); myRecipe=cell([1,ll]);
for ii=1:ll
  myRecipe{ii}=RPreMixData.Recipe{udata{ii}(1)};
end

%----------------------------------
% Recipe Loop
%----------------------------------
xdata=[];
fs=fieldnames(myRecipe{1});
for fidx=1:length(fs)
  cflag=false;
  % Check Exist Field
  for ii=2:ll
    if ~isfield(myRecipe{ii},fs{fidx})
      cflag=true;
    end
  end
  if cflag, continue; end
  
  % My wrap List
  % Get My WRAPPER LIST
  wraps={};fdatas={};eqflag=[]; eqflag2=[];idxs={};
  for jj=1:length(myRecipe{1}.(fs{fidx}))
    try
      if iscell(myRecipe{1}.(fs{fidx})) && ...
          isfield(myRecipe{1}.(fs{fidx}){jj},'wrap')
        wraps{end+1}  = myRecipe{1}.(fs{fidx}){jj}.wrap;
        fdatas{end+1} = myRecipe{1}.(fs{fidx}){jj};
        eqflag(end+1) = true;
        eqflag2(end+1) = true;
        idxs{end+1}   = jj;
      end
    catch
    end
  end
  % IS SAME?
  for ii=2:ll
    wraps2={};
    fdatas2={};
    idxs2 =[];
    for jj=1:length(myRecipe{ii}.(fs{fidx}))
      try
        if iscell(myRecipe{ii}.(fs{fidx})) && ...
            isfield(myRecipe{ii}.(fs{fidx}){jj},'wrap')
          wraps2{end+1}  = myRecipe{ii}.(fs{fidx}){jj}.wrap;
          fdatas2{end+1} = myRecipe{ii}.(fs{fidx}){jj};
          idxs2(end+1)=jj;
        end
      catch
      end
    end
    [wraps, i0, i2]=intersect(wraps,wraps2);

    % Update Additional-Information
    fdatas=fdatas(i0);
    eqflag=eqflag(i0);
    eqflag2=eqflag2(i0);
    idxs=idxs(i0);
    for kk=1:length(i0)
      % Chack Same Parameter?
      if ~isequal(fdatas{kk},fdatas2{i2(kk)})
        eqflag(kk)=false;
      end
      % Check Same State
      try
        if ~isequal(fdatas{kk}.enable,fdatas2{i2(kk)}.enable)
          eqflag2(kk)=false;
        end
      catch
      end
      try
        if strcmpi(fs{fidx},'TimeBlocking') && ...
            ~isequal(myRecipe{1}.block_enable,myRecipe{ii}.block_enable)
          eqflag2(kk)=false;
        end
      catch
      end
      idxs{kk}(end+1)=idxs2(i2(kk));
    end
    if isempty(wraps), break;end
  end
  % Summarize
  for kk=1:length(wraps)
    if isempty(xdata)
      xdata=...
        struct('field',fs{fidx},'wrap',wraps{kk},...
        'fdata',fdatas{kk},...
        'eqflag',eqflag(kk),'eqflag2',eqflag2(kk),...
        'idxs',idxs{kk});
    else
      xdata(end+1)=...
        struct('field',fs{fidx},'wrap',wraps{kk},...
        'fdata',fdatas{kk},...
        'eqflag',eqflag(kk),'eqflag2',eqflag2(kk),...
        'idxs',idxs{kk});
    end
  end
end

% Make String
str={};
for kk=1:length(xdata)
  if xdata(kk).eqflag
    s1='Same';
  else
    s1='Different';
  end
  if xdata(kk).eqflag2
    s2='Same';
  else
    s2='Different';
  end
  str{end+1}=sprintf(' %s (State: %s, Parameter:%s)', xdata(kk).fdata.name,s2,s1);
end
% Set up GUI
if isempty(str)
  % if empyt..
  set([hs.frm_RPMix_EditableFilters,...
    hs.txt_RPMix_EF_title, hs.pop_RPMix_EF_function,...
    hs.psb_RPMix_EF_Change, ...
    hs.psb_RPMix_EF_Enable, hs.psb_RPMix_EF_Disable,...
    hs.psb_RPMix_EF_Remove],'Visible','off');
else
  vl=get(hs.pop_RPMix_EF_function,'Value');
  if (vl>length(str)), vl=length(str);end
  set(hs.pop_RPMix_EF_function,'String',str,'UserData',xdata,'Value',vl);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyisis File Selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_RPMix_AnaFile_update(hs)
% Analysis File Select
RPreMixData=getappdata(hs.figure1, 'RPreMixData');

vl   =get(hs.lbx_RPMix_RecipeGroup,'Value');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');

idkey  = feval(RPreMixData.fcn,'getIdentifierKey');
key={RPreMixData.data.(idkey)};
str={};
for ii=udata{vl}
  str{end+1}=sprintf('Data #%d : %s',ii,key{ii});
end
set(hs.pop_RPMix_AnaFile,'Value',1,'String',str);


function pop_RPMix_AnaFile_init(hs)  %#ok
% Analysis File Select
if 1
  return; % 2010_2_RC05-4
end
RPreMixData=getappdata(hs.figure1, 'RPreMixData');

udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');
recipeid=cumsum(cellfun('length',udata));
ids=cell2mat(udata);


idkey  = feval(RPreMixData.fcn,'getIdentifierKey');
key={RPreMixData.data.(idkey)};
str={};
for ii=1:length(key)
  myid=find(ids==ii);
  rid =find(recipeid>=myid);
  str{end+1}=sprintf('Data #%d : %s (Recipe %d)',ii,key{ii},rid(1));
end
set(hs.pop_RPMix_AnaFile,'Value',1,'String',str);

function pop_RPMix_AnaFile_Callback(hs) %#ok
% Update Recipe Information
return; % 2010_2_RC05-4


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recipe Local Change...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_RPMix_RecipeGroup_Callback(hs)
% Change Recipe ALL
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
vl=get(hs.lbx_RPMix_RecipeGroup,'Value');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');

% Confirm Dialog
a=questdlg({'All Recipes in files are replaced by selected recipe',...
  ['( Reciep ' num2str(vl) ')']}, 'Confirm Dialog','OK','Cancel','OK');
if ~strcmpi(a,'OK')
  return;
end


r=RPreMixData.Recipe(udata{vl}(1));
RPreMixData.Recipe(1:end)=r;
setappdata(hs.figure1, 'RPreMixData',RPreMixData);
setappdata(hs.figure1,'ActiveDataModSTATE',true);
UpdateRecipe(hs);

function psb_RPMix_EF_Change_Callback(hs)
% Pre Recipe : 
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');
% Get Filter Data
vl=get(hs.pop_RPMix_EF_function,'Value');
xdata=get(hs.pop_RPMix_EF_function,'UserData');
xdata=xdata(vl);
rg    = get(hs.pop_FilterList,'UserData'); % Regions

try
  tmp_data=RPreMixData.Recipe{udata{1}(1)}; % Select Recipe(1)
  x=false;
  % Remove Before Filter
  for id=1:length(rg)
    if isfield(tmp_data,rg{id})
      if x
        tmp_data=rmfield(tmp_data,rg{id});
        continue;
      end
      if strcmp(rg{id},xdata.field)
        x=true;
      end
    end
  end
  tmp_data.(xdata.field)(xdata.idxs(1):end)=[];
  if isempty(tmp_data.(xdata.field))
    tmp_data=rmfield(tmp_data,xdata.field);
  end
  
  m=get_now_mfile(hs,tmp_data);
  d=OspFilterDataFcn('fixData',RPreMixData.Recipe{1}.(xdata.field){xdata.idxs(1)},m);
  % 2010_2_RC05-1
  for ll=1:length(xdata.idxs)
    for mm=udata{ll}
      RPreMixData.Recipe{mm}.(xdata.field){xdata.idxs(ll)}=d;
    end
  end
  if strcmp(xdata.field,'TimeBlocking')
    for ll=1:length(RPreMixData.Recipe)
      RPreMixData.Recipe{ll}.BlockPeriod=d.argData.BlockPeriod;
    end
  end
catch
  errordlg({'Error to Change Filter', lasterr});
end
% Save Data & Update
setappdata(hs.figure1, 'RPreMixData',RPreMixData);
setappdata(hs.figure1,'ActiveDataModSTATE',true);
UpdateRecipe(hs);

function before_mfile = get_now_mfile(handles, filterdata)
% get Mfile for filterdata,
actdata = getappdata(handles.figure1, 'LocalActiveData');

%===============================
% == Make M-File ==
%===============================
try
  key.actdata = actdata;
  key.filterManage = filterdata;
  fname=feval(actdata.fcn,'make_mfile', key);
catch
  rethrow(lasterror);
end
before_mfile = fname;

return;

%==========================================================================
function psb_RPMix_EF_Enable_Callback(hs)
% Enable Function
%==========================================================================
psb_RPMix_EF_Disable_Callback(hs,true);
%==========================================================================
function psb_RPMix_EF_Disable_Callback(hs,type)
% Disable Function
%==========================================================================
if nargin<2
  type=false;
end
% Get Information
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
vl=get(hs.pop_RPMix_EF_function,'Value');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');
xdata=get(hs.pop_RPMix_EF_function,'UserData');
xdata=xdata(vl);
if strcmp(xdata.field,'TimeBlocking')
  for ll=1:length(xdata.idxs)
    % Bugfix : 2010.12.20
    for mm=udata{ll}
      RPreMixData.Recipe{mm}.block_enable=type;
    end
  end
else
  % Set On or Off
  if type
    a='on';
  else
    a='off'; 
  end
  % 2010_2_RC05-1
  for ll=1:length(xdata.idxs)
    try
      for mm=udata{ll}
        RPreMixData.Recipe{mm}.(xdata.field){xdata.idxs(ll)}.enable=a;
      end
    catch
      disp(C__FILE__LINE__CHAR);
    end
  end
end
% Save Data & Update
setappdata(hs.figure1, 'RPreMixData',RPreMixData);
setappdata(hs.figure1,'ActiveDataModSTATE',true);
UpdateRecipe(hs);

%==========================================================================
function psb_RPMix_EF_Remove_Callback(hs)
% Remove Function
%==========================================================================

% Get Information
RPreMixData=getappdata(hs.figure1, 'RPreMixData');
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');
vl=get(hs.pop_RPMix_EF_function,'Value');
xdata=get(hs.pop_RPMix_EF_function,'UserData');
xdata=xdata(vl);
if strcmp(xdata.field,'TimeBlocking')
  % 2010_2_RC05-1
  for ll=1:length(RPreMixData.Recipe);
    try
      RPreMixData.Recipe{ll}=rmfield(RPreMixData.Recipe{ll},'BlockPeriod');
      RPreMixData.Recipe{ll}=rmfield(RPreMixData.Recipe{ll},'TimeBlocking');
      RPreMixData.Recipe{ll}=rmfield(RPreMixData.Recipe{ll},'BlockData');
    catch
      disp(C__FILE__LINE__CHAR);
    end
  end
else
  % 2010_2_RC05-1
  for ll=1:length(xdata.idxs)
    try
      for mm=udata{ll}
        RPreMixData.Recipe{mm}.(xdata.field)(xdata.idxs(ll))=[];
      end
    catch
      disp(C__FILE__LINE__CHAR);
    end
  end
end
% Save Data & Update
setappdata(hs.figure1, 'RPreMixData',RPreMixData);
setappdata(hs.figure1,'ActiveDataModSTATE',true);
UpdateRecipe(hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grand Average
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_RPMix_GrandAveragePlot_Callback(hs)
% Draw Grand-Average..

RPreMixData=getappdata(hs.figure1, 'RPreMixData');
fcn =RPreMixData.fcn;  % Data-Function
data=RPreMixData.data; % Data-Function
ll=length(data);
idkey  = feval(fcn,'getIdentifierKey');
% Get 1st-Data
try
  ii=1;
  fname=feval(fcn,'make_mfile',RPreMixData.data(ii));
  [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
    'chdata', 'cdata', 'bhdata', 'bdata');
catch
  delete(fname);
  rethrow(lasterror);
end
delete(fname);

if ~isempty(bhdata)
  % For Block-Data
  data0=PlugInWrap_Flag2NaN('exe0',bdata,bhdata);
  stimkind=unique(bhdata.stimkind);
  sz=size(data0);

  dnum=zeros([length(stimkind),sz(2),sz(3),sz(4)]);
  data=dnum;
  flag=zeros([1,length(stimkind),sz(3)]);
  
  myperiod=bhdata.samplingperiod;
  idx=0;
  for sk=stimkind'
    idx=idx+1;
    bid=(bhdata.stimkind==sk);
    tmp=data0(bid,:,:,:);
    dnan=isnan(tmp);tmp(dnan)=0;
    dnum(idx,:,:,:)=sum(~dnan,1);
    data(idx,:,:,:)=sum(tmp,1);
    try
      flag(1,idx,:,:)=sum(bhdata.flag(1,bid,:),2);
    catch
    end
  end
  stimdiff=(bhdata.stim(2)-bhdata.stim(1))*bhdata.samplingperiod;
  hdata=bhdata;
  
  % Sum-up
  for ii=2:ll
    % Load Data
    fname=feval(fcn,'make_mfile',RPreMixData.data(ii));
    [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
      'chdata', 'cdata', 'bhdata', 'bdata');
    data0=PlugInWrap_Flag2NaN('exe0',bdata,bhdata);

    % Add Stim?
    n=setdiff(bhdata.stimkind,stimkind);
    if ~isempty(n)
      stimkind(end+1:end+length(n))=n;
    end
    sz0=size(data0);

    % Check size
    if ~isequal(sz0(3:end),sz(3:end))
      warning('Current Version : Data size must be same');
      disp([' Data size of ' RPreMixData.data(1).(idkey) ':'])
      disp(sz);
      disp([' Data size of ' RPreMixData.data(ii).(idkey) ':'])
      disp(size(data0));
      continue;
    end

    % Check Stim DIff
    stimdiff0=(bhdata.stim(2)-bhdata.stim(1))*bhdata.samplingperiod;
    if abs(stimdiff-stimdiff0)>OSP_STIMPERIOD_DIFF_LIMIT
      error(['[E] Stimulation Period vary a great deal.\n', ...
        '    Stim1 is %6.3f [sec]\n', ...
        '    Stim2 is %6.3f [sec]\n'], ...
        stimdiff,stimdiff0);
    end

    % Check Pereio
    if (myperiod~=bhdata.samplingperiod)
      warning('Current Version : Sampling Period must be same');
      continue;
    end

    % Time Index Check
    idx1=1:sz(2);
    idx2=1:sz0(2);
    a=hdata.stim-bhdata.stim;
    if a(1)>0
      idx1(1:a(1))=[];
    end
    if a(1)<0
      idx2(1:a(1))=[];
    end
    if length(idx1)>length(idx2)
      idx1(length(idx2)+1:end)=[];
    end
    if length(idx1)<length(idx2)
      idx2(length(idx1)+1:end)=[];
    end
    
    idx=0;
    for sk=stimkind'
      idx=idx+1;
      bid=(bhdata.stimkind==sk);
      tmp=data0(bid,idx2,:,:);
      dnan=isnan(tmp);tmp(dnan)=0;
      % Sum up
      if (size(dnum,1)<idx)
        % (New)
        dnum(idx,idx1,:,:)=sum(~dnan);
        data(idx,idx1,:,:)=sum(tmp);
        try
          flag(1,idx,:,:)=sum(bhdata.flag(1,bid,:),2);
        catch
        end
      else
        % Add
        dnum(idx,idx1,:,:)=dnum(idx,idx1,:,:)+sum(~dnan,1);
        data(idx,idx1,:,:)=data(idx,idx1,:,:)+sum(tmp,1);
        try
          flag(1,idx,:,:)=flag(1,idx,:,:)+sum(bhdata.flag(1,bid,:),2);
        catch
        end
      end
    end
  end
  data=data./(dnum+(dnum==0));
  % --> Ajust Header
  fsz=size(hdata.flag);
  if fsz(2)>1,
    try, hdata.stimTC2(2:end,:)=[];end
    try, hdata.stimkind=stimkind;end
    try, hdata.flag=flag;end
  end
  
  %  Load Layout and View
  p=fileparts(which(mfilename));
  f=[p filesep 'RPreMix_GrandAverage_LAYOUT.mat'];
  load(f,'LAYOUT');
  if 0
    % debug : Edit LAYOUT-File
    lh=LayoutEditor;
    lhs=guidata(lh);
    LayoutEditor('menu_openLayout_Callback',lhs.menu_openLayout,[],lhs,f);
  end
  P3_view(LAYOUT,chdata,cdata, ...
    'bhdata',hdata, 'bdata', data);
else
  error('Not for Continuous');
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Othere...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_RPMix_RecipeGroup_Edit_Callback(hs)
% Edit Callback
%   2010_2_RC01-2

% Analysis File Select
% Get Current Select File Index(Internal)
udata=get(hs.lbx_RPMix_RecipeGroup,'UserData');
vl=get(hs.lbx_RPMix_RecipeGroup,'Value');
internalindex=udata{vl};

% Get Outer File Index
vls   =get(hs.lbx_fileList,'Value');
newvls=vls(internalindex);

% Displayed File-List
dvls=get(hs.lbx_disp_fileList,'UserData');
[myidx myvl]=intersect(dvls,newvls); %#ok myidx is not use

% Set Select File
set(hs.lbx_disp_fileList,'Value',myvl);
POTATo('lbx_disp_fileList_Callback',hs.lbx_disp_fileList,[],hs);



