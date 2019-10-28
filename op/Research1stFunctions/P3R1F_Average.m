function varargout=P3R1F_Average(fcn,varargin)
% POTATo : Research Mode 1st-Level-Analysis Function "Average"

% == History ==
%  2010.11.15 : New! (for testing....)

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'createBasicInfo','CreateGUI',...
      'Activate','Suspend',...
      'MakeExeData','SetExeData',...
      'execute'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case {'myhandles'}
    % for debug
    disp('Debug Path');
    disp(C__FILE__LINE__CHAR);
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  otherwise
    error('Not Implemented Function : %s',fcn);
end

%##########################################################################
function basic_info=createBasicInfo()
% Get Basic-Info of this function
%##########################################################################
basic_info.name = 'Average';   % Display-Name 
basic_info.ver  = 1.5;          % Version (double)
basic_info.fcn  = mfilename;    % Function-Name

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tag)
% Tool : make unique tagname.
tag=[tag '_' mfilename];

%==========================================================================
function hs=CreateGUI(hs)
% Create Related GUI
%==========================================================================

%----------------------
% Set GUI Common Property.
%----------------------
c=get(hs.figure1,'Color');
prop={'Units','pixels','Visible','off'};
prop_t={prop{:},'style','text',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c};

%----------------------
% Get GUI Position...
%----------------------
%p0=get(hs.frm_R1stExecution,'Position');
pt=get(hs.txt_R1st_ExecuteName,'Position');
pp=get(hs.pop_R1st_ExecuteName,'Position');
sx2=pt(1); y=pp(2);
xsize=pt(3);

iy=3;ix=10;
apidata={};
%----------------------
% Get GUI Position...
%----------------------
dy=20; y=y-dy-iy;

% Preriod Setting
xsize2=xsize/2-2*ix;
sx3=sx2+xsize2+ix;
if 0
  dy=20;y=y-dy-iy;
  tag=mytag('txt_R1st_Period');
  hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
    'String','Mean-Period:',...
    'Position',[sx2 y xsize2 dy]);
  tag=mytag('edt_R1st_Period');
  hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
    'style','edit','BackgroundColor',[1 1 1],...
    'HorizontalAlignment','left',...
    'String','1:end',...
    'Position',[sx3 y xsize2 dy]);
end

% Set Grou-ping
dy=20; y=y-dy-iy;
tag=mytag('keygrouping');
[hs, apidata{end+1}]=P3R1gui_KeyGrouping('CreateGUI',hs,tag,...
  [sx2 y xsize dy]);

% Recipe
% -- Blocking --
dy=20; y=y-dy-2*iy;
tag=mytag('block');
% Default Blocking Filter Data
filData.name='Blocking';
filData.wrap='FilterDef_TimeBlocking';
filData.enable='on';
filData.argData.BlockPeriod=[5 15];
filData.argData.Marker     ='All';
filData.argData.wrap       ='FilterDef_TimeBlocking';

filterData.fcn       ='FilterDef_TimeBlocking';
filterData.usealways =true;
filterData.region    =-1;
filterData.default   =filData;
filterData.Before    ={};
[hs, apidata{end+1}]=P3R1gui_OptionRecipe('CreateGUI',hs,tag,...
  [sx2 y xsize dy],filterData,'String','Blocking');

% -- Baseline Correction --
dy=20; y=y-dy-2*iy;
tag=mytag('baseline');
% Default Baseline-Correction
filData.name='Baseline Correction';
filData.wrap='FilterDef_LocalFitting';
filData.enable='on';
filData.argData=struct('Degree',1,...
  'UnFitPeriod','[m1:m2]');

filterData.fcn          = 'FilterDef_LocalFitting';
filterData.usealways    = false;
filterData.region       = 3;
filterData.default      = filData;
filterData.Before{end+1}=apidata{end};
[hs, apidata{end+1}]=P3R1gui_OptionRecipe('CreateGUI',hs,tag,...
  [sx2 y xsize dy],filterData,'String','Basiline Correction');

% -- PeakSearch --
dy=20; y=y-dy-2*iy;
tag=mytag('peaksearch');
filterData.fcn          = 'PlugInWrap_PeakSearch';
filterData.usealways    = false;
filterData.region       = 3;
filterData.default      = [];
filterData.Before{end+1}=apidata{end};
[hs, apidata{end+1}]=P3R1gui_OptionRecipe('CreateGUI',hs,tag,...
  [sx2 y xsize dy],filterData,'String','Period for Averaging');

% Check-Box
dy=20;y=y-dy-iy;
tag=mytag('ckb_R1st_ApplyFlag');
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','checkbox',...
  'String','Apply Flags',...
  'Value',1,...
  'Position',[sx2+2*ix y xsize-2*ix dy]);

%dy=20;y=y-dy-iy;
tag=mytag('drawgrandaverage');
p=fileparts(which('P3R1gui_DrawButton'));
ud.mode=0;
ud.Layout=[p filesep 'LAYOUT_P3R1gui_DrawButton_GA.mat'];
ud.Before=filterData.Before;
ud.Before{end+1}=apidata{end};
[hs, apidata{end+1}]=P3R1gui_DrawButton('CreateGUI',hs,tag,[sx3 y xsize2 dy],...
  'UserData',ud);

% Save API Data
setappdata(hs.figure1,mfilename,apidata);

%==========================================================================
function h=myhandles(hs)
% My Handle List
%==========================================================================
if 0
  h=[hs.(mytag('txt_R1st_Period')),...
    hs.(mytag('edt_R1st_Period')),...
    hs.(mytag('ckb_R1st_ApplyFlag')),...
    ];
else
  h=hs.(mytag('ckb_R1st_ApplyFlag'));
end
%==========================================================================
function h=Activate(hs,sdt)
% My GUI Visible On
%==========================================================================
if sdt==3
  P3_gui_Research_1st('disable_execution',hs,...
    {'Error:','Continuous/Block Mixed'});
  return;
end

h=myhandles(hs);
set(h,'Visible','on');

% Suspend API's
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    [h,sdt]=feval(apidata{ii}.fcn,'Activate',hs,apidata{ii},sdt);
  catch
  end
end

%==========================================================================
function h=Suspend(hs)
% My GUI Visible Off
%==========================================================================
h=myhandles(hs);
set(h,'Visible','off');
% Suspend API's
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    feval(apidata{ii}.fcn,'Suspend',hs,apidata{ii});
  catch
  end
end

%##########################################################################
% GUI Callbacks
%##########################################################################
% (Nothing to do in this function)

%##########################################################################
% GUI <--> ExeData
%##########################################################################

%==========================================================================
function ExeData=MakeExeData(hs)
% Get Parameter's of 1st-Level-Analysis Execution
%==========================================================================
if 0
  ExeData.P1=...
    get(hs.(mytag('edt_R1st_Period')),'String');
end
ExeData.ApplyFlag=...
  get(hs.(mytag('ckb_R1st_ApplyFlag')),'Value');
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    ExeData.([apidata{ii}.fcn num2str(ii)])=...
      feval(apidata{ii}.fcn,'MakeExeData',apidata{ii});
  catch
  end
end
ExeData.oldapidata=apidata; % for Normal-Group

%==========================================================================
function r=SetExeData(hs,ExeData)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
try
  %set(hs.(mytag('edt_R1st_Period')),'String',ExeData.P1);
  set(hs.(mytag('ckb_R1st_ApplyFlag')),'Value',ExeData.ApplyFlag);
catch
  r=1;
end
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    feval(apidata{ii}.fcn,'SetExeData',apidata{ii},...
      ExeData.([apidata{ii}.fcn num2str(ii)]));
  catch
  end
end

%##########################################################################
% Execution
%##########################################################################
function datar=execute(datar)
% Execute 1st-Level-Analysis
%
% Input : datar
%       datar.nfile    : number of files
%       datar.Anafiles : Analysis-File (with Recipe)
%       datar.ExeData  : Parameter's that seted by MakeData
% Output : datar
%       datar.Header     : Cell Header of Summarized Data
%       datar.Summarized : Cell Summarized Data

% Convert Our ExeData to Common-ExeData
ed0=datar.ExeData;
ev='if (~exist(''psdata'') || isempty(psdata)) ,psdata=data;end;D= nan_fcn(''mean'',psdata(:,:,:,:),2);clear psdata;';
fs=fieldnames(ed0);
for ii=1:length(fs)
  try
    % Modify
    switch fs{ii}
      case {'P1'}
        if isempty(ed0.(fs{ii}))
          ev=strrep(ev,fs{ii},':');
        else
          ev=strrep(ev,fs{ii},ed0.(fs{ii}));
        end
      case {'ApplyFlag'}
        ed.(fs{ii})=ed0.(fs{ii});
    end
  catch
  end
end
ed.ExecuteString=ev;
datar.ExeData=ed;

apidata=ed0.oldapidata;
for ii=1:length(apidata)
  try
    datar=feval(apidata{ii}.fcn,'execute',datar,...
      ed0.([apidata{ii}.fcn num2str(ii)]));
  catch
  end
end
datar.SSFcn=mfilename;
datar=dofirst(datar);
datar.ExeData=ed0;

function [datar logmsg]=dofirst(datar)
% Execute 1st-Level-Analysis
%
% Input : datar
%       datar.nfile    : number of files
%       datar.Anafiles : Analysis-File (with Recipe)
%       datar.ExeData  : Execution Parameter
%       datar.ExeData.ExecuteString ( Execute String)
%       datar.ExeData.ApplyFlag ( Check Flag or not)
%       datar.ExeData.GroupInfo
%       datar.ExeData.OptionRecipe
% Output : datar
%       datar.Header     : Cell Header of Summarized Data
%       datar.Summarized : Cell Summarized Data

if ~isfield(datar.ExeData,'GroupInfo')
  [datar,logmsg]=P3R1F_Evaluate('dofirst',datar);
  return;
end

logmsg={'---- 1st Level Analysis (Evaluate -in Average - Version 0.0 ---'};
dfcn='DataDef2_Analysis'; % Data-Function
idkey  = feval(dfcn,'getIdentifierKey');

dlist=feval(dfcn,'loadlist');
fns=fieldnames(dlist);
Header={'Block','Stim',fns{:}};
SummarizedKey ={};
SummarizedData={};
blkkey=[]; % SearchKey for Block (2010_2_RA06-1)
for ii=1:length(fns)
  if ~isstruct(dlist(1).(fns{ii})), continue; end
  tmp=dlist(1).(fns{ii});
  if ~isfield(tmp,'Type'), continue; end
  if any(strcmpi({'NumericB','TextB'},tmp.Type))
    blkkey(end+1)=ii;
  end
end

if isfield(datar.ExeData,'ApplyFlag') && datar.ExeData.ApplyFlag
  apflag=true;
  logmsg{end+1}=sprintf(' * Flag : Apply');
else
  apflag=false;
end

X=0;
DX=1/datar.nfile;
for gid=1:datar.ExeData.GroupInfo.Number
  fids=find(datar.ExeData.GroupInfo.ID==gid);
  renewflg=true;
  % 
  for fid=fids(:)'
    X=X+DX;
    %===============================
    % Load Analysis Data
    %===============================
    myname=datar.AnaFiles{fid}.(idkey);
    tmps00=dlist(strcmp({dlist.(idkey)},myname));
    if renewflg
      for fid0=2:length(fids)
        tmps00.(idkey)=[tmps00.(idkey) '_' datar.AnaFiles{fid0}.(idkey)];
      end
      tmps=struct2cell(tmps00);
      renewflg=false;
    else
      tmps00=struct2cell(tmps00);
      tmps(blkkey)=tmps00(blkkey);
    end
    
    logmsg{end+1}=sprintf('Start %s',myname);
    P3_waitbar(X,logmsg(end));
    key.actdata.data=datar.AnaFiles{fid};
    % Filter
    fmd=datar.AnaFiles{fid}.data.filterdata;
    try
      if isfield(datar.ExeData,'OptionRecipe')
        for ori=1:length(datar.ExeData.OptionRecipe)
          fmd=P3R1gui_OptionRecipe('updateFilterManageData',...
            datar.ExeData.OptionRecipe{ori},fmd);
        end
      end
    catch
      logmsg{end+1}=sprintf('[E] Option Recipe Failed : %s',lasterr);
      P3_waitbar(X,logmsg(end));
    end
    key.filterManage=fmd;
    try
      fname=feval(dfcn,'make_mfile',key);
      [chdata, cdata, bhdata, bdata, psdata] = scriptMeval(fname,...
        'chdata', 'cdata', 'bhdata', 'bdata','psdata'); %#ok
    catch
      try delete(fname); catch  end
      logmsg{end+1}=sprintf('[E] Evaluate Faild : %s',lasterr);
      P3_waitbar(X,logmsg(end));
    end
    try
     [p f]=fileparts(fname); %#ok
     clear(f); 
    catch
    end
    try
      delete(fname);
    catch
    end
    if isempty(bhdata)
      logmsg{end+1}=sprintf('[W] Ignore non-blocking Data');
      P3_waitbar(X,logmsg(end));
      continue;
    end
    clear chdata cdata;

    %===============================
    % Apply Flags
    %===============================
    szf=size(bdata);
    szf=szf([1 3]);
    if apflag
      % Apply Flag
      flg=reshape(sum(bhdata.flag,1),szf);
    else
      % Use All Data
      flg=false(szf);
    end

    %===============================
    % Evaluate String
    %===============================
    clear D;
    st=bhdata.stim(1); %#ok for Period Evaluation (Start Point)
    ed=bhdata.stim(2); %#ok for Period Evaluation (Start Point)
    hdata=bhdata;      %#ok
    data=bdata;        %#ok
    try
      eval(datar.ExeData.ExecuteString);
    catch
      logmsg{end+1}=sprintf('[E] Execute Error: %s',lasterr);
      P3_waitbar(X,logmsg(end));
      continue;
    end
    
    if ~exist('D','var')
      logmsg{end+1}=sprintf('[W] No Result');
      P3_waitbar(X,logmsg(end));
      continue;
    end

    %===============================
    % Make Summarized Data
    %===============================
    sz0=size(bdata); sz0(2)=[];
    sz1=size(D);     sz1(2)=[];
    if ~isequal(sz0,sz1)
      st=length(logmsg);
      logmsg(end+1:end+2)={...
        sprintf('[E] Data size has changed at the file #%d:%s',fid,myname),...
        ''};
      P3_waitbar(X,logmsg(end-1));
      P3_waitbar(X,logmsg(end));
      if (sz0(1)~=sz1(1))
        logmsg{end+1}=...
          sprintf('   Size of Dimmensin 1 (block) has changed from %d to %d',sz0(1),sz1(1));
        P3_waitbar(X,logmsg(end));
      end
      if length(sz1)<2
        logmsg{end+1}=...
          sprintf('   Size of Dimmensin 3 (channel) has changed from %d to 0',sz0(2));
        P3_waitbar(X,logmsg(end));
      elseif (sz0(2)~=sz1(2))
        logmsg{end+1}=...
          sprintf('   Size of Dimmensin 3 (channel) has changed from %d to %d',sz0(2),sz1(2));
        P3_waitbar(X,logmsg(end));
      end
      if length(sz1)<3
        logmsg{end+1}=...
          sprintf('   Size of Dimmensin 4 (kind) has changed from %d to 0',sz0(3));
        P3_waitbar(X,logmsg(end));
      elseif (sz0(2)~=sz1(2))
        logmsg{end+1}=...
          sprintf('   Size of Dimmensin 4 (kind) has changed from %d to %d',sz0(3),sz1(3));
        P3_waitbar(X,logmsg(end));
      end
      P3_waitbar(1,'!!! Error Exit !!!');
      error(logmsg{st+1});
    end
    
    sz=size(D);
    % Version ***
    try
      szz=sz;szz(1)=[];
      for blk=1:sz(1)
        t={blk,bhdata.stimkind(blk)};
        tmps0=tmps;
        for kk=blkkey(:)' % SearchKey for Block (2010_2_RA06-1)
          try
            tmps0{kk}=tmps{kk}.Data{blk};
          catch
            switch lower(tmps{kk}.Type)
              case {'numericb'}
                tmps0{kk}=NaN;
              case {'textb'}
                tmps0{kk}='';
              otherwise
                tmps0{kk}=[];
            end
          end
        end
        t={t{:} tmps0{:}};
        SummarizedKey(end+1,:)=t;
		
        SummarizedData(end+1,:)=...
          {reshape(D(blk,:,:,:),szz),flg(blk,:)}; %#ok
      end
    catch
      logmsg{end+1}=sprintf('[E] Make Summarized Data Error: %s',lasterr);
      P3_waitbar(X,logmsg(end));
      continue;
    end
    logmsg{end+1}=sprintf('** OK **');
    P3_waitbar(X,logmsg(end));
  end
end
datar.Header=Header;
datar.SummarizedKey = SummarizedKey;
datar.SummarizedData = SummarizedData;
datar.SummuarizedDataTag = [repmat({'Av'},[1 size(D,4)]) 'flag'];
datar.SSFnc=mfilename;
%uiwait(msgbox(logmsg,'Evaluate Logs','none','modal'));
P3_waitbar(1,{'Done','----------------------'});


