function stimInfo= motioncheck(data, hb_kind, stimInfo, ...
			       highpath, lowpath, ...
			       criterion, unit, ...
			       axes_h, ch)
% MOTIONCHECK detect Motion from OSP HB-Raw Data
%
%   --- Input Data --
%   data   : 3 dimensional HB Data
%            time x channel x HB-Kind
%
%  HB Kind : Checking HB-Kind
%            Multipul Input is avairable, example 'hb_kid=[1:3]'
%
%  stimInfo : Information of Stimulation.
%             OSP Stimulation Data.
%
%  highpath  : High-Path for Band-path filter
%              Input by [Hz]
%
%  lowpath   : High-Path for Band-path filter
%              Input by [Hz]
%
%  criterion : Criterion for determinig the acceptability Motion.
%               numerical : 
%                      [mMmm]
%              other : ( sometion no numerical value)
%                      Triple Standerd Divition.
%
%  unit      :  time unit
%
%  -- if you plot --
%  axes_h    :  Handle of plot axes
%  ch        :  Handle of plot channel
%
% - -- Output Data --
%  stimInfo : Information of Stimulation.
%             OSP Stimulation Data.
%             If we detect motion at Channel in each block,
%             change Using Flag in stimInfo zero.
%
%
% Detecting Method : 
%   1. smothing by using Band-Path-Filter
%   2. Difference-Check 
%      nere time
%
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original
%   author : H.Atumori 
%
%  -> Import block_controller , 2005.02.03
%      Change to function
%        Masanori Shoji
% $Id: motioncheck.m 180 2011-05-19 09:34:28Z Katura $


  % === Argument Check ======
  if nargin>0         %  normaly 1, if 0 use debugmode
  else
    ldata    = OSP_DATA('GET','OSP_LocalData');
    data     = ldata.HBdata;
    stimInfo = ldata.StimInfo;
    unit     = 1000/ldata.info.sampleperiod;
    hb_kind  = 3;   % Old
    tag      = ldata.HBdata3Tag;
    ch       = 1;
    clear ldata;

    highpath=0.02;
    lowpath =0.8;
    criterion = '3sigma';

    fh= figure;
    set(fh,...
	'Name','Motion Check Debug',...
	'NumberTitle', 'off',...
	'Color',[1 1 1], ...
	'Renderer','OpenGL');
    axes_h = axes;
  end

  % ===== Initiarize =======
  % sampling period
  smpl_pld = 1000/unit;
  chnum    = size(data,2);
  if ch > chnum, ch = chnum; end

  % ===== Plot Check Data ======
  if exist('axes_h','var') && nargin==0
    axes(axes_h); hold on;

    strHB.data = data;
    if exist('tag','var')
      strHB.tag  = tag;
    else
      strHB.tag  = 'Original MotionCheck Data';
    end
    strHB.color= [1 0 0; 0 0 1; 0 0 0];
    plot_HBdata(axes_h, ch, unit, hb_kind, strHB);
    clear strHB;
  end


  % HB kind Loop if you want to 
  stimData = stimInfo.StimData;

  for ahbkind = hb_kind  % Loop hbkind

    % Initiarize 
    cdata = data(:,:,ahbkind);

    % ========== Data Filtering ===========
    % === Preprocessing : Butter worth Distal Filtering ===
    if exist('butter','file')==0 
      if ~exist('warn_butter','var')
	warndlg(...
	    sprintf('%s\n\t%s\n',...
		    'No butter worth : There is no function ''butter''', ...
		    ' Use FFT'),' Debug Mode');
	warn_butter = 1;
      end
    
      cdata = ot_bandpass2(cdata, highpath(1), lowpath(1), ...
			   1, smpl_pld/1000, 1,'time');
    else
      [b,a]=ot_butter(highpath(1), lowpath(1), ...
		      unit, 5,'bpf');%Use 5 degree
      cdata=ot_filtfilt(cdata, a , b, 1);
    end 


    % --  (Plot Butter Worth By Black ) --
    if exist('axes_h','var')
      strHB.data(1:size(cdata,1),1:size(cdata,2), 1) = cdata;
      strHB.tag   = {['MotionCheck Fiter Data, HBkind=' num2str(ahbkind)]};
      strHB.color= [0.5 0.5 0.5];
      plot_HBdata(axes_h, ch, unit, 1, strHB);
    end

    % ===== Start Motion Check =====
    errorTime=[];
    for stimkind = 1:length(stimData)  % Kind Loop
      lstimtime = stimData(stimkind).stimtime;

      if ~isfield(lstimtime,'chflg')
	[lstimtime.chflg] = deal(true([chnum,1]));
      end
      for block =1:length(lstimtime) % Block Loop
	cdata2 = cdata(lstimtime(block).iniBlock: ...
		       lstimtime(block).finBlock, :);
	if ~exist('criterion','var') || ~isnumeric(criterion)
	  sz=size(cdata2); sz(1)=sz(1)-2;
	  chk_base = 3*std(cdata2, 0, 1);
	  chk_base = repmat(chk_base,sz(1),1);
	else
	  chk_base = criterion(1);
	end

	% Check if defference is begger than chk_base
	%  --(2*sampleperiod : ordinary 200msec) --
	chk = abs(cdata2(1:end-2,:) - cdata2(3:end  ,:));
	chkAns = chk > chk_base;
	chflg0 = any(chkAns,1);
	lstimtime(block).chflg(find(chflg0 ==1)) = false;

	if chflg0(ch)==1 % For Error Plot 
	  if lstimtime(block).iniStim == lstimtime(block).finStim
	    errorTime(end+1) = lstimtime(block).iniStim;
	  else
	    errorTime=[errorTime ...
		       linspace(lstimtime(block).iniStim, ...
				lstimtime(block).finStim, ...
				10)];
	  end
	end
      end
      stimData(stimkind).stimtime=lstimtime;
    end
  end  % HB kind
  stimInfo.StimData = stimData;


  if exist('axes_h','var')
    htmp = findobj(axes_h,'Tag', 'Motion Check Error Block');
    if ~isempty(htmp), delete(htmp); end;

	if  ~isempty(errorTime)
		ax0 = axis;
		errorTime=errorTime(:); 
		% unit change
		errorTime = errorTime./unit;
		height(1:length(errorTime)) = 0.05*ax0(4) + 0.95* ax0(3);
		htmp = plot(errorTime,height,'rx');
		set(htmp,'Tag', 'Motion Check Error Block');
	end  
  end
return;



