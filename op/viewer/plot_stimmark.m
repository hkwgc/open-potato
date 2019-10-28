function plot_stimmark(axes_h,ch, unit, stimInfo)
% plot_stimmark is rewrite "Stimulation Mark" to the axes
%
%  plot_stimmark(axes_h, ch)
%     plot "Stimulation Mark"
%     Range of Time ( x-axis ) is same as now axes
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
%   * stimInfo is Stimulation Information


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


  % ============================
  % Argument Check
  % ============================
  if ~ishandle(axes_h)
    error(' Argument 1 : Axes Handle');
  end

  if nargin<2, ch = 1; end

  if nargin<3, unit = 1; end

  % ============================
  % Load Stimulation Information
  % ============================
  if nargin <4
    ldata = OSP_DATA('GET','OSP_LocalData');
    mode     = ldata.StimInfo.type;
    stimData = ldata.StimInfo.StimData;
    clear ldata;
  else
    mode     = stimInfo.type;
    stimData = stimInfo.StimData;
    clear stimInfo;
  end

  % ============================
  % Plot Axes Seting
  % ============================
  % -- remove old data --
  old_h = findobj(axes_h,'Tag','StimMark');
  if ~isempty(old_h)
    delete(old_h);
  end
  axes(axes_h); hold on;

  % -- Get  Plot Range --
  axtmp = axis;

  % Plot Time ( x-axis ) 
  sptime = axtmp(1);               % Plot Start-Time(X)
  fptime = axtmp(2);               % Plot Final-Time(X)
  stime = sptime * unit;           % Start-Time(X) in the stim unit
  ftime = fptime * unit;           % Final-Time(X) in the stim unit

  % Plot Density  ( y-axis ) 
  sz   = (axtmp(4)-axtmp(3)) * 0.1 ;
  lower_dnsty = axtmp(3) + sz;    % Lower Position of Y-axis
  upper_dnsty = axtmp(4) - sz;    % Upwer Position of Y-axis

  clear axtmp;


  % === Make Plot Data ===
  % Height Setting
  [kind{1:length(stimData)}] = deal(stimData.kind);
  kind = [kind{:}];
  kind = sort(kind);
  sz2 = sz/length(kind);
  upper_dnsty(kind) = upper_dnsty - sz2 * [1:length(kind)];
  clear kind sz2; 

  switch mode
    %%%%%%%%%%%%%%%%%%%%%%
   case 1 % Event Data
    %%%%%%%%%%%%%%%%%%%%%%
     ptime=[]; pheight=[];
     ptime_ng=[]; pheight_ng=[];
     for astimData =stimData
       for astimtime = astimData.stimtime

	 % Range Check
	 if astimtime.iniStim < stime || ...
	       astimtime.iniStim > ftime
	   continue;
	 end

	 % Using Flag
	 if ~isfield(astimtime,'chflg') || astimtime.chflg(ch) == 1
	   ptime(end+1)   = astimtime.iniStim;
	   pheight(end+1) = upper_dnsty(astimData.kind);
	 else
	   ptime_ng(end+1)   = astimtime.iniStim;
	   pheight_ng(end+1) = lower_dnsty;
	 end
      end % Stimulation Time
     end  % Stim Kind

     tmp_h=[];
     % Selected Marker
     if ~isempty(ptime)
       % Sort along Time
       [ptime idx]= sort(ptime);
       pheight    = pheight(idx);

       % unit transrate
       ptime    = ptime./unit;
       
       % plot
       tmp_h(1) = plot(ptime, pheight,'go');
     end

     % Unselected Marker
     if ~isempty(ptime_ng)
       % Sort along Time
       [ptime_ng idx]= sort(ptime_ng);
       pheight_ng    = pheight_ng(idx);

       % unit transrate
       ptime_ng = ptime_ng./unit;

       % Plot  NG
       tmp_h(end+1) = plot(ptime_ng, pheight_ng,'mx');
     end

    %%%%%%%%%%%%%%%%%%%%%%
   case 2  % Block Data
    %%%%%%%%%%%%%%%%%%%%%%
     ptime=[]; pheight=[];
     ptime_end=[];
     for astimData =stimData
       for astimtime = astimData.stimtime

	 % Range Check + Using Flag
	 if astimtime.finStim < stime || ...
	       astimtime.iniStim > ftime 
	   continue;
	 elseif isfield(astimtime,'chflg') && astimtime.chflg(ch) ~= 1
	   continue;
	 end

	 % Using Flag
	 ptime(end+1)       = astimtime.iniStim;
	 ptime_end(end+1)   = astimtime.finStim;
	 pheight(end+1)     = upper_dnsty(astimData.kind);
       end % Stimulation Time
     end  % Stim Kind

     % No Selected Stimulation Block
     if ~isempty(ptime)
       % Sort along Time
       [ptime idx]= sort(ptime);
       pheight      = pheight(idx);
       ptime_end    = ptime_end(idx);

       % Make Pulse
       ptime = [ ptime(:)'; ptime(:)'; ...
		 ptime_end(:)'; ptime_end(:)' ];
       pheight2(1:length(pheight)) = lower_dnsty;
       pheight = [ pheight2(:)'; pheight(:)'; ...
		   pheight(:)'; pheight2(:)'];
       clear pheight2;

       ptime = ptime(:); pheight=pheight(:);

       % Range Check2
       %     early - check
       if ptime(1) < stime
	 ptime(1)=stime;
       else
	 ptime   = [ stime ;ptime];
	 pheight = [ pheight(1) ;pheight];
       end
       %     late - check
       if ptime(end) > ftime
	 ptime(end)=ftime;
       else
	 ptime(end+1)   = ftime;
	 pheight(end+1) = pheight(end);
       end
     else
       % Set Start from End
       ptime(1)     = stime;
       ptime(2)     = ftime;
       pheight(1:2) = lower_dnsty;
     end

     % unit transrate
     ptime    = ptime./unit;

     % Plot
     tmp_h(1) = plot(ptime, pheight,'k:');

   otherwise
    error('Unknow Mode');
  end

  if ~isempty(tmp_h)
    set(tmp_h,'Tag','StimMark');
  end

return;
