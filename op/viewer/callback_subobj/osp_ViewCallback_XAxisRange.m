function varargout=osp_ViewCallback_XAxisRange(fcn,varargin)
% X-Axis Range Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_XAxisRange.m 298 2012-11-15 08:58:23Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%---------------
% History
%---------------
% Revisiton 1.8:
%     2007.07.l8 : shoji
%      1. Modify for (part) FFT.
%      2. bugfix : too slow

%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else
    feval(fcn, varargin{:});
  end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'X Axis Range'
%       Myfunction Name
%         'vcallback_XAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='X AxisRange';
  basicInfo.fnc    ='osp_ViewCallback_XAxisRange';
  % File Information
  basicInfo.rver   ='$Revision: 1.9 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2008/09/24 04:33:02 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_XAxisRange'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='X Axis';
  data.fnc ='osp_ViewCallback_XAxisRange';
  data.pos =[0, 0, 0.2, 0.1];
  prompt={'Position : '};
  pos{1} = num2str(data.pos);
  flag=true;
  while flag,
    pos = inputdlg({'Relative Position : '}, ...
		   'Callback Position', 1,pos);
    if isempty(pos), break; end
    try
      pos0=str2num(pos{1});
      if ~isequal(size(pos0),[1,4]),
	wh=warndlg('Number of Input Data must be 4-numerical!');
	waitfor(wh);continue;
      end
      if any(pos0>1) || any(pos0<0)
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
  str=['curdata=osp_ViewCallback_XAxisRange(''make'',handles, abspos,' ...
       'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj)
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
  pos=getPosabs(obj.pos,apos);
  initstr='auto';
  curdata.Callback_XRange.handles= ...
      uicontrol(hs.figure1,...
		'Style','edit','String',initstr, ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position',pos, ...
                'TooltipString','X Axis Property or Range Setting', ...
                'Tag','Callback_XAxisrange', ...
		'Callback', ...
		['osp_ViewCallback_XAxisRange(''xaxis_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
  %ud1st=initstr;
  set(curdata.Callback_XRange.handles, ...
      'UserData',{});
  %    'UserData',{ud1st});
  
  % Common Callback
  CCD.handle=curdata.Callback_XRange.handles;
  CCD.CurDataValue={'X_Axis1','X_Axis'};
  CCD.Name = 'X_Axis1';
  if isfield(curdata,'CommonCallbackData')
    curdata.CommonCallbackData{end+1}=CCD;
  else
    curdata.CommonCallbackData={CCD};
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xaxis_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  axisv=getAxisValue(hObject);
catch
  % Error Operation
  h=errordlg({' OSP Error!', ...
    ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
  waitfor(h);
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

% User Data
ud     = get(hObject,'UserData');
for idx=1:length(ud),
  try
    if isfield(ud{idx},'ObjectID')
      % Execute for Common-Control Type
      % Get Data
      data = p3_ViewCommCallback('getData', ...
        ud{idx}.axes, ...
        ud{idx}.name, ud{idx}.ObjectID);
      data.curdata.Xaxis=axisv;
      obj=data.obj;      
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
      % Draw
      feval(obj.fnc,'draw',data.axes, data.curdata, data.obj, ud{idx}.ObjectID);
    else
      %eval(ud{idx}.str);
      % Get Current Axes
      set(gcbf,'CurrentAxes',ud{idx}.axes);
      if isnumeric(axisv),
        % Numerical Value
        a=axis;
        a(1:2)=axisv;
        axis(a);
      else
        % String (auto/tight .. and so on
        if strcmp(axisv, 'default')==1,
          axis auto;
          a=axis;
          a(1:2)=ud{idx}.default(1:2);
          axis(a);
        else
          axis(axisv);
        end
      end
    end
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);


function axisv=getAxisValue(hObject)
%--  Default Color --
set(hObject,'ForegroundColor','black');
% -- Getting Variable --
% Get , Check Axis property
axisv=[];
axisstr = get(hObject,'String');
if isempty(axisstr),
  error('Input Axis Property or Input Axis Range.');
end
if checkAxisStr(axisstr)>0,
  % Axis-String is Range
  try
    axisv = str2num(axisstr);
    if isempty(axisv),
      error('Invalid Strings for Axis-Range.');
    end
    if length(axisv)==2,
      aaxisv=axisv;
      axisv(1:2)=[min(aaxisv) max(aaxisv)];
    elseif length(axisv)==1
      axisv(2)=axisv(1);
    else
      error('Invalid Strings.');
    end
  catch
    error('Input Axis Property or Input Axis Range.');
  end
else
  % value..
  axisv=axisstr;
end
    
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

function flg=checkAxisStr(str)
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
