function str=ETG_SDpos2CHpos_P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='SD to CH(pos)';
OSP_DATA('SET','ETGPOS_FWRITE',false)
if nargin<=0,return;end

% TODO : P3 Rock
try
  OSP_DATA('SET','ETGPOS_FWRITE',true);
  etgpos_sd2ch;
catch
  % TODO : P3 un-Rock
  errordlg(lasterr);
end
OSP_DATA('SET','ETGPOS_FWRITE',false);

% TODO : P3 un-Rock
return;
