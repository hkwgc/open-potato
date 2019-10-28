function varargout=OspFilterCallbacks(fcn, hObject, eventdata, handles)
% OSP Filter Control Panel, Callback-Functions.
%  This function is for OSP-GUI.
%
% Upper-Link : block_filter, signal_viewr.
%              (Sometime there FIG-File)
%
% Lower-Link : OspFilterDataFcn.
%
% See also BLOCK_FILTER, SIGNAL_VIEWER, OSPFILTERDATAFCN.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2005.??.??
%   I'm not sure, Feb ? Jan?
%   But this function is spin-out from block_filter,
%   when Signal-Viewer use this functions.
% $Id: OspFilterCallbacks.m 397 2014-03-31 04:29:56Z katura7pro $
%
% Reversion 1.7 :
%   Add BlockPeriod to FilterData.
%   We use This field is special one.
%   we assume this is uc_blocking Special Data.
%
% Reversion 1.14
%   Save GroupData (Filter-Data)
%
% Revision 1.20
%   ==> Filter Data : Cell
%
% Revision 1.44, 1.45
%  Bugfix : 070615A
%
% Revision 1.46
%  Blush-Up (getfield/setfield)
%
% Revision 1,47
%  --> Start-Up Message
switch fcn
  case 'set'
    setFMD(hObject,eventdata);
    handles=guidata(hObject); % handles is not inputed.
    pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);

  case 'get'
    if nargin<2, hObject=gcf; end
    rm_flag=1;
    if nargin>=3, rm_flag=eventdata; end
    fmd=getFMD(hObject,rm_flag);
    varargout{1}=fmd;

  case 'get with 1st Lvl Ana'
    if nargin<2, hObject=gcf; end
    rm_flag=1;
    if nargin>=3, rm_flag=eventdata; end
    fmd=getFMD(hObject,rm_flag,true);
    varargout{1}=fmd;

  case 'LocalActiveDataOn',
    hs = [handles.pop_FilterList, ...
      handles.psb_addFiltData, ...
      handles.psb_removeFiltData, ...
      handles.lbx_FiltData, ...
      handles.psb_changeFiltData, ...
      handles.psb_Suspend, ...
      handles.psb_upFiltData, ...
      handles.psb_downFiltData];
    if isfield(handles,'psb_testplot');
      hs = [hs, handles.psb_testplot];
    end
    set(hs, 'enable', 'on');
    % ==> in POTTo Remake Filter! <==

    % lbx_FiltData_Callback(handles.lbx_FiltData, eventdata, handles)
  case 'LocalActiveDataOff',
    hs = [handles.pop_FilterList, ...
      handles.psb_addFiltData, ...
      handles.psb_removeFiltData, ...
      handles.lbx_FiltData, ...
      handles.psb_changeFiltData, ...
      handles.psb_Suspend, ...
      handles.psb_upFiltData, ...
      handles.psb_downFiltData];
    if isfield(handles,'psb_testplot');
      hs = [hs, handles.psb_testplot];
    end
    set(hs, 'enable', 'off');
  otherwise,
    try
      eval([fcn '(hObject, eventdata, handles)'], ...
        'errordlg(lasterr);');
    catch
      error([lasterr ':: Fileter Manage Data ' ...
        'is Cell in this Version ::']);
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In Application data 'FILTER_MANAGER'
%    Change Definition : since revision 1.20
% --> This Function is I/O function of the data
%    There is bug : for Block-Filter Enable/Disable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fmd=getFMD(fig_h,rm_flag,fla_flag)
% Get Filter-Manage-Data to use/save.
%
%   FIG_H    : Handle of Figure.
%
%   RM_FLAG  : Remove 
%
%   FLA_FLAG : Get 1st-Level-Analysis Function.
%              true  : Get.
%              false : Remove.
%              default : false.
%=============================================
refreshflag=false;

%--------------------------------------
% Get Filter-Manage-Data (Raw)
%--------------------------------------
fmd=getappdata(fig_h,'FILTER_MANAGER');
if isempty(fmd), return;end

%--------------------------------------
% Set Default Arguments
%--------------------------------------
if (nargin<=1), rm_flag=true; end
if nargin<3,fla_flag=false;end

%--------------------------------------
% Remove Enable-Field
%--------------------------------------
% --> since 1.20 :
% 2006.04.19 :
%  Remove This Operation


%-------------------------------------
% Remove Block-Time Period Functions.
%-------------------------------------
if isfield(fmd,'block_enable') && fmd.block_enable,
  % Use Block Period
elseif isfield(fmd,'BlockPeriod') && rm_flag,
  % Delete Block Perios
  fmd=rmfield(fmd,'BlockPeriod');
end

%-------------------------------------
% Remove 1st-Level-Analysis Functions
%               since :    15-Feb-2007
%-------------------------------------
if fla_flag,return;end

%............
% Load-Data
%............
hs = guidata(fig_h); % Get GUI-Data (Handles)
ud = get(hs.pop_FilterDispKind,'UserData');
Regions=ud.Regions;
DefineOspFilterDispKind; % Display-Kind Definition

%.................
% Check & Remove
%.................
% Region Loop
for rg = 1:length(Regions)
  % no-Data to Skip This Region
  if ~isfield(fmd,Regions{rg}),continue;end

  % - - - - - - - - -
  % Get FilterData
  % - - - - - - - - -
  fmd_Region = ['fmd.' Regions{rg}];
  fdata = eval([fmd_Region ';']);
  
  % - - - - - - - - - - - - - - - - - -
  % Ignore Old Code (Array of Structure)
  % (not include 1st-Lvl-Ana)
  % - - - - - - - - - - - - - - - - - -
  if isstruct(fdata),continue;end

  fdata_out={}; % Output Data
  for fd = 1:length(fdata)
    fdata0 = fdata{fd};

    % - - - - - - - - - - - - - - - - - - - - - -
    % Check :  Is fdata0 '1st-Lvl-Ana Plugin' ?
    % - - - - - - - - - - - - - - - - - - - - - -
    try
      % Check Default Function?
      % --> 070521B :: wrap is char/function pointer
      if ischar(fdata0.wrap)
        fnc=fdata0.wrap;
      else
        fnc=func2str(fdata0.wrap);
      end
      if ~strcmpi(fnc(1:10),'FilterDef_')
        % Plugin Function : is 1st-Lvl-Ana ?
        info=P3_PluginEvalScript(fdata0.wrap,'createBasicInfo');
        if (isfield(info,'DispKind') && info.DispKind==F_1stLvlAna),continue;end
      end
    catch
      q=questdlg({'Unknown Wrapper :',...
        ['  Named : ' fdata0.name],...
        '',...
        'Do you want to Delete?'},...
        'Unknown Function :',...
        'Yes','No','Yes');
      if strcmpi(q,'Yes'),
        refreshflag=true;
        continue;
      end
    end
    fdata_out{end+1}=fdata0;
  end % Filter Data Loop
  
  % - - - - - - - - - - - - - - - - - - - - - -
  % Update Filter-Manage-Data 's Region Field
  % - - - - - - - - - - - - - - - - - - - - - -
  eval([fmd_Region '= fdata_out;']);
end % Region Loop

if refreshflag
  setFMD(fig_h,fmd);
  pop_FilterDispKind_Callback(hs.pop_FilterDispKind,[],hs);
end

function setFMD(fig_h,fmd)
%-----------------------
% Set Filter Manage Data
%   with Enable Flag, default value is on.
%-----------------------

% Setting Enable flag
if isempty(fmd),
  % Reset to Empty, return;
  clear fmd;
  fmd.HBdata={};
end
rg=fieldnames(fmd); % Get Region

%~~~~~~~~~~~~~~~~~~~~
% Version Transfer
%  OSP Ver 2.00 Group-Data
%   to Ver 2.11 Group-Data
%~~~~~~~~~~~~~~~~~~~~~
% == Region Loop ==
for rgid=1:length(rg)
  if any(strcmp(rg{rgid},{'dumy','block_enable','BlockPeriod'}))
    continue;
  end
  tmp=fmd.(rg{rgid});
  if iscell(tmp), continue; end

  % Transfer Each Data Struct to Cell
  fmd0={};
  % tmp must be Structuer!
  for tidx=length(tmp):-1:1,
    fmd0{tidx} = tmp(tidx);
    if ~isfield(fmd0{tidx},'enable'),
      fmd0{tidx}.enable='on';
    end
  end
  fmd.(rg{rgid})=fmd0;
end
if ~isfield(fmd,'block_enable'), fmd.block_enable = true; end
if isfield(fmd,'dumy'),fmd=rmfield(fmd,'dumy');end
setappdata(fig_h,'FILTER_MANAGER',fmd);

% change view
handles = guidata(fig_h);
[info,linfo] = OspFilterDataFcn('getInfo',fmd);
if isempty(info)
  set(handles.lbx_FiltData,'String','-- No Filter Data --');
  OSP_LOG('perr','Error : No information About Filter'); % may be
  return;
end
set(handles.lbx_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',1);
lbx_FiltData_Callback(handles.lbx_FiltData, [], handles);
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filter Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==> Filter Kind Selection
function pop_FilterDispKind_Switch_1stLvl(h,e,hs)
% ==> 1st-Lvel-Ana/ Normal Filter
%     Switching Function

% Check : is P3 Running?
try
  isrun=OSP_DATA('GET','isPOTAToRunning');
  if isempty(isrun),isrun=false;end
catch
  isrun=false;
end
if ~isrun,return;end

% Check 1st-Lvel-Ana
p3mode=OSP_DATA('GET','POTATO_P3MODE');
adv= strcmpi(p3mode,'Developer');
flg=get(hs.advtgl_1stLvlAna,'Value');
if flg && adv
  % 1st Level Ana
  set(h,'Value',1,'String',{'1st-Lvl-Ana'});
else
  % Normal Filter
  pop_FilterDispKind_CreateFcn(h,e,hs);
end
pop_FilterDispKind_Callback(h,e,hs);
return;

%==========================================
function pop_FilterDispKind_CreateFcn(h,e,hs)
% Create Normal Filter Display-Kind Popup-menu
%==========================================
try
  p3ash=P3('getStatusHandle');
  if ~isempty(p3ash) && ishandle(p3ash)
    set(p3ash,'String',{'Filter-Display-Kind : Create MPP-Type'});
    POTATo_About;
  end
  [FilterList, Regions, DispKind] = OspFilterDataFcn('getList');
  if isempty(FilterList)
    error(' No Fiter Data Available');
  end
  ud.FilterList= FilterList;
  ud.Regions = Regions;
  ud.DispKind= DispKind;
  str={'All Filter'};
  
%   , ...
%     'General', ...
%     'Time Series', ...
%     'Flag', ...
%     'Data Change', ...
%     'Control'};

  % Book Mark
  str2=OspFilterDataFcn('BookMarkString');
  if ~isempty(str2), str={str2,str{:}}; end

  set(h, 'Value',1,'String',str,'UserData',ud);
catch
  errordlg(lasterr);
  OSP_LOG('err',' No Fiter Data Available',...
    'OspFilterDataFcn(''getList'');');
end
return;

function pop_FilterDispKind_Callback(h,e,hs)
% --> Filter List Selection:: <--
DefineOspFilterDispKind;
vl=get(h,'Value');st=get(h,'String');
md=st{vl}; clear vl st;
ud=get(h,'UserData');

% === Modifyed For POTATo ===
switch md,
  case 'All Filter',
    %---------------------------
    % Check is Potato running?
    %--------------------------
    try
      isrun=OSP_DATA('GET','isPOTAToRunning');
      if isempty(isrun),isrun=false;end
    catch
      isrun=false;
    end
    if isrun,
      %---------------------------------
      % POTATo : Set Additional Filters
      %---------------------------------
      useflg = find(~bitand(ud.DispKind,F_NOTALL));
      %-----------
      % Add Bloking
      %-----------
      fmd=getFMD(hs.figure1,false,true); % with not remove;
      if ~isfield(fmd,'BlockPeriod'),
        %useflg(end+1) = find(bitand(ud.DispKind,F_Blocking0));
        %useflg=sort(useflg);
        useflg=union(useflg,find(bitand(ud.DispKind,F_Blocking0)));
      end

    else
      %---------------------------------
      % Only OSP set Ordinal Filter
      %---------------------------------
      %useflg=1:length(ud.DispKind);
      useflg = find(~bitand(ud.DispKind,F_NOTALL));
    end
  case 'General',
    useflg=find( bitand(ud.DispKind,F_General) );
  case 'Time Series',
    useflg=find( bitand(ud.DispKind,F_TimeSeries) );
  case 'Flag',
    useflg=find( bitand(ud.DispKind,F_Flag) );
  case 'Data Change',
    useflg=find( bitand(ud.DispKind,F_DataChange) );
  case 'Control',
    useflg=find( bitand(ud.DispKind,F_Control) );
    
  case '1st-Lvl-Ana',
    useflg=find( bitand(ud.DispKind,F_1stLvlAna0) );
    if isempty(useflg),
      errordlg('No 1st-Lvel-Analysis Plugin!');
      set(hs.pop_FilterList,...
        'Visible','off',...
        'String','Not Plugin Exist',...
        'UserData',[]);
      return;
    end
  otherwise,
    % Book Mark?
    useflg=find( bitand(ud.DispKind,F_BOOKMARK));
end

if isempty(useflg),
  errordlg('No Filter Exist!!');
  set(h,'Value',1);
  % "Value" 1: All Filter.
  pop_FilterDispKind_Callback(h,e,hs);
  return;
end

hf=hs.pop_FilterList;
% Set Value (2011.01.05)
try
  s=get(hf,'String');
  v=get(hf,'Value');
  vl=find(strcmp(s{v},ud.FilterList(useflg)));
  if isempty(vl),vl=1;end
catch
  vl=1;
end
set(hf,...
  'Visible','on',...
  'Value',vl, ...
  'String',ud.FilterList(useflg),  ...
  'Enable','on', ...
  'UserData',ud.Regions);

return;

function pop_FilterList_CreateFcn(hObject, eventdata, handles)
% ----------------
% Read Filter List
% ----------------
try
  p3ash=P3('getStatusHandle');
  if ~isempty(p3ash) && ishandle(p3ash)
    set(p3ash,'String',{'Filter-List : Create MPP-Type'});
    POTATo_About;
  end

  %[FilterList, Regions] = OspFilterDataFcn('getList');
  [FilterList, Regions] = OspFilterDataFcn('ListReset');
  if isempty(FilterList)
    error(' No Fiter Data Available');
  end
  set(hObject,'Value',1, ...
    'String',FilterList,  ...
    'Enable','on', ...
    'UserData',Regions);
catch
  errordlg(lasterr);
  OSP_LOG('err',' No Fiter Data Available',...
    'OspFilterDataFcn(''getList'');');
end
return;

function pop_FilterList_Callback(h, ev, hs)
% Filte - List Popupwas change :: display help 
%  ** Meeting on 12-Oct-2007 **
if 0,disp(ev);end
v=get(hs.psb_HelpFiltData,'Value');
if v,
  id = get(h,'Value');
  fl = get(h,'String');   % FilterName
  filtername=fl{id}; clear id fl;
  OspFilterDataFcn('FuncHelp',filtername);
end


%------------------------
% ==== Data  Select =====
%------------------------
function lbx_FiltData_Callback(hObject, eventdata, handles)
% ----------------
%  Update related Button Enable
% ----------------

data  = getappdata(handles.figure1, 'FILTER_MANAGER');
linfo = get(handles.lbx_FiltData,'Userdata');
id0   = get(handles.lbx_FiltData,'Value');
% scalar
%set(handles.lbx_FiltData,'Max',2);
%if ~isempty(id0)
%  id0=id0(1);
%end
rg    = get(handles.pop_FilterList,'UserData'); % Regions

enable_h  =[];
disable_h =[];

% Set Enable / Disable
if isempty(linfo) || linfo(id0,2)==0
  % Boundary of Data Region
	
  % Check POTATo is run?
  try
    isrun=OSP_DATA('GET','isPOTAToRunning');
    if isempty(isrun),isrun=false;end
  catch
    isrun=false;
  end
  if isrun,
    % POTATo is running!
    disable_h =[handles.psb_downFiltData; ...
      handles.psb_upFiltData];
    if isempty(linfo) || linfo(id0,1)~=3, % BlockData
      disable_h(end+1)=handles.psb_removeFiltData;
      disable_h(end+1)=handles.psb_changeFiltData;
      disable_h(end+1)=handles.psb_Suspend;
		else
%			% Block
%			if linfo(id0,3)==1
%				set(handles.lbx_FiltData,'Value',[id0-1,id0]);
%			else
%				set(handles.lbx_FiltData,'Value',[id0,id0+1]);
%			end

      enable_h(end+1)=handles.psb_removeFiltData;
      enable_h(end+1)=handles.psb_changeFiltData;
      enable_h(end+1)=handles.psb_Suspend;
    end
    % Bugfix : 070615A
    if data.block_enable,
      set(handles.psb_Suspend, 'String', 'Disable');
    else
      set(handles.psb_Suspend, 'String', 'Enable');
    end
  else
    % OSP is running!
    disable_h =[handles.psb_removeFiltData; ...
      handles.psb_downFiltData; ...
      handles.psb_upFiltData];
    
    if isempty(linfo) || linfo(id0,1)~=3, % BlockData
      
      disable_h(end+1)=handles.psb_changeFiltData;
      disable_h(end+1)=handles.psb_Suspend;
    else
      enable_h(end+1)=handles.psb_changeFiltData;
      if linfo(id0,1)==3 && ...
          ( strcmp(get(handles.figure1,'Name'),'Signal Viewer') || ...
          strcmp(get(handles.figure1,'Name'),'Signal Viewer II') || ...
          strcmp(get(handles.figure1,'Name'),'View') ),
        enable_h(end+1)=handles.psb_Suspend;
        if data.block_enable,
          set(handles.psb_Suspend, 'String', 'Disable');
        else
          set(handles.psb_Suspend, 'String', 'Enable');
        end
      else
        disable_h(end+1)=handles.psb_Suspend;
      end
    end
  end % is Potato running?
else
  % not Boundary of Data Region
  index = linfo(id0,:);
%  if linfo(id0,3)==1
%    set(handles.lbx_FiltData,'Value',[id0-1,id0]);
%  else
%    set(handles.lbx_FiltData,'Value',[id0,id0+1]);
%  end

  % Get Filter Data of Selected Region
  rgdata = data.(rg{index(1)});
  fdata0 = rgdata{index(2)}; % Filter Data!
  ar     = OspFilterDataFcn('getAllowRegion',fdata0.name);


  % * Remove Button & Change
  enable_h = [enable_h; ...
    handles.psb_removeFiltData; ...
    handles.psb_Suspend; ...
    handles.psb_changeFiltData];

  if isfield(fdata0,'enable'),
    if strcmp(fdata0.enable, 'on')
      set(handles.psb_Suspend, 'String', 'Disable');
    else
      set(handles.psb_Suspend, 'String', 'Enable');
    end
  end

  % * Up
  if ( ( index(2)==1 && ...
      isempty(find(ar==(index(1)-1)))) || ...
      ( strcmp(fdata0.name,'Resize Block')) )
    disable_h =[disable_h; handles.psb_upFiltData];
  else
    enable_h = [enable_h; handles.psb_upFiltData];
  end

  % * Down
  if ( ( index(2) == length(rgdata) && isempty(find(ar==(index(1)+1))) ) || ...
      ( strcmp(fdata0.name,'Resize Block')) || ...
      ( index(2) == length(rgdata) && linfo(end,1)==index(1) ) ),
    disable_h =[disable_h; handles.psb_downFiltData];
  else
    enable_h = [enable_h; handles.psb_downFiltData];
  end
end

% Set Property;
%   Set Here Chang Property, like color, visible and so on
enable_h(~ishandle(enable_h))=[];
if ~isempty(enable_h)

% if ~isempty(~enable_h)
  set(enable_h,  'Enable','on');
end
set(disable_h, 'Enable','off');

if get(handles.psb_HelpFiltData,'Value')>=1
  if strcmpi(get(handles.psb_changeFiltData,'Enable'),'on')
    if linfo(id0,2)==0
      if isfield(data,'TimeBlocking'),
        filtdata=data.TimeBlocking{1};
        OspFilterDataFcn('FuncHelp',filtdata.name);
      else
        % OSP : Original Change Method.
        %       No Special Time-Bloking Plugin.
      end
    else
      filtdata=data.(rg{linfo(id0,1)}){linfo(id0,2)};
      OspFilterDataFcn('FuncHelp',filtdata.name);
    end
  end
end

% if you want to change property
%   corresponding to selected name
% switch data(id).name
% end

% ================
% Save Group-Data
% ================
% Since  r1.14
saveflag=getappdata(handles.figure1,'SAVE_GROUP');
if isempty(saveflag), saveflag=false; end
if saveflag,
  fig_name=get(handles.figure1,'Name');
  switch fig_name,
    case 'Signal Viewer',
      % Bug Fix -> Signal Viewer II
      signal_viewer('SaveGroupData',hObject,[],handles);
    case 'Signal Viewer II',
      signal_viewer2('SaveGroupData',hObject,[],handles);
    case 'View',
      signal_viewer3('SaveGroupData',hObject,[],handles);
    case 'Block Filter'
      block_filter('SaveGroupData', ...
        handles.file_save_psb,[],handles);
    otherwise,
      %case 'Platform for Optical Topography Analysis Tools'
      %setappdata(handles.figure1,'ActiveDataModSTATE',true);
      % ==> Not save Filete-Data <==
      %     By Selecting    %
      % (Filter Manager I/O)
      % For POTATo
      setappdata(handles.figure1,'ActiveDataModSTATE',true);
  end
  setappdata(handles.figure1,'SAVE_GROUP',false);
end

return;

function fi_ln = getFilterInfoLineNo(linfo,index)
% Get FilterInfo(made in OSPFilteData) line, from index
try
  % If Matlab Version 7.0, use find(*,1)
  rg = find(linfo(:,1)==index(1));
  fl = find(linfo(rg:end,2)==index(2));
  fl = rg(1) + fl(1)-1;
  in = find(linfo(fl:end,3)==index(3));
  fi_ln = fl + in(1) -1;
  if fi_ln < 0 || fi_ln > size(linfo,1)
    error(['fi_ln : Over flow : ' ...
      sprintf('\n')
      'Result : ' num2str(fi_ln) ...
      sprintf('\n')
      'Region : ' num2str(rg(1)) ...
      sprintf('\n')
      'Filter : ' num2str(fl(1)) ...
      sprintf('\n')
      'Index  : ' num2str(in(1))]);
  end
catch
  warning(' Select FilterInfo lineNo Error. Use Default..')
  OSP_LOG('perr',' Can not Fiind FilterInfo lineNo.',lasterr, ...
    ['    index         : ' num2str(index)], ...
    ['    size of linfo : ' num2str(size(linfo))]);
  fi_ln=1;
end
return;

function psb_HelpFiltData_Callback(hObject, eventdata, handles)
% --------------------
%  Help of Filter Data
% --------------------
% get Filter Name
v=get(hObject,'Value');
if v
  id = get(handles.pop_FilterList,'Value');
  fl = get(handles.pop_FilterList,'String');   % FilterName
  filtername=fl{id}; clear id fl;
  %rg = get(handles.pop_FilterList,'UserData'); % Regions
  OspFilterDataFcn('FuncHelp',filtername);
else
  uihelp([],'close');
end


function psb_addFiltData_Callback(hObject, eventdata, handles)
% ----------------
%  Add Data
% ----------------

% get Filter Name
id = get(handles.pop_FilterList,'Value');
fl = get(handles.pop_FilterList,'String');   % FilterName
filtername=fl{id}; clear id fl;
rg = get(handles.pop_FilterList,'UserData'); % Regions

% Easter Egg...
% sory for bad source-code,
% this block for LoacalFiting, Resize, and so on.
rgidx  = OspFilterDataFcn('getAllowRegion',filtername);
% Minimum region is Blocking or later?
if (min(rgidx) >=3 ),
  % with Block Period seting Check
  setFilterDefInputData(handles, 1);
else
  % no block period setting
  setFilterDefInputData(handles);
end

% Get "Filter Data Manage"
data   = getappdata(handles.figure1, 'FILTER_MANAGER');
if isfield(data,'block_enable')
  bpflag=isfield(data,'BlockPeriod') & data.block_enable;
else
  bpflag=isfield(data,'BlockPeriod');
end
% --make M-File--
tmp_data = data;
rgidx  = OspFilterDataFcn('getAllowRegion',filtername);
if rgidx==-1,rgidx=1;end
for rgidx0=rgidx+1:length(rg),
  if isfield(data, rg{rgidx0}),
    tmp_data = rmfield(tmp_data, rg{rgidx0});
  end
  if strcmpi(rg{rgidx0},'BlockData')
    tmp_data.block_enable=false;
    if isfield(tmp_data,'BlockPeriod')
      tmp_data=rmfield(tmp_data,'BlockPeriod');
    end
  end
end


befor_mfile = get_now_mfile(handles, tmp_data);


% Make Filter Data
set(handles.figure1,...
  'WindowButtonDownFcn', ...
  'msgbox(''Please set Filter Argument'',''Data-reloading'')');
try
  [data index] = OspFilterDataFcn('makeData',data, filtername, befor_mfile);
catch
  data=[];index=[];
  errordlg(lasterr,filtername);
  OSP_LOG('err',lasterr);
end
delete(befor_mfile);
set(handles.figure1, 'WindowButtonDownFcn',[]);
if isempty(index)
  return; % No FilterDataManage :  Cancel or Error
end

% Renew Data Information
try
  [info,linfo]    = OspFilterDataFcn('getInfo',data);
catch
  info={'Error : In getting information by OspFilterDataFcn', ...
    lasterr};
  OSP_LOG('err',info);
  errordlg(info);
  return;
end
if isempty(info)
  info={' -- No Filter Data -- '};
  OSP_LOG('perr','Error : No information About Filter'); % may be error
  return;
end

% Update Filter-Data Listbox
fi_ln = getFilterInfoLineNo(linfo,index);
set(handles.lbx_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',fi_ln);
setappdata(handles.figure1, 'FILTER_MANAGER',data);
setappdata(handles.figure1,'SAVE_GROUP',true);
lbx_FiltData_Callback(handles.lbx_FiltData, [], handles)

% Change Block-Filter?
if isfield(data,'BlockPeriod') && bpflag==false,
  pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);
end
return;


%------------------------
% ==== Data  Change =====
%------------------------
function psb_removeFiltData_Callback(hObject, eventdata, handles)

% Specify Remove Data
id0   = get(handles.lbx_FiltData,'Value');
linfo = get(handles.lbx_FiltData,'Userdata');
rg    = get(handles.pop_FilterList,'UserData'); % Regions
index=linfo(id0,:); % Remove Data Index
% Get Filter-Management-Data
data   = getappdata(handles.figure1, 'FILTER_MANAGER');

mfdk   = false;
try
  % Remove!
  if index(2)==0 && ...  % Boundary
      index(1)==3,       % Time-Blocking
    mfdk   = true;
    % Special Case (Time-Blocking)
    data=rmfield(data,'BlockPeriod');
    if isfield(data,'TimeBlocking'),
      data=rmfield(data,'TimeBlocking');
    end
    if isfield(data,rg{index(1)}),
      data=rmfield(data,rg{index(1)});
    end
  else
    % Normal : Filter-Data
    data.(rg{index(1)})(index(2))=[];
  end

  % Renew Data Information
  [info,linfo]    = OspFilterDataFcn('getInfo',data);
  if isempty(info)
    info={' -- No Filter Data -- '}; linfo=[];
    OSP_LOG('perr','Error : No information About Filter'); % may be error
    fi_ln=1;
  else
    index(2) = index(2)-1; 
    if index(2)<=-1,index(1)=2;index(2)=0;end
    index(3)=0;
    fi_ln = getFilterInfoLineNo(linfo,index);
  end
  
  % Update Filter-Data Listbox
  set(handles.lbx_FiltData,...
    'String',info, ...
    'Userdata',linfo, ...
    'value',fi_ln);
  setappdata(handles.figure1, 'FILTER_MANAGER',data);
  setappdata(handles.figure1,'SAVE_GROUP',true);
  lbx_FiltData_Callback(handles.lbx_FiltData, [], handles)
catch
  errordlg([' Progrma Error : Remove Disable' lasterr]);
  OSP_LOG('perr','Remove Disable',lasterr);
end

% Time-Block-Filter : Enable
if mfdk,
  pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);
end

return;


function psb_Suspend_Callback(hObject, eventdata, handles)
%------------------------
% Suspend Data
%------------------------
id0   = get(handles.lbx_FiltData,'Value');
linfo = get(handles.lbx_FiltData,'Userdata');
rg    = get(handles.pop_FilterList,'UserData'); % Regions

try
  data   = getappdata(handles.figure1, 'FILTER_MANAGER');
  index=linfo(id0,:);
  if (index(2)==0),
    data.block_enable= ~data.block_enable;
    if (data.block_enable),
      st='Disable';
    else
      st='Enable';
    end
  else
    tmpdata = data.(rg{index(1)});

    if strcmp(tmpdata{index(2)}.enable, 'on')
      tmpdata{index(2)}.enable='off';
      st='Enable';
    else
      tmpdata{index(2)}.enable='on';
      st='Disable';
    end

    % Renew Data Information
    data.(rg{index(1)})=tmpdata;
  end

  info  = OspFilterDataFcn('getInfo',data);
  % Update Filter-Data Listbox
  set(handles.lbx_FiltData, 'String',info);
  setappdata(handles.figure1, 'FILTER_MANAGER',data);
  set(handles.psb_Suspend, 'String', st);
  setappdata(handles.figure1,'SAVE_GROUP',true);
  % for POTATo
  setappdata(handles.figure1,'ActiveDataModSTATE',true);
  % If Filter Kind will be change by Disable/Enalbe
  % pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);
catch
  errordlg([' Progrma Error : Cannot disable' lasterr]);
  OSP_LOG('perr','Remove Disable',lasterr);
end
return;

function psb_changeFiltData_Callback(hObject, eventdata, handles)
% ----------------
% change Filter Data
% ----------------

% Easter Egg ...
setFilterDefInputData(handles);

id0   = get(handles.lbx_FiltData,'Value');
linfo = get(handles.lbx_FiltData,'Userdata');
rg    = get(handles.pop_FilterList,'UserData'); % Regions
data   = getappdata(handles.figure1, 'FILTER_MANAGER');

% --make M-File--
tmp_data = data;
index=linfo(id0,:);
if isfield(data,rg{index(1)}) && index(2)>=1,
  if index(2) <= length(data.(rg{index(1)})),
    tmp_data.(rg{index(1)})(index(2):end)=[];
  end
end

% --make M-File--
for rgidx0=index(1)+1:length(rg),
  if isfield(data, rg{rgidx0}),
    tmp_data = rmfield(tmp_data, rg{rgidx0});
  end
  if strcmpi(rg{rgidx0},'BlockData')
    tmp_data.block_enable=false;
    if isfield(tmp_data,'BlockPeriod')
      tmp_data=rmfield(tmp_data,'BlockPeriod');
    end
  end
end

befor_mfile = get_now_mfile(handles, tmp_data);

try
  index=linfo(id0,:);
  block_period_change = 0;
  if index(2)~=0,
    % Normal Changing method
    % --> Change
    filt_r2 = OspFilterDataFcn('fixData',data.(rg{index(1)}){index(2)},befor_mfile);
    if ~isempty(filt_r2)
      data.(rg{index(1)}){index(2)}=filt_r2;
      if strcmp(filt_r2.name,'Resize Block'),
        block_period_change = 1;
      end
    end
  else
    % for Boundary-Region.
    % now Block Period Only
    if isfield(data,'TimeBlocking'),
      % POTATo : Change According to Special Time-Blocking Plugin
      tmp= OspFilterDataFcn('fixData',data.TimeBlocking{1}, befor_mfile);
      if ~isempty(tmp)
        data.TimeBlocking{1}=tmp;
        bp= tmp.argData.BlockPeriod;
      else
        bp=[];
      end
    else
      % OSP : Original Change Method.
      %       No Special Time-Bloking Plugin.
      if isfield(data,'BlockPeriod')
        bp=data.BlockPeriod;
      else
        bp=[5,15];% Default BlockPeriod
      end
      bp = BlockPeriodInputdlg(bp);
    end
    % Change More ...
    if ~isempty(bp),
      block_period_change = 1;
      data.BlockPeriod = bp;
    end
  end  % end of Change Data

  % if Block Period changed,
  % 14-Jun-2005
  if isfield(data,rg{index(1)}),
    filt_r = data.(rg{index(1)}); % filter data in region.
  else
    filt_r={};
  end

  if block_period_change,
    bp = data.BlockPeriod;
    for idx=index(2)+1:length(filt_r),
      if strcmp(filt_r{idx}.name,'Resize Block'),
        bp2 = filt_r{idx}.argData.BlockPeriod;
        if bp2(1)>bp(1), % pre-stim NG?
          warning('Prestim-time : Changed');
          filt_r{idx}.argData.BlockPeriod(1)=bp(1);
          bp2(1)=bp(1);
        end % pre-stim NG?
        if bp2(2)>bp(2), % post-stim NG?
          warning('Poststim-time : Changed');
          filt_r{idx}.argData.BlockPeriod(2)=bp(2);
          bp2(2)=bp(2);
        end % post-stim NG?
        bp = bp2;
      end % Resize Block?
    end % loop for idx;
    % update
    data.(rg{index(1)})=filt_r;
  end % Block Period changed
catch
  errordlg([' Progrma Error : Change Disable' lasterr]);
  OSP_LOG('perr','Change Disable',lasterr);
end
delete(befor_mfile);

[info , linfo]   = OspFilterDataFcn('getInfo',data);
if isempty(info)
  info={' -- No Filter Data -- '};
  OSP_LOG('perr','Error : No information About Filter'); % may be error
end

% Update Filter-Data Listbox
fi_ln = getFilterInfoLineNo(linfo,index);
set(handles.lbx_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',fi_ln);
setappdata(handles.figure1, 'FILTER_MANAGER',data);
setappdata(handles.figure1,'SAVE_GROUP',true);
lbx_FiltData_Callback(handles.lbx_FiltData, [], handles)
return;


%------------------------
% ==== Order Change =====
%------------------------
function swapFiltData(handles,mv)
% fdlist_h : handle of lbx_FiltData
id0   = get(handles.lbx_FiltData,'Value'); % Selected Line : id0
linfo = get(handles.lbx_FiltData,'Userdata'); % Line Information
rg    = get(handles.pop_FilterList,'UserData'); % Regions
data  = getappdata(handles.figure1, 'FILTER_MANAGER'); % FilterData

% Now Move region is -1 / 1
if mv>0, mv=-1; elseif mv<0, mv=1; else   return;  end

try
  % Selected Line Info
  % ( path of Filter-Data)
  index=linfo(id0,:);

  % Get Swap Data Line :  id2
  %   & that Line Info :  index2
  id1 = id0;
  while 1
    % Check Upper | Lower Data
    id1 = id1+mv;
    index2 = linfo(id1,:);

    % Not Comment? Yes -> Find data:
    %              No  -> Search Next
    if index2(3)==0 && index(2)~=index2(2) break; end
  end

  if index2(2)~=0 && index2(1)==index(1)
    % Region Internal Swap
    % (Region is invariant)
    data.(rg{index(1)})([index(2) index2(2)])=...
      data.(rg{index(1)})([index2(2) index(2)]);
  else
    % Region Swap
    
    % Remove Original Data & set swap data
    swapdata = data.(rg{index(1)}){index(2)};
    data.(rg{index(1)})(index(2))=[];

    % Check Allow Region
    ar      = OspFilterDataFcn('getAllowRegion', ...
      swapdata.name);
    if index2(1)==index(1), % Move to Upper Region?
      % Changeind Region check
      index2(1) = index2(1) -1;
      if isempty((index2(1))==ar)
        error([' Moving Error : Not Allowed Region ' ...
          num2str(index2(1))]);
      end

      if isfield(data,rg{index2(1)}),
        % There is Upper Region-Data

        % Get Upper Region Data
        tmpdata = data.(rg{index2(1)});
        if isempty(tmpdata),
          data.(rg{index2(1)})={swapdata};
        else
          % Add to end
          data.(rg{index2(1)}){end+1}=swapdata;
        end
        index2(2)=length(data.(rg{index2(1)}));
      else
        % No Upper Region-Data
        data.(rg{index2(1)})={swapdata};
        index2(2)= 1;
      end

    else  % Move to Lower Region?
      % Changeind Region check
      if isempty(index2(1)==ar)
        error([' Moving Error : Not Allowed Region ' ...
          num2str(index2(1))]);
      end

      if isfield(data,rg{index2(1)})
        % There is Lower Region
        % Get Lower Region-Data
        tmpdata = data.(rg{index2(1)});
        if ~isempty(tmpdata),
          % Add to top
          data.(rg{index2(1)})={swapdata, tmpdata{:}};
        else
          data.(rg{index2(1)})={swapdata};
        end
      else
        data.(rg{index2(1)})={swapdata};
      end
      index2(2)=1; %  Add to top
    end
  end

  % Information Change
  [info, linfo]    = OspFilterDataFcn('getInfo',data);
  if isempty(info)
    info={' -- No Filter Data -- '};
    OSP_LOG('perr','Error : No information About Filter'); % may be error
  end

  % Update Filter-Data Listbox
  % get moved Filter Data Index
  fi_ln = getFilterInfoLineNo(linfo,index2);
  set(handles.lbx_FiltData,...
    'String',info, ...
    'Userdata',linfo, ...
    'value',fi_ln);
  setappdata(handles.figure1, 'FILTER_MANAGER',data);
  setappdata(handles.figure1,'SAVE_GROUP',true);
  lbx_FiltData_Callback(handles.lbx_FiltData, [], handles)

catch
  errordlg('Cannot Swap : Filter Data ');
  try
    fieldName = rg{index(1)};
  catch
    fieldName = 'Region Get Error';
  end
  OSP_LOG('perr', 'Cannot Swap : Filter Data',...
    lasterr, ...
    ['Filter Manage Field : ' fieldName], ...
    ['ID 1                : ' num2str(id0)], ...
    ['Move                : ' num2str(mv)]);
end
return;

function psb_upFiltData_Callback(hObject, eventdata, handles)
swapFiltData(handles,1);
return;

function psb_downFiltData_Callback(hObject, eventdata, handles)
swapFiltData(handles,-1);
return;

% =============================================
%  Make M-File Before ****
% =============================================
function psb_testplot_Callback(hObject, eventdata, handles)

% Load Data
%fdm         = getappdata(handles.figure1, 'FILTER_MANAGER');
fdm=getFMD(handles.figure1);
if isfield(fdm, 'BlockPeriod'),
  fdm=rmfield(fdm,'BlockPeriod');
end
before_mfile = get_now_mfile(handles, fdm);
[cdata, chdata] = scriptMeval(before_mfile, 'cdata', 'chdata');
delete(before_mfile);
cdataid = getappdata(handles.figure1,'CDATA_ID');
if isempty(cdataid) || (cdataid==0),
  warning('Continuous data selecting Error!');
  cdataid=1;
end
if (cdataid>length(cdata)), cdataid=1; end
if (cdataid==0), errordlg('No data to plot'); return; end
data  = cdata{cdataid};  clear cdata;
hdata = chdata{cdataid}; clear chdata;

ch          = get(handles.pop_channel, 'Value');
strHB.data  = data(:,ch,:); clear data;
strHB.tag   = {};
for idx = 1:size(strHB.data,3),
  if length(hdata.TAGs.DataTag) >= idx,
    strHB.tag{end+1}   = ['Filter of ' hdata.TAGs.DataTag{idx}];
  else
    strHB.tag{end+1}   = ['Filter of --'];
  end
end

% for PCA filter,
% We need other channel data
smpl_pld    = hdata.samplingperiod;
unit = 1000/smpl_pld;

strHB.color = [1 .7 .7; .7 .7 1; .7 .7 .7];
plot_HBdata(handles.axes1, 1, unit,[1:3],strHB);

axes(handles.axes1);
lh=legend;
if ~isempty(lh)
  delete(lh); tag_legend(handles.axes1);
end

return;

function setFilterDefInputData(handles, bp_flg)
% add : 04-Jun-2005
%  Data setting for exchanging or new Filter-Data,
%
% Mod : 07-Jul-2005
%  when bp_flg exist,
%    set Block-Period and set OSP_DATA ...
%
% - Set Data -
%   (where)     (variable name )    ( meaning )
%   OSP_DATA :  'PREPOST_STIM'     : Block Period

if nargin <2,bp_flg=0; end

% Get "Filter Data Manage"
filter_manager  = getappdata(handles.figure1, 'FILTER_MANAGER');
% -- Set Pre-Post Stimulation Data --
% 04-Jun-2005
% Change settiong Block Period.
% Bug: 070530A --> This able Block-Period.
bp=[];
if isfield(filter_manager,'BlockPeriod') && ...
    ~isempty(filter_manager.BlockPeriod)
  bp = filter_manager.BlockPeriod;
  if isfield(filter_manager,'BlockData'),
    for idx=1: length(filter_manager.BlockData),
      if strcmp(filter_manager.BlockData{idx}.name, 'Resize Block'),
        bp=[bp; filter_manager.BlockData{idx}.argData.BlockPeriod];
        bp=min(bp); % even those, last one must be minimum.
      end
    end
  end
  OSP_DATA('SET', 'PREPOST_STIM',bp);
end

if bp_flg, % No Block Period
  if isfield(filter_manager,'block_enable')
    filter_manager.block_enable=true;
  end
  % Bug : 070517A
  %  Auto Blocking :: Change to FilterDef_TimeBlocking
  % --> Add Data-Blocking
  if isempty(bp)
    filData.name='Blocking';
    filData.wrap='FilterDef_TimeBlocking';
    while 1,
      dataxx = P3_PluginEvalScript(filData.wrap,'getArgument',filData);
      if isempty(dataxx)
        h=warndlg('You must set Block Period, here.');
        waitfor(h);
      else
        break;
      end
    end
    bp=dataxx.argData.BlockPeriod;
    OSP_DATA('SET', 'PREPOST_STIM',bp);
    bp=OSP_DATA('GET', 'PREPOST_STIM');
    % fprintf(1,' ** bp set ** \n'); disp(bp);
    filter_manager.BlockPeriod = bp;
    filter_manager.TimeBlocking={dataxx};
  end
  if 1
    % --> Current Values
    val=get(handles.lbx_FiltData,'Value');
    s=get(handles.pop_FilterList,'String');
    s=s{get(handles.pop_FilterList,'Value')};
    
    setFMD(handles.figure1,filter_manager);
    
    pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);
    
    % Reset Values
    set(handles.lbx_FiltData,'Value',val);
    s0=get(handles.pop_FilterList,'String');
    set(handles.pop_FilterList,'Value',find(strcmp(s0,s)));
    
  else    
    setappdata(handles.figure1, 'FILTER_MANAGER', filter_manager);
  end
end



% -- Set Stimulation Period --
sr=getappdata(handles.figure1,'StimulationRange');
OSP_DATA('SET', 'StimulationRange',sr);
% -- Unit --
sp = getappdata(handles.figure1, 'SamplingPeriod');
OSP_DATA('SET','SamplingPeriod',sp);

return;


function [before_mfile, drs_mfile] = get_now_mfile(handles, filterdata)
% get Mfile for filterdata,
actdata = getappdata(handles.figure1, 'LocalActiveData');
if isempty(actdata),
  % -- No Data Select --
  % cf) Mail from Shoji to Mr. Katura
  %      at 21-Jul-2005 09:21
  %     A.1 : Comment out unknown selecting  Data
  %           And make Error
  error(' In makeing Filet : No Effective Data exist.');
  % actdata = OSP_DATA('GET','ACTIVEDATA');
  % if isempty(actdata),
  %  error('File not open');
  % end
end

% remove suspend data
% filterdata.
rg    = get(handles.pop_FilterList,'UserData'); % Regions
for idx=1:length(rg),
  if isfield(filterdata,rg{idx}),
    tmp = filterdata.(rg{idx});
    if ~isfield(tmp,'enable'), break; end
    flg = {tmp.enable};
    flg = strcmp(flg,'off');
    if any(flg),
      tmp(flg)=[];
    end
    filterdata.(rg{idx})=tmp;
  end
end

%===============================
% == Make M-File ==
%===============================
try
  % TO bug fix : Sepcial Case::
  if isfield(actdata,'MultiBlockMode')
    key.actdata = actdata;
    key.filterManage = filterdata;
    fname=DataDef_SignalPreprocessor('make_mfile_useblock',key);
  else
    key.actdata = actdata;
    key.filterManage = filterdata;
    fname=feval(actdata.fcn,'make_mfile', key);
  end
catch
  rethrow(lasterror);
end
before_mfile = fname;

% == Make Data-Reize M-File ==
%===============================
if nargout<2,return;end
% Data_Resize
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter-Data File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_saveFiltData_Callback(hObject, eventdata, handles)
% Save Filter Data

% 0 : OSP - POTATo 3.1.3 
% 1 : POTATo 3.1.4
mod=1;  % <-- by setting?
switch mod
  case 1
    %======================
    % POTAOTo 3.1.4
    %======================
    % Get Filter-Manage Data
    
    % Save-File
    cwd=pwd;
    p0=OSP_DATA('GET','PROJECT');
    if isempty(p0) || ~isfield(p0,'Path') || ~exist(p0.Path,'dir')
      p0=cwd;
    else
      p0=p0.Path;
    end
    
    try
      cd(p0)
      [f,p]= uiputfile({'*.mat','P3 Recipe File(*.mat)'},'Save Recipe');
      if isequal(f,0) || isequal(p,0),
        cd(cwd);return;
      end
    catch
      cd(cwd);
      errordlg({'Could not get Save-File-Name',['  ' lasterr]});
      return;
    end
    cd(cwd);
    fname=[p filesep f];
    
    % Get Save Data
    if 1
      % With 1st-Lve-Ana
      Filter_Manager=getFMD(handles.figure1,false,true);
    else
      % (Delete : 1st-Lve-Ana)
      Filter_Manager=getFMD(handles.figure1,false,false);
    end
    
    Version=1;
    Name   ='P3-Recipe';
    
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(fname,'Filter_Manager','Version','Name','-v6');
    else
      save(fname,'Filter_Manager','Version','Name');
    end 
    if 0,disp(Filter_Manager);disp(Version);disp(Name);end
    
  case 0
    %======================
    % POTATo 3.1.3
    %======================
    DataDef_FilterData('NewFilter',getappdata(handles.figure1, 'FILTER_MANAGER'));
  otherwise
    errordlg({...
      'Undefined Save-Mode : '...
      ['   ' mfilename ' : $Revision: 1.49 $']},'Recipe Save Error');
end
return;

function psb_loadFilterData_Callback(hObject, eventdata, handles)
% Load Filter Data

% 0 : OSP - POTATo 3.1.3 
% 1 : POTATo 3.1.4
mod=1;  % <-- by setting?
switch mod
  case 1
    % Load File
    cwd=pwd;
    p0=OSP_DATA('GET','PROJECT');
    if isempty(p0) || ~isfield(p0,'Path') || ~exist(p0.Path,'dir')
      p0=cwd;
    else
      p0=p0.Path;
    end
    
    try
      cd(p0);
      while 1
        [f,p]= uigetfile({'*.mat','P3 Recipe File(*.mat)'},'Load Recipe');
        if isequal(f,0) || isequal(p,0),
          cd(cwd);return;
        end
        fname=[p filesep f];
        % Filter_Manager Version Name
        try
          s=load(fname);
          if ~isfield(s,'Filter_Manager')
            error('Out of Recipe Format');
          end
          break;
        catch
          errordlg({' Load Error : ',['   ' lasterr]},'Load Recipe Error:');
        end
      end
    catch
      cd(cwd);
      errordlg({'Could not get Load-File-Name',['  ' lasterr]});
      return;
    end
    cd(cwd);

    % Set up
    setFMD(handles.figure1,s.Filter_Manager);
  case 0
    ini_actdata = OSP_DATA('GET','ACTIVEDATA'); % swapping.
    set(handles.figure1,'Visible','off');
    try
      fs_h = uiFileSelect('DataDef',{'FilterData'});
      waitfor(fs_h);
    catch
      set(handles.figure1,'Visible','on');
      rethrow(lasterror);
    end
    set(handles.figure1,'Visible','on');

    actdata = OSP_DATA('GET','ACTIVEDATA');
    OSP_DATA('SET','ACTIVEDATA',ini_actdata);
    % Cancel Check
    if isempty(actdata), return; end
    % Set up
    setFMD(handles.figure1,actdata.data.data);
end

% Set Save-Flag 
setappdata(handles.figure1,'SAVE_GROUP',true);
% for POTATo
setappdata(handles.figure1,'ActiveDataModSTATE',true);
% ==> Remove 1st Lvl ==>
if 0
  str=get(handles.pop_FilterDispKind,'String');
  str=str{get(handles.pop_FilterDispKind,'Value')};
  if ~strcmpi('1st-Lvl-Ana',str),
    fmd=getFMD(handles.figure1,false);
    setFMD(handles.figure1,fmd);
  end
end
return;

