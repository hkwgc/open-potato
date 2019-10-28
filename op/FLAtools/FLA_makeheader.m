function header=FLA_makeheader(hdata,data,fnc,wrap)
% Make Header of First-Level-Analysis Data.
% This function pick up Default 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Header to Data....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4, wrap = eval(['@' fnc]);end
% Input by DataDef2_1stLevelAnalysis: 
% (only initialize)
header.name        = ''; 
header.ID          = 0; 
header.localID     = 0;
% => Here
header.function    = fnc;
header.wrapper     = wrap;
header.filename    = hdata.TAGs.filename;
header.ID_number   = hdata.TAGs.ID_number;
header.measuremode =  hdata.measuremode;
header.age         = hdata.TAGs.age;
header.sex         = hdata.TAGs.sex;
header.date        = date;
header.timestamp        = now; % 080222tk 
if isfield(hdata,'Pos'),
  header.Pos       = hdata.Pos;
end
if isfield(hdata.TAGs,'FileIdOfBlock'),
  header.FileIdOfBlock=hdata.TAGs.FileIdOfBlock;
  header.BlockIdOfFile=hdata.TAGs.BlockIdOfFile;
end


%=========================
% Data dimension.
%=========================
sz=size(data);
switch length(sz),
  case 3,
    % Continuous Data
    header.inputformat = 'continuous';
    header.timelen     = sz(1);
    header.chlen       = sz(2);
    header.kindlen     = sz(3);
    header.DataTag     = hdata.TAGs.DataTag;
  case 4,
    % Blcok Data
    header.inputformat = 'blocktime';
    header.blocklen    = sz(1);    
    header.timelen     = sz(2);
    header.chlen       = sz(3);
    header.kindlen     = sz(4);
    header.DataTag     = hdata.TAGs.DataTag;
  otherwise,
    error('Input data is out of format, set Continuous/Block data');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I/O of P3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  mh=OSP_DATA('GET','POTATOMAINHANDLE');
  if ~ishandle(mh),error('P3 is not running');end
  hs=guidata(mh);
catch
  error(['P3 I/O Error', lasterr]);
end
%=========================
% Filter List..
%=========================
fmd0 = OspFilterCallbacks('get with 1st Lvl Ana',mh,false);
% ==> Make Filter List....
%     stop when my Filter
%
fmd.fla=true;
%-----------------------------
% Chekcing HBdata
%-----------------------------
eflag=false;
if isfield(fmd0,'HBdata')
  hb={};
  for idx=1:length(fmd0.HBdata),
    if strcmpi(fmd0.HBdata{idx}.enable,'off')
      continue;
    end
    hb{end+1}=fmd0.HBdata{idx};
    if isequal(fmd0.HBdata{idx}.wrap,wrap)
      eflag=true;
      break;
    end
  end
  fmd.HBdata=hb;
end
%-----------------------------
% Chekcing Time Blocking..
%-----------------------------
if ~eflag && isfield(fmd0,'BlockPeriod')
  fmd.BlockPeriod=fmd0.BlockPeriod;
end
if ~eflag && isfield(fmd0,'TimeBlocking')
  fmd.TimeBlocking=fmd0.TimeBlocking;
end
%-----------------------------
% Chekcing Block-Time 
%-----------------------------
if isfield(fmd0,'BlockData')
  bd={};
  for idx=1:length(fmd0.BlockData),
    if strcmpi(fmd0.BlockData{idx}.enable,'off')
      continue;
    end
    bd{end+1}=fmd0.BlockData{idx};
    if isequal(fmd0.BlockData{idx}.wrap,wrap)
      %eflag=true;
      break;
    end
  end
  fmd.BlockData=bd;
end
header.FilterData = fmd;

%-----------------------
% Raw-Data File Name
%-----------------------
header.RawDataFileName=get(hs.advpsb_1stLvlAna_Exe,'UserData');
%=========================
%  Getting Rename Option
%=========================

