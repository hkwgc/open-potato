function varargout=osp_ViewCallback_YAxisRange(fcn,varargin)
% Y-Axis Range Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_YAxisRange.m 180 2011-05-19 09:34:28Z Katura $


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
%         'Y Axis Range'
%       Myfunction Name
%         'vcallback_YAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Y AxisRange';
  basicInfo.fnc    ='osp_ViewCallback_YAxisRange';
  % File Information
  basicInfo.rver   ='$Revision: 1.6 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/10/27 08:30:24 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_YAxisRange'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='Y Axis';
  data.fnc ='osp_ViewCallback_YAxisRange';
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
  str=['curdata=osp_ViewCallback_YAxisRange(''make'',handles, abspos,' ...
       'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
  pos=getPosabs(obj.pos,apos);
  
  initstr='auto';
  curdata.Callback_YRange.handles= ...
      uicontrol(hs.figure1,...
		'Style','edit','String',initstr, ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position',pos, ...
                'TooltipString','Y Axis Property or Range Setting', ...
                'Tag','Callback_YAxisrange', ...
		'Callback', ...
		['osp_ViewCallback_YAxisRange(''yaxis_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
  %ud1st=initstr;
  set(curdata.Callback_YRange.handles, ...
      'UserData',{});
  %    'UserData',{ud1st});

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axisstr = get(hObject,'String');
try,
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  % User Data
  ud     = get(hObject,'UserData');
  % Get , Check Axis property
  axisv=[];
  if isempty(axisstr),
	  h=errordlg('Input Axis Property or Input Axis Range.');
	  waitfor(h);return;
  end
  if checkAxisStr(axisstr)>0,
	  try,
		  axisv = str2num(axisstr);
		  if isempty(axisv),
			  h=errordlg('Input Axis Range.');
			  waitfor(h);return;
		  end
		  if length(axisv)==2,
			  aaxisv=axisv;
			  axisv(1:2)=[min(aaxisv) max(aaxisv)];
		  elseif length(axisv)<2,
			  axisv(2)=axis;axisv(1)=0;
		  else
			  h=errordlg('Input Axis Range.');
			  waitfor(h);return;
		  end
	  catch,
		  h=errordlg('Input Axis Property or Input Axis Range.');
		  waitfor(h);return;
	  end
  end

  % Set 'default'string --Special prpcess
  if strcmp(axisstr, 'default'), 
    set(hObject,'String', '\default');
  else
    set(hObject,'String', axisstr);
  end
 
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
% Optional Variable
%    axisstr  : String of this Object(Axis Property)
%    axisv    : String of this Object(Axis Range)

for idx=1:length(ud),
    try
        %eval(ud{idx}.str);
	% Get Current Axes
	axes(ud{idx}.axes);
	if isempty(axisv),
	  if strcmp(axisstr, 'default')==1,
	    %axis auto;
	    a=axis;
	    a(3:4)=ud{idx}.default(3:4);
	    axis(a);
	  else
	    axis(axisstr);
	  end
	else
	  %axis auto;
	  a=axis;
	  a(3:4)=axisv;
	  axis(a);
	end
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

function flg=checkAxisStr(str),
% Get axis property
  flg=0;   % ==Property
  if strcmp(str, 'auto')==0 && ...
     strcmp(str, 'manual')==0 && ...
     strcmp(str, 'tight')==0 && ...
     strcmp(str, 'full')==0 && ...
     strcmp(str, 'default')==0 && ...
     strcmp(str, 'on')==0 && ...
     strcmp(str, 'off')==0 ,
    flg=1; % == Range
  end
return;
