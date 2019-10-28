function varargout = PluginGui_base(varargin)
% PluginGui_base M-file for PluginGui_base.fig
%
%      H = PluginGui_base returns the handle to a new PluginGui_base or the handle to
%      the existing singleton*.
%
%      If you want to chaneg Using Data or Start up PluginGui_base, 
%      set value that used in PluginAnalysis_base. To Set Value 
%      PluginGui_base('SetValue',hObject,[],handles, ...
%              BlockData, BlockKind, HBkindTag, ...
%              Astimtimes, Unit, MeasureMode);
%      Those Value can get by using getappdata.
%
%      PluginGui_base('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PluginGui_base.M with the given input arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Reversion :1.00

if (nargin==1),
  strcmp('createBasicInfo',varargin{1});
  varargout{1}='Display Name';
  if nargout==1, return;  end
  varargout{2}='Type Number';      % Type of S
  if nargout==2, return;  end

  return;
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PluginGui_base_OpeningFcn, ...
                   'gui_OutputFcn',  @PluginGui_base_OutputFcn, ...
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GUI Control functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PluginGui_base_OpeningFcn(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Open Figure with No Data.
%  Data must set by calling Callback 'SetValue'
%----------------------------------------------------------------
  handles.output = hObject;
  set(hObject,'Color',[1 1 1]);
  guidata(hObject, handles);
return;

function varargout = PluginGui_base_OutputFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Output is handle of uiTttest
%----------------------------------------------------------------
  varargout{1} = handles.output;
return;

function figure1_KeyPressFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Common Keybind Setting
%----------------------------------------------------------------
  osp_KeyBind(hObject,[],handles,mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Data Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetValue(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Init Function : Set Apprication Value
%   This Function Input must be common in Statistic Analysis GUI
%----------------------------------------------------------------

  if 0,
	  % OSP version 1.00
	  h= handles.figure1;
	  argName={'BlockData', ...
			  'BlockKind', ...
			  'HBkindTag', ...
			  'Astimtimes', ...
			  'Unit', ...
			  'MeasureMode'};
	  argID_BlockDaota   = 1;
	  argID_BlockKind   = 2;
	  argID_HBkindTag   = 3;
	  argID_Astimtimes  = 4;
	  argID_Unit        = 5;
	  argID_MeasureMode = 6;
	  
	  
	  % -- Set Apprication Data --
	  % use max, to detect error 
	  for vid = 1: max( (nargin-3), length(argName)),  
		  setappdata(h, argName{vid},varargin{vid});
	  end
	  
	  %===  Initial Value Setting ===
	  
	  % -- Block Data --
	  sz=size(varargin{argID_BlockData});
	  set(handles.text_bknum, 'String', num2str(sz(1)));
	  set(handles.text_chnum, 'String', num2str(sz(3)));
	  set(handles.text_hbnum, 'String', num2str(sz(4)));
	  
	  % -- Stimtime --
	  astimtimes = varargin{argID_Astimtimes};
	  astimtime  = astimtimes(1); clear astimtimes;
	  
	  % unit translate
	  unit      = varargin{argID_Unit};
	  start_p   = -(astimtime.iniStim  -1)/unit;
	  setappdata(h, 'StartIndexTime',start_p);
	  
	  astimtime.iniBlock = start_p+(astimtime.iniBlock -1)/unit;
	  astimtime.iniStim  = start_p+(astimtime.iniStim  -1)/unit;
	  astimtime.finStim  = start_p+(astimtime.finStim  -1)/unit;
	  astimtime.finBlock = start_p+(astimtime.finBlock -1)/unit;
	  
	  set(handles.text_iniBlock, 'String', num2str(astimtime.iniBlock));
	  set(handles.text_iniStim,  'String', num2str(astimtime.iniStim));
	  set(handles.text_finStim,  'String', num2str(astimtime.finStim));
	  set(handles.text_finBlock, 'String', num2str(astimtime.finBlock));
	  
	  % Area
	  set(handles.edit_area1st, 'String', num2str(astimtime.iniBlock));
	  set(handles.edit_area1ed, 'String', num2str(astimtime.iniStim));
	  
	  p2start = astimtime.iniStim + 5;
	  if (p2start > astimtime.finStim), p2start = astimtime.finStim; end
	  p2end   = p2start           + 5;
	  if (p2end > astimtime.finBlock), p2end = astimtime.finBlock; end
	  set(handles.edit_area2st, 'String', num2str(p2start));
	  set(handles.edit_area2ed, 'String', num2str(p2end));
  else, 
	  % since OSP version 1.10 
	  h= handles.figure1;
	  msg=nargchk(5,5,nargin);
	  if ~isempty(msg), error(msg); end;
	  
	  data  = varargin{1};
	  hdata = varargin{2}; 
	  clear varargin;
	  setappdata(h, 'BlockData', data);;
	  setappdata(h, 'Header', hdata); % for time_axes_positionCell
	  try,
		  setappdata(h,'HBkindTag', hdata.TAGs.DataTag);
	  end

	  try,
		  setappdata(h,'MeasureMode', hdata.measuremode);
	  end
	  %===  Initial Value Setting ===
	  
	  % -- Block Data --
	  sz=size(data);
	  set(handles.text_bknum, 'String', num2str(sz(1)));
	  set(handles.text_chnum, 'String', num2str(sz(3)));
	  set(handles.text_hbnum, 'String', num2str(sz(4)));
	  
	  % Stimulation timing in Block-Data-Time-cordinate
	  asimtime.iniBlock =  0;
	  astimtime.iniStim  = hdata.stim(1);
	  astimtime.finStim  = hdata.stim(2);
	  astimtime.finBlock = sz(2);
	  setappdata(h,'Astimtimes', astimtime);
	  
	  % unit transrate
	  unit      = 1000/hdata.samplingperiod;
	  setappdata(h,'Unit', unit);
	  
	  start_p   = -(hdata.stim(1)  -1)/unit;
	  setappdata(h, 'StartIndexTime',start_p);
	  
	  astimtime.iniBlock = start_p;
	  astimtime.iniStim  = 0;
	  astimtime.finStim  = start_p+(hdata.stim(2)  -1)/unit;
	  astimtime.finBlock = start_p+(sz(2) -1)/unit;
	  
	  set(handles.text_iniBlock, 'String', num2str(astimtime.iniBlock));
	  set(handles.text_iniStim,  'String', num2str(astimtime.iniStim));
	  set(handles.text_finStim,  'String', num2str(astimtime.finStim));
	  set(handles.text_finBlock, 'String', num2str(astimtime.finBlock));
	  
	  % Area
	  set(handles.edit_area1st, 'String', num2str(astimtime.iniBlock));
	  set(handles.edit_area1ed, 'String', num2str(astimtime.iniStim));
	  
	  p2start = astimtime.iniStim + 5;
	  if (p2start > astimtime.finStim), p2start = astimtime.finStim; end
	  p2end   = p2start           + 5;
	  if (p2end > astimtime.finBlock), p2end = astimtime.finBlock; end
	  set(handles.edit_area2st, 'String', num2str(p2start));
	  set(handles.edit_area2ed, 'String', num2str(p2end));

  end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Block Area Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = area_check(hObject,handles)
%----------------------------------------------------------------
%  Check Area Start-Value 
%----------------------------------------------------------------
  
  % Data Change
  val = get(hObject, 'String'); val = str2num(val);
  if isempty(val)
    warndlg('Set a Numerical value'); val = 1;
  end

  % get Area
  mn = str2num(get(handles.text_iniBlock, 'String'));
  mx = str2num(get(handles.text_finBlock, 'String'));

  % range check
  if val < mn, 
    %warndlg('Set Value in a Block');
	val = mn;
    set(hObject,'ForegroundColor','red');
  elseif val > mx,
    %warndlg('Set Value in a Block');
	val = mx;
    set(hObject,'ForegroundColor','red');
  else
    set(hObject,'ForegroundColor','black');
  end

  % Renew
  set(hObject,'String',num2str(val));
return;  
  
function st = edit_area1st_Callback(hObject, eventdata, handles)
% Check Setting Data.
% To remove this useless functions, Change GUI Callback setting
  st = area_check(hObject, handles);
function ed = edit_area1ed_Callback(hObject, eventdata, handles)
  ed = area_check(hObject, handles);
function st = edit_area2st_Callback(hObject, eventdata, handles)
  st = area_check(hObject,handles);
function ed = edit_area2ed_Callback(hObject, eventdata, handles)
  ed = area_check(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Peak Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ckb_peaksearch_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
% Peack Search  Enable / Disable
%----------------------------------------------------------------
  hs = [handles.edit_peaksearch1, ...
        handles.edit_peaksearch2, ...
        handles.psb_peaksearch, ...
        handles.pop_psearch];
  if get(hObject,'Value')
    ev='on';
  else
    ev='off';
  end

  set(hs,'Enable',ev);
return;

function area=getArea(handles)
%----------------------------------------------------------------
%  Get Peak Search Original Area 
%----------------------------------------------------------------
  val = get(handles.pop_psearch,'Value');
  st_h = eval(['handles.edit_area' num2str(val) 'st']);
  ed_h = eval(['handles.edit_area' num2str(val) 'ed']);
  st = area_check(st_h, handles);
  ed = area_check(ed_h, handles);
  try
    area = [st ed];
  catch
    error(' Not Proper Area, Cannot Set Peak Search Value');
  end
return;

function val = edit_peaksearchCheck(hObject, handles)
%----------------------------------------------------------------
%  Get Peak Search Original Area 
%----------------------------------------------------------------

  area=getArea(handles);

  % Data Change
  val = get(hObject, 'String'); val = str2num(val);
  if isempty(val)
    warndlg('Set a Numerical value'); val = 0;
  end

  % get Area
  mx = str2num(get(handles.text_finBlock, 'String'));

  mn  = getappdata(handles.figure1, 'StartIndexTime');
  % range check
  if (area(1) + val) < mn,
    warndlg('Ignore Under Flow Region'); val = mn-area(1);
    set(hObject,'ForegroundColor','red');
  elseif (area(2) + val) > mx,
    warndlg('Ignor Over Flow Region'); val = mx - area(2);
    set(hObject,'ForegroundColor','red');
  else
    set(hObject,'ForegroundColor','black');	  
  end

  % Renew
  set(hObject,'String',num2str(val));
return;

function val=edit_peaksearch1_Callback(hObject, eventdata, handles)
% Check Setting Data.
% To remove this useless functions, Change GUI Callback setting
  val = edit_peaksearchCheck(hObject, handles);
return;
function val=edit_peaksearch2_Callback(hObject, eventdata, handles)
  val = edit_peaksearchCheck(hObject, handles);
return;

function psb_peaksearch_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Peak Search Exe
%----------------------------------------------------------------
  f_h = handles.figure1;

  block    = getappdata(f_h, 'BlockData');
  area     = getArea(handles);
  sarea(1) = edit_peaksearch1_Callback(handles.edit_peaksearch1, [], handles);
  sarea(2) = edit_peaksearch1_Callback(handles.edit_peaksearch2, [], handles);
  tag      = getappdata(f_h, 'HBkindTag');
  
  % unit change
  area  = unit2index(f_h, area);
  sarea = unit2index(f_h, sarea,'no_shift');

  unit     = getappdata(f_h,'Unit');
  start_p  = getappdata(f_h, 'StartIndexTime');
  
  osp_peaksearch(block, area, sarea, tag, [1/unit, start_p]);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Test ( T-Test or Rank-Sum Test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, tmode] = testexe(handles)
%----------------------------------------------------------------
% T Test Execute
%----------------------------------------------------------------

  f_h = handles.figure1;
  block    = getappdata(f_h, 'BlockData');

  % Make Test Data
  val(1) = area_check(handles.edit_area1st,handles);
  val(2) = area_check(handles.edit_area1ed,handles);
  val    = unit2index(f_h, val);
  data1 = block(:,val(1):val(2),:,:);
  
  val(1) = area_check(handles.edit_area2st,handles);
  val(2) = area_check(handles.edit_area2ed,handles);
  val    = unit2index(f_h, val);
  data2 = block(:,val(1):val(2),:,:);

  % -- Peak Search --
  if get(handles.ckb_peaksearch,'Value')
    area     = getArea(handles);
    sarea(1) = edit_peaksearch1_Callback(handles.edit_peaksearch1, [], handles);
    sarea(2) = edit_peaksearch1_Callback(handles.edit_peaksearch2, [], handles);
	% unit change
	area  = unit2index(f_h, area);
	sarea = unit2index(f_h, sarea);

    datatmp  = osp_peaksearch(block, area, sarea);

    % Old one is execute only val==2
    % ?? fix is better?
    val = get(handles.pop_psearch,'Value');
    if val==1
      data1=datatmp;
    else
      data2=datatmp;
    end
    clear datatmp;
  end

  t_threshold = edit_threshold_Callback(handles.edit_threshold, [], handles);
  % -- Test --
  if get(handles.radio_Ttest,'Value'),

    % ---- t - test ----
    tmode = 'T - Test';
    data1 = nan_fcn('mean', data1,2);
    sz=size(data1); sz(2)=[]; data1=reshape(data1,sz);
    data2 = nan_fcn('mean', data2,2);
    sz=size(data2); sz(2)=[]; data2=reshape(data2,sz);
    for ch = 1:size(data1, 2),     % ch data num (ex. 24 channel)
      for kind = 1:size(data1,3),  % HB data num (ex. 3 oxy,deoxy,total)
                                   
	% nan remove
	nanflg = isnan(data1(:,ch,kind)) | isnan(data2(:,ch,kind));
	nanflg = find(nanflg==0);
	if ~isempty(nanflg)
	  data1tmp = data1(nanflg,ch,kind);
	  data2tmp = data2(nanflg,ch,kind);
	end
	
	if ~isempty(nanflg) && exist('tcdf','file')
	  try
	    [h,pv,ci,stat]= ...
		ttest3(data2tmp, data1tmp, t_threshold, 0);
	  catch
	    [h,pv,ci,stat]=ttest3([1,1],[1,2]);
	    h=0;pv=0;stat.tstat=0;
	  end
	else
	  if isempty(nanflg) && kind==1,
	    errordlg(['NaN Channel : ' num2str(ch)]);
	  end
	  if ch==1 && kind==1
	    if ~exist('tcdf','file')
	      errordlg('No TCDF(Statistics Toolbox)');
	    end
	  end
	  stat.tstat = NaN;
	  pv         = NaN;
	  h          = NaN;
	end
        data(1, ch, kind)=stat.tstat;
        data(2, ch, kind)=pv;
        data(3, ch, kind)=h;
        data(4, ch, kind)= nan_fcn('mean', data2(:, ch, kind));
        data(5, ch, kind)= nan_fcn('std0', data2(:, ch, kind));
        data(6, ch, kind)= nan_fcn('mean', data1(:, ch, kind));
        data(7, ch, kind)= nan_fcn('std0', data1(:, ch, kind));
      end
    end
  elseif get(handles.radio_ranksum,'Value'),

    % ---- Wilcoxon rank-sum test ----
    tmode = 'Wilcoxon Rank-Sum Test';

    % Make [ block*time ch hb]
    s=size(data1);
    data1=reshape(data1,[s(1)*s(2) s(3) s(4)]);
    s=size(data2);
    data2=reshape(data2,[s(1)*s(2) s(3) s(4)]);

    for ch = 1:size(data1, 2),     % ch data num (ex. 24 channel)
      for kind = 1:size(data1,3),  % HB data num (ex. 3 oxy,deoxy,total)
	if exist('ranksum','file')
	  [pv,h,stat]= ...
	      ranksum(data1(:, ch, kind), data2(:, ch, kind), t_threshold);
	else
	  if ch==1 && kind==1
	    errordlg('No RANKSUM(Statistics Toolbox)');
	  end
	  stat.zval= NaN;
	  h        = NaN;
	  pv       = NaN;
	end
        data(1, ch, kind)=stat.zval;
        data(2, ch, kind)=pv;
        data(3, ch, kind)=h;
        data(4, ch, kind)= nan_fcn('mean', data2(:, ch, kind));
        data(5, ch, kind)= nan_fcn('std0', data2(:, ch, kind));
        data(6, ch, kind)= nan_fcn('mean', data1(:, ch, kind));
        data(7, ch, kind)= nan_fcn('std0', data1(:, ch, kind));
      end
    end
    
  else
    error('No Test-Mode');
  end
return;  


function val = edit_threshold_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Numerical Check
%----------------------------------------------------------------
  val = get(hObject,'String');
  val = str2num(val);
  if length(val)~= 1
    error('Input Single value that is between 0.0 and 1.0');
  end 
  if val<0 || val >1
    errordlg('Threshold value must be between 0.0 and 1.0.'); 
    if val<0, val=0; else val=1; end
  end 
  set(hObject,'String',num2str(val));
return;

function Test_ModeSelect(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Select Handles
%----------------------------------------------------------------
  TMradio_h = [handles.radio_Ttest, ...
	       handles.radio_ranksum];
   
  set(hObject,'Value',1)
  TMradio_h(find(TMradio_h == hObject)) =[];
  set(TMradio_h,'Value',0);

return;

function psb_barplot_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Result Plot by Bar
%----------------------------------------------------------------

  [data, tmode] = testexe(handles);

  % === Figure Setting ===
  header      = getappdata(handles.figure1, 'Header');
  measuremode = getappdata(handles.figure1, 'MeasureMode');
  fig_h= figure;
  uimenu_Osp_Graph_Option(fig_h);

  psn  = time_axes_position(header, ...
			    [0.9 0.9], [0.05 0.05]);

  set(fig_h, ...
      'Name', [tmode ' : Result'], ...
      'Color', [.75 .75 .5]);

  % Plot Data
  for chid = 1:size(psn,1)
	figure(fig_h); % confine
    ax = axes('units','normal','Position', psn(chid,:));
    tag_chnum = strcat('ch', num2str(chid));
    set(ax, 'FontSize',[6], ...
            'Tag', tag_chnum);
    osp_g_ttest_bar(data(:,chid,:));
  end
return;

function psb_Image_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Result Plot by Image
%----------------------------------------------------------------

  [data, tmode] = testexe(handles);
  measuremode    = getappdata(handles.figure1, 'MeasureMode');
  header         = getappdata(handles.figure1, 'Header'); % for time_axes_positionCell
  % === Open Image ===
  image_h = osp_imageview;

  % --- Image setup Data ---
  setappdata(image_h, 'xdata', 1:size(data,1));
  % for image
  for kind=1:size(data,3)
    for type=1:size(data,1)
      if all(isnan(data(type,:,kind)))
	data(type,:,kind)=0;
      end
    end
  end
  
  setappdata(image_h, 'ydata', data);
  setappdata(image_h, 'HEADER', header);
  setappdata(image_h, 'measuremode', measuremode);
  set(image_h, 'Name', 'Image View Control');

  % -- Initiarize --
  image_handles = guihandles(image_h);
  set( image_handles.ppmSldSpeed,'Value',1,'Visible','off');
  set( image_handles.edtMeanPeriod, ...
       'String', '1', ...
       'Enable', 'inactive');
  set( image_handles.edtAxisMax, 'String', '1');
  set( image_handles.edtAxisMin, 'String', '0');
  set( image_handles.cbxAxisAuto, 'Value', 1);
  set( image_handles.sldPos, 'Value', 1, ...
		    'Max'  , 7, ...
		    'Min',1, ...
		    'SliderStep', [ 1/6 1/6 ]);
  osp_imageview_ttest_help;

  set( image_handles.edtPos, 'String','1');
return;


function psb_save_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Save Result in format DataDef_TTest
%----------------------------------------------------------------

  [data, tmode] = testexe(handles);
  fig_h = handles.figure1;
  key.Data       = data;
  key.TestMode   = tmode;
  key.MeasureMode = getappdata(fig_h, 'MeasureMode');
  key.Tag        = getappdata(fig_h, 'HBkindTag');

  try,
	  data = DataDef_TTest('New',key);
	  if ~isempty(data),
	    setappdata(handles.figure1, 'TTestData',data);
	    set(handles.psb_save_ow, 'Visible','on');
	  end
  catch,
	  errordlg(lasterr);
  end
  
return;

function psb_save_ow_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Save Result in format DataDef_TTest, 
%     Data Re-set
%----------------------------------------------------------------

  [data, tmode] = testexe(handles);

  fig_h = handles.figure1;
  key.Data       = data;
  key.TestMode   = tmode;
  key.MeasureMode = getappdata(fig_h, 'MeasureMode');
  key.Tag        = getappdata(fig_h, 'HBkindTag');

  data = getappdata(handles.figure1, 'TTestData');
  if isempty(data)
    errordlg(' TTest Data Lost');
    set(handles.psb_save_ow, 'Visible','off');
  end

  data.data = key;
  DataDef_TTest('save_ow',data);
  setappdata(handles.figure1, 'TTestData',data);
return;

function data=unit2index(f_h, data, mode),
% change variable data [unit] to index.
%   f_h  : Handle of the Figure. -> f_h = uiTtest;
%   data : data.
  if nargin<=2,
      mode='normal';
  end
  unit     = getappdata(f_h,'Unit');
  start_p  = getappdata(f_h, 'StartIndexTime');
  switch mode,
      case 'normal',
          data = round((data-start_p) * unit + 1);
      case 'no_shift'
          data = round(data * unit);
      otherwise,
          error('Unknown mode');
  end
return;

function psb_save_file_Callback(hObject, eventdata, handles)
% save to file

  % Get Working Directory
  wd='';
  try,
    wd = OSP_DATA('GET','WORK_DIRECTORY');
  end
  if isempty(wd), wd=pwd; end
  tmpdir = pwd;

  % get save file
  cd(wd);
  [f p] = uiputfile('*.mat', 'Save Plot File', ...
                    'T_test_result.mat');
  if isequal(f,0) || isequal(p,0)
    cd(tmpdir);
    return; % cancel
  end

  % save working directory
  cd(p); wd=pwd;
  try,
    OSP_DATA('SET','WORK_DIRECTORY',wd);
  end
  cd(tmpdir);

  % --- make data --
  [data, tmode] = testexe(handles);
  fig_h = handles.figure1;
  Data        = data;
  TestMode    = tmode;
  MeasureMode = getappdata(fig_h, 'MeasureMode');
  Tag         = getappdata(fig_h, 'HBkindTag');

  % -- save
  try,
    save([wd filesep f], ...
	 'data', ...
	 'TestMode', ...
	 'MeasureMode', ...
	 'Tag');
  catch,
    errordlg(lasterr);
  end
return;
