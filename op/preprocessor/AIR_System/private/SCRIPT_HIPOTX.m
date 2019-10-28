% Back-up Raw Data (if you want)
if exist('raw','var')
  tags.data      = raw;
  %====================================
  % translate Voltage into HB-data.
  %====================================
  % Set Wave-Length
  %  TODO : How to get Wave-Length :: Mail at 25-Jan-2007
  ch_sum=size(raw,2);
  wavelength=zeros(1, ch_sum);
  s=sdata.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lLaserWaveLength;
  s=reshape(s,[8,2]);
  %ld2ch=[1 3 3 5 5 7 7 1 2 3 4 5 6 7 8 2 2 4 4 6 6 8];
  ld2ch=[1 1 2 2 3 2 3 3 4 4 5 4 5 5 6 6 7 6 7 7 8 8];
  wavelength(1,1:2:ch_sum)=s(ld2ch,1)/1000;
  wavelength(1,2:2:ch_sum)=s(ld2ch,2)/1000;
  % Translate (and omit Non-Measurement-Data from the calculations.)
  data = p3_chbtrans(raw, wavelength,prescantime);
end


%============================================================
% Get Measure-Mode & Set Position
%============================================================
% --> Remove unused Value.
switch sdata.HEADGEARINFO.State.sProbeMode
  case {1,3}
    % Select [2x8]
    header.measuremode = 201;
  otherwise
    error('Undefined Probe Mode');
end

%====================================
% set header
%====================================
% set stimMode
stimmode=2; % =Stim
try
  if sdata.MEASUREPARAMETER.sMeasurementType==1
    stimmode=1; % Event
  end
catch
end
% ----------
% set stim
% ----------
if (stimmode==2)
  st_idx  = find(ss==1 & se==0);
  end_idx = find(ss==0 & se==1);
else
  st_idx  = find(ss==1);
  end_idx = find(se==1);
  if isempty(end_idx)
    end_idx=st_idx;
  end
end
bls_num = length(st_idx);ble_num = length(end_idx);
if (bls_num ~= ble_num),
  bls_num = min(bls_num,ble_num);
  st_idx = st_idx(1:bls_num);
  end_idx= end_idx(1:bls_num);
  warning('Unclosed Mark Exist!');
end

stim      = zeros(bls_num, 3);
if bls_num~=0
  tmp=st_idx>end_idx;
  if any(tmp(:))
    % Not Maching start-end
    error('Mark-data is blocken.');
  end
  stim(:,1) = om(st_idx);
  stim(:,2) = st_idx;
  stim(:,3) = end_idx;
end
header.stim   = stim;
% set stimTC
header.stimTC = zeros(1,length(om));
header.stimTC(st_idx)=om(st_idx);
header.stimTC(end_idx)=om(end_idx);
% set stimMode
header.StimMode = stimmode;

%-----------
% set flag
%-----------
header.flag     = false([1, datasize, size(data,2)]);

%--------------------
% set sampling_period
%--------------------
if 0,
  % TEST of Sampling Period
  header.samplingperiod =round(period*1000); % msec
else
  header.samplingperiod =200; % msec
end

%-----------
% set TAGs
%-----------
tags.DataTag     = {'Oxy','Deoxy','Total'};
tags.filename    = [fname ext];
tags.pathname    = pathname;
tags.ID_number   = sdata.USERINFO.cID;
% Bugfix:2008.04.04
if ischar(sdata.USERINFO.cAge)
  [s,e]=regexp(sdata.USERINFO.cAge,'[0-9]+');
  try
  tags.age=str2double(s(1):e(1))+...
    str2double(s(2):e(2))/12+...
    (7*str2double(s(3):e(3))+str2double(s(4):e(4)))/365;
  catch
    try
      % for WOT?
      tags.age=str2double(sdata.USERINFO.cAge(s(1):e(1)));
    catch
      tags.age=0;
    end
  end
else
  tags.age=sdata.USERINFO.cAge;
end
if strcmpi(sdata.USERINFO.cSex,'Male')
  tags.sex=0;
elseif strcmpi(sdata.USERINFO.cSex,'Female')
  tags.sex=1;
else
	tags.sex=[];
end
tags.subjectname = sdata.USERINFO.cName;
tags.comment     = sdata.USERINFO.cComment;%
try
  tags.date        = datenum(sdata.cstime,'yyyy/mm/dd HH:MM:SS');
catch
  tags.date        = datenum(timer0(:,1)');
end

% --> Setting Information
tags.WOTInfo=sdata;

header.TAGs = tags;

%-----------
% Add : Member-Information
%-----------
MemberInfo = struct( ...
  'stim', ['Stimulation Data, ' ...
  '(Number of Stimulation, ' ...
  '[kind, start, end])'], ...
  'stimTC', ['Stimulation Timeing, ' ...
  '(1, time)'], ...
  'StimMode', ['Stimulation Mode, ' ...
  '1:Event, 2:Block'], ...
  'flag',  ['Flags, (kind, time, ch),  ' ...
  ' Now kind is only one, if 1, then Motion occur'], ...
  'measuremode', ' Measure Mode of ETG', ...
  'samplingperiod', 'sampling period [msec]', ...
  'TAGs', 'Other Data', ...
  'MemberInfo', 'This Data, Header fields Information');
header.MemberInfo = MemberInfo;

% test-data for debug
% [h, strplotdata]=uc_plot_data(header,data1,'PlotChannel',[1:20]);
% [psn]=time_axes_position(header,[0.9 0.9], [0.05 0.05]);
