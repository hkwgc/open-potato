function varargout = preproTemplateSample(fcn, varargin)
%

% DO NOT EDIT START (from here to L 28)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


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
%===============================

% Do NOT EDIT END

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='Your Name Here';
basicInfo.Version  =0.0;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=getFilterSpec
% ** CREATE BASIC INFORMATION **
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={'*.txt','Text File'}; %- Your target file


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi = createBasicInfo;
dd = '$Date: 2012/02/02 00:00:00 $';
dd([1:6, end]) = [];
str={'=== Test Format ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date     : ' dd], ...
  ' ------------------------ ', ...
  '  Text Type', ...
  ' ------------------------ '};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flg, msg] = CheckFile(filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=[];
flg=true;

[pname, fname, ext] = fileparts(filename);

% Check Extension
if strcmpi(ext,{'.txt'})==0,
  % Extend
  msg='Extension Error';
  flg = false;
  return;
end

try
	%
	%- Check the file here.
	%	
catch
	flg= false;
end

if flg==false,
  msg='1st Line is not Header of ******';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str =getFileInfo(filename)
% ** get Information of file  **
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pname, fname, ext] = fileparts(filename);
str={sprintf('%s\n%s\n%s\n',pname,fname,ext)};

try
	%
	% Read header infomation here.
	% And return var:"str" as a string/cell string.
	%
	str{end+1}=[];%- for example.
	%
catch
  % If Error : Close File
  rethrow(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproFVer4_04('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[pname, fname, ext] = fileparts(filename);

%% === Make "data" =========================================
%
% Read data here.
% Make var:data as a Matrix.
% Size of "data" should be; [time, channel, type]
% Note that a length of "type" must be larger than 1.
% Or length of dimention "data" automaticaly truncated to 2 from 3.
%
data = zeros(100,10,2);%- for example.
%

%% === Make "hdata" =====================================
sz=size(data);
hdata.stimTC   = zeros(1,sz(1));%- marker info as 
hdata.StimMode = 1;%- 1:event, 2:block
hdata.stim=[1,1,1;1,4795,4795];%- [mark number, (mark type, start time, end time)]

% Using Flag, (kind, time, channel)
hdata.flag     = false([1, sz(1), sz(2)]);

% other using Data
hdata.measuremode    = -1;%- for cunstom mode
hdata.samplingperiod = 1000/samplingHz;%- (ms)

hdata.TAGs.DataTag  = {'tyoe1','type2'};%- Length of this cell must be same as size(data,3).
hdata.TAGs.filename = 'test_file.txt';%- file name
hdata.TAGs.date = datestr(now);%- date string
hdata.TAGs.ID_number=0; %- ID num
hdata.TAGs.age=0;%- age
hdata.TAGs.sex=0;%- sex 0:male, 1:female
hdata.TAGs.subjectname='who';

%- Pos: var for channel positions.
Pos = zeros(10,2);%- [channel number, (x,y)]
hdata.Pos.D2.P = Pos;
hdata.Pos.Group.ChData{1}=1:10;%- channel group.
