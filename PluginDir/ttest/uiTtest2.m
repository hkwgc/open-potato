function varargout = uiTtest2(varargin)
% UITTEST2 set Arguments of Plug-in T Test (Add)
%
% UITTEST2, by itself, creates a new UITTEST2 or raises the existing
% singleton*.
%
% Syntax :
%   argData = UITTEST2('argData',argData,'Mfile_Pre',mfile_previous);
%     argData is Structure of Arguments for PlugInWrap_AddTTest.
%     mfile_previous is File-Name (Character) of M-File, that
%     get Filterd Block-Data (User-Command-Data).
%
% See also: GUIDE, GUIDATA, GUIHANDLES,
%           PLUGINWRAP_ADDTTEST, TTEST3.

% Last Modified by GUIDE v2.5 19-Oct-2006 16:36:15

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2006.02.15
% $Id: uiTtest2.m 180 2011-05-19 09:34:28Z Katura $


%=========================================
% Switch sub-functions
%   By GUIDE v2.5 ( UNIX )
%=========================================
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiTtest2_OpeningFcn, ...
                   'gui_OutputFcn',  @uiTtest2_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GUI Control functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiTtest2_OpeningFcn(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Open Figure.
% Input Data (varargin) must be mfile_previous and argData.
%   mfile_previous : String
%   argData        : empty / Structure
%----------------------------------------------------------------
  handles.output = [];
  set(hObject,'Color',[1 1 1]);
  
  guidata(hObject, handles); % Save handles (GUIDATA)
  msg = nargchk(2,2,length(varargin));
  if isempty(msg),
      errordlg(lasterr);return;
  end
  try
    % Set Current Data 
    mfile_previous=varargin{4};
    [header,data]=scriptMeval(mfile_previous,'bhdata','bdata');
    SetValue(hObject, [], handles, data,header);

    % Set Arguments
    argData       =varargin{2};
    if ~isempty(argData),
      setArgData(handles,argData);
    end
  catch
    errordlg({'OSP Error : ', lasterr});
    return; % No Wait and Return!! == Cancel!
  end
    
  axes1_redrawfunc(hObject,1,handles);

  % <---- ui wati ------>
  if 1,
    set(hObject,'WindowStyle','modal')
    uiwait(hObject);
  else,
    % ::Debug::
    warning('Debug Mode --> Not uiwait');
  end

function varargout = uiTtest2_OutputFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Output is Argument Data
%----------------------------------------------------------------
  varargout{1} = handles.output;
  % Try to Delete Opened figure
  try,
    % Get Open Figure
    h=getappdata(handles.figure1,'CURRENT_FIGURES');
    for idx=1:length(h),
      try,     % Is h(idx) handle?
	if ishandle(h(idx)),
	  delete(h(idx));
	end
      end
    end
  end % try Delete
  delete(handles.figure1);
return;

function addfig(hin,handles),
  h=getappdata(handles.figure1,'CURRENT_FIGURES');
  h(end+1)=hin;
  setappdata(handles.figure1,'CURRENT_FIGURES',h);

function figure1_KeyPressFcn(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Common Keybind Setting
%----------------------------------------------------------------
  osp_KeyBind(hObject,[],handles,mfilename);

%%%%%%%%%%%%%%%%%
%   Data I/O    %
%%%%%%%%%%%%%%%%%
function psb_SetupCancel_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Setup : Cancel
%----------------------------------------------------------------
  handles.output = [];
  guidata(hObject, handles);
  if isequal(get(handles.figure1,'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
  else,
    delete(handles.figure1);
  end
return;

function psb_SetupOK_Callback(hObject, eventdata, handles)
%----------------------------------------------------------------
%  Setup : OK
%----------------------------------------------------------------
  handles.output = getArgData(handles);
  guidata(hObject, handles);
  if isequal(get(handles.figure1,'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
  else,
    delete(handles.figure1);
  end
return;

function setArgData(handles,argData)
% Set ArgData to GUI
  if isempty(argData), return; end

  % Figrue Handle
  f_h = handles.figure1; 

  %== Test Period ==
  if isfield(argData,'Period'),
    % period1
    sec1 = argData.Period.sec1;
    set(handles.edit_area1st, 'String', num2str(sec1(1)));
    set(handles.edit_area1ed, 'String', num2str(sec1(2)));
    area_check(handles.edit_area1st,handles);
    area_check(handles.edit_area1ed,handles);

    % period2
    sec2 = argData.Period.sec2;
    set(handles.edit_area2st, 'String', num2str(sec2(1)));
    set(handles.edit_area2ed, 'String', num2str(sec2(2)));
    area_check(handles.edit_area2st,handles);
    area_check(handles.edit_area2ed,handles);
  end

  %== PeackSerach Setting ==
  if isfield(argData,'PeakSearch'),
    peakserach=argData.PeakSearch;
    % Enable or Disable
    set(handles.ckb_peaksearch,'Value',peakserach.enable);
    
    % Period Number (1|2)
    set(handles.pop_psearch,'Value',peakserach.period);
    % Search Area
    set(handles.edit_peaksearch1, ...
	'String',num2str(peakserach.SearchArea.sec(1)));
    edit_peaksearch1_Callback(handles.edit_peaksearch1, ...
			      [], handles);
    set(handles.edit_peaksearch2, ...
	'String',num2str(peakserach.SearchArea.sec(2)));
    edit_peaksearch2_Callback(handles.edit_peaksearch2, ...
			      [], handles);
  end

  %== T-Test Optiion ==
  if isfield(argData,'Option');
    option=argData.Option;
    % T-Test 
    set(handles.radio_Ttest,...
	'Value',option.ttest);
    % Wilcoxon Rank-Sum Test
    set(handles.radio_ranksum,...
	'Value',option.ranksum);
    % Threshold
    set(handles.edit_threshold,...
	'String', num2str(option.threshold));
  end

function argData=getArgData(handles)
% Get ArgData from GUI
  
  % Figrue Handle
  f_h = handles.figure1; 
  %== Test Period ==
  % period1
  p1(1) = area_check(handles.edit_area1st,handles);
  p1(2) = area_check(handles.edit_area1ed,handles);
  period.sec1 = p1; % Unit
  period.idx1 = unit2index(f_h, p1); % Index

  % period2
  p2(1) = area_check(handles.edit_area2st,handles);
  p2(2) = area_check(handles.edit_area2ed,handles);
  period.sec2 = p2; % Unit
  period.idx2 = unit2index(f_h, p2); % Index
  argData.Period=period; clear period p1 p2;

  %== PeackSerach Setting ==
  % Enable or Disable
  if get(handles.ckb_peaksearch,'Value')
    peakserach.enable=true;
  else,
    peakserach.enable=false;
  end
  % Period Number (1|2)
  peakserach.period = get(handles.pop_psearch,'Value');
  % Search Area
  sa(1) =  edit_peaksearch1_Callback(handles.edit_peaksearch1, ...
				     [], handles);
  sa(2) =  edit_peaksearch2_Callback(handles.edit_peaksearch2, ...
				     [], handles);
  peakserach.SearchArea.sec=sa;
  peakserach.SearchArea.idx=unit2index(f_h, sa,'no_shift');
  argData.PeakSearch=peakserach; clear sa peakserach;

  %== T-Test Optiion ==
  % T-Test 
  if get(handles.radio_Ttest,'Value'),
    option.ttest=true;
  else
    option.ttest=false;
  end
  % Wilcoxon Rank-Sum Test
  if get(handles.radio_ranksum,'Value'),
    option.ranksum=true;
  else
    option.ranksum=false;
  end
  % Threshold
  option.threshold = ...
      edit_threshold_Callback(handles.edit_threshold,[], handles);
  argData.Option = option;
return;

function SetValue(hObject, eventdata, handles, varargin)
%----------------------------------------------------------------
% Init Function : Set Apprication Value
%   This Function Input must be common in Statistic Analysis GUI
%----------------------------------------------------------------

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
  axes1_redrawfunc(hObject,1,handles);
function ed = edit_area1ed_Callback(hObject, eventdata, handles)
  ed = area_check(hObject, handles);
  axes1_redrawfunc(hObject,1,handles);
function st = edit_area2st_Callback(hObject, eventdata, handles)
  st = area_check(hObject,handles);
  axes1_redrawfunc(hObject,1,handles);
function ed = edit_area2ed_Callback(hObject, eventdata, handles)
  ed = area_check(hObject, handles);
  axes1_redrawfunc(hObject,1,handles);

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
  
  axes1_redrawfunc(hObject,1,handles);

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
  axes1_redrawfunc(hObject,0,handles);
  return;
function val=edit_peaksearch2_Callback(hObject, eventdata, handles)
  val = edit_peaksearchCheck(hObject, handles);
  axes1_redrawfunc(hObject,0,handles);
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
  
  [ad, am, h]=osp_peaksearch(block, area, sarea, tag, [1/unit, start_p]);
  addfig(h,handles);
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
	sarea = unit2index(f_h, sarea,'no_shift');

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
  fig_h= figure; addfig(fig_h,handles);
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
  image_h = osp_imageview; addfig(image_h,handles);

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
  help_h=osp_imageview_ttest_help; addfig(help_h,handles);

  set( image_handles.edtPos, 'String','1');
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unit <-> Index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=unit2index(f_h, data, mode),
% change variable data [unit] to index.
%   f_h  : Handle of the Figure. -> f_h = uiTtest2;
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

function axes1_redrawfunc(hObject,e,handles)
% hObject is handles Axes1, 
% e is not in use, dumy
% handles : handles of this gui
  
% Axes Reset
  cla(hObject);
  hold on
  
  h=handles.figure1;
  astimtime=getappdata(h,'Astimtimes'); % Block Time in Index
  unit=getappdata(h,'Unit');

  % Block Timinge
  astimtime.iniBlock = str2num(get(handles.text_iniBlock, 'String'));
  astimtime.iniStim  = str2num(get(handles.text_iniStim, 'String'));
  astimtime.finStim  = str2num(get(handles.text_finStim, 'String'));
  astimtime.finBlock = str2num(get(handles.text_finBlock, 'String'));
  t=[astimtime.iniBlock , astimtime.iniStim, ...
    astimtime.finStim,   astimtime.finBlock ];
  
  argData.Period.sec1(1)=str2num(get(handles.edit_area1st,'String'));
  argData.Period.sec1(2)=str2num(get(handles.edit_area1ed,'String'));
  argData.Period.sec2(1)=str2num(get(handles.edit_area2st,'String'));
  argData.Period.sec2(2)=str2num(get(handles.edit_area2ed,'String'));

  argData.PeakSearch.enable=get(handles.ckb_peaksearch,'Value');
  argData.PeakSearch.period=get(handles.pop_psearch,'Value');
  argData.PeakSearch.SearchArea.sec(1)=str2num(get(handles.edit_peaksearch1,'String'));
  argData.PeakSearch.SearchArea.sec(2)=str2num(get(handles.edit_peaksearch2,'String'));
  
  % peacksearch
  if argData.PeakSearch.enable,
    if argData.PeakSearch.period==1,
      % First
      % in realry check +- and ...
      wk=argData.Period.sec1+argData.PeakSearch.SearchArea.sec;
   
	  h(1)=line([wk(1), wk(1)],[0.5 1]);
	  h(2)=line([wk(2)+argData.Period.sec1(2), wk(2)+argData.Period.sec1(2)],[0.5 1]);
	  h(3)=line([wk(1), wk(2)+argData.Period.sec1(2)],[0.75 0.75]);
	  set(h,'Color',[0.5 0.8 0],'LineWidth',3);
    else
      wk=argData.Period.sec2+argData.PeakSearch.SearchArea.sec;
	  h(1)=line([wk(1), wk(1)],[1.1 1.6]);
	  h(2)=line([wk(2)+argData.Period.sec1(2), wk(2)+argData.Period.sec1(2)],[1.1 1.6]);
	  h(3)=line([wk(1), wk(2)+argData.Period.sec1(2)],[1.35 1.35]);
	  set(h,'Color',[0.5 0.8 0],'LineWidth',3);
    end
	
	  ylim([0.2 1.8])

  end

  % Region 1
  hl1=patch( [argData.Period.sec1 argData.Period.sec1([2 1])],[0.5 0.5 1 1],[0.8 1 0.8]);
  % range 2
  hl2=patch( [argData.Period.sec2 argData.Period.sec2([2 1])],[1.1 1.1 1.6 1.6],[0.8 1 0.8]);

  hline=line(t([1 2 2 3 3 4]), [0.4 0.4 1.7 1.7 0.3 0.3]);
  set(hline,'LineStyle',':','Color',[1 0 0],'Linewidth',2);


% --- Executes on selection change in pop_psearch.
function pop_psearch_Callback(hObject, eventdata, handles)
% hObject    handle to pop_psearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_psearch contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_psearch
  axes1_redrawfunc(hObject,1,handles);


