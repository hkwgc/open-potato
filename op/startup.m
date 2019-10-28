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
% $Id: startup.m 180 2011-05-19 09:34:28Z Katura $
%
% 2007.02.26:
%  Add P3_confirm
% 2007.07.03 : Change to Do nothing

% Comment Out 
if 0
  % Get ospPath : OSP installed Directory path
  flg=1;
  % ospPath0=which('OSP','-all');
  ospPath0{1}=which('OSP');
  if iscell(ospPath0), ospPath0=ospPath0{flg}; end
  if isempty(ospPath0)
    ospPath=pwd;
  else
    ospPath=fileparts(ospPath0);
  end
  clear flg ospPath0;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set OSP Path
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  add_path={};
  ospDir={}; % for M-Lint... dumy
  load([ospPath filesep 'ospDir.mat'], 'ospDir');   % Load Dir Data

  %================================
  % Set Sub-Directory Path
  %================================
  try
    %--------------------------------------------
    % Loop for spath
    % spath : Special Path that sub-directory ...
    %--------------------------------------------
    for spath={'PluginDir', 'user_tools',...
        'UserCommand','viewer','preprocessor',...
        'LayoutEdit','2ndLvlAnaPlugin'},
      % Check Sub-Direcotorys
      P3_rpath('add',[ospPath filesep char(spath)]);
    end
  catch
    warning(lasterr);
  end

  %=====================================
  % Add Main-Direoctorys to MATLAB-Path
  %=====================================
  for dirid=1:length(ospDir)
    try
      add_path{end+1}=  [ospPath filesep ospDir{dirid}];
      path(add_path{end},path);
    catch
      warning(lasterr);
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set POTATo Path
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  try
    path([ospPath filesep 'POTAToProject'],path);
  catch
    warning(lasterr);
  end
  try
    path([ospPath filesep 'POTAToGUI'],path);
  catch
    warning(lasterr);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Debug Mode/ Programming-Path
  % or Now Chaning...
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if 0,
    try
      path([ospPath filesep 'dbg'],path);
      path([ospPath filesep 'Schedule'],path);
      for spath={'Schedule'},
        D=dir([ospPath filesep char(spath)]);
        D([D.isdir]==0)          = [];
        D(strcmp({D.name},'.'))  = []; % Delete Current Directory
        D(strcmp({D.name},'..')) = []; % Delete Upper Directory
        D(strcmp({D.name},'ja')) = []; % Delete Japanese Help Directory
        D(strcmp({D.name},'en')) = []; % Delete English Help Directory(html)
        AddPath_PLUGIN = {D.name};
        if ~isempty(AddPath_PLUGIN),
          for dirid=1:length(AddPath_PLUGIN),
            if strcmpi(AddPath_PLUGIN{dirid},'private'),continue;end
            add_path{end+1} =  ...
              [ospPath filesep char(spath) filesep ...
              AddPath_PLUGIN{dirid}];
            path(add_path{end},path);
          end
        end
      end
      clear D AddPath_PLUGIN spath;
      % --> for Shoji Only <---
      path([ospPath filesep 'newGUI'],path);
    catch
      disp(lasterr);
    end
  end

  %---> Main Path!!! <---
  path(ospPath,path);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % OSP_DATA('SET','ADD_PATH',add_path);
  % Clean up
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  clear ospPath ospDir dirid add_path;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Other Start-Up function
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  P3_confirm;
end
