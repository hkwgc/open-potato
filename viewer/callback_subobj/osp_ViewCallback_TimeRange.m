function varargout=osp_ViewCallback_TimeRange(fcn,varargin)
% Time Range Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_TimeRange.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%       Display-Name of the Plagin-Function.
%         'Time Range'
%       Myfunction Name
%         'vcallback_TimeRange'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Time Range';
  basicInfo.fnc    ='osp_ViewCallback_TimeRange';
  % File Information
  basicInfo.rver   ='$Revision: 1.7 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/10/27 08:30:24 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_TimeRange'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='Time Range';
  data.fnc ='osp_ViewCallback_TimeRange';
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
   str=['curdata=osp_ViewCallback_TimeRange(''make'',handles, abspos,' ...
        'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos,curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
  pos=getPosabs(obj.pos,apos);
  %=====================
  % Set Special User Data
  % <- User Data 1 is Special ->
  %=====================
  if iscell(cdata),
    timelen=size(cdata{1},1);
    t0=1:size(cdata{1},1); t=(t0 -1)*chdata{1}.samplingperiod/1000;
  else,
    timelen=size(cdata,1);
    t0=1:size(cdata,1); t=(t0 -1)*chdata.samplingperiod/1000;
  end
  range=[t(1) t(timelen)];
  curdata.Callback_TimeRange.handles= ...
      uicontrol(hs.figure1,...
		'Style','edit','String',num2str(range), ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position',pos, ...
                'TooltipString','Time-Range Setting', ...
                'Tag','Callback_TimeRange', ...
		'Callback', ...
		['osp_ViewCallback_TimeRange(''timerange_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
  ud1st=num2str(range);
  set(curdata.Callback_TimeRange.handles, ...
      'UserData',{ud1st});

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timerange_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try,
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  % User Data
  ud     = get(hObject,'UserData');
  % Get , Check Time
  timestr = get(hObject,'String'); 
  time = str2num(timestr); 
  time = round(time);
  if ~isempty(find(time(:)<0)),
    h=errordlg('Input time>0.');
    waitfor(h);return;
  end

  % Error Check
  if length(time)==2,
    ttime=time;
    time(1:2)=[min(ttime) max(ttime)];
  elseif length(time)<2 && time>0,
    time =[0 time];
  else
    h=errordlg('Input time>0.');
    waitfor(h);return;
  end


  set(hObject,'String',num2str(time));
 
catch,
  % Error Operation
  errordlg({' OSP Error!', ...
	    ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
  return;
end

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    time     : [start end]
%
% Optional Variable
%    timestr  : String of this Object

for idx=2:length(ud),
    try
        eval(ud{idx}.str);
    catch
        warning(lasterr);
    end
end
set(hObject,'UserData',ud);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos),
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
