function varargout=ViewGroupData(fnc,varargin)
% Viewer-Group-Data : File I/O Function.
%      Functions : getBasicInfo, getDefaultData, convert, gui,
%                  getGUIdata, exe 
%      Callbacks : psb_LineProp_Callback 
%


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
function info=getBasicInfo
% Basic Info
  info.MODENAME = 'GROUP';
  info.fnc  = 'ViewGroupData';
  info.down = true;
  info.col  = [.9 .9 1];
  info.strhead  = 'G '; % Group-Data
function data=getDefaultData
  data.NAME    = 'Untitled Group';
  data.MODE    = 'ViewGroupData';
  data.Position=[0 0 1 1];
  data.Object  ={};
  data.lineprop  ={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=convert(data),
% Convert View-Group-Object
%    --> to 'ViewGroupData'
  try,
    switch data.MODE
     case 'ViewGroupData', 
      %-->
      return;
     case {'ViewGroupCallback','ViewGroupGroup'}
      % Object is same..
      % --> Do not delete Object

      % case 'ViewGroupAxes',
     otherwise,
      data.Object = {};
    end
  end
  %     Do not Remove lineprop
  data.MODE   = 'ViewGroupData';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=gui(figh,data)
% Set Line Property
  h0=guidata(figh);
  pos  =  get(h0.frm_set,'Position');
  ud = data.lineprop;
  str={};

  if ~isempty(ud),
    for i=1:length(ud),
	str{end+1}=['   ' ud{i}.name];
    end
  end
  % Push Button of changing Line-Property
  tpos = [0.05, 0.62, 0.45, 0.07];
  handles.psb_LineProp = ...
      uicontrol(figh, ...
                'Style', 'pushbutton', ...
                'BackgroundColor',[0.9 0.88 0.6], ...
                'Units','Normalized', ...
				'FontUnits', 'normalized', ....
                'FontUnits', 'normalized', ....
				'HorizontalAlignment', 'center', ...
                'String', 'LineProperty', ...
                'UserData', ud, ...
                'Callback', ...
                'ViewGroupData(''psb_LineProp_Callback'',gcbo,[],guidata(gcbo))',...
                'Position', getPosabs(tpos,pos));
  tpos = [0.05 0.03 0.9 0.55];
  handles.lbx_LineProp = ...
      uicontrol(figh, ...
                'Style', 'ListBox', ...
                'BackgroundColor',[1 1 1], ...
                'Unit','Normalized', ...
                'FontUnits', 'normalized', ....
                'String', str, ...
                'UserData', ud, ...
                'Visible', 'on', ...
                'Position', getPosabs(tpos,pos));
  if ~isempty(str), set(handles.lbx_LineProp, 'Visible', 'on');end
  setappdata(figh,'HandleOfGroupdata',handles);

return;

%function data=psb_LineProp_Callback(hObject,eventdata,handles,figh,data),
function psb_LineProp_Callback(hObject,eventdata,handles),
  str={};
  figh=handles.LayoutManager;
  hs=getappdata(figh,'HandleOfGroupdata');
  if isempty(hs) ||  ~isfield(hs,'lbx_LineProp'),
     return;
  end
  % Get UserData
  bud=get(hs.psb_LineProp, 'UserData');
  set(handles.LayoutManager, 'Visible', 'off');
  % Get from Setting GUI
  try
    ud = LayoutManager_LProperty(bud);
    if isempty(ud),           return;end
    % Check cancel from group_layout_lineprop GUI  
    if ~iscell(ud) &&  ud==-1,
      set(handles.LayoutManager, 'Visible', 'on');
      return;
    end 
  
    for i=1:length(ud),
	str{end+1}=['   ' ud{i}.name];
    end
    % Set listbox
    set(hs.lbx_LineProp,'String', str);
    set(hs.lbx_LineProp,'UserData', ud);
    set(hs.lbx_LineProp,'Visible', 'on');
    % Update UserData of button
    set(hs.psb_LineProp,'UserData', ud);
  catch
    warndlg('Can''t receive line''s property.');
  end
  set(handles.LayoutManager, 'Visible', 'on');
return;

function data=getGUIdata(figh,data),
  if ~strcmp(data.MODE,'ViewGroupData'),
    error('GUI Data confuse!');
  end
  try
    hs=getappdata(figh,'HandleOfGroupdata');
    data.lineprop=get(hs.psb_LineProp, 'UserData');
    f=fieldnames(hs);
    for idx=1:length(f)
      try,
	delete(getfield(hs,f{idx}));
      end
    end
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-File I/O ( not in use )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeStart(vgdata,hname,abspos,varargin)
function writeEnd(vgdata,hname,abspos,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=exe(handles,vgdata,abspos0,curdata)
%=====================
% Menu Add
%=====================
path0 = curdata.path;
if isfield(curdata,'menu_current'),
    curdata.menu_current = ...
        uimenu(curdata.menu_current,...
        'Label',['&' num2str(curdata.path(end)) '.  ( ' vgdata.NAME ' )'], ...
        'TAG', vgdata.MODE);
end
%=====================
% Current Data Change
%=====================
% Line Property 
if isfield(vgdata,'lineprop') && ~isempty(vgdata.lineprop),
	curdata.lineprop = vgdata.lineprop;
end

%=====================
% My Children
%=====================
% Confine GCF: to plot...
figure(handles.figure1);
% Change Current Position
abspos=getPosabs(vgdata.Position,abspos0);
obj  = vgdata.Object;
for idx=1:length(obj),
	info=feval(obj{idx}.MODE,'getBasicInfo');
	h=feval(obj{idx}.MODE,'getBasicInfo');
	hname = [ obj{idx}.MODE  num2str(idx)];
	curdata.hname = hname;
	curdata.path  = [path0, idx];
	h     = feval(obj{idx}.MODE,'exe',handles,obj{idx},abspos,curdata);
	handles=setfield(handles,hname,h);
end

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
  lpos([1,3]) = lpos([1,3])*pos(3);
  lpos([2,4]) = lpos([2,4])*pos(4);
  lpos(1:2)   = lpos(1:2)+pos(1:2);
return;

