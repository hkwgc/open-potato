function data=readKT_csv_SettingFile(filename)
% Air Setting File


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



offs=0;

[fid,msg]=fopen(filename,'r');
if fid==-1, error(msg); end
fclose(fid); % file open check. afterward file will be read by textread().

% Read Version
[dum]=textread(filename,'%s',2,'headerlines',offs+1,'delimiter',',');
data.ver=dum{2};

ProbeIndex=[8 9 10 11 12 13 14 15];
GetGainIndex=[ProbeIndex*2-1 ProbeIndex*2];
try
  switch data.ver
    case '1.01.01'
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Version 1.01.01 Reader
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if 0
      data.key=[];
      data.Endian=[];
      end
      %-------------
      % FIRMWAREINFO
      %-------------
      [dum]=textread(filename,'%s',2,'headerlines',offs+2,'delimiter',',');
      data.FIRMWAREINFO.cCPCApp          =dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+3,'delimiter',',');
      data.FIRMWAREINFO.cCPUVersion      =dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+4,'delimiter',',');
      data.FIRMWAREINFO.cFPGAVersion     =dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+5,'delimiter',',');
      data.FIRMWAREINFO.cProbeFPGAVersion=dum{2};
      % hiPOT-X's MeasureMode
      %  0 : Stand-Alone
      %  1 : Wireless Monitor
      [dum]=textread(filename,'%s',2,'headerlines',offs+6,'delimiter',',');
      if(strcmpi(dum{2},'Wireless Monitor') )
        data.WOT_Mode=1;
      else
        data.WOT_Mode=0;
      end
      % ID of Control PC
      [dum]=textread(filename,'%s',2,'headerlines',offs+7,'delimiter',',');
      data.PCID=dum{2};
      % Comet ID
      %data.CometID=[];
      [dum]=textread(filename,'%s',2,'headerlines',offs+8,'delimiter',',');
      data.MeasureID=dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+9,'delimiter',',');
      data.MeasureName=dum{2};
      %-------------
      % User-Information
      %-------------
      [dum]=textread(filename,'%s',2,'headerlines',offs+11,'delimiter',',');
      data.USERINFO.cID=dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+12,'delimiter',',');
      data.USERINFO.cName=dum{2};
      [dum]=textread(filename,'%s',2,'headerlines',offs+13,'delimiter',',');
      data.USERINFO.cComment=dum{2};
      % Age
      [dum]=textread(filename,'%s',2,'headerlines',offs+14,'delimiter',',');
      data.USERINFO.cAge=dum{2};
      % 'None/Male/Female'
      [dum]=textread(filename,'%s',2,'headerlines',offs+15,'delimiter',',');
      data.USERINFO.cSex=dum{2};

      %--------------
      % HeadGearInfo : Setting
      %--------------
      [dum]=textread(filename,'%s',2,'headerlines',offs+21,'delimiter',',');
      if(strcmpi(dum{2},'X') )
          data.HEADGEARINFO.Setting.sMethodmPDDiv=0; % 'X'
      else
          data.HEADGEARINFO.Setting.sMethodmPDDiv=1; % 'O'
      end
      [dum]=textread(filename,'%s',2,'headerlines',offs+22,'delimiter',',');
      if(strcmpi(dum{2}(1:4),'Auto') )
          data.HEADGEARINFO.Setting.sMethodAPS=0; % 'Auto...'
      else
          data.HEADGEARINFO.Setting.sMethodAPS=1; % 'Always ...'
      end
      %data.HEADGEARINFO.Setting.sMethodGetRawData   =0; % set default
      %data.HEADGEARINFO.Setting.sMethodWarmUpLight  =0; % set default
      %data.HEADGEARINFO.Setting.sWarmUpTime  =0; % set default
      %data.HEADGEARINFO.Setting.sDummy1      =0; % set default
      if 0
      data.HEADGEARINFO.Setting.sLaserSetting=[];
      data.HEADGEARINFO.Setting.sLaserLightingOrder= ...
        [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sAGCMeasureCount =[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sAnalogThreshold =[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDigitalThreshold=[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDummy1          =[];
            data.HEADGEARINFO.Setting.ProbeGainSetting.sOverThreshold=[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sUnderThreshold  =[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sStrayThreshold  =[];
      data.HEADGEARINFO.Setting.ProbeGainSetting.sDummy2          =[];
      end

      [dum]=textread(filename,'%s',2,'headerlines',offs+20,'delimiter',',');
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.cProbeID=dum{2};
      
      [dum]=textread(filename,'%s',45,'headerlines',offs+34,'delimiter',',');
      val=SelectStrings2num(dum(2:45),GetGainIndex);
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerOff= ...
        reshape(val,[8,2]);
      [dum]=textread(filename,'%s',45,'headerlines',offs+35,'delimiter',',');
      val=SelectStrings2num(dum(2:45),GetGainIndex);
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerLow= ...
        reshape(val,[8,2]);
      [dum]=textread(filename,'%s',45,'headerlines',offs+36,'delimiter',',');
      val=SelectStrings2num(dum(2:45),GetGainIndex);
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.sLaserPowerHigh= ...
        reshape(val,[8,2]);
      if 0
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Po = 2600; % default
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL2Po = 1000; % default
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Vm = 1800; % default
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.lWL1Po = 1200; % default
      end
      [dum]=textread(filename,'%s',45,'headerlines',offs+30,'delimiter',',');
      val=GetKakkoValues(dum(2:45));
      val=val(GetGainIndex)*1000;
      
      data.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lLaserWaveLength = ...
        reshape(val,[8,2]);
      %data.HEADGEARINFO.Setting.ProbeIndividualSetting.ProbeLDWLSetting.lReserve1 = [];
      %----------------------
      % HeadGearInfo : State: not set below
      %----------------------
      % 0: Normal, 1: Error
      if 0
      data.HEADGEARINFO.State.sState=[];
      data.HEADGEARINFO.State.sErrorCode=[];
      end
      % 0: Noting, 1:2x8, 2:2x4x2
      [dum]=textread(filename,'%s',2,'headerlines',offs+19,'delimiter',',');
      if(findstr(dum{2},'2x8') )
          data.HEADGEARINFO.State.sProbeMode=1;
      else
          data.HEADGEARINFO.State.sProbeMode=0;
      end
      %----------------------
      % MeasureParameter
      %----------------------
      [dum]=textread(filename,'%s',2,'headerlines',offs+47,'delimiter',',');
      switch dum{2}
        case 'Stim'
          data.MEASUREPARAMETER.sMeasurementType=0;
        case 'Event'
          data.MEASUREPARAMETER.sMeasurementType=1;
        otherwise
          data.MEASUREPARAMETER.sMeasurementType=[];
      end

      if 0
      data.HEADGEARINFO.State.sWarmUpLight=[];
      % BreakDown LD
      data.HEADGEARINFO.State.schBreakdownLD=[];
      data.HEADGEARINFO.State.lGainAdjustmentState=[];
      % Gain AjustmentResult
      data.HEADGEARINFO.State.sGainAdjustmentResult=[];
      data.HEADGEARINFO.State.sAnalogGainAdjustment=[];
      data.HEADGEARINFO.State.lDigitalGainAdjustment=[];
      data.HEADGEARINFO.State.sDrivingLaserPower=[];
      data.HEADGEARINFO.State.sMPD=[];
      %----------------------
      % MeasureParameter
      %----------------------
      data.MEASUREPARAMETER.sMeasurementType=[];
      data.MEASUREPARAMETER.sReserve1       =[];

      
      % Stim
      data.MEASUREPARAMETER.Stim.lMeasureTime    = [];
      data.MEASUREPARAMETER.Stim.lPreScanSection = [];

      data.MEASUREPARAMETER.Stim.MarkSetting=[];

      % Event
      data.MEASUREPARAMETER.Event.lMeasureTime    = [];
      data.MEASUREPARAMETER.Event.lPreScanSection = [];

      data.MEASUREPARAMETER.Event.MarkSetting=[];
      
      end
      % External Input Setting
      if 0
      s=fread(fid,4,'short');
      data.MEASUREPARAMETER.ExternalInputSetting=struct(...
        'sMarkInType',s(1),...
        'sReserve1',s(2),...
        'sInputChanel',s(3),...
        'sInputJudgmentLogic',s(4),...
        'lThreshold',fread(fid,1,'long'));
      end
      %----------------------
      % Times
      %----------------------
      if 0
      data.cstime=[];
      data.cetime=[];
      data.num   =[];
      end
    otherwise
      error(['Unknown Version : ' ver])
  end
catch
  rethrow(lasterror);
end


function values = GetKakkoValues(string_array)
[row_size col_size] = size(string_array);
for i=1:1:row_size
    value = GetInKakko(string_array{i});
    values(i) = str2num(value);
end

function value = GetInKakko(string)
value=0;
first_idx=findstr(string,'(')+1;
last_idx =findstr(string,')')-1;
value=string(first_idx:last_idx);

function t = TransLasersetting(s)
[row_size col_size] = size(s);
average_val = mean(s);
for i=1:1:row_size
    for j=1:1:col_size
        if( s(i,j) <= 0 )
            t(i,j)=0;
        elseif( s(i,j) <= average_val )
            t(i,j)=1;
        else
            t(i,j)=2;
        end
    end
end
        
function values = SelectStrings2num(string_array,GetGainIndex)
[row_size col_size] = size(GetGainIndex);
for j=1:1:col_size
    values(j) = str2num(string_array{GetGainIndex(j)});
end
