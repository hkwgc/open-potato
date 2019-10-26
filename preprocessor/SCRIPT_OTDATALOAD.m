signal=[];
% === OT_LOCAL_DATA.Info ===
%  -- Basic Information --
%      soft_version	: ETG File Version
%      id	        : Identifier number
%      subjectname	: Name of subject
%      comment	        : Comment
%      age	        : Age
%      sex	        : Sex
%      opmode	        : operation mode
%      anamode	        : analyze mode
%      measmode	        : measurement mode
%      date	        : Date

% Revision 1.6 :
%    Add field named "StimMode" to the structure signal.
%   (if there )


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% $Id: SCRIPT_OTDATALOAD.m 382 2013-11-28 00:01:28Z katura7pro $
signal.ospsoftversion    = 1.01;
signal.ospsoftversiontag = {'version of OSP signal format', ...
		    'number'};

try
  signal.softversion     = soft_version;
catch
  signal.softversion     = 'Unknown'; warning('soft-version : Unknown');
end
signal.softversiontag    = {'version of software in OT system', ...
		    'strings'};

%signal.filename         = filename;
signal.filename         = [fname ext];
signal.filenametag      = {'file name of original data in OT system', ...
		    'strings'};
signal.pathname	         = pathname;
signal.pathnametag	  = {'path name of original data in this PC', ...
		    'strings'};

if isnumeric(id),
  id=num2str(id);
end
signal.ID_number	  = id;
signal.ID_numbertag	  = {'ID number', 'strings'};

try
  if (OSP_DATA('GET','SP_ANONYMITY')),
    signal.subjectname	  = 'somebody'; % Anonymity
  else,
    signal.subjectname	  = subjectname;
  end
catch
  signal.subjectname	  = 'anyone';
end
signal.subjectnametag	  = {'subject name', 'strings'};

try
  signal.comment	  = comment;
catch
  signal.comment	  = 'no comment';
end
signal.commenttag       =    {'comment    in   measurement', ...
		    'strings'};

%  signal.age	          = age;
%  signal.agetag	          = {'a vector of age',...
%		    'age-number',...
%		    'no-definition',...
%		    'no-definition',...
%		    'no-definition'};
signal.age	          = age(1);
signal.agetag	          = {'a vector of age',...
		    'age-number'};

signal.sex	           = sex;
signal.sextag	           = {'sex-1:female,0:male','number'};
%signal.sextag	           = {'sex-1:female,2:male','number'};

signal.operationmode	   = opmode;
signal.operationmodetag  = {'operation mode','no-definition'};

% signal.analizemodetag    = {'analyze mode','no-definition'}; % not input

%  -- Raw Data --
%      smpl_period	: Sampling period
%      adnmpn	        : ????????????A/Dch??????/??????????????
%      wlen	        : ?????????/A/Dch???????
%      adrng	        : ???????A/Dgain[V]/A/Dch???????
%      amprng	        : ???????lockin-amp gain/A/Dch???????
%      datanum	        : ????????
%      data	        : ???
%      stim	        : stimulation timing
[stmdatblk]=stmblk(stim);
stmkind={'','A','B','C','D','E','F','G','H','I','J','K','L','M','N'};
[stmknd]=stmkind(stim+1);

signal.measuremode    = measmode;
signal.measuremodetag = {'measure mode-1: 24ch&2p, 2: 24ch&1p, 3: 22ch&1p ',...
		    'number'};
signal.adnum          = adn;
signal.adnumtag       = {[ 'a vector of ad channels,' ...
		    'this number is ordered as measurement position'],...
		    'number'};
signal.chnum          = chnum;
signal.chnumtag       = {'a vector of channel number', ...
		    'number'};
signal.plnum          = plnum;
signal.plnumtag       = {'the number of planes',...
		    'number'};
% Date
% date = char(date);disp(date); % Change 24-Jan-2005
if iscell(date), date=date{1}; end
try
	if strcmp(date,'-')
		signal.date=date;
	elseif regexp(date,'^\d\d\d\d/')
    % Syle 1 ( like 2005/01/24 16:20 )
    date0=[0 0 0 0 0 0];
    date=strrep(date,'/',' ');date=strrep(date,':',' ');
    date=str2num(date);
    date0(1:length(date))=date(:);
    signal.date= datenum(date0);
  else
    % Style 2 ( like 24-Jan-2004 )
    signal.date = datenum(date);
  end
catch
  warning([' Date(' date{1} ') is not a Date format.'...
	   'change to ' datestr(now)]);
  signal.date           = now;
end
signal.datetag        = {'measurement date',...
		    'Date Number'};
signal.sampleperiod   = smpl_period;
signal.sampleperiodtag= {'sampling period [msec]',...
		    'number'};
signal.adnummeasnum   = adnmpn;
signal.adnummeasnumtag= {['a vector of values of A/D gain,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
signal.wavelength     = wlen;
signal.wavelengthtag  = {['a vector of wavelength for each channel,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
signal.adrange        = adrng;
signal.adrangetag     = {['a vector of A/D range for each channel,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
signal.ampgain        = amprng;
signal.ampgaintag     = {['a vector of amplifier gain,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
if exist('d_gain','var'),
  signal.d_gain       = d_gain;
  signal.d_gaintag    = {['a vector of distal gain,'...
		    'this was corrected to the order of measurement channel'],...
		    'number'};
end
signal.datanum        = datanum;
signal.datanumtag     = {'numbers of sampling', ...
		    'number'};
signal.time           = time;
signal.timetag        = {'a vector of sampling time',...
		    'number'};
signal.data           = data;
signal.datatag        = {['a vector of raw data,'...
		    'this was corrected to the order of measurement channel'],...
		    'time','channel'};
signal.stim           = stim;
signal.stimtag        = {['a vector of stimulation timing in original data,'...
		    '1 means the timing of stimulation start or end'],...
		    'number-0 or 1'};
if exist('StimMode','var'),
  signal.StimMode     = StimMode;
  signal.StimModetag  = {' Stimulation Mode ', ...
		    ' number 1 : Event, 2 : Block '};
end

signal.stimblk        = stmdatblk;
signal.stimblktag     = {['a vector of stimulation timing in original data,'...
		    '1 means the block duration of stimulation'],...
		    'number-0 or 1'};
signal.stimkind       = stmknd;
signal.stimkindtag    = {'a vector of stimulation kinds',...
		    'string'};
signal.modstim        = stim;
signal.modstimtag     = {['a vector of stimulation timing in modified data,'...
		    '1 means the timing of stimulation start or end'],...
		    'number-0 or 1'};
signal.modstimblk     = stmdatblk;
signal.modstimblktag  = {['a vector of stimulation timing in modified data,'...
		    '1 means the block duration of stimulation'],...
		    'number-0 or 1'};
signal.modstimkind    = stmknd;
signal.modstimkindtag = {'a vector of modified stimulation kinds','string'};


if exist('otherData','var'),
  signal.otherData= otherData;
end

OT_LOCAL_DATA.info = signal;

% === OT_LOCAL_DATA.HBdata ===
%     HB Data  corresponding to time x channel x  HB Kind
% HB transfer
if ~exist('ischbtrans','var') || ischbtrans
  OT_LOCAL_DATA.HBdata     =  osp_chbtrans(signal.data, ...
    signal.wavelength, 5);
  OT_LOCAL_DATA.HBdataTag  =  {'a vector of Hb value before any filtering',...
    'time','channel','hb-kind(Describe HBdata3Tag)'};
  OT_LOCAL_DATA.HBdata3Tag =  {'Oxy','Deoxy','Total'};
  OT_LOCAL_DATA.HBcolor    =  [ 1 0 0; 0 0 1; 0 0 0]; % red, blur, black
end

