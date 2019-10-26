function varargout = Multi_file_Mfile_Out(varargin)
% MULTI_FILE_MFILE_OUT M-file for Multi_file_Mfile_Out.fig
%      MULTI_FILE_MFILE_OUT, by itself, creates a new MULTI_FILE_MFILE_OUT or raises the existing
%      singleton*.
%
%      H = MULTI_FILE_MFILE_OUT returns the handle to a new MULTI_FILE_MFILE_OUT or the handle to
%      the existing singleton*.
%
%      MULTI_FILE_MFILE_OUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTI_FILE_MFILE_OUT.M with the given input arguments.
%
%      MULTI_FILE_MFILE_OUT('Property','Value',...) creates a new MULTI_FILE_MFILE_OUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Multi_file_Mfile_Out_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Multi_file_Mfile_Out_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 03-Jul-2006 18:01:55


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.11.24
% $Id: Multi_file_Mfile_Out.m 180 2011-05-19 09:34:28Z Katura $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Multi_file_Mfile_Out_OpeningFcn, ...
                   'gui_OutputFcn',  @Multi_file_Mfile_Out_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Multi_file_Mfile_Out_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before Multi_file_Mfile_Out is made visible.

  %-----------------
  % Initialization
  %-----------------
  %  GUI Data
  handles.output  = hObject;  % Output : Figure handle
  handles.figure1 = hObject;  % My Format..
  guidata(hObject, handles); % Save GUIDATA (Modify)

  %-----------------
  % Other
  %-----------------
  set(hObject,'Color',[1 1 1]); % Figure Color
  % Empty Cell
  set(handles.lsb_datalist, 'UserData',{});
  set(handles.lsb_datalist, 'String',{});
  

function varargout = Multi_file_Mfile_Out_OutputFcn(hObject, eventdata, handles)
% Outputs from this function are returned to the command line.
%   is Figure Handle (See also Multi_file_Mfile_Out_OpeningFcn )
  varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_FileOpen_Callback(hObject, eventdata, handles)
% Load Signal - Data
  ini_actdata = OSP_DATA('GET', 'ActiveData'); % For swap

  %  -- Lock --
  set(handles.figure1, 'Visible', 'off');

  % === File Select  ===
  try
    fs_h = uiFileSelect('DataDif', {'SignalPreprocessor'}, ...
			'SetMax', 10);
    waitfor(fs_h);
  catch
    OSP_DATA('SET','ACTIVEDATA',ini_actdata);
    set(handles.figure1,'Visible','on');
    rethrow(lasterror);
  end

  % -- Unlock --
  set(handles.figure1,'Visible','on');
  actdata0 = OSP_DATA('GET','ACTIVEDATA');
  OSP_DATA('SET','ACTIVEDATA',ini_actdata);
  
  dt=get(handles.lsb_datalist, 'UserData');
  st=get(handles.lsb_datalist, 'String');
  for idx=1:length(actdata0),
    actdata=actdata0(idx);
    idfld = feval(actdata.fcn, 'getIdentifierKey');
    dname = getfield(actdata.data,idfld);
    st{end+1} = dname;
    dt{end+1} = actdata;
  end
  id = length(st);
  set(handles.lsb_datalist, ...
      'Value', id, ...
      'UserData', dt, ...
      'String', st);
  
  lsb_datalist_Callback(handles.lsb_datalist, [], handles);
  
function psb_FileRemove_Callback(hObject, eventdata, handles)
% Remove Signal-Data from List
  st=get(handles.lsb_datalist, 'String');
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');
  
  if isempty(dt)
    warndlg(' No Data to remove');
    return;
  end

  st(tg)=[];  dt(tg)=[];
  if isempty(dt)
    st = {};
    dt = {};
  end
  if tg > length(st)
    tg=length(st);
  end

  set(handles.lsb_datalist, ...
      'Value', tg, ...
      'String', st, ...
      'UserData', dt);
  lsb_datalist_Callback(handles.lsb_datalist, [], handles);

function lsb_datalist_Callback(hObject, eventdata, handles)
% Signal-Data List Box : Select Current Signal-Data 
%  
  dt=get(handles.lsb_datalist, 'UserData');
  tg=get(handles.lsb_datalist, 'Value');
  if length(dt) == 0
    set(handles.lsb_datainfo, ...
        'Value', 1, ...
        'String', {'-- No Data Selected --'});
    setappdata(handles.figure1, 'LocalActiveData',[]);
    OspFilterCallbacks('LocalActiveDataOff', hObject,[],handles);
    return;
  end

  % Active Data
  actdata = dt{tg}; clear dt tg;
  [header, data] = DataDef_SignalPreprocessor('load', actdata.data);
  % Change for Bug Fix :
  actdata.MultiBlockMode=true;
  setappdata(handles.figure1, 'LocalActiveData',actdata);
  OspFilterCallbacks('LocalActiveDataOn', hObject,[],handles);

  % === Data Print ===
  info = feval(actdata.fcn, 'showinfo', actdata.data);
  set(handles.lsb_datainfo, ...
      'Value'    , 1, ...
      'String'   , info);

function lsb_datainfo_Callback(hObject, eventdata, handles)
% Do nothing now;

function pop_stimtype_Callback(hObject, eventdata, handles)
% Do Nothing Now;
  
function edt_serialno_Callback(hObject, eventdata, handles)
% Check Serial Number
str=get(hObject,'String');
try,
  %-----------------
  % Data Check (Get)
  %-----------------
  % get Serial No (Fromat of Numerical check in str2num)
  sn=str2num(str);
  sn=round(sn); % Integer
			
  % There is effective Data?
  if isempty(sn), 
    error('No Data-Selected');
  end
  % In a range ?
  if find(sn<=0),
    error('Serial Number must be positive');
  end
  
  % Set Data 
  set(hObject,'UserData',sn);
catch,
    % ----------------------------
    % When Input Data Error!
    %   Back to Before Setting
    % ----------------------------
	stkind=get(hObject,'UserData');
	if isempty(stkind) 
		stkind=1;
		set(hObject,'UserData',1);
	else,
		stkind=num2str(stkind);
	end
	%   Error Messages
	set(hObject,'String',stkind,'ForegroundColor','red');
	errordlg({'Stim-Kind must be Integer',lasterr});
end
function edt_stimtype_Callback(hObject, eventdata, handles)
% Check StimKind
str=get(hObject,'String');
try,
    %-----------------
	% Data Check (Get)
	%-----------------
    % get Kind (Fromat of Numerical check in str2num)
	stkind=str2num(str);
	stkind=round(stkind); % Integer
	% There is effective Data?
	if isempty(stkind), 
		error('No Kind Selected');
	end
	% In a range ?
	if find(stkind<=0),
		error('stkind must be positive');
	end
	
	% Set Data 
	set(hObject,'UserData',stkind);
catch,
    % ----------------------------
    % When Input Data Error!
    %   Back to Before Setting
    % ----------------------------
	stkind=get(hObject,'UserData');
	if isempty(stkind) 
		stkind=1;
		set(hObject,'UserData',1);
	else,
		stkind=num2str(stkind);
	end
	%   Error Messages
	set(hObject,'String',stkind,'ForegroundColor','red');
	errordlg({'Stim-Kind must be Integer',lasterr});
end

function psb_makeMfile_Callback(hObject, eventdata, handles)
% Make Multi-File-M-File
% === Get Datae ===
stimtype = get(handles.pop_stimtype,'Value');
stimkind = get(handles.edt_stimtype,'UserData');
serialno = get(handles.edt_serialno,'UserData');
fmd      = OspFilterCallbacks('get',handles.figure1,false);
datalist = get(handles.lsb_datalist, 'UserData');

% Data Check...
if ~isstruct(fmd) || ~isfield(fmd,'BlockPeriod'),
  errordlg('Multi File Mfile Need Block Data');
  return;
end

% Data Check...
if isempty(datalist),
  errordlg({'No Data-List Selected', ' Open File at first!'});
  return;
end
  
% === Get File Name ===
while (1),
	[f, p] = uiputfile( ...
		{'*.m','OutPut M-file (*.m)'}, ...
		'Multi File M-file Name', 'mfmf.m');
	% Cancel Check
	if isequal(f,0) | isequal(p,0),
		return;
	end
	% Other Check
	if 0,
		% Error comment
		continue;
	end
	break;
end

% == Open M-File ==
fname = [p filesep f];
fname0 = strfind(f,'.');
switch length(fname0),
  case 0,
   fname0 = f;
   fname  = [fname '.m'];

 case 1,
  if (fname0==1),
    errordlg('Input Filename'); return;
  end 
  if ~strcmp(f(fname0:end),'.m'),
    errordlg('Extention of File must be ''.m''!');
    return;
  end
  fname0  = f(1:(fname0-1));

 otherwise,
  errordlg('Double Extention exist!');
  return;
end

try,
	[fid, fname] = make_mfile('fopen', fname,'w');
	% Header And Comment
	make_mfile('with_indent', ...
		   ['function [bdata, bhdata]=' fname0 '(varargin)']);
	make_mfile('with_indent', ...
		   {'% Make some Group-Data by Cell-array From Files.', ...
		    ['% Syntax : [bdata, bhdata]= ' fname0 ';'], ...
		    ' % bdata : ', ...
		    [' %   Cell Aray of Block-Data of ' ...
		     'User-Command Data'], ...
		    ' % bhdata : ', ...
		    [' %   Cell Aray of Header of Block-Data of ' ...
		     'User-Command Data'], ...
		    ' % $Id: Multi_file_Mfile_Out.m 180 2011-05-19 09:34:28Z Katura $', ' '});

	% Initialize
	make_mfile('code_separator',1)
	make_mfile('with_indent', '% Initialize Data');
	make_mfile('code_separator',1)
	make_mfile('with_indent', {'bdata={}; bhdata={};', ' '});
	make_mfile('code_separator',3)
	make_mfile('with_indent', '% Arguments Check');
	
	% Getting File Info
	dname = feval(datalist{1}.fcn,'getFilename',datalist{1}.data);
	make_mfile('with_indent', ...
		   ['datanames={ {''' dname '''}, ...']);
	
	for idx=2:length(datalist)-1,
	  dname = feval(datalist{idx}.fcn,...
			'getFilename',datalist{idx}.data);
        make_mfile('with_indent', ...
		   ['            {''' dname '''}, ...']);
	end
	dname = feval(datalist{end}.fcn,...
		      'getFilename',datalist{end}.data);
	make_mfile('with_indent', ...
		   ['            {''' dname '''}};']);
	
	make_mfile('with_indent', ...
		   'for idx=1:length(datanames),');
	make_mfile('indent_fcn', 'down');
	if 0,
	  % Error ???
	  make_mfile('with_indent', ...
		     {'[bdata{end+1}, bhdata{end+1}] = ...', ...
		      '           ospfilt0(datanaems{idx});'});
	else,
	  make_mfile('with_indent', ...
		     {'d = datanames{idx};', ...
		      '[bdata{end+1}, bhdata{end+1}] = ospfilt0(d);'});
	end
	make_mfile('indent_fcn', 'up');
	make_mfile('with_indent', 'end');
	make_mfile('with_indent', {'return;   % Main', ' ', ' '});
	
	% Function of Filter
	make_mfile('with_indent', ...
		'function [bdata, bhdata]=ospfilt0(datanames)');
	FilterData2Mfile(fmd, stimtype, stimkind,serialno);
catch,
	make_mfile('fclose');
	rethrow(lasterror);
end

% == Close M-File ==
make_mfile('fclose');

if 1,
  % Debug Mode
  edit(fname);
end


function psb_makeGroupData_Callback(hObject, eventdata, handles)
% :: Save as Group Data::
% === Get Datae ===
stimtype = get(handles.pop_stimtype,'Value');
stimkind = get(handles.edt_stimtype,'UserData');
if isempty(stimkind), stimkind=1;end
serialno = get(handles.edt_serialno,'UserData');
fmd      = OspFilterCallbacks('get',handles.figure1,false);
datalist = get(handles.lsb_datalist, 'UserData');

% Data Check...
if ~isstruct(fmd) || ~isfield(fmd,'BlockPeriod'),
  errordlg('Multi File Mfile Need Block Data');
  return;
end

% Data Check...
if isempty(datalist),
  errordlg({'No Data-List Selected', ' Open File at first!'});
  return;
end

%-------------------
% Make Default Data
%-------------------
  keys = DataDef_GroupData('Keys');
  % === Setting Information ===
  keys{end+1}='CreateDate';
  prompt=keys;
  def={};
  % Default Key
  for ii=1:length(keys)
      switch keys{ii}
       case 'Tag'
	gdata.Tag='';
       case 'ID_number'
        gdata.ID_number=1;
       case 'CreateDate'
        gdata.CreateDate=now;
       otherwise
	gdata = setfield(gdata,keys{ii},'');
      end
  end

  for idx=1:length(datalist),
      try,
	  % -- Load Stim Data --
	  [hdata, sdata]=DataDef_SignalPreprocessor('load',datalist{idx});

	  %================
	  % Make Group Data
	  %================
	  %------------------------
	  % Make Header Part of GD 
	  %------------------------
	  % Initialize Data
          gdataM=gdata; 
	  % File Name Setting
          gdataM.Tag=sprintf('%s_%d', datalist{idx}.data(1).filename,idx);
	  
	  %----------------------
	  % Make Data Part of GD 
	  %----------------------
	  % -- Signal-Data-File Name --
	  data.name = datalist{idx}.data(1).filename;
	  % -- Set Filter --
	  data.filterdata  = fmd;
	  % -- Stim Data --
	  stimTC=hdata.stimTC(:);
	  if isempty(stimTC), return; end
	  ostim =find(stimTC>0);
	  ostim =ostim(:);
	  data.stim.ver = '1.50';
	  data.stim.tag = ['Stim of this version is ' ...
			   'Differences to original stimulation.'];
	  data.stim.type=stimtype;
	  data.stim.orgn=[stimTC(ostim), ostim]; %[Kind, timing]
	  data.stim.diff=zeros(size(ostim,1),1);
	  data.stim.flag=true([size(ostim,1),size(sdata,2)]);
	  if isempty(serialno), 
	    wk = find(data.stim.orgn(:,1)==stimkind);
	  else,
	    serialno(find(serialno<0))=[];
	    serialno(find(serialno>size(data.stim.org,1)))=[];
	    wk = find(data.stim.orgn(serialno,1)==stimkind);
	  end
	  if isempty(wk), continue; end
	  data.stim.flag(wk,:)=false; % Use the Block
	  gdataM.data = data;
	  
	  %================
	  % Save Group Data
	  %================
          DataDef_GroupData('save',gdataM);
      catch,
          errordlg(lasterr);
      end
  end % End of Signal-data Loop

%Close
close(handles.figure1);




