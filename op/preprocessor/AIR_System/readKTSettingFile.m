function data=readKTSettingFile(filename)
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
confine_filepos(fid,8);
data.ver=my_sprintf('%s',ver(1:7)); % Delete after \0
try
  switch data.ver
    case '1.00.00'
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Version 1.0 Reader
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      data.key=my_sprintf('%s',fread(fid,16,'*char'));
      confine_filepos(fid,24);
      data.Endian=fread(fid,1,'long'); % This Keyword is not work now (Ver1.00)
      confine_filepos(fid,28);
      %-------------
      % FIRMWAREINFO
      %-------------
      data.FIRMWAREINFO.cCPUVersion      =my_sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,36);
      data.FIRMWAREINFO.cFPGAVersion     =my_sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,44);
      data.FIRMWAREINFO.cProbeFPGAVersion=my_sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,52);
      data.FIRMWAREINFO.cCPCApp          =my_sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,60);
      % ID of Control PC
      data.PCID=my_sprintf('%s',fread(fid,4,'*char'));
      confine_filepos(fid,64);
      % Comet ID
      data.CometID=fread(fid,1,'short');
      % hiPOT-X's MeasureMode
      %  0 : Stand-Alone
      %  1 : Wireless Monitor
      data.WOT_Mode=fread(fid,1,'short');
      data.MeasureID=my_sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,92);
      data.MeasureName=my_sprintf('%s',fread(fid,128,'*char'));
      confine_filepos(fid,220);
      %-------------
      % User-Information
      %-------------
      data.USERINFO.cID=my_sprintf('%s',fread(fid,32,'*char'));
      confine_filepos(fid,252);
      data.USERINFO.cName=my_sprintf('%s',fread(fid,32,'*char'));
      confine_filepos(fid,284);
      data.USERINFO.cComment=my_sprintf('%s',fread(fid,128,'*char'));
      confine_filepos(fid,412);
      % Age
      data.USERINFO.cAge=my_sprintf('%s',fread(fid,16,'*char'));
      confine_filepos(fid,428);
      % 'None/Male/Female'
      data.USERINFO.cSex=my_sprintf('%s',fread(fid,8,'*char'));
      confine_filepos(fid,436);
      %--------------
      % HeadGearInfo : Setting
      %--------------
      data.HEADGEARINFO.Setting.sMethodmPDDiv=fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sMethodAPS   =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sMethodGetRawData   =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sMethodWarmUpLight  =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sWarmUpTime  =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.sDummy1      =fread(fid,1,'short');

      s=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.sLaserSetting=s;
      data.HEADGEARINFO.Setting.sLaserLightingOrder=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sAGCMeasureCount =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sAnalogThreshold =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDigitalThreshold=fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDummy1          =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sOverThreshold   =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sUnderThreshold  =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sStrayThreshold  =fread(fid,1,'short');
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDummy2          =fread(fid,1,'short');

      confine_filepos(fid,528);
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.cProbeID  =my_sprintf('%s',fread(fid,32,'*char'));
      confine_filepos(fid,560);
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerOff=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerLow=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerHigh=fread(fid,16,'short');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Po = fread(fid,1,'long');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL2Po = fread(fid,1,'long');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Vm = fread(fid,1,'long');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Po = fread(fid,1,'long');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lLaserWaveLength =fread(fid,16,'long');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lReserve1 = fread(fid,1,'long');

      %----------------------
      % HeadGearInfo : State
      %----------------------
      % 0: Normal, 1: Error
      data.HEADGEARINFO.State.sState=fread(fid,1,'short');
      data.HEADGEARINFO.State.sErrorCode=fread(fid,1,'short');
      % 0: Noting, 1:2x8, 2:2x4x2
      data.HEADGEARINFO.State.sProbeMode=fread(fid,1,'short');
      data.HEADGEARINFO.State.sWarmUpLight=fread(fid,1,'short');
      % BreakDown LD
      s=fread(fid,16,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.schBreakdownLD=s;
      data.HEADGEARINFO.State.lGainAdjustmentState=fread(fid,1,'int');
      % Gain AjustmentResult
      s=fread(fid,44,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.sGainAdjustmentResult=s;
      s=fread(fid,44,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.sAnalogGainAdjustment=s;
      s=fread(fid,44,'long');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.lDigitalGainAdjustment=s;
      s=fread(fid,16,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.sDrivingLaserPower=s;
      s=fread(fid,16,'short');
      s=struct('SlowWave',num2cell(s(1:2:end-1)),...
        'ShighWave',num2cell(s(2:2:end)));
      data.HEADGEARINFO.State.sMPD=s;
      confine_filepos(fid,1200);
      
      %----------------------
      % MeasureParameter
      %----------------------
      data.MEASUREPARAMETER.sMeasurementType=fread(fid,1,'short');
      data.MEASUREPARAMETER.sReserve1       =fread(fid,1,'short');

      
      % Stim
      data.MEASUREPARAMETER.Stim.lMeasureTime    = fread(fid,1,'long');
      data.MEASUREPARAMETER.Stim.lPreScanSection = fread(fid,1,'long');

      clear s;
      s.sMarkInType=fread(fid,1,'short');
      s.sReserve1=fread(fid,1,'short');
      s.lWaitSection=fread(fid,1,'long');
      p=1220;
      confine_filepos(fid,p);
      for idx=1:10
        s.MarkClass(idx).cName=my_sprintf('%s',fread(fid,20,'*char'));
        confine_filepos(fid,p+20);
        s.MarkClass(idx).lStimSection=fread(fid,1,'int');
        s.MarkClass(idx).lNonStimSection=fread(fid,1,'int');
        p=p+28;
      end
      s.sMarkInOrder=fread(fid,10,'short');
      s.lRepeatCount=fread(fid,1,'long');
      s.SbeepOn=fread(fid,1,'short');
      s.sReserve2=fread(fid,1,'short');
      data.MEASUREPARAMETER.Stim.MarkSetting=s;

      % Event
      data.MEASUREPARAMETER.Event.lMeasureTime    = fread(fid,1,'long');
      data.MEASUREPARAMETER.Event.lPreScanSection = fread(fid,1,'long');

      clear s;
      s.sMarkInType=fread(fid,1,'short');
      s.sReserve1=fread(fid,1,'short');
      s.lWaitSection=fread(fid,1,'long');
      p=1544;
      confine_filepos(fid,p);
      for idx=1:10
        s.MarkClass(idx).cName=my_sprintf('%s',fread(fid,20,'*char'));
        confine_filepos(fid,p+20);
        s.MarkClass(idx).lStimSection=fread(fid,1,'int');
        s.MarkClass(idx).lNonStimSection=fread(fid,1,'int');
        p=p+28;
      end
      s.sMarkInOrder=fread(fid,10,'short');
      s.lRepeatCount=fread(fid,1,'long');
      s.SbeepOn=fread(fid,1,'short');
      s.sReserve2=fread(fid,1,'short');
      data.MEASUREPARAMETER.Event.MarkSetting=s;
      
      
      % External Input Setting
      s=fread(fid,4,'short');
      data.MEASUREPARAMETER.ExternalInputSetting=struct(...
        'sMarkInType',s(1),...
        'sReserve1',s(2),...
        'sInputChanel',s(3),...
        'sInputJudgmentLogic',s(4),...
        'lThreshold',fread(fid,1,'long'));
      %----------------------
      % Times
      %----------------------
      confine_filepos(fid,1864);
      data.cstime=my_sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,1888);
      data.cetime=my_sprintf('%s',fread(fid,24,'*char'));
      confine_filepos(fid,1912);
      data.num   =fread(fid,1,'long');
    otherwise
      error(['Unknown Version : ' ver])
  end
catch
  fclose(fid);
  rethrow(lasterror);
end

fclose(fid);

function s=my_sprintf(varargin)
%
s0=sprintf(varargin{:});
try
    % get str  before 0
    xx=find(s0==0);
    s=s0(1:xx(1)-1);
catch
    s=s0;
end
