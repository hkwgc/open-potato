function varargout=P3R1gui_DrawButton(fcn,varargin)
% POTATo : Research Mode 1st-Level-Analysis Function "Average"

% == History ==
%  2010.11.15 : New! (for testing....)

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'CreateGUI',...
      'Activate','Suspend',...
      'MakeExeData','SetExeData',...
      'psb_draw',...
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
function mydata=createMydata(hs,tagname)
% Get mydata
%##########################################################################
mydata.handle  = hs.(mytag(tagname));
mydata.tagname = tagname;
mydata.fcn     = mfilename;    % Function-Name

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tagname)
% Tool : make unique tagname.
tag=['psb_R1gui_draw_' tagname];

%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,varargin)
% Create Related GUI
%==========================================================================
prop={'Units','pixels','Visible','off'};
error(nargchk(3, 100, nargin, 'struct'));

tag=mytag(tagname);

% make default 'UserData'
p=fileparts(which(mfilename));
ud.mode=0;
ud.Layout=[p filesep 'LAYOUT_P3R1gui_DrawButton_GA.mat'];
ud.Before=[];
hs.(tag)=uicontrol(hs.figure1,'String','Draw','UserData',ud);
try
  if ~isempty(varargin)
    set(hs.(tag),varargin{:});
  end
catch
  warndlg({'Bad Property: ',lasterr},mfilename);
end
mydata=createMydata(hs,tagname);
set(hs.(tag),prop{:},...
  'TAG',tag,...
  'style','pushbutton',...
  'Position',pos,...
  'Callback',[mfilename '(''psb_draw'',gcbo);']);

%==========================================================================
function h=myhandles(hs,tagname)
% My Handle List
%==========================================================================
h=hs.(mytag(tagname));

%==========================================================================
function [h,sdt]=Activate(hs,mydata,sdt)
% My GUI Visible On
%==========================================================================
h=myhandles(hs,mydata.tagname);
set(h,'Visible','on');

%==========================================================================
function h=Suspend(hs,mydata)
% My GUI Visible Off
%==========================================================================
h=myhandles(hs,mydata.tagname);
set(h,'Visible','off');

%##########################################################################
% GUI Callbacks
%##########################################################################
function psb_draw(h)
%

%----------------
% Check UserData
%----------------
ud=get(h,'UserData');
if isempty(ud)
  waitfor(warndlg('Lost : Draw Property'));
  p=fileparts(which(mfilename));
  ud.mode=0;
  ud.Layout=[p filesep 'LAYOUT_P3R1gui_DrawButton_GA.mat'];
end 
if ~isstruct(ud) || ~isfield(ud,'mode') || ~isfield(ud,'Layout')
  errordlg({'Bad User-Data Format'},'Draw');
  return;
end
if isfield(ud,'Before')
  optionrecipe=ud.Before;
else
  optionrecipe=[];
end

hs=guidata(h);
if strcmpi(get(hs.psb_R1st_Copy,'Visible'),'on')
  isnewmode=false;
else
  isnewmode=true;
end

switch ud.mode
  case 0
    if isnewmode
      draw_grandaverage1(hs,ud.Layout,optionrecipe); % Load From Disp-File List
    else
      draw_grandaverage2(hs,ud.Layout,optionrecipe); % Load From Summary-Stastic-Data
    end
  otherwise
    errordlg({sprintf('Not Support Mode %d',mode)},'Draw');
end
  
function draw_grandaverage1(hs,layout,optionrecipe)
% Drwa Grand-Average

%-------------------------------
% All-DataSelected ? 2010_2_RA03-6
%-------------------------------
isselectall=false;

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

% Load Ana-Files
ll=datar.nfile;
for ii=1:ll
  datar.AnaFiles{ii}=feval(fcn,'load',filedata(vls(ii)));
end
draw_grandaverage0(layout,datar,fcn,optionrecipe);


function draw_grandaverage2(hs,layout,optionrecipe)
% Drwa Grand-Average

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
isselectall=true;
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
for ii=1:datar.nfile
  jj=ud(2,ii); % Real Index
  switch ud(1,ii)
    case 0
      % Recipe : Same (Use summarized Data Recipe)
      datar.AnaFiles{ii}=actdata.data.data.AnaFiles{jj};
    case 1
      % Recipe : Use Analysis-Data Recipe
      datar.AnaFiles{ii}=feval(fcn,'load',...
        actdata.data.data.AnaFiles{jj});
    case 2
      % Use : List Data
      datar.AnaFiles{ii}=feval(fcn,'load',filedata(jj));
    otherwise
      error('Undefined File-List Information ID %d',ud(1,ii));
  end % switch
end

draw_grandaverage0(layout,datar,fcn,optionrecipe);


function draw_grandaverage0(layout,datar,fcn,orr)
% Load 1st
outputflag=false; % See also Main 13-Jan-2011
if outputflag
  obhdata=cell([1,datar.nfile]);
  obdata =cell([1,datar.nfile]);
end
idkey  = feval(fcn,'getIdentifierKey');
ll=datar.nfile;
ii=1;
try
  key.actdata.data=datar.AnaFiles{ii};
  fmd=datar.AnaFiles{ii}.data.filterdata;
  for jj=1:length(orr)
    fmd=feval(orr{jj}.fcn,'updateFilterManageData0',orr{jj},fmd);
  end
  %fname=feval(fcn,'make_mfile',datar.AnaFiles{ii});
  key.filterManage=fmd;
  fname=feval(fcn,'make_mfile',key);
  [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
    'chdata', 'cdata', 'bhdata', 'bdata'); %#ok
catch
  delete(fname);
  rethrow(lasterror);
end
delete(fname);
if isempty(bhdata)
  error('Not for Continuous');
end

% For Block-Data
data0=PlugInWrap_Flag2NaN('exe0',bdata,bhdata);
if outputflag
  obhdata{1}=bhdata;
  obdata{1} =data0;
end
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
  key.actdata.data=datar.AnaFiles{ii};
  fmd=datar.AnaFiles{ii}.data.filterdata;
  for jj=1:length(orr)
    fmd=feval(orr{jj}.fcn,'updateFilterManageData0',orr{jj},fmd);
  end
  %fname=feval(fcn,'make_mfile',datar.AnaFiles{ii});
  key.filterManage=fmd;
  fname=feval(fcn,'make_mfile',key);
  [chdata, cdata, bhdata, bdata] = scriptMeval(fname,...
    'chdata', 'cdata', 'bhdata', 'bdata'); %#ok
  delete(fname);
  data0=PlugInWrap_Flag2NaN('exe0',bdata,bhdata);
  if outputflag
    obhdata{ii}=bhdata;
    obdata{ii} =data0;
  end
  
  % Add Stim?
  n=setdiff(bhdata.stimkind,stimkind);
  if ~isempty(n)
    stimkind(end+1:end+length(n))=n;
  end
  sz0=size(data0);
  
  % Check size
  if ~isequal(sz0(3:end),sz(3:end))
    warning('Current Version : Data size must be same'); %#ok
    disp([' Data size of ' datar.AnaFiles{ii}.(idkey) ':'])
    disp(sz);
    disp([' Data size of ' datar.AnaFiles{ii}.(idkey) ':'])
    disp(size(data0));
    continue;
  end

  % Check Stim DIff
  stimdiff0=(bhdata.stim(2)-bhdata.stim(1))*bhdata.samplingperiod;
  if abs(stimdiff-stimdiff0)>OSP_STIMPERIOD_DIFF_LIMIT
    error(['[E] Stimulation Period vary a great deal.\n', ...
      '    Stim1 is %6.3f [sec]\n', ...
      '    Stim2 is %6.3f [sec]\n'], ...
      stimdiff,stimdiff0);
  end
  
  % Check Pereio
  if (myperiod~=bhdata.samplingperiod)
    warning('Current Version : Sampling Period must be same'); %#ok
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
      dnum(idx,idx1,:,:)=sum(~dnan,1);
      data(idx,idx1,:,:)=sum(tmp,1);
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
if fsz(2)>1,
  try, hdata.stimTC2(2:end,:)=[];end %#ok
  try, hdata.stimkind=stimkind;end   %#ok
  try, hdata.flag=flag;end           %#ok
end

%  Load Layout and View
load(layout,'LAYOUT');
if 0
  % debug : Edit LAYOUT-File
  lh=LayoutEditor;
  lhs=guidata(lh);
  LayoutEditor('menu_openLayout_Callback',lhs.menu_openLayout,[],lhs,f);
end
% reset flag
hdata.flag(:)=false;
P3_view(LAYOUT,hdata,data);

if outputflag
  assignin('base','Header',obhdata);
  assignin('base','Data',obdata);
end

%##########################################################################
% Dummy functions
%##########################################################################
%==========================================================================
function ExeData0=MakeExeData(mydata) %#ok
% Do noting
ExeData0=[];return;

%==========================================================================
function r=SetExeData(mydata,ExeData0) %#ok
% Do noting
r=0;return;

%==========================================================================
function datar=execute(datar,ExeData0) %#ok
% Do noting
return;

