function str=fNavigation_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Navigation';
if nargin<=0,return;end

try
        
    % Open Serial Port
%	s=serial('com3','BaudRate',115200,'Parity','none');
%	fopen(s);

    % Open GUI
    
    try
%        Navigation('SerialPort',s);
	Navigation('IniFile','\ini\D3_ini.txt');
    catch
        
    end

    % Close Serial Port
%	CtrlY=char(25);
%	fprintf(s,CtrlY);
%	fclose(s);
catch
  % TODO : P3 un-Rock
  errordlg(lasterr);
  return;
end

return;
