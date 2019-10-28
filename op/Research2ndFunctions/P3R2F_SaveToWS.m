function varargout=P3R2F_SaveToWS(fcn,varargin)
% POTATo : Research Mode 2nd-Level-Analysis Function "Average"

% == History ==
%  2011.01.26 : New! (for testing....)

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'createBasicInfo','CreateGUI',...
      'Activate','Suspend',...
      'MakeArgData','SetArgData',...
      'UpdateRequest',...
      'execute',...
      'Callback',...
      'rdb_twosample_Callback',...
      'rdb_paired_Callback',...
      'rdb_unpaired_Callback',...
      'InfoButton',...
      'exebutton_Callback','CallBack_Averaging_CheckBox'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  case 'enableInfoButton'
    varargout{1}=false;
  case {'myhandles'}
    % for debug
    disp('Debug Path');
    disp(C__FILE__LINE__CHAR);
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  otherwise
    error('Not Implemented Function : %s',fcn);
end

%##########################################################################
function basic_info=createBasicInfo()
% Get Basic-Info of this function
%##########################################################################
basic_info.name = 'Save to Workspace';   % Display-Name 
basic_info.ver  = 1.0;          % Version (double)
basic_info.fcn  = mfilename;    % Function-Name

%##########################################################################
% GUI Control
%##########################################################################
function tag=mytag(tag)
% Tool : make unique tagname.
tag=[tag mfilename];
function cbstr=myCallback(tag)
cbstr=[mfilename '(''' tag(1:end-length(mfilename)-1) '_Callback'',guidata(gcbo));'];

%==========================================================================
function hs=CreateGUI(hs)
% Create Related GUI
%==========================================================================

%----------------------
% Set GUI Common Property.
%----------------------
c=get(hs.figure1,'Color');
prop={'Units','pixels','Visible','off'};
prop_t={prop{:},'style','text',...
  'HorizontalAlignment','left',...
  'BackgroundColor',c};

%----------------------
% Get GUI Position...
%----------------------
pf=get(hs.frm_R2nd_Function,'Position'); % GUI Range..
pp=get(hs.pop_R2nd_Function,'Position'); % GUI 

A=POTATo_sub_MakeGUI(hs.figure1);
A.PosX=100+pp(1);A.PosY=0+pp(2);
A.SizeX=120;A.SizeY=30;
A.invertY=1;
A.UIType='Button';
A.Name = 'SavetoWS';
A.String=[mfilename '(''Callback'',guidata(gcbo));'];
A.Label='Save to Workspace';
A = POTATo_sub_MakeGUI(A);

hs=POTATo_sub_MakeGUI(A,'CopyHandlesTo',hs);


%==========================================================================
function h=Suspend(hs)
% My GUI Visible Off
%==========================================================================
h=myhandles(hs);
set(h,'Visible','off');
%==========================================================================
function h=Activate(hs)
% My GUI Visible On
%==========================================================================
h=myhandles(hs);
set(h,'Visible','on');

%==========================================================================
function [h, myhs]=myhandles(hs)
% My Handle List
fn=fieldnames(hs);
h=[];
for k=1:length(fn)
	if ~isempty(findstr(fn{k},mfilename))
		h(end+1)=hs.(fn{k});
		myhs.(fn{k}) = hs.(fn{k});
	end
end

%==========================================================================
function cellSS=UpdateRequest(hs,tag,varargin)

apidata=getappdata(hs.figure1,mfilename);
switch lower(tag)
  case 'init'
    % for init
    cellSS=varargin{1};
    for ii=1:length(apidata)
      try
        feval(apidata{ii}.fcn,'UpdateRequest',apidata{ii},cellSS);
      catch
      end
    end
  case 'output'
    % for Output 
    cellSS=varargin{1};
    for ii=1:length(apidata)
      try
        cellSS=feval(apidata{ii}.fcn,'UpdateRequest',apidata{ii},cellSS);
      catch
      end
    end
  otherwise
    error('Unknown tag');
end

%==========================================================================
function Callback(hs)

cellSS=P3_gui_Research_2nd('loadCellSS',hs);
if isempty(cellSS)
	warndlg('No SS data added yet.');
end
assignin('base','cellSS',cellSS);

function [prop,prop_t,c]=sub_sub_Get_Base_Properties(figH)
c=get(figH,'Color');
prop={'Units','pixels','Visible','off'};
prop_t={prop{:},'style','text','HorizontalAlignment','left','BackgroundColor',c};
