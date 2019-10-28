function varargout = preproETG7000_resampling(fcn, varargin)
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

% == History ==
% ETG-7000 format loading routine
% DATE:03.02.20
% WRITTEN:Y.Inoue
%
% Inprot form Upper ot_datalod.
% create : 2005.12.21
% $Id: preproETG7000_resampling.m 180 2011-05-19 09:34:28Z Katura $

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
basicInfo.DispName ='ETG 7000 resampling';
basicInfo.Version  =1.0;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
rver = '$Revision: 0.1 $';
[s,e]= regexp(rver, '[0-9.]');
try,
  basicInfo.Version = str2num(rver(s(1):e(end)));
catch,
  basicInfo.Version =1.0;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo,
% get Information of This Function  
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  bi = createBasicInfo;
  dd = '$Date: 2006/12/19 11:44:24 $';
  dd([1:6, end]) = [];
%  str={'=== ETG 7000 Format ===', ...
%       ' Version 1.0', ...
%       ' Last Modfy : 22-Dec-2005', ...
%       ' ------------------------ ', ...
%       '  Text Type', ...
%       '  1st Line : Header ....  ', ...
%       ' ------------------------ '};
  str={'=== ETG 7000 Format ===', ...
       [' Revision : ' num2str(bi.Version)], ...
       [' Date     : ' dd], ...
       ' ------------------------ ', ...
       '  Text Type', ...
       '  1st Line : Header ....  ', ...
       ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename),
% Syntax:
%  [flag,msg] = preproETG7000('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg=[];
  [pname, fname,ext] = fileparts(filename);
  % Check Extension
  if strcmpi(ext,{'.dat', '.mea','.csv'})==0,
    % Extend
    msg='Extension Error';
    flag = false;
    return;
  end

  % Check 1st Line
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
  str ={[' Format ETG 7000 : ' filename]};
  [dum]=textread(filename,'%s',2,'headerlines',20,'delimiter',',');
  ofst=0; if strcmp(dum{1},'Mode') ofst=1; end;
  % if strcmp(dum{2},'3x3x2') measmode= 1; end % New : for yanaka
  str{end+1} = ['  Measure Mode : ' dum{2}];

  %Inisialize
  % count adnum from line,22or23
  [dum]=textread(filename, '%s%*[^\n]',1, 'headerlines',21+ofst, ...
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
  str{end+1} = ['  Channel Num : ' num2str(chnum)];

  fnpl=findstr(filename,'.');
  plnum=str2num(filename(fnpl(end)-1));
  if isempty(plnum), plnum=0;,end
  %plnum=1;
  str{end+1} = ['  Plane Num : ' num2str(plnum)];

  adnmpn=1:adn;

  for i=1:adn
    adrng(i)=2.50; % A/D gain of each channel 2.50[V]
  end

  soft_version=textread(filename, '%*12c%s',1, 'headerlines',1, ...
			'delimiter',',');
  dum=textread(filename, '%*2c%s',1, 'headerlines',3,'delimiter',',');
  id=dum{1};
  str{end+1} = ['  ID  : ' id];
  dum=textread(filename, '%*4c%s',1, 'headerlines',4,'delimiter',',');
  subjectname=dum{1};
  str{end+1} = ['  Subject Name  : ' id];
  dum=textread(filename, '%*7c%s',1, 'headerlines',5,'delimiter',',');
  comment=dum{1};
  str{end+1} = ['  Comment       : ' comment];
  age_str= textread(filename, '%*3c%s',1, 'headerlines',6,...
		    'delimiter', ',');
		    

  if(strcmp(age_str{1}(end),'y'))
    tmp=age_str{1}(1:end-1);
  else
    tmp=age_str{1};
  end
  age(1)=str2double(tmp);
  for ii=2:4
    age(ii)=0;
  end

  sex_str=textread(filename, '%*3c%s',1, 'headerlines',7,...
		   'delimiter',',');
  switch(sex_str{1})
   case 'Male',
    str{end+1} = '  SEX         : Male';
    sex=0;
   case 'Female',
    str{end+1} = '  SEX         : Female';
    sex=1;
  end

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
  [dum]=textread(filename,'%s',2,'headerlines',20,'delimiter',',');
  ofst=0; if strcmp(dum{1},'Mode') ofst=1; end;
    % Mode definition for ETG-7000
  measmode=99;
  if strcmp(dum{2},'4x4') measmode=51; end
  if strcmp(dum{2},'3x5') measmode=52; end
  if strcmp(dum{2},'5x3') measmode=53; end
  if strcmp(dum{2},'8x8') measmode=50; end
  if strcmp(dum{2},'3x11') measmode=54; end % !Add New
  % if strcmp(dum{2},'3x3x2') measmode= 1; end % New : for yanaka

  %Inisialize
  % count adnum from line,22or23
  [dum]=textread(filename, '%s%*[^\n]',1, 'headerlines',21+ofst, ...
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
  plnum=str2num(filename(fnpl(end)-1));
  if isempty(plnum), plnum=0;,end
  %plnum=1;

  adnmpn=1:adn;
  for i=1:adn
    adrng(i)=2.50; % A/D gain of each channel 2.50[V]
  end

  soft_version=textread(filename, '%*12c%s',1, 'headerlines',1, ...
			'delimiter',',');
  dum=textread(filename, '%*2c%s',1, 'headerlines',3,'delimiter',',');
  id=dum{1};
  dum=textread(filename, '%*4c%s',1, 'headerlines',4,'delimiter',',');
  subjectname=dum{1};
  dum=textread(filename, '%*7c%s',1, 'headerlines',5,'delimiter',',');
  comment=dum{1};
  age_str= textread(filename, '%*3c%s',1, 'headerlines',6,...
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

  sex_str=textread(filename, '%*3c%s',1, 'headerlines',7, ...
		   'delimiter',',');
  switch(sex_str{1})
   case 'Male',
    sex=0;
   case 'Female',
    sex=1;
  end

  analyze_mode=textread(filename, '%*11c%s',1, 'headerlines',9, ...
			'delimiter',',');

  % skip line,11 to 19

  date=textread(filename, '%*4c%s',1, 'headerlines',19,'delimiter',',');

  %load wave length
  [dum]=textread(filename, '%s',adn+1, 'headerlines',21+ofst, ...
		 'delimiter',',');
  for i=1:adn
    l_per=findstr(dum{i+1},'(');
    r_per=findstr(dum{i+1},')');
    in_per_num=str2double(dum{i+1}(l_per+1:r_per-1));
    wlen(i)=in_per_num;
  end
  clear dum;

  %load analog gain to each channel
  [dum]=textread(filename, '%s',adn+1, 'headerlines',22+ofst, ...
		 'delimiter',',');
  for i=1:adn
    amprng(i)=str2double(dum(i+1,:));
  end
  clear dum;

  %load digital gain to each channel
  [dum]=textread(filename, '%s',adn+1, 'headerlines',23+ofst, ...
		 'delimiter',',');
  for i=1:adn
      d_gain(i)=str2double(dum(i+1,:));
  end
  clear dum;

  %load sampling period[s]
  smpl_period=textread(filename, '%*18c%f',1, 'headerlines',24+ofst, ...
		       'delimiter',',');

  % Stimulation Information
  [dum]=textread(filename,'%s',2,'headerlines',25+ofst,'delimiter',',');
  if strcmpi(dum{2},'EVENT')
    StimMode = 1; % Event
    [dum]=textread(filename, '%s',1,'headerlines',27+ofst, ...
		   'delimiter','\n');
    [stim_timeQ,stim_time]=strread(dum{1}, '%s%d','delimiter',',');
    if length(stim_time) < 10
      stim_time(end+1:10)=0;  % Add more
    end
    clear dum;
  else
    StimMode = 2; % Block
    %load stim time
    [stim_time]=textread(filename,'%*c%d',10,'headerlines',27+ofst, ...
			 'delimiter',',');
  end


  %load repeart count
  repeat=textread(filename, '%*12c%d',1, 'headerlines',28+ofst, ...
		  'delimiter',',');

  %load data
  % read all row as number of data
  [dum] = textread(filename, '%c%*[^\n]','headerlines',41);
  datanum=length(dum);
  clear dum;
  %NEW
  fid=fopen(filename);
  try,
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
  
  % modified by TK 061219
  % revisec by TH 061226
  % get time from time stamp in data-file which describe (ms) time
  %
  t1=data_mark(adn+3,:)*60*60+data_mark(adn+4,:)*60+data_mark(adn+5,:); % time in second
  t=t1-t1(1);
  t1=[0:0.1:length(t)/10-0.1];
  %t=t*1000;
  h = waitbar(0,'Resampling data. Please wait...');
  for i=1:size(data,2);
	  waitbar(i/size(data,2),h,sprintf('Resampling data. Please wait... %d/%d',i,size(data,2)))
	  a=data(:,i)';
      
      t0=(find(diff(t)~=0));
      a=a([1 t0(1:end-1)+1]);      
      t=t([1 t0(1:end-1)+1]);
      
	  a1=interp1(t,a,t1);
	  data(:,i)=a1';
  end  
  close(h)
  time=[0:smpl_period:(datanum-1)*smpl_period];
  %tktktktktktktktktktktktktktktk
	  
	  
  
  % convert sec to msec
  smpl_period=1000*smpl_period;

%% Dumy Loop ( for Switch break )==>
SCRIPT_OTDATALOAD;
return;


