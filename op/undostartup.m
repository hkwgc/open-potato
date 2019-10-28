% rmove OSP-function's path  from MATLAB's current search path for OSP
%
% If you want to setup, use startup.
%

% ===================================================================================
% Copyright(c) 2019, National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ===================================================================================


% == History ==
% original auther : Masanori Shoji
% create : 2004.01.25
% $Id: undostartup.m 180 2011-05-19 09:34:28Z Katura $
%
warning off MATLAB:rmpath:DirNotFound

% === Get ospPath : OSP installed Directory path ===
flg=1;
% ospPath0=which('OSP','-all');
ospPath0=which('OSP');
if iscell(ospPath0), ospPath0=ospPath0{flg}; end
if isempty(ospPath0)
  ospPaht=pwd;
else
  ospPath=fileparts(ospPath0);
end
clear flg ospPath0;

% === Remove OSP Path ===
load([ospPath filesep 'ospDir.mat'], 'ospDir');   % Load Dir Data
for dirid=1:length(ospDir)
  try
    rmpath([ospPath filesep ospDir{dirid}]);
  catch
    warning(lasterr);
  end
end
try
  rmpath([ospPath filesep 'POTAToProject']);
catch
  warning(lasterr);
end
try
  rmpath([ospPath filesep 'POTAToGUI']);
catch
  warning(lasterr);
end


try
  for spath={'preprocessor','PluginDir', 'user_tools',...
        'UserCommand','viewer',...
        'LayoutEdit','2ndLvlAnaPlugin',...
        'LAYOUT','BenriButton',...
        'Research1stFunctions',...
        'Research2ndFunctions'},
    try
      P3_rpath('rm',[ospPath filesep char(spath)]);
    end
	end % for
	clear D AddPath_PLUGIN spath;
end

% Clean up
clear ospPath ospDir dirid;

warning on MATLAB:rmpath:DirNotFound
