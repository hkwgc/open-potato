function varargout = P3_MarkSetting(varargin)
% P3_MARKSETTING_MARKER M-file for P3_MarkSetting_Marker.fig
%      P3_MARKSETTING_MARKER, by itself, creates a new P3_MARKSETTING_MARKER or raises the existing
%      singleton*.
%
%      H = P3_MARKSETTING_MARKER returns the handle to a new P3_MARKSETTING_MARKER or the handle to
%      the existing singleton*.
%
%      P3_MARKSETTING_MARKER('Property','Value',...) creates a new P3_MARKSETTING_MARKER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to P3_MarkSetting_Marker_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      P3_MARKSETTING_MARKER('CALLBACK') and P3_MARKSETTING_MARKER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in P3_MARKSETTING_MARKER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 06-Mar-2007 14:25:14


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_MarkSetting_OpeningFcn, ...
  'gui_OutputFcn',  @P3_MarkSetting_OutputFcn, ...
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


% --- Executes just before P3_MarkSetting_Marker is made visible.
function P3_MarkSetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for P3_MarkSetting_Marker
handles.output = hObject;
% Update handles structure
handles.figure1=hObject;
set(handles.psb_ok,'Visible','off');
setappdata(handles.figure1,'StimTC',[]);
setappdata(handles.figure1,'Stim',[]);
% Set Render
set(handles.figure1,'Render','zbuffer');

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = P3_MarkSetting_OutputFcn(hObject, eventdata, handles)
% Output is Figure-Handle : See also OpeningFcn
varargout{1} = handles.output;

% ------------------------------------------------------------------
function setContinuousData(hObject, eventdata, handles, header, data)
% input countinuous-data,set gui
%  header      : Continuoue-Header Data
%  data        : Countinuous Data
%
% Get Appdata
tc=getappdata(handles.figure1, 'StimTC');
if ~isempty(tc) && length(tc)==length(header.stimTC)
  a=questdlg({' Mark Setting : ',...
    '  Do you want to Copy before Stimulation Mark?'},'Copy Mark?',...
    'Yes','No','Yes');
  if strcmp(a,'No')
    % Set Appdaat->header
    header.stimTC=getappdata(handles.figure1,'StimTC');
    header.stim  =getappdata(handles.figure1,'Stim');
    set(handles.psb_ok, 'Visible','off');
  else
    set(handles.psb_ok, 'Visible','on');
  end
else
  set(handles.psb_ok, 'Visible','on');
end
% Update Appdata
setappdata(handles.figure1,'StimTC',header.stimTC);
setappdata(handles.figure1,'Stim',header.stim);
setappdata(handles.figure1,'Header',header);
setappdata(handles.figure1,'Data',data);
% Set stimMode
set(handles.pop_mode, 'Value', header.StimMode);
% Set Filename
fname=header.TAGs.filename;
set(handles.txt_filename,'String',fname);
% Set Local-data
setLocal(handles.figure1);

% ------------------------------------------------------------------
function setLocal(fig)
handles = guidata(fig);
header=getappdata(handles.figure1,'Header');
data=getappdata(handles.figure1,'Data');

ch = size(data,2);
setappdata(fig, 'SamplingPeriod',header.samplingperiod);
setappdata(fig, 'DATA_SIZE', size(data));
clear header data;
% Make String
str={};
for tg=1:ch
  str{end+1}=num2str(tg);
end
% Make Value
chini = get(handles.pop_channel,'Value');
if chini > ch,  chini=ch;  end

set(handles.pop_channel,...
  'Value',chini,...
  'String',str);
clear str chini ch;

%  -- Reload Stimulation Marks --
try
  set(handles.figure1,'CurrentAxes',handles.axes1);
  cla;
  plot_HB(handles);
  axis tight; ax = axis;
  axh = ax(4) - ax(3); sz = axh *0.2;
  ax(4)=ax(4)+sz; ax(3)=ax(3)-sz;
  axis(ax);
end
try
  psb_reset_Callback(handles.psb_reset, [], handles);
end
return;

% ------------------------------------------------------------------
function [header,data]=getContinuousData(hObject, eventdata, handles)
% get gui , output  countinuous-data
%  header      : Continuoue-Header Data
%  data        : Countinuous Data
%
% Get Appdata
header=getappdata(handles.figure1,'Header');
data=getappdata(handles.figure1,'Data');

% ------------------------------------------------------------------
function ecode=getLocal(handles)
% Get Local GUI-Data
header=getappdata(handles.figure1,'Header');
s     = getappdata(handles.figure1,'OriginalStimulation');
dstim = getappdata(handles.figure1,'DiffStimulation');
sflag = getappdata(handles.figure1,'FlagStimulation');

if 0
  % ?? yamada ---> too poor to set
  % Update stimTc
  tc=getappdata(handles.figure1,'StimTC');
  tc(:)=0;
  % Bugfix 06-Apr-2007
  tc(s(:,2)+dstim)=s(:,1);
  %tc(s(:,2))=1;
  header.stimTC=tc;
  % Update stim
  mode=get(handles.pop_mode,'Value');
  [header, ecode]=uc_makeStimData(header,mode);
else
  % B070625B (Make New Stim)
  mode=get(handles.pop_mode,'Value');
  [stim_kind,stim_out]= patch_stim(s,mode,sflag,dstim);
  if mode==1
    didx=find(sflag(:,1));
    stim_kind(didx)=[];stim_out(didx,:)=[];
  end
  % Apply Difference to stimTC
  header.stimTC(:)=0;
  header.stimTC(stim_out(:,1))=stim_kind(:);
  header.stimTC(stim_out(:,2))=stim_kind(:);
  % Applay stimTC to header
  mode=get(handles.pop_mode,'Value');
  [header, ecode]=uc_makeStimData(header,mode);
end
  
if ecode==0,
  % Set
  setappdata(handles.figure1,'Header',header);
else
  psb_reset_Callback(handles.psb_reset,[],handles);
  errordlg({'Could not make Stim-data.',lasterr},'Make Stim Error:');
end

% ------------------------------------------------------------------
function psb_ok_Callback(hObject, eventdata, handles)
% get gui , set  visible-off of ok-button
%
% Get Local-data
ecode=getLocal(handles);
if ecode==0,
  % Set Visible-off of ok-button
  set(handles.psb_ok,'Visible','off');
end

% ------------------------------------------------------------------
function psb_cancel_Callback(hObject, eventdata, handles)
handles.output=[];
P3_MarkSetting_CloseRequestFcn(handles.figure1, [],handles);


% ------------------------------------------------------------------
function psb_reset_Callback(hObject, eventdata, handles)
header=getappdata(handles.figure1,'Header');
data=getappdata(handles.figure1,'Data');

% Make Stimulation Time
smpl_pld=header.samplingperiod;% sampling period [ms]
st= str2num( get(handles.edt_prestim, 'String') )  * 1000/smpl_pld;
ed= str2num( get(handles.edt_poststim, 'String') )    * 1000/smpl_pld;
% rx= str2num( get(handles.rlx_edt, 'String') )           * 1000/smpl_pld;

stimTC = header.stimTC(:);
ostim = find(stimTC>0);
ostim = ostim(:);

% Original Stimulation Data
ostim = [stimTC(ostim), ostim];
setappdata(handles.figure1,'OriginalStimulation', ostim);

% Difference between dstim
dstim = zeros(size(ostim,1),1);
setappdata(handles.figure1,'DiffStimulation', dstim);

% Flag of Stimulation
sflag  = false([size(ostim,1),size(data,2)]);
setappdata(handles.figure1,'FlagStimulation', sflag);

% Make Strings of Marker-Listbox
new_listbox_marker(handles);

% Plot Marker
plot_Mark(handles);
return;

%------------------------------------------------------------------
function lbx_marker_ButtonDownFcn(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List box --> Selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lbx_marker_Callback(hObject, eventdata, handles)
return;

%------------------------------------------------------------------
function lbx_marker_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List box --> Selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (get(handles.cbx_onSelect, 'Value') )
  sub_invert(handles);
end
plot_Mark(handles);
stim_edit_view(handles);
return;

%------------------------------------------------------------------
function pop_mode_Callback(hObject, eventdata, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change mode .. renew
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dstim = getappdata(handles.figure1,'DiffStimulation');
if isempty(dstim),
  psb_reset_Callback(handles.figure1, [] , handles);
else,
  % Make Strings of Marker-Listbox
  new_listbox_marker(handles);
  % Plot Marker
  plot_Mark(handles);
end
return;

%------------------------------------------------------------------
function psb_change_Callback(hObject, eventdata, handles)
%invert
sub_invert(handles);
plot_Mark(handles);
return;

%------------------------------------------------------------------
function psb_select_Callback(hObject, eventdata, handles)
% marker select mode
% === Load Data ===
sorgn = getappdata(handles.figure1, 'OriginalStimulation');
sdiff = getappdata(handles.figure1, 'DiffStimulation');
sflag = getappdata(handles.figure1, 'FlagStimulation');

st = get(handles.lbx_marker, 'String');
idx= get(handles.lbx_marker, 'UserData');
% ********* Search Series *********
if get(handles.cbx_selectSerial,'Value')
  % === get Select Key ===
  selectkey = get(handles.edt_selectSerial,'String');
  % Now : series number is as same as line
  sSeries =str2num(selectkey);      % OK
  ck = [find(sSeries>length(idx)); ...
    find(sSeries<=0)];
  if ~isempty(ck), sSeries(ck)=[]; end

  tg_tmp = zeros(length(idx),1);
  tg_tmp(sSeries) = 1;
  if exist('tg','var')
    tg_tmp = tg + tg_tmp;
    tg = tg_tmp==2;
  else
    tg =tg_tmp;
  end
end
% ********* Search Kind *********
if get(handles.cbx_selectKind,'Value')
  selectkey = get(handles.edt_selectKind,'String');
  sKind = str2num(selectkey);
  %type(Kind) <?>
  kind=sorgn(idx(:,1),1);
  tg_tmp = zeros(length(idx),1);
  for kind_num = sKind
    kind_idx = find(kind==kind_num); % must be scalar
    if isempty(kind_idx)
      warndlg([' No Kind ' num2str(kind_num) ' exist.']);
      continue;
    end
    tg_tmp(kind_idx) = 1;
  end
  if exist('tg','var')
    tg_tmp = tg + tg_tmp;
    tg = tg_tmp==2;
  else
    tg =tg_tmp;
  end
end
if exist('tg','var')
  tg = find(tg);
else
  tg = [1:length(idx)]';
end
% ===== Over/Under flow Check ====
if isempty(tg)
  errordlg('No matching data found');
  OSP_LOG('err', ' POTATo Mark Select', ...
    [' Select Key : ' selectkey]);
else
  set(handles.lbx_marker, 'Value',tg);
  plot_Mark(handles);
end
return;


%------------------------------------------------------------------
function n=edt_pm_unit_Callback(hObject, eventdata, handles)
try,
  n=str2double(get(hObject,'String'));
catch,
  warndlg(['Stimulation Change rate : ' lasterr]);
  n=1;
end
stim_edit_view(handles);
return;

%------------------------------------------------------------------
function psb_stimPlus_Callback(hObject, eventdata, handles)
n=edt_pm_unit_Callback(handles.edt_pm_unit, [], handles);
stimChange(handles,+n);
return;

%------------------------------------------------------------------
function psb_stimMinus_Callback(hObject, eventdata, handles)
n=edt_pm_unit_Callback(handles.edt_pm_unit, [], handles);
stimChange(handles,-n);
return;

%------------------------------------------------------------------
function pop_channel_Callback(hObject, eventdata, handles)
set(handles.figure1,'CurrentAxes',handles.axes1);
cla;
plot_HB(handles);
axis tight; ax = axis;
axh = ax(4) - ax(3); sz = axh *0.2;
ax(4)=ax(4)+sz; ax(3)=ax(3)-sz;
axis(ax);
plot_Mark(handles);

% ------------------------------------------------------------------
function P3_MarkSetting_DeleteFcn(hObject, eventdata, handles)

% ------------------------------------------------------------------
function P3_MarkSetting_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);


% ==Inner function===================================================
% For plot
% ------------------------------------------------------------------
function plot_HB(handles,header,data)
% Change : (Data-Format)
% load
header=getappdata(handles.figure1, 'Header');
data  =getappdata(handles.figure1, 'Data');
% set argument
ch       = get(handles.pop_channel, 'value');
smpl_pld = header.samplingperiod;
unit = 1000/smpl_pld;
hb_kind = 1:size(data,3); % All Print

% ordinary Put HBdata to Plot
strHBdata.data = data(:,ch,:); clear data;
ch=1;
strHBdata.tag  = header.TAGs.DataTag;
% TODO : Color Setting
clear header;
% plot HB Data
plot_HBdata(handles.axes1, ch, unit, hb_kind,strHBdata);
return;

%------------------------------------------------------------------
function plot_Mark(handles)
% ====================
% Get Stimulation Data
% ====================
ud = get(handles.lbx_marker, 'UserData');

sflag = getappdata(handles.figure1,'FlagStimulation');
unit  = 1000.0/getappdata(handles.figure1, 'SamplingPeriod');

clear ostim;
ch   = get(handles.pop_channel, 'value');

% ====================
% Axes Setting
% ====================
set(handles.figure1,'CurrentAxes',handles.axes1);
% Height get
tg = get(handles.lbx_marker, 'Value');
ax = axis;
% ====================
% Make Effective stim
% ====================
sflag = sflag(:,ch);

rm_h = findobj(handles.axes1,'Tag', 'StimArea');
if ~isempty(rm_h), delete(rm_h); end;
for id = 1:size(ud,1),
  if sflag(ud(id,1)) || sflag(ud(id,2))
    continue;
  end
  tc1 = ud(id,3:4)/unit;
  if (tc1(2)-tc1(1) < 0.001),
    tc1 = mean(tc1(:)) + [-0.005 0.005];
  end
  h_p = fill(tc1([1 1 2 2 1]), ...
    ax([3 4 4 3 3]), ...
    [0.7, 1.0, 0.7]);
  set(h_p, 'Tag', 'StimArea', ...
    'LineStyle', 'none');
  alpha(h_p,0.07);
end
% ====================
% Plot Selected Stimulation
% ====================
% height = ax(3) + 0.95 * (ax(4) - ax(3));
height = 0.95 * ax(4) + 0.05 * ax(3);
plot_stim=[];
for id=tg(:)',
  if ud(tg,1)~=ud(tg,2),
    plot_stim = [plot_stim, ...
      linspace(ud(id, 3), ud(id, 4),10)];
  else
    plot_stim = [plot_stim, ud(id,3)];
  end
end
% Remove Function
rm_h = findobj(handles.axes1,'Tag', 'SelectedMarker');
if ~isempty(rm_h), delete(rm_h); end
h = plot(plot_stim(:)./unit, repmat(height,length(plot_stim),1), 'mp');
set(h,'Tag', 'SelectedMarker');

return;

%------------------------------------------------------------------
function new_listbox_marker(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Renew Marker Label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Data :
%   [index1, start_time1, end_time1;
%    index2, start_time2, end_time2; ...]
%  where index 1, or 2 is stimulation number

% ===== Get Stimulation Data ====
ostim = getappdata(handles.figure1,'OriginalStimulation');
dstim = getappdata(handles.figure1,'DiffStimulation');
sflag = getappdata(handles.figure1,'FlagStimulation');

[stim_kind, stim_out, flag, idx] = ...
  patch_stim(ostim, get(handles.pop_mode,'Value'), ...
  sflag, dstim);

vl=get(handles.lbx_marker, 'Value');
vl(find(vl>size(idx,1)))=[];
if isempty(vl), vl=size(idx,1); end

set(handles.lbx_marker, ...
  'Value', vl, ...
  'userdata', [idx, stim_out]);

% ==== Make Strings ====
str={};
for id = 1:size(idx,1),
  str{id} = get_lbxMarkerString(handles,id);
end

if isempty(str),
  str = 'No Stimulation Exist';
end
set(handles.lbx_marker, 'String',str);

% update Relax Max
changeRelaxMax(handles);
return;

%------------------------------------------------------------------
function str = get_lbxMarkerString(handles,id),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List Box String maker
%  stimData : Stimulation Data
%  idx      : target Stimulation Data
%  line_no  : Sirial Number of Stimulation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------
%  Get Now Data
% --------------
ud    = get(handles.lbx_marker, 'UserData');
ostim = getappdata(handles.figure1,'OriginalStimulation');
sflag = getappdata(handles.figure1,'FlagStimulation');
unit  = 1000.0/getappdata(handles.figure1, 'SamplingPeriod');

sflag = sflag(ud(id,1),:) | sflag(ud(id,2),:);
if all(sflag),
  tmp = ' x ';
elseif any(sflag),
  tmp = 'mix';
else,
  tmp = ' o ';
end

switch get(handles.pop_mode,'Value'),
  case 1
    % Event
    str = ...
      sprintf('%s[%03d]<%02d>: %8.1f', ...
      tmp,id , ostim(ud(id,1),1), ...
      ud(id,3) /unit);

  case 2
    % Block
    str = ...
      sprintf(['%s[%03d]<%02d>: %8.1f ' ...
      'To %8.1f ( Diff : %8.1f )'], ...
      tmp, id, ostim(ud(id,1),1), ...
      ud(id,3)/unit, ud(id,4)/unit, (ud(id,4)-ud(id,3))/unit);
  otherwise,
    error('Stimulation Mode Error');
end
return;


%------------------------------------------------------------------
function changeRelaxMax(handles)
% Change Relaxing time Max and Min
% Create by Masanori Shoji at 03-Jun-2005

% get Stimulation Data
ud = get(handles.lbx_marker, 'UserData');
ostim = getappdata(handles.figure1,'OriginalStimulation');
sflag = getappdata(handles.figure1,'FlagStimulation');

% == get StimTiming Matrix ==
% Initialize  StimTiming Matrix
if isempty(ud),
  stimtime_list=[];
  set([handles.txt_premax, handles.txt_postmax],...
    'String','(-)');
else,
  stimtime_list = [ostim(ud(:,1),1), ud(:,3:4)];
end

stim_interval = stimtime_list(:,[2,3])';
sz            = getappdata(handles.figure1, 'DATA_SIZE');
stim_interval = [0; ...
  stim_interval(:);...
  sz(1)];
stim_interval = diff(stim_interval);
stim_interval = stim_interval(1:2:end);

stim_kind      = zeros(size(stim_interval,1),2);
stim_kind(1,2) = NaN;stim_kind(end,1) = NaN;
stim_kind([1:end-1],1) = stimtime_list(:,1);
stim_kind([2:end],  2) = stimtime_list(:,1);

unit_inv    = getappdata(handles.figure1, 'SamplingPeriod')/1000.;

get_kind   = find(~isnan(stim_kind));
if isempty(get_kind),
  set([handles.txt_premax, handles.txt_postmax],...
    'String','(-)');
  return;
end
get_kind = stim_kind(get_kind);

tmp = find(stim_kind(:,1)==get_kind(1));
start_max  = min(stim_interval(tmp));
set(handles.txt_premax, ...
  'String',sprintf('%4.1f',start_max*unit_inv));

tmp = find(stim_kind(:,2)==get_kind(1));
end_max    = min(stim_interval(tmp));
set(handles.txt_postmax, ...
  'String',sprintf('%4.1f',end_max*unit_inv));

% Change minimum Stimulation
% add : 04-Jun-2005
stim_list2 = stimtime_list(:,3) - stimtime_list(:,2);
mx = max(stim_list2(:));
mn = min(stim_list2(:));
if mx*unit_inv*1000 > (mn*unit_inv*1000+OSP_STIMPERIOD_DIFF_LIMIT),
  warndlg('stimulation time is so different.');
end
setappdata(handles.figure1,'StimulationRange',mx * unit_inv);

return;

%------------------------------------------------------------------
function stim_edit_view(handles)
% Enable / Disable  push-button, '+'/'-';
try
  n=str2double(get(handles.edt_pm_unit,'String'));
catch
  n=1;
end

% Load Stim Data;
ostim = getappdata(handles.figure1,'OriginalStimulation');
dstim = getappdata(handles.figure1,'DiffStimulation');
stim      = ostim(:,2) + dstim;
stim_kind = ostim(:,1);
clear ostim dstim;

tg = get(handles.lbx_marker, 'Value');
ud = get(handles.lbx_marker, 'UserData');
tg = ud(tg,1:2); tg=tg(:)';
clear ud;
sz = getappdata(handles.figure1, 'DATA_SIZE');

% Default
set(handles.psb_stimPlus,'enable','on');
set(handles.psb_stimMinus,'enable','on');

for id0 = tg,
  if id0~=size(stim,1),
    % Get Upper Stimulation Time of
    upper = stim(id0+1);
  else
    upper=sz(1); % Max of Time-Point
  end

  % p_time = cunow_time + n
  p_time = stim(id0) + n;
  if p_time>= upper,
    set(handles.psb_stimPlus,'enable','off');
  end

  if id0~=1,
    lower=stim(id0-1);
  else
    lower=0;
  end
  m_time = stim(id0) - n;
  if m_time <= lower,
    set(handles.psb_stimMinus,'enable','off');
  end
end

return;

% --------------------------------------------------------------------
function sub_invert(handles)
% Change Selected Channel Flags

% Load Stimulation
ud    = get(handles.lbx_marker, 'UserData');
tg    = get(handles.lbx_marker, 'Value');
st    = get(handles.lbx_marker, 'String');
sflag = getappdata(handles.figure1,'FlagStimulation');

for id=tg,
  sflag0 = sflag(ud(id,1),:) | sflag(ud(id,2),:);
  if all(sflag0),
    sflag(ud(id,1),:) = false(size(sflag(ud(id,1),:)));
  else
    sflag(ud(id,1),:) = true(size(sflag(ud(id,1),:)));
    if ud(id,1) ~= ud(id,2),
      sflag(ud(id,2),:) = sflag(ud(id,1),:);
    end
  end
  if ud(id,1) ~= ud(id,2),
    sflag(ud(id,2),:) = sflag(ud(id,1),:);
  end
  setappdata(handles.figure1,'FlagStimulation',sflag);

  st{id} = get_lbxMarkerString(handles,id);
end

set(handles.lbx_marker, 'String',st);

% update Relax Max
changeRelaxMax(handles);
return;


% --------------------------------------------------------------------
function stimChange(handles,n)
% Change Selected Stimulation Block --> + n [point]

% Load Stim Data;
dstim = getappdata(handles.figure1,'DiffStimulation');

tg = get(handles.lbx_marker, 'Value');
ud = get(handles.lbx_marker, 'UserData');

for id=tg
  dstim(ud(id,1)) = dstim(ud(id,1)) + n(1);
  if ud(id,1) ~= ud(id,2),
    dstim(ud(id,2)) = dstim(ud(id,2)) + n(1);
  end
end
setappdata(handles.figure1,'DiffStimulation',dstim);

new_listbox_marker(handles);
plot_Mark(handles);
stim_edit_view(handles),
return;
