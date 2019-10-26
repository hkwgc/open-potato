function varargout = uiEditAxes(varargin)
% UIEDITAXES is GUI for Edit Axes-Children.
%   | Modify for OSP-Viewer II.
%   
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 08-Mar-2006 17:51:28
% Last Modified by GUIDE v2.5 08-Mar-2006 17:51:28
% Last Modified by GUIDE v2.5 08-Mar-2006 10:58:25
%   | Modify for OSP-Viewer II.

% History
% $Id: uiEditAxes.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiEditAxes_OpeningFcn, ...
                   'gui_OutputFcn',  @uiEditAxes_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Opening, Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiEditAxes_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before uiEditAxes is made visible.
% Opening Function : set argh_handle
% This function Set Axes-Handle to Edit,
%  and get Children.
handles.output = hObject;
handles.figure1 = hObject; % I Love figure1.
guidata(hObject, handles);
set(hObject,'Color',[1 1 1]);

% Get Optional Arguments
for ii=1:2:length(varargin)-1
	switch varargin{ii}
		case 'arg_handle',
			tmp = varargin{ii+1};
			if isfield(tmp,'ax'),
				axes_h = tmp.ax;
			else
				axes_h = tmp.axes;
			end
		otherwise,
			disp(' -- Unknown Property --');
			disp(varargin{:});
	end % End Switch
end
if ~exist('axes_h','var'),
	% gca is unforcau..
	try,
		axes_h = evalin('base','uiEditAxes_axes');
		if ~ishandle(axes_h), error('no deffunc'); end
	catch,
		axes_h = gca;
	end
end

% Setting AXES_HANDLE to EDIT
setappdata(hObject,'AXES_HANDLE',axes_h);

reload_children(handles);
return;

%===========================
% Create Functions
%===========================
function txt_revision_CreateFcn(hObject, eventdata, handles)
% Create Revision Text Acording to My cvsroot.
r='$Revision: 1.7 $'; % Change automaticaly by CVS
r=strrep(r,'$',''); set(hObject,'String',r);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Close , Delete , Change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = uiEditAxes_OutputFcn(hObject, eventdata, handles)
% Output Function
varargout{1} = handles.output;
if isempty(get(handles.pop_obj,'userData')),
	% no children at the opening : delete
	delete(handles.figure1);
end

function psb_close_Callback(hObject, eventdata, handles)
% Close button
delete(handles.figure1);
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% now do nothing in paticular..
delete(hObject);

function psb_propedit_Callback(hObject, eventdata, handles)
% propedit 
id  = get(handles.pop_obj,'Value');
h   = get(handles.pop_obj,'userData');
propedit(h(id));
delete(handles.figure1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Children List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_refresh_Callback(hObject, eventdata, handles)
% dumy function ::
reload_children(handles)

function reload_children(handles,flag)
% Reload Children
% Lower : pop_obj_Callback

% Search Children..
axes_h=getappdata(handles.figure1,'AXES_HANDLE');
cld_h = get(axes_h,'children');
if isempty(cld_h)
	errordlg('No Children in the Axes');
	set(handles.pop_obj,'userData',[],'String',{'No Children'});
	return;
end

% Make Tags ( if empty : Untitled)
tags  = get(cld_h, 'Tag');
if ~iscell(tags), tags={tags}; end
d = cellfun('isempty',tags);
d = find(d==1);
if ~isempty(d)
	[tags{d}] = deal('Untitled');
end

% Set to pop_obj
set(handles.pop_obj,'userData',cld_h,'String',tags,'Value',1);
% Reload pop_obj
if nargin<2,
	pop_obj_Callback(handles.pop_obj, [], handles);
else
	pop_obj_Callback(handles.pop_obj, [], handles,flag);
end
set(handles.psb_refresh,'Visible','off');
return;

function psb_delete_Callback(hObject, eventdata, handles)
% Children Object Delete Function
id  = get(handles.pop_obj,'Value');
h   = get(handles.pop_obj,'userData');
st = get(handles.pop_obj,'String');

% Delete Handle
if ishandle(h(id)),	delete(h(id));end
h(id)=[];
% Delete String
if isempty(h),psb_close_Callback(handles.figure1,[],handles);return;end
st(id)=[];
if id>length(st), id=length(st); end
set(handles.pop_obj,'Value',id,'UserData',h,'String',st);
pop_obj_Callback(handles.pop_obj, [], handles);

function pop_obj_Callback(hObject, eventdata, handles)
% Essensial Value
id = get(hObject,'Value');
oldid = getappdata(handles.figure1,'PopObj_oldid');
setappdata(handles.figure1,'PopObj_oldid',id);
h  = get(handles.pop_obj,'userData');
st = get(handles.pop_obj,'String');

if isempty(h),
	errordlg('No children exsist');
	return;
end
% Effective Handle Check
hck = ishandle(h);
if hck(id)==0,
	set(handles.psb_refresh,'Visible','on');
	errordlg('This Handle was Deleted');
	return;
end
h0 = h(id); % current Object;

% Delete Current Change Props
if isfield(handles,'chprops') && ...
		~isempty(handles.chprops)
	idx=find(ishandle(handles.chprops));
	delete(handles.chprops(idx));
end
try,
	hs=[];
	% Get Current Property..
	prop=get(h0);
	propstr=fieldnames(prop);
	%-- set visible --
	posidx=1; %<-- Title Position
	getposfcn = @getposfcn0;
	objnum=0;  % Object Number
	objlim=6; % max num;
	bgc   =  get(handles.frm_addprop,'BackgroundColor');

	list={'LineProp','MarkProp','FaceProp','FontProp'};
	% Adding Color
	for fcn=list,
		if objnum>=objlim, break; end
		pos=feval(getposfcn,handles,objnum+1);
		htmp=feval(fcn{1}, h0, handles.figure1, ...
			pos, bgc, prop, propstr,objnum);
		if ~isempty(htmp),
			objnum=objnum+1;
			hs=[hs, htmp];
		end
	end
	% Add Colorbox
	if objnum==0,
		objnum=objnum+1;
		pos=feval(getposfcn,handles,objnum);
		hs=uicontrol(handles.figure1, ...
			'Style','text', ...
			'HorizontalAlignment', 'left', ...
			'Units', 'Normalized', ...
			'String','No edit propert in the GUI..', ...
			'BackgroundColor', bgc, ...
			'Position',pos);
	end

catch
	errordlg({'OSP Error!!', ...
			['  at ' C__FILE__LINE__CHAR], ...
			'   Prop Setting Error Occur : ', ...
			['   ' lasterr]});
end
% Update handles.(chprops)
handles.chprops=hs;
guidata(hObject, handles);

set(hObject,'Value',id, 'String', st, 'userdata', h);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default : GUI Object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_eval_Callback(hObject, eventdata, handles)
% Evaluate
  ax = getappdata(handles.figure1,'AXES_HANDLE');
  % set(0,'CurrentFigure',handles.figure1);
  f=get(ax,'Parent');
  set(0,'CurrentFigure',f); set(f,'CurrentAxes',ax);
  id  = get(handles.pop_obj,'Value');
  h   = get(handles.pop_obj,'userData');
  h = h(id); % --> will be use in evaluate string.
  
  str = get(handles.edit_eval,'String');  
  try
	  if iscell(str),
		  for idx=1:length(str),
			  eval(str{idx});
		  end
	  else
		  eval(str)
	  end
  catch
    errordlg({'Error in Evaluating : ', ...
			['   ' str], ...
			'-------------------------------', ...
			['  ' lasterr]});  
  end
  set(0,'CurrentFigure',handles.figure1);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional GUI Object : (Position Setting)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos=getposfcn0(handles,posidx)
% Get Positoin Function
persistent opos possp possz
% --> Positoin - Size Definition
if isempty(opos) || isempty(possz),
	% Get Upper Position
	opos     =  get(handles.frm_addprop,'Position');
	possz  = [opos(3)/2 opos(4)/4]; % (indent)
	opos   = [opos(1), opos(2)+possz(2)*2];

	possp  = [possz*0.02, possz*0.04];
end
rowidx=posidx;
colidx=0;
while rowidx>3,
	rowidx=rowidx-3; colidx=colidx+1;
end
pos=[opos(1) + colidx*possz(1) + possp(1) , ...
		opos(2) - rowidx*possz(2) + possz(2), ...
		possz(1) - possp(3), ...
		possz(2) - possp(4)];
% Debug Print
if 0,
	a=get(handles.frm_addprop,'Position');
	figure;
	fill([a(1);a(1);a(1)+a(3);a(1)+a(3);a(1)], ...
		[a(2);a(2)+a(4);a(2)+a(4);a(2);a(2)], [.8 .9 1]);
	hold on
	cl=[1 .8 .8];
	for posidx=1:6,
		rowidx=posidx;
		colidx=0;
		while rowidx>3,
			rowidx=rowidx-3; colidx=colidx+1;
		end
		a=[opos(1) + colidx*possz(1) + possp(1) , ...
				opos(2) - rowidx*possz(2) + possz(2), ...
				possz(1) - possp(3), ...
				possz(2) - possp(4)];
		fill([a(1);a(1);a(1)+a(3);a(1)+a(3);a(1)], ...
			[a(2);a(2)+a(4);a(2)+a(4);a(2);a(2)],cl);
		cl = cl * 0.8;
	end
	axis([0 1 0 1]);
end
return;
function pos=getposfcn_mat(pos0, m,n , p)
%  position like subplot...
%  pos=getposfcn_mat(pos0, m,n , p);
sz=[pos0(3)/n, pos0(4)/m];
colidx=p-1;
rowidx=1;
while colidx>=n, 
	colidx=colidx-n; rowidx=rowidx+1;
end
pos=[   pos0(1) + (colidx+0.01)*sz(1), ...
		pos0(2) + (m-rowidx+0.01)*sz(2), ...
		sz(1) *0.98, ...
		sz(2) *0.98];
if 0,
	a=pos0;
	figure;
	fill([a(1);a(1);a(1)+a(3);a(1)+a(3);a(1)], ...
		[a(2);a(2)+a(4);a(2)+a(4);a(2);a(2)], [.8 .9 1]);
	cl=[1 .8 .8];
	hold on
	a=pos;
	fill([a(1);a(1);a(1)+a(3);a(1)+a(3);a(1)], ...
		[a(2);a(2)+a(4);a(2)+a(4);a(2);a(2)],cl);
	axis([0 1 0 1]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional GUI Object : Property List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Called from pop_obj
%	list={'LineProp','MarkProp','FaceProp'};
%	htmp=feval(fcn,h0,figh, bgc, prop, propstr,objnum);	

%=================
% Line Prop
%=================
function h=LineProp(h0, figh,pos0, bgc, prop, propstr,objnum)
% Line Property Setting Object
h=[];

% Checking Propety...
% st : Line Style 
% wt : Line Width
% cl : Line Color
st=find(strcmpi(propstr,'LineStyle'));
if isempty(st), return; end
wt=find(strcmpi(propstr,'LineWidth'));
if isempty(wt), return; end

cl=find(strcmpi(propstr,'EdgeColor'));
if isempty(cl),
	cl=find(strcmpi(propstr,'Color'));
end
% No Line Color Propperty
if isempty(cl),return; end

% -- Title --
try,
	pos=getposfcn_mat(pos0, 3, 1, 1);
	h=uicontrol(figh, ...
		'Style','text', ...
		'HorizontalAlignment', 'left', ...
		'Units', 'Normalized', ...
		'String','LineProperty', ...
		'Tag', 'LinePropText', ...
		'BackgroundColor', bgc, ...
		'Position',pos);
end

% cl : Line Color
try,
	pos=getposfcn_mat(pos0, 2, 4, 6);
	propname=propstr{cl(1)};
	cl=get(h0,propname);
	ud.h0=h0;ud.propname=propname;
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'Tag', 'LinePropColor', ...
		'BackgroundColor', cl, ...
		'UserData',ud, ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
			'cl = uisetcolor;', ...
			'if isequal(cl,0), return; end;', ...
			'set(ud.h0,ud.propname,cl);', ... 
			'set(gcbo,''BackgroundColor'',cl);'], ...
		'Position',pos);
	%'cl = uisetcolor(h0);', ...
end
% st : Line Style 
try,
	pos=getposfcn_mat(pos0, 3, 2, 4);
	ststr={'none','-','--', ':', '-.'};
	st=get(h0,'LineStyle');
	val=find(strcmp(ststr,st));
	if isempty(val), val=1; end
	h(end+1)=uicontrol(figh, ...
		'Style','popupmenu', ...
		'String',ststr, ...
		'value',val, ...
		'Units', 'Normalized', ...
		'Tag', 'LinePropStyle', ...
		'BackgroundColor', [1 1 1], ...
		'UserData',h0, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'str=get(gcbo,''String'');' ...
			'val=get(gcbo,''Value'');' ...
			'set(h0,''LineStyle'',str{val});'], ...
		'Position',pos);
end
	
% wt : Line Width
try,
	pos=getposfcn_mat(pos0, 3, 2, 6);
	wt=get(h0,'LineWidth');
	ud.h0 = h0;
	ud.wt = [0.1, 0.5, 1, 2, 3, 4]*wt;
	val   =  3;               
	str={};
	for idx=length(ud.wt):-1:1,
		str{idx}=num2str(ud.wt(idx));
	end
	
	if isempty(val), val=1; end
	h(end+1)=uicontrol(figh, ...
		'Style','popupmenu', ...
		'UserData',ud, ...
		'String',str, ...
		'value',val, ...
		'Units', 'Normalized', ...
		'Tag', 'LinePropWidth', ...
		'BackgroundColor', [1 1 1], ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
			'val=get(gcbo,''Value'');' ...
			'set(ud.h0,''LineWidth'',ud.wt(val));'], ...
		'Position',pos);
end

%=================
% Marker Prop
%=================
function h=MarkProp(h0,figh,pos0, bgc, prop, propstr,objnum)
h=[];
% Checking Propety...
% mk : Maker
% sz : MarkerSize
% fc : MarkerFaceColor
% ec : MarkerEdgeColor
mk=find(strcmpi(propstr,'Marker'));
if isempty(mk), return; end
sz=find(strcmpi(propstr,'MarkerSize'));
if isempty(sz), return; end
ec=find(strcmpi(propstr,'MarkerEdgeColor'));
if isempty(ec), return; end
fc=find(strcmpi(propstr,'MarkerFaceColor'));
if isempty(fc), return; end


% -- Title --
try,
	pos=getposfcn_mat(pos0, 3, 1, 1);
	h=uicontrol(figh, ...
		'Style','text', ...
		'HorizontalAlignment', 'left', ...
		'Units', 'Normalized', ...
		'String','MarkerProperty', ...
		'Tag', 'MarkerPropText', ...
		'BackgroundColor', bgc, ...
		'Position',pos);
end

% --- fc : MarkerFaceColor  -----
try,
	pos=getposfcn_mat(pos0, 3, 4, 6);
	cl=get(h0,'MarkerFaceColor');
	if ischar(cl), cl=[1 1 1]; end
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'Tag', 'MarkerPropFaceColor', ...
		'BackgroundColor', cl, ...
		'UserData',h0, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'cl = uisetcolor;', ...
			'if isequal(cl,0), return; end;', ...
			'set(h0,''MarkerFaceColor'',cl);', ...
			'set(gcbo,''BackgroundColor'',cl);'], ...
		'Position',pos);
end

% --- ec : MarkerEdgeColor  -----
try,
	pos=getposfcn_mat(pos0, 3, 4, 10);
	cl=get(h0,'MarkerEdgeColor');
	if ischar(cl), cl=[1 1 1]; end
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'Tag', 'MarkerPropEdgeColor', ...
		'BackgroundColor', cl, ...
		'UserData',h0, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'cl = uisetcolor;', ...
			'if isequal(cl,0), return; end;', ...
			'set(h0,''MarkerEdgeColor'',cl);', ...
			'set(gcbo,''BackgroundColor'',cl);'], ...
		'Position',pos);
end

% --- mk : Maker            -----
try,
	pos=getposfcn_mat(pos0, 3, 2, 4);
	str={'none','+','o','*','.','x', 'square', 'diamond',...
			'v','^', '<','>','pentagram', 'hexagram'};
	st=get(h0,'Marker');
	val=find(strcmp(str,st));
	if isempty(val), val=1; end
	h(end+1)=uicontrol(figh, ...
		'Style','popupmenu', ...
		'String',str, ...
		'value',val, ...
		'Units', 'Normalized', ...
		'Tag', 'MarkerProp', ...
		'BackgroundColor', [1 1 1], ...
		'UserData',h0, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'str=get(gcbo,''String'');' ...
			'val=get(gcbo,''Value'');' ...
			'set(h0,''Marker'',str{val});'], ...
		'Position',pos);
end

% --- sz : MarkerSize      -----
try,
	pos=getposfcn_mat(pos0, 3, 2, 6);
	ms=get(h0,'MarkerSize');
	ud.h0 = h0;
	ud.ms = [0.1, 0.5, 1, 2, 3, 4]*ms;
	val   =  3;               
	str={};
	for idx=length(ud.ms):-1:1,
		str{idx}=num2str(ud.ms(idx));
	end
	
	if isempty(val), val=1; end
	h(end+1)=uicontrol(figh, ...
		'Style','popupmenu', ...
		'UserData',ud, ...
		'String',str, ...
		'value',val, ...
		'Units', 'Normalized', ...
		'Tag', 'MarkerPropSize', ...
		'BackgroundColor', [1 1 1], ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
			'val=get(gcbo,''Value'');' ...
			'set(ud.h0,''MarkerSize'',ud.ms(val));'], ...
		'Position',pos);
end

function h=FaceProp(h0,figh, pos0, bgc, prop, propstr,objnum)
h=[];

% Checking Propety...
% fc : FaceColor
fc=find(strcmpi(propstr,'FaceColor'));
if isempty(fc), return; end

% -- Title --
try,
	pos=getposfcn_mat(pos0, 3, 1, 1);
	h=uicontrol(figh, ...
		'Style','text', ...
		'HorizontalAlignment', 'left', ...
		'Units', 'Normalized', ...
		'String','Face Color', ...
		'Tag', 'FaceColorText', ...
		'BackgroundColor', bgc, ...
		'Position',pos);
end

% --- fc : MarkerFaceColor  -----
try,
	pos=getposfcn_mat(pos0, 2, 4, 6);
	cl=get(h0,'FaceColor');
	if ischar(cl), cl=[1 1 1]; end
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'Tag', 'FaceColor', ...
		'BackgroundColor', cl, ...
		'UserData',h0, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'cl = uisetcolor;', ...
			'if isequal(cl,0), return; end;', ...
			'set(h0,''FaceColor'',cl);', ...
			'set(gcbo,''BackgroundColor'',cl);'], ...
		'Position',pos);
end

% --- Alpha  -----
try,
	pos=getposfcn_mat(pos0, 2, 2, 4);
	ud.h0 = h0;
	ud.ms = 0:0.25:1;
	val=5;
	str   ={'0%','25%','50%','75%','100%'};
	try,
		a=get(h0,'FaceAlpha');
		if all(ud.ms~=a),
			[ud.ms, idx]=sort([ud.ms, a]);
			str{end+1} = [num2str(round(a*100)) '%'];
			str=str(idx);
			val=find(idx==6);
		else,
			val=find(ud.ms==a);
		end
	end
		
	h(end+1)=uicontrol(figh, ...
		'Style','popupmenu', ...
		'UserData',ud, ...
		'String',str, ...
		'value',val, ...
		'HorizontalAlignment','right', ...
		'Units', 'Normalized', ...
		'Tag', 'MarkerPropSize', ...
		'BackgroundColor', [1 1 1], ...
		'TooltipString', 'Alpha setting', ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
			'val=get(gcbo,''Value'');' ...
			'alpha(ud.h0,ud.ms(val));'], ...
		'Position',pos);
end

function h=FontProp(h0,figh, pos0, bgc, prop, propstr,objnum)
h=[];

% Checking Propety...
% fc : FaceColor
fn=find(strcmpi(propstr,'FontName'));
if isempty(fn), return; end
fn=find(strcmpi(propstr,'FontUnits'));
if isempty(fn), return; end
fn=find(strcmpi(propstr,'FontSize'));
if isempty(fn), return; end
fn=find(strcmpi(propstr,'FontWeight'));
if isempty(fn), return; end
fn=find(strcmpi(propstr,'FontAngle'));
if isempty(fn), return; end

% -- Title --
try,
	pos=getposfcn_mat(pos0, 3, 1, 1);
	h=uicontrol(figh, ...
		'Style','text', ...
		'HorizontalAlignment', 'left', ...
		'Units', 'Normalized', ...
		'String','Font Set', ...
		'Tag', 'FontText', ...
		'BackgroundColor', bgc, ...
		'Position',pos);
end

% pushbutton : Set Font
try,
	pos=getposfcn_mat(pos0, 2, 4, 7);
	pos(3)=pos(3)*1.5;
	cl=bgc*0.9; cl(end)=1;
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'UserData',h0, ...
		'String','Set Font', ...
		'Tag', 'setfont', ...
		'BackgroundColor', cl, ...
		'Callback', ...
		['h0=get(gcbo,''UserData'');' ...
			'uisetfont(h0);'], ...
		'Position',pos);
end

% Color
cl=find(strcmpi(propstr,'ForegroundColor'));
if isempty(cl),
	cl=find(strcmpi(propstr,'Color'));
end
% No Line Color Propperty
if isempty(cl),
	if length(h)==1,delete(h); h=[]; return; end
end
% cl : Line Color
try,
	pos=getposfcn_mat(pos0, 2, 4, 6);
	propname=propstr{cl(1)};
	cl=get(h0,propname);
	ud.h0=h0;ud.propname=propname;
	h(end+1)=uicontrol(figh, ...
		'Units', 'Normalized', ...
		'Tag', 'FontColor', ...
		'BackgroundColor', cl, ...
		'UserData',ud, ...
		'Callback', ...
		['ud=get(gcbo,''UserData'');' ...
			'cl = uisetcolor;', ...
			'if isequal(cl,0), return; end;', ...
			'set(ud.h0,ud.propname,cl);', ... 
			'set(gcbo,''BackgroundColor'',cl);'], ...
		'Position',pos);
	%'cl = uisetcolor(h0);', ...
end


% Error!
if length(h)==1,delete(h); h=[]; end