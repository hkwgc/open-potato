function varargout=P3R1F_Evaluate(fcn,varargin)
% POTATo : Research Mode 1st-Level-Analysis Function "Evaluate"
%
%  Make Summary-Static Data by Execute Evaluate-String.
%   Where variable named 'D' is Summary-Stastic.

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
      'execute',...
      'dofirst'}
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
basic_info.name = 'Evaluate';   % Display-Name 
basic_info.ver  = 1.0;          % Version (double)
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
%----------------------
% Get GUI Position...
%----------------------
dy=20; y=y-dy-iy;
tag=mytag('txt_R1st_ExecuteString');
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Equation:',...
  'Position',[sx2 y xsize dy]);
dy=20; y=y-dy;

tag=mytag('edt_R1st_ExecutionString');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','edit','BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String','D= nan_fcn(''mean'',data(:,P1,:,:),2);',...
  'Position',[sx2+2*ix y xsize-2*ix dy]);

% Preriod Setting(1)
xsize2=xsize/2-2*ix;
dy=20;y=y-dy-iy;
sx3=sx2+xsize2+ix;
tag=mytag('txt_R1st_Period1');
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Period1:',...
  'Position',[sx2 y xsize2 dy]);
tag=mytag('edt_R1st_Period1');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','edit','BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String','1:end',...
  'Position',[sx3 y xsize2 dy]);

% Preriod Setting(2)
dy=20;y=y-dy;
tag=mytag('txt_R1st_Period2');
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Period2:',...
  'Position',[sx2 y xsize2 dy]);
tag=mytag('edt_R1st_Period2');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','edit','BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String','1:end',...
  'Position',[sx3 y xsize2 dy]);

% Check-Box
dy=20;y=y-dy-iy;
tag=mytag('ckb_R1st_ApplyFlag');
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','checkbox',...
  'String','Apply Flags',...
  'Value',1,...
  'Position',[sx2+2*ix y xsize-2*ix dy]);

%==========================================================================
function h=myhandles(hs)
% My Handle List
%==========================================================================
h=[hs.(mytag('txt_R1st_ExecuteString')),...
  hs.(mytag('edt_R1st_ExecutionString')),...
  hs.(mytag('txt_R1st_Period1')),...
  hs.(mytag('edt_R1st_Period1')),...
  hs.(mytag('txt_R1st_Period2')),...
  hs.(mytag('edt_R1st_Period2')),...
  hs.(mytag('ckb_R1st_ApplyFlag')),...
  ];

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


%==========================================================================
function h=Suspend(hs)
% My GUI Visible Off
%==========================================================================
h=myhandles(hs);
set(h,'Visible','off');

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
ExeData.ExecuteString=...
  get(hs.(mytag('edt_R1st_ExecutionString')),'String');
ExeData.P1=...
  get(hs.(mytag('edt_R1st_Period1')),'String');
ExeData.P2=...
  get(hs.(mytag('edt_R1st_Period2')),'String');
ExeData.ApplyFlag=...
  get(hs.(mytag('ckb_R1st_ApplyFlag')),'Value');

%==========================================================================
function r=SetExeData(hs,ExeData)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
try
  set(hs.(mytag('edt_R1st_ExecutionString')),'String',ExeData.ExecuteString);
  set(hs.(mytag('edt_R1st_Period1')),'String',ExeData.P1);
  set(hs.(mytag('edt_R1st_Period2')),'String',ExeData.P2);
  set(hs.(mytag('ckb_R1st_ApplyFlag')),'Value',ExeData.ApplyFlag);
catch
  r=1;
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
ev=ed0.ExecuteString;
fs=fieldnames(ed0);
for ii=1:length(fs)
  try
    % Modify
    switch fs{ii}
      case {'P1','P2'}
        ev=strrep(ev,fs{ii},ed0.(fs{ii}));
      case {'ApplyFlag'}
        ed.(fs{ii})=ed0.(fs{ii});
    end
  catch
  end
end
ed.ExecuteString=ev;
datar.ExeData=ed;
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
% Output : datar
%       datar.Header     : Cell Header of Summarized Data
%       datar.Summarized : Cell Summarized Data
logmsg={'---- Summary Statistics Computation: Evaluate Version 0.0 ---'};
X=0;
P3_waitbar(X,logmsg,'Summary Statistics Computation'); 

dfcn='DataDef2_Analysis'; % Data-Function
idkey  = feval(dfcn,'getIdentifierKey');

dlist=feval(dfcn,'loadlist');
fns=fieldnames(dlist);
%Header={'Data','Block','Channel','Kind','Stim',fns{:}};
Header={'Block','Stim',fns{:}};
%Summarized    ={};
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
  P3_waitbar(X,logmsg(end));
else
  apflag=false;
end

DX = 1/datar.nfile;
%DXX= DX/2;
for fid=1:datar.nfile
  %===============================
  % Load Analysis Data
  %===============================
  X=(fid-1)*DX;
  
  myname=datar.AnaFiles{fid}.(idkey);
  tmps=dlist(strcmp({dlist.(idkey)},myname));
  tmps=struct2cell(tmps);
  
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
  fname=feval(dfcn,'make_mfile',key);
  	
	%--TK debug
	%disp(fname);
	%--TK
	
  try
    [chdata, cdata, bhdata, bdata,psdata] = scriptMeval(fname,...
      'chdata', 'cdata', 'bhdata', 'bdata','psdata'); %#ok
  catch
    try delete(fname); catch  end
    logmsg{end+1}=sprintf('[E] Evaluate Faild : %s',lasterr);
    P3_waitbar(X,logmsg(end));
    continue;
  end
  try 
     [p f]=fileparts(fname); %#ok
     clear(f); 
  catch
  end
  try delete(fname); catch  end
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
      sprintf('[E] Data size has changes at File #%d:%s',fid,myname),...
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
		  %try
		  %tmps0{kk}=tmps{kk}.Data{blk};
		  %catch
		  switch lower(tmps{kk}.Type)
			  case {'numericb'}
				  n=str2num(tmps{kk}.Data{1});
				  if length(n)==sz(1)
					  tmps0{kk}=n(blk);
				  else
					  tmps0{kk}=NaN;%TODO
				  end
			  case {'textb'}
				  s=tmps{kk}.Data{1};
				  p=regexp(s,' ');
				  if length(p)==sz(1)-1
					  p=[1 p+1 length(p)+1];
					  tmps0{kk}=s(p(blk):p(blk-1));
				  else
					  tmps0{kk}='';%TODO
				  end
				  % otherwise
				  % tmps0{kk}=[];
				  %end
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
  % OLD Version ***
  %   try
  %     for blk=1:sz(1)
  %       for tm=1:sz(2)
  %         for ch=1:sz(3)
  %           for knd=1:sz(4)
  %             t={D(blk,tm,ch,knd),blk,ch,knd,bhdata.stimkind(blk)};
  %             t={t{:} tmps{:}};
  %             Summarized(end+1,:)=t;
  %           end
  %         end
  %       end
  %     end
  %   catch
  %     logmsg{end+1}=sprintf('[E] Make Summarized Data Error: %s',lasterr);
  %     continue;
  %   end
  logmsg{end+1}=sprintf('** OK **');
  P3_waitbar(X+DX,logmsg(end));
end
datar.Header=Header;
datar.SummarizedKey = SummarizedKey;
datar.SummarizedData = SummarizedData;

%uiwait(msgbox(logmsg,'Evaluate Logs','none','modal'));
P3_waitbar(1,{'Done','----------------------'});



