function str=Project_Manage_P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Project Repair';
if nargin<=0,return;end

% TODO : P3 Rock
try
  uc_P3_ProjectManage;
catch
  % TODO : P3 un-Rock
  errordlg(lasterr);
  return;
end
% TODO : P3 un-Rock
return;
