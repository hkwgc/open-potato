function varargout = preproOSP_SPDATAv1(fcn, varargin)
% Preprocessor Function of Signal Data of OSP version 1.xx
%   This Format read HB-Data of OSP version 1.xx
%    Make OSP Signal Data of version 1.00  by File-Name.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = preproOSP_SPDATAv1('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%
% ** Check If the file is in format. **
% Syntax:
%  [flag,msg] = preproOSP_SPDATAv1('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%
% ** get Information of file  **
% Syntax:
%  str = preproOSP_SPDATAv1('getFileInfo',filename);
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%
% ** get Information of This Function  **
% Syntax:
%  str = preproOSP_SPDATAv1('getFunctionInfo')
%     str          : Information of the function.
%                    Cell array of string.
%
% ** execute **
% Syntax:
%  [hdata, data] = preproOSP_SPDATAv1('Execute', filename)
%  Continuous Data.
%
%
% ==== Additional Functions =====
% ** get Version of OSP SP File **
% Syntax:
%  [ver,msg] = preproOSP_SPDATAv1('getVer',filename)
%     ver : Version of OSP
%            -1   : Out of Format
%             0   : Version 0
%             1   : Version 1
%             2   : Version 2
%
%     msg : if Out-Of-Format, reason why Out of Format.
%     filename     : Full-Path of the File
%
% See also :
%          SIGNAL_PREPROCESSOR,
%          OTSIGTRANSCHLD2,
%
%          DATADEF_SIGNAL_PREPROCESSOR,
%          OLDDATALOAD,
%          OT2UCDATA,
%
%          PREPROSZ,
%          PREPROETG7000,
%          PREPROFVER2_02,
%          PREPROFVER3_02,
%          PREPROFVER4_04.



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% OSP Signal Data Load
%   create : 2006.01.06
%
%  Import date : 23-Dec-2005.
%
% Now Version :
% $Id: preproOSP_SPDATAv1.m 214 2011-06-22 05:42:05Z Katura $
%
% Revision 1.1:
%    Inport from ot_dataload
%    Modify : for OSP version 2.0
% Revision  1.2:
%    Bug fix : reversion to revision
% Revision  1.3:
%    Add some comments.


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
%  basic_info = preproOSP_SPDATAv1('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='OSP/POTATo Data';
rver = '$Revision: 1.8 $';
[s,e]=regexp(rver,'[0-9.]');
try
  basicInfo.Version = str2double(rver(s(1):e(end)));
catch
  basicInfo.Version = 1.0;
end
basicInfo.OpenKind  = 1;
basicInfo.IO_Kind   = 1;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=getFilterSpec
% ** CREATE BASIC INFORMATION **
% Syntax:
%  filterspec = getFilterSpec;
%    Return FilterSpec of File-Select-Dilalogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs={...
  's_*.mat; RAW_*.mat; HB_*.mat;','P3 Files';...
  's_*.mat', 'VER0.x Signal Data'; ...
  'HB_*.mat', 'VER1.0 Signal Data'; ...
  'RAW_*.mat', 'P3 Data'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi=createBasicInfo;
dd= '$Date: 2007/09/05 11:58:07 $';
dd([1:6, end] ) = [];
str={'=== OSP Signal Data Version 0.0-1.8 ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  [' Date      : ' dd], ...
  ' ------------------------ ', ...
  '  Type      : Mat-File ( -V6 ) ', ...
  '  Extension : .mat  ....  ', ...
  ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flag, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = preproOSP_SPDATAv1('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ver, msg] = getVer(filename);
if (ver>=0),
  flag=true;
else
  flag=false;
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ver, msg] = getVer(filename)
% Syntax:
%  [ver,msg] = preproOSP_SPDATAv1('getVer',filename)
%     ver : Version of OSP
%            -1   : Out of Format
%             0   : Version 0
%             1   : Version 1
%             2   : Version 2
%
%     msg : if Out-Of-Format, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ver    = -1;
msg    = '';

% Check Version 0.xx
old_v0 = regexpi(filename,'[\\\/]s_(.*)[.]mat$');
if ~isempty(old_v0),
  warning off all;
  try
    S=whos('-file',filename);nm={S.name};
    if ~any(strcmpi(nm,'signal')),
      ver=0;
    else
      msg='Version 0 : signal-Data missing';
      ver=-1;
    end
  catch
    msg = 'Version 0 : Internal Error Occur!';
  end
  warning on all;
  return;
end

% Check Version 1.xx
old_v1 = regexpi(filename,'[\\\/]HB_(.*)[.]mat$');
p3_v1  = regexpi(filename,'[\\\/]RAW_(.*)[.]mat$');
if ~isempty(old_v1) || ~isempty(p3_v1)
  warning off all;
  try
    S=whos('-file',filename);
    nm={S.name};
    % Check Version 1.0-1.70
    if any(strcmpi(nm,'OSP_LOCALDATA')),
      ver =1;
    elseif any(strcmpi(nm,'OSP_SP_DATA_VER')) && ...
        any(strcmpi(nm,'data')) && ...
        any(strcmpi(nm,'header')),
      %ver = S.OSP_SP_DATA_VER;
      load(filename,'OSP_SP_DATA_VER');
      ver=OSP_SP_DATA_VER;
      if all(ver~=[1,2,3]),
        msg=['Unknown Version : ' num2str(ver)];
        ver = -1;
      end
    else
      msg = 'Version 1-2 : Some Variables missing.';
    end
  catch
    msg = 'Version 1-2 : Internal Error Occur!';
    ver=-1;
  end
  warning on all;
  return;
end

% Out of File-Name Definition
msg=['File Name : ' filename ' : Out of Format.'];
ver=-1;
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
msg = {' -- OSP Signal Data --'};
[ver, msg2] = getVer(filename);
[pname, fname,ext] = fileparts(filename);
fnm    =[fname ext];

msg{end+1} = sprintf(' File Name    : %s',fnm);
msg{end+1} = sprintf(' File Version : %d',ver);
if ~isempty(msg2),
  msg{end+1} = sprintf(' File Error   : %s',msg2);
  return;
end
try
  [hdata, data] =Execute(filename);
catch
  msg{end+1} = sprintf(' Execute Error: %s',lasterr);
  return;
end

msg{end+1} = sprintf(' Measure Mode : %d',hdata.measuremode);
try
  c = OspDataFileInfo(0,1,hdata.TAGs);
  msg={msg{:}, c{:}};
catch
  msg{end+1}=sprintf(' ==Information Error ==: %s',lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [header, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = preproOSP_SPDATAv1('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ver, msg] = getVer(filename);
if ~isempty(msg), error(msg); end
switch ver,

  case 0,
    % === Version 0 File ==
    % Ver 0 File to Ver 1
    data = OldDataLoad(filename, 0);
    % Ver 1 to Ver 2
    [data,header]=ot2ucdata(data);

  case 1,
    % === Version 1 File ==
    % Load Ver 1 Data
    S=load(filename);
    % Ver 1 to Ver 2
    if isfield(S,'Position'),
      [data,header]=ot2ucdata(S.OSP_LOCALDATA,...
        'Position', S.Position);
    else
      [data,header]=ot2ucdata(S.OSP_LOCALDATA,'Position');
    end
  case {2,3}
    % === Version 2 File ==
    % Load Ver 2 File
    load(filename);
  otherwise,
    % Undefind Name
    error(['Undefined Version ' num2str(ver)]);
end
return;
