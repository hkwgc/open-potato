function varargout=osp_ViewAxesObj_StimArea(fnc,varargin)
% Control Function to Draw "Line" in Viewer II
%
% osp_ViewAxesObj_StimArea is "View-Axes-Object",
% so osp_ViewAxesObj_StimArea is based on the rule.
%
% osp_ViewAxesObj_StimArea use "Common-Callback",
% so osp_ViewAxesObj_StimArea is based on the rule.
%
%
% === Open Help Document ===
% Defined in View Axes Object :
%   Upper-Link :  ViewGroupAxes/HelpObj
%
% Syntax :
%   osp_ViewAxesObj_StimArea
%     Open Help of the Function for user.
%
% === Other  ===
%
% Syntax :
% varargout=osp_ViewAxesObj_StimArea(fnc,varargin)
%
% See also : OSP_VIEWCOMMCALLBACK,
%            OSP_LAYOUTVIEWER,
%            LAYOUTMANAGER,
%            VIEWGROUPAXES.

% == Warning !! ==
% When you want to edit this function,
%  you must be based on View-Axes-Object rules.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2006.08.08
% $Id: osp_ViewAxesObj_StimArea.m 298 2012-11-15 08:58:23Z Katura $
%
% Revision 1.3:
%  fast--> remove unplot Area

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch .. sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No argument : Help : (Defined in View-Axes-Object )
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
	[varargout{1:nargout}] = feval(fnc, varargin{:});
else,
	feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=createBasicInfo
% get Basic Info
info.MODENAME='Stim Area (test 0)';
info.fnc     ='osp_ViewAxesObj_StimArea';
% Useing Common-Callback-Object
%   info.ccb     = {'Data',...
% 	  'Channel', ...
% 	  'Kind', ...
% 	  'TimeRange'};
info.ccb ='all';
info.Version = 1.0;

% No TimePoint
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin)
% Set up : Plot Data
% --- for change ---
if length(varargin)>=1,
	data=varargin{1};
end
data.str = 'Stim Area (test 0)';
data.fnc = 'osp_ViewAxesObj_StimArea';
data.ver = 2.0;
data.StimPlotMode='Fill';
%data.defaultVisible='off';

% Figure
fh=figure('MenuBar','none', 'Units','Characters');
p=get(fh,'Position');
p(3:4)=[80,10];set(fh,'Position',p);
set(fh,'Units','Normalized');
set(fh,'DeleteFcn','error(''Push OK / Cancel'');');
% Title
th = uicontrol('Style','Text', ...
	'Units','Normalized', ...
	'Position',[5,80,90,15]/ 100, ...
	'String','Data Change Option', ...
	'HorizontalAlignment','left');
% Popup Menu
pstr = {'on','off'};
val=2;
try
	if isfield(data,'defaultVisible')
		val  = find(strcmp(data.defaultVisible,pstr));
		if isempty(val), val=2; end
	end
catch
	errordlg({'Colud not read Default-Visible Option.',...
		'  : Select off for Default Visible'});
	set(0,'CurrentFigure',fh);
end
ph = uicontrol('Style','popupmenu', ...
	'Units','Normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[10,50,70,20]/ 100, ...
	'String', pstr, ...
	'Value', val);

% OK button
oh = uicontrol('Units','Normalized', ...
	'Position',[30,10,20,20]/ 100, ...
	'BackgroundColor',[1 1 1], ...
	'String', 'OK', ...
	'Callback', ...
	['set(gcbf,''DeleteFcn'','''');'...
	'set(gcbf,''UserData'',true);']);
ch = uicontrol('Units','Normalized', ...
	'Position',[60,10,20,20]/ 100, ...
	'BackgroundColor',[1 1 1], ...
	'String', 'Cancel', ...
	'Callback', ...
	['set(gcbf,''DeleteFcn'','''');'...
	'set(gcbf,''UserData'',false);']);
waitfor(fh,'DeleteFcn','');
if ishandle(fh),
	flg = get(fh,'UserData');
	% Cancel
	if flg,
		data.defaultVisible=pstr{get(ph,'Value')};
	else
		data=[];
	end
	delete(fh);
else
	data=[];
end



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
str=['osp_ViewAxesObj_StimArea(''draw'', ', ...
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

myName='LAYOUT_AO_StimArea_ObjectData';

if isfield(curdata,'Callback_StimAreaMenu') && ...
		isfield(curdata.Callback_StimAreaMenu,'handle') && ...
		ishandle(curdata.Callback_StimAreaMenu.handle)
	val=get(curdata.Callback_StimAreaMenu.handle,'checked');
	if strcmpi(val,'off')
		h.h=[];
		%=      Common-Data Setting       =
		if exist('ObjectID','var'),
			p3_ViewCommCallback('Update', h.h, myName, gca0, curdata, obj, ObjectID);
		else
			p3_ViewCommCallback('CheckIn', h.h, myName, gca0, curdata, obj);
		end
		return;
	end
elseif strcmpi(obj.defaultVisible,'off') %- check default setting
	h.h=[];
	%=      Common-Data Setting       =
	if exist('ObjectID','var'),
		p3_ViewCommCallback('Update', h.h, myName, gca0, curdata, obj, ObjectID);
	else
		p3_ViewCommCallback('CheckIn', h.h, myName, gca0, curdata, obj);
	end
	return;
end

%mh=curdata.Callback_StimAreaMenu.handles;
%curdata.Callback_StimAreaMenu.handles=mh;
%wk.gca0=gca0;
%wk.curdata=curdata;
%wk.obj    = obj;
%myName='AO_StimArea';
% if ~exist('ObjectID','var'),
%   ud=get(mh,'UserData');
%   wk.objidx=length(ud)+1;
%   ud{wk.objidx}=wk;
%   set(mh,'UserData',ud);
%   %======================================
%   %=      Common-Callback Setting       =
%   %======================================
%   ObjectID=p3_ViewCommCallback('CheckIn', ...
%     [], myName, ...
%     gca0, curdata, obj);
%   h=[];
%   if ~isfield(obj,'defaultVisible'), return; end
%   if strcmpi(obj.defaultVisible,'off'), return; end
%   set(mh,'Check','on')
% end

f=curdata.gcf;
set(f,'CurrentAxes',gca0);
hdata=osp_LayoutViewerTool('getCurrentData',f,curdata);

%------------------
% Time Range Change
%------------------
unit = 1000/hdata.samplingperiod;
t0=1:length(hdata.stimTC);
t=(t0 -1)/unit; t_endbk=t(end);
% Time Range Require!
of=find(t<curdata.time(1));t0(of)=[]; t(of)=[];
uf=find(t>curdata.time(2));t0(uf)=[]; t(uf)=[];

switch obj.StimPlotMode
	case 'Fill_Old',
		hold on;
		% Y-Area
		if 1,
			r=axis(gca0);
			y0=[r(3);r(3);r(4);r(4)];
		else,
			y0 = [-100; -100; 100; 100];
		end
		% X-Area & get Stim-Kind-Vector
		stim = hdata.stim;
		if size(stim,2)==3,
			stim_kind = stim(:,1);
			stim(:,1)=[];
		else,
			stim_kind = hdata.stimkind;
		end
		stim = stim./unit;
		
		% Make Area Color
		stim_kind = fix(stim_kind);
		
		bkp = 0;
		c0=[0.8 0.8 0.8];
		% Patch Plot
		h.h=[];
		for iblk = 1:size(stim,1),
			tc1 = stim(iblk,:);
			if (tc1(2)-tc1(1)<0.001),
				% when Event..
				tc1 = mean(tc1(:)) + ...
					[-0.05, 0.05];
			end
			tc0 = [bkp, tc1(1)];bkp=tc1(2);
			h.h(end+1) = fill(tc0([1 2 2 1])', y0, c0);
			alpha(h.h(end),0.7);
			set(h.h(end),'LineStyle','none');
			h.h(end+1) = fill(tc1([1 2 2 1])', y0, [0.4 1 0.8]);
			alpha(h.h(end),0.7);
			set(h.h(end),...
				'LineStyle','-', ...
				'LineWidth',0.5, ...
				'EdgeColor',[0.3,0.9,0.7]);
			alpha(h.h(end),0.7);
		end
		tc0 = [bkp t_endbk];
		h.h(end+1) = fill(tc0([1 2 2 1])', y0, c0);
		alpha(h.h(end),0.7);
		set(h.h(end),'LineStyle','none');
		
		if 0,
			% Comment out : mail 2007.08.06
			axis tight
			axis off
		end
		% Painter xx
		% -- Change Rendere --
		% --> to Enable Alpha
		set(f,'Renderer','zbuffer');
		%set(f,'Renderer','OpenGL');
		
	case 'Fill',
		hold on;
		% Y-Area
			if isfield(curdata,'ylim')
				y0=[curdata.ylim(1);curdata.ylim(1);...
					curdata.ylim(2);curdata.ylim(2)];
			else
				r=axis(gca0);
				y0=[r(3);r(3);r(4);r(4)];
			end
		
	
		% X-Area & get Stim-Kind-Vector
		stim = hdata.stim;
		
		if isfield(hdata,'stimkind')
			stim_kind=hdata.stimkind;
		else
			if size(stim,2)==3,
				stim_kind = stim(:,1);
				stim(:,1)=[];
			else
				stim_kind = hdata.stimkind;
			end
		end
		if strcmpi('block',curdata.region)
			stim=stim./unit;
		else %- continuous
			stim = stim./unit;
		end
		
		% Make Area Color
		col = perms([0.9 0.8 0.7]);
		
		% Patch Plot
		h.h=[];
		switch curdata.region
			case 'Continuous'
				
				stim = hdata.stim;
				if isfield(curdata,'stimkind')
					stimTG=find(ismember(stim(:,1),curdata.stimkind))';
				else
					stimTG=1:size(stim,1);
				end
				stim=stim/unit;		

				for iblk = stimTG
					tc1 = stim(iblk,2:3);
					if (tc1(2)-tc1(1)<0.001),%- Event
						tc1 = mean(tc1(:)) + [-0.05, 0.05];
						h.h(end+1) = line(tc1([1 1])', y0([1 3]));
						set(h.h(end),'linewidth',2,'Color', col(mod(stim_kind(iblk,1)+2,6)+1,:));
					else					%- Block
						%tc0 = [bkp, tc1(1)];bkp=tc1(2);
						h.h(end+1) = fill(tc1([1 2 2 1])', y0, col(mod(stim_kind(iblk,1)+2,6)+1,:));
						set(h.h(end), 'LineStyle','none');
						%alpha(h.h(end),0.7);
					end
				end
			case 'Block'
				
				stim=hdata.stim/unit;
				if isfield(curdata,'stimkind')
					stim_kind=curdata.stimkind;
				else
					stim_kind=unique(hdata.stimkind);
				end				
				
				tc1 = stim(1,:);
				if (tc1(2)-tc1(1)<0.001),
					% when Event..
					tc1 = mean(tc1(:)) + [-0.05, 0.05];
				end
				
				if length(stim_kind)>1
					col1 = [0.7 0.7 0.7];
				else
					col1=col(mod(stim_kind(1)+2,6)+1,:);
				end
				h.h(end+1) = fill(tc1([1 2 2 1])', y0, col1);
				set(h.h(end), 'LineStyle','none');
				
			otherwise
		end
		if 0
			%- Comment out : mail 2007.08.06
			axis tight
		end
		
		%- Painter xx
		%set(f,'Renderer','zbuffer');
		
end % switch

%%object order sort (put stim area to last)
tmp.id=get(gca0,'children');
tmp.id=[tmp.id(~ismember(tmp.id,h.h)); tmp.id(ismember(tmp.id,h.h))];
set(gca0,'children',tmp.id);
clear tmp;
%%-------------------------- mod bt TK@HARL 090306

% wk.h    = h.h;
% wk.objidx = ObjectID;
% ud=get(mh,'UserData');
% ud{wk.objidx}=wk;
% set(mh,'UserData',ud);
% p3_ViewCommCallback('Update', ...
%   h.h, myName, ...
%   gca0, curdata, obj, ObjectID);

%==================================
%=      Common-Data Setting       =
%==================================
if exist('ObjectID','var'),
	p3_ViewCommCallback('Update', ...
		h.h, myName, ...
		gca0, curdata, obj, ObjectID);
else
	p3_ViewCommCallback('CheckIn', ...
		h.h, myName, ...
		gca0, curdata, obj);
end


return;

