function [bdata, bheader] = uc_blocking(data, header, prestim, ...
  poststim, stimkind)
% Make Block-Time-Data from Continuous-Data. Last-Modify : POTATo 3.1.6
%
% Styntax :
%  [data, header] = uc_blocking(data, header, prestim, poststim, stimkind)
%
% -- Input Data --
%  data     : Continuous Data, 3D-matrix for (time, channel, kind)
%  header   : Continuous Header Data.
%  prestim  : Pre-Stimulation Time.   [sec]
%  poststim : Post-Stimulation Time.  [sec]
%  stimkind : Using Stimulation Kind.
%             If no input, [1:10].
%
% -- Output Data --
%  data     : Block Data, 4D-matrix for
%             (Block, time, channel, kind)
%             Warning!! Block include NaN for overfllow, or
%                       Underfllow.
%                       There is some function taht
%                       interpret, or ignore NaN.
%                       That is NAN_FCN, ...
%  header   : Blcok  Header Data.
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.04.14
% $Id: uc_blocking.m 398 2014-03-31 04:36:46Z katura7pro $
%

% Revision 1.5
%   Apply Adding Position Data
%
% Revision 1.7
%   Add StimTC2
%
% Revision 1.8
%    Change : OSP_STIMPERIOD_DIFF_LIMIT :
%
% Revision 1.9
%    Bug fix : Insert File-Separation: See also mail
%
% Revision 1.10
%    Add TimeSeries
%
% Revision 1.11
%    Bug fix : 061116B
%
% Revision 1.14
%   stimkind : auto is acsept
%
% Revision 1.16 : P3.1.6
%    implicit bug fix.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg = nargchk(4,5,nargin);
if ~isempty(msg), error(msg);end
%-------------------------
% Default Stimulation I/O
%-------------------------
if nargin <= 4, stimkind='auto';  end

%-------------------------
% Check Argument Type,
%  and Change Argument type, if we can.
%-------------------------
if ~iscell(data), data={data}; end
if ~iscell(header), header={header}; end

%-------------------------
% Pair check (data, header)
%-------------------------
if length(data)~=length(header)
  error('[E] Data & header size is different.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intialize Header of Block Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
header1 = header{1};
sz=size(data{1});
bheader.stim           = [1 1];
bheader.stimTC         = zeros(1,10);
bheader.stimTC2        = []; % Old StimData Copy
bheader.stimkind       = 1;
bheader.flag           = zeros(size(header1.flag,1),0,sz(2));
bheader.measuremode    = header1.measuremode;
bheader.samplingperiod = header1.samplingperiod;
bheader.TAGs           = [];
if isfield(header1,'Pos'),
  bheader.Pos          = header1.Pos;
end
if isfield(header1,'BlockInfo')
	bheader.BlockInfo = header1.BlockInfo;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consistent Check ,
%   Each-Continuous-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=====================================
% initialize Working Variable for Check
%=====================================
stimperiod =[];      % Stimulation Period

%====================================
%  Load Each Continuous Data
%====================================
for id=1:length(header)
  % Load Continuous-Data
  dt =data{id};
  hd = header{id};

  %-----------------------------------
  % Sampling Period
  %
  % Block-Time-Data's Samplingperiod is
  %  Greatest Common Divisor of Continuous-Data's one.
  %-----------------------------------
  bheader.samplingperiod = ...
    gcd(hd.samplingperiod, bheader.samplingperiod);

  %-----------------------------------
  % Check Measure Mode is Same?
  %-----------------------------------
  if bheader.measuremode ~= hd.measuremode,
    error(...
      ['[E] Measure Mode is difference.\n',...
      '    %s \t: %d\n',...
      '    %s \t: %d\n'],...
      bheader.TAGs.filename{1},bheader.measuremode,...
      hd.TAGs.filename,hd.measuremode);
  end

  %-----------------------------------
  % Channel Number is Same?
  %-----------------------------------
  if sz(2) ~= size(dt,2),
    error(...
      ['[E] Channel size is difference.\n',...
      '    %s \t: %d\n',...
      '    %s \t: %d\n'],...
      bheader.TAGs.filename{1},sz(2),...
      hd.TAGs.filename,size(dt));
  end

  %-----------------------------------
  % Data-Kind :
  %
  % Block-Time-Data's  Number of Data-Kind
  %  is Maximum.
  %-----------------------------------
  if sz(3) < size(dt,3),sz(3) =  size(dt,3);end

  %-----------------------------------
  % Modification TAGs
  %-----------------------------------
  % Add TAGs ( and simplify)
  bheader.TAGs = addTags(bheader.TAGs, hd.TAGs);

  %-----------------------------------
  % Check  Simulation Period Check
  %-----------------------------------
  stim = hd.stim;
  % unit transfer, m sec
  stim(:,[2 3]) = stim(:,[2 3]) * hd.samplingperiod;
  stimperiod = [stimperiod; stim];
  
  %-----------------------------------
  % Add Results
  %  Bugfix : 070720A 
  %-----------------------------------
  if isfield(hd,'Results')
    if ~isfield(bheader,'Results')
      bheader.Results=hd.Results;
    else
      fd=fieldnames(hd.Results);
      for irfd=1:length(fd)
        if ~isfield(bheader.Results,fd{irfd})
          % New
          bheader.Results.(fd{irfd}) = hd.Results.(fd{irfd});
        else
          % make cell.
          %  if you wan to overwirte, delete above "if statement"
          if ~iscell(bheader.Results.(fd{irfd}))
            bheader.Results.(fd{irfd})={bheader.Results.(fd{irfd})};
          end
          bheader.Results.(fd{irfd}){end+1}= hd.Results.(fd{irfd});
        end
      end % for
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking Stimulation (Marks)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================
% Kind filter
% BUG 061116B :
%=========================
if isnumeric(stimkind)
  block_stim_enable=false(size(stimperiod,1),1);
  for sk = stimkind(:)',
    block_stim_enable(sk==stimperiod(:,1))=true;
  end
  stimperiod(block_stim_enable==false, :) = [];
  clear sk;
else
  if ~any(strcmpi({'auto','all'},stimkind))
    warndlg({'Inproper Stim-Kind : Used Stim-Kind is ''all'''},'Blocking');
  end
  stimkind=unique(stimperiod(:,1));
end

% -- save kind --
bheader.stimkind = stimperiod(:,1);
stimperiod(:,1)=[];

%===========================
% Check Block-Time-Size
%===========================
% get difference of stimulation period.
stimperiod=diff(stimperiod,1,2);
% check and max use. (unit : m sec)

% stimulation timing is more than "OSP_STIMPERIOD_DIFF_LIMIT" [m sec]
if isempty(stimperiod),
  error('No Effective Data Exist');
end
if min(stimperiod)<0 || ...
    (max(stimperiod) - min(stimperiod))>OSP_STIMPERIOD_DIFF_LIMIT
  error(['[E] Stimulation Period vary a great deal.\n', ...
    '    Max is %6.3f [sec]\n', ...
    '    Min is %6.3f [sec]\n'], ...
    max(stimperiod)/1000,min(stimperiod)/1000);
end
stimperiod = max(stimperiod);

%============================
% Transfer Unit of Time
%============================
% unit transform : millisecond to sampringperiod-unit
% ( round may be not useful, because new sampling period is
%   result of GCD)
stimperiod = round(stimperiod/bheader.samplingperiod)+1;

% unit transform : sec to sampringperiod-unit
prestim  = round((prestim  * 1000)/bheader.samplingperiod);
poststim = round((poststim * 1000)/bheader.samplingperiod);

%============================
% Make New Block-Time-Data
%============================
%---------------
% Allocate
%---------------
% Data
bdata=zeros(size(bheader.stimkind,1), ...
  prestim + stimperiod + poststim, ...
  sz(2), ...
  sz(3));
bdata(:)=NaN; % default value

% Continuous Stimulation Point
% old stim
bheader.stimTC2    = zeros(size(bdata,1),size(bdata,2));
bheader.stimTC2(:) = NaN; % default value

%--------------------------------
% Set Fixed Value of Stimulation
%--------------------------------
bheader.stim   = [prestim+1,prestim+stimperiod];
bheader.stimTC = zeros(1,size(bdata,2));
bheader.stimTC(bheader.stim) = 1;

% Debug Print....
if 0
  fprintf([' Unit     : %5d [msec]\n'...
    ' Prestim  : %5d [unit] \n' ...
    ' StimTime : %5d [unit]\n' ...
    ' Poststim : %5d [unit]\n'], ...
    bheader.samplingperiod, prestim, stimperiod, poststim);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Blocking!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ======== Blocking ==============
blkid=1;
% Add->2006.07.24 : Original-File-ID of blocks
bheader.TAGs.FileIdOfBlock=zeros(1,size(bdata,1));
% Add->2006.07.24 : Bock-ID in the Original-File
bheader.TAGs.BlockIdOfFile=cell(1,length(header));
for id=1:length(header)
  dt =data{id};
  hd = header{id};

  % unit transform
  sz_0       = size(dt);
  prestim_0  = round(prestim  * bheader.samplingperiod/hd.samplingperiod);
  %poststim_0 = round(poststim * bheader.samplingperiod/hd.samplingperiod);

  tmp_unit = hd.samplingperiod/bheader.samplingperiod;
  tmp_pos = 1:tmp_unit:size(bdata,2);
  blkidbk = [];
  for blkid0=1:size(hd.stim,1),
    stim_0 = hd.stim(blkid0,:);
    if ~any(stim_0(1)==stimkind)
      continue;
    end
    stim_0(1) = [];

    % get range
    % stim_1 = stim_0 + [-prestim_0, poststim_0]+1;
    stim_1(1) = stim_0(1) -prestim_0;
    stim_1(2) = stim_1(1) + size(tmp_pos,2) -1;

    if stim_1(1)<1, 
			stim_1(1)=1; 
			P3_WarningMessage(10001);
		end
    if stim_1(2)>sz_0(1), 
			stim_1(2)=sz_0(1); 
			P3_WarningMessage(10002);
		end

    get_pos = stim_1(1):stim_1(2);
    inp_pos = get_pos - (stim_0(1)-bheader.stim(1)/tmp_unit);
    inp_pos(inp_pos<1)=1;
    inp_pos(inp_pos>size(tmp_pos,2))= size(tmp_pos,2);
    inp_pos = tmp_pos(inp_pos);

    %==========================================
    % Time Series Data Transfer
    %==========================================
    % Data
    blkidbk(end+1)=blkid;
    kindsize=size(dt,3);
    bdata(blkid,inp_pos,:,1:kindsize)         = dt(get_pos,:,:);
    bheader.TAGs.FileIdOfBlock(blkid)= id;

    % stimTC2 : since 1.7
    try
      bheader.stimTC2(blkid, inp_pos) = hd.stimTC(get_pos);
    catch
      % Error : not mind..
    end

    % TimeSeries : since 1.10
    if isfield(hd,'TimeSeries'),
      % TimeSeries Field Loop
      tsd=fieldnames(hd.TimeSeries);
      for itsd=1:length(tsd),
        mydata=hd.TimeSeries.(tsd{itsd});
        % Error Message ::
        emsg0={['Continuous ID : ' num2str(id)], ...
          ['Field : ' tsd{itsd}]};

        % In a format?
        if ~isstruct(mydata) || ...
            ~isfield(mydata,'Data') || ...
            ~isfield(mydata,'TimeAxis'),
          msg={'OSP Warning : Ignore Following Time-Series ', ...
            emsg0{:}, ...
            ' :: OUT-OF-FORMAT in this version'};
          warndlg(msg);
          continue;
        end
        if length(mydata.TimeAxis)~=1,
          errordlg({'OSP Error : Ignore Following Time-Series ', ...
            emsg0{:}, ...
            ' :: Too many Time-Axis :: '});
          continue;
        end

        % Set Data
        try
          % Data Size
          sz1=size(mydata.Data);
          sz1(mydata.TimeAxis)=length(get_pos);
          if mydata.TimeAxis > length(sz1) || ...
              mydata.TimeAxis <=0,
            errordlg({'OSP Error : Ignore Following Time-Series ', ...
              emsg0{:}, ...
              ' :: Time-Axis : Out of range.'});
            continue;
          end

          % Blocked Data
          if isfield(bheader,'TimeSeries') && ...
              isfield(bheader.TimeSeries,tsd{itsd}),
            % Read Exist Block-Time-Series (Field)
            bts=bheader.TimeSeries.(tsd{itsd});
          else
            % New TimeSeries Field of Block (Field)
            bts.Data     = zeros([0 sz1]);
            bts.TimeAxis = mydata.TimeAxis+1;
            if isfield(mydata,'AxisTag'),
              bts.AxisTag={'Block', mydata.AxisTag{:}};
            end
            % Block ID correnpond to data
            bts.BlockID  = [];
          end

          % Confine Axis Tag
          if isfield(mydata,'AxisTag')
            if isfield(bts,'AxisTag') && ...
                (length(bts.AxisTag)-1) ~= ...
                length(mydata.AxisTag),
              errordlg({ 'OSP Error : ', emsg0{:}, ...
                ' inconsistency in Axis-Tag'});
              continue;
            end
            if ~isfield(bts,'AxisTag'),
              bts.TimeAxis={'Block', mydata.AxisTag{:}};
            end
          end

          % Data Size String
          expstr1='end+1,';
          expstr2='';
          for szidx=1:length(sz1),
            if mydata.TimeAxis==szidx,
              expstr1=[expstr1 'inp_pos,'];
              expstr2=[expstr2 'get_pos,'];
            else
              expstr1=[expstr1 ':,'];
              expstr2=[expstr2 ':,'];
            end
          end
          expstr1(end)=[];
          expstr2(end)=[];

          evalstr = ['bts.Data(', expstr1 , ') = ', ...
            'mydata.Data(', expstr2, ');'];
          eval(evalstr);
          bts.BlockID(end+1)=blkid;
          if isfield(bheader,'TimeSeries'),
            bheader.TimeSeries.(tsd{itsd})=bts;
          else
            bheader.TimeSeries=struct(tsd{itsd},bts);
          end

        catch % Set Data ( Catch )
          msg = {' OSP Error :', emsg0{:}, lasterr};
          errordlg(msg);
        end % end of tyr-catch : Set Data
      end  % TimeSeries Field Loop
    end % TimeSeries Setting
    blkid=blkid+1;

    flag = hd.flag(:,get_pos,:); % kind, time , channel

    % kind 1 : motion check
    %          if exist motion, true
    % --> in block, if exist motion, true
    %     mean any
    flag = any(flag,2);
    size(flag);
    bheader.flag(:,end+1,:)  = flag;
  end
  bheader.TAGs.BlockIdOfFile{id}=blkidbk(:)';
end
return;

%----------------------------------------
function blocktags = addTags(blocktags, tags)
% The function addTags add BlockTAGs to TAGs.
%
% BLOCKTAGS is TAGs of Header of Block-Data.
%   If BLOCKTAGS is Null, new blocktags.
% TAGS is TAGs of Header of Continuos-Data.
%   If TAGS is Null, do nothing.
%
% TAG is data include ETG files original data.
%   TAGS is using as Plot-Label, Data Identifier, and so on.
%
% author : Masanori Shoji
% create : 2005.04.29

if isempty(tags), return; end
if isempty(tags.age) || ischar(tags.age)
  tags.age=0;
end
if isempty(tags.sex) || ischar(tags.sex)
  tags.sex=0;
end

if isempty(blocktags)
  % Initializing
  clear blocktags;
  % filename -> fullpath
  if isfield(tags,'pathname')
    if strcmp(tags.pathname(end),filesep),
      blocktags.filename  = {[tags.pathname tags.filename]}; % Cell
    else
      blocktags.filename  = {[tags.pathname filesep tags.filename]}; % Cell
    end
  else
    blocktags.filename  = {tags.filename}; % Cell
  end
  blocktags.ID_number = {tags.ID_number}; % Cell
  blocktags.age       = tags.age; % Matrix
  blocktags.sex       = tags.sex; % Matrix
  blocktags.DataTag   = tags.DataTag;  % Cell ( add )
else
  blocktags.filename{end+1}  = [tags.pathname tags.filename];
  blocktags.ID_number{end+1} = tags.ID_number;
  blocktags.age(end+1)       = tags.age;
  blocktags.sex(end+1)       = tags.sex;
  % tag set
  %deflen =  - length(blocktags.DataTag);
  for id = 1:length(blocktags.DataTag);
    % Break if no data-kind
    if length(tags.DataTag)<id,break;end
    
    if ~strcmp(blocktags.DataTag{id}, tags.DataTag{id}),
      if isempty(blocktags.DataTag{id}),
        blocktags.DataTag{id}=tags.DataTag{id};
      elseif ~isempty(tags.DataTag{id}),
        error([' Data Kind of ' tags.filename ...
          ' is not equal to another one.']);
      end
    end
  end
  for id1 = length(blocktags.DataTag)+1:length(tags.DataTag)
    blocktags.DataTag{id1} = tags.DataTag{id1};
  end
end
return;
