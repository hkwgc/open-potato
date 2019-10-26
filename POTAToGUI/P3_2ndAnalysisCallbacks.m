function varargout=P3_2ndAnalysisCallbacks(fcn, varargin)
% OSP Filter Control Panel, Callback-Functions.
%  This function is for OSP-NEW-GUI.
%
% Upper-Link : POTATo
%              (Sometime there FIG-File)
%
% Lower-Link : OspFilterDataFcn.
%
% See also POTATo, POTATo_win_MultiAnalysis.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2006.11.27
%   But this function is spin-out from POTATo_win_MultiAnalysis,
%   when Signal-Viewer use this functions.
% $Id: P3_2ndAnalysisCallbacks.m 293 2012-09-27 06:11:14Z Katura $

  switch fcn
    case 'pop_2ndAnalysis_PluginFunction_CreateFcn',
      % Search 2nd-Lvl-Ana Plugin & setup Popupmenu
      %  -->Callback in Layout-Function (from guimainfcn)
      % Syntax : 
      %    pop_2ndAnalysis_PluginFunction_CreateFcn(h)
      pop_2ndAnalysis_PluginFunction_CreateFcn(varargin{1});
    case 'pop_2ndAnalysis_PluginFunction_Callback',
      % Change Visible
      % Syntax : 
      %     pop_2ndAnalysis_PluginFunction_Callback(h,hs)
      pop_2ndAnalysis_PluginFunction_Callback(varargin{:});
    case 'psb_2ndAnalysis_Execute_Callback',
      psb_2ndAnalysis_Execute_Callback(varargin{3});
   otherwise,
    try
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fcn, varargin{:});
      else
        feval(fcn, varargin{:});
      end
    catch
      % Error::
      errordlg(lasterr);
    end
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control Funcion
%    Status Control : StatusOf2ndLvlAna
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=StatusOf2ndLvlAna(mod,data)
persistent status;

str={'SelectPlugin','MakingGroup','Result'};

val=true;
switch mod
  case 'init',
    % --> Init &
    mlock;
    if nargin>=2
      status=uint8(data);
    else
      status=uint8(0);
    end

  case 'final'
    munlock;
    status=[];
    
  case 'disp'
    % Display Status ::
    %   for debug
    fprintf('-------------------------\n');
    if isempty(status)
      fprintf(' ** Not Running ** \n');
    else
      s1=char(str);
      %s2={'False','True'};
      s2={'x','o'};
      for id=1:length(str)
        fprintf(' %s\t:\t%s\n',...
          s1(id,:),s2{bitget(status,id)+1})
      end
    end
    fprintf('-------------------------\n');
    
  otherwise,
    % ==> Status Change
    id=find(strcmpi(str,mod));
    if length(id)~=1,
      error('[P3 Program Error ] : Invarid STATUS : %s',mod);
    end
    if nargin>=2
      status=bitset(status,id,data);
    else
      val=bitget(status,id);
    end
end

%======================================================
function ChangeVisible(hs)
% Change Visible of 2nd-Lvl-Ana.
%   input ==>
%     hs         : handles of P3
%======================================================
if nargin<1
  h=OSP_DATA('GET','POTATOMAINHANDLE');
  hs=guidata(h);
end
h0=POTATo_win_2ndLevelAnalysis('myHandles',hs);
set(h0,'Visible','off'); % to confine

%--- if File Select?
if StatusOf2ndLvlAna('SelectPlugin')
  %h.txt_2ndAnalysis_title,...
  set([...
    hs.txt_2ndAnalysis_PluginFunction,...
    hs.pop_2ndAnalysis_PluginFunction,...
    hs.lbx_2ndAnalysis_PluginFunctionInfo,...
    hs.psb_2ndAnalysis_fnc_help],...
    'Visible','on');
end

if StatusOf2ndLvlAna('MakingGroup')
  set([...
    hs.lbx_2ndAnalysis_GroupList, ... 
    hs.txt_2ndAnalysis_GroupList, ... 
    hs.psb_2ndAnalysis_AddGroup, ...
    hs.psb_2ndAnalysis_RmGroup, ...
    hs.txt_2ndAnalysis_GroupInfo,...
    hs.lbx_2ndAnalysis_GroupInfo,...
    hs.psb_2ndAnalysis_Execute],...
    'Visible','on');
  %h.psb_2ndAnalysis_ChangeGroup, ...
end

hr=[hs.pop_Layout,hs.psb_drawdata,hs.psb_MakeMfile];
if StatusOf2ndLvlAna('Result')
  %set(hr,'Visible','on');
else
  set(hr,'Visible','off');
end

%======================================================
function startAnalysis(hs)
% Startup 2nd-Level-Analysis
%======================================================
actdata=getappdata(hs.figure1, 'LocalActiveData');
mydata=actdata.data.data;

% Status is Initialize
StatusOf2ndLvlAna('init');
%----------------------------
% Selecting Current Function
%----------------------------
lst=get(hs.pop_2ndAnalysis_PluginFunction,'UserData');
flg=true; % Modify/not modfy?
if isempty(mydata.Function) || isempty(lst)
  vl=1;
else
  % Check what data is selecting
  vl=find(strcmpi(mydata.Function,{lst.function}));
  if isempty(vl),
    errordlg({'2nd-Lvl-Ana Plugin Eror:',...
      sprintf('  No-Plugin named : %s',mydata.Function),...
      '   A. Confirm your 2nd-Lvl-Ana Plugin by which',...
      '   B. Use ''rehash'' / startup in Install Directory'},...
      'Could not found Proper Plugin');
    vl=1;
  else
    flg=false;
  end
end
set(hs.pop_2ndAnalysis_PluginFunction,'Value',vl(1));
pop_2ndAnalysis_PluginFunction_Callback(...
  hs.pop_2ndAnalysis_PluginFunction,hs)
setappdata(hs.figure1,'ActiveDataModSTATE',flg);

%----------------------------
% Selecting Current Group
%----------------------------
StatusOf2ndLvlAna('MakingGroup',true);
set(hs.lbx_2ndAnalysis_GroupList,...
  'UserData',mydata.Group,'Value',1);
ShowGroupList(hs);
lbx_2ndAnalysis_GroupList_Callback(...
  hs.lbx_2ndAnalysis_GroupList,hs)

%----------------------------
% Getting Result
%----------------------------
if ~isempty(mydata.Result)
  StatusOf2ndLvlAna('Result',true);
  set(hs.psb_2ndAnalysis_Execute,'UserData',mydata.Result);
end

ChangeVisible(hs);

%======================================================
function sladata=get2ndLvlAnaData(hs)
% 2nd-Lvel-Analysis Data seted in thg GUI's
%  (Out put Function of thoes Parths)
%======================================================
actdata=getappdata(hs.figure1, 'LocalActiveData');
sladata=actdata.data;
mydata=sladata.data;
%----------------------------
% Selecting Current Function
%----------------------------
lst=get(hs.pop_2ndAnalysis_PluginFunction,'UserData');
vl =get(hs.pop_2ndAnalysis_PluginFunction,'Value');
if length(lst)>=vl,
  mydata.Function=lst(vl).function;
end
%----------------------------
% Selecting Current Group
%----------------------------
if StatusOf2ndLvlAna('MakingGroup');
  mydata.Group=get(hs.lbx_2ndAnalysis_GroupList,'UserData');
end

%----------------------------
% Getting Result
%----------------------------
if StatusOf2ndLvlAna('Result')
  mydata.Result=get(hs.psb_2ndAnalysis_Execute,'UserData');
else
  mydata.Result={};
end
sladata.data=mydata;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting of 2nd-Lvel-Analysis Window!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======================================================
function pop_2ndAnalysis_PluginFunction_CreateFcn(h)
% Search 2nd-Lvel-Analysis Plugin & set Property to h.
%======================================================
initdir=pwd;
%--------------------------------
% Search Path 2nd-Lvl-Ana Plugin
%--------------------------------
% make SearchPath
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end

[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  searchpath = [osp_path filesep '..' filesep '2ndLvlAnaPlugin'];
  searchpath2= [osp_path filesep '..' filesep 'PluginDir'];
else
  searchpath = [osp_path filesep '2ndLvlAnaPlugin'];
  searchpath2= [osp_path filesep 'PluginDir'];
end
% get file-list named Plugin2ndLvlAna_
files =find_file('^Plugin2ndLvlAna_\w+.[mp]$', searchpath,'-i');
files2=find_file('^PluginWrapP2_\w+.[mp]$', searchpath2,'-i');
files={files{:},files2{:}};
%-->  (dumy for  M-Lint)
if 0
  % Structure of Function List!
  fnclist.wrap = eval(['@' mfilename]); % dumy
  fnclist.name = 'dumy';
  fnclist.info = struct('dumy',[]);
end

id=1;
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
    % Get Basic Info!
    % -----------------
    bi = feval(nm2,'createBasicInfo');
    % Check Basic Info
    if ~isfield(bi,'name')
      error([nm ' : no-name in BasicInfo']);
    end
    if ~isfield(bi,'wrap')
      error([nm ' : no-wrap in BasicInfo']);
    end
    if ~isfield(bi,'Version'),
      error([nm ' : no-Version in BasicInfo']);
    end
    
    %---------------
    % Add to List
    % (If no error)
    %---------------
    tmpfnc.function = nm;
    tmpfnc.wrap     = nm2;
    tmpfnc.name     = bi.name;
    tmpfnc.info     = bi;
    
    fnclist(id)    = tmpfnc;
    id=id+1;
  catch
    % ==> in create function : not warning..
    disp(files{idx});
    warning(lasterr);
  end
end
cd(initdir);
if id==1,
  % No Data
  set(h,'Visible','off');
  % --> Cannot Avirable | 2nd-Level-Analysis
  % for user benefit.
  %rehash TOOLBOX
  rehash
  errordlg({'No 2nd-Level-Analysis Plugin,',...
    '  Please Confine your Plugin-Function.',...
    '     /   Plugin 2nd-Level-Analysis at first!'},...
    'No 2nd-Lvl-Ana Plugin Available');
else
  set(h,'Visible','on');
  set(h,'Value',1,'String',{fnclist.name},'UserData',fnclist);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selecting Plugin Function (2nd-Lvel-Analysis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_2ndAnalysis_PluginFunction_Callback(h,hs)
% Change Visible (Simple Help)
ud=get(h,'UserData');
vl=get(h,'Value');
setappdata(hs.figure1,'ActiveDataModSTATE',true);
StatusOf2ndLvlAna('Result',false);
if length(ud)>=vl,
  StatusOf2ndLvlAna('SelectPlugin',true);
else
  StatusOf2ndLvlAna('SelectPlugin',false);
  return;
end

% --> Change Simple Help <--
ud=ud(vl);
try
  str=feval(ud.wrap,'simlpleHelpText');
catch
  % disp('[W] Inproper Plugin-Warning!');
  str={'No Help Comment in this Function', ...
    ' becase : ',lasterr};
end
set(hs.lbx_2ndAnalysis_PluginFunctionInfo,...
  'Value',1,...
  'String',str);

% --> Real Help <--
hh=hs.psb_2ndAnalysis_fnc_help;
try
  % get tgl-value
  v=get(hh,'Value'); % if help is on
  if v
    % show help
    psb_2ndAnalysis_PluginFunctionHelp_Callback(hh,hs);
  end
catch
  errordlg({'2nd-Analysis-Help : Open Error',lasterr});
end

function lbx_2ndAnalysis_PluginFunctionInfo_Callback(h,hs)
% Do nothing now
function psb_2ndAnalysis_PluginFunctionHelp_Callback(h,hs)
% Help of the function

v=get(h,'Value');
if v
  ud=get(hs.pop_2ndAnalysis_PluginFunction,'UserData');
  ud=ud(get(hs.pop_2ndAnalysis_PluginFunction,'Value'));
  try
    feval(ud.wrap,'help');
  catch
    % --> for debug::
    set(h,'UserData',lasterr);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selecting Group.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================
function ShowGroupList(hs,ud,vl)
% Update Group-List
%===================================
h=hs.lbx_2ndAnalysis_GroupList;

if nargin<2
  ud=get(h,'UserData');
end
if nargin<3
  vl=get(h,'Value');
end

str=cell(1,length(ud));
for idx=1:length(ud)
  try
    bi=feval(ud{idx}.function,'createBasicInfo');
    num=length(ud{idx}.groups);
    if num==1
      if isfield(ud{idx}.groups(1),'empty'),
        num=0;
      end
    end
    str{idx}=sprintf('[%3d] : %s :(x%d)',...
      idx,bi.name,num);
  catch
    str{idx}=sprintf('[%3d] : !ERROR! :(NaN)',idx);
  end
end
if isempty(str)
  str={'-- Empty --'};
end

set(h,'Value',min(vl,length(str)),'String',str);
if nargin>=2,set(h,'UserData',ud);end
lbx_2ndAnalysis_GroupList_Callback(h,hs);

%===================================
function lbx_2ndAnalysis_GroupList_Callback(h,hs)
% Change Group-Information
%===================================
ud=get(h,'UserData');vl=get(h,'Value');
if length(ud)<vl,
  set(hs.lbx_2ndAnalysis_GroupInfo,...
    'Value',1,...
    'String',...
    {'No Group Selected.',...
    ' * Add Group to the List.'});
  return;
end

ud=ud{vl};
bi=feval(ud.function,'createBasicInfo');
str={[' Function       : ' bi.name]};
num=length(ud.groups);
if num==1
  if isfield(ud.groups(1),'empty'),
    num=0;
  end
end
str{end+1}=sprintf(' Number of Data : %d',num);
str{end+1}='-----------------------------';
for idx=1:num
  if isfield(ud.groups(idx),'Inner')
    str{end+1}=sprintf('  %d : %s \t\t> %s (x%d)',...
      idx,ud.groups(idx).Files.name,...
      ud.groups(idx).Inner.Key,...
      length(ud.groups(idx).Inner.Val));
  else
    str{end+1}=sprintf('  %d : %s',...
      idx,ud.groups(idx).Files.name);
  end
end
if num==0;str{end+1}=' *** Empty ***';end
str{end+1}='-----------------------------';
% Update 
set(hs.lbx_2ndAnalysis_GroupInfo,...
  'Value',1,...
  'String',str);

function lbx_2ndAnalysis_GroupInfo_Callback(h,hs)
% Do nothing now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modify Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================
function psb_2ndAnalysis_AddGroup_Callback(h,hs)
% Make Group && Add Group (to GUI, not-data-file)
%===================================
%---------------------
% Making --> Group
%---------------------
group=P3_uiFLAselect;
% cancel?
if isempty(group),return;end
setappdata(hs.figure1,'ActiveDataModSTATE',true);
StatusOf2ndLvlAna('Result',false); % Result must be change

%---------------------
% Update --> Group
%---------------------
ud  = get(hs.lbx_2ndAnalysis_GroupList,'UserData');
if isempty(ud)
  ud={group};
else
  ud{end+1}=group;
end
ShowGroupList(hs,ud,Inf);

function psb_2ndAnalysis_RmGroup_Callback(h,hs)
% Remove Group:

ud  = get(hs.lbx_2ndAnalysis_GroupList,'UserData');
vl  = get(hs.lbx_2ndAnalysis_GroupList,'Value');
if length(ud)<vl,
  helpdlg({'No Data to remove!'},'Remove Group');
  return;
end
ud(vl)=[];
% Update Group
ShowGroupList(hs,ud);
setappdata(hs.figure1,'ActiveDataModSTATE',true);
StatusOf2ndLvlAna('Result',false);

function psb_2ndAnalysis_ChangeGroup_Callback(h,hs)
% now: unpopulated 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_2ndAnalysis_Execute_Callback(hs)
% Execute 2nd-Level-Analysis!
data=get2ndLvlAnaData(hs); % Get 

gdata0=data.data.Group;
for gid=1:length(gdata0)
  fnc=gdata0{gid}.function;
  bi=feval(fnc,'createBasicInfo');
  % Get -- number of 1st-Lvl-Ana data in the group (gid)
  num=length(gdata0{gid}.groups);
  if num==1
    if isfield(gdata0{gid}.groups,'empty'),
      num=0;
    end
  end
  
  % init local group data
  tmp.fhdata={};
  tmp.fdata={};
  fla_list=DataDef2_1stLevelAnalysis('loadlist');

  if isfield(gdata0{gid}.groups,'Inner')
    for idx=1:num
      [tmp.fhdata{end+1}, tmp.fdata{end+1}]=...
        DataDef2_1stLevelAnalysis('load',...
        gdata0{gid}.groups(idx).Files,...
        gdata0{gid}.groups(idx).Inner,fla_list);
    end
  else
    for idx=1:num
      [tmp.fhdata{end+1}, tmp.fdata{end+1}]=...
        DataDef2_1stLevelAnalysis('load',...
        gdata0{gid}.groups(idx).Files,[],fla_list);
    end
  end
  % In Execute Function of data.data.Function
  Group(gid)=tmp;
end

try
  if exist('Group','var')
    % Input
    r=feval(data.data.Function,'Execute',Group);
  else
    % No Input
    r=feval(data.data.Function,'Execute');
  end
catch
  errordlg({'2nd-Lvl-Ana Plugin Error:',...
      sprintf('   Function %s :',data.data.Function),...
      '     Error Occur in Execute Function.',...
      '',...
      ['   ' lasterr]},...
    sprintf('%s/Execute',data.data.Function));
  return;
end

StatusOf2ndLvlAna('Result',true);
set(hs.psb_2ndAnalysis_Execute,'UserData',r);

