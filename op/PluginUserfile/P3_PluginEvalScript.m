function varargout= P3_PluginEvalScript(scriptname, subscriptname,varargin)
% スクリプトプラグイン用：実行関数
%
% syntax: varargout= P3_PluginEvalScript(scriptname, subscriptname,varargin)
% -------------------------------------------------------------------------
% scriptname: ファイル名
% subscriptname: サブ関数名: 通常 "createBasicInfo"など
%  (通常のスクリプトも実効可能)


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% 変更履歴
%  2014.03.12: 新規作成 MS

%----------------------
% 引数無し ：通常の feval
%----------------------
if nargin==1
  if nargout,
    [varargout{1:nargout}]=feval(scriptname);
  else
    feval(scriptname);
  end
  return;
end

%----------------------
% 特殊 Callback 経由
%----------------------
if ishandle(scriptname)
  % !!-- バージョン依存する可能性有り --!!
  a=scriptname;
  b=subscriptname;
  scriptname=varargin{1};
  subscriptname=varargin{2};
  varargin{1}=a;
  varargin{2}=b;
  %varargin(1:2)=[];
end

%----------------------
% Feval で実行
%----------------------
isnormal=true;
% 関数ポインタ?
if ischar(scriptname)
  % *** MCR 用の配布スクリプト　？ ****** (スクリプト作成ツールと合わせる)
  wk='PlugInWrapPS1_';
  if strncmpi(wk,scriptname,length(wk))
    isnormal=false; % プラグイン
  end
  % *** MCR 用の配布スクリプト　？ ****** (スクリプト作成ツールと合わせる)
  wk='P3Scrpt_';
  if strncmpi(wk,scriptname,length(wk))
    isnormal=false; % スクリプト
  end
end

%----------------------
% Feval で実行
%----------------------
if isnormal 
  if nargout,
    [varargout{1:nargout}]=feval(scriptname,subscriptname,varargin{:});
  else
    feval(scriptname,subscriptname,varargin{:});
  end
  return;
end


%================================================================
% 検索パス設定
%=================================================================
fullname= P3_PluginGetScript(scriptname, subscriptname);

% スクリプト実行
if nargout
  [varargout{1:nargout}]=fevalScriptMCR(fullname,nargout,varargin{:});
else
  fevalScriptMCR(fullname,nargout,varargin{:});
end

%=================================================================
function varargout = fevalScriptMCR(fname,nout,varargin)
% スクリプト実行
%    fname のスクリプトをvarargin/varargoutで実行する。
%=================================================================
if nargin<2,
  error('too few arguments');
end

myScriptName=fname;
vai0=varargin;
%vao0=varargout;
nin=length(varargin);
for ii=1:nin
  % vin1=varargin{1};
  % vin2=varargin{2}; ....
  eval(sprintf('vin%d=varargin{%d};',ii,ii));
end

% ファイル読込
[fd,msg]=fopen(fname,'r');
if(msg), error(msg);end
try
  c_s = fread(fd,inf,'*char');
  fclose(fd);
catch
  fclose(fd);
  rethrow(lasterror);
end

% 実行
%  -- 該当ファイルの入力 --
%    nin   = 入力引数の数
%    vin1  = 第一引数…
%    nout  = 出力変数の数
%  -- 該当ファイルの出力 --
%    vout1 = 第一出力引数: …
eval(c_s);

% 結果出力
for tmp_loop_index_xx__ = 1: nout
  voutstr=sprintf('vout%d',tmp_loop_index_xx__);
  if exist(voutstr,'var'),
    varargout{tmp_loop_index_xx__} = eval(voutstr);
  else
    fprintf(2,'[%s]\n\t[Warn] varargout error in %s\n',fname,voutstr);
    disp(C__FILE__LINE__CHAR);
    varargout{tmp_loop_index_xx__} = [];
  end
end

return;

