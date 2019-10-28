function varargout=Lparts_Manager(fnc,varargin)
% P3-Layout-Editor : Layout-Parts 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2007.02.19
% $Id: Lparts_Manager.m 180 2011-05-19 09:34:28Z Katura $

if isempty(fnc),OspHelp(mfilename);end
  
%======== Launch Switch ========
switch fnc,
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'ChangeTgl',
    ChangeTgl(varargin{:});
  case 'getLPOfunction',
    varargout{1}=getLPOfunction(varargin{:});
  otherwise,
    if nargout==0,
      feval(fnc,varargin{:});
    else
      [varargout{1:nargout}]=feval(fnc,varargin{:});
    end
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of Layout'Parts-Object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================
function lp=LayoutPartsObjectList
% List of Layout-Parts-Object
%===============================
lp = {@Lparts_Figure,... 
      @Lparts_Area,...
      @Lparts_Axis,... 
      @Lparts_object,... 
      @Lparts_control,... 
      @Lparts_special_control}; 
if 0, % UNPOPULATED
lp = {@Lparts_Figure,...
    @Lparts_Area,...
    @Lparts_Axis,...
    @Lparts_object,...
    @Lparts_control,...
    @Lparts_special_control};
end % UNPOPULATED
return;

%===============================
function fnc=getLPOfunction(LP)
% Check-Kind-of Layout-Parts
%===============================

fnc=[];
%------------------------------
% Object / Control
%------------------------------
if isfield(LP,'fnc')
  % Axes-Object
  if strcmpi(LP.fnc(1:15),'osp_ViewAxesObj')
    fnc=@Lparts_object;
    return;
  elseif strcmpi(LP.fnc(1:16),'osp_ViewCallback')
    % Control
    if strcmpi(LP.fnc(17),'C'),
      fnc=@Lparts_control;
    else
      fnc=@Lparts_special_control;
    end
    return;
  elseif strcmpi(LP.fnc(1:10),'LAYOUT_AO_')
    fnc=@Lparts_object;
    return;
  elseif strcmpi(LP.fnc(1:10),'LAYOUT_CO_')
    fnc=@Lparts_special_control;
    return;
  elseif strcmpi(LP.fnc(1:11),'LAYOUT_CCO_')
    %    fnc=@Lparts_control;
    fnc=@Lparts_special_control;
    return;
  else
    error('Unknown Layout-Parts Type');
  end
end

%------------------------------
% View-Gruop-Object
%------------------------------
if isfield(LP,'MODE'),
  if strcmpi(LP.MODE,'ViewGroupAxes')
    fnc=@Lparts_Axis;
    return;
  elseif strcmpi(LP.MODE,'ViewGroupArea')
    % TODO:
    fnc=@Lparts_Area;
    return;
  end
end

%------------------------------
% Figure
%------------------------------
if isfield(LP,'vgdata')
  fnc=@Lparts_Figure;
  return;
end
fnc=[];

%================================
function hs=resetLPO(hs,suspendflag)
% Make Property Setting GUIS
%  hs : Handles of LayoutEditor
%================================

if nargin<2,  suspendflag=true; end

% Suspend All
if suspendflag,
  lp=LayoutPartsObjectList;
  for idx=1:length(lp)
    feval(lp{idx},'Suspend',hs);
  end
end

% Set Application Data
%     : 
setappdata(hs.figure1,'CurrentLPOfnc',[]);
setappdata(hs.figure1,'CurrentLPOabspos',[0 0 1 1]);
% (2) : 
setappdata(hs.figure1,'CurrentLPOpath',[]);
% (4) : 
setappdata(hs.figure1,'CurrentLPOischange',false);
% (5) : 
setappdata(hs.figure1,'CurrentLPOdata',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function hs=Create(hs)
% Make Property Setting GUIS
%  hs : Handles of LayoutEditor
%================================

% reset Default-Application Data
resetLPO(hs,false);


% Function List
lp=LayoutPartsObjectList;
for idx=1:length(lp)
  hs=feval(lp{idx},'Create',hs);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================
function setLPO(hs,LP,path0,abspos)
% Set LPO to the GUI : Code ID=F3
%===============================

% Suspend All
lp=LayoutPartsObjectList;
for idx=1:length(lp)
  feval(lp{idx},'Suspend',hs);
end
setappdata(hs.figure1,'CurrentLPOpath',path0);
setappdata(hs.figure1,'CurrentLPOabspos',abspos);
setappdata(hs.figure1,'CurrentLPOischange',false);

% Select Functions
fnc=getLPOfunction(LP);
if isempty(fnc),return;end

% Activation & Setting
feval(fnc,'setParts',hs,LP)
feval(fnc,'Activate',hs);
setappdata(hs.figure1,'CurrentLPOfnc',fnc);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Save  + Alpha..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================
function saveLPO(hs)
% Save Current LPO : Code ID=F1
%===============================

% Check Current-Data? 
% Load : (4)
if ~getappdata(hs.figure1,'CurrentLPOischange'),return;end
fnc=getappdata(hs.figure1,'CurrentLPOfnc');
if isempty(fnc),return;end

% Load (2)
p=getappdata(hs.figure1,'CurrentLPOpath');

% 2007.03.02:
%   bugfix (in-testing...)
%   Expand-Flag Marge
% ==> get Expand Flag
LP0=LayoutPartsIO('get',hs,p);
% Load (5)
LP=feval(fnc,'getParts',hs);
if isfield(LP0,'ExpandFlag'),
  LP.ExpandFlag=LP0.ExpandFlag;
end

% save (1)
LayoutPartsIO('set',hs,LP,p);
% Set : (4)
setappdata(hs.figure1,'CurrentLPOischange',false);

%===========================================
function saveAndTree(hs)
% Save Current LPO & Make-Tree : Code ID=F1x
%===========================================
saveLPO(hs);
create_layoutTreelist(hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Over View I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveAndTreeAndOV(hs)
% Save Current LPO & Make-Tree : Redraw Overview
% nealy equal lbx_select, but no reselect
%===========================================
setappdata(hs.figure1,'CurrentLPOischange',true);
saveLPO(hs);
create_layoutTreelist(hs);
% Load (2)
p=getappdata(hs.figure1,'CurrentLPOpath');

% Redraw Over-View
if ~ishandle(hs.fig_OverView),
  hs.fig_OverViwe=LE_OverView;
  guidata(hs.figure1,hs);
end

LAYOUT=LayoutPartsIO('get',hs,[]);
try
  LE_OverView('Redraw',...
    hs.fig_OverView,[],...
    guidata(hs.fig_OverView),...
    LAYOUT,p);
catch
  disp('------------------------------');
  disp(['TODO :' C__FILE__LINE__CHAR]);
  disp(lasterr);
  disp('------------------------------');
end


%===========================================
function OverviewChangePossition(hs,pos)
% Save Current LPO & Overview : (2-2)
%===========================================
%saveLPO(hs); %% needless. may be.
% Redraw Over-View
if ~ishandle(hs.fig_OverView),
  hs.fig_OverViwe=LE_OverView;
  guidata(hs.figure1,hs);
end

% ==> To Kidachi
% Relative Position of The Layout-Parts (Changeed)
posdata.pos     = pos; 
% Absolute Position of Parent Layout-Parts.
posdata.abspos = getappdata(hs.figure1,'CurrentLPOabspos');
% Path of the Layout-Parts
posdata.path    = getappdata(hs.figure1,'CurrentLPOpath');

try
  % TODO : Kidachi
  LE_OverView('ChangePossition',...
    hs.fig_OverView,[],...
    guidata(hs.fig_OverView),...
    posdata);
catch
  disp('------------------------------');
  disp(['TODO :' C__FILE__LINE__CHAR]);
  disp(lasterr);
  disp('------------------------------');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receive Pos from OV + Set gui
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================
function setPosition(hs,pos)
% Change Absolute-Position by LE_overview-pos
%                            : Code ID=F7
%===============================
% Get Current-Data 
fnc=getappdata(hs.figure1,'CurrentLPOfnc');
if isempty(fnc),return;end

% Load Relative-Position-handle
[poshs, aposhs]=feval(fnc,'getPoshandle',hs);
if isempty(poshs),return;end

% Set Value
%Absolute-Position to Relatine-Position  
set(aposhs,'String', num2str(pos,'%4.2f  '));
ChangeAPOS(aposhs,hs,false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Over-View Draw Function's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ov_draw(LP,abspos,curpath,drawpath)
%  LP       : Layout-Parts.
%  abspos   : Absorute Positon
%  curpath  : Current LPO's path
%  drawpath : Draw LPO's path
fnc=getLPOfunction(LP);
h=[];
try
  if isempty(curpath),
    % current Figure
    h=feval(fnc,'ov_draw',LP,abspos,0);
  elseif isequal(curpath,drawpath),
    % Current LPO
    h=feval(fnc,'ov_draw',LP,abspos,2);
  elseif isequal(curpath(1:end-1),drawpath(1:end-1)),
    % Current LPO Region
    h=feval(fnc,'ov_draw',LP,abspos,1);
  %elseif curpath(end)<0 && isequal(curpath(1:end-1),drawpath),
  elseif isequal(curpath(1:end-1),drawpath),
    % (C-Object Area
    h=feval(fnc,'ov_draw',LP,abspos,3);
  else
    % Otherwise
    h=feval(fnc,'ov_draw',LP,abspos,0);
  end
catch
  lpos=[0 0 1 1];
  absp=LayoutPartsIO('getPosabs',lpos,abspos);
  x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1);absp(1)];
  y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4);absp(2)];
  h = line(x,y);  
  set(h,'Color',[0.4,0.4,0.4]);
  % TODO :
  disp(['TODO : ov_draw' func2str(fnc)]);
  disp(C__FILE__LINE__CHAR);
  disp(lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common-Callback from LPO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function ChangeName(hs)
% Callback of Change-Name
%================================

% Set : (4)
setappdata(hs.figure1,'CurrentLPOischange',true);
saveLPO(hs);

%================================
function ChangeRPOS(h,hs,flg)
%================================
% Callback of Relative-Postion
isNG = getposWithCheck(h,hs);
if isNG,return;end
% Set : (4)
if nargin<=2
  setappdata(hs.figure1,'CurrentLPOischange',true);
else
  setappdata(hs.figure1,'CurrentLPOischange',flg);
end

ud      = get(h,'UserData'); pos0=ud.data;
% RelativePos => AbsolutePos
pos = getappdata(hs.figure1,'CurrentLPOabspos');
ud.data([1,3]) = ud.data([1,3])*pos(3);
ud.data([2,4]) = ud.data([2,4])*pos(4);
ud.data(1:2)   = ud.data(1:2)+pos(1:2);
set(ud.aposh,...
  'UserData',ud,...
  'String',num2str(ud.data,'%4.2f  '));
if nargin<=2 || flg
  OverviewChangePossition(hs,pos0);
end

%================================
function ChangeAPOS(h,hs,flg)
%================================
% Callback of Relative-Postion
isNG = getposWithCheck(h,hs);
if isNG,return;end
% Set : (4)
setappdata(hs.figure1,'CurrentLPOischange',true);

ud      = get(h,'UserData');pos0=ud.data;
% AbsolutePosition => RelativePosition
pos = getappdata(hs.figure1,'CurrentLPOabspos');
ud.data(3:4)   = ud.data(3:4)./pos(3:4);
ud.data(1:2)   = ud.data(1:2)-pos(1:2);
ud.data(1:2)   = ud.data(1:2)./pos(3:4);
set(ud.rposh,...
  'UserData',ud,...
  'String',num2str(ud.data,'%4.2f  '));
if nargin<=2 || flg
  OverviewChangePossition(hs,pos0);
end

%-------------------------------
function isNG = getposWithCheck(h,hs)
% Subfunction for Check Position
%-------------------------------
isNG=true;
posstr=get(h,'String');
try
  pos   = str2num(posstr);
  % TODO :Check Numerical x 4
  if length(pos)~=4, error('Input 4 Numerical Value'); end
  ud      = get(h,'UserData');
  ud.data = pos;
  set(h,'UserData',ud,'ForegroundColor',[0 0 0]);
  % Set Flag(4)
  setappdata(hs.figure1,'CurrentLPOischange',true);
  isNG=false;
catch
  beep;
  set(h,'ForegroundColor',[1 0 0],'TooltipString',lasterr);
end
