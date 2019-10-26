function setOspPath(flag)
% OSPPATHSETUP is equal to STARTUP
% but special name.
%
% This function is for USER COMMNAD.
  osppath = fileparts(which('OSP'));  
  % OSP Path Setting
  cwd = pwd; % get Currenct Working Directory
  if nargin==0 || strcmp(flag,'on'),
    try
      cd(osppath); startup; cd(cwd);
    catch
      cd(cwd); rethrow(lasterror);
    end
  end
return;
