function uc_P3_ProjectManage(fnc)
% This Function Manage P3-Project
% $Id: uc_P3_ProjectManage.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Launch Check
if ~OSP_DATA,
  disp('P3 is not running');return;
end
if ~OSP_DATA('GET','isPOTAToRunning')
  disp('P3 is not running');return;
end

% Load Current Project..
pppt=OSP_DATA('GET', 'PROJECTPARENT'); %ParentProjectPath
if isempty(pppt) || ~exist(pppt,'dir')
  disp('No Project-Directory');return;
end

%---- (Outer Execution) --
if nargin>=1
  switch fnc
    case 'All'
      lfConfinePath(pppt);
      CheckRelation(pppt);
      LostFile;
      CheckRawData(pppt);
    case 'Fix Path'
      lfConfinePath(pppt);
    case 'CheckRelation'
      CheckRelation(pppt);
    case 'LostFile'
      LostFile(pppt);
    case 'Raw-Data Check'
      CheckRawData(pppt);
    case 'Remake Relation'
      RemakeRelation;
  end
  return;
end

mlist={'All','Fix Path','CheckRelation','LostFile','Raw-Data Check','exit','Remake Relation'};
cntflag=true;
while cntflag
  tmp=menu('Project Repair menu',mlist);
  if isempty(tmp) || isequal(tmp,0),return;end
  name=mlist{tmp};
  switch name
    case 'All'
      lfConfinePath(pppt);
      CheckRelation(pppt);
      LostFile;
      CheckRawData(pppt);
      cntflag=false;
    case 'Fix Path'
      lfConfinePath(pppt);
    case 'CheckRelation'
      CheckRelation(pppt);
    case 'LostFile'
      LostFile;
    case 'Raw-Data Check'
      CheckRawData(pppt);
    case 'exit'
      cntflag=false;
    case 'Remake Relation'
      RemakeRelation;
    otherwise
     eval([mlist{tmp} '(pppt);']);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1st Step : Project-ParentPath to Confine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lfConfinePath(pppath)
% Confile PPP
disp('###################################');
disp('# Checking Current Project Path   #');
disp('###################################');

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
cwd=pwd; % Current-Working-Directory
try
  cd(pppath);
  f=[pppath filesep 'ProjectData.mat'];
  if 0,ProjectData=[];end
  load(f,'ProjectData');
  PPD=ProjectData;
  lostid=[];
  for idx=1:length(PPD)
    disp('--------------------');
    disp([' Check Project : ' PPD(idx).Name]);
    disp('--------------------');
    if ~strcmpi(PPD(idx).Path,pppath)
      PPD(idx).Path=pppath;
      disp(' + Path : Confuse --> reshape');
    end
    ppath=[pppath filesep PPD(idx).Name];
    
    if ~exist(ppath,'dir')
      disp(' X Lost All Data :');
      disp(['   No such a Directory : ' ppath]);
      lostid(end+1)=idx; %#ok (Data-Lost-Case)
      continue;
    end
    
    f2=[ppath filesep 'PROJECT_DATA.mat'];
    try
      load(f2,'Project');
    catch
      clear Project;
      Project.Ver=2;
      Project.Name=PPD(idx).Name;
      Project.Path=pppath;
      Project.CreateDate = now;
      Project.Operator   = 'someone';
      Project.Comment    = 'Lost Comment';
    end
    if ~strcmpi(Project.Path,ppath)
      disp(' + Local-Path : Confuse --> reshape');
      Project.Path=ppath;
    end
    if rver >=14
      save(f2,'Project','-v6');
    else
      save(f2,'Project');
    end
  end
  PPD(lostid)=[];
  ProjectData=PPD;
  if 0,disp(ProjectData);end
  if rver >=14
    save(f,'ProjectData','-v6');
  else
    save(f,'ProjectData');
  end

catch
  cd(cwd);
  disp('###################################');
  disp('# Current Project Path : NG       #');
  fprintf('#');
  disp(lasterr);
  disp('###################################');
  return;
end
cd(cwd);
  disp('###################################');
  disp('# Current Project Path : [OK]  #');
  disp('###################################');
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckRelation(pppath)
% Check Relation of Data in the Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' No Project to Check');
  error(' No Project to Check');
end
% Empty Project?
xx=DataDef2_RawData('loadlist');
if isempty(xx),return;end

% start Checking-Data-Relation
ppath=[pppath filesep pj.Name filesep];
disp('###################################');
disp('# Checking Data-Relation in       #');
fprintf('#  %30s #\n',pj.Name);
disp('###################################');
try
  FileFunc('StructType');  % New Format
catch
  disp(lasterr);
  f=FileFunc('getRelationFileName');
  disp(f);
  if ~exist(f,'file')
    disp('No-such-file or directory');
  end
  % file info
  x=dir(f);disp(x);
  try
    Relation=load(f,'-regexp','^[RAM]*');
  catch
    disp(lasterr);
    x=whos('-file',f);disp(x);
  end
  if isfield(Relation,'Relation')
    Relation=Relation.Relation;
  end
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >=14
    save(f,'Relation','-v6');
  else
    save(f,'Relation');
  end
end

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
cwd=pwd; % Current-Working-Directory
rfile=FileFunc('getRelationFileName'); % relation File

try
  cd(ppath); % Change to Project Path
  load(rfile,'Relation'); % get Relation File
  eflag=false;
  
  vname=fieldnames(Relation); %#ok Load-Data
  
  % Checking Relation 
  for idx=1:length(vname)
    %======================================================================
    % P-->C Relation Check
    %======================================================================
    p=Relation.(vname{idx}).Parent;
    for pidx=1:length(p)
      if ~isfield(Relation,p{pidx})
        disp([' X Error : Lost Relation-Data ' p{pidx}]);
        eflag=true;
        continue;
      end
      vidx=find(strcmp(Relation.(p{pidx}).Children,vname{idx}));
      if isempty(vidx)
        disp([' + P-->C Lost-Relation-Error was fixed in ' p{pidx}]);
        Relation.(p{pidx}).Children{end+1}=vname{idx};
        eval([p{pidx} '.Children{end+1}=vname{idx};']);
      elseif length(vidx)>=2
        disp([' + P-->C Double-Count-Error was fixed in ' p{pidx}]);
        Relation.(p{pidx}).Children(vidx(2:end))=[];
        eval([p{pidx} '.Children(vidx(2:end))=[];']);
      end
    end
    
    %======================================================================
    % C-->P Relation Check
    %======================================================================
    c=Relation.(vname{idx}).Children;
    for cidx=1:length(c)
      if ~isfield(Relation,c{cidx})
        disp([' X Error : Lost Relation-Data ' c{cidx}]);
        eflag=true;
        continue;
      end
      vidx=find(strcmp(Relation.(c{cidx}).Parent,vname{idx}));
      if isempty(vidx)
        disp([' + C-->P Lost-Relation-Error was fixed in ' c{cidx}]);
        Relation.(c{cidx}).Parent{end+1}=vname{idx};
        eval([c{cidx} '.Parent{end+1}=vname{idx};']);
      elseif length(vidx)>=2
        disp([' + C-->P Double-Count-Error was fixed in ' c{cidx}]);
        Relation.(c{cidx}).Parent(vidx(2:end))=[];
        eval([c{cidx} '.Parent(vidx(2:end))=[];']);
      end
    end
    
    %======================================================================
    % Reduce
    %======================================================================
    if length(vname{idx})<4, continue;end
    k=feval(Relation.(vname{idx}).fcn,'getIdentifierKey');
    tmp=struct(k,Relation.(vname{idx}).data.(k));
    switch (vname{idx}(1:4)),
      case {'RAW_','ANA_','SLA_','MLT_'}
      case 'FLA_'
        tmp.function = Relation.(vname{idx}).data.function;
        tmp.ID       = Relation.(vname{idx}).data.ID;
      otherwise
        tmp=Relation.(vname{idx}).data;
    end
    Relation.(vname{idx}).data=tmp;
  end
  
  %========================================================================
  % Over write Relation File
  %========================================================================
  if rver >=14
    save(rfile,'Relation','-v6');
  else
    save(rfile,'Relation');
  end
  
  if eflag
    error('# Some Relation was Terrible Error');
  end
catch
  cd(cwd);
  disp('###################################');
  disp('# Checking Data-Relation [NG]     #');
  fprintf('#');
  disp(lasterr);
  disp('###################################');
  return;
end
cd(cwd);
disp('###################################');
disp('# Checking Data-Relation [OK]     #');
disp('###################################');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LostFile()
% Check Relation of Data in the Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' No Project to Check');
  error(' No Project to Check');
end
disp('###################################');
disp('# Checking Lost-File in           #');
fprintf('#  %30s #\n',pj.Name);
disp('###################################');

try
  %----------------
  disp('# Raw Data Check...');
  f0=DataDef2_RawData('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_RawData('loadlist');
  for idx=1:length(l)
    f=DataDef2_RawData('getDataFileName',l(idx));
    if ~exist(f,'file')
      disp(['Lost File : ' f]);
      try
        DataDef2_RawData('deleteData',l(idx));
      catch
        disp(lasterr);
      end
    end
  end
  %----------------
  disp('# ANA Data Check...');
  f0=DataDef2_Analysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_Analysis('loadlist');
  for idx=1:length(l)
    f=DataDef2_Analysis('getDataFileName',l(idx));
    if ~exist(f,'file')
      disp(['Lost File : ' f]);
      try
        DataDef2_Analysis('deleteData',l(idx));
      catch
        disp(lasterr);
      end
    end
  end
  %----------------
  disp('# Mult Data Check...');
  f0=DataDef2_MultiAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_MultiAnalysis('loadlist');
  for idx=1:length(l)
    f=DataDef2_MultiAnalysis('getDataFileName',l(idx));
    if ~exist(f,'file')
      disp(['Lost File : ' f]);
      try
        DataDef2_MultiAnalysis('deleteData',l(idx));
      catch
        disp(lasterr);
      end
    end
  end

  %----------------
  disp('# 1st Data Check...');
  f0=DataDef2_1stLevelAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_1stLevelAnalysis('loadlist');
  for idx=1:length(l)
    f=DataDef2_1stLevelAnalysis('getDataFileName',l(idx));
    if ~exist(f,'file')
      disp(['Lost File : ' f]);
      try
        DataDef2_1stLevelAnalysis('deleteData',l(idx));
      catch
        disp(lasterr);
      end
    end
  end

  %----------------
  disp('# 2nd Data Check...');
  f0=DataDef2_2ndLevelAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_2ndLevelAnalysis('loadlist');
  for idx=1:length(l)
    f=DataDef2_2ndLevelAnalysis('getDataFileName',l(idx));
    if ~exist(f,'file')
      disp(['Lost File : ' f]);
      try
        DataDef2_2ndLevelAnalysis('deleteData',l(idx));
      catch
        disp(lasterr);
      end
    end
  end
catch
  disp('###################################');
  disp('# Checking Lost-File     [NG]     #');
  fprintf('#');
  disp(lasterr);
  disp('###################################');
  return;
end
disp('###################################');
disp('# Checking Lost-File     [OK]     #');
disp('###################################');
return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function deleteUnusedRawData(pppath)
function CheckRawData(pppath)
% Check Relation of Data in the Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' No Project to Check');
  error(' No Project to Check');
end
% Empty Project?
xx=DataDef2_RawData('loadlist');
if isempty(xx),return;end

ppath=[pppath filesep pj.Name filesep];
disp('###################################');
disp('# Delete RawData not in use       #');
fprintf('#  %30s #\n',pj.Name);
disp('###################################');

cwd=pwd; % Current-Working-Directory
rfile=FileFunc('getRelationFileName'); % relation File

try
  cd(ppath); % Change to Project Path
  load(rfile,'Relation'); % get Relation File
  
  vname=fieldnames(Relation);
  
  %======================================================================
  % Checking Empty Data
  %======================================================================
  list=[];
  for idx=1:length(vname)
    % is Raw?
    if length(vname{idx})<4 || ~strcmp(vname{idx}(1:4),'RAW_')
      continue;
    end

    if isempty(Relation.(vname{idx}).Children)
      list(end+1)=idx; %#ok Data-Lost Case
    end
  end
  
  cd(cwd);
  if ~isempty(list)
    % set : use Question Dialog of "Can I Delete?" (true)
    OSP_DATA('SET','ConfineDeleteDataRD',true);
    OSP_DATA('SET','SP_Rename','OriginalName');
    for idx=list
      q=questdlg({'Unused Raw-Data, named ',...
        Relation.(vname{idx}).data.filename,...
        'What do you want to do?'},...
        'Unconnected Raw-Data','MakeAnaData','Delete Raw-Data','MakeAnaData');
      if isempty(q),continue;end
      if strcmpi(q,'Delete Raw-Data')
        DataDef2_RawData('deleteGroup',Relation.(vname{idx}).data);
      else
        mydata=Relation.(vname{idx}).data;
        mydata.TimeBlock='off';
        mydata.data.ver=1.0;
        mydata.data.name=mydata.filename;
        mydata.data.filterdata.dumy='No Effective Data';
        DataDef2_Analysis('save',mydata);
      end
    end
  end
  
catch
  cd(cwd);
  disp('###################################');
  disp('# Delete RawData not in use  [NG] #');
  fprintf('#');
  disp(lasterr);
  disp('###################################');
end
cd(cwd);
  disp('###################################');
  disp('# Delete RawData not in use  [OK] #');
  disp('###################################');
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemakeRelation()
% Check Relation of Data in the Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' No Project to Check');
  error(' No Project to Check');
end


disp('###################################');
disp('# Remake Relation-File            #');
fprintf('#  %30s #\n',pj.Name);
disp('###################################');

try
  %----------------
  disp('# Raw Data Check...');
  f0=DataDef2_RawData('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_RawData('loadlist');
  for idx=1:length(l)
    try
      nm=DataDef2_RawData('reshapeName',l(idx).filename);
      if ~isvarname(nm),
          error(['Bad-Name ' nm])
      end
    catch
      disp([' Warning :ignore: ' l(idx).filename]);
      disp(lasterr);
      continue;
    end
    Relation.(nm).name=nm;
    Relation.(nm).data.filename=l(idx).filename;
    Relation.(nm).fcn = 'DataDef2_RawData';
    Relation.(nm).Parent={};
    Relation.(nm).Children={};
  end
  %----------------
  disp('# ANA Data Check...');
  f0=DataDef2_Analysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_Analysis('loadlist');
  for idx=1:length(l)
    try
      dt=DataDef2_Analysis('load',l(idx));
      nm=DataDef2_Analysis('reshapeName',dt.filename);
      if ~isvarname(nm),
        error(['Bad-Name ' nm])
      end
    catch
      disp(' Warning :No-Data-Exist: ');
      disp(l(idx));
      disp(lasterr);
      continue;
    end
    Relation.(nm).name=nm;
    Relation.(nm).data.filename=dt.filename;
    Relation.(nm).fcn = 'DataDef2_Analysis';
    Relation.(nm).Parent={};
    Relation.(nm).Children={};
    % Parent
    for idx2=1:length(dt.data)
      nm2=DataDef2_RawData('reshapeName',dt.data(idx2).name);
      if isfield(Relation,nm2)
        % Add Relation
        Relation.(nm).Parent{end+1}=nm2;
        Relation.(nm2).Children{end+1}=nm;
      else
        % No Data Exist ---> Delete This Data::
        disp('-- Lost - Raw-Data --');
        Relation=rmfield(Relation,nm);
      end
    end % Parent Loop
  end % Ana-Data Loop

  %----------------
  disp('# Mult Data Check...');
  f0=DataDef2_MultiAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_MultiAnalysis('loadlist');
  for idx=1:length(l)
    try
      dt=DataDef2_MultiAnalysis('load',l(idx));
      nm=DataDef2_MultiAnalysis('reshapeName',dt.Tag);
      if ~isvarname(nm),
        error(['Bad-Name ' nm])
      end
    catch
      disp(' Warning :No-Data-Exist: ');
      disp(l(idx));
      disp(lasterr);
      continue;
    end
    Relation.(nm).name=nm;
    Relation.(nm).data.Tag=dt.Tag;
    Relation.(nm).fcn = 'DataDef2_MultiAnalysis';
    Relation.(nm).Parent={};
    Relation.(nm).Children={};
    % Parent
    for idx2=1:length(dt.data.AnaKeys)
      nm2=DataDef2_Analysis('reshapeName',dt.data.AnaKeys{idx2});
      if isfield(Relation,nm2)
        % Add Relation
        Relation.(nm).Parent{end+1}=nm2;
        Relation.(nm2).Children{end+1}=nm;
      else
        % No Data Exist ---> Delete This Data::
        disp('-- Lost - Ana-Data --');
        Relation=rmfield(Relation,nm);
      end
    end % Parent Loop
  end % Mult Loop

  %----------------
  disp('# 1st Data Check...');
  f0=DataDef2_1stLevelAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_1stLevelAnalysis('loadlist');
  for idx=1:length(l)
    try
      dt=DataDef2_1stLevelAnalysis('load',l(idx));
      nm=DataDef2_1stLevelAnalysis('reshapeName',dt.name);
      if ~isvarname(nm),
        error(['Bad-Name ' nm])
      end
    catch
      disp(' Warning :No-Data-Exist: ');
      disp(l(idx));
      disp(lasterr);
      continue;
    end
    Relation.(nm).name=nm;
    Relation.(nm).data.name=dt.name;
    Relation.(nm).data.function=dt.function;
    Relation.(nm).data.ID=dt.function;
    Relation.(nm).fcn = 'DataDef2_1stLevelAnalysis';
    Relation.(nm).Parent={};
    Relation.(nm).Children={};
    % Parent
    if ~iscell(dt.RawDataFileName),dt.RawDataFileName={dt.RawDataFileName};end
    for idx2=1:length(dt.RawDataFileName)
      nm2=DataDef2_RawData('reshapeName2',dt.RawDataFileName{idx2});
      if isfield(Relation,nm2)
        % Add Relation
        Relation.(nm).Parent{end+1}=nm2;
        Relation.(nm2).Children{end+1}=nm;
      else
        % No Data Exist ---> Delete This Data::
        disp('-- Lost - Raw-Data --');
        %Relation=rmfield(Relation,nm);
      end
    end % Parent Loop
  end % 1st ANA Loop

  %----------------
  disp('# 2nd Data Check...');
  f0=DataDef2_2ndLevelAnalysis('getDataListFileName');
  disp(['##  ' f0]);
  %----------------
  l=DataDef2_2ndLevelAnalysis('loadlist');
  for idx=1:length(l)
    try
      dt=DataDef2_2ndLevelAnalysis('load',l(idx));
      nm=DataDef2_2ndLevelAnalysis('reshapeName',dt.Name);
      if ~isvarname(nm),
        error(['Bad-Name ' nm])
      end
    catch
      disp(' Warning :No-Data-Exist: ');
      disp(l(idx));
      disp(lasterr);
      continue;
    end
    Relation.(nm).name=nm;
    Relation.(nm).data.Name=dt.Name;
    Relation.(nm).fcn = 'DataDef2_2ndLevelAnalysis';
    Relation.(nm).Parent={};
    Relation.(nm).Children={};
    % Parent
    for idx2=1:length(dt.data.Group)
      tmp0=dt.data.Group{idx2}.groups;
       if ~isfield(tmp0,'Files'),continue;end
       for idx3=1:length(tmp0),
         tmp=tmp0(idx3);
         for idx4=1:length(tmp.Files)
           nm2=DataDef2_1stLevelAnalysis('reshapeName',tmp.Files(idx4).name);
           if isfield(Relation,nm2)
             % Add Relation
             Relation.(nm).Parent{end+1}=nm2;
             Relation.(nm2).Children{end+1}=nm;
           else
             % No Data Exist ---> Delete This Data::
             disp('-- Lost - 1st-LVL-Data --');
             %Relation=rmfield(Relation,nm);
           end
         end % end File-Loop
       end % Files Loop
    end % Parent Loop
  end % 2nd Ana Loop
  
  % Empty Project?
  if exist('Relation','var')
    % Save
    disp('-- Save Relsutl --');
    f=FileFunc('getRelationFileName');
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >=14
      save(f,'Relation','-v6');
    else
      save(f,'Relation');
    end
  else
    disp('-- No Data in this Project --')
  end
catch
  disp('###################################');
  disp('# Remake Relation-File   [NG]     #');
  fprintf('#');
  disp(lasterr);
  disp('###################################');
  return;
end
disp('###################################');
disp('# Remake Relation-File   [OK]     #');
disp('###################################');
return;


