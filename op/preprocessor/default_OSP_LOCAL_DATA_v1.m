function OT_LOCAL_DATA=default_OSP_LOCAL_DATA_v1(varargin),
% make Default OSP Local Data version 1.0.
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



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
  signal=[];
  signal.ospsoftversion    = 1.00;
  signal.ospsoftversiontag = {'version of OSP signal format', ...
		  'number'};
  signal.softversion     = 'Unknown'; 
  signal.softversiontag    = {'version of software in OT system', ...
		  'strings'};
  signal.filename         = 'Untitled';
  signal.filenametag      = {'file name of original data in OT system', ...
		  'strings'};
  signal.pathname	      = '.';
  signal.pathnametag	  = {'path name of original data in this PC', ...
		  'strings'};
  
  signal.ID_number	  = '';
  signal.ID_numbertag	  = {'ID number', 'strings'};
  
  signal.subjectname	  = 'somebody';
  signal.subjectnametag	  = {'subject name', 'strings'};
  
  signal.comment	  = 'no comment';
  signal.commenttag       =    {'comment    in   measurement', ...
		  'strings'};
  signal.age	          = 0;
  signal.agetag	          = {'a vector of age', 'age-number'};
  
  signal.sex	           = 1;
  signal.sextag	           = {'sex-1:female,2:male','number'};
  
  signal.operationmode	   = 'not-defined';
  signal.operationmodetag  = {'operation mode','no-definition'};
  
  %  -- Raw Data --
  %      smpl_period	: Sampling period
  %      adnmpn	        : ????????????A/Dch??????/??????????????
  %      wlen	        : ?????????/A/Dch???????
  %      adrng	        : ???????A/Dgain[V]/A/Dch???????
  %      amprng	        : ???????lockin-amp gain/A/Dch???????
  %      datanum	        : ????????
  %      data	        : ???
  %      stim	        : stimulation timing
  
  signal.measuremode    = -1;
  signal.measuremodetag = {'measure mode-1: 24ch&2p, 2: 24ch&1p, 3: 22ch&1p ',...
		  'number'};
  signal.adnum          = [];
  signal.adnumtag       = {[ 'a vector of ad channels,' ...
			  'this number is ordered as measurement position'],...
		  'number'};
  signal.chnum          = [];
  signal.chnumtag       = {'a vector of channel number', ...
		  'number'};
  signal.plnum          = [];
  signal.plnumtag       = {'the number of planes',...
		  'number'};
  % Date
  % date = char(date);disp(date); % Change 24-Jan-2005
  signal.date = now;
  signal.datetag        = {'measurement date',...
		  'Date Number'};
  
  signal.sampleperiod   = 100;
  signal.sampleperiodtag= {'sampling period [msec]',...
		  'number'};
  signal.adnummeasnum   = [];
  signal.adnummeasnumtag= {['a vector of values of A/D gain,'...
			  'this was corrected to the order of measurement channel'],...
		  'number'};
  signal.wavelength     = [];
  signal.wavelengthtag  = {['a vector of wavelength for each channel,'...
			  'this was corrected to the order of measurement channel'],...
		  'number'};
  signal.adrange        = [];
  signal.adrangetag     = {['a vector of A/D range for each channel,'...
			  'this was corrected to the order of measurement channel'],...
		  'number'};
  signal.ampgain        = [];
  signal.ampgaintag     = {['a vector of amplifier gain,'...
			  'this was corrected to the order of measurement channel'],...
		  'number'};
  signal.datanum        = [];
  signal.datanumtag     = {'numbers of sampling', ...
		  'number'};
  signal.time           = [];
  signal.timetag        = {'a vector of sampling time',...
		  'number'};
  signal.data           = [];
  signal.datatag        = {['a vector of raw data,'...
			  'this was corrected to the order of measurement channel'],...
		  'time','channel'};
  signal.stim           = [];
  signal.stimtag        = {['a vector of stimulation timing in original data,'...
			  '1 means the timing of stimulation start or end'],...
		  'number-0 or 1'};
  signal.stimblk        = [];
  signal.stimblktag     = {['a vector of stimulation timing in original data,'...
			  '1 means the block duration of stimulation'],...
		  'number-0 or 1'};
  signal.stimkind       = [];
  signal.stimkindtag    = {'a vector of stimulation kinds',...
		  'string'};
  signal.modstim        = [];
  signal.modstimtag     = {['a vector of stimulation timing in modified data,'...
			  '1 means the timing of stimulation start or end'],...
		  'number-0 or 1'};
  signal.modstimblk     = [];
  signal.modstimblktag  = {['a vector of stimulation timing in modified data,'...
			  '1 means the block duration of stimulation'],...
		  'number-0 or 1'};
  signal.modstimkind    = [];
  signal.modstimkindtag = {'a vector of modified stimulation kinds','string'};
  
  %  -- Othere --
  %      otherData        : depend on File ( May be not in use )
  signal.otherData= struct([]);
  
  OT_LOCAL_DATA.info = signal;
  
  % === OT_LOCAL_DATA.HBdata ===
  %     HB Data  corresponding to time x channel x  HB Kind
  % HB transfer
  OT_LOCAL_DATA.HBdata     =  [];
  OT_LOCAL_DATA.HBdataTag  =  {'a vector of Hb value before any filtering',...
		  'time','channel','hb-kind(Describe HBdata3Tag)'};
  OT_LOCAL_DATA.HBdata3Tag =  {'Oxy','Deoxy','Total'};
  OT_LOCAL_DATA.HBcolor    =  [ 1 0 0; 0 0 1; 0 0 0]; % red, blur, black
  
  % === OT_LOCAL_DATA.StimInfo ===
  %     StimInfo
  %  -> needless
  % OT_LOCAL_DATA.StimInfo   = makeStimData(signal.stim,1,[100 150]);
  
