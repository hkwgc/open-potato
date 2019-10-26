function varargout = P3_wizard_plugin(varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% $Id: P3_wizard_plugin.m 180 2011-05-19 09:34:28Z Katura $

% Last Modified by GUIDE v2.5 12-Jul-2007 16:28:34



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_wizard_plugin_OpeningFcn, ...
  'gui_OutputFcn',  @P3_wizard_plugin_OutputFcn, ...
  'gui_LayoutFcn',  [] , ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function P3_wizard_plugin_OpeningFcn(h, ev, handles, varargin)
% Opening Function
handles.output = []; % Default Result is noting
handles.figure1=h;

%================
% Checking Argument
%================
% No Argument
if 0
  disp(varargin);disp(ev);
end

%===========================
% Draw : Background Image
%===========================
try
  if ~isfield(handles,'img_background')
    set(h,'CurrentAxes',handles.axes2);
    p=fileparts(which(mfilename));
    c=imread([p filesep 'PluginWizard.bmp']);
    handles.img_background=image(c); axis off
    set(h,'Color',[.8, .8, .8]);
  end
catch
  disp(lasterr);
  warning('Warning : Error occur in drawing Background Image.');
end

guidata(h, handles);
ChangePage(handles,NaN);
% Make the GUI modal
% Debugging..
if 0
  waitfor(h);
end

if 0
  % subfunctions
  figure1_CloseRequestFcn;
  figure1_KeyPressFcn;
end

function varargout = P3_wizard_plugin_OutputFcn(h, ev, handles)
% Retun 
if nargout>=1
  varargout{1} = handles.output;
end
if 0,disp(h);disp(ev);end
% use delete h

function figure1_CloseRequestFcn(h, ev, hs)
% Close if End
if isequal(get(h, 'waitstatus'), 'waiting')
  uiresume(h);
else
  delete(h);
end
if 0,disp(ev);disp(hs);end

function figure1_KeyPressFcn(hObject, ev, hs)
% Close figure, when if press "Escape-Key"
if isequal(get(hObject,'CurrentKey'),'escape')
  uiresume(h);
end
if 0,disp(ev);disp(hs);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Page Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  psb_BK_Callback;
  psb_Next_Callback;
end
function psb_BK_Callback(h, ev, hs)
% Back to Page (-1)
ChangePage(hs,-1);
if 0,disp(ev);disp(h);end

function psb_Next_Callback(h, ev, hs)
% Proceed to Page, (+1)
ChangePage(hs,1);
if 0,disp(ev);disp(h);end

function fnclist=getFunctionList(hs,mydata)
% Definition of Function List
fnclist={@P3_wizard_plugin_P1};
pt=getappdata(hs.figure1,'PluginType');
if isempty(pt),return;end

% --> Plugin Type was made in
switch pt
  case 'Filter Plug-in'
    fnclist{end+1}=@P3_wizard_plugin_P_FRegion;
    fnclist{end+1}=@P3_wizard_plugin_P_FFormat;
    fnclist{end+1}=@P3_wizard_plugin_P_argset;
    fnclist{end+1}=@P3_wizard_plugin_P_Help;
    fnclist{end+1}=@P3_wizard_plugin_P_Foption;
  case 'Viewer Axis-Object'
    %fnclist{end+1}=@P3_wizard_plugin_P_AControl;
    fnclist{end+1}=@P3_wizard_plugin_P_AFormat;
    fnclist{end+1}=@P3_wizard_plugin_P_argset;
    fnclist{end+1}=@P3_wizard_plugin_P_Help;
  case '1st-Level-Analysis Plug-in'
    fnclist{end+1}=@P3_wizard_plugin_P_FRegion;
    fnclist{end+1}=@P3_wizard_plugin_P_1Format;
    fnclist{end+1}=@P3_wizard_plugin_P_argset;
    fnclist{end+1}=@P3_wizard_plugin_P_Help;
  otherwise
    errordlg('Unpopulated Plugin Type was selected');
end
fnclist{end+1}=@P3_wizard_plugin_P_Save;

function ChangePage(hs,page)
% Change Page
persistent mypage;
%-------------
% Initialize
%-------------
mydata=getappdata(hs.figure1,'SettingInfo');
if isempty(mydata),
  mydata=struct('dumy',[]);
end
fnclist=getFunctionList(hs,mydata);
if isnan(page) || isempty(mypage)
  mypage=1;
end

mydata.page_diff=page;
%------------
% Close Page
%------------
mydata.page=mypage;
if ~isnan(page)
  try
    mydata=feval(mydata.currentpage,'ClosePage',hs,mydata);
    if length(fnclist)==mypage && page==1
      hs.output=mydata;
      guidata(hs.figure1, hs);
      figure1_CloseRequestFcn(hs.figure1, [], hs);
      return;
    end
  catch
    fnclist{mypage+1}=@errorPage;
    page=1;
  end
end

%-------------
% Change Page
%-------------
if ~isnan(page)
  mypage=mypage+page;
end
if mypage<=1,
  set(hs.psb_BK,'Visible','off');
else
  set(hs.psb_BK,'Visible','on');
end
if length(fnclist)<mypage
  fnc=@errorPage;
  mydata.errormessage=' Undefined/Unpopulated Page ';
else
  fnc=fnclist{mypage};
end
mydata.page=mypage;

fncinfo=feval(fnc,'createBasicInfo');
if fncinfo.islast
  set(hs.psb_Next,'String','OK');
else
  set(hs.psb_Next,'String','Next');
end

%------------
% Open
%------------
mydata=feval(fnc,'OpenPage',hs,mydata);
mydata.currentpage=fnc;

setappdata(hs.figure1,'SettingInfo',mydata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Help Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_help_Callback(h,e,hs)
mydata=getappdata(hs.figure1,'SettingInfo');
if isequal(mydata.currentpage,@errorPage)
  try
    fnclist=getFunctionList(hs,mydata);
    feval(fnclist{mydata.page-1});
  catch
    feval(mydata.currentpage);
  end
  return;
end
feval(mydata.currentpage);

if 0,disp(e);disp(h);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error Page:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=errorPage(mode,varargin)
% Page for Error
if nargin==0
  OspHelp(mfilename);
  return;
end
switch mode
  case 'createBasicInfo',
    data.islast=false;
    varargout{1}=data;
  case 'OpenPage',
    hs=varargin{1};
    mydata=varargin{2};
    if isfield(mydata,'errormessage')
      emsg=mydata.errormessage;
    else
      emsg=lasterr;
    end
    if isfield(mydata,'errorPage_hs') && ...
        ishandle(mydata.errorPage_hs.txt_error)
      set(mydata.errorPage_hs.txt_error,'String',emsg,'Visible','on');
    else
      hh=uicontrol(hs.figure1);
      set(hh,'String',emsg,'Style','text',...
        'Units','Normalized','Position',[0.2, 0.2, 0.7,0.63],...
        'HorizontalAlignment','left',...
        'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0]);
      mydata.errorPage_hs.txt_error=hh;
    end
    set(hs.psb_Next,'String','---','Enable','off');
    varargout{1}=mydata;
  case 'ClosePage',
    hs=varargin{1};
    mydata=varargin{2};
    set(mydata.errorPage_hs.txt_error,'Visible','off');
    set(hs.psb_Next,'Enable','on');
    varargout{1}=mydata;
  otherwise
    error('in Error Page : Undefined Operation for Page-Object');
end

    
