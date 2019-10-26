function varargout=osp_ViewCallback_2DImageAuto(fcn,varargin)
% 2D-Image Auto, Zerofix Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_2DImageAuto.m 245 2011-11-21 09:12:38Z Katura $


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
%         '2D-Image Auto'
%       Myfunction Name
%         'vcallback_2DImageAuto'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='C Axis';
basicInfo.fnc    ='osp_ViewCallback_2DImageAuto';
% File Information
basicInfo.rver   ='$Revision: 1.8 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/03/02 13:57:41 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_2DImageAuto'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin) %#ok
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.name='C Axis';
data.fnc ='osp_ViewCallback_2DImageAuto';
if isfield(varargin{1},'pos')
	defVal{1}=num2str(varargin{1}.pos);
	defVal{2}=num2str(varargin{1}.Auto);
	defVal{3}=num2str(varargin{1}.Max);
	defVal{4}=num2str(varargin{1}.Min);
	defVal{5}=num2str(varargin{1}.ZeroFix);
else
	defVal{1}=num2str([0.7, 0, 0.3, 0.2]);
	defVal{2}='1';
	defVal{3}='1';
	defVal{4}='-1';
	defVal{5}='1';	
end

data.pos =[0.7, 0, 0.3, 0.2];
flag=true;
while flag,
  pos = inputdlg({'Relative Position : ','Auto (1:On, 0:Off)','Max','Min','Zero fix (1:Yes, 0:No)'}, ...
    'Default Value setting', 1,defVal);
  if isempty(pos), break; end
  try
    pos0=str2num(pos{1}); %#ok
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0)) %#ok for MATLAB 6.5.1
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
data.Auto = str2num(pos{2});
data.Max = str2num(pos{3});
data.Min = str2num(pos{4});
data.ZeroFix = str2num(pos{5});
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_2DImageAuto(''make'',' ...
  'handles, abspos, curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj) %#ok
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%pos=getPosabs(obj.pos,apos);
pos = obj.pos;

% Background Color
if isfield(curdata,'BackgroundColor'),
  bgc=curdata.BackgroundColor;
else
  bgc=get(hs.figure1,'Color');
end
% Set position of Auto checkbox, Min,Max edit, Zerofix checkbox components
width=pos(3);height=pos(4);
if width>height,
  h0=height/5; w0=width/2;
  %x=w0*[0:1]+pos(1);
  x=[pos(1),w0+pos(1)];
  %y=h0*[4:-1:0]+pos(2);
  y=pos(2)+h0*4:-h0:pos(2);
  pos0=[x(1) y(1) width h0];
  pos1=[x(1) y(2) w0 h0];
  pos2=[x(2) y(2) w0 h0];
  pos31=[x(1) y(3) w0 h0];
  pos32=[x(2) y(3) w0 h0];
  pos41=[x(1) y(4) w0 h0];
  pos42=[x(2) y(4) w0 h0];
  barpos=getPosabs([pos(1) y(5)+h0/2 width h0/2], apos);
else
  h0=height/5;w0=width/7;
  x=pos(1):w0:6*w0+pos(1);
  %y=h0*[4:-1:0]+pos(2);
  y=pos(2)+h0*4:-h0:pos(2);
  pos0=[x(1) y(1) w0*5 h0];
  pos1=[x(1) y(2) w0*5 h0];
  pos2=[x(1) y(5) w0*5 h0];
  pos31=[x(1) y(3) w0*3 h0];
  pos32=[x(4) y(3) w0*2 h0];
  pos41=[x(1) y(4) w0*3 h0];
  pos42=[x(4) y(4) w0*2 h0];
  barpos= getPosabs([x(7)+w0/2 y(5) w0/2 height], apos);
end
pos0  = getPosabs(pos0,apos);
pos1  = getPosabs(pos1,apos);
pos2  = getPosabs(pos2,apos);
pos31 = getPosabs(pos31,apos);
pos32 = getPosabs(pos32,apos);
pos41 = getPosabs(pos41,apos);
pos42 = getPosabs(pos42,apos);

%figure(hs.figure1);

%=====================
% Set Special User Data(only 2DImageAuto)
% <- User Data 1 is Special ->
%=====================
if isfield(obj,'Auto')
	curdata.ImageProp.v_axisAuto=obj.Auto;
	curdata.ImageProp.v_axMax=obj.Max;
	curdata.ImageProp.v_axMin=obj.Min;
	curdata.ImageProp.v_zerofix=obj.ZeroFix;
else
	curdata.ImageProp.v_axisAuto=1;
	curdata.ImageProp.v_axMax=1;
	curdata.ImageProp.v_axMin=-1;
	curdata.ImageProp.v_zerofix=1;
end

% Colorbar
set(0,'CurrentFigure',hs.figure1);
m=colormap;
if width>height,
  cdata=1:size(m,1);
else
  cdata=1:size(m,1);cdata=cdata';
end
h=axes;
h2=image(cdata);
% Bugfix : 070529B
set(h2,'CDataMapping','scaled');

if width>height,
  set(h,'Position', barpos, ...
	  'YDir','normal','YTick',[],'XTick',linspace(1,size(m,1),5));
else
  set(h,'Position', barpos, ...
    'XDir','normal','YDir','normal','XTick',[],'YTick',linspace(1,size(m,1),5));
end
curdata.Callback_2DImageColor.handles=h;

% Auto checkbox
curdata.Callback_2DImageCaxis.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','CAXIS', ...
  'Units','normalized', ...
  'BackgroundColor',bgc, ...
  'Position',pos0);

curdata.Callback_2DImageAuto.handles= ...
  uicontrol(hs.figure1,...
  'Style','checkbox','String','Auto', ...
  'Value',curdata.ImageProp.v_axisAuto,...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos1, ...
  'TooltipString','Image Auto/Manual Setting', ...
  'Tag','Callback_2DImageAuto', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageAuto(''autoaxis_Callback'','...
  'gcbo,[], guidata(gcbo))']);

% Max edit
curdata.Callback_2DImageMaxT.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','MAX', ...
  'Units','normalized', ...
  'BackgroundColor',bgc, ...
  'Position',pos31, ...
  'HorizontalAlignment', 'center', ...
  'Tag','Callback_2DImageMaxT');

curdata.Callback_2DImageMax.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit',...
  'String', num2str(curdata.ImageProp.v_axMax),...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos32, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Axis Max Setting', ...
  'Tag','Callback_2DImageMax', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageAuto(''axisrange_Callback'','...
  'gcbo,[],guidata(gcbo))']);

% Min edit
curdata.Callback_2DImageMinT.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','MIN', ...
  'BackgroundColor',bgc, ...
  'Units','normalized', ...
  'Position',pos41, ...
  'HorizontalAlignment', 'center', ...
  'Tag','Callback_2DImageMinT');

curdata.Callback_2DImageMin.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit', ...
  'String', num2str(curdata.ImageProp.v_axMin),...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos42, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Axis Min Setting', ...
  'Tag','Callback_2DImageMin', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageAuto(''axisrange_Callback'','...
  'gcbo,[],guidata(gcbo))']);

% Zerofix checkbox
curdata.Callback_2DImageZerofix.handles= ...
  uicontrol(hs.figure1,...
  'Style','checkbox','String','Zero fix', ...
  'Value', curdata.ImageProp.v_zerofix,...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos2, ...
  'TooltipString','Zero Fix  Setting', ...
  'Tag','Callback_2DImageZerofix', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageAuto(''zerofix_Callback'','...
  'gcbo,[], guidata(gcbo))']);

%---------------------------------
% set Handles for Visible Control
%---------------------------------
% Set handles to Auto-UserData{1}
ud={};
ud{1}=[curdata.Callback_2DImageMinT.handles, ...
  curdata.Callback_2DImageMin.handles, ...
  curdata.Callback_2DImageMaxT.handles, ...
  curdata.Callback_2DImageMax.handles];
set(curdata.Callback_2DImageAuto.handles, 'UserData', ud);

if curdata.ImageProp.v_axisAuto==1
  % Set Visible property
  set(ud{1},'Visible', 'off');
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoaxis_Callback(hObject,eventdata,handles) %#ok Callback-function
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- Getting Userdata --
ud       = get(hObject, 'UserData');
% -- Getting manual handles --
manual_h = ud{1};

% -- Getting Variable --
val   = get(hObject, 'Value');
if val==0,
  set(manual_h,'Visible','on');
else
  set(manual_h,'Visible','off');
end

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    fdname   : property name(='v_axisAuto')
%
% Optional Variable
%    val     :  1:auto or 0:manual

for idx=2:length(ud),
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axisrange_Callback(hObject,eventdata,handles) %#ok Callback-Fucntion
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- Getting Variable --
ud   = get(hObject, 'UserData');
val  = str2double(get(hObject, 'String')); %#ok used in us.str

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    fdname   : property name(='v_axMin' or 'v_axMax')
%
% Optional Variable
%    val    : min or max
for idx=1:length(ud),
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zerofix_Callback(hObject,e,hs) %#ok Used in Callback
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(e);disp(hs);end
% -- Getting Userdata --
ud       = get(hObject, 'UserData');

% -- Getting Variable --
zerofix   = get(hObject, 'Value'); %#ok used in evaluate

% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    fdname   : property name(='v_zerofix')
%
% Optional Variable
%    zerofix     :  1:zerofix or 0:not fixed

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
