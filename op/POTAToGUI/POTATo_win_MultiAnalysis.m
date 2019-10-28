function varargout=POTATo_win_MultiAnalysis(fnc,varargin)
% POTATo Window : Mulri-Analysis Mode Control GUI
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%======== Launch Switch ========
switch fnc,
  case {'DisConnectAdvanceMode',...
      'ChangeLayout'}
    % ==> Use POTATo_win (Default Function)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'MakeMfile',
    varargout{1}=MakeMfile(varargin{:});
  case 'Export2WorkSpace'
    varargout{1}=Export2WorkSpace(varargin{:});
  case 'SaveData',
    varargout{1}=SaveData(varargin{:});    
  case 'DrawLayout'
    varargout{1}=DrawLayout(varargin{:});
  case 'ConnectAdvanceMode'
    ConnectAdvanceMode(varargin{:});    
    %=========================
    % Special Functin List
    %=========================
  case 'pop_MLT_AnaFile_Callback',
    pop_MLT_AnaFile_Callback(varargin{3}); %<==handles
  case 'EditParentFile',
    EditParentFile(varargin{:}); %<==handles
  case 'lbx_MLT_AnaFileInfo_Callback',
    % noting to do now.
    %lbx_MLT_AnaFileInfo_Callback(varargin{3}); %<==handles
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hs,pos]=myHandles(h)
% Return 'Handles of Multi-Analysis GUI' & 'Position'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos0=get(h.frm_AnalysisArea,'Position');
pos1=get(h.frm_MultiAnaArea,'Position');
pos=pos0(1:2)-pos1(1:2);
hs=[h.txt_MLT_title,...
    h.pop_MLT_AnaFile, ...
    h.lbx_MLT_AnaFileInfo, ...
    h.pop_MLT_MPP_Type, ...
    h.pop_MLT_FilterList, ...
    h.psb_MLT_Add, ...
    h.lbx_MLT_FiltData, ...
    h.psb_MLT_Help, ...
    h.psb_MLT_Up, ...
    h.psb_MLT_Down, ...
    h.psb_MLT_Change, ...
    h.psb_MLT_Suspend, ...
    h.psb_MLT_Remove, ...
    h.psb_MLT_Save, ...
    h.psb_MLT_Load,...
    h.ckb_MLT_FileMode];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(handles,varargin)
% Suspend Mulit-Analysis Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- varargin is not use now --
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

%==========================
% Change Position & Visible
%==========================
[hs,pos]=myHandles(handles);
suspend_comm(hs,pos, handles);
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');

%set(handles.psb_MakeMfile,'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(handles,varargin)
% Activate Mulit-Analysis Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- varargin is not use now --
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

%==========================
% Change Position & Visible
%==========================
[hs,pos]=myHandles(handles);
activate_comm(hs,pos, handles);
% Viewer is unpopulated
%set(handles.pop_Layout,'Visible','on');
%set(handles.psb_drawdata,'Visible','on');


%=============================
% Load Multi File
%=============================
%-------------------------
% Load Data
%-------------------------
% get current DataDef (II) Function
fcn=get(handles.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  fcn=fcn{get(handles.pop_filetype,'Value')};
end
% ('fcn' must be DataDef2_MultiAnalysis, in this version)

% get Data-File
filedata=get(handles.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
else
  vls=get(handles.lbx_fileList,'Value');
  multdata=filedata(vls(1));
  clear filedata;
end
multdata=feval(fcn,'load',multdata);
actdata.fcn  = fcn;
actdata.data = multdata;

%=============================
% Set-up Analysif-Files
%=============================
% Load Analysis Files
[anadata, str, isblock]   = DataDef2_MultiAnalysis('get_ANA_info',multdata);

% Show Recipes (Ana)
set(handles.pop_MLT_AnaFile,'String',str,'UserData',anadata,'Value',1);
pop_MLT_AnaFile_Callback(handles);

%=============================
% Set-up Multi-Recipe
%=============================
% --> Can I Edit?
set(handles.lbx_MLT_FiltData,'UserData',[]);
if ~isempty(isblock) && all(isblock(:)==isblock(1))
  % Edit : OK
  setappdata(handles.figure1,'LocalActiveData',actdata);
  P3_gui_MultiAnalysis('LocalActiveDataOn',handles);
  % Set up Multi Processing Functions (recipe)
  if isfield(multdata.data,'Recipe')
    P3_gui_MultiAnalysis('set',handles.figure1,multdata.data.Recipe);
  else
    P3_gui_MultiAnalysis('set',handles.figure1,[]);
  end
else
  % Edit : NG
  P3_gui_MultiAnalysis('LocalActiveDataOff',handles);
  h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
  set(h0,'Visible','off');
  h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
  set(h0,'Visible','off');
  return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [msg, fnametmp]=MakeMfile(handles)
% Make M-File of Multi-Analysis Mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get File List
msg='';
actdata=getappdata(handles.figure1,'LocalActiveData');
actdata.data = feval(actdata.fcn, 'load', actdata.data);
key.actdata=actdata;
% -- File name Get --
if nargout<=1,
  % == Get M-File Name==
  [f p] = osp_uiputfile('*.m', ...
    'Output M-File Name', ...
    ['POTATo_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel
  fname = [p filesep f];
  key.fname  =fname;
  %------------------------------
  % add Viewer
  %  mail 2007.05.14
  %------------------------------
  wk=get(handles.ckb_Draw,'Value');
  if wk
    actdata.data=feval(actdata.fcn,'load',actdata.data);
    data.name='Local Viewer';
    data.wrap='PluginWrapPM_localviewer';
    layoutfile=get(handles.pop_Layout,'UserData');
    layoutfile=layoutfile{get(handles.pop_Layout,'Value')};
    data.argData.LayoutFile=layoutfile;
    if isfield(actdata.data.data,'Recipe')
      key.Recipe=actdata.data.data.Recipe;
    end
    try
      key.Recipe.default{end+1} = data;
    catch
      key.Recipe.default = {data};
    end
  end
else
  key.fname  ='';
end
% Make M-File
try
  fnametmp=feval(actdata.fcn,'make_mfile',key);
catch
  msg=lasterr;
  return;
end

%-------------
% Open Editor
%-------------
if nargout<=1
  edit(fname);
end

function msg=Export2WorkSpace(hs)
% Export Mfile Result to WorkSpace (base);
[msg, fnametmp]=MakeMfile(hs);
if ~isempty(msg),return;end
try
  scriptMevalin(fnametmp);
catch
  msg={'--------------------',...
    ' [Platform Error]',...
    '--------------------',...
    ' Script Execution Error',lasterr};
end
try
  delete(fnametmp);
catch
  warndlg({' File Delete Error occur : ', lasterr});
end


function p3view(LAYOUT,hdata,data)
% viewer for data of multi-ana result
tp=0;
isDcell =iscell(hdata);
if isDcell
  tp=bitset(tp,2);
  if ~isempty(data) && ndims(data{1})==4
    tp=bitset(tp,1);
  end
else
  if ndims(data)==4
    tp=bitset(tp,1);
  end
end

switch tp
  case 0,
    % 00(0) : Normal-Continuos
    %error('Unpopulated Data-Format for Viewer!');
    osp_LayoutViewer(LAYOUT,{hdata},{data});
  case 1,
    % 01(1) : Normal-Block
    %!!! Warning Continuous Data is Dumy !!!
    [dd,dh]=dumy_data_forp3view(1);
    osp_LayoutViewer(LAYOUT,{dh},{dd},'bhdata',hdata,'bdata',data);
  case 2,
    % 10(2) : Cell  -Continuous
    osp_LayoutViewer(LAYOUT,hdata,data);
  case 3,
    % 11(3) : Cell  -Block
    error('Unpopulated Data-Format for Viewer!');
end

function [data,hdata]=dumy_data_forp3view(mode)
% Mode 1: Continuous
% Mode 2: Block
p=fileparts(which('LE_testdraw'));
datafile   = [p filesep 'TestData' filesep 'data0.mat'];
[data, hdata] = uc_dataload(datafile);
if mode==2
  [data, hdata] = uc_blocking({data}, {hdata},5.000000,15.000000);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=DrawLayout(handles)
% Draw Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get Layout File
layoutfile=get(handles.pop_Layout,'UserData');
layoutfile=layoutfile{get(handles.pop_Layout,'Value')};

% Make Mfile
[msg, fname]=MakeMfile(handles);
if msg,return;end

%[p f e]=fileparts(fname);
%eval(f);
try
  %rehash TOOLBOX
  rehash
  % TODO : File IO
  [p,f]=fileparts(fname);if 0,disp(p);end
  [data, hdata] = eval(f);
catch
  msg={'Error in Making Data : ',['   ' lasterr]};
  return;
end

load(layoutfile,'LAYOUT');
% Draw Layout
%  :: rf) PluginWrapPM_Sample/checkdatatype
p3view(LAYOUT,hdata,data)

function ConnectAdvanceMode(handles,varargin)
% ==> Setup 
%     Edit (Multi-Ana) Constitument.

% get Advance Button-Position
hs=handles.advpsb_EditParentFile;
% Comment out : Meeting on 20-Apr-2007
%  handles.advpsb_MultiAna];
set(hs,'Visible','on');
if length(varargin)>0
  disp(mfilename);
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=SaveData(handles)
% Save Multi Analysis Data Status!
% Call from OspFilteCallbacks
% Load Selected File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg='';  
%========================
% Load Save-Data
%========================
actdata=getappdata(handles.figure1, 'LocalActiveData');

try
  % Reload Data
  actdata.data = feval(actdata.fcn, 'load', actdata.data);
  % Load Filter-Manager's Data
  mpf = P3_gui_MultiAnalysis('get',handles.figure1,0);
  actdata.data.data.Recipe=mpf;
catch
  msg=['Error in Making Save-Data : ' lasterr];
end

%========================
%% Save (Over Write)
%========================
try
  feval(actdata.fcn,'save_ow',actdata.data);
catch
  msg=['Error in Save-Data : ' lasterr];
  OSP_LOG('err',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Functin of Make-Multi Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_MLT_AnaFile_Callback(hs)
% File Select Popup-Menu! => Change AnaFile Informaiton
%  String   : File-Key
%  UserData : Cell-Structure of Ana-Data's (Loaded)

vl=get(hs.pop_MLT_AnaFile,'Value');
dt=get(hs.pop_MLT_AnaFile,'UserData');
dt=dt{vl};
info = OspFilterDataFcn('getInfo',dt.data(end).filterdata);
set(hs.lbx_MLT_AnaFileInfo,'Value',1,'String',info);


function EditParentFile(hs)
% 
% Making Select Key
anadata=get(hs.pop_MLT_AnaFile,'UserData');
k=DataDef2_Analysis('getIdentifierKey');
k=['anadata{idx}.' k ';'];
skey='';
for idx=1:length(anadata)
  t=eval(k);
  skey=[skey '(^' t '$)|'];
end
skey(end)=[];

% Change Data-Type
%str=get(hs.pop_filetype,'String');
%idx=find(strcmp(str,'Analysis'));
set(hs.pop_filetype,'Value',1); % Must be Ana
POTATo('ChangeProjectIO',hs.figure1,[],hs);
set(hs.edt_searchfile,'String',skey);
POTATo('edt_searchfile_Callback',hs.edt_searchfile,[],hs);



