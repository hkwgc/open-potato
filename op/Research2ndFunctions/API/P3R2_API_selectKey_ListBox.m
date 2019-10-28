function varargout=P3R2_API_selectKey_ListBox(fcn,varargin)
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
mydata.handle  = hs.(mytag(tagname,2)); % 2 indicatre the Listbox
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
tag=['R2api' num2str(id) '_' tagname];
function h=myhandle(hs,h0,id)
% Tool : get handle
tg=get(h0,'Tag');
tg(6)=num2str(id);
h=hs.(tg);

%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,APIdata)
% Create Related GUI
%==========================================================================
error(nargchk(4, 4, nargin, 'struct'));

% Make GUI
% Position --

% Other Prop
prop={'Units','pixels','Visible','off'};
c=get(hs.figure1,'Color');
prop_b={'style','pushbutton',prop{:}};



%- - - -  - - - - -
% Title
%- - - -  - - - - -
tag=mytag(tagname,1);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'HorizontalAlignment','left',...
  'backgroundcolor',c,...
  'style','text',...
  'Position',[pos(1) pos(2)+pos(4)-10 pos(3) 10]);
% is there Default Value?
if isfield(APIdata,'Title')
  set(hs.(tag),'String',APIdata.Title);
else
  set(hs.(tag),'String','Key-Selector');
end

%- - - -  - - - - -
% Key Poupumenu
%- - - -  - - - - -
tag=mytag(tagname,2);
hs.(tag)=uicontrol(hs.figure1,prop{:},...
  'TAG',tag,...
  'backgroundcolor',[1 1 1],...
  'style','listbox', 'max',2,...
  'Enable','inactive',...
  'Position',[pos(1) pos(2) pos(3) pos(4)-15] ,...
  'String','No SS-Data selected');

try
  if feval(APIdata.Upper,'enableInfoButton')
    set(hs.(tag),'Enable','on');
  end
catch
  % do nothing
end

% make data
mydata=createMydata(hs,tagname);

% Update String
%==========================================================================
function h=myhandles(hs,tagname)
% My Handle List
%==========================================================================
h=zeros([1,2]);
for i=1:2
  h(i)=[hs.(mytag(tagname,i))];
end

%==========================================================================
function h=Activate(hs,mydata)
% My GUI Visible On
%==========================================================================
h=myhandles(hs,mydata.tagname);
APIdata=get(h(2),'UserData');
try
  if ~feval(APIdata.Upper,'enableInfoButton')
    h(2)=[];
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

%============================
% No out put?
%============================
if nargout<1,  return; end
% Execution
ArgData0=MakeArgData(mydat);
Data=execute(Data,ArgData0);

function cellSS=execute(cellSS,ArgData)
% Update Cell of Summarized-Statistics Data
%
if length(cellSS)~=1
	errordlg(C__FILE__LINE__CHAR);return;
end

[c ia,ib]=intersect(ArgData.SelectedKeys,cellSS{1}.Header);
cellSS{1}.SummarizedKey=cellSS{1}.SummarizedKey(:,ib);
cellSS{1}.Header=cellSS{1}.Header(1,ib);


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
h1=myhandle(hs,h,2); % Listbox
str=get(h1,'string');
val=get(h1,'value');
ArgData0.SelectedKeys=str(val);

%==========================================================================
function r=SetArgData(mydata,ArgData0)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
h=mydata.handle;
hs=guidata(h);

try
id=[];
h6=myhandle(hs,h,2); %- ID should be "2"?
slist=get(h6,'string');
klist=ArgData0.SelectedKeys;
for k=1:length(klist)
	id(end+1)=strmatch(klist{k},slist,'exact');
end
set(h6,'value',id);
catch
	r=1;
end
	
% try
%   klist=ArgData0.SelectedKeys;
%   %h6=myhandle(hs,h,6);  bug? 2013-02-20 TK
%   h6=myhandle(hs,h,2); %- ID should be "2"?
%   if isempty(klist)
%     set(h6,'Value',1,'String','No Keys','UserData',[]);
%   else
%     set(h6,'Value',1,'String',klist,'UserData',klist);
%   end
% catch
%   r=1;
% end

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


