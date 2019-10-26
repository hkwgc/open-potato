function varargout = preproFVer2_02(fcn, varargin)
% Preprocessor Function of FVer 2.02 Fromat: Normal..
%   This Format Read FVer2_02.
%   And Plug-in Format Version 1.0 
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproFVer2_02('createBasicInfo');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproFVer2_02('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproFVer2_02('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproFVer2_02('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproFVer2_02('Execute', filename)
%  Continuous Data. 
%
%  OT_LOCAL_DATA = preproFVer2_02('ExecuteOld', filename)
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
% FVer2.02 format loading routine
% DATE:03.02.20
% WRITTEN:Y.Inoue
%
% Inprot form Upper ot_datalod.
% create : 2005.12.21
% $Id: preproFVer2_02.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo,
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproFVer2_02('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='FVer 2.02';
basicInfo.Version  =1.0;
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
% get Revision
rver = '$Revision: 1.6 $';
[s,e]= regexp(rver, '[0-9.]');
try,
  basicInfo.Version = str2num(rver(s(1):e(end)));
catch,
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
function  str = getFunctionInfo,
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  bi = createBasicInfo;
  dd = '$Date: 2007/09/05 11:58:07 $';
  dd([1:6, end]) = [];
%  str={'=== FVer 2.02L Format ===', ...
%       ' Version 1.0', ...
%       ' Last Modfy : 22-Dec-2005', ...
%       ' ------------------------ ', ...
%       '  Text Type', ...
%       '  1st Line : Header ....  ', ...
%       ' ------------------------ '};
  str={'=== FVer 2.02L Format ===', ...
       [' Revision : ' num2str(bi.Version)], ...
       [' Date     : ' dd], ...
       ' ------------------------ ', ...
       '  Text Type', ...
       '  1st Line : Fver 2.02 ....  ', ...
       ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename),
% Syntax:
%  [flag,msg] = preproFVer2_02('CheckFile',filename)
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
  flag = strncmp(line_01{1},'FVer 2.02L',10);
  if flag==false,
    msg='1st Line is not Header of FVer 2.02L';
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
  str={[' Format FVer 2.02L : ' filename]};

  pfnc_separetor = @tlinesep0;   % Line Separetor ( Tag & Value )

 %%+++Read Header
  [dum]=textread(filename,'%s%*[^\n]',3,'headerlines',1,'whitespace', ...
		 '''');
  id=dum{1}(1:end-1);subjectname=dum{2}(1:end-1);comment=dum{3}(1: ...
						  end-1);

  clear dum;

  [dum]=textread(filename,'%d%*[^\n]',11,'headerlines',4,'whitespace', ...
		 '''');
  age(1)=dum(1);age(2)=0;age(3)=0;age(4)=0;
  sex=dum(2);opmode=dum(3);anamode=dum(4);measmode=dum(5);
  dspslct=dum(6);hbslct=dum(7);wavslct=dum(8);timescl=dum(9);rate= ...
	  dum(10);
  stimselect(1)=dum(11);stimselect(2)=0;
  clear dum;

  [smpl_period]=textread(filename,'%d%*[^\n]',1,'headerlines',84, ...
			 'whitespace','''');

  [date]=textread(filename,'%q%*[^\n]',1,'headerlines',155, ...
		  'whitespace','''');
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

  [adnmpn]=(textread(filename,'%d',adn,'headerlines',156,  'delimiter',', '))';
  [wlen]=(textread(filename,'%20f',adn,'headerlines',157,  'delimiter',', '))';
  [adrng]=(textread(filename,'%20f',adn,'headerlines',158, 'delimiter',', '))';
  [amprng]=(textread(filename,'%20f',adn,'headerlines',159,'delimiter',', '))';

  if ~isempty(measmode), 
%    str{end+1} = ['  Measure Mode : ' measstr];
    str{end+1} = ['  Measure Mode : ' num2str(measmode)];
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
%  [hdata, data] = preproFVer2_02('Execute',  filename)
%  Continuous Data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data =ExecuteOld(filename);
  [data,hdata]=ot2ucdata(data);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OT_LOCAL_DATA =ExecuteOld(filename)
%  OT_LOCAL_DATA = preproFVer2_02('ExecuteOld', filename)
%  OT_LOCAL_DATA : Version 1.5 Inner Data-Format.
%  Thsi will be removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % get pathname 
 [pathname, fname, ext] = fileparts(filename);

  %line_01=textread(filename,'%s%*[^\n]',1,'whitespace','''');
  soft_version=textread(filename,'%s%*[^\n]',1,'whitespace','''');

  pfnc_separetor = @tlinesep0;   % Line Separetor ( Tag & Value )

 %%+++Read Header
  [dum]=textread(filename,'%s%*[^\n]',3,'headerlines',1,'whitespace', ...
		 '''');
  id=dum{1}(1:end-1);subjectname=dum{2}(1:end-1);comment=dum{3}(1: ...
						  end-1);

  clear dum;

  [dum]=textread(filename,'%d%*[^\n]',11,'headerlines',4,'whitespace', ...
		 '''');
  age(1)=dum(1);age(2)=0;age(3)=0;age(4)=0;
  sex=dum(2);opmode=dum(3);anamode=dum(4);measmode=dum(5);
  dspslct=dum(6);hbslct=dum(7);wavslct=dum(8);timescl=dum(9);rate= ...
	  dum(10);
  stimselect(1)=dum(11);stimselect(2)=0;
  clear dum;

  [smpl_period]=textread(filename,'%d%*[^\n]',1,'headerlines',84, ...
			 'whitespace','''');

  [date]=textread(filename,'%q%*[^\n]',1,'headerlines',155, ...
		  'whitespace','''');
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

  [adnmpn]=(textread(filename,'%d',adn,'headerlines',156,  'delimiter',', '))';
  [wlen]=(textread(filename,'%20f',adn,'headerlines',157,  'delimiter',', '))';
  [adrng]=(textread(filename,'%20f',adn,'headerlines',158, 'delimiter',', '))';
  [amprng]=(textread(filename,'%20f',adn,'headerlines',159,'delimiter',', '))';

  [dum]=textread(filename,'%20f','headerlines',163,'delimiter',',');
  dum=(reshape(dum,[66,length(dum)/66]))';
  data=dum(:,1:adn);
  stim=dum(:,65);%??? Only-stim_select=4 => Kawasaki Check!
  clear dum;

  %Change order of colom A/D to Meas point
  wlen=wlen(adnmpn+1);adrng=adrng(adnmpn+1);amprng=amprng(adnmpn+ ...
						  1);data=data(:,adnmpn+1);
  datanum=length(data(:,1));tstp=smpl_period/1000;time=[0:tstp:(datanum-1)*tstp];

%% Dumy Loop ( for Switch break )==>
SCRIPT_OTDATALOAD;
return;
