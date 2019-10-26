function varargout=osp_ViewCallback_KindSelector(fcn,varargin)
% Kind Select Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%
% This function will be removed soon. 
% Please use osp_ViewCallbackC_DataKind.

% $Id: osp_ViewCallback_KindSelector.m 180 2011-05-19 09:34:28Z Katura $


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
%         'Kind Selector'
%       Myfunction Name
%         'vcallback_KindSelector'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Kind Selector';
  basicInfo.fnc    ='osp_ViewCallback_KindSelector';
  % File Information
  basicInfo.rver   ='$Revision: 1.8 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/10/27 08:30:24 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_KindSelector'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='Kind Selector';
  data.fnc ='osp_ViewCallback_KindSelector';
  data.pos =[0, 0, 0.4, 0.1];
  prompt={'Position : '};
  pos{1} = num2str(data.pos);
  flag=true;
  while flag,
    pos = inputdlg({'Relative Position : '}, ...
		   'Callback Position', 1,pos);
    if isempty(pos), break; end
    try,
      pos0=str2num(pos{1});
      if ~isequal(size(pos0),[1,4]),
	wh=warndlg('Number of Input Data must be 4-numerical!');
	waitfor(wh);continue;
      end
      if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
	wh=warndlg('Input Position Value between 0.0 - 1.0.');
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
  data.pos =pos0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_KindSelector(''make'',handles, abspos,' ...
        'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
warndlg({'================ OSP Warning ====================',  ...
        ' You are using Old-Viewer II Function.', ...
        ' In Popum-Menu of Channel', ...
        ' osp_ViewCallback_KindSelector will be removed soon. ',...
        ' Please use osp_ViewCallbackC_DataKind.', ...
        '=================================================='});
  pos=getPosabs(obj.pos,apos);
  
  curdata.Callback_KindSelector.handles= ...
      uicontrol(hs.figure1,...
		'Style','edit','String','1 2', ...
        'BackgroundColor',[.9 .7 .7], ...
		'Units','normalized', ...
		'Position',pos, ...
		'TooltipString','Old-Version Kind Selector', ...
		'Tag','Callback_KindSelector', ...
		'Callback', ...
		['osp_ViewCallback_KindSelector(''kind_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
  %=====================
  % Set Special User Data
  % <- User Data 1 is Special ->
  %=====================
  if 1,
      cdata=getappdata(hs.figure1,'CDATA');
      if iscell(cdata),
          kindlen=size(cdata{1},3);
      else,
          kindlen=size(cdata,3);
      end
      ud1st.ckindlen = kindlen;        % Continuous
      bdata=getappdata(hs.figure1,'BDATA');
      ud1st.bkindlen = size(bdata,4); % Block-Data
      set(curdata.Callback_KindSelector.handles, ...
          'UserData',{ud1st});
  else
      ud1st.ckindlen = Inf; % --> no check
      ud1st.bkindlen = Inf; % --> no check
      set(curdata.Callback_KindSelector.handles, ...
          'UserData',{ud1st});
  end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kind_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try,
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  % User Data
  ud     = get(hObject,'UserData');
  % Kind
  kindstr= get(hObject,'String'); 
  kind   = str2num(kindstr); kind   = round(kind);

  % Kind-Length
  ud1st  = ud{1}; % Special User Data
  ckindlen = ud1st.ckindlen; % Kind-Length of Continuous Data 
  bkindlen = ud1st.bkindlen; % Kind-Length of Block Data 

  % Error Check
  if ~isempty(find(kind(:)<0)),
    error('Data Kind Must be Positive Integer');
  end
  if ~isempty(find(kind(:)>max(ckindlen,bkindlen))),
    error('Selected Data-Kind is too large');
  end
  
catch,
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
%    kind     : Selected Data-Kind by this Object
%    ckindlen : Kind-Length of Continuous Data 
%    bkindlen : Kind-Length of Block Data 
%
% Optional Variable
%    kindstr  : String of this Object
%    u1st     : (Special User Kind)

for idx=2:length(ud),
    try
        eval(ud{idx}.str);
    catch
        warning(lasterr);
    end
end
set(hObject,'UserData',ud);


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
