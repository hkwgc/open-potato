function varargout = LayoutManager(varargin)
% LAYOUTMANAGER M-file for LayoutManager.fig
%      This GUI Set/Edit Layout-Data in OSP.
%
%      LayoutData = LAYOUTMANAGER returns the Layout-Data to SIGNAL_VIEWER2
%
%      LAYOUTMANAGER('Property','Value',...) creates a new LAYOUTMANAGER using the
%      given property value pairs. 
%      'LAYOUT'     : layout information table
%      'LayoutPath' : current path of layout information table
%
%      LAYOUTMANAGER('CALLBACK') and LAYOUTMANAGER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LAYOUTMANAGER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 01-Mar-2006 20:39:38

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original autohr : Y Yamada.,  Hitachi-ULSI Systems Co.,Ltd.
%          M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 10-Jan-2006
%
% $Id: LayoutManager.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.01
%  Meeting on 10-Jan-2006
%      T.K (HARL), M.S (H-ULSI)
%      About Gruop Data
%  Meeting on 11-Jan-2006
%      Y.Y (H-ULSI), M.S (H-ULSI)
%
% Meeting on 20-Feb-2006
%      T.K (HARL), M.S (H-ULSI)
%       --> Grop-View-Data List Change
%       Note : 21-Feb-2006
%       Change on 24-Feb-2006
%
% Meeting on 01-Mar-2006
%    1.  view of whole-map(reloadchild)
%        Change on 01-Mar-2006(reload_child)
%    2. Remove button : UP, Down
%    3. Modify Execute-button
%       --> Change to Add (Group/Axes/Callback/Channel)
%       --> Add Load Button
%    4. Add button named "Add child"
%    5. Move View-Group-Object Popup 
%  (Done at 21:00, 01-Mar-2006) M.S
%
% Revision 1.21
%  Change Style : (pop_GroupManaeg --> edit-text)
%  Enable Common Callback
%
% Revision 1.24
%  Resize .. add

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LayoutManager_OpeningFcn, ...
                   'gui_OutputFcn',  @LayoutManager_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1}) 
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI I/O Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LayoutManager_OpeningFcn(hObject, eventdata, handles, varargin)
% Just before LayoutManager is made visible.
% Choose default command line output for LayoutManager.
%
% Set Initial-Value by Arguments.
%-------------------------------------------
  LAYOUT=[];
  LayoutPath=[];
  msg=nargchk(0,4,length(varargin));
  if ~isempty(msg),
    errordlg(msg);return;
  end

  %=========================
  % Set Other Property
  %=========================
  try,
    al = length(varargin); % Argument Length
    if bitget(al,1)==1,
      error(' Invalid parameter/value pair arguments.');
    end
    for idx=1:2:al
      switch varargin{idx},
       case {'LAYOUT','LayoutPath'},
		   eval([varargin{idx} '= varargin{idx+1} ;']);
       otherwise,
      end % End Variable Name :
    end
  catch,
    % When Error : Show Useage.
    h=errordlg({'Error Occur ', lasterr});
    waitfor(h);return;
  end

  %=========================
  % Opening
  %=========================
  handles.output = {}; % Bugfix : Initial-Value
  handles.figure1 = handles.LayoutManager;

  %  Set window's size & Color
  c0 = [0.703 0.763 0.835];
  set(hObject, ...
      'Units', 'normalized', ...
      'Position', [0.10, 0.1, 0.65, 0.5], ...
      'Color',   c0);
  % Set Axes Property
  axis([handles.axes1 handles.axes2], 'manual');
  axis([handles.axes1 handles.axes2], [0, 1, 0, 1]);
  % Make Frame of Group Data
  set(handles.frm_set, ...
      'BackgroundColor',c0, ...
      'ForegroundColor',[0.1, 0.1, 0.9]);
  %==================================
  % Make Children of frm_set!
  %  (Control of Group-Object Data )
  %==================================
  % Make Uicontrol of Group Setting
  %   pos  : Position of Output Uicontrols
  pos = get(handles.frm_set,'Position'); % Figure Position
  %   c0   : Color of figure
  %   c1   : Button Color
  c1 = c0*0.8; c1(3)=0.9; 

  %---------------------------
  % Popup Menu of View-Group
  %---------------------------
  % <-- Group-Object List -->
  fnc =  {@ViewGroupData, ...
		  @ViewGroupAxes, ...
		  @ViewGroupGroup, ...
		  @ViewGroupCallback};
  ud={};str ={};
  for idx=1:length(fnc),
	  info=feval(fnc{idx}, 'getBasicInfo');
	  ud{idx}  = info;
	  str{idx} = info.MODENAME;
  end
  % --> copy to popup --> add : 02-Mar-2006
  set(handles.pop_add,'String',str,'UserData',ud);
  % Position
  tpos = [0.05, 0.9, 0.45, 0.06];
  handles.pop_GroupMode = uicontrol(hObject, ...
	  'Style', 'edit', ...
	  'Enable', 'Inactive', ...
	  'BackgroundColor',[1 1 1], ...
	  'Unit','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'HorizontalAlignment', 'left', ...
	  'String', str{1}, ...
	  'UserData',ud, ...
	  'Position', getPosabs(tpos,pos));
  % Make Help
  tpos = [0.55, 0.9, 0.4, 0.06];
  handles.psb_VGroupHelp = uicontrol(hObject, ...
	  'Style', 'pushbutton', ...
	  'String', 'VG-Help', ...
	  'BackgroundColor',c1, ...
	  'Unit','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'HorizontalAlignment', 'left', ...
	  'Callback', ...
	  ['handles=guidata(gcbo);' ...
		  'val=getappdata(gcbf,''GroupMode'');' ...
		  'ud =get(handles.pop_GroupMode,''UserData'');' ...
		  'try,eval(ud{val}.fnc); end'], ...
	  'Position', getPosabs(tpos,pos));
  
  % Make Name Text
  tpos = [0.05, 0.81, 0.24, 0.06];
  handles.nametext = uicontrol(hObject, ...
			      'Style', 'text', ...
			      'BackgroundColor',c0, ...
			      'Unit','Normalized', ...
			      'FontUnits', 'normalized', ....
			      'HorizontalAlignment', 'left', ...
			      'String', 'Name : ', ...
			      'Position', getPosabs(tpos,pos));
  % Print Name :
  tpos = [0.3, 0.81, 0.65, 0.06];
  handles.nameedit = uicontrol(hObject, ...
			      'Style', 'edit', ...
			      'BackgroundColor',[1 1 1], ...
			      'Unit','Normalized', ...
			      'FontUnits', 'normalized', ....
			      'HorizontalAlignment', 'left', ...
			      'String', '--', ...
			      'Callback', ...
			      'LayoutManager(''nameedit_Callback'',gcbo,[],guidata(gcbo))',...
			      'Position', getPosabs(tpos,pos));
  % Make Position Text
  tpos = [0.05, 0.72, 0.24, 0.06];
  handles.postext = uicontrol(hObject, ...
			      'Style', 'text', ...
			      'BackgroundColor',c0, ...
			      'Unit','Normalized', ...
			      'FontUnits', 'normalized', ....
			      'HorizontalAlignment', 'left', ...
			      'String', 'Position : ', ...
			      'Position', getPosabs(tpos,pos));
  % Print Position :
  tpos = [0.3, 0.72,  0.65, 0.06];
  handles.posedit = uicontrol(hObject, ...
			      'Style', 'edit', ...
			      'BackgroundColor',[1 1 1], ...
			      'Unit','Normalized', ...
			      'FontUnits', 'normalized', ....
			      'FontSize', 0.4, ...
			      'HorizontalAlignment', 'left', ...
			      'String', '--', ...
			      'Callback', ...
			      'LayoutManager(''posedit_Callback'',gcbo,[],guidata(gcbo))',...
			      'Position', getPosabs(tpos,pos));

  % --------------------------
  %  List of Application Data 
  % --------------------------
  % View-Grop-Data : root :
  % setappdata(handles.LayoutManager, 'GroupTable', {});

  % Path to the Current Group Data in GroupTable
  setappdata(handles.LayoutManager, 'CurrentGroupPath', []);
  % Next Position of Group
  setappdata(handles.LayoutManager, 'GroupRect', [0.1, 0.5, 0.15, 0.15]);
  % Grid Size in Motion
  setappdata(handles.LayoutManager,'GridSize',0.01);
  % Initialize gplist ListBox
  set(handles.lbx_gplist, 'Value', []);
  set(handles.lbx_gplist, 'String', {});
  % temporary process
  set(handles.psb_saveas, 'Visible', 'off');

  % Set input argument(LAYOUT,LayoutPath)
  set(handles.LayoutManager, 'UserData',{LAYOUT, LayoutPath});
  if ~isempty(LAYOUT) && isfield(LAYOUT, 'vgdata'),
    vgdata=LAYOUT.vgdata;
  else
    vgdata={};
  end
  if ~isempty(LAYOUT) && isfield(LAYOUT, 'FigureProperty'),
    set(handles.psb_Figprop, 'UserData',LAYOUT.FigureProperty);
  else
    set(handles.psb_Figprop, 'UserData',[]);
  end
  % Show GUI by input LAYOUT
  setappdata(handles.LayoutManager, 'CurrentGroupPath', []);
  setappdata(handles.LayoutManager, 'GroupTable', vgdata);
  showCurrentGroup(vgdata, handles);


  % Update handles structure
  guidata(hObject, handles);
  % Axes Resize
  resizeAxes2(hObject,[],handles);

  uiwait(handles.LayoutManager); 
return;
% || End of Opening Function
  
function varargout = LayoutManager_OutputFcn(hObject, eventdata, handles)
  handles= guidata(hObject);
  % Bugfix : -> handles.output 
  if nargout~=0,
      if (nargout>length(handles.output)) || ...
              ~iscell(handles.output),
          if isempty(handles.output),
              varargout{1:nargout}=deal([]);
          else,
              error('Too many output variable.');
          end
      else,
          [varargout{1:nargout}] = handles.output{1:nargout};
      end
  end
  delete(handles.LayoutManager);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inner Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function vgdata=getCurrentVG(handles,cp),
% Get Current Gruop Data
%
% vgdata : Current View Group Data
% cp     : Path to the Current Group Data in GroupTable
vgdata = getappdata(handles.LayoutManager, 'GroupTable');
if nargin<2,
  cp     = getappdata(handles.LayoutManager, 'CurrentGroupPath');
end
try,
  for idx=cp
    % Current Group Data
    vgdata=vgdata{idx};
    vgdata=vgdata.Object;
  end
catch,
  error('Cannot get Current View-Group Data');
end
return;

function name=getCurrentVGNAME(handles,cp),
% Get Current Gruop Data
%
% name  : Name of Current View Group Data
% cp    : Path to the Current Group Data in GroupTable
name='Top Layout-Data';
vgdata = getappdata(handles.LayoutManager, 'GroupTable');
if nargin<2,
  cp     = getappdata(handles.LayoutManager, 'CurrentGroupPath');
end
if isempty(cp), return;end
try,
  for idx=cp
    % Current Group Data
    vgdata=vgdata{idx};
    name=vgdata.NAME;
    vgdata=vgdata.Object;
  end
catch,
  error('Cannot get Name of Current View-Group Data');
end
return;

function setCurrentVG(handles,vgdata),
% Set Current-ViewGroupData 
% 
% vgdata : Current View Group Data.
  cp     = getappdata(handles.LayoutManager, 'CurrentGroupPath');
  try,
    for idx0=1:(length(cp))
      idx =cp(end);
      cp(end)=[];
      uvgdata=getCurrentVG(handles,cp);
      uvgdata{idx}.Object= vgdata;
      vgdata      = uvgdata;
    end
    setappdata(handles.LayoutManager, 'GroupTable',vgdata);
 catch,
  error('Cannot get Current View-Group Data');
  end
  % Reset List2
  resetVGDataList2(handles);
return;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu : File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mn_file_Callback(hObject, eventdata, handles)
function mn_new_Callback(hObject, eventdata, handles)
  setappdata(handles.LayoutManager, 'GroupTable', {});
  setappdata(handles.LayoutManager, 'CurrentGroupPath', []);
  showCurrentGroup({}, handles);
return;

function mn_load_Callback(hObject, eventdata, handles)
% Load View Group Data from 'vgdata'
%
  
  % Get LayoutPath
  ud=get(handles.LayoutManager, 'UserData');
  if ~isempty(ud{2}),
    vdir = ud{2};
  else,
    vdir=which('LayoutManager');
  end
  [pname, fname, ext]=fileparts(vdir);

  % uiputfile
  curpwd = pwd;
  cd(pname);
  try,
    [fn, pn] = uigetfile('*.mat');
  catch,
    cd(curpwd);
    rethrow(lasterr);
  end
  cd(curpwd);
  if fn==0, return;end
  fname = [pn filesep fn];
  load (fname, 'LAYOUT');
  if ~exist('LAYOUT'),
      error('Selected File have not View-Layout-Data');
  end

  % load and Set vgdata
  if  ~isempty(LAYOUT) && isfield(LAYOUT,'vgdata'),
    vgdata=LAYOUT.vgdata;
  else
    warndlg('Could not load. This file don''t have vgdata.');
    return;
  end
  setappdata(handles.LayoutManager, 'CurrentGroupPath', []);
  setappdata(handles.LayoutManager, 'GroupTable', vgdata);

  % Set figureproperty
  if isfield(LAYOUT,'FigureProperty'),
    set(handles.psb_Figprop, 'UserData',LAYOUT.FigureProperty);
  else
    set(handles.psb_Figprop, 'UserData',[]);
  end    
  
  % Show GUI
  showCurrentGroup(vgdata, handles);
return;

function mn_close_Callback(hObject, eventdata, handles)
  quitFnc(hObject, [], handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu : Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mn_gridsize_Callback(hObject, eventdata, handles)
  gs=getappdata(handles.LayoutManager,'GridSize');
  prompt={'Gird Size of Object-Position : 0.1 to 0.0000001'};
  gsstr = num2str(gs);
  while 1,
    gsstr = inputdlg(prompt,'Grid Size',1,{gsstr});
    if isempty(gsstr), break; end
    try,
      gs = str2num(gsstr{1});
      if length(gs)~=1,
	error('Number of Grid Size must be 1');
      end
      if gs>0.1,
	error('Too large!');
      end
      if gs<0.0000001,
	error('Too small!');
      end
      setappdata(handles.LayoutManager,'GridSize',gs);
      break;
    catch
      h=errordlg({'Input Proper Number:',lasterr});
      waitfor(h);
    end
  end
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% About LAYOUT-Data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LAYOUT=getLayout(handles)
% Get Layout Data from this GUI
%   Upper :

  %=========================
  % Get Current Group-Table
  %========================= 
  savenow_grouplist(handles);
  vgdata = getappdata(handles.LayoutManager, 'GroupTable');

  %========================= 
  % Make LAYOUT(vgdata,ver,FigureProperty) 
  %========================= 
  LAYOUT.vgdata=vgdata;
  LAYOUT.ver   =1.0;
  fProp = get(handles.psb_Figprop, 'UserData');
  if ~isempty(fProp),
    LAYOUT.FigureProperty = fProp;
  else
    LAYOUT.FigureProperty = [];
  end
  % ==> redraw It.
  lbx_gplist_Callback(handles.lbx_gplist,[],handles);
return;

function psb_Figprop_Callback(hObject, eventdata, handles)
% Show Setting Dialog and  Get figure's property
%
% handles  : handles of LayoutManager
  % Get PropertyList to FigProp-UserData
  FigureProperty=get(handles.psb_Figprop, 'UserData');
  prompt = {' Enter : Name  ( Character )', ...
            ' Enter : Position-Normalized Units  (X Y Width height)', ...
            ' Enter : Color  ( R G B )'};
  %def    = {'File Name', ...
  %	    num2str([0.0 0.5 0.5 0.5]),...
  %	    num2str([1 1 1])};
  if ~isempty(FigureProperty) && isfield(FigureProperty, 'Name'),
     def{1}=FigureProperty.Name;
  else
    def{1}='FigurePropertyName';
  end
  if ~isempty(FigureProperty) && isfield(FigureProperty, 'Position'),
    def{2}=num2str(FigureProperty.Position);
  else
    def{2}=num2str([0.0 0.5 0.5 0.5]);
  end
  if ~isempty(FigureProperty) && isfield(FigureProperty, 'Color'),
    def{3}=num2str(FigureProperty.Color);
  else
    def{3}=num2str([1 1 1]);
  end

  % Open Input-Dialog
  while 1,
    % input-dlg
    def = inputdlg(prompt, 'Figure Property Setting', 1, def);
    if isempty(def),break; end
    if ~isempty(find(str2num(def{2})<0))  || ...
	  ~isempty(find(str2num(def{2})>1)), 
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);
      continue;
    end
    if ~isempty(find(str2num(def{3})<0))  || ...
	  ~isempty(find(str2num(def{3})>1)), 
      wh=warndlg('Input Color Value between 0.0 - 1.0.');
      waitfor(wh);
      continue;
    end
    break;
  end

  % Cancel:
  if isempty(def), return;end
  % OK:
  FigureProperty.Name     = def{1}; 
  FigureProperty.Color    = [ str2num(def{3}) ];
  FigureProperty.Units    = 'normalized';
  FigureProperty.Position = [ str2num(def{2}) ];
  % Set PropertyList to FigProp-UserData
  set(handles.psb_Figprop, 'UserData', FigureProperty);

  %%%% Resize aexs2
  resizeAxes2(hObject,[],handles);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I/O Button : callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_saveas_Callback(hObject, eventdata, handles)
% Not in use
errordlg('This function is not in use.');
return;  
function psb_save_Callback(hObject, eventdata, handles)
% Set GUI-Oupput-Data and Close
%    1st Output Data is LAYOUT

  %======================================
  % Get Layout Data
  %======================================
  LAYOUT=getLayout(handles);
  %========================= 
  % Set Output Value of the GUI
  %  1st : LAYOUT Data
  %========================= 
  varargout{1}=LAYOUT;
  handles.output=varargout;
  guidata(hObject,handles);

  %========================= 
  %  Resume  == Close
  %========================= 
  if isequal(get(handles.LayoutManager, 'waitstatus'), 'waiting')
    uiresume(handles.LayoutManager);
  else
	delete(handles.LayoutManager);
  end
return

function varargout = psb_Filesave_Callback(hObject, eventdata, handles)
% Save File button
  %======================================
  % Get Layout Data
  %======================================
  LAYOUT=getLayout(handles);

  %======================================
  % Get Layout-Data-File Path (vdir)
  %======================================
  ud=get(handles.LayoutManager, 'UserData');
  if ~isempty(ud{2}),
    vdir = ud{2};
  else
    fpath=which('LayoutManager');
    [vdir, fname, ext]=fileparts(fpath);
  end

  %======================================
  % UIPUTFILE : (Directory Change)
  %======================================
  curpwd = pwd; cd (vdir);
  try,
    [fname pname]=uiputfile('*.mat', 'Save Layout File');
  catch,
    cd(curpwd);
    rethrow(lasterr);
  end
  cd(curpwd);
  if (isequal(fname,0) ||isequal(pname,0)),return;end

  %======================================
  % Save LAYOUT
  %======================================
  rver=OSP_DATA('GET', 'ML_TB');
  rver=rver.MATLAB;
  if rver>=14,
    save([pname filesep fname], 'LAYOUT','-v6');
  else
    save([pname filesep fname], 'LAYOUT');
  end
return;  

function psb_quit_Callback(hObject, eventdata, handles)
% Quit button
%
  quitFnc(hObject, [], handles);
return;

function quitFnc(hObject, eventdata, handles)
  % Output Empty (LAYOUT) 
  handles.output=[];
  guidata(hObject,handles);
  %  Resume 
  if isequal(get(handles.LayoutManager, 'waitstatus'), 'waiting')
    uiresume(handles.LayoutManager);
  else,
    delete(handles.LayoutManager);  
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Movie
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LayoutManager_WindowButtonDownFcn(hObject, eventdata, handles)
% Call when Button Down on this Figure.
% Checked : 13-Jan-2006
  set(handles.LayoutManager, 'DoubleBuffer', 'on');

function ButtonDownObject(hObject,eventdata,handles,id),
% Call when Object is selected in axes1.
  gpname=get(handles.lbx_gplist, 'String');
  if id<=length(gpname) && id>0,
    set(handles.lbx_gplist, 'Value', id);
    lbx_gplist_Callback(handles.lbx_gplist, [], handles);
  else,
    errordlg(['could not handles. input id=' num2str(id)]);
  end
  
  % Get Mouse-Down Position and Set
  axes1p = get(handles.axes1, 'CurrentPoint');
  setappdata(handles.LayoutManager, 'MDownPoint', axes1p);

  % Get Object's handle and  Set Start-Position
  gph=get(handles.lbx_gplist, 'UserData');
  x  =get(gph(id), 'XData');
  y  =get(gph(id), 'YData');
  x1max=x(1)+0.03;
  x2min=x(2)-0.03;
  y1max=y(1)+0.03;
  y2min=y(4)-0.03;
  setappdata(handles.LayoutManager, 'MDownXData', x);
  setappdata(handles.LayoutManager, 'MDownYData', y);

  % Check User action
  if axes1p(1,1)<=x1max && axes1p(1,2)<=y1max,
    setappdata(handles.LayoutManager, 'BUTTON_MODE', 'Size');
    setappdata(handles.LayoutManager, 'BUTTON_POS', 'LB'); 
	set(gph(id),'FaceColor',[1 .3 .3]);
  elseif axes1p(1,1)<=x1max  &&  y2min<=axes1p(1,2),
    setappdata(handles.LayoutManager, 'BUTTON_MODE', 'Size');
    setappdata(handles.LayoutManager, 'BUTTON_POS', 'LU'); 
	set(gph(id),'FaceColor',[1 .3 .3]);
  elseif x2min<=axes1p(1,1) &&  axes1p(1,2)<=y1max,
    setappdata(handles.LayoutManager, 'BUTTON_MODE', 'Size');
    setappdata(handles.LayoutManager, 'BUTTON_POS', 'RB'); 
	set(gph(id),'FaceColor',[1 .3 .3]);
  elseif x2min<=axes1p(1,1) &&   y2min<=axes1p(1,2),
    setappdata(handles.LayoutManager, 'BUTTON_MODE', 'Size');
    setappdata(handles.LayoutManager, 'BUTTON_POS', 'RU'); 
	set(gph(id),'FaceColor',[1 .3 .3]);
  else,
    setappdata(handles.LayoutManager, 'BUTTON_MODE', 'Move');
	set(gph(id),'FaceColor',[.3 .3 1]);
  end

function LayoutManager_WindowButtonMotionFcn(hObject, eventdata, handles)
% Executes on mouse motion over figure - except title and menu.
% Move Object alog Mouse.
%
% Application-Date:
%   BUTTOM_MODE : Move : surface is selected
%                 Size : edge is selected

  bmode = getappdata(handles.LayoutManager, 'BUTTON_MODE');
  if isempty(bmode) || strcmp(bmode,'none'), return; end
  id  = get(handles.lbx_gplist, 'Value');
  gph = get(handles.lbx_gplist, 'UserData');
  dx = getappdata(handles.LayoutManager, 'MDownXData');
  dy = getappdata(handles.LayoutManager, 'MDownYData');
  x  =dx; y=dy;
  axes1p=getappdata(handles.LayoutManager, 'MDownPoint');
  axes2p=get(handles.axes1, 'CurrentPoint');
  diff=axes2p-axes1p;

  switch bmode,
   case 'none',
     return;

   case 'Move',
    
     x=x+diff(1,1);
     y=y+diff(1,2);

   case 'Size',
    bpos = getappdata(handles.LayoutManager, 'BUTTON_POS');
     switch bpos,
       case 'LB',
	x([1 4])=x([1 4])+diff(1,1);
	y([1 2])=y([1 2])+diff(1,2);
       case 'LU',
	x([1 4])=x([1 4])+diff(1,1);
	y([3 4])=y([3 4])+diff(1,2);
       case 'RB',
	x([2 3])=x([2 3])+diff(1,1);
	y([1 2])=y([1 2])+diff(1,2);
       case 'RU',
	x([2 3])=x([2 3])+diff(1,1);
	y([3 4])=y([3 4])+diff(1,2);
     end
  end

  % Check range
  if ~isempty(find(x<0)) || ~isempty(find(x>1)) || ...
	~isempty(find(y<0)) || ~isempty(find(y>1)),
    
    if ~isempty(find(x<0)),
      mx=min(x(x<0)); x=x-mx;
      if strcmp(bmode,'Size') && max(x)~=max(dx),
	x(find(x==max(x))) = max(dx);
      end
    end
    if ~isempty(find(x>1)),
      mx=max(x-1); x=x-mx;
      if strcmp(bmode, 'Size') && min(x)~=min(dx),
	x(find(x==min(x))) = min(dx);
      end
    end
    if ~isempty(find(y<0)),
      my=min(y(y<0)); y=y-my;
      if strcmp(bmode,'Size') && max(y)~=max(dy),
	y(find(y==max(y))) = max(dy);
      end
    end
    if ~isempty(find(y>1)),
      my=max(y-1); y=y-my;
      if strcmp(bmode,'Size') && min(y)~=min(dy),
	y(find(y==min(y))) = min(dy);
      end
    end
    % Sort 
    x(1:4)=[min(x);max(x);max(x);min(x)];
    y(1:4)=[min(y);min(y);max(y);max(y)];
  end

  % Round(0.XX) and update
  gs=getappdata(handles.LayoutManager,'GridSize');
  x=(round((x+1)/gs))*gs-1;
  y=(round((y+1)/gs))*gs-1;

  rpos(1)= min(x);  rpos(3)=abs(rpos(1)-max(x));
  rpos(2)= min(y);  rpos(4)=abs(rpos(2)-max(y));
  set(handles.posedit, 'String', ['[' num2str(rpos) ']']);

  set(gph(id), 'XData', x);
  set(gph(id), 'YData', y);
  set(handles.lbx_gplist, 'UserData', gph);

return;

function LayoutManager_WindowButtonUpFcn(hObject, eventdata, handles)
% Call when Button Up on this Figure.
%
% Application-Date:
%   BUTTOM_MODE : Move : surface is selected
%                 Size : edge is selected
%set(handles.LayoutManager, 'DoubleBuffer', 'off');
mode = getappdata(handles.LayoutManager,'BUTTON_MODE');
if (isempty(mode) || strcmp(mode,'none')), return; end;

try
  % Change Position :: Last ::
  LayoutManager_WindowButtonMotionFcn(hObject, [], handles);
  % Change Button Mode : none
  setappdata(handles.LayoutManager, 'BUTTON_MODE', 'none');
  setappdata(handles.LayoutManager, 'BUTTON_POS', 'none');
catch
  rethrow(lasterror);
end
%  Sort and update 
id  = get(handles.lbx_gplist, 'Value');
gph = get(handles.lbx_gplist, 'UserData');
x   = get(gph(id), 'XData');
y   = get(gph(id), 'YData');

x(1:4)=[min(x);max(x);max(x);min(x)];
y(1:4)=[min(y);min(y);max(y);max(y)];
set(gph(id), 'XData', x, 'YData', y, ...
	'FaceColor', [1.0, 0.7, 0.7]);
set(handles.lbx_gplist, 'UserData', gph);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position & Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function posedit_Callback(hObject, eventdata, handles)
% Position Data Edit 
  % get Current information
  val = get(handles.lbx_gplist, 'Value');
  gph = get(handles.lbx_gplist, 'UserData');
  if length(gph)<val,
	  set(handles.nameedit, 'String','----');
	  errordlg('No effective data to set position');
	  return;
  end
  spos = get(handles.posedit, 'String');
  if ~isempty(spos),
    rpos= str2num(spos);
    if rpos(1)+rpos(3)>1|| rpos(2)+rpos(4)>1,
      rpos(1)=1-rpos(3);rpos(2)=1-rpos(4);
      if rpos(1)<0, rpos(1)=0;end
      if rpos(2)<0, rpos(2)=0;end
      % Update input text
      set(handles.posedit, 'String', ['[' num2str(rpos) ']']);
    end
  end
  % Update
  val = get(handles.lbx_gplist, 'Value');
  gph = get(handles.lbx_gplist, 'UserData');
  x(1:4)=[rpos(1);rpos(1)+rpos(3);rpos(1)+rpos(3);rpos(1)];
  y(1:4)=[rpos(2);rpos(2);rpos(2)+rpos(4);rpos(2)+rpos(4)];
  set(gph(val), 'XData', x);
  set(gph(val), 'YData', y);
  set(handles.lbx_gplist, 'UserData', gph);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View Group Data , Other than Position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_GroupMode_Callback(hObject,eventdata,handles)
% Change Group Mode of Selecting Object.
  % Check Data
  val0= getappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD');
  if  isempty(val0),
    errordlg('No effective GroupData Selected!');
    return;
  end
  % Get Current View-Groupx
  vgdata=getCurrentVG(handles);
  % <== Save & Delete : GUI of Group Object==>
  setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',[]);
  vgdata{val0}=feval(vgdata{val0}.MODE, ...
		     'getGUIdata',handles.LayoutManager,vgdata{val0});
  setCurrentVG(handles,vgdata);

  % New Mode get
  val = get(hObject,'Value');
  ud  = get(hObject,'UserData');
  % Data Conversation
  try,
    vgdata{val0} = feval(ud{val}.fnc,'convert',vgdata{val0});
  catch,
    warndlg({'Data Conversion Error occur!','Use Default Value'});
    tmp          = vgdata{val0};
    vgdata{val0} = feval(ud{val}.fnc,'getDefaultData');
    vgdata{val0}.NAME = tmp.NAME;
  end
  setCurrentVG(handles,vgdata);
  feval(vgdata{val0}.MODE, 'gui',handles.LayoutManager,vgdata{val0});
  setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',val0);
return;

function nameedit_Callback(hObject,eventdata,handles)
% Change View-Group Name
  val    = get(handles.lbx_gplist, 'Value');
  % get current String
  vgdata=getCurrentVG(handles);
  if length(vgdata)<val,
	  set(handles.nameedit, 'String','----');
	  errordlg('No effective data to set name');
	  return;
  end
  % get Name
  name = get(handles.nameedit, 'String');
  % Update Current View-Group-Data
  vgdata{val}.NAME=name;
  setCurrentVG(handles,vgdata);
  % Update List-Box String
  gpname = get(handles.lbx_gplist, 'String');
  gpname{val}=name;
  set(handles.lbx_gplist, 'String', gpname);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savenow_grouplist(handles),
% Save Now Group List-Data and 
% Update Delete UICONTROL's in View-GROUP-Data
  val0= getappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD');
  vgdata=getCurrentVG(handles);
  %if ~isempty(val0)
  if ~isempty(val0) && ~isempty(vgdata),
    % <== Save Unsaved Data==>
    %%setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',[]);
    vgdata{val0}=feval(vgdata{val0}.MODE, ...
        'getGUIdata',handles.LayoutManager,vgdata{val0});
    setCurrentVG(handles,vgdata);
  end
  setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',[]);
  % Change Position
  h = get(handles.lbx_gplist, 'UserData');  % children handles
  for idx=1:length(h),
    x=get(h(idx), 'XData');
    y=get(h(idx), 'YData');
    rpos=[x(1),y(1),abs(x(2)-x(1)),abs(y(3)-y(2))];
    vgdata{idx}.Position=rpos;
  end
  setCurrentVG(handles,vgdata);
return;

% --- Executes on selection change in lbx_gplist.
function lbx_gplist_Callback(hObject, eventdata, handles)
% View-Group-Data List Callback.
%  Execute on selection change in VG Listbox 
%             Button down on Axes-2 (CurrentGroup) Object

  %  Data Check
  val = get(handles.lbx_gplist, 'value');
  if size(val)>1, 
    warndlg('Please select one from list');
    return;
  end

  % ---------------------------
  % Get : Children in the Group
  % ---------------------------
  childname = get(handles.lbx_gplist, 'String');    % children names
  gphandles = get(handles.lbx_gplist, 'UserData');  % children handles

  % -------------------------------
  % Get : Before ID & Current Group
  % -------------------------------
  val0= getappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD');
  vgdata=getCurrentVG(handles);
  if isempty(val) || length(vgdata)<val,
    return;
  end

  % ---------------------
  % Check OLD-LIST-INDEX 
  % ---------------------
  if val0>length(childname),
    %%added on 06/01/24%%
    h=errordlg('OSP Error! Internal Data broken!');
    waitfor(h);
    delete(hObject);return;
  end 

  % -------------------------------
  % Update : Viewer-Group UICONTROL
  % -------------------------------
  if ~isempty(val0) && (val0~=val),
    % <== Save Unsaved Data & Clear VG-UICONTROL ==>
    setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',[]);
    vgdata{val0}=feval(vgdata{val0}.MODE, ...
        'getGUIdata',handles.LayoutManager,vgdata{val0});
    setCurrentVG(handles,vgdata);
  end
  if isempty(val0) || (val0~=val),
    % Make Viewer-Group UICONTROL
    feval(vgdata{val}.MODE, 'gui',handles.LayoutManager,vgdata{val});
    setappdata(handles.LayoutManager,'GROUP_LIST_ID_OLD',val);
  end
  
  % -------------
  % Update : Mode
  % -------------
  ud  = get(handles.pop_GroupMode,'UserData');
  mode=[];
  for idx=1:length(ud),
      if strcmp(ud{idx}.fnc,vgdata{val}.MODE),
          mode=idx; break;
      end
  end
  if ~isempty(mode),
    setappdata(handles.figure1,'GroupMode',mode);
    set(handles.pop_GroupMode,'String',ud{idx}.MODENAME);
  end
  
  % -------------------------
  % Update : Name
  % -------------------------
  set(handles.nameedit, 'String', childname{val});

  % -------------------------
  % Update : Position
  % -------------------------
  x=get(gphandles(val), 'XData');
  y=get(gphandles(val), 'YData');
  rpos=[x(1),y(1),abs(x(2)-x(1)),abs(y(3)-y(2))];
  set(handles.posedit, 'String', ['[' num2str(rpos) ']']);

  % -------------------------
  % Change Color : Active 
  % -------------------------
  %  Face Color Change ::  [1,0.8,0.5],
  set(gphandles(val), ...
	  'FaceColor', [1.0, 0.7, 0.7], ...
	  'EdgeColor', [1,0,0]);
  % -------------------------
  % Change Color : Old Active Chiled
  % -------------------------
  if ~isempty(val0) && (val0~=val),
	  info=feval(vgdata{val0}.MODE,'getBasicInfo');
	  set(gphandles(val0), 'FaceColor', info.col, 'EdgeColor', [.3,.3,.3]);
	  %'EdgeColor', info.col);
  end

  % -------------------------
  %  Update Listbox2
  % since revision 1.12
  % -------------------------
  % ( Current-Group-Path) 
  resetVGDataList2(handles,val);

  % -------------------------
  % Change Order of Active Chiled
  % -------------------------
  ch = get(handles.axes1, 'Children');
  ii = find(ch==gphandles(val));
  if ii~=1 && ~isempty(ii),
    cht=ch(1);
    ch(1)=ch(ii);	ch(ii)=cht;
    set(handles.axes1, 'Children', ch);
  end
return;

function lbx_vgdatalist2_Callback(hObject, eventdata, handles)
% --> Callback lbx1
  % To Lock
  setappdata(handles.LayoutManager,...
      'VG_DATA_LOCK', true);
  try,
      ud = get(hObject,'UserData');
      vl = get(hObject,'Value');
      ud =ud{vl};
      if length(ud)>=1,
          vl2=ud(end);ud(end)=[];
      else,
          vl2=1;
      end
      savenow_grouplist(handles);
      % Current Goup Path :: up
      setappdata(handles.LayoutManager, 'CurrentGroupPath',ud);
      % Get Current Data
      vgdata=getCurrentVG(handles);
      % Show GUI
      showCurrentGroup(vgdata, handles);
      % Select Current Object
      set(handles.lbx_gplist,'Value',vl2);
      lbx_gplist_Callback(handles.lbx_gplist,[],handles);
  catch,
      errordlg({'OSP Internal Error!!',lasterr});
  end
  setappdata(handles.LayoutManager,...
      'VG_DATA_LOCK', []);
return;

function resetVGDataList2(handles,val);
% View-Data List II Refresh

  lockf=getappdata(handles.LayoutManager,...
      'VG_DATA_LOCK');
  % Get View-Group Data (Root)
  vgdataRoot = getappdata(handles.LayoutManager, 'GroupTable');
  % Get Selected Value
  if nargin>=2 && isempty(lockf),
      % get Current Group Object
      cpnow      = getappdata(handles.LayoutManager, ...
          'CurrentGroupPath');
      % make My-Object-Path
      if val~=0,
          cpnow(end+1) = val; % Selected Obj-Path! 
      end

      % Make Set of Data
      [str, ud0,val0] = vgdata2txt(vgdataRoot,'Text',cpnow);
      set(handles.lbx_vgdatalist2,...
          'String', str, ...
          'UserData', ud0, ...
          'Value', val0);
  else
      % Make Set of Data
      [str, ud0] = vgdata2txt(vgdataRoot);
      vl0=get(handles.lbx_vgdatalist2,'Value');
      if length(ud0)<vl0, vl0=length(ud0);end
      set(handles.lbx_vgdatalist2,...
          'String', str, ...
          'UserData', ud0,...
          'Value',vl0);
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_addchildren_Callback(hObject, eventdata, handles)
% Executes on button press in Down
%  Current-Group to lower Gruop
val = get(handles.lbx_gplist, 'value');
if isempty(val) || val==0,
	warndlg('Select Effective Data.');
	return;
end
vgdata=getCurrentVG(handles);
if length(vgdata)<val,
	warndlg('No selected Current Variable exist');
	return;
end
info=feval(vgdata{val}.MODE,'getBasicInfo');
if info.down==false,
	errordlg('Can not down for this Object');
	return;
end

savenow_grouplist(handles);
% Current Goup Path :: up
cp     = getappdata(handles.LayoutManager, 'CurrentGroupPath');
cp(end+1)=val;
setappdata(handles.LayoutManager, 'CurrentGroupPath',cp);
% Get Current Data
vgdata=getCurrentVG(handles);
% Show GUI
showCurrentGroup(vgdata, handles);
psb_addcurrent_Callback(handles.psb_addcurrent, [], handles);

function psb_addcurrent_Callback(hObject, eventdata, handles)
% Execute on button press in Execute
% New or Load Group to Current-Group

% ------------
% Get Add Type
% ------------
addtype  = get(handles.pop_add, 'value');
ud=get(handles.pop_add,'UserData');
if isempty(addtype), return;end
% ----------------
% Create new Group
% ----------------
data=feval(ud{addtype}.fnc,'getDefaultData');
addGroupChild(handles, ...
	data.NAME, ...
	ud{addtype});


% -----------------------
% Save Current Group-Data
% -----------------------
vgdata=getCurrentVG(handles);
vgdata{end+1}=data;
setCurrentVG(handles,vgdata);
set(handles.lbx_gplist,'Value',length(vgdata));
lbx_gplist_Callback(handles.lbx_gplist,[],handles);
return;

function psb_LoadLayoutFile_Callback(hObject, eventdata, handles)
% ------------------------------
% Load Layout-File, and add 
% ------------------------------

% Get Layout-File Directory Path
ud=get(handles.LayoutManager, 'UserData');
if ~isempty(ud{2}),
	vdir = ud{2};
else,
	vdir=which('LayoutManager');
end
[pname, fname, ext]=fileparts(vdir);

curpwd = pwd;
cd(pname);
try,
	[fn, pn] = uigetfile('*.mat');
catch,
	cd(curpwd);
	rethrow(lasterr);
end
cd(curpwd);
if fn==0, return;end % cancell ?

fname = [pn filesep fn];
%load (fname, 'vgdata');
load (fname, 'LAYOUT');
if isfield(LAYOUT,'vgdata'),
	vgdata=LAYOUT.vgdata;
else
	warndlg('Could not load. This file don''t have vgdata.');
	return;
end
[pname, fname, ext]=fileparts(fname);
addGroupChild(handles, fname);
data=ViewGroupData('getDefaultData');
data.NAME=fname;
data.Object =vgdata;
% -----------------------
% Save Current Group-Data
% -----------------------
vgdata=getCurrentVG(handles);
vgdata{end+1}=data;
setCurrentVG(handles,vgdata);
set(handles.lbx_gplist,'Value',length(vgdata));
lbx_gplist_Callback(handles.lbx_gplist,[],handles);
return;

function psb_delete_Callback(hObject, eventdata, handles)
% Execute on button press in Delete
% Delete Group from Current-Group
  deleteGroupChild(handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Goup Data // Change 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_up_Callback(hObject, eventdata, handles)
% Execute on button press in UP
%  Current-Group to upper Gruop

  % Get Current Path
  cp     = getappdata(handles.LayoutManager, 'CurrentGroupPath');
  if isempty(cp),
    h=errordlg('Current Group : Top Level');
    waitfor(h); return;
  end

  ud=get(handles.lbx_vgdatalist2,'UserData');
  opidx=1;
  for idx=1:length(ud),
    if isequal(ud{idx},cp),
      opidx=idx;
    end
  end
  set(handles.lbx_vgdatalist2,'Value',opidx);
  % Change Directory.
  lbx_vgdatalist2_Callback(handles.lbx_vgdatalist2, [], handles);
  if 0,
    savenow_grouplist(handles);
    setappdata(handles.LayoutManager, 'CurrentGroupPath',cp);
    % Get Current Data
    vgdata=getCurrentVG(handles);
    % Show GUI
    showCurrentGroup(vgdata, handles);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_tile_Callback(hObject,eventdata,handles)
% Reload-button:
%   Show 
  % Save currnt grouplist
  savenow_grouplist(handles);
% Overall View of Current Group 
  axes(handles.axes2);cla
  axis manual; axis ([0 1 0 1]); hold on; 
  pos=[0 0 1 1];
  % Get View-Group
  vgdata = getappdata(handles.LayoutManager, 'GroupTable');  
  cvgp0=getappdata(handles.LayoutManager, 'CurrentGroupPath');
  reload_child(pos,vgdata,handles.axes2,[],cvgp0);
  set(handles.axes2,'Color','white');

  lbx_gplist_Callback(handles.lbx_gplist,[],handles);
return;

function reload_child(pos,vgdata,axh,cvgp,cvgp0)
% pos    : Plot Position.
% vgdata : Current View Group Data.
% axh    : Plot Axes.
% cvgp   : Current ViweGroup Data Path.
% Copy --> signal_viewer2 : overview_child
  for idx =1:length(vgdata)
    % Get Basic Information
    info=feval(vgdata{idx}.MODE,'getBasicInfo');

    % View Box
    lpos=vgdata{idx}.Position;
    absp=getPosabs(lpos,pos);  
    x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1)];
    y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4)];
    axes(axh); % To Confine Axes.
    h = fill(x,y,info.col);

    % Set Callback & User Data
    tmp.cvgp = cvgp; % Current Group Path
    tmp.idx  = idx;
    %--> tagset for resizeAxes1
    tagname=num2str([cvgp idx]);
    tagname=strrep(tagname,' ','_');
    tagname=['SQ' tagname];

    if isequal(cvgp0,[cvgp idx]),
		% Selecting Grop-View-Object
        set(h,'UserData',tmp, ...
	      'Tag',tagname, ...
            'LineStyle', ':', ...
			'EdgeColor', [1 0 0], ...
			'FaceAlpha', 0.5, ...
            'ButtonDownFcn', ...
            'LayoutManager(''selectGroup'', gcbo, [], guidata(gcbo))');
		%alpha(h,0.1);
    else,
		% Unselected Grop-View-Object
		col=info.col*0.8;
        set(h,'UserData',tmp, ...
	      'Tag',tagname, ...
			'FaceAlpha', 1, ...
            'LineStyle', '-', ...
			'EdgeColor', col, ...
			'FaceColor','none', ...
            'ButtonDownFcn', ...
            'LayoutManager(''selectGroup'', gcbo, [], guidata(gcbo))');
%            'Marker', 'o', ...
%            'MarkerEdgeColor', [0.7 .7 1], ...
    end
    % Can be down?
    if info.down,
      reload_child(absp,vgdata{idx}.Object,axh,[cvgp, idx],cvgp0);
    end
  end
return;

function selectGroup(hObject,eventdata,handles)
% Change Current Group to Select Group
% Execute on button down on Object in Axes2
%  Wehre Axes2  is Overall-View of the ViewGroup
% See also RELOAD_CHILD
  savenow_grouplist(handles);
  % Current Goup Path :: up
  ud = get(hObject,'UserData');
  setappdata(handles.LayoutManager, 'CurrentGroupPath',ud.cvgp);
  % Get Current Data
  vgdata=getCurrentVG(handles);
  % Show GUI
  showCurrentGroup(vgdata, handles);
  % Select Current Object
  set(handles.lbx_gplist,'Value',ud.idx);
  lbx_gplist_Callback(handles.lbx_gplist,[],handles);
return;

function showCurrentGroup(vgdata, handles)
% Show Currect View Group
%
% vgdata  : Current View Group Data
% handles : handles of LayoutManager 

  % ---------
  % Clear GUI
  % ---------
  axes(handles.axes1);
  axis manual; axis ([0 1 0 1]); hold on; 
  cla;
  val0   = get(handles.lbx_gplist, 'Value');
  gpname = {};%get(handles.lbx_gplist, 'String');
  gph    = [];%get(handles.lbx_gplist, 'UserData');
  mlist  = 1; %get(handles.pop_GroupMode, 'String');
  
  % Set Current Name text 
  curname   = getCurrentVGNAME(handles);
  set(handles.text_current_gpname, 'String', ...
	  sprintf('Zoomed Data : %s',curname));

  if ~isempty(vgdata),
    for i=1:length(vgdata),
      info=feval(vgdata{i}.MODE,'getBasicInfo');
      gpname{end+1}=vgdata{i}.NAME;
      absp=vgdata{i}.Position;
      x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1)];
      y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4)];
      h = fill(x,y,info.col);
      gph(end+1)   =h;
      % ------------
      % Set CallBack
      % ------------
      set(h, ...
		  'Marker','square', ...
		  'MarkerSize', 3, ...
		  'ButtonDownFcn', ...
		  ['LayoutManager(''ButtonDownObject'', gcbo, [], guidata(gcbo)', ...
			  ', ' num2str(i) ')']);
    end
    %lbx_gplist_Callback(handles.lbx_gplist,[],handles);
  end
  % ------
  %  Show 
  % ------
  if isempty(val0) || val0>length(vgdata)|| val0==0,
    set(handles.lbx_gplist, 'Value',length(vgdata));
  end
  set(handles.lbx_gplist, 'String',  gpname);
  set(handles.lbx_gplist, 'UserData',gph);
  if ~isempty(vgdata),
      psb_tile_Callback(handles.psb_reload,[],handles);
  end
return;


function addGroupChild(handles, addname,info)
% Add Group to GUI
%
% handles  : handles of LayoutManager
% addname  : Name of Group Data

  % ---------------------------
  % Get name-list, handle-list
  % ---------------------------
  gpname={};
  val    =get(handles.lbx_gplist, 'Value');
  gpname =get(handles.lbx_gplist, 'String');
  gph    =get(handles.lbx_gplist, 'UserData');

  % -------------------------------
  % Calculation Position of handle
  % -------------------------------
  rpos=[];
  if isempty(rpos),
    rpos = getappdata(handles.LayoutManager, 'GroupRect');
    if rpos(1)+0.05+rpos(3)<1 && rpos(2)+0.05+rpos(4)<1,
      rpos = [rpos(1)+0.05, rpos(2)+0.05, rpos(3), rpos(4)];
    else
      rpos = [0, 0, rpos(3), rpos(4)];
    end
    setappdata(handles.LayoutManager, 'GroupRect', rpos);
    set(handles.posedit, 'String', ['[' num2str(rpos) ']']);
  end

  absp=rpos;
  x  =[absp(1);absp(1)+absp(3);absp(1)+absp(3);absp(1)];
  y  =[absp(2);absp(2);absp(2)+absp(4);absp(2)+absp(4)];
  axes(handles.axes1);
  axis manual; axis ([0 1 0 1]); hold on; 

  % -----------------------------------------------
  % Get Object's Data information  , Create Handle
  % -----------------------------------------------
  if nargin<3,
	  info=ViewGroupData('getBasicInfo');
  end
  h = fill(x,y,info.col);

  % ----------------------------------
  % Set name-list, handle-list to GUI
  % ----------------------------------
  if isempty(addname), addname='Untitled Group';end
  gpname{end+1}=addname;
  gph(end+1)   =h;
  % -------------------------
  %   Set CallBack of handle
  % -------------------------
  id = length(gph);
  set(h, ...
	  'Marker','square', ...
	  'MarkerSize', 3, ...
      'ButtonDownFcn', ...
	  ['LayoutManager(''ButtonDownObject'', gcbo, [], guidata(gcbo)', ...
		  ', ' num2str(id) ')']);
  set(handles.lbx_gplist, 'String',  gpname);
  set(handles.lbx_gplist, 'UserData',gph);
return;

function deleteGroupChild(handles)
% Delete Group from GUI
%
% handles  : handles of LayoutManager
  % ---------------------------
  % Get name-list, handle-list
  % ---------------------------
  val    =get(handles.lbx_gplist, 'Value');

  % ------------------------
  %  Save Current ViewGroup 
  % ------------------------
  savenow_grouplist(handles);

  % ------------------------
  %  Get Current Group Path 
  % ------------------------
  cp = getappdata(handles.LayoutManager, 'CurrentGroupPath');
  vg = getCurrentVG(handles, cp);
  % ==> Delete <===
  if length(vg)>=val && val>0,
      vg(val)=[];
  end
  setCurrentVG(handles, vg);
  % ------
  %  Show 
  % ------
  showCurrentGroup(vg, handles);
return;

function resizeAxes2(h,e,handles)
% Check handles
  if isempty(handles) || ...
	~isfield(handles,'figure1'),
    % Before Opening Function::
    return;
  end

% hs : handles of this figure
  xorg=0.376;
  yorg=0.35;
  % Get PropertyList to FigProp-UserData
  figureProperty=get(handles.psb_Figprop, 'UserData');
  if isempty(figureProperty) || ...
          ~isfield(figureProperty,'Position'),
    X=0.5; Y=0.5;
  else,
    X=figureProperty.Position(3);
    Y=figureProperty.Position(4);
  end
  % Get Layout Manager size 
  fp=get(handles.figure1,'Position');
  xp=fp(3);yp=fp(4);

  %x = (yp*X)/(xp*Y)*yorg;
  rate=(yp*X)/(xp*Y);
  if rate>=1,
      y=yorg/rate;
      x=xorg;
  else,
      x=rate*xorg;
      y=yorg;
  end

  % Set Axes2 Position
  pos=get(handles.axes2,'Position');
  pos(3)=x;pos(4)=y;
  set(handles.axes2,'Position',pos);
  resizeAxes1(handles);
return;

function resizeAxes1(handles)
% hs : handles of this figure
  % Get axes2 position
  pos=get(handles.axes2,'Position');
  x2=pos(3); y2=pos(4);

  % Get Current Group
    %--> find from tagset(reload_child)
    cvgp=getappdata(handles.figure1, 'CurrentGroupPath');
    tagname=num2str(cvgp);
    tagname=strrep(tagname,' ','_');
    tagname=['SQ' tagname];
    % tagname
    h=findobj(handles.axes2,'Tag',tagname);
    if ~isempty(h),
      x=get(h,'XData');
      y=get(h,'Ydata');
      x=max(x(:))-min(x(:));
      y=max(y(:))-min(y(:));
    else,
      x=0.5;   % for debug
      y=0.5;
    end

  % Get axes1 position
  pos=get(handles.axes1,'Position');
  %x1=pos(3); y1=pos(4);
  x1=0.376;
  y1=0.35;

  rate=(x*x2)/(y*y2);
  %rate=(y2*x)/(x2*y);
  pos(3)=y1*rate;
  if pos(3)>x1,
      pos(3)=x1;
      pos(4)=x1/rate;
  else
      pos(4)=y1;
  end

  % Set Axes1 Position
  set(handles.axes1,'Position',pos);
return;

