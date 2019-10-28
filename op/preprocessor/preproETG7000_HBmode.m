function varargout = preproETG7000_HBmode(fcn, varargin)
% Preprocessor Function of ETG 7000 Fromat: Normal..
%   This Format Read ETG7000.
%   And Plug-in Format Version 1.0
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproETG7000_HBmode('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproETG7000_HBmode('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproETG7000_HBmode('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproETG7000_HBmode('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproETG7000_HBmode('Execute', filename)
%  Continuous Data.
%
%  OT_LOCAL_DATA = preproETG7000_HBmode('ExecuteOld', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%
% See also OSPFILTERDATAFCN.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% ETG-7000 format loading routine
% DATE:03.02.20
% WRITTEN:Y.Inoue
%
% Inprot form Upper ot_datalod.
% create : 2005.12.21
% $Id: preproETG7000_HBmode.m 311 2013-02-27 05:36:27Z Katura $

%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
if 0
  % Entry function
  createBasicInfo;
  getFunctionInfo;
  CheckFile;
  getFileInfo;
  Execute;
  % new
  getFilterSpec;
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproETG7000_HBmode('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='ETG7000 (Hemoglobin-Data)';
basicInfo.Version  =1.0;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
rver = '$Revision: 1.2 $';
[s,e]= regexp(rver, '[0-9.]');
try
  basicInfo.Version = str2double(rver(s(1):e(end)));
catch
  basicInfo.Version =1.0;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=getFilterSpec
% ** CREATE BASIC INFORMATION **
% Syntax:
%  filterspec = preproETG7000_HBmode('getFilterSpec');
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*_Probe[0-9]+_Oxy.csv','HB Data'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi = createBasicInfo;
dd = '$Date: 2008/04/25 02:09:02 $';
dd([1:6, end]) = [];
str={'=== ETG 7000 Hemoglobin-Format ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date     : ' dd], ...
  ' ------------------------ ', ...
  '  Text Type', ...
  '  1st Line : Header ....  ', ...
  ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = preproETG7000_HBmode('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pname, fname,ext] = fileparts(filename);
% Check Extension
if strcmpi(ext,{'.dat', '.mea','.csv'})==0,
  % Extend
  msg='Extension Error';
  flag = false;
  return;
end

%------------------------
% Checking Original Data
%------------------------
msg='Not Hemoglobin Format';
try 
  if ~strcmpi('_Oxy',fname(end-3:end)),flag=false;return;end
catch
  flag=false;return;
end

%------------------------
% Checking Other Files
%------------------------
[msg pfiles]=getProbeFiles(pname,fname,ext);
if msg,flag=false;return;end


%------------------------
% Check 1st Line
%------------------------
for idx=1:length(pfiles)
  line_01=textread(pfiles{idx},'%s%*[^\n]',1,'whitespace','''');
  flag = strcmp(line_01{1},'Header');
  if flag==false,
    [p,f]=fileparts(pfiles{idx});
    msg=[f ' : 1st Line is not Header'];
    if 0,difp(p);end
    return;
  end
end


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg =getFileInfo(filename)
% ** get Information of file  **
% Syntax:
%  str =
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
line0=0;
% Open File
fp = fopen(filename,'r');
try
  msg={' Format ETG 7000 Hemoglobin Data', ['Filename : ' filename]};

  % Read 50 Lines : And use lines as messages.
  for line0 = 1:30,
    tline = fgetl(fp);
    % if End-Of-File : Break
    if ~ischar(tline), break; end;
    if isempty(tline),break;end

    msg{end+1} = tline;
  end
catch
  msg{end+1}=['Error Occur : at line ' num2str(line0)];
  errordlg(msg{end+1});
end
fclose(fp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproETG7000_HBmode('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================
% Initializetion
%======================================================
% Check Files
[p,f,e]=fileparts(filename);
[msg pfiles fname]=getProbeFiles(p,f,e); % Reading Probe Files
if msg,error(msg);return;end

% Make Default Data
hdata = osp_default_ContinuousData;

% Set File Name
%hdata.TAGs.filename         = [fname e];
hdata.TAGs.filename         = fname;
hdata.TAGs.filenametag      = {'file name of original data in OT system', 'strings'};
hdata.TAGs.pathname	         = p;
hdata.TAGs.pathnametag	  = {'path name of original data in this PC', 'strings'};

% Delimitor & Software Version
soft_version=textread(filename, '%*12c%s',1, 'headerlines',1,'delimiter','\n','whitespace','''');
dlmtr0=soft_version{1}(1);
soft_version{1}(1)=[];
% for textread string
if strcmpi(dlmtr0,sprintf('\t'))
  dlmtr='\t';
else
  dlmtr=dlmtr0;
end

hdata.TAGs.softversion    = soft_version;
hdata.TAGs.softversiontag = {'version of software in OT system', ...
		    'strings'};

%=====================================================
% Read Header of Oxy-Data-File
%=====================================================
% line:21 'Mode'?? ???Mode?????式???????

HEADER_LINE_ADJ=zeros(1,40);
switch soft_version{1}
	case '1.10'
		SkipHeaderLineNumber=20;
	case {'1.21','1.22'}
		SkipHeaderLineNumber=22;
		HEADER_LINE_ADJ(7:20)=1;
		HEADER_LINE_ADJ(21:end)=2;		
end

[dum]=textread(filename,'%s',2,'headerlines',SkipHeaderLineNumber,'delimiter',dlmtr);
ofst=0; 
if strcmp(dum{1},'Mode'), ofst=1; end;
% Mode definition for ETG-7000
switch dum{2},
  case {'3x3','3x3x2'},
    hdata.measuremode=1;
  case '4x4'
    hdata.measuremode=51;
  case '3x5'
    hdata.measuremode=52;
  case '5x3'
    hdata.measuremode=53;
  case '8x8'
    hdata.measuremode=50;
  case '3x11'
    hdata.measuremode=54;
  otherwise
    hdata.measuremode=99;
end
% if strcmp(dum{2},'3x3x2') measmode= 1; end % New : for yanaka

%Inisialize
% count adnum from line,22or23
[dum]=textread(filename, '%s%*[^\n]',1, 'headerlines',21+ofst+HEADER_LINE_ADJ(21), ...
  'whitespace','''');
if strcmpi(dum{1}(end),dlmtr0)
  adn=length(findstr(dum{1},dlmtr0))-1;
else
  adn=length(findstr(dum{1},dlmtr0));
end
% Changed by H.Atsumori, July 12 2004

clear dum;
chnum=adn/2;
hdata.TAGs.chnum          = chnum;
hdata.TAGs.chnumtag       = {'a vector of channel number','number'};
%hdata.TAGs.operationmode	   = 99;
%hdata.TAGs.operationmodetag  = {'operation mode','no-definition'};

%fnpl=findstr(filename,'.');
%plnum=str2double(filename(fnpl(end)-5));
%if isempty(plnum), plnum=0;end
%hdata.TAGs.plnum          = plnum;
%hdata.TAGs.plnumtag       = {'the number of planes','number'};
		    
% adnmpn=1:adn;
% for i=1:adn
%   adrng(i)=2.50; % A/D gain of each channel 2.50[V]
% end

% ID
dum=textread(filename, '%*2c%s',1, 'headerlines',3,'delimiter',dlmtr);
hdata.TAGs.ID_number	  = dum{1};
hdata.TAGs.ID_numbertag	= {'ID number', 'strings'};

% Subject Name
try
  if (OSP_DATA('GET','SP_ANONYMITY')),
    hdata.TAGs.subjectname	  = 'somebody'; % Anonymity
  else
    dum=textread(filename, '%*4c%s',1, 'headerlines',4,'delimiter',dlmtr);
    hdata.TAGs.subjectname	  = dum{1};
  end
catch
  hdata.TAGs.subjectname	  = 'anyone';
end
hdata.TAGs.subjectnametag	  = {'subject name', 'strings'};

% Comment
dum=textread(filename, '%*7c%s',1, 'headerlines',5,'delimiter',dlmtr);
hdata.TAGs.comment	  = dum{1};
hdata.TAGs.commenttag = {'comment    in   measurement', 'strings'};

% Get Age
age_str= textread(filename, '%*3c%s',1, 'headerlines',6,'delimiter',dlmtr);
if strcmp(age_str{1}(end),'y')
  tmp=age_str{1}(1:end-1);
else
  tmp=age_str{1};
end
hdata.TAGs.age	   = str2double(tmp);
hdata.TAGs.agetag	 = {'a vector of age','age-number'};

sex_str=textread(filename, '%*3c%s',1, 'headerlines',7+HEADER_LINE_ADJ(7),'delimiter',dlmtr);
switch(sex_str{1})
  case 'Male',
    hdata.TAGs.sex=0;
  case 'Female',
    hdata.TAGs.sex=1;
end
hdata.TAGs.sextag	           = {'sex-1:female,0:male','number'};

% skip line,11 to 19
date=textread(filename, '%*4c%s',1, 'headerlines',19+HEADER_LINE_ADJ(19),'delimiter',dlmtr);
% Date
% date = char(date);disp(date); % Change 24-Jan-2005
if iscell(date), date=date{1}; end
try
  if regexp(date,'^\d\d\d\d/')
    % Syle 1 ( like 2005/01/24 16:20 )
    date0=[0 0 0 0 0 0];
    date=strrep(date,'/',' ');date=strrep(date,':',' ');
    date=str2num(date);
    date0(1:length(date))=date(:);
    hdata.TAGs.date= datenum(date0);
  else
    % Style 2 ( like 24-Jan-2004 )
    hdata.TAGs.date = datenum(date);
  end
catch
  warning([' Date(' date{1} ') is not a Date format.'...
	   'change to ' datestr(now)]);
  hdata.TAGs.date           = now;
end
hdata.TAGs.datetag   = {'measurement date','Date Number'};
		    
      
%load wave length
[dum]=textread(filename, '%s',adn+1, 'headerlines',21+ofst+HEADER_LINE_ADJ(21), ...
  'delimiter',dlmtr);
hdata.TAGs.wavelength=zeros([1,adn]);
for i=1:adn
  l_per=findstr(dum{i+1},'(');
  r_per=findstr(dum{i+1},')');
  in_per_num=str2double(dum{i+1}(l_per+1:r_per-1));
  hdata.TAGs.wavelength(i)=in_per_num;
end
hdata.TAGs.wavelengthtag  = {['a vector of wavelength for each channel,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
clear dum;

%load analog gain to each channel
[dum]=textread(filename, '%s',adn+1, 'headerlines',22+ofst+HEADER_LINE_ADJ(22), ...
  'delimiter',dlmtr);
hdata.TAGs.adrange=zeros([1,adn]);
for i=1:adn
  hdata.TAGs.adrange(i)=str2double(dum(i+1,:));
end
hdata.TAGs.adrangetag     = {['a vector of A/D range for each channel,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
clear dum;

%load digital gain to each channel
[dum]=textread(filename, '%s',adn+1, 'headerlines',23+ofst+HEADER_LINE_ADJ(23), ...
  'delimiter',dlmtr);
hdata.TAGs.d_gain=zeros([1,adn]);
for i=1:adn
  hdata.TAGs.d_gain(i)=str2double(dum(i+1,:));
end
hdata.TAGs.d_gaintag    = {['a vector of distal gain,'...
  'this was corrected to the order of measurement channel'],...
  'number'};
clear dum;

%load sampling period[s]
smpl_period=textread(filename, '%*18c%f',1, 'headerlines',24+ofst+HEADER_LINE_ADJ(24),'delimiter',dlmtr);
% convert sec to msec
hdata.samplingperiod=1000*smpl_period;

% Stimulation Information
[dum]=textread(filename,'%s',2,'headerlines',25+ofst+HEADER_LINE_ADJ(25),'delimiter',dlmtr);
if strcmpi(dum{2},'EVENT')
  hdata.StimMode = 1; % Event
  %load stim time
  %   [dum]=textread(filename, '%s',1,'headerlines',27+ofst, ...
  %     'delimiter','\n');
  %   [stim_timeQ,stim_time]=strread(dum{1}, '%s%d','delimiter',dlmtr);
  %   if length(stim_time) < 10
  %     stim_time(end+1:10)=0;  % Add more
  %   end
  clear dum;
else
  hdata.StimMode = 2; % Block
  %load stim time
  % [stim_time]=textread(filename,'%*c%d',10,'headerlines',27+ofst);
end


%load repeart count
%repeat=textread(filename, '%*12c%d',1, 'headerlines',28+ofst);


%=====================================================
% Read Data of Oxy-Data-File
%=====================================================
%load data
% read all row as number of data
[dum] = textread(filename, '%c%*[^\n]','headerlines',41,'delimiter',dlmtr);
datanum=length(dum);
clear dum;

%---------
% Oxy
%---------
fid=fopen(filename);
try
  % 12-Dec-2005 : Mod
  for i=1:40,fgetl(fid);end
  f=fgetl(fid);
  cp = findstr(f,dlmtr0);
  tp=findstr(f,'Time');
  st='';
  for ix=cp,
    st=[st '%f' dlmtr0];
    if ix>tp,
      st(end)=':';
      st=[st '%f:%f' dlmtr0];
      tp=inf;
    end
  end
  st = [st '%f'];
  data_mark=fscanf(fid,st,[length(cp)+3, datanum]);
catch
  fclose(fid);
  rethrow(lasterror);
end
fclose(fid);
oxy=data_mark(2:chnum+1,:);
oxy=oxy';

%--> stim / somthing mark..
stim=data_mark(chnum+2,:);
% Empty Check
if ~any(stim)
  warning('No Stimulation Data, set dumy stimulation at start and end');
  stim([1,end])=1;
end

% set TAGs
hdata.TAGs.stim           = stim';
hdata.TAGs.stimtag        = {['a vector of stimulation timing in original data,'...
  '1 means the timing of stimulation start or end'],...
  'number-0 or 1'};

% make stimTC
hdata.stimTC = stim;
hdata=uc_makeStimData(hdata);

hdata.TAGs.time    = 0:smpl_period:(datanum-1)*smpl_period;
hdata.TAGs.timetag = {'a vector of sampling time','number'};
		    
% convert sec to msec
hdata.samplingperiod=1000*smpl_period;

%---------
% Deoxy
%---------
fid=fopen(pfiles{2});
try
  % 12-Dec-2005 : Mod
  for i=1:41,fgetl(fid);end
  data_mark=fscanf(fid,st,[length(cp)+3, datanum]);
catch
  fclose(fid);
  rethrow(lasterror);
end
fclose(fid);
deoxy=data_mark(2:chnum+1,:);
deoxy=deoxy';

%---------
% Total
%---------
fid=fopen(pfiles{3});
try
  % 12-Dec-2005 : Mod
  for i=1:41,fgetl(fid);end
  data_mark=fscanf(fid,st,[length(cp)+3, datanum]);
catch
  fclose(fid);
  rethrow(lasterror);
end
fclose(fid);
tot=data_mark(2:chnum+1,:);
tot=tot';

data=reshape([oxy,deoxy,tot],[datanum,chnum,3]);
hdata.flag=false([1,datanum,chnum]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [msg, files, fname]=getProbeFiles(p,f,e)
% get Probe Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fname=f(1:end-4);
base=[p filesep fname '_'];
msg='';

files{3}=[base 'Total' e];
if ~exist(files{3},'file')
  msg='No Totla-File Exist.';
end

files{2}=[base 'Deoxy' e];
if ~exist(files{2},'file')
  msg='No Deoxy-File Exist.';
end

files{1}=[base 'Oxy' e];
if ~exist(files{1},'file')
  msg='No Oxy-File Exist.';
end


