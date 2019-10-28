function varargout=osp_ViewCallback_StimAreaMenu(fcn,varargin)
% Y-Axis Range Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_StimAreaMenu.m 298 2012-11-15 08:58:23Z Katura $


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
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%       Display-Name of the Plagin-Function.
%         'Y Axis Range'
%       Myfunction Name
%         'vcallback_YAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Stim Area Menu';
  basicInfo.fnc    =mfilename;
  % File Information
  basicInfo.rver   ='$Revision: 1.1 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/11/24 11:13:37 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_StimArea'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='Stim Area Menu';
  data.fnc =mfilename;
  data.pos =[0, 0, 0.2, 0.1];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  str=['curdata=osp_ViewCallback_StimAreaMenu(''make'',handles, abspos,' ...
       'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
pos=getPosabs(obj.pos,apos);
figure(hs.figure1);
%=====================
% Common-Callback-Data
CCD.Name         = 'StimKindMenu';
CCD.CurDataValue = {'stimkindmenu'};
CCD.handle       = []; % Update
%=====================

curdata.Callback_StimAreaMenu.handle=...
  uimenu(curdata.menu_callback,'Label','&StimArea', ...
  'Checked','on',...
  'TAG', 'Callback_menuStimArea',...
  'UserData',{},...
  'Callback',...
  ['osp_ViewCallback_StimAreaMenu(''StimAreaMenu_Callback'','...
    'gcbo)']);
CCD.handle = curdata.Callback_StimAreaMenu.handle;
%-- add me as CCO
if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end
%--
return;

function StimAreaMenu_Callback(h)
%
check=get(h,'Checked');
if strcmpi(check,'on'),
	set(h,'Checked','off');
else
	set(h,'Checked','on');
end

%== Redraw AO members in this.
ud=get(h,'UserData');
for idx=1:length(ud), % B110106B
  % Get Data
  data = p3_ViewCommCallback('getData', ud{idx}.axes, ud{idx}.name, ud{idx}.ObjectID);
  
  % Delete handle
  for idxh = 1:length(data.handle),
    try
      if ishandle(data.handle(idxh)),
        delete(data.handle(idxh));
      end
    catch
      warning(lasterr);
    end % Try - Catch
  end
  
  % Evaluate (Draw)
  try
    eval(ud{idx}.str);
  catch
    warning(lasterr);
  end % Try - Catch
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == tmp ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lpos=getPosabs(lpos,pos),
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
