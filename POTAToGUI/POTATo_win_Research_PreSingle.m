function varargout=POTATo_win_Research_PreSingle(fnc,varargin)
% POTATo Window : Signal-Analysis Mode Control GUI
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




%======== Launch Switch ========
global FOR_MCR_CODE;
advmode=true;

switch fnc
  case {'DisConnectAdvanceMode','ChangeLayout'},
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
    if advmode
      POTATo_win('DisConnectAdvanceMode',varargin{:});
    else
      hs=varargin{1};
      set(hs.psb_export_workspace,...
          'Visible','off',...
          'String','Export WS');
    end
  case 'Activate',
    if advmode
      ConnectAdvanceMode(varargin{:});
    end
    Activate(varargin{:});
    hs=varargin{1};
    if advmode
      hx=[...
        hs.psb_export_workspace,...
        hs.psb_MakeMfile,...
        hs.ckb_Draw,...
        hs.psb_EditLayout];
      set(hx,'Visible','on');
    else
      set(hs.psb_export_workspace,...
          'Visible','on',...
          'String','Export to File');
    end
  case 'SaveData',
    varargout{1}=SaveData(varargin{:});
  case 'MakeMfile',
    varargout{1}=MakeMfile(varargin{:});
  case 'Export2WorkSpace'
    if ~(FOR_MCR_CODE)
      varargout{1}=Export2WorkSpace(varargin{:});
    else
      varargout{1}=Export2WorkSpace2(varargin{:});
    end
  case 'DrawLayout',
    varargout{1}=DrawLayout(varargin{:});
  case 'ConnectAdvanceMode'
    ConnectAdvanceMode(varargin{:});
    
    %=========================
    % Special Functin List
    %=========================
  case 'CopyData',
    CopyData(varargin{1});
    
    %=========================
    % Unseting Function List
    %=========================
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

function [hs,pos]=myHandles(h)
% Return Entry Handle

pos0=get(h.frm_AnalysisArea,'Position');
pos1=get(h.frm_SinglAnaArea,'Position');
pos=pos0(1:2)-pos1(1:2);
hs=[h.text4,...
    h.pop_FilterDispKind, ...
    h.pop_FilterList, ...
    h.psb_addFiltData, ...
    h.lbx_FiltData, ...
    h.psb_HelpFiltData, ...
    h.psb_upFiltData, ...
    h.psb_downFiltData, ...
    h.psb_changeFiltData, ...
    h.psb_Suspend, ...
    h.psb_removeFiltData, ...
    h.psb_saveFiltData, ...
    h.psb_loadFiltData];
% TODO

function Suspend(handles,varargin)
[hs,pos]=myHandles(handles);
suspend_comm(hs,pos,handles);
if isfield(handles,'menu_SA_copydata'),
  %set(handles.menu_SA_copydata,'Visible','off');
  set(handles.menu_SA_copydata,'Enable','off');
end
if ~isempty(varargin)
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end
set(handles.psb_extended_search,'Visible','off');

function Activate(handles,varargin)
% Activate Single-Analysis Mode!
%=============================
% Move GUI : Current Position
%=============================
[hs,pos]=myHandles(handles);
activate_comm(hs,pos,handles);
set(handles.psb_extended_search,'Visible','on');
%-------------------------
% Copy-Data-Push Button
%-------------------------
if isfield(handles,'menu_SA_copydata'),
  % Enable
  set(handles.menu_SA_copydata,'Enable','on');
else
  % - - - -
  % Create
  % - - - -
  % get position..
  % p0=get(handles.psb_MakeMfile,'Position');
  % p0(2)=p0(2)+p0(4)+4;
  % uicontrol(handles.figure1,...
  %   'Units','pixels','Position',p0,...
  
  %   handles.menu_SA_copydata=...
  %     uimenu(handles.menu_Edit,...
  %     'Label','&Copy Data',...
  %     'Callback',...
  %     'POTATo_win_Research_PreSingle(''CopyData'',guidata(gcbf));');
  %   guidata(handles.figure1,handles);
end  
 
%=============================
% Filter-Manager Activate
%=============================
%-----------------------
% Make Local-Active-Data
%-----------------------
% get DataDef (II) Function
fcn=get(handles.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  actdata.fcn=fcn{get(handles.pop_filetype,'Value')};
  clear fcn;
end
% get Data-File
filedata=get(handles.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
else
  actdata.data=filedata(get(handles.lbx_fileList,'Value'));
  clear filedata;
end

%----------------------------
% Vislble on
%----------------------------
setappdata(handles.figure1, 'LocalActiveData',actdata);
OspFilterCallbacks('LocalActiveDataOn', [],[],handles);

%=============================
% Filter-Manager Data Setting
%=============================
% Load (Real) Data 
actdata.data = feval(actdata.fcn, 'load', actdata.data);

% -- Reset, Filter List --
% Load Selected File
try
  if ~isempty(actdata.data.data),
    % Filte Manage Data
    fmd = actdata.data.data.filterdata; 
    OspFilterCallbacks('set',handles.figure1, fmd);
  else
    OspFilterCallbacks('set',handles.figure1, []);
  end
catch
  OSP_LOG('err',lasterr, 'Loading Filter Data');
  rethrow(lasterror);
end
if ~isempty(varargin)
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

try
  % Try to Open Help
  OspFilterCallbacks('pop_FilterList_Callback',...
    handles.pop_FilterList,[],handles);
catch
end

function msg=SaveData(handles)
% Save Single Analysis Data Status!
% Call from OspFilteCallbacks
% Load Selected File
msg='';  
%========================
%% get Save-File
%========================
actdata=getappdata(handles.figure1, 'LocalActiveData');

%========================
%% Make Active Data
%========================
%actdata.fcn  = @DataDef2_Analysis;
%actdata.data = svfile;
%disp(['Save : ' actdata.data.filename]);
try
  % Reload Data
  actdata.data = feval(actdata.fcn, 'load', actdata.data);
  % Load Filter-Manager's Data
  fmd = OspFilterCallbacks('get',handles.figure1,0);
  actdata.data.data.filterdata=fmd;
catch
  msg=['Error in Making Save-Data : ' lasterr];return;
end

%========================
%% Save (Over Write)
%========================
try
  feval(actdata.fcn,'save_ow',actdata.data);
catch
  msg=['Error in Save-Data : ' lasterr];return;
end
%setappdata(handles.figure1, 'LocalActiveData',actdata);

%========================
%% Update!
%========================
% data must be reload, 
% In this Block, do nothing but a comment.

function [msg, fnametmp]=MakeMfile(handles)
% get File List
msg='';

fdata=get(handles.lbx_fileList,'UserData');
fdata=fdata(get(handles.lbx_fileList,'Value'));

dfnc=get(handles.pop_filetype,'UserData');
dfnc=dfnc{get(handles.pop_filetype,'Value')};
for idx=1:length(fdata),
  % -- File name Get --
  if nargout<=1,
    % == Get M-File Name==
    [f p] = osp_uiputfile('*.m', ...
      'Output M-File Name', ...
      ['POTATo_' datestr(now,30) '.m']);
    if (isequal(f,0) || isequal(p,0)), return; end % cancel
    fname = [p filesep f];
  end
  % Make M-File
  try
    fnametmp=feval(dfnc,'make_mfile',fdata(idx));
    if nargout<=1,
      movefile(fnametmp,fname);
    end
  catch
    msg=lasterr;return;
  end
end
%------------------------------
% add Viewer
%  mail 2007.05.14
%------------------------------
wk=get(handles.ckb_Draw,'Value');
if nargout<=1 && wk
  % --> get Layout-File
  layoutfile=get(handles.pop_Layout,'UserData');
  layoutfile=layoutfile{get(handles.pop_Layout,'Value')};
  
  make_mfile('fopen',fname,'a');
  try
    make_mfile('code_separator',1);
    make_mfile('with_indent','% Viewer');
    make_mfile('code_separator',1);
    make_mfile('with_indent',...
      sprintf('load(''%s'',''LAYOUT'');',layoutfile));
    make_mfile('with_indent',...
      {'if ~exist(''bhdata'',''var'') || isempty(bhdata)',...
      '  P3_view(LAYOUT,chdata,cdata);',...
      'else',...
      '  P3_view(LAYOUT,chdata,cdata, ...',...
      '           ''bhdata'',bhdata, ''bdata'', bdata);',...
      'end'});
  catch
    make_mfile('fclose');rethrow(lasterror);
  end
  make_mfile('fclose');
end

% Editor
%  mail 2007.05.14
if nargout<=1,edit(fname);end

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

%=============================================================
% 2014.03 : Export to File
function msg=Export2WorkSpace2(hs)
% Export to File
%-------------------------------------------------------------

[msg, fnametmp]=MakeMfile2(hs);
if ~isempty(msg),return;end
try
  %scriptMevalin(fnametmp);
	scriptMeval(fnametmp);
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

function [msg, fnametmp]=MakeMfile2(handles)
% Make M-File with FilterData
%-------------------------------------------------------------
msg='';

%========================
% get Current-Data
%========================
actdata=getappdata(handles.figure1, 'LocalActiveData');
try
  % Reload Data
  actdata.data = feval(actdata.fcn, 'load', actdata.data);
  % Load Filter-Manager's Data
  fmd = OspFilterCallbacks('get',handles.figure1,0);
  actdata.data.data.filterdata=fmd;
catch
  msg=['Error in Making Save-Data : ' lasterr];return;
end

try
  key.actdata=actdata;
  %  Add FilterData
  %fmd=AddFilterData2List(FilterData,fmd);
  key.filterManage=fmd;
  fnametmp=feval(actdata.fcn,'make_mfile',key);
catch
  msg=lasterr;return;
end
% Filter Update
fmd=uigetFilterData(fmd,fnametmp);
try
	delete(fnametmp);
end
% Ä“xì¬
try
  key.filterManage=fmd;
  fnametmp=feval(actdata.fcn,'make_mfile',key);
catch
  msg=lasterr;return;
end


function fmd=AddFilterData2List(FilterData,fmd)
% -- cf) P3R1gui_OptionRecipe
%-------------------------------------------------------------
rg=FilterData.region;
if rg==-1
  % Block Filter
  fmd.block_enable=true;
  fmd.TimeBlocking={FilterData.Filter};
  fmd.BlockPeriod =FilterData.Filter.argData.BlockPeriod;
  if isfield(fmd,'BlockData')
    fmd=rmfield(fmd,'BlockData');
  end
  return;
end
% Set to last
Regions={'Raw', 'HBdata', 'BlockData'};
setflg=false;
for ii=length(rg):-1:1
	r=rg(ii);
	if r==3 && ~fmd.block_enable
		continue;
	end
	if isfield(fmd,Regions{r})
		fmd.(Regions{r}){end+1}=FilterData.Filter;
	else
		fmd.(Regions{r})={FilterData.Filter};
	end
	setflg=true;
	break;
end
if setflg==false
	% “KØ‚ÈˆÊ’u‚ÉWork-space-out Filter‚ðÝ’è‚Å‚«‚È‚©‚Á‚½
	warning('Can not execute Export to File. change recie please.');
end

function fdm=uigetFilterData(fdm,fname)
% get Filter-Data by GUI
fdm=uigetFilterData_ExportData(fdm,fname);
%disp('TODO:');
%disp(C__FILE__LINE__CHAR);
return;
%=============================================================

function msg=DrawLayout(handles)
% Get Layout File
layoutfile=get(handles.pop_Layout,'UserData');
layoutfile=layoutfile{get(handles.pop_Layout,'Value')};

[msg, fname]=MakeMfile(handles);
if msg,return;end

%[p f e]=fileparts(fname);
%eval(f);
try
  [chdata, cdata, bhdata, bdata] = ...
    scriptMeval(fname,...
    'chdata', 'cdata', ...
    'bhdata', 'bdata');
catch
  if 0
    errordlg({'Error in Making Data : ',...
      ['   ' lasterr]},'Error : Make Data');
  else
    msg={'Error in Making Data : ',['   ' lasterr]};
    return;
  end
end

load(layoutfile,'LAYOUT');

if isempty(bhdata)
    osp_LayoutViewer(LAYOUT,chdata,cdata);
else
  osp_LayoutViewer(LAYOUT,chdata,cdata, ...
    'bhdata',bhdata, 'bdata', bdata);
end

function ConnectAdvanceMode(handles,varargin)
% ==> Setup 
%     Position Setting Button
%     Mark Setting Button

%global FOR_MCR_CODE;
advmode=true;
% get Advance Button-Position
if ~(advmode)
  hs=[handles.advpsb_SetPosition, ...
    handles.advpsb_BenriButton];
else
  hs=[handles.advpsb_SetPosition, ...
    handles.advpsb_SetMark,...
    handles.advpsb_BenriButton];
%    handles.advtgl_1stLvlAna];
end
% Comment out : Meeting on 20-Apr-2007
%  handles.advpsb_MultiAna];
set(hs,'Visible','on');
if ~isempty(varargin)
  disp(mfilename);
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end


%===========================
function CopyData(handles)
% P3-Copy Ana Data
%===========================

%-----------------
% Save Current Data
%-----------------
msg=SaveData(handles);
if msg,errordlg(msg);end

%------------------
% Load Current Data
%------------------
actdata=getappdata(handles.figure1, 'LocalActiveData');
% Reload Data
actdata.data = feval(actdata.fcn, 'load', actdata.data);
% Load Filter-Manager's Data
fmd = OspFilterCallbacks('get',handles.figure1,0);
actdata.data.data.filterdata=fmd;

%------------------
% Load Current Data
%------------------
prmpt={'Enter New File Name.'};
numlines=1;
name0=actdata.data.filename;
name={['Copy_' actdata.data.filename]};
flg=true;
while flg
  name=inputdlg(prmpt,'NewFileName',numlines,name);
  % Cancel
  if isempty(name),break;end
  % mod data
  % save Key
  try
    actdata.data.filename=name{1};
    DataDef2_Analysis('save',actdata.data);
    flg=false;
  catch
    helpdlg(lasterr,'Save-Error');
  end
end

if flg,return;end
%------------------
% Filnalize
%------------------
% Logging
P3_AdvTgl_status('Logging',handles,...
  [' Copy ' name0 ' to ' name{1}]);
% ==> Project Reset
POTATo('ChangeProjectIO',handles.figure1,[],handles);
  
