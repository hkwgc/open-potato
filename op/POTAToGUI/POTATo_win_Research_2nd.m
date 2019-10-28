function varargout=POTATo_win_Research_2nd(fnc,varargin)
% POTATo Analysis-Status : Research-2nd Analysis
%  Analysis-GUI-sets, 
%  when Research (P3-Mode), multi-data.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%  2010.11.02 : New!
%       2010_2_RA01-3

%======== Launch Switch ========
switch fnc,
  case 'Suspend',
    Suspend(varargin{:});
    POTATo_win('DisConnectAdvanceMode',varargin{:});
    
  case 'Activate',
    Activate(varargin{:});
    hs=varargin{1};
    hx=[hs.psb_export_workspace];
    set(hx,'Visible','on');
    
  case 'Export2WorkSpace'
    varargout{1}=Export2WorkSpace(varargin{:});
  case {'DisConnectAdvanceMode','SaveData','ConnectAdvanceMode',...
      'ChangeLayout'},
    % (mean Do nothing)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make GUI & Handle Control
function h=myHandles(hs)
% Handle List
h=P3_gui_Research_2nd('myHandles',hs);
% For Debug
%h0=hs.([mfilename '_TODO']);h=[h,h0];s=C__FILE__LINE__CHAR(1);fprintf('DEBUG MODE:%s\n',s);
%Note: Line 119 elseif 0 --> Debug off;

function h=fileinfohandles(handles)
h=[handles.pop_fileinfo,...
  handles.lbx_fileinfo,...
  handles.txt_fileinfo];

%**************************************************************************
function hs=create_win(hs)
% Make GUI for Research 2nd status
hs.([mfilename '_TODO'])=uicontrol(hs.figure1,...
  'Units','pixels','Position',[150 480 250 20],...
  'BackgroundColor',[1 0 0],...
  'Style','text','Visible','off',...
  'String',['TODO: ' mfilename]);
P3_gui_Research_2nd('create_win',hs);
hs=guidata(hs.figure1);

%##########################################################################
% Open / Close
%##########################################################################
%**************************************************************************
function Suspend(hs)
% Suspend Window : Visible off
h=myHandles(hs);
set(h,'Visible','off');
set(hs.frm_AnalysisArea,'Visible','off');
set(hs.menu_data_Selector,'Enable','on');

% Suspend Statistical Test Function
vl=get(hs.pop_R2nd_Function,'Value');
ud=get(hs.pop_R2nd_Function,'UserData');
feval(ud{vl}.fcn,'Suspend',hs);
% Main Control : POTATo/renew_pop_filetype
%set([hs.edt_searchfile,hs.txt_searchfile],'Visible','on');
vb=get(hs.lbx_disp_fileList,'Visible');
set(fileinfohandles(hs),'Visible',vb);


%**************************************************************************
function Activate(hs)
% Activate Single-Analysis Mode!
persistent inuse;

if isempty(inuse) || inuse==false
  inuse=true; %#ok
else
  return;
end
try
  Activate0(hs)
catch
  inuse=[]; %#ok (variable might never be used. -->no used)
  rethrow(lasterror);
end
inuse=[];

function Activate0(hs)
% Visible On;Off
if ~isfield(hs,[mfilename '_TODO']) || ~ishandle(hs.([mfilename '_TODO']))
  hs=create_win(hs);
elseif 0
	% for debug
  try %#ok
    delete(myHandles(hs));
  end
  try %#ok
    hs=create_win(hs);
  end
  disp('debug');
  disp(C__FILE__LINE__CHAR);
end

%============================
% Close Search Function
%============================
% Close Extended Search
ck=get(hs.menu_data_Selector,'Checked');
if strcmpi(ck,'on');
  POTATo('menu_data_Selector_Callback',hs.menu_data_Selector,[],hs);
  hs=guidata(hs.figure1); % confine update
  set(hs.menu_data_Selector,'Enable','off');
else
  set(hs.menu_data_Selector,'Enable','off');
end
% Close Search
%set([hs.edt_searchfile,hs.txt_searchfile],'Visible','off');

%============================
% Activate GUI's
%============================
h=myHandles(hs);
set(hs.frm_AnalysisArea,'Visible','on');
set(h,'Visible','on');

h0=POTATo('getViewerGUI_IO',hs.figure1,[],hs);
set(h0,'Visible','off');

P3_gui_Research_2nd('pop_R2nd_SummarizedDataList_Init',hs);
P3_gui_Research_2nd('pop_R2nd_Function_Callback',hs,[]);
set(fileinfohandles(hs),'Visible','off');

%##########################################################################
% Output
%##########################################################################
function msg=Export2WorkSpace(hs)
% Export Summarized data to WorkSpace (base);

eflag=false;
msg={'Export Summarized Data',};

try
  esd=P3_gui_Research_2nd('getExpandedSummarizedData',hs);
  if isempty(esd)
    error('No data to Export');
  end
  assignin('base','ExpandedSummarizedData',esd);
catch
  eflag=true;
  msg{end+1}=lasterr;
end
if ~eflag
  helpdlg(msg,'Export Summarized Data');
  msg=[];
end

