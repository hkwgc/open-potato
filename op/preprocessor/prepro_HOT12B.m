function varargout = prepro_HOT12B(fcn, varargin)
% Hitachi HOT121B Data Format ファイル: POTATo 読込関数
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% ============= History ===============
%   original author : Shoji
%   Creat Date: 30-Jan-2014


%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    % Basic Information
    varargout{1} = createBasicInfo;
  case 'CheckFile'
    [varargout{1:nargout}] = CheckFile(varargin{:});
  case 'getFunctionInfo'
    varargout{1} = getFunctionInfo;
  case 'getFileInfo'
    % Filename to message
    varargout{1} =getFileInfo(varargin{:}); % Mesage
  case 'Execute'
    %[hdata, data] =Execute(filename)
    [varargout{1:nargout}] = Execute(varargin{:});
  case 'getFilterSpec'
	  varargout{1}={'*.csv', 'HOT12B-CSV Files'};
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  basicInfo= createBasicInfo
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = prepro_Personal('createBasicIno');
%    Return Information for OSP Application.
%    basic_info is structure that fields are
%       DispName : Display Name : String
%       Version  : Version of the function
%       OpenKind : Kind of Open Function
%       IO_Kind  : Kind of I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.DispName ='HOT12B';
% get Revistion
rver = '$Revision: 1.1 $';
[s,e]=regexp(rver,'[0-9.]');
try
  basicInfo.Version = str2double(rver(s(1):e(end)));
catch
  basicInfo.Version = 1.0;
end
basicInfo.OpenKind =1;
basicInfo.IO_Kind  =1;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  str = getFunctionInfo
% get Information of This Function
%     str          : Information of the function.
%                    Cell array of string.
% レガシーコード？
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi=createBasicInfo;
str={'=== HOT121  ===', ...
  [' Revision : ' num2str(bi.Version)], ...
  ' Date      : 2014-01-40', ...
  ' ------------------------ ', ...
  '  Text Type', ...
  '  Extension : .csv  ....  ', ...
  ' ------------------------ '};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flg, msg] = CheckFile(filename)
% Syntax:
%  [flag,msg] = prepro_Personal('CheckFile',filename)
%     flag : true  :  In format (Available)
%            false :  Out of Format.
%     msg  : if false, reason why Out of Format.
%     filename     : Full-Path of the File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flg=true;msg='';
% TODO:
% 拡張子，ファイルヘッダ，バージョンのチェック
%[p, f,ext] = fileparts(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg =getFileInfo(filename)
% ** get Information of file  **
% Syntax:
%  str =
%     str          : File Infromation.
%                    Cell array of string.
%     filename     : Full-Path of the File.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open File
fp = fopen(filename,'r');
msg=cell(1,26);
warning off REGEXP:multibyteCharacters
for i=1:26
	try
		msg{i}  =fgetl(fp);
  catch
  %catch ME
    %fprintf(2,'%s\n',ME.message);
    fprintf(2,'%s\n',lasterr);
	end
end
fclose(fp);
msg(3:23)=[];
warning on REGEXP:multibyteCharacters

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdata, data] =Execute(filename)
% ** execute **
% Syntax:
%  [hdata, data] = prepro_Personal('Execute',  filename)
%  Continuous Data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open File
fid = fopen(filename,'r');
warning off REGEXP:multibyteCharacters
try
  [hdata,data]=FileRead(fid);
  %[p,f,e]=fileparts(filename);
  [p,f,e]=fileparts(filename);
  hdata.TAGs.filename    = [f e];
  hdata.TAGs.pathname    = p;
%catch ME
catch
  fclose(fid);
  warning on REGEXP:multibyteCharacters
  %rethrow(ME);
  rethrow(lasterror);
end
fclose(fid);
warning on REGEXP:multibyteCharacters

%%
function [header,data]=FileRead(fid)
% Read Real ....

%====================
% ヘッダ取得
%====================
fhd  = fgetl(fid); % % #Hitachi HOT121B Data Format
ver  = fgetl(fid); % #Ver 1.20
ver  = str2double(ver(5:end));

% マーク関連情報 (読み飛ばし)
while 1
	s=fgetl(fid);
	if s==-1, break;end % 完了
	if ~strncmpi('#prop',s,5) % #prop Mark000_Common:1
    break;
  end
end
hd=s; % 時系列のヘッダのはず

% ヘッダチェック
if ~strcmpi('#時刻,脳血流(左),脳血流(左1cm),脳血流(左3cm),脳血流(右),脳血流(右1cm),脳血流(右3cm),脈拍(左),脈拍(右),LF/HF(左),LF/HF(右),温度,X軸角度,Y軸角度,Z軸角度,深呼吸デキ度,チャートX軸,チャートY軸,チャート象限,チャート円半径,マーキング(1～32)',hd)
  % ファイルを厳密にチェックする場合  エラー
  fprintf(2,'ファイルフォーマットが期待しているものでない可能性があります\n');
end

%====================
% データ読み込み
%====================
fmt='%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n';
[tmp, cnt]=fscanf(fid,fmt);
nn=cnt/52;
xx=reshape(tmp,[52,nn]); % 行列に直す

% 仮解釈
tim = xx(1,:);                      % 1行目 = 時間
d=xx(2:2+6-1,:)';
d=reshape(d,[nn,3,2]);
data=permute(d,[1 3 2]); % 2～7　　脳血流
ot=xx(8:20,:)';                   % 8～20 脈拍(左),脈拍(右),LF/HF(左),LF/HF(右),温度,X軸角度,Y軸角度,Z軸角度,深呼吸デキ度,チャートX軸,チャートY軸,チャート象限,チャート円半径,
ottag='脈拍(左),脈拍(右),LF/HF(左),LF/HF(右),温度,X軸角度,Y軸角度,Z軸角度,深呼吸デキ度,チャートX軸,チャートY軸,チャート象限,チャート円半径';
mk=xx(21:end,:)';             %マーキング(1～32)'
clear xx

%====================
% 刺激設定
%====================
header.stim      = [];
% header.stim(:,1) = 1;
% header.stim(:,2) = stim(:);
% header.stim(:,3) = stim(:);
% set stimTC
header.stimTC = zeros(1,size(data,1));
for  ii=1:32
  stm=find(mk(:,ii)); % マークの有無チェック
  if isempty(stm)
    continue;
  end
  header.stimTC(stm)=ii;
end
stim=find(header.stimTC);
header.stim=[header.stimTC(stim)', stim',stim'];
% header.stimTC(stim)=1;

% set stimMode
header.StimMode = 1;    % 1=Event

%====================
% Position
%====================
header.measuremode=-1;
p.ver=2;
pos=zeros(2,2);
%pos(:,1)=(pos(:,1)-7.5)*10;
%pos(:,2)=(pos(:,2)-4.5)*20;
pos(1,1)=10;
pos(2,1)=-pos(1,1);

p.D2.P=pos;
p.D3.P=zeros(size(data,2),3); % zero
p.D3.Base.Nasion=[0 0 0];
p.Group.ChData={1:size(data,2)};
p.Group.mode=199;
p.Group.OriginalCh={1:size(data,2)};
header.Pos = p;

%-----------
% set flag
%-----------
header.flag     = false([1, size(data,1), size(data,2)]);

%--------------------
% set sampling_period
%--------------------
header.samplingperiod =  round(1000*(tim(end)-tim(1))/(length(tim)-1)); % msec

%-----------
% set TAGs
%-----------
% 脳血流(左),脳血流(左1cm),脳血流(左3cm),脳血流(右),脳血流(右1cm),脳血流(右3cm),
tags.DataTag     = {'Hb','Hb1cm','Hb3cm'}; % Meeting 14-Jan-2014
tags.filename    = 'test';
tags.pathname    = 'test';
tags.ID_number   = sprintf('%s(ver% 5.2f)',fhd,ver);
tags.age=0;                              % set suitably
tags.sex=1;                                 % set suitably,Male
tags.subjectname = 'anonymity';             % set suitably
tags.comment     = '';
tags.date        = now;
% Back-up Raw Data (if you want)
if 1
  % 脈波
  tags.DataTag{4}='m';
  data(:,:,4)=ot(:,1:2);
  % LF/HF
  tags.DataTag{5}='LF/HF';
  data(:,:,5)=ot(:,3:4);
  tags.HOT121Bdata      = ot(:,5:end); 
  tags.HOT121Btag        = '温度,X軸角度,Y軸角度,Z軸角度,深呼吸デキ度,チャートX軸,チャートY軸,チャート象限,チャート円半径';
else
  tags.HOT121Bdata      = ot; 
  tags.HOT121Btag        = ottag; 
end
header.TAGs = tags;

%-----------
% Add : Member-Information
%-----------
MemberInfo = struct( ...
  'stim', ['Stimulation Data, ' ...
  '(Number of Stimulation, ' ...
  '[kind, start, end])'], ...
  'stimTC', ['Stimulation Timeing, ' ...
  '(1, time)'], ...
  'StimMode', ['Stimulation Mode, ' ...
  '1:Event, 2:Block'], ...
  'flag',  ['Flags, (kind, time, ch),  ' ...
  ' Now kind is only one, if 1, then Motion occur'], ...
  'measuremode', ' Measure Mode of ETG', ...
  'samplingperiod', 'sampling period [msec]', ...
  'TAGs', 'Other Data', ...
  'MemberInfo', 'This Data, Header fields Information');
header.MemberInfo = MemberInfo;
