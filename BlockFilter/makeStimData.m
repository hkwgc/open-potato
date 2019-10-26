function [stimInfo, ecode] =makeStimData(stim0, mode, period)
% Make OSP Stimulation Information from ETG stimulation data
%
% Syntax :
%  [stimInfo, ecode] =makeStimDataFcn(stim, mode, period)
%
% -- Input --
%  stim    : ETG stimulation data
%            stim is vector, that length is size(HB-Data,1)
%
%  mode    :  Stimulation mode (1: Event , 2: Block )
%
%  period  :  Relaxing Time of Aroun Stimulation
%
% -- Output --
%  stimInfo : OSP Stimulation Information
%
%  ecode    : bit 1 : Nunber of Sets Error
%             bit 2 : Block StimKind is differ
%                     Remove Some Data-Sets


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Initialize
  ecode=0;   % Continuable Error
  stimInfo=[];
  stim= stim0;

  %================
  % Setup Argument
  %================
  if nargin==0
    % = Get Test  Data =
    warning('stimDataFcn : Use TestData');
    load('stimtest.mat','stim');
  end

  % Mode ( Stimulation Type  )
  if nargin<2
    mode=1;    % Stimulating Mode (1: Event , 2: Block )
  end

  if nargin<3
    st = 10;    % in real <- use stimperiod & So on
    ed = 15;    % in real <- use stimperiod & So on
  else
    st = period(1);
    ed = period(2);
  end

  % ========= Make Essence Data ===========
  stim=stim(:);     % Confine Vector
  stim=[[1:length(stim)]' stim];
  idxmax=stim(end,1);

  % Remove 0 Data
  stim(find(stim(:,2)==0),:)=[];

  % ========= CHECK SET-CHECK ===========
  if mode == 2  % Block Data
    % Number of Data Check
    if bitget(size(stim,1),1)==1
      stim(end,:)=[]; 
      ecode = bitset(ecode,1); % Ecode = 1
    end
    npair0 = diff(stim(:,2));   % Different StimKind Check
    npair0(2:2:size(npair0,1))=0; % Ignore neborhoot Block
    npair0 = find(npair0~=0);   % Find Different Kind Set Block
    if ~isempty(npair0)
      npair0 = [npair0; npair0+1];
      stim_1=stim;
      stim(npair0(:),:)=[]; 
      ecode = bitset(ecode,2); % Ecode = bit 2 is 1
    end
    
    if ecode~= 0
      warning(' Stimulation Pair Error : Delete Some Pairs');
      OSP_LOG('warn', { 'Stimulation Pair Error :',  ...
			'   Ignore those Pairs.'});

      if bitget(ecode,2)
	%   Print Ignore Data
	npair0 = sort(npair0);
	figure; 
	ax_h = axes;
	hold on;grid on;
	h = plot(stim0,'b-');
	set(h,'Tag', 'Original Stimulation Point', ...
	      'LineWidth', 0.1);
	h = plot(stim_1(npair0,1), stim_1(npair0,2),'rx');
	set(h,'Tag', ' Ignore Stimulation Point', ...
	      'MarkerSize', 7);
	legend(ax_h, ...
	       ' Original Stimulation Point', ...
	       ' Ignore Stimulation Point');
	title('  ---- Ignore Stimulation Data ----  ');
	xlabel(' Stimulation Timing [ sampling-time-unit]');
	ylabel(' Stimulation Kind');
	clear stim_1;
      end
    end
    clear npair0;

  end

  clear stim0;

  if isempty(stim)
    OSP_LOG('err', ...
	    [' Cannot make Stimulation Data.' ...
	     '     No Stimulation exist!']);
    error(' Cannot make Stimulation Data : No Stimulation exist!');
  end

  % ========== Make Stimdata =============
  stimData=struct([]); sd_id=0;
  while ~isempty(stim)
    stimkind=stim(1,2);                        %  Loop for stimKind
    wrk0=find( stim(:,2)==stimkind);
    wrk =stim(wrk0,:);   % StimKind Position 

    % Condition of Break
    stim(wrk0,:)=[];
    
    sd_id=sd_id+1;
    stimData(sd_id).kind  = stimkind;
    
    % Set Start ID
    if mode == 2  % Block Data
      id0=0;
      for id=2:2:size(wrk,1)
	id0=id0+1;
	stimStruct(id0) = struct(...
	    'iniBlock', wrk(id-1,1) -st , ...
	    'iniStim' , wrk(id-1,1),      ...
	    'finStim' , wrk(id  ,1),      ...
	    'finBlock', wrk(id  ,1) +ed   );
	if stimStruct(id0).iniBlock<=0
	  stimStruct(id0).iniBlock=1;
	end
	if stimStruct(id0).finBlock > idxmax
	  stimStruct(id0).finBlock =idxmax;
	end
      end
        
    elseif mode == 1 % Event Data

      for id=1:size(wrk,1)
	stimStruct(id) = struct(...
	    'iniBlock', wrk(id,1) -st , ...
	    'iniStim' , wrk(id,1),      ...
	    'finStim' , wrk(id,1),      ...
	    'finBlock', wrk(id,1) +ed   );
	if stimStruct(id).iniBlock<=0
	  stimStruct(id).iniBlock=1;
	end
	if stimStruct(id).finBlock > idxmax
	  stimStruct(id).finBlock =idxmax;
	end
      end
    end
    
    stimData(sd_id).stimtime=stimStruct;
    clear stimStruct;
  end

  %================
  % make stim
  %================


  % Stimulation Information
  stimInfo.preStim  = round(st);
  stimInfo.postStim = round(ed);
  stimInfo.type     = round(mode);
  stimInfo.StimData = stimData;  




