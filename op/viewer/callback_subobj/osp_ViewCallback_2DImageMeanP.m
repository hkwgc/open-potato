function varargout=osp_ViewCallback_2DImageMeanP(fcn,varargin)
% 2D-Image Mean Period Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%
% $Id: osp_ViewCallback_2DImageMeanP.m 180 2011-05-19 09:34:28Z Katura $
%  Revision 1.4 : Add -- Default Value --


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
else
  feval(fcn, varargin{:});
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         '2D-Image Mean Period'
%       Myfunction Name
%         'vcallback_2DImageMeanP'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='2DImage Mean Period';
basicInfo.fnc    ='osp_ViewCallback_2DImageMeanP';
% File Information
basicInfo.rver   ='$Revision: 1.4 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/02/05 09:54:06 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_2DImageMeanP'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin) %#ok
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.name='2DImage Mean Period';
data.fnc ='osp_ViewCallback_2DImageMeanP';
if ~isfield(data,'pos')
  data.pos =[0, 0, 0.2, 0.1];
end
if ~isfield(data,'v_mp')
  data.v_mp =50;
end

prompt={'Relative Position : ','Mean-Period of Image'};
pos = {num2str(data.pos),num2str(data.v_mp)};
flag=true;
while flag,
  pos = inputdlg(prompt, ...
    'Callback Position', 1,pos);
  if isempty(pos), break; end
  try
    pos0=str2num(pos{1}); %#ok 4-Elements
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0)) %#ok for MATLAB 6.5.1
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);continue;
    end
    % Mean-Period
    % Mask Check
    v_mp = str2num(pos{2}); %#ok for mask
    v_mp0= round(v_mp);
    if ~isequal(v_mp,v_mp0)
      wh=warndlg('Mean-Period must be Integer.');
      waitfor(wh);continue;
    end
    if ~isempty(find(v_mp0<0)) %#ok for MATLAB 6.5.1
      wh=warndlg('Mean-Period must be greater than 0.');
      waitfor(wh);continue;
    end
    if length(v_mp0)~=1
      wh=warndlg('Mean-Period must be single value.');
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
data.pos  =pos0;
data.v_mp =v_mp0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_2DImageMeanP(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj) %#ok
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);
%=====================
% Not Set Special User Data
% <- User Data 1 is Special ->
%=====================
if isfield(obj,'v_mp')
  curdata.ImageProp.v_MP=obj.v_mp;
else
  curdata.ImageProp.v_MP=50;
end
curdata.Callback_2DImageMeanP.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit','String', num2str(curdata.ImageProp.v_MP), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Mean Period Setting', ...
  'Tag','Callback_2DImageMeanP', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageMeanP(''meanperiod_Callback'','...
  'gcbo,[],guidata(gcbo))']);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function meanperiod_Callback(hObject,eventdata,handles) %#ok Callback
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  % -- Getting Userdata --
  ud       = get(hObject, 'UserData');

  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  meanp   = str2double(get(hObject, 'String')); %#ok used in 

catch
  % Error Operation
  errordlg({' Platform Error!', ...
    '   Mean-Period of Image',...
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
%    fdname   : property name('mask_channel')
%
% Optional Variable
%    meanp    : mean period

for idx=1:length(ud),
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);
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
