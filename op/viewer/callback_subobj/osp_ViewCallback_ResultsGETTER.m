function varargout=osp_ViewCallback_ResultsGETTER(fcn,varargin)
% Control Callback Object, Select Data-Kind, in Signal-ViewerII.
%
% This function is Common-Callback-Object of OSP-Viewer II.
%


% == History ==
% $Id: osp_ViewCallback_ResultsGETTER.m 298 2012-11-15 08:58:23Z Katura $
%
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 05-Jun-2006


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
basicInfo.name   ='Results GETTER';
basicInfo.fnc    ='osp_ViewCallback_ResultsGETTER';
% File Information
basicInfo.rver   ='$Revision: 1.2 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2010/02/25 13:03:49 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_ResultsGETTER'};
basicInfo.uicontrol={'listbox','popupmenu',...
	'menu'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getDefaultCObject
data.name='Results GETTETR';
data.fnc ='osp_ViewCallback_ResultsGETTER';
%data.SelectedUITYPE='popupmenu';
data.SelectedUITYPE='listbox';
data.pos =[0, 0, 0.1, 0.1];
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectBlockChannel.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data=getDefaultCObject;
data.name='Results GETTETR';
data.fnc ='osp_ViewCallback_ResultsGETTER';

data.pos =[0, 0, 0.2, 0.1];
data.default.SelectedItemNumber = 1;

prompt={'Relative Position : ','Default Selected Item Number','UI Type (listbox/popupmenu/menu)'};
pos{1} = num2str(data.pos);
pos{2}='1';
pos{3}='listbox';
flag=true;
while flag,
	pos = inputdlg(prompt,'setting', 1,pos);
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

data.pos = str2num(pos{1});
data.default.SelectedItemNumber = str2num(pos{2});
data.SelectedUITYPE=pos{3};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_ResultsGETTER(''make'',handles, abspos,' ...
	'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(obj,'pos'),
	pos=getPosabs(obj.pos,apos); % Position Transfer
end
cl0=get(hs.figure1,'Color'); % Plot Color

%========================
% Load Kind Information
%========================
[hdata,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);
kindlen = size(data,3);
if kindlen<=1,
	warndlg({'============== OSP Warning ==============', ...
		'  Too few Data-Kind', ...
		'  to make Data-Kind Select Control GUI', ...
		'========================================='});
	return;
end

%=====================
% search Results
if ndims(data)==3
	Chlen=size(data,2);
else
	Chlen=size(data,3);
end

if ~isfield(hdata,'Results'), return;end

Rs=ospsub_CheckStruct(hdata.Results,Chlen);
curdata.ResultsString=Rs{1};
curdata.ResultsStringIDX=1;
if isfield(obj,'default')
	if isfield(obj.default,'SelectedItemNumber')
		if length(Rs)>=obj.default.SelectedItemNumber
			curdata.ResultsString=Rs{obj.default.SelectedItemNumber};
			curdata.ResultsStringIDX = obj.default.SelectedItemNumber;
		end
	end
end
%=====================

%=====================
% Waring : Overwrite
%=====================
if isfield(curdata,'Callback_ResultsGETTER'),
	warndlg({'========= OSP Warning =========', ...
		' Common Data-Kind Callback : Over-Write', ...
		'  Confine your Layout.', ...
		'==============================='});
end

%===================
% Make Control GUI
%===================
switch lower(obj.SelectedUITYPE),
	case 'listbox',
		% === List Box ===
		curdata.Callback_ResultsGETTER.handles= ...
			uicontrol(hs.figure1,...
			'Style','listbox', ...
			'BackgroundColor',cl0, ...
			'Units','normalized', ...
			'Position',pos, ...
			'Max',1, ...
			'String',Rs, ...
			'Value', curdata.ResultsStringIDX, ...
			'Tag','Callback_ResultsGETTER', ...
			'TooltipString','Data-Kind Listbox', ...
			'Callback', ...
			['osp_ViewCallback_ResultsGETTER(''ExeCallback'','...
			'gcbo,[],guidata(gcbo),''val'')']);
		
	case 'popupmenu',
		% === PopupMenu ===
		curdata.Callback_ResultsGETTER.handles= ...
			uicontrol(hs.figure1,...
			'Style','popupmenu', ...
			'BackgroundColor',cl0, ...
			'Units','normalized', ...
			'Position',pos, ...
			'Max',10, ...
			'String',Rs, ...
			'Value', curdata.ResultsStringIDX, ...
			'Tag','Callback_ResultsGETTER', ...
			'TooltipString','Data-Kind Popup Menu', ...
			'Callback', ...
			['osp_ViewCallback_ResultsGETTER(''ExeCallback'','...
			'gcbo,[],guidata(gcbo),''val'')']);
		
	case 'menu',
		% === Menu ===
		if isfield(curdata,'menu_callback'),
			ud1.h=...
				uimenu(curdata.menu_callback,'Label','Data &Kind', ...
				'TAG', 'Callback_ResultsGETTER');
			ud1.h2=[];
			curdata.Callback_ResultsGETTER.handles= ud1.h;
			for idx=1:length(Rs),
				% User Data=
				ud1.h2(idx)=uimenu(ud1.h,'Label',...
					['&' num2str(idx) Rs{idx}], ...
					'Callback', ...
					['osp_ViewCallback_ResultsGETTER(''ExeCallback'','...
					'gcbo,[],guidata(gcbo),''parent'')']);
			end
			set(ud1.h2(1),'Checked','on');
			set(ud1.h,'UserData',{ud1});
		end
		
	otherwise,
		errordlg({'====== OSP Error ====', ...
			['Undefined Mode :: ' obj.SelectedUITYPE], ...
			['  in ' mfilename], ...
			'======================='});
		delete(curdata.Callback_ResultsGETTERl.handles);
		curdata=rmfield(curdata,'Callback_ResultsGETTER');
end % End Make Control GUI

% Set Interped-handles to Mode-UserData{1}
ud={};
ud{1}=[0];
set(curdata.Callback_ResultsGETTER.handles, 'UserData', ud);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,eventdata,handles,type)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================
% Update Channel!
%================
% -- Default Setting ---
idx0 = 1;
ud=get(hObject,'UserData');

%  Switch :: Defined in Callback :: Style
switch type,
	case 'val',
		% Kind == Value
		Rs = get(hObject,'string');
		Rs = Rs{get(hObject,'value')};
		idx0=1;
		
	case 'parent',
		% Kind : Parent
		c=get(hObject,'Checked');
		if strcmpi(c,'on'), c='off';else, c='on';end
		set(hObject,'Checked',c);
		% ==> Convert hObject :: Parent
		hObject=get(hObject,'Parent');
		ud=get(hObject,'UserData');
		ud1=ud{1};idx0=2;
		c=get(ud1.h2,'Checked');
		kind= find(strcmpi(c,'on'));
		kind=kind(:)';
end

ResultsString=Rs;
for idx=2:length(ud),
	%try
	if isfield(ud{idx},'curdata')
		ud{idx}.curdata.ResultsString = Rs;
		delete(ud{idx}.h);
	end
	eval(ud{idx}.str);
	%catch
	%warning(lasterr);
	%end
end
set(hObject,'UserData',ud);
return;

% %===================
% % ReDraw : Callback!
% %===================
% ud=get(hObject,'UserData');
% tmp_data.update='osp_ViewCallback_ResultsGETTER';
% %[tmp_data.hdata, tmp_data.data ] = ...
% %    osp_LayoutViewerTool('getCurrentData',gcf,curdata);
%
% for idx=idx0:length(ud),
%   % Get Data
% %   data = p3_ViewCommCallback('getData', ...
% % 			      ud{idx}.axes, ...
% % 			      ud{idx}.name, ud{idx}.ObjectID);
%   % Channel Update
%   data.curdata.ResultsString = Rs;
%   %data.curdata.tmp_data = tmp_data;
%
%   % Delete handle
%   for idxh = 1:length(data.handle),
%       try,
%           if ishandle(data.handle(idxh)),
%               delete(data.handle(idxh));
%           end
%       catch
%           warning(lasterr);
%       end % Try - Catch
%   end
%   % Evaluate (Draw)
%   try
%       eval(ud{idx}.str);
%   catch
%       warning(lasterr);
%   end % Try - Catch
% end

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
