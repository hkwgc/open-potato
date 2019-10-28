function varargout = osp_vao_2Dimage_getargument(varargin)
% OSP_VAO_2DIMAGE_GETARGUMENT M-file for osp_vao_2Dimage_getargument.fig
%      This GUI Set 2D Image Properties of View-Group-Axes.
%
%      p = OSP_VAO_2DIMAGE_GETARGUMENT returns Image-Property to View-Group-Axes(osp_ViewAxesObj_2DImage).
%
%      OSP_VAO_2DIMAGE_GETARGUMENT('CALLBACK') and OSP_VAO_2DIMAGE_GETARGUMENT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in OSP_VAO_2DIMAGE_GETARGUMENT.M with the given input
%      arguments.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% $Id: osp_vao_2Dimage_getargument.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 22-Feb-2006 10:25:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @osp_vao_2Dimage_getargument_OpeningFcn, ...
  'gui_OutputFcn',  @osp_vao_2Dimage_getargument_OutputFcn, ...
  'gui_LayoutFcn',  [], ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function osp_vao_2Dimage_getargument_OpeningFcn(hObject, ev, handles, varargin)
% Choose default command line output for osp_vao_2Dimage_getargument
handles.output = []; % cancel
handles.figure1= hObject;
guidata(hObject, handles);

% Insert custom Axes Object and Title if specified by the user.
% Default Axes-Object (init)
if(nargin > 3)
  for index = 1:2:(nargin-3),
    if nargin-3==index, break, end
    switch lower(varargin{index})
      case 'title'
        set(hObject, 'Name', varargin{index+1});
      case 'axesobject'
        set2DImageAxesObjectData(handles,varargin{index+1});
      otherwise,
        warning(['Ignore Input Property: ' , ...
          varargin{index}]);
    end
  end
end

set(handles.pop_colorMap, 'Visible', 'off');
set(handles.txt_colorMap, 'Visible', 'off');
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes osp_vao_2Dimage_getargument wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = osp_vao_2Dimage_getargument_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
handles=guidata(hObject);
varargout{1} = handles.output;
delete(handles.figure1);

function psb_set_Callback(hObject, eventdata, handles)
% Get information
% Set output
handles.output = get2DImageAxesObjectData(handles);
guidata(hObject,handles);
%  Resume
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end
return;

function psb_cancel_Callback(hObject, eventdata, handles)
% Canncel to output 'empty'
handles.output = [];
guidata(hObject,handles);
%  Resume
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
  uiresume(handles.figure1);
else
  delete(handles.figure1);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Getter & Setter : of this GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=get2DImageAxesObjectData(handles)
% Getter of this GUI

% --- default setting ---
data=getappdata(handles.figure1,'DefaultAOdata');
if isempty(data) || ~isstruct(data)
  data.str = '2D-Image';
  data.fnc = 'osp_ViewAxesObj_2DImage';
  data.ver = 1.00;
else
  if ~isfield(data,'str')
    data.str = '2D-Image';
  end
  if ~isfield(data,'fnc')
    data.fnc = 'osp_ViewAxesObj_2DImage';
  end
  if ~isfield(data,'ver')
    data.ver = 1.00;
  end
end

str=get(handles.pop_DataRegion,'String');
data.region =str{get(handles.pop_DataRegion,'value')};

% Mask ch data
prop.mask_channel = str2num(get(handles.edit_maskCh, 'String'));
% Get Time -
prop.v_timeposition = str2num(get(handles.edit_pos', 'String'));

% setup Color-Axis
prop.v_axisAuto   = get(handles.cbx_axisAuto, 'Value');
v_axMax=str2num(get(handles.edit_axisMax, 'String'));
v_axMin=str2num(get(handles.edit_axisMin, 'String'));
if (v_axMax==v_axMin), v_axMax=v_axMax+1;end
prop.v_axMin      = v_axMin;
prop.v_axMax      = v_axMax;
prop.v_zerofix    = get(handles.cbx_zerofix,'Value');

% convert channel to image
prop.image_mode_ind  = get(handles.pop_imgMode', 'Value');
v_interpmethod = get(handles.pop_interpMethod, 'String');
prop.interpmethod = ...
  char(v_interpmethod(get(handles.pop_interpMethod, 'Value')));
prop.v_interpstep = ...
  round(str2num( get(handles.edit_interpMatrix, 'String' ) ));

data.image2Dprop = prop; %<-- from gui
% Default Values
data.image2Dprop.v_MP = 50;
data.image2Dprop.v_colormap = 1; % default
return;

function set2DImageAxesObjectData(handles,data)
% Setter of this GUI
% default setting

% not structure : outof format ;
if ~isstruct(data), return; end
setappdata(handles.figure1,'DefaultAOdata',data);

% Set Region
if isfield(data,'region'),
  try,
    str=get(handles.pop_DataRegion,'String');
    val=find(strcmpi(str,data.region));
    if ~isempty(val),
      set(handles.pop_DataRegion,'value',val);
    end
  end
end
% have image -2d property?
if ~isfield(data,'image2Dprop'),
  return;
end
prop = data.image2Dprop;

% Set Mask ch data
try
  if isfield(prop,'mask_channel') && ~isempty(prop.mask_channel),
    set(handles.edit_maskCh, 'String', ...
      num2str(prop.mask_channel));
  end
end

% Set Time
try
  if isfield(prop,'v_timeposition') && ~isempty(prop.v_timeposition),
    set(handles.edit_pos', 'String', ...
      num2str(prop.v_timeposition ));
  end
end

% setup Color-Axis
try,
  if isfield(prop,'v_axisAuto'),
    set(handles.cbx_axisAuto, 'Value',prop.v_axisAuto);
  end
  if isfield(prop,'v_zerofix'),
    set(handles.cbx_zerofix,'Value', prop.v_zerofix);
  end
  if isfield(prop,'v_axMax') && ~isempty(prop.v_axMax),
    set(handles.edit_axisMax, 'String', ...
      num2str(prop.v_axMax));
  end
  if isfield(prop,'v_axMin') && ~isempty(prop.v_axMin),
    set(handles.edit_axisMin, 'String', ...
      num2str(prop.v_axMin));
  end
end
% convert channel to image
try
  if isfield(prop,'image_mode_ind') &&  ...
      prop.image_mode_ind(1) > 0 && ...
      prop.image_mode_ind(1) <= 3,
    set(handles.pop_imgMode', 'Value',prop.image_mode_ind(1));
  end
  if isfield(prop,'interpmethod'),
    str=get(handles.pop_interpMethod, 'String');
    val=find(strcmpi(str,prop.interpmethod));
    if ~isempty(val),
      set(handles.pop_interpMethod, 'Value',val);
    end
  end
  if isfield(prop,'v_interpstep'),
    set(handles.edit_interpMatrix, 'String', ...
      num2str(prop.v_interpstep));
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Check and sub-getter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbx_axisAuto_Callback(h, eventdata, handles)
% ---------------------------------------
%  Change Enable / Disable by for Auto-Axis(color)
% ---------------------------------------
% Axis Setting
axisset_h = [handles.edit_axisMax, ...
  handles.edit_axisMin, ...
  handles.txt_max, ...
  handles.txt_min];
% Axis Auto Checkbox
if get(h,'Value')
  set(axisset_h,'Enable','off');
else
  set(axisset_h,'Enable','on');
end
return;

%----------------------------------------------------------------
function edit_maskCh_Callback(h, eventdata, handles)
% ---------------------------------------
%  Set Time position index
% ---------------------------------------
chs = str2num(get(handles.edit_maskCh, 'String'));
% check positive integer
return;

function edit_pos_Callback(h, eventdata, handles)
% ---------------------------------------
%  Set Time position index
% ---------------------------------------
pos = str2num(get(handles.edit_pos, 'String'));
if isempty(pos) || length(pos)>1,
  h=warndlg('Input a number.');
  waitfor(h);return;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI control(Enable/Disable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_imgMode_Callback(h, eventdata, handles)
% ---------------------------------------
%  Change Enable / Disable by Image Mode
% ---------------------------------------
% Image Mode Change
interped_h = [handles.txt_interp, ...
  handles.pop_interpMethod, ...
  handles.txt_matrix, ...
  handles.edit_interpMatrix];
if get(h, 'Value')==2,
  set(interped_h,'Enable','on');
else
  set(interped_h,'Enable','off');
end
return;
