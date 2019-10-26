function varargout=P3_AdvTgl_2ndLvlAna(fnc,varargin)
% P3 : 2nd-Lvl-Ana Toggle-Button Control Function


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if isempty(fnc),OspHelp(mfilename);end
  
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
function hs=Create(hs)
% Make Advanced Tgl Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================
% Make TGL Button
%===============================
hs.advtgl_2ndLvlAna = ...
  subput_advbutton(8,5,15+3,'Tight',...
  'Tag','advtgl_2ndLvlAna',...
  'Style','ToggleButton',...
  'String','2ndLvlAna',...
  'Visible','off',...
  'Callback',...
  'P3_AdvTgl(''ChangeTgl'',gcbo,guidata(gcbo))');
  
%===============================
% Set Advance Toggle Data
%===============================
atd0.TglHandle=hs.advtgl_2ndLvlAna;
atd0.Function =eval(['@' mfilename ';']);

atd=getappdata(hs.figure1,'AdvancedToggleData');
if isempty(atd),  atd = atd0;
else              atd(end+1)=atd0; end
setappdata(hs.figure1,'AdvancedToggleData',atd);

%===============================
% Set Advance Mode Handle
%===============================
av=OSP_DATA('GET','AdvanceButtonHandles');
av=[av(:);hs.advtgl_2ndLvlAna;subhandle(hs)];
OSP_DATA('SET','AdvanceButtonHandles',av);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=subhandle(hs)
% Set Subhandles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Suspend(h,hs)
% Suspend TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',0)
set(subhandle(hs),'Visible','off');
OspFilterCallbacks('pop_FilterDispKind_Switch_1stLvl',...
  hs.pop_FilterDispKind,[],hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(h,hs)
% Activate TGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(h,'Value',1);
set(subhandle(hs),'Visible','on');
OspFilterCallbacks('pop_FilterDispKind_Switch_1stLvl',...
  hs.pop_FilterDispKind,[],hs);
