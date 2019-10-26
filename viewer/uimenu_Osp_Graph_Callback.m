function varargout = uimenu_Osp_Graph_Callback(mode,varargin)
% Call back Functions of OSP-Graph-Menu
%

% Revision 1.10 
%   Error-Area Menu :
%       Set Rendere OpenGL to Alpha


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



hObject = gcbo;
fig_h   = gcbf;
axs_h   = gca;

% ---------- Menu : Show Info --------
switch mode,
	case 'ShowInformation',
		% Show Figure Data-Information 
		actdata = getappdata(fig_h, 'DataInfo');
		if ~isempty(actdata),
			info =feval(actdata.fcn,'showinfo', actdata.data);
			cl = get(fig_h,'Color');
			fh= figure('MenuBar','none');
			set(fh,'Color',cl,'Name','Infomation');
			axes; axis off;
			th = text(0, 0.7,info);
			set(th, ...
				'Interpreter', 'none', ...
				'FontSize',    12    , ...
				'Color',       1-cl, ...
				'Tag',         'DATA_INFO');
		end
		
	case 'Legend',
		% Legend on/off
		checked = get(hObject,'Checked');
		ax = findPlotAxes(fig_h);
		
		if strcmp(checked,'on')
			set(hObject,'Checked','off');
			for axi = 1:length(ax),
        set(fig_h,'CurrentAxes',ax(axi));
				h = legend; delete(h);
			end
			if isempty(ax)
				h = legend; delete(h);
			end
		else
			set(hObject,'Checked','on');
			for axi = 1:length(ax),
        set(fig_h,'CurrentAxes',ax(axi));
				h = legend; delete(h);
			end
			tag_legend(axs_h);
			h = legend;
			set(h,'Fontsize',10);
		end
		
		% ---------- Menu : Axes --------
	case 'AP_X_AXIS',
		% Apply GCA X-Axis to All Axes
		xlmd=get(axs_h,'XLimMode');
		if strcmp(xlmd,'Auto'), return; end
		xlim=get(axs_h,'XLim');
		ax = findPlotAxes(fig_h);
		
		set(ax,'XLim',xlim);
		
	case 'AP_Y_AXIS',
		% Apply GCA Y-Axis to All Axes
		ylmd=get(axs_h,'YLimMode');
		if strcmp(ylmd,'Auto'), return; end
		ylim=get(axs_h,'YLim');
		ax = findPlotAxes(fig_h);
		
		set(ax,'YLim',ylim);
		
	case 'AXIS_TIGHT',
		% TIGHT AXIS Setting
		ax = findPlotAxes(fig_h);
		nzero = 1e-10;
		for idx=1:length(ax(:)),
      set(fig_h,'CurrentAxes',ax(idx));
			
			tmph=findobj(ax(idx),...
				'Type','patch');
			tg  = get(tmph,'Tag');
			tmph = tmph(strmatch('StimulationPoint',tg));
			
			tmph0 = findobj(ax(idx),'Type','line');
			if isempty(tmph0),
				cnt=axis;cnt=(cnt(3)+cnt(4))/2;                
			else
				yd  = get(tmph0,'YData');
				if iscell(yd), yd=yd{1}; end
				cnt=yd(1);
			end
			
			if isempty(tmph),
				axis tight;
			else
				y = get(tmph,'YData');
				if ~iscell(y), y={y};end
				for iy=1:length(tmph),
					y0=y{iy}; 
					y0(find(y0<-nzero)) = cnt-nzero;
					y0(find(y0> nzero)) = cnt+nzero;
					set(tmph(iy),'YData',y0);
				end
				axis tight;
				for iy=1:length(tmph),
					set(tmph(iy),'YData',y{iy});
				end
			end
		end
		
	case 'AXIS_RESET',
		% RESET AXIS Setting
		ax = findPlotAxes(fig_h);
		set(ax, ...
			'XLimMode','Auto','YLimMode','Auto', ...
			'XScale','Linear','YScale','Linear');
		
	case 'ErrorArea',
		% Error Area Plot
		ep_h=getappdata(fig_h,'ERROR_PATCH_HANDLES');
		if isempty(ep_h), return; end
		
		vb = get(ep_h(1),'Visible');
		if strcmp(vb,'on'),
			vb='off';
		else,
			vb='on';
			set(fig_h,'Renderer','OpenGL');
		end
		
		set(ep_h,'Visible',vb);
		
	case 'LINE_COLOR',
		lh = findLinePropObj(axs_h);
		ax = findPlotAxes(fig_h);
		ax = ax(:)';
		
		Tags =get(lh,'Tag');
		Types=get(lh,'Type');
		ntag=length(Tags);
		for iax=ax
			lh2 = findLinePropObj(iax);
			Tags2=get(lh2,'Tag');
			for idx=1:ntag,
				idx2=find(strcmp(Tags2,Tags{idx}));
				if ~isempty(idx2),
					try,
						if strcmp(get(lh2(idx2),'Type'),Types{idx}),
							switch Types{idx}
								case 'patch',
									set(lh2(idx2),'EdgeColor',get(lh(idx),'EdgeColor'));
								case 'line',
									set(lh2(idx2),'Color',get(lh(idx),'Color'));
							end
						end
					end
				end
			end
		end
		
	case 'LINE_STYLE',
		setLineProp(axs_h, fig_h,'LineStyle');
		
	case 'LINE_All',
		uimenu_Osp_Graph_Callback('LINE_COLOR');
		set(fig_h,'CurrentAxes',axs_h);
		uimenu_Osp_Graph_Callback('LINE_STYLE');
		
	case 'LINE_PROP',
		prop=varargin{1};
		switch lower(prop),
			case 'all',
				uimenu_Osp_Graph_Callback('LINE_COLOR');
				props={'LineStyle','LineWidth'};
				for idx=1:length(props),
					setLineProp(axs_h, fig_h,props{idx});
				end
			case 'color'
				uimenu_Osp_Graph_Callback('LINE_COLOR');
			otherwise,	
				setLineProp(axs_h, fig_h,prop);
		end
		
	case 'MARKER_PROP',
		% Marker Props
		prop=varargin{1};
		if strcmpi(prop,'all'),
			props={'Marker', 'MarkerEdgeColor', 'MarkerFaceColor', 'MarkerSize'};
			for idx=1:length(props),
				setLineProp(axs_h, fig_h,props{idx});
			end
		else
			setLineProp(axs_h, fig_h,prop);
		end
		
end
return;

function ax = findPlotAxes(fig_h)
ax0  = findobj(fig_h, 'Type', 'axes');
tags = get(ax0,'Tag');
idx  = strmatch('ch',tags);
if isempty(idx), 
	ax  = ax0; % Select all axes
else
	% Channel Axes plotted by plot_HBdata 
	ax   = ax0(idx); 
end
return;

function lh = findLinePropObj(ax_h)
lh1=findobj(ax_h,'Type','line');
lh2=findobj(ax_h,'Type','patch');
lh =[lh1; lh2];

function setLineProp(axs_h, fig_h, prop),
lh = findLinePropObj(axs_h);
ax = findPlotAxes(fig_h);
ax = ax(:)';

Tags =get(lh,'Tag');
Types=get(lh,'Type');
ntag=length(Tags);
for iax=ax
	lh2 = findLinePropObj(iax);
	Tags2=get(lh2,'Tag');
	for idx=1:ntag,
		idx2=find(strcmp(Tags2,Tags(idx)));
		if ~isempty(idx2),
			try,
				if strcmp(get(lh2(idx2),'Type'),Types{idx}),
					set(lh2(idx2),prop,get(lh(idx),prop));
				end
			end
		end
	end
end


