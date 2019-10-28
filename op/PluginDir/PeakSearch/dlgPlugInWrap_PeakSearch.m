function varargout = dlgPlugInWrap_PeakSearch(varargin)
% Dialg to set up Peak-Search
% See also: GUIDE, GUIDATA, GUIHANDLES


% Last Modified by GUIDE v2.5 17-Feb-2011 13:12:46


%##########################################################################
% Launcher
%##########################################################################
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dlgPlugInWrap_PeakSearch_OpeningFcn, ...
                   'gui_OutputFcn',  @dlgPlugInWrap_PeakSearch_OutputFcn, ...
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

%##########################################################################
% GUI Control functions
%##########################################################################
function dlgPlugInWrap_PeakSearch_OpeningFcn(h,ev,hs, varargin) %#ok
% This function has no output args, see OutputFcn.
hs.output = [];

% Update handles structure
guidata(h,hs);

msg = nargchk(2,2,length(varargin));
if isempty(msg),
  errordlg(lasterr);return;
end
try
  % Set Current Data
  mfile_previous=varargin{4};
  [header,data]=scriptMeval(mfile_previous,'bhdata','bdata');
  setappdata(h,'bhdata',header);
  setappdata(h,'bdata',data);
  argData       =varargin{2};
  if isempty(argData),
    argData.dummy=[];
  end
  setArgData(hs,argData);
catch
  errordlg({'Error in Evaluateing-Recipe', lasterr});
  return; % No Wait and Return!! == Cancel!
end

hs=axes1_redrawfunc(hs.axes1,1,hs); % Update hs
guidata(h,hs);
% <---- ui wati ------>
if 1
  set(h,'WindowStyle','modal')
  uiwait(h);
else
  % ::Debug::
  warndlg('Debug Mode --> Not uiwait');
end

%==========================================================================
function varargout = dlgPlugInWrap_PeakSearch_OutputFcn(h,ev,hs) %#ok
% Get default command line output from handles structure
%==========================================================================
try
  varargout{1} = hs.output;
  % Try to Delete Opened figure
  %disp(C__FILE__LINE__CHAR);
  delete(h);
catch
  varargout{1}=[];
end
return;

%==========================================================================
function psb_OK_Callback(h,ev,hs)     %#ok
% OK
%==========================================================================
hs.output = getArgData(hs);
guidata(h,hs);
if isequal(get(hs.figure1,'waitstatus'), 'waiting'),
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
return;

%==========================================================================
function psb_Cancel_Callback(h,ev,hs) %#ok
% Cancel & Exit
%==========================================================================
hs.output = [];
guidata(h,hs);
if isequal(get(hs.figure1,'waitstatus'), 'waiting'),
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
return;

%##########################################################################
% Data I/O
%##########################################################################
function argData=getArgData(hs)
% Make ArgData
argData.Period  =sort([get(hs.edt_stp,'UserData'),get(hs.edt_edp,'UserData')]);
if get(hs.ckb_peaksearch,'Value')
  argData.FlexTerm=sort([get(hs.edt_minus,'UserData'),get(hs.edt_plus,'UserData')]);
else
  argData.FlexTerm=[0 0];
end
if argData.FlexTerm(1)>0, argData.FlexTerm(1)=0; end

function setArgData(hs,argData)
% Set ArgData
if isfield(argData,'Period')
  d=argData.Period;
  set(hs.edt_stp,'UserData',d(1),'String',num2str(d(1)));
  set(hs.edt_edp,'UserData',d(2),'String',num2str(d(2)));
else
  hdata=getappdata(hs.figure1,'bhdata');
  t=(hdata.stim(2)-hdata.stim(1))*hdata.samplingperiod/1000;
  set(hs.edt_stp,'UserData',0,'String','0');
  if (t>1)
    set(hs.edt_edp,'UserData',t,'String',num2str(t));
  else
    set(hs.edt_edp,'UserData',1,'String','1');
  end
end
if isfield(argData,'FlexTerm')
  d=argData.FlexTerm;
  set(hs.edt_minus,'UserData',d(1),'String',num2str(d(1)));
  set(hs.edt_plus,'UserData',d(2),'String',num2str(d(2)));
else
  set(hs.edt_minus,'UserData',-5,'String','-5');
  set(hs.edt_plus,'UserData',5,'String','5');
end

%##########################################################################
% Draw
%##########################################################################
function hs=axes1_redrawfunc(h,ev,hs)
% Draw
fh=hs.figure1;
hdata=getappdata(fh,'bhdata');
data=getappdata(fh,'bdata');
argData=getArgData(hs);


% Select
set(0,'CurrentFigure',fh);
set(fh,'CurrentAxes',h);

if ev>0
  % set Axis
  ax=[1 size(data,2)] - hdata.stim(1);
  ax=ax * hdata.samplingperiod/1000;
  ax(3:4)=[0 1];
  axis(ax);
  xlabel('[sec]','FontUnits','pixels','FontSize',10);
end

p=argData.Period + argData.FlexTerm;
if ~isfield(hs,'FlexBar')
  hs.FlexBar = line(p([1 1 1 2 2 2]),[3 5 4 4 5 3]/8);
  set(hs.FlexBar,'Color',[0.5 0.8 0],'LineWidth',3);
else
  set(hs.FlexBar,'XData',p([1 1 1 2 2 2]));
end
if get(hs.ckb_peaksearch,'Value')
  set(hs.FlexBar,'Visible','on');
else
  set(hs.FlexBar,'Visible','off');
end

p=argData.Period;
if ~isfield(hs,'Period')
  hs.Period=patch(p([1 2 2 1]),[1 1 3 3]/4,[0.8 1 0.8]);
else
  set(hs.Period,'XData',p([1 2 2 1]));
end

if ~isfield(hs,'BlockLine')
  p=[1 hdata.stim([1 2]) size(data,2)]-hdata.stim(1);
  p=p*hdata.samplingperiod/1000;
  hs.BlockLine = line(p([1 2 2 3 3 4]),[1 1 9 9 1 1]/10);
  set(hs.BlockLine,'LineStyle',':','Color',[1 0 0],'Linewidth',2);
end

%##########################################################################
% Edit Control
%##########################################################################
function psb_testplot_Callback(h,ev,hs)
% Test Plog

% Get Data
fh=hs.figure1;
hdata=getappdata(fh,'bhdata');
data=getappdata(fh,'bdata');
argData=getArgData(hs);

startp=get(hs.BlockLine,'XData');
startp=startp(1);
unit=1000/hdata.samplingperiod;
area =round(argData.Period   * unit); 
sarea=round(argData.FlexTerm * unit);
tag= hdata.TAGs.DataTag;
osp_peaksearch(data, area, sarea, tag, [1/unit, startp]);

%==========================================================================
% check
%==========================================================================
function r=myck(h,hs)
v=str2double(get(h,'String'));
if isempty(v) || ~isfinite(v)
  % error
  errordlg('Bad Input Data');
  v=get(h,'UserData');
  set(h,'String',num2str(v),'ForegroundColor',[1 0 0]);
  r=v;
  return;
else
  set(h,'UserData',v(1),'ForegroundColor',[0 0 0],...
    'String',num2str(v(1)));
  r=v(1);
end
if isnumeric(r)
  axes1_redrawfunc(hs.axes1,[],hs);
end

function edt_stp_Callback(h,ev,hs) %#ok
myck(h,hs);
function edt_edp_Callback(h,ev,hs) %#ok
myck(h,hs);

function edt_minus_Callback(h,ev,hs) %#ok
r=myck(h,hs);
if (r>0) 
  set(h,'UserData',0,'ForegroundColor',[0 0 0],'String','0');
end  
  
function edt_plus_Callback(h,ev,hs) %#ok
r=myck(h,hs);
if (r<0)
  set(h,'UserData',0,'ForegroundColor',[0 0 0],'String','0');
end


function ckb_peaksearch_Callback(h,ev,hs)
% Change Visible

hh=[hs.edt_minus, hs.txt_psto, hs.edt_plus, hs.psb_testplot];
if get(h,'Value')
  set(hh,'Visible','on');
else
  set(hh,'Visible','off');
end
axes1_redrawfunc(hs.axes1,ev,hs);
