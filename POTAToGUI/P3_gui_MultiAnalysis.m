function varargout=P3_gui_MultiAnalysis(fcn, varargin)
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
% Original author : Masanori Shoji
% create : 2007.04.19
%
% $Id: P3_gui_MultiAnalysis.m 293 2012-09-27 06:11:14Z Katura $
%
% Reversion 1.1 :
%   OspFilterCallbacks

if nargin<=0,OspHelp(mfilename);return;end

switch fcn
  case 'set'
    % Set Multi Processing Functions
    %==========================
    hObject=varargin{1};
    mpf=varargin{2};
    hs=guidata(hObject);
    setMPF(hObject,mpf);
    pop_MLT_MPP_Type_Callback(hs);

  case 'get'
    % Get Multi Processing Functions
    %==========================
    
    % Get Figure Handle
    if nargin<2, 
      hObject=gcbf;
    else
      hObject=varargin{1};
    end
    
    % Get Remove Flag
    rm_flag=1;
    if nargin>=3, rm_flag=varargin{2};end
    
    % Execute FMD
    mpf=getMPF(hObject,rm_flag);
    varargout{1}=mpf;

  case 'LocalActiveDataOn',
    % Enable to use MLT
    %==========================
    handles=varargin{1};
    hs = [handles.pop_MLT_FilterList, ...
      handles.psb_MLT_Add, ...
      handles.psb_MLT_Remove, ...
      handles.lbx_MLT_FiltData, ...
      handles.psb_MLT_Change, ...
      handles.psb_MLT_Suspend, ...
      handles.psb_MLT_Up, ...
      handles.psb_MLT_Down];
    set(hs, 'enable', 'on');
    
  case 'LocalActiveDataOff',
    handles=varargin{1};
    hs = [handles.pop_MLT_FilterList, ...
      handles.psb_MLT_Add, ...
      handles.psb_MLT_Remove, ...
      handles.lbx_MLT_FiltData, ...
      handles.psb_MLT_Change, ...
      handles.psb_MLT_Suspend, ...
      handles.psb_MLT_Up, ...
      handles.psb_MLT_Down];

    set(hs, 'enable', 'off');
  case {'pop_MLT_FilterList_CreateFcn',...
      'pop_MLT_FilterList_Callback',...
      'pop_MLT_MPP_Type_CreateFcn',...
      'pop_MLT_MPP_Type_Callback',...
      'psb_MLT_Add_Callback','psb_MLT_Change_Callback',...
      'psb_MLT_Up_Callback','psb_MLT_Down_Callback',...
      'psb_MLT_Remove_Callback',...
      'psb_MLT_Suspend_Callback',...
      'ckb_MLT_FileMode_Callback',...
      'psb_MLT_Help_Callback',...
      'lbx_MLT_FiltData_Callback',...
      'psb_MLT_Save_Callback',...
      'psb_MLT_Load_Callback'}
    % OK Function
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  otherwise,
    error('Unpopulated Function : %s',fcn);
end
if any(strcmpi(fcn,{,...
    'psb_MLT_Add_Callback','psb_MLT_Change_Callback',...
    'psb_MLT_Up_Callback','psb_MLT_Down_Callback',...
    'psb_MLT_Remove_Callback',...
    'psb_MLT_Suspend_Callback'}))
  handles=varargin{1};
  setappdata(handles.figure1,'ActiveDataModSTATE',true);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In Application data 'MULTI_PROCESSING_FUNCTIONS'
%    Change Definition : since revision 1.20
% --> This Function is I/O function of the data
%    There is bug : for Block-Filter Enable/Disable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mpf=getMPF(fig_h,rm_flag)
% Get Filter-Manage-Data to use/save.
%
%   FIG_H    : Handle of Figure.
%
%   RM_FLAG  : Remove Disable Function or not.
%              This function do not work.
%              -- onlys for compatibility --
%              ==> Make-Mfile work well now.
%=============================================

%--------------------------------------
% Get Filter-Manage-Data (Raw)
%--------------------------------------
mpf=getappdata(fig_h,'MULTI_PROCESSING_FUNCTIONS');
hs=guidata(fig_h);
if isempty(mpf) && ~isstruct(mpf), return;end
mpf.FileIOMode=get(hs.ckb_MLT_FileMode,'Value');


%--------------------------------------
% Set Default Arguments
%--------------------------------------
if (nargin<=1), rm_flag=true; end
if rm_flag,return;end
%--------------------------------------
% Remove Enable-Field
%--------------------------------------
% --> Removed Function <--

function setMPF(fig_h,mpf)
%-----------------------
% Set Filter Manage Data
%   with Enable Flag, default value is on.
%-----------------------

% Setting Enable flag
if isempty(mpf),
  % Reset to Empty, return;
  clear mpf;
  mpf.default={};
end
handles = guidata(fig_h);
% 

%~~~~~~~~~~~~~~~~~~~~
% Version Transfer
%~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~
% change view
%~~~~~~~~~~~~~~~~~~~~~
if isfield(mpf,'FileIOMode')
  set(handles.ckb_MLT_FileMode,'Value',mpf.FileIOMode);
else
  set(handles.ckb_MLT_FileMode,'Value',0);
end

setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',mpf);
[info,linfo] = P3_MultiProcessingFunction('getInfo',mpf);
if isempty(info)
  set(handles.lbx_MLT_FiltData,'String','-- No Recipe --');
  OSP_LOG('perr','Error : No information About Filter'); % may be
  return;
end
set(handles.lbx_MLT_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',1);
lbx_MLT_FiltData_Callback(handles);
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filter Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================
function pop_MLT_MPP_Type_CreateFcn(h)
% Definition of MPP Types
%==========================================
try
  p3ash=P3('getStatusHandle');
  if ~isempty(p3ash) && ishandle(p3ash)
    set(p3ash,'String',{'Multi-Mode : Create MPP-Type'});
    POTATo_About;
  end

  %  Load Disp Kind 
  DefineOspFilterDispKind;
  % Load Multi Plugin
  MPPL = P3_MultiProcessingFunction('getList');
  
  % Load Filter Plugin
  [FilterList, Regions, DispKind] = OspFilterDataFcn('getList');
  % Delete 1st-Lvl-Ana
  d=find(bitand(DispKind,F_1stLvlAna0));
  FilterList(d)=[];DispKind(d)=[];
  
  if isempty(FilterList)
    error(' No Fiter Data Available');
  end

  % Default - Strings
  str={'All Filter', ...
    'General', ...
    'Time Series', ...
    'Flag', ...
    'Data Change', ...
    'Control'};
  if isempty(MPPL)
    ud.FilterList= FilterList;
    ud.Regions = Regions;
    ud.DispKind= DispKind;
    warning(' No Multi-Fiter Data Available');
  else
    ud.FilterList= {MPPL(:).name FilterList{:}};
    ud.Regions = {Regions,'Cell-Raw','Cell-Block'};
    ud.DispKind= [ [MPPL.type] DispKind(:)'];
    % --> Add Type
    str={str{1}, 'Multi-Processing', str{2:end}};
  end
  
  % Book Mark
  set(h, 'Value',1,'String',str,'UserData',ud);
catch
  errordlg(lasterr);
  OSP_LOG('err',' MPP Type Setting Error:');
end
return;

function pop_MLT_MPP_Type_Callback(hs)
% Change Recipe Type.

DefineOspFilterDispKind;
h=hs.pop_MLT_MPP_Type;
vl=get(h,'Value');st=get(h,'String');
rtype=st{vl}; clear vl st; % Get Recipe-Type
ud=get(h,'UserData'); % Load User-Data

% === Modifyed For POTATo ===
switch rtype,
  case 'All Filter',
    %---------------------------
    % Check is Potato running?
    %--------------------------
    useflg = true(size(ud.DispKind));
  case 'General',
    useflg=find( bitand(ud.DispKind,F_General) );
  case 'Multi-Processing'
    useflg=find( bitand(ud.DispKind,F_MultAna) );
  case 'Time Series',
    useflg=find( bitand(ud.DispKind,F_TimeSeries) );
  case 'Flag',
    useflg=find( bitand(ud.DispKind,F_Flag) );
  case 'Data Change',
    useflg=find( bitand(ud.DispKind,F_DataChange) );
  case 'Control',
    useflg=find( bitand(ud.DispKind,F_Control) );
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

set(hs.pop_MLT_FilterList,...
  'Visible','on',...
  'Value',1, ...
  'String',ud.FilterList(useflg),  ...
  'Enable','on', ...
  'UserData',ud);
pop_MLT_FilterList_Callback(hs);
return;

function pop_MLT_FilterList_CreateFcn(hObject)
% ----------------
% Read Filter List
% ----------------
% --> Comment Out :: Start-up Value is Set by 
%     "pop_MLT_MPP_Type_Callback"
set(hObject,...
  'Callback',...
  'P3_gui_MultiAnalysis(''pop_MLT_FilterList_Callback'',guidata(gcbo));',...
  'Value',1,'String','Deinitialize');

function [fp, fname, ftype]=pop_MLT_FilterList_Callback(hs,gflag)
% Chage/Get Filter-Function.
%--------------------------------------
% Change MLT-Filter-Function
% - - - - - - - - - - - - - - - - - - -
% Syntax :  
%  pop_MLT_FilterList_Callback(hs);
%    hs : Hnadles of the GUI (GUIDATA)
%--------------------------------------
% Get Infromation of MLT-Filter-Function
% - - - - - - - - - - - - - - - - - - -
% Syntax :  
%  [fp, fname, ftype] = pop_MLT_FilterList_Callback(hs,true);
%    fp    : Function-Pointer of Function-Control
%    fname : Function-Name
%    ftype : Type of File
%--------------------------------------
persistent ftype0 fp0 fname0;
% Get Data
if nargin>=2 && gflag==true && ~isempty(ftype0)
  ftype=ftype0;fp=fp0;fname=fname0;
  return;
end
% Reset Data

% Checking Type
DefineOspFilterDispKind;
id = get(hs.pop_MLT_FilterList,'Value');
ud = get(hs.pop_MLT_FilterList,'UserData');
fn = get(hs.pop_MLT_FilterList,'String');
fname0 = fn{id};
ftype0 = ud.DispKind(id);
% is Multi Function?
if bitand(ftype0,F_MultAna)==F_MultAna
  fp0=@P3_MultiProcessingFunction;
else
  fp0=@OspFilterDataFcn;
end
% Set Return Value
ftype=ftype0;fp=fp0;

%--> Help
%feval(fp,'FuncHelp',fname0);
psb_MLT_Help_Callback(hs);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Filter <--> Recipe I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======================================
function psb_MLT_Help_Callback(handles)
%  Help of Filter Data
%======================================
v=get(handles.psb_MLT_Help,'Value');
if v
  [fp,filtername]= pop_MLT_FilterList_Callback(handles,true);
  feval(fp,'FuncHelp',filtername);
else
  uihelp([],'close');
end

%======================================
function psb_MLT_Add_Callback(handles)
%  Add Data
%======================================

% ------------
% get Current Filter
% ------------
[fp,filtername]= pop_MLT_FilterList_Callback(handles,true);

% -----------
% get Recipe
% ------------
data   = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');

% Region Check : off

% ------------
% Make M-File
% ------------
befor_mfile = get_now_mfile(handles, data);

% Lock GUI
wbdf=set(handles.figure1,'WindowButtonDownFcn');
set(handles.figure1,...
  'WindowButtonDownFcn', ...
  'msgbox(''Please set Filter Argument'',''Data-reloading'')');
try
  [data index] = P3_MultiProcessingFunction('makeData',data, filtername, befor_mfile);
catch
  data=[];index=[];
  errordlg(lasterr);
  OSP_LOG('err',lasterr);
end
delete(befor_mfile);
set(handles.figure1, 'WindowButtonDownFcn',wbdf);
if isempty(index)
  return; % No FilterDataManage :  Cancel or Error
end

% ------------------------
% Renew Recipe Information
% ------------------------
try
  [info,linfo]    = P3_MultiProcessingFunction('getInfo',data);
catch
  info={'Error : In getting information by P3_MultiProcessingFunction', ...
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
set(handles.lbx_MLT_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',fi_ln);
setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',data);
setappdata(handles.figure1,'SAVE_GROUP',true);
lbx_MLT_FiltData_Callback(handles)

% Change Block-Filter?
if isfield(data,'BlockPeriod') && bpflag==false,
  pop_FilterDispKind_Callback(handles.pop_FilterDispKind,[],handles);
end
return;


%------------------------
% ==== Data  Change =====
%------------------------
function psb_MLT_Remove_Callback(handles)

% Specify Remove Data
id0   = get(handles.lbx_MLT_FiltData,'Value');
linfo = get(handles.lbx_MLT_FiltData,'Userdata');
rg    = P3_MultiProcessingFunction('Regions');
%rg    = get(handles.pop_MLT_FilterList,'UserData'); % Regions
index=linfo(id0,:); % Remove Data Index
% Get Filter-Management-Data
data   = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');

try
  % Remove!

  % Normal : Filter-Data
  tmpdata = getfield(data,rg{index(1)});
  tmpdata(index(2)) = [];
  data = setfield(data,rg{index(1)},tmpdata);

  % Renew Data Information
  [info,linfo]    = P3_MultiProcessingFunction('getInfo',data);
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
  set(handles.lbx_MLT_FiltData,...
    'String',info, ...
    'Userdata',linfo, ...
    'value',fi_ln);
  setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',data);
  setappdata(handles.figure1,'SAVE_GROUP',true);
  lbx_MLT_FiltData_Callback(handles)
catch
  errordlg([' Progrma Error : Remove Disable' lasterr]);
  OSP_LOG('perr','Remove Disable',lasterr);
end

return;



%------------------------
% ==== Data  Select =====
%------------------------
function lbx_MLT_FiltData_Callback(handles)
% ----------------
%  Update related Button Enable
% ----------------

data  = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');
linfo = get(handles.lbx_MLT_FiltData,'Userdata');
id0   = get(handles.lbx_MLT_FiltData,'Value');
rg    = P3_MultiProcessingFunction('Regions');

enable_h  =[];
disable_h =[];

% Set Enable / Disable
if isempty(linfo) || linfo(id0,2)==0
  % Boundary of Data Region
  disable_h =[handles.psb_MLT_Remove; ...
    handles.psb_MLT_Down; ...
    handles.psb_MLT_Change; ...
    handles.psb_MLT_Suspend; ...
    handles.psb_MLT_Up];
else
  % not Boundary of Data Region
  index = linfo(id0,:);
  % Get Selected Filter Data
  rgdata = eval(['data.' rg{index(1)} ';']);
  fdata0 = rgdata{index(2)}; % Filter Data!

  % * Remove Button & Change
  enable_h = [enable_h; ...
    handles.psb_MLT_Remove;...
    handles.psb_MLT_Suspend; ...
    handles.psb_MLT_Change];

  if isfield(fdata0,'enable'),
    if strcmp(fdata0.enable, 'on')
      set(handles.psb_MLT_Suspend, 'String', 'Disable');
    else
      set(handles.psb_MLT_Suspend, 'String', 'Enable');
    end
  end

  % * Up
  if index(2)==1 
    disable_h =[disable_h; handles.psb_MLT_Up];
  else
    enable_h = [enable_h; handles.psb_MLT_Up];
  end

  % * Down
  if index(2) == length(rgdata)
    disable_h =[disable_h; handles.psb_MLT_Down];
  else
    enable_h = [enable_h; handles.psb_MLT_Down];
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

if get(handles.psb_MLT_Help,'Value')>=1
  if strcmpi(get(handles.psb_MLT_Suspend,'Enable'),'on')
    %index = linfo(id0,:);
    % Get Selected Filter Data
    [fp,filtername]= pop_MLT_FilterList_Callback(handles,true);
    feval(fp,'FuncHelp',filtername);
    %fdata = data.(rg{index(1)}){index(2)};
    %feval(fdata.wrap,'FuncHelp',fdata.name);
  end
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

function psb_MLT_Suspend_Callback(handles)
%------------------------
% Suspend Data
%------------------------
id0   = get(handles.lbx_MLT_FiltData,'Value');
linfo = get(handles.lbx_MLT_FiltData,'Userdata');
rg    = P3_MultiProcessingFunction('Regions');

try
  data   = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');
  index=linfo(id0,:);
  tmpdata = getfield(data,rg{index(1)});
  
  if strcmp(tmpdata{index(2)}.enable, 'on')
    tmpdata{index(2)}.enable='off';
    st='Enable';
  else
    tmpdata{index(2)}.enable='on';
    st='Disable';
  end

  % Renew Data Information
  data = setfield(data,rg{index(1)},tmpdata);

  info  = P3_MultiProcessingFunction('getInfo',data);
  % Update Filter-Data Listbox
  set(handles.lbx_MLT_FiltData, 'String',info);
  setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',data);
  set(handles.psb_MLT_Suspend, 'String', st);
  % for POTATo
  setappdata(handles.figure1,'ActiveDataModSTATE',true);
catch
  errordlg([' Progrma Error : Cannot disable' lasterr]);
  OSP_LOG('perr','Remove Disable',lasterr);
end
return;

function psb_MLT_Change_Callback(handles)
% ----------------
% change Filter Data
% ----------------

% Easter Egg ...
setFilterDefInputData(handles);

id0   = get(handles.lbx_MLT_FiltData,'Value');
linfo = get(handles.lbx_MLT_FiltData,'Userdata');
rg    = P3_MultiProcessingFunction('Regions');
%rg    = get(handles.pop_MLT_FilterList,'UserData'); % Regions
data   = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');

% --make M-File--
tmp_data = data;
index=linfo(id0,:);
if isfield(data,rg{index(1)}) && index(2)>=1,
  tmp_data_r = data.(rg{index(1)}); % filter data in region.
  if index(2) <= length(tmp_data_r),
    tmp_data_r(index(2):end)=[];
    tmp_data.(rg{index(1)})= tmp_data_r;
  end
end

for rgidx0=index(1)+1:length(rg),
  if isfield(data, rg{rgidx0}),
    tmp_data = rmfield(tmp_data, rg{rgidx0});
  end
end
befor_mfile = get_now_mfile(handles, tmp_data);

try
  index=linfo(id0,:);
  block_period_change = 0;
  if index(2)~=0,
    % Normal Changing method
    filt_r = data.(rg{index(1)}); % filter data in region.
    % --> Change
    filt_r2 = P3_MultiProcessingFunction('fixData',filt_r{index(2)}, befor_mfile);
    if ~isempty(filt_r2)
      filt_r{index(2)}=filt_r2;
      data.(rg{index(1)})= filt_r;
      if strcmp(filt_r2.name,'Resize Block'),
        block_period_change = 1;
      end
    end
  else
    % for Boundary-Region.
    % now Block Period Only
    if isfield(data,'TimeBlocking'),
      % POTATo : Change According to Special Time-Blocking Plugin
      tmp= P3_MultiProcessingFunction('fixData',data.TimeBlocking{1}, befor_mfile);
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
  end,  % end of Change Data

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
    data.(rg{index(1)})= filt_r;
  end % Block Period changed
catch
  errordlg([' Progrma Error : Change Disable' lasterr]);
  OSP_LOG('perr','Change Disable',lasterr);
end
delete(befor_mfile);

[info , linfo]   = P3_MultiProcessingFunction('getInfo',data);
if isempty(info)
  info={' -- No Filter Data -- '};
  OSP_LOG('perr','Error : No information About Filter'); % may be error
end

% Update Filter-Data Listbox
fi_ln = getFilterInfoLineNo(linfo,index);
set(handles.lbx_MLT_FiltData,...
  'String',info, ...
  'Userdata',linfo, ...
  'value',fi_ln);
setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',data);
setappdata(handles.figure1,'SAVE_GROUP',true);
lbx_MLT_FiltData_Callback(handles)
return;


%------------------------
% ==== Order Change =====
%------------------------
function swapFiltData(handles,mv)
% fdlist_h : handle of lbx_MLT_FiltData
id0   = get(handles.lbx_MLT_FiltData,'Value'); % Selected Line : id0
linfo = get(handles.lbx_MLT_FiltData,'Userdata'); % Line Information
%rg    = get(handles.pop_MLT_FilterList,'UserData'); % Regions
rg    = P3_MultiProcessingFunction('Regions');
data  = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS'); % FilterData

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
    tmpdata = data.(rg{index(1)});
    tmpdata([index(2) index2(2)]) = tmpdata([index2(2) index(2)]);
    data.(rg{index(1)})= tmpdata;
  else
    % Region Swap

    % Remove Original Data & set swap data
    tmpdata = data.(rg{index(1)});
    swapdata = tmpdata{index(2)};
    tmpdata(index(2)) = [];
    % Original Region Update!
    data.(rg{(index(1))})=tmpdata;

    % Check Allow Region
    ar      = P3_MultiProcessingFunction('getAllowRegion', ...
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
          tmpdata = {swapdata};
        else
          % Add to end
          tmpdata{end+1} = swapdata;
        end
        index2(2)=length(tmpdata);
      else
        % No Upper Region-Data
        tmpdata  = {swapdata};
        index2(2)= 1;
      end
      data.(rg{index2(1)})=tmpdata;

    else, % Move to Lower Region?
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
          tmpdata = {swapdata, tmpdata{:}};
        else
          tmpdata = {swapdata};
        end
      else
        tmpdata = {swapdata};
      end
      index2(2)=1; %  Add to top
      data.(rg{index2(1)}) =tmpdata;
    end
  end

  % Information Change
  [info, linfo]    = P3_MultiProcessingFunction('getInfo',data);
  if isempty(info)
    info={' -- No Filter Data -- '};
    OSP_LOG('perr','Error : No information About Filter'); % may be error
  end

  % Update Filter-Data Listbox
  % get moved Filter Data Index
  fi_ln = getFilterInfoLineNo(linfo,index2);
  set(handles.lbx_MLT_FiltData,...
    'String',info, ...
    'Userdata',linfo, ...
    'value',fi_ln);
  setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS',data);
  setappdata(handles.figure1,'SAVE_GROUP',true);
  lbx_MLT_FiltData_Callback(handles)

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

function psb_MLT_Up_Callback(handles)
swapFiltData(handles,1);
return;

function psb_MLT_Down_Callback(handles)
swapFiltData(handles,-1);
return;

% =============================================
%  Make M-File Before ****
% =============================================
function psb_testplot_Callback(handles)

% Load Data
%fdm         = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');
fdm=getMPF(handles.figure1);
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
    strHB.tag{end+1}   = 'Filter of --';
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
filter_manager  = getappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS');
% -- Set Pre-Post Stimulation Data --
% 04-Jun-2005
% Change settiong Block Period.
if isfield(filter_manager,'BlockPeriod') && ...
    ~isempty(filter_manager.BlockPeriod),
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

elseif bp_flg, % No Block Period
  % --> Add Data-Blocking
  bp=[];
  while 1,
    bp = BlockPeriodInputdlg;
    if isempty(bp),
      h=warndlg('You must set Block Period, here.');
      waitfor(h);
    else
      break;
    end
  end
  OSP_DATA('SET', 'PREPOST_STIM',bp);
  bp=OSP_DATA('GET', 'PREPOST_STIM');
  % fprintf(1,' ** bp set ** \n'); disp(bp);
  filter_manager.BlockPeriod = bp;
  setappdata(handles.figure1, 'MULTI_PROCESSING_FUNCTIONS', filter_manager);
end

% -- Set Stimulation Period --
sr=getappdata(handles.figure1,'StimulationRange');
OSP_DATA('SET', 'StimulationRange',sr);
% -- Unit --
sp = getappdata(handles.figure1, 'SamplingPeriod');
OSP_DATA('SET','SamplingPeriod',sp);

return;


function before_mfile = get_now_mfile(handles, filterdata)
% get Mfile for filterdata,
actdata = getappdata(handles.figure1, 'LocalActiveData');
if isempty(actdata),
  % -- No Data Select --
  % cf) Mail from Shoji to Mr. Katura
  %      at 21-Jul-2005 09:21
  %     A.1 : Comment out unknown selecting  Data
  %           And make Error
  error(' In makeing Filet : No Effective Data exist.');
end

% remove suspend data
% filterdata.
rg    = P3_MultiProcessingFunction('Regions');
for idx=1:length(rg),
  if isfield(filterdata,rg{idx}),
    tmp = eval(['filterdata.' rg{idx} ';']);
    if ~isfield(tmp,'enable'), break; end
    flg = {tmp.enable};
    flg = strcmp(flg,'off');
    if any(flg),
      tmp(flg)=[];
    end
    eval(['filterdata.' rg{idx} '= tmp;']);
  end
end

% == Make M-File ==
try
  key.actdata = actdata;
  key.fname   = '';
  key.Recipe  = filterdata;
  fname=feval(actdata.fcn,'make_mfile', key);
catch
  rethrow(lasterror);
end
before_mfile = fname;

return;

function ckb_MLT_FileMode_Callback(figh)
setappdata(figh,'ActiveDataModSTATE',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multi-Recipe File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_MLT_Save_Callback(handles)
% Save Multi-Proecssing Recipe

% Get Save Data
MultiRecipe=getMPF(handles.figure1);
Version=1;
Name   ='P3-Multi-Recipe';
try
  actdata = getappdata(handles.figure1, 'LocalActiveData');
  f0=['M_Recipe_' actdata.data.Tag '.mat'];
catch
  f0={'*.mat','P3 Recipe File(*.mat)'};
end

% get Save-FileName
[f,p]=osp_uiputfile(f0,'Save Recipe');
if isequal(f,0) || isequal(p,0),return;end
fname=[p filesep f];

% Save
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,'MultiRecipe','Version','Name','-v6');
else
  save(fname,'MultiRecipe','Version','Name');
end
if 0,disp(MultiRecipe);disp(Version);disp(Name);end

return;

function psb_MLT_Load_Callback(handles)
% Load Multi-Proecssing Recipe
% Get Save Data
try
   actdata = getappdata(handles.figure1, 'LocalActiveData');
  f0=['M_Recipe_' actdata.data.Tag '.mat'];
catch
  f0={'*.mat','P3 Recipe File(*.mat)'};
end
[f,p]=osp_uigetfile(f0,'Save Recipe');
if isequal(f,0) || isequal(p,0),return;end
fname=[p filesep f];

s=load(fname);
msg={};
if ~isfield(s,'MultiRecipe')
  msg{end+1}='Out of Recipe Format';
end
if ~isempty(msg),errordlg(msg);return;end

% Set
setMPF(handles.figure1,s.MultiRecipe);
setappdata(handles.figure1,'SAVE_GROUP',true);
setappdata(handles.figure1,'ActiveDataModSTATE',true);
return;

