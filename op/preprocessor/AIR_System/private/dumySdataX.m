function sdata=dumySdataX()
% Dumy Data
sdata.HEADGEARINFO.State.sProbeMode=1;
%sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LlowWave =791000;
%sdata.HEADGEARINFO.Setting.lchLaserWaveLength.LhighWave=850000;
sdata.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lLaserWaveLength=...
  repmat([754000 830000],[8,1]);
%  repmat([705000 830000],[8,1]);
sdata.USERINFO.cID ='dumy';
sdata.USERINFO.cAge='00y00m00';
sdata.USERINFO.cSex='None';
sdata.USERINFO.cName='someone';
sdata.USERINFO.cComment='No Comment';
sdata.MEASUREPARAMETER.sMeasurementType = 1; % Event Mode

