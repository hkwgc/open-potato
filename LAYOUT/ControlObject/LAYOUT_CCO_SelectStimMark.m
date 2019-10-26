function varargout=LAYOUT_CCO_SelectStimMark(fcn,varargin)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% autohr : M. Shoji
% create : 22-Feb-2010
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
%         'Stim Mark'
%       Myfunction Name
%         'LAYOUT_CCO_SelectStimMark'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Select Stim Kind';
basicInfo.fnc    ='LAYOUT_CCO_SelectStimMark';
% File Information
basicInfo.rver   ='$Revision: 1.1 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/17 05:21:50 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname  = {'VarEdit'};
basicInfo.uicontrol= {'edit'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.name='Select Stim Kind';
data.fnc ='LAYOUT_CCO_SelectStimMark';
data.pos =[0, 0, 0.9, 0.1];
prop={'Stim Kind'};
DefVal{1} = '1';

v=varargin{1};
if isfield(v,'DefVal'), DefVal{1}=num2str(v.DefVal); end

flag=true;
while flag,
  STR = inputdlg(prop,'Stim Kind CCO', 1, DefVal);
  if isempty(STR), break; end
  try
     va=str2double(STR{1});
     if ~isfinite(va)
       wh=warndlg('Number of Input Data must be numerical!');
       waitfor(wh);continue;
     end
     DefVal{1}=va;
  catch
    h=errordlg({'Input Proper Value',lasterr});
    waitfor(h); continue;
  end
  flag=false;
end
% Canncel
if flag,
  data=[]; return;
end

% OK
data.DefVal = DefVal{1};

% Rename
data.name_Label=sprintf('Stim(%d) Popup',data.DefVal);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=LAYOUT_CCO_SelectStimMark(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
if 0, disp(varargin);end
return;

function curdata=make(hs, apos, curdata,obj)
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->

% Get Header of P3-Data
hdata=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);

try
	if isfield(hdata,'stimkind')%- for Blocked data
		xstr= unique(hdata.stimkind);
	elseif isfield(hdata,'stim') && size(hdata.stim,2)==3 %- for Cont data
		xstr = unique(hdata.stim(:,1));
	else
		errdlg('Data type (stim in hdata) is unknown.');
		return;
	end
	ud={xstr};
  try
    if isnumeric(obj.DefVal)
      stimmark=obj.DefVal;
    else
      stimmark=1;
    end
  catch
    stimmark=1;
  end
  a=find(xstr==stimmark);
  xxstr={};
  for xx=1:length(xstr)
    xxstr{end+1}=sprintf('Stim : %d',xstr(xx));
  end
  xstr=xxstr;
  if ~isempty(a)
    stimmark=a(1);
  else
    stimmark=1; % dumy 1
    xstr='NG';
  end  
catch
  stimmark=1;
  xstr='NG: Not Block';
end


%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'StimKind';
CCD.CurDataValue = {'StimKind','StimMark', 'stimkind','SSMark'};
CCD.handle       = []; % Update

pos=getPosabs(obj.pos,apos);
%pos = obj.pos;

% %=====================
% % Set Special User Data
% % <- User Data 1 is Special ->
% %=====================
% Edit
%curdata.Callback_2DImageTime.handles= ...
CCD.handle= ...
  uicontrol(hs.figure1,...
  'Style','pop', ...
  'String', xstr,...
  'Value',stimmark,...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position', pos, ...
  'TooltipString','Stimulation Mark-Number', ...
  'Visible','on',...
  'Tag','CCD_SSMark' );

% Add Callback
set(CCD.handle,'Callback',[mfilename '(''Callback'',gcbo)']);
set(CCD.handle,'UserData',ud);

curdata.stimkind=stimmark;
curdata.flag.InterMarkAveraging = false;
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Callback(h)
% Execute on Mark-Selector Edit-Text
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
value = get(h,'Value');
UD1 = ud{1};
stimkind = UD1(value);

%- check average option state in menu
for idx=2:length(ud),
  % Get Data
  vdata = p3_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
  
  % Update
  vdata.curdata.stimkind = stimkind;
  %vdata.curdata.flag.InterMarkAveraging = false;
  
  % Delete handle
  for idxh = 1:length(vdata.handle),
    try
      if ishandle(vdata.handle(idxh)),
        delete(vdata.handle(idxh));
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
