function str=CopyStimData_P3_BB(hs)
% 選択中のファイルの刺激データを、選択するファイルの刺激データに置き換える
%   便利ボタン
%         2013.09.13  

str='CopyStimData';
if nargin<=0,return;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lock 用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hs=guidata(OSP_DATA('GET','POTATOMAINHANDLE'));
 
try
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % コピー 先 (to) と元(from)の基本データ作成
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  vls      = get(hs.lbx_fileList,'Value');
  %if length(vls)>1, warndlg('please select one file.');return;end
  datalist = get(hs.lbx_fileList,'UserData');
  fromlist = datalist(setdiff(1:length(datalist),vls));
  fromstr   ={fromlist.filename};
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GUI 入力
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  p0=get(hs.figure1,'Position');
  p2=[p0(1), p0(2)+500-100 400, 100];

  % Figure
  h=figure;
  set(h,'Units','Pixels','Position',p2)
  set(h,'MenuBar','none','toolBar','none')
  set(h,'FileName','Copy Stim-Data','NumberTitle','off');
  
  % タイトル
  ht=uicontrol(h,'Units','pixels','Position',[10 70 200 30]);
  set(ht,'style','text','String','copy stim-data from:','horizontalAlignment','left');

  % コピー元選択用
  hp=uicontrol(h,'Units','pixels','Position',[20 40 360 30]);
  set(hp,'style','popupmenu','String',fromstr);
  
  % OK ボタン
  hok=uicontrol(h,'Units','pixels','Position',[250 10 50 30]);
  set(hok,'style','pushbutton','String','OK','Callback','set(gcbf,''Visible'',''off'');');

  % Cancel ボタン
  hcl=uicontrol(h,'Units','pixels','Position',[310 10 50 30]);
  set(hcl,'style','pushbutton','String','Cancel','Callback','delete(gcbf);');

  % ボタン入力まち
  set(h,'WindowStyle','modal');
  waitfor(h,'Visible');
  if ~ishandle(h)
      % Cancel
      return;
  end
  fromdata = fromlist(get(hp,'Value'));
  delete(h);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % コピー元 Stim-Data取得 (RAW)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  an=DataDef2_Analysis('load',fromdata);
  rd=DataDef2_RawData('loadlist',an.data.name);
  [hdata,data]=DataDef2_RawData('load',rd);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % コピー先ループ
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for  ii=vls
      %----------
      % 呼び出し
      %----------
      dii   = datalist(ii);
      anii=DataDef2_Analysis('load',dii);
      rdii=DataDef2_RawData('loadlist',anii.data.name);
      [hdataii,dataii]=DataDef2_RawData('load',rdii);

      %----------
      % コピー
      %----------
      hdataii=copystim(hdata,hdataii);

      %----------
      % 保存
      %----------
      DataDef2_RawData('save_ow',hdataii,dataii);
  end

catch ME
  rethrow(ME);
end


function toh=copystim(frmh,toh)
% Copy Stim Data from frmh to toh

ln=length(toh.stimTC);
% Stimコピー
stim=frmh.stim;
stim((stim(:,3)>ln) | (stim(:,2)>ln)  ,:)=[];
toh.stim=stim;

% StimTCコピー
ln0=length(frmh.stimTC);
if (ln0>ln)
    toh.stimTC(:)=frmh.stimTC(1:ln);
else
    toh.stimTC(1:ln0)=frmh.stimTC(:);
    toh.stimTC(ln0+1:end)=0;
end




