function A = POTATo_sub_MakeGUI(A,varargin)
%--------------
% sub routine for making GUI
%[USAGE]
% A = POTATo_sub_MakeGUI(figureHandle); %- Returns default setting structure.
% A = POTATo_sub_MakeGUI(A); % Make GUI controll according to A.
%
%[IN]
% A.hs:
% A.UIType:
% A.Name:
% A.Def_String:
% A.Labe_String:
% A.p:
% A.dp:
%
%[OUT]
% A.hs:
% A.newHS:
% A.p:
%
%------------- TK@CRL 2012-03-09
%---
%- GCA check added 13-Jan-2014

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin>1
	if isstruct(varargin{1})
		SetAllValues(A,varargin{1});
	elseif ischar(varargin{1})
		switch lower(varargin{1})
			case 'copyhandlesto'
				A=subCopyHandlesTo(A,varargin{2});
			case 'getallvalues'
				A=GetAllValues(A);
			case 'setallvalues'
				SetAllValues(A,varargin{2});
			otherwise
		end
	end
	return;
end

if ~isstruct(A)
	if ~ishandle(A)
		errordlg({'ERROR: ',mfilename,'','The 1st variable must be a figure handle.',''});
		return;
	end
	h=A;clear A;
	try
		n=dbstack('-completenames',1);
		if ~isempty(n)
			fn=n(1).file;
			[p fn]=fileparts(fn);
		else
			fn='unknown';
		end
	catch
		fn='unknown';		
	end
	A.OriginalMFileName = fn;
	A.handles.figure1 = h;
	A.invertY = true;
	A.UIType = 'edit';
	A.Name = 'tagName';
	A.String = 'default string';
	A.Value = 1;
	A.Label = 'Label';
	A.Unit = 'pixels';
	% 	if strcmpi('normalized',get(h,'units'))
	% 		warndlg('Normalized unit in figure is not supported yet.');
	% 		return;
	% 	else
	A.PosX = 10;
	A.PosY = 30;
	A.SizeX = 100;
	A.SizeY = 30;
	A.NextX = 10;
	A.NextY = 0;
	% 	end
	
	A.PRMs.visible = 'off';
	return;
end

%=== Check gca(gcf) unit
original_GCF_UNIT=get(gcf,'Units');
set(gcf,'Units',A.Unit);
%====== TK@CRL 13-Jan-2014

A=sub_invertY(A);

A.p = [A.PosX, A.PosY, A.SizeX, A.SizeY];
A.dp = [A.SizeX, A.SizeY];

%=== Check gca
if isfield(A.handles,'gca')
	original_GCA_UNIT=get(gca,'Units');
	set(gca,'Units',A.Unit);
	pgca=get(gca,'position');
	A.p(1)=A.p(1)+pgca(1);
	A.p(2)=A.p(2)+pgca(2);
	if strcmpi(A.Unit,'normalized')
		A.p(3)=A.p(3)*pgca(3);
		A.p(4)=A.p(4)*pgca(4);
	end	
end
%=====

A.newHS=[];

switch lower(A.UIType)
	case {'edit','editbox'}
		A = sub_MakeGUI_Editbox(A);
	case {'list','listbox'}
		A = sub_MakeGUI_Listbox(A);
	case {'popupmenu','pulldownlist'}
		A = sub_MakeGUI_Popupmenu(A);
	case {'check','checkbox'}
		A = sub_MakeGUI_Checkbox(A);
	case {'togglebutton','toggle'}
		A = sub_MakeGUI_Toggle(A);
	case {'button'}
		A = sub_MakeGUI_Button(A);
	case {'frame'}
		A = sub_MakeGUI_Frame(A);
	case {'text','textbox','label'}
		A = sub_MakeGUI_Text(A);
	case {'panel'}
		A = sub_MakeGUI_Panel(A);
	case {'slider'}
		A = sub_MakeGUI_Slider(A);		
	otherwise
		errordlg(['No function for "' UIType '" is defined.']);
end

A=sub_invertY(A);

%- prepare for next position
A.PosX = A.PosX+A.NextX;
A.PosY = A.PosY+A.NextY;

%- set PaRMeters for newHS
mb=fieldnames(A.PRMs);
for k=1:length(mb)
	set(A.newHS,mb{k},A.PRMs.(mb{k}));
end

%=== Restore GCA unit
set(gcf,'Units',original_GCF_UNIT);
if exist('original_GCA_UNIT','var')
	set(gca,'Units',original_GCA_UNIT);
end
%=====

%==========================================================================
function A = sub_MakeGUI_Editbox(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('edt_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'style','edit','BackgroundColor',[1 1 1],...
	'HorizontalAlignment','left',...
	'String',A.String,...
	'Units',A.Unit,...
	'Position',[A.p(1) A.p(2) A.p(3) A.p(4)-lblDY]);
A.newHS(end+1)=A.handles.(tag);

tag=mytag('label_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'String',A.Label,...
	'Units',A.Unit,...
	'Position',[A.p(1) A.p(2)+A.p(4)-lblDY A.p(3) lblDY]);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Listbox(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('lbx_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'style','listbox','BackgroundColor',[1 1 1],...
	'HorizontalAlignment','left','max',100,'ListboxTop',1,...
	'String',A.String,'Value', A.Value,...
	'Unit',A.Unit,...
	'Position',[A.p(1) A.p(2)-lblDY*0 A.p(3) A.p(4)-lblDY]);
set(A.handles.(tag),'Listboxtop',1);
A.newHS(end+1)=A.handles.(tag);

A=subMakeLabel(A);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Popupmenu(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('ppm_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'style','popupmenu','BackgroundColor',[1 1 1],...
	'HorizontalAlignment','left',...
	'Units',A.Unit,...
	'String',A.String,'Value', A.Value(1),...
	'Position',[A.p(1:3) A.p(4)-lblDY(A)]);
A.newHS(end+1)=A.handles.(tag);

A=subMakeLabel(A);
A.newHS(end+1)=A.handles.(tag);

%==========================================================================
function A = sub_MakeGUI_Checkbox(A)
%==========================================================================
newHS=[];
[tmp,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('cbx_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{3:end},'TAG',tag,...
	'style','checkbox','String',A.Label,'Value',A.Value,...
	'Units',A.Unit,...
	'Position',A.p);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Toggle(A)
%==========================================================================
newHS=[];
[tmp,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);
if isfield(A,'Callback')
	sC=A.Callback;
	sS=A.String;
else
	sC=A.String;
	sS=A.Label;
end
tag=mytag('tgl_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{3:end},'TAG',tag,...
	'style','togglebutton','String',sS,'Value',A.Value,...
	'Callback',sC,...
	'Units',A.Unit,...
	'Position',A.p);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Button(A)
%==========================================================================
[dummy,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);
tag=mytag('btn_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'style','pushbutton','String',A.Label,...
	'Units',A.Unit,...
	'Callback', A.String, 'Position',A.p);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Checkbox2(A)
%==========================================================================
[dummy,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('cbx_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{3:end},'TAG',tag,...
	'style','checkbox','String','','Value',A.Value,...
	'Units',A.Unit,...
	'Position',A.p);
newHS(end+1)=hs.(tag);

tag=mytag('txt_',A);
cbstr = sprintf('hs=guidata(gcf);v=get(hs.%s,''value'');set(hs.%s,''value'',(v==0))',tag,tag);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,'String',A.Label,...
	'Units',A.Unit,...
	'Position',[A.p(1)+20 A.p(2:3) A.p(4)/2],'ButtonDownFcn',cbstr);

A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Frame(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('frm_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'Style','Frame',...
	'String',A.Label,...
	'Units',A.Unit,...
	'Position',[A.p(1:3) lblDY]);
A.newHS(end+1)=A.handles.(tag);

A=subMakeLabel(A);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Text(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

tag=mytag('txt_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'String',A.String,...
	'Units',A.Unit,...
	'Position',A.p);
A.newHS(end+1)=A.handles.(tag);
%==========================================================================
function A = sub_MakeGUI_Slider(A)
%==========================================================================
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);

p=A.p;
p(3)=p(3)*0.9;
tag=mytag('sld_',A);
cbstr='h=getappdata(gcbo,''txtH'');set(h,''string'',num2str(get(gcbo,''value'')));';
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'style','slider','BackgroundColor',[1 1 1],...
	'String',A.String,...
	'Units',A.Unit,...
	'Position',p, 'Callback',cbstr);
A.newHS(end+1)=A.handles.(tag);

p(1)=p(1)+p(3);p(3)=p(3)/0.9*0.1;
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'String','0',...
	'Units',A.Unit,...
	'Position',p);
A.newHS(end+1)=A.handles.(tag);
setappdata(A.newHS(end-1),'txtH',A.newHS(end));




A=subMakeLabel(A);
A.newHS(end+1)=A.handles.(tag);




%********************************************************
%********************************************************
%********************************************************
function tag=mytag(tag,A)
% Tool : make unique tagname.

%- check over write
tag=[tag A.Name A.OriginalMFileName];

if isfield(A.handles,tag)
	warndlgIT({'[[ POTATo_sub_MakeGUI ]]','Handle-overwrite. An old object has deleted by this function.',sprintf('Name: %s',tag)});
	delete(A.handles.(tag));
end

%********************************************************
function [prop,prop_t,c]=sub_sub_Get_Base_Properties(figH)
c=get(figH,'Color');
prop={'Visible','off'};
prop_t={prop{:},'style','text','HorizontalAlignment','left','BackgroundColor',c};
%********************************************************
function A=sub_invertY(A)
if ~A.invertY, return;end

if strcmpi(A.Unit,'Normalized')
	y0=1;
else
	p0=get(A.handles.figure1,'position');
	y0=p0(4);
end

A.PosY=y0-A.PosY-A.SizeY;
A.NextY=A.NextY;
%********************************************************
function data=GetAllValues(A)
fn=fieldnames(A.handles);
LN=length(A.OriginalMFileName);
for k=1:length(fn)
	if length(fn{k})<LN, continue;end
	varname=fn{k}(5:end-LN);
	switch fn{k}(1:3)
		case 'edt'
			data.(varname) = get(A.handles.(fn{k}),'string');
		case {'lbx','cbx','ppm'}
			data.(varname) = get(A.handles.(fn{k}),'value');
		otherwise
	end
end
%********************************************************
function SetAllValues(A,data)
fn=fieldnames(data);
for k=1:length(fn)
	fldname=[fn{k} '_PTTSubMakeGUI'];
	switch fn{k}(1:3)
		case 'edt'
			set(A.handles.(fldname),'string',data.(fn{k}));
		case {'lbx','cbx','ppm'}
			set(A.handles.(fldname),'value',data.(fn{k}));
		otherwise
	end
end
%********************************************************
function H=subCopyHandlesTo(A,H)
fn=fieldnames(A.handles);
for k=1:length(fn)
	H.(fn{k})=A.handles.(fn{k});
end
%********************************************************
function A=subMakeLabel(A)
if isempty(A.Label), return;end
[prop,prop_t] = sub_sub_Get_Base_Properties(A.handles.figure1);
prop;
tag=mytag('label_',A);
A.handles.(tag)=uicontrol(A.handles.figure1,prop_t{:},'TAG',tag,...
	'String',A.Label,...
	'Position',[A.p(1) A.p(2)+A.p(4)-lblDY A.p(3) lblDY]);
A.newHS(end+1)=A.handles.(tag);

function ret=lblDY(varargin)
if nargin==0
	ret=11;
else
	A=varargin{1};
	if ~isstruct(A),ret=11;return;end
	switch lower(A.Unit)
		case 'pixels'
			ret = 11;
		case 'normalized'
			u=get(A.handles.figure1,'Units');set(A.handles.figure1,'Units','Pixels');
			fp=get(A.handles.figure1,'position');
			ret=11/fp(4);
			set(A.handles.figure1,'Units',u);
		otherwise
			ret=11;
	end
end

function warndlgIT(str)

set(0,'ShowHiddenHandles','on')
h=get(0,'Children');HND=0;
for k=1:length(h)
	if strcmp(get(h(k),'Tag'),'Msgbox_POTATo_sub_MAKEGUI__')
		c=cell2mat(get(get(h(k),'children'),'children'));
		tg=strcmp(get(c,'tag'),'MessageBox');
		s=get(c(tg),'string');
		str=cat(1,s,{''},str(end)');		
		delete(h(k));
	end
end

warndlg(str,'POTATo_sub_MAKEGUI__');
