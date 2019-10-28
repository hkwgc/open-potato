function fullname= P3_PluginGetScript(scriptname, subscriptname,mypath)
% スクリプトプラグイン：実行ファイル名取得関数
% syntax: fullname= P3_PluginGetScript(scriptname, subscriptname)
%入力
%  scriptname   : スクリプト名 (=スクリプト・プラグイン ファイル名)
%  subscriptname: サブ関数に相当するサブスクリプト名
%出力
% fullname: フルパス ファイル名 (実際のスクリプト名)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


persistent plugin_path;
global     WinP3_EXE_PATH;
%================================================================
% 検索パス設定
%=================================================================
if isempty(plugin_path)
  osp_path=OSP_DATA('GET','OspPath');
  if isempty(osp_path)
    osp_path=fileparts(which('POTATo'));
  end
  [pp ff] = fileparts(osp_path);
  if( strcmp(ff,'WinP3')~=0 )
    plugin_path = [osp_path filesep '..' filesep 'PluginDir'];
  else
    plugin_path = [osp_path filesep 'PluginDir'];
  end
end
if isempty(WinP3_EXE_PATH)
	plugin_path2=plugin_path;
	plugin_path3=[];
else
	plugin_path2=[WinP3_EXE_PATH filesep 'PluginDir'];
	plugin_path3=[WinP3_EXE_PATH filesep 'BenriButton'];
end



%================================================================
% 本ファイル検索
%=================================================================
if nargin==3
  pth=mypath; % 設定パス (新規作成時)
else
  files=find_file(['^' scriptname '.m$'], plugin_path2,'-i');
  if isempty(files)
		if ~isempty(plugin_path3)
			files=find_file(['^' scriptname '.m$'], plugin_path3,'-i');
		end
		if isempty(files)
			files=find_file(['^' scriptname '.m$'], plugin_path,'-i');
		end
	end
	if isempty(files)
    % 見つからなかったらエラー　/ デフォルト値?
    error('No such file.');
    %pth=plugin_path;
  else
    % 複数ある場合は最初に見つかったもの
    pth=fileparts(files{1}); % パス取得
  end
end

if isempty(subscriptname)
  fname=[scriptname '.m'];
else
  fname=['P3Scrpt_' scriptname '_' subscriptname '.m'];
  pth=[pth filesep 'private'];
end

fullname=[pth filesep fname];
%-- no exist
% fullnameのファイルが実在しなくても問題なし。
%   (書き込み用途で利用することもあるので)


