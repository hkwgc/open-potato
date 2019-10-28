function varargout=P3R2_API_selectKey(fcn,varargin)
% Statistical Test :: Key SElect API

% == History ==
%  2011.01.26 : New!
%  2011.04.25 : psb_info : bugfix

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'CreateGUI',...
      'Activate','Suspend',...
      'UpdateRequest',...
      'MakeArgData','SetArgData',...
      'execute',...
      'psb_addkey_Callback',...
      'psb_removekey_Callback',...
      'psb_info_Callback'}
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
  case {'help'}
    POTATo_Help(mfilename);
  otherwise
    error('Not Implemented Function : %s',fcn);
end

%##########################################################################
function mydata=createMydata(hs,tagname)
% Get mydata
%##########################################################################
mydata.handle  = hs.(mytag(tagname,6)); % Listbox is most important
mydata.tagname = tagname;
mydata.fcn     = mfilename;    % Function-Name
%##########################################################################
function mydata=createMydata2(hs,h)
% Get mydata
%##########################################################################
tagname=get(h,'Tag');
tagname(1:9)=[];
mydata=createMydata(hs,tagname);

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tagname,id)
% Tool : make unique tagname.
tag=['R2apiSK' num2str(id) '_' tagname];
function h=myhandle(hs,h0,id)
% Tool : get handle
tg=get(h0,'Tag');
tg(8)=num2str(id);
h=hs.(tg);

%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,APIdata)
% Create Related GUI
%==========================================================================
error(nargchk(4, 4, nargin, 'struct'));

% Make GUI
% Position --
pos0=pos; % start
ix=1;iy=1;
x1=pos(3)-2*ix; x2=(pos(3)-4*ix)/3;
y1=20; y2=pos(4)-5*iy-3*y1;

% Other Prop
prop={'Units','pixels','Visible','off'};
c=get(hs.figure1,'Color');
prop_b={'style','pushbutton',prop{:}};

pos0(1)=pos(1)+ix;
pos0(3)=x1;
pos0(2)=pos(2)+pos(4)-y1-iy-3;
pos0(4)=y1;

%- - - -  - - - - -
% Title
%- - - -  - - - - -
tag=mytag(tagname,1);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'HorizontalAlignment','left',...
  'backgroundcolor',c,...
  'style','text',...
  'Position',pos0);
% is there Default Value?
if isfield(APIdata,'Title')
  set(hs.(tag),'String',APIdata.Title);
else
  set(hs.(tag),'String','Key-Selector');
end

%- - - -  - - - - -
% Key Poupumenu
%- - - -  - - - - -
pos0(2)=pos0(2)-y1-iy+3;
tag=mytag(tagname,2);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'backgroundcolor',[1 1 1],...
  'style','popupmenu',...
  'Enable','inactive',...
  'Position',pos0,...
  'String','No Data selected');

%- - - -  - - - - -
% Push-Buttons
%- - - -  - - - - -
pos0(2)=pos0(2)-y1-iy;
pos0(3)=x2;
tag=mytag(tagname,3);
hs.(tag)=uicontrol(hs.figure1,prop_b{:},...
  'TAG',tag,...
  'Position',pos0,...
  'String','Add',...
  'Callback',[mfilename '(''psb_addkey_Callback'',gcbo);']);

pos0(1)=pos0(1)+ix+pos0(3);
tag=mytag(tagname,4);
hs.(tag)=uicontrol(hs.figure1,prop_b{:},...
  'TAG',tag,...
  'Position',pos0,...
  'String','Remove',...
  'Callback',[mfilename '(''psb_removekey_Callback'',gcbo);']);

pos0(1)=pos0(1)+ix+pos0(3);
tag=mytag(tagname,5);
hs.(tag)=uicontrol(hs.figure1,prop_b{:},...
  'TAG',tag,...
  'Position',pos0,...
  'String','Info',...
  'Enable','off',...
  'UserData',APIdata,...
  'Callback',[mfilename '(''psb_info_Callback'',gcbo);']);
try
  if feval(APIdata.Upper,'enableInfoButton')
    set(hs.(tag),'Enable','on');
  end
catch
  % do nothing
end

%- - - -  - - - - -
% Listbox
%- - - -  - - - - -
pos0(1)=pos(1)+ix;
pos0(2)=pos0(2)-y2-iy;
pos0(3)=x1;
pos0(4)=y2;
tag=mytag(tagname,6);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'style','listbox',...
  'backgroundcolor',[1 1 1],...
  'TAG',tag,...
  'Position',pos0,...
  'String','No Keys');

% make data
mydata=createMydata(hs,tagname);

% Update String
%==========================================================================
function h=myhandles(hs,tagname)
% My Handle List
%==========================================================================
h=zeros([1,6]);
for i=1:6
  h(i)=[hs.(mytag(tagname,i))];
end

%==========================================================================
function h=Activate(hs,mydata)
% My GUI Visible On
%==========================================================================
h=myhandles(hs,mydata.tagname);
APIdata=get(h(5),'UserData');
try
  if ~feval(APIdata.Upper,'enableInfoButton')
    h(5)=[];
  end
catch
end
set(h,'Visible','on');

%==========================================================================
function h=Suspend(hs,mydata)
% My GUI Visible Off
%==========================================================================
h=myhandles(hs,mydata.tagname);
set(h,'Visible','off');

%##########################################################################
% Execution
%##########################################################################
function Data=UpdateRequest(mydat,Data)
% Update relational-GUI.
%  if need Output-Function... too late
% Input :
%     mydat : return-value of CreateGUI
%               (See alos createMyData)
%     Data  : Cell of Real-Part of Summary-Statistics Data 
h=mydat.handle;hs=guidata(h);
if ~iscell(Data),Data={Data};end

% get Key-List
ngroup=length(Data);
keys=ss_datakeys;
for ii=1:ngroup
  keys=union(keys,Data{ii}.Header);
end
% Update Key-List
h2=myhandle(hs,h,2); % Key-List
vl=get(h2,'Value');
if ngroup==0
  set(h2,'String','No Data selected','Enable','inactive','Value',1);
else
  if vl>length(keys), vl=length(keys);end
  set(h2,'String',keys,'Enable','on','Value',vl);
end
% Remove bad-key
h6=myhandle(hs,h,6); % Listbox
klist=get(h6,'UserData');
v=get(h6,'Value');
[xx,ia]=intersect(klist,keys); %#ok
klist=klist(sort(ia));
if v<length(klist), v=length(klist);end
if isempty(klist)
  set(h6,'Value',1,'String','No Keys','UserData',[]);
else
  set(h6,'Value',v,'String',klist,'UserData',klist);
end

%============================
% No out put?
%============================
if nargout<1,  return; end
% Execution
ArgData0=MakeArgData(mydat);
Data=execute(Data,ArgData0);

function cellSS=execute(cellSS0,ArgData0)
% Update Cell of Summarized-Statistics Data
%
% cellSS={datar,...} : cell of Summarized Statistics
%       datar: Real-part of Summarized Statistics.
%       datar.nfile    : --(undefined here.)--
%       datar.Anafiles : --(undefined here.)--
%       datar.ExeData  : --(undefined here.)--
%       datar.Header        : Cell Header of Summarized Data
%       datar.SummarizedKey : Cell Summarized Data (Key-part)
%       datar.SummarizedData: Cell Summarized Data (Data-part)
% ArgData0: Data maid by sub-function MakeArgData

% Argument Check...
if isempty(ArgData0.SelectedKeys)
  cellSS=cellSS0;
  return; % do noting
end

% Original Cell-Loop
n =length(cellSS0);
cellSS={};
for ii=1:n
  if size(cellSS0{ii}.SummarizedKey,1)>=1
    localCellSS=exe2(cellSS0{ii},ArgData0.SelectedKeys);
    cellSS(end+1:end+length(localCellSS))=localCellSS(:);
  end
end

function cellSS=exe2(SS,key)
% Make key list..
% Input :
%      SS    : Summmary-Statistics 
%      kdata : Data of Filtered Key
%      key   : List of Apply
% Output:
%   cellSS : Cell of Summmary-Statistics 

n=length(key);
dk=ss_datakeys;
kdata={};
for ii=1:n
  kdata0.name=key{ii};
  % is Data key (time or channel or kind)
  kid=find(strcmpi(key{ii},dk));
  if isempty(kid)
    % get from Key
    myid=find(strcmp(key{ii},SS.Header));
    kdata0.kid=0;
    kdata0.myid=myid;
    if isempty(myid)
      kdata0.vlist =[];
      kdata0.myid  =0;
    else
      if isnumeric(SS.SummarizedKey{1,myid})
        kdata0.vlist =unique([SS.SummarizedKey{:,myid}]);
      else
        try
          kdata0.vlist =unique(SS.SummarizedKey(:,myid));
        catch
          warning(sprintf('Unsupported Key Type:%s',key{ii}));
          kdata0.vlist =[];
        end
      end
    end
  else
    % Get From data
    kdata0.kid =kid;
    kdata0.myid=0;
    mx=0;
    dl=size(SS.SummarizedData,1);
    for dd=1:dl
      mx=max(size(SS.SummarizedData{dd,1},kid),mx);
    end
    kdata0.vlist=1:mx;
  end
  if ~isempty(kdata0.vlist)
    kdata{end+1}=kdata0;
  end
end

% Last Data : Make cellSS
if isempty(kdata), cellSS={};return;end
cellSS=exe3(SS,{},kdata);
return;

function cellSS=exe3(SS,kdata,kdatain)
% Original Cell-Loop
%  kdata.name :: key name
%  kdata.kid  :: id oy data time,ch,kind
%  kdata.myid :: id of key
%  kdata.vlist:: list of ..
%  kdata.value:: Value (for kdata only)

cellSS={};
if length(kdatain)>=1
  n=length(kdatain{1}.vlist);
  kdatanew=kdatain;
  kdatanew(1)=[];
  if iscell(kdatain{1}.vlist)
    for ii=1:n
      kdata0=kdatain{1};
      kdata0.value=kdatain{1}.vlist{ii};
      x=exe3(SS,{kdata{:},kdata0},kdatanew);
      cellSS(end+1:end+length(x))=x(:);
    end
  else
    for ii=1:n
      kdata0=kdatain{1};
      kdata0.value=kdatain{1}.vlist(ii);
      x=exe3(SS,{kdata{:},kdata0},kdatanew);
      cellSS(end+1:end+length(x))=x(:);
    end
  end
  return;
end

% make
n=length(kdata); % n: must be nunber of kye
for ii=1:n
  k=kdata{ii};
  if (k.kid>=1)
    % for data
    dl=size(SS.SummarizedData,1);
    shiboFlag=[];
    for dd=1:dl
      if size(SS.SummarizedData{dd,1},k.kid)<k.value
        shiboFlag(end+1)=dd;
      else
        SS.(k.name)=k.value;
        switch (k.kid)
          case 1
            SS.SummarizedData{dd,1}=SS.SummarizedData{dd,1}(k.value,:,:);
          case 2
            SS.SummarizedData{dd,1}=SS.SummarizedData{dd,1}(:,k.value,:);
            SS.SummarizedData{dd,2}=SS.SummarizedData{dd,2}(:,k.value);
          case 3
            SS.SummarizedData{dd,1}=SS.SummarizedData{dd,1}(:,:,k.value);
            %SS.SummarizedData{dd,2}=SS.SummarizedData{dd,2}(:,:,k.value);
        end
      end
    end
    SS.SummarizedData(shiboFlag,:)=[];
    SS.SummarizedKey(shiboFlag,:)=[];
  else
    % for key
    if isnumeric(SS.SummarizedKey{1,k.myid})
      shiboFlag=[SS.SummarizedKey{:,k.myid}]~=k.value;
    else
      try
        shiboFlag=~strcmp(SS.SummarizedKey(:,k.myid),k.value);
      catch
        warning(sprintf('Unsupported Key Type:%s',k.name));
        kdata0.vlist =[];
      end
    end
    SS.(k.name)=k.value;
    SS.SummarizedData(shiboFlag,:)=[];
    SS.SummarizedKey(shiboFlag,:)=[];
  end
  
  % No result..
  if isempty(SS.SummarizedKey)
    cellSS={};
    return;
  end
end

% mod filename
fid=strcmp(SS.Header,'filename');
xx=unique(SS.SummarizedKey(:,fid));
xx=char(xx);xx=xx';xx=xx(:)';
for ii=SS.nfile:-1:1
  if isempty(strfind(xx,SS.AnaFiles{ii}.filename))
    SS.AnaFiles(ii)=[];
  end
end
SS.nfile=length(SS.AnaFiles);
cellSS={SS};


%##########################################################################
% GUI <--> ArgData
%##########################################################################
%==========================================================================
function ArgData0=MakeArgData(mydata)
% Get Parameter's of 1st-Level-Analysis Execution
%==========================================================================
h=mydata.handle;hs=guidata(h);
h6=myhandle(hs,h,6); % Listbox
ArgData0.SelectedKeys=get(h6,'UserData');

%==========================================================================
function r=SetArgData(mydata,ArgData0)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
h=mydata.handle;
hs=guidata(h);
try
  klist=ArgData0.SelectedKeys;
  h6=myhandle(hs,h,6);
  if isempty(klist)
    set(h6,'Value',1,'String','No Keys','UserData',[]);
  else
    set(h6,'Value',1,'String',klist,'UserData',klist);
  end
catch
  r=1;
end

%##########################################################################
% GUI Callbacks
%##########################################################################
%==========================================================================
function psb_addkey_Callback(h)
% Add Key
%==========================================================================
hs=guidata(h);
h2=myhandle(hs,h,2); % key popup
if ~strcmpi(get(h2,'Enable'),'on')
  beep;
  return;
end

key=get(h2,'String');
key=key(get(h2,'Value'));

h6=myhandle(hs,h,6); % listbox
klist=get(h6,'UserData');
if isempty(klist)
  klist=key;
else
  if any(strcmp(key,klist))
    errordlg('double input');
    return;
  end
  klist{end+1}=key{1};
end
set(h6,'String',klist,'UserData',klist);
return;
%==========================================================================
function psb_removekey_Callback(h)
% Remove
%==========================================================================
hs=guidata(h);
h6=myhandle(hs,h,6); % listbox
v=get(h6,'Value');
klist=get(h6,'UserData');
if length(klist)<v
  beep;
  return;
end
klist(v)=[];
if length(klist)<v, v=length(klist);end
if isempty(klist)
  set(h6,'Value',1,'String','No Keys','UserData',[]);
else
  set(h6,'Value',v,'String',klist,'UserData',klist);
end
return;
%==========================================================================
function psb_info_Callback(h)
% show information
%==========================================================================
hs=guidata(h);
h5=h;                % me: info
mydat=createMydata2(hs,h);
APIdata=get(h5,'UserData');
feval(APIdata.Upper,'InfoButton',APIdata,mydat);


