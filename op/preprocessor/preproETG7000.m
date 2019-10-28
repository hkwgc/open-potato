function varargout = preproETG7000(fcn, varargin)
% Preprocessor Function of ETG 7000 Fromat: Normal..
%   This Format Read ETG7000.
%   And Plug-in Format Version 1.0
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproETG7000('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproETG7000('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproETG7000('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproETG7000('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproETG7000('Execute', filename)
%  Continuous Data.
%
%  OT_LOCAL_DATA = preproETG7000('ExecuteOld', filename)
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
% $Id: preproETG7000.m 382 2013-11-28 00:01:28Z katura7pro $
% $Id: preproETG7000.m 382 2013-11-28 00:01:28Z katura7pro $

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
  ExecuteOld;
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproETG7000('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='ETG 7000';
basicInfo.Version  =1.2;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
%rver = '$Revision: 1.15 $';
rver = '$Revision: 1.16 $';%- TK@HARL 20110225
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
%  filterspec = preproETG7000('getFilterSpec');
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*.dat; *.mea; *.csv;','ETG7000 Text File';...
  '*.dat', 'Dat Files'; ...
  '*.mea', 'Mea Files'; ...
  '*.csv', 'CSV Files'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi = createBasicInfo;
dd = '$Date: 2007/12/18 07:00:12 $';
dd([1:6, end]) = [];

str={'=== ETG 7000 Format ===', ...
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
%  [flag,msg] = preproETG7000('CheckFile',filename)
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

%--------------------------------
% Checking not Hemoglobin Format
%--------------------------------
msg='Hemoglobin Format.';
try 
  if strcmpi('_Oxy',fname(end-3:end)),flag=false;return;end
catch
end
try 
  if strcmpi('_Deoxy',fname(end-5:end)),flag=false;return;end
catch
end
try 
  if strcmpi('_Total',fname(end-5:end)),flag=false;return;end
catch
end
msg='';

%--------------------------------
% Check 1st Line
%--------------------------------
line_01=textread(filename,'%s%*[^\n]',1,'whitespace','''');
flag = strcmp(line_01{1},'Header');
if flag==false,
  msg='1st Line is not Header';
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str =getFileInfo(filename)
% ** get Information of file  **
% Syntax:
%  str =
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=textread(filename,'%s',32,'headerlines',0,'delimiter',',');
str =[[' Format ETG 7000 : ' filename]; cellstr(str)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproETG7000('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data =ExecuteOld(filename);
[data,hdata]=ot2ucdata(data);


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OT_LOCAL_DATA =ExecuteOld(filename)
%  OT_LOCAL_DATA = preproETG7000('ExecuteOld', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pathname, fname, ext] = fileparts(filename);
% line:21 'Mode'?? ???Mode?????式???????

%- check format version %%%-TK@HARL 2011/01/12
fid = fopen(filename,'r');
fgetl(fid);%- skip one line
FORMAT_VER=sscanf(fgetl(fid),'File Version,%f');
fclose(fid);

%--TK
if (FORMAT_VER<1.2)
	FORMAT_VER=1.1;
end
%--TK
switch FORMAT_VER,
	case {1.1, 1.18, 2.03, 2.05, 2.09}
		[dum]=textread(filename,'%s',2,'headerlines',20,'delimiter',',');
		HEADER_LINE_ADJ = zeros(1,100);
	case {1.21, 1.22,1.24} %- 1.22 add TK@CRL 2013-02-08
		[dum]=textread(filename,'%s',2,'headerlines',22,'delimiter',',');
		HEADER_LINE_ADJ = zeros(1,100);
		HEADER_LINE_ADJ(6:end) = 1;%- line7 added
		HEADER_LINE_ADJ(21:end) = HEADER_LINE_ADJ(21:end)+1;%-line22 added
		HEADER_LINE_ADJ(39:end) = 0;%- HEADER end	

	case 2.12 %-TK@CRL 2012-03-16
		[dum]=textread(filename,'%s',2,'headerlines',21,'delimiter',',');
		HEADER_LINE_ADJ = zeros(1,100);
		HEADER_LINE_ADJ(6:31) = 1;

	otherwise
		errordlg(sprintf('File format ver%0.3f\n%s',FORMAT_VER,C__FILE__LINE__CHAR(1)));
		return;
end
		
%[dum]=textread(filename,'%s',2,'headerlines',20,'delimiter',',');
ofst=0; if strcmp(dum{1},'Mode'), ofst=1; end;
% Mode definition for ETG-7000
switch dum{2},
  case {'3x3','3x3x2'},
    measmode=1;
  case '4x4'
    measmode=51;
  case '3x5'
    measmode=52;
  case '5x3'
    measmode=53;
  case '8x8'
    measmode=50;
  case '3x11'
    measmode=54;
  otherwise
    measmode=99;
end
% if strcmp(dum{2},'3x3x2') measmode= 1; end % New : for yanaka

%Inisialize
% count adnum from line,22or23
[dum]=textread(filename, '%s%*[^\n]',1, 'headerlines',21+ofst+HEADER_LINE_ADJ(21), ...
  'whitespace','''');
if (dum{1}(end) == ',')
  adn=length(findstr(dum{1},','))-1;
else
  adn=length(findstr(dum{1},','));
end
%     adn=length(findstr(dum{1},','))-1;
% ?????????ADch????','???????????????B
% Changed by H.Atsumori, July 12 2004

clear dum;
chnum=adn/2;
opmode=99;

fnpl=findstr(filename,'.');
plnum=regexp(filename(fnpl(end)-1),'[0-9]');
if isempty(plnum)
  plnum=0;
else
  plnum=str2double(filename(fnpl(end)-1));
end
%plnum=1;

adnmpn=1:adn;
for i=1:adn
  adrng(i)=2.50; % A/D gain of each channel 2.50[V]
end

soft_version=textread(filename, '%*12c%s',1, 'headerlines',1+HEADER_LINE_ADJ(1), ...
  'delimiter',',');
dum=textread(filename, '%*2c%s',1, 'headerlines',3+HEADER_LINE_ADJ(3),'delimiter',',');
id=dum{1};
dum=textread(filename, '%*4c%s',1, 'headerlines',4+HEADER_LINE_ADJ(4),'delimiter',',');
subjectname=dum{1};
dum=textread(filename, '%*7c%s',1, 'headerlines',5+HEADER_LINE_ADJ(5),'delimiter',',');
comment=dum{1};
age_str= textread(filename, '%*3c%s',1, 'headerlines',6+HEADER_LINE_ADJ(6),...
  'delimiter',',');

if(strcmp(age_str{1}(end),'y'))
  tmp=age_str{1}(1:end-1);
else
  tmp=age_str{1};
end
age(1)=str2double(tmp);
for ii=2:4
  age(ii)=0;
end

sex_str=textread(filename, '%*3c%s',1, 'headerlines',7+HEADER_LINE_ADJ(7), ...
  'delimiter',',');
switch(sex_str{1})
  case 'Male',
    sex=0;
  case 'Female',
    sex=1;
end

analyze_mode=textread(filename, '%*11c%s',1, 'headerlines',9+HEADER_LINE_ADJ(9), ...
  'delimiter',',');

% skip line,11 to 19

date=textread(filename, '%*4c%s',1, 'headerlines',19+HEADER_LINE_ADJ(19),'delimiter',',');

%load wave length
[dum]=textread(filename, '%s',adn+1, 'headerlines',21+ofst+HEADER_LINE_ADJ(21), ...
  'delimiter',',');
for i=1:adn
  l_per=findstr(dum{i+1},'(');
  r_per=findstr(dum{i+1},')');
  in_per_num=str2double(dum{i+1}(l_per+1:r_per-1));
  wlen(i)=in_per_num;
end
clear dum;

%load analog gain to each channel
[dum]=textread(filename, '%s',adn+1, 'headerlines',22+ofst+HEADER_LINE_ADJ(22), ...
  'delimiter',',');
for i=1:adn
  amprng(i)=str2double(dum(i+1,:));
end
clear dum;

%load digital gain to each channel
[dum]=textread(filename, '%s',adn+1, 'headerlines',23+ofst+HEADER_LINE_ADJ(23), ...
  'delimiter',',');
for i=1:adn
  d_gain(i)=str2double(dum(i+1,:));
end
clear dum;

%load sampling period[s]
smpl_period=textread(filename, '%*18c%f',1, 'headerlines',24+ofst+HEADER_LINE_ADJ(24), ...
  'delimiter',',');

% Stimulation Information
[dum]=textread(filename,'%s',2,'headerlines',25+ofst+HEADER_LINE_ADJ(25),'delimiter',',');
if strcmpi(dum{2},'EVENT')
  StimMode = 1; % Event
  [dum]=textread(filename, '%s',1,'headerlines',27+ofst+HEADER_LINE_ADJ(27), ...
    'delimiter','\n');
  [stim_timeQ,stim_time]=strread(dum{1}, '%s%d','delimiter',',');
  if length(stim_time) < 10
    stim_time(end+1:10)=0;  % Add more
  end
  clear dum;
else
  StimMode = 2; % Block
  %load stim time
  [stim_time]=textread(filename,'%*c%d',10,'headerlines',27+ofst+HEADER_LINE_ADJ(27), ...
    'delimiter',',');
end


%load repeart count
repeat=textread(filename, '%*12c%d',1, 'headerlines',28+ofst+HEADER_LINE_ADJ(28), ...
  'delimiter',',');

%load data
% read all row as number of data
[dum] = textread(filename, '%c%*[^\n]','headerlines',41+HEADER_LINE_ADJ(41));
datanum=length(dum);
clear dum;

%NEW
fid=fopen(filename);
try
  % 12-Dec-2005 : Mod
  for i=1:40,fgetl(fid);end
  f=fgetl(fid);
  cp = findstr(f,',');
  tp=findstr(f,'Time');
  st='';
  for ix=cp,
    st=[st '%f,'];
    if ix>tp,
      st(end)=':';
      st=[st '%f:%f,'];
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
data=data_mark(2:adn+1,:);
data=data';
stim=data_mark(adn+2,:);
stim=stim';

time=[0:smpl_period:(datanum-1)*smpl_period];
% convert sec to msec
smpl_period=1000*smpl_period;

% Make OT_LOCAL_DATA from file data.
SCRIPT_OTDATALOAD;
return;


