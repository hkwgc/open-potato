function varargout = P3_wizard_plugin_P_Help_sub(varargin)
% Setup Help-comments
%
% Syntax :
%    data=P3_wizard_plugin_P_Help_sub;
%    data=P3_wizard_plugin_P_Help_sub('DefaultValue',data);
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help P3_wizard_plugin_P_Help_sub

% Last Modified by GUIDE v2.5 19-Feb-2008 17:01:43


% ===================================================================================
% Copyright(c) 2019, National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ===================================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launcher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_wizard_plugin_P_Help_sub_OpeningFcn, ...
  'gui_OutputFcn',  @P3_wizard_plugin_P_Help_sub_OutputFcn, ...
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
% Window I/O Funcitons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P3_wizard_plugin_P_Help_sub_OpeningFcn(hObject, e, handles, varargin)
% Set Default-Value & wait for User-Responce
if 0,disp(e);end

handles.output = [];

%--------------------
% get Argument
%--------------------
if(nargin > 3)
  msg={};
  for index = 1:2:(nargin-3),
    if nargin-3==index, break, end
    if ~ischar(varargin{index}),
      msg{end+1}=sprintf('Property Name Must be String');
      continue;
    end
    switch varargin{index}
      case 'DefaultValue'
        %--------------------
        % set Default Value
        %--------------------
        setDefaultValue(handles,varargin{index+1});
      otherwise
        % Make Error Messange
        msg{end+1}=sprintf('Unknown Property : %s',varargin{index});
    end
  end

  %--------------------
  % Popup Warning Dialog
  %--------------------
  if ~isempty(msg)
    wh=warndlg(msg);
    waitfor(wh);
  end
end

%------------------------
% Wait for user response
%------------------------
% Update handles structure
guidata(hObject, handles);
% waiting...
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);
if 0,
  figure1_CloseRequestFcn;
  figure1_KeyPressFcn;
  setDefaultValue;
end

function figure1_CloseRequestFcn(h, e, hs)
% Close with Cancel
if isequal(get(hs.figure1, 'waitstatus'), 'waiting')
  uiresume(hs.figure1);
else
  delete(hs.figure1);
end
if 0,disp(h);disp(e);end
function figure1_KeyPressFcn(h, e, hs)
% When Escape Key Press, Close figure.
key=get(h,'CurrentKey');
switch lower(key)
  case 'escape'
    % Close Figure with "" Cancel ""
    if isequal(get(h, 'waitstatus'), 'waiting')
      uiresume(h);
    else
      delete(h);
    end
end
if 0,disp(e);disp(hs);end


function varargout = P3_wizard_plugin_P_Help_sub_OutputFcn(h, e, hs)
% Get default command line output from handles structure
varargout{1} = hs.output;
% The figure can be deleted now
delete(hs.figure1);
if 0,disp(h);disp(e);end
if 0,
  % output data : See also
  psb_OK_Callback;
  psb_Cancel_Callback;
end


%==========================================================================
function psb_OK_Callback(h, e, hs)
% Gather Result and resume.
%==========================================================================

%===================
% Gather Result
%===================
data.function.SeeAlso    = get(hs.edt_seealso,'String');
data.function.Syntax     = get(hs.edt_syntax,'String');
data.function.Example    = get(hs.edt_example,'String');
data.copyright.Author    = get(hs.edt_author,'String');
data.copyright.CopyRight = get(hs.edt_copyright,'String');
%--------------------
% Set up Output-Data
%--------------------
hs.output = data;
guidata(hs.figure1, hs);

%===================
% Resume
%===================
uiresume(hs.figure1);
if 0,disp(h);disp(e);end

%==========================================================================
function psb_Cancel_Callback(h, e, hs)
% Cancel Button
%==========================================================================
hs.output = [];
guidata(hs.figure1, hs);
uiresume(hs.figure1);
if 0,disp(h);disp(e);end

function setDefaultValue(hs,data)
if isempty(data) || ~isstruct(data)
  return;
end

if isfield(data,'function')
  d=data.function;
  if isfield(d,'SeeAlso')
    set(hs.edt_seealso,'String',d.SeeAlso);
  end
  if isfield(d,'Syntax')
    set(hs.edt_syntax,'String',d.Syntax);
  end
  if isfield(d,'Example')
    set(hs.edt_example,'String',d.Example);
  end
end
if isfield(data,'copyright')
  d=data.copyright;
  if isfield(d,'Author')
    set(hs.edt_author,'String',d.Author);
  end
  if isfield(d,'CopyRight')
    set(hs.edt_copyright,'String',d.CopyRight);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Check..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  edt_author_Callback;
  edt_copyright_Callback;
  edt_seealso_Callback;
  edt_syntax_Callback;
  edt_example_Callback;
end
function edt_author_Callback(h, e, hs)
if 0,disp(h);disp(e);disp(hs);end
function edt_copyright_Callback(h, e, hs)
if 0,disp(h);disp(e);disp(hs);end
function edt_seealso_Callback(h, e, hs)
if 0,disp(h);disp(e);disp(hs);end
function edt_syntax_Callback(h, e, hs)
if 0,disp(h);disp(e);disp(hs);end
function edt_example_Callback(h, e, hs)
if 0,disp(h);disp(e);disp(hs);end
