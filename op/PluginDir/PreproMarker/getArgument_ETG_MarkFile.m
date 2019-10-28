function varargout = getArgument_ETG_MarkFile(varargin)
% This function is for setting PlugInWrapPP_ETG_MarkFile.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 13-Jun-2007 16:09:26

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Masanori Shoji
% create : 2007.06.13
% $Id: getArgument_ETG_MarkFile.m 180 2011-05-19 09:34:28Z Katura $
%
% Revition 1.1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @getArgument_ETG_MarkFile_OpeningFcn, ...
                   'gui_OutputFcn',  @getArgument_ETG_MarkFile_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function getArgument_ETG_MarkFile_OpeningFcn(h, ev, hs, varargin)
% Opening function get Input-Arguments and Open-Figure.
% 
%==========================================================================

%---------------------------------
% Default : Cancel
%  Othere Default-Value is in *.fig
%----------------------------------
hs.output = [];
hs.figure1=h; % myfavorite.

%----
% TODO : move to figure setting...
%---
set(hs.pop_FileName,'BackgroundColor',[1 1 1]);
set(hs.edt_Treshold,'UserData',1.0);
pop_FileName_Callback(hs.pop_FileName,[],hs);

%---------------------------------
% set Argument-Data
%----------------------------------
if ~isempty(varargin)
  setArgData(hs,varargin{1});
end


%--------------------------
% Open Figure
%--------------------------
guidata(h,hs);
if 1
  set(h,'WindowStyle','modal')
  uiwait(h);
end

%-------------------------
% Function List for M-Lint
%-------------------------
if 0
  psb_OK_Callback(hs.psb_OK,ev,hs);
  psb_Cancel_Callback(hs.psb_Cancel,ev,hs);
  edt_Treshold_Callback(hs.edt_Treshold,ev,hs);
  pop_FileName_Callback(hs.pop_FileName,ev,hs)
end
%==========================================================================
function varargout = getArgument_ETG_MarkFile_OutputFcn(h,ev,hs)
% Do noting in paticure. set output value.
%==========================================================================
varargout{1} = hs.output;
if 1
  delete(h);
end
if 0,disp(h);disp(ev);end

%==========================================================================
function psb_OK_Callback(h,ev,hs)
% Make Output-Data and Close Figure.
%==========================================================================

% get ArgData
hs.output = getArgData(hs);

%--------------
% Close Figure
%--------------
guidata(hs.figure1, hs);
if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
if 0,disp(h);disp(ev);end

%==========================================================================
function psb_Cancel_Callback(h,ev,hs)
% set output-Data and Close Figure
%==========================================================================
hs.output=[]; % Empty : Cancel
%--------------
% Close Figure
%--------------
guidata(hs.figure1, hs);
if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
if 0,disp(h);disp(ev);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ArgData <---> GUI Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgData(hs)
% Make ArgData from GUI
data.Threshold=get(hs.edt_Treshold,'UserData');
s=get(hs.pop_FileName,'String');
vl=get(hs.pop_FileName,'Value');
data.FileName.Method=s{vl};
if vl~=1
  data.FileName.String=get(hs.edt_FileNamePattern,'String');
end
data.ConfineResult=get(hs.cbx_ConfineResult,'Value');

function setArgData(hs,data)
% Set ArgData
if isfield(data,'Treshold')
  set(hs.edt_Treshold,...
    'UserData',data.Threshold,...
    'String',num2str(data.Threshold));
end

if isfield(data,'FileName')
  if isfield(data.FileName,'Method')
    s=get(hs.pop_FileName,'String');
    vl=find(s,data.FileName.Method);
    set(hs.pop_FileName,'Value',vl);
    pop_FileName_Callback(hs.pop_FileName,[],hs);
  end
  if isfield(data.FileName,'String')
    set(hs.edt_FileNamePattern,'String',data.FileName.String);
  end
end
if isfield(data,'ConfineResult')
  set(hs.cbx_ConfineResult,'Value',data.ConfineResult);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple GUI Control.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function edt_Treshold_Callback(h,ev,hs)
% Check Is Single-Numerical?
%==========================================================================
s=get(h,'String');
try
  n=str2double(s);
  if length(n)~=1 || ~isfinite(n)
    % Error
    error('Treshold Must be Mumerical!');
  end
  set(h,'UserData',n,...
    'ForegroundColor',[0 0 0]);
  
catch
  % Error (Not Single-Numerical)
  n=get(h,'UserData');
  set(h,'String',num2str(n),'ForegroundColor','red');
end
if 0,disp(hs);disp(ev);end

%==========================================================================
function pop_FileName_Callback(h,ev,hs)
% This Popupmenu Make's How to get File-Name.
%  if we need more Information to get filename,
%  Visible on More UICONTROLS.
%==========================================================================
val=get(h,'Value');
% cf) if program be complex, use string-property & switch.
if val==1
  set(hs.edt_FileNamePattern,'Visible','off');
else
  set(hs.edt_FileNamePattern,'Visible','on');
end
if 0,disp(h);disp(ev);end


%==========================================================================
function cbx_ConfineResult_Callback(h,ev,hs)
% Do Nothing now
% --> Value of Check-Box is used in OK : == result.
%==========================================================================

%==========================================================================
function edt_FileNamePattern_Callback(h,ev,hs)
%==========================================================================
