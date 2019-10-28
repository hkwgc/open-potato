function varargout=dev3dpos(cmd,varargin)
% Make P3 Data by Cell-array From Files.

persistent fnc; % デバイス毎に変化させる関数

if  isempty(fnc) || ~isa(fnc, 'function_handle')
  % 各種変数の初期化
  %read ini file
  IniFile='BenriButton\D3Mapping\ini\D3_ini.txt';
  try
        fid=fopen(IniFile,'r');
  catch
        error(['Ini-File not opend: ' IniFile]);
        return;
  end
  [Serial Std_Ref GuiAppli Navigation D3View]=Ini_file_read(fid);
  fclose(fid);
  if(strcmp(lower(Serial.Device),'isotrak2'))
        fnc=@dev3dpos_isotrack;
  
  elseif(strcmp(lower(Serial.Device),'patriot'))
        fnc=@dev3dpos_patriot;
  end
  
end

if nargout,
  [varargout{1:nargout}] = feval(fnc, cmd, varargin{:});
else
  feval(fnc, cmd, varargin{:});
end