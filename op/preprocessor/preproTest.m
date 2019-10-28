function varargout = preproFVer4_04(fcn, varargin)
% Preprocessor Function of FVer 4.04 Fromat: Normal..
%   This Format Read FVer4_04.
%   And Plug-in Format Version 1.0
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproFVer4_04('createBasicInfo');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproFVer4_04('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproFVer4_04('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproFVer4_04('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproFVer4_04('Execute', filename)
%  Continuous Data.
%
%  OT_LOCAL_DATA = preproFVer4_04('ExecuteOld', filename)
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
% FVer4.04 format loading routine
% DATE:03.02.20
% WRITTEN:Y.Inoue
%
% Inprot form Upper ot_datalod.
% create : 2005.12.21
% $Id: preproFVer4_04.m 180 2011-05-19 09:34:28Z Katura $

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
%  basic_info = preproFVer4_04('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='FVer 4.04';
basicInfo.Version  =1.0;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
rver = '$Revision: 1.11 $';
[s,e]= regexp(rver, '[0-9.]');
try
  basicInfo.Version = str2num(rver(s(1):e(end)));
catch
  basicInfo.Version =1.0;
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=getFilterSpec
% ** CREATE BASIC INFORMATION **
% Syntax:
%  filterspec = getFilterSpec;
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*.dat; *.mea; *.csv;','ETG Text File';...
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
dd = '$Date: 2009/03/11 14:08:57 $';
dd([1:6, end]) = [];
%  str={'=== FVer 4.04 Format ===', ...
%       ' Version 1.0', ...
%       ' Last Modfy : 22-Dec-2005', ...
%       ' ------------------------ ', ...
%       '  Text Type', ...
%       '  1st Line : Header ....  ', ...
%       ' ------------------------ '};
str={'=== FVer 4.04 Format ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date     : ' dd], ...
  ' ------------------------ ', ...
  '  Text Type', ...
  '  1st Line : Fver 4.04 ....  ', ...
  ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = preproFVer4_04('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=[];
[pname, fname, ext] = fileparts(filename);
% Check Extension
if strcmpi(ext,{'.dat', '.mea','.csv'})==0,
  % Extend
  msg='Extension Error';
  flag = false;
  return;
end

% Check 1st Line
line_01=textread(filename,'%s%*[^\n]',1,'whitespace','''');
% disp(line_01);
% disp(line_01{1});
flag = strncmp(line_01{1},'FVer 4.04',9);
if flag==false,
  msg='1st Line is not Header of FVer 4.04';
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
str={[' Format FVer 4.04 : ' filename]};

pfnc_separetor = @tlinesep0;   % Line Separetor ( Tag & Value )

% == initialize ==
v4_04def=1;   % 0: break by DataTable 1: break by Before Tag

% Openf Figure
fid=fopen(filename); noticeNum=0;

% ======= Read Header ===========
% Here we read Head of FVer4.04
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
    if isempty(tline), continue, end % Blank Line

    % Get Line Tag (Data-Name) & Line Value (Data-Value)
    [ltag, lval]=feval(pfnc_separetor,tline);

    % If no LineTag(Data-Name)
    if v4_04def==0 % 0: break by DataTable
      if isempty(ltag), eflg=0; break; end
    else           % Ignore Data-Table Line
      if isempty(ltag), continue; end
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
          measstr=lval;
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
              filename,rline,smpl_period(1)));
            smpl_period=smpl_period(1);
          end
          %     [smpl_period]=textread(filename,'%d%*[^\n]',1,'headerlines',64,'whitespace','''');

        case  'Date',
          % date=lval;
          [date]=strread(tline,'%q','whitespace','''');
          if v4_04def==1 % 1: break by Before Tag, So ignore DataTag
            endflg=0;  % Break by Date
          end

        otherwise,
          % Set other Data
          % otherData=setfield_anyway(otherData, ltag, lval,rline);
      end
    catch
      % If there is Error : Print to OSP_LOG
      noticeNum=noticeNum+1;
      OSP_LOG('note',...
        sprintf('%s : line %d\n\t %s -> cannot interpret %s''\n',...
        filename,rline, ltag,lval));
    end
  end
catch
  % If Error : Close File
  fclose(fid); rethrow(lasterror);
end
fclose(fid);

if ~isempty(measstr),
  str{end+1} = ['  Measure Mode : ' measstr];
  str{end+1} = ['  Channel Num : '  num2str(chnum)];
  str{end+1} = ['  Plane Num : '    num2str(plnum)];
end
if ~isempty(id),          str{end+1} = ['  ID  : ' id] ;end
if ~isempty(subjectname), str{end+1} = ['  Subject Name  : ' subjectname];end
if ~isempty(comment),     str{end+1} = ['  Comment       : ' comment];end
if ~isempty(age),         str{end+1} = ['  Age       : '     num2str(age(1))];end
if ~isempty(sex),
  switch(sex)
    case 0,
      str{end+1} = '  SEX         : Male';
      %sex=0;
    case 1,
      str{end+1} = '  SEX         : Female';
      %sex=1;
  end
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproFVer4_04('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data =ExecuteOld(filename);
[data,hdata]=ot2ucdata(data);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OT_LOCAL_DATA =ExecuteOld(filename)
%  OT_LOCAL_DATA = preproFVer4_04('ExecuteOld', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get pathname
[pathname, fname, ext] = fileparts(filename);

%line_01=textread(filename,'%s%*[^\n]',1,'whitespace','''');
soft_version=textread(filename,'%s%*[^\n]',1,'whitespace','''');

pfnc_separetor = @tlinesep0;   % Line Separetor ( Tag & Value )

% == initialize ==
v4_04def=1;   % 0: break by DataTable 1: break by Before Tag
otherData=[];

% Openf Figure
fid=fopen(filename); noticeNum=0;

% ======= Read Header ===========
% Here we read Head of FVer4.04 File
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
    if isempty(tline), continue, end % Blank Line

    % Get Line Tag (Data-Name) & Line Value (Data-Value)
    [ltag, lval]=feval(pfnc_separetor,tline);

    % If no LineTag(Data-Name)
    if v4_04def==0 % 0: break by DataTable
      if isempty(ltag), eflg=0; break; end
    else           % Ignore Data-Table Line
      if isempty(ltag), continue; end
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
              filename,rline,smpl_period(1)));
            smpl_period=smpl_period(1);
          end
          %     [smpl_period]=textread(filename,'%d%*[^\n]',1,'headerlines',64,'whitespace','''');

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
        filename,rline, ltag,lval));
    end
  end
catch
  % If Error : Close File
  fclose(fid); rethrow(lasterror);
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
    if isempty(tline), continue, end % Blank Line

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
        filename,rline, ltag,lval));
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
  'Name', ' Loading FVer4.04 File');
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
    if isempty(tline), break, end % Blank Line is end
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
  msg.message=sprintf('Unknown Format Error\n Look Error Log'' ''OSPerror.log''\n');
  msg.identifier=[];
  rethrow(lasterror);
end
clear fid rline endflg noticeNum;

%Change order of colom A/D to Meas point
adnmpn(adnmpn<0)=[];
wlen=wlen(adnmpn+1);adrng=adrng(adnmpn+1);amprng=amprng(adnmpn+1);
data=data(:,adnmpn+1);
datanum=length(data(:,1));
tstp=smpl_period/1000;  time=[0:tstp:(datanum-1)*tstp];

%% Dumy Loop ( for Switch break )==>
SCRIPT_OTDATALOAD;
return;

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
d=strfind('1234567890_',field0(1));
if ~isempty(d),
  field0=['F_' field0];
end

% Error in Field Name Use Line-No for TagName
% ( First charactor in Data-Name is numerical )
try
  Strct=setfield(Strct,field0,lval);
catch
  Strct=setfield(Strct,sprintf('Line%d',xnum),[field0 ' : ' ...
    lval]);
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
