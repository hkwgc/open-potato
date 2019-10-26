function varargout=P3R1gui_KeyGrouping(fcn,varargin)
% POTATo : Research Mode 1st-Level-Analysis Function "Average"

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


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
      'ck_Callback',...
      'sel_Callback',...
      'info_Callback',...
      'execute'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case {'myhandles','psb_Callback0'}
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
mydata.handle  = hs.(mytag(tagname,2));
mydata.tagname = tagname;
mydata.fcn     = mfilename;    % Function-Name

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tagname,id)
% Tool : make unique tagname.
tag=['psb_R1gui_' num2str(id) tagname];
function h=myhandle(hs,h0,id)
% Tool : get handle
tg=get(h0,'Tag');
tg(11)=num2str(id);
h=hs.(tg);

%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,varargin)
% Create Related GUI
%==========================================================================
error(nargchk(3, 100, nargin, 'struct'));

% Default Setting
tag=mytag(tagname,2);
hs.(tag)=uicontrol(hs.figure1,'String','Make-Group');
try
  if ~isempty(varargin)
    set(hs.(tag),varargin{:});
  end
catch
  warndlg({'Bad Property: ',lasterr},mfilename);
end
mydata=createMydata(hs,tagname);

% Make GUI
% Position --
pos0=pos; % start
x1=20;x2=(pos0(3)-x1)*2/3;x3=pos0(3)-x1-x2;
pos1=pos0;pos1(3)=x1;
pos2=pos0;pos2(1)=pos1(1)+x1;pos2(3)=x2;
pos3=pos2;pos3(1)=pos2(1)+x2;pos3(3)=x3;

% Other Prop
prop={'Units','pixels','Visible','off'};
c=get(hs.figure1,'Color');
defaultname=get(hs.(tag),'String');

tag=mytag(tagname,1);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'backgroundcolor',c,...
  'style','checkbox',...
  'Enable','off',...
  'Position',pos1,...
  'Callback',[mfilename '(''ck_Callback'',gcbo);'],...
  'UserData',defaultname);
tag=mytag(tagname,2);
set(hs.(tag),prop{:},...
  'TAG',tag,...
  'style','pushbutton',...
  'Position',pos2,...
  'Callback',[mfilename '(''sel_Callback'',gcbo);'],...
  'Userdata',[]);
tag=mytag(tagname,3);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'style','pushbutton',...
  'Enable','off',...
  'String','Info',...
  'Position',pos3,...
  'Callback',[mfilename '(''info_Callback'',gcbo);'],...
  'Userdata',[]);

%==========================================================================
function h=myhandles(hs,tagname)
% My Handle List
%==========================================================================
h=zeros([1,3]);
for i=1:3
  h(i)=[hs.(mytag(tagname,i))];
end

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
%==========================================================================
function ck_Callback(h)
%
%==========================================================================
v=get(h,'Value');
hs=guidata(gcbo);
h2=myhandle(hs,h,2);
h3=myhandle(hs,h,3);

if (v==0)
  defaultname=get(h,'UserData');
  set(h2,'String',defaultname);
  set(h3,'Enable','off');
else
  key=get(h2,'UserData');
  set(h2,'String',key);
  set(h3,'Enable','on');
end

%==========================================================================
function sel_Callback(h)
% Old-One
%==========================================================================
ud=get(h,'UserData');
hs=guidata(h);

dfcn='DataDef2_Analysis'; % Data-Function
dlist=feval(dfcn,'loadlist');
fns=fieldnames(dlist);

if isempty(ud)
  vl=1;
else
  vl=find(strcmp(fns,ud));
  if isempty(vl),vl=1;end
end

%========================================
% Question Dialog
%========================================
%-----------------------
% make key-select-figure
%-----------------------
% Position.
set(0,'Units','pixels');p=get(0,'ScreenSize');
dy_cm=20*2;dy=20; iy=5;y=3*iy+dy_cm;
dx=10;x=200;
% Clolor
c=get(hs.figure1,'Color');

ths.fig=figure('Visible','off',...'Resize','off',...
  'Color',c,...
  'MenuBar','none','NumberTitle','off',...
  'Name','Set Grouping-Key',...
  'Units','pixels','Position',[(p(3)-x)/2 (p(4)-y)/2 x y]);

% Key
y=y-dy-iy;
sx1=dx;
x1 =(x-3*dx)/4;
sx2=sx1+x1+dx;
x2 =x1*3;
ths.txt_key=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','text',...
  'BackgroundColor',c,...
  'HorizontalAlignment','left',...
  'String','Key:',...
  'Position',[sx1 y x1 dy]);
ths.pop_key=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','popupmenu',...
  'BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'Value',vl(1),...
  'String',fns,...
  'Position',[sx2 y x2 dy]);
% OK Button
y=y-dy-iy;
x0=(x-3*dx)/2;
sx2=sx1+x0+dx;
ths.ok =uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','OK',...
  'Callback','set(gcbf,''visible'',''off'')',...
  'Position',[sx1 y x0 dy]);
ths.cancel=uicontrol(ths.fig,...
  'Unit','pixels',...
  'style','pushbutton',...
  'String','Cancel',...
  'Callback','delete(gcbf)',...
  'Position',[sx2 y x0 dy]);
%-----------------------
% open key-select-figure
%-----------------------
h0=findobj(ths.fig,'Type','uicontrol');
set(h0,'Units','Normalized');
set(ths.fig,'Visible','on','WindowStyle','modal');
waitfor(ths.fig,'Visible','off');


if ~ishandle(ths.fig)
  % Closed (or Cancel)
  return;
end

ud=fns{get(ths.pop_key,'Value')};
delete(ths.fig);
set(h,'String',ud,'UserData',ud);
h1=myhandle(hs,h,1);
set(h1,'Enable','on','Value',1);
h3=myhandle(hs,h,3);
set(h3,'Enable','on');

%==========================================================================
function info_Callback(h)
% Old-One
%==========================================================================
hs=guidata(gcbo);
h2=myhandle(hs,h,2);
% Get SS-Real (of Ana-Info part)
isselectall=false;
datar=P3_gui_Research_1st('makeSSReal0',hs,isselectall);
% Get GroupInfo : Execute (Old format)
key=get(h2,'UserData');
datar=execute(datar,key);

% Show Info: 
%  datar.ExeData.GroupInfo.Number
%  datar.ExeData.GroupInfo.ID
dfcn='DataDef2_Analysis'; % Data-Function
idkey  = feval(dfcn,'getIdentifierKey');

info={sprintf('--Group Data (%s) --',key)};
for gid=1:datar.ExeData.GroupInfo.Number
  fids=find(datar.ExeData.GroupInfo.ID==gid);
  info{end+1}=sprintf('Group [%03d]',gid);
  for fid=fids(:)'
    myname=datar.AnaFiles{fid}.(idkey);
    info{end+1}=sprintf('  file[%03d] %s',fid,myname);
  end  
end

if length(info)==1
  info={'No Analysis-Data'};
end

% HK: 2019-10-22
msgbox(info,'Grouping Information','help');
% msglistbox(info,'Grouping Information','help');

%##########################################################################
% GUI <--> ExeData
%##########################################################################
%==========================================================================
function ExeData0=MakeExeData(mydata)
% Get Parameter's of 1st-Level-Analysis Execution
%==========================================================================
h=mydata.handle;
hs=guidata(h);
h1=myhandle(hs,h,1);
ExeData0.Check=get(h1,'Value');
h2=myhandle(hs,h,2);
ExeData0.Key  =get(h2,'UserData');

%==========================================================================
function r=SetExeData(mydata,ExeData0)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
h=mydata.handle;
hs=guidata(h);
try
  h1=myhandle(hs,h,1);
  set(h1,'Value',ExeData0.Check);
catch
  r=1;
end
try
  h2=myhandle(hs,h,2);
  set(h2,'UserData',ExeData0.Key);
catch
  r=1;
end

%##########################################################################
% Execution
%##########################################################################
function datar=execute(datar,ExeData0)
% Make Group-Information
%
% Input : datar
%       datar.nfile    : number of files
%       datar.Anafiles : Analysis-File (with Recipe)
%       datar.ExeData  : Parameter's that seted by MakeData
% Output : datar
%       datar.ExeData.GroupInfo.Number
%       datar.ExeData.GroupInfo.ID

% Convert Our ExeData to Common-ExeData
if isempty(ExeData0)
  %datar.ExeData.GroupInfo.Number = datar.nfile;
  %datar.ExeData.GroupInfo.ID     = [1:datar.nfile]'; %#ok??
  return;
end
if isstruct(ExeData0)
  if ExeData0.Check
    ExeData0=ExeData0.Key;
  else
    return;
  end
end

dfcn='DataDef2_Analysis'; % Data-Function
idkey  = feval(dfcn,'getIdentifierKey');
dlist=feval(dfcn,'loadlist');
nms0={dlist.(idkey)};
ds  =zeros([1,datar.nfile]);
for ii=1:datar.nfile;
  idx=find(strcmp(datar.AnaFiles{ii}.(idkey),nms0));
  ds(ii)=idx(1);
end

dlist=dlist(ds);
if isnumeric(dlist(1).(ExeData0))
  [lst, i0, j0]=unique([dlist.(ExeData0)]); %#ok
elseif ischar(dlist(1).(ExeData0))
  [lst, i0, j0]=unique({dlist.(ExeData0)}); %#ok
else
  % expand...
  lst={};
  j0=zeros([datar.nfile,1]);
  for ii=1:datar.nfile
    if j0(ii)~=0, continue;end
    lst{end+1}=dlist(ii).(ExeData0);
    gid=length(lst);
    j0(ii)=gid;
    for jj=ii:datar.nfile
      if j0(jj)~=0, continue;end
      if isequal(dlist(ii).(ExeData0),dlist(jj).(ExeData0))
        j0(jj)=gid;
      end
    end
  end
end

datar.ExeData.GroupInfo.Number = length(lst);
datar.ExeData.GroupInfo.ID     = j0;


