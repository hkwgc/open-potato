function h=uihelp(fname,x,varargin)
% Help with GUI for POTATo.
%
% syntax:
% when you want to display help for function named fname.
%    h=uihelp(fname);
%      h     : handle of help figure.
%
% See also: help

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

persistent myh;  % my figure handle

%==========================================================================
% Callback
%==========================================================================
if nargin ==2
	% special :: callback
	switch x
		case 'psb_help_Callback',
			% Detail Help-Document Button
			psb_help_Callback;
			return;
			
		case 'close'
			% Close Request
			if ~isempty(myh) && ishandle(myh)
				close(myh);myh=[];
			end
			return;
			
		otherwise
			% EINVAL
			rethrow('Bad argument for uihelp')
	end
	return;
	
elseif nargin==3
	feval(varargin{1});
	return;
end


%==========================================================================
% Make GUI
%==========================================================================
if isempty(myh) || ~ishandle(myh)
	myh=create_uihelp();
end


%==========================================================================
% get handles
%==========================================================================
h=myh;
hs=guidata(h);
figure(h);

%==========================================================================
% Argument Check
%==========================================================================
if nargin == 0
	return;
end

%==========================================================================
% Argument Check
%==========================================================================
change_color(hs);
update_help(fname,hs)

% Debug
if 0
	% launch old-help-button
	disp('debug');
	disp(C__FILE__LINE__CHAR);
	if ~isfield(hs,'dbg_help')
		hs.dbg_help=uicontrol(myh,...
			'Units','pixels',...
			'style','pushbutton',...
			'String','Dbg help',...
			'Callback',['OspHelp(''' fname ''')'],...
			'Position',[220,470,90,20]);
		guidata(h,hs);
	else
		set(hs.dbg_help,'Callback',...
			['OspHelp(''' fname ''')']);
	end
end

%**************************************************************************
% Make GUI
%**************************************************************************
function h=create_uihelp()
% Create Figure

%---------------------------------------------
%  Position
%      p0   :  position
%      pmh  :  POTATo handle
%---------------------------------------------
wd = 320;
ht = 500;
p0 = [0 0 wd ht];
try
	% Get POTATo Position
	pmh =OSP_DATA('GET','POTATOMAINHANDLE');
	set(pmh,'Units','pixels');
	try
		pp=get(pmh,'OuterPosition');
	catch
		pp=get(pmh,'Position');
	end
	p0(1) = pp(1)+pp(3);
	p0(2) = pp(2);
	%p0(4) = pp(4); % height
	
	% Get ScreenSize
	set(0,'Units','pixels');
	ps = get(0,'ScreenSize');
	if (p0(1)+p0(3) > ps(3) )
		p0(1) = ps(3) - p0(3);
		if (p0(1) < 1)
			p0(1)=1;
		end
	end
catch
end

%---------------------------------------------
%  Figure
%---------------------------------------------
h=figure('MenuBar','none',...
	'Name','Help',...
	'NumberTitle','off',...
	'IntegerHandle','off',...
	'Units','pixels',...
	'Position',p0);
%  'Visible','off',...

hs.figure1 = h;
%---------------------------------------------
% GUI
%---------------------------------------------
% Recipe
sx1 = 10; % indent 0
sx2 = 10;

w0 = wd-sx1*2;
h0 = ht;

w2 = wd -sx1-sx2;

prop_t={'Units','pixels',...
	'HorizontalAlignment','left'};

sz = 21;
h0 = h0-sz -9;
tag='txt_fnc';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
	'style','text',...
	'String','Function: ',...
	'Position',[sx1 h0 w0 sz]);

% Description
sz = h0 - 49;
h0 = h0 - sz - 9;
tag='lbx_description';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
	'style','edit','BackgroundColor',[1 1 1],'min',0,'max',100,...
	'String',{'No Function Selected'},...
	'Position',[sx2 h0 w2 sz]);
% --> Add context menu
hs.contextmenu=uicontextmenu;
cm=hs.contextmenu;
hs.menu_font = ...
	uimenu(cm,'Label','Font',...
	'UserData',hs.lbx_description,...
	'Callback',...
	['h=get(gcbo,''UserData'');'...
	's=uisetfont(h,''change font'');'...
	'if isstruct(s), set(h,s);end;']);
hs.menu_copyall=...
	uimenu(cm,'Label','Copy all',...
	'UserData',hs.lbx_description,...
	'Callback',{'uihelp','Callback_CopyAll'});

set(hs.lbx_description,'UIContextMenu',cm);

% Help
sz = 21;
h0 = h0 - sz - 9;
tag='psb_help';
hs.(tag)=uicontrol(hs.figure1,prop_t{:},'TAG',tag,...
	'Units','pixels',...
	'style','pushbutton',...
	'String','Help',...
	'Enable','off',...
	'Callback','uihelp('''',''psb_help_Callback'')',...
	'Position',[sx1 h0 w0 sz]);


set(h,'unit','normalize');
set(h,'Visible','on');
guidata(h,hs);

hh=myh(hs);
set(hh,'unit','normalize');

%**************************************************************************
% Function
%**************************************************************************
function h=myh(hs)
% get all uicontrol handles
%========================================================================
h=[hs.txt_fnc, hs.lbx_description, hs.psb_help];

function change_color(hs)
% Change Color
%========================================================================
h=[hs.txt_fnc];
try
	% Get POTATo Color
	pmh =OSP_DATA('GET','POTATOMAINHANDLE');
	c   = get(pmh,'Color');
catch
	c =get(0,'defaultFigureColor');
end
set(h,'BackgroundColor',c);
set(hs.figure1,'Color',c);
function Callback_CopyAll(varargin)
a=getappdata(gcf);
s=get(a.UsedByGUIData_m.lbx_description,'string');
s=sprintf('%s\n',s{:});

clipboard('copy',s);

function update_help(fname,hs)
% Update Function-Help
%========================================================================

%=====================
% Setup Help-Button
%=====================
% get help text
fname0=fname;
txt='';
if exist(fname,'file')
	[pp,fname]=fileparts(fname); %#ok
	if ~isempty(fname)
		try
			txt=help(fname);
		catch
			txt=' MCR : no help-data exist..';
		end
	end
end
% update GUI
if isempty(txt)
	set(hs.lbx_description,'Value',1,'String',...
		['No help exist for ' fname0]);
else
	% char (with \n) to cell-string
	s2={}; sep=sprintf('\n');
	pos1 = 1;
	for idx=strfind(txt,sep),
		s2{end+1} = txt(pos1:idx);
		pos1=idx+1;
	end
	s2{end+1}=['[[File name]]  ' fname ];
	set(hs.lbx_description,'Value',1,'String',s2);
end

%=====================
% Setup Help-Button
%=====================
% check enable ?
if isempty(txt)
	x=false;
else
	x=POTATo_Help(fname,true);
end

% OK
if x
	h_enable='on';
	h_udata=fname;
else
	h_enable='off';
	h_udata='';
end
set(hs.psb_help,'Enable',h_enable,'UserData',h_udata);

%**************************************************************************
% Callback
%**************************************************************************
function  psb_help_Callback()
% launch help-view
%========================================================================
h=gcbo;
f=get(h,'UserData');
if ~isempty(f)
	POTATo_Help(f);
end
