function P3_PluginFunction2Script(plugindir)
% プラグイン関数をスクリプト形式に変換するプログラム


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% 基本設定
%-------------------
logname='transPluginScript';

% 引数
%-------------------
if nargin<1
  % デバッグ
  %disp('デバッグコード');
  %disp(C__FILE__LINE__CHAR);
  %plugindir='C:\Users\Katura\Desktop\shoji\P38_20140203\PluginDir\EvalString';
  %plugindir='D:\shoji\P38_Source\PluginDir\EvalString';
  plugindir=uigetdir;
  if isequal(plugindir,0)
    return;
  end
end
[s m]=mkdir(plugindir,'private');
if s==false
  myfprint(2,'[E] %s\n',m);
  return;
end

% ログファイル名
%-------------------
fid_mlog = fopen([plugindir filesep logname '.log'],'w');
if (fid_mlog==-1)
  myfprint(2,'Can not make Logfile [%s]\n',[plugindir filesep logname '.log']);
  return;
end

try
  % 1.スクリプトリスト(slist)作成
  %-------------------------------
  d=dir([plugindir filesep '*.m']);

  myfprint(fid_mlog,'-- Function List ---\n');
  slist=struct([]);
  for ii=1:length(d)
    d0=d(ii);
    % 変換ファイル/関数名情報取得
    [msg, sdata]=getFname(plugindir, d0);
    % 対象外？
    if isempty(sdata)
      if msg
        % エラー？
        myfprint(-fid_mlog,'[Error] %s :%s\n',d0.name, msg);
      end
      continue;
    end
    
    % リストに追加
    if isempty(slist)
      slist=sdata;
    else
      slist(end+1)=sdata; %#ok<AGROW>
    end
    myfprint(fid_mlog,'* %s to %s\n',sdata.oldfname1,sdata.newfname1);
  end


  % 2.各関数ループ
  %-------------------------------
  for ii=1:length(slist)
    myfprint(fid_mlog,'\n********************************\n');
    myfprint(fid_mlog,'[Function] %s\n',slist(ii).newfname1);
    myfprint(fid_mlog,'********************************\n');
    msg=transfile(plugindir,slist,ii,fid_mlog);
    if msg
      myfprint(-fid_mlog,' [E] transfile %s\n',msg);
    end
	end

	% 結果をzip化
	%-------------------------------
	% 注意: CDが必要のため CDの Overwriteは許されない
		myfprint(fid_mlog,'\n********************************\n');
	myfprint(fid_mlog,' Make Zip-File\n');
	p0=pwd;
	if p0(1)=='.'
		warning('Do not make zip, because "cd" is overwitten.');
		fclose(fid_mlog);
		return;
	end
	cd(plugindir);
	[px, f]=fileparts(plugindir);
	zipname=[plugindir filesep f '.zip'];
	myfprint(fid_mlog,' Filename : %s\n',zipname);
	myfprint(fid_mlog,'********************************\n');
	
	fs={};
	for ii=1:length(slist)
		fs{end+1}=[slist(ii).newfname1 '.m'];
		myfprint(fid_mlog,' [%d] %s\n',length(fs),slist(ii).oldfname0);
	end
	f0=find_file('P3Scrpt_[\w\W]*.m', [plugindir filesep 'private'],'-i');
	for ii=1:length(f0)
		f=strrep(f0{ii},plugindir,'.');
		fs{end+1}=f;
		myfprint(fid_mlog,' [%d] %s\n',length(fs),f0{ii});
	end
	zip(zipname, fs);
	delete(fs{:});
	cd(p0);

catch
  myfprint(-fid_mlog,'[E] %s\n',lasterr);
end
fclose(fid_mlog);



%##########################################################################
% ツール
%##########################################################################
function cn=myfprint(fid0,fmt,varargin)
% メッセージ出力関数
%==========================================================================

fid=abs(fid0);
% 通常出力
cn=fprintf(fid,fmt,varargin{:});

% 標準エラー出力まではお終い。
if fid<=2
  return;
end

% 標準出力にも印字
if fid0<0
  fprintf(2,fmt,varargin{:});
else
  fprintf(1,fmt,varargin{:});
end


%##########################################################################
% ファイル命名規則
%##########################################################################
function [msg, sdata]=getFname(pdir,d0)
% ファイル名変換規則
%==========================================================================
msg=[];

% スクリプトヘッダは P3_PluginEvalScript にも反映させる必要がある。
headname1='PlugInWrapPS1_';  % スクリプト・プラグイン
headname2='P3Scrpt_';        % 通常のスクリプト

% ファイル種類分け
oldf = d0.name(1:end-2);

% 置換済みのファイル?
%-------------------
if strncmpi(headname1,d0.name,length(headname1)) || ...
    strncmpi(headname2,d0.name,length(headname2))
  % 変換対象でない/エラーでない
  sdata=[];
  return;
end

% sdata初期化
%-------------
sdata.type    =0;
sdata.oldfname1=oldf;
sdata.oldfname0=[pdir filesep d0.name];
sdata.newfname1=[headname2 oldf];

% プラグイン関数の場合はtype,newfname1更新
wk='pluginwrap_';
if strncmpi(wk,d0.name,length(wk))
  sdata.type=1;
  sdata.newfname1=[headname1 oldf(length(wk)+1:end)];
end
wk='pluginwrapp1_';
if strncmpi(wk,d0.name,length(wk))
  sdata.type=1;
  sdata.newfname1=[headname1 oldf(length(wk)+1:end)];
end

% 新しいファイルのフルパス
sdata.newfname0=[pdir filesep sdata.newfname1 '.m'];

%##########################################################################
% 読込ツール
%  cmd=myfgetcmd(fid) :  "..." で連結される行を結合し MATLABの1行をとりだす。
%                        空白行は飛ばす
%  myfbuf             : mygfgetcmdで読み込んだが、出力していない行を管理
%      line=myfbuf('get')  :  myfbuf内の行を取得
%      myfbuf('put',line)  :  myfbuf内に行を登録
%      myfbuf('clear')     :  myfbufをクリア
%      myfbuf('flush',fid) :  myfbufをクリア
%##########################################################################

function cmd=myfgetcmd(fid)
%  "..." で連結される行を結合し MATLABの1行をとりだす。
%==========================================================================
cmd   = [];

while 1
  % 1行読込 & Buf 登録
  %--------
  tline = fgetl(fid);
  if ~ischar(tline)
    break; % EOF?
  end
  myfbuf('put',tline);
  
  % 空行?
  %--------
  s=regexp(tline,'\S', 'once'); % 非空白文字
  if isempty(s) 
    % 空行： 初回読み飛ばし
    if  isempty(cmd)
      continue;
    end
    % 2回目以降　終了 (通常ありえない)
    break;
  end
  
  % 継続行？
  %--------
  s=regexp(tline,'\.\.\.\s*$', 'once'); % ...
  if isempty(s)
    % 継続行でない
    s=regexp(tline,'\S','once');
    cmd=[cmd tline(s(1):end)]; % 結合
    break;
  end
  
  d=regexp(tline,'\S','once');
  cmd=[cmd tline(d(1):s(1)-1)];
end

function line=myfbuf(cmd,arg1)
% mygfgetcmdで読み込んだが、出力していない行を管理
%==========================================================================
persistent mybuf;
switch cmd
  case 'clear',
    mybuf=[];
  case 'get',
    if isempty(mybuf)
      line=[];
    else
      line=mybuf{1};
      mybuf(1)=[];
    end
  case 'put'
    line=arg1;
    if isempty(mybuf)
      mybuf={line};
    else
      mybuf{end+1}=line;
    end
  case 'flush'
    fid=arg1;
    for ii=1:length(mybuf)
      fprintf(fid,'%s\n',mybuf{ii});
    end
    mybuf=[];
end

%##########################################################################
% パースツール
%   t =iscommentline(str):　コメント行判定 (空白もコメントとみなす)
%   kw=getKeyWords(str):    str中で使われているキーワードを取得
%  [name, vin, vout]=myParseFunction(cmd): 関数を取得する
%##########################################################################
function c=cellcell2cell(cc)
% regexpのtokens の結果 cellのcell配列を、cellに変更する

% 空？
if isempty(cc)
  c={};
  return;
end

c=cell([1,length(cc)]);
% 変換
for ii=1:length(cc)
  if iscell(cc{ii})
    c(ii)=cc{ii};
  else
    % cell-cellでない場合の対応(今のところ通らない)
    c(ii)=cc(ii);
  end
end


function t=iscommentline(str)
% コメントラインか否かの判定
%==========================================================================
t=true;
% 最初の空白以外の文字を取得
[s e]=regexpi(str,'^\s*\S','once');
if isempty(e)
  % 空白行
  return; % true扱い
end
if str(e)=='%'
  return;
end
t=false;

function kw=getKeyWords(str,flg)
% str中で使われているキーワードを取得
%==========================================================================
if nargin<2
  flg=false;
end

if flg
  % コーテーション部分を除く
  s=regexp(str,'''');
  idx=[];
  for ii=2:2:length(s)
    idx=[idx s(ii-1):s(ii)];
  end
  str(idx)=[];
end
[kw s t]=regexp(str,'[\W]*([a-zA-Z]\w*)[\s,]*','tokens');
kw=cellcell2cell(kw);

function [name, vin, vout]=myParseFunction(str0)
% 関数宣言を解釈し、関数名, 入力/出力引数
%==========================================================================
name=[];vin=[];vout=[];
str=str0;  % デバッグ用に str0は保存

% 関数 ?
[s e]=regexpi(str,'^\s*function\s+');
if isempty(s)
  return;
end

str=str(e:end);
% 出力
s=regexp(str,'=','once');
if ~isempty(s)
  outstr=str(1:s(1)-1);
  str   =str(s(1)+1:end);
  vout=regexp(outstr,'\s*([a-zA-Z]\w*)[\s,]*','tokens');
  vout=cellcell2cell(vout);
end

% 名前
s=regexp(str,'\(','once');
if isempty(s)
  name=str;
  s=regexp(name,'[a-zA-Z]','once');
  name=name(s(1):end);
  return;
end
name=str(1:s(1)-1);
s0=regexp(name,'[a-zA-Z]','once');
name=name(s0(1):end);
str=str(s(1):end);

s=regexp(str,'\)','once');
str=str(1:s(1));
% 入力
vin=regexp(str,'\s*([a-zA-Z]\w*)[\s,]*','tokens');
vin=cellcell2cell(vin);

%##########################################################################
% 変換
%##########################################################################
function msg=transfile(plugindir,slist,ii,fid_mlog)
% 1ファイル変換メイン
%==========================================================================
sdata=slist(ii);

% 各種チェック
if exist([sdata.oldfname1 '.fig'],'file')
  %myfprint(fid_mlog,' [W] Figを含むファイルです。動作しない場合があります.\n',slist(ii).newfname1)
	myfprint(fid_mlog,' [W] M-File, named %s, include ".fig" file.\n',slist(ii).newfname1)
end

fid_in =fopen(sdata.oldfname0,'r');
fid_out=fopen(sdata.newfname0,'w');
try
  
  % 関数
  % * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

  % ヘッダ処理
  %------------------------------------------------------------------------
  [msg vout ssdata]=makeHead(fid_mlog,fid_in,fid_out);
  if msg
    error(['makeHead:' msg]);
  end
   
  
  % サブ関数リストの作成
  %------------------------------------------------------------------------
  [msg sslist]=getSubfunc(fid_mlog,fid_in, ssdata);
  if msg
    error(['getSubfunc:' msg]);
  end

  % メイン関数: ボディ
  %------------------------------------------------------------------------
  msg=makeBody0(fid_mlog,fid_in, fid_out,slist,ii,sslist);
  
  % 出力引数を設定する
  %------------------------------------------------------------------------
  msg=makeFoot(fid_out,vout);
  if msg
    error(['makeFoot:' msg]);
  end
  fclose(fid_out);fid_out=-1;

  % サブ関数
  % * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
  disp(C__FILE__LINE__CHAR);
  for ii2=2:length(sslist)
    try
      msg=makeSubfunction(fid_mlog,fid_in, slist,ii,sslist,ii2);
    catch
      msg=lasterr;
      myfprint(-fid_mlog,'[E] subfunction\t%s\n',msg);
    end
  end
  
catch
  msg=lasterr;
  myfprint(-fid_mlog,'[E] transfile:main-function\n\t%s\n',msg);
  msg=[];
  % 終了処理
  fclose(fid_in);
  if (fid_out~=-1)
    fclose(fid_out);
  end
  delete(sdata.newfname0);
  return;
end
if (fid_out~=-1)
  fclose(fid_out);
end
fclose(fid_in);
return;


function  [msg vout ssdata]=makeHead(fid_mlog,fid_in,fid_out)
% ヘッダ
%   引数解釈をし，vin1, vin2,,, 
%   出力用データとして　voutを作成する
%==========================================================================
msg=[];
myfbuf('clear');

% 初期化
ssdata.subfname='';
ssdata.fpos_st =-1;
ssdata.fpos_ed =-1;
ssdata.vin		 =[];
ssdata.vout		 =[];
ssdata.cmd      ='';

% 関数名取得
%----------------
while 1
  fpos=ftell(fid_in);
  cmd=myfgetcmd(fid_in);
  % コメントは出力して次へ
  if iscommentline(cmd)
    myfbuf('flush',fid_out);
    continue;
  end
  % 関数パース
  [name, vin, vout]=myParseFunction(cmd);
  if isempty(name)
    % そもそもスクリプト？
    msg=['Function Parse Error:' cmd];
    return;
  end
  ssdata.subfname=name;
  ssdata.fpos_st =ftell(fid_in);
  ssdata.vin     =vin;
  ssdata.vout    =vout;
  ssdata.cmd     =cmd;
  myfbuf('clear');
  func=cmd;
  break;
end

% ヘルプコメント出力
%----------------
while 1
  fpos=ftell(fid_in); % 最後の位置
  cmd=myfgetcmd(fid_in);
  % コメントは出力して次へ
  if iscommentline(cmd)
    myfbuf('flush',fid_out);
    continue;
  end
  break;
end
fprintf(fid_out,'\n%% %s\n%% converted by\n%%   $Id: $\n%%   Date: %s\n',...
  func,datestr(now));

ssdata.fpos_st =fpos; % 特殊!! 次回ここから出力
ssdata.fpos_ed =fpos;

msg=makeHead0(fid_out,vin);

function msg=makeHead0(fid_out,vin)
% 入力引数解釈
% See also : P3_PluginEvalScript/fevalScriptMCR
%==========================================================================
msg=[];
% インデント用スペース
if nargin<3 
  indentstr='';
end

fprintf(fid_out,'\n');
fprintf(fid_out,'\n%% Input Variable\n');
fprintf(fid_out,'nargin=nin;\n');
for ii=1:length(vin)
  if strcmpi('varargin',vin{ii})
    fprintf(fid_out,'varargin=cell(1,nin-%d+1);\n',ii);
    fprintf(fid_out,'for ii=%d:nin\n',ii);
    fprintf(fid_out,'  varargin{ii-%d+1}=eval(sprintf(''vin%%d'',ii));\n',ii);
    fprintf(fid_out,'end\n');
    break;
	else
		fprintf(fid_out,'if nin>=%d\n',ii);
    fprintf(fid_out,'  %s\t= vin%d;\n',vin{ii},ii);
		fprintf(fid_out,'end\n');
  end
end
fprintf(fid_out,'\n');

function  [msg sslist]=getSubfunc(fid_mlog,fid_in, ssdata)
% サブ関数リストを取得する
%==========================================================================
msg=[];
sslist=ssdata;

% 頭だし
fpos=ssdata.fpos_ed;
fseek(fid_in,fpos,'bof');
myfbuf('clear');

% 初期化 (定義)
ssdata.subfname='';
ssdata.fpos_st =-1;
ssdata.fpos_ed =-1;
ssdata.vin		 =[];
ssdata.vout		 =[];
ssdata.cmd     ='';
% 関数名取得
%----------------
while 1
  fpos=ftell(fid_in);
  % 1行読込
  cmd=myfgetcmd(fid_in);
  if isempty(cmd)
    sslist(end).fpos_ed=fpos;
    break;
  end
  
  % 関数パース
  [name, vin, vout]=myParseFunction(cmd);
  if isempty(name)
    % 関数?
    continue;
  end
  
  % 関数リスト追加
  ssdata.subfname=name;
  ssdata.fpos_st =ftell(fid_in);
  ssdata.vin     =vin;
  ssdata.vout    =vout;
  ssdata.fpos_ed =-1;
  ssdata.cmd     =cmd;
  sslist(end).fpos_ed=fpos;
  sslist(end+1)=ssdata;
  myfbuf('clear');
   
  myfprint(fid_mlog,'\tsubfunction : %s(at%d)\n',cmd,ssdata.fpos_st);
  
end

function msg=makeBody0(fid_mlog,fid_in, fid_out,slist,sid,sslist)
% メイン化数のボディ部分
%==========================================================================
msg=[];
% 頭だし
ssdata=sslist(1);
fpos=ssdata.fpos_st;
fseek(fid_in,fpos,'bof');
myfbuf('clear');

% 読み込み/変換
%----------------
while 1
  fpos=ftell(fid_in);
  % 関数終了?
  if fpos >= ssdata.fpos_ed;
    break;
  end

  cmd=myfgetcmd(fid_in);
  % コメントは出力して次へ
  if iscommentline(cmd)
    myfbuf('flush',fid_out);
    continue;
  end

  % キーワード置換
  %----------------
  %myfprint(fid_mlog,'[DBG] %s\n',cmd);
  % キーワードリスト取得
  kw=getKeyWords(cmd,true); % 文字列部分無視
	
	% return (単体行)
	if length(kw)==1 && strcmpi(kw{1},'return')
		s=regexpi(cmd,'return');
		if s(1)~=1
			msg=makeFoot(fid_out,ssdata.vout,cmd(1:s(1)-1));
		else
			msg=makeFoot(fid_out,ssdata.vout);
		end
		if msg
			error(['makeFoot:' msg]);
		end
		myfprint(fid_mlog,'[LOG] Add output-variable-setting before return-statement.\n',cmd);
		myfbuf('flush',fid_out);
		continue;
	end
	
		cmdX=cmd;
  ischange=false;
  
  for ii=1:length(kw)
    %myfprint(fid_mlog,'     %s\n',kw{ii});
    % メイン関数では feval を置換
    if strcmpi(kw{ii},'feval')
      ischange=true;
      [s e]=regexpi(cmdX,'feval[\s]*\(');
      if ~isempty(s)
        cmdX=[cmdX(1:s(1)-1) ...
          sprintf('P3_PluginEvalScript(''%s'',',slist(sid).newfname1)...
          cmdX(e(1)+1:end)];
      end
    end
    
    % 親関数
    idx=find(strcmpi(kw{ii},{slist.oldfname1}));
    if ~isempty(idx)
      ischange=true;
      cmdX=strrep(cmdX,kw{ii},slist(idx(1)).newfname1);
    end
    
    % サブ関数
    if any(strcmpi(kw{ii},{sslist.subfname}))
      ischange=true;
      [s e]=regexpi(cmdX,[kw{ii} '[\s]*\(']);
      if isempty(s)
        cmdX=strrep(cmdX,kw{ii},...
          sprintf('P3_PluginEvalScript(''%s'',''%s'')',...
          slist(sid).newfname1,kw{ii}));
      else
        cmdX=[cmdX(1:s(1)-1) ...
          sprintf('P3_PluginEvalScript(''%s'',''%s'',',...
          slist(sid).newfname1,kw{ii}) ...
          cmdX(e(1)+1:end)];
      end
		end

			% mfilename
			if strcmpi(kw{ii},'mfilename')
				ischange=true;
				[s, e]=regexpi(cmdX,[kw{ii} '[\s]*\([\w\W]\)']);
				if isempty(s)
					cmdX=strrep(cmdX,kw{ii},'myScriptName');
				else
					% 引数無視して置き換え
					if e(1)<length(cmdX)
						cmdX=[cmdX(1:s(1)-1) 'myScriptName' cmdX(e(1)+1:end)];
					else
						cmdX=[cmdX(1:s(1)-1) 'myScriptName'];
					end
				end
			end
			
			% return
			if strcmpi(kw{ii},'return')
				% 前後で改行できるはず
				ischange=true;
				[s, e]=regexpi(cmdX,[kw{ii} '[\s;]']);
				% 前半出力
				fprintf(fid_out,'%s\n',cmdX(1:s(1)-1));

				% Footer出力
				makeFoot(fid_out,ssdata.vout,'  ');
				fprintf(fid_out,'  return;\n');
				
				% 後半はそのまま
				if e(1)<length(cmdX)
					cmdX=cmdX(e(1)+1:end);
				else
					cmdX='';
				end
			end
		
  end
  
  if ischange
    % 変換文字列を出力
    fprintf(fid_out,'%s\n',cmdX);
    myfbuf('clear',fid_out);
    myfprint(fid_mlog,'[LOG] Change-Line\n      %s\n      -> %s\n',cmd,cmdX);
  else
    % 単純にフラッシュして次へ
    myfbuf('flush',fid_out);
    continue;
  end
end


function msg=makeFoot(fid_out,vout,indentstr)
% フッタ
%   出力引数を設定する
%   出力用データとして　voutを作成する
%==========================================================================
msg=[];
% インデント用スペース
if nargin<3 
  indentstr='';
end

% 出力引数の解釈
%----------------------
% See also : P3_PluginEvalScript/fevalScriptMCR
fprintf(fid_out,'\n%% Output Variable\n');
for ii=1:length(vout)
  
  if strcmpi('varargout',vout{ii})
    fprintf(fid_out,'%sfor ii=%d:nout\n',indentstr,ii);
    fprintf(fid_out,'%s  eval(sprintf(''vout%%d=varargout{ii-%d+1};'',ii));\n',indentstr,ii);
    fprintf(fid_out,'%send\n',indentstr);
    break;
  else
    fprintf(fid_out,'%svout%d\t= %s;\n',indentstr,ii,vout{ii});
  end
end
fprintf(fid_out,'\n');


function msg=makeSubfunction(fid_mlog,fid_in, slist,sid,sslist,ssid)
% サブ関数の出力
%==========================================================================
msg=[];

% 読込ファイル頭だし
ssdata=sslist(ssid);
fpos=ssdata.fpos_st;
fseek(fid_in,fpos,'bof');
myfbuf('clear');

ignoreStringFlg=true;
squot   =''''; % シングルコーテーション 文字列
if strcmpi(ssdata.subfname,'write')
  ignoreStringFlg=false;
  squot   =''''''; % シングルコーテーション 文字列
end
% 出力ファイル
fullname= P3_PluginGetScript(slist(sid).newfname1, ssdata.subfname,...
	fileparts(slist(sid).newfname0));
fid_out=fopen(fullname,'w');

try
  myfprint(fid_mlog,'\n--------------------------------\n');
  myfprint(fid_mlog,'[sub-function] %s(%s)\n',ssdata.subfname,fullname);
  myfprint(fid_mlog,'--------------------------------\n');

  fprintf(fid_out,'%% [Syntax] %s\n',ssdata.cmd);

  % ヘッダ
  msg=makeHead0(fid_out,ssdata.vin);
  if msg
    error(['makeHead0:' msg]);
  end

  % メイン部分

  % 読み込み/変換
  %----------------
  while 1
    fpos=ftell(fid_in);
    % 関数終了?
    if fpos >= ssdata.fpos_ed;
      break;
    end

    cmd=myfgetcmd(fid_in);
    % コメントは出力して次へ
    if iscommentline(cmd)
      myfbuf('flush',fid_out);
      continue;
    end

    % キーワード置換
    %----------------
    %myfprint(fid_mlog,'[DBG] %s\n',cmd);
    % キーワードリスト取得
    kw=getKeyWords(cmd,ignoreStringFlg); % 文字列部分無視

		% return (単体行)
		if length(kw)==1 && strcmpi(kw{1},'return')
			s=regexpi(cmd,'return');
			if s(1)~=1
				msg=makeFoot(fid_out,ssdata.vout,cmd(1:s(1)-1));
			else
				msg=makeFoot(fid_out,ssdata.vout);
			end
			if msg
				error(['makeFoot:' msg]);
			end
			myfprint(fid_mlog,'[LOG] Add output-variable-setting before return-statement.\n',cmd);
			myfbuf('flush',fid_out);
			continue;
		end
		
    cmdX=cmd;
    ischange=false;
    for ii=1:length(kw)
      %myfprint(fid_mlog,'     %s\n',kw{ii});

			% 親関数
			idx=find(strcmpi(kw{ii},{slist.oldfname1}));
			if ~isempty(idx)
				ischange=true;
				%cmdX=strrep(cmdX,kw{ii},slist(idx(1)).newfname1);
				[s, e]=regexpi(cmdX,['\{[\s]*@' kw{ii} '[\s]*,']);
				if ~isempty(s)
					% @関数
					cmdX=[cmdX(1:s(1)-1) ...
						'{@P3_PluginEvalScript,' ...
						sprintf('%s%s%s,[]',...
						squot,slist(idx(1)).newfname1,squot) ...
						cmdX(e(1):end)];
				else
					[s, e]=regexpi(cmdX,[kw{ii} '[\s]*\(']);
					if isempty(s)
						cmdX=strrep(cmdX,kw{ii},...
							sprintf('P3_PluginEvalScript(%s%s%s,[])',...
							squot,slist(idx(1)).newfname1,squot));
					else
						if e(1)<length(cmdX)
							cmdX=[cmdX(1:s(1)-1) ...
								sprintf('P3_PluginEvalScript(%s%s%s,[],',...
								squot,slist(idx(1)).newfname1,squot) ...
								cmdX(e(1)+1:end)];
						else
							cmdX=[cmdX(1:s(1)-1) ...
								sprintf('P3_PluginEvalScript(%s%s%s,[],',...
								squot,slist(idx(1)).newfname1,squot)];
						end
					end
				end
			end

      % サブ関数
			if any(strcmpi(kw{ii},{sslist.subfname}))
				ischange=true;
				[s, e]=regexpi(cmdX,['\{[\s]*@' kw{ii} '[\s]*,']);
				if ~isempty(s)
					% @関数
					cmdX=[cmdX(1:s(1)-1) ...
						'{@P3_PluginEvalScript,' ...
						sprintf('%s%s%s,%s%s%s',...
						squot,slist(sid).newfname1,squot,squot,kw{ii},squot) ...
						cmdX(e(1):end)];
				else
					[s, e]=regexpi(cmdX,[kw{ii} '[\s]*\(']);
					if isempty(s)
						cmdX=strrep(cmdX,kw{ii},...
							sprintf('P3_PluginEvalScript(%s%s%s,%s%s%s)',...
							squot,slist(sid).newfname1,squot,squot,kw{ii},squot));
					else
						if e(1)<length(cmdX)
							cmdX=[cmdX(1:s(1)-1) ...
								sprintf('P3_PluginEvalScript(%s%s%s,%s%s%s,',...
								squot,slist(sid).newfname1,squot,squot,kw{ii},squot) ...
								cmdX(e(1)+1:end)];
						else
							cmdX=[cmdX(1:s(1)-1) ...
								sprintf('P3_PluginEvalScript(%s%s%s,%s%s%s,',...
								squot,slist(sid).newfname1,squot,squot,kw{ii},squot)];
						end
					end
				end
			end
			
			% mfilename
			if strcmpi(kw{ii},'mfilename')
				ischange=true;
				[s, e]=regexpi(cmdX,[kw{ii} '[\s]*\([\w\W]\)']);
				if isempty(s)
					cmdX=strrep(cmdX,kw{ii},'myScriptName');
				else
					% 引数無視して置き換え
					if e(1)<length(cmdX)
						cmdX=[cmdX(1:s(1)-1) 'myScriptName' cmdX(e(1)+1:end)];
					else
						cmdX=[cmdX(1:s(1)-1) 'myScriptName'];
					end
				end
			end
			
			% return
			if strcmpi(kw{ii},'return')
				% 前後で改行できるはず
				ischange=true;
				[s, e]=regexpi(cmdX,kw{ii});
				% 前半出力
				fprintf(fid_out,'%s\n',cmdX(1:s(1)-1));
				

				% Footer出力
				sini=repmat(' ',1,s(1));
				makeFoot(fid_out,ssdata.vout,sini);
				
				% 後半はそのまま
				if e(1)<length(cmdX)
					
					cmdX=cmdX(e(1)+1:end);
				else
					cmdX='';
				end
			end

    end

    if ischange
      % 変換文字列を出力
      fprintf(fid_out,'%s\n',cmdX);
      myfbuf('clear',fid_out);
      %myfprint(fid_mlog,'[LOG] 変換実行\n      %s\n      -> %s\n',cmd,cmdX);
			myfprint(fid_mlog,'[LOG] Change Line\n      %s\n      -> %s\n',cmd,cmdX);
    else
      % 単純にフラッシュして次へ
      myfbuf('flush',fid_out);
      continue;
    end
  end % 読込ループ

  % フッタ
  msg=makeFoot(fid_out,ssdata.vout);
  if msg
    error(['makeFoot:' msg]);
  end
catch
  myfprint(-fid_mlog,'[E] %s\n',lasterr);
  msg='in makeSubfunction';
end
fclose(fid_out);

if 0
  edit(fullname);
end



