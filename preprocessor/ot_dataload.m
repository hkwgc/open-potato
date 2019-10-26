function [OT_LOCAL_DATA]=ot_dataload(fnms,pthnm,load_lvl);
% "ot_dataload" Read OT data and make OSP DATA ( @since 2.0 )
%
% Receive valuables: 
%  fnm        is filename of target
%  pthnm      is path-name of the target file included
%  [load_lvl] is Load Level flag by bits 
%     [binary-Flag]  :  ( Load Data )
%         0000       : Load Nothing
%         0001       : Load Basic Information Only
%         0010       : Load Raw Data
%         0110       : Translate Raw to HB Data
%         1000       : Load not defined data (Available Fver 4.04)
%      that is to say
%                   old "ot_fileinfo"  is  0001 ( more or less )
%                   old "ot_dataload"  is  0111
%      if omitted use (7) [0111]
%
% OSP_LocalData=ot_fileinfo(fnms,pthnm);
%
%++++++++++++++++++++++++++++++++++++++++++++++++++
% === OT_LOCAL_DATA.Info ===
%  -- Basic Information --
%      soft_version	: ETG File Version
%      id	        : Identifier number
%      subjectname	: Name of subject
%      comment	        : Comment
%      age	        : Age  ------> change to a scaler
%      sex	        : Sex
%      opmode	        : operation mode
%      anamode	        : analyze mode
%      measmode	        : measurement mode
%      date	        : Date  ----> change to datenum @since 2.0
%  -- Raw Data --
%      smpl_period	: Sampling period
%      adnmpn	        : A vector of A/D gain vector.
%                         this wan corrected to the order of measurement channel 
%      wlen	        : A vector of wavelength for each channel
%      adrng	        : A vector of A/D range for each channel
%      amprng	        : a vector of amplifier gain
%      datanum	        : number of sampling data
%      data	        : matrix of raw data. correspond to data,
%                         channel
%      stim	        : stimulation timing
%  -- Other --
%      otherData        : depend on File ( May be not in use )
%
% === OT_LOCAL_DATA.HBdata ===
%     HB Data  corresponding to time x channel x  HB Kind
%
% === OT_LOCAL_DATA.StimInfo ===
%     StimInfo       
%++++++++++++++++++++++++++++++++++++++++++++++++++
%
% Create
% May 23, 02 Maki
%
%mod 030721 by TK ETG-7000 dataload
%mod 041126 by MS Fver4.04 add
% 07-Jan-2005 : Add to CVS to eda_pc01, 
% $Id: ot_dataload.m 180 2011-05-19 09:34:28Z Katura $

% Reversion : 1.5 
%  Fver4.04 : csv Data can be read

% Reversion : 1.11
%   OSP v1.00 Signal data can be available.
%   BugFix : warning , function name.

% Reversion : 1.13
%   Enable Anonymity


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% === Initiarize ===
% Argument check
if nargin < 3, load_lvl= 7; end  % Default is 0111
OT_LOCAL_DATA=[];
if load_lvl==0
  warning(' ot_dataload : load_lvl is 0 ');
  return;
end
if bitget(load_lvl,3)==1 && bitget(load_lvl,2)==0
  error(' Load Level Error : if there is no Data to Read Cannot Convert');
end

otherData=[];  % Init

% Make File Name
sep=filesep;      % Directory Separator of the platform ( changed by Shoji 13-Oct-2004)
if ~strcmp(pthnm(end),sep),pthnm=strcat(pthnm,sep);end
clear sep;
fnm=strcat(pthnm,fnms);
if ~exist(fnm,'file')
    error('exist : File not found');
end

% -- OldVertion --
old_v0 = regexpi(fnms,'^s_(.*)[.]mat$');
if ~isempty(old_v0)
  OT_LOCAL_DATA = OldDataLoad(fnm, 0);
  return;
end
clear old_v0;
old_v1 = regexpi(fnms,'^HB_(.*)[.]mat$');
if ~isempty(old_v1)
  load(fnm,'OSP_LOCALDATA');
  OT_LOCAL_DATA = OSP_LOCALDATA; clear OSP_LOCALDATA;
  return;
end
clear old_v1;
% Get File Version 
line_01=textread(fnm,'%s%*[^\n]',1,'whitespace','''');


% ==== Switch By File Version ====
%disp(line_01);
for dumy_swich_Break=1;   %% Dumy code to Break in Switch
switch line_01{1},

% % Cnage : Try to FVer 4.04 , because 2.02 is poor
%   %==================
%  case 'FVer 2.02C ',
%   %==================
%   soft_version=line_01;


  
  %==================
 case 'FVer 2.02L ',
  %==================
  soft_version=line_01;
  %%+++Read Header
  [dum]=textread(fnm,'%s%*[^\n]',3,'headerlines',1,'whitespace','''');
  id=dum{1}(1:end-1);subjectname=dum{2}(1:end-1);comment=dum{3}(1:end-1);
    
  clear dum;
    
  [dum]=textread(fnm,'%d%*[^\n]',11,'headerlines',4,'whitespace','''');
  age(1)=dum(1);age(2)=0;age(3)=0;age(4)=0;
  sex=dum(2);opmode=dum(3);anamode=dum(4);measmode=dum(5);
  dspslct=dum(6);hbslct=dum(7);wavslct=dum(8);timescl=dum(9);rate=dum(10);
  stimselect(1)=dum(11);stimselect(2)=0;
  clear dum;
    
  [smpl_period]=textread(fnm,'%d%*[^\n]',1,'headerlines',84,'whitespace','''');
    
  [date]=textread(fnm,'%q%*[^\n]',1,'headerlines',155,'whitespace','''');
    

  % == Information Only ==
  if bitget(load_lvl,2)==0,
    break;
  end

  %%+++ Read data-block
  %the number of colum
  switch measmode,
   case 1,
    adn=48;
    chnum=24;
    plnum=2;
   case 2,
    adn=48;
    chnum=24;
    plnum=1;
   case 3,
    adn=44;
    chnum=22;
    plnum=1;
  end
  
  [adnmpn]=(textread(fnm,'%d',adn,'headerlines',156,'delimiter',','))';
  [wlen]=(textread(fnm,'%20f',adn,'headerlines',157,'delimiter',','))';
  [adrng]=(textread(fnm,'%20f',adn,'headerlines',158,'delimiter',','))';
  [amprng]=(textread(fnm,'%20f',adn,'headerlines',159,'delimiter',','))';
    
  [dum]=textread(fnm,'%20f','headerlines',163,'delimiter',',');
  dum=(reshape(dum,[66,length(dum)/66]))';
  data=dum(:,1:adn);
  stim=dum(:,65);%??? Only-stim_select=4 => Kawasaki Check! 
  clear dum;
    
  %Change order of colom A/D to Meas point
  wlen=wlen(adnmpn+1);adrng=adrng(adnmpn+1);amprng=amprng(adnmpn+1);data=data(:,adnmpn+1);
  datanum=length(data(:,1));tstp=smpl_period/1000;time=[0:tstp:(datanum-1)*tstp];
    
  %==================    
 case {'FVer 3.02  ','FVer 3.03  '},
  %==================
  soft_version=line_01;
  %%+++Read Header
  [dum]=textread(fnm,'%s%*[^\n]',3,'headerlines',1,'whitespace','''');
  id=dum{1}(1:end-1);subjectname=dum{2}(1:end-1);comment=dum{3}(1:end-1);
  clear dum;
  
  [age(1), age(2), age(3), age(4)] = ...
      textread(fnm,'%d%d%d%d%*[^\n]',1,'headerlines',4,'whitespace','''');
  
  [dum]=textread(fnm,'%d%*[^\n]',9,'headerlines',5,'whitespace','''');
  sex=dum(1);opmode=dum(2);anamode=dum(3);measmode=dum(4);
  dspslct=dum(5);hbslct=dum(6);wavslct=dum(7);timescl=dum(8);rate=dum(9);
  clear dum;
    
  [stimselect(1), stimselect(2)] = ...
      textread(fnm,'%d%d%*[^\n]',1,'headerlines',14,'whitespace','''');
    
  [smpl_period]=textread(fnm,'%d%*[^\n]',1,'headerlines',64,'whitespace','''');
  
  shift=0;if strcmp(soft_version{1},'FVer 3.03  '),shift=8;,end;
  [date]=textread(fnm,'%q%*[^\n]',1,'headerlines',130+shift,'whitespace','''');
    
  % == Information Only ==
  if bitget(load_lvl,2)==0
    break;
  end

  %%+++ Read data-block
  %the number of colum
  switch measmode,
   case 1,
    adn=48;
    chnum=24;
    plnum=2;
   case 2,
    adn=48;
    chnum=24;
    plnum=1;
   case 3,
    adn=44;
    chnum=22;
    plnum=1;
  end
        
  [adnmpn]=(textread(fnm,'%d'  ,adn,'headerlines',131+shift,'delimiter',','))';
  [wlen]  =(textread(fnm,'%20f',adn,'headerlines',132+shift,'delimiter',','))';
  [adrng] =(textread(fnm,'%20f',adn,'headerlines',133+shift,'delimiter',','))';
  [amprng]=(textread(fnm,'%20f',adn,'headerlines',134+shift,'delimiter',','))';
    
  [dum]=textread(fnm,'%20f ','headerlines',140+shift,'delimiter',',');
  dum=(reshape(dum,[66,length(dum)/66]))';
  data=dum(:,1:adn);
  stim=dum(:,65);%??? Only-stim_select=4 => Kawasaki Check! 
  clear dum;
    
  %Change order of colom A/D to Meas point
  wlen=wlen(adnmpn+1);adrng=adrng(adnmpn+1);amprng=amprng(adnmpn+1);data=data(:,adnmpn+1);
  datanum=length(data(:,1));tstp=smpl_period/1000;time=[0:tstp:(datanum-1)*tstp];

  %==================    
case 'Header',
  %==================
  % ETG-7000 format loading routine
  % DATE:03.02.20 
  % WRITTEN:Y.Inoue
  
  % line:21 'Mode'?? ???Mode?????式???????
  [dum]=textread(fnm,'%s',2,'headerlines',20,'delimiter',',');
  ofst=0; if strcmp(dum{1},'Mode') ofst=1; end;
  
  % Mode definition for ETG-7000
  measmode=99;
  if strcmp(dum{2},'4x4') measmode=51; end
  if strcmp(dum{2},'3x5') measmode=52; end
  if strcmp(dum{2},'5x3') measmode=53; end       
  if strcmp(dum{2},'8x8') measmode=50; end       
  % if strcmp(dum{2},'3x3x2') measmode= 1; end % New : for yanaka
          
  %Inisialize
  % count adnum from line,22or23
  [dum]=textread(fnm, '%s%*[^\n]',1, 'headerlines',21+ofst,'whitespace','''');
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
    
  fnpl=findstr(fnm,'.');
  plnum=str2num(fnm(fnpl(end)-1));
  if isempty(plnum), plnum=0;,end
  %plnum=1;
    
  adnmpn=1:adn;

  for i=1:adn
    adrng(i)=2.50; % A/D gain of each channel 2.50[V]
  end

  soft_version=textread(fnm, '%*12c%s',1, 'headerlines',1,'delimiter',',');
  dum=textread(fnm, '%*2c%s',1, 'headerlines',3,'delimiter',',');
  id=dum{1};
  dum=textread(fnm, '%*4c%s',1, 'headerlines',4,'delimiter',',');
  subjectname=dum{1};
  dum=textread(fnm, '%*7c%s',1, 'headerlines',5,'delimiter',',');
  comment=dum{1};
  age_str= textread(fnm, '%*3c%s',1, 'headerlines',6,'delimiter',',');

  if(strcmp(age_str{1}(end),'y'))
    tmp=age_str{1}(1:end-1);
  else
    tmp=age_str{1};
  end
  age(1)=str2double(tmp);
  for ii=2:4
    age(ii)=0;
  end
    
  sex_str=textread(fnm, '%*3c%s',1, 'headerlines',7,'delimiter',',');
  switch(sex_str{1})
   case 'Male',
    sex=0;
   case 'Female',
    sex=1;
  end

  analyze_mode=textread(fnm, '%*11c%s',1, 'headerlines',9,'delimiter',',');

  % skip line,11 to 19

  date=textread(fnm, '%*4c%s',1, 'headerlines',19,'delimiter',',');
    


  % == Information Only ==
  if bitget(load_lvl,2)==0
    break;
  end

  %load wave length
  [dum]=textread(fnm, '%s',adn+1, 'headerlines',21+ofst,'delimiter',',');
  for i=1:adn
    l_per=findstr(dum{i+1},'(');
    r_per=findstr(dum{i+1},')');
    in_per_num=str2double(dum{i+1}(l_per+1:r_per-1));
    wlen(i)=in_per_num;
  end
  clear dum;


  %load analog gain to each channel
  [dum]=textread(fnm, '%s',adn+1, 'headerlines',22+ofst,'delimiter',',');
  for i=1:adn
    amprng(i)=str2double(dum(i+1,:));
  end
  clear dum;

  %load digital gain to each channel
  [dum]=textread(fnm, '%s',adn+1, 'headerlines',23+ofst,'delimiter',',');
  for i=1:adn
      d_gain(i)=str2double(dum(i+1,:));
  end
  clear dum;
    
  %load sampling period[s]
  smpl_period=textread(fnm, '%*18c%f',1, 'headerlines',24+ofst,'delimiter',',');
  
  % Stimulation Information
  [dum]=textread(fnm,'%s',2,'headerlines',25+ofst,'delimiter',',');
  if strcmpi(dum{2},'EVENT')
    [dum]=textread(fnm, '%s',1,'headerlines',27+ofst,'delimiter','\n');
    [stim_timeQ,stim_time]=strread(dum{1}, '%s%d','delimiter',',');
    if length(stim_time) < 10
      stim_time(end+1:10)=0;  % Add more
    end
    clear dum;
  else
    %load stim time
    [stim_time]=textread(fnm,'%*c%d',10,'headerlines',27+ofst,'delimiter',',');
  end

  %load repeart count
  repeat=textread(fnm, '%*12c%d',1, 'headerlines',28+ofst,'delimiter',',');
  
  %load data
  % read all row as number of data
  [dum] = textread(fnm, '%c%*[^\n]','headerlines',41);
  datanum=length(dum);
  clear dum;

  %NEW
  fid=fopen(fnm);
  if 0,
	  w=waitbar(0,'Loading data ... 0%');
	  for i=1:41,fgetl(fid);end
	  f=fgetl(fid);
	  f(findstr(f,','))=' ';% delimiter change comma to space
	  sz=size(sscanf(f,'%f'),1);
	  
	  data_mark=zeros(sz,datanum);
	  data_mark(:,1) = sscanf(f, '%f');
	  for i=2:datanum
		  if mod(i/datanum,1)
			  waitbar(i/datanum,w,...
				  ['Loading data ... ' sprintf('%3.0f',i/datanum*100) '%'],...
				  ' Loading data ...');
		  end
		  f=fgetl(fid);
		  f(findstr(f,','))=' ';% delimiter change comma to space
		  data_mark(:,i) = sscanf(f, '%f');
	  end
	  close(w);
  else,
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
  end
  fclose(fid);
  data=data_mark(2:adn+1,:);
  data=data';
  stim=data_mark(adn+2,:);
  stim=stim';

  %OLD
  % 	data_mark=[];
  %     for i=2:datanum
  % 		if mod(i/datanum,1), waitbar(i/datanum,w,['Loading data ... ' sprintf('%3.0f',i/datanum*100) '%'], ' Loading data ...');end
  % 		[dum] = textread(fnm, '%f',adn+2,'headerlines',41+i,'delimiter',',');
  % 		data_mark = [data_mark,dum];
  % 		clear dum;
  %     end
  %     data=data_mark(2:adn+1,:);
  %     data=data';
  %     stim=data_mark(adn+2,:);
  %     stim=stim';
	
  %datanum=length(data);
  time=[0:smpl_period:(datanum-1)*smpl_period];
  % convert sec to msec
  smpl_period=1000*smpl_period;


  %%%%%%%%%%%% 25-Nov-2004 by M. Shoji % Read FVer 4.04 %%%%%%%%%%
  %    case 'FVer 4.04  '
 otherwise    % try :: other case 
  soft_version=line_01;

  pfnc_separetor = @tlinesep0;   % Line Separetor ( Tag & Value )

  % Other Case
  if ~strcmp(soft_version,'FVer 4.04  ')
    warning([' Unknown File Version : ' ...
	     char(soft_version) ...
	     ', Try to FVer 4.04 Mode ']);

    % Cnage Line Separetor ( Tag & Value )
    if ~isempty(strfind(char(soft_version),','))
      pfnc_separetor = @tlinesep_csv;   
    end
  end
		
  % == initialize ==
  v4_04def=1;   % 0: break by DataTable 1: break by Before Tag

		
  % Openf Figure
  fid=fopen(fnm); noticeNum=0;

  % ======= Read Header ===========
  % Here we read Head of ETG-File 
  %  Header Format is defined in following Functions
  %     [ltag, lval]=tlinesep0(tline)
  %     [ltag, lval]=tlinesep_csv(tline)
  %       --> Change to [ltag, lval]=feval(pfnc_separetor,tline);
  %  , here ltag is Data-Name  (String)
  %         lval is Data-Value (String)
  %
  %   Header Area in the File is defined by "v4_04def"
  %   If v4_04def is 0: Headder Area is Top to no ltag area
  %                  1: Break by before Data-Name
  % ================================
  try
    endflg=1;  % Ending flag
    rline=0;   % Reading Line
    while endflg
      % Read Line (& include Reading-Line)
      tline=fgetl(fid); rline=rline+1;
      
      % -- Special Case --
      if ~isstr(tline), break, end % EOF
      if isempty(tline) continue, end % Blank Line
      
      % Get Line Tag (Data-Name) & Line Value (Data-Value)
      [ltag, lval]=feval(pfnc_separetor,tline);
				
      % If no LineTag(Data-Name)
      if v4_04def==0 % 0: break by DataTable
	if isempty(ltag); eflg=0; break; end
      else           % Ignore Data-Table Line
	if isempty(ltag); continue; end
      end
      
      try
	% -- Value Transrate --
	% Switch By Data-Name,
	%    And Transrate Data^Value
	% disp(ltag);
	switch ltag
	 case 'ID',
	  % id=str2num(lval);
	  id=lval;
	 case 'Name',
	  subjectname=lval;
	 case 'Comment',
	  comment=lval;
	 case 'Age',
	  age=sscanf(lval,'%d');
	 case 'Sex',
	  sex=str2num(lval);
	 case 'Operation Mode',
	  opmode=str2num(lval);
	 case 'Analyze Mode',
	  anamode=str2num(lval);
	 case 'Meas Mode',
	  measmode=str2num(lval);
	  %%+++ Read data-block
	  %the number of colum
	  switch measmode,
	   case 1,
	    adn=48;
	    chnum=24;
	    plnum=2;
	   case 2,
	    adn=48;
	    chnum=24;
	    plnum=1;
	   case 3,
	    adn=44;
	    chnum=22;
	    plnum=1;
	  end
	  
	 case 'Display Select',
	  dspslct=str2num(lval);
	 case 'Hb Select'
	  hbslct=str2num(lval);
	 case 'Wave Select',
	  wavslct=str2num(lval);
	 case 'Time Scale',
	  timescl=str2num(lval);
	 case 'Rate',
	  rate=str2num(lval);
	 case 'Stim Select',
	  stimselect=sscanf(lval,'%d');
	 case 'Sampling Period',
	  [smpl_period, num]=sscanf(lval,'%d');
	  if num>1  % Unknoen Tag
	    OSP_LOG('note',...
		    sprintf('%s : line %d\n\t Use 1st Sampling Period(%d)\n',...
			    fnm,rline,smpl_period(1)));
	    smpl_period=smpl_period(1);
	  end
	  %     [smpl_period]=textread(fnm,'%d%*[^\n]',1,'headerlines',64,'whitespace','''');
							
	 case  'Date', 
	  % date=lval;
	  [date]=strread(tline,'%q','whitespace','''');
	  if v4_04def==1 % 1: break by Before Tag, So ignore DataTag
	    endflg=0;  % Break by Date
	  end

	 otherwise,
	  % Set other Data
	  otherData=setfield_anyway(otherData, ltag, lval,rline);
	end
      catch
	% If there is Error : Print to OSP_LOG
	noticeNum=noticeNum+1;
	OSP_LOG('note',...
		sprintf('%s : line %d\n\t %s -> cannot interpret %s''\n',...
			fnm,rline, ltag,lval));
      end
    end
  catch
    % If Error : Close File
    fclose(fid); rethrow(lasterror);
  end
        
  % == Information Only ==
  if bitget(load_lvl,2)==0
    fclose(fid);break;
  end

  % ======= Read Data-Table : mesuerment data ===========    
  % Read Data Table
  %  Data-Table(MesurementData) is matrix
  %    raw : check Line-Comment
  %    col : A/D CH(64) Data
  % =====================================================
		
  % If v4_04def is 0, tline is top of the Data Table
  if v4_04def==1
    tline=fgetl(fid); rline=rline+1;
  end
  [adnmpn]=(strread(tline,'%d','delimiter',','))'; % A/D gain order ?
  adnmpnlen = find(adnmpn==0);
  if length(adnmpnlen)>2
    adnmpn = adnmpn(1:adnmpnlen(2)-1);
  end
  if bitget(length(adnmpn),1) ~= 0
    %disp(adnmpn);
    error('Data of adnmpn  : Channel Size Error');
  end
  tline=fgetl(fid); rline=rline+1;
  [wlen]  =(strread(tline,'%f','delimiter',','))'; % wavelength
  tline=fgetl(fid); rline=rline+1;
  [adrng] =(strread(tline,'%f','delimiter',','))'; % A/D gain range
  tline=fgetl(fid); rline=rline+1;
  [amprng]=(strread(tline,'%f','delimiter',','))';  % Amplifiere gain
  
  % ======= HB Data Indexing  ===========
  % Data of 
  try
    endflg=1;  % Ending flag
    while endflg
      % Read Line & Include Reading Line
      tline=fgetl(fid); rline=rline+1;
      if ~isstr(tline), break, end % EOF
      if isempty(tline) continue, end % Blank Line
      
      % ltag(Data-Name), lval(Data-Value)
      [ltag, lval]=feval(pfnc_separetor,tline);
      if isempty(ltag); continue; end % Ignore DataTable
      
      try
	% -- Value Transrate --
	% Switch By Data-Name,
	%    And Transrate Data-Value
	% Data is not in use.. only set OtherData
	% disp(ltag);
	switch ltag
	 case 'Data Period'
	  try lval=str2num(lval);end
	  otherData=setfield(otherData,'DataPeriod',lval);
	 case 'Number of data'
	  try lval=str2num(lval);end                        
	  otherData=setfield(otherData,'NoData',lval);
	  endflg=0;  % Breake After
	 otherwise
	  % Set other Data
	  otherData=setfield_anyway(otherData, ltag, lval,rline);
	end
	
      catch
	noticeNum=noticeNum+1;
	OSP_LOG('note',...
		sprintf('s : line %d\n\t %s -> cannot interpret %s''\n',...
			fnm,rline, ltag,lval));
      end
    end
  catch
    % If Error :Close File
    fclose(fid); rethrow(lasterror);
  end
        
  % ======= Read Data-Table : HB data ===========    
  % Read Data Table
  %  Data-Table(HB Data) is matrix
  %    raw : Mesurment Case
  %    col : A/D CH(64) Data, Kind of Mark(1), Time(hhmmss)
  % =====================================================
  w=waitbar(0,'Load Data ... 0%', ...
	    'Name', ' Loading ETG File');
  datanum= otherData.NoData;
  if isempty(datanum)
    datanum=0; % not to Div 0
  end
  datanum=datanum+1;    % for ETG NoData is Number of Data +1
  try
    localTime=1; dum=zeros([66 datanum]); % for malloc
    while 1
      tline=fgetl(fid); rline=rline+1;
      if ~isstr(tline), break, end % EOF
      if isempty(tline) break, end % Blank Line is end
      try
	tline(strfind(tline,','))=' ';         % delimiter change comma to space
	dum(:,localTime) = sscanf(tline, '%f');
      catch
	break;  % not in format : break;
      end
      localTime=localTime+1;
      if mod(localTime/datanum,1)
	waitbar(localTime/datanum,w,...
		['Loading data ... ' ...
		 sprintf('%3.0f',localTime/datanum*100) '%']);
      end
    end
    
    localTime=localTime-1; % -- to delete following Note : Change -1 to -2 --
    if ~isempty(otherData) && isfield(otherData,'NoData')
      if  datanum ~= localTime
	OSP_LOG('note','Data size is not Correct');
	% / if over Remove? accept?
	% / if smaller, rethrew error? continue?
      end
    end
    dum=dum';
    data=dum(:,1:adn);
    stim=dum(:,65);%??? 
    clear dum;
  catch
    close(w); fclose(fid); rethrow(lasterror);
  end
  
  % === Exit 4.04 ===
  close(w);
  fclose(fid);
  
  % Check Out of  Format
  if noticeNum~=0
    msg.message=sprintf('Unknown Format Error\n Look Error Log ''OSPerror.log''\n');
    msg.identifier=[];
    rethrow(lasterror);
  end
  clear fid rline endflg noticeNum;
  
  %Change order of colom A/D to Meas point
  wlen=wlen(adnmpn+1);adrng=adrng(adnmpn+1);amprng=amprng(adnmpn+1);
  data=data(:,adnmpn+1);
  datanum=length(data(:,1));
  tstp=smpl_period/1000;  time=[0:tstp:(datanum-1)*tstp];
    
end %% Switch by File Version
end %% Dumy Loop ( for Switch break )
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
if bitget(load_lvl,1)==1
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

  signal.filename         = fnms;
  signal.filenametag      = {'file name of original data in OT system', ...
		    'strings'};
  signal.pathname	         = pthnm;
  signal.pathnametag	  = {'path name of original data in this PC', ...
		    'strings'};

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
  signal.sextag	           = {'sex-1:female,2:male','number'};
  
  signal.operationmode	   = opmode;
  signal.operationmodetag  = {'operation mode','no-definition'};

  % signal.analizemodetag    = {'analyze mode','no-definition'}; % not input
end

%  -- Raw Data --
%      smpl_period	: Sampling period
%      adnmpn	        : ????????????A/Dch??????/??????????????
%      wlen	        : ?????????/A/Dch???????
%      adrng	        : ???????A/Dgain[V]/A/Dch???????
%      amprng	        : ???????lockin-amp gain/A/Dch???????
%      datanum	        : ????????
%      data	        : ???
%      stim	        : stimulation timing
if bitget(load_lvl,2)==1
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
	  if regexp(date,'^\d\d\d\d/')
		   % Syle 1 ( like 2005/01/24 16:20 )
		   date0=[0 0 0 0 0 0];
		   date=strrep(date,'/',' ');date=strrep(date,':',' ');
		   date=str2num(date);
		   date0(1:length(date))=date(:);
		   signal.date= datenum(date0);
% 		  if regexp(date,'\d\d:\d\d:\d\d(\s*)$')
% 			  % with Second ( now : Fversion 4.04 ) 
% 			  try % Matlab ver 7.00
% 				  signal.date= datenum(date,'yyyy/mm/dd HH:MM:SS');
% 			  catch
% 				 date=strrep(date,'/',' ');date=strrep(date,':',' ');
% 				  signal.date= datenum(str2num(date));
% 			  end
% 		  else
% 			  try % Matlab ver 7.00
% 				  signal.date= datenum(date,'yyyy/mm/dd HH:MM');
% 			  catch
% 				 signal.date= datenum([str2num(date) 0]);
% 			  end
% 		  end
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
end

%  -- Othere --
%      otherData        : depend on File ( May be not in use )
if bitget(load_lvl,4)==1
  signal.otherData= otherData;
end

OT_LOCAL_DATA.info = signal;

% === OT_LOCAL_DATA.HBdata ===
%     HB Data  corresponding to time x channel x  HB Kind
if bitget(load_lvl,3)==1
  % HB transfer
  OT_LOCAL_DATA.HBdata     =  osp_chbtrans2(signal.data, ...
					    signal.wavelength, 5);
  OT_LOCAL_DATA.HBdataTag  =  {'a vector of Hb value before any filtering',...
		    'time','channel','hb-kind(Describe HBdata3Tag)'};
  OT_LOCAL_DATA.HBdata3Tag =  {'Oxy','Deoxy','Total'};
  OT_LOCAL_DATA.HBcolor    =  [ 1 0 0; 0 0 1; 0 0 0]; % red, blur, black


  % === OT_LOCAL_DATA.StimInfo ===
  %     StimInfo
  %  -> needless
  % OT_LOCAL_DATA.StimInfo   = makeStimData(signal.stim,1,[100 150]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Field .. anyway
%    S = setfield_with_Trans(S , 'field' , V, xnum)
%  where S, 'field', V is same as setfield
%        xnum is Specify number to make Structure
%
%  Date : 07-Jan-2005
%         M. Shoji
%%%%%%%%%%%%%%%%%%%%%%%%%%
function Strct=setfield_anyway(Strct, field0, lval, xnum);
  
  for badchar=[' ', '/', '.', '(', ')','[',']',',','&']
    delpoint=strfind(field0,badchar);
    if ~isempty(delpoint)
      field0(delpoint)=[]; % Delete
    end
  end
							
  % Error in Field Name Use Line-No for TagName
  % ( First charactor in Data-Name is numerical )
  try
    Strct=setfield(Strct,field0,lval);
  catch
    Strct=setfield(Strct,sprintf('Line%d',xnum),[field0 ' : ' lval]);
  end
  % For Debug Code
  %  noticeNum=noticeNum+1;
  %   OSP_LOG('note',sprintf('%s : line %d\n\t %s -> Unknown
  %   Tag\n', fnm,rline,field0,lval));

return;

%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Line Tag & Value
%  Read Header Format
%
% input line is
%  [Value1] ' [Name]
% 
%  Date : 25-Nov-2004 
%         M. Shoji
%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [ltag, lval]=tlinesep0(tline)            
  % -- initiarize --
  ltag=[]; lval=[]; % Set Default
  if isempty(tline), return; end  % No data

  % Search Value-Name Separator
  tagpos=strfind(tline,'''');
  if isempty(tagpos)
    lval=tline; return;  % if No name ( DataTable)
  end 

  % Get Value
  try
    lval=tline(1:tagpos(1)-1); % if tagpos(1)==1 , error but null
  end
  % Get Name
  try
    ltag=tline(tagpos(1)+1:end); % if tagpos(1)==end , error but null
  end

  if isempty(ltag), return; end

  % if you want to use csv version
  % x=strfind(lval,','); lval(x)=' ';
  % x=strfind(ltag,','); lval(x)=' ';   % warnig Check upper Switch

  % Delete Unuseful Space 
  while ltag(end)==' ', ltag(end)=[];  end 
  while ltag(1)==' ', ltag(1)=[];  end

  % ltag=upper(ltag);
return;

% for csv 
function  [ltag, lval]=tlinesep_csv(tline)
  cmm = strfind(tline,',');
  if ~isempty(cmm), tline(cmm)=' '; end
  [ltag, lval]=tlinesep0(tline);  
return;
