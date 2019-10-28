function [ecode, msg]=LastAirProject(fnc)
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


ecode=false;msg='';


try
  switch fnc
    case 'OPEN'
      [ecode,msg]=openAir;
    case 'CheckIn'
      [ecode,msg]=CheckIn;
  end
catch
  msg  =lasterr;
  ecode=true;
end

function fname=myfile
% Save File Name
p=fileparts(which('POTATo.m'));
fname=[p filesep 'ospData' filesep 'LastAirProjectPath.mat'];

function [ecode,msg]=CheckIn
% Checkin if Air Project
ecode=false;msg='';

% Is there Air-List?
try
  al=DataDef2_RawData('loadAirList');
  if isempty(al),return;end
catch
  return;
end

% Make Project Data
AirProject.parent =OSP_DATA('GET','PROJECTPARENT');
AirProject.project=OSP_DATA('GET','PROJECT');

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(myfile, 'AirProject','-v6');
else
  save(myfile, 'AirProject');
end

%---> Auto reading...
if 0
  disp(C__FILE__LINE__CHAR);
  disp('Auto Importing....');
end
%--> Air Save-Data Path
fname=[AirProject.parent filesep AirProject.project.Name filesep ...
  'AirSaveDataPath.txt'];
if exist(fname,'file')
  airpath=textread(fname,'%s');
  if iscell(airpath),airpath=airpath{1};end
  msg=AirImportMain(airpath);
  if ~isempty(msg),warndlg(msg,'Import Error:');end
end


function [ecode,msg]=openAir
% Open Last-Air-Project
ecode=false;msg='';
fname=myfile;
isnew=true;
if exist(fname,'file')
  if 0,AirProject=[];end
  load(fname,'AirProject');
  try
    projectListFile=[AirProject.parent filesep 'ProjectData.mat'];
    if ~exist(projectListFile,'file')
      error('No ProjectData File Exist');
    end
    load(projectListFile, 'ProjectData');
    if exist('ProjectData','var')
      plist={ProjectData.Name};
    end
    if all(strcmp(AirProject.project.Name, plist)==0),
      error('No Project to Open!');
    end    
    d=[AirProject.parent filesep AirProject.project.Name];
    if ~exist(d,'dir')
      error('Last Opened Project was Deleted');
    end
    isnew=false;
  catch
    % TODO : Display messages.
    %  (Where needless)
  end
end

if isnew
  newProject;
  AirProject.parent =OSP_DATA('GET','PROJECTPARENT');
  AirProject.project=OSP_DATA('GET','PROJECT');
end

% POTATo Refresh.
h=OSP_DATA('GET','POTATOMAINHANDLE');
handles=guidata(h);
POTATo('ChangeProjectParentIO',h,AirProject.parent,handles);
POTATo('ChangeProject_IO',h,[],handles, AirProject.project);

function newProject
% Make New Project for Air
pj.Ver  = 2.0;
pj.Name = 'AirDir';
pj.Path = OSP_DATA('GET','PROJECTPARENT');
if isempty(pj.Path),error('No Parent Directory to Import.');end
pj.CreateDate=now;
try
  if ispc
    pj.Operator = getenv('USERNAME');
  else
    pj.Operator = getenv('USER');
  end
catch
  pj.Operator = 'Unknown';
end
pj.Comment  = 'WorkDir';

Project=POTAToProject('LoadData');

%--> Opening ..
idx=0;
if ~isempty(Project)
  while 1
    pjidx=strmatch(pj.Name,{Project.Name},'exact');
    if isempty(pjidx),break;end
    idx=idx+1;
    pj.Name=sprintf('AirDir_%d',idx);
  end
end

% make Project
pj=POTAToProject('Add',pj);
if isempty(pj),
  error('Could not Make Project');
end

