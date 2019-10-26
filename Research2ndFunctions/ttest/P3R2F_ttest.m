function varargout=P3R2F_ttest(fcn,varargin)
% POTATo : Research Mode 2nd-Level-Analysis Function "Average"

% == History ==
%  2011.01.26 : New! (for testing....)

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'createBasicInfo','CreateGUI',...
      'Activate','Suspend',...
      'MakeArgData','SetArgData',...
      'UpdateRequest',...
      'execute',...
      'rdb_onesample_Callback',...
      'rdb_twosample_Callback',...
      'rdb_paired_Callback',...
      'rdb_unpaired_Callback',...
      'InfoButton',...
      'exebutton_Callback','CallBack_Averaging_CheckBox'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case 'enableInfoButton'
    varargout{1}=false;
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
basic_info.name = 'T-test';   % Display-Name 
basic_info.ver  = 1.0;          % Version (double)
basic_info.fcn  = mfilename;    % Function-Name

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tag)
% Tool : make unique tagname.
tag=[tag '_' mfilename];
function cbstr=myCallback(tag)
cbstr=[mfilename '(''' tag(1:end-length(mfilename)-1) '_Callback'',guidata(gcbo));'];

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
pf=get(hs.frm_R2nd_Function,'Position'); % GUI Range..
pp=get(hs.pop_R2nd_Function,'Position'); % GUI 
iy=3;ix=10; % margin

sx1=pf(1)+ix; y=pp(2);
xsize  =pf(3)-2*ix;
xsizep2=xsize/2-ix/2;
sx2=sx1+ix+xsizep2;

%----------------------
% Set Grouping API
%----------------------
APIdata.Upper     =mfilename;
APIdata.Before    ={};
apidata0={}; % API - Data-sets

% Independent Key API
dy=100; y=y-dy-2*iy;
tag=mytag('indep');
APIdata.Title     ='Independent key';
[hs, apidata0{end+1}]=P3R2_API_selectKey('CreateGUI',hs,tag,...
  [sx1 y xsizep2 dy],APIdata);

%- Target Data
A=POTATo_sub_MakeGUI(hs.figure1);
A.Name='targetData_';A.PosX=sx2;A.PosY=y-10;A.String='SummarizedData';A.Label='Target Data';
A.UIType='popupmenu';A.handles=hs;
A=POTATo_sub_MakeGUI(A);
hs=A.handles;

% Independent Key API
tag=mytag('target');
APIdata.Title     ='Target Group';APIdata.Before    = apidata0;
[hs, apidata0{end+1}]=P3R2_API_groupingByKey('CreateGUI',hs,tag,[sx2 y-40 xsizep2 dy],APIdata);

%- - -
%- Averaging
%- - - 
pos0 = [sx1 y-15-15 xsizep2 15];
[hs, newHS, pos0] = sub_MakeGUI_Popupmenu(hs, 'Averaging_Tag', 'No Data Selected', 1, '', pos0, [0 -0]);
[hs, newHS, pos0] = sub_MakeGUI_Checkbox(hs, 'Averaging_CheckBox', 0, 'Average in each...', pos0,[0 25]);
y=pos0(2);
set(newHS,'CallBack',[mfilename '(''CallBack_Averaging_CheckBox'')']);

%----------------------
% T-Test GUI
%----------------------

% - - - - - - -
% T-Test Mode
% - - - - - - -
dy=20+5; y=y-dy-iy+3; ybk=y;
tag=mytag('frm_mode');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','frame',...
  'BackgroundColor',c,...
  'Position',[sx1 y xsize dy]);

dx2=10;
y=y+dy+iy - 4; dy=20; y=y-dy;
tag=mytag('rdb_onesample');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','radio',...
  'BackgroundColor',c,...
  'String','One Sample',...
  'Value',1,...
  'Position',[sx1+dx2 y xsizep2-dx2*2 dy],...
  'Callback',myCallback(tag));
tag=mytag('rdb_twosample');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','radio',...
  'BackgroundColor',c,...
  'String','Two Sample',...
  'Position',[sx2+dx2 y xsizep2-dx2*2 dy],...
  'Callback',myCallback(tag));

% - - - - - - -
% Type
% - - - - - - -
dy=25; 
y=ybk-dy-iy; %ybk=y;
tag=mytag('frm_type');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','frame',...
  'BackgroundColor',c,...
  'Position',[sx1 y xsize dy]);

dx2=10;
y=y+dy+iy - 4; 
dy=20; y=y-dy;
tag=mytag('rdb_unpaired');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','radio',...
  'BackgroundColor',c,...
  'String','Unpaired',...
  'Value',1,...
  'Position',[sx1+dx2 y xsizep2-dx2*2 dy],...
  'Callback',myCallback(tag));
tag=mytag('rdb_paired');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','radio',...
  'BackgroundColor',c,...
  'String','Paired',...
  'Position',[sx2+dx2 y xsizep2-dx2*2 dy],...
  'Callback',myCallback(tag));

dy=25;y=pf(2)+iy;
tag=mytag('exebutton');
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','launch T-Test',...
  'Position',[sx2 y xsizep2 dy],...
  'Callback',myCallback(tag));

% Save API Data
setappdata(hs.figure1,mfilename,apidata0);

%==========================================================================
function CallBack_Averaging_CheckBox
hs=guidata(gcf);
str={'on','off'};
v=get(hs.cbx_Averaging_CheckBox_P3R2F_ttest,'value');

set(hs.cbx_Averaging_CheckBox_P3R2F_ttest,'value',(v==1));
set(hs.ppm_Averaging_Tag_P3R2F_ttest,'enable',str{1+(v==0)});
%==========================================================================
function h=type_handles(hs)
% My Handle List
%==========================================================================
h=[hs.(mytag('frm_type')),...
  hs.(mytag('rdb_unpaired')),...
  hs.(mytag('rdb_paired'))];

%==========================================================================
function h=myhandles(hs)
% My Handle List
%==========================================================================
%h=hs.(mytag('ckb_R1st_ApplyFlag'));
% h=[...
%   hs.(mytag('frm_mode')),...
%   hs.(mytag('rdb_twosample')),...
%   hs.(mytag('rdb_onesample')),...
%   hs.(mytag('exebutton'))];
% h=[h, type_handles(hs)];

fn=fieldnames(hs);
h=[];
for k=1:length(fn)
	tmp=findstr(fn{k},mfilename);
	if ~isempty(tmp) && (tmp==length(fn{k})-length(mfilename)+1)
		h(end+1)=hs.(fn{k});
		myhs.(fn{k}) = hs.(fn{k});
	end
end

%==========================================================================
function h=Activate(hs)
% My GUI Visible On
%==========================================================================
h=myhandles(hs);

% %##for debug###################
% try delete(h);catch;end
% hs=CreateGUI(hs);
% guidata(hs.figure1,hs);
% h=myhandles(hs);
% %#############################

set(h,'Visible','on');
rdb_onesample_Callback(hs); % for visible 
% Activate API's
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    feval(apidata{ii}.fcn,'Activate',hs,apidata{ii});
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

%==========================================================================
%  T-test mode control
%==========================================================================
function rdb_onesample_Callback(hs)
% select one sample
set(type_handles(hs),'Visible','off');
set(hs.(mytag('rdb_twosample')),'Value',0);
set(hs.(mytag('rdb_onesample')),'Value',1);

function rdb_twosample_Callback(hs)
% select two sample
set(type_handles(hs),'Visible','on');
set(hs.(mytag('rdb_twosample')),'Value',1);
set(hs.(mytag('rdb_onesample')),'Value',0);

%==========================================================================
%  T-test Type (parir) contorl
%==========================================================================
function rdb_unpaired_Callback(hs)
set(hs.(mytag('rdb_unpaired')),'Value',1);
set(hs.(mytag('rdb_paired')),'Value',0);
function rdb_paired_Callback(hs)
set(hs.(mytag('rdb_unpaired')),'Value',0);
set(hs.(mytag('rdb_paired')),'Value',1);
%##########################################################################
% GUI <--> ExeData
%##########################################################################

%==========================================================================
function ArgData=MakeArgData(hs)
% Get Parameter's of 1st-Level-Analysis Execution
%==========================================================================

% T-Test
if get(hs.(mytag('rdb_onesample')),'Value')
  ArgData.TTest.mode='OneSample';
else
  ArgData.TTest.mode='TwoSample';
end
if get(hs.(mytag('rdb_paired')),'Value')
  ArgData.TTest.paired=true;
else
  ArgData.TTest.paired=false;
end

% API-Information
apidata=getappdata(hs.figure1,mfilename);
ArgData.APIInfo.Number=length(apidata);
ArgData.APIInfo.Stat  =cell([1,length(apidata)]);

for ii=1:length(apidata)
  api.fcn=apidata{ii}.fcn;
  api.fld=[apidata{ii}.fcn num2str(ii)];
  try
    ArgData.(api.fld)=feval(api.fcn,'MakeArgData',apidata{ii});
    api.isok  =true;
  catch
    api.isok  =false;
  end
  ArgData.APIInfo.Stat{ii}=api;
end

%- Target Data
cellSS=P3_gui_Research_2nd('loadCellSS',hs);
t.h1=hs.(mytag('ppm_targetData'));
%t.h1=hs.ppm_targetData_unknown;
%== TODO ==
t.v=get(t.h1,'value');
t.s=get(t.h1,'String');
if t.v==1
	t.data=cellSS{1}.SummarizedData;
else
	tg=strcmp(t.s{t.v},cellSS{1}.Header);
	t.data=cellSS{1}.SummarizedKey(:,tg);
end
ArgData.TargetData=t;

%- Averaging Tag
if get(hs.(mytag('cbx_Averaging_CheckBox')),'value')
	tmpS=get(hs.(mytag('ppm_Averaging_Tag')),'string');
	if ~iscell(tmpS), tmpS={tmpS};end
	tmpV=get(hs.(mytag('ppm_Averaging_Tag')),'value');
	ArgData.Averaging_Tag = tmpS{tmpV};
end
%==========================================================================
function r=SetArgData(hs,ArgData)
% Set Parameter's of 1st-Level-Analysis Execution
%==========================================================================
r=0;
% T-Test
switch ArgData.TTest.mode
  case 'OneSample'
    rdb_onesample_Callback(hs);
  case 'TwoSample'
    rdb_twosample_Callback(hs);
  otherwise
    r=1;
end
if ArgData.TTest.paired
  rdb_paired_Callback(hs);
else
  rdb_unpaired_Callback(hs);
end

% API-Information
apidata=getappdata(hs.figure1,mfilename);
for ii=1:length(apidata)
  try
    feval(apidata{ii}.fcn,'SetArgData',apidata{ii},...
      ArgData.([apidata{ii}.fcn num2str(ii)]));
  catch
    r=2;
  end
end

%##########################################################################
% Execution
%##########################################################################
function cellSS=UpdateRequest(hs,tag,varargin)

apidata=getappdata(hs.figure1,mfilename);
switch lower(tag)
  case 'init'
    % for init
    cellSS=varargin{1};
    for ii=1:length(apidata)
      try
        feval(apidata{ii}.fcn,'UpdateRequest',apidata{ii},cellSS);
      catch
      end
    end
  case 'output'
    % for Output 
    cellSS=varargin{1};
    for ii=1:length(apidata)
      try
        cellSS=feval(apidata{ii}.fcn,'UpdateRequest',apidata{ii},cellSS);
      catch
      end
    end
  otherwise
    error('Unknown tag');
end

%- check Target Data
h1=hs.(mytag('ppm_targetData'));
if isempty(cellSS)
	str={''};
elseif ~isfield(cellSS{1},'TotalChannelNumber')
	str={'SummarizedData'};
else
	flg=cellfun(@(x) length(x)==cellSS{1}.TotalChannelNumber, cellSS{1}.SummarizedKey);
	flg=all(flg,1);
	str=['SummarizedData', cellSS{1}.Header(flg)];
end
set(h1,'String',str,'value',1);	

%- Averaging Tag
str=get(hs.(mytag('R2apiSK2_indep')),'string');
if strcmp(str,'No Data selected'), 
	set(hs.(mytag('cbx_Averaging_CheckBox')),'value',0);
	set(hs.(mytag('ppm_Averaging_Tag')),'enable','off');
end
set(hs.(mytag('ppm_Averaging_Tag')),'string',str);
set(hs.(mytag('ppm_Averaging_Tag')),'value',1);



%==========================================================================
function exebutton_Callback(hs)
% Execute button
%   1. make Arguments
%   2. Execute
%==========================================================================
ArgData=MakeArgData(hs);  % get Argument from GUI

%- check data
if isempty(ArgData.P3R2_API_groupingByKey2.Group)
	errordlg('ADD at least one Target Group.');
	return;
end
%----------- 20120907

cellSS=P3_gui_Research_2nd('loadCellSS',hs);

%----------------------
% Load Raw-Data for Drawing
%----------------------
vls      = get(hs.lbx_fileList,'Value');
datalist = get(hs.lbx_fileList,'UserData');
datalist = datalist(vls);
if length(datalist)>1 %- bug fixed TK@HARL 20110209
	datalist=datalist(1);
end
an=DataDef2_Analysis('load',datalist);
rd=DataDef2_RawData('loadlist',an.data.name);
[hdata, data]=DataDef2_RawData('load',rd);
data = data(1,:,:) * nan;
ArgData.RawDataForDrawing.hdata = hdata;
ArgData.RawDataForDrawing.dummydata = data;
%----------------------
%----------------------


r=execute(cellSS,ArgData);   % GUI-Independent functin..

if (r.error)
  errordlg(r.error,'T-Test Error');
end

%==========================================================================
function result=execute(cellSS, ArgData)
% Perform T-Test
% Input : cellSS={datar,...} : cell of Summarized Statistics
%       datar: Real-part of Summarized Statistics.
%       datar.nfile    : --(undefined here.)--
%       datar.Anafiles : --(undefined here.)--
%       datar.ExeData  : --(undefined here.)--
%       datar.Header        : Cell Header of Summarized Data
%       datar.SummarizedKey : Cell Summarized Data (Key-part)
%       datar.SummarizedData: Cell Summarized Data (Data-part)
%==========================================================================
result.error='';
%---------------------
% Input param check
%---------------------
if isempty(cellSS)
  result.error='Empty Summarized Statistics Data';
  return;
end

% Input : One SS Data
if length(cellSS)>1
  try
    cellSS=P3R2_API_SSTools('merge',cellSS);
  catch
    % --> (TOOD) <-- 
    result.error='Too many Summarized Statistics Input';
    return;
  end
end

% Input : Number of API is 2
if ArgData.APIInfo.Number~=2
  result.error='Number of API must be 2';
  return;
end
for ii=1:ArgData.APIInfo.Number
  if ~ArgData.APIInfo.Stat{ii}.isok
    result.error=sprintf('API(%d) Status : Error',ii);
    return;
  end    
end

%- prepare target data
%cellSS{1}.SummarizedData=ArgData.TargetData.data;

%---------------------
% Open GUI
%---------------------
result.h=exe_P3R2F_ttest('cellSS',cellSS,'ArgData',ArgData);

%% ==========================================================================
function [hs, newHS, p] = sub_MakeGUI_Checkbox(hs, Name, Def_Value, Label_String, p,dp)
newHS=[];
[dummy,prop_t] = sub_sub_Get_Base_Properties(hs.figure1);

tag=mytag(['cbx_' Name]);
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','checkbox','String',Label_String,'Value',Def_Value,...
  'Position',p);
newHS(end+1)=hs.(tag);
p(1) = p(1)+dp(1); p(2) = p(2)-dp(2);
%% ==========================================================================
function [hs, newHS, p] = sub_MakeGUI_Popupmenu(hs, Name, Def_String, Def_Value, Label_String, p, dp)
newHS=[];
[prop,prop_t] = sub_sub_Get_Base_Properties(hs.figure1);
lblDY = 11;

tag=mytag(['txt_' Name '_Label']);
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String',Label_String,...
  'Position',[p(1) p(2) p(3) lblDY]);
newHS(end+1)=hs.(tag);

tag=mytag(['ppm_' Name]);
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'String',Def_String,'Value', Def_Value(1),...
  'Position',[p(1) p(2)-p(4)+lblDY p(3) p(4)-lblDY]);
newHS(end+1)=hs.(tag);
p(1) = p(1)+dp(1); p(2) = p(2)-dp(2);
%% ==========================================================================
function [prop,prop_t,c]=sub_sub_Get_Base_Properties(figH)
c=get(figH,'Color');
prop={'Units','pixels','Visible','off'};
prop_t={prop{:},'style','text','HorizontalAlignment','left','BackgroundColor',c};
