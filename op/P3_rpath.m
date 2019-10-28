function P3_rpath(mod,spath)
% Add/Remove directory to path include subdirectories recurcive.
% Syntax : 
%  P3_rpath(mod,spath)
%   mod : add/rm
%         add : Add Directory
%         rm  : Remove Directory
%   spath : Search Path

switch mod
  case 'add',
    ad0(spath);
  case 'rm',
    %rm0(spath);
    % Speedup
    rpth=rm1(spath,'');
    rmpath(rpth);
  otherwise
    error('Bad Mode : %s',mod);
end

function ad0(spath)
% Add
D=dir(spath);
path(spath,path);
D([D.isdir]==0)          = [];
D(strcmp({D.name},'.'))  = []; % Delete Current Directory
D(strcmp({D.name},'..')) = []; % Delete Upper Directory
D(strcmpi({D.name},'ja')) = []; % Delete Japanese Help Directory
D(strcmpi({D.name},'en')) = []; % Delete English Help Directory(html)
D(strcmpi({D.name},'private')) = []; % Delete English Help Directory(private)

AddPath_PLUGIN = {D.name};
if ~isempty(AddPath_PLUGIN),
  % Adding sub-directory to Path
  for dirid=1:length(AddPath_PLUGIN),
    %     if length([spath filesep AddPath_PLUGIN{dirid}]),
    %       disp([spath filesep AddPath_PLUGIN{dirid}]);
    %     end
    ad0([spath filesep AddPath_PLUGIN{dirid}]);
  end
end

function rpth=rm1(spath,rpth)
% Make Remove Path-List 
D=dir(spath);
rpth=[rpth pathsep spath];

D([D.isdir]==0)=[];
ns={D.name};
[x,idx]=setdiff(ns,{'.','..','ja','en','private','.svn'}); %#ok 
D=D(idx);clear x;
AddPath_PLUGIN = {D.name};

if ~isempty(AddPath_PLUGIN),
  for dirid=1:length(AddPath_PLUGIN),
    try
        rpth=rm1([spath filesep AddPath_PLUGIN{dirid}],rpth);
    end % try-catch
  end % for
end % if

function rm0(spath)
% Never used :: OLD Program :: 
D=dir(spath);
rmpath(spath);
D([D.isdir]==0)=[];
D(strcmp({D.name},'.')) = [];
D(strcmp({D.name},'..')) = [];
AddPath_PLUGIN = {D.name};
if ~isempty(AddPath_PLUGIN),
  for dirid=1:length(AddPath_PLUGIN),
    try
      rm0([spath filesep AddPath_PLUGIN{dirid}]);
    end % try-catch
  end % for
end % if
