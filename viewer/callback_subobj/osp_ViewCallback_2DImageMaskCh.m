function varargout=osp_ViewCallback_2DImageMaskCh(fcn,varargin)
% 2D-Image Mask Channel Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_2DImageMaskCh.m 180 2011-05-19 09:34:28Z Katura $


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
%         '2D-Image Mask Channel'
%       Myfunction Name
%         'vcallback_2DImageMaskCh'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='2DImage Mask Channel';
basicInfo.fnc    ='osp_ViewCallback_2DImageMaskCh';
% File Information
basicInfo.rver   ='$Revision: 1.4 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/02/05 09:54:06 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_2DImageMaskCh'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin) %#ok
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name
%     data.pos     :  layout position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=1 && isstruct(varargin{1})
  data=varargin{1};
end
data.name='2DImage Mask Channel';
data.fnc ='osp_ViewCallback_2DImageMaskCh';
if ~isfield(data,'pos')
  data.pos =[0, 0, 0.2, 0.1];
end
if ~isfield(data,'mask')
  data.mask =[];
end
pos{1} = num2str(data.pos);
pos{2} = num2str(data.mask);
flag=true;
while flag,
  pos = inputdlg({'Relative Position : ','Masked Channel :'}, ...
    'Callback Position', 1,pos);
  if isempty(pos), break; end
  
  try
    % Position Check
    pos0=str2num(pos{1}); %#ok 4-Elements
    if ~isequal(size(pos0),[1,4]),
      wh=warndlg('Number of Input Data must be 4-numerical!');
      waitfor(wh);continue;
    end
    if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0)) %#ok for MATLAB 6.5.1
      wh=warndlg('Input Position Value between 0.0 - 1.0.');
      waitfor(wh);continue;
    end
    % Mask Check
    mask = str2num(pos{2}); %#ok for mask
    mask0= round(mask);
    if ~isequal(mask,mask0),
      wh=warndlg('Masked Channel must be Integer.');
      waitfor(wh);continue;
    end
    if ~isempty(find(mask0<0)) %#ok for MATLAB 6.5.1
      wh=warndlg('Masked Channel must be greater than 0.');
      waitfor(wh);continue;
    end
  catch
    h=errordlg({'Setting Error Occur :',lasterr});
    waitfor(h); continue;
  end
  flag=false;
end
% Canncel
if flag,
  data=[]; return;
end

% OK
data.pos  = pos0;
data.mask = mask0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin) %#ok
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_2DImageMaskCh(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj) %#ok
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);

%=====================
% Not Set Special User Data
% <- User Data 1 is Special ->
%=====================
if isfield(obj,'mask')
  curdata.ImageProp.mask_channel=obj.mask;
else
  curdata.ImageProp.mask_channel=[];
end
str=num2str(curdata.ImageProp.mask_channel);
curdata.Callback_2DImageMaskCh.handles = ...
  uicontrol(hs.figure1,...
  'Style','edit','String', str, ...
  'BackgroundColor',[1 1 1], ...
  'Units','normalized', ...
  'Position',pos, ...
  'HorizontalAlignment', 'left', ...
  'TooltipString','Mask Channel Setting', ...
  'Tag','Callback_2DImageMaskCh', ...
  'Callback', ...
  ['osp_ViewCallback_2DImageMaskCh(''maskchannel_Callback'','...
  'gcbo,[],guidata(gcbo))']);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maskchannel_Callback(hObject,eventdata,handles) %#ok Callback
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  % -- Getting Userdata --
  ud       = get(hObject, 'UserData');

  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  maskch   = str2num(get(hObject, 'String')); %#ok use in ud.str

catch
  % Error Operation
  errordlg({' OSP Error!', ...
    ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
  return;
end
% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    fdname   : property name('mask_channel')
%
% Optional Variable
%    maskch     : mask channel

for idx=1:length(ud),
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end
end
set(hObject,'UserData',ud);
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
