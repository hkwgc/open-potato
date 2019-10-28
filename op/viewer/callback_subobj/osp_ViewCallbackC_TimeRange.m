function varargout=osp_ViewCallbackC_TimeRange(fcn,varargin)
% Common-Callback-Object, Change TimeRange, in Signal-ViewerII.
%
% This function is Common-Callback-Object of OSP-Viewer II.
% 


% == History ==
% $Id: osp_ViewCallbackC_TimeRange.m 298 2012-11-15 08:58:23Z Katura $
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
  else
    feval(fcn, varargin{:});
  end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Time-Range';
  basicInfo.fnc    ='osp_ViewCallbackC_TimeRange';
  % File Information
  basicInfo.rver   ='$Revision: 1.2 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2007/08/01 01:39:26 $';
  basicInfo.date([1,end])   =[];

  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_TimeRange'};
  basicInfo.uicontrol={'listbox','popupmenu',...
          'menu','edit'};
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
  data=varargin{1};
  data.name='Data Kind';
  data.fnc ='osp_ViewCallbackC_TimeRange';
  
  %=======================
  % Set up of Input Dialog
  %=======================
  prompt={}; def={};
  
  % Position
  if ~strcmpi(data.SelectedUITYPE,'menu'),
      prompt{end+1}='Relative Position : ';
      if isfield(data,'pos'),
          def{end+1} = num2str(data.pos);
      else
          def{end+1} ='[0,  0,  0.1,  0.1]';
      end
  end

  
  %=======================
  % Input Dialog Loop
  %=======================
  if isempty(prompt), flag=false;
  else, flag=true; end
      
  while flag,
      %-------------------
      % Open Input Dialog 
      %-------------------      
      def = inputdlg(prompt, 'Setting : Data-Kind Callback', 1,def);
      if isempty(def), data=[]; return; end % Cancel
      
      %-------------------
      % Data Loading..
      %-------------------
      flag=false;
      for idx=1:length(prompt),
          switch prompt{idx},
              case 'Relative Position : ',
                  % -- Position --
                  try,
                      pos0=str2num(def{idx});
                      if ~isequal(size(pos0),[1,4]),
                          flag=true; % == ;continue;
                          wh=warndlg('Number of Input Data must be 4-numerical!');
                          waitfor(wh)
                      end
                      if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
                          flag=true; % == continue;
                          wh=warndlg('Input Position Value between 0.0 - 1.0.');
                          waitfor(wh);
                      end
                      data.pos=pos0;
                  catch
                      flag=true; % == ;continue;
                      h=errordlg({'Input Proper Number:',lasterr});
                      waitfor(h);
                  end
              otherwise,
                  % --- Error : Undefined Prompt ---
                  errordlg({'==================== OSP : Program Error ======================', ...
                          [' in ' mfilename ], ...
                          '      in getArgument :: Undefined :: Prompt of Inputdlg ' , ...
                          ['      Named : ' prompt{idx} ], ...
                          '================================================================'});
                  data=[]; return;
          end % End Switch 
      end % End Prompt Loop
  end % Input Dialog Loop

  % OK
  % Normal End
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  str=['curdata=osp_ViewCallbackC_TimeRange(''make'',handles, abspos,' ...
       'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj,newflag),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isfield(obj,'pos'),
      pos=getPosabs(obj.pos,apos); % Position Transfer
  end
  cl0=get(hs.figure1,'Color'); % Plot Color
  
  %========================
  % Load TimeRange
  %========================
  size=osp_LayoutViewerTool('getCurrentSize',curdata);

  %=====================
  % Waring : Overwrite
  %=====================
  if isfield(curdata,'CCallback_TimeRange'),
    warndlg({'========= OSP Warning =========', ...
	     ' Common Time-Range Callback : Over-Write', ...
	     '  Confine your Layout.', ...
	     '==============================='});
  end

  %===================
  % Make Control GUI
  %===================
  switch lower(obj.SelectedUITYPE), 
      case 'listbox',
          % === List Box ===
          curdata.CCallback_DataKind.handles= ...
              uicontrol(hs.figure1,...
              'Style','listbox', ...
              'BackgroundColor',cl0, ...
              'Units','normalized', ...
              'Position',pos, ...
              'Max',10, ...
              'String',kindtag, ...
              'Value', kindval, ...
              'Tag','CCallback_DataKind', ...
              'TooltipString','Data-Kind Listbox', ...
              'Callback', ...
              ['osp_ViewCallbackC_TimeRange(''ExeCallback'','...
                  'gcbo,[],guidata(gcbo),''val'')']);
          
      case 'popupmenu',
          % === PopupMenu ===
          curdata.CCallback_DataKind.handles= ...
              uicontrol(hs.figure1,...
              'Style','popupmenu', ...
              'BackgroundColor',cl0, ...
              'Units','normalized', ...
              'Position',pos, ...
              'Max',10, ...
              'String',kindtag, ...
              'Value', kindval(1), ...
              'Tag','CCallback_DataKind', ...
              'TooltipString','Data-Kind Popup Menu', ...
              'Callback', ...
              ['osp_ViewCallbackC_TimeRange(''ExeCallback'','...
                  'gcbo,[],guidata(gcbo),''val'')']);
          
      case 'menu',
          % === Menu ===
          ud1.h=...
              uimenu(curdata.menu_current,'Label','Data &Kind', ...
              'TAG', 'CCallback_DataKind');          
          ud1.h2=[];
          curdata.CCallback_DataKind.handles= ud1.h;
          for idx=1:kindlen,
              % User Data= 
              ud1.h2(idx)=uimenu(ud1.h,'Label',...
                  ['&' num2str(idx) kindtag{idx}], ...
                  'Callback', ...
                  ['osp_ViewCallbackC_TimeRange(''ExeCallback'','...
                      'gcbo,[],guidata(gcbo),''parent'')']);
          end
          set(ud1.h2(kindval),'Checked','on');
          set(ud1.h,'UserData',{ud1});
              
      case 'edit',
          % === edit ===
          curdata.CCallback_DataKind.handles= ...
              uicontrol(hs.figure1,...
              'Style','edit', ...
              'BackgroundColor',cl0, ...
              'Units','normalized', ...
              'Position',pos, ...
              'Max',10, ...
              'String',num2str(kindval), ...
              'Tag','CCallback_DataKind', ...
              'TooltipString','Data-Kind Edit-Text', ...
              'Callback', ...
              ['osp_ViewCallbackC_TimeRange(''ExeCallback'','...
                  'gcbo,[],guidata(gcbo),''string'')']);
          
      otherwise,
          errordlg({'====== OSP Error ====', ...
                  ['Undefined Mode :: ' obj.SelectedUITYPE], ...
                  ['  in ' mfilename], ...
                  '======================='});
          delete(curdata.CCallback_DataKindl.handles);
          curdata=rmfield(curdata,'CCallback_DataKind');
  end % End Make Control GUI
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,eventdata,handles,type)
% Execute on change popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================
% Update Channel!
%================
% -- Default Setting ---
kind = 1;idx0 = 1;
% Get Kind and Start Index of UserData
%  Switch :: Defined in Callback :: Style
switch type,
  case 'val',
      % Kind == Value
      kind = get(hObject,'Value');
      idx0=1;
  case 'string', 
      % Kind == String
      try,
          kind = str2num(get(hObject,'String'));
          set(hObject,'ForegroundColor',[0 0 0]);
      catch,
          errordlg({'========== OSP Error ===========', ...
                  ' Edit-Text Callback Kind : Input Kind-Number', ...
                  '================================='});
          set(hObject,'ForegroundColor',[1 0 0]);
          return;
      end
      idx0 = 1;
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

%===================
% ReDraw : Callback!
%===================
ud=get(hObject,'UserData');
for idx=idx0:length(ud),
  % Get Data
  data = p3_ViewCommCallback('getData', ...
      ud{idx}.axes, ...
      ud{idx}.name, ud{idx}.ObjectID);
  % Channel Update
  data.curdata.kind = kind;

  % Delete handle
  for idxh = 1:length(data.handle),
      try,
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
