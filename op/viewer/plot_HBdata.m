function plot_HBdata(axes_h, ch, unit, hb_kind, strHBdata, holdflg)
% plot_HBdata is rewrite HB Data
%
% plot_HBdata(axes_h, ch, unit, hb_kind,HBdata)
%
%   * axes_h is Ploting Axes Handle
%
%   * ch is using channel
%
%   * unit is relative unit
%         unit  =  [plot-unit] / [stimData-unit]
%       if your ploting unit is [sec],
%         and 1 stimData unit  is 0.1 [sec] set unit 10
%       if your ploting unit is 0.1 [sec],
%         and 1 stimData unit  is 0.1 [sec] set unit 1
%
%   * hb_kind is plot-HBkind ID
%       if you want to Oxy & Deoxy , set [ 1 2]
%       if you want to Inport data 4, set 4

% == History ==
% original author : Masanori Shoji
% create : 
% $Id: plot_HBdata.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.10
%   Bug fixd 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



  labels_flg = 1;  % Print Label / not
  legend_flg = 0;  % if new legend -> 1 

  % ============================
  % Argument Check
  % ============================
  if nargin<1 || isempty(axes_h)
    figure; axes_h=gca;
    legend_flg = 1;
  end
  if ~ishandle(axes_h)
    error(' Argument 1 : Axes Handle');
  end
  if nargin<2, ch = 1; end
  if nargin<3, unit=1; end
  if nargin<4, hb_kind = [1 2]; end % Default is [Oxy + Deoxy]
  if nargin<5
    ldata = OSP_DATA('GET','OSP_LocalData');    
    % ordinary Put HBdata to Plot
    strHBdata.data = ldata.HBdata(:,ch,:);
    strHBdata.tag  = ldata.HBdata3Tag;
    ch=1;
    if isfield(ldata,'HBcolor')
      strHBdata.color = ldata.HBcolor;
    end
    clear ldata;
  end
  if nargin<6, holdflg = 0; end 

  % Make Plot HB Data
  HBdata = strHBdata.data;
  HB_tag = strHBdata.tag;
  if isfield(strHBdata,'color')
    HB_col = strHBdata.color;
  else
    HB_col = [ 1 0 0; 0 0 1; 0 0 0 ; ...
	       1 .8 .8; .8 .8 1; .8 .8 .8];
  end
  HBtime =linspace(0, size(HBdata,1)/unit, size(HBdata,1))';
  % make error
  if isfield(strHBdata,'std')
    HBdatastd = strHBdata.std;
    estep = 25; % errorplot
    if size(HBtime,1)<1000
      estep = ceil(size(HBdatastd,1)/40);
    end
    HBerrtimeidx = 1:estep:size(HBdatastd,1);
    if HBerrtimeidx(end)~=size(HBdatastd,1)
        HBerrtimeidx(end+1)=size(HBdatastd,1);
    end
    HBerrtime    = HBtime(HBerrtimeidx);
  end
  % clear strHBdata;


  % axes setting
  %axes(axes_h);
  fig_h= gcf;
  set(fig_h,'CurrentAxes',axes_h);
  hold on;

  % Remove Bifore Data
  if holdflg== 0
    for id = 1:length(HB_tag)
      rm_h = findobj(axes_h,'Tag',HB_tag{id});
      if ~isempty(rm_h)
	delete(rm_h);
      end
    end
  end

  % -- Error Plot ---
  if exist('HBdatastd','var')
    ep_h=getappdata(fig_h,'ERROR_PATCH_HANDLES');
    for a_hbkind = hb_kind
      % @since 1.9
      std_now = HBdatastd(HBerrtimeidx, ch, a_hbkind);
      if any(isnan(std_now)) || any(std_now<=0), continue; end

      % Color Setting
      if size(HB_col,1) >= a_hbkind
	color = HB_col(a_hbkind,:);
      else
	color = [.8 .8 .4]; % Default
      end
    
      plotdata = squeeze(HBdata(:,ch, a_hbkind));
      err_p = plotdata(HBerrtimeidx) +  ...
	      squeeze(HBdatastd(HBerrtimeidx, ch, a_hbkind));
      err_m = plotdata(HBerrtimeidx) -  ...
	      squeeze(HBdatastd(HBerrtimeidx, ch, a_hbkind));

      ep_h(end+1) = ...
	  patch([HBerrtime; HBerrtime(end:-1:1)], ...
		[err_p; err_m(end:-1:1)], ...
		1, ...
		'EdgeColor', color, ...
		'FaceColor', color, ...
		'FaceAlpha', 0.1, ...
		'Tag', [HB_tag{a_hbkind} ' : Error']);
    end % HB kind Loop
    setappdata(fig_h,'ERROR_PATCH_HANDLES',ep_h);
    r=get(fig_h,'Renderer');
    if strcmpi(r,'painters'),
      set(fig_h,'Renderer','zbuffer');
      %set(fig_h,'Renderer','OpenGL');
    end
  end % Error plot

  % -- Plot --
  for a_hbkind = hb_kind

    % Color Setting
    if size(HB_col,1) >= a_hbkind
      color = HB_col(a_hbkind,:);
    else
      color = [.8 .8 .4]; % Default
    end
    
    plotdata = squeeze(HBdata(:,ch, a_hbkind));
    
    opt={};
    if isfield(strHBdata,'VIEW')
        if isfield(strHBdata.VIEW,'lineprop'),
            ud= strHBdata.VIEW.lineprop;
            if length(ud)>=a_hbkind,
                ud = ud{a_hbkind};
                if isfield(ud,'color'),
                    color=ud.color;
                end
                if isfield(ud,'mark'),
                    opt{end+1}='Marker';
                    opt{end+1}=ud.mark;
                end
                if isfield(ud,'style'),
                    opt{end+1}='LineStyle';
                    opt{end+1}=ud.style;
                end
		% Add : 19-Apr-2006
                if isfield(ud,'LineWidth'),
                    opt{end+1}='LineWidth';
                    opt{end+1}=ud.LineWidth;
                end
                if isfield(ud,'MarkerSize'),
                    opt{end+1}='MarkerSize';
                    opt{end+1}=ud.MarkerSize;
                end
                if isfield(ud,'MarkerEdgeColor'),
                    opt{end+1}='MarkerEdgeColor';
                    opt{end+1}=ud.MarkerEdgeColor;
                end
                if isfield(ud,'MarkerFaceColor'),
                    opt{end+1}='MarkerFaceColor';
                    opt{end+1}=ud.MarkerFaceColor;
                end

            end
        end
            
    end            
    opt{end+1}='Color';
    opt{end+1}=color;
    opt{end+1}='Tag';
    opt{end+1}=HB_tag{a_hbkind};
            
    plot(HBtime, plotdata,opt{:});
    
        
  end

%  % Labels
%  if labels_flg
%    title(['HB Data Channels : ' num2str(ch)]);
%    xlabel('time');
%  end

  % === Axes Setting ===
  axis tight;
  % Legend
  if legend_flg
    tag_legend(axes_h);
  end
return;
