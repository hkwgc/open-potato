function varargout=P3_AdvTgl_1stLvlAna(fnc,varargin)
% P3 : 1st-Lvl-Ana Toggle-Button Control Function


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if nargin<1,OspHelp(mfilename);end
  
%======== Launch Switch ========
switch fnc,
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'Exe',
    % Syntax : Exe(handles)
    Exe(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hs=Create(hs)
% Make Advanced Tgl Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================
% Make TGL Button
%===============================
hs.advtgl_1stLvlAna = ...
  subput_advbutton(8,5,15+2,'Tight',...
  'Tag','advtgl_1stLvlAna',...
  'Style','ToggleButton',...
  'String','1stLvlAna',...
  'Visible','off',...
  'Callback',...
  'P3_AdvTgl(''ChangeTgl'',gcbo,guidata(gcbo))');

%===================
% Sub-Handle
%===================
opt={...
  'Follows Plugin', ...
  'InputName', ...
  'Date', ...
  'ID'};

% Rename Option's
hs.advpop_1stLvlAna_Rename = ...
  subput_advbutton(6,2,6+1,'Inner',...
  'Style','Popupmenu',...
  'Visible','off',...
  'String',opt,...
  'Value',1,...
  'BackgroundColor',[1 1 1],...
  'Tag','advpsb_1stLvlAna_Rename',...
  'Callback',...
  'P3_AdvTgl_1stLvlAna(''ChangeRename'',gcbo,guidata(gcbo))');

hs.advpop_1stLvlAna_Rename.Visible='on';  % HK: avoid undesired GUI visiblity
hs.advpop_1stLvlAna_Rename.Visible='off'; % HK: avoid undesired GUI visiblity


hs.advedt_1stLvlAna_Rename = ...
  subput_advbutton(6,2,8+1,'Inner',...
  'Visible','off',...
  'Style','Edit',...
  'BackgroundColor',[1 1 1],...
  'String',date,...
  'Tag','advedt_1stLvlAna_Rename');

% Execute Button
hs.advpsb_1stLvlAna_Exe = ...
  subput_advbutton(6,3,15+3,'Inner',...
  'Visible','off',...
  'Tag','advtgl_1stLvlAna',...
  'String','Exe 1st-Lvl-Ana',...
  'Callback',...
  'P3_AdvTgl_1stLvlAna(''Exe'',guidata(gcbo))');

%===============================
% Set Advance Toggle Data
%===============================
atd0.TglHandle=hs.advtgl_1stLvlAna;
atd0.Function =eval(['@' mfilename ';']);

atd=getappdata(hs.figure1,'AdvancedToggleData');
if isempty(atd),  atd = atd0;
else              atd(end+1)=atd0; end
setappdata(hs.figure1,'AdvancedToggleData',atd);

%===============================
% Set Advance Mode Handle
%===============================
av=OSP_DATA('GET','AdvanceButtonHandles');
av=[av(:);hs.advtgl_1stLvlAna;subhandle(hs)];
OSP_DATA('SET','AdvanceButtonHandles',av);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=subhandle(hs)
% Set Subhandles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=[hs.advpop_1stLvlAna_Rename;...
  hs.advedt_1stLvlAna_Rename;...
  hs.advpsb_1stLvlAna_Exe;];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(h,hs)
% Suspend TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',0)
set(subhandle(hs),'Visible','off');
OspFilterCallbacks('pop_FilterDispKind_Switch_1stLvl',...
  hs.pop_FilterDispKind,[],hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(h,hs)
% Activate TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',1);
set(subhandle(hs),'Visible','on');
OspFilterCallbacks('pop_FilterDispKind_Switch_1stLvl',...
  hs.pop_FilterDispKind,[],hs);
%P3_AdvTgl_status('Logging',hs,...
%  ' --> Activate "1st-Lvl-Ana"');

%==================================
% Data Initiarize
%==================================
ChangeRename(hs.advpop_1stLvlAna_Rename,hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=====================================
function ChangeRename(h,hs)
%  Change Visible of edit-txt
%  (Callback when Rename Popup-menu was change.)
%=====================================
opt=get(h,'String');
opt=opt{get(h,'Value')};
if strcmpi(opt,'InputName')
  set(hs.advedt_1stLvlAna_Rename,'Visible','on');
else
  set(hs.advedt_1stLvlAna_Rename,'Visible','off');
end


%===========================================
function Exe(hs)
% Execute 1st-Level-Analysis
%  (Callback when Exe-1stLvlAna-Button down)
%===========================================
setappdata(hs.figure1,'FastLevelAna_StartTime',datestr(now,0));
%------------------
% Make M-File (ANA)
%------------------
% Get Filter-Manager-Data
fmd = OspFilterCallbacks('get with 1st Lvl Ana',...
  hs.figure1,false);

%------------------
% Make M-File
%------------------
% Make Temp-File-Name
path0 = fileparts(which('OSP'));
path0 = [path0 filesep 'ospData' filesep];
fname0= ['flaexe_' datestr(now,30)];
fname = [path0 fname0 '.m'];
  
make_mfile('fopen', fname,'w');
try
  P3_FilterData2Mfile(fmd);
catch
  make_mfile('fclose');
  rethrow(lasterror);
end
make_mfile('fclose');
% Ensure Function.
%rehash TOOLBOX
rehash

%------------------
% Execute M-File
%------------------
% Execute File-Data List
fdataXXX=get(hs.lbx_fileList,'UserData');
fdataXXX=fdataXXX(get(hs.lbx_fileList,'Value'));

% Evaluate Upper M-File for File-Data-List
% See also P3_FilterData2Mfile
fdatalen=length(fdataXXX);
wb_rate =0;
wb_step =1/fdatalen;
wb_h    =waitbar(wb_rate,'Executing 1st-LVL-ANA...');
% Buffering:20080731
FileFunc('BufferingMode');
DataDef2_1stLevelAnalysis('save',0); % Start BufferMode
for idx=1:fdatalen
  % -- File name Get --
  try
    ana=DataDef2_Analysis('load',fdataXXX(idx));
    datanames = DataDef2_RawData('getFilename',ana.data.name);
    [p f e] = fileparts(datanames);
    if 1,
      % Search in Project-->
      set(hs.advpsb_1stLvlAna_Exe,...
        'UserData',[f e]);
    else
      set(hs.advpsb_1stLvlAna_Exe,...
        'UserData',[p filesep f e]);
    end
    eval(fname0);
    wb_rate=wb_rate+wb_step;
    try , wb_h    =waitbar(wb_rate,wb_h);  end %#ok
  catch
    wb_rate=idx*wb_step;
    errordlg({'In Execute 1st-Level-Analysis',...
      [' Data  : Analysis-Data "' ana.filename '"'],...
      [' Error : ' lasterr]},...
      'P3 : 1st-Lvl-Ana Execute Error');
  end
end
DataDef2_1stLevelAnalysis('save',1); % End BufferMode
FileFunc('Flush'); % Buffering:20080731
try,delete(wb_h);end %#ok
set(hs.advpsb_1stLvlAna_Exe,'UserData','');

% for debug :: backup Exefiel
if 1,
  % ordinary
  delete(fname);
else
  % debug
  fnamex = [pwd filesep 'dbg_flaexe.m'];
  movefile(fname,fnamex);
  disp('Debug Mode is Running ; ');
  disp(mfilename);
  disp(C__FILE__LINE__CHAR);
  return;
end

%------------------
% Filnalize
%------------------
% Logging
P3_AdvTgl_status('Logging',hs,...
  ' --> Execute "1st-Lvl-Ana"');
% Delete 1st-Level-Plugin
fmd=OspFilterCallbacks('get',hs.figure1);
OspFilterCallbacks('set',hs.figure1,fmd);
% Change Status
P3_AdvTgl('ChangeTgl',hs.advtgl_status,hs);

% ==> Project Reset
setappdata(hs.figure1,'CurrentSelectFile',true) ;
POTATo('ChangeProjectIO',hs.figure1,[],hs);

  
