function str=Remove_1stLvlAna_P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Remove1stLvlAnaXX';
if nargin<=0,return;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lock 用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nlh=figure('MenuBar','none',...
  'Units','Normalized', ...
  'Position',[0,0.9,0.2,0.1]);
set(nlh,'Color','white','WindowStyle','modal');
uicontrol(nlh,'Style','text', ...
  'BackgroundColor','white',...
  'Units','Normalized', ...
  'Position',[0.01,0.01,0.9,0.9], ...
  'String', 'Now Loading...');

try

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 削除：1st-Level-Analysis
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  f=DataDef2_1stLevelAnalysis('getDataListFileName');
  [p f]=fileparts(f);
  try
    delete([p filesep f '.mat']);
  catch
  end
  %  Delete Real-Data
  fs=find_file('^FLA_[\D\d]*\.mat$',p,'-i');
  if ~isempty(fs), delete(fs{:});  end  %#ok
  %  Delete Search-Key
  fs=find_file('^FLASKF_[\D\d]*\.mat$',p,'-i');
  if ~isempty(fs),
    delete(fs{:});
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 削除：2nd-Level-Analysis
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  f=DataDef2_2ndLevelAnalysis('getDataListFileName');
  [p f]=fileparts(f);
  try,delete([p filesep f '.mat']);end %#ok
  %  Delete Real-Data
  fs=find_file('^SLD_[\D\d]*\.mat$',p,'-i');
  if ~isempty(fs),
    delete(fs{:});
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % リレーションファイル変更
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  rfile=FileFunc('getRelationFileName');
  load(rfile,'Relation');
  if ~exist('Relation','var')
    Relation=load(rfile);
  end
  fn=fieldnames(Relation);
  n=strmatch('SLA_',fn);
  for i=n(:)'
    Relation=rmfield(Relation,fn{i});
  end

  idx=strmatch('FLA_',fn);
  for d=idx(:)'
    dpl=Relation.(fn{d}).Parent;
    for dp=1:length(dpl)
      Relation.(dpl{dp}).Children(strcmpi(Relation.(dpl{dp}).Children,fn{d}))=[];
    end
    Relation=rmfield(Relation,fn{d});
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Save
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  % --> it can be simplifies
  if rver >= 14,
    save(rfile,'-v6','Relation');
  else
    save(rfile,'Relation');
  end
  POTATo('ChangeProjectIO',hs.figure1,[],hs);

catch
  delete(nlh);
  rethrow(lasterror);
end
delete(nlh);
