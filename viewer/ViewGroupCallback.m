function varargout=ViewGroupCallback(fnc,varargin)
% Viewer-Group-Data : File I/O Function.
%    with Callback 
%   (CObject : Callback Object is vcallback_***.m)
%      Functions : getBasicInfo, getDefaultData, convert, gui,
%                  getGUIdata, exe
%      Callbacks : AddObj 

% $Id: ViewGroupCallback.m 386 2013-12-02 06:17:49Z katura7pro $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
info=getBasicInfo
function info=getBasicInfo
% Basic Info
  info.MODENAME = 'GROUP with Callback';
  info.fnc  = 'ViewGroupCallback';
  info.down = true;
  info.col  = [.7 .7 1] ;
    info.strhead  = 'CB'; % Group-Callback

function data=getDefaultData
  %<-- Group-Object : Common Field -->
  data.NAME    = 'Untitled Callback-Group';
  data.MODE    = 'ViewGroupCallback';
  data.Position=[0 0 1 1];
  data.Object  ={};
  %<-- Special Field -->
  data.CObject ={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=convert(data),
% Convert data.MODE to 'ViewGroupCallback'

  try,
    switch data.MODE
     case 'ViewGroupCallback',
      %--> 
      return;
     case {'ViewGroupData','ViewGroupGroup'}
      % Object is same..
      % so DO Nothing in particular

      % case 'ViewGroupAxes',
     otherwise,
      data.Object = {};
    end
  end
  data.CObject = {};
  data.MODE    = 'ViewGroupCallback';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=gui(figh,data)
% Set Callback-Object
  h0=guidata(figh);
  pos = get(h0.frm_set,'Position');
  binfo = getBasicInfo;

  %=====================================
  % Callback Object List
  %=====================================
  % <-- Function List -->
  % mode string
  mode_str={'Common Callbacks', ...
		  'Specific Callbacks'}; 
  mode_ud ={}; % User-Data of Mode
  % mode_ud structure
  
  %-----------------------
  % Setup : CommonCallbacks
  %-----------------------
  mode_ud{1} = p3_ViewCommCallback('makeud');

  %-----------------------
  % Setup : SpecialCallbacks
  %-----------------------
  ud={};str={};
  tmpdir=pwd;
  try
	  osp_path= OSP_DATA('GET','OSPPATH');
	  co_path = [osp_path filesep 'viewer' filesep 'callback_subobj'];
	  cd(co_path);
	  files = dir('osp_ViewCallback_*.m');
	  nolist={'osp_ViewCallback_ChannelPopup', ...
              'osp_ViewCallback_KindSelector'};
	  for idx=1:length(files),
		  try
			  % - get data -
              [pth, nm, ex] = fileparts(files(idx).name);
              if any(strcmpi(nm,nolist)),
                  continue;
              end
			  f0    = eval(['@' nm]);
			  info  = feval(f0, 'createBasicInfo');
			  u0    = info;
			  s0    = info.name;
			  % if success to get all data
			  [ud{end+1}, str{end+1}] = ...
				  deal(u0,s0);
		  catch
			  warning(lasterr);
		  end
	  end
  catch
	  cd(tmpdir); rethrow(lasterror);
  end
  cd(tmpdir);
  mode_ud{2}.str=str;
  mode_ud{2}.ud =ud;
	  
  %=====================================
  % Making GUI
  %=====================================
  % == Pop Up Menu ==
  % Now "Enable" is "inactive", and "Value" is "2" .
  % Because Mode 1 is  not run successful in this version..
%   tpos = [0.05 0.6 0.65 0.07];
  tpos = [0.05 0.565 0.65 0.07];
  handles.pop_CallbackMode=uicontrol(figh,...
	  'Style','popupmenu',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'BackgroundColor',[1, 1, 1], ...
	  'String', mode_str, ...
	  'UserData', mode_ud, ...
	  'Position',getPosabs(tpos,pos), ...
          'Value', 1, ...
          'Enable','on', ...
	  'Callback',...
	  'ViewGroupCallback(''pop_CallbackModeChange'',gcbo,[],guidata(gcbo))');
%      'Value', 2, ...
%      'Enable','inactive', ...
  
  % == Pop Up Menu(1_1) ==
%   tpos = [0.05 0.52 0.32 0.07];
  tpos = [0.05 0.485 0.32 0.07];
  handles.pop_Variable=uicontrol(figh,...
	  'Style','popupmenu',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'BackgroundColor',[1, 1, 1], ...
	  'String', mode_ud{1}.str, ...
	  'UserData', mode_ud{1}.ud, ...
	  'Visible', 'off', ...
	  'Position',getPosabs(tpos,pos), ...
	  'Callback', ...
	  'ViewGroupCallback(''pop_Variable_Callback'',gcbo,[],guidata(gcbo))');
  % == Pop Up Menu(1_2) == ( function )
%   tpos = [0.38 0.52 0.32 0.07];
  tpos = [0.38 0.485 0.32 0.07];
  handles.pop_UITYPE=uicontrol(figh,...
	  'Style','popupmenu',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'BackgroundColor',[1, 1, 1], ...
	  'String', mode_ud{1}.ud{1}.uicontrol, ...
	  'Visible', 'off', ...
	  'Position',getPosabs(tpos,pos));
  
  % == Pop Up Menu(2) ==
%   tpos = [0.05 0.49 0.65 0.07];
  tpos = [0.05 0.485 0.65 0.07];
  handles.pop_Callback=uicontrol(figh,...
	  'Style','popupmenu',...
	  'Units','Normalized', ...
	  'BackgroundColor',[1, 1, 1], ...
	  'String', mode_ud{2}.str, ...
	  'UserData', mode_ud{2}.ud, ...
	  'Visible', 'on', ...
	  'Position',getPosabs(tpos,pos));

  %---------
  % Buttons	
  %---------
  % Position : See also ViewGroupAxes
  %  (width : 0.2220, space : 0.004)
  %  Button Color :
  % == Data Kind Button
  bcl = [0.5624, 0.6104, 0.9];
  tpos = [0.05 0.65 0.5 0.06];
  if isfield(data,'DefaultKind'),
      tmpkind=data.DefaultKind;
  else,
      tmpkind=[1 2];
  end
  handles.psb_OptionData=uicontrol(figh,...
      'Style','pushbutton',...
      'Units','Normalized', ...
      'FontUnits', 'normalized', ....
      'String', 'Data Kind Setting', ...
      'UserData',tmpkind,...
      'Position',getPosabs(tpos,pos), ...
      'BackgroundColor', bcl, ...
      'CallBack', ...
      'ViewGroupCallback(''psb_OptionData'',gcbo,[],guidata(gcbo))');
  bcl = [0.7, 0.7, 0.8];
  % == Add button ==
  tpos = [0.05 0.4 0.222 0.08];
  handles.psb_Add=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Add', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupCallback(''AddObject'',gcbo,[],guidata(gcbo))');

  % == Modify button ==
  tpos = [0.276 0.4 0.222 0.08];
  handles.psb_Modify=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Modify', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupCallback(''ModifyObj'',gcbo,[],guidata(gcbo))');
  
  % == Delete button ==
  tpos = [0.502 0.4 0.222 0.08];
  handles.psb_Del=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Delete', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupCallback(''DelObject'',gcbo,[],guidata(gcbo))');

  % == Position Set by GUI button ==
  tpos = [0.728 0.4 0.222 0.08];
  handles.psb_PosSet=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ...
	  'Max', 2, ...
	  'String', 'Sub GUI', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupCallback(''PosSet'',gcbo,[],guidata(gcbo))');

  % == Help button ==
%   tpos = [0.728 0.52 0.222 0.15];
  tpos = [0.728 0.49 0.222 0.15];
  handles.psb_Help=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Help', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupCallback(''HelpObj'',gcbo,[],guidata(gcbo))');

  % == List of Callback-Object ==
  str={};ud={};
  try,
    for idx=1:length(data.CObject),
      str{end+1}=data.CObject{idx}.name;
      ud{end+1} =data.CObject{idx};
    end
  catch,
    str={};ud={};
  end
  tpos = [0.05 0.03 0.9 0.36];
  handles.lbx_data=uicontrol(figh,...
	  'Style','ListBox', ...
	  'Units','Normalized', ...
	  'String', str, ...
	  'BackgroundColor',[1 1 1], ...
	  'UserData', ud, ...
	  'Position',getPosabs(tpos,pos));
  setappdata(figh,'HandleOfGroupdata',handles);
  pop_CallbackModeChange(handles.pop_CallbackMode,[],h0);
return;

%=============================
% Callbacks
%=============================
% Option Data CallBack
function psb_OptionData(hObject,eventdata,handles),

  figh=handles.LayoutManager;
  hs=getappdata(figh,'HandleOfGroupdata');
  oldkind=get(hs.psb_OptionData, 'UserData');

  try,
      userkind=inputdlg({'Input Kind:'},'Input Dialog',1,{num2str(oldkind)});
      if length(userkind{:}) == 0,
          errordlg('Please Input Data-Kind Number.','Input Error!!');
          return;
      end
      userkind=str2num(userkind{:});
      if isempty(userkind) == 1,
          errordlg('Please Input Numerical Character.','Input Error!!');
          return;
      end
      if find(userkind(:) == 0) > 0,
          errordlg('Please Input Numerical Character > 0.','Input Error!!');
          return;
      end
      figh=handles.LayoutManager;
      hs=getappdata(figh,'HandleOfGroupdata');
      set(hs.psb_OptionData, 'UserData', userkind);
  catch,
  end
return;

function pop_CallbackModeChange(hObject,eventdata,handles)
% Change Callback Mode :
%    Callback GUI handles
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
mod=get(hObject,'Value');
hpop1=[hs.pop_Variable, hs.pop_UITYPE];
hpop2=hs.pop_Callback;
if mod==1,
	set(hpop1,'Visible','on');
	set(hpop2,'Visible','off');
	pop_Variable_Callback(hs.pop_Variable,[],handles);
else,
	set(hpop1,'Visible','off');
	set(hpop2,'Visible','on');
end

function pop_Variable_Callback(hObject,eventdata,handles)
% Callback of == Pop Up Menu(1_2) == ( function )
% (Mode Common : Change Variable
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
val= get(hObject,'Value');
ud = get(hObject,'UserData');
set(hs.pop_UITYPE, 'String',  ud{val}.uicontrol,'Value',1);

%--- Select Popup menu Object ---
function obj=getObjectInPopupmenu(handles)
% get Object data form Popupmenu Information
%
%  Syntax:
%    [obj, type, mod]=getObjectInPopummenu(handles)
%  Input Variables:
%    handles : handles of GUI
%  Output Variables:
%    obj  : Object selected by Popumenu,
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
mod=get(hs.pop_CallbackMode,'Value');
if mod==1,
  ud=get(hs.pop_Variable,'UserData');
  id=get(hs.pop_Variable,'Value');
  obj=ud{id};
  type=get(hs.pop_UITYPE,'String');
  type=type{get(hs.pop_UITYPE,'Value')};
  obj.SelectedUITYPE=type;
  % Common Mode
else,
  id=get(hs.pop_Callback,'Value');
  ud=get(hs.pop_Callback,'UserData');
  obj=ud{id};
end
function HelpObj(hObject,eventdata,handles)
% Show Help
obj = getObjectInPopupmenu(handles);
try,
    tmp=obj.fnc;
    if ~ischar(tmp),
        tmp=func2str(obj.fnc);
    end
    OspHelp(tmp);
catch
    OspHelp;
end

function AddObject(hObject,eventdata,handles)
% Add Callback Object
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
obj=getObjectInPopupmenu(handles);
% ==> Plugin Callback : set
data=feval(obj.fnc,'getArgument',obj);
if isempty(data), return; end
stro= get(hs.lbx_data,'String');
udo = get(hs.lbx_data,'UserData');
stro{end+1}=data.name;
udo{end+1} =data;
set(hs.lbx_data,'String',stro,'UserData',udo,...
	'Value',length(udo));

%--- Select List-Box ---
function DelObject(hObject,eventdata,handles)
% Delete Object from Data-Listbox
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
  
% ==> Plugin Callback : set
stro= get(hs.lbx_data,'String');
udo = get(hs.lbx_data,'UserData');
val = get(hs.lbx_data,'Value');
if val>=1 && length(udo)>=val,
  stro(val)=[];
  udo(val) =[];
  if val>length(udo), val=length(udo); end
  set(hs.lbx_data,...
      'String',stro,...
      'UserData',udo, ...
      'Value',val);
end

function ModifyObj(hObject,eventdata,handles)
% Modify Object in Data-Listbox
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
  
% ==> Plugin Callback : set
stro= get(hs.lbx_data,'String');
udo = get(hs.lbx_data,'UserData');
val = get(hs.lbx_data,'Value');
if val>=1 && length(udo)>=val,
	tmp=feval(udo{val}.fnc,'getArgument',udo{val});
	if isempty(tmp), return; end
	udo{val} =tmp;
	str{val}=udo{val}.name;
	if val>length(udo), val=length(udo); end
	set(hs.lbx_data,...
		'String',stro,...
		'UserData',udo, ...
		'Value',val);
end

function PosSet(hObject,eventdata,handles)
% set Position by sub GUI..
str={};
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');
cObject=get(hs.lbx_data,'UserData'); % Callback Object List

% Lock LayoutManage (not good..)
set(handles.LayoutManager, 'Visible', 'off');
% Get from Setting GUI
try
	% -- Lauch Sub GUI (and Modify cObject) --
	cObject = ViewGroupCallback_subgui_pos('CObject',cObject);
	% Cancel?
	if isempty(cObject), 
		% Unlock LayoutManager and End..
		set(handles.LayoutManager, 'Visible', 'on');return;
	end

	% -- Update cObject. --
	% if change number of cObject/Name
	%    you must Remake..
	set(hs.lbx_data,'UserData',cObject); % Callback Object List
catch
	errordlg({'OSP Error !!', ...
			'   View-Group Callback-Objcet : ', ...
			'   Error while Position Change Sub-GUI.', ...
			lasterr});
end
% Unlock LayoutManage..
set(handles.LayoutManager, 'Visible', 'on');


function data=getGUIdata(figh,data),
% Get GUI Object
  try,
    if ~strcmp(data.MODE,'ViewGroupCallback'),
      warning('GUI Data confuse!');
    end
    data.Mode='ViewGroupCallback';
    hs = getappdata(figh,'HandleOfGroupdata');
    data.CObject = get(hs.lbx_data,'UserData');

    KindData=get(hs.psb_OptionData,'UserData');
    if ~isempty(KindData)
        data.DefaultKind=KindData;
    end

    f=fieldnames(hs);
    for idx=1:length(f)
      try,
	delete(getfield(hs,f{idx}));
      end
    end
  end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=exe(handles,vgdata,abspos0,curdata)
% Draw Layout Children

% --> Debug-Mode
if curdata.dbgmode,
  osp_debugger('start',[mfilename '/exe']);
  disp(get(handles.figure1,'Visible'));
  disp(vgdata);
end

%=====================
% Menu Add
%=====================
path0 = curdata.path;
if isfield(curdata,'menu_current'),
    curdata.menu_current = ...
        uimenu(curdata.menu_current,...
        'Label',['&' num2str(curdata.path(end)) '.  [ ' vgdata.NAME ' ]' ], ...
        'TAG', vgdata.MODE);
end
%=====================
% Current Data Change
%=====================

%==> Old Version
if isfield(vgdata,'DefaultKind'),
    curdata.kind=vgdata.DefaultKind;
end
%!!!!!!!!!!!!!!!!!!! New LayoutEditor !!!!!!!!!!!!!!!
% ==> Apply Property 
%!!!!!!!!!!!!!!!!!!! New LayoutEditor !!!!!!!!!!!!!!!
curdata=P3_ApplyAreaProperty(curdata,vgdata);


%=====================
% Callback Object Loop
%=====================

%==> Callback Menu Label <===
%  2006.11.10 Kidachi
if isfield(curdata,'menu_callback'),
    menu_current_bak=curdata.menu_callback;
    curdata.menu_callback=uimenu(curdata.menu_callback,...
        'Label', vgdata.NAME);
end

cbobj = vgdata.CObject;
abspos=getPosabs(vgdata.Position,abspos0);
%menu_ch1  = get(curdata.menu_current,'Children');
for idx=1:length(cbobj),
  info = feval(cbobj{idx}.fnc,'createBasicInfo');
  % << !! curdata will be change !! >>
  try
      str  =feval(cbobj{idx}.fnc,'drawstr',cbobj{idx});
      eval(str);
  catch
      errordlg({'P3 Error!!', ...
              '  Callback-Object Error', ...
              ['  Named : ' info.name], ...
              ['  ' lasterr]});
  end
end
%menu_ch2  = get(curdata.menu_current,'Children');

%==> Callback Menu Label <===
%  Checks2006.11.10 Kidachi
if isfield(curdata,'menu_callback'),
    ch = get(curdata.menu_callback,'Children');
    if isempty(ch),
        delete(curdata.menu_callback);
    end
    curdata.menu_callback=menu_current_bak;
end

%=====================
% My Children
%=====================
% Change Current Position
obj  = vgdata.Object;
for idx=1:length(obj),
	info=feval(obj{idx}.MODE,'getBasicInfo');
	h=feval(obj{idx}.MODE,'getBasicInfo');
	hname = [ obj{idx}.MODE  num2str(idx)];
	curdata.hname = hname;
	curdata.path  = [path0, idx];
	h = feval(obj{idx}.MODE,'exe',handles,obj{idx},abspos,curdata);
	handles=setfield(handles,hname,h);
end

%========================
% Ordering Callback Menu
%========================
% if length(menu_ch2)~=0,
%   c=get(curdata.menu_current ,'Children');
%   menu_id   = length(menu_ch1)+1:length(menu_ch2);
%   menu_id    = menu_id - length(menu_ch2) + length(c);
%   c2=c(menu_id);
%   c(menu_id)=[];
%   set(curdata.menu_current ,'Children',[c2(:);c(:)]);
%   set(c2(end),'Separator','on');
% end

%=====================
% Add Common Menu
%=====================
% Delete My Menu
if isfield(curdata,'menu_current'),
    c=get(curdata.menu_current ,'Children');
    if isempty(c),
        delete(curdata.menu_current);
    else,
        curdata.path=path0;
        h=osp_LayoutViewerTool('addMenu_Edit_Axes0', curdata);
        set(h,'Separator','on');
% === Add Menu :: Axis Setting
        menu_editAllAxis=uimenu(curdata.menu_current,...
            'Label','Edit Axis Setting',...
            'Tag','menu_EditAllAxis');
        menu_editAllAxis_X=osp_LayoutViewerTool('addMenu_EditAllAxis',...
            1,menu_editAllAxis,curdata);
        curdata.menu_current=uimenu(curdata.menu_current,...
        'Label','Property',...
        'Separator','on');
        h=osp_LayoutViewerTool('addMenu_Line', curdata);
        h=osp_LayoutViewerTool('addMenu_Marker', curdata);
        h=osp_LayoutViewerTool('addMenu_Legend', curdata);
    end
end
if curdata.dbgmode,
  osp_debugger('end',[mfilename '/exe']);
  disp(get(handles.figure1,'Visible'));
end

return;


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
