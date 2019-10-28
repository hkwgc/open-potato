function varargout=P3_AdvTgl_status(fnc,varargin)
% P3 : Status Toggle-Button Control Function
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: P3_AdvTgl_status.m 393 2014-02-03 02:19:23Z katura7pro $

if nargin<1,OspHelp(mfilename);end
  
%======== Launch Switch ========
switch fnc,
  case 'Create',
    % Syntax : hs=Create(hs)
    %   Create Status-Adv-Toggle
    varargout{1}=Create(varargin{:});
  case 'Suspend',
    % Syntax : Suspend(h,hs)
    % Suspend Status-Adv-Toggle
    Suspend(varargin{:});
  case 'Activate',
    % Syntax : Activate(h,hs)
    % Activate Status-Adv-Toggle
    Activate(varargin{:});
  case 'Logging',
    % Syntax : Logging(hs,Log)
    % Log is String of History.
    Logging(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hs=Create(hs)
% Make Advanced Tgl Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================
% Make TGL Button
%===============================
hs.advtgl_status = ...
  subput_advbutton(8,5,15+1,'Tight',...
  'Tag','advtgl_status',...
  'Style','ToggleButton',...
  'String','Status',...
  'Callback',...
  'P3_AdvTgl(''ChangeTgl'',gcbo,guidata(gcbo))');

hs.advtgl_status_History = ...
  subput_advbutton(2,1,2,'Inner',...
  'Tag','advtgl_status_History',...
  'Style','listbox',...
  'FontName',get(0,'FixedWidthFontName'),...
  'BackgroundColor',[1 1 1],...
  'String',{...
  '************************************************',...
  ' Platform for Optical Topography Anaysisi Tools',...
  '            Platform version 3                 ',...
  sprintf('                           Rev %s',OSP_DATA('GET','POTAToVersion')),...
  '***********************************************'});

%===============================
% Set Advance Toggle Handle
%===============================
atd0.TglHandle=hs.advtgl_status;
atd0.Function =eval(['@' mfilename ';']);

atd=getappdata(hs.figure1,'AdvancedToggleData');
if isempty(atd),  atd = atd0;
else              atd(end+1)=atd0;end
setappdata(hs.figure1,'AdvancedToggleData',atd);

Activate(hs.advtgl_status,hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=subhandle(hs)
% Set Subhandles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=hs.advtgl_status_History;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(h,hs)
% Suspend TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',0)
set(subhandle(hs),'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(h,hs)
% Activate TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',1);
set(subhandle(hs),'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Logging(hs,varargin)
% Logging 
if ~isfield(hs,'advtgl_status_History'),return;end
h=hs.advtgl_status_History;
str=get(h,'String');

%Same Log : canncel
if iscell(str),
  tmp=str{end};
else
  tmp=str;
end
if length(varargin)==1 && isequal(tmp,varargin{1})
  return;
end

for idx=1:length(varargin)
  if iscell(varargin{idx}),
    str0=varargin{idx};
    str=[str(:)' str0(:)'];
  else
    if ischar(varargin{idx}),
      str{end+1}=varargin{idx};
    end
  end
end
s=length(str)-100;
if s<1, s=0;end
v=length(str);
set(h,'String',str(s+1:v),'Value',v-s);
% B0817A : Status-Update-Timing
f=get(0,'CurrentFigure');
if isempty(f),
  f=hs.figure1;
end
figure(hs.figure1);
if 0
  set(0,'CurrentFigure',f);
else
  % slow...
  if (hs.figure1 ~=f)
    figure(f);
  end
end


