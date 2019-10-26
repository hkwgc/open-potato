function varargout = FD_BandFilter_getArgument(varargin)
% FD_BANDFILTER_GETARGUMENT make Band-Filter Argument-Data.
%
%
% --- Function ----
% Syntax : 
%   argData = FD_BANDFILTER_GETARGUMENT('argData',argData,'Mflie',script);
%
% Input Value :
%    argData : Default Argument Data / or no..
%    script  : Test Plot Data for this GUI.
%
% Return Value : (argData)
%   --> if push-button OK :
%             argData of Filter-Data of BandFilter
%   --> if cancel or push-button Canncel or Delte by window(X):
%             empty.
%
% Using MAT-File :
%   BlockFilter/LAYOUT_BandFilter.mat : Layout Filterd Data of Viewer II.
%   ospData/LAYOUT_PlotLine.mat : Layout Filterd Group Data of Viewer II.
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES,
%           UC_BANDFILTER, FILTERDEF_Butter,FFT(=BANDFILTER),
%           OSP_LAYOUTVIEWER, OSP_VIEWAXESOBJ_L_BF.

% Last Modified by GUIDE v2.5 26-Dec-2006 14:38:14


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 2006.04.03
% $Id: FD_BandFilter_getArgument.m 180 2011-05-19 09:34:28Z Katura $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FD_BandFilter_getArgument_OpeningFcn, ...
                   'gui_OutputFcn',  @FD_BandFilter_getArgument_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening & Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FD_BandFilter_getArgument_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
handles.output = [];
guidata(hObject, handles);

%==================
% invisible Apply-button
%==================
set(handles.psb_mc_view, 'Enable','off','Visible', 'off');    
%==================
% Get Arguments
%==================
argData=[];mfile_pre='';
for idx=2:2:length(varargin),
  % Property Name ?
  if ~ischar(varargin{idx-1}),
    warning('Bad Property Name');
    continue;
  end
  switch(varargin{idx-1}),
   case {'argData'},
    argData=varargin{idx};
   case {'Mfile'},
    mfile_pre=varargin{idx};
   otherwise,
    warning(['No such a Property : ' varargin{idx}]);
    continue;
  end % Property Name Switch
end % Get Get Argument


%========================
%  Arg-Data Initiarized! 
%========================
%------------------------
% Filter Type (Function)
%------------------------
str=get(handles.pop_filtername, 'String');
if ~exist('butter','file'),
  str=str(1);
  set(handles.pop_filtername, 'String', str);
end
filterfunction=str{1};
if ~isempty(argData) && isfield(argData,'FilterFunction'),
  % There is Filter-Function
  vl=find(strcmpi(argData.FilterFunction,str));
  if isempty(vl),
    h=warndlg({...
        ['No Filter-Function Named, ' argData.FilterFunction ',',...
          ' in your environment.'],...
        ' Butterworth need "Signal Processing Toolbox".'},...
      'No Filter-Function');
    waitfor(h);
    vl=1;
  else
    set(handles.pop_filtername, 'Value',vl);
  end
  filterfunction=str{vl};
end

%-------------
% Filter Type ,terrible way..
%-------------
pos=get(handles.pop_filtertype, 'Position');
if strcmpi(filterfunction,'FFT'),
  % FFT
  acth=handles.pop_filtertype2;
  sush=handles.pop_filtertype;
  set(handles.edt_dimension,'Visible','off','Enable', 'off');
else
  % Butter.. 
  acth=handles.pop_filtertype;
  sush=handles.pop_filtertype2;
  set(handles.edt_dimension,'Visible','on', 'Enable', 'on');
  if ~isempty(argData) && isfield(argData,'butterworthDim'),
    set(handles.edt_dimension,...
      'String',num2str(argData.butterworthDim));
  end
end
set(acth,...
  'Value', 1, 'Position', pos,...
  'Visible', 'on', 'Enable', 'on');
set(sush,...
  'Value', 1, 'Position', pos,...
  'Visible', 'off', 'Enable', 'off');

% Set filtername,type popup-menu
if ~isempty(argData) && isfield(argData,'FilterType'),
  str=get(acth,'String');
  idx=find(strcmpi(str, argData.FilterType));
  if isempty(idx),
    warndlg('No Filter Type :: in your environment!');
    idx=1;
  end
  set(acth,'Value',idx);
end
%------------
% High- Pass 
%------------
hp=[];
if isfield(argData,'HighPassFilter'),
  argData.HighPassFilter = argData.HighPassFilter;
end
if isfield(argData,'HighPassFilter') && ...
      ~isempty(argData.HighPassFilter),
  try,
    hp = num2str(argData.HighPassFilter(1));
  catch,
    warning(['Error : High Pass Filter Setting..' lasterr]);
  end
end
if isempty(hp),
  set(handles.edt_highpass,'String','0.02','UserData',0.02);
else,
  set(handles.edt_highpass,'String',hp, ...
		    'UserData',argData.HighPassFilter(1));
end

%------------
% low- Pass
%------------
lp=[]; 
if isfield(argData,'LowPassFilter'),
  argData.LowPassFilter = argData.LowPassFilter;
end
if isfield(argData,'LowPassFilter') && ...
      ~isempty(argData.LowPassFilter),
  try,
    lp = num2str(argData.LowPassFilter(1));
  catch,
    warning(['Error : Low Pass Filter Setting..' lasterr]);
  end
end
if isempty(lp),
  set(handles.edt_lowpass,'String','0.8','UserData',0.8);
else,
  set(handles.edt_lowpass,'String',lp, ...
		    'UserData',argData.LowPassFilter(1));
end

%=====================
% View!
%=====================
try,
  if ~isempty(mfile_pre),
    draw_init(handles,mfile_pre);
    % View (create range-slider and the callbacks) 
    draw_slider_axesrange(hObject, handles);
    draw_xaxis(handles);
  else,
    error('No Previous Data Exist to print');
  end
catch,
  warning(lasterr);
end

% B070704A :::
handles=guidata(hObject);
if strcmpi(filterfunction,'FFT'),
  % FFT
  pop_filtertype2_Callback(handles.pop_filtertype2,eventdata,handles);
else
  % Butter.. 
  pop_filtertype_Callback(handles.pop_filtertype,eventdata,handles);
end


%===========================
% Wait for user response 
% (if OK)
%===========================
if 1,
  set(handles.figure1,'WindowStyle','modal')
  uiwait(handles.figure1);
else
  % Debug Mode ..
  handles.output = 'debug';
  guidata(hObject, handles);
end

%------------------------------------
function pop_filtertype_CreateFcn(hObject, eventdata, handles)
% Get Available Filter Type and initiarize.
% If you want to add more Filter Type,
% Change also uc_bandfilter
%------------------------------------- 
% str = {'FFT','BandPassFilter','BandStopFilter', ...
%      'HighPassFilter','LowPassFilter',};
% ft  = {'fft','bpf','bsf', 'hpf','lpf',};  % for butter filter 
% 
% set(hObject,'String',str, 'Value',1);
% set(hObject,'UserData',ft);

str = {'BandPassFilter','BandStopFilter', ...
     'HighPassFilter','LowPassFilter',};
ft  = {'bpf','bsf', 'hpf','lpf',};  % for butter filter 

set(hObject,'String',str, 'Value',1);
set(hObject,'UserData',ft);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Output Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function varargout = FD_BandFilter_getArgument_OutputFcn(hObject, eventdata, handles)
% Output Function :
% Get default command line output from handles structure
%   --> if push-button OK :
%             argData of Filter-Data of BandFilter
%   --> if cancel or push-button Canncel or Delte by window(X):
%             empty.
%------------------------------------
varargout{1} = handles.output;

% For Debug --> See Also Opting Function
if ischar(varargout{1}) && strcmp(varargout{1},'debug'),
  % This code run only if Debug Mode!
  warning(['FD_BandFilter_getArgument: ' ...
	   'Runing in Debug Mode!']);
  varargout{1}=[];
  return;
end

% Delete Figure : When output
delete(handles.figure1);

%------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close function with uiresume
%   Not Dete here
%------------------------------------
try,
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % --> back to Opening funcition : at uiwait
    %     --> Outup Function : Delete
    uiresume(handles.figure1);
  else,
    delete(hObject);
  end
end


%------------------------------------
function psb_OK_Callback(hObject, eventdata, handles)
% Set output Variables, and close.
% --> Output Data is argData of Filter-Data
%     Definition of argData is written in
%     FilterDef_BandFilter!
%------------------------------------
fhs=handles;
% Filter-Mode
str=get(handles.pop_filtername, 'String');
d.FilterFunction=str{get(handles.pop_filtername, 'Value')};
if strcmp(get(handles.edt_dimension,'Visible'),'on')
  d.butterworthDim=round(str2double(get(handles.edt_dimension,'String')));
end

% Filter-Type
if strcmpi(d.FilterFunction,'FFT'),
  % FFT
  acth=handles.pop_filtertype2;
else
  % Butter.. 
  acth=handles.pop_filtertype;
end
ft=get(handles.pop_filtertype,'String');
ft0=get(acth,'String');
d.FilterType=ft0{get(acth,'Value')};

% High-Pass
if strcmp(d.FilterType,  ft{4})~=1,   % case != LowPassFilter
    d.HighPassFilter=get(fhs.edt_highpass,'UserData');
end 
% Low-Pass
if strcmp(d.FilterType,  ft{3})~=1,   % case != HighPassFilter
    d.LowPassFilter=get(fhs.edt_lowpass,'UserData');
end 
% --- Update GUI-Data ---
handles.output   = d;
guidata(hObject, handles);
% (not debug mode..)
% --> return to Opening-function at uiwait.
%      --> Output function.
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
else, delete(handles.figure1); end

%------------------------------------
function psb_cancel_Callback(hObject, eventdata, handles)
% Set output to Empty, and close.
%------------------------------------
handles.output   = []; guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
else, delete(handles.figure1); end

%------------------------------------
function psb_Help_Callback(hObject, eventdata, handles)
% Help of This Funciton
%------------------------------------
OspHelp('FilterDef_BandFilter');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting Variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function pop_filtername_Callback(hObject, eventdata, handles)
% Do notion in particular in this version.
% If you want to Add new Filter-Type for Band Filter
%   1. Chnage Create-Function of this popup-menu.
%   2. Change uc_bandfilter. ---->>> ui_bandfilter
%------------------------------------
val = get(hObject,'Value');
pos= get(handles.pop_filtertype, 'Position');
tval1 = get(handles.pop_filtertype,  'Value');
tstr1 = get(handles.pop_filtertype,  'String');
tval2 = get(handles.pop_filtertype2, 'Value');
tstr2 = get(handles.pop_filtertype2, 'String');

if val==1,
  idx=find(strcmp(tstr2, tstr1{tval1}));
  if isempty(idx), idx=1;end
  set(handles.pop_filtertype2, 'Value', idx);
  set(handles.pop_filtertype2, 'Visible', 'on', ...
                               'Enable', 'on', 'Position', pos);
  set(handles.pop_filtertype,  'Visible', 'off', 'Enable', 'off');
  pop_filtertype2_Callback(handles.pop_filtertype2, [], handles);
else
  idx=find(strcmp(tstr1, tstr2{tval2}));
  if isempty(idx), idx=1;end
  set(handles.pop_filtertype,  'Value', idx);
  set(handles.pop_filtertype,  'Visible', 'on', ...
                               'Enable', 'on');
  set(handles.pop_filtertype2, 'Visible', 'off', 'Enable', 'off');
  pop_filtertype_Callback(handles.pop_filtertype, [], handles);  
end

%------------------------------------
function pop_filtertype_Callback(hObject, eventdata, handles)
% Do notion in particular in this version.
% If you want to Add new Filter-Type for Band Filter
%   1. Chnage Create-Function of this popup-menu.
%   2. Change uc_bandfilter. ---->>> ui_bandfilter
%------------------------------------
ft  = get(hObject,'String');
val = get(hObject,'Value');

set(handles.edt_highpass, 'ForegroundColor', 'black');   
set(handles.edt_lowpass,  'ForegroundColor', 'black');   
% Show Dimension-edit
set(handles.edt_dimension, 'Enable', 'on', 'Visible', 'on'); 
set(handles.txt_dimension, 'Visible', 'on');      

% Check pass-edit
if ft{val}(1) == 'L',
        set(handles.edt_highpass, 'Enable', 'off');    
    else,      
        set(handles.edt_highpass, 'Enable', 'on');        
end
if ft{val}(1) == 'H',
        set(handles.edt_lowpass, 'Enable', 'off');    
    else,      
        set(handles.edt_lowpass, 'Enable', 'on');        
    end
% Apply callback    
lock_slider_pass(hObject,[], handles);
psb_mc_view_Callback(handles.psb_mc_view, [], handles);

%------------------------------------
function pop_filtertype2_Callback(hObject, eventdata, handles)
% Do notion in particular in this version.
% If you want to Add new Filter-Type for Band Filter
%   1. Chnage Create-Function of this popup-menu.
%   2. Change uc_bandfilter. ---->>> ui_bandfilter
%------------------------------------
ft  = get(hObject,'String');
val = get(hObject,'Value');

set(handles.edt_highpass, 'ForegroundColor', 'black');   
set(handles.edt_lowpass,  'ForegroundColor', 'black');   
% Hide Dimension-edit
set(handles.edt_dimension, 'Enable', 'off', 'Visible', 'off');   
set(handles.txt_dimension, 'Visible', 'off');    
% Check pass-edit
if ft{val}(1) == 'L',
        set(handles.edt_highpass, 'Enable', 'off');    
    else,      
        set(handles.edt_highpass, 'Enable', 'on');        
end
if ft{val}(1) == 'H',
        set(handles.edt_lowpass, 'Enable', 'off');    
    else,      
        set(handles.edt_lowpass, 'Enable', 'on');        
    end
% Apply callback   

lock_slider_pass(hObject,[], handles);
psb_mc_view_Callback(handles.psb_mc_view, [], handles);

%------------------------------------
function edt_highpass_Callback(hObject, eventdata, handles)
%------------------------------------
%==> High- Pass %.. spell-miss..
%.. correct spell-miss..
str=get(hObject,'String');
try
  num=str2num(str);
if num<0,error('HighPass must be positive'); end
  if length(num)>1, error('Too many input data');end
  set(hObject,'ForegroundColor','black', ...
	      'UserData',num);
catch
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',num2str(ud));
end
% Apply callback    
psb_mc_view_Callback(handles.psb_mc_view, [], handles);
% Update Slider(range,edge)
update_slider_pass(hObject, [], handles);

%------------------------------------
function edt_lowpass_Callback(hObject, eventdata, handles)
%------------------------------------
str=get(hObject,'String');
try,
  num=str2num(str);
  if num<0,error('LowPass must be positive'); end
  if length(num)>1, error('Too many input data');end
  set(hObject,'ForegroundColor','black', ...
	      'UserData',num);
catch,
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',num2str(ud));
end
% Apply callback    
psb_mc_view_Callback(handles.psb_mc_view, [], handles);
% Update Slider(range,edge)
update_slider_pass(hObject, [], handles);

%------------------------------------
function edt_dimension_Callback(hObject, eventdata, handles)
%------------------------------------
%  Check dimension
dim=str2num(get(hObject, 'String'));
if ~isempty(dim),dim=round(dim); end
if isempty(dim) || dim==0, dim=1; end
set(hObject, 'String', num2str(dim));
% ==> Aply View
psb_mc_view_Callback(handles.psb_mc_view, [], handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band Filter!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function [hdata, data]=getCurrentBFdata(fh,ed,hs),
% Get Current filterd data
% Input ; is as same as other Callbacks.
% bug fh is handle of figure.
%
% Known Upper : 
%    osp_VieweAxesObje_L_bf(getCurrentData)
%------------------------------------
hdata=getappdata(fh,'FHDATA');
data =getappdata(fh,'FDATA');
did  = 1; % TODO : Select Data
if iscell(data),  data=data{did}; end
if iscell(hdata), hdata=hdata{did}; end
%------------------------------------
function [hdata, data]=getCurentData(fh,ed,hs),
% Get Current Data
% Input ; is as same as other Callbacks.
% bug fh is handle of figure.
%
% Known Upper : 
%    exe_BandFilter
%------------------------------------
hdata=getappdata(fh,'CHDATA');
data =getappdata(fh,'CDATA');
did  = 1; % TODO : Select Data
if iscell(data),  data=data{did}; end
if iscell(hdata), hdata=hdata{did}; end

%------------------------------------
function exe_BandFilter(handles)
% Execute BandFilter, and Set Result to Application Data.
%   The Application-Data will be used in Ploting 
%   via "osp_ViewAxesObj_L_bf".
%
%   !! -- Warning -- !!
%     Execute This Object,
%     Before osp_ViewAxesObj_L_bf.
% 
% == List of APPLICATION DATA for OSP_VIEWAXESOJB_L_MC ==
%  I/O : NAME       : Info
%   I  : CHDATA     : Continuous Header Data
%   I  : CDATA      : Continuous Data
%   O  : FHDATA     : Header Filterd Data
%   O  : FDATA     : Filterd Data
%------------------------------------
type2={'BandPassFilter', 'HighPassFilter', 'LowPassFilter'};
fhs=handles; 
hp=get(fhs.edt_highpass,'UserData');
lp=get(fhs.edt_lowpass, 'UserData');
ff=get(fhs.pop_filtername,'String');
ff=ff{get(fhs.pop_filtername,'Value')};
ft=get(fhs.pop_filtertype,'String');
ft=ft{get(fhs.pop_filtertype,'Value')};
dim = str2num(get(fhs.edt_dimension, 'String'));
% convert to butterworth filter name
idx = regexp(ft, '[A-Z]');
ft = lower(ft(idx));
[hdata, data]=getCurentData(fhs.figure1,[],handles);
[cdata, chdata] = ...
  uc_bandfilter(data, hdata, hp,lp, ... 
  'FilterFunction',ff,...
  'FiltType', ft, 'Dimension', dim);
setappdata(handles.figure1, 'FHDATA', chdata);
setappdata(handles.figure1, 'FDATA',  cdata);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function draw_init(handles,mfile_pre)
% Motion Check Resutl-View Initialization.
% Make Continuous-Data
%------------------------------------
[cdata, chdata]=scriptMeval(mfile_pre,'cdata','chdata');
% Default Band-Filter Axes Object
%aobj_BandFilter=osp_ViewAxesObj_L_mc('getArgument');
% Modify Axes-Object

% Load Layout-Data
p=fileparts(which(mfilename));
load([p filesep 'LAYOUT_BandFilter_SB2.mat'],'LAYOUT');
% Modify Layout Data
% --> If you want fix Clor --> Set Here!
if 0,
  % -- lkie.
  LAYOUT.FilugrProperty.Name=get(handles.figure1,'Name');
  LAYOUT.vgdata{1}.Object{1}.Object{1} = ...
      aobj_BandFilter;
end
mx=-1;
for idx=1:length(cdata),
    tmp=size(cdata{idx},3);
    mx =max(mx,tmp);
end
setappdata(handles.figure1,'KindMaxNum',mx);
setappdata(handles.figure1,'CHDATA',chdata);
setappdata(handles.figure1,'CDATA',cdata);
exe_BandFilter(handles);

% Launch View --> with Option
h=osp_LayoutViewer(LAYOUT, chdata,cdata,...
		   'figureh',handles.figure1, ...
		   'kind', 1, ...
		   'psb_mc_view',handles.psb_mc_view);
     
graph_hs = findobj(handles.figure1, 'Type', 'Axes');
g_title={'FFT Result Filterd Data', 'FFT Result Original Data', 'Filterd Data', 'Original Data'};
% if length(graph_hs)>=4,
%   for i=4:-1:1,
%     subplot(graph_hs(i));
%     title(g_title(i), 'FontWeight','bold');
%   end
% end

%----------------------
% --> Set Data for 
%     Axes Distribution
%  (Default Axes Position)
%----------------------
% Get Axes in 1_1_1.
% See also ViewGroupAxes
%  and LayoutData
% !Commnet Out :: since rivistion 1.4
if 0,
a=findobj(handles.figure1,'Type','axes');
idx=strmatch('P1_1_1',get(a,'TAG'));
a=a(idx); 
pa.handle=a(end:-1:1);
set(a,'Units','Normalized');
p=get(pa.handle,'Position');
pa.original=p;
p=cell2mat(p);
pa.lb=[min(p(:,1)),min(p(:,2))];
pa.rt=[max(p(:,1)),max(p(:,2))] + p(1,3:4);
pa.ln=size(p,1);

set(handles.pop_axes_dist,'UserDat',pa);
end

%------------------------------------
function psb_plotall_Callback(hObject, eventdata, handles)
% Plot Review..
%     Plot by 'Plot All' Push-Button
%------------------------------------
p=fileparts(which(mfilename));
pp=fileparts(which('OSP'));
%load([pp filesep 'ospData' filesep 'LAYOUT_PlotLine.mat'],'LAYOUT');
load([pp filesep 'LAYOUT' filesep 'LAYOUT_PlotLine.mat'],'LAYOUT');
%load([p filesep 'LAYOUT_BF_GC.mat'],'LAYOUT');
% Modify Layout Data
% --> If you want fix Clor --> Set Here!
v=get(handles.pop_axes_dist,'Value');
switch v,
 case 1,
  nm='Normal0';
 case 2,
  nm='Square';
 case 3,
  nm='2Columns';
 otherwise,
  nm='Normal'
end
LAYOUT.vgdata{1}.Object{1}.DistributionMode=nm;

mx=getappdata(handles.figure1,'KindMaxNum');
fh=figure;
setappdata(fh,'KindMaxNum',mx);
fhdata=getappdata(handles.figure1,'FHDATA');
fdata=getappdata(handles.figure1,'FDATA');
%setappdata(fh,'FHDATA',fhdata);
%setappdata(fh,'FDATA',fdata);

try,
    kind_handle=findobj(handles.figure1,'style','listbox');
    kind=get(kind_handle,'Value');
catch,
    kind = 3;  % set same value of FD_MotionCheck
end
% Launch View --> with Option
% osp_LayoutViewer(LAYOUT, chdata,cdata,...
osp_LayoutViewer(LAYOUT, fhdata,fdata,...
		   'figureh',fh, ...
		   'kind', kind);
return;



%------------------------------------
function psb_mc_view_Callback(hObject, eventdata, handles)
% Callback of Push button Apply!
% Do Band-Filter and set Result to Appdata.
% and Re-View Result.
%------------------------------------
exe_BandFilter(handles);

ud=get(hObject,'UserData');
for idx=1:length(ud),
    try
        eval(ud{idx}.str);
    catch
        warning(lasterr);
    end
end
set(hObject,'UserData',ud);

%------------------------------------
function pop_axes_dist_Callback(hObject, eventdata, handles)
% Axes Distribution Change Popup-Menu
% This function change Axes Distribution 
% in Channgel Group-Axes
%------------------------------------
% Commnet Out :: since rivistion 1.4
if 0, % Comment out!
pa=get(hObject,'UserData');
vl=get(hObject,'Value');
posa=cell2mat(pa.original);
switch vl,
 case 1,
 case {2,3},
  if vl==2,
    cnum=ceil(sqrt(pa.ln));
  else,
    cnum=2;
  end
  % width
  pa_sz=pa.rt-pa.lb;
  c_sz   = pa_sz(1)/cnum;
  c_sp   = c_sz * 0.2; % space of col : 20%
  c_spp2 = c_sp/2;
  
  pos = pa.lb;
  cpos = pos(1)+c_spp2;
  for cid=2:cnum;
    cpos(cid)=cpos(cid-1)+c_sz;
  end
  % height
  rnum   = ceil(pa.ln/cnum);
  r_sz   = pa_sz(2)/rnum;
  r_spp2 = r_sz * 0.1; % space of col : 20%

  rpos = pos(2)+pa_sz(2) -(r_sz-r_spp2);
  for rid=2:rnum;
    rpos(rid)=rpos(rid-1)-r_sz;
  end

  posa=zeros(pa.ln,4);
  rid=1;
  ax_sz = [c_sz, r_sz] * 0.8;
  chid=1;
  for rid = 1: rnum
    for cid=1:cnum,
      posa(chid,:)=[cpos(cid), rpos(rid), ax_sz];
      chid=chid+1;
      if (chid>pa.ln) break; end
    end
  end
end

for idx=1:pa.ln,
  set(pa.handle(idx),'Position',posa(idx,:));
end
% Comment out!
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View range-slider
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
% Draw axesrange
%------------------------------------
function draw_slider_axesrange(hObject, handles) 
  % Copy axis ,FFTgraph->range-axes-area
  a=findobj(handles.figure1,'Type','axes');
  idx=strmatch('P1_3',get(a,'TAG')); 
  a=a(idx);
  range_xlim=get(a,'XLim');
  set(handles.axes_range, 'XLimMode', 'manual');
  set(handles.axes_range, 'XTick', get(a,'XTick'));
  set(handles.axes_range, 'XTickLabel', get(a,'XTickLabel'));
  set(handles.axes_range, 'YTick', [], 'YTickLabel', '');
 
  % Get position 
  pos=get(handles.axes_range, 'Position'); %position without edge
  
  % Set Position and XLim
  slider_pos=pos;
  edge_pos=pos(3)*0.02;
  slider_pos(1)=pos(1)-edge_pos;
  slider_pos(3)=pos(3)+2*edge_pos;
  width=0.08;  % fixed edge-width
  setappdata(handles.figure1, 'EDGE_WIDTH', width);
  
  % slider_area=range_area+edge
  set(handles.axes_range,'Position', slider_pos);
  e_xlim=diff(range_xlim)*0.02;
  edge_xlim(1)=range_xlim(1)-e_xlim; 
  edge_xlim(2)=range_xlim(2)+e_xlim; 
  set(handles.axes_range, 'XLim', edge_xlim, 'UserData', range_xlim);
  
  % Draw base
  xmin=min(range_xlim);xmax=max(range_xlim);
  x   = [xmin xmax xmax xmin xmin];
  y   = [0 0 1 1 0];
  basecol = [220/255 224/255 200/255];
  axes(handles.axes_range);
  hold on;
  p=axis;axis off;   
  handles.base_h  =fill(x,y,basecol, 'Parent', handles.axes_range);
  p(1:2)=edge_xlim;axis(p);
  set(handles.base_h,  'Visible', 'on');
  % Get pass-value
  if get(handles.edt_highpass, 'Enable') =='on',
    hp=str2num(get(handles.edt_highpass, 'String'));
  else
    hp=range_xlim(1);
  end
  if get(handles.edt_lowpass, 'Enable') =='on',
    lp=str2num(get(handles.edt_lowpass,  'String'));
  else
    lp=range_xlim(2);
  end
  % Draw edge
  x   = [hp lp lp hp hp];
  hpx = [hp-width hp hp           hp-width hp-width];
  lpx = [lp      lp+width lp+width lp lp];
  col = [192/255 195/255 152/255];
  edgecol=[0/255 64/255 64/255];
  axes(handles.axes_range);
  p=axis;
  handles.range_h   = fill(x,y,col, 'Parent', handles.axes_range);
  handles.hp_edge_h = fill(hpx,y,edgecol, 'Parent', handles.axes_range);  
  handles.lp_edge_h = fill(lpx,y,edgecol, 'Parent', handles.axes_range);
  p(1:2)=edge_xlim;axis(p);
  % Update handles
  guidata(hObject,handles);
  % Set Callback
  set(handles.range_h,  'Visible', 'on',...
                'LineStyle','none',...
                'UserData', [], ...
                'ButtonDown', ...
                ['FD_BandFilter_getArgument(', ...
                  '''xaxis_Down'', gcbo,[], guidata(gcbo));']);
  set(handles.hp_edge_h,  'Visible', 'on',...
                'LineStyle','none',...
                'Tag', 'hp_edge_h', ...
                'UserData', [], ...
                'ButtonDown', ...
                ['FD_BandFilter_getArgument(', ...
                  '''xaxis_edge_Down'', gcbo,[],guidata(gcbo));']);
  set(handles.lp_edge_h,  'Visible', 'on',...
                'LineStyle','none',...
                'Tag', 'lp_edge_h', ...
                'UserData', [], ...
                'ButtonDown', ...
                ['FD_BandFilter_getArgument(', ...
                  '''xaxis_edge_Down'', gcbo,[],guidata(gcbo));']);
  hold off;
return;

%------------------------------------
% Change axesrange-axis
%------------------------------------
function change_slider_axesrange(hObject, handles,flg)
% Modify Slider and aply FFT
%  if flg=false, no-fft
%  if no-flg,    asume flg is true.

% Default-Setting (flg : 
if nargin==2, flg=true; end
a=findobj(handles.figure1,'Type','axes');
idx=strmatch('P1_3',get(a,'TAG'));
a=a(idx);
xlim=get(a,'XLim');

e_xlim=diff(xlim)*0.02;
edge_xlim(1)=xlim(1)-e_xlim;
edge_xlim(2)=xlim(2)+e_xlim;
set(handles.axes_range, 'XLim', edge_xlim);
set(handles.axes_range, 'XTick', get(a,'XTick'));
set(handles.axes_range, 'XTickLabel', get(a,'XTickLabel'));
set(handles.axes_range, 'YTick', [], 'YTickLabel', '');
% Redraw base
xmin=min(xlim);xmax=max(xlim);
x   = [xmin xmax xmax xmin xmin];
set(handles.base_h,  'XData', x, 'Visible', 'on');
% Redraw edge
range_xlim=get(handles.axes_range, 'UserData');
e_width = getappdata(handles.figure1, 'EDGE_WIDTH');
e_width = e_width*diff(xlim)/diff(range_xlim);
xdata1  = get(handles.hp_edge_h, 'XData');
xdata2  = get(handles.lp_edge_h, 'XData');
if max(xdata1)<min(range_xlim), xdata1([2 3])=min(range_xlim);end
xdata1([1 4 5])=xdata1(2)-e_width;
set(handles.hp_edge_h, 'XData', xdata1);
if max(range_xlim)<min(xdata2), xdata2([1 4 5])=max(range_xlim);end
xdata2([2 3])=xdata2(1)+e_width;
set(handles.lp_edge_h, 'XData', xdata2);
% Update edit-pass
if flg
  update_edt_pass('hp_edge_h',[],handles);
  update_edt_pass('lp_edge_h',[],handles);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxis_Down(h, eventdata, handles)
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.hp_edge_h, 'Visible', 'off');
set(handles.lp_edge_h, 'Visible', 'off');
eh=get(handles.edt_highpass, 'Enable');
el=get(handles.edt_lowpass, 'Enable');
cbd.h  = h;
cbd.ah =get(h,'Parent');

cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1);
cbd.XData = get(cbd.h,'XData');

if strcmp(eh, 'on') && strcmp(el,'on'), 
  set(cbd.h,'FaceColor',[0.8, 0.9, 1]);
  set(gcbf,'WindowButtonMotionFcn', ...
        ['FD_BandFilter_getArgument(', ...
            '''xaxisMove_Callback'', gcbf,[],[]);']);

  setappdata(gcbf,'CallbackData',cbd);
  waitfor(gcbf,'WindowButtonMotionFcn', '');
  col = [192/255 195/255 152/255];
  set(cbd.h,'FaceColor',col);
  % Check edge
  xr=get(cbd.h, 'XData');
  xmin=min(xr);  % =high-pass
  xmax=max(xr);  % =low-pass
  range_xlim=get(handles.axes_range, 'UserData');
  w   = getappdata(handles.figure1, 'EDGE_WIDTH');
  w   = w*diff(xlim)/diff(range_xlim);
  if xmin<min(range_xlim), xmin=min(range_xlim);end
  if xmax>max(range_xlim), xmax=max(range_xlim);end
  set(handles.hp_edge_h, 'XData', [xmin-w xmin xmin xmin-w xmin-w], 'Visible', 'on');
  set(handles.lp_edge_h, 'XData', [xmax xmax+w xmax+w xmax xmax],   'Visible', 'on');
  %% Update edit-text
  update_edt_pass([],[],handles);
else
  set(handles.hp_edge_h, 'Visible', 'on');
  set(handles.lp_edge_h, 'Visible', 'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisMove_Callback(figh, eventdata, handles),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
xdata= cbd.XData + cp(1) - cbd.cp0;
% Check edge
range_xlim= get(cbd.ah, 'UserData');
if min(xdata)<min(range_xlim),
  xdata([1 4 5])= min(range_xlim);
end
if max(xdata)>max(range_xlim),
  xdata([2 3])=max(range_xlim);
end
set(cbd.h,'XData',xdata);
range=[min(xdata), max(xdata)];
% xaxisMove(cbd,range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisResize_Callback(figh, eventdata, handles),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
cbd.XData(cbd.id)=cp(1);
xdata=cbd.XData;
% Check edge
range_xlim= get(cbd.ah, 'UserData');
if min(xdata)<min(range_xlim),
  xdata([1 4 5])= min(range_xlim);
end
if max(xdata)>max(range_xlim),
  xdata([2 3])=max(range_xlim);
end
set(cbd.h,'XData', xdata);
range=[min(cbd.XData), max(cbd.XData)];
% xaxisMove(cbd,range)
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisMove(cbd,r)
% Move Real
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if r(2)==r(1),return;end
ud=get(cbd.ah,'UserData');
for idx=2:length(ud);
  axes(ud{idx}.axes);
  p=axis;
  p(1:2)=r(1:2);
  axis(p);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxis_edge_Down(h, eventdata, handles)
% Execute on 
% hp_edge_fill
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Callback-object
cbd.edge  = h;
cbd.ah    = get(h,'Parent');
cp0       = get(cbd.ah,'CurrentPoint');
cbd.cp0   = cp0(1);
cbd.tag   = get(cbd.edge, 'Tag');
cbd.XData = get(h,'XData');
cbd.range = handles.range_h;

if strcmp(cbd.tag, 'hp_edge_h'),
  if strcmp(get(handles.edt_highpass, 'Enable'), 'off'),return;end
  cbd.XData2=get(handles.lp_edge_h, 'XData');
else
  if strcmp(get(handles.edt_lowpass, 'Enable'), 'off'),return;end
  cbd.XData2=get(handles.hp_edge_h, 'XData');
end
set(gcbf,'WindowButtonMotionFcn', ...
        ['FD_BandFilter_getArgument(', ...
            '''xaxisMove_edge_Callback'', gcbf,[],[]);']);

setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');

%% Update Edt-text
update_edt_pass(cbd.tag, [], handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxisMove_edge_Callback(figh, eventdata, handles),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
tag  = cbd.tag;
xdata  = cbd.XData + cp(1) - cbd.cp0;
xdata2 = cbd.XData2;
% Check edge
range_xlim= get(cbd.ah, 'UserData');
if strcmp(tag, 'hp_edge_h'),
  if min(xdata2)<max(xdata),
    xdata=xdata-(max(xdata)-min(xdata2));
  end
  if max(xdata)<min(range_xlim),
    xdata=xdata+(min(range_xlim)-max(xdata));
  end
  xdata_r=[max(xdata) min(xdata2) min(xdata2) max(xdata) max(xdata)];
else
  if min(xdata)<max(xdata2),
    xdata=xdata+(max(xdata2)-min(xdata));
  end
  if max(range_xlim)<min(xdata),
    xdata=xdata-(min(xdata)-max(range_xlim));
  end
  xdata_r=[max(xdata2) min(xdata) min(xdata) max(xdata2) max(xdata2)];
end
% Set edge-data
set(cbd.edge,'XData',xdata);
% Set range-data
set(cbd.range,'XData',xdata_r);
range=[min(xdata), max(xdata)];
%xaxisMove(cbd,range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_edt_pass(tag, eventdata, handles),
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmp(tag, 'lp_edge_h'),
  xdata1=get(handles.hp_edge_h, 'XData'); 
  x1=max(xdata1);
  set(handles.edt_highpass, 'String', num2str(x1), 'UserData', x1);
  edt_highpass_Callback(handles.edt_highpass, eventdata, handles);
end
if ~strcmp(tag, 'hp_edge_h'),
  xdata2=get(handles.lp_edge_h, 'XData');
  x2=min(xdata2);
  set(handles.edt_lowpass, 'String', num2str(x2), 'UserData', x2);
  edt_lowpass_Callback(handles.edt_lowpass, eventdata, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_slider_pass(h, eventdata, handles)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pass    = str2num(get(h, 'String'));
xdata_r = get(handles.range_h, 'XData');
range   = get(handles.axes_range, 'XTick');
xlim    = get(handles.axes_range, 'XLim');

range_xlim=get(handles.axes_range, 'UserData');
w   = getappdata(handles.figure1, 'EDGE_WIDTH');
w   = w*diff(xlim)/diff(range_xlim);

if h == handles.edt_highpass,
  % Check another edge
  xdata2 = get(handles.lp_edge_h, 'XData');
  if pass>min(xdata2),pass=min(xdata2);end 
  if pass<min(range_xlim), pass=min(range_xlim);end 
  set(h, 'String', num2str(pass));
  xdata=[pass-w pass pass pass-w pass-w];
  set(handles.hp_edge_h, 'XData', xdata);
  % Check range-data
  %%ri=find(xdata_r == min(xdata_r));
  ri=[1 4 5];
end
if h == handles.edt_lowpass,
  % Check another edge
  xdata2 = get(handles.hp_edge_h, 'XData');
  if pass<max(xdata2),pass=max(xdata2);end
  if pass>max(range_xlim), pass=max(range_xlim);end 
  xdata=[pass pass+w pass+w pass pass];
  set(handles.lp_edge_h, 'XData', xdata);
  % Check range-data
  %ri=find(xdata_r == max(xdata_r));
  ri=[2 3];
end
% Set Data
set(h, 'String', num2str(pass));
if ~isempty(ri),
  xdata_r(ri)=pass;
  set(handles.range_h, 'XData', xdata_r);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lock_slider_pass(h, eventdata, handles),
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ft    = get(h,'String');
val   = get(h,'Value');
w   = getappdata(handles.figure1, 'EDGE_WIDTH');
range_xlim=get(handles.axes_range, 'UserData');
xlim      =get(handles.axes_range, 'XLim'); 
w   = w*diff(xlim)/diff(range_xlim);
 
xdata_r = get(handles.range_h, 'XData');
range   = get(handles.axes_range, 'XTick');

hdata=getappdata(handles.figure1, 'FHDATA');
lowlim = 1000/hdata.samplingperiod/length(hdata.stimTC);
highlim = 1000/hdata.samplingperiod/2;

if ft{val}(1) == 'L', % lock highpass 
  pass = lowlim;
  xdata=[pass-w pass pass pass-w pass-w];
  set(handles.hp_edge_h, 'XData', xdata);
  xdata_r([1 4 5])=pass;
  set(handles.range_h, 'XData', xdata_r);
  set(handles.edt_highpass, 'String', num2str(pass), 'UserData', pass);
end
if ft{val}(1) == 'H', % lock lowpass
  pass = highlim;
  xdata=[pass pass+w pass+w pass pass];
  set(handles.lp_edge_h, 'XData', xdata);
  xdata_r([2 3])=pass;
  set(handles.range_h, 'XData', xdata_r);
  set(handles.edt_lowpass, 'String', num2str(pass), 'UserData', pass);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis Property
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------
% Set Position
% -------------------------------------------
function draw_xaxis(handles)
pos=get(handles.txt_axis, 'Position');
pos(2)=0.278;
set(handles.txt_axis,'Position',pos);

pos=get(handles.edt_axis_min, 'Position');
pos(2)=0.3;pos(4)=0.033;
set(handles.edt_axis_min,'Position',pos);

pos=get(handles.edt_axis_max, 'Position');
pos(2)=0.3;pos(4)=0.033;
set(handles.edt_axis_max,'Position',pos);

try
  set(handles.edt_axis_min,'KeyPressFcn', ...
                   ['FD_BandFilter_getArgument(', ...
                    '''press_edt_axisMin'',gcbf,[],guidata(gcbf));']);
  set(handles.edt_axis_max,'KeyPressFcn',...
                   ['FD_BandFilter_getArgument(', ...
                    '''press_edt_axisMax'',gcbf,[],guidata(gcbf));']);
catch
  warning('Coud not set KeyPressFunction, for this MATLAB-version.');
end
                
pos=[0.185 0.316 0.025 0.017];
set(handles.psb_axisMin_pl,'Position',pos);

pos=[0.185 0.299 0.025 0.017];
set(handles.psb_axisMin_ms,'Position',pos);

pos=[0.323 0.316 0.025 0.017];
set(handles.psb_axisMax_pl,'Position',pos);

pos=[0.323 0.299 0.025 0.017];
set(handles.psb_axisMax_ms,'Position',pos);

% Get from FFTgraph
a=findobj(handles.figure1,'Type','axes');
idx=strmatch('P1_3',get(a,'TAG')); 
a=a(idx);
xtick=get(a,'XTick');
if length(xtick)>2,
  shift=xtick(2)-xtick(1);
  set(handles.edt_axis_min, 'String', num2str(xtick(1)), ...
                            'UserData', xtick(1), ...
                            'Visible', 'on');
  set(handles.edt_axis_max, 'String', num2str(xtick(end)+shift), ...
                            'UserData', xtick(end)+shift, ...
                            'Visible','on');
  set(handles.txt_axis, 'Visible', 'on');
  %shift=shift/2;
  shift=round(shift*10)/10;
  set(handles.psb_axisMin_ms, 'UserData', shift, 'Visible', 'on');
  set(handles.psb_axisMin_pl, 'UserData', shift, 'Visible', 'on');
  set(handles.psb_axisMax_ms, 'UserData', shift, 'Visible', 'on');
  set(handles.psb_axisMax_pl, 'UserData', shift, 'Visible', 'on');
  set(handles.edt_fft_axis_temp, 'Visible', 'off', 'Enable', 'off');
end

% -------------------------------------------
% axis callback
% -------------------------------------------
function edt_axis_min_Callback(hObject, eventdata, handles) %#ok
% Change Result-AXIS for MIN
% Get Editor Value
pv=get(hObject, 'UserData'); % Previous Value
if isempty(pv),pv=0;end
try
  amin = str2double(get(hObject, 'String'));
catch
  amin = pv;
end
if isempty(amin),amin=pv;end
% Modify by : Limits
if isempty(amin),amin=0;end
amax = get(handles.edt_axis_max, 'UserData');
if isempty(amax),amax=5;end
if amin<0,  amin=0;end
if amin>=amax, amin=pv;end
% Update Values
set(hObject, 'String', num2str(amin));
set(hObject,'UserData', amin);
change_axis([amin amax], handles);

function edt_axis_max_Callback(hObject, eventdata, handles) %#ok
% Change Result-AXIS for MAX
pv=get(hObject, 'UserData'); % Previous Value
if isempty(pv),pv=5;end
try
  amax = str2double(get(hObject, 'String'));
catch
  amax=pv;
end
if isempty(amax), amax=pv;end
% Modify by : Limits
amin = get(handles.edt_axis_min, 'UserData');
if isempty(amin),amin=0;end
%if amax>5,          amax=5;  end
if amax<=amin,      amax=pv; end
% Update Values
set(hObject, 'String', num2str(amax));
set(hObject, 'UserData', amax);
change_axis([amin amax], handles);

function psb_axisMin_pl_Callback(hObject, ev, handles)
amin = get(handles.edt_axis_min, 'UserData');
if isempty(amin), amin=0;end
shift= get(hObject, 'UserData');
set(handles.edt_axis_min, 'String', round((amin+shift)*10)/10);
edt_axis_min_Callback(handles.edt_axis_min, ev, handles);

function psb_axisMin_ms_Callback(hObject, ev, handles)
amin = get(handles.edt_axis_min, 'UserData');
if isempty(amin), amin=0;end
shift= get(hObject, 'UserData');
set(handles.edt_axis_min, 'UserData', amin);
set(handles.edt_axis_min, 'String', round((amin-shift)*10)/10);
edt_axis_min_Callback(handles.edt_axis_min, ev, handles);

function psb_axisMax_pl_Callback(hObject, ev, handles)
amax = get(handles.edt_axis_max, 'UserData');
if isempty(amax),amax=5;end
shift= get(hObject, 'UserData');
set(handles.edt_axis_max, 'String', round((amax+shift)*10)/10);
edt_axis_max_Callback(handles.edt_axis_max, ev, handles);

function psb_axisMax_ms_Callback(hObject, ev, handles)
amax = get(handles.edt_axis_max, 'UserData');
if isempty(amax),amax=5;end
shift= get(hObject, 'UserData');
set(handles.edt_axis_max, 'String', round((amax-shift)*10)/10);
edt_axis_max_Callback(handles.edt_axis_max, ev, handles);

function press_edt_axisMin(hObject, eventdata, handles) %ok
try  
  currentkey=get(hObject,'CurrentKey');
  switch lower(currentkey),
    case 'uparrow',
      psb_axisMin_pl_Callback(handles.psb_axisMin_pl, eventdata, handles);
    case 'downarrow',
      psb_axisMin_ms_Callback(handles.psb_axisMin_ms, eventdata, handles);
    otherwise,
      %disp(lower(currentkey));
  end
catch
  disp('error');
end
 
function press_edt_axisMax(hObject, eventdata, handles) %ok
persistent isbusy;
if isempty(isbusy),isbusy=false;end
if isbusy,return;end
isbusy=true;
try
  currentkey=get(hObject,'CurrentKey');
  switch lower(currentkey),
    case 'uparrow',
      psb_axisMax_pl_Callback(handles.psb_axisMax_pl, eventdata, handles);
    case 'downarrow',
      psb_axisMax_ms_Callback(handles.psb_axisMax_ms, eventdata, handles);
    otherwise,
      %disp(lower(currentkey));
  end
catch
  disp('error');
end
isbusy=false;

%------------------------------------
function edt_fft_axis_temp_Callback(hObject, eventdata, handles)
% Modify X-AXis of FFT
% temporary callback
%------------------------------------
ax=str2num(get(hObject, 'String'));
% Reset axis to FFT graph
a=findobj(handles.figure1,'Type','axes');
idx3=strmatch('P1_3',get(a,'TAG')); 
idx4=strmatch('P1_4',get(a,'TAG')); 
set(a(idx3), 'XLim', ax);
set(a(idx4), 'XLim', ax);
% Change axis of axes_range 
 change_slider_axesrange(handles.axes_range, handles);

%------------------------------------
function change_axis(ax, handles)
%------------------------------------
% Reset axis to FFT graph
a=findobj(handles.figure1,'Type','axes');
idx3=strmatch('P1_3',get(a,'TAG')); 
idx4=strmatch('P1_4',get(a,'TAG')); 
set(a(idx3), 'XLim', ax);
set(a(idx4), 'XLim', ax);
% Change axis of axes_range 
change_slider_axesrange(handles.axes_range, handles,false);
