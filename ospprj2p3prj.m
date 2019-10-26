function ospprj2p3prj(dir)
% OSP プロジェクトを P3 プロジェクトにインポートする関数です。
%
% Syntax : 
%    ospprj2p3prj(dir)
% 変数：
%    dir : OSP-Project 検索用 Directory
% -------------------------------------------------------------------------
% 詳細な使い方は 別ファイル『プロジェクトの引継ぎ.ppt』をご参照ください。
% -------------------------------------------------------------------------
% Known Bugs:
%    データが小さい場合, まれにSignal-Dataの読込みが失敗する。
%      発生の条件:
%       1秒以内にロード・保存が実行でき、
%       randを２回連続して行った結果, 小数点以下第2位まで一致したとき。
%
% -------------------------------------------------------------------------
% See also : OSPPROJECT, POTATOPROJECT,
%            DATADEF_GROUPDATA,
%            DATADEF2_RAWDATA,
%            DATADEF2_ANSLYSIS.
%
% * OSPは国内利用しかされていないため 日本語 コメントにしております。
%

 
% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2007.04.11
% $Id: ospprj2p3prj.m 180 2011-05-19 09:34:28Z Katura $

% バグ修正履歴：
% ----------------
% Revision 1.01: Shoji 2007/04/12
% ----------------
% 2007.04.10 の電話／メールから着手:
% OSPプロジェクトをP3に移す仕組み。
%
% ①レシピ（FilterData)のコピー
% ②GroupData ⇒Raw＋Ana
%
% 複数ファイルからなる GroupDataはMultiMode にて対応する。
%  今回は保留 で　〆: 2007.04.13 (朝の打合せまで)
%
% ----------------
% Revision 1.02: Shoji  2007/04/12
% ----------------
% Signal-Dataの読込み追加
%
% ----------------
% Revision 1.03: Shoji  2007/04/23
% ----------------
% GroupData読込み失敗で終了するバグを修正。
%  (Tsuzuki指摘バグ修正)
%
% ----------------
% Revision 1.04: Shoji 2007/05/17
% ----------------
% 複数ファイルからなる GroupData⇒ Multi Modeにて読込み。
% ヘルプコメント変更
% 
%


%%%%%%%%%%%%%%%%%%%%
% P3 の起動 
%  現在のProject Directory取得
%  パス/関数の初期化
%%%%%%%%%%%%%%%%%%%
h      =P3;
handles=guidata(h);
pdir  = OSP_DATA('get','PROJECTPARENT');
if isempty(pdir)
  %=======================
  % Project Parent の設定
  % (もしなければ）
  %=======================
  if isempty(pdir),pdir=pwd;end
  pdir = uigetdir(pdir,'Select Project Directory');

  % Cancel Check
  if isequal(pdir,0),return;end
  % Change Project-Parent-Directory
  POTATo('ChangeProjectParentIO',h,pdir,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Searching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------
% Open Search Files
%-------------------
if nargin<1 || ~exist(dir,'dir')
  dir=uigetdir(pwd,'Search Directory');
  if isequal(dir,0),return;end
end

%-------------------
% Search OspDir
%-------------------
rslt=find_file('^OspDataDir$',dir,'-i');

%-------------------
% Loging A
%-------------------
fname=[pwd filesep 'ospprj2p3prj_find.html'];
fp=openhtml(fname);
fprintf(fp,'<H1>Find Files</H1><br>\n');
fprintf(fp,'&nbsp;<H2>Search Dirs:</H2><br>\n');
fprintf(fp,'&nbsp;&nbsp;%s<br>\n',dir);
fprintf(fp,'&nbsp;<H2>Found Project:</H2><br>\n');
rslt_bk=rslt;
for id=1:length(rslt)
  rslt{id}(end-10:end)=[];
  fprintf(fp,'&nbsp;&nbsp;%s<br>\n',rslt{id});
end
closehtml(fp);
helpview(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Each Dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> こっからが本番でーす。
for id=1:length(rslt)
  prj0=OspProject('GetProjectDataInDir',rslt{id});
  %===================================
  % TODO : 選択されている Projectの表示：
  %===================================
  % とりあえず、べろっと標準出力に
  disp('Import P-3 Project from..');
  s=OspProject('Info',prj0);
  disp(char(s));
  disp('');

  %===================================
  % 新 Projectの作成 (いれもの作成）
  %===================================
  uiPOTAToProject('Action','New');
  % Change Project!
  prj=OSP_DATA('GET','PROJECT');
  % Cancel : とばしまーす。
  if isempty(prj), continue;end
  % TODO : コピー先の表示
  %        ... GUI化する？ (工数 2 hourぐらいで見積もり可能そうなら)
  disp('Import Project :');
  s=POTAToProject('Info',prj);
  disp(char(s));
  disp('');
  
  %===================================
  % 必要な情報をとってきておく
  %===================================
  cp_from= rslt_bk{id};
  cp_to  = [prj.Path filesep prj.Name];
  
  %===================================
  % れしぴ(Filter Data)のこぴー
  %===================================
  f=[filesep 'DataListFilterData.mat'];
  if exist([cp_from f],'file')
    [r,msg]=copyfile([cp_from f],[cp_to f]);
    if ~r ,
      fprintf('  XXX Could not Import Filter Data : %s\n',msg);
    else
      fprintf('  ==> Import Filter Data\n');
    end
  else
    fprintf('  --- No Filter Data\n');
  end
  
  %===================================
  % Group Data の登録
  %===================================
  % + + + + + + + + + + + + + + 
  % 一旦、OSPのプロジェクトをセット
  % + + + + + + + + + + + + + + 
  OSP_DATA('SET','PROJECT',prj0);
  gdlist = DataDef_GroupData('loadlist');
  % 保存時のファイル命名規則：(警告をださないため)
  OSP_DATA('SET','SP_Rename','-');
  namelist={}; % GDで保存される名前リスト
  
  for gid=1:length(gdlist)
    % + + + + + + + + + + + + + + 
    % 一旦、OSPのプロジェクトをセット
    % + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj0);

    try
      gd=DataDef_GroupData('load',gdlist(gid));
      fprintf(' * try to Import Group Data Named : %s\n',gd.Tag);
	catch
      disp(['  XXX GD-Load Error Named : ' gdlist(gid).Tag]);
    end
    
    %--------------------
    % Check Single File? 
    %--------------------
    if length(gd.data)~=1,
      %--------------------------------------------------------------------
      % Multi Dataとして保存!
      %--------------------------------------------------------------------
      namelist=group2multi(gd,prj,h,handles,namelist);
    else
      %--------------------------------------------------------------------
      % Ana Dataとして保存!
      %--------------------------------------------------------------------
      namelist=group2ana(gd,prj,h,handles,namelist);
    end
    
    %---------------------------------
    % その他：
    %---------------------------------
    if 0
      % --> 本当はテストもっときちんとしたテストシナリオがほしい。
      %     Project Viewer みたいのものを先に作るべき?
      %
      % デバッグ用：結果を POTAToに反映させる。
      OSP_DATA('SET','PROJECT',prj);
      POTATo('ChangeProjectIO',h,[],handles);
      % ↑のおかげで 上手くいっているということが無い様、注意
      disp('でばっぐこーど実行中： <- Breakたてる箇所');
    end
  end
  
  %===================================
  % Signal Data の登録
  %===================================
  %==> SDが不要な場合 if 0 を if 1 に変更
  if 0,continue;end
  % + + + + + + + + + + + + + + 
  % 一旦、OSPのプロジェクトをセット
  % + + + + + + + + + + + + + + 
  OSP_DATA('SET','PROJECT',prj0);
  splist = DataDef_SignalPreprocessor('loadlist');
  for sid=1:length(splist)
    % + + + + + + + + + + + + + + 
    % 一旦、OSPのプロジェクトをセット
    % + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj0);
    
    % GDですでに保存された?
    if any(strcmpi(namelist,splist(sid).filename)),continue;end
    sp=splist(sid);
	try
		sp.data=DataDef_SignalPreprocessor('load',sp);
	catch
		fprintf(' XXX Could not Load Data \n');continue;
	end
	fprintf(' * try to Import Signal Data Named : %s\n',sp.filename);
	
    %---------------------------------
    % Make Raw-Data with Stimulation
    %---------------------------------
    key.actdata.data=sp;
    key.filterManage.HBdata=[]; % No Filter bad stim
    [data,hdata]=DataDef_SignalPreprocessor('make_ucdata',key);
    
    % + + + + + + + + + + + + + + + + + + + + + + + + + 
    % Projectの状態を P-3 の新規作成したものに戻しておく。
    % + + + + + + + + + + + + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj);
    POTATo('ChangeProjectIO',h,[],handles);
    try
      % --> Raw & Ana の保存
      %  !! -- Ana も自動保存されることに注意 -- !!
      DataDef2_RawData('save',hdata,data);
      fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
      fprintf('  ==> Save Ana Data : Named : %s\n',hdata.TAGs.filename);
    catch
      fprintf('  XXX Could not Save Raw Data\n');
    end    
  end

  
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  % Projectの状態を P-3 の新規作成したものに戻しておく。
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  OSP_DATA('SET','PROJECT',prj);
  POTATo('ChangeProjectIO',h,[],handles);
end

disp('*************** Done **************');

function fp=openhtml(fname)
% Open HTML
fp=fopen(fname,'w');
fprintf(fp,'<HTML language="ja">\n<HEAD>\n');
fprintf(fp,'\t<TITLE> OSP Project 2 P-3Project</TITLE>\n');
fprintf(fp,'</HEAD>\n<BODY>\n');

function closehtml(fp)
% Close HTML
fprintf(fp,'</BODY>\n</HTML>');
fclose(fp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function namelist=group2ana(gd,prj,h,handles,namelist)
% (OSP) Group-Data to (P3) Ana-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------
% Make Raw-Data with Stimulation
%---------------------------------
key.actdata.data=gd;
key.filterManage.HBdata=[]; % No Filter bad stim
[data,hdata]=DataDef_GroupData('make_ucdata',key);

% + + + + + + + + + + + + + + + + + + + + + + + + +
% Projectの状態を P-3 の新規作成したものに戻しておく。
% + + + + + + + + + + + + + + + + + + + + + + + + +
OSP_DATA('SET','PROJECT',prj);
POTATo('ChangeProjectIO',h,[],handles);

% --------------------------------------------------
% 
% --------------------------------------------------
if isempty(hdata),
	fprintf('  XXX Could not Save Ana Data\n');
	return;
end
if any(strcmpi(namelist,hdata.TAGs.filename))
  % Raw-Data is already saved,
  % Make Ana File Only
  try
    ana = DataDef2_Analysis('loadlist',hdata.TAGs.filename);
    ana = DataDef2_Analysis('load',ana);
    % Rename
    s=regexpi(namelist,[hdata.TAGs.filename '$']);
    if ~iscell(s),s={s};end
    s=~cellfun('isempty',s);s=sum(s(:));
    ana.filename=sprintf('RCP%d_%s',s,hdata.TAGs.filename);
    % Change Recipe
    ana.data(end).filterdata = gd.data(end).filterdata;
    DataDef2_Analysis('save',ana);
    namelist{end+1}=ana.filename;
  catch
    fprintf('  XXX Could not Save Ana Data\n');
  end
else
  try
    % --> Raw & Ana の保存
    %  !! -- Ana も自動保存されることに注意 -- !!
    rd=DataDef2_RawData('save',hdata,data);
    fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
    namelist{end+1}=hdata.TAGs.filename; % GDで保存される名前リストに追加
  catch
    fprintf('  XXX Could not Save Raw Data\n');
  end
  
  %---------------------------------
  % Make ANA-Data : レシピの編集
  %---------------------------------
  try
    % 自動保存された Ana Data のキー名を取得
    % ==> こっちは仕様が変わるかもしれないので
    %     べた書き不可。
    ifk=DataDef2_RawData('getIdentifierKey');
    if 0,k=rd.name;end
    k  = eval(['rd.' ifk ';']);
    % 自動保存された Aan の読込み
    ana = DataDef2_Analysis('loadlist',k);
    ana = DataDef2_Analysis('load',ana);
    % レシピ更新
    ana.data(end).filterdata = gd.data(end).filterdata;
    % Save : Over-Write
    DataDef2_Analysis('save_ow',ana);
    fprintf('  ==> Save Ana Data : Named : %s\n',k);
  catch
    fprintf('  XXX Could not Save Ana Data\n');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function namelist=group2multi(gd,prj,h,handles,namelist)
% (OSP) Group-Data to (P3) Mulit-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------
% Make Raw-Data with Stimulation
%---------------------------------
try
  key.actdata.data=gd;
  key.filterManage.HBdata=[]; % No Filter bad stim
  key.outputtype='cell';
  [cdata,chdata]=DataDef_GroupData('make_ucdata',key);
  
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  % Projectの状態を P-3 の新規作成したものに戻しておく。
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  OSP_DATA('SET','PROJECT',prj);
  POTATo('ChangeProjectIO',h,[],handles);
  
  %------------------------
  % Make Default Multi Data
  %------------------------
  multdata.Tag=gd.Tag;
  multdata.NumberOfFiles=length(cdata);
  multdata.ID_number=1;
  multdata.Comment='';
  multdata.CreateDate=now;
  multdata.data.AnaKeys={};
  %--> Add Rename
  wk={struct('name','Sample','type',8192,...
    'region',0,'version',0,'wrapper','PluginWrapPM_Sample',...
    'wrap','PluginWrapPM_Sample','argData',struct('Format','TmpFile'),...
    'enable','on')};
  %--> Add Blocking
  wk{2}=struct('name','Blocking','wrap','FilterDef_TimeBlocking',...
    'argData',...
    struct('BlockPeriod',[5 15],'Marker',1,'wrap','FilterDef_TimeBlocking'),...
    'enable','on');
  if isfield(gd.data(end).filterdata,'BlockData')
    multdata.data.Recipe.default={wk{:}, gd.data(end).filterdata.BlockData{:}};
  else
    multdata.data.Recipe.default=wk;
  end
  
  try,
	  fmd0.HBdata = gd.data(end).filterdata.HBdata;
  catch
	  fmd0.dummmy=0;
  end

  for idx=1:length(cdata)
    data=cdata{idx};hdata=chdata{idx};

    if any(strcmpi(namelist,hdata.TAGs.filename))
      % Raw-Data is already saved,
      % Make Ana File Only
      try
        ana = DataDef2_Analysis('loadlist',hdata.TAGs.filename);
        ana = DataDef2_Analysis('load',ana);
        % Rename
        s=regexpi(namelist,[hdata.TAGs.filename '$']);
        if ~iscell(s),s={s};end
        s=~cellfun('isempty',s);s=sum(s(:));
        ana.filename=sprintf('RCP%d_%s',s,hdata.TAGs.filename);
        % Change Recipe
        ana.data(end).filterdata = fmd0;
        DataDef2_Analysis('save',ana);
        namelist{end+1}=ana.filename;
        multdata.data.AnaKeys{end+1}=ana.filename;
      catch
        fprintf('  XXX Could not Save Ana Data\n');
      end
    else
      try
        % --> Raw & Ana の保存
        %  !! -- Ana も自動保存されることに注意 -- !!
        rd=DataDef2_RawData('save',hdata,data);
        fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
        namelist{end+1}=hdata.TAGs.filename; % GDで保存される名前リストに追加
        multdata.data.AnaKeys{end+1}=hdata.TAGs.filename;
      catch
        fprintf('  XXX Could not Save Raw Data\n');
      end

      %---------------------------------
      % Make ANA-Data : レシピの編集
      %---------------------------------
      try
        % 自動保存された Ana Data のキー名を取得
        % ==> こっちは仕様が変わるかもしれないので
        %     べた書き不可。
        ifk=DataDef2_RawData('getIdentifierKey');
        if 0,k=rd.name;end
        k  = eval(['rd.' ifk ';']);
        % 自動保存された Aan の読込み
        ana = DataDef2_Analysis('loadlist',k);
        ana = DataDef2_Analysis('load',ana);
        % レシピ更新
        ana.data(end).filterdata = fmd0;
        % Save : Over-Write
        DataDef2_Analysis('save_ow',ana);
        fprintf('  ==> Save Ana Data : Named : %s\n',k);
      catch
        fprintf('  XXX Could not Save Ana Data\n');
      end
    end
  end
  DataDef2_MultiAnalysis('save',multdata);
catch
  fprintf('   XXX TODO: Multi-Data Save\n');
end
    
    
