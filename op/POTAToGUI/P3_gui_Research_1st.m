function varargout=P3_gui_Research_1st(fcn, varargin)
% P3: Research-Mode, 1st Status GUI Control
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
% create : 2010.11.05
%
% $Id: P3_gui_Research_1st.m 310 2013-02-22 09:43:19Z Katura $
%
% 2010.11.10 : New! (2010_2_RA03)
% 2010.12.06 : Change term
%              Sumarized-Data -> Summary Stastic
% 2010.12.07 : Add Save/Load/Help Button

if nargin<=0,OspHelp(mfilename);return;end

switch fcn
  case {'create_win','myHandles',...
      'tgl_R1st_New_Callback','tgl_R1st_Edit_Callback',...
      'tgl_R1st_Lock_Callback',...
      'pop_R1st_ExecuteName_Callback',...
      'psb_R1st_FcnArgSave_Callback',...
      'psb_R1st_FcnArgLoad_Callback',...
      'psb_R1st_FcnHelp_Callback',...
      'pop_R1st_SummarizedDataList_Callback',...
      'psb_R1st_Save_Callback',...
      'psb_R1st_Change_Callback',...
      'psb_R1st_Remove_Callback',...
      'psb_R1st_Copy_Callback',...
      'psb_R1st_TextOut_Callback',...
      'lbx_R1st_fileList_Callback',...
      'mnu_R1st_SMD2ANA_Callback',...
      'mnu_R1st_ANA2SMD_Callback',...
      'ext_search',...
      'disable_execution',...
      'makeSSReal0',...
      'psb_R1st_ChangeComment_Callback',...
      }
    % Enable 
    try
      if all(~strcmpi(fcn,{...
          'psb_R1st_ChangeComment_Callback',...
          'psb_R1st_FcnArgSave_Callback',...
          'psb_R1st_FcnArgLoad_Callback',...
          'psb_R1st_FcnHelp_Callback',...
          'tgl_R1st_Lock_Callback',...
          'disable_execution',...
          'makeSSReal0','create_win'...
          }))
        enable_execution(varargin{1});
      end
    catch
    end
    % Execute OK Function
    try
      if nargout,
        [varargout{1:nargout}] = feval(fcn, varargin{:});
      else
        feval(fcn, varargin{:});
      end
    catch
      rethrow(lasterror)
    end
  case ''
    % Now not Execute
    return;
  case {'psb_R1st_RecipeCheck_Callback','enable_execution'}
    % Inner Function (for Debug purpose)
    disp(C__FILE__LINE__CHAR);
    error('Forbidden Callback: %s is inner function',fcn);
  otherwise,
    disp(C__FILE__LINE__CHAR);
    error('Not Implemented Function : %s',fcn);
end

% set Modified Flag (None)
if any(strcmpi(fcn,{,...
    }))
  handles=varargin{1};
  setappdata(handles.figure1,'ActiveDataModSTATE',true);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI & Handles Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function hs=create_win(hs)
% Make GUI for Research Pre Multi-Data
% Upper Link : POTATo_win_Research_1st/Activate
%==========================================================================

%-----------------------
% Setting 
%-----------------------
c=get(hs.figure1,'Color');
c2=ones([1,3])*0.7529;
prop_t={'style','text','Units','pixels',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c,'Visible','off'};
prop={'Units','pixels','Visible','off'};
prop_b={prop{:},...
  'style','pushbutton',...
  'BackgroundColor',[0.8 0.4 0.4],'ForegroundColor',[1 1 1]};
prop_b2={prop{:},...
  'style','pushbutton',...
  'BackgroundColor',[0.4 0.4 0.8],'ForegroundColor',[1 1 1]};

xsize0=360;  % Width of Area
xsizel=160;  % Width of Left Area
sx0=410; % start x (with indent 0)
sx1=414; % start x (with indent 1)
ix=10;    % Interval of x
iy= 3;    % Interval of y

%----------------------------
% Make GUI
%----------------------------
% Title
y=449;dy=19; xsize=0;
% tag='txt_R1st_title';
% hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
%   'String','',...
%   'Position',[sx0 y xsize dy]);

tag='tgl_R1st_New';
sx3=sx0+xsize+ix;
xsize = (xsize0-(sx3-sx1)-ix-ix)/3;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','toggle','BackgroundColor',c2,...
  'String','New','Value',1,...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

tag='tgl_R1st_Edit';
sx3=sx3+xsize;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','toggle','BackgroundColor',c2,...
  'String','Edit','Value',0,...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

tag='tgl_R1st_Lock';
sx3=sx3+xsize+ix;
xsize=17;dy=17;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','toggle','BackgroundColor',c2,...
  'String','','Value',0,...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
tgl_R1st_Lock_Callback(hs);

% Status Change Button 2010_RC02-1

% Summarized Data-List
%- - - - - - - - - - - -
dy=20;y=420; xsize=xsizel;
sx3=sx1+xsize+ix;
tag='txt_R1st_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Summary Stastic List',...
  'Position',[sx1 y xsize dy]);
tag='txt_R1st_DataName';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Summary Stastic Data-Name:',...
  'Position',[sx1 y xsize dy]);

%dy=20; y=y-dy-iy; 
tag='pop_R1st_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'No Summary Stastic Data'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
tag='edt_R1st_DataName';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','edit','BackgroundColor',[1 1 1],...
  'String','Untitled','HorizontalAlignment','left',...
  'Position',[sx3 y xsize dy]);

% Comment
dy=20; y=y-dy-iy;xsize=xsizel;
tag='txt_R1st_Comment';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Comment:',...
  'Position',[sx1 y xsize dy]);
tag='psb_R1st_ChangeComment';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','Change Comment',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
tag='edt_R1st_Comment';
xsize=xsize0;
dy=40; y=y-dy;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','edit','BackgroundColor',[1 1 1],...
  'Max',10,'HorizontalAlignment','left',...
  'String',{'This Data is for Test','','xx'},...
  'Position',[sx1 y xsize dy]);

% Execute Popup
%- - - - - - - - - - - -
dy=250; xsize=xsize0;y=y-iy;
tag='frm_R1st_Execution';
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','frame','Position',[sx1 y-dy xsize dy]);
errpos=[sx1+1 y-dy+1 xsize-2 dy-40-2*iy-2];

dy=20;y=y-dy-iy;
sx2=sx1+ix; xsize=xsize-2*ix;
% Evaluate Function-List
dy=20; %y=y-dy-iy;
tag='txt_R1st_ExecuteName';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Function-Name:',...
  'Position',[sx2 y xsize dy]);

dy=20; y=y-dy;
tag='pop_R1st_ExecuteName';
sx3=sx2+2*ix;
xsizeX=xsize-2*ix;
xsize=xsizeX/2-ix;
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'Average','t-test','Evaluate'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
% --> 
ix3=1;
sx3=sx3+xsize+ix3;
xsize=(xsizeX/2-3*ix3)/3;
tag='psb_R1st_FcnArgSave';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Save',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
sx3=sx3+xsize+ix3;
tag='psb_R1st_FcnArgLoad';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Load',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
sx3=sx3+xsize+ix3;
tag='psb_R1st_FcnHelp';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Help',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy],...
  'style','toggle');

% For New
% - - - - - - - - - - - - - - -
y=120;
yback=y;
dy=30;y=y-dy-20;
xsize=50;
sx3=sx0+xsize0-xsize;
tag='psb_R1st_Save';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Save',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

% For Edit
% - - - - - - - - - - - - - - -
y=yback;
dy=30;y=y-dy-20;
ixx=1;xsize=(xsize0-3*ixx)/3;
sx3=sx0;
tag='psb_R1st_Change';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Apply changes',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
sx3=sx3+xsize+ixx;
xsize=xsize/2;
%dy=dy/2;y=yback-dy-20;
tag='psb_R1st_Remove';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Remove',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
sx3=sx3+xsize+ixx;
%y=y-dy-20;
tag='psb_R1st_Copy';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Copy',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);
sx3=sx3+xsize+ixx;
xsize=xsize*2;
tag='psb_R1st_TextOut';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Text Out',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

pos=get(hs.lbx_disp_fileList,'Position');
fnt=get(0,'FixedWidthFontName');
y=pos(2)+pos(4)+1;
xsize=90;
tag='psb_R1st_RecipeCheck';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Recipe Check',...
  'Visible','off',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx0-xsize-20 y xsize 20]);

if 0
  disp(C__FILE__LINE__CHAR);
  disp('Debug Mode Running...: R1st File-List-Box Position');
  pos(3)=pos(3)/2;
  pos(1)=pos(1)+pos(3);
end
tag='lbx_R1st_fileList';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String','No Data','HorizontalAlignment','left',...
  'FontName',fnt,...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Max',100,'Position',pos);

tag0=tag;
tag='cmn_R1st_fileList';
hs.(tag)=uicontextmenu('Parent',hs.figure1,'TAG',tag);
hcm=hs.(tag);
try
  set(hs.(tag0),'UiContextMenu',hcm);
  tag='mnu_R1st_SMD2ANA';
  hs.(tag)=uimenu(hcm,'Label','Use Summary Statistic Data Recipe',...
    'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));']);
  tag='mnu_R1st_ANA2SMD';
  hs.(tag)=uimenu(hcm,'Label','Use Analysis Data Recipe',...
    'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));']);
catch
  % Do nothing 
  % (Old version of MATLAB is not have UicContextMenu Property)
end

%--------------------------------------------------------------------------
% Init & Listup Research-Mode 1st-Level-Analysis Functions
%    2010_2_RA03-2
%--------------------------------------------------------------------------
logmsg={};
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end

[pp ff] = fileparts(osp_path); %#ok
if( strcmp(ff,'WinP3')~=0 )
  path0 = [osp_path filesep '..' filesep];
else
  path0 = [osp_path filesep];
end

plugin_path = [path0 'PluginDir'];
fs=find_file('^P3R1F_\w+.[mp]$', plugin_path,'-i');

plugin_path = [path0 'Research1stFunctions'];
fs0=find_file('^P3R1F_\w+.[mp]$', plugin_path,'-i');
fs=[fs,fs0];

str={};udata={};
try
  ll=length(fs);
  for ii=1:ll
    [p nm] = fileparts(fs{ii}); %#ok
    try
      bi=feval(nm,'createBasicInfo');
      hs=feval(nm,'CreateGUI',hs);
      
      str{end+1}=bi.name;
      udata{end+1}=bi;
    catch
      logmsg{end+1}=sprintf('Error : %s, %s',nm,lasterr);
    end
  end
  if ~isempty(logmsg)
    errordlg(logmsg,'Summary Statistics Computation Initialization');
  end
catch
end
set(hs.pop_R1st_ExecuteName,'Value',1,'String',str,'UserData',udata);

% Error Message
tag='txt_R1st_ErrorMessage';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Error:',...
  'Position',errpos);

guidata(hs.figure1,hs); % save
pop_R1st_ExecuteName_Callback(hs,[]);

%==========================================================================
function h=myHandles(hs)
% Handles
%==========================================================================
h=[hs.tgl_R1st_New,hs.tgl_R1st_Edit,hs.tgl_R1st_Lock,...
  hs.txt_R1st_Comment , hs.edt_R1st_Comment,...
  hs.frm_R1st_Execution, hs.txt_R1st_ExecuteName,...
  hs.pop_R1st_ExecuteName,...
  hs.psb_R1st_FcnArgSave,...
  hs.psb_R1st_FcnArgLoad,...
  hs.psb_R1st_FcnHelp,...
  ];

h0=ChangeStatus(hs);
h=[h, h0];

function h=myHandlesNew(hs)
% Handles for New
h=[hs.txt_R1st_DataName, hs.edt_R1st_DataName,hs.psb_R1st_Save];

function h=myHandlesEdit(hs)
% Handles for Edit
h=[hs.txt_R1st_SummarizedDataList,...
  hs.pop_R1st_SummarizedDataList,...
  hs.psb_R1st_ChangeComment,...
  hs.psb_R1st_Change,...
  hs.psb_R1st_Remove,...
  hs.psb_R1st_Copy,...
  hs.psb_R1st_TextOut,...
  hs.lbx_R1st_fileList];
% always Visible off
%  hs.psb_R1st_RecipeCheck,...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Status Change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=exeButton(hs)
h=[hs.psb_R1st_Save,...
  hs.psb_R1st_Change,hs.psb_R1st_Copy];
function disable_execution(hs,msg)
set(exeButton(hs),'Enable','off');
if nargin>=2 && ~isempty(msg)
  %errordlg(msg); 
  set(hs.txt_R1st_ErrorMessage,'String',msg);
else
  set(hs.txt_R1st_ErrorMessage,'String','Error Occur');
end
set(hs.txt_R1st_ErrorMessage,'Visible','on');

function enable_execution(hs)
set(exeButton(hs),'Enable','on');
set(hs.txt_R1st_ErrorMessage,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Status Change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tgl_R1st_Lock_Callback(hs)
p=fileparts(which(mfilename));
h=hs.tgl_R1st_Lock;
if get(h,'Value')
  fname=[p filesep 'ico_locked.bmp'];
else
  fname=[p filesep 'ico_lock.bmp'];
end
[c,m]=imread(fname);
cdata=zeros([size(c),3]);
for y=1:size(c,2)
  for x=1:size(c,1)
    cdata(x,y,:)=m(double(c(x,y))+1,:);
  end
end
set(h,'CData',cdata);

function [h,stat]=tgl_R1st_StatusHandleList(hs)
% Return Research-Mode 1st Status Toggle-Handle List
h=[hs.tgl_R1st_New,hs.tgl_R1st_Edit];
if nargout<=1, return; end
v=get(h,'Value');
v=cell2mat(v);
stat=get(h(v==1),'String');


%==========================================================================
function tgl_R1st_New_Callback(hs,sflag)
% Enter New Status
%==========================================================================
if nargin<2
  sflag=true;
end
% Change View
h=tgl_R1st_StatusHandleList(hs);set(h,'Value',0);
set(hs.tgl_R1st_New,'Value',1);
ChangeStatus(hs);

%--------------------------
% Apply Search Functions...
%--------------------------
% Reset Normal Search
try
  set(hs.edt_searchfile,'String','');
catch
end
% Apply Extended Search
if sflag
  udx=get(hs.menu_data_Selector,'UserData');
  if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
    hsp=guidata(udx.figh);
    P3_ExtendedSearch('pop_SOkey_Callback',hsp.pop_SOkey,[],hsp);
  end
end

%==========================================================================
function tgl_R1st_Edit_Callback(hs,dataname)
% Enter Edit Status
%==========================================================================

%-------------------------------------
% Update pop_R1st_SummarizedDataList
%     2010_2_RA04-1 (1)
%-------------------------------------
% Load Data-List
dfnc='DataDefIN_SummarizedData';
idkey=feval(dfnc,'getIdentifierKey');
dlist=feval(dfnc,'loadlist');
if isempty(dlist)
  % No Data
  errordlg({'No Summary Stastic Data to Edit'},'Research Mode');
  tgl_R1st_New_Callback(hs,false);
  return;
end
str={dlist.(idkey)};

%-------------------------------------
% Change View
%-------------------------------------
h=tgl_R1st_StatusHandleList(hs);set(h,'Value',0);
set(hs.tgl_R1st_Edit,'Value',1);
ChangeStatus(hs);

%-------------------------------------
% Set up/Select SummarizedDataList
%-------------------------------------
lh=hs.pop_R1st_SummarizedDataList;
% Select Value
vl=get(lh,'Value');
if (vl>length(str)), vl=1; end
if (nargin>=2 )
  try
    vl0=find(strcmp(str,dataname));
    if ~isempty(vl0)
      vl=vl0(1);
    end
  catch
  end
end
set(lh,'String',str,'Value',vl,'UserData',dlist);
% Update List
pop_R1st_SummarizedDataList_Callback(hs);

%==========================================================================
function h=ChangeStatus(hs)
% Change Status Visible
%==========================================================================
[h0, stat]=tgl_R1st_StatusHandleList(hs); %#ok

% Change View
hnew =myHandlesNew(hs);
hedit=myHandlesEdit(hs);
set([hnew , hedit],'Visible','off');

switch stat
  case 'New'
    h=hnew;
  case 'Edit'
    h=hedit;
  otherwise
end
set(h,'Visible','on');

%==========================================================================
function sdt=get_SelectedDataType(hs)
% Get Selected Data Type :: Meeting on 2010.12.20
%   BIT : Mean
%     1 : Exist Continuous-Dat 
%     2 : Exist Blcok-Data
%==========================================================================
[h0, stat]=tgl_R1st_StatusHandleList(hs); %#ok
% Change View
switch stat
  case 'New'
    sdt=get_SelectedDataType_new(hs);
  case 'Edit'
    sdt=get_SelectedDataType_edit(hs);
  otherwise
    error('Unknown Status');
end
%---------------------------------------------
function sdt=get_SelectedDataType_new(hs)
% Check All Reciep And Check Data-Type(Region)
%---------------------------------------------

% get Data-File
filedata=get(hs.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
end
%-------------------------------
% All-DataSelected ? 
%-------------------------------
isselectall=false;
if isselectall
  vls=get(hs.lbx_disp_fileList,'UserData');
else
  vls=get(hs.lbx_fileList,'Value');
end

%------------------------
% Load & Check Ana-Files
%------------------------
filedata=filedata(vls);
sdt=0;
for ii=1:length(filedata)
  % Load
  tmp = DataDef2_Analysis('load',filedata(ii));
  fmd=tmp.data.filterdata;
  bp  = [];
  
  % Check
  if isfield(fmd,'BlockPeriod')
    bp=fmd.BlockPeriod;
  end
  if isfield(fmd,'block_enable') && fmd.block_enable==false
    bp=[];
  end
  % Logging
  if ~isempty(bp)
    sdt=bitset(sdt,2); % Block
  else
    sdt=bitset(sdt,1); % Continuous
  end
end
if 0 
  % debug
  disp(C__FILE__LINE__CHAR);
  disp(sdt);
end

%---------------------------------------------
function sdt=get_SelectedDataType_edit(hs)
% Check All Reciep And Check Data-Type(Region)
%---------------------------------------------

%-------------------------------
% Get summarized data
%-------------------------------
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
% Apply Check File List
vl=get(hs.lbx_R1st_fileList,'Value');
ud=get(hs.lbx_R1st_fileList,'UserData');

%-------------------------------
% All-DataSelected ? 
%-------------------------------
isselectall=false;
if isselectall
  vls=1:size(ud,2);
else
  vls=vl;
end

%--------------------------
% Get Ana-Files
%-------------------------
filedata=get(hs.lbx_fileList,'UserData');
sdt=0;
% Load Ana-Files
for ii=vls(:)'
  %----------
  % Load
  %----------
  jj=ud(2,ii); % Real Index
  switch ud(1,ii)
    case 0
      % Recipe : Same (Use summarized Data Recipe)
      tmp=actdata.data.data.AnaFiles{jj};
    case 1
      % Recipe : Use Analysis-Data Recipe
      tmp=DataDef2_Analysis('load',...
        actdata.data.data.AnaFiles{jj});
    case 2
      % Use : List Data
      tmp=DataDef2_Analysis('load',filedata(jj));
    otherwise
      error('Undefined File-List Information ID %d',ud(1,ii));
  end % switch
  
    fmd=tmp.data.filterdata;
  bp  = [];
  
  %----------
  % Check
  %----------
  if isfield(fmd,'BlockPeriod')
    bp=fmd.BlockPeriod;
  end
  if isfield(fmd,'block_enable') && fmd.block_enable==false
    bp=[];
  end
  % Logging
  if ~isempty(bp)
    sdt=bitset(sdt,2); % Block
  else
    sdt=bitset(sdt,1); % Continuous
  end
end


if 0
  % debug
  disp(C__FILE__LINE__CHAR);
  disp(sdt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Function Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_R1st_ExecuteName_Callback(hs,oldvl)
%  Change Execute-Name...
% 2010_2_RA03_2
persistent myval;
%persistent selected_data_type;

% Function Check
if nargin>=2
  myval=oldvl;
end
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');

% Data-Type Check
sdt=get_SelectedDataType(hs);

% Check Do-nothing
if ~isempty(myval) && isnumeric(myval)
  %   if ~isempty(selected_data_type) && isnumeric(selected_data_type)
  %     if ((vl==myval) && (sdt==selected_data_type))
  %       return;
  %     end
  %   end
  % Suspend Old-Function
  feval(ud{myval}.fcn,'Suspend',hs);
end

% Activate Current Function
feval(ud{vl}.fcn,'Activate',hs,sdt);
%feval(ud{vl}.fcn,'Activate',hs);disp(C__FILE__LINE__CHAR);
%selected_data_type=sdt;
myval=vl;

% Open Help
psb_R1st_FcnHelp_Callback(hs);

function psb_R1st_FcnArgSave_Callback(hs)
% Save Execute Function Argument
%==========================================================================
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');
p3r1f_data=ud{vl};

name0=['R1st_' p3r1f_data.fcn '_'  datestr(now,'dd_mmm_yyyy') '.mat'];
[fname, pname] = osp_uiputfile(name0, 'Save File Name');
if isequal(fname,0) || isequal(pname,0)
  return;
end
ExeData=feval(p3r1f_data.fcn,'MakeExeData',hs); %#ok
FcnName=p3r1f_data.fcn;                          %#ok
save([pname filesep fname], 'ExeData','FcnName');

function psb_R1st_FcnArgLoad_Callback(hs)
% Load Execute Function Argument
%==========================================================================
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');
p3r1f_data=ud{vl};

[fname, pname] = osp_uigetfile('*.mat', 'Execute Data File Name');
if isequal(fname,0) || isequal(pname,0)
  return;
end
LoadData=load([pname filesep fname]);
if ~strcmpi(LoadData.FcnName,p3r1f_data.fcn)
  errordlg({'Bad Function Data', ...
    ['  * Selected  Function : ' p3r1f_data.fcn],...
    ['  * Load Data Function : ' LoadData.FcnName]},...
    'Load Argument Data Error');
  return;
end
feval(p3r1f_data.fcn,'SetExeData',hs,LoadData.ExeData);

function psb_R1st_FcnHelp_Callback(hs)
% Show Help Execute Function
%==========================================================================
if get(hs.psb_R1st_FcnHelp,'Value')==1
  vl=get(hs.pop_R1st_ExecuteName,'Value');
  ud=get(hs.pop_R1st_ExecuteName,'UserData');
  p3r1f_data=ud{vl};
  %POTATo_Help(p3r1f_data.fcn);
  sfh=gcbf;uihelp(p3r1f_data.fcn);figure(sfh);
  %set(0,'currentFigure',sfh)
else
  uihelp([],'close');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function pop_R1st_SummarizedDataList_Callback(hs)
% Apply Summarized-Data
%     2010_2_RA04-1 (2)
%==========================================================================

%--------------------------
% Load Summarized Data
%--------------------------
% Load Data-List
h=hs.pop_R1st_SummarizedDataList;
vl=get(h,'Value');
ud=get(h,'UserData');

% Make Active-Data Fromat
actdata.fcn ='DataDefIN_SummarizedData';
actdata.data=ud(vl);
% load Data
actdata.data=feval(actdata.fcn,'load',actdata.data);

%--------------------------
% Apply to GUI
%--------------------------
% to Comment
set(hs.edt_R1st_Comment,'String',actdata.data.Comment);
try
  fid=0;
  fl=get(hs.pop_R1st_ExecuteName,'UserData');
  for ii=1:length(fl)
    try
      if strcmp(fl{ii}.fcn,actdata.data.ExeFunction)
        fid=ii;break;
      end
    catch
    end
  end
  if (fid>0)
    set(hs.pop_R1st_ExecuteName,'Value',fid);
    % Calllback will be occur in ReicpCheck!
  end
catch
end
% Exefunction
feval(actdata.data.ExeFunction,'SetExeData',hs,actdata.data.data.ExeData);

%--------------------------
% Apply to File List
%--------------------------
psb_R1st_RecipeCheck_Callback(hs,actdata);

%--------------------------
% Reset Search Functions...
%--------------------------
% Normal Search
try
  set(hs.edt_searchfile,'String','');
catch
end
%Extended Search
try
  % Check Extended Search..
  udx=get(hs.menu_data_Selector,'UserData');
  if ~isempty(udx) && ~isempty(udx.figh) && ishandle(udx.figh)
    % - - - - - - - - - - - - - - - - - - 
    % Make-Search-Key
    % - - - - - - - - - - - - - - - - - -
    skey.Type ='Bracket';
    skey.Relop='And';
    skey.Not  =0;
    %skey.list   =cell([1, actdata.data.data.nfile]);
    skey.list   =cell([1, 1]);
    idkey=DataDef2_Analysis('getIdentifierKey');
    so.Type   = 'SearchOption';
    so.Relop  = 'And';
    so.Not    = 0;
    so.String = '';
    so.key    =idkey;
    so.KeyType='Text';
    so.SortType='Regexp';
    so.SortValue='';
    if 0
      for ii=1:actdata.data.data.nfile
        tmp=actdata.data.data.AnaFiles{ii}.(idkey);
        so.String = ['^' tmp '$'];
        so.SortValue=so.String;
        skey.list{ii}=so;
        so.Relop='Or';
      end
    end
    for ii=1:actdata.data.data.nfile
      tmp=actdata.data.data.AnaFiles{ii}.(idkey);
      so.String = [so.String '(^' tmp '$)|'];
    end
    so.String(end)=[]; % Delete last |
    so.SortValue=so.String;
    so.Relop='Or';
    skey.list{1}=so;

    % - - - - - - - - - - - - - - - - - - 
    % Apply SerKey to P3-Extended Search
    % - - - - - - - - - - - - - - - - - - 
    hsp=guidata(udx.figh);
    P3_ExtendedSearch('UpdateSearchKey',hsp.figure1,{skey},hsp);
  end
catch
  errordlg({'Extended Search Error:', lasterr},'Extended Searc');
end


%==========================================================================
function psb_R1st_RecipeCheck_Callback(hs,actdata)
% Check difference between Summarized-Data-Recipe and Analysis-Data's.
%==========================================================================

% I/O Check
if nargin<2
  actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
end

str=cell([1,actdata.data.data.nfile]);
str0=cell([1,actdata.data.data.nfile]);
ud =zeros([2,actdata.data.data.nfile]);
idkey=DataDef2_Analysis('getIdentifierKey');
for ii=1:actdata.data.data.nfile
  tmp=DataDef2_Analysis('load',actdata.data.data.AnaFiles{ii});
  iseqrecipe=isequal(actdata.data.data.AnaFiles{ii}.data.filterdata,...
    tmp.data.filterdata);
  str0{ii}=actdata.data.data.AnaFiles{ii}.(idkey);
  if iseqrecipe
    ud(1,ii)=0;
    str{ii}=sprintf('   %s',actdata.data.data.AnaFiles{ii}.(idkey));
  else
    ud(1,ii)=1;
    %str{ii}=[' M ' actdata.data.data.AnaFiles{ii}.(idkey)];
    str{ii}=sprintf('***%s',actdata.data.data.AnaFiles{ii}.(idkey));
  end
  ud(2,ii)=ii;
end
%vl=get(hs.lbx_R1st_fileList,'Value');
%if (vl>length(str)), vl=length(str);end
vl=1:length(str);
set(hs.lbx_R1st_fileList,'UserData',ud,'String',str,'Value',vl);

% from Summarized-Data..
actdata.Default.StringDisplay=str;
actdata.Default.StringFiles  =str0;
actdata.Default.UserData     =ud;
set(hs.psb_R1st_RecipeCheck,'UserData',actdata);

lbx_R1st_fileList_Callback(hs);

%==========================================================================
function lbx_R1st_fileList_Callback(hs)
% Control uicontextmenu
%       2010_2_RC02-5 
%==========================================================================
vl=get(hs.lbx_R1st_fileList,'Value');
ud=get(hs.lbx_R1st_fileList,'UserData');
try
  if any(ud(1,vl)==1)
    set(hs.lbx_R1st_fileList,'UiContextMenu',hs.cmn_R1st_fileList);
    %set(hs.cmn_R1st_fileList,'Visible','on');
  else
    set(hs.lbx_R1st_fileList,'UiContextMenu',[]);
    %set(hs.cmn_R1st_fileList,'Visible','off');
  end
catch
  % Maybe Old MATLAB Version
end

% Update...
try
  actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
  name=actdata.Default.StringFiles;
  st=get(hs.lbx_fileList,'String');
  ids=[];
  for ii=vl(:)'
    if ud(1,ii)==2
      ids(end+1)=ud(2,ii);
    else
      tmp=find(strcmp(name{ud(2,ii)},st));
      if length(tmp)==1
        ids(end+1)=tmp;
      end
    end
  end
  if length(ids)>=1
    set(hs.pop_fileinfo,...
      'String',st(ids),...
      'UserData',ids,...
      'Value',1);
    POTATo('pop_fileinfo_Callback',hs.pop_fileinfo,[],hs,true);
  end
catch
end

% Data-Check! 
pop_R1st_ExecuteName_Callback(hs);

%==========================================================================
function mnu_R1st_SMD2ANA_Callback(hs)
% Apply Summarized-Data Recipe To Analysis-Data Recipe
%       2010_2_RC02-5 
%==========================================================================

% Get Summarized-Data
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
% Apply Check File List
vl=get(hs.lbx_R1st_fileList,'Value');
ud=get(hs.lbx_R1st_fileList,'UserData');

% Init Analysis Data I/O
%FileFunc('BufferingMode'); % Save Ana-Data with Buffering
for ii=vl(:)'
  % Is Same Recipe?
  if ud(1,ii)~=1, continue; end
  
  jj=ud(2,ii);
  % Load Analysis Data
  ana=DataDef2_Analysis('load',actdata.data.data.AnaFiles{jj});
  % Mod Recipe
  ana.data.filterdata=actdata.data.data.AnaFiles{jj}.data.filterdata;
  % Save
  DataDef2_Analysis('save_ow',ana);
  
end
%FileFunc('Flush'); % Saveed Ana-Data : Flush
% Check Recipe...
pop_R1st_SummarizedDataList_Callback(hs);

%==========================================================================
function mnu_R1st_ANA2SMD_Callback(hs)
% Apply Analysis-Data Recipe To Summarized-Data Recipe
%       2010_2_RC02-5 
%==========================================================================

% Get Summarized-Data
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
% Apply Check File List
vl=get(hs.lbx_R1st_fileList,'Value');
ud=get(hs.lbx_R1st_fileList,'UserData');

for ii=vl(:)'
  % Is Same Recipe?
  if ud(1,ii)~=1, continue; end
  jj=ud(2,ii);
  % Load Analysis Data
  ana=DataDef2_Analysis('load',actdata.data.data.AnaFiles{jj});
  % Mod Recipe
  actdata.data.data.AnaFiles{jj}.data.filterdata=ana.data.filterdata;
end
% Save
feval(actdata.fcn,'save_ow',actdata.data);
% Check Recipe
pop_R1st_SummarizedDataList_Callback(hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exteded Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ext_search(hs,mylist,flag)
% - - - - - - - - - - - - - - - - - - - - - - - -
% Update Display List
% - - - - - - - - - - - - - - - - - - - - - - - -

% Get Data
flh =hs.lbx_fileList;      % Effective File-List
fl=get(flh,'String');
rflh=hs.lbx_R1st_fileList; % My-File-List List-box
mydata=get(hs.psb_R1st_RecipeCheck,'UserData');
% non 
if isempty(mydata), return; end
mydata=mydata.Default;

vl=[];
if ~isempty(mylist)
  list=mylist.data;
  %---------------------------
  % Loop : Search Pattern List
  %---------------------------
  str=cell([1,length(list)]);
  ud =zeros([2,length(list)]);
  for ii=1:length(list)
    vl(end+1)=ii;
    % Search Matching-Data
    jj=find(strcmp(mydata.StringFiles,list{ii}));
    kk=find(strcmp(list{ii},fl));
    if isempty(jj)
      ud(1,ii) = 2;
      if isempty(kk), kk=-1;end
      ud(2,ii) = kk(1);
    else
      ud(:,ii) = mydata.UserData(:,jj);
    end
    if ud(1,ii)==1
      str{ii}=sprintf('***%s',mylist.str{ii});
    else
      str{ii}=sprintf('   %s',mylist.str{ii});
    end
  end
end
if isempty(vl)
  set(rflh,'Value',1,...
    'String','No Match Files',...
    'UserData',[2 -1]);
else
  set(rflh,'String',str,'UserData',ud,'Value',vl);
end
if 0
  if nargin<3 || flag
    lbx_R1st_fileList_Callback(hs);
  end
else
  lbx_R1st_fileList_Callback(hs);
end

%===============================
% debug : Extended Search
%         for Disp-File-List
%===============================
if 0
  dflh=hs.lbx_disp_fileList; % Display-File-List
  flh =hs.lbx_fileList;      % Effective File-List
  fl=get(flh,'String');
  if ~isempty(mylist)
    vl=[];
    list=mylist.data;
    %---------------------------
    % Loop : Search Pattern List
    %---------------------------
    for idx=1:length(list)
      % Search Matching-Data
      addid=find(strcmp(list{idx},fl));
      if ~isempty(addid)
        vl(end+1)=addid;
      end
    end
    %----------------------------------
    fl2    = mylist.str;
  else
    vl=1:length(fl);
  end
  
  set(dflh,'Value',1,'UserData',vl);
  if isempty(vl),
    % No Match
    set(dflh,'String',{'No - Match Files'});
  else
    % Exist
    if exist('fl2','var')
      set(dflh,'String',fl2);
    else
      set(dflh,'String',fl(vl));
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Summarized-Data : Select Tool
%    tagetConfirmQdlg: Question Dialog to Taget Confirmation.
%    makeSSReal0     : Make Summarized-Statistic Data (Real-part)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function isselectall=tagetConfirmQdlg(hs,n)
% Question Dialog : Taget Confirmation
%             2010_2_RA03-6
%==========================================================================

% get GUI Information
set(0,'Units','pixels');p=get(0,'ScreenSize');
x=200;y=120;
c=get(hs.figure1,'Color');
%c=[0.7 0.7 0.7];

ths.fig=figure('Visible','off',...
  'Color',c,...
  'MenuBar','none','NumberTitle','off',...
  'Name','Taget file confirmation',...
  'Units','pixels','Position',[(p(3)-x)/2 (p(4)-y)/2 x y]);
dy=20; iy=5;
y=y-dy;
ths.title=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','text',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Analyze and save ...',...
  'Position',[10 y 390 dy]);

y=y-dy-iy;
ths.selected=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','radiobutton',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String',sprintf('Selected %d files',n),...
  'Value',1,...
  'Callback','h=get(gcbo,''UserData'');set(h,''Value'',0);;set(gcbo,''Value'',1);',...
  'Position',[20 y 380 dy]);

y=y-dy-iy;
ths.all=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','radiobutton',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','all files in Data List',...
  'Value',0,...
  'UserData',ths.selected,...
  'Callback','h=get(gcbo,''UserData'');set(h,''Value'',0);;set(gcbo,''Value'',1);',...
  'Position',[20 y 380 dy]);
set(ths.selected,'UserData',ths.all);

ths.save =uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','Save',...
  'Callback','set(gcbf,''visible'',''off'')',...
  'Position',[10 10 x/2-20 30]);
ths.cancel=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','Cancel',...
  'Callback','delete(gcbf)',...
  'Position',[x/2 10 x/2-20 30]);

set(ths.fig,'Visible','on','WindowStyle','modal');
waitfor(ths.fig,'Visible','off');
if ~ishandle(ths.fig)
  % Closed
  isselectall=[];
  return;
end
isselectall=get(ths.all,'Value');
delete(ths.fig);

%==========================================================================
function datar=makeSSReal0(hs,isselectall)
% Make Summry Stastic-Data (Real-Part) 
%   datar.nfile
%   datar.AnaFiles
%==========================================================================
[h0, stat]=tgl_R1st_StatusHandleList(hs); %#ok
% Change View
if nargin==1
  isselectall=[];
end
switch stat
  case 'New'
    datar=makeSSReal0_New(hs,isselectall);
  case 'Edit'
    datar=makeSSReal0_Edit(hs,isselectall);
  otherwise
    error('Unknown Status');
end

function datar=makeSSReal0_New(hs,isselectall)
% make datar for New

%-------------------------------
% All-DataSelected ? 2010_2_RA03-6
%-------------------------------
v=get(hs.lbx_disp_fileList,'Value');
n=get(hs.lbx_disp_fileList,'String');
if isempty(isselectall)
  if ~isequal(v,1:length(n))
    isselectall=tagetConfirmQdlg(hs,length(v));
    if isempty(isselectall), datar=[];return; end
  else
    isselectall=false;
  end
end

%--------------------------
% Get Ana-Files
%-------------------------
% get DataDef (II) Function
fcn=get(hs.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
end
fcn=fcn{get(hs.pop_filetype,'Value')};
% (( fcn must be DataDef2_Analysis))

% get Data-File
filedata=get(hs.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
end

if isselectall
  vls=get(hs.lbx_disp_fileList,'UserData');
else
  vls=get(hs.lbx_fileList,'Value');
end
datar.nfile    = length(vls);
datar.AnaFiles = cell([1,datar.nfile]);
if datar.nfile>=5
  wh=waitbar(0,'Loading Analysis Data','WindowStyle','Modal');
  try
    set(wh,'Name','Save Summarized Data');
    set(wh,'CloseRequestFcn','');
  catch
  end
  try
    wi=1/datar.nfile;
    for ii=1:datar.nfile
      datar.AnaFiles{ii}=feval(fcn,'load',filedata(vls(ii)));
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
  end
end


function datar=makeSSReal0_Edit(hs,isselectall)
% make datar for Edit

%-------------------------------
% Get summarized data
%-------------------------------
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');

% Apply Check File List
vl=get(hs.lbx_R1st_fileList,'Value');
ud=get(hs.lbx_R1st_fileList,'UserData');

%-------------------------------
% All-DataSelected ? 2010_2_RA03-6
%-------------------------------
if isempty(isselectall)
  if ~isequal(vl(:)',1:size(ud,2))
    isselectall=tagetConfirmQdlg(hs,length(vl));
    if isempty(isselectall),  % canceled
      datar=[];
      return; 
    end
  else
    isselectall=false;
  end
end
if isselectall
  vls=1:size(ud,2);
else
  vls=vl;
end

%--------------------------
% Get Ana-Files
%-------------------------
% get DataDef (II) Function
fcn=get(hs.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
end
fcn=fcn{get(hs.pop_filetype,'Value')};
% (( fcn must be DataDef2_Analysis))

% get Data-File
filedata=get(hs.lbx_fileList,'UserData');

datar.nfile    = length(vls);
datar.AnaFiles = cell([1,datar.nfile]);
% Load Ana-Files
for ii0=1:datar.nfile
  ii=vls(ii0);
  jj=ud(2,ii); % Real Index
  switch ud(1,ii)
    case 0
      % Recipe : Same (Use summarized Data Recipe)
      datar.AnaFiles{ii0}=actdata.data.data.AnaFiles{jj};
    case 1
      % Recipe : Use Analysis-Data Recipe
      datar.AnaFiles{ii0}=feval(fcn,'load',...
        actdata.data.data.AnaFiles{jj});
    case 2
      % Use : List Data
      datar.AnaFiles{ii0}=feval(fcn,'load',filedata(jj));
    otherwise
      error('Undefined File-List Information ID %d',ud(1,ii));
  end % switch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks Modify Summarized-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function psb_R1st_ChangeComment_Callback(hs)
% Change Comment
%==========================================================================
%-------------------------------
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
dataf.Name        = actdata.data.Name;
dataf.Comment     = get(hs.edt_R1st_Comment,'String');

%-------------------------------
% Summarized Data (Active-Data-Format)
%-------------------------------
DataDefIN_SummarizedData('update_comment',dataf);
tgl_R1st_Edit_Callback(hs);

%==========================================================================
function psb_R1st_Save_Callback(hs)
% Save New Summarized-Data
%==========================================================================

%-------------------------------
% Check Same Name?
%-------------------------------
a=DataDefIN_SummarizedData('loadlist',get(hs.edt_R1st_DataName,'String'));
if ~isempty(a)
  errordlg({'Data-Name already exists.',...
    '  Change Name and try again, please'},'Same Summary Stastic Data');
  return;
end

%-------------------------------------------
% Make Summary-Stastistic Data of
%            Analysis-Data Set Information
%-------------------------------------------
datar=makeSSReal0(hs); % with  isselect all
if isempty(datar)
  return; % cancel 
end

%-------------------------------
% Get ExeData
%-------------------------------
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');
p3r1f_data=ud{vl};

datar.ExeData=feval(p3r1f_data.fcn,'MakeExeData',hs);

%-------------------------------
% Get Summarized Data
%-------------------------------
try
  datar=feval(p3r1f_data.fcn,'execute',datar);
catch
  errordlg(lasterr);
  return;
end

%-------------------------------
% Summarized Data (Data-Format) 
%-------------------------------
dataf.Name        = get(hs.edt_R1st_DataName,'String');
dataf.Comment     = get(hs.edt_R1st_Comment,'String');
dataf.ExeFunction = p3r1f_data.fcn;  
dataf.data        = datar;

%-------------------------------
% Summarized Data (Active-Data-Format)
%-------------------------------
summarizeddata.fcn ='DataDefIN_SummarizedData';
summarizeddata.data=dataf;

%-------------------------------
% Save Summarized Data 
%-------------------------------
try
  feval(summarizeddata.fcn,'save',summarizeddata.data);
catch
  errordlg({'In Saving Summarized Data', lasterr},'Save Summarized Data')
end

% --------------------------------
% Move to Edit-Mode
% (See also mail 7-Jan-2011)
% --------------------------------
tgl_R1st_Edit_Callback(hs,dataf.Name);

%==========================================================================
function psb_R1st_Change_Callback(hs,datafMOD)
% Overwrite Save Summarized-Data
%==========================================================================

%-------------------------------
% Get summarized data
%-------------------------------
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');

%-------------------------------------------
% Make Summary-Stastistic Data of
%            Analysis-Data Set Information
%-------------------------------------------
datar=makeSSReal0(hs); % with  isselect all
if isempty(datar)
  return;
end

%-------------------------------
% Get ExeData
%-------------------------------
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');
p3r1f_data=ud{vl};

datar.ExeData=feval(p3r1f_data.fcn,'MakeExeData',hs);

%-------------------------------
% Get Summarized Data
%-------------------------------
try
  datar=feval(p3r1f_data.fcn,'execute',datar);
catch
  errordlg(lasterr);
  return;
end

%-------------------------------
% Summarized Data (Data-Format) 
%-------------------------------
dataf.Name        = actdata.data.Name;
dataf.Comment     = get(hs.edt_R1st_Comment,'String');
dataf.ExeFunction = p3r1f_data.fcn;  
dataf.data        = datar;

if nargin>=2
  % copy from
  infs=fieldnames(datafMOD);
  adfs=fieldnames(dataf);
  fs=intersect(infs,adfs);
  for ii=1:length(fs)
    dataf.(fs{ii})=datafMOD.(fs{ii});
  end
end

%-------------------------------
% Summarized Data (Active-Data-Format)
%-------------------------------
summarizeddata.fcn ='DataDefIN_SummarizedData';
summarizeddata.data=dataf;

if nargin==1
  %-------------------------------
  % Overwrite Save Summarized Data
  %-------------------------------
  try
    feval(summarizeddata.fcn,'save_ow',summarizeddata.data);
  catch
    errordlg({'In Overwrite Saving Summarized Data', lasterr},'Save Summarized Data')
  end
else
  %-------------------------------
  % Save Summarized Data
  %-------------------------------
  try
    feval(summarizeddata.fcn,'save',summarizeddata.data);
  catch
    errordlg({'In Saving Summarized Data', lasterr},'Save Summarized Data')
  end
end
tgl_R1st_Edit_Callback(hs);
%==========================================================================
function psb_R1st_Remove_Callback(hs)
% Delete Summarized-Data (2010_2_RA04_5)
%  TODO: Name of Button : (Delete? Remove?)
%==========================================================================

%-------------------------------
% Get summarized data
%-------------------------------
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
% Enable Question Dilaog.
OSP_DATA('SET','ConfineDeleteDataSV',true);
% Delete
feval(actdata.fcn,'deleteGroup',actdata.data);
tgl_R1st_Edit_Callback(hs);

%==========================================================================
function psb_R1st_Copy_Callback(hs)
% Copy Summarized-Data (2010_2_RA04_6)
%==========================================================================
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');

% get GUI Information
set(0,'Units','pixels');p=get(0,'ScreenSize');
dy_cm=20*5;
dy=20; iy=5;
x=400;y=80+iy*5+dy_cm;
c=get(hs.figure1,'Color');

ths.fig=figure('Resize','off','Visible','off',...
  'Color',c,...
  'MenuBar','none','NumberTitle','off',...
  'Name','Taget file confirmation',...
  'Units','pixels','Position',[(p(3)-x)/2 (p(4)-y)/2 x y]);

y=y-dy;
ths.title=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','text',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Copy SummarizedData',...
  'Position',[10 y x-10 dy]);

y=y-dy-iy;
sx1=20;
x1 =(x-60)/3;
sx2=sx1+x1+20;
x2 =x1*2;
ths.txt_name=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','text',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Name:',...
  'Position',[sx1 y x1 dy]);
ths.edt_name=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','edit',...
  'BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String',['Copy_' actdata.data.Name],...
  'Position',[sx2 y x2 dy]);
y0=y;
y=y-dy-iy;
ths.txt_comment=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','text',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Comment:',...
  'Position',[sx1 y x1 dy]);
y=y0-dy_cm-iy;
ths.edt_comment=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','edit',...
  'Max',10,...
  'BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String',actdata.data.Comment,...
  'Position',[sx2 y x2 dy_cm]);

y=y-dy-iy;
ths.issimplecopy=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','checkbox',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Copy original summalized data',...
  'Value',1,...
  'Position',[20 y x-20 dy]);

y=y-dy-iy;
ths.copy =uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','Copy',...
  'Callback','set(gcbf,''visible'',''off'')',...
  'Position',[10 y x/2-20 dy]);
ths.cancel=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','Cancel',...
  'Callback','delete(gcbf)',...
  'Position',[x/2 y x/2-20 dy]);

h0=findobj(ths.fig,'Type','uicontrol');
set(h0,'Units','Normalized');
set(ths.fig,'Visible','on','WindowStyle','modal');
while (1)
  waitfor(ths.fig,'Visible','off');
  if ~ishandle(ths.fig)
    % Closed
    return;
  end
  nm=get(ths.edt_name,'String');
  cm=get(ths.edt_comment,'String');
  datafin.Name=nm;
  datafin.Comment=cm;
  a=feval(actdata.fcn,'loadlist',nm);
  if ~isempty(a)
    errordlg({sprintf('Data-Name (%s) already exists.',nm),...
      '  Change Name and try again, please'},'Same Summarized Data');
    set(ths.fig,'Visible','on');
    continue;
  end
  
  issimplecopy=get(ths.issimplecopy,'Value');
  delete(ths.fig);
  break;
end

if issimplecopy==0
  % Save Data (get GUI-Data)
  psb_R1st_Change_Callback(hs,datafin);
  return;
end

% copy from 
infs=fieldnames(datafin);
adfs=fieldnames(actdata.data);
fs=intersect(infs,adfs);
for ii=1:length(fs)
  actdata.data.(fs{ii})=datafin.(fs{ii});
end
feval(actdata.fcn,'save',actdata.data);
tgl_R1st_Edit_Callback(hs);

%==========================================================================
function psb_R1st_TextOut_Callback(hs)
% Text out
%==========================================================================
actdata=get(hs.psb_R1st_RecipeCheck,'UserData');
SS=actdata.data.data; % get Summarized Statistics Data
emsg=P3R2_API_SSTools('textout',SS);
if emsg, errordlg(emsg,'TextOut Error');end


