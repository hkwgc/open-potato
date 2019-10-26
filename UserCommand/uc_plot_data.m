function varargout = uc_plot_data(header, data, varargin)
% Plot User Command Data
%
%  [h, strPlotData]=uc_plot_data(header, data, varargin)
%
% --- Input ---
%   header : Header of User Command Data 
%
%   data   : Data parts of User Command Data 
%
% varargin is parir of Option and Value.
% = = = = = = = = = = = = = = = = = = = =
%  FigBGcolor : [0.75 0.75 0.75];  
%      Figure Background Color
%
%  AxesFontSize : 6
%      Font size of Axes ( in points)
%
%  PlotKind   : 1:size(data,ndims(data)); 
%      Plot Data-Kind
%
%  STIMPLOT   : 'area'
%      'on'   : Stimulation timing Plot by Mark
%      'area' : Stimulation timing Plot by Band
%
%  AreaColor  : [0.8252           1       0.816]
%       When  'STIMPLOT' is 'area', 
%       'AreaColor' is Color of Simulation Band.
%       'AreaColor' is 2-Dimensional matrix that size
%       is [Number-of-stimulation-kind, 3].
%       If stimulatio kind is 2, '1' and '2'.
%      'AreaColor' can be defined like following
%        [.7 1 .7; 1 1 .1] is 
%      So Period in giving Stimulation 1 is painted  by light-green([0.7, 1.0, 0.7]).
%      So Period in giving Stimulation 2 is painted by yellow([1.0, 1.0, 0.1]).
%
%  DC_OPTION  : ''
%       Data Change option.
%       Data-Option : listed in pop_data_chaneg_v1.
%      'HB data', 'FFT Power', 'FFT Phase' and so on.
%
%  X_AXIS     : -- auto --
%       Axis of X. Example [1, 100]
%
%  Y_AXIS     : -- auto --
%       Axis of Y. Example [-1, 1]
%
%  TitleFig : ''
%      Title in a plot area.
%
%  ErrorPLOT  : 'on'
%      Error Plot or not
%
%  Color     : []
%      Line Color of kind
%      'Color' is 2-Dimensional matrix that size
%      is [Number-of-Data-kind, 3].
%      If Data-Kind is 4, that is 'Oxy','Deoxy','Total','tmp'.
%      'Color' can be defined like following
%           [1 0 0; ...
%            0 0 1; ...
%            0 0 0; ...
%            0 1 0];
%      So Line-Colr of Oxy is red ([1 0 0]),
%      that of Deoxy is blue ([0 0 1]).
%
%  No_MEAN    :  'off'
%       Plot Every Block or not.
%       'on' : Plot Everi Block and not plot Mean
%       'off' : Plot Mean Value of Block only.
% = = = = = = = = = = = = = = = = = = = =
%
% --- Output ---
%  h           : 
%    handles of axes, figure.
%  strPlotData : 
%    Structure of Plot Data.
%    ... not string, sory for bad naming.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See also SIGNAL_VIEWER, PLOT_HBDATA,
%           UC_DATALOAD, UC_BLOCKING, 
%           UC_IMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.04.28
% $Id: uc_plot_data.m 180 2011-05-19 09:34:28Z Katura $
%
% Revison 1.5
%  Bug fixed: (error plot and so on)
%  Add Option Arguments.
%       X_AXIS   : X-Axis
%       Y_AXIS   : Y-Axis
%       TitleFig : Title in a plot area.
%
% Revison 1.6
%   Multi Probe OK.
%
% Revision 1.15
%   Bug fix : 08-Jun-2006 :: See also Mail.


  % -- Argument Check --
  msg=nargchk(2, 100, nargin);
  if ~isempty(msg), error(msg); end

  % Reading Argument
  n = length(varargin);
  if bitget(n,1)==1
    error('Invalid option/value pair arguments');
  end
  clear n msg; % clear variabel.

  % data information
  if ndims(data)~=3 && ndims(data)~=4
    error(['Dimension of DATA matrix is in corerct.' ...
            ' : ' num2str(ndims(data))]);
  end
  
  % === Default Option Setting ===
  % Variable been able to set directory by Argument. 
  argvars    = {'FigBGcolor', ...
		'AxesFontSize', ...
		'PlotKind', ...
		'PlotChannel', ...
		'STIMPLOT', ...
		'AreaColor', ...
		'ErrorPLOT', ...
		'DC_OPTION' ...
		'X_AXIS', ...
		'Y_AXIS', ...
		'TitleFig', ...
		'AXES_TITLE', ...
		'No_MEAN', ...
		'ChannelDistribution' ...
	};

  % Figure Background Color 
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  FigBGcolor = [0.75 0.75 0.75];         % default : gray
  %  FontSize of Axes
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  AxesFontSize = 6;
  % Plot Kind
  %~~~~~~~~~~
  PlotKind   = 1:size(data,ndims(data)); % Default Plot all 
  % Plot Channel
  %~~~~~~~~~~
  PlotChannel= 1:size(data,ndims(data)-1); % Default Plot all 
  % Stimulation Plot On/Off 
  %~~~~~~~~~~~~~~~~~~~~~~~~~
  STIMPLOT   = 'area';
  % Error patch On/Off
  %~~~~~~~~~~~~~~~~~~~
  ErrorPLOT  = 'on';
  % DC_OPTION : Data-Change-Option
  %~~~~~~~~~~~~~~~~~~~
  DC_OPTION = '';
  % X_AXIS : default axis setting
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  X_AXIS = [];
  % Y_AXIS : default axis setting
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Y_AXIS = [];
  % TitleFig : Title of Figure ploting
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  TitleFig = '';
  % AXES_TITLE : AXES_TITLE on/off
  %~~~~~~~~~~~~~~~~~~~
  AXES_TITLE = 'off';
  % Line Color Setting
  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  %   strPlotData.color :  Line Color
  strPlotData.color = [1 0 0; 0 0 1; 0 0 0; ...
		  1 .8 .8; .8 .8 1; .8 .8 .8];
  % Plot Every Block 
  %~~~~~~~~~~~~~~~~~~~
  No_MEAN = 'off';

  % Area Color of StimPlot :
  %  Change 07-Nov-2005
  AreaColor=[0.8252           1       0.816];
  
  % setting value
  for id = 1:2:length(varargin)

    % Setting Variable
    if any(strcmp(argvars, varargin{id})),
      eval([varargin{id} ' = varargin{id+1};']);continue;
    end
    
    switch varargin{id}
     case 'Color', 
      strPlotData.color = varargin{id+1};
	  %      case 'Color2',
	  %       strPlotData.color(2,:) = varargin{id+1};
	  %      case 'Color3',
	  %       strPlotData.color(3,:) = varargin{id+1};
     otherwise,
      error(['Undefined Option : ' varargin{id}]);
    end
  end

  % Tag Setting
  %~~~~~~~~~~~~
  %   strPlotData.tag :  Tag of Data Kind 
  strPlotData.tag = header.TAGs.DataTag;

  % Line Plot Property of Header
  if isfield(header,'VIEW') 
    strPlotData.VIEW = header.VIEW;
  end

  if exist('MultiProbeID','var') && isfield(header,'Pos'),
    mmode = header.Pos.Group.mode(MultiProbeID);
    if mmode~=1,
      mch = header.Pos.Group.ChData{MultiProbeID};
    else
      if bitget(MultiProbeID,1)==0,
	mch = [header.Pos.Group.ChData{MultiProbeID-1}, ...
	       header.Pos.Group.ChData{MultiProbeID}];
      else,
	mch = [header.Pos.Group.ChData{MultiProbeID}, ...
	       header.Pos.Group.ChData{MultiProbeID+1}];
      end
    end
    header.flag(:,:,mch)=[];
    header.measuremode=mmode;
    if ndims(data)==3,
      data(:,mch,:)=[];
    elseif ndims(data)==4,
      data(:,:,mch,:)=[];
    end
  end

  % Make Plot Data
  %~~~~~~~~~~~~~~~
  %   strPlotData.data  : Plot Data
  %   strPlotData.std   : Data for Error Plot (if there)
  if ndims(data)==3,
	  % time x channel x data-kind
	  strPlotData.data = data;
  elseif ndims(data)==4,
	  %--- Block Data : Mean Block ---
	  if strcmpi(No_MEAN,'on'),
		  sz=size(data);
		  strPlotData.data = zeros([0, 0, 0]);
		  
		  pk_tmp  = PlotKind(:)';
		  PlotKind = [];
		  if size(strPlotData.color,1)<sz(4),
		    col_tmp  = strPlotData.color(1:end, :);
		    col_tmp(end+1:sz(4),:) = hsv(sz(4)-size(strPlotData.color,1));
		  else,
		    col_tmp  = strPlotData.color(1:sz(4), :);
		  end
		  strPlotData.color = [];
		  tag_tmp = strPlotData.tag;
		  strPlotData.tag =  {};
		  % reshape(permute(data,[2,3,4,1]),[sz(2),sz(3),sz(4)+sz(1)])
          bflag = any(header.flag,1);
		  for iBlock=1:sz(1),
              if all(bflag(1,iBlock,:)), continue; end
			  strPlotData.data(:,:,end+1:end+sz(4)) = ...
				  data(iBlock,:,:,:);
			  strPlotData.data(:,find(bflag(1,iBlock,:)),end-sz(4)+1:end) = NaN;
			  for istkind=1:sz(4),
				  try,
					  strPlotData.tag{end+1} = ...
						  [tag_tmp{istkind} num2str(iBlock)];
				  catch
					  strPlotData.tag{end+1} = '';
				  end
			  end
			  PlotKind = [PlotKind, pk_tmp];
			  pk_tmp = pk_tmp + sz(4);
			  strPlotData.color = [strPlotData.color; col_tmp];
		  end
		  
	  else, % Mean Version 
		  if strcmp(ErrorPLOT,'on')
			  [strPlotData.data, std_block] = ...
				  uc_blockmean(data, header);
			  if ~isempty(std_block) && any(std_block(:)),
				  strPlotData.std = std_block;
			  end
		  else
			  strPlotData.data = uc_blockmean(data, header);
		  end
		  clear data;
		  if isempty(strPlotData.data),
			  msg=sprintf(['No data to plot\n', ...
					  '\t1.Check if there is selected data\n', ...
					  '\t2.Check BlockArea is not overlap with other Stimulation.\n']);
			  error(msg);
		  end
	  end % Mean Version (end)
  end % Block Data End

  % Data Change Option
  % ~~~~~~~~~~~~~~~~~~
  %
  % If Data change Option
  axis_label.x ='time [sec]';
  axis_label.y ='HB data';
  unit = 1000/header.samplingperiod;
  if ~isempty(DC_OPTION),
	  % === Plot Data Option ==
	  [strPlotData.data , axis_label, unit] ...
		  = pop_data_change_v1(DC_OPTION, strPlotData.data,...
		  axis_label, unit);
	  header.sampleperiod = 1000/unit; 
	  if isfield(strPlotData,'std'),
		  if ~all(size(strPlotData.data)==size(strPlotData.std)),
			  strPlotData = rmfield(strPlotData,'std');
		  end
	  end
  end

  % *************************
  % === Channel Selection ===
  % *************************
  % Select Channel
  if isfield(header,'Pos'),
	  header.Pos.D2.P=header.Pos.D2.P(PlotChannel,:);
	  header.Pos.D3.P=header.Pos.D3.P(PlotChannel,:);
	  pgcd=cell(size(header.Pos.Group.ChData));
	  for tmp_pc = 1:size(PlotChannel,2),
		  for gid=1:length(header.Pos.Group.ChData),
			  id=find(header.Pos.Group.ChData{gid}==PlotChannel(tmp_pc));
			  if ~isempty(id), 
				  pgcd{gid}(end+1)=tmp_pc;
				  break; 
			  end
		  end
	  end
	  header.Pos.Group.ChData = pgcd;
  end  
  
  % **********************
  % === Start Plotting ===
  % **********************
  h.figure1 = figure;
  uh=uimenu_Osp_Graph_Option(h.figure1);

  % === Figure Layout ===
  % ( for Single - Measure Mode )
  if isfield(strPlotData,'std')
      % - Error On/Off - , Check Box
      uh=uimenu(uh, ...
          'Label','Error Area', ...
          'Checked','on', ...
          'Callback',...
          ['uimenu_Osp_Graph_Callback(''ErrorArea'');' ...
              'if strcmp(get(gcbo,''Checked''),''on''),' ...
              '    set(gcbo,''Checked'',''off'');' ...
              'else,' ...
              '    set(gcbo,''Checked'',''on'');' ...
              'end']);
      % Warning!! On/Off is not good..
%           'units','normalized', ...
%           'Position',[0.05, 0.01, 0.9, 0.12], ...
%           'Style', 'checkbox', ...
%           'Value',1, ...
%           'String', 'Error Area', ...
%           'HorizontalAlignment','left', ...
%           'BackgroundColor',FigBGcolor);
 end
 % make Position
 if exist('ChannelDistribution','var'),
     psn  = getChannelDistribution(ChannelDistribution, ...
         size(PlotChannel,2), ...
         [0.9 0.9], [0.05 0.05]);
 else,
     psn  = time_axes_position(header, ...
         [0.9 0.9], [0.05 0.05]);
 end
  
  set(h.figure1, ...
      'Name', [axis_label.x ' x ' axis_label.y], ...
      'Color', FigBGcolor);

  % === Plot Data ===
  for chid = 1:size(PlotChannel,2),
    % plot for one channel
	chid2 = PlotChannel(chid);
	if exist('ChannelDistribution','var') || isfield(header,'Pos'),
		chid0 = chid;
	else,
		chid0 = chid2;
	end

    % Axes position
    ax=axes('units','normal','Position', psn(chid0,:));

    % Axes Handler Management
    ax = gca; % backup ax, because plotting time is so log.
    tag_chnum = strcat('ch', num2str(chid2));
    h=setfield(h,['axes_' tag_chnum],ax);

    % Axes Setting
    set(ax, 'FontSize',AxesFontSize, ...
            'Tag', tag_chnum);
    set(ax, 'FontUnits','Normalized');
    % Plot Stimulation Mark
	switch STIMPLOT,
		case 'on'
			hold on;
			% Y-Area
			ypos     = 0;
			tc1 = find(header.stimTC>0);
			tc1 = tc1./unit;
			h_p = plot(tc1(:), repmat(ypos,length(tc1),1),'gx');
			set(h_p, 'Tag', 'StimulationPoint');
			h.StimulationPoint=h_p;
	
		case {'area', 'Area'},
			hold on;
			% Y-Area
			ypos(1)  = -100;
			ypos(2)  =  100;

			% X-Area & get Stim-Kind-Vector
			stim = header.stim;
			if size(stim,2)==3,
				stim_kind = stim(:,1);
				stim(:,1)=[];
			else,
				stim_kind = header.stimkind;
			end
			stim = stim./unit;

			% Make Area Color
			stim_kind = fix(stim_kind);
			st_kind_map = hsv(max(stim_kind(:)));
			st_kind_map = st_kind_map + 0.5;
			st_kind_map(find(st_kind_map>1))=1;
			% Color ( special)
			if exist('AreaColor','var'),
                st_kind_map = AreaColor;
                if size(st_kind_map,1)<max(stim_kind(:)),
                    for xx=size(st_kind_map,1)+1:max(stim_kind(:)),
                        st_kind_map(xx,:)=st_kind_map(1,:);
                    end
                end
			end
			
			% Patch Plot
			for iblk = 1:size(stim,1),
				tc1 = stim(iblk,:);
				if (tc1(2)-tc1(1)<0.001),
				  % when Event..
				  tc1 = mean(tc1(:)) + ...
					[-0.005, 0.005];
				end
				h_p = fill(tc1([1 1 2 2 1]), ...
					ypos([1 2 2 1 1]), ...
					st_kind_map(stim_kind(iblk),:));
				tg = ['StimulationPoint' num2str(iblk)];
				set(h_p, ...
					'Tag', tg, ...
					'LineStyle','none');
				alpha(h_p,0.7);
				h = setfield(h,tg,h_p);
			end
			% Painter xx  
			% -- Change Rendere --
			% --> to Enable Alpha
			set(h.figure1,'Renderer','zbuffer');
			%set(h.figure1,'Renderer','OpenGL');
    end % switch
  
    % check data existence
    if any(any(~isnan(strPlotData.data(:,chid2,PlotKind ))))
      plot_HBdata(ax, chid2, unit, PlotKind , strPlotData);
    else
      delete(ax);
      continue;
    end
	
    if strcmpi(AXES_TITLE,'on'),
      h_tmp = title(tag_chnum);
      h = setfield(h,['title_' tag_chnum], h_tmp);
    end
	
	axis_now = axis;
	if size(X_AXIS,2)==2,
		axis_now(1:2)=X_AXIS(:);
	end
	if size(Y_AXIS,2)==2,
		axis_now(3:end)=Y_AXIS(:);
	else,
		tmp = strPlotData.data(:,chid2,PlotKind);
		axis_now(3) = min(tmp(:));
		axis_now(4) = max(tmp(:));
	end
    if axis_now(1)==axis_now(2),
        axis_now(1)=axis_now(1)-0.0001;
        axis_now(2)=axis_now(2)+0.0001;
    end
    if axis_now(3)==axis_now(4),
        axis_now(3)=axis_now(3)-0.0001;
        axis_now(4)=axis_now(4)+0.0001;
    end
	axis(axis_now);
  end
	
  
  if ~isempty(TitleFig),
	  tmp_ax = axes;
	  set(tmp_ax, ...
		  'Visible','off',...
		  'Unit','Normalized', ...
		  'position',[0 0 1 1], ...
		  'TAG', 'TitleFig_ax');
	  h.TitleFig_ax = tmp_ax;
	  tmp_tx = text(0.01, 0.97, TitleFig );
	  set(tmp_tx,...
		  'FontUnits','Normalized',...
		  'FontSize',0.03, ...
		  'TAG', 'TitleFig_txt');
	  h.TitleFig_txt = tmp_tx;
  end

  % === Setting Return Value ===
  % 1st : Handler
  if nargout>=1
    varargout{1}=h;
  end
  % 2nd : ProtData
  if nargout>=2
    varargout{2}=strPlotData;
  end

return;


function psn = getChannelDistribution(mode, chnum, pa_sz,pos),
  switch mode,
   case 'Square'
    cnum = ceil(sqrt(chnum));
   case '2Colums'
    cnum = 2;
   otherwise,
    error('No mode exist for Channel Distorybution');
  end

  % width
  c_sz   = pa_sz(1)/cnum;
  c_sp   = c_sz * 0.2; % space of col : 20%
  c_spp2 = c_sp/2;

  cpos = pos(1)+c_spp2;
  for cid=2:cnum;
    cpos(cid)=cpos(cid-1)+c_sz;
  end

  % height
  rnum   = ceil(chnum/cnum);
  r_sz   = pa_sz(2)/rnum;
  r_spp2 = r_sz * 0.1; % space of col : 20%

  rpos = pos(2)+pa_sz(2) -(r_sz-r_spp2);
  for rid=2:rnum;
    rpos(rid)=rpos(rid-1)-r_sz;
  end

  psn=zeros(chnum,4);
  rid=1;
  ax_sz = [c_sz, r_sz] * 0.8;
  chid=1;
  for rid = 1: rnum
    for cid=1:cnum,
      psn(chid,:)=[cpos(cid), rpos(rid), ax_sz];
      chid=chid+1;
      if (chid>chnum) break; end
    end
  end
  
return;
