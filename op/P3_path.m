function P3_path
% Setup MATLAB's current search path for OSP
%
% if you want to "undo", execute undostartup
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2004.12.21
% $Id: P3_path.m 398 2014-03-31 04:36:46Z katura7pro $
%
% 2007.02.26:
%  Add P3_confirm
%
% 2014.03.27
%  for New MCR

ismcr=false;
% Get ospPath : OSP installed Directory path
flg=1;
% ospPath0=which('OSP','-all');
ospPath0{1}=which('P3');
if iscell(ospPath0), ospPath0=ospPath0{flg}; end
if isempty(ospPath0)
  ospPath=pwd;
else
  ospPath=fileparts(ospPath0);
end
clear flg ospPath0;

ospPath0=ospPath;
[pp, ff] = fileparts(ospPath);
if( strcmp(ff,'WinP3') )
	%return; % Do notihng
	ospPath=pp;
	ismcr=true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set OSP Path 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---> Main Path!!! <---
add_path=ospPath;
ospDir={}; % for M-Lint... dumy
load([ospPath0 filesep 'ospDir.mat'], 'ospDir');   % Load Dir Data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set POTATo Path 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  add_path=[add_path ';' ospPath filesep 'POTAToProject'];
catch
  warning(lasterr);
end
try
  add_path=[add_path ';' ospPath filesep 'POTAToGUI'];
catch
  warning(lasterr);
end

%=====================================
% Add Main-Direoctorys to MATLAB-Path
%=====================================
for dirid=1:length(ospDir)
  try
    add_path=[add_path ';' ospPath filesep ospDir{dirid}];
  catch
    warning(lasterr);
  end
end


%================================
% Set Sub-Directory Path
%================================
try
  %--------------------------------------------
  % Loop for spath
  % spath : Special Path that sub-directory ...
  %--------------------------------------------
  for spath={'preprocessor','PluginDir', 'user_tools',...
      'UserCommand','viewer',...
      'LayoutEdit','2ndLvlAnaPlugin',...
      'LAYOUT',...
      'BenriButton',...
      'Research1stFunctions',...
      'Research2ndFunctions',...
	  'SimpleModeDir',...
	  },
    % Check Sub-Direcotorys
    add_path=getpath([ospPath filesep char(spath)],add_path);
  end
catch
  warning(lasterr);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug Mode/ Programming-Path
% or Now Chaning...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isdir([ospPath filesep 'dbg'])
  add_path=[add_path ';' ospPath filesep 'dbg'];
end
if 0,
  try
    path([ospPath filesep 'dbg'],path);
    path([ospPath filesep 'Schedule'],path);
    add_path=getpath([ospPath filesep 'Schedule'],add_path);
  catch
    warning(lasterr);
  end
end

path(add_path,path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OSP_DATA('SET','ADD_PATH',add_path);
% Clean up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear ospPath ospDir dirid add_path;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Start-Up function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~ismcr
	P3_confirm;
end

function p=getpath(spath,p)
% get Path from SearchPath
D=dir(spath);
if isempty(strfind(p,[spath ';']))
  p=[p ';' spath];
  %else
  %  disp([' DC : ' spath])
end
D([D.isdir]==0)          = [];
ns={D.name};
[x,idx]=setdiff(ns,{'.','..','ja','en','private','.svn'}); %#ok 
D=D(idx); clear x;

%--> Remove MCR path
rmidx=[];
for idx=1:length(D)
  if length(D(idx).name)<4,continue;end
  if strcmpi(D(idx).name(end-3:end),'_mcr')
    rmidx(end+1)=idx;
  end  
end
D(rmidx)=[];

AddPath_PLUGIN = {D.name};
if ~isempty(AddPath_PLUGIN),
  % Adding sub-directory to Path
  for dirid=1:length(AddPath_PLUGIN),
    p=getpath0([spath filesep AddPath_PLUGIN{dirid}],p);
  end
end

function p=getpath0(spath,p)
% get Path from SearchPath
D=dir(spath);
p=[p ';' spath];
D([D.isdir]==0)          = [];
ns={D.name};
[x,idx]=setdiff(ns,{'.','..','ja','en','private','.svn'}); %#ok 
D=D(idx); clear x;

%--> Remove MCR path
rmidx=[];
for idx=1:length(D)
  if length(D(idx).name)<4,continue;end
  if strcmpi(D(idx).name(end-3:end),'_mcr')
    rmidx(end+1)=idx;
  end  
end
D(rmidx)=[];

AddPath_PLUGIN = {D.name};
if ~isempty(AddPath_PLUGIN),
  % Adding sub-directory to Path
  for dirid=1:length(AddPath_PLUGIN),
    p=getpath0([spath filesep AddPath_PLUGIN{dirid}],p);
  end
end
