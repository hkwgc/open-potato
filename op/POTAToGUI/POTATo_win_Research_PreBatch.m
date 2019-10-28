function varargout=POTATo_win_Research_PreBatch(fnc,varargin)
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
% create : 2010.11.09
global FOR_MCR_CODE;

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
    if ~(FOR_MCR_CODE)
      hs=varargin{1};
      hx=[...
        hs.psb_export_workspace,...
        hs.psb_MakeMfile,...
        hs.ckb_Draw,...
        hs.psb_EditLayout];
      set(hx,'Visible','on');
    end
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
  case {'psb_RPBatch_GrandAveragePlot_Callback'}
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
set(handles.txt_fileListNum,'Visible','off');
set(handles.psb_extended_search,'Visible','off');
set(handles.psb_RPBatch_GrandAveragePlot,'Visible','off');

function Activate(handles,varargin)
% Activation Batch-Mode

% Mail 20010.12.24
 set(handles.advpsb_BenriButton,'Visible','on');
 set(handles.psb_extended_search,'Visible','on');
% Grand Avarage
tag='psb_RPBatch_GrandAveragePlot';
if ~isfield(handles,tag) || ~ishandle(handles.(tag))
  p=get(handles.psb_drawdata,'Position');
  p(3)=70;
  p(1)=p(1)-p(3)-5;
  handles.(tag)=uicontrol(handles.figure1,'TAG',tag,...
    'Units','pixels',...
    'style','pushbutton',...
    'FontUnit','pixels','FontSize',10,...
    'String','Plot Average',...
    'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
    'Position',p);
  guidata(handles.figure1,handles);
else
  set(handles.psb_RPBatch_GrandAveragePlot,'Visible','on');
end

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
  % Update Selected File Number
  l=length(get(handles.lbx_disp_fileList,'String'));
  set(handles.txt_fileListNum,'Visible','on',...
    'String',sprintf('Selected:%d/%d',length(vls),l));
end

%----------------------------
% Vislble on
%----------------------------
setappdata(handles.figure1, 'LocalActiveData',actdata);
%setappdata(handles.figure1, 'BATCH_FILEINDEX',vls);
setappdata(handles.figure1, 'BATCH_FILEDATA',filedata(vls));
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
global FOR_MCR_CODE;
if FOR_MCR_CODE
  msg='Can not Execute Make-Mfile for MCR';
  fname='';
  return;
end
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
  make_mfile('with_indent','% $Id: POTATo_win_Research_PreBatch.m 393 2014-02-03 02:19:23Z katura7pro $');
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

function psb_RPBatch_GrandAveragePlot_Callback(hs)
% Draw Grand-Average..
msg=SaveData(hs);
if msg
  errordlg(msg);return;
end
%========================
% Get Active Data
%========================
actdata=getappdata(hs.figure1, 'LocalActiveData');
filedata=getappdata(hs.figure1, 'BATCH_FILEDATA');
ll=length(filedata);
idkey  = feval(actdata.fcn,'getIdentifierKey');
try
  ii=1;
  fname=feval(actdata.fcn,'make_mfile',filedata(ii));
  [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
    'chdata', 'cdata', 'bhdata', 'bdata');
catch
  try
    delete(fname);
  catch
  end
  errordlg(lasterr);
  return;
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
    fname=feval(actdata.fcn,'make_mfile',filedata(ii));
    [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
      'chdata', 'cdata', 'bhdata', 'bdata');
    data0=PlugInWrap_Flag2NaN('exe0',bdata,bhdata);

    if isempty(bhdata)
      warning('Ignore Non-Blocking Data');
      continue;
    end
    % Add Stim?
    n=setdiff(bhdata.stimkind,stimkind);
    if ~isempty(n)
      stimkind(end+1:end+length(n))=n;
    end
    sz0=size(data0);

    % Check size
    if ~isequal(sz0(3:end),sz(3:end))
      warning('Current Version : Data size must be same');
      disp([' Data size of ' filedata(1).(idkey) ':'])
      disp(sz);
      disp([' Data size of ' filedata(ii).(idkey) ':'])
      disp(size(data0));
      continue;
    end

    % Check Stim DIff
    stimdiff0=(bhdata.stim(2)-bhdata.stim(1))*bhdata.samplingperiod;
    if abs(stimdiff-stimdiff0)>OSP_STIMPERIOD_DIFF_LIMIT
      s=sprintf(['[W] Ignore Stimulation Period vary a great deal.\n', ...
        '    Max is %6.3f [sec]\n', ...
        '    Min is %6.3f [sec]\n'], ...
        max(stimperiod)/1000,min(stimperiod)/1000);
      warning(s);continue;
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
      
      if (size(dnum,1)<idx)
        dnum(idx,idx1,:,:)=sum(~dnan);
        data(idx,idx1,:,:)=sum(tmp);
        try
          flag(1,idx,:,:)=sum(bhdata.flag(1,bid,:),2);
        catch
        end
      else
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
  %if fsz(2)>1,
  if fsz(2)>=1
    try, hdata.stimTC2(2:end,:)=[];end
    try, hdata.stimkind=stimkind;end
    dn=sum(sum(dnum),4);
    try,dn=reshape(dn,[1,1,fsz(3)]);end
    try, hdata.flag=(dn==0);end
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
  errordlg('Plot average is for Blocked Data');
end




