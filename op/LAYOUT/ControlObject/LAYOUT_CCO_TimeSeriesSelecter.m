function varargout=LAYOUT_CCO_VarEdit(fcn,varargin)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% autohr : TK
% create : 25-Nov-2007
%
%------------->

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
basicInfo.name   ='hdata.TimeSeries Selecter';
basicInfo.fnc    ='LAYOUT_CCO_TimeSeriesSelecter';
% File Information
basicInfo.rver   ='$Revision: 1.1 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/02/18 02:48:21 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname  = {'TimeSeriesSelecter'};
basicInfo.uicontrol={'listbox','popupmenu','menu'};

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)

data.name='hdata.TimeSeries Selecter';
data.fnc ='LAYOUT_CCO_TimeSeriesSelecter';
data.pos =[0, 0, 0.9, 0.1];
data.SelectedUITYPE='listbox';

  data.pos =[0, 0, 0.2, 0.1];
  prompt={'Position : '};
  pos{1} = num2str(data.pos);
  flag=true;
  while flag,
    pos = inputdlg({'Relative Position : '}, ...
		   'Callback Position', 1,pos);
    if isempty(pos), break; end
    try,
      pos0=str2num(pos{1});
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
data.pos =pos0;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_TimeSeriesSelecter(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;
%===================================================================
function curdata=make(hs, apos, curdata,obj),

[hdata,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);
if isfield(hdata,'TimeSeries')
	TSstr=fieldnames(hdata.TimeSeries);
else
	TSstr={''};
end

%=====================
% Common-Callback-Data
%=====================
CCD.Name         = ['TimeSeriesSelecter'];
CCD.CurDataValue = {'TimeSeriesSelecter','TimeSeries','timeseries'};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;

%===================
% Make Control GUI
%===================
cl0=get(hs.figure1,'Color'); % Plot Color
switch lower(obj.SelectedUITYPE), 
	case 'listbox',
		% === List Box ===
		curdata.Callback_TimeSeriesSelecter.handles= ...
			uicontrol(hs.figure1,...
			'Style','listbox', ...
			'BackgroundColor',cl0, ...
			'Units','normalized', ...
			'Position',pos, ...
			'Max',1, ...
			'String',TSstr, ...
			'Value', 1, ...
			'Tag','Callback_TimeSeriesSelecter', ...
			'TooltipString','Data-Kind Listbox', ...
			'Callback', ...
			['LAYOUT_CCO_TimeSeriesSelecter(''ExeCallback'','...
			'gcbo,[],guidata(gcbo),''val'')']);
		
	case 'popupmenu',
		% === PopupMenu ===
		curdata.Callback_TimeSeriesSelecter.handles= ...
			uicontrol(hs.figure1,...
			'Style','popupmenu', ...
			'BackgroundColor',cl0, ...
			'Units','normalized', ...
			'Position',pos, ...
			'Max',10, ...
			'String',TSstr, ...
			'Value', 1, ...
			'Tag','Callback_TimeSeriesSelecter', ...
			'TooltipString','Data-Kind Popup Menu', ...
			'Callback', ...
			['LAYOUT_CCO_TimeSeriesSelecter(''ExeCallback'','...
			'gcbo,[],guidata(gcbo),''val'')']);
		
	case 'menu',
		% === Menu ===
		if isfield(curdata,'menu_callback'),
			ud1.h=...
				uimenu(curdata.menu_callback,'Label','Data &Kind', ...
				'TAG', 'Callback_TimeSeriesSelecter');          
			ud1.h2=[];
			curdata.Callback_TimeSeriesSelecter.handles= ud1.h;
			for idx=1:length(TSstr),
				% User Data= 
				ud1.h2(idx)=uimenu(ud1.h,'Label',...
					['&' num2str(idx) TSstr{idx}], ...
					'Callback', ...
					['LAYOUT_CCO_TimeSeriesSelecter(''ExeCallback'','...
					'gcbo,[],guidata(gcbo),''parent'')']);
			end
			set(ud1.h2(1),'Checked','on');
			set(ud1.h,'UserData',{ud1});
		end

	otherwise,
		errordlg({'====== OSP Error ====', ...
			['Undefined Mode :: ' obj.SelectedUITYPE], ...
			['  in ' mfilename], ...
			'======================='});
		delete(curdata.Callback_TimeSeriesSelecter.handles);
		curdata=rmfield(curdata,'Callback_TimeSeriesSelecter');
end % End Make Control GUI

CCD.handle = curdata.Callback_TimeSeriesSelecter.handles;
val.TSstr=TSstr;
val.ID=1;
curdata.TimeSeriesSelecter=val;
set(CCD.handle, 'UserData', {val});

%=== Common Callback Setting ===
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
%===============================

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(h,dummy,d,mode)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    timepos  : time  index
%    unit     : time-unit of Cdata
ud=get(h,'UserData');

%--- update value
ud{1}.ID=get(h,'value');
set(h,'UserData',ud);
%---

for idx=2:length(ud),
  % Get Data
  data = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  
  % Update
  data.curdata.TimeSeriesSelecter=ud{1};  
  
  % Delete handle
  for idxh = 1:length(data.handle),
    try
      if ishandle(data.handle(idxh)),
        delete(data.handle(idxh));
      end
    catch
      warning(lasterr);
    end % Try - Catch
  end
  
  % Evaluate (Draw)
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end % Try - Catch
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
