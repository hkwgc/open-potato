function varargout=osp_LayoutViewer(LAYOUT, chdata, cdata, varargin)
% OSP Viewer
% -- USEAGE of OSPVEIWER --
% 1st Argument: View-Layout Data
% 2nd Argument: Header of Continuous Data'
% 3rd Argument: Continuous Data
% More Arguments -->
%  sets of property name and property-value
%
% Table of properties.
%----------------------------------------
%  property name  |  value
%-----------------+----------------------
%  bhdata         | Header of Block-Data'
%  bdata          | Block-Data
%  figureh        | handle of plot figure.
%----------------------------------------
%
% Otherwise, sets of field-name and value.
% Like
%
% Table of Filed-Name and Value(Example)
%----------------------------------------
%  Filed-Name     |  value
%-----------------+--------------------
%  time           | Time-Range(min,max)
%  AxesMenuFlag   | True / False : Draw Axes-Menu on/off
%  enlargemode    | Mode : ButtonDownFnc of Axes.
%  axestitlemode  | VGG-Axes-Title:Channel  (-1:off)
%----------------------------------------
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.10.14
% $Id: osp_LayoutViewer.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.11 :
%    Add enlargemode by Kidachi ::
%     ---> Please set Comment
%
% Revision 1.12 :
%    Add Function : changeDefaultValueOfFig(logical,fig_handle)
%    Add Function : changeDefaultValueOfFig0(logical)
%
% Revision 1.1? :
%    Change Axes EnlargeMode ::  Axes-Button-Doun
%                               to Windows-Button-Doun
%
% Revision 1.16 :
%    Change Axes EnlargeMode ::  VGG Only
%
% Revision 1.27 : Add Toolbar
%                 Blush-up
%
%%  change Default-Value of GUI-Object to Draw fast.
% See also OSP/Schedule/doc/Viewer/ViewOff.html
global FOR_MCR_CODE;

%%%%%%%%%%%%%%%%%%%%%
% Arguments Check
%%%%%%%%%%%%%%%%%%%%%
% Number of Arguments
msg=nargchk(3,21,nargin);
if ~isempty(msg),
  useage(msg); return;
end

dbgmode=false;
if dbgmode,osp_debugger('start',mfilename);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Default Current-Variable-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(cdata), cdata={}; end
if ~iscell(cdata), cdata={cdata}; chdata={chdata};end
if length(cdata)~=length(chdata),
  errordlg('Continuous Data Size Error!');
  if dbgmode,osp_debugger('end',mfilename);end
  return;
end

curdata.region= 'Continuous'; 	% 'Continous'/'Block'
curdata.cidmax= length(cdata);  % Cell of Cdata
curdata.cid0  = min(1,curdata.cidmax);   % Continuous Data ID
if ~isempty(cdata)
  curdata.csize = size(cdata{1}); % Continuous Data Size
end
curdata.bidmax= 0;
curdata.bid0  = 0;              % Block ID
curdata.bsize = [0 0];          % Block Data Size
curdata.time  =[-Inf Inf];      % Time-Range (min, max)
% :: example ::
% if (t<curdata.time(1)), t=curdata.time(1); end
% if (t>curdata.time(2)), t=curdata.time(2); end
curdata.ch    =1;               % channel
curdata.kind  =[1 2];           %Data-Kind
curdata.dbgmode=dbgmode;        % Debug - Mode : Add 2006.09.28

curdata.enlargemode  =0;        % normal statement
curdata.axestitlemode=0;        % VGG-Axes-Title:Channel

bhdata=[]; bdata =[];           % Block Data
AxesMenuFlag   = true;            % Add 2006.06.19
InfoMenuFlag   = true;            % Add 2011.03.24
FigureMenuFlag = true;            % Add 2011.03.24
try
  %=========================
  % Transfer LAYOUT Version
  %=========================
  % Current Version :
  %     figprop
  %     vgdata
  switch (LAYOUT.ver)
    case {1,2},
      if isfield(LAYOUT,'FigureProperty')
        figprop= LAYOUT.FigureProperty; % Figure Property
      else
        figprop= [];
      end
      vgdata = LAYOUT.vgdata;         % Layout data
      %(View-Group-Data)
    otherwise,
      error(' Version of LAYOUT Error');
  end % End Version Siwtch

  %=========================
  % Set Other Property
  %=========================
  rlf=false; % Region Lock Flag Rock
  bbit = 0;
  al = length(varargin); % Argument Length
  if bitget(al,1)==1,
    error(' Invalid parameter/value pair arguments.');
  end
  for idx=1:2:al
    switch varargin{idx},
      case 'bhdata',
        bhdata = varargin{idx+1};
        if bitget(bbit,1),
          errordlg(' Block-Data Header : Double Defined');
          if dbgmode,osp_debugger('end',mfilename);end
          return;
        end
        bbit=bitset(bbit,1);
      case 'bdata',
        bdata = varargin{idx+1};
        if bitget(bbit,2),
          errordlg(' Block-Data Header : Double Defined');
          if dbgmode,osp_debugger('end',mfilename);end
          return;
        end
        bbit=bitset(bbit,2);

      case 'figureh',
        %  figureh        | handle of plot figure.
        figh=varargin{idx+1};
      case {'AxesMenuFlag','InfoMenuFlag','FigureMenuFlag'}
        if islogical(varargin{idx+1})
          vl=varargin{idx+1};
        elseif (varargin{idx+1}==1 || varargin{idx+1}==0),
          vl=varargin{idx+1}==1;
        else
          vl=true;
          warndlg({'Menu Flag must be logical!', ...
            'Ignore Value'});
        end
        % set
        switch varargin{idx}
          case 'AxesMenuFlag'
            AxesMenuFlag=vl;
          case 'InfoMenuFlag'
            InfoMenuFlag=vl;
          case 'FigureMenuFlag'
            FigureMenuFlag=vl;
        end
      case {'bidmax', 'bsize', 'csize','cidmax'},
        warndlg({['Can not set : ' varargin{idx}], ...
          '  Uncontrollable Variable for user.'});
      otherwise,
        eval(['curdata.' varargin{idx} '=varargin{idx+1};']);
        if strcmp(varargin{idx},'region'),
          rlf=true; % Lock Region
        end
    end % End Variable Name :
  end

  %-- Block Setting --
  if bbit==3,
    if rlf==false,
      curdata.region= 'Block'; % Change Region
    end
    curdata.bidmax= size(bdata,1);
    if curdata.bid0==0, curdata.bid0  = 1; end
    curdata.bsize = size(bdata);
  end

  % Check Data
  if curdata.cidmax < curdata.cid0,
    warndlg('Too Large cid');
    curdata.cid0 = curdata.cidxmax;
  end
  if ~isempty(cdata)
    curdata.csize = size(cdata{curdata.cid0});
  end
  if curdata.bidmax < curdata.bid0,
    warndlg('Too Large bid');
    curdata.bid0 = curdata.bidxmax;
  end
catch
  % When Error : Show Useage.
  useage({'Error Occur ', lasterr});
  if dbgmode,osp_debugger('end',mfilename);end
  return;
end

%%%%%%%%%%%%%%%%%%%%%
% Loading Information
%%%%%%%%%%%%%%%%%%%%%
nlh=figure('MenuBar','none',...
  'Units','Normalized', ...
  'Position',[0,0.9,0.2,0.1]);
set(nlh,'Color','white');
uicontrol(nlh,'Style','text', ...
  'BackgroundColor','white',...
  'Units','Normalized', ...
  'Position',[0.01,0.01,0.9,0.9], ...
  'String', 'Now Loading...');

%%%%%%%%%%%%%%%%%%%%%
% Making Figure
%%%%%%%%%%%%%%%%%%%%%
% --> Fast Write Setting <-- since 1.12
% See also OSP/Schedule/doc/Viewer/ViewOff.html
changeDefaultValueOfFig0(false);
% Figure Initialize
%  figureh        | handle of plot figure.
if ~exist('figh','var') || ~ishandle(figh)
  figh=figure('Visible','off'); % Main Figure
else
  set(0,'defaultFigureVisible','off');
  figh=figure(figh);
end
% --> Fast Write Setting <-- since 1.12
% OSP/Schedule/doc/Viewer/ViewOff.html
changeDefaultValueOfFig(false,figh);

%==> Default Setting <==
set(figh,'Units','Normalized');

%==> Initialize osp_FigureMapController
if (curdata.enlargemode == 0) || (curdata.enlargemode == 1),
  rcode = osp_FigureMapController('Initialize',figh);
end

%--> R2006a is too late, when we use Rendere 'OpenGL' <--
%  ==> use : 'auto'!!=> painter is best in this System..
%   20060424 : Checked by TK and MS
if 0,
  set(figh,'Renderer','zbuffer');
  %set(figh,'Renderer','OpenGL');
  set(figh,'DoubleBuffer','on');
end
if FOR_MCR_CODE
  try
    % -- XXXX in MCR OpenGL is not work-well XXXX ---
    set(figh,'Renderer','zbuffer');
    set(figh,'RendererMode','manual');
  catch
  end
end

% External Imput Properties
if ~isempty(figprop) && isstruct(figprop),
  % Structure Version
  % Format like following
  pn = fieldnames(figprop);
  vl = struct2cell(figprop);
  set(figh,pn',vl');
elseif ~isempty(figprop) && iscell(figprop),
  % Cell Version
  % Format like following
  % figprop={'propname',val, ...}
  set(figh,figprop{:});
end
%==> confine Units is Normalized <==
set(figh,'Units','Normalized','Visible','off');

% <- Not to use gcf ->
curdata.gcf = figh;

% ============
% Set Appdata
% ============
setappdata(figh, 'CHDATA', chdata);
setappdata(figh, 'CDATA',  cdata);
setappdata(figh, 'BHDATA', bhdata);
setappdata(figh, 'BDATA',  bdata);

% initialize for Execute..
abspos=[0 0 1 1];
handles.figure1=figh;
% Add Menu
%==========================
% Info Menu Starting
%==========================
if InfoMenuFlag
  handles.mainmenu    = uimenu('Parent',figh,'Label','Info', ...
    'TAG', 'mainmenu');

  % Information of Input Value
  handles.menu_datainfo = uimenu(handles.mainmenu,'Label','&Data Info', ...
    'TAG', 'menu_datainfo');
  handles.menu_layoutinfo = uimenu(handles.menu_datainfo, ...
    'Label', '&Layout Data', ...
    'TAG', 'menu_layoutinfo');
  try,
    handles.menu_layoutinfo0 = uimenu(handles.menu_layoutinfo, ...
      'Label', 'Mode &0', ...
      'UserData', vgdata2txt(vgdata,'text'), ...
      'Callback', 'msgbox(get(gcbo,''UserData''),''Layout Data'');', ...
      'TAG', 'menu_layoutinfo0');
  end
  try
    handles.menu_layoutinfo1 = uimenu(handles.menu_layoutinfo, ...
      'Label', 'Mode &1', ...
      'UserData', vgdata2txt(vgdata,'text1'), ...
      'Callback', 'msgbox(get(gcbo,''UserData''),''Layout Data'');', ...
      'TAG', 'menu_layoutinfo1');
  end
  try
    handles.menu_layoutinfo2 = uimenu(handles.menu_layoutinfo, ...
      'Label', 'Mode &2', ...
      'UserData', vgdata2txt(vgdata,'text2'), ...
      'Callback', 'msgbox(get(gcbo,''UserData''),''Layout Data'');', ...
      'TAG', 'menu_layoutinfo1');
  end
  % Information Using Function
  % (Add in Axes
  if 0
    handles.menu_fcninfo  = uimenu(handles.mainmenu,'Label','&Functions Info', ...
      'TAG', 'menu_fcninfo');
    curdata.menu_fcninfo   = handles.menu_fcninfo; % set control menu..
    handles.menu_fcn_OSP=...
      uimenu(curdata.menu_fcninfo,'Label','OSP', 'Callback', 'OspHelp OSP', ...
      'TAG','menu_fcn_OSP');
    handles.menu_fcn_LayoutView= ...
      uimenu(curdata.menu_fcninfo,'Label','Layout Viewer', ...
      'Callback', 'OspHelp osp_LayoutViewer', ...
      'TAG','menu_fcn_LayoutView');
  end
end % Info Menu

%==========================
% Axes Menu Starting
%==========================
if AxesMenuFlag,
  handles.menu_viewii = uimenu(handles.figure1,...
    'Label','&Axes Control', ...
    'TAG', 'menu_viewii');
  curdata.menu_current   = handles.menu_viewii; % set control menu..
end
%==========================
% Axes Context-Menu Starting
%==========================
if 1,
  curdata.uicontext_axes1=uicontextmenu;
  uimenu(curdata.uicontext_axes1,...
    'Label','Figure Enlarge',...
    'Callback',['a0=get(gcbf,''CurrentPoint'');',...
    'osp_FigureEnlarge(gcbf,a0,''normal'');']);
  uimenu(curdata.uicontext_axes1,...
    'Label','Edit Axes Title Font',...
    'Separator','on',...
    'Callback','uisetfont(get(gca,''TITLE''));');
  uimenu(curdata.uicontext_axes1,...
    'Label','Edit Axes Font',...
    'CallBack','uisetfont(gca);');
  uimenu(curdata.uicontext_axes1,...
    'Label','Launch OSP Axes-Editor', ...
    'Separator','on',...
    'Callback', ...
    'tmp.ax=gca;uiEditAxes(''arg_handle'',tmp);');
end

%==========================
% Control (Callback) Menu Starting
%==========================
handles.menu_callback = uimenu(handles.figure1,...
  'Label','&Callbacks', ...
  'TAG', 'menu_callback');
curdata.menu_callback = handles.menu_callback;

%==========================
% Figure Property Menu
%   (Figure Fixed )
%==========================
if FigureMenuFlag
  handles.menu_figprop = uimenu(handles.figure1,...
    'Label','Figure &Setting', ...
    'TAG', 'menu_color');
  handles.menu_clrchse = uimenu(handles.menu_figprop,...
    'Label','Colormap', ...
    'TAG', 'menu_colormap');
  % map
  % 1: default
  % 2: hot
  % 3: gray
  % 4: blue-red
  % 5: inverse-gray
  handles.menu_colormap01 = uimenu(handles.menu_clrchse,...
    'Label','0&1. default', ...
    'TAG', 'menu_default',...
    'Callback', ...
    'osp_set_colormap(1)');
  %   'osp_set_colormap(1,default)');
  handles.menu_colormap02 = uimenu(handles.menu_clrchse,...
    'Label','0&2. hot', ...
    'TAG', 'menu_hot',...
    'Callback', ...
    'osp_set_colormap(2)');
  %   'osp_set_colormap(2,hot)');
  handles.menu_colormap03 = uimenu(handles.menu_clrchse,...
    'Label','0&3. gray', ...
    'TAG', 'menu_gray',...
    'Callback', ...
    'osp_set_colormap(3)');
  %   'osp_set_colormap(3,gray)');
  handles.menu_colormap04 = uimenu(handles.menu_clrchse,...
    'Label','0&4. blue-red', ...
    'TAG', 'menu_blue-red',...
    'Callback', ...
    'osp_set_colormap(4)');
  %   'osp_set_colormap(4,blue-red)');
  handles.menu_colormap05 = uimenu(handles.menu_clrchse,...
    'Label','0&5. inverse-gray', ...
    'TAG', 'menu_inverse-gray',...
    'Callback', ...
    'osp_set_colormap(5)');
  %   'osp_set_colormap(5,inverse-gray)');

  % add Renderer menu
  %==
  % renderer
  handles.menu_renderer = uimenu(handles.menu_figprop,...
    'Label','Renderer', ...
    'TAG', 'menu_renderer');
  
  handles.menu_renderer_1 = uimenu(handles.menu_renderer,...
    'Label','Painter', ...
    'TAG', 'menu_renderer_1', ...
    'Callback', ...
    ['set(gcf,''renderer'',''Painter'');H=guidata(gcbo);',...
    'set(H.menu_renderer_1,''Checked'',''on'');',...
    'set(H.menu_renderer_2,''Checked'',''off'');',...
    'set(H.menu_renderer_3,''Checked'',''off'');']);
  handles.menu_renderer_2 = uimenu(handles.menu_renderer,...
    'Label','zbuffer', ...
    'TAG', 'menu_renderer_2', ...
    'Callback', ...
    ['set(gcf,''renderer'',''zbuffer'');H=guidata(gcbo);',...
    'set(H.menu_renderer_1,''Checked'',''off'');',...
    'set(H.menu_renderer_2,''Checked'',''on'');',...
    'set(H.menu_renderer_3,''Checked'',''off'');']);
  handles.menu_renderer_3 = uimenu(handles.menu_renderer,...
    'Label','OpenGL', ...
    'TAG', 'menu_renderer_3', ...
    'Callback', ...
    ['set(gcf,''renderer'',''OpenGL'');H=guidata(gcbo);',...
    'set(H.menu_renderer_1,''Checked'',''off'');',...
    'set(H.menu_renderer_2,''Checked'',''off'');',...
    'set(H.menu_renderer_3,''Checked'',''on'');']);
end % Figure Property Menu

osp_WindowControl('init',handles.figure1);
%%%%%%%%%%%%%%%%%%%%%%%
%=====> Execute <======
%%%%%%%%%%%%%%%%%%%%%%%
handles=exe(handles,vgdata,abspos,curdata);
% --> Remove! :  Use Application Data : 20060424
%	chdata,cdata,bhdata,bdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===== GUI Setting  ==========
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Handle data to figure;
% This data will be use in Menu or Callbacks.
% See also GUIDATA.
h0=guidata(figh);
if ~isempty(h0) && isstruct(h0)
  n=fieldnames(h0);
  for idx=1:length(n),
    try,
      eval(['handles.' n{idx} '=h0.' n{idx} ';']);
    end
  end
end
guidata(figh,handles);

changeDefaultValueOfFig0(true);
changeDefaultValueOfFig(true,figh);

% Vislble On
set(figh,'Visible','on');

try,
  if ishandle(nlh), delete(nlh);end
end
if (curdata.enlargemode == 0) || (curdata.enlargemode == 1),
  set(figh,'WindowButtonDownFcn',...
    'osp_FigureEnlarge(gcbf,get(gcbf,''CurrentPoint''),get(gcbf,''SelectionType''));');
end

% ===== Output  ==========
if nargout>=1
  varargout{1}=handles;
end
if dbgmode,osp_debugger('end',mfilename);end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=exe(handles,vgdata,abspos,curdata)
% Execute 1st
% Delete : chdata,cdata,bhdata,bdata

% Cell loop
for idx=1:length(vgdata),
  info    = feval(vgdata{idx}.MODE,'getBasicInfo');
  hname   = [ vgdata{idx}.MODE  num2str(idx)];
  try
    curdata.hname = hname;
    curdata.path  = idx;
    %h       = feval(vgdata{idx}.MODE,'exe',handles,vgdata{idx},abspos,curdata,...
    %    chdata,cdata,bhdata,bdata);
    h       = feval(vgdata{idx}.MODE,'exe',handles,vgdata{idx},abspos,curdata);
    handles.(hname)=h;
  catch
    errordlg({'--- OSP Error!!---', ...
      ['  ModeName         : ' info.MODENAME], ...
      ['  FuncName         : ' info.fnc], ...
      ['  ObjectName       : ' vgdata{idx}.NAME], ...
      ['  Number of Object : ' ...
      num2str(length(vgdata{idx}.Object))], ...
      '  Last Error :  ', lasterr});
  end
end

% ==Menu :: optional :: ==
% Edit All axis Menu:
if isfield(curdata,'menu_current'),
  handles.menu_editAllAxes=uimenu(curdata.menu_current, ...
    'Label','Edit All Axes',...
    'Separator','on', ...
    'Callback', ...
    'a0=findobj(gcbf,''Type'',''Axes'');propedit(a0);');
  handles.menu_editAxesTitleFont=uimenu(curdata.menu_current,...
    'Label','Edit Axes Title Font',...
    'Callback', ...
    'osp_LayoutViewerTool(''addMenu_AxesFont'',1,gcbf);');
  handles.menu_editAxesFont=uimenu(curdata.menu_current,...
    'Label','Edit Axes Font',...
    'CallBack',...
    'osp_LayoutViewerTool(''addMenu_AxesFont'',2,gcbf);');
end
% qflag=getappdata(gcf,'IMAGE_QUIVER');
% if ~isempty(qflag) && isfield(curdata,'menu_callback'),
%   handles.menu_quiver=uimenu(curdata.menu_callback, ...
%     'Label','Quiver',...
%     'Checked','off', ...
%     'Callback', ...
%     ['if strcmp(get(gcbo,''Checked''),''on''),' ...
%     '   set(gcbo,''Checked'',''off'');' ...
%     '   setappdata(gcbf,''IMAGE_QUIVER'',false);' ...
%     'else,' ...
%     '   set(gcbo,''Checked'',''on'');' ...
%     '   setappdata(gcbf,''IMAGE_QUIVER'',true);' ...
%     'end']);
% end

% Delete Callback Menu?
if isfield(curdata,'menu_callback'),
  ch=get(curdata.menu_callback,'Children');
  if isempty(ch), delete(curdata.menu_callback);end
end



return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h, rev, dd]=useage(msg0)
% Useage of OSPVIWER
rev   = '$Revision: 1.28 $';
rev([1, end])=[];
dd = '$Date: 2010/03/02 13:57:26 $';
dd([1 , end])=[];


msg ={' ------- USEAGE of OSPVEIWER -------' ,...
  ['     ' rev], ...
  ['     ' dd], ...
  ' -------------------------------------', ...
  '', ...
  '1st Argument: View-Layout Data', ...
  '2nd Argument: Header of Continuous Data', ...
  '3rd Argument: Continuous Data', ...
  '', ...
  'More Arguments --> Property + data', ...
  ' bhdata : Header of Block-Data', ...
  ' bdata  : Block-Data', ...
  ' Otherwise : Field of Current Variable'};

% Add Unique Information
if ~isempty(msg0) && ischar(msg0),
  msg{end+1}=' -------------------------------------';
  msg{end+1}=' Run Message : ';
  msg{end+1}=' -------------------------------------';
  if ~iscell(msg0), msg0={msg0}; end
  for idx=1:length(msg0),
    msg{end+1}=msg0{idx};
  end
end

% Display Message
h=msgbox(msg,'Useage of Layout Viewer II');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change Default-Value of GUI-Object to Fast Draw.
%    since 1.12
%
% See also OSP/Schedule/doc/Viewer/ViewOff.html
% See also OSP/Schedule/doc/Viewer/SearchR2006a.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changeDefaultValueOfFig0_slow(isrecover)
% isrecover : true  -> set backup-value
% isrecover : false -> set vale
persistent bkval;
prop={'defaultFigureVisible', ...
  'defaultUicontrolVisible'};
idxmax=2;
if isrecover && ~isempty(val),
  val=bkval;
else
  val={'off','off'};
  % -- Backup Values --
  for idx=1:idxmax,
    try,
      bkval{idx}=get(0,prop{idx});
    end
  end
end
for idx=1:idxmax,
  try,
    set(prop{idx},val{idx});
  end
end

function changeDefaultValueOfFig0(isrecover)
% isrecover : true  -> set backup-value
% isrecover : false -> set vale
%
% This function was written not to use
% extra memory..

% --> if you want safty, use Try-Catch
if isrecover,
  set(0,'defaultFigureVisible', 'on');
  %'DefaultAxesVisible','on');
else
  set(0,'defaultFigureVisible', 'off');
  %'DefaultAxesVisible','off');
end

function changeDefaultValueOfFig(isrecover,figh)
% change Default-Value of GUI-Object to Fast Draw.
if isrecover,
  %    as=findobj(figh,'Type','Axes');
  %    axis(as,'on');
  %   axis(as,'tight');

  %ui=findobj(figh,'Type','uicontrol');
  %set(ui,'Visible','on');
  set(figh,'Toolbar','figure');
else
  set(figh,...
       'DefaultTextInterpreter','none');

  %       'DefaultUicontrolVisible','off',...
  %       'DefaultAxesFontSIZE',0.1,...
  %       'DefaultAxesFontUnits','Normalized',...
  %       'DefaultAxesALimMode','manual',...
  %       'DefaultAxesCLimMode','manual',...
  %       'DefaultAxesPlotBoxAspectRatioMode','manual',...
  %       'DefaultAxesTickDirMode','manual',...
  %       'DefaultAxesXLimMode','manual',...
  %       'DefaultAxesYLimMode','manual',...
  %       'DefaultAxesZLimMode','manual',...
  %       'DefaultAxesXTick',[],...
  %       'DefaultAxesYTick',[],...
  %       'DefaultAxesZTick',[],...
  %       'DefaultAxesXTickLabel','',...
  %       'DefaultAxesYTickLabel','',...
  %       'DefaultAxesZTickLabel','');

  %       'DefaultAxesCameraPositionMode','manual',...
  %       'DefaultAxesCameraTargetMode','manual',...
  %       'DefaultAxesCameraUpVectorMode','manual',...
  %       'DefaultAxesCameraViewAngleMode','manual',...
end
