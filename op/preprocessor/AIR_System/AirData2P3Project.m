function varargout = AirData2P3Project(varargin)
% Air - POTATo I/O Function.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 14-Jun-2007 16:01:33


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2007.06.14
% $Id: AirData2P3Project.m 180 2011-05-19 09:34:28Z Katura $
%
% Revition 1.1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AirData2P3Project_OpeningFcn, ...
                   'gui_OutputFcn',  @AirData2P3Project_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End initialization code -
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================================================
function AirData2P3Project_OpeningFcn(h,ev,hs, varargin)
% Open : Select-Default-Project & waitfor user-responce
%==========================================================================

% Escape: Double Open..
if isfield(hs,'output') && hs.output==false, return;end

%----------------------------
% Setting...
%----------------------------
hs.output = false;hs.figure1= h;
set(h,'Color',[0.92,0.96,0.99],...
  'Renderer','OpenGL');
hs.txt_PrjStatus=uicontrol(...
  'Style','text',...
  'BackgroundColor',[0.9 0.94 0.5],...
  'Units','Characters',...
  'Position',[ 61.5   25.8   10    1]);
  
% Update handles structure
guidata(h, hs);

%--------------------------------
% Try-to-Load Default AIR-Systems
%---------------------------------
defh='C:\AirControlCenterDataBase\SaveData\AirSaveInfoManager.asimtable';
SetAirPath(hs,defh);
%---------------------------------
% Try-to-Open Project
%---------------------------------
openProject(hs)

if ~isempty(varargin),warndlg('Unknown Arguments');return;end
% Waitfor Exit / Finish.
if 1
  set(h,'WindowStyle','modal')
  uiwait(h);
end

%--> Dumy Function List for M-Lint
if 0,
  checkbox3_Callback(hs.checkbox3,ev,hs);
  lbx_AirInfo_Callback(hs.lbx_AirInfo,ev,hs);
  
  % Air Data Path Setting
  psb_AirDataPath_brows_Callback(hs.psb_AirDataPath_brows,ev,hs)
  edt_AirDataPath_Callback(hs.edt_AirDataPath,ev,hs)

  % Project Data
  edit_name_Callback(hs.edit_name,ev,hs)
  edit_ope_Callback(hs.edit_ope,ev,hs)
  edit_date_Callback(hs.edit_date,ev,hs)
  edit_coment_Callback(hs.edit_coment,ev,hs)

  % I/O
  psb_Import_Callback(hs.psb_Import,ev,hs)
  psb_Exit_Callback(hs.psb_Exit,ev,hs)
end


%==========================================================================
function varargout = AirData2P3Project_OutputFcn(h,ev,hs)
%==========================================================================
% Get default command line output from handles structure
varargout{1} = hs.output;
delete(h);
if 0,disp(ev);end

function psb_Exit_Callback(h,ev,hs)
hs.output=false; % False : Cancel
%--------------
% Close Figure
%--------------
guidata(hs.figure1, hs);
if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
if 0,disp(h);disp(ev);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dumy // not in use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkbox3_Callback(h,ev,hs)
if 0,disp(h);disp(hs);disp(ev);end
function lbx_AirInfo_Callback(h,ev,hs)
if 0,disp(h);disp(hs);disp(ev);end
function edit_ope_Callback(h,ev,hs)
if 0,disp(h);disp(hs);disp(ev);end
function edit_date_Callback(h,ev,hs)
if 0,disp(h);disp(hs);disp(ev);end
function edit_coment_Callback(h,ev,hs)
if 0,disp(h);disp(hs);disp(ev);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Air - Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=SetAirPath(hs,myfile)
% Set : AirSaveInfoManager
msg='';
set(hs.edt_AirDataPath,'String',myfile);
%------------------
% File Exist Check.
%------------------
if ~exist(myfile,'file')
  ud=get(hs.edt_AirDataPath,'UserData');
  if isempty(ud),ud='';end
  set(hs.edt_AirDataPath,...
    'ForegroundColor','red',...
    'String',ud);
  return;
end

%------------------
% Loding..
%------------------
set(hs.lbx_AirInfo,'Value',1,'String','Now Loading...');
data=readAirSaveInfoManager(myfile);
str={'===================================',...
  sprintf(' %s File : ver %s',data.key,data.ver),...
  '===================================',...
  sprintf(' Number of Data : %d',data.n),...
  '-----------------------------------'};
for idx=1:data.n
  f=data.file(idx);
  str{end+1}=sprintf(...
    '[%s] - [%s] / %s (%s)',...
    f.topdir,f.enddir, f.name,f.key);
end
%------------------
% Show Listbox
%------------------
set(hs.lbx_AirInfo,'Value',1,'String',str,'UserData',{data});
set(hs.edt_AirDataPath,...
  'UserData',myfile,...
  'String',myfile,...
  'ForegroundColor','black');
setappdata(hs.figure1,'AIR_DATAPATH',fileparts(myfile));

function edt_AirDataPath_Callback(h,ev,hs)
% Modify Path
SetAirPath(hs,get(h,'String'));
if 0, disp(ev);end
function psb_AirDataPath_brows_Callback(h,ev,hs)
% Brows Air-Data-Path

% uigetfile
f=get(hs.edt_AirDataPath,'String');
p=fileparts(f);if isempty(p),p=pwd;end
cwd=pwd;
try
  cd(p);
  [fname,pname] = uigetfile(...
    {'AirSaveInfoManager.asimtable','Save Information'},...
    'get Save Inromation Manager File');
catch
  cd(cwd);return;
end
cd(cwd);
if isequal(fname,0) || isequal(pname,0), return;end

% Set Path
SetAirPath(hs,[pname filesep fname]);
if 0,disp(h);disp(ev);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P3-Project Data I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_name_Callback(h,ev,hs)
openProject(hs);
if 0,disp(h);disp(ev);end
%--------------------------------------------------------------------------
function openProject(hs,newflag)
% Try-to-Open Project
%--------------------------------------------------------------------------
if nargin<2,  newflag=false; end
Project=POTAToProject('LoadData');
pj=getProjectData(hs);
pjidx=strmatch(pj.Name,{Project.Name},'exact');

%-------------------------
% ReOpen Project
%-------------------------
if ~isempty(pjidx)
  % There is Project
  POTAToProject('Select',pjidx);
  setProjectData(Project(pjidx),hs);
  set(hs.txt_PrjStatus,'String','Open');
  return;
end

%-------------------------
% New Project
%-------------------------
set(hs.txt_PrjStatus,'String','New');

% New Project...
set(hs.edit_date,  'String',datestr(now));
if newflag
  % Make-New Project
  pj=POTAToProject('Add',pj);
  if isempty(pj),
    error('Could not Make Project');
  end
end

function pj=getProjectData(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Project Data From GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1, handles = guihandles(gcbo);end
pj.Ver  = 2.0;
pj.Name = get(handles.edit_name,'String');
pj.Path=OSP_DATA('GET','PROJECTPARENT');
%pj.CreateDate=datenum(get(handles.edit_date,  'String'));
pj.CreateDate=now;
pj.Operator = get(handles.edit_ope,'String');
pj.Comment  = get(handles.edit_coment,'String');
return;

function pj=setProjectData(pj, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Project Data From GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <= 1
  handles = guihandles(gcbo);
end
set(handles.edit_name,  'String',pj.Name);
%set(handles.edit_path,  'String',pj.Path);
set(handles.edit_date,  'String',datestr(pj.CreateDate));
set(handles.edit_ope,   'String',pj.Operator);
set(handles.edit_coment,'String',pj.Comment);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Impotrt!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function psb_Import_Callback(h,ev,hs)
%==========================================================================

% Get Import Path
p=getappdata(hs.figure1,'AIR_DATAPATH');
if isempty(p) || ~exist(p,'dir')
  errordlg('No Data Directory exist.');
  return;
end

% Open Project to Import 
openProject(hs,true);
% Execute Import
[msg,slog]=AirImportMain(p,hs);

% Show Result
helpdlg(slog,'Import Logs : ');
if isempty(msg)
  % Close File
  hs.output=true;
  guidata(hs.figure1, hs);
  if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
    uiresume(hs.figure1);
  else
    delete(hs.figure1);
  end
else
  errordlg(msg,'Import Error : ');
end
if 0,disp(h);disp(ev);end



