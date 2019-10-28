function [bdata, bheader] = uc_joinblock(data, header, prestim, ...
  poststim, stimkind)
% Make Block-Time-Data from Cell-Block-Time-Data.
%
% Styntax :
%  [data, header] = uc_joinblock(data, header, prestim, poststim, stimkind)
%
% -- Input Data --
%  data     : Cell-Block Data, cell of 4D-matrix (block, ime, channel, kind)
%  header   : Cell-Block Header Data.
%  prestim  : Pre-Stimulation Time.   [sec] (min)
%  poststim : Post-Stimulation Time.  [sec] (min)
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
% $Id: uc_joinblock.m 305 2013-02-01 06:11:44Z Katura $
%

% Revision 1.1
%   @since P3.1.6

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
bheader = header{1};
sz      = size(data{1});
bheader.stimkind       = [];
bheader.TAGs           = [];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consistent Check ,
%   Each-Continuous-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=====================================
% initialize Working Variable for Check
%=====================================
stimperiod =[];      % Stimulation Period
betime     =Inf;     % Block End Time
%====================================
%  Load Each Continuous Data
%====================================
for id=1:length(header)
  % Load Block-Data
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
    error('[E] Measure Mode is difference.');
  end

  %-----------------------------------
  % Channel Number is Same?
  %-----------------------------------
  if sz(3) ~= size(dt,3),
    error('[E] Channel size is difference.');
  end

  %-----------------------------------
  % Data-Kind :
  %
  % Block-Time-Data's  Number of Data-Kind
  %  is Maximum.
  %-----------------------------------
  if sz(4) < size(dt,4),sz(4) =  size(dt,4);end

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
  stim = stim * hd.samplingperiod;
  stimperiod = [stimperiod; stim];
  betime    =min(betime,hd.samplingperiod*(size(dt,2)-hd.stim(2)));
  % -- save kind --
  bheader.stimkind = [bheader.stimkind;hd.stimkind];

  
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
            %bheader.Results.(fd{irfd})={bheader.Results.(fd{irfd})};
						bheader.Results.(fd{irfd})=cell(0);
          end
          bheader.Results.(fd{irfd}){end+1}= hd.Results.(fd{irfd});
        end
      end
    end
  end
end

if isempty(stimperiod),
  error('No Effective Data Exist');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking Stimulation (Marks)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================
% Kind filter
% BUG 061116B :
%=========================
if isnumeric(stimkind)
  stimkind=unique(stimkind);
  % Bugfix : 071217C
  block_stim_enable=false(size(bheader.stimkind));
  for sk = stimkind(:)',
    block_stim_enable(sk==bheader.stimkind)=true;
  end
  bheader.stimkind(block_stim_enable==false, :) = [];
  clear sk;
else
  if ~any(strcmpi({'auto','all'},stimkind))
    warndlg({'Inproper Stim-Kind : Used Stim-Kind is ''all'''},'Blocking');
  end
  stimkind=unique(bheader.stimkind);
end
      
%===========================
% Check Block-Time-Size
%===========================
stimdiff=stimperiod(:,2)-stimperiod(:,1);
% Task Start-Time
tstime=min(max(stimperiod(:,1)),prestim*1000);
% Task End-Time
tetime=tstime+max(stimdiff);
betime0=min(betime,poststim*1000);
betime=tetime+betime0;

% check and max use. (unit : m sec)

% stimulation timing is more than "OSP_STIMPERIOD_DIFF_LIMIT" [m sec]
if (max(stimdiff) - min(stimdiff))>OSP_STIMPERIOD_DIFF_LIMIT
  error(['[E] Stimulation Period vary a great deal.\n', ...
    '    Max is %6.3f [sec]\n', ...
    '    Min is %6.3f [sec]\n'], ...
    max(stimdiff)/1000,min(stimdiff)/1000);
end

%============================
% Transfer Unit of Time
%============================
% unit transform : millisecond to sampringperiod-unit
% ( round may be not useful, because new sampling period is
%   result of GCD)
stimperiod = round(stimperiod/bheader.samplingperiod);

% unit transform : sec to sampringperiod-unit
prestim  = round((prestim  * 1000)/bheader.samplingperiod);
poststim = round((poststim * 1000)/bheader.samplingperiod);
mytime   = round([tstime,tetime,betime]/bheader.samplingperiod);
mytime   = mytime+[1 1 2];

%============================
% Make New Block-Time-Data
%============================
%---------------
% Allocate
%---------------
% Data
if 0
  % Release 14 -->
  bdata=NaN(length(bheader.stimkind), ...
    mytime(end),...
    sz(3), ...
    sz(4));
else
  bdata=zeros(length(bheader.stimkind), ...
    mytime(end),...
    sz(3), ...
    sz(4));
  bdata(:)=NaN;
end

% Continuous Stimulation Point
% old stim
if 0
  bheader.stimTC2    = NaN(size(bdata,1),size(bdata,2));
else
  bheader.stimTC2    = zeros(size(bdata,1),size(bdata,2));
  bheader.stimTC2(:) = NaN;
end

%--------------------------------
% Set Fixed Value of Stimulation
%--------------------------------
bheader.stim   = mytime(1:2);
bheader.stimTC = zeros(1,size(bdata,2));
bheader.stimTC(bheader.stim) = 1;
bheader.flag   = false([1,size(bdata,1),size(bdata,3)]);

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
  for blkid0=1:length(hd.stimkind)
    stim_0 = hd.stimkind(blkid0,:);
    if ~any(stim_0(1)==stimkind)
      continue;
    end
    stim_0 = hd.stim;

    % get range
    % stim_1 = stim_0 + [-prestim_0, poststim_0]+1;
    stim_1(1) = stim_0(1) -prestim_0;
    stim_1(2) = stim_1(1) + size(tmp_pos,2) -1;

    if stim_1(1)<1, stim_1(1)=1; end
    if stim_1(2)>sz_0(2), stim_1(2)=sz_0(2); end

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
    bdata(blkid,inp_pos,:,:)         = dt(blkid0,get_pos,:,:);
    bheader.TAGs.FileIdOfBlock(blkid)= id;

    % stimTC2 : since 1.7
    try
      bheader.stimTC2(blkid, inp_pos) = hd.stimTC2(blkid0,get_pos);
    catch
      % Error : not mind..
    end

    % TimeSeries : 
    if isfield(hd,'TimeSeries'),
      warning('Time Seriese Data is not support now');
    end % TimeSeries Setting
    bheader.flag(1,blkid,:)  = sum(hd.flag(:,blkid0,:),1);
    blkid=blkid+1;
  end
  bheader.TAGs.BlockIdOfFile{id}=blkidbk(:)';
end
return;

%----------------------------------------
function blocktags = addTags(blocktags, tags)
% The function join add BlockTAGs to TAGs.
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

if isempty(blocktags)
  % copy!
  blocktags = tags;
  blocktags.FileIdOfBlock  = [];
  blocktags.BlockIdOfFile  = [];
else
  blocktags.filename  = {blocktags.filename{:}  tags.filename{:}};
  blocktags.ID_number = {blocktags.ID_number{:} tags.ID_number{:}};
  blocktags.age       = [blocktags.age(:)' tags.age(:)'];
  blocktags.sex       = [blocktags.sex(:)' tags.sex(:)'];
  % tag set
  %deflen =  - length(blocktags.DataTag);
  for id = 1:length(blocktags.DataTag);
    if ~strcmp(blocktags.DataTag{id}, tags.DataTag{id}),
      error([' Data Kind of ' tags.filename ...
        ' is not equal to another one.']);
    end
  end
  for id1 = length(blocktags.DataTag)+1:length(tags.DataTag)
    blocktags.DataTag{id1} = tags.DataTag{id1};
  end
end
return;
