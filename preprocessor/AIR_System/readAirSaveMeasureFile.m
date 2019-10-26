function  [header,data]=readAirSaveMeasureFile(filename,sdata)
% Load AIR Files
%----------------------------------------------------
%   Syntax : 
%----------------------------------------------------
% [hdata,data]=readAirSaveMeasureFile(mesfile,sdata)
%
%  hdata, data : P3 Continuous Data
%  mesfile     : Air-Measure-File
%  sdata       : Air-Setting-File Inormation.
%                cf) readAirSettingFile


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Read File & Make Continuous-Data.
[pathname, fname, ext] = fileparts(filename);
% Check Extension
if strcmpi(ext,{'.airMeasure'})==0,
  error('Air-Measure Mode : Extension Error');
end

% ====================================
% Read file,
% ====================================
% file open
finfo=dir(filename); % Get for Data-Size
[fid,message] = fopen(filename, 'r', 'l');
if fid == -1, error(message); end


try
  % -- fixed value
  ch_sum=56;
  % -- read Header-parts
  ver=fread(fid,8,'*char')';
  keyword=fread(fid,16,'*char')';
  
  % -- get data-size, and allocate
  one_data_len = 136;
  datasize = floor(finfo.bytes-24)/one_data_len;
  
  dataid   = zeros(datasize, 1);
  raw      = zeros(ch_sum, datasize);
  stimkind = zeros(datasize, 1);
  timer0=repmat(' ',12,datasize);
  
  % -- read Data-parts
 for id=1:datasize
    % get Data-Number
    dataid(id)  = fread(fid, 1, 'long');
    if dataid(id)==0,
      %--------------------
      % Skip Loading
      %--------------------
      fseek(fid,132,0);
      raw(:,id)   = NaN;
      %timer0(id)  = NaN;
      stimkind(id)= stimkind(id-1);
      warning('Broken Data Exist in %d',id);
    else
      %--------------------
      % Load One-Time Data
      %--------------------
      % get Raw-data
      raw(:,id)   = fread(fid, ch_sum, 'short');
      % get Time-data
      timer0(:,id)= fread(fid, 12, '*char');  %% HH:MM:SS
      % get external-analog-channel
      fseek(fid,4,0);
      % get Mark-data
      stimkind(id)= fread(fid, 1, 'uint16');
      % get Reserve-data
      fseek(fid,2,0);
    end
  end
catch
  fclose(fid);
  rethrow(lasterror);
end
fclose(fid);

%====================================
% Modify Reading Data
%====================================
% Transfer RAW-Data to Voltage.
xrate   = 6.5536e+3; % (-16384,16384) to (-2.5,2.5) V 
raw = raw./xrate;
raw = raw';
% Original-Mark (in AIR Format)
om = bitshift(bitand(stimkind,240),-4);
% Stimulation-Start
ss = bitget(stimkind, 10);
% Stimulation-End
se = bitget(stimkind,  9);
% Timer Modify
ts= datenum(timer0(:,1)');
te= datenum(timer0(:,end)') ;
timerange  =te-ts;
measuretime=timerange*24*60*60; % Date to sec
period      = measuretime/(datasize-1);

%============================================================
% Get Measure-Mode & Set Position
%  TODO : How to get Measure-Mode :: Mail at 25-Jan-2007
%============================================================
if 1
  % --> Remove unused Value.
  switch sdata.HEADGEARINFO.State.sProbeMode
    case 2
      % Select [2x4x2]
      header.measuremode = -1;
      header.Pos=air_getPosData;
      % omit 11-18ch
      raw(:,21:36)=[];
    case {1,3}
      % Select [2x8]
      header.measuremode = 201;
      % omit 1-3,26-28ch
      raw(:,51:end)=[];
      raw(:,1:6)=[];
    otherwise
      error('Undefined Probe Mode');
  end
else
  % Select [2x10]
  header.measuremode = 200;
  switch sdata.HEADGEARINFO.State.sProbeMode
    case 2
      % omit 11-18ch
      raw(:,21:36)=0;
    case {1,3}
      % omit 1-3,26-28ch
      raw(:,51:end)=0;
      raw(:,1:6)=0;
    otherwise
      error('Undefined Probe Mode');
  end
end

%====================================
% translate Voltage into HB-data.
%====================================
% Set Wave-Length
%  TODO : How to get Wave-Length :: Mail at 25-Jan-2007
ch_sum=size(raw,2);
wavelength=zeros(1, ch_sum);
wavelength(1,1:2:ch_sum)=...
  sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LlowWave/1000;
wavelength(1,2:2:ch_sum)=...
  sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LhighWave/1000;
% Translate (and omit Non-Measurement-Data from the calculations.)
data = osp_chbtrans(raw, wavelength);

%====================================
% set header
%====================================
% ----------
% set stim
% ----------
st_idx  = find(ss==1 & se==0);
end_idx = find(ss==0 & se==1);
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
header.StimMode = 2;    % =Block

%-----------
% set flag
%-----------
header.flag     = false([1, datasize, size(data,2)]);

%--------------------
% set sampling_period
%--------------------
if 0,
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
  tags.age=num2str(s(1):e(1))+...
    num2str(s(2):e(2))/12+...
    (7*num2str(s(3):e(3))+num2str(s(4):e(4)))/365;
  catch
    tags.age=0;
  end
else
  tags.age=sdata.USERINFO.cAge;
end
if strcmpi(sdata.USERINFO.cSex,'Male')
  tags.sex=0;
else
  tags.sex=1;
end
tags.subjectname = sdata.USERINFO.cName;
tags.comment     = sdata.USERINFO.cComment;%
tags.date        = datenum(timer0(:,1)');

% --> Setting Information
tags.AirInfo=sdata;
% Back-up Raw Data (if you want)
if 1, tags.data      = raw; end
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
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Innner Function for create Pos-Data of Probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos=air_getPosData
% Make Position-Data for AIR [2x4x2]
pos.ver=2;
gr_chnum=10;
% 
x = linspace(-60,-6,7);
y = linspace(61,25,3);
p=zeros(gr_chnum,2);
p(1:3:10,1) = x(1:2:7);
p(2:3:8 ,1) = x(2:2:6);
p(3:3:9 ,1) = x(2:2:6);
p(2:3:8 ,2) = y(1);
p(1:3:10,2) = y(2);
p(3:3:9 ,2) = y(3);
%pos=[pos; pos+60]; % set No.11-20ch(mesure data:19-28ch)
tp=p; tp(:,1)=p(:,1)+70;
p=[p; tp];     %%%%% 60:random
pos.D2.P=p;

% 3D Data
pos.D3.P=zeros(size(p,1),3);
pos.D3.Base.Nasion =[0 -100 0];
pos.D3.Base.LeftEar=[80 0 0];
pos.D3.Base.RightEar=[-80 0 0];

% Group
pos.Group.ChData    = {1:10, 11:20};
pos.Group.mode      = [202, 202];
pos.Group.OriginalCh= {1:10,1:10};


