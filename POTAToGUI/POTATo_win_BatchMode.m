function varargout=POTATo_win_BatchMode(fnc,varargin)
% POTATo Window : Signal-Analysis Mode Control GUI
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2008.03.25
% $Id: POTATo_win_BatchMode.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.19
%  * Bug-Fix : 080401A
%              080401B

%======== Launch Switch ========
switch fnc
  case {'DisConnectAdvanceMode','ChangeLayout'},
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'SaveData',
    varargout{1}=SaveData(varargin{:});
  case 'MakeMfile',
    varargout{1}=MakeMfile(varargin{:});
  case 'Export2WorkSpace'
    varargout{1}=Export2WorkSpace(varargin{:});
  case 'DrawLayout',
    varargout{1}=DrawLayout(varargin{:});
  case 'ConnectAdvanceMode'
    ConnectAdvanceMode(varargin{:});
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
% GUI Position ===> Move away
[hs,pos]=myHandles(handles);
suspend_comm(hs,pos, handles);
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end
  

function Activate(handles,varargin)
% Activation Batch-Mode

% GUI Position ===> Here
[hs,pos]=myHandles(handles);
activate_comm(hs,pos, handles);
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
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
  vls=get(handles.lbx_fileList,'Value');
  % ==> Select 1st Data to Edit
  actdata.data=filedata(vls(1));
end

%----------------------------
% Vislble on
%----------------------------
setappdata(handles.figure1, 'LocalActiveData',actdata);
%setappdata(handles.figure1, 'BATCH_FILEINDEX',vls);
setappdata(handles.figure1, 'BATCH_FILEDATA',filedata(vls));
OspFilterCallbacks('LocalActiveDataOn', [],[],handles);

%=============================
%% Filter-Manager Data Setting
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

%========================
%% Save Othere Functions
% (Over write)
%========================
%vls=getappdata(handles.figure1, 'BATCH_FILEINDEX');
%filedata=get(handles.lbx_fileList,'UserData');
filedata=getappdata(handles.figure1, 'BATCH_FILEDATA');

for idx=2:length(filedata)
%  actdata.data = feval(actdata.fcn, 'load', filedata(vls(idx)));
  actdata.data = feval(actdata.fcn, 'load', filedata(idx));
  actdata.data.data.filterdata=fmd;
  try
    feval(actdata.fcn,'save_ow',actdata.data);
  catch
    msg=['Error in Save-Data : ' lasterr];
    OSP_LOG('err',msg);
  end
end

function [msg, fname]=MakeMfile(handles)
% get File List
msg='';
% Make Multi-File-M-File
% === Get Datae ===
fmd      = OspFilterCallbacks('get',handles.figure1,false);
vls      = get(handles.lbx_fileList,'Value');
datalist = get(handles.lbx_fileList,'UserData');
datalist = datalist(vls);


% === Get File Name ===
if nargout<=1
  [f, p] = uiputfile( ...
    {'*.m','OutPut M-file (*.m)'}, ...
    'Multi File M-file Name', 'mfmf.m');
  % Cancel Check
  if isequal(f,0) || isequal(p,0),
    return;
  end

  % == Open M-File ==
  fname = [p filesep f]; %File Name : Fullpath
  fname0 = strfind(f,'.');
  % Make File-Name
  %   ==> fname0 : Function-Name
  switch length(fname0),
    case 0,
      fname0 = f;
      fname  = [fname '.m'];

    case 1,
      if (fname0==1),
        errordlg('Input Filename'); return;
      end
      if ~strcmp(f(fname0:end),'.m'),
        errordlg('Extention of File must be ''.m''!');
        return;
      end
      fname0  = f(1:(fname0-1));
      
    otherwise,
      errordlg('Double Extention exist!');
      return;
  end
else
  fname=OSP_DATA('GET','OSPPATH');
  fname0=[fname filesep 'ospData' filesep];
  fname= [fname0 'batch_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'batch_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x'; %#ok
  end
  [p,fname0]=fileparts(fname);
end

try
	[fid, fname] = make_mfile('fopen', fname,'w');
  %- - - - - - - - - - - -
	% Header And Comment
  %- - - - - - - - - - - -
  make_mfile('with_indent', ...
    ['function [data, hdata]=' fname0 '(varargin)']);
  make_mfile('with_indent', ...
    {'% Make P3 Data by Cell-array From Files.', ...
    ['% Syntax : [data, hdata]= ' fname0 ';'], ...
    '% data : ', ...
    '%   Cell Aray of P3 Data ',...
    '% hdata : ', ...
    '%   Cell Aray of Header of P3 Data' });
  make_mfile('with_indent','%');
  % Data Informaiton
  make_mfile('with_indent', '% == Batch-Mode Data-Information ==');
  % Project Information
  P3_Write_Mfile_Comment('projectInfo');
  if 0
    % Comment out : DR on 2008.03.07 (P3_50)
    % Data Information
    make_mfile('with_indent', '% Using RAW-Data-List');
    for idx0=1:length(datalist)
      rd=DataDef2_Analysis('load',datalist(idx0));
      make_mfile('with_indent', ['%   Name  : ' rd.data.name]);
    end
  end
  make_mfile('with_indent', '% ');
  make_mfile('with_indent', ['% Date : ' datestr(now,0)]);
  make_mfile('with_indent', '% ');
  make_mfile('with_indent', '% ');
  % Recipe Information
  P3_Write_Mfile_Comment('recipeInfo',fmd);
  make_mfile('with_indent','%');
  make_mfile('with_indent','% $Id: POTATo_win_BatchMode.m 180 2011-05-19 09:34:28Z Katura $');
  make_mfile('with_indent','');

	% Initialize
	make_mfile('code_separator',1)
	make_mfile('with_indent', '% Initialize Data');
	make_mfile('code_separator',1)
	make_mfile('with_indent', {'data={}; hdata={};', ' '});
	make_mfile('code_separator',3)
	make_mfile('with_indent', '% Arguments Check');
	
	% Getting File Info
  rd=DataDef2_Analysis('load',datalist(1));
  dname = DataDef2_RawData('getFilename',rd.data.name);
	make_mfile('with_indent', ...
		   ['datanames={ ''' dname ''', ...']);
	
	for idx=2:length(datalist)-1,
    rd=DataDef2_Analysis('load',datalist(idx));
    dname = DataDef2_RawData('getFilename',rd.data.name);
        make_mfile('with_indent', ...
		   ['            ''' dname ''', ...']);
  end
  dname = DataDef2_RawData('getFilename',datalist(end));
	make_mfile('with_indent', ...
		   ['            ''' dname '''};']);
	
	make_mfile('with_indent', ...
		   'for idx=1:length(datanames),');
	make_mfile('indent_fcn', 'down');
  make_mfile('with_indent', ...
    {'d = datanames{idx};', ...
    '[data{end+1}, hdata{end+1}] = ospfilt0(d);'});
	make_mfile('indent_fcn', 'up');
	make_mfile('with_indent', 'end');
  
  %------------------------------
  % add Viewer
  %  mail 2007.05.14
  %------------------------------
  if nargout<=1
    wk=get(handles.ckb_Draw,'Value');
    if wk
      make_mfile('code_separator',1);
      make_mfile('with_indent','% Viewer');
      make_mfile('code_separator',1);

      layoutfile=get(handles.pop_Layout,'UserData');
      layoutfile=layoutfile{get(handles.pop_Layout,'Value')};
      make_mfile('with_indent',...
        sprintf('load(''%s'',''LAYOUT'');',layoutfile));

      make_mfile('with_indent', ...
        'for idx=1:length(datanames),');
      make_mfile('indent_fcn', 'down');

      if ~isfield(fmd,'BlockPeriod') || ...
          ~isfield(fmd,'block_enable') || fmd.block_enable==false
        make_mfile('with_indent',...
          'P3_view(LAYOUT,hdata(idx),data(idx));');
      else
        % Block
        make_mfile('with_indent','% [Warning] : Continuous Data is Dummy!');
        make_mfile('with_indent',...
          {'P3_view(LAYOUT,hdata(idx),data(idx),...',...
          '          ''bhdata'',hdata{idx}, ''bdata'', data{idx});'});
      end
      make_mfile('indent_fcn', 'up');
      make_mfile('with_indent', 'end');
    end
  end

  make_mfile('with_indent', {'return;   % Main', ' ', ' '});
	
	% Function of Filter
	make_mfile('with_indent', ...
		'function [data, hdata]=ospfilt0(datanames)');
	P3_FilterData2Mfile(fmd);
  
  
catch
  try
    make_mfile('fclose');
  catch
    fclose(fid);
  end
	rethrow(lasterror);
end

% == Close M-File ==
make_mfile('fclose');

% B081216B
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

function msg=DrawLayout(handles)
% Draw Figues
msg='';
% Get Layout File
layoutfile=get(handles.pop_Layout,'UserData');
layoutfile=layoutfile{get(handles.pop_Layout,'Value')};
load(layoutfile,'LAYOUT');

%========================
%% Get Active Data
%========================
actdata=getappdata(handles.figure1, 'LocalActiveData');
%vls=getappdata(handles.figure1, 'BATCH_FILEINDEX');
%filedata=get(handles.lbx_fileList,'UserData');
filedata=getappdata(handles.figure1, 'BATCH_FILEDATA');

figh=[];
hoge={};
for idx=1:length(filedata)
  try
    % Evaluate Files
    fname=feval(actdata.fcn,'make_mfile',filedata(idx));
    [chdata, cdata, bhdata, bdata] = ...
      scriptMeval(fname,...
      'chdata', 'cdata', ...
      'bhdata', 'bdata');
    % Draw!
    if isempty(bhdata)
      h=osp_LayoutViewer(LAYOUT,chdata,cdata);
    else
      h=osp_LayoutViewer(LAYOUT,chdata,cdata, ...
        'bhdata',bhdata, 'bdata', bdata);
    end
    % =Check Figures
    figh(end+1)=h.figure1;
    hoge{end+1}=fname;
  catch
    msg='Cannot Make M-File';
  end
end
for idx=1:length(hoge)
  % disp(hoge{idx});
  try,delete(hoge{idx});end
end

%==> Figure Distribute ==>
n=length(figh);
pos0=get(figh(1),'Position');
poss=[pos0(1) ,pos0(2)+pos0(4)];
pose=[pos0(1)+pos0(3) ,pos0(2)];
posd=(pose - poss)./(n+3);
for idx=2:n
  pos0([1 2]) = pos0([1 2]) + posd;
  set(figh(idx),'Position',pos0);
end

fc=figure_controller;
hs=guidata(fc);
try
  for idx=1:n
   figure_controller('setFigureHandle',figh(idx),[],hs);
  end
catch
  if isempty(msg)
    msg='Cannot Open Figure Controller';
  end
end


function ConnectAdvanceMode(handles,varargin)
%
% Default : ADV-Mode
if 1,
  hs=[handles.advpsb_SetPosition, ...
    handles.advpsb_SetMark,...
    handles.advpsb_BenriButton,...
    handles.advtgl_1stLvlAna,...
    handles.advpsb_MultiAna];
else
  hs=[handles.advpsb_SetPosition, ...
    handles.advpsb_SetMark,...
    handles.advtgl_1stLvlAna,...
    handles.advtgl_2ndLvlAna];
end
set(hs,'Visible','on');
if length(varargin)>0
  disp(mfilename);
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

