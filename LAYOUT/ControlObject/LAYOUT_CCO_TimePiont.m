function varargout=LAYOUT_CCO_TimePiont(fcn,varargin)
% Control Callback Object to for Time-Point
%
% This function is Formated by Common-Callback-Object
% for POTATo (ver 3.1.8 )
%
% $Id: LAYOUT_CCO_TimePiont.m 393 2014-02-03 02:19:23Z katura7pro $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 14-Nov-2007
%
%------------->
% 2007.11.12
%  Modify for Common-Control Design-20071108

% Import from : osp_ViewCallback_2DImageTime (r1.6)


% Help for noinput
if nargin==0,  fcn='help';end

%====================
% Swhich by Function
%====================
switch fcn
  case {'help','Help','HELP'},
    OspHelp(mfilename);
  case {'createBasicInfo','getDefaultCObject','drawstr','getArgument'},
    % Basic Information
    varargout{1} = feval(fcn, varargin{:});
  case 'make',
    varargout{1} = make(varargin{:});
  case 'ExeCallback'
    ExeCallback(varargin{:});
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
%===============================
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         '2DImage Time'
%       Myfunction Name
%         'vcallback_2DImageTime'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Time Point';
basicInfo.fnc    ='LAYOUT_CCO_TimePiont';
% File Information
basicInfo.rver   ='$Revision: 1.3 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2007/12/13 11:39:27 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname  = {'TimePoint'};
basicInfo.uicontrol= {'slider'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout positioncura
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=1 && isstruct(varargin{1})
  data=varargin{1};
end
data.name='Time Point';
data.fnc ='LAYOUT_CCO_TimePiont';

[data,varList]=subSetDefaultValues(data);

flag=true;
while flag,
	ret = inputdlg(varList(:,3)','Default value setting', 1,varList(:,2)');

	if isempty(ret), break; end
  try
    pos0=str2num(ret{strmatch('pos',varList(:,1))}); %#ok : not single
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);continue;
    end
  catch
    h=errordlg({'Input Proper Number:',lasterr});
    waitfor(h); continue;
  end
  flag=false;
end
% Canncel
if flag,
  data=[]; return;
end

% OK
for k=1:size(varList,1)
	data.(varList{k,1})=ret{k};
end
data.pos =pos0;
return;

%************
function varargout=subSetDefaultValues(data)
varList={...
	'pos','[0 0 0.2 0.1]','Relative position';...
	'timePoint','3','Start time point';...
	'sliderStep', '1', 'Slider step (1:x1 2:x2 3:x4 4:x8 5:x16)';...
	};
for k=1:size(varList,1)
	if ~isfield(data,varList{k,1})
		data.(varList{k,1})=varList{k,2};
	else
		varList{k,2}=num2str(data.(varList{k,1}));
	end
end
varargout{1}=data;
varargout{2}=varList;
%************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_TimePiont(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

%-check obj
obj=subSetDefaultValues(obj);

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'TimePoint';
CCD.CurDataValue = {'TimePoint0','TimePoint'};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;
% Set position of Time slider, Time edit, Time-Step popup components
if pos(4)<pos(3),
  % heigh < width
  %         *2 *3
  % <----------->
  pos1(1:4) = [pos(1)               pos(2)            pos(3)       pos(4)*0.5];
  pos2(1:4) = [pos(1)+pos(3)*0.75   pos(2)+pos(4)*0.5 pos(3)*0.125 pos(4)*0.5];
  pos3(1:4) = [pos(1)+pos(3)*0.875  pos(2)+pos(4)*0.5 pos(3)*0.125 pos(4)*0.5];
else
  wt=pos(3)/4;
  ht=pos(4)/4;
  % heigh > width
  %  |
  %  | *2
  %  | *3
  pos1(1:4) = [pos(1)       pos(2)        wt  3*ht];
  pos2(1:4) = [pos(1)+2*wt  pos(2)+1.2*ht 3*wt    ht];
  pos3(1:4) = [pos(1)+2*wt  pos(2)+0.1*ht 3*wt    ht];
end
%pos1 = getPosabs(pos1,apos);
%pos2 = getPosabs(pos2,apos);
%pos3 = getPosabs(pos3,apos);

%=====================
% Set Special User Data
% <- User Data 1 is Special ->
%=====================
sld_v=str2num(obj.timePoint);                     % init
sval=str2num(obj.sliderStep);                      % slide bar step(=x4)
% Set Time Position Number
[header,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);
datasize=size(data);
if length(datasize)>=4,
  datasize=datasize(2);
else
  datasize=datasize(1);
end

sldsp  = 2^(sval-1); % Slide Speed
stepOfButton = sldsp/datasize;
if stepOfButton>1, stepOfButton = 1; end
if sld_v>datasize, sld_v=datasize; end

% Time Slider
%curdata.Callback_2DImageTime.handles= ...
CCD.handle= ...
  uicontrol(hs.figure1,...
  'Style','slider', ...
  'Value', sld_v, ...
  'Min', 1,       ...
  'Max', datasize, ...
  'SliderStep', [ stepOfButton 0.05], ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', pos1, ...
  'TooltipString','Time Index  Setting', ...
  'Tag','Callback_2DImageTime', ...
  'Callback', ...
  'LAYOUT_CCO_TimePiont(''sld_time_Callback'',gcbo)');

% confierm ::
set(hs.figure1,'Visible','off');

% Time edit
%curdata.Callback_2DImageTimeE.handles = ...
CCD.handle_edit_time = ...
  uicontrol(hs.figure1,...
  'Style','edit','String', num2str(sld_v), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', pos2, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Time Index Setting', ...
  'Tag','Callback_2DImageTime', ...
  'Callback', ...
  'LAYOUT_CCO_TimePiont(''edit_time_Callback'',gcbo)');


str={'x1','x2','x4','x8','x16'};
% Time-Step popup
%curdata.Callback_2DImageTimeStep.handles= ...
CCD.handle_pop_timestep = ...
  uicontrol(hs.figure1,...
  'Style','popupmenu','String',str, ...
  'Value', sval, ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', pos3, ...
  'TooltipString','Time slider step Setting', ...
  'Tag','Callback_2DImageTimeStep', ...
  'Callback', ...
  'LAYOUT_CCO_TimePiont(''pop_timestep_Callback'',gcbo)');

CCD.datasize=datasize;
% Set handles to Time-UserData{1}
set(CCD.handle, 'UserData', {CCD});
set(CCD.handle_edit_time, 'UserData', CCD);
set(CCD.handle_pop_timestep, 'UserData', CCD);

curdata.TimePoint0 = sld_v;
curdata.TimePoint  = sld_v*header.samplingperiod/1000;

if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sld_time_Callback(h)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  % -- Getting Userdata --
  ud       = get(h, 'UserData');
  CCD      = ud{1};

  % -- Getting Variable --
  timepos   = round(get(h, 'Value'));
  % Error Checking....
  if length(timepos)~=1,
    error('set 1 point (time-Index) to this edit-text');
  end
  if timepos<=0
    error('set Positive');
  end
  if timepos> get(h,'MAX'),
    error('Time-Index : Over flow');
  end
  set(CCD.handle_edit_time, 'String', num2str(timepos));
catch
  % Error Operation
  errordlg({' P3 Error!', ['   ' lasterr]});
  return;
end

%======================
% Get Unit for callback
%======================
chdata=getappdata(gcbf,'CHDATA');
try
	if ~isempty(chdata)
		unit =  1000/chdata{1}.samplingperiod;
	else
		bhdata=getappdata(gcbf,'BHDATA');
		unit =  1000/bhdata.samplingperiod;
	end
	% No sampling period
catch ME
	fprintf(2,'[W] No Sampingpeiod\n\y%s\n',ME.message);
	unit = 5; % 1000/200msec,  5 point/sec
end
timepos_sec=timepos/unit;

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    timepos  : time  index
%    unit     : time-unit of Cdata

for idx=2:length(ud),
  % Get Data
  vdata = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  
  % Channel Update
  vdata.curdata.TimePoint  = timepos_sec;
  vdata.curdata.TimePoint0 = timepos;

  % Delete handle
  if isfield(vdata,'obj') && isfield(vdata.obj,'flagRetain') && (vdata.obj.flagRetain == true)
	  %- retain object
	  vdata.obj.RetainedObjectHandle = vdata.handle;
  else
	  for idxh = 1:length(vdata.handle),
		  try
			  if ishandle(vdata.handle(idxh)),
				  delete(vdata.handle(idxh));
			  end
		  catch
			  warning(lasterr);
		  end % Try - Catch
	  end
  end
  % Evaluate (Draw)
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end % Try - Catch
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_time_Callback(h)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  % -- Getting Userdata --
  CCD       = get(h, 'UserData');
  %--  Default Color --
  set(h,'ForegroundColor','black');

  % -- Getting Variable --
  timepos =round(str2double(get(h, 'String')));
  % Error Checking....
  if length(timepos)~=1,
    error('set 1 point (time-Index) to this edit-text');
  end
  if timepos<=0
    error('set Positive');
  end
  if timepos> CCD.datasize
    error('Time-Index : Over flow');
  end

  % ===== Callback by sld_time! =====
  set(CCD.handle,'Value',timepos);
  sld_time_Callback(CCD.handle);
catch
  % Error Operation
  errordlg({' P3 Error!', ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_timestep_Callback(hObject)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  % -- Getting Userdata --
  CCD       = get(hObject, 'UserData');
  % -----------------------------------

  % -- Getting Variable --
  sldsp  = 2^(get(hObject, 'Value')-1); % Slide Speed
  stepOfButton = sldsp/CCD.datasize;

  if stepOfButton>1, stepOfButton = 1; end
  set(CCD.handle,'SliderStep', [ stepOfButton 0.05]);
catch
  % Error Operation
  errordlg({' P3 Error!', ['   ' lasterr]});
  return;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
