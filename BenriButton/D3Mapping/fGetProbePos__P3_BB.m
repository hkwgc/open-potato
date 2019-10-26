function str=fGetProbePos_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Get Probe Pos';
if nargin<=0,return;end

try
    try
        GetProbePos('\ini\D3_ini.txt');
    catch
        
    end

catch
  % TODO : P3 un-Rock
  errordlg(lasterr);
  return;
end

return;
