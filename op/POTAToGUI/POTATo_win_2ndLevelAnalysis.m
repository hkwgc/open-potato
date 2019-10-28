function varargout=POTATo_win_2ndLevelAnalysis(fnc,varargin)
% POTATo Window : 2nd-Lvl-Analysis Mode Control Function
%
% This Function is special


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
switch fnc
  case {'DisConnectAdvanceMode','ChangeLayout'},
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'SaveData',
    varargout{1}=SaveData(varargin{:});
  case 'MakeMfile',
    % varargout{1}=MakeMfile(varargin{:});
  case 'DrawLayout',
    % varargout{1}=DrawLayout(varargin{:});
  case 'ConnectAdvanceMode'
    %ConnectAdvanceMode(varargin{:});
  case 'psb_new_2ndLvlAna_Callback'
    psb_new_2ndLvlAna_Callback(varargin{3});
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loacal GUI Making Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hs,pos]=myHandles(h)
% Return Entry Handle
pos0=get(h.frm_AnalysisArea,'Position');
pos1=get(h.frm_2ndAnaArea,'Position');
pos=pos0(1:2)-pos1(1:2);
hs=[h.txt_2ndAnalysis_title,...
    h.pop_2ndAnalysis_PluginFunction,...
    h.txt_2ndAnalysis_PluginFunction,...
    h.psb_2ndAnalysis_fnc_help,...
    h.lbx_2ndAnalysis_PluginFunctionInfo,...
    h.lbx_2ndAnalysis_GroupList, ... 
    h.txt_2ndAnalysis_GroupList, ... 
    h.psb_2ndAnalysis_AddGroup, ...
    h.psb_2ndAnalysis_RmGroup, ...
    h.psb_2ndAnalysis_ChangeGroup, ...
    h.txt_2ndAnalysis_GroupInfo,...
    h.lbx_2ndAnalysis_GroupInfo,...
    h.psb_2ndAnalysis_Execute];
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Activate / Suspend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(handles,varargin)
% Suspend 
% * Number of Arguments Check *
if ~isempty(varargin)
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

[hs,pos]=myHandles(handles);
suspend_comm(hs,pos,handles);
set(handles.psb_new_2ndLvlAna,'Visible','off');

% --> confine other handles on
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');

% ==> M-File : Unlock
P3_2ndAnalysisCallbacks('StatusOf2ndLvlAna','final');

function Activate(handles,varargin)
% * Number of Arguments Check *
if ~isempty(varargin)
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Activate');
end
[hs,pos]=myHandles(handles);
activate_comm(hs,pos, handles);
set(handles.psb_new_2ndLvlAna,'Visible','on');
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');

%================================
% 2nd-Level-Analysis Activate
%================================
%------------------------
% Make Local-Active-Data
%------------------------
% get DataDef (II) Function
fcn=get(handles.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  actdata.fcn=fcn{get(handles.pop_filetype,'Value')};
  clear fcn;
end
% get Data-File
filedata=get(handles.lbx_fileList,'UserData');
if isempty(filedata),
  % ==> No Data Select!!<==
  set(hs,'Visible','off');
  % --> Return Acitvate!
  %  (wait for next selecting)
  return;
else
  actdata.data=filedata(get(handles.lbx_fileList,'Value'));
  clear filedata;
end
actdata.data = feval(actdata.fcn, 'load', actdata.data);
setappdata(handles.figure1, 'LocalActiveData',actdata);
%------------------------
% Set-up to Start!
%------------------------
P3_2ndAnalysisCallbacks('startAnalysis',handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=SaveData(handles)
% Save (Overwrite) 2nd-Level-Analysis Data.
%  == Delete -> Save ==
%  Cause Relation will be change!
%
msg='';
%========================
% get Save-File
%========================
try
  data=P3_2ndAnalysisCallbacks('get2ndLvlAnaData',handles);
  DataDef2_2ndLevelAnalysis('save_ow',data);
catch
  msg=lasterr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_new_2ndLvlAna_Callback(hs)
% Make New 2nd-Lvl-Analysis!

%---------------------------
% Make New-2nd-Lvl-Ana Data
%---------------------------
% ==> Save Name ...
data=DataDef2_2ndLevelAnalysis('NewData');
% is Cancel?
if isempty(data),return;end 

% Logging
P3_AdvTgl_status('Logging',hs,...
  sprintf(' Made New "2nd-Lvl-Ana" named : %s',data.Name));

%---------------------------
% Reset Project
%---------------------------
POTATo('lbx_fileList_Callback',hs.lbx_fileList,[],hs,data.Name);
setappdata(hs.figure1,'CurrentSelectFile',true);
POTATo('ChangeProjectIO',hs.figure1,[],hs);
