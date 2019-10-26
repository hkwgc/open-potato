function varargout=osp_ViewCallback_2DImageTime(fcn,varargin)
% 2D-Image Time Callback for OSP-Viewer
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_2DImageTime.m 180 2011-05-19 09:34:28Z Katura $


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
%         '2DImage Time'
%       Myfunction Name
%         'vcallback_2DImageTime'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='2DImage Time';
  basicInfo.fnc    ='osp_ViewCallback_2DImageTime';
  % File Information
  basicInfo.rver   ='$Revision: 1.6 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2006/10/27 08:30:24 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_2DImageTime'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.name='2DImage Time';
  data.fnc ='osp_ViewCallback_2DImageTime';
  data.pos =[0, 0, 0.9, 0.1];
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
  str=['curdata=osp_ViewCallback_2DImageTime(''make'',handles, abspos,' ...
          'curdata, cbobj{idx});'];
  return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
  %pos=getPosabs(obj.pos,apos);
  pos = obj.pos;
  % Set position of Time slider, Time edit, Time-Step popup components
  if pos(4)<pos(3),
	  % heigh < width
	  %         *2 *3
	  % <----------->
	  pos1(1:4) = [pos(1)               pos(2)            pos(3)       pos(4)*0.5];
	  pos2(1:4) = [pos(1)+pos(3)*0.75   pos(2)+pos(4)*0.5 pos(3)*0.125 pos(4)*0.5];
	  pos3(1:4) = [pos(1)+pos(3)*0.875  pos(2)+pos(4)*0.5 pos(3)*0.125 pos(4)*0.5];
  else
	  wt=pos(3)/4;
	  ht=pos(4)/4;
	  % heigh > width
	  %  |
	  %  | *2
	  %  | *3 
	  pos1(1:4) = [pos(1)       pos(2)        wt  3*ht];
	  pos2(1:4) = [pos(1)+2*wt  pos(2)+1.2*ht 3*wt    ht];
	  pos3(1:4) = [pos(1)+2*wt  pos(2)+0.1*ht 3*wt    ht];
  end
  pos1 = getPosabs(pos1,apos); 
  pos2 = getPosabs(pos2,apos);
  pos3 = getPosabs(pos3,apos);
  
  %=====================
  % Set Special User Data
  % <- User Data 1 is Special ->
  %=====================
  sld_v=3;                     % init
  sval=3;                      % slide bar step(=x4) 
  % Set Time Position Number
  [header,data]=osp_LayoutViewerTool('getCurrentData',hs.figure1,curdata);
  datasize=size(data);
  if length(datasize)>=4,
      datasize=datasize(2);
  else,
      datasize=datasize(1);
  end

  sldsp  = 2^(sval-1); % Slide Speed
  stepOfButton = sldsp/datasize;
  if stepOfButton>1, stepOfButton = 1; end 
  if sld_v>datasize, sld_v=datasize; end
  ud={};
  % Time Slider
  curdata.Callback_2DImageTime.handles= ...
      uicontrol(hs.figure1,...
		'Style','slider', ...
		'Value', sld_v, ...
		'Min', 1,       ...
		'Max', datasize, ...
		'SliderStep', [ stepOfButton 0.05], ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position', pos1, ...
                'TooltipString','Time Index  Setting', ...
                'Tag','Callback_2DImageTime', ...
		'Callback', ...
		['osp_ViewCallback_2DImageTime(''sld_time_Callback'','...
		 'gcbo,[], guidata(gcbo))']); 
  % confierm :: 
  set(hs.figure1,'Visible','off');
  % Time edit
  curdata.Callback_2DImageTimeE.handles = ...
      uicontrol(hs.figure1,...
		'Style','edit','String', num2str(sld_v), ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position', pos2, ...
		'HorizontalAlignment', 'left', ...
                'TooltipString','Time Index Setting', ...
                'Tag','Callback_2DImageTime', ...
		'Callback', ...
		['osp_ViewCallback_2DImageTime(''edit_time_Callback'','...
		 'gcbo,[],guidata(gcbo))']);

  str={'x1','x2','x4','x8','x16'};
  % Time-Step popup
  curdata.Callback_2DImageTimeStep.handles= ...
      uicontrol(hs.figure1,...
		'Style','popupmenu','String',str, ...
		'Value', sval, ...
		'BackgroundColor',[1 1 1], ...
		'Units','normalized', ...
		'Position', pos3, ...
                'TooltipString','Time slider step Setting', ...
                'Tag','Callback_2DImageTimeStep', ...
		'Callback', ...
		['osp_ViewCallback_2DImageTime(''pop_timestep_Callback'','...
		 'gcbo,[],guidata(gcbo))']);
  
   % Set handles to Time-UserData{1}
   ud={};
   ud{1}=[curdata.Callback_2DImageTime.handles, ...
	  curdata.Callback_2DImageTimeE.handles, ...
	  curdata.Callback_2DImageTimeStep.handles, datasize];
   set(curdata.Callback_2DImageTime.handles, 'UserData', ud);
   set(curdata.Callback_2DImageTimeE.handles, 'UserData', ud);
   set(curdata.Callback_2DImageTimeStep.handles, 'UserData', ud);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sld_time_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try,
  % -- Getting Userdata --
  ud       = get(hObject, 'UserData');
  % -- Getting handles --
  hs       = ud{1};
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  timepos   = round(get(hObject, 'Value'));
  % Error Checking....
  if length(timepos)~=1,
	  error('set 1 point (time-Index) to this edit-text');
  end
  if timepos<=0
	  error('set Positive');
  end
  if timepos> get(hs(1),'MAX'),
	  error('Time-Index : Over flow');
  end  

  %hs(2)==curdata.Callback_2DImageTimeE
  set(hs(2), 'String', num2str(timepos));
catch,
	% Error Operation
	errordlg({' OSP Error!', ...
			['   ' lasterr]});
	set(hObject,'ForegroundColor','red');
	return;
end
%======================
% Get Unit for callback
%======================
chdata=getappdata(gcbf,'CHDATA');
unit =  1000/chdata{1}.samplingperiod;


% == Callback Execution ==
%
% Available Variables in Callback Execution
%
% Useful Variables
%    ud       : User Data ( Set in axes_Object Callback)
%    idx      : Execution ID
%    timepos  : time  index
%    unit     : time-unit of Cdata

for idx=2:length(ud),
	try
		eval(ud{idx}.str);
	catch
		warning(lasterr);
	end
end
%drawnow;
set(hObject,'UserData',ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_time_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try,
  % -- Getting Userdata --
  ud       = get(hObject, 'UserData');
  % -- Getting handles --
  hs       = ud{1};
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  timepos =str2num(get(hObject, 'String'));
  % Error Checking....
  if length(timepos)~=1,
	  error('set 1 point (time-Index) to this edit-text');
  end
  if timepos<=0
	  error('set Positive');
  end
  if timepos> get(hs(1),'MAX'),
	  error('Time-Index : Over flow');
  end
  
  % ===== Callback by sld_time! =====
  set(hs(1),'Value',timepos);
  sld_time_Callback(hs(1),[],handles);

catch,
  % Error Operation
  errordlg({' OSP Error!', ...
	    ['   ' lasterr]});
  set(hObject,'ForegroundColor','red');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_timestep_Callback(hObject,eventdata,handles)
% Execute on Kind-Selector Edit-Text
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try,
  % -- Getting Userdata --
  ud       = get(hObject, 'UserData');
  % -- Getting handles --
  hs       = ud{1};
  % -----------------------------------
  %hs(1)==curdata.Callback_2DImageTime 
  %hs(2)==curdata.Callback_2DImageTimeE
  %hs(4)==datasize==size(cdata,1)
  % -----------------------------------
  sld_v = round(get(hs(1), 'Value'));
  if sld_v<=0, sld_v=1;end
  set(hs(2), 'String', num2str(sld_v));
  
  %--  Default Color --
  set(hObject,'ForegroundColor','black');

  % -- Getting Variable --
  sldsp  = 2^(get(hObject, 'Value')-1); % Slide Speed
  datasize     = hs(4);
  stepOfButton = sldsp/datasize;

  if stepOfButton>1, stepOfButton = 1; end 
  if sld_v>datasize, sld_v=datasize; end
  set(hs(1),'Value',sld_v, ...
		    'Min', 1,       ...
		    'Max', datasize, ...
		    'SliderStep', [ stepOfButton 0.05]);
catch,
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
