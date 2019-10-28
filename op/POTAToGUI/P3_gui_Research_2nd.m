function varargout=P3_gui_Research_2nd(fcn, varargin)
% P3: Research-Mode, 2nd Status GUI Control
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2010.11.05
%
% $Id: P3_gui_Research_2nd.m 365 2013-06-27 10:02:29Z Katura $
%
% 2010.11.10 : New! (2010_2_RA03)
% 2010.12.06 : Change term
%              Sumarized-Data -> Summary Stastic

if nargin<=0,OspHelp(mfilename);return;end

switch fcn
  case {'create_win','myHandles',...
      'pop_R2nd_SummarizedDataList_Init',...
      'pop_R2nd_SummarizedDataList_Callback',...
      'psb_R2nd_Add_Callback','psb_R2nd_Remove_Callback',...
      'psb_R2nd_TextOut_Callback',...
      'getExpandedSummarizedData',...
      'pop_R2nd_Function_Callback',...
      'psb_R2nd_FcnArgSave_Callback',...
      'psb_R2nd_FcnArgLoad_Callback',...
      'psb_R2nd_FcnHelp_Callback',...
      'loadCellSS',...
      }
    % Execute OK Function
    try
      if nargout,
        [varargout{1:nargout}] = feval(fcn, varargin{:});
      else
        feval(fcn, varargin{:});
      end
    catch
      rethrow(lasterror)
    end
  case 'lbx_R2nd_fileList_Callback'
    % Do nothing
    return;
  otherwise,
    disp(C__FILE__LINE__CHAR);
    error('Not Implemented Function : %s',fcn);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI & Handles Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function hs=create_win(hs)
% Make GUI for Research Pre Multi-Data
% Upper Link : POTATo_win_Research_2nd/Activate
%==========================================================================
%-----------------------
% Setting 
%-----------------------
c=get(hs.figure1,'Color');
fnt=get(0,'FixedWidthFontName');
prop={'Units','pixels','FontName',fnt};
prop_t=[prop,...
  {'style','text',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c}];
prop_b=[prop,...
	{'style','pushbutton',...
	'BackgroundColor',[0.8 0.4 0.4],'ForegroundColor',[1 1 1]}];
prop_b2=[prop,...
  {'style','pushbutton',...
  'BackgroundColor',[0.4 0.4 0.8],'ForegroundColor',[1 1 1]}];
xsize0=360;  % Width of Area
xsizel=160;  % Width of Left Area
sx0=410; % start x (with indent 0)
sx1=414; % start x (with indent 1)
ix=10;    % Interval of x
iy= 3;    % Interval of y

%----------------------------
% Make GUI
%----------------------------
% Title
y0=468;

%-------------------------
% Summarized Data-List
%-------------------------
y=y0;dy=128; xsize=xsize0;
tag='frm_R2nd_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','frame','Position',[sx0 y-dy xsize dy]);
ybk=y-dy;

y=y0-iy;dy=18;xsize=xsizel;
y=y-dy;
tag='txt_R2nd_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Summary Stastic Data List:',...
  'Position',[sx1 y xsize dy]);

dy=20; y=y-dy-iy; 
tag='pop_R2nd_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'No-Data'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx1 y xsize dy]);

% Add/Remove
sx3=sx1;
xsize=xsize/2;
dy=20;y=y-dy-iy;
tag='psb_R2nd_Add';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Add',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

sx3=sx3+xsize;
tag='psb_R2nd_Remove';
hs.(tag)=uicontrol(hs.figure1,prop_b{:},'TAG',tag,...
  'String','Remove',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx3 y xsize dy]);

% List
xsize=xsizel;
dy=56; y=y-dy-iy; 
tag='lbx_R2nd_SummarizedDataList';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String',{'No-Data'},...
  'Position',[sx1 y xsize dy]);

% Comment
dy=18;y=y0-dy-iy; xsize=xsizel-ix;
sx3=sx1+xsizel+ix+ix;
tag='txt_R2nd_Comment';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'String','Comment:',...
  'Position',[sx3 y xsize dy]);

dy=100; y=y-dy-iy; 
tag='lbx_R2nd_Comment';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'Position',[sx3 y xsize dy]);

% Covwe up Search-GUI
p1=get(hs.edt_searchfile,'Position');
p2=get(hs.txt_searchfile,'Position');
pp=[min(p1(1),p2(1)) min(p1(2),p2(2))];
pp(3)= max(p1(1)+p1(3),p2(1)+p2(3))-pp(1);
pp(4)= max(p1(2)+p1(4),p2(2)+p2(4))-pp(2);
tag='txt_R2nd_CoverupSearchGUI';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,'Position',pp);

%---------------------------------
% Function's
%---------------------------------
y=ybk;
dy=260;y=y-dy-iy; xsize=xsize0;
tag='frm_R2nd_Function';
hs.(tag)=uicontrol(hs.figure1,prop_t{3:end},'TAG',tag,...
  'style','frame','Position',[sx0 y xsize dy]);

y=ybk-iy;
dy=20;y=y-dy-iy; xsize=xsizel;
% tag='txt_R2nd_Function';
% hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
%   'String','Analysis Function:',...
%   'Position',[sx1 y xsize dy]);
%sx4=sx1+xsize;
sx4=sx1;
dy=20; %y=y-dy-iy; 
tag='pop_R2nd_Function';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','popupmenu','BackgroundColor',[1 1 1],...
  'String',{'NoFunction'},...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx4 y xsize dy]);

sx4=sx1+xsize+ix;ix3=1;
xsize=(xsizel-ix -2*ix3)/3;
% save load help
tag='psb_R2nd_FcnArgSave';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Save',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx4 y xsize dy]);
sx4=sx4+xsize+ix3;
tag='psb_R2nd_FcnArgLoad';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Load',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx4 y xsize dy]);
sx4=sx4+xsize+ix3;
tag='psb_R2nd_FcnHelp';
hs.(tag)=uicontrol(hs.figure1,prop_b2{:},'TAG',tag,...
  'String','Help',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[sx4 y xsize dy],...
  'style','toggle');


%---------------------------------
% List Box
%---------------------------------
pos=get(hs.lbx_disp_fileList,'Position');
if 0
  disp(C__FILE__LINE__CHAR);
  disp('Debug Mode Running...: R2nd File-List-Box Position');
  pos(3)=pos(3)/2;
  pos(1)=pos(1)+pos(3);
end
tag='lbx_R2nd_fileList';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','listbox','BackgroundColor',[1 1 1],...
  'String','No Data','HorizontalAlignment','left',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Max',100,'Position',pos);
%---------------------------------
% Data I/O
%---------------------------------
pos=get(hs.psb_export_workspace,'Position');
pos(2)=pos(2)+pos(4)+iy;
tag='psb_R2nd_TextOut';
hs.(tag)=uicontrol(hs.figure1,prop{:},'TAG',tag,...
  'style','pushbutton',...
  'String','Text Out',...
  'Callback',[mfilename '(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',pos);

%--------------------------------------------------------------------------
% Init & Listup Research-Mode 1st-Level-Analysis Functions
%    2010_2_RA03-2
%--------------------------------------------------------------------------
logmsg={};
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path); %#ok
if( strcmp(ff,'WinP3')~=0 )
  path0 = [osp_path filesep '..' filesep];
else
  path0 = [osp_path filesep];
end

plugin_path = [path0 'PluginDir'];
fs=find_file('^P3R2F_\w+.[mp]$', plugin_path,'-i');

plugin_path = [path0 'Research2ndFunctions'];
fs0=find_file('^P3R2F_\w+.[mp]$', plugin_path,'-i');
fs=[fs,fs0];

str={};udata={};
try
  ll=length(fs);
  for ii=1:ll
    [p nm] = fileparts(fs{ii}); %#ok
    try
      bi=feval(nm,'createBasicInfo');
      hs=feval(nm,'CreateGUI',hs);
      
      str{end+1}=bi.name;
      udata{end+1}=bi;
    catch
      logmsg{end+1}=sprintf('Error : %s, %s',nm,lasterr);
    end
  end
  if ~isempty(logmsg)
    %msglistbox(logmsg,'Statistical Test Initialization','error');
    msgbox(logmsg,'Statistical Test Initialization','error');
  end
catch
end
set(hs.pop_R2nd_Function,'Value',1,'String',str,'UserData',udata);

%---------------------------------
% NG: Text  (Bug fix: B110226A)
%---------------------------------
tag='txt_R2nd_NoSummarizedData';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
  'Max',3,...
  'String',{'No Summary Stastic Data', ' Please Execute 1st-Level-Analysis first'},...
  'Position',[sx0-ix 0 xsize0+4*ix 470]);


%---------------------------------
% Save GUI-Data
%---------------------------------
guidata(hs.figure1,hs); % save

%==========================================================================
function h=myHandles(hs)
% Handles
%==========================================================================
h=[hs.txt_R2nd_SummarizedDataList,...
  hs.pop_R2nd_SummarizedDataList,hs.lbx_R2nd_SummarizedDataList,...
  hs.psb_R2nd_Add,hs.psb_R2nd_Remove,...
  hs.txt_R2nd_Comment, hs.lbx_R2nd_Comment,...
  hs.psb_R2nd_TextOut,...
  hs.frm_R2nd_SummarizedDataList,...
  hs.frm_R2nd_Function,...
  hs.pop_R2nd_Function,...
  hs.psb_R2nd_FcnArgSave,hs.psb_R2nd_FcnArgLoad,hs.psb_R2nd_FcnHelp,...
  hs.lbx_R2nd_fileList,...
  hs.txt_R2nd_CoverupSearchGUI,...
  hs.txt_R2nd_NoSummarizedData
  ];


%##########################################################################
% Select Summarized-Data
%##########################################################################
%==========================================================================
function pop_R2nd_SummarizedDataList_Init(hs)
% List Up SummarizedDataList
%==========================================================================
dl=DataDefIN_SummarizedData('loadlist');
if isempty(dl)
  set(hs.txt_R2nd_NoSummarizedData,'Visible','on');
  return;
end

% Make Display String
k=DataDefIN_SummarizedData('getIdentifierKey');
str=cell([1,length(dl)]);
for ii=1:length(dl)
  bi=feval(dl(ii).ExeFunction,'createBasicInfo');
  str{ii}=sprintf('%s (%s)',dl(ii).(k),bi.name);
end
% Select Data
vl=get(hs.pop_R2nd_SummarizedDataList,'Value');
if (vl>length(str)), vl=1;end

% Update GUI's
set(hs.pop_R2nd_SummarizedDataList,...
  'Value',vl,'String',str,...
  'UserData',dl);
set(hs.txt_R2nd_NoSummarizedData,'Visible','off');
% Callback
pop_R2nd_SummarizedDataList_Callback(hs);

%==========================================================================
function pop_R2nd_SummarizedDataList_Callback(hs)
% Update Comment Listbox *GUI(5)
%==========================================================================
h=hs.pop_R2nd_SummarizedDataList;
ud=get(h,'UserData');
d=ud(get(h,'Value'));

set(hs.lbx_R2nd_Comment,'String',d.Comment);

%==========================================================================
function psb_R2nd_Add_Callback(hs)
% Add Summarized Data to List
%==========================================================================
hd=hs.pop_R2nd_SummarizedDataList;
ud=get(hd,'UserData');
d =ud(get(hd,'Value')); % Summarized Data
k =DataDefIN_SummarizedData('getIdentifierKey');
bi=feval(d.ExeFunction,'createBasicInfo');
st=sprintf('%s (%s)',d.(k),bi.name);

hl=hs.lbx_R2nd_SummarizedDataList;
str=get(hl,'String');
udl=get(hl,'UserData');

if 1 % Same Data Check
  if any(strcmp(st,str))
    % Same Data
    errordlg({'Summary Statistics Data named',...
      ['"' st '"'],'   already listed'},'Resaerch 2nd');
    return;
  end
end
if isempty(udl)
  udl=d;
  str={st};
else
  udl(end+1)=d;
  str{end+1}=st;
end
set(hl,'String',str,'UserData',udl,'Value',length(str));
lbx_R2nd_SummarizedDataList_Update(hs);

%==========================================================================
function psb_R2nd_Remove_Callback(hs)
% Remove Summarized Data from List
%==========================================================================
hl=hs.lbx_R2nd_SummarizedDataList;
str=get(hl,'String');
udl=get(hl,'UserData');
vl=get(hl,'Value');

if isempty(udl) 
  errordlg('No Data To Remove List');
  return;
else
  udl(vl)=[];
  str(vl)=[];
end
if isempty(str)
  str={'No Listup Data'};
end
set(hl,'String',str,'UserData',udl,'Value',1);
lbx_R2nd_SummarizedDataList_Update(hs);

%==========================================================================
function lbx_R2nd_SummarizedDataList_Update(hs)
% Update lbx_R2nd_SummarizedDataList
%==========================================================================
hl=hs.lbx_R2nd_fileList;
% Load SS Data
cellSS=loadCellSS(hs);

% modify
vl=get(hs.pop_R2nd_Function,'Value');
ud=get(hs.pop_R2nd_Function,'UserData');
% Activate Current Function
try
  cellSS=feval(ud{vl}.fcn,'UpdateRequest',hs,'Init',cellSS);
catch
end

% make Info
info=P3R2_API_SSTools('getDataInformation',cellSS);
% show
set(hl,'Value',1,'String',info);



%##########################################################################
% Summarized Data
%##########################################################################
%==========================================================================
function cellSS=loadCellSS(hs,flg)
% get Raw Summarized Data
% Inpu :
%    hs: potato handles
%    flg : 0 :  do nothing
%          1 :  add Summarized Data Name to Sarch key
%    1. get Summarized-Data-List
%    2. Merge it.
%    3. Output
%==========================================================================
hl=hs.lbx_R2nd_SummarizedDataList;
ud=get(hl,'UserData');
if isempty(ud), cellSS={};return;end
if nargin<=1
	flg=1;
end

% init for load loop
fcn = 'DataDefIN_SummarizedData';
dnum=length(ud);
cellSS=cell([1,dnum]);
for idx=1:dnum
  dataf=feval(fcn,'load',ud(idx));
  
  
  if flg==1 && ~any(strcmp(dataf.data.Header,'SummarizedDataName'))
	  % 2013.06.27
	  % Summarized Data Name to Sarch key
	  dataf.data.Header{end+1}='SummarizedDataName';  % Add Name
	  
	  nr = size(dataf.data.SummarizedKey,1); % number of row
	  nf = length(dataf.Name);               % length of "Name"
	  C=mat2cell(repmat(dataf.Name,nr,1),ones(nr,1),nf); % Make Add Data
	  dataf.data.SummarizedKey=[dataf.data.SummarizedKey, C];
  end

  cellSS(idx)={dataf.data};
end

%==========================================================================
function rsd=getRawSummarizedData(hs,flg)
% get Raw Summarized Data
%    1. get Summarized-Data-List
%    2. Merge it.
%    3. Output
%       - rsd.shead, Header
%       - rsd.skey,  Key
%       - rsd.sdata, Data
%==========================================================================
if nargin<=1
	flg=1;
end
hl=hs.lbx_R2nd_SummarizedDataList;
ud=get(hl,'UserData');
fcn = 'DataDefIN_SummarizedData';
if isempty(ud), rsd=[];return;end
shead={};
skey ={};
sdata={};
for idx=1:length(ud)
  dataf=feval(fcn,'load',ud(idx));

  if flg==1 && ~any(strcmp(dataf.data.Header,'SummarizedDataName'))
	  % 2013.06.27
	  % Summarized Data Name to Sarch key
	  dataf.data.Header{end+1}='SummarizedDataName';  % Add Name
	  
	  nr = size(dataf.data.SummarizedKey,1); % number of row
	  nf = length(dataf.Name);               % length of "Name"
	  C=mat2cell(repmat(dataf.Name,nr,1),ones(nr,1),nf); % Make Add Data
	  dataf.data.SummarizedKey=[dataf.data.SummarizedKey, C];
  end
  
  datar=dataf.data;
  if isempty(datar.SummarizedData), continue; end
  % Update Data
  sdata=[sdata; datar.SummarizedData];
  % Update Header
  shead0=shead;
  shead=union(shead,datar.Header);
  [x i0o i0i]=intersect(shead, shead0); %#ok x is not use
  [x ido idi]=intersect(shead, datar.Header); %#ok x is not use
  % Update Key
  rown=size(sdata,1);
  coln=length(shead);
  tmp=cell([rown, coln]);
  tmp(1:size(skey,1)  ,i0o) = skey(:,i0i);
  tmp(size(skey,1)+1:end,ido) = datar.SummarizedKey(:,idi);
  skey=tmp;
end

rsd.shead=shead;
rsd.skey =skey;
rsd.sdata=sdata;

%==========================================================================
function esd=getExpandedSummarizedData(hs)
% Get Expanded Summarized-Data
%    1. get Raw-Summarized-Data
%    2. Expand it.
%    3. Output
%       - esd.head, Header
%       - esd.data, Data
%==========================================================================
rsd=getRawSummarizedData(hs);
if isempty(rsd), esd=[];return;end
% Expand Raw-Summarized-Data
esd.head = {'Data','Time','Channel','Kind', rsd.shead{:}};
esd.data = cell([0,length(esd.head)]);
for ii=1:size(rsd.sdata,1) % Data Loop
  % Data
  for ch=1:size(rsd.sdata{ii,1},2)
    % Ignore Flaged Data
    if (rsd.sdata{ii,2}(1,ch)>=1),  continue; end
    for tm=1:size(rsd.sdata{ii,1},1)
      for kd=1:size(rsd.sdata{ii,1},3)
        % Print Store
        esd.data(end+1,:)=...
          {rsd.sdata{ii,1}(tm,ch,kd),tm,ch,kd,...
          rsd.skey{ii,:}};
      end
    end
  end
end

%==========================================================================
function psb_R2nd_TextOut_Callback(hs)
% 
%==========================================================================
esd=getExpandedSummarizedData(hs);
if isempty(esd)
  errordlg('No Data to Text Output');
  return; 
end
[fname, pname] = osp_uiputfile('*.csv', 'Output File Name');
if isequal(fname,0) || isequal(pname,0)
  return;
end

fname=[pname filesep fname];
%fname0=[pname filesep fname];
%fname=tempname;
try
  wbh = waitbar(0,'Please wait...','WindowStyle','Modal','Name','Text OUT');
  fid=fopen(fname,'w');
  fprintf(fid,'Summary Stastic Data Output File\n');
  fprintf(fid,' in Research(2nd) Mode\n');
  fprintf(fid,',,POTATo Versin %s\n',OSP_DATA('GET','POTAToVersion'));
  for ii=1:length(esd.head)
    fprintf(fid,'%s,',esd.head{ii});
  end
  fprintf(fid,'\n');

  wb_unit =size(esd.data,1) *2.5/100; % 2.5% unit..
  wb_unit0=wb_unit;
  for ii=1:size(esd.data,1) % Data Loop
    % Data (key)
    keystr='';
    for jj=1:size(esd.data,2)
      try
        if isnumeric(esd.data{ii,jj})
          keystr=[keystr ',' num2str(esd.data{ii,jj})];
        else
          keystr=[keystr ',' esd.data{ii,jj}];
        end
      catch
        keystr=[keystr ',***'];
      end
    end % keystr
    if ~isempty(keystr), keystr(1)=[];end
    % Print Data
    fprintf(fid,'%s\n',keystr);
    if (wb_unit<ii)
      waitbar(ii/size(esd.data,1),wbh);
      wb_unit=wb_unit+wb_unit0;
    end
  end
catch
  fclose(fid);
  close(wbh)
  rethrow(lasterror);
end
fclose(fid);
close(wbh)
%movefile(fname,fname0);

% function psb_R2nd_TextOut_Callback(hs)
% % 
% %==========================================================================
% sd=getRawSummarizedData(hs);
% if isempty(sd)
%   errordlg('No Data to Text Output');
%   return; 
% end
% [fname, pname] = osp_uiputfile('*.csv', 'Output File Name');
% if isequal(fname,0) || isequal(pname,0)
%   return;
% end
% fname=[pname filesep fname];
% try
%   fid=fopen(fname,'w');
%   fprintf(fid,'Summarized Data Output File\n');
%   fprintf(fid,' in Research(2nd) Mode\n');
%   fprintf(fid,',,POTATo Versin %s\n',OSP_DATA('GET','POTAToVersion'));
%   fprintf(fid,'Data,Time,Channel,Kind');
%   for ii=1:length(sd.shead)
%     fprintf(fid,',%s',sd.shead{ii});
%   end
%   fprintf(fid,'\n');
%   for ii=1:size(sd.sdata,1) % Data Loop
%     % Data (key)
%     keystr='';
%     for jj=1:size(sd.skey,2)
%       try
%         if isnumeric(sd.skey{ii,jj})
%           keystr=[keystr ',' num2str(sd.skey{ii,jj})];
%         else
%           keystr=[keystr ',' sd.skey{ii,jj}];
%         end
%       catch
%         keystr=[keystr ',***'];
%       end
%     end % keystr
%     % Data
%     for tm=1:size(sd.sdata{ii,1},1)
%       for ch=1:size(sd.sdata{ii,1},2)
%         for kd=1:size(sd.sdata{ii,1},3)
%           % Ignore Flaged Data
%           if (sd.sdata{ii,2}(1,ch)>=1),  continue; end
%           % Print Data
%           fprintf(fid,'%f,%d,%d,%d%s\n',...
%             sd.sdata{ii,1}(tm,ch,kd),tm,ch,kd,keystr);
%         end
%       end
%     end
%   end
% catch
%   fclose(fid);
%   rethrow(lasterror);
% end
% fclose(fid);

%##########################################################################
% Execute Funciton :: Callback
%##########################################################################
%==========================================================================
function pop_R2nd_Function_Callback(hs,oldval)
%  Change File
%==========================================================================
persistent myval;

% Function Check
if nargin>=2
  myval=oldval;
end
vl=get(hs.pop_R2nd_Function,'Value');
ud=get(hs.pop_R2nd_Function,'UserData');

% Check Do-nothing
if ~isempty(myval) && isnumeric(myval)
  if (vl==myval)
    return;
  end
  % Suspend Old-Function
  feval(ud{myval}.fcn,'Suspend',hs);
end

% Activate Current Function
try
  feval(ud{vl}.fcn,'Activate',hs);
  lbx_R2nd_SummarizedDataList_Update(hs); % data update-request
catch
end
myval=vl;
psb_R2nd_FcnHelp_Callback(hs);

%==========================================================================
function psb_R2nd_FcnArgSave_Callback(hs)
% Save Execute Function Argument
%==========================================================================
vl=get(hs.pop_R2nd_Function,'Value');
ud=get(hs.pop_R2nd_Function,'UserData');
p3r2f_data=ud{vl};

name0=['STArg_' p3r2f_data.fcn '_'  datestr(now,'dd_mmm_yyyy') '.mat'];
[fname, pname] = osp_uiputfile(name0, 'Save Argument File Name');
if isequal(fname,0) || isequal(pname,0)
  return;
end
ArgData=feval(p3r2f_data.fcn,'MakeArgData',hs); %#ok
FcnName=p3r2f_data.fcn;                          %#ok
save([pname filesep fname], 'ArgData','FcnName');

%==========================================================================
function psb_R2nd_FcnArgLoad_Callback(hs)
% Save Execute Function Argument
%==========================================================================
vl=get(hs.pop_R2nd_Function,'Value');
ud=get(hs.pop_R2nd_Function,'UserData');
p3r2f_data=ud{vl};

[fname, pname] = osp_uigetfile('*.mat', 'Argument Data File Name');
if isequal(fname,0) || isequal(pname,0)
  return;
end
LoadData=load([pname filesep fname]);
if ~strcmpi(LoadData.FcnName,p3r2f_data.fcn)
  errordlg({'Bad Function Data', ...
    ['  * Selected  Function : ' p3r2f_data.fcn],...
    ['  * Load Data Function : ' LoadData.FcnName]},...
    'Load Argument Data Error');
  return;
end
feval(p3r2f_data.fcn,'SetArgData',hs,LoadData.ArgData);
% Reload (Update) :: old :: 
%pop_R2nd_Function_Callback(hs,[]);

%==========================================================================
function psb_R2nd_FcnHelp_Callback(hs)
% Save Execute Function Argument
%==========================================================================
if get(hs.psb_R2nd_FcnHelp,'Value')==1
  vl=get(hs.pop_R2nd_Function,'Value');
  ud=get(hs.pop_R2nd_Function,'UserData');
  p3r2f_data=ud{vl};
  %POTATo_Help(p3r2f_data.fcn);
  sfh=gcbf;uihelp(p3r2f_data.fcn);figure(sfh);
  %set(0,'currentFigure',sfh)
else
  uihelp([],'close');
end

