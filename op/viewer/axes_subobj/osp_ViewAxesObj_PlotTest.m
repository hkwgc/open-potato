function varargout=osp_ViewAxesObj_PlotTest(fnc,varargin)
% Axes Plugin Object : Line-Plot Function (format 1.1)
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Line Plot(test)';
  info.fnc     ='osp_ViewAxesObj_PlotTest';
%  data.ver  = 1.00;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set up : Plot Data
% --- for change ---
if length(varargin)>=1,
	data=varargin{1};
end
  data.str = 'Line Plot';
  data.fnc = 'osp_ViewAxesObj_PlotTest';
  data.ver = 1.00;
  if ~isfield(data,'data'),
	  data.data='Continuous';
  end
  if ~isfield(data,'dcoption'),
	  data.dcoption='HB data';
  end
  
  prompt = {'Continuous/Blcok:',...
	    'DataCange OPTION:(see also pop_data_change_v1)'};
  def    = {data.data, data.dcoption};
  flg=true;
  % data change option definition.
  dcod={'HB data', 'FFT Power', ...
	'FFT Phase', 'FFT Magninude'};
  while flg,
    flg=false;
	  def = inputdlg(prompt,'Plot Arguments', 1,def);
	  if isempty(def), data={}; return; end
	  try,
	    % Check 1st Argument
	    data.data     = def{1};
	    dk=find(strcmpi({'Continuous','Block'},data.data));
	    if length(dk)~=1,
	      h=errordlg('1st Argument must be ''Continous'' or ''Block''.');
	      waitfor(h);
	      flg=true;
	      def{1}='Continuous';
	    end

	    % Check 2nd Argument
	    data.dcoption = def{2};
	    dk=find(strcmp(dcod,data.dcoption));
	    if length(dk)~=1,
	      h=errordlg({'2nd Argument : ', dcod{:}});
	      waitfor(h);
	      flg=true;
	      def{2}=dcod{1};
	    end
	  catch,
		  h=errordlg('Input Variable Error.');
		  waitfor(h);
		  flg=true;
	  end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% Object : obj.data == 
%          'Continous'/ 'Block'
%          obj.mode ==
%
% See also osp_ViewAxesObject_PlotTest/getArgument
obj=varargin{1};
% Check Data
flag=false;
if ~isfield(obj,'data'),
  obj.data='Continuous';
  flag=true;
end
if ~isfield(obj,'dcoption'),
  obj.dcoption='HB data';
  flag=true;
end
% Warning 
if flag,
  warning('Axes Plot Object is old');
end

str=['osp_ViewAxesObj_PlotTest(''test'', ', ...
     '''' obj.data ''', ''' obj.dcoption ''',curdata)'];
return;

function h=test(datastr,dcoption, curdata,ObjectID)
% datastr is string of DataMode 'Block'/'Continuous'
% curdata.time
% curdata.kind

% --> Using Current Data in plot <--
curdata0.ch   = curdata.ch;
curdata0.time = curdata.time;
curdata0.kind = curdata.kind;
curdata0.cid0 = curdata.cid0;
% --> Line Property <---
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  curdata0.lineprop = curdata.lineprop;
  linepropflag=true;
else,
  linepropflag=false;
end
% Default Color
a=max(curdata.kind(:));
if a<10; a=10;end
dcol=hot(a);
dcol(1:3,:)=[0, 0, 1; ...
	     1, 0, 0; ...
	     0, 0, 0];

%=================
% Makke Plot Data
%=================
[hdata,data]=getCurrentData(gcf,datastr,curdata);

axis_label.x='time [sec]';
axis_label.y='HB data';
unit = 1000/hdata.samplingperiod;

try,
  % Mode Transfer
  [data, axis_label, unit] = ...
      pop_data_change_v1(dcoption, data, axis_label, unit);
  hdata.samplingperiod=1000/unit;
catch,
  warning(['OSP Warning : Data Change Error Occur! ' ...
	   C__FILE__LINE__CHAR ...
	   ' ' lasterr]);
end

% Axis Setting
if 0,
  xlabel(axis_label.x);
  ylabel(axis_label.y);
end

% Time Check
if strcmp(axis_label.x,'time [sec]'),
  t0=1:size(data,1);
  t=(t0 -1)/unit;
  of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
  uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];
else,
  t0=1:size(data,1);
  t = t0/unit;
end

% Plot Data
data = data(t0,:,:);

%==================================
% Plot
%==================================
h.h=[];
h.tag={}; 
if strcmpi(dcoption,'HB data'),
	tag_head=[datastr(1) '_.' dcoption(1:2)];
else,
	tag_head=[datastr(1) '_.' dcoption([1,4])];
end
for kind=curdata.kind,
	lp0=0;
	if linepropflag,
		try,
			for lp=1:length(curdata.lineprop),
				f=strcmp(hdata.TAGs.DataTag{kind},curdata.lineprop{lp}.name);
				if f, lp0=lp; break; end
			end
		end
	end
	h.h(end+1)=plot(t,data(:,curdata.ch,kind));
	h.tag{end+1}=[tag_head hdata.TAGs.DataTag{kind}];
	if (lp0~=0), 
		lpx=curdata.lineprop{lp}; 
	else, 
		lpx.style='-';
		lpx.mark='none';
		lpx.color=dcol(kind,:);
	end
	set(h.h(end),...
		'LineStyle',lpx.style,...
		'Marker',lpx.mark, ...
		'Color',lpx.color, ...
		'MarkerEdgeColor',lpx.color, ...
		'MarkerFaceColor',lpx.color, ...
		'TAG', h.tag{end});
end


%==================================
%=      Common-Data Setting       =
%==================================
od=getappdata(gcf,'AXES_PlotTest_ObjectData');
odadd.handle = h.h; % Handles of connected function
odadd.curdata = curdata0;
odadd.datastr = datastr;
odadd.dcoption = dcoption;
if exist('ObjectID','var'),
  od{ObjectID}=odadd;
else,
  if isempty(od),
    od{1}=odadd;
    ObjectID=1;
  else,
    od{end+1}=odadd;
    ObjectID=length(od);
  end
end
setappdata(gcf,'AXES_PlotTest_ObjectData',od);

% ==============================
% ==== Callback Setting List ===
% ==============================
%------------------------
%  Channel Popupmenu 
%------------------------
if isfield(curdata,'Callback_ChannelPopup') && ...
      isfield(curdata.Callback_ChannelPopup,'handles') && ...
      ishandle(curdata.Callback_ChannelPopup.handles),
  % See also osp_view
  pop_ch = curdata.Callback_ChannelPopup.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_PlotTest(' ...
		'''changechannel'',ud{idx}, ch);'];
  ud=get(pop_ch,'UserData');
  ud{end+1}=udadd;
  set(pop_ch,'UserData',ud);
end

%------------------------
%  Kind Selector
%------------------------
if isfield(curdata,'Callback_KindSelector') && ...
      isfield(curdata.Callback_KindSelector,'handles') && ...
      ishandle(curdata.Callback_KindSelector.handles),
  % See also osp_view
  h0            = curdata.Callback_KindSelector.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_PlotTest(' ...
		'''KindSelect'',ud{idx}, kind);'];
  ud=get(h0,'UserData');
  ud{end+1}=udadd;
  set(h0,'UserData',ud);
end

%------------------------
%  Time Range
%------------------------
if isfield(curdata,'Callback_TimeRange') && ...
      isfield(curdata.Callback_TimeRange,'handles') && ...
      ishandle(curdata.Callback_TimeRange.handles),
  % See also osp_view
  h0            = curdata.Callback_TimeRange.handles;
  udadd.ObjectID=ObjectID;
  udadd.axes=gca;
  udadd.str  = ['ud{idx}=osp_ViewAxesObj_PlotTest(' ...
		'''TimeRange'',ud{idx}, time);'];
  ud=get(h0,'UserData');
  ud{end+1}=udadd;
  set(h0,'UserData',ud);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================
function ud=changechannel(ud,ch)
% Channel Change
% Callback of Channel Popupmenu
%==================================
axes(ud.axes);

%--> Object Data <--
od = getappdata(gcf,'AXES_PlotTest_ObjectData');
od = od{ud.ObjectID};
ud.handle=od.handle;
ud.curdata=od.curdata;

try,
  delete(ud.handle);
catch
  warning(['Miss Delete Function : ', ...
	   'Operating Speed might be too fast to redraw.']);
end
ud.curdata.ch=ch;
h=test(od.datastr, od.dcoption, ...
       ud.curdata,ud.ObjectID);

%==================================
function ud=KindSelect(ud,kind)
% Change Kind 
% Callback of Kind Select
%==================================
axes(ud.axes);

%--> Object Data of PLOT-TEST <--
od = getappdata(gcf,'AXES_PlotTest_ObjectData');
od = od{ud.ObjectID};
ud.handle=od.handle;
ud.curdata=od.curdata;

try,
  delete(ud.handle);
catch
  warning(['Miss Delete Function : ', ...
	   'Operating Speed might be too fast to redraw.']);
end

ud.curdata.kind=kind;
h=test(od.datastr, od.dcoption, ...
       ud.curdata,ud.ObjectID);

%==================================
function ud=TimeRange(ud,time)
% Change TimeRange 
% Callback of Time Range
%==================================
axes(ud.axes);

%--> Object Data of PLOT-TEST <--
od = getappdata(gcf,'AXES_PlotTest_ObjectData');
od = od{ud.ObjectID};
ud.handle=od.handle;
ud.curdata=od.curdata;

try,
  delete(ud.handle);
catch
  warning(['Miss Delete Function : ', ...
	   'Operating Speed might be too fast to redraw.']);
end

% Check,Change time range
if length(time)<2, time=[-Inf  time]; end

ud.curdata.time=time;
h=test(od.datastr, od.dcoption, ...
       ud.curdata,ud.ObjectID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata,data]=getCurrentData(figh,datastr, curdata)
% Get Current Data along datastr

switch lower(datastr),
 case 'continuous',
  hdata = getappdata(figh,'CHDATA');
  data  = getappdata(figh,'CDATA');
  if iscell(data),
      if length(curdata.cid0)<=length(data),
          data = data{curdata.cid0};
          hdata=hdata{curdata.cid0};
      else,
          data = data{1};
          hdata=hdata{1};
      end
  end
 case 'block',
  hdata = getappdata(figh,'BHDATA');
  data  = getappdata(figh,'BDATA');
  data  =uc_blockmean(data,hdata);

 otherwise,
  error(['Unknown DataString : ' datastr]);
end
