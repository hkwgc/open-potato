function varargout=LAYOUT_CO_ChannelROI(fcn,varargin)
% Channel ROI Select Callback for Viewer
% 

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
  basicInfo.name   ='Channel ROI select';
  basicInfo.fnc    ='LAYOUT_CO_ChannelROI';
  % File Information
  basicInfo.rver   ='$Revision: 1.0 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2007/10/24 17:00:00 $';
  basicInfo.date([1,end])   =[];

  % Current - Variable Field-Name-List
  %basicInfo.cvfname={'vc_ChannelPopup'};
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
  data.name='Channel ROI select';
  data.fnc ='LAYOUT_CO_ChannelROI';
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
  str=['curdata=LAYOUT_CO_ChannelROI(''make'',handles, abspos,' ...
          'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
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
  
  curdata.Callback_ChannelROI.handles= ...
	  uicontrol(hs.figure1,...
		'Style','listbox','String',str, ...
		'BackgroundColor',[.9 .7 .7], ...
		'Units','normalized', ...
		'Position',pos, ...
		'Max',2,...
		'TooltipString','Channel ROI select: select some channels...', ...
		'Tag','Callback_ChannelROI', ...
		'Callback', ...
		['LAYOUT_CO_ChannelROI(''pop_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
	curdata.SelectedChannelROI=1;
	ud{1}.curdata=curdata;
	set(curdata.Callback_ChannelROI.handles,'UserData',ud); % set curdata in ud{1} 
	
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_Callback(hObject,eventdata,handles)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud=get(hObject,'UserData');
curdata=ud{1}.curdata;
curdata.SelectedChannelROI=get(hObject,'Value');
for idx=2:length(ud),
	% ** If there exist some objects that should be deleted on update ...	
% 	if isfield(ud{idx},'DeleteOnUpdate_ObjectHandles')
% 		delete(ud{idx}.DeleteOnUpdate_ObjectHandles);	
% 	end
	% ** change axes focus
	if isfield(ud{idx},'axes')
		set(curdata.gcf,'CurrentAxes',ud{idx}.axes);
	end
	% ** execute callback
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
