function varargout = P3_wizard_plugin_P_Foption(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%
% $Id: P3_wizard_plugin_P_Foption.m 180 2011-05-19 09:34:28Z Katura $


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
  psb_adInfo_Callback;
  psb_rsltPI_Callback;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=createBasicInfo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.islast=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mydata=OpenPage(hs,mydata)
% Open Page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(mydata,'P_Foption')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Advanced Setting',...
    'BackgroundColor',[1 1 1]);
  
  myhs.psb_adInfo=uicontrol(hs.figure1,...
    'Style','pushbutton',...
    'Units','Normalized','Position',[0.22, 0.58, 0.7,0.1],...
    'String','Additional Information',...
    'UserData',[],...
    'Callback','P3_wizard_plugin_P_Foption(''psb_adInfo_Callback'',gcbf,gcbo)');
  % 'BackgroundColor',[1 1 1],...
  
  myhs.psb_rsltPI=uicontrol(hs.figure1,...
    'Style','pushbutton',...
    'Units','Normalized','Position',[0.22, 0.47, 0.7,0.1],...
    'String','Result-Plugin',...
    'UserData',[],...
    'Callback','P3_wizard_plugin_P_Foption(''psb_rsltPI_Callback'',gcbf,gcbo)');
  
  myhs.txt_titleds  = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.22, 0.4, 0.7,0.06],...
    'HorizontalAlignment','left',...
    'String','Descript : ',...
    'BackgroundColor',[1 1 1]);
  myhs.edt_Description=uicontrol(hs.figure1,...
    'Style','edit',...
    'Units','Normalized','Position',[0.24, 0.2, 0.68,0.2],...
    'HorizontalAlignment','left',...
    'Max',2,...
    'String','',...
    'BackgroundColor',[1 1 1]);
  mydata.P_Foption=myhs;
else
  set([mydata.P_Foption.txt_title,...
    mydata.P_Foption.psb_adInfo,...
    mydata.P_Foption.psb_rsltPI,...
    mydata.P_Foption.txt_titleds,...
    mydata.P_Foption.edt_Description],'Visible','on');
end

%-- Setup Listbox --
if isfield(mydata,'FilterOption') 
  if isfield(mydata.FilterOption,'DispKind') && ...
      isfield(mydata.FilterOption,'ResizeOption') 
    d.DispKind     = mydata.FilterOption.DispKind;
    d.ResizeOption = mydata.FilterOption.ResizeOption;
    set(mydata.P_Foption.psb_adInfo,'UserData',d);
  end
  if isfield(mydata.FilterOption,'ResultPlugin')
    set(mydata.P_Foption.psb_rsltPI,...
      'UserData',mydata.FilterOption.ResultPlugin);
  end
  if isfield(mydata.FilterOption,'Description')
    set(mydata.P_Foption.edt_Description,...
      'String',mydata.FilterOption.Description);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mydata=ClosePage(hs,mydata)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set([mydata.P_Foption.txt_title,...
  mydata.P_Foption.psb_adInfo,...
  mydata.P_Foption.psb_rsltPI,...
  mydata.P_Foption.txt_titleds,...
  mydata.P_Foption.edt_Description],'Visible','off');

%-----------------
% Filter Option 
%-----------------
d=get(mydata.P_Foption.psb_adInfo,'UserData');
if ~isempty(d)
  if isfield(d,'DispKind')
    mydata.FilterOption.DispKind=d.DispKind;
  end
  if isfield(d,'ResizeOption')
    mydata.FilterOption.ResizeOption=d.ResizeOption;
  end
end
%-----------------
% Result Plugin
%-----------------
d=get(mydata.P_Foption.psb_rsltPI,'UserData');
if ~isempty(d)
  mydata.FilterOption.ResultPlugin=d;
end
%-----------------
% Discript
%-----------------
d=get(mydata.P_Foption.edt_Description,'String');
if ~isempty(d)
  mydata.FilterOption.Description=d;
end
if 0,disp(hs);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function psb_rsltPI_Callback(fh,h)
%==========================================================================
if 0
  disp('--- Debugmode running --');
  disp(C__FILE__LINE__CHAR);
  load rsltPlugin.mat
  a=data; %#ok (for debug)
end
data=get(h,'UserData');
if ~isempty(data)
  data=P3_MakeResultControl('DefaultValue',data);
else
  data=P3_MakeResultControl;
end
if ishandle(fh)
  set(0,'CurrentFigure',fh);
  if ~isempty(data)
    set(h,'UserData',data);
  end
else
  disp(C__FILE__LINE__CHAR);
  disp(' Plugin Wizard was close, could not setup Result-Draw-Option.');
  disp(data);
end

%=======================================
function psb_adInfo_Callback(fh,h)
% Add Informaiotn
%=======================================

% Setting
%cl=[0.723 0.783 0.855];
cl=get(0,'DefaultFigureColor');

%----------------------------
% Make New Figure 
%----------------------------
% create Figure setting FilterDispKind
fh2=figure('MenuBar','none', ...
  'Visible','off',...
  'Color',cl,...
  'NumberTitle','off',...
  'Name','Filer-Plug-in : Additiona Option',...
  'Units','Characters');
p=get(fh2,'Position');
p(3:4)=[80,25];
set(fh2,'Position',p);
set(fh2,...
  'Units','Normalized',...
  'DeleteFcn','error(''Push OK / Cancel'');');

% Title
uicontrol('Style','Text', ...
  'BackgroundColor',cl,...
  'Units','Normalized', ...
  'Position',[0.05,0.9,0.9,0.09], ...
  'FontSize',12, ...
  'String','Additional Option :', ...
  'HorizontalAlignment','left');

%----------------------------
% Option : Display-Kind
%----------------------------
% Title
%~~~~~~~
uicontrol('Style','Text', ...
  'BackgroundColor',cl,...
  'Units','Normalized', ...
  'Position',[0.10,0.8,0.4,0.09], ...
  'FontSize',12, ...
  'String','Filter-Type', ...
  'HorizontalAlignment','left');

% List Box
%~~~~~~~~~~
DefineOspFilterDispKind;
kindlist=who;
ff=regexp(kindlist, '^F_\w*[a-zA-Z]$');
for i=length(ff):-1:1,
  if isempty(ff{i}),
    kindlist(i)=[];
  else
    x=eval([kindlist{i} ';']);
    % POTATo only : 1st-Level-Ana, Multi-Ana, Blocking
    %% over 11
    if x>=1024
      kindlist(i)=[];
    end
  end
end
if ~isempty(kindlist), val=1; end

lh = uicontrol('Style','listbox', ...
  'Units','Normalized', ...
  'BackgroundColor',[1 1 1], ...
  'Position',[0.10,0.21,0.35,0.59], ...
  'FontSize',12, ...
  'String', kindlist, ...
  'Max', 2, ...
  'Value', val);

% Initialization
%~~~~~~~~~~~~~~~~~~~~
d=get(h,'UserData');
if isstruct(d) && isfield(d,'DispKind')
  % disp kind
  [comlist,vl]=intersect(kindlist,d.DispKind);
  if 0,disp(comlist);end
  clear comlist;
  set(lh,'Value',vl)
  % Resize Option
end

%----------------------------
% Option : Resize
%----------------------------
% Title
uicontrol('Style','Text', ...
  'BackgroundColor',cl,...
  'Units','Normalized', ...
  'Position',[0.50,0.8,0.4,0.09], ...
  'FontSize',12, ...
  'String','ResizeOption', ...
  'HorizontalAlignment','left');
rs_ckbh=[];
rs_edth=[];
rsd={'Time','Channel','Kind','BlockNumber'};
lrs=length(rsd);

% Each-Check Box
hsz=0.4/lrs;
hps=0.8-hsz;
for idx=1:lrs
  rs_ckbh(end+1)=uicontrol('Style','Checkbox',...
    'Units','Normalized', ...
    'BackgroundColor',cl, ...
    'Position',[0.50,hps,0.25,hsz], ...
    'FontSize',12, ...
    'String', rsd{idx}, ...
    'Value', 0);
  rs_edth(end+1)=uicontrol('Style','edit',...
    'Units','Normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Position',[0.75,hps,0.2,hsz], ...
    'FontSize',12);
  % Initialization
  %~~~~~~~~~~~~~~~~
  if isstruct(d) && isfield(d,'ResizeOption') && ...
      isfield(d.ResizeOption,rsd{idx})
    set(rs_ckbh(end),'Value',1);
    set(rs_edth(end),'String',d.ResizeOption.(rsd{idx}));
  else
    set(rs_edth(end),'String', '*1');
  end
  % Point --> 
  hps=hps-hsz;
end

%-----------
% OK button
%-----------
uicontrol('Units','Normalized', ...
  'Position',[30,10,20,10]/ 100, ...
  'FontSize',12, ...
  'String', 'OK', ...
  'Callback', ...
  ['set(gcbf,''DeleteFcn'','''');'...
  'set(gcbf,''UserData'',true);']);
uicontrol('Units','Normalized', ...
  'Position',[60,10,20,10]/ 100, ...
  'FontSize',12, ...
  'String', 'Cancel', ...
  'Callback', ...
  ['set(gcbf,''DeleteFcn'','''');'...
  'set(gcbf,''UserData'',false);']);

% ---> Wait for responce <---
set(fh2,'Visible','on');
waitfor(fh2,'DeleteFcn','');

%=========================
% Get Result of Disp-Kind
%=========================
if ishandle(fh2),
  flg = get(fh2,'UserData');
  if flg,
    % true : OK
    %-------------------------
    % Disp-Kind
    %-------------------------
    d.DispKind     = kindlist(get(lh,'Value'));
    %---------
    % Resize
    %---------
    wmsg={'Format Error Occur in ...'};
    for idx=1:lrs
      if ~get(rs_ckbh(idx),'Value')
        if isfield(d,'ResizeOption') && isfield(d.ResizeOption,rsd{idx})
          d.ResizeOption=rmfield(d.ResizeOption,rsd{idx});
        end
        continue;
      end
      str=get(rs_edth(idx),'String');
      s=regexp(str,'^[\*\+\-\/]?[0-9]+$','once');
      if isempty(s)
        if isfield(d.ResizeOption,rsd{idx})
          d.ResizeOption=rmfield(d.ResizeOption,rsd{idx});
        end
        wmsg{end+1}=['  ' rsd{idx}];
        continue;
      end
      d.ResizeOption.(rsd{idx})=str;
    end
    if length(wmsg)>1
      warndlg({wmsg{:},'Format: [+-*/]?[0-9]+'},'Format Error in Resize');
    end
    set(h, 'UserData', d);
  else
    % false : Cancel
    % ==> not to change
  end
  % Delete
  delete(fh2);
end
set(0,'CurrentFigure',fh);
