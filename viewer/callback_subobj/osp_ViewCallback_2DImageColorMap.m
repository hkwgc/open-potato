function varargout=osp_ViewCallback_2DImageColorMap(fcn,varargin)
% 2D-Image ColorMap Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_2DImageColorMap.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         '2D-Image ColorMap'
%       Myfunction Name
%         'vcallback_2DImageColorMap'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='ColorMap';
basicInfo.fnc    ='osp_ViewCallback_2DImageColorMap';
% File Information
basicInfo.rver   ='$Revision: 1.4 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2007/12/13 11:33:48 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_2DImageColorMap'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=1 && isstruct(varargin{1})
  data=varargin{1};
end
data.name='ColorMap';
data.fnc ='osp_ViewCallback_2DImageColorMap';
if ~isfield(data,'pos')
  data.pos =[0, 0, 0.2, 0.1];
end
if ~isfield(data,'cmapid')
  data.cmapid=1;
end
str={'default','hot','gray','red-blue','inv-gray'};

pos{1} = num2str(data.pos);
pos{2} = str{data.cmapid};

flag=true;
while flag,
  pos = inputdlg({'Relative Position : ',...
    'Colormap : (default,hot,gray,red-blue,inv-gray)'}, ...
    'Colormap Control Setting', 1,pos);
  if isempty(pos), break; end
  try
    % Position Check
    pos0=str2num(pos{1});
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);continue;
    end
    % Colormap String Check
    cmapid=find(strcmpi(str,pos{2}));
    if length(cmapid)~=1
      wh=warndlg('Invalid Color-Map Name');
      waitfor(wh);continue;
    end
  catch
    h=errordlg({'Input Proper Number:',lasterr});
    waitfor(h); continue;
  end
  flag=false;
end
% Canncel
if flag,
  data=[]; return;
end

% OK
data.pos    = pos0;
data.cmapid = cmapid;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_2DImageColorMap(''make'',' ...
  'handles, abspos, curdata, cbobj{idx});'];
%   str=['curdata=osp_ViewCallback_2DImageColorMap(''make'',handles, abspos,' ...
%        'chdata,cdata, bhdata,bdata,curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj)
% function curdata=make(hs, apos, chdata,cdata, ...
% 		      bhdata,bdata,curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);
if isfield(obj,'cmapid')
  val=obj.cmapid;
else
  val=1;                     % default
end

%=====================
% Not Set Special User Data
% <- User Data 1 is Special ->
%=====================
osp_set_colormap(val);
str={'default','hot','gray','red-blue','inv-gray'};
curdata.Callback_Change_ColorMap.handles= ...
  uicontrol(hs.figure1,...
  'Style','popupmenu','String',str, ...
  'Value', val, ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos, ...
  'TooltipString','Color Map Setting', ...
  'Tag','Callback_2DImageColorMap', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageColorMap(''imagecolormap_Callback'','...
  'gcbo,[], guidata(gcbo))']);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imagecolormap_Callback(hObject,eventdata,handles)
% Execute on ViewGroupCallback 'exe' Function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  %--  Default Color --
  set(hObject,'ForegroundColor','black');
  osp_set_colormap(get(hObject,'Value'));
catch
  % Error Operation
  errordlg({' OSP Error!', ...
    ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
  return;
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position
% and Parent Position.
%
% lpos : Relative-Position
% pos  : Parent Position
% apos : Absorute Position
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
return;
