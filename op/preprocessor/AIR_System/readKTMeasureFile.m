function  [header,data]=readKTMeasureFile(filename,sdata) %#ok 
% Load AIR Files
%----------------------------------------------------
%   Syntax : 
%----------------------------------------------------
% [hdata,data]=readKTMeasureFile(mesfile,sdata)
%
%  hdata, data : P3 Continuous Data
%                  (format in SCRIPT_HIPOTX)
%  mesfile     : hiPOT-X : Measure-File
%  sdata       : hiPOT-X : Setting-File Inormation.
%                cf) readTKSettingFile


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
if strmatch('.ktMeasure ',ext)==1
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
  % -- read Header-parts
  fver=fread(fid,8,'*char')';
  fver=sprintf('%s',fver(1:7)); % Delete after \0
  confine_filepos(fid,8);
  switch fver
    case {'1.00.00', '1.00.00 '}
      % -- fixed value
      ch_sum=22*2;
      % Header
      keyword=fread(fid,16,'*char')';
      confine_filepos(fid,24);
      Endian=fread(fid,1,'long');
      
  
      % -- get data-size, and allocate
      if ~isfield(sdata,'num')
        one_data_len = 220;
        datasize = floor(finfo.bytes-28)/one_data_len;
      else
        datasize = sdata.num;
      end
  
      dataid   = zeros(datasize, 1);
      raw      = zeros(ch_sum, datasize);
      eraw     = zeros(2,datasize);
      stimkind = zeros(datasize, 1);
      timer0=repmat(' ',12,datasize);
      mpd      = zeros(16,datasize);
      
      p=28;
      % -- read Data-parts
      for id=1:datasize
        confine_filepos(fid,p);
        p = p+220;
        % get Data-Number
        dataid(id)  = fread(fid, 1, 'long');
        if dataid(id)==0
          %--------------------
          % Skip Loading
          %--------------------
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
          eraw(:,id) = fread(fid, 2, 'short');

          % get Mark-data
          stimkind(id)= fread(fid, 1, 'uint16');
          % get Reserve-data
          fseek(fid,2,0);
          mpd(:,id)=fread(fid, 16, 'short');
          fseek(fid,40,0); %Reserv A
          fseek(fid,28,0); %Reserv B
          fseek(fid, 8,0); %Reserv C
        end
      end
      
    otherwise % Version ??
      error(['Unknown Version : ' ver])
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
xxx=[...
  1    23     2    24     3    25     4    26     5 ...
  27     6    28     7    29     8    30     9    31 ...
  10    32    11    33    12    34    13    35    14 ...
  36    15    37    16    38    17    39    18    40 ...
  19    41    20    42    21    43    22    44];
raw = raw(:,xxx);
% Offset
of = bitget(stimkind,14);
prescantime= bitget(stimkind,12) | bitget(stimkind,11); % prescha-time
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
period      = measuretime/(datasize-1); % now : not used !! ( for debug)

%=================================
% --> Script File <--
%=================================
% Transform sdata, raw, (of) om, ss, se, (period)
% to  header,data
%  if you have data already rm raw !
SCRIPT_HIPOTX;
return;
