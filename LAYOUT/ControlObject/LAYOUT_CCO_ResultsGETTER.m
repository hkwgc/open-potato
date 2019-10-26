function varargout=LAYOUT_CCO_ResultsGETTER(fcn,varargin)
% Control Callback Object(CO), to get Result in P3
%
% This function is Common-Callback-Object of POTATo
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin==0, fcn='help'; end

% == History ==
% $Id: LAYOUT_CCO_ResultsGETTER.m 364 2013-06-26 01:12:45Z Katura $
%
% autohr : T K., Hitachi Advanced Research Laboratory

%====================
% Swhich by Function
%====================
switch fcn
  case {'help','Help','HELP'},
    OspHelp(mfilename);
  case {'createBasicInfo','getDefaultCObject','drawstr','getArgument'},
    % Basic Information
    varargout{1} = feval(fcn, varargin{:});
  case 'make',
    varargout{1} = make(varargin{:});
  case 'ExeCallback'
    ExeCallback(varargin{:});
  otherwise
    % Default
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Results GETTER rev.2';
  basicInfo.fnc    ='LAYOUT_CCO_ResultsGETTER';
  % File Information
  basicInfo.rver   ='$Revision: 1.1 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2009/12/21 05:16:02 $';
  basicInfo.date([1,end])   =[];

  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_ResultsGETTER'};
  basicInfo.uicontrol={'listbox','popupmenu','menu'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getDefaultCObject
data.name='Results GETTETR rev.2';
data.fnc ='LAYOUT_CCO_ResultsGETTER';
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
% --> TODO : Change For MODIFICATION!!
if length(varargin{1})==1
	data=varargin{1};
else
	data.name='Results GETTETR rev.2';
	data.fnc ='LAYOUT_CCO_ResultsGETTER';
	data.pos =[0, 0, 0.2, 0.1];
	data.default.SelectedItemNumber = 1;
	data.SelectedUITYPE='listbox';
end

prompt={'Relative Position : ','Default Selected Item Number','UI Type (listbox/popupmenu/menu)'};
pos{1} =num2str(data.pos);
pos{2}=num2str(data.default.SelectedItemNumber);
pos{3}=data.SelectedUITYPE;
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
  str=['curdata=LAYOUT_CCO_ResultsGETTER(''make'',handles, abspos,' ...
          'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CCD.Name         = 'ResultsGETTER';
CCD.CurDataValue = {'ResultsGETTER'};
CCD.handle       = []; % Update

  if isfield(obj,'pos'),
      pos=getPosabs(obj.pos,apos); % Position Transfer
  end
  cl0=get(hs.figure1,'Color'); % Plot Color
  
  try
	  obj.default.SelectedItemNumber;
  catch
	  obj.default.SelectedItemNumber=1;
  end
  %========================
  % Load Kind Information 
  %========================
  [hdata,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);
  kindlen = size(data,3);
  if kindlen<=1,
      warndlg({'============== POTATo Warning ==============', ...
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
  Rs=POTATo_sub_CheckStruct(hdata.Results,Chlen);
  id=min([length(Rs) obj.default.SelectedItemNumber]);
  curdata.ResultsString=Rs{id};
  %=====================
  
  %=====================
  % Waring : Overwrite
  %=====================
  
  %===================
  % Make Control GUI
  %===================
  switch lower(obj.SelectedUITYPE), 
      case 'listbox',
          % === List Box ===
          CCD.handle= ...
              uicontrol(hs.figure1,...
              'Style','listbox', ...
              'BackgroundColor',cl0, ...
              'Units','normalized', ...
              'Position',pos, ...
              'Max',1, ...
              'String',Rs, ...
              'Value', obj.default.SelectedItemNumber, ...
              'Tag','Callback_ResultsGETTER', ...
              'TooltipString','Data-Kind Listbox', ...
              'Callback', ...
              ['LAYOUT_CCO_ResultsGETTER(''ExeCallback'','...
                  'gcbo,[],guidata(gcbo),''val'')']);
          
      case 'popupmenu',
          % === PopupMenu ===
          CCD.handle= ...
              uicontrol(hs.figure1,...
              'Style','popupmenu', ...
              'BackgroundColor',cl0, ...
              'Units','normalized', ...
              'Position',pos, ...
              'Max',10, ...
              'String',Rs, ...
              'Value', obj.default.SelectedItemNumber, ...
              'Tag','Callback_ResultsGETTER', ...
              'TooltipString','Data-Kind Popup Menu', ...
              'Callback', ...
              ['LAYOUT_CCO_ResultsGETTER(''ExeCallback'','...
                  'gcbo,[],guidata(gcbo),''val'')']);
          
      case 'menu',
          % === Menu ===
          if isfield(curdata,'menu_callback'),
              ud1.h=...
                  uimenu(curdata.menu_callback,'Label','Data &Kind', ...
                  'TAG', 'Callback_ResultsGETTER');          
              ud1.h2=[];
              CCD.handle= ud1.h;
              for idx=1:length(Rs),
                  % User Data= 
                  ud1.h2(idx)=uimenu(ud1.h,'Label',...
                      ['&' num2str(idx) Rs{idx}], ...
                      'Callback', ...
                      ['LAYOUT_CCO_ResultsGETTER(''ExeCallback'','...
                          'gcbo,[],guidata(gcbo),''parent'')']);
              end
              set(ud1.h2(obj.default.SelectedItemNumber),'Checked','on');
              set(ud1.h,'UserData',{ud1});
          end
              
      otherwise,
          errordlg({'====== POTATo Error ====', ...
                  ['Undefined Mode :: ' obj.SelectedUITYPE], ...
                  ['  in ' mfilename], ...
                  '======================='});
              return;
  end % End Make Control GUI
  
% Set Interped-handles to Mode-UserData{1}
ud={};
ud{1}=0; % ?? 'menu' will be BUG ??
set(CCD.handle, 'UserData', ud);

if isfield(curdata,'CommonCallbackData')
  curdata.CommonCallbackData{end+1}=CCD;
else
  curdata.CommonCallbackData={CCD};
end

%curdata.Callback_ResultsGETTER=CCD;
%curdata.Callback_ResultsGETTER.handles = curdata.Callback_ResultsGETTER.handle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,eventdata,handles,type)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================
% Update Channel!
%================
% -- Default Setting ---
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


% for idx=2:length(ud),
% 	if isfield(ud{idx},'name')
% 		% Get Data
% 		data = p3_ViewCommCallback('getData', ud{idx}.axes, ud{idx}.name, ud{idx}.ObjectID);
% 		data.curdata.ResultsString=Rs;
% 		try
% 			eval(ud{idx}.str);
% 		catch
% 			warning(lasterr);
% 		end
% 	else
% 		%try
% 		if isfield(ud{idx},'curdata')
% 			ud{idx}.curdata.ResultsString = Rs;
% 			delete(ud{idx}.h);
% 		end
%         eval(ud{idx}.str);
% 	end
% end
funcStr='vdata.curdata.ResultsString=varargin{1};';
ud=p3_ViewCommCallback('redrawAO',ud(2:end),funcStr,Rs);
%set(hObject,'UserData',ud);
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
