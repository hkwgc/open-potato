function varargout=P3R1gui_OptionRecipe(fcn,varargin)
% POTATo 1st GUI: Research Mode Add-Recipe

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
%  2010.12.27 : New!

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'CreateGUI',...
      'Activate','Suspend',...
      'MakeExeData','SetExeData',...
      'ck_Callback',...
      'getArgument',...
      'info_Callback',...
      'updateFilterManageData0',...
      'updateFilterManageData',...
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
tag=['R1guiOR' num2str(id) '_' tagname];
function h=myhandle(hs,h0,id)
% Tool : get handle
tg=get(h0,'Tag');
tg(8)=num2str(id);
h=hs.(tg);

%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,filterData,varargin)
% Create Related GUI
%==========================================================================
error(nargchk(3, 100, nargin, 'struct'));

% Default Setting
tag=mytag(tagname,2);
try
  bi=feval(filterData.fcn,'createBasicInfo');
  myname=bi.name;
catch
  myname=[filterData.fcn(11:end) ' XX'];
end
hs.(tag)=uicontrol(hs.figure1,'String',myname);
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
x1=20;x2=(pos0(3)-x1)*0.5;x3=pos0(3)-x1-x2;
pos1=pos0;pos1(3)=x1;
pos2=pos0;pos2(1)=pos1(1)+x1;pos2(3)=x2;
pos3=pos2;pos3(1)=pos2(1)+x2;pos3(3)=x3;

% Other Prop
prop={'Units','pixels','Visible','off'};
c=get(hs.figure1,'Color');

%- - - -  - - - - -
% Checkbox
%- - - -  - - - - -
tag=mytag(tagname,1);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'backgroundcolor',c,...
  'Enable','off',...
  'style','checkbox',...
  'Position',pos1,...
  'Callback',[mfilename '(''ck_Callback'',gcbo);']);
% is there Default Value?
if isfield(filterData,'default') && ~isempty(filterData.default)
  set(hs.(tag),'Enable','on','Value',1);
  filterData.Filter=filterData.default;
else
  filterData.Filter=[];
end

% Uee-Always
if filterData.usealways
  % !!Need Default-Value!!
  if isempty(filterData.default)
    errordlg({'Program Error: ', ...
      '  OptionRecipe need Default Value'});
  end
  try
    set(hs.(tag),'Enable','inactive');
  catch
    set(hs.(tag),'Enable','off');
  end
end

%- - - -  - - - - -
% Push-Button
%- - - -  - - - - -
tag=mytag(tagname,2);
set(hs.(tag),prop{:},...
  'TAG',tag,...
  'style','pushbutton',...
  'Position',pos2,...
  'Callback',[mfilename '(''getArgument'',gcbo);'],...
  'Userdata',filterData);
%- - - -  - - - - -
% Information Textbox
%- - - -  - - - - -
tag=mytag(tagname,3);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'style','pushbutton',...
  'Enable','off',...
  'Position',pos3,...
  'Callback',[mfilename '(''info_Callback'',gcbo);'],...
  'Userdata',[]);
%  'Backgroundcolor',[1 1 1],...
%  'style','edit',...
%  'max',10,...
%  'HorizontalAlignment','left',...

% Update String
tag=mytag(tagname,1);
ck_Callback(hs.(tag),hs);

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
ud=get(h(2),'UserData');
try
  if length(ud.region)==1
    switch ud.region
      case -1
        % Blocking
        if sdt==1
          set(h,'Visible','on');
          sdt=2; % Block
        else
          set(h,'Visible','off');
        end
      case 2
        % Continuous
        if bitget(sdt,1)
          set(h,'Visible','on');
        else
          set(h,'Visible','off');
        end
      case 3
        % Block Data
        if bitget(sdt,2)
          set(h,'Visible','on');
        else
          set(h,'Visible','off');
        end
      otherwise
        error('Non Define');
    end
  end
catch
  set(h,'Visible','off');
end

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
function ck_Callback(h,hs)
%
%==========================================================================
v=get(h,'Value');
if nargin<2
  hs=guidata(gcbo);
end
h3=myhandle(hs,h,3);

if (v==0)
  % Info Update
  set(h3,'Enable','off','String','-');
else
  % Info Update
  h2=myhandle(hs,h,2);
  ud=get(h2,'UserData');
  try
    if 0
      strx = OspDataFileInfo(0,1,ud.Filter.argData);
      strx=char(strx)';
      strx=[strx; repmat(',',[1,size(strx,2)])];
      strx=strrep(strx(:)',' ','');
      strx(end)=[];
      set(h3,'Enable','on','String',strx);
    else
      set(h3,'Enable','on','String','Info');
    end
  catch
    set(h3,'Enable','inactive','String','EMPTY');
  end
end

%==========================================================================
function fmd=updateFilterManageData0(mydata,fmd)
% Update Filter-Management Data (From GUI)
%==========================================================================
ExeData0=MakeExeData(mydata);
fmd=updateFilterManageData(ExeData0,fmd);

function fmd=updateFilterManageData(ExeData0,fmd)
% Update Filter-Management Data (From ExeData)
if ExeData0.Check==0
  return; % Do nothing
end

FilterData=ExeData0.FilterData;
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
if isfield(fmd,Regions{rg})
  fmd.(Regions{rg}){end+1}=FilterData.Filter;
else
  fmd.(Regions{rg})={FilterData.Filter};
end


%==========================================================================
function getArgument(h)
% Old-One
%==========================================================================
ud=get(h,'UserData');
hs=guidata(h);
h1=myhandle(hs,h,1); % checkbox

% Get SS-Real (of Ana-Info part)
isselectall=false;
datar=P3_gui_Research_1st('makeSSReal0',hs,isselectall);

if datar.nfile==0
  errordlg('No Data Selected');
  return;
end

try
  % Make M-File (befre)
  key.actdata.data=datar.AnaFiles{1};
  fmd=datar.AnaFiles{1}.data.filterdata;
  % Modify
  for ii=1:length(ud.Before)
    % ud.Before{ii}.fcn is might be this file
    fmd=feval(ud.Before{ii}.fcn,'updateFilterManageData0',ud.Before{ii},fmd);
  end
  key.filterManage=fmd;
  fname=DataDef2_Analysis('make_mfile',key);
  

  % Make Input Filter Data
  if isempty(ud.Filter)
    try
      bi=feval(ud.fcn,'createBasicInfo');
    catch
      error('Program Error: Bad Usage of OptionRecipe');
    end
    filData=bi;
    filData.wrap=ud.fcn;
    filData.enable='on';
  else
    filData=ud.Filter;
  end
  
  % Do getArgumjent
  filDataup = feval(filData.wrap,'getArgument',filData, fname);
  
catch
  % Try to delete file
  try  delete(fname); catch end
  rethrow(lasterror);
end

% Try to delete file
try  delete(fname); catch end
% Cancel Check
if isempty(filDataup), return; end
ud.Filter=filDataup;
set(h,'UserData',ud);
if ~ud.usealways
  set(h1,'Value',1,'Enable','on');
end
ck_Callback(h1);

%==========================================================================
function info_Callback(h)
% Old-One
%==========================================================================
hs=guidata(gcbo);
h2=myhandle(hs,h,2);
ud=get(h2,'UserData');
try
  strx = OspDataFileInfo(0,1,ud.Filter.argData);
  % HK 2019/10/22
  msgbox(strx,'Grouping Information','help');
  %msglistbox(strx,'Grouping Information','help');
catch
  errordlg('No argument data');
end


%##########################################################################
% GUI <--> ExeData
%##########################################################################
%==========================================================================
function ExeData0=MakeExeData(mydata)
% Get Parameter's of 1st-Level-Analysis Execution
%==========================================================================
h=mydata.handle;hs=guidata(h);
h1=myhandle(hs,h,1); % checkbox
ExeData0.Check=get(h1,'Value');
if strcmpi(get(h1,'Visible'),'off')
  ExeData0.Check=0;
end
h2=myhandle(hs,h,2);
ExeData0.FilterData  =get(h2,'UserData');
ExeData0.fcn=mfilename;

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
  tmp=get(h2,'UserData');
  ExeData0.FilterData.Before=tmp.Before;
  set(h2,'UserData',ExeData0.FilterData);
  if ~ ExeData0.FilterData.usealways
    if ~isempty(ExeData0.FilterData.Filter)
      set(h1,'Enable','on');
    else
      set(h1,'Enable','off');
    end
  end
  ck_Callback(h1);
catch
  r=1;
end

%##########################################################################
% Execution
%##########################################################################
function datar=execute(datar,ExeData0)
% Make Group-Information
% Input : datar
%       datar.nfile    : number of files
%       datar.Anafiles : Analysis-File (with Recipe)
%       datar.ExeData  : Parameter's that seted by MakeData
% Output : datar
%       datar.ExeData.OptionRecipe

% Convert Our ExeData to Common-ExeData
if isempty(ExeData0)
  return;
end
if ExeData0.Check==0
  return;
end

% Add Option Recipe
if isfield(datar.ExeData,'OptionRecipe')
  datar.ExeData.OptionRecipe{end+1}=ExeData0;
else
  datar.ExeData.OptionRecipe       ={ExeData0};
end
