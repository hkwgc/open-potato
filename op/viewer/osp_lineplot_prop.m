function varargout = osp_lineplot_prop(varargin)
% Launch Sinple Line Plot Property Setting GUI.
% OSP_LINEPLOT_PROP M-file for osp_lineplot_prop.fig
%  OSP_LINEPLOT_PROP by itself, creates a new OSP_LINEPLOT_PROP or raises the
%  existing singleton*.
%  OSP_LINEPLOT_PROP Manage LinePropertty Data.
%
%  H = OSP_LINEPLOT_PROP returns the handle to a new OSP_LINEPLOT_PROP or the handle to
%  the existing singleton*.
%
%  OSP_LINEPLOT_PROP('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in OSP_LINEPLOT_PROP.M with the given input arguments.
% ========================================================
% prop=osp_lineplot_prop('getAll',hObject,[],handles);
%   get Line Property of axis, title pattern.
%   Input arguments
%     hObject : Upper Object of this GUI
%     handles : this guihandles
%   Return value 
%    prop    : structure
%      prop.fname : title pattern
%      prop.xax   : X axis [min, max]
%      prop.yax   : Y  axis [min, max]
%    if filed is empty, use default.
% ------------------------------------------------------
% osp_lineplot('setUpperGUI',upperObject,[],gui_handle);
%   set Upper GUI Handele.
%   Input arguments.
%    Upper Object : Upper Object of this GUI
%    handles      : this guihandles
% ------------------------------------------------------
% osp_lineplot('setTitleAvailableData',hObject,[],gui_handle,);
%   set Title Pattern Available Data.
%   Input arguments.
%    Upper Object : Upper Object of this GUI
%    handles      : this guihandles
% ========================================================
%
%      OSP_LINEPLOT_PROP('Property','Value',...) creates a new OSP_LINEPLOT_PROP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before osp_lineplot_prop_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to osp_lineplot_prop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help osp_lineplot_prop

% Last Modified by GUIDE v2.5 24-Oct-2005 18:35:45

% Begin initialization code - DO NOT EDIT


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.05.23
% $Id: osp_lineplot_prop.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.1
%   New: with uiwait
%
% Reversion 1.2
%   1, Figure, with getter
%   2, earch data have a checkbox

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @osp_lineplot_prop_OpeningFcn, ...
                   'gui_OutputFcn',  @osp_lineplot_prop_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%=====================================
%   GUI Control functions
%=====================================

function osp_lineplot_prop_OpeningFcn(hObject, eventdata, handles, varargin)
% OSP-Line-Plot-Property Opening Function.
%   Uiwait Code is removed since 1.2. 
%   This is normal function.
%
% Choose default command line output for osp_lineplot_prop
  if 1
    handles.output = hObject;
  else
    handles.output = [];
  end
  guidata(hObject, handles);
  set(hObject,'Color',[1 1 1]);

  % Set Properties.
  % -- here can comment out --
  % now we have getter
  if(nargin > 3)
    for index = 1:2:(nargin-3),
      if nargin-3==index break, end
      switch lower(varargin{index})
       case 'prop'
	prop= varargin{index+1};
	if isempty(prop), continue; end
	set(handles.edt_xmin,'String', num2str(prop.ax(1)));
	set(handles.edt_xmax,'String', num2str(prop.ax(2)));
	set(handles.edt_ymin,'String', num2str(prop.ax(3)));
	set(handles.edt_ymax,'String', num2str(prop.ax(4)));
	set(handles.edt_TitlePattern,'String',prop.fname);
       case 'data'
	data = varargin{index+1};
	if isempty(data), continue; end
	setappdata(hObject,'data',data);
       otherwise,
	errordlg(['Not proper Property : ' varargin{index}]);
      end
    end
  end

  if 1
    set(handles.figure1,'KeyPressFcn',[]);
  else
    % UIWAIT makes osp_lineplot_prop wait for user response (see UIRESUME)
    uiwait(handles.figure1);
  end

return;

function varargout = osp_lineplot_prop_OutputFcn(hObject, eventdata, handles)
% Return Value Setting.
  varargout{1} = handles.output;
  if 0
    % comment out @since 1.2
    % when uiwait, 
    %   Openingfcn -> (wait responce) -> output & delete
    delete(handles.figure1);
  end
return;

function figure1_KeyPressFcn(hObject, eventdata, handles)
% in uiwait, set this function effective.
% Default is null in OpeningFcn,
%  -> set(handles.figure1,'KeyPresFcn',[]);
  if isequal(get(hObject,'CurrentKey'),'escape')
    handles.output = [];
    guidata(hObject, handles);
    uiresume(handles.figure1);
  end    
  
  if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
  end    

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close
  if 1
    delete(handles.figure1);
  else
    % in uiwait
    if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
      uiresume(handles.figure1);
    else
      delete(handles.figure1);
    end
  end

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete function
  try
    upperObject = getappdata(hObject,'UpperGUI'); 
    if ishandle(upperObject),
      setappdata(upperObject,'LinePlotProperty',[]);
    end
  end
return;

%=====================================
%   Edit Check
%=====================================

function edt_number_CB(hObject, eventdata, handles)
% Confine Input number is Single Numerical-Value.
% Callback Function of Edit Max, Min.
  s=get(hObject,'String'); 
  if iscell(s), s=s{1}; end
  flg=0;
  try
    is = str2num(s);
  catch
    flg=1;
  end
  if flg 
    errordlg(lasterr); return;
  elseif length(is)~=1,
    errordlg('Input One Data'); return;
  end
  set(hObject,'String',num2str(s));

return;

%=====================================
%  Title Pattern Functions
%=====================================
function edt_TitlePattern_Callback(hObject, eventdata, handles)
% Callback function of Edit Title Pattern.
%   If there is check or reset.

function psb_fn_Callback(hObject, eventdata, handles)
%  Display Variable available in Edit-Title Pattern.

  data = getappdata(handles.figure1,'data');
  if isempty(data),
    % if no data selected
    disp('--- No Data Selected --'); return;
  end

  disp('--------')
  disp(data);
  nms=fieldnames(data.data);
  disp('- data ')
  disp([repmat(' ',size(nms,1),6) char(nms)]);
  disp('--------')

%=====================================
%   UIWAIT Return Value Setting
%                        (not in use)
%=====================================

function psb_yes_Callback(hObject, eventdata, handles)
% User only in uiwait, not use
% Set Return Value Propertty
  prop.ax = [str2num(get(handles.edt_xmin,'String')) , ...
	     str2num(get(handles.edt_xmax,'String')) , ...
	     str2num(get(handles.edt_ymin,'String')) , ...
	     str2num(get(handles.edt_ymax,'String'))];
  prop.fname = get(handles.edt_TitlePattern,'String');

  % Set handles structure
  handles.output = prop;
  guidata(hObject, handles);

  % exit
  uiresume(handles.figure1);

function psb_no_Callback(hObject, eventdata, handles)
% User only in uiwait, not use
% Set Return Value null.
  handles.output = [];       % no data 
  guidata(hObject, handles); % select
  uiresume(handles.figure1);
return;

%=====================================
%   Getter
%=====================================
function prop=getAll(hObject,eventdata,handles),
% prop=osp_lineplot_prop('getAll',hObject,[],handles);
%   get Line Property of axis, title pattern.
% 
%   hObject : Upper Object of this GUI
%   handles : this guihandles

  % Title
  tmp = getFname(handles);
  if ~isempty(tmp),
    prop.TitleFig = tmp;
  end

  % Axes title
  if 1==get(handles.pop_AXES_TITLE,'Value'),
    prop.AXES_TITLE = 'on';
  end

  tmp = getAxesFontSize(handles);
  if ~isempty(tmp),
    prop.AxesFontSize=tmp;
  end

  % Axis
  tmp = getXaxis(handles);
  if ~isempty(tmp),
    prop.X_AXIS   = tmp;
  end

  tmp = getYaxis(handles);
  if ~isempty(tmp),
    prop.Y_AXIS   = tmp;
  end

  % Channel Distribution
  mode=getChannelDistribution(handles);
  if ~isempty(mode),
    prop.ChannelDistribution=mode;
  end
  % Multi Probe ID
  id = getMultiProbeMode(handles);
  if ~isempty(id),
    prop.PlotChannel=id;
  end

  % Error Plot
  try,
    [mode, val] = getErrorMode(handles);
    prop=setfield(prop,mode,val);
  catch,
    warning(lasterr);
  end

  tmp = getAreaColor(handles);
  if ~isempty(tmp),
    prop.AreaColor = tmp;
  end
	      
return;

function fname = getFname(handles),
% get Figure Title Pattern, if empty
  if get(handles.cbx_title,'Value'),
    fname = get(handles.edt_TitlePattern,'String');
  else
    fname = [];
  end
return;

function fs = getAxesFontSize(handles),
  if get(handles.cbx_AxesFontSize,'Value'),
    st=get(handles.pop_AxesFontSize,'String');
    fs = str2num(st{get(handles.pop_AxesFontSize,'Value')});
  else,
    fs=[];
  end
return;

function xax   = getXaxis(handles),
% get X axis Limit -> if no data empty.
  if get(handles.cbx_xaxis,'Value'),
    xax = [str2num(get(handles.edt_xmin,'String')) , ...
	   str2num(get(handles.edt_xmax,'String'))];
  else
    xax = [];
  end
return;
function yax   = getYaxis(handles),
% get Y axis Limit -> if no data empty.
  if get(handles.cbx_yaxis,'Value'),
    yax = [str2num(get(handles.edt_ymin,'String')) , ...
	   str2num(get(handles.edt_ymax,'String'))];
  else
    yax = [];
  end
return;

function mode=getChannelDistribution(handles)
  id = get(handles.pop_CD,'Value');
  st = get(handles.pop_CD,'String');
  switch id,
   case 1,
    mode='';
   case 2,
    mode='Square';
   case 3,
    mode='2Colums';
   otherwise,
    warning('Undefined Channel distribution');
    mode='';
  end
return;

function id = getMultiProbeMode(handles),
id =get(handles.edit_PlotChannel, 'UserData');
if iscell(id),
	id=[id{:}];
end

return;
    

function [mode, val] = getErrorMode(handles),
  id = get(handles.pop_ErrorPlot,'Value');
  st = get(handles.pop_ErrorPlot,'String');
  st = st{id};
  switch st,
   case 'Error on',
    mode= 'ErrorPLOT';
    val = 'on';
   case 'Error off',
    mode= 'ErrorPLOT';
    val = 'off';
   case 'area';
    mode= 'STIMPLOT';
    val = 'area';
   case 'every block',
    mode= 'No_MEAN';
    val = 'on';
   otherwise,
    error(sprintf(['<< OSP Error!!! >>\n' ...
		   '<< in Popupmenu Erro-Plot-Mode : >>\n' ...
		   '<<       No Match Mode %s'],st));
  end
return;
% Error plot
function ac = getAreaColor(handles),
  vb = get(handles.frame_AreaColor,'Visible');  
  if strcmpi(vb,'off'), ac=[]; return; end

  ac = get(handles.frame_AreaColor,'BackgroundColor');
return;



%=====================================
%   Setter
%=====================================
function setUpperGUI(upperObject,eventdata,handles),
% set Upper GUI Handele
%   osp_lineplot('setUpperGUI',upperObject,[],gui_handle);
%   Upper Object : Upper Object of this GUI
%   handles      : this guihandles
% See also figure1_DeleteFcn
  setappdata(handles.figure1,'UpperGUI', upperObject); 
return;

function setTitleAvailableData(hObject,eventdata,handles,data),
% osp_lineplot('setTitleAvailableData',hObject,[],handles,data);
%   set Title Pattern Available Data
%   hObject : Upper Object of this GUI
%   handles : this guihandles
  setappdata(hObject,'data',data);
  % since reversion 1.4
  try,
    fcn=func2str(data.fcn);
    e_h = [handles.frame_ErrorPlot, ...
	   handles.frame_AreaColor, ...
	   handles.psb_AreaColor, ...
	   handles.pop_ErrorPlot, ...
	   handles.txt_ErrorPlot];
    switch lower(fcn),
     case 'datadef_groupdata',
      set(e_h,'Visible','on');
      pop_ErrorPlot_Callback(handles.pop_ErrorPlot, [], handles);
     otherwise,
      set(e_h,'Visible','off');
    end
  catch,
    if 0,
      disp(lasterr);
    end
    errordlg({'Please Select Correct Data (to view) at first!',lasterr});
    return;
  end

  % Pop Channel Distribution 
  %set(handles.pop_CD,'Value',1);
  %set(handles.pop_CD,'String',{''});

  % MultiProbe Mode
  key.actdata=data;key.filterManage=[];key.dumy=[];
  [d,hdata]=feval(data.fcn,'make_ucdata',key);
  chdata = {[1:size(d,ndims(d)-1)]};
  d=[];
  st ={'All Probe'};
  if isfield(hdata,'Pos'),
      id = get(handles.pop_MPM,'Value');

      len= length(hdata.Pos.Group.ChData);
      for idx=1:len,
          st{end+1}=['Probe ' num2str(idx)];
      end
      if id>(len+1), id=len+1; end
	  chdata = hdata.Pos.Group.ChData;
  else,
      id=1;
  end
  set(handles.pop_MPM,...
      'Value',id, ...
	  'UserData', chdata, ...
      'String', st);
  pop_MPM_Callback(handles.pop_MPM,[],handles);
return;

%=====================================
% Error Plot Controle
%=====================================

function psb_AreaColor_Callback(hObject, eventdata, handles)
c=get(handles.frame_AreaColor,'BackgroundColor');
c=uisetcolor(c);
if length(c)==3,
    set(handles.frame_AreaColor,'BackgroundColor',c);
end
  
function pop_ErrorPlot_Callback(hObject, eventdata, handles)
e_h = [handles.frame_AreaColor, ...
        handles.psb_AreaColor];
val = get(hObject,'Value');
if val==3,
    set(e_h,'Visible','on');
else,
    set(e_h,'Visible','off');
end
return;



function edit_PlotChannel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PlotChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PlotChannel as text
%        str2double(get(hObject,'String')) returns contents of edit_PlotChannel as a double
try,
	st = get(hObject,'String');
	chid=eval(st);
	set(hObject,'UserData', chid);
catch,
	errordlg(lasterr);
	set(hObject,'Color',[1, 0, 0]);
end



% --- Executes on selection change in pop_MPM.
function pop_MPM_Callback(hObject, eventdata, handles)
chdata = get(hObject,'UserData');
val    = get(hObject,'Value');

if (val==1),
	st=['{'];
	for idx=1:length(chdata),
		st=[st, ' [' num2str(chdata{idx}) '],'];
	end
	st(end)='}';
	set(handles.edit_PlotChannel, ...
		'String', st, ...
		'UserData', chdata);
else,
	set(handles.edit_PlotChannel, ...
		'String', num2str(chdata{val-1}), ...
		'UserData',chdata{val-1});
end
return;


