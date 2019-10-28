function varargout=Lparts_Figure(fnc,varargin)
% Figure Layout-Parts Object


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2007.02.19
% $Id: Lparts_Figure.m 298 2012-11-15 08:58:23Z Katura $

%======== Launch Switch ========
switch fnc,
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create & GUI-Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==================================================
function hs=Create(hs)
% Create  Figure-Layout-Parts  Property Setting GUI
%===================================================

%-------------------------------
% Name
%-------------------------------
hs.lpofig_txtname=subuicontrol(hs.figure1,...
  15,2,2+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Name');
% Callback is common.
hs.lpofig_edtname=subuicontrol(hs.figure1,...
  15,2,2+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','No-Name',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  'Lparts_Manager(''ChangeName'',guidata(gcbf));');

%-------------------------------
% Figure - Position
%-------------------------------
hs.lpofig_txtpos=subuicontrol(hs.figure1,...
  15,2,4+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Position');
% Use Original Callback
hs.lpofig_edtpos=subuicontrol(hs.figure1,...
  15,2,4+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[0, 0, 1, 1]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  [mfilename '(''ChangePosition'',gcbo,guidata(gcbf));']);

%-------------------------------
% Color
%-------------------------------
hs.lpofig_txtcol=subuicontrol(hs.figure1,...
  15,2,6+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Color');
% Use Original Callback
hs.lpofig_edtcol=subuicontrol(hs.figure1,...
  15,2,6+2,'Inner',...
  'Style','Edit',...
  'HorizontalAlignment','left',...
  'String','[1.00, 1.00, 1.00]',...
  'BackgroundColor',[1, 1, 1],...
  'Callback',...
  [mfilename '(''ChangeColor'',gcbo,guidata(gcbf));']);

%-------------------------------
% Function
%-------------------------------
hs.lpoobj_txtfn=subuicontrol(hs.figure1,...
  15,8,28*4+1,'Inner',...
  'Style','Text',...
  'HorizontalAlignment','left',...
  'String','Path');
% Use Original Callback
hs.lpoobj_txtfnstr=subuicontrol(hs.figure1,...
  15,8,28*4+2,'Inner',...
  'Style','edit',...
  'HorizontalAlignment','left',...
  'String','');
p=get(hs.lpoobj_txtfnstr,'position');
set(hs.lpoobj_txtfnstr,'position',[p(1:2) p(3)*7 p(4)]);

% Suspend This Property
Suspend(hs);

function h=subhandle(hs)
% Sub-Handles
h=[...
  hs.lpofig_txtname;...
  hs.lpofig_edtname;...
  hs.lpofig_txtpos;...
  hs.lpofig_edtpos;...
  hs.lpofig_txtcol;...
  hs.lpofig_edtcol;...
	hs.lpoobj_txtfn;...
	hs.lpoobj_txtfnstr];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visible On/Off Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(hs)
% Suspend : Visible off
set(subhandle(hs),'Visible','off');

function Activate(hs)
% Activate
set(subhandle(hs),'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return Position-handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rh,ah]=getPoshandle(hs)
rh=[];ah=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPO   Getter & Setter   ( Setter of Data (5) )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function setParts(hs,LP)
% Set Layout-Parts to GUI (5)
%=============================
if isfield(LP,'FigureProperty'),
  
  % Name Property
  if isfield(LP.FigureProperty, 'Name'),
    set(hs.lpofig_edtname,'String',LP.FigureProperty.Name);
  else
    % Default
    disp('TODO : might be Program Error. Untiteld Layout Exist.')
    disp(C__FILE__LINE__CHAR);
    set(hs.lpofig_edtname,'String','Untitled Layout');
  end
  
  % Figure-Position Property
  if isfield(LP.FigureProperty, 'Position'),
    set(hs.lpofig_edtpos,'String',  num2str(LP.FigureProperty.Position,'%4.2f  '));
    set(hs.lpofig_edtpos,'UserData',LP.FigureProperty.Position);
  else
    set(hs.lpofig_edtpos,'String','[0, 0, 1, 1]');
    set(hs.lpofig_edtpos,'UserData',[0, 0, 1, 1]);
  end
  
  % Figure - Color Proeprety
  if isfield(LP.FigureProperty, 'Color'),
    set(hs.lpofig_edtcol,'String',  num2str(LP.FigureProperty.Color,'%4.2f  '));
    set(hs.lpofig_edtcol,'UserData',LP.FigureProperty.Color);
  else
    set(hs.lpofig_edtcol,'String','[1, 1, 1]');
    set(hs.lpofig_edtcol,'UserData',[1, 1, 1]);
	end
	
	%- Set file path name
	set(hs.lpoobj_txtfnstr,'string',getappdata(hs.figure1, 'CurrentLayoutFname'));
	%getappdata(hs.figure1, 'CurrentLayoutFname')
	
else
  set(hs.lpofig_edtname,'String','Untitled');
  set(hs.lpofig_edtpos,'String','[0, 0, 1, 1]');
  set(hs.lpofig_edtpos,'UserData',[0, 0, 1, 1]);  
  set(hs.lpofig_edtcol,'String','[1, 1, 1]');
  set(hs.lpofig_edtcol,'UserData',[1, 1, 1]);
end 
setappdata(hs.figure1,'CurrentLPOdata',LP);

%=============================
function LP=getParts(hs)
% Getter of Layout-Parts to GUI (5)
%=============================
LP=getappdata(hs.figure1,'CurrentLPOdata');
LP.FigureProperty.Name    =get(hs.lpofig_edtname,'String');
LP.FigureProperty.Position=get(hs.lpofig_edtpos,'UserData');
LP.FigureProperty.Color   =get(hs.lpofig_edtcol,'UserData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback of Local Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function ChangePosition(h,hs)
% Change Position!!
%=============================
posstr=get(h,'String');
try
  pos   = str2num(posstr);
  % TODO :Check Numerical x 4
  if length(pos)~=4, error('Input 4 Numerical Value'); end
  set(h,'UserData',pos,'ForegroundColor',[0 0 0]);
  % Set Flag(4)
  setappdata(hs.figure1,'CurrentLPOischange',true);
catch
  beep;
  set(h,'ForegroundColor',[1 0 0],'TooltipString',lasterr);
end


%=============================
function ChangeColor(h,hs)
% Check Numerical x 3
%=============================
colstr=get(h,'String');
try
  col   = str2num(colstr);
  % TODO :Check Numerical x 3
  if length(col)~=3, error('Input 3 Numerical Value'); end
  set(h,'UserData',col,'ForegroundColor',[0 0 0]);
  % Set Flag(4)
  setappdata(hs.figure1,'CurrentLPOischange',true);
catch
  beep;
  set(h,'ForegroundColor',[1 0 0],'TooltipString',lasterr);
end
