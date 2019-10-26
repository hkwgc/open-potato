function varargout=osp_ViewCallback_2DImageMode(fcn,varargin)
% 2D-Image Mode Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_2DImageMode.m 299 2012-12-11 04:47:40Z Katura $


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         '2DImage Mode'
%       Myfunction Name
%         'vcallback_2DImageMode'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='2DImage Mode';
basicInfo.fnc    ='osp_ViewCallback_2DImageMode';
% File Information
basicInfo.rver   ='$Revision: 1.13 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/02/07 04:40:49 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_2DImageMode'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin) %#ok
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=1 && isstruct(varargin{1})
  data=varargin{1};
end
data.name='2DImage Mode';
data.fnc ='osp_ViewCallback_2DImageMode';

[data,varList]=subSetDefaultValues(data);

flag=true;
while flag,
	ret = inputdlg(varList(:,3)','Default value setting', 1,varList(:,2)');
  if isempty(ret), break; end
  try
    pos0=str2num(ret{strmatch('pos',varList(:,1))}); %#ok : not single
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0)) %#ok for 6.5.1
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
for k=1:size(varList,1)
	data.(varList{k,1})=ret{k};
end
data.pos =pos0;
return;

%************
function varargout=subSetDefaultValues(data)
varList={...
	'pos','[0 0 0.2 0.1]','Relative position';...
	'mode','2','Image mode (1: Interped, 2: Patch)';...
	'patchSize', '0.03', 'Patch size';...
	'edgeColor', '[0.7 .7 .7]', 'Patch edge color';...
	'alpha', '1.0', 'Image alpha';...
	'interpMode', '2', 'Interp mode (1:linear 2:cubic 3:nearest 4:invdist)';...
	'interpStep', '3', 'Interp step'};
for k=1:size(varList,1)
	if ~isfield(data,varList{k,1})
		data.(varList{k,1})=varList{k,2};
	else
		varList{k,2}=num2str(data.(varList{k,1}));
	end
end
varargout{1}=data;
varargout{2}=varList;
%************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_2DImageMode(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata, obj) %#ok Call-from draw-str (
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%pos=getPosabs(obj.pos,apos);

%-check obj
obj=subSetDefaultValues(obj);
pos = obj.pos;
% Background Color
if isfield(curdata,'BackgroundColor'),
  bgc=curdata.BackgroundColor;
else
  bgc=get(hs.figure1,'Color');
end

% Set position of Mode, Method, Step components
width=pos(3);height=pos(4);
if width>height,
  h0=height/4; w0=width/5;
  %x=w0*[0:4]+pos(1);
  x=pos(1):w0:w0*4+pos(1);
  %y=h0*[3:-1:0]+pos(2);
  y=h0*3+pos(2):-h0:pos(2);
  pos1=[x(1) y(1) width h0];
  pos2=[x(1) y(2) width h0];
  pos3=[x(1) y(3) w0*3 h0];
  pos4=[x(1) y(4) w0*3 h0];
  pos5=[x(4) y(3) w0*2 h0];
  pos6=[x(4) y(4) w0*2 h0];
else
  h0=height/6;
  %y=h0*[5:-1:0]+pos(2);
  y=h0*5+pos(2):-h0:pos(2);
  pos1=[pos(1) y(1) width h0];
  pos2=[pos(1) y(2) width h0];
  pos3=[pos(1) y(3) width h0];
  pos4=[pos(1) y(4) width h0];
  pos5=[pos(1) y(5) width h0];
  pos6=[pos(1) y(6) width h0];
end
pos1 = getPosabs(pos1,apos);
pos2 = getPosabs(pos2,apos);
pos3 = getPosabs(pos3,apos);
pos4 = getPosabs(pos4,apos);
pos5 = getPosabs(pos5,apos);
pos6 = getPosabs(pos6,apos);

%=====================
% Set Special User Data
% <- User Data 1 is Special ->
%=====================
%val=1;                     % 'POINTS'
m=str2num(obj.mode);
curdata.ImageProp.image_mode = 2+(m==2)*2;%1:interp 4:patch
curdata.ImageProp.image_mode_ind = curdata.ImageProp.image_mode;
%str={'POINTS','INTERPED','smooth POINTS','Patch Image'};
str={'INTERPED','Patch Image'};
%  Mode
curdata.Callback_2DImageMode.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','Mode', ...
  'Units','normalized', ...
  'BackgroundColor',bgc, ...
  'Position',pos1);

curdata.Callback_2DImageMode.handles= ...
  uicontrol(hs.figure1,...
  'Style','popupmenu','String',str, ...
  'Value', 1+(curdata.ImageProp.image_mode==4), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos2, ...
  'TooltipString','Image Mode Setting', ...
  'Tag','Callback_2DImageMode', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageMode(''imagemode_Callback'','...
  'gcbo,[], guidata(gcbo))']);

curdata.Callback_2DImageInterp.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','Interp', ...
  'Units','normalized', ...
  'BackgroundColor',bgc, ...
  'Position',pos3);

% Method
str={'linear','cubic','nearest','invdist'};
curdata.Callback_2DImageMethod.handles= ...
  uicontrol(hs.figure1,...
  'Style','popupmenu','String',str, ...
  'Value', str2num(obj.interpMode), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos4, ...
  'TooltipString','Image Method Setting', ...
  'Tag','Callback_2DImageMethod', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageMode(''imagemethod_Callback'','...
  'gcbo,[],guidata(gcbo))']);

% Step
curdata.ImageProp.v_interpstep = str2num(obj.interpStep);
curdata.Callback_2DImageSteptext.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','STEP', ...
  'BackgroundColor',bgc, ...
  'Units','normalized', ...
  'Position',pos5, ...
  'HorizontalAlignment', 'center', ...
  'Tag','Callback_2DImageStep');
curdata.Callback_2DImageStep.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit','String', curdata.ImageProp.v_interpstep, ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos6, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Image Method Step Setting', ...
  'Tag','Callback_2DImageStep', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageMode(''imagestep_Callback'','...
  'gcbo,[],guidata(gcbo))']);

if curdata.ImageProp.image_mode ~=2
  set([curdata.Callback_2DImageInterp.handles, ...
    curdata.Callback_2DImageMethod.handles, ...
    curdata.Callback_2DImageSteptext.handles, ...
    curdata.Callback_2DImageStep.handles],'Visible', 'off');
end

%============> for Patch Image0
% Edge Size
curdata.Callback_2DImagePMedgesize_str.handles = ...
  uicontrol(hs.figure1,...
  'Style','text','String','Patch Size', ...
  'Units','normalized', ...
  'BackgroundColor',bgc, ...
  'Position',pos3);

curdata.ImageProp.PatchImageProp.EdgeSize=str2num(obj.patchSize);
curdata.Callback_2DImagePMedgesize_edt.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit',...
  'String',num2str(curdata.ImageProp.PatchImageProp.EdgeSize), ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos4, ...
  'TooltipString','Edige Style', ...
  'Tag','Callback_2DImagePMedgesize_edt', ...
  'UserData',curdata.Callback_2DImageMode.handles,...
  'Callback', ...
  ['h=get(gcbo,''UserData'');'...
  'osp_ViewCallback_2DImageMode(''imagemode_Callback'',h,[], guidata(h))']);


% Edige Color
curdata.ImageProp.PatchImageProp.EdgeColor=str2num(obj.edgeColor);
curdata.Callback_2DImagePMedgecolor_psb.handles = ...
  uicontrol(hs.figure1,...
  'Style','pushbutton','String','Edge Color', ...
  'BackgroundColor',curdata.ImageProp.PatchImageProp.EdgeColor, ...
  'Units','normalized', ...
  'Position',pos5, ...
  'TooltipString','Edige Style', ...
  'Tag','Callback_2DImagePMedgecolor_psb', ...
  'UserData',curdata.Callback_2DImageMode.handles,...
  'Callback',...
  ['h=get(gcbo,''UserData'');'...
  'c=uisetcolor(gcbo);'...
  'set(gcbo,''BackgroundColor'',c);'...
  'set(gcbo,''ForegroundColor'',1-c);'...
  'osp_ViewCallback_2DImageMode(''imagemode_Callback'',h,[], guidata(h))']);


% Alpha
curdata.ImageProp.PatchImageProp.Alpha=str2num(obj.alpha);
curdata.Callback_2DImagePMalpha_pop.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit',...
  'String',num2str(curdata.ImageProp.PatchImageProp.Alpha),...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos6, ...
  'TooltipString','Image alpha', ...
  'Tag','Callback_2DImagePMalpha_pop', ...
  'Callback', ...
  ['ud=get(gcbo,''UserData'');h=ud.h;'...
  'osp_ViewCallback_2DImageMode(''imagemode_Callback'',h,[], guidata(h))']);
%<===========  for Patch Image

% Set Visible property
if curdata.ImageProp.image_mode ~=4
  set([curdata.Callback_2DImagePMalpha_pop.handles,...
    curdata.Callback_2DImagePMedgecolor_psb.handles,...
    curdata.Callback_2DImagePMedgesize_edt.handles,...
    curdata.Callback_2DImagePMedgesize_str.handles],'Visible','off');
end


% Set Interped-handles to Mode-UserData{1}
ud={};
ud{1}=[curdata.Callback_2DImageInterp.handles, ...
  curdata.Callback_2DImageMethod.handles, ...
  curdata.Callback_2DImageSteptext.handles, ...
  curdata.Callback_2DImageStep.handles,...
  curdata.Callback_2DImagePMalpha_pop.handles,...
  curdata.Callback_2DImagePMedgecolor_psb.handles,...
  curdata.Callback_2DImagePMedgesize_edt.handles,...
  curdata.Callback_2DImagePMedgesize_str.handles];
set(curdata.Callback_2DImageMode.handles, 'UserData', ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imagemode_Callback(hObject,e,hs) %#ok : in Call from "Callback"
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
piprop=[];
if 0,disp(e);disp(hs);end
% -- Getting Userdata --
ud       = get(hObject, 'UserData');
% -- Getting Interped-handles --
interp_h = ud{1};
try
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  val   = get(hObject, 'Value');
  if val==1,mode=2;else mode=4;end
  set(interp_h,'Visible','off');
  switch mode
    case 2
      % INTERPED
      set(interp_h(1:4),'Visible','on');
    case 4
      set(interp_h(5:8),'Visible','on');
      %--> 2dmode
      piprop.Alpha=str2num(get(interp_h(5),'string'));
      piprop.EdgeColor=get(interp_h(6),'BackGroundColor');
      edgesize=get(interp_h(7),'String');
      edgesize=str2double(edgesize);
      if ~isfinite(edgesize),edgesize=6;end
      piprop.EdgeSize=edgesize;
  end
catch
  % Error Operation
  errordlg({' Platform Error:', ...
    '   In Mode Change',...
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
%    fdname   : property name(='image_mode_ind')
%
% Optional Variable
%    mode     : image mode index

% for idx=2:length(ud),
%   try
%     if mode==4
%       ud{idx}.PatchImageProp=piprop;
%       %curdata.ImageProp.PatchImageProp=piprop;
%     else
%       if isfield(ud{idx},'PatchImageProp')
%          piprop=ud{idx}.PatchImageProp;
%       else
%         piprop=[];
%       end
%     end
%     eval(ud{idx}.str);
%   catch
%     warning(lasterr);
%   end
% end
funcStr=['mode=varargin{1};piprop=varargin{2};',...
	'if mode==4, ud{idx}.PatchImageProp=piprop;',...
	'else, if isfield(ud{idx},''PatchImageProp''),piprop=ud{idx}.PatchImageProp;',...
	'else, piprop=[]; end;  end;'];
ud=p3_ViewCommCallback('redrawAO',ud(2:end),funcStr,mode,piprop);
%set(hObject,'UserData',ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imagemethod_Callback(hObject,e,hs) %#ok : in Call from "Callback"
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(e);disp(hs);end
try
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --

  ud     = get(hObject, 'UserData');
  str    = get(hObject, 'String');
  method =  str{get(hObject, 'Value')}; %#ok : used in UsetData-String
catch
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
%    fdname   : property name(='interpmethod')
%
% Optional Variable
%    method     : method of interp-mode
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
function imagestep_Callback(hObject,e,hs)  %#ok : in Call from "Callback"
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(e);disp(hs);end
try
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  ud     = get(hObject, 'UserData');
  step   = str2double(get(hObject, 'String')); %#ok : used in UsetData-String
catch
  % Error Operation
  errordlg({' Platform Error :', ...
    '   in Step-Callback',...
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
%    fdname   : property name(='v_interpstep')
% Optional Variable
%    step     : step number of interp-mode
for idx=1:length(ud),
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
