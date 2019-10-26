function str=set_refpoints__P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Get Ref Pos';
if nargin<=0,return;end

try
    % Check Device
    if 0
        errordlg('No 3D-Device exist\n'); 
        return;
    end
    
    % Open Serial-Port
    if 0
    end
        
    % Open GUI
    try
        set_refpoints('IniFile','\ini\D3_ini.txt');
    catch
        
    end
    
    % Close Serial-Port

catch
  % TODO : P3 un-Rock
  errordlg(lasterr);
  return;
end

return;
