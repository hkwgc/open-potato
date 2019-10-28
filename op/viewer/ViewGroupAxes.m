function varargout=ViewGroupAxes(fnc,varargin)
% Viewer-Group-Axes : File I/O Function.
%      Functions : getBasicInfo, getDefaultData, convert, gui,
%                  getGUIdata, exe
%      Callbacks : AddObj 
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
else
  feval(fnc, varargin{:});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=getBasicInfo
% Basic Info
  info.MODENAME = 'AXES';
  info.fnc      = 'ViewGroupAxes';
  info.down     = false;
  info.col      =[1 .8 1];
  info.strhead  = 'AX'; % Group-Axes
function data=getDefaultData
  data.NAME    = 'Untitled Axes';
  data.MODE    = 'ViewGroupAxes';
  data.Position=[0 0 1 1];
  data.Object  ={};
  data.ExpandFlag=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=convert(data),
  if ~strcmp(data.MODE,'ViewGroupAxes'),
    data.MODE   = 'ViewGroupAxes';
    data.Object = {};
    data.ExpandFlag=false;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=gui(figh,data)
% Set Axes-Object
  h0=guidata(figh);
  pos  =  get(h0.frm_set,'Position');

  % == Pop Up Menu ==
  % <-- Function List -->
  fnc={};ud={};str={};
  tmpdir = pwd;
  try
    osp_path= OSP_DATA('GET','OSPPATH');
    co_path = [osp_path filesep 'viewer' ...
               filesep 'axes_subobj'];
    cd(co_path);

    files = dir('osp_ViewAxesObj_*.m');
    for idx=1:length(files),
      try
        % - get data -
        [pth, nm, ex] = fileparts(files(idx).name);
        f0    = eval(['@' nm]);
        info  = feval(f0, 'createBasicInfo');
        u0    = info;
        s0    = info.MODENAME;
        % if success to get all data
		[fnc{end+1}, ud{end+1}, str{end+1}] = ...
			deal(f0,u0,s0);
      catch
        warning(lasterr);
      end
    end
  catch
    cd(tmpdir); rethrow(lasterror);
  end
  cd(tmpdir);
  
  % Popup Menu : Main
  tpos = [0.05, 0.62, 0.9, 0.08];
  handles.pop_Axes=uicontrol(figh,...
			     'Style','popupmenu',...
			     'Units','Normalized', ...
				 'BackgroundColor',[1, 1, 1], ...
			     'String', str, ...
			     'UserData', ud, ...
			     'Position',getPosabs(tpos,pos));
  %---------
  % Buttons	
  %---------
  % Position : 
  %  (width : 0.2220, space : 0.004)
  %  4 * wd + 3*sp = 0.90
  % sp=[0:0.001:0.01]'; % smal
  % wd= (0.90 - 3*sp)/4; % select proper value..
  % Button Color :
  bcl = [0.8, 0.7, 0.7];
  % Add button
  tpos = [0.05 0.5 0.222 0.1];
  handles.psb_Add=uicontrol(figh,...
			    'Style','pushbutton',...
			    'Units','Normalized', ...
				'FontUnits', 'normalized', ....
				'String', 'Add', ...
			    'Position',getPosabs(tpos,pos), ...
				'BackgroundColor', bcl, ...
			    'Callback',...
			    'ViewGroupAxes(''AddObj'',gcbo,[],guidata(gcbo))');
  % Modify button
  tpos = [0.276 0.5 0.222 0.1];
  handles.psb_Modify=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Modify', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupAxes(''ModifyObj'',gcbo,[],guidata(gcbo))');
  % Remove button
  tpos = [0.502 0.5 0.222 0.1];
  handles.psb_Remove=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Remove', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupAxes(''RemoveObj'',gcbo,[],guidata(gcbo))');
  % Help button
  tpos = [0.728 0.5 0.222 0.1];
  handles.psb_Help=uicontrol(figh,...
	  'Style','pushbutton',...
	  'Units','Normalized', ...
	  'FontUnits', 'normalized', ....
	  'String', 'Help', ...
	  'Position',getPosabs(tpos,pos), ...
	  'BackgroundColor', bcl, ...
	  'Callback',...
	  'ViewGroupAxes(''HelpObj'',gcbo,[],guidata(gcbo))');
  
  % List of Data
  tpos = [0.05 0.03 0.9 0.46];
  str={};ud={};
  try,
    for idx=1:length(data.Object),
      str{end+1}=data.Object{idx}.str;
      ud{end+1} =data.Object{idx};  
    end
  catch,
    str={};ud={};
  end
  handles.lbx_data=uicontrol(figh,...
			     'Style','ListBox', ...
			     'Units','Normalized', ...
			     'String', str, ...
				 'UserData',ud, ...
			     'BackgroundColor',[1 1 1], ...
			     'Position',getPosabs(tpos,pos));
  setappdata(figh,'HandleOfGroupdata',handles);

return;

function AddObj(hObject,evendata,handles)
% Add Axes obj : in LayoutManager

  figh=handles.LayoutManager;
  hs=getappdata(figh,'HandleOfGroupdata');
  id=get(hs.pop_Axes,'Value');
  ud=get(hs.pop_Axes,'UserData');
  
  % ==> Plugin Callback : set
  data=feval(ud{id}.fnc,'getArgument');
  if isempty(data), return; end
  stro= get(hs.lbx_data,'String');
  udo = get(hs.lbx_data,'UserData');
  stro{end+1}=data.str;
  udo{end+1} =data;
  set(hs.lbx_data,'String',stro,'UserData',udo, ...
	  'Value',length(udo));

function ModifyObj(hObject,evendata,handles)
% Remove Axes Object :
figh=handles.LayoutManager;
hs=getappdata(figh,'HandleOfGroupdata');

stro= get(hs.lbx_data,'String');
udo = get(hs.lbx_data,'UserData');
val = get(hs.lbx_data,'Value');

% check un selected? 
if val<1 || length(udo)<val, return; end
% modify
tmp= feval(udo{val}.fnc,'getArgument',udo{val});
if isempty(tmp), return; end
udo{val} =tmp;
stro{val}= udo{val}.str;
set(hs.lbx_data,...
	'String',stro,...
	'UserData',udo);
return;

function RemoveObj(hObject,evendata,handles)
% Remove Axes Object :
  figh=handles.LayoutManager;
  hs=getappdata(figh,'HandleOfGroupdata');
  
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
return;

function HelpObj(hObject,evendata,handles)
% Help of Axes Object
hs=getappdata(handles.LayoutManager,'HandleOfGroupdata');
id=get(hs.pop_Axes,'Value');
ud=get(hs.pop_Axes,'UserData');
eval(ud{id}.fnc); % ==> No argument : Help

function data=getGUIdata(figh,data),
%  data.MODE    = ViewGroupAxes;
%  data.Position=[0 0 1 1];
%  data.Object  ={};
try
  data.Mode = 'ViewGroupAxes';
  hs=getappdata(figh,'HandleOfGroupdata');
  data.Object = get(hs.lbx_data,'UserData');
  f=fieldnames(hs);
  for idx=1:length(f)
      try,
          delete(getfield(hs,f{idx}));
      end
  end
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeStart(vgdata,hname,abspos,varargin)

make_mfile('with_indent', '');
make_mfile('with_indent', '%  X X X X X X X X');
make_mfile('with_indent', ['%  Axes : ' vgdata.NAME]);
make_mfile('with_indent', 'clear AX;');
make_mfile('with_indent', ...
	sprintf('AX.handle=axes(''position'',[%f,%f,%f,%f]);', ...
	abspos(1),abspos(2),abspos(3),abspos(4)));
make_mfile('with_indent', '');
for idx=1:length(vgdata.Object),
	writeObj(vgdata.Object{idx},hname);
end
make_mfile('with_indent',[hname 'AX=AX;']);

function writeEnd(vgdata,hname,abspos,varargin)
make_mfile('with_indent', '%  X X X X X X X X');

%----------------------------
% M-File I/O Subfunctions
%----------------------------
function writeObj(obj,hname)
make_mfile('with_indent', '');
fname='Unknown';
try,
	fname=func2str(obj.fnc);
	feval(obj.fnc,'writeMfile',obj);
catch,
	errordlg({'OSP Error!', ...
			[' Function : ' fname], ...
			'  Error :', lasterr});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=exe(handles,vgdata,abspos,curdata)
%	Removed Arguments : chdata,cdata,bhdata,bdata
if nargin<4
  error('[E] : Not enough input arguments. 2317');
end

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
        'Label',['&' num2str(curdata.path(end)) '.  < ' vgdata.NAME ' >'], ...
        'TAG', vgdata.MODE);
end

%=====================
% Current Data Change
%=====================
% ******** TODO ********

%=====================
% Plot Axes
%=====================
% Confine GCF: to plot...
abspos=getPosabs(vgdata.Position,abspos);
set(0,'CurrentFigure',handles.figure1)
h.axes = axes('position',abspos);

%=========================
% Setting of ButtonDownFcn 
%=========================
switch curdata.enlargemode
  case -1,
    % Do nothing
    %set(h.axes,'ButtonDownFcn', '');
  case 0,
    % Do nothing
    % MapMode
  case 1,
    % Make MapMode
    % ---- Enlarge Axes ----
    AxesID=h.axes;
    p=get(h.axes,'Position');
    rcode = osp_FigureMapController('AddMapData',...
				    handles.figure1,...
				    AxesID, p, curdata.ch);
end % End swich of Setting of ButtonDownFcn

switch curdata.axestitlemode
  case 0,
    % Do nothing
  case 1,
    % axes title write
    title(num2str(curdata.ch));
end
%=====================
osp_LayoutViewerTool('setPathTag',h.axes,curdata);
if isfield(curdata,'menu_current')
    set(curdata.menu_current,'UserData',h);
end
fnames={'axes'};
hold on;

%=====================
% Plot Inner Object
%=====================
% Change Current Position
obj=vgdata.Object;
for idx=1:length(obj),
	%---------------------
	% Plot Object
	%---------------------
	fname='Unknown';
	try
    %axes(h.axes);
    set(handles.figure1,'CurrentAxes',h.axes);
	  info=feval(obj{idx}.fnc,'createBasicInfo');
	  if ~ischar(obj{idx}.fnc),
	    fname=func2str(obj{idx}.fnc);
	  end
	  % Plot Execution
	  str  =feval(obj{idx}.fnc,'drawstr',obj{idx});
    eval(str);
	  %h2   = eval(str);
	  
	  % Set Handles
	  fnames={'axes'};
	  % *** TODO ***
	catch
	  rethrow(lasterror); % i want avoid too many errordlg with ViewGroupGroup error. 100722TK@HARL
	  %eh = errordlg({'Axis-Object Error!', ...
		%	 [' Function : ' fname], ...
		%	 '  Error :', lasterr});
	  %%waitfor(eh);
	  %% Confine GCF: to plot...
	  %set(0,'CurrentFigure',handles.figure1)
	end
end
% Special Axis Setting..
if isfield(curdata,'xlim')
	set(h.axes,'Xlim',curdata.xlim);
end
if isfield(curdata,'ylim')
	set(h.axes,'Ylim',curdata.ylim);
end
%=========================
% Additional Axes Context-Menu
%  if there is Current Menu..
%
% TODO : Swich Mode
%=========================
if isfield(curdata,'uicontext_axes1'),
    set(h.axes,'uicontextmenu',curdata.uicontext_axes1);
    try,
        c=get(h.axes,'Children');
        if length(c)>=2,
          c(~cellfun('isempty',get(c,'uicontextmenu')))=[];
        end
        set(c,'uicontextmenu',curdata.uicontext_axes1);
    end
end

%=========================
% Additional Axes menu
%  if there is Current Menu..
%=========================
if isfield(curdata,'menu_current'),
    c=get(curdata.menu_current,'Children');
    hx=uimenu(curdata.menu_current, ...
        'Label', 'Edit Axes', ...
        'Callback', ...
        ['p=get(gcbo,''Parent'');' ...
            'ud=get(p,''UserData'');' ...
            'propedit(ud.axes);']);
    if ~isempty(c),
        set(hx,'Separator','on');
    end
    hx=uimenu(curdata.menu_current,...
        'Label','Launch Axes-Editor', ...
        'Callback', ...
        ['p=get(gcbo,''Parent'');' ...
            'ud=get(p,''UserData'');' ...
            'tmp.ax=gca;uiEditAxes(''arg_handle'',ud);']);
end
if curdata.dbgmode,
  osp_debugger('end',[mfilename '/exe']);
  disp(get(handles.figure1,'Visible'));
end
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
  lpos([1,3]) = lpos([1,3])*pos(3);
  lpos([2,4]) = lpos([2,4])*pos(4);
  lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
