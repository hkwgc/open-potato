function varargout=POTATo_win_Make_MultiAnalysis(fnc,varargin)
% POTATo Window : Signal-Analysis Mode Control GUI
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
switch fnc,
  case {'DisConnectAdvanceMode','MakeMfile',...
      'ChangeLayout','DrawLayout'}
    % Use Default Function (POTATo_win)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'ConnectAdvanceMode'
    ConnectAdvanceMode(varargin{:});
    
    % TODO : Save Function
    %        --> Question Dialog "Do you want to change? <---
    
    %=========================
    % Special Functin List
    %=========================
  case 'psbOK_Callback',
    psbOK_Callback(varargin{:}); %<==handles
    
  case 'pop_MLT_AnaFile_Callback',
    pop_MMA_AnaFile_Callback(varargin{:}); %<==handles
  case 'FoceBatch'
    FoceBatch(varargin{:}); %<==handles

  otherwise
    try
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
      else
        feval(fnc, varargin{:});
      end
    catch
      % --> Undefined Function : Use Default Function
      if nargout,
        [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
      else
        POTATo_win(fnc,varargin{:});
      end
    end
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hs,pos]=myHandles(h)
% Return Entry Handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos0=get(h.frm_AnalysisArea,'Position');
pos1=get(h.frm_MakeMultiArea,'Position');
pos=pos0(1:2)-pos1(1:2);
hs=[h.txt_MMA_title,...
    h.txt_MMA_Notice,...
    h.pop_MMA_AnaFile,...
    h.lbx_MMA_AnaFileInfo,...
    h.txt_MMA_Tag,...
    h.edt_MMA_Tag,...
    h.txt_MMA_NumberOfFiles,...
    h.txt_MMA_NumberOfFiles2,...
    h.txt_MMA_ID,...
    h.edt_MMA_ID,...
    h.txt_MMA_Comment,...
    h.edt_MMA_Comment,...
    h.txt_MMA_CreateDate,...
    h.txt_MMA_CreateDate2,...
    h.psb_MMA_OK];
%    h.txt_MMA_Info,...
%    h.lbx_MMA_Info,...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(handles,varargin)
% Suspend MMA GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hs,pos]=myHandles(handles);
suspend_comm(hs,pos,handles);

h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(handles,varargin)
% Activate MMA GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=============================
% Move GUI : Current Position
%=============================
[hs,pos]=myHandles(handles);
activate_comm(hs,pos,handles);

% No Viewer and No Visible
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');

ismakemult=get(handles.advpsb_MultiAna,'UserData');
if ismakemult,
  set(handles.txt_MMA_Notice,'Visible','off');
else
  set(handles.txt_MMA_Notice,'Visible','on','BackgroundColor',[0.84,0.68,0.8]);
end

%=============================
% Make Default Multi File
%=============================
%-------------------------
% Load Data
%-------------------------

% get current DataDef (II) Function
fcn=get(handles.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  fcn=fcn{get(handles.pop_filetype,'Value')};
end

% get Data-File
filedata=get(handles.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
else
  vls=get(handles.lbx_fileList,'Value');
  data0=filedata(vls);
  clear filedata;
end

%-------------------------
% Making
%-------------------------
% --> See also ospprj2p3prj
multdata.Tag='Untitled';
multdata.NumberOfFiles=length(data0);
multdata.ID_number=1;
multdata.Comment='';
multdata.CreateDate=now;
idkey  = feval(fcn,'getIdentifierKey');
if 1
  % Save Only Pointer
  multdata.data.AnaKeys   = eval(['{data0.' idkey '};']);
else
  % Save {(RAW)+(Single-Resipi)} x n
  multdata.data.AnaKyes   = eval(['{data0.' idkey '};']);
end

%=============================
% refresh GUI Multi File
%=============================
ot={'BackgroundColor',[0.9 0.9 0.9],'ForegroundColor',[0 0 0]};
set(handles.edt_MMA_Tag,'String',multdata.Tag,ot{:});
set(handles.txt_MMA_NumberOfFiles2,'String',num2str(multdata.NumberOfFiles),ot{:});
set(handles.edt_MMA_ID,'String',num2str(multdata.ID_number),ot{:});
set(handles.edt_MMA_Comment,'String',multdata.Comment,ot{:});
set(handles.txt_MMA_CreateDate2,'String',datestr(multdata.CreateDate,1),ot{:});

% ========================
% Load Analysis Data Key
% ========================
[anadata, str, isblock]   = DataDef2_MultiAnalysis('get_ANA_info',multdata);
set(handles.pop_MMA_AnaFile,'String',str,'UserData',anadata,'Value',1);
% ========================
% Show Recipes:
%  Meeting on 20-Apr-2007
%  ** 2.2 **
% ========================
pop_MMA_AnaFile_Callback(handles)

% ========================
% Checking Data:
%   Meeting on 20-Apr-2007 
%   ** 2.4.1 **
% ========================
% -- reflect result --
% TODO:? with notify?
if ~isempty(isblock) && all(isblock(:)==isblock(1))
  set(handles.psb_MMA_OK,'Enable','on');
else
  set(handles.psb_MMA_OK,'Enable','off');
end


%--> Show File-Information <--
if 0
  str={'= Include files  ='};
  for idx=1:length(data0)
    s=feval(fcn,'showinfo',data0(idx));
    str={str{:}, [' ** File ' num2str(idx) '**'], s{:},''};
  end
  set(handles.lbx_MMA_Info,'String',str,'Value',1);
end
% ============================
% Update Saving Data
% ============================
actdata.fcn  = 'DataDef2_MultiAnalysis';
actdata.data = multdata;
% => Save Local Active Daata
setappdata(handles.figure1, 'LocalActiveData',actdata);
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

function ConnectAdvanceMode(handles,varargin)
% ==> Setup 
%     Force into Batch

% get Advance Button-Position
hs=handles.advpsb_ForceBatch;
hs(end+1)=handles.advpsb_BenriButton;
  
% Comment out : Meeting on 20-Apr-2007
%  handles.advpsb_MultiAna];
set(hs,'Visible','on');
if length(varargin)>0
  disp(mfilename);
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Functin of Make-Multi Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%========================================
function psbOK_Callback(hs)
% OK Button : Load -> check -> save -> select Multi!
%========================================

%------------------------------
% Load Multi-Ana Data from GUI
%------------------------------
actdata=getappdata(hs.figure1, 'LocalActiveData');
multdata=actdata.data;
multdata.Tag=get(hs.edt_MMA_Tag,'String');
%multdata.NumberOfFiles=
try
  multdata.ID_number=round(str2double(get(hs.edt_MMA_ID,'String')));
  set(hs.edt_MMA_ID,'ForegroundColor',[0 0 0]);
catch
  set(hs.edt_MMA_ID,'ForegroundColor',[1 0 0]);
  errordlg({'ID must be single numerical.',lasterr},'ID Error');
end
multdata.Comment=get(hs.edt_MMA_Comment,'String');
multdata.CreateDate=now;

%------------------------------
% Save Multi-Ana Data from GUI
%------------------------------
actdata.data=multdata;
try
  feval(actdata.fcn,'save',actdata.data);
catch
  errordlg({'Save Error:',['  ' lasterr]},'Make Mult Data');
  return;
end


%------------------
% Filnalize
%------------------
% Logging
P3_AdvTgl_status('Logging',hs,...
  [' --> Save MultiAna named : ' multdata.Tag]);

% ==> Project Reset
POTATo('ChangeProjectIO',hs.figure1,[],hs);

% Select Multi Mode
str=get(hs.pop_filetype,'String');
idx=find(strcmp(str,'Multi-Analysis'));
set(hs.pop_filetype,'Value',idx(1));
%  (Select Saved Data)
setappdata(hs.figure1,'CurrentSelectFile',true);

POTATo('lbx_fileList_Callback',hs.lbx_fileList,[],hs,multdata.Tag);
POTATo('pop_filetype_Callback',hs.pop_filetype,[],hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Functin of Make-Multi Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_MMA_AnaFile_Callback(hs)
% File Select Popup-Menu! => Change AnaFile Informaiton
%  String   : File-Key
%  UserData : Cell-Structure of Ana-Data's (Loaded)

vl=get(hs.pop_MMA_AnaFile,'Value');
dt=get(hs.pop_MMA_AnaFile,'UserData');
dt=dt{vl};
info = OspFilterDataFcn('getInfo',dt.data(end).filterdata);
set(hs.lbx_MMA_AnaFileInfo,'Value',1,'String',info);

function FoceBatch(hs)
% Force into Batch Mode

fmd.block_enable=1;
anadata=get(hs.pop_MMA_AnaFile,'UserData');
for idx=1:length(anadata)
  anadata{idx}.data(end).filterdata=fmd;
  try
     DataDef2_Analysis('save_ow',anadata{idx});
  catch
    msg=['Error in Foce into Batch : ' laster];
    OSP_LOG('err',msg);
  end
end

% ==> Project Reset
POTATo('lbx_disp_fileList_Callback',hs.lbx_disp_fileList,[],hs);




