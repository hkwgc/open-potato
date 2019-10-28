function [header, hs, cdata0,f0] = uc_motioncheck(data, hb_kind,header, ...
				 highpath, lowpath, ...
				 criterion, plot_mode, varargin)
% MOTIONCHECK detect Motion from OSP HB-Raw Data
%
% == Syntax ==
% header = uc_motioncheck(data, stimInfo, hb_kind, ...
%			       highpath, lowpath, ...
%			       criterion)
%   --- Input Data --
%   data   : 3 dimensional HB Data
%            time x channel x HB-Kind
%
%  HB Kind : Checking HB-Kind
%            Multipul Input is avairable, example 'hb_kid=[1:3]'
%
%  header   : header of data
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
%                      Warning!!
%                      In making SD, use all data.
%                      ordinal Motinocheck is use only block reasion.
%
%
% - -- Output Data --
%  header :  Changed header
%             If we detect motion at Channel in each block,
%             change Using Flag in stimInfo zero.
%
% == Syntax ==
% @since 1.4
% [header, hs] = uc_motioncheck(data, stimInfo, hb_kind, ...
%			        highpath, lowpath, ...
%			        criterion, plot_mode);
%    plot_mode<0 or not inputed : noplot
%    plot_mode=1 : viewer I
%    plot_mode=2 : viewer II
%    plot_mode=3 : veiwer II (no-plot make cdata only)
%
% Detecting Method : 
%   1. smothing by using Band-Path-Filter
%   2. Difference-Check 
%      nere time
%
% == Syntax ==
% @since 1.7
% [header, hs, cdata0, f0] = uc_motioncheck(data, stimInfo, hb_kind, ...
%			        highpath, lowpath, ...
%			        criterion, plot_mode, ...
%                   'PropertyName', PropertyValue, ....);
%
%  cdata : cell of Check-Data
%          cdata{hb_kind_idx}(time,channel);
%  f0    : Flags before Or-Operation.
%          f0{hb_kind_idx}(time,channel);
%
%  Propert-Name | Variable-Type| explain
%   filttype
%
%   Add More Properties.
%   
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
% $Id: uc_motioncheck.m 398 2014-03-31 04:36:46Z katura7pro $
%
% Reversion 1.4:
%   Add function : when there is plot_ch, plot result.
%
% Revision 1.5
%   Add Filter Type option


  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % ===== Initiarize =======
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %=========================
  % ===== Read Argument ====
  %=========================
  % Read Value
  msg=nargchk(6,20,nargin);
  if ~isempty(msg), error(msg);end
  % Read 1 to 6
  % sampling period
  smpl_pld = header.samplingperiod;
  chnum    = size(data,2);
  highpath = max(highpath(:));
  lowpath  = min(lowpath(:));
  % header.flag(:) = 0; % init % comment out 04-Jul-2005
  plot_kind = hb_kind;
  hs=[]; cdata0={}; f0={};

  % Plot Mode
  if nargin<7,
    plot_mode=0; % Plot Option : False(Default)
  end
  if isempty(plot_mode), plot_mode=0;end
  % handles 2: handle for plot..
  if plot_mode==1,header2 = header;end    
  if plot_mode==2,plot_ch=1;end
  % Plot TIme
  ptime=1:size(data,1);
  ptime = (ptime-1) * (smpl_pld(1)/1000);
  ptime = ptime';

  % Set Default Value of Filter - Type
  if exist('butter','file'),
    filttype='butter';
  else,
    filttype='bandpass2';
    if 0,
      % Now Change ..
      warndlg(...
	  sprintf('%s\n\t%s\n',...
		  'No butter worth : ''butter''', ...
		  'So Use FFT'),' Debug Mode');
    end
  end
  
  % set (Diff -Check Interval)
  %
  dcinterval=2;

  % Set Optional Data
  for idx=2:2:length(varargin),
      % Property Name ?
      if ~ischar(varargin{idx-1}),
          warning('Bad Property Name');
          continue;
      end
      % Property Name Switch
      switch lower(varargin{idx-1})
          case 'filttype',
              tmp=varargin{idx};
              if iscell(tmp),tmp=tmp{1};end
              if ~ischar(tmp),
                  warning('Bad Value for FilterType');continue;
              end
              ftstr={'none','butter','bandpass2'};
              s=find(strcmpi(ftstr,varargin{idx}));
              if ~isempty(s),
                  filttype=ftstr{s(1)};
              else,
                  warning('Bad Value for FilterType');
              end
              
          case 'dcinterval',
              dcinterval=varargin{idx};
              if length(dcinterval)~=1,
                  warning('Diff-Check-Intervalu must be 1');
              end
              dcinterval=round(dcinterval(1));
              if dcinterval<1,
                  error('Too small Different');
              end
              if size(data,1)<=dcinterval,
                  error('Too large Diff-Check-Interval');
              end
          case 'plot_ch',
              % Plot Channel for plot_mode==2
              plot_ch=varargin{idx};
          otherwise,
              warning(['No such a Property : ' varargin{idx}]);
      end % Property Name Switch
  end % Read Argument

  % Data Check Interval...
  sdci = 1+ceil(dcinterval/2);
  edci = size(data,1) - floor(dcinterval/2);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ===== Motion Check ==========
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  sz=size(data);
  cdata = zeros(sz(1:2));
  % --- Data - Kind Loop ----
  for ahbkind = hb_kind  % Loop hbkind
    
    % Initiarize 
    cdata = data(:,:,ahbkind);

    %======================================
    % ========== Data Filtering ===========
    %======================================
    switch filttype,
     case 'butter',
      % === Preprocessing : Butter worth Distal Filtering ===
      [b,a]=ot_butter(highpath(1), lowpath(1), ...
		      1000/smpl_pld, 5,'bpf');%Use 5 degree
      cdata=ot_filtfilt(cdata, a , b, 1);
     case 'bandpass2',
      % === Preprocessing : FFT Filtering ===
      cdata = ot_bandpass2(cdata, highpath, lowpath, ...
			   1, smpl_pld/1000, 1,'time');
     case 'none',
      % === Preprocessing : No Filtering ===
     otherwise,
      % Never Occure..
      error('No such a Filter Type!');
    end

    if plot_mode==1,
      data(:,:,end+1)=cdata;
      header2.TAGs.DataTag{end+1} = ...
	  [header2.TAGs.DataTag{ahbkind} 'CheckData'];
      plot_kind(end+1)=size(data,3);
    elseif plot_mode==2,
      hs(end+1)=plot(ptime,cdata(:,plot_ch)');
      set(hs(end),'Color',[0.8 ,0.8 ,0.8], ...
		  'Tag', 'Filterd-Data');
    end
    % for out put 
    if nargout>=3,cdata0{end+1}=cdata; end

    % ===== Start Motion Check =====
    errorTime=[];
    if ~exist('criterion','var') || ~isnumeric(criterion)
      sz=size(cdata); sz(1)=sz(1)-dcinterval;
      sigma    = std(cdata, 0, 1);
      chk_base = eval(criterion); % Modified! since 1.5
      if isequal(size(chk_base),size(sigma)),
          chk_base = repmat(chk_base,sz(1),1);
      else,
          chk_base=chk_base(1);
      end
    else
      chk_base = criterion(1);
    end

    % Check if defference is bigger than chk_base
    %  --(2*sampleperiod : ordinary 200msec) --
    chk = abs(cdata(1:end-dcinterval,:) - ...
        cdata(dcinterval+1:end  ,:));
    chkAns = chk > chk_base;
    % for out put 
    if nargout>=4,f0{end+1}=chkAns; end
    flg_tmp = squeeze(header.flag(1,sdci:edci,:));
    header.flag(1, sdci:edci, :)  = chkAns | flg_tmp;
  end  % HB kind

  if plot_mode==1 && ~isempty(plot_kind),
    h=uc_plot_data(header2,data,'PlotKind', plot_kind);
    nm = fieldnames(h);
    idx0= strmatch('axes_ch', nm);
    x=linspace(0, size(data,1)*header2.samplingperiod/1000, size(data,1))';
    for idx=idx0',
      cid = str2num(nm{idx}(8:end));
      axes(getfield(h,nm{idx}));
      x2 = x(find(header.flag(1,:,cid)));
      hx=plot(x2, repmat(0,size(x2)),'rx');
      set(hx,'Tag','Motion Exist');
    end
    set(h.figure1,'Name', 'MotionCheck Result', ...
		  'NumberTitle','off');	  
    hs=h;
  end
  
  if plot_mode==2 && ~isempty(plot_kind),
    c=hsv(max(plot_kind(:)));
    c(1,:)=[1, 0, 0];
    c(2,:)=[0, 0, 1];
    c(3,:)=[0, 0, 0];
    c(find(c<0.5))=0.5;
    for hbkind=plot_kind(:)',
      hs(end+1)=plot(ptime,data(:,plot_ch,hbkind)');
      set(hs(end),'Color',c(hbkind,:), ...
		  'Tag', header.TAGs.DataTag{hbkind});
      x=find(header.flag(1,:,plot_ch)==1);
      if ~isempty(x)
          hs(end+1)=plot(ptime(x),zeros(size(x)),'rx');
          set(hs(end),'Tag','Motion Exist');
      end
    end
  end
  
return;



