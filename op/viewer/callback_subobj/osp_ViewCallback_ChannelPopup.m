function varargout=osp_ViewCallback_ChannelPopup(fcn,varargin)
% Channel Select Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%
% This function will be removed soon. 
% Please use osp_ViewCallbackC_Channel.
% 
% See also : LAYOUTMANAGER OSP_VIEWCALLBACKC_CHANNEL

% $Id: osp_ViewCallback_ChannelPopup.m 180 2011-05-19 09:34:28Z Katura $


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
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Channel Popup';
  basicInfo.fnc    ='osp_ViewCallback_ChannelPopup';
  % File Information
  basicInfo.rver   ='$Revision: 1.7 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/10/27 08:30:24 $';
  basicInfo.date([1,end])   =[];

  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_ChannelPopup'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectBlockChannel.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='Channel Popup';
  data.fnc ='osp_ViewCallback_ChannelPopup';
  data.pos =[0, 0, 0.1, 0.1];
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
  str=['curdata=osp_ViewCallback_ChannelPopup(''make'',handles, abspos,' ...
          'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
warndlg({'================ OSP Warning ====================',  ...
        ' You are using Old-Viewer II Function.', ...
        ' In Popum-Menu of Channel', ...
        ' osp_ViewCallback_Channel will be removed soon. ',...
        ' Please use osp_ViewCallbackC_Channel.', ...
        '=================================================='});
  pos=getPosabs(obj.pos,apos);
  cdata=getappdata(hs.figure1,'CDATA');
  %=====================
  if iscell(cdata),
    chlen=size(cdata{1},2);
  else,
    chlen=size(cdata,2);
  end
  for idx=chlen:-1:1,
    str{idx}=['Ch ' num2str(idx)];
  end
  %cl=get(hs.figure1,'Color');
  
  curdata.Callback_ChannelPopup.handles= ...
      uicontrol(hs.figure1,...
		'Style','popupmenu','String',str, ...
		'BackgroundColor',[.9 .7 .7], ...
		'Units','normalized', ...
		'Position',pos, ...
                'TooltipString','Old Popup-Menu of Channel', ...
                'Tag','Callback_ChannelPopup', ...
		'Callback', ...
		['osp_ViewCallback_ChannelPopup(''pop_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_Callback(hObject,eventdata,handles)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(hObject,'UserData');
ch=get(hObject,'Value');
for idx=1:length(ud),
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
