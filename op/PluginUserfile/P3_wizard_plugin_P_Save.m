function varargout = P3_wizard_plugin_P_Save(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% $Id: P3_wizard_plugin_P_Save.m 180 2011-05-19 09:34:28Z Katura $


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

if 0
  % Sub function List
  createBasicInfo;
  OpenPage;
  ClosePage;
  psb_name_Callback;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=createBasicInfo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.islast=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mydata=OpenPage(hs,mydata)
% Open Page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------
% Making Default Path and BaseName
%---------------------------------
pathname = fileparts(which('POTATo'));
if isfield(mydata,'P_Save')
  ud=get(mydata.P_Save.edt_name,'UserData');
end
switch mydata.PluginType
  case 'Viewer Axis-Object'
    ud.path    = [pathname filesep 'LAYOUT' filesep 'AxisObject' filesep];
    ud.base    = 'LAYOUT_AO_';
    %ud.fname   = genvarname(mydata.PluginName);
    ud.fname   = genvarname(mydata.UiFunction.Function);
    ud.default = [ud.path ud.base ud.fname '.m'];
    ud.create  = 'P3_wizard_plugin_create(mydata,fname,''MA'');';
  case '1st-Level-Analysis Plug-in'
    ud.path    = [pathname filesep 'PluginDir' filesep];
    ud.base    = 'PlugInWrapP1_';
    %ud.fname   = genvarname(mydata.PluginName);
    ud.fname   = genvarname(mydata.UiFunction.Function);
    ud.default = [ud.path ud.base ud.fname '.m'];
    ud.create  = 'P3_wizard_plugin_create(mydata,fname,''M1'');';
  otherwise
    ud.path    = [pathname filesep 'PluginDir' filesep];
    ud.base    = 'PlugInWrap_';
    %ud.fname   = genvarname(mydata.PluginName);
    ud.fname   = genvarname(mydata.UiFunction.Function);
    ud.default = [ud.path ud.base ud.fname '.m'];
    ud.create  = 'P3_wizard_plugin_create(mydata,fname,''MF'');';
end
if ~isfield(ud,'current')
  ud.current = ud.default;
end

%--------------------------------
% Open : Save-Page
%---------------------------------
if ~isfield(mydata,'P_Save')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Save Result',...
    'BackgroundColor',[1 1 1]);

  myhs.edt_name=uicontrol(hs.figure1,...
    'Style','Edit',...
    'BackgroundColor',[1 1 1],...
    'Units','Normalized','Position',[0.22, 0.58, 0.6,0.1],...
    'HorizontalAlignment','left',...
    'String',ud.default,...
    'UserData',ud,...
    'Callback',[mfilename '(''edt_name_Callback'',gcbf,gcbo)']);
  myhs.psb_name=uicontrol(hs.figure1,...
    'Style','Pushbutton',...
    'Units','Normalized','Position',[0.83, 0.58, 0.09,0.1],...
    'HorizontalAlignment','left',...
    'String','...',...
    'Callback',[mfilename '(''psb_name_Callback'',gcbf,gcbo)']);

  myhs.ckb_open=uicontrol(hs.figure1,...
    'Style','CheckBox',...
    'BackgroundColor',[1 1 1],...
    'Value',0,...
    'Units','Normalized','Position',[0.3, 0.15, 0.62,0.1],...
    'HorizontalAlignment','left',...
    'String','Open Wrapper-File');
  mydata.P_Save=myhs;
else
  set([mydata.P_Save.txt_title,...
    mydata.P_Save.edt_name,...
    mydata.P_Save.psb_name,...
    mydata.P_Save.ckb_open],'Visible','on');
end

%--------------------------------
% Check : File Name is Consistent
%---------------------------------
set(mydata.P_Save.edt_name,'UserData',ud);
edt_name_Callback(hs.figure1,mydata.P_Save.edt_name,mydata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mydata=ClosePage(hs,mydata)
% Close Page // if Close-Window Makge M-File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set([mydata.P_Save.txt_title,...
  mydata.P_Save.edt_name,...
  mydata.P_Save.psb_name,...
  mydata.P_Save.ckb_open],'Visible','off');
if 0,disp(hs);end

if mydata.page_diff<0, return;end

%==============
% Make M-File
%==============
% get File-Name
ud=get(mydata.P_Save.edt_name,'UserData');
fname=ud.current;
try
  eval(ud.create);
catch
  if 0
    delete(fname);
  else
    edit(fname);
  end
  rethrow(lasterror);
end

% Open File
if get(mydata.P_Save.ckb_open,'Value')
  edit(fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  % Name Check & set Collor
  edt_name_Callback;
end
function str=edt_name_Callback(fh,h,mydata)
% Confine Data
if nargin<=2
  mydata= getappdata(fh,'SettingInfo');
end
if nargin<=1,
  h=mydata.P_Save.edt_name;
end
set(h,'ForegroundColor','black');
ud =get(h,'UserData');
str=get(h,'String');
[p,f,e] =fileparts(str);
idx=strmatch(ud.path,[p filesep]);
if isempty(idx), 
  str='';
  set(h,'ForegroundColor','red','String',ud.current,...
    'TooltipString','Bad-Path Error');
  return;
end
idx=strmatch(ud.base,f);
if isempty(idx), 
  str='';
  set(h,'ForegroundColor','red','String',ud.current,...
    'TooltipString','Bad-File-Name Error');
  return;
end
if isempty(e)
  e='.m';
  str=[p filesep f e];
else
  idx=strcmpi('.m',e);
  if isempty(idx),
    str='';
    set(h,'ForegroundColor','red','String',ud.current,...
      'TooltipString','Bad-Extension Error');
    return;
  end
end
ud.current=str;
set(h,'UserData',ud);

function psb_name_Callback(fh,h,mydata)
% Brose Position
if nargin<=2
  mydata= getappdata(fh,'SettingInfo');
end
if 0,disp(h);end

h0=mydata.P_Save.edt_name;
str=get(h0,'String');
ud =get(h0,'UserData');
[p,f,e]=fileparts(str);
[f,p]=P3_uiputpluginfile(ud,[f e],p);
if isequal(f,0),return;end
set(h0,'String',[p filesep f]);
edt_name_Callback(fh,h0,mydata);
