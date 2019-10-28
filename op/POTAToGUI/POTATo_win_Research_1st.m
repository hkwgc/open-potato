function varargout=POTATo_win_Research_1st(fnc,varargin)
% POTATo Analysis-Status : Research-1st Analysis
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
%  2010.11.02 : New! (2010_2_RA01-3)
%  2010.11.02 : Add GUI

%======== Launch Switch ========
switch fnc,
  case 'Suspend',
    Suspend(varargin{:});
    
  case 'Activate',
    Activate(varargin{:});    
    
  case {'DisConnectAdvanceMode','SaveData','Export2WorkSpace','ConnectAdvanceMode'},
    % (mean Do nothing)
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case {'pop_R1st_SammarizedDataList_CB'},
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
      else
        feval(fnc, varargin{:});
      end
  case {'ChangeLayout','DrawLayout'}
      % Do noting
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=myHandles(hs)
%- Handle List
h=P3_gui_Research_1st('myHandles',hs);
%- For Debug
%h0=hs.([mfilename '_TODO']);h=[h,h0];s=C__FILE__LINE__CHAR(1);fprintf('DEBUG MODE:%s\n',s);

%**************************************************************************
function hs=create_win(hs)
% Make GUI for Research 1st status
hs.([mfilename '_TODO'])=uicontrol(hs.figure1,...
  'Units','pixels','Position',[150 480 250 20],...
  'BackgroundColor',[1 0 0],...
  'Style','text','Visible','off',...
  'String',['TODO: ' mfilename]);
P3_gui_Research_1st('create_win',hs);
hs=guidata(hs.figure1);

%**************************************************************************
function Suspend(hs)
% Suspend Window : Visible off
h=myHandles(hs);
set(h,'Visible','off');
set(hs.frm_AnalysisArea,'Visible','off');
set(hs.menu_data_Selector,'Enable','on');

% Suspend Summary Statistics Computation Function
vl=get(hs.pop_R1st_ExecuteName,'Value');
ud=get(hs.pop_R1st_ExecuteName,'UserData');
feval(ud{vl}.fcn,'Suspend',hs);

% Close : Enable
esh=get(hs.menu_data_Selector,'UserData');
try
  if ishandle(esh.figh)
    eshs=guidata(esh.figh);
    set(eshs.psb_Close,'Enable','on');
  end
catch
end

%**************************************************************************
function Activate(hs)
% Activate Single-Analysis Mode!
persistent inuse;
if isempty(inuse) || inuse==false
  inuse=true; %#ok (variable might never be used. -->no used)
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
%=============================
% Vislble On/Off
%=============================
if ~isfield(hs,[mfilename '_TODO']) || ~ishandle(hs.([mfilename '_TODO']))
  hs=create_win(hs);
else
  % for debug
  try %#ok
    delete(myHandles(hs));
  end
  try %#ok
    delete(myHandlesNew(hs));
  end
  try %#ok
    delete(myHandlesEdit(hs));
  end
  hs=create_win(hs);
  %disp('debug');
  %disp(C__FILE__LINE__CHAR);
end

% Lock or not
if get(hs.tgl_R1st_Lock,'Value')
  % Locked
else
  % Unlocked --> select new
  set(hs.tgl_R1st_New,'Value',1);
  set(hs.tgl_R1st_Edit,'Value',0);
end

%============================
% Open Search Function
%============================
% Close Extended Search
ck=get(hs.menu_data_Selector,'Checked');
if strcmpi(ck,'on');
  set(hs.menu_data_Selector,'Enable','off');
else
  POTATo('menu_data_Selector_Callback',hs.menu_data_Selector,[],hs);
  hs=guidata(hs.figure1); % confine update
  set(hs.menu_data_Selector,'Enable','off');
end
% Close : Disable
esh=get(hs.menu_data_Selector,'UserData');
try
  if ishandle(esh.figh)
    eshs=guidata(esh.figh);
    set(eshs.psb_Close,'Enable','off');
  end
catch
end
% Close Search
%set([hs.edt_searchfile,hs.txt_searchfile],'Visible','off');

h=myHandles(hs);
set(h,'Visible','on');
set(hs.frm_AnalysisArea,'Visible','on');

%=============================
% Activate GUI
%=============================
P3_gui_Research_1st('pop_R1st_ExecuteName_Callback',hs,[]);

if get(hs.tgl_R1st_Edit,'Value')
  P3_gui_Research_1st('tgl_R1st_Edit_Callback',hs);
end
% Viewer
h0=POTATo('getViewerGUI_IO',hs.figure1,[],hs);
set(h0,'Visible','off');
