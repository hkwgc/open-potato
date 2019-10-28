function varargout = P3_wizard_plugin_P1(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% $Id: P3_wizard_plugin_P1.m 180 2011-05-19 09:34:28Z Katura $



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
end

function data=createBasicInfo
data.islast=false;

function mydata=OpenPage(hs,mydata)
% Open Page
if ~isfield(mydata,'P1_hs')
  %-------
  % Create 
  %-------
  myhs.txt_PluginName=uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.3, 0.9, 0.3,0.1],...
    'HorizontalAlignment','left',...
    'String','Input Your Plug-in Name:',...
    'BackgroundColor',[1 1 1]);
  myhs.edt_PluginName=uicontrol(hs.figure1,...
    'Style','edit',...
    'Units','Normalized','Position',[0.6, 0.9, 0.3,0.1],...
    'HorizontalAlignment','left',...
    'String','Test Filter',...
    'BackgroundColor',[1 1 1]);
  % Radio Button
  str={'Import Plug-in','Import Suppport Plug-in',...
    'Filter Plug-in',...
    '1st-Level-Analysis Plug-in',...
    '2nd-Level-Analysis Plug-in',...
    'Viewer Axis-Object'};

  h=0.2;
  hd=0.6/length(str);
  for idx=length(str):-1:1
    myhs.rdb(idx)=uicontrol(hs.figure1,...
      'Style','radiobutton',...
      'Units','Normalized','Position',[0.2, h, 0.8,hd],...
      'HorizontalAlignment','left',...
      'String',str{idx},...
      'BackgroundColor',[1 1 1]);
    h=h+hd;
  end
  set(myhs.rdb(3),'Value',1);
  setappdata(hs.figure1,'PluginType',str{3});
  set(myhs.rdb,'UserData',myhs.rdb,...
    'Callback',...
    ['h=get(gcbo,''UserData'');'...
    'set(h,''Value'',0);'...
    'set(gcbo,''Value'',1);'...
    'setappdata(gcbf,''PluginType'',get(gcbo,''String''));']);
  myhs.rdb_str=str;
  mydata.P1_hs=myhs;
else
  set(mydata.P1_hs.txt_PluginName,'String','Input Your Plug-in Name:');
  set(mydata.P1_hs.edt_PluginName,'Style','edit');
  set(mydata.P1_hs.rdb,'Visible','on');
  if isfield(mydata.P1_hs,'txt_PluginType')
    set(mydata.P1_hs.txt_PluginType,'Visible','off');
  end
end
set(hs.psb_help,'Visible','on');

% unpopulated list
if 1
  % TODO:
  set(mydata.P1_hs.rdb([1 2 5]),'Visible','off');
  % 4: 1st-Level-Analysis
  %set(mydata.P1_hs.rdb([1 2 4 5]),'Visible','off');
end

function mydata=ClosePage(hs,mydata)
% 
try
  set(mydata.P1_hs.txt_PluginName,'String','Plug-in Name:');
  set(mydata.P1_hs.edt_PluginName,'Style','text');
  mydata.PluginName=get(mydata.P1_hs.edt_PluginName,'String');
  
  set(mydata.P1_hs.rdb,'Visible','off');
  mydata.PluginType=getappdata(hs.figure1,'PluginType');
  
  if isfield(mydata.P1_hs,'txt_PluginType')
    set(mydata.P1_hs.txt_PluginType,'Visible','on','String',mydata.PluginType);
  else
    mydata.P1_hs.txt_PluginType=uicontrol(hs.figure1,...
      'Style','text',...
      'Units','Normalized','Position',[0.18, 0.83, 0.8,0.05],...
      'HorizontalAlignment','left',...
      'String',mydata.PluginType,...
      'BackgroundColor',[1 1 1]);
  end
catch
  mydata.emsg=lasterr;
  rethrow(lasterror);
end

