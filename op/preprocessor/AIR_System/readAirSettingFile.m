function data=readAirSettingFile(filename)
% Air Setting File


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



[fid,msg]=fopen(filename,'r');
if fid==-1, error(msg); end

% Read Version
ver=fread(fid,8,'*char');
ver=ver(1:4);   % ADD 2014.04.23
confine_filepos(fid,8);
data.ver=sprintf('%s',ver); % Delete after \0
try
  switch data.ver
    case '1.00'
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Version 1.0 Reader
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      data.key=sprintf('%s',fread(fid,16,'*char'));
      confine_filepos(fid,24);
      %-------------
      % FIRMWAREINFO
      %-------------
      data.FIRMWAREINFO.cCPUVersion      =sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,32);
      data.FIRMWAREINFO.cFPGAVersion     =sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,40);
      data.FIRMWAREINFO.cProbeFPGAVersion=sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,48);
      % ID of Control PC
      data.PCID=sprintf('%s',fread(fid,4,'*char'));
      confine_filepos(fid,52);
      % Comet ID
      data.CometID=fread(fid,1,'short');
      % Air's MeasureMode
      %  0 : Stand-Alone
      %  1 : Wireless Control
      %  2 : Wireless Monitor
      data.AirMode=fread(fid,1,'short');
      data.MeasureID=sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,80);
      data.MeasureName=sprintf('%s',fread(fid,128,'*char'));
      confine_filepos(fid,208);
      %-------------
      % User-Information
      %-------------
      data.USERINFO.cID=sprintf('%s',fread(fid,32,'*char'));
      confine_filepos(fid,240);
      data.USERINFO.cName=sprintf('%s',fread(fid,32,'*char'));
      confine_filepos(fid,272);
      data.USERINFO.cComment=sprintf('%s',fread(fid,128,'*char'));
      confine_filepos(fid,400);
      % Age
      data.USERINFO.cAge=sprintf('%s',fread(fid,16,'*char'));
      confine_filepos(fid,416);
      % 'None/Male/Female'
      data.USERINFO.cSex=sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,424);
      %--------------
      % HeadGearInfo : Setting
      %--------------
      data.HEADGEARINFO.Setting.sLaserControlMethod=fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sThreshold=fread(fid,1,'short');
      s=fread(fid,16,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.Setting.schLaserSetting=s;
      data.HEADGEARINFO.Setting.sLaserLightingOrder=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.sSellectedMeasureCh=fread(fid,28,'short');
      % Dumy
      dumy=fread(fid,22,'short');
      data.HEADGEARINFO.Setting.sReserve1=dumy(end);
      % LaserPower
      % (C Language->MATLAB)
      s=fread(fid,48,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      s=reshape(s,3,8)';
      data.HEADGEARINFO.Setting.schLaserPower=s;
      dumy=fread(fid,1,'short'); if 0,disp(dumy);end% Dummy3
      data.HEADGEARINFO.Setting.sGainAdjustmentThreshold=fread(fid,1,'short');
      dumy=fread(fid,2,'short'); if 0,disp(dumy);end% Dummy4, 5
      data.HEADGEARINFO.Setting.lchLaserWaveLength.LlowWave=fread(fid,1,'int');
      data.HEADGEARINFO.Setting.lchLaserWaveLength.LhighWave=fread(fid,1,'int');
      data.HEADGEARINFO.Setting.lLaserWaveLengthDigit=fread(fid,1,'int');
      %----------------------
      % HeadGearInfo : State
      %----------------------
      % 0: Normal, 1: Error
      data.HEADGEARINFO.State.sState=fread(fid,1,'short');
      data.HEADGEARINFO.State.sErrorCode=fread(fid,1,'short');
      % 0: Noting, 1:2x8, 2:2x4x2
      data.HEADGEARINFO.State.sProbeMode=fread(fid,1,'short');
      dumy=fread(fid,1,'short'); if 0,disp(dumy);end % Dummy1
      % BreakDown LD
      s=fread(fid,16,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.schBreakdownLD=s;
      data.HEADGEARINFO.State.lGainAdjustmentState=fread(fid,1,'int');
      % Gain AjustmentResult
      s=fread(fid,56,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.schGainAdjustmentResult=s;
      % Analog Gain
      % (C Language->MATLAB)
      s=fread(fid,64,'short');
      % ==> modify
      s=s*100/31 +1;
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      s=reshape(s,4,8)';
      data.HEADGEARINFO.State.schAnalogGainAdjustment=s;
      % Soft-Gain
      s=fread(fid,56,'int');
      s=struct('LlowWave',num2cell(s(1:2:end-1)),...
        'LhighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.lchSoftGainAdustment=s;
      s=fread(fid,80,'short');
      % Laser Power to Current
      s(17:32)=s(17:32)*(29/16383);
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.schDrivingLaserPower=s(9:16);
      %----------------------
      % MeasureParameter
      %----------------------
      data.MEASUREPARAMETER.lMeasureTime=fread(fid,1,'int');
      data.MEASUREPARAMETER.lPreScanSectionTime=fread(fid,1,'int');
      % MarkSetting
      clear s;
      s.SmarkInType=fread(fid,1,'short');
      s.sReserve1=fread(fid,1,'short');
      s.LwaitSection=fread(fid,1,'int');
      p=1392;
      confine_filepos(fid,p);
      for idx=1:10
        s.MarkClass(idx).cName=sprintf('%s',fread(fid,20,'*char'));
        confine_filepos(fid,p+20);
        s.MarkClass(idx).lStimSection=fread(fid,1,'int');
        s.MarkClass(idx).lNonStimSection=fread(fid,1,'int');
        p=p+28;
      end
      s.sMarkInOrder=fread(fid,10,'short');
      s.lRepeatCount=fread(fid,1,'int');
      s.SbeepOn=fread(fid,1,'short');
      s.sReserve2=fread(fid,1,'short');
      data.MEASUREPARAMETER.MarkSetting=s;
      % External Input Setting
      s=fread(fid,4,'short');
      data.MEASUREPARAMETER.ExternalInputSetting=struct(...
        'sMarkInType',s(1),...
        'sReserve1',s(2),...
        'sInputChanel',s(3),...
        'sInputJudgmentLogic',s(4),...
        'lThreshold',fread(fid,1,'int'));
      %----------------------
      % Times
      %----------------------
      confine_filepos(fid,1712);
      data.cstime=sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,1736);
      data.cetime=sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,1760);
      data.num   =fread(fid,1,'int');
    otherwise
      error(['Unknown Version : ' ver])
  end
catch
  fclose(fid);
  rethrow(lasterror);
end

fclose(fid);
