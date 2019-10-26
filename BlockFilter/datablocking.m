function varargout = datablocking(mode, varargin)
% OSP : Group Data to Block Data
%
% [relax]                   = datablocking('getMinRelax', groupdatalist)
% [prestim, poststim]       = datablocking('getMinRelax', groupdatalist)
% [prestim, poststim, unit] = datablocking('getMinRelax', groupdatalist)
%    Minimum of Relaxing Time in GroupDataList
%     groupdatalist is Structure array of GroupData Structure
%     prestim, poststim is Minimum of Filtering Stimulation Timing
%     For Analyzing Blocking-Data must be smaller than the period.
%     Because if filter range is in the Blocking-Data, Blocking-Data
%     might have un-expected noncontinuous data point.
%
% strctMultiBlock = datablocking('getMultiStrctBlock', ...
%                                         groupdatalist, relax)
%    Make structure of Multi Blocking HBdata from GroupDataList
%     groupdatalist is Structure array of GroupData Structure
%     relax is vector  [prestim poststim], smaller than the result
%     of datablocking('getMinRelax', groupdatalist)
%
% [MultiBlock, blockkind, tag, astimtimes,measuremode ] = ...
%              datablocking('getMultiBlock', groupdatalist, relax)
%    MultiBlock is Bloked HBdata, 4-dimensions in the array Multi-Block
%       Meaning of each dimensions is Block, Time, Chanel, and
%       HBkind, respectively.
%       Data that out-of-time-range or unused channel is NaN.
%    blockkind is vector of Stimulation Kind of Block 
%    tag is HBkind tag of last-effective-block
%    astimtimes is Stimulation-Timing of Each-block.
%       If astimtimes of same kind block is same.
%
% StrctBlck = datablocking('getSingleStrctBlck', ...
%                          data, groupdata)
% StrctBlck = datablocking('getSingleStrctBlck', ...
%                          data, stimInfo)
%   Warning !! This Function is not Filter!!
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% author : Masanori Shoji
% $Id: datablocking.m 180 2011-05-19 09:34:28Z Katura $
%
% This function will be removing soon.
%
%

  warning([ mfilename ' will be removing soon.']);

  try
    switch mode

      % ---------------
     case 'getMinRelax'
      groupdatalist = varargin{1};
      [prestim, poststim, unit] = getMinRelax(groupdatalist);
      if nargout==1
	varargout{1} = [prestim, poststim];
      elseif nargout==2
	varargout{1} = prestim;
	varargout{2} = poststim;
      elseif nargout==3
	varargout{1} = prestim;
	varargout{2} = poststim;
	varargout{3} = unit;
      end
      return;

      case 'getMultiStrctBlock'
       groupdatalist = varargin{1};
       relax = varargin{2};
       strctMultiBlock = getMultiStrctBlock(groupdatalist, relax);
       varargout{1} = strctMultiBlock;
       return;

      % ---------------
     case 'getMultiBlock'
       groupdatalist = varargin{1};
       relax = varargin{2};
       [MultiBlock, blockkind, tag, astimtimes, measuremode] = ...
	   getMultiBlock(groupdatalist, relax);
       varargout{1} = MultiBlock;
       if nargout>=2
	 varargout{2} = blockkind;
       end
       if nargout>=3
	 varargout{3} = tag;
       end
       if nargout>=4
	 varargout{4} = astimtimes;
       end
       if nargout>=5
	 varargout{5} = measuremode;
       end
	 
      % ---------------
     case 'getSingleStrctBlck'
      HBdata    = varargin{1};
      if nargin == 3
	groupdata = varargin{2};
	stim        = groupdata.stim;
      else
	stim        = varargin{2};
      end

      StrctBlck    = getSingleStrctBlck(HBdata, stim);
      varargout{1} = StrctBlck;
      return;

  otherwise,
       error(['unknow 1st argument ' mode]);
    end

  catch
    OSP_LOG('err',lasterr);
    rethrow(lasterror);
  end

return;

function [preStim, postStim, unit] = getMinRelax(groupDatalist, filtdata)
%---------------------------------------------
% Get Minimum Relaxing Time Around Stimulation
%                    of Moving Average, Filter
% This Function is use for 'getMinRelax'
%---------------------------------------------

  preStim = Inf; postStim=Inf;

  if isfield(groupDatalist, 'Tag')
    groupDatalist = groupDatalist.data;
  end

  for groupdata = groupDatalist

    % Filtering Setting 
    filtdatam    = groupdata.filterdata;
    try
        % Too slow --> change data structure ...
        tmpkey.filename = groupdata.name;
        header=DataDef_SignalPreprocessor('load',tmpkey);
        unit         = 1000/header.sampleperiod;
        clear header tmpkey;
	catch
	  unit         = 10;
    end
    % * Check LocalFitting Relaxing Time Around Stimulation
    if isfield(filtdatam,'BlockData')
      filtdata = filtdatam.BlockData;
      if ~isempty(filtdata)
	[names{1:length(filtdata)}] = deal(filtdata.name);
	id = find(strcmp(names,'LocalFitting'));
	for idx = id,    % M id is empty or a few
	  data0 = filtdata(idx).argData;
	  if ~isfield(data0,'preStim'), continue; end
	  preStim  = min([preStim,  data0.RelaxPre  * unit]);
	  postStim = min([postStim, data0.RelaxPost * unit]);
	end
      end
    end

    % * Motion Check Stimulation
    motion_argData = groupdata.motioncheck;
    if ~isempty(motion_argData)
      preStim  = min([preStim,  motion_argData.PreStim ]);
      postStim = min([postStim, motion_argData.PostStim]);
    end
    
  end
  
  % initial value: 0
  % if you want to plot all area,
  %   not to change preStim and postStim
  %   (change "if 1" to "if 0").
  if 1
    if isinf(preStim),preStim=0;end
    if isinf(postStim), postStim=0; end
  end
return;  


function strctMultiBlock = getMultiStrctBlock(groupdatalist, relax)

  strctMultiBlock = struct('name', 'unknown', ...
			   'chnum', 0, ...
			   'hbkindnum', 0, ...
			   'maxblock', 0, ...
			   'sampleperiod', 0, ...
			   'data', struct([]));
			   
  if isfield(groupdatalist, 'Tag')
    groupdatalist = groupdatalist.data;
  end

  sbmid = 1;   % Struct Block Name
  % Main Data
  for gdl = groupdatalist
    strctMultiBlock(sbmid).name  = gdl.name;
   
    % Load HBData
    tmpkey.filename = gdl.name;
    [header,data]=DataDef_SignalPreprocessor('load',tmpkey);
    HBdata       = data;
    HBTag        = header.TAGs.DataTag;
    sampleperiod = header.sampleperiod;
    measuremode  = header.measuremode;
    clear data header;
    
    % plotkind2(end+1) = size(HBdata,3);
    strctMultiBlock(sbmid).blocknum      = 0;
    strctMultiBlock(sbmid).maxblock      = 0;
    strctMultiBlock(sbmid).chnum         = size(HBdata,2);
    strctMultiBlock(sbmid).hbkindnum     = size(HBdata,3);
    strctMultiBlock(sbmid).hbkindtag     = HBTag;
    strctMultiBlock(sbmid).sampleperiod  = sampleperiod;
    strctMultiBlock(sbmid).measuremode   = measuremode;
    

    % HBdata Filter
    [HBdata, stim] = OspFilterMain(HBdata, gdl.stim, ...
				   gdl.filterdata,'HBdata');
    clear stim;
    gdl.stim = changeStimData('Relaxing', gdl.stim, ...
			      relax(1), relax(2), ...
			      size(HBdata,1));

    % Blocking Filter
    strctBlck = struct('kind',1, ...
		       'PreStim', 0, ...
		       'PostStim', 0, ...
		       'data',  struct([]));
    sbid = 1;
    for aStimData = gdl.stim.StimData
      strctBlck(sbid).PreStim  =  gdl.stim.preStim;
      strctBlck(sbid).PostStim =  gdl.stim.postStim;
      strctBlck(sbid).kind     =  aStimData.kind;

      strctBlck(sbid).stim_period = [-Inf, Inf];
      strctBlck(sbid).data = struct('block',[0], ...
				    'ch', [], ...
				    'stimini', struct([]), ...
				    'iniStim', 0, ...
				    'finStim', 0);
      blkid = 1;
      for aStimTime = aStimData.stimtime
	if any(aStimTime.chflg)==0, continue; end;

	ch = find(aStimTime.chflg);
	
	tmpdata = HBdata(:,ch,:);
	% Block Data Filter
	if isfield(gdl.filterdata, 'BlockData')
	  filt_area=[Inf Inf];
	  block_area(1) = aStimTime.iniStim  - aStimTime.iniBlock;
	  block_area(2) = aStimTime.finBlock - aStimTime.finStim;
	  for filtdata = gdl.filterdata.BlockData
	    if isfield(filtdata.argData,'RelaxPre')
	      % Warning for discontinuous
	      if filt_area(1) <  filtdata.argData.RelaxPre || ...
		    filt_area(2) <  filtdata.argData.RelaxPost,
		warning([ filtdata.name ...
			  ' : Filter to discontinuous Data!']);
	      else
		% Renewal : Fitting Aera 
		ldata = OSP_DATA('GET','OSP_LocalData');
		smpl_pld=ldata.info.sampleperiod; clear ldata; % [msec/ 1 point]
		filt_area(1) =  round(filtdata.argData.RelaxPre *1000/smpl_pld);
		filt_area(2) =  round(filtdata.argData.RelaxPost*1000/smpl_pld);
	      end
	      tmpdata = feval(filtdata.wrap, 'exe', ...
			      'BlockData', ...
			      filtdata, tmpdata, aStimTime);
	    else
	      % Renewal : Fitting Aera 
	      filt_area =  block_area;
	      tmpdata(aStimTime.iniBlock:aStimTime.finBlock,:,:) = ...
		  feval(filtdata.wrap, 'exe', ...
			'BlockData', ...
			filtdata, ...
			tmpdata(aStimTime.iniBlock: ...
				aStimTime.finBlock,:,:));
	    end
	    % Warning for discontinuous
	    if any(filt_area <  block_area)
	      disp(filt_area);disp(block_area);
	      warning([ filtdata.name ...
			' : Filter to discontinuous Data, and Rest' ...
			' indifferentiable data.']);
	    end
	  end  % Filter Loop
	end % End of Filter

	% Add to Block Data
	tmpblock.block   = tmpdata(aStimTime.iniBlock: ...
				   aStimTime.finBlock,:,:);
	tmpblock.ch      = ch;
	tmpblock.stimini = aStimTime;
	tmpblock.iniStim = aStimTime.iniStim-aStimTime.iniBlock+1;
	tmpblock.finStim = aStimTime.finStim-aStimTime.iniBlock+1;

	% -- Kind Block Change
	stim_period = tmpblock.finStim - tmpblock.iniStim;
	if strctBlck(sbid).stim_period(1) < stim_period
	  strctBlck(sbid).stim_period(1) = stim_period;
	end
	if strctBlck(sbid).stim_period(2) > stim_period
	  strctBlck(sbid).stim_period(2) = stim_period;
	end

	strctBlck(sbid).data(blkid) = tmpblock;

	% -- Block Data-info
	if size(tmpblock.block,1) > strctMultiBlock(sbmid).maxblock
	  strctMultiBlock(sbmid).maxblock =size(tmpblock.block,1);
	end
	strctMultiBlock(sbmid).blocknum      = ...
	    strctMultiBlock(sbmid).blocknum +1;

	blkid = blkid + 1; 
      end % End of Block Loop

      chk_StimDiffCheck(strctBlck(sbid).stim_period);

      if blkid ~=1
	sbid = sbid+1;
      end
    end % End of StimKind Loop
    
    % Data Add
    if sbid ~= 1
      strctMultiBlock(sbmid).data  = strctBlck;
      sbmid = sbmid +1;
    end
  end  % End of Group List Loop

  if sbmid == 1, % no Output Data
    strctMultiBlock=struct([]);
  end
return;

function [MultiBlock, blockkind, tag, astimtimes, measuremode]= getMultiBlock(groupdatalist, relax)

  % ==== Make Structure ====
  MultiBlock=[]; blockkind=[]; tag={}; 
  astimtimes = struct('iniBlock' , 0 , ...
		      'iniStim'  , 0 , ...
		      'finStim'  , 0, ...
		      'finBlock' , 0, ...
		      'chflg'    , true);

  strctMultiBlock = getMultiStrctBlock(groupdatalist, relax);
  if isempty(strctMultiBlock),
    return;
  end

  sizeOfStrctMultiBlock; % get block size


  % === Check Block Size ===
  preStim     = strctMultiBlock(1).data(1).PreStim;
  measuremode = strctMultiBlock(1).measuremode;
  stim_period = [];
  for fblock = strctMultiBlock,    % Loop of File

    if measuremode ~= fblock.measuremode,
      error('Measure Mode is different');
    end

    for kblock = fblock.data,           % Loop of Stim Kind

      % Check Relaxing time of Pre-Stimulation Time
      if preStim ~= kblock.PreStim
	% Never occur
	OSP_LOG('perr','Relaxing Time of Gruoping Data is different');
	error('Relaxing Time of Gruoping Data is different');
      end
      
      stim_period(end+1,:) = [kblock.kind, kblock.stim_period];
    end
  end
  % Stimulation Period Check
  while ~isempty(stim_period)
    tmp1 = find(stim_period(1) == stim_period(:,1));
    tmpperiod(1) = max(stim_period(tmp1, 2));
    tmpperiod(2) = min(stim_period(tmp1, 3));
    chk_StimDiffCheck(tmpperiod);
    stim_period(tmp1, :) = [];
  end
  clear tmp1 tmpperiod stim_period;


  % === mallock ===
  blockkind      = zeros(blocksize(1),1);
  MultiBlock     = zeros(blocksize);
  MultiBlock(:)  = NaN;
  id = 1; 
  tag =cell(1,blocksize(4));
  % == Make Block ==
  for fblock = strctMultiBlock,    % Loop of File
    [tag{1:fblock.hbkindnum}] = ...
	deal(fblock.hbkindtag{:});
    for kblock = fblock.data,      % Loop of Stim Kind
      for block = kblock.data,     % Loop of Block
	% Output Area ( Adjust Block )
	outarea = (preStim+1) - block.iniStim +1;
	area_ch(2,:) = 1:size(block.block,1);
	if ~isinf(outarea)
	  area_ch(1,:) = outarea:size(block.block,1)+outarea-1;
	else
	  area_ch(1,:) = area_ch(2,:);
	end

	ow = find( area_ch(1, :) > blocksize(2) );
	if ~isempty(ow)
	  if length(ow)>10
	    figure
	    hold on
	    axis([0 area_ch(2,end) 0 3])
	    plot(area_ch(1,:)',1,'r')
	    plot(area_ch(2,:)',2,'b')
	    plot(block.iniStim,2.1, 'bo')
	    plot(block.finStim,2.1, 'bx')
	    plot(preStim, 1.1, 'ro')
	    plot([1; 1; NaN; blocksize(2); blocksize(2)],[0; 3; NaN; 0; 3],'g-')            
	  end
	  area_ch(:,ow) =[];
	end
	
	blockkind(id)   = kblock.kind; 
	chtmp           = false([ 1,blocksize(3)]);
	chtmp(block.ch) = true;
	astimtimes(id)  = struct('iniBlock' , 1       , ...
				 'iniStim'  , preStim , ...
				 'finStim'  , round(preStim + mean(kblock.stim_period)), ...
				 'finBlock' , blocksize(2), ...
				 'chflg'    , chtmp);
	
	MultiBlock(id, area_ch(1,:), block.ch, 1:fblock.hbkindnum) = ...
	    block.block(area_ch(2,:), :, :);
	id = id+1;
	clear area_ch;
      end % end of Block Loop

    end % end of Stim Kind Loop
  end % end of File Loop

  
return;

  
function strctBlck = getSingleStrctBlck(HBdata, stim)
%---------------------------------------------
% Get Block Data by Cell, No Filter
%---------------------------------------------
  
  % define of Struct Block
  strctBlck = struct('kind',1, ...
		     'PreStim', 0, ...
		     'PostStim', 0, ...
		     'data',  struct([]));

  id        = 1;
  chnum     = size(HBdata,2);
  hbkindnum = size(HBdata,3);
  

  for stimknd = 1:length(stim.StimData)
    strctBlck(id).PreStim  =  stim.preStim;
    strctBlck(id).PostStim =  stim.postStim;
    strctBlck(id).kind     =  stim.StimData(stimknd).kind;

    strctBlck(id).data = struct('block',[0], ...
				 'stimini', struct([]), ...
				 'iniStim', 0, ...
				 'finStim', 0);

    aStimData = stim.StimData(stimknd);
    for blkid = 1: length(aStimData.stimtime)
      astimtime = aStimData.stimtime(blkid);

      % useless channel is Nan
      ch = find(astimtime.chflg);
      data.block =  ...
	  zeros([ astimtime.finBlock-astimtime.iniBlock+1, ...
		  chnum, hbkindnum]);
      data.block(:) = NaN;

      data.block(:, ch, :) = ...
	  HBdata(astimtime.iniBlock: astimtime.finBlock, ch, :);
      data.stimini = astimtime;
      data.iniStim = astimtime.iniStim  - astimtime.iniBlock+1;
      data.finStim = astimtime.finStim  - astimtime.iniBlock+1;
      
      strctBlck(id).data(blkid) = data;
      
    end % Stim Time
  end % Stim Kind
  
return;
  

function chk_StimDiffCheck(stim_period);
  if diff(stim_period) < -3
    disp(stim_period);
    error(' Difference of Stimulation Period is larger than 3');
  end
return;
