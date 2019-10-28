function varargout = P3_wizard_plugin_P_argset(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% $Id: P3_wizard_plugin_P_argset.m 180 2011-05-19 09:34:28Z Katura $

% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0
  % Sub function List
  createBasicInfo;
  OpenPage;
  ClosePage;
end

function data=createBasicInfo
data.islast=false;

function mydata=OpenPage(hs,mydata)
% Open Page

typelist={'Character', 'Integer', 'Float', 'Cell array'};
if ~isfield(mydata,'P_argset')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Input-Argument & their Property.',...
    'BackgroundColor',[1 1 1]);
  myhs.lbx_argdata=uicontrol(hs.figure1,...
    'Style','listbox',...
    'Units','Normalized','Position',[0.22, 0.23, 0.5,0.55],...
    'HorizontalAlignment','left',...
    'FontName',get(0,'FixedWidthFontName'),...
    'String','',...
    'UserData',[],...
    'BackgroundColor',[1 1 1],...
    'Callback','P3_wizard_plugin_P_argset(''lbx_argdata_Callback'',gcbf,gcbo)');
  
  myhs.pop_argtype=uicontrol(hs.figure1,...
    'Style','popupmenu',...
    'Units','Normalized','Position',[0.75 0.73 0.2 0.05],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1],...
    'Callback','P3_wizard_plugin_P_argset(''lbx_argdata_Callback'',gcbf);',...
    'String',typelist);
  
  myhs.txt_argnote=uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.75 0.65 0.2 0.05],...
    'HorizontalAlignment','left',...    
    'BackgroundColor',[1 1 1],...
    'String','Note :');
  myhs.edt_argnote=uicontrol(hs.figure1,...
    'Style','edit',...
    'Units','Normalized','Position',[0.75 0.57 0.2 0.08],...
    'HorizontalAlignment','left',...    
    'BackgroundColor',[1 1 1],...
    'Callback','P3_wizard_plugin_P_argset(''lbx_argdata_Callback'',gcbf);',...
    'String','');

  myhs.txt_argval=uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.75 0.49 0.2 0.05],...
    'HorizontalAlignment','left',...    
    'BackgroundColor',[1 1 1],...
    'String','Default Value:');
  myhs.edt_argval=uicontrol(hs.figure1,...
    'Style','edit',...
    'Units','Normalized','Position',[0.75 0.41 0.2 0.08],...
    'HorizontalAlignment','left',...    
    'BackgroundColor',[1 1 1],...
    'Callback','P3_wizard_plugin_P_argset(''lbx_argdata_Callback'',gcbf);',...
    'String','');
  
  
  mydata.P_argset=myhs;
else
  set([...
    mydata.P_argset.txt_title,...
    mydata.P_argset.lbx_argdata,...
    mydata.P_argset.pop_argtype,...
    mydata.P_argset.txt_argnote,...
    mydata.P_argset.edt_argnote,...
    mydata.P_argset.txt_argval,...
    mydata.P_argset.edt_argval],'Visible','on');
end

% -- Definition of "Default Argument Setting" --
ud0.name='noname';
ud0.type=typelist{1}; % Char
ud0.note='';
ud0.val ='';

udold=get(mydata.P_argset.lbx_argdata,'UserData');
if isempty(udold)
  namelist={};
else
  namelist={udold.name};
end


% Data Renew
if length(mydata.UiFunction.arglist)>0
  ud=ud0;
  for idx=1:length(mydata.UiFunction.arglist)
    idold=find(strcmp(mydata.UiFunction.arglist(idx),namelist));
    if isempty(idold)
      ud(idx)=ud0;
      ud(idx).name=mydata.UiFunction.arglist{idx};
      ud(idx).note=mydata.UiFunction.arglist{idx};
    else
      ud(idx)=udold(idold);
    end
  end
else
  ud=[];
end

%-- Setup Listbox --
str=lbx_argdata_ud2str(ud);
id=get(mydata.P_argset.lbx_argdata,'Value');
if id>length(str),id=1;end
set(mydata.P_argset.lbx_argdata,...
  'Value',id,...
  'String',str,'UserData',ud);
lbx_argdata_Callback; % init

%-- Setup Setting Region --
lbx_argdata_Callback(hs.figure1,mydata.P_argset.lbx_argdata,mydata);

function mydata=ClosePage(hs,mydata)
% 
set([...
  mydata.P_argset.txt_title,...
  mydata.P_argset.lbx_argdata,...
  mydata.P_argset.pop_argtype,...
  mydata.P_argset.txt_argnote,...
  mydata.P_argset.edt_argnote,...
  mydata.P_argset.txt_argval,...
  mydata.P_argset.edt_argval],'Visible','off');

if mydata.page_diff<0,return;end

mydata.ArgumentProp= get(mydata.P_argset.lbx_argdata,'UserData');

if 0, %emsg
  mydata.emsg=emsg;
  error(emsg);
end
if 0,disp(hs);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbx_argdata_Callback(fh,h,mydata)
%
persistent myid;
if nargin==0, myid=[];return;end
if nargin<=2
  mydata= getappdata(fh,'SettingInfo');
end
if nargin<=1,
  h=mydata.P_argset.lbx_argdata;
end

idx   = get(h,'Value');
ud    = get(h,'UserData');
str   = get(h,'String');
typelist=get(mydata.P_argset.pop_argtype,'String');

%-----------------
% Save Before Data
%-----------------
if ~isempty(myid) && myid<=length(ud)
  alist.name = ud(myid).name;
  
  alist.type=typelist{get(mydata.P_argset.pop_argtype,'Value')};
  alist.note=get(mydata.P_argset.edt_argnote,'String');
  
  val       =get(mydata.P_argset.edt_argval,'String');
  % TODO : Check consistent of Value & alist.type.
  alist.val = val;

  ud(myid)  =alist;
  str(myid) =lbx_argdata_ud2str(ud(myid));
end
set(h,'UserData',ud);
set(h,'String',str);

%-------------------
% Change Visible
%-------------------
subhs=[mydata.P_argset.pop_argtype,...
  mydata.P_argset.txt_argnote,...
  mydata.P_argset.edt_argnote,...
  mydata.P_argset.txt_argval,...
  mydata.P_argset.edt_argval];

if idx>length(ud)
  set(subhs,'Visible','off');
  myid=[];return;
end
set(subhs,'Visible','on');

%-------------------
% Apply Current Data
%-------------------
alist=ud(idx);
v=find(strcmp(alist.type,typelist));
set(mydata.P_argset.pop_argtype,'Value',v);
  
set(mydata.P_argset.edt_argnote,'String',alist.note);
set(mydata.P_argset.edt_argval,'String',alist.val);

myid=idx; % Update myid
return;

function str=lbx_argdata_ud2str(ud)
% Argument ListBox's User-Data to String.
str={};
for idx=length(ud):-1:1
  alist=ud(idx);
  str{idx}=sprintf(' %-4s[%-10s] : %s (%s)',...
    alist.name,alist.type,alist.note,alist.val);
end
if isempty(str)
  str={'No Data Available'};
end