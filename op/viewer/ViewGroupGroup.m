function varargout=ViewGroupGroup(fnc,varargin)
% Viewer-Group-Data with channel : File I/O Function.
%      Functions : getBasicInfo, getDefaultData, convert, gui,
%                  getGUIdata, exe 
%      local     : getChannelPosition


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% create : 2004.10.14
% $Id: ViewGroupGroup.m 180 2011-05-19 09:34:28Z Katura $



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
  info.MODENAME = 'GROUP CH';
  info.fnc  = 'ViewGroupGroup';
  info.down = true;
  info.col  = [.9 1 .9] ;
    info.strhead  = 'GC'; % Channel Grou
function data=getDefaultData
  data.NAME    = 'Untitled Channel-Group';
  data.MODE    = 'ViewGroupGroup';
  data.Position=[0 0 1 1];
  data.Object  ={};
  data.lineprop  ={};
  data.DistributionMode ='Normaly';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=convert(data),
  data.MODE   = 'ViewGroupGroup';
  data.Object = {};
  data.lineprop = {};
  data.DistributionMode ='Normaly';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=gui(figh,data)
% Set Channel Distribution
h0=guidata(figh);
pos  =  get(h0.frm_set,'Position');
cl   =  get(h0.frm_set,'BackgroundColor');

% PopupMenu of changing Channel-Distribution
% Popup Menu : Main
tpos = [0.05, 0.62, 0.33, 0.08];
handles.pop_txt1=uicontrol(figh,...
	'Style','text', ...
	'Units','Normalized', ...
	'FontUnits', 'normalized', ....
	'HorizontalAlignment', 'left', ...
	'BackgroundColor',cl, ...
	'String', 'Distribution : ', ...
	'Position',getPosabs(tpos,pos));
% Distribute : popupmenu;
str  ={'Normal','Normal0', 'Array(Square)','Array(2 Columns)'};
udstr={'Normal','Normal0', 'Square','2Columns'};
val=1;
if isfield(data, 'DistributionMode'),
	pind=find(strcmp(udstr, data.DistributionMode));
	if ~isempty(pind),val= pind; end
end
tpos = [0.4, 0.62, 0.55, 0.08];
handles.pop_DistributionMode = ...
	uicontrol(figh, ...
	'Style', 'popupmenu', ...
	'BackgroundColor',[1 1 1], ...
	'Unit','Normalized', ...
	'FontUnits', 'normalized', ....
	'HorizontalAlignment', 'left', ...
	'String', str, ...
	'UserData', udstr, ...
	'Value', val, ...
	'Position', getPosabs(tpos,pos));
setappdata(figh,'HandleOfGroupdata',handles);
return;

function data=getGUIdata(figh,data),
  if ~strcmp(data.MODE,'ViewGroupGroup'),
    error('GUI Data confuse!');
  end
  try
    hs=getappdata(figh,'HandleOfGroupdata');
    udstr=get(hs.pop_DistributionMode, 'Userdata');
    data.DistributionMode=udstr{get(hs.pop_DistributionMode, 'Value')};
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

% Separator Level :
sep=1;
try,
	idx=find(strcmp({varargin{1:2:end}},'SeparatorLevel'));
	if ~isempty(idx),
		sep=varargin{idx(1)*2};
	end
end

make_mfile('code_separator',sep);
make_mfile('with_indent', ['%  Gropu Channel : ' vgdata.NAME]);
make_mfile('code_separator',sep);

% CHDATA -> Header 
make_mfile('with_indent', ...
	{'% Get Channel Position Data', ...
		'if iscell(chdata),', ....
		'   header=chdata{1};', ...
		'else,', ...
		'   header=chdata;', ...
		'end'});
% Position Get
make_mfile('with_indent', ...
	{'psn  = time_axes_position(header, ...'
	sprintf('[%f, %f], [%f,%f]);', ...
		abspos(3),abspos(4), abspos(1),abspos(2))});

make_mfile('with_indent', 'for ch=1:size(psn,1),' );
make_mfile('indent_fcn', 'down');

function writeEnd(vgdata,hname,abspos,varargin)
make_mfile('indent_fcn', 'up');
make_mfile('with_indent', 'end % Channel Loop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=exe(handles,vgdata,abspos,curdata),
%=====================
% Menu Add
%=====================
path0 = curdata.path;
if isfield(curdata,'menu_current'),
    curdata.menu_current = ...
        uimenu(curdata.menu_current,...
        'Label',['&' num2str(curdata.path(end)) '.  { ' vgdata.NAME ' }'], ...
        'TAG', vgdata.MODE);
end

%=====================
% Current Data Change
%=====================
if curdata.enlargemode == 0, curdata.enlargemode=1;end
if curdata.axestitlemode == 0, 
  curdata.axestitlemode=1;
  osp_LayoutViewerTool('addMenu_AxesTitle',curdata);
end

%=====================
% Get Channel Position
%=====================
%[header,data]=osp_LayoutViewerTool('getCurrentData',handles.figure1,curdata);
header=osp_LayoutViewerTool('getCurrentData',handles.figure1,curdata);

%!!!!!!!!!!!!!!!!!!! New LayoutEditor !!!!!!!!!!!!!!!
% ==> Apply Property 
%!!!!!!!!!!!!!!!!!!! New LayoutEditor !!!!!!!!!!!!!!!
curdata=P3_ApplyAreaProperty(curdata,vgdata);


abspos0=abspos;
abspos=getPosabs(vgdata.Position,abspos);

%---> Switch By Setting <---
% Get Channel DistributionMode 
if ~isfield(vgdata,'DistributionMode'),
  warning(' No DistributionMode.');
  distmode=2;
end

%=====================
% Callback Object Loop
%=====================
if isfield(vgdata,'CObject'),
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
  
  % Callback-Menu recover : B110106A
  if isfield(curdata,'menu_callback'),
    ch = get(curdata.menu_callback,'Children');
    if isempty(ch),
      delete(curdata.menu_callback);
    end
    curdata.menu_callback=menu_current_bak;
  end
end

%-------------------------
% Make Normal Distribution
%--------------------------
switch vgdata.DistributionMode,
 case {'Normal', 'Normaly'},
  distmode=1;
 case 'Normal0',
  distmode=2;
 case 'Square',
  distmode=3;
 case '2Columns',
  distmode=4;
otherwise
  errordlg({...
      ' Layout Error : ',...
      ['   Undefined Distribution Mode : ' vgdata.DistributionMode],...
      '   Unpopulated  Distribute / Change Layout'},'Layout Error');
end

gdm_psn=cell(1,4); % GroupDistributeMenu Position
psn = time_axes_position(header, abspos(3:4),abspos(1:2));
gdm_psn{2}=psn; % Normal0
% normarized..
abspos(1:2)=abspos(1:2) + abspos(3:4)*0.01;
abspos(3:4)=abspos(3:4)*(1-0.02);
posmin = [min(psn(:,1)), min(psn(:,2))];
psn(:,1:2) = psn(:,1:2) - repmat(posmin,size(psn,1),1);
posmax = [max(psn(:,1)+psn(:,3)), max(psn(:,2)+psn(:,4))];
psn    = psn.*repmat(abspos(3:4)./posmax,size(psn,1),2);
psn(:,1:2) = psn(:,1:2) + repmat(abspos(1:2),size(psn,1),1);
gdm_psn{1}=psn; % Normal

s=size(header.flag);  % number of channel
gdm_psn{3}=getChannelPosition('Square', ...
			     s(3), abspos(3:4), abspos(1:2));
gdm_psn{4}=getChannelPosition('Square', ...
			     s(3), abspos(3:4), abspos(1:2));

gdm_ud.val = distmode;
gdm_ud.psn = gdm_psn;
gdm_ud.str ={'Normal','Normal0','Square','2Colums'};
% reSelect Position
psn= gdm_psn{distmode};

%===>
% *** TODO : Group-Distribute-Mode Callback ***
%<==

%===========================
% Channel Loop
%===========================
% To Speedup by T.K -> 2006.10.15
%tmpflag=false;
%if tmpflag,
%  % disp('--Use TMP Data--');
%  curdata.tmp_hdata=header;
%else,
%  % disp('--notuse TMP Data--');
%end
for ch=1:size(psn,1),
  %-------------------
  % Data For Channel
  %-------------------
  curdata.ch=ch;
  %if tmpflag,curdata.tmp_data =data(:,ch,:);end
  %=====================
  % My Children
  %=====================
  % Confine GCF: to plot...
  %set(0,'CurrentFigure',handles.figure1);
  % Change Current Position
  obj  = vgdata.Object;
  for idx=1:length(obj),
    info=feval(obj{idx}.MODE,'getBasicInfo');
    h=feval(obj{idx}.MODE,'getBasicInfo');
    hname = [ obj{idx}.MODE  num2str(idx)];
    curdata.hname = hname;
    curdata.path  = [path0, idx];
    h     = feval(obj{idx}.MODE,'exe',handles,obj{idx},...
		  psn(ch,:),curdata);
    handles=setfield(handles,hname,h);
  end
end
%toc
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
%=====================
% Add Uicontext Axis Menu
%=====================
curdata.uicontext_axes1=uimenu(curdata.uicontext_axes1,...
    'Label','Axis Setting','Separator','on');
curdata.uicontext_axes1=osp_LayoutViewerTool('addMenu_EditAllAxis',...
    1,curdata.uicontext_axes1,curdata);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inner Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psn = getChannelPosition(mode, chnum, pa_sz, pos),
  switch mode,
   case 'Square'
    cnum = ceil(sqrt(chnum));
   case '2Columns'
    cnum = 2;
   otherwise,
    error('No mode exist for Channel Position');
  end

  % width
  c_sz   = pa_sz(1)/cnum;
  c_sp   = c_sz * 0.2; % space of col : 20%
  c_spp2 = c_sp/2;

  cpos = pos(1)+c_spp2;
  for cid=2:cnum;
    cpos(cid)=cpos(cid-1)+c_sz;
  end

  % height
  rnum   = ceil(chnum/cnum);
  r_sz   = pa_sz(2)/rnum;
  r_spp2 = r_sz * 0.1; % space of col : 20%

  rpos = pos(2)+pa_sz(2) -(r_sz-r_spp2);
  for rid=2:rnum;
    rpos(rid)=rpos(rid-1)-r_sz;
  end

  psn=zeros(chnum,4);
  rid=1;
  ax_sz = [c_sz, r_sz] * 0.8;
  chid=1;
  for rid = 1: rnum
    for cid=1:cnum,
      psn(chid,:)=[cpos(cid), rpos(rid), ax_sz];
      chid=chid+1;
      if (chid>chnum) break; end
    end
  end

return;

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
