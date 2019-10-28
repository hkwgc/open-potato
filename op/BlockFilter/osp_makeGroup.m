function varargout=osp_makeGroup(varargin)
%  uiGrouping make OSP-Group-Data by GUI.
%
%  The GUI listup Signal-Data in the Project, 
%  so select Signal-Data Files and Stimulation Mark.
%
% $Id: osp_makeGroup.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji (ULSI)
% create : 2006.07.26
% $Id: osp_makeGroup.m 180 2011-05-19 09:34:28Z Katura $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of Persistent Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbgmode = false;
% My GUI Handle
persistent myfighandle;

% Not Opened..
if isempty(myfighandle) || ...
      ~ishandle(myfighandle),
  if dbgmode,osp_debugger('start',mfilename);end
  try,
    %------------
    % Get Layout.
    %------------
    if dbgmode,osp_debugger('start','myLayoutFcn');end
    [myfighandle,hs]=myLayoutFcn;
    if dbgmode,osp_debugger('end','myLayoutFcn');end

    %-------------------
    % Opening Function.
    %-------------------
    r=osp_makeGroup('myOpeningFcn',myfighandle,hs);
    if ~isempty(r),
      % Waiting....
      set(myfighandle,'Visible','on');
      waitfor(myfighandle,'UserData',true);
    end
    if ~ishandle(myfighandle),
      % Deleted Before Output Setting
      for idx=1:nargout,
        varargout{idx}=[]; % All Empty
      end
    else,
      %--------------------------
      % Out put & Delete Function
      %--------------------------
      hs=guidata(myfighandle); % Reload
      if nargout,
        if dbgmode,osp_debugger('start','myOutputFcn');end
        [varargout{1:nargout}] = myOutputFcn(myfighandle,hs);
        if dbgmode,osp_debugger('end','myOutputFcn');end
      end
      try,delete(myfighandle);end
      myfighandle=[];
    end
  catch,
    myfighandle=[];
    if dbgmode,osp_debugger('rethrow',mfilename);end
  end
  if dbgmode,
    if nargout==0,
      osp_debugger('end',mfilename);
    else
      for idx=1:nargout,
        varargout{idx}=hs.output{idx};
      end
      osp_debugger('end',mfilename,varargout{:});
    end
  end
  return;
end

%==================
% Launcher
%==================
if nargin,
  if dbgmode,osp_debugger('start',varargin{:});end
  % Evaluate Callbacks
  try,
    if nargout,
      [varargout{1:nargout}] = feval(varargin{1}, varargin{2:end});
    else,
      feval(varargin{1}, varargin{2:end});
    end
  catch,
    if dbgmode,osp_debugger('rethrow',varargin{1});end
  end

  if dbgmode,
    if nargout,
      osp_debugger('end',varargin{1},varargout{:});
    else,
      osp_debugger('end',varargin{1});
    end
  end
  % Error Occur
else, 
  % No input (and not Opening Function)
  % Return My handles
  if nargout>=1,
    varargout{1}=myfighandle;
  end
  if nargout>=2,
    varargout{2}=guidata(myfighandle);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening.. Layout Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setcdata2button(h,ardata,cl1,cl2),
% Set ColorData (map);
cl = [0.8 0.9 0.8; 0.2 0.4 0.2];
if nargin>=3, cl(1,:)=cl1;end
if nargin>=4,cl(2,:)=cl2;end
sz=size(ardata);
sz(end+1)=3;
cdata=zeros(sz);
for x=1:sz(1),
  for y=1:sz(2),
    cdata(x,y,:)=cl(ardata(x,y),:);
  end
end
set(h,'CData',cdata);

function [h,hs]=myLayoutFcn()
% Open Figure
% h   : Figure handle.
% hs  : handles ( ==guidata)
% hs2 : my special grouping handles

  %==============================
  % Initialized
  %==============================
  OSP_LOG('msg','Grouping ');  

  % Figure Size
  sz0=[0, 30,110, 32];
  % Back Ground Color
  cl = [1 1 1];
  % Default Button Color
  cl2= [.8 .9 .8];
  cl3= cl2;
  % Pecture of Button Data
  load('osp_mark_button_img.mat','ardata'); % ardata
  % Markers Color
  clmark = [.8 .85 .9];
  % Main Button Color
  clb = [.5 .7 .9]; 

  %==============================
  % Figure 
  %==============================
  
  % Open Figure
  h=figure('Units','Characters', ...
	   'IntegerHandle','off',...
     'Color',cl, ...
	   'MenuBar','none', ...
	   'Name', 'Grouping..', ...
	   'NumberTitle','off', ...
	   'Position',sz0, ...
	   'Tag','OSP_Grouping', ...
     'Visible','off', ...
	   'KeyPressFcn', ...
	   'osp_KeyBind(gcbo,[],guidata(gcbo),osp_osp_makeGroup)');
  hs.figure1=h;
  set(h,'Units','Normalized'); % Normarized

  % Set Title
  p=[0, 0.95, 1, 0.05];
  hs.title  = uicontrol('Parent',h, ...
			'Units','Normalized', ...
			'FontSize',12, ...
			'Position',p, ...
      'BackgroundColor',cl, ...
			'String','Grouping $Revision: 1.4 $', ...
			'HorizontalAlignment','left', ...
			'Style','text', ...
			'Tag','title');
  
  %==============================
  % Filte Area
  %==============================
  hp=[0.01, 0.9, 0.4, 0.05];
  hs.fhead  = uicontrol('Parent',h, ...
			'Units','Normalized', ...
      'BackgroundColor',cl, ...      
			'Position',hp, ...
			'String','Files', ...
			'HorizontalAlignment','left', ...
			'Style','text', ...
			'Tag','fhead');
  % Up Button
  bup=0.84; bdp=0.14;
  bp=[0.01, bup, 0.04, 0.06];
  hs.psb_up = uicontrol('Parent',h,...
			'Units','normalized',...
      'BackgroundColor',cl2, ...
			'Callback','osp_makeGroup(''psb_up_Callback'',guidata(gcbo))',...
			'Position',bp, ...
			'Tag','psb_up');
  setcdata2button(hs.psb_up,ardata,cl2);
  % Down Button
  bp(2)=bdp;
  hs.psb_down = uicontrol('Parent',h,...
			  'Units','normalized',...
        'BackgroundColor',cl2, ...
			  'Callback',...
			  'osp_makeGroup(''psb_down_Callback'',guidata(gcbo))',...
			  'Position',bp, ...
			  'Tag','psb_down');
  setcdata2button(hs.psb_down,ardata(end:-1:1,:),cl2);
  % File Re-Select
  p(1) = bp(1)+0.1;
  p(2) = bp(2)*1.0;
  p(3) = hp(3)-0.1;
  p(4) = bp(4)*0.9;
  hs.psb_fs = uicontrol(...
      'Parent',h,...
      'Units','normalized',...
      'BackgroundColor',clb,...
      'Callback',...
      'osp_makeGroup(''psb_fs_Callback'',guidata(gcbo))',...
      'Position',p, ...
      'String','File Select',...
      'Tag','psb_fs');
    
  % File Text
  y = linspace(bdp+0.06,bup,11); y0=y(11);y=y(10:-1:1);
  p = bp; p(3)=hp(3);p(4)=(y(1)-y(2))*0.9;
  yl= y(end)-p(4);
  hs.txt_file=zeros([10,1]);
  for idx=1:10,
    p(2)=y(idx);
    hs.txt_file(idx)=...
	uicontrol('Parent',h,...
		  'Units','Normalized', ...
		  'Position',p, ...
      'BackgroundColor',cl, ...
		  'String','not load yet.', ...
		  'HorizontalAlignment','right', ...
		  'Style','text', ...
		  'Visible','off', ...
		  'Tag',['txt_file' num2str(idx)]);
  end

  %==============================
  % Marker Setting Area
  %==============================
  hp(1)=hp(1)+0.5;
  hs.mhead  = uicontrol('Parent',h, ...
			'Units','Normalized', ...
			'Position',hp, ...
      'BackgroundColor',cl, ...
			'String','Files', ...
			'HorizontalAlignment','left', ...
			'Style','text', ...
			'Tag','mhead');

  % Left Button
  blp=hp(1)-0.06; brp=0.9;
  bp=[blp, bup, 0.04, 0.06];
  hs.psb_left = uicontrol('Parent',h,...
			  'Units','normalized',...
        'BackgroundColor',cl2, ...
			  'Callback',...
			  'osp_makeGroup(''psb_left_Callback'',guidata(gcbo))',...
			  'Position',bp, ...
			  'Tag','psb_left');
  ardata=ardata';
  setcdata2button(hs.psb_left,ardata,cl2);
  % Right Button
  bp(1)=brp;
  hs.psb_down = uicontrol('Parent',h,...
			  'Units','normalized',...
        'BackgroundColor',cl2, ...
			  'Callback',...
			  'osp_makeGroup(''psb_right_Callback'',guidata(gcbo))',...
			  'Position',bp, ...
			  'Tag','psb_right');
  setcdata2button(hs.psb_down,ardata(:,end:-1:1),cl2);

  % Marker Frame
  fp = [hp(1) ,  bdp+0.06, brp-hp(1), bup-bdp-0.06];
  hs.frm_mark  = ...
      uicontrol('Parent',h,...
		'Units','normalized',...
    'BackgroundColor',clmark,...
		'Position',fp, ...
    'Style','Frame', ...
		'Tag', 'frm_mark');
  % Marker Check box
  x = linspace(hp(1),brp,6);
  p(3)=(x(2)-x(1))*0.8; dpx=(x(2)-x(1))*0.1;
  p(4)=(y(1)-y(2))*0.8; dpy=(y(1)-y(2))*0.1;
  hs.cmhs=zeros(1,5);
  hs.cbhs=zeros(10,5);    % Handles
  hs.cbus=false([10,5]);  % Use flag
  hs.cehs=zeros(1,5);
  for ix=1:5,
    p(1)=x(ix)+dpx;
    p(2)=y0;
    hs.mhead  = uicontrol('Parent',h, ...
      'Units','Normalized', ...
      'Position',p, ...
      'BackgroundColor',cl, ...
      'String',['M' num2str(ix)], ...
      'HorizontalAlignment','left', ...
      'Style','text', ...
      'Tag',['ckb' num2str(ix) '_Mark']);
    for iy=1:10,
      p(2)=y(iy)+dpy;
      hs.cbhs(iy,ix)=...
	  uicontrol('Parent',h,...
		    'Units','Normalized', ...
        'BackgroundColor',clmark,...
		    'Position',p, ...
		    'String','', ...
		    'Style','checkbox', ...
		    'Visible','off', ...
        'Tag',['ckb' num2str(ix) '_' num2str(iy)]);
    end
    p(2)=yl;
    hs.cbhs_all(ix)=uicontrol('Parent',h,...
			      'Units','Normalized', ...
			      'BackgroundColor',cl,...
			      'Position',p, ...
			      'String','', ...
			      'Style','checkbox', ...
			      'Visible','off', ...
			      'Tag',['ckb_All' num2str(ix) ]);
  end

  %=====================
  % Last Button
  %=====================
  p = [0.6, 0.02, 0.15, 0.04];
  hs.psb_ok = uicontrol(...
      'Parent',h,...
      'Units','normalized',...
      'BackgroundColor',clb,...
      'Callback',...
      'osp_makeGroup(''psb_ok_Callback'',guidata(gcbo))',...
      'Position',p, ...
      'String','OK',...
      'Tag','psb_ok');
  p = [0.8, 0.02, 0.15, 0.04];
  hs.psb_cancel = uicontrol(...
      'Parent',h,...
      'Units','normalized',...
      'BackgroundColor',clb,...
      'Callback',...
      'osp_makeGroup(''psb_cancel_Callback'',guidata(gcbo))',...
      'Position',p, ...
      'String','Cancel',...
      'Tag','psb_cancel');
  
  %======================
  % Add Menu
  %======================
  %h.menu_help=uimenu(h,'Label','&Help');

  %======================
  % Last Check
  %======================
  hs.output=h;
  guidata(h,hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function r=myOpeningFcn(hObject,hs),
% Opening Function ot this GUI.
% This Function Select Figure Managers.
% and Initialize all data.
r='';

%==========================
% File Selection
%==========================
flag=true;
while flag,
  osp_makeGroup('psb_fs_Callback',hs);
  fs=getappdata(hObject,'CurrentFigures');
  if ~isempty(fs), break; end
  a=questdlg({'"Make Groping" Need Some Signal-Data Files.', ...
	      ' Do you want to Cancel open "Make Groping"?'}, ...
	     'Quest', ...
	     'Yes', 'No','Yes');
  if strcmp(a,'Yes'), return;end
end

r='load done';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reload Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function psb_fs_Callback(hs),
% Callback function of Figure Select Push-Button's,
% This also called from myOpening Function
x=get(hs.figure1,'Visible');
set(hs.figure1,'Visible','off');

actdata_bk = OSP_DATA('GET','ACTIVEDATA');
try,
  fs_h = uiFileSelect('DataDif', { 'SignalPreprocessor'}, 'SetMax', 10);
  waitfor(fs_h);
  set(hs.figure1,'Visible',x);
  actdata = OSP_DATA('GET','ACTIVEDATA');
catch,
  OSP_DATA('SET','ACTIVEDATA',actdata_bk);
  rethrow(lasterr);
end

OSP_DATA('SET','ACTIVEDATA',actdata_bk);
if isempty(actdata), return; end

%== Selecting File List! ==
fnum=length(actdata);
stim=cell([fnum,1]);
stimmax0 = size([fnum,1]);
stimmax  =-Inf;
for fidx=1:fnum,
  % Load Header (,Data,Version)
  %[h,d,v]=DataDef_SignalPreprocessor('load',actdata(fidx));
  h=DataDef_SignalPreprocessor('load',actdata(fidx));
  stim{fidx}=h.stim;
  stimmax0(fidx)=max(h.stim(:,1));
  stimmax=max(stimmax,stimmax0(fidx));
end
setappdata(hs.figure1,'StimMax0',stimmax0);
setappdata(hs.figure1,'StimMax',stimmax);

% Visble Flag
vf = false([length(actdata),stimmax]);
for fidx=1:length(actdata),
  % Load Header (,Data,Version)
  %[h,d,v]=DataDef_SignalPreprocessor('load',actdata(fidx));
  st=stim{fidx};
  for stimid=1:stimmax0(fidx)
    t=find(st==stimid);
    if ~isempty(t),vf(fidx,stimid)=true; end
  end
end
setappdata(hs.figure1,'VisibleFlag',vf);
% Selected Flag (Reseted)
sf = false([length(actdata),stimmax]);
setappdata(hs.figure1,'SelectedFlag',sf);
setappdata(hs.figure1, 'Zone',[1, 1]);
setappdata(hs.figure1,'CurrentFigures',actdata);  
osp_makeGroup('ZoneSelect',hs);

function e=ZoneSelect(hs,zonediff),
% e        : error is occur?
% zonediff : empty : initialize
%            [ 0  1] : --> Left (marker +)
%            [ 0 -1] : --> Left (marker -)
%            [ 1  0] : --> Up   (Figure +)
%            [-1  0] : --> Down (Figure -)

actdata=getappdata(hs.figure1,'CurrentFigures');
sz=size(hs.cbhs);
% Get Zone
if nargin<2,
  % File Page
  fpage=1;
  % Marker Page
  mpage=1;
else
  zone=getappdata(h.figure1, 'Zone');
  if isempty(zone), zone=[1 1]; end
  % File Page
  fpage=zone(1) + zonediff(1);
  % Marker Page
  mpage=zone(2) + zonediff(2);
end
vf=getappdata(hs.figure1,'VisibleFlag');
pos0 = [1 1]+sz.*[fpage-1,mpage-1];
pos1 = sz.*[fpage,mpage];

sz2=size(vf);

%====================
% Arrow Button On/Off
%====================
% Figures
if pos0(1)==1,
  set(hs.psb_up,'Visible','off');
else
  set(hs.psb_up,'Visible','on');
end
if pos1(1)>=sz2(1),
  pos1(1)=sz2(1);
  set(hs.psb_down,'Visible','off');
else
  set(hs.psb_down,'Visible','on');
end
% Markers
if pos0(2)==1,
  set(hs.psb_left,'Visible','off');
else
  set(hs.psb_left,'Visible','on');
end
if pos1(2)>=sz2(2),
  pos1(2)=sz2(2);
  set(hs.psb_up,'Visible','off');
else
  set(hs.psb_up,'Visible','on');
end


% Initialized Handle (Visibile : Off)
set(hs.txt_file(:),'Visible','off');
set(hs.cbhs(:),'Visible','off','Value',0);
set(hs.cbhs_all(:),'Visible','off','Value',0);
% Get Selected Flag
sf=getappdata(hs.figure1,'SelectedFlag');
% Check All Check box / on/off
vf2=sum(vf);
idx=find(vf2(pos0(2):pos1(2))>1);
set(hs.cbhs_all(idx),'Visible','on','Value',0);

fidx0=0;
% Figure On/Off : Value Set
for fidx=pos0(1):pos1(1),
  %====================
  % Filgure On/Off
  %====================
  fidx0=fidx0+1; % Handles File-index
  set(hs.txt_file(fidx0),...
      'String', actdata(fidx).data.filename, ...
      'Visible','on');


  %====================
  % Marker CheckBox
  %====================
  idx=find(vf(fidx,vf(pos0(2):pos1(2))));
  set(hs.cbhs(fidx0,idx),'Visible','on');
  
  idx=find(sf(fidx,pos0(2):pos1(2))~=0);
  set(hs.cbhs(idx),'Value',1);
end

e=false;
