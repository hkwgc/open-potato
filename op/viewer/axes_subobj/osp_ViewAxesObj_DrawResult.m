function varargout=osp_ViewAxesObj_DrawResult(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_DrawResult is "View-Axes-Object",
% so osp_ViewAxesObj_DrawResult is based on the rule.
%
% osp_ViewAxesObj_DrawResult use "Common-Callback",
% so osp_ViewAxesObj_DrawResult is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax :
%   osp_ViewAxesObj_DrawResult
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax :
% varargout=osp_ViewAxesObj_DrawResult(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% $Id: osp_ViewAxesObj_DrawResult.m 298 2012-11-15 08:58:23Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == Warning !! ==
% When you want to edit this function,
%  you must be based on View-Axes-Object rules.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No argument : Help : (Defined in View-Axes-Object )
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0
  createBasicInfo;
  getArgument;
  drawstr;
  draw;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='Draw Results';
info.fnc     = mfilename;
% Useing Common-Callback-Object
info.ccb     = {'Data',...
  'Channel', ...
  'Kind', ...
  'TimeRange'};
% No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% --- for change ---
if length(varargin)>=1,
  data=varargin{1};
end
data.str = 'Draw Results';
data.fnc = mfilename;
data.ver = 1.00;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% DrawStr :
%
% See also osp_ViewAxesObject_PlotTest/getArgument,
%          ViweGroupAxes/exe,
%          p3_ViewCommCallback.
str=['osp_ViewAxesObj_DrawResult(''draw'', ', ...
  'h.axes ,curdata, obj{idx})'];
if 0,disp(varargin);end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw Executtion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=draw(gca0, curdata,obj, ObjectID)
% Draw / Redraw Line-Axes-Object
%
% GCA0      : The Draw Axeis( Usually Current Axis);
% CURDATA   : Current Data in Drawing.
%             Defined in ViewerII ->
%             rf). osp_LayoutViewer
% OBJ       : This Axes-Object.
%             Made in subfunction getArgument.
% OBJECT_ID : When draw   : There is no ObjectID.
%             When Redraw : INDEX of Redraw Object.
%             This variable for CommonCallabck.


% Load Current Data
[hdata,data]=...
  osp_LayoutViewerTool('getCurrentDataRaw',curdata.gcf,curdata);
% !! data might be used in evaluate function !!
if 0,disp(data);end 
if ~isfield(hdata,'Results'),return;end

% Position Map : used for reshaping axes.
posmap=mat2pos(10,3,1);
if ~exist('ObjectID','var'),
  % get Default Axes Size
  axespos=get(gca0,'Position');
  axesunit=get(gca0,'Unit');
  % Set Default Axes Size
  curdata.axespos=axespos;
  curdata.axesunit=axesunit;
  %-----------------------
  % Making Select Control
  %----------------------
  fs=fieldnames(hdata.Results);
  str={};
  for idx=1:length(fs)
    x=eval(['hdata.Results.' fs{idx}]);
    if isfield(x,'CommonDrawProperty')
      str{end+1}=fs{idx};
    end
  end
  if isempty(str),return;end; % No Plot Data ....
  % matrix 10x3 of 1
  pos=posmap;
  pos=getPosabs(pos,axespos);
  sch=uicontrol;
  set(sch,'style','popupmenu','Value',1,'String',str,...
    'Units',axesunit,'Position',pos,'UserData',cell([1,length(str)+1]));
  curdata.ResultsSelectHandle=sch;
else
  % get Default Axes Size
  axespos=curdata.axespos;
  axesunit=curdata.axesunit;
end

%-----------------------
% Loading Data
%----------------------
str=get(curdata.ResultsSelectHandle,'String');
ud0=get(curdata.ResultsSelectHandle,'UserData');
vl=get(curdata.ResultsSelectHandle,'Value');
str=str{vl};

if ~isempty(ud0{end}) && isfield(ud0{end},'hs')
  set(ud0{end}.hs,'Visible','off');
end

result =eval(['hdata.Results.' str]);
ud=ud0{vl};
if isempty(ud) && isfield(result.CommonDrawProperty,'Control')
  
  %---------------
  % Make Control
  %---------------
  ud.hs=[];
  for idx=1:length(result.CommonDrawProperty.Control)
    ctrl=result.CommonDrawProperty.Control{idx};
    eval(ctrl.DefaultValueString); % get default value
    ud.hs(end+1)=uicontrol;
    % now:only listobx/popupmenu
    set(ud.hs(end),'Style',ctrl.mode,...
      'String',ctrl.variable.str,...
      'UserData',{ctrl.variable.val{:},curdata.ResultsSelectHandle},...
      'Unit',axesunit,...
      'Callback',...
      sprintf('ud=get(gcbo,''UserData'');%s(''main_callback'',ud{end})',mfilename));
    if 0, main_callback;end
    if isfield(ctrl,'ObjectProperty')
      set(ud.hs(end),ctrl.ObjectProperty{:});
    end
    % setup position
    if isfield(ctrl,'Position')
      pstr=ctrl.Position;
    else
      pstr='top';
    end
    if isnumeric(pstr)
      matpos=pstr; % direct position by Matrix 
      pstr='array';
    end
      
    try
      
      switch lower(pstr)
        case {'top','rtop'},
          % Top Position
          pos = mat2pos(10,3,3);
        case 'ctop'
          % Top Position
          pos = mat2pos(10,3,2);
        case 'lbottom'
          % Button Position
          pos = mat2pos(10,3,28);
        case 'cbottom'
          % Button Position
          pos = mat2pos(10,3,29);
        case {'rbottom','bottom'};
          % Button Position
          pos = mat2pos(10,3,30);
        case 'array'
          pos  = mat2pos(matpos(1),matpos(2),matpos(3));
          
        otherwise
          warning('no position exist now');
      end
      pos0  = getPosabs(pos,axespos);
      set(ud.hs(end),'Position',pos0);
      posmap(end+1,:)=pos;
    catch
      % --> no position property?
    end
    ud.posmap=posmap;
  end
elseif isfield(result.CommonDrawProperty,'Control')
  % get Value
  for idx=1:length(result.CommonDrawProperty.Control)
    ctrl=result.CommonDrawProperty.Control{idx};
    htmp=ud.hs(idx);
    myval =get(htmp,'Value');
    setval=get(htmp,'UserData');
    eval([ctrl.varname '=setval{myval};']);
    if 0,disp(setval{myval});end
  end    
  if isfield(ud,'hs')
    set(ud.hs(ishandle(ud.hs)),'Visible','on');
  end
end
if isfield(ud,'posmap'),  posmap=ud.posmap; end

% ===> Change Axes Position <=== %
posmap(:,[3,4])=posmap(:,[1,2])+posmap(:,[3,4]);
% Bit : top    : 1
%       bottom : 2
%       right  : 4
%       left   : 8
t=posmap(:,2)>0.75;
b=posmap(:,4)<0.25;
r=posmap(:,1)>0.75;
l=posmap(:,3)<0.25;
pospos= t + 2*b + 4*r + 8*l;

% remove too large compornent
rm0=find((t+b+r+l)>=3);
if ~isempty(rm0),
  warning('Too Large Control Exist');
  pospos(rm0)=0;
end
rm0=find((t+b)>=2);
if ~isempty(rm0),
  warning('Too Large Control Exist');
  pospos(rm0)=0;
end
rm0=find((r+l)>=2);
if ~isempty(rm0),
  warning('Too Large Control Exist');
  pospos(rm0)=0;
end


axespos1=[0 0 1 1];
% bottom element ?
if ~isempty(find(pospos==2))
  axespos1(2)=max(posmap(logical(bitget(pospos,2)),4));
end

% top element ?
if ~isempty(find(pospos==1))
  axespos1(4)=min(posmap(logical(bitget(pospos,1)),2));
end
axespos1(4)=axespos1(4)-axespos1(2);


% left element ?
if ~isempty(find(pospos==8))
  axespos1(1)=max(posmap(logical(bitget(pospos,4)),4));
end

% right element ?
if ~isempty(find(pospos==4))
  axespos1(3)=min(posmap(logical(bitget(pospos,3)),2));
end
axespos1(3)=axespos1(3)-axespos1(1);

axespos1  = getPosabs(axespos1,axespos);

% Set Default Axes Size
set(gca0,'Unit',axesunit,'Position',axespos1);



%--------------------------
% Make Data Set
%--------------------------
if ~isfield(result.CommonDrawProperty,'DataName')
  eval(result.CommonDrawProperty.DataString);
else
  if isfield(result.CommonDrawProperty.DataName,'X');
    eval(result.CommonDrawProperty.DataName.X);
  end
  if isfield(result.CommonDrawProperty.DataName,'Y');
    eval(result.CommonDrawProperty.DataName.Y);
  end
  if isfield(result.CommonDrawProperty.DataName,'Z');
    eval(result.CommonDrawProperty.DataName.Z);
  end
end

%--------------------------
% Draw
%--------------------------
if isfield(result.CommonDrawProperty,'DrawString')
  eval(result.CommonDrawProperty.DrawString);
else
  fstr=lower(result.CommonDrawProperty.DrawType);
  switch fstr
    case {'plot','bar'}
      f=eval(['@' fstr ';']);
      if ~exist('Y','var')
        feval(f,X);
      elseif ~exist('X','var')
        feval(f,Y);
      else
        feval(f,X,Y);
      end
    case 'plot3'
      plot3(X,Y,Z);
    case 'image'
      if exist('Z','var')
        if exist('Y','var') && ~exist('X','var')
          image(X,Y,Z);
        else
          image(Z);
        end
      elseif exist('C','var')
        if exist('Y','var') && ~exist('X','var')
          image(X,Y,C);
        else
          image(C);
        end
      elseif ~exist('X','var')
        image(Y);
      elseif ~exist('Y','var')
        image(X);
      end
    otherwise
      warning('Undefined Draw-Type');
  end
end
h.h=get(gca0,'Children'); %<--- all

if isfield(result.CommonDrawProperty,'AxisProperty');
  eval(result.CommonDrawProperty.AxisProperty);
end
%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_PlotTest_ObjectData';

if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', ...
    h.h, myName, ...
    gca0, curdata, obj, ObjectID);
else
  ObjectID=p3_ViewCommCallback('CheckIn', ...
    h.h, myName, ...
    gca0, curdata, obj);
  set(curdata.ResultsSelectHandle,'UserData',ud0);
  set(sch,'Callback',[mfilename  '(''main_callback'',gcbo);']);
end
ud.axes=gca0;
ud.name=myName;
ud.ObjectID=ObjectID;
ud0{end}=ud;
ud0{vl} =ud;
set(curdata.ResultsSelectHandle,'UserData',ud0);

%==========================================================================
function main_callback(h)
% Callback of Result Selector
%==========================================================================
ud=get(h,'UserData');
data=p3_ViewCommCallback('getData',...
  ud{end}.axes,ud{end}.name,ud{end}.ObjectID);
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
draw(data.axes, data.curdata, data.obj, ud{end}.ObjectID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos,x,y]=mat2pos(n,m,p)
% Matrix ID 2 position (is as same as subplot)
% [pos,x,y]=mat2pos(n,m,p)
%==========================================================================

% mesh size
nsz = 1/n;
msz = 1/m;

% p --> index
n1=floor(p/m-0.000001); % Top
m1=p-n1*m-1;   % Left

% make position data
pos(4) = nsz;
pos(3) = msz;
pos(1) = m1*msz;
pos(2) = 1-(n1+1)*nsz;

if nargout>=2
  x=[pos(1),pos(1)+pos(3)];
end
if nargout>=3
  y=[pos(2), pos(2)+pos(4)];
end
% debug
if 0
  x=[pos(1),pos(1)+pos(3),pos(1)+pos(3),pos(1),pos(1)];
  y=[pos(2),pos(2), pos(2)+pos(4),pos(2)+pos(4),pos(2)];
  fill(x,y,'r');
end

%==========================================================================
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position 
%==========================================================================
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
