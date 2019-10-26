function varargout=p3_ViewCommCallback(fnc,varargin)
% Toolbox of Common-Callback Function's  Main-Control
%
% More Information :
%  "How to Plugin Axes-Object"
%  Manual : Signal-Viewer II
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User's Function's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------
% Syntax :
%    p3_ViewCommCallback
%----------------------------------
%     Help of the function
%
%----------------------------------
% Syntax :
%    ID=p3_ViewCommCallback('checkin',h, name, gca0, curdata, obj)
%      h    : Handles of Object that Drawn by Axes-Object
%      name : Special-Name of Axes-Object.
%             It's can be overwrap,
%             but It might be better to set unique name.
%     gca0  : Handle of Object's Parents Axes
%     curdata : Current-Data in the situation.
%     obj   : View-Axes-Object Data
%
%     ID    : ID of the Axes-Object
%----------------------------------
%      Check in to All-Common Callback.
%
%----------------------------------
% Syntax :
%    p3_ViewCommCallback('Update',h, name, gca0, curdata, obj,id)
%      h, name, gca0, curdata, obj is defined already.
%     id    : ID of the Axes-Object.
%             ID is always managed by the Viewer II.
%             (is as same as Object ID)
%----------------------------------
%      Update Current data or there situation.
%
%----------------------------------
% Syntax :
%    data=p3_ViewCommCallback('getdata', gca0, name, id)
%     data : Data is structure that defined following.
%            data.handle  = h;
%            data.axes    = gca0;
%            data.curdata = curdata;
%            data.obj     = obj;
%     h, gca0, curdata, obj, name, id is defined already.
%----------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------
% Syntax :
%  userdata = p3_ViewCommCallback('makeUD');
%     userdata : Structure that define Common-Callback-List
%                userdata.str : Cell Array of String : Display name
%                userdata.ud  : Cell Array of
%                               Common-Callback-Object information.
%----------------------------------
%
%
%   See also : VIEWGROUPCALLBACK,
%              LAYOUTMANAGER,
%              OSP_LAYOUTVIEWER.


% == History ==
% original author : Masanori Shoji (ULSI)
% create : 2006.04.25
% $Id: _osp_ViewCommCallback.m 352 2013-05-08 02:42:56Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% ==> No argument : Help
if nargin==0 || strcmpi(fnc,'Help'),
  OspHelp(mfilename); return;
end
fnc=lower(fnc);
if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0,
  %---------------
  % Function List
  %---------------
  checkin;
  update;
  getdata;
  makeud;  % OSP Only
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ID=checkin(handles, name, gca0, curdata, obj)
% ==> Check in Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================
% Make Checkin Data
%=======================
data.handle  = handles;
data.axes    = gca0;
data.curdata = curdata;
data.obj     = obj;

%=======================
% Push Application Data
%  -- Fullset-Data --
%=======================
datalist=getappdata(curdata.gcf,name);
datalist{end+1}=data;
setappdata(curdata.gcf,name,datalist);
% ==> Define ID
ID=length(datalist);

%=====================================
% Checking Status to checkin AO to CO
%=====================================
% This Block (==) IO
%----------------------
% In  : curdata, obj
% OUT : info (Axes Object Information)
%----------------------
% Modify Meeting on 08-Nov-2007
if ~isfield(curdata,'CommonCallbackData')
  return;
end
if ~iscell(curdata.CommonCallbackData)
  errordlg(...
    {'===================================',...
    ' [P3] Error : ',...
    '====================================',...
    'Common-Callback-Data Format Error: ',...
    '    Data-Format must be Cell-Array'},...
    '[P3] Common Callback Data Format Error','replace');
  return;
end

try
  info=feval(obj.fnc,'createBasicInfo');
  if ~isfield(info,'ccb'),return;end
  if ~iscell(info.ccb),info.ccb={info.ccb};end
  % Current Auto :
  if strcmpi(info.ccb{1},'auto')
    info.ccb={'all'};
  end
catch
  warndlg({'Error Occur in Checkin : ',lasterr, ...
    'Function : ' obj.fnc},'Check-in Error','replace');
  return;
end

%=======================
% Set up Callback Object
%=======================
% Make Additonal User Data.
udadd.axes     = gca0;
udadd.ObjectID = ID;
udadd.name     = name;
% TODO: 
% --> swich by info <---
udadd.str      = [obj.fnc, ...
  '(''draw'',data.axes, data.curdata, data.obj, ud{idx}.ObjectID);'];


%===========================
% Checkin 
%===========================
for id1=1:length(curdata.CommonCallbackData)
  CCD=curdata.CommonCallbackData{id1};
  %-----------------
  % Can I Check-in?
  %-----------------
  if ~strcmpi(info.ccb{1},'all')
    if isempty(intersect(CCD.CurDataValue,info.ccb))
      continue;
    end
  end

  %----------
  % Check in
  %----------
  ud=get(CCD.handle,'UserData');
  if isempty(ud)
    ud={udadd};
  else
    ud{end+1}=udadd;
  end
  set(CCD.handle,'UserData',ud);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update(handles, name, gca0, curdata, obj, ID)
% Update Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.handle  = handles;
data.axes    = gca0;
data.curdata = curdata;
data.obj     = obj;

% Update Data
%axes(gca0);
set(curdata.gcf,'CurrentAxes',gca0);
datalist=getappdata(curdata.gcf,name);

datalist{ID}=data;
setappdata(curdata.gcf,name,datalist);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getdata(gca0,name,ID)
% Update Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update Data
f=get(gca0,'Parent');
set(0,'CurrentFigure',f);
set(f,'CurrentAxes',gca0);
%axes(gca0);
datalist=getappdata(f,name);
data=datalist{ID};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud0 = makeud()
% Setup : CommonCallbacks
%        Called ViewGroupCallback
%
% === Warning ===
% This Code is for OSP :Layout-Manager!!
%  So in P3, following code was not called.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%str0={'Data','Channel','Kind','TimeRange','TimePoint'};
fnc={'osp_ViewCallbackC_Data', ...
  'osp_ViewCallbackC_Channel', ...
  'osp_ViewCallbackC_DataKind', ...
  'osp_ViewCallbackC_TimePoint'};
%       'osp_ViewCallbackC_TimeRange', ...
ud={};
str={};

% - get data -
% info.uicontrol={'checkbox','listbox','radiobutton',...
% 'togglebutton', ...
% 'edit','popupmenu','slider', ...
% 'frame', ...
% 'pushbutton','text'};
for idx=1:length(fnc),
  try
    if ~exist(fnc{idx},'file'),continue;end
    info  = feval(fnc{idx}, 'createBasicInfo');
    u0    = info;
    s0    = info.name;
    if isfield(info,'uicontrol'),
      % if success to get all data
      [ud{end+1}, str{end+1}] = ...
        deal(u0,s0);
    else
      error([ s0 ': No Uicontrol Exist!!']);
    end
  catch
    % Now allow Error
    % warning(lasterr);
  end
end
ud0.str=str;
ud0.ud = ud;


