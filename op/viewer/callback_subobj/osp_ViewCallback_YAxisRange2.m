function varargout=osp_ViewCallback_YAxisRange2(fcn,varargin)
% Y-Axis Range Callback for OSP-Viewer by Axis
% This function is Callback-Object of OSP-Viewer II.
%

% $Id: osp_ViewCallback_YAxisRange2.m 180 2011-05-19 09:34:28Z Katura $


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
%         'X Axis Range'
%       Myfunction Name
%         'vcallback_YAxis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   ='Y Axis-Range (II)';
  basicInfo.fnc    ='osp_ViewCallback_YAxisRange2';
  % File Information
  basicInfo.rver   ='$Revision: 1.1 $';
  basicInfo.rver([1,end])   =[];
  basicInfo.date   ='$Date: 2007/02/01 09:00:06 $';
  basicInfo.date([1,end])   =[];
  
  % Current - Variable Field-Name-List
  basicInfo.cvfname={'vc_YAxisRange2'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.fnc     :  this Function name 
%     data.pos     :  layout position 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isempty(varargin)
    data=varargin{1};
  end
  data.name='Y Axis II';
  data.fnc ='osp_ViewCallback_YAxisRange2';
  if ~isfield(data,'pos')
    data.pos =[0, 0.15, 0.1, 0.2];
    data.lim=[-1 1];
  end
  prompt={'Position : ','Default YLim'};
  def{1} = num2str(data.pos);
  def{2} = num2str(data.lim);
  flag=true;
 
  while flag,
    inp = inputdlg(prompt, ...
		   'Callback Position', 1,def);
    if isempty(inp), break; end
    try,
      pos0=str2num(inp{1});
      if ~isequal(size(pos0),[1,4]),
	      wh=warndlg('Number of Input Data must be 4-numerical!');
	      waitfor(wh);continue;
      end
      if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
	      wh=warndlg('Input Position Value between 0.0 - 1.0.');
	      waitfor(wh);continue;
      end
      lim0=str2num(inp{2});
      if lim0(1)>lim0(2),
	      wh=warndlg('Input YLim Value as ''ymin  ymax''.');
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
  data.pos = pos0;
  data.lim = lim0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  str=['curdata=osp_ViewCallback_YAxisRange2(''make'',handles, abspos,' ...
       'curdata, cbobj{idx});'];
return;

function curdata=make(hs, apos, curdata,obj),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
  pos=getPosabs(obj.pos,apos);
  
  initstr='auto';
  %curdata.Callback_YRange2.handles=axes;
  ah=axes;
   
   x=[0 1 1 0 0];
   y = obj.lim;
   if y(1)>0, y(1)=y(1)*1.2;,
   else, y(1)=y(1)*0.8;end
   if y(2)>0, y(2)=y(2)*0.8;,
   else, y(2)=y(2)*1.2;end
   y=y([1 1 2 2 1]);
   range  =fill(x,y,[0.8 0.8, 0.8]);

   set(ah,...
     'XTickLabelMode','manual', ...
     'XTickLabel','', ...
     'Color',[0.9 0.9, 0.9], ...
     'Position', pos, ...
     'YLimMode','manual',...
     'YLim', obj.lim);
    
  ud.max = -Inf;
  ud.min =  Inf; 
  %ud.range =  curdata.Callback_YRange2.range;
  ud.range = range;
  ud.tagkey=osp_LayoutViewerTool('make_pathstr',curdata.path);
  set(ah,'UserData',ud);
  set(ud.range,...
	  'LineStyle','none',...
      'ButtonDown', ...
      ['osp_ViewCallback_YAxisRange2(', ...
          '''yaxis_Down'', gcbo)']);
%      'LineWidth',10, ...
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxis_Down(h),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd.h  = h;
cbd.ah =get(h,'Parent');
cp0=get(cbd.ah,'CurrentPoint');
cbd.cp0=cp0(1,2);
cbd.YData = get(cbd.h,'YData');
ud = get(cbd.ah,'UserData');
cbd.callbackaxes =osp_LayoutViewerTool('findAxes', gcbf,ud.tagkey);

r=[min(cbd.YData), max(cbd.YData)];
asize= r(2) - r(1);
asize=asize*0.1;

if cp0(1,2)< (r(1) + asize),
  % Select : Reft
  if asize~=0,
    cbd.id=find(cbd.YData < r(1)+asize);
  else,
    cbd.id=[1 2 5];
  end
  set(cbd.h,'FaceColor',[0.8, 1, 0.9]);
  set(gcbf,'WindowButtonMotionFcn', ...
	   ['osp_ViewCallback_YAxisRange2(', ...
            '''yaxisResize_Callback'', gcbf);']);

elseif cp0(1,2)> (r(2) - asize), 
  % Select : Reft
  if asize~=0,
    cbd.id=find(cbd.YData > r(2)-asize);
  else,
    cbd.id=[3 4];
  end
  set(cbd.h,'FaceColor',[0.9, 1, 0.9]);
  set(gcbf,'WindowButtonMotionFcn', ...
	   ['osp_ViewCallback_YAxisRange2(', ...
            '''yaxisResize_Callback'', gcbf);']);
else,
    set(cbd.h,'FaceColor',[0.8, 0.9, 1]);
    set(gcbf,'WindowButtonMotionFcn', ...
        ['osp_ViewCallback_YAxisRange2(', ...
            '''yaxisMove_Callback'', gcbf);']);
end
setappdata(gcbf,'CallbackData',cbd);
waitfor(gcbf,'WindowButtonMotionFcn', '');
set(cbd.h,'FaceColor',[0.8 0.8, 0.8]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisMove_Callback(figh),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
ydata= cbd.YData + cp(1,2) - cbd.cp0;
set(cbd.h,'YData',ydata);
range=[min(ydata), max(ydata)];
yaxisMove(cbd,range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisResize_Callback(figh),
% Execute on Fill box Add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbd=getappdata(figh,'CallbackData');
cp =get(cbd.ah,'CurrentPoint');
cbd.YData(cbd.id)=cp(1,2);
set(cbd.h,'YData',cbd.YData);
range=[min(cbd.YData), max(cbd.YData)];
yaxisMove(cbd,range)
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yaxisMove(cbd,r)
% Move Real
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if r(1)==r(2),return;end
set(cbd.callbackaxes,'YLim',r(1:2));

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

function flg=checkAxisStr(str),
% Get axis property
  flg=0;   % ==Property
  if strcmp(str, 'auto')==0 && ...
     strcmp(str, 'manual')==0 && ...
     strcmp(str, 'tight')==0 && ...
     strcmp(str, 'full')==0 && ...
     strcmp(str, 'default')==0 && ...
     strcmp(str, 'on')==0 && ...
     strcmp(str, 'off')==0 ,
    flg=1; % == Range
  end
return;
