function varargout=LAYOUT_AO_Histgram(fnc,varargin)
%$ID$

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
function info=createBasicInfo
% get Basic Info
  info.MODENAME='Histgram';
  info.fnc     ='LAYOUT_AO_Histgram';
  % Useing Common-Callback-Object
   info.ccb     = {'Channel', ...
 	  'Kind', ...
 	  'stimkind',...
 	  };
%info.ccb = 'all';
  % No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
function data=getArgument(varargin),
% Set up : Plot Data
% --- for change ---
  if length(varargin)>=1,
    data=varargin{1};
  end
  data.str = 'Histgram';
  data.fnc = 'LAYOUT_AO_Histgram';
  data.ver = 1.00;
  data.dcoption = 'HB data';
%-   
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> set Callback of Axes-Group
function str = drawstr(varargin)
% DrawStr : 
%
% See also osp_ViewAxesObject_PlotTest/getArgument,
%          ViweGroupAxes/exe,
%          p3_ViewCommCallback.
str=['LAYOUT_AO_Histgram(''draw'', ', ...
     'h.axes ,curdata, obj{idx})'];
return;

function h=draw(gca0, curdata,obj, ObjectID)
% Draw / Redraw Line-Axes-Object
%
% GCA0      : The Draw Axeis( Usually Current Axis);
% CURDATA   : Current Data in Drawing.
%             Defined in ViewerII -> 
%             rf). osp_LayoutViewer
% OBJ       : This Axes-Object.
%             Made in subfunction getArgument.
% OBJECT_ID : When draw   : There is no ObjectID.
%             When Redraw : INDEX of Redraw Object.
%             This variable for CommonCallabck.

% Load Current Data
%axes(gca0);
f=curdata.gcf;
h.h=[];h.tag={}; 

%curdata.flag.MarkAveraging = false;%- no averageing mode
%[hdata,data] = osp_LayoutViewerTool('getCurrentData',f,curdata);
% if iscell(data)
% 	col = [1 0 0; 0 .7 0; 0 0 1; 1 .6 0; 0 .7 .5;.8 0 .6;];
% 	for k=1:length(data)
% 		h=sub_DrawLine(h, data{k}(:,curdata.ch,:), hdata, gca0, curdata, obj);
% 		set(h.h(end),'Color',col(mod(curdata.stimkind(k)+5,6)+1,:));
% 	end
% 
% else
% 	h=sub_DrawLine(h, data(:,curdata.ch,:), hdata, gca0, curdata, obj);
% end

[hdata,data] = osp_LayoutViewerTool('getCurrentDataRaw',f,curdata);
switch curdata.region
	case 'Continuous'
		tmp=data(:,curdata.ch,curdata.kind(1));
	case 'Block'
		tmp=data(:,:,curdata.ch,curdata.kind(1));
end

h=sub_DrawLine(h, tmp(:), hdata, gca0, curdata, obj);

%======================================
%=      Common-Callback Setting       =
%======================================
myName='AXES_PlotTest_ObjectData';
if exist('ObjectID','var'),
  p3_ViewCommCallback('Update', h.h, myName, gca0, curdata, obj, ObjectID);
else
  p3_ViewCommCallback('CheckIn', h.h, myName, gca0, curdata, obj);
end


%================================================================
function h = sub_DrawLine(h, data, hdata, gca0, curdata, obj)

%===========================
%    Line Property 
%===========================
if isfield(curdata,'lineprop') && ~isempty(curdata.lineprop),
  linepropflag=true;
else
  linepropflag=false;
end
%---------------
% Default Color
%---------------
a=size(data);a=a(end);
if a<10; a=10;end
%dcol=hot(round(a));
dcol=copper(a);
dcol(1:3,:)=[1, 0, 0; ...
	     0, 0, 1; ...
	     0, 0, 0];

%===========================
% Data Change Option ...
%===========================
axis_label.x='time [sec]';
axis_label.y='HB data';
unit = 1000/hdata.samplingperiod;
try
  % Mode Transfer
  [data, axis_label, unit] = ...
      pop_data_change_v1(obj.dcoption, data, axis_label, unit);
  hdata.samplingperiod=1000/unit;
catch
  warning(['OSP Warning : Data Change Error Occur! ' ...
	   C__FILE__LINE__CHAR ...
	   ' ' lasterr]);
end
%-------------------
% Line TAG Setting..
%-------------------
if strcmpi(obj.dcoption,'HB data'),
  tag_head=[curdata.region(1) '_' obj.dcoption(1:2)];
else
  tag_head=[curdata.region(1) '_' obj.dcoption([1,4])];
end

%===========================
%--- Axes Setting --
%===========================
% Axis Setting
if 0,
  xlabel(axis_label.x);
  ylabel(axis_label.y);
end

%===========================
% Time Range Change
%===========================
if strcmp(axis_label.x,'time [sec]'),
  t0=1:size(data,1);
  t=(t0 -1)/unit;
  % Time Range Require!
  of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
  uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];
else,
  t0=1:size(data,1);
  t = t0/unit;
end
data = data(t0,:,:);

%===========================
% make data & Draw
%===========================
if isfield(curdata,'prmHistgram')
	p=curdata.prmHistgram;
else
	%- default setting
	p.mode=1;
	p.binnum=10;
end

%-
if p.mode==1
	m=hist(data(:,:,curdata.kind(1)),p.binnum);
else
	m=hist(data(:,:,curdata.kind(1)),p.binvec);
end
h.h=bar(m);
set(h.h,'facecolor','none');

%xlim([-0.5 0.5])
axis tight;

% Kind is in a Data-Range? 
tmp_kind= find((curdata.kind<=0) + (curdata.kind>size(data,3)));
if ~isempty(tmp_kind),curdata.kind(tmp_kind)=[];end

