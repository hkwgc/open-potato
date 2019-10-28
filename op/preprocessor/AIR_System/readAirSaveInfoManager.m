function data=readAirSaveInfoManager(filename)
% test function for reading binary
%  like od


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if nargin<=0
  filename='C:\AirControlCenterDataBase\SaveData\AirSaveInfoManager.asimtable';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,msg]=fopen(filename,'r');
if fid==-1, error(msg); end

% Read Version
ver=fread(fid,8,'*char');
data.ver=sprintf('%s',ver); % Delete after \0
try
  switch data.ver
    case '1.00'
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Version 1.0 Reader
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      data.key=sprintf('%s',fread(fid,16,'*char'));
      confine_filepos(fid,24);
      % Number of Files
      if 0
        data.n  =fread(fid,1,'int');
      else
        tmp=fread(fid,4,'*char');
        data.n=str2double(tmp');
      end
      %-----------------
      % Load File Names
      %-----------------
      p=28;
      confine_filepos(fid,p);
      for idx=1:data.n
        tmp=fread(fid,8,'*char');p=p+8;
        data.file(idx).topdir=sprintf('%s',tmp);
        confine_filepos(fid,p);

        tmp=fread(fid,24,'*char');p=p+24;
        data.file(idx).name=sprintf('%s',tmp);
        confine_filepos(fid,p);
        
        tmp=fread(fid,32,'*char');p=p+32;
        data.file(idx).key=sprintf('%s',tmp);
        confine_filepos(fid,p);
        
        tmp=fread(fid,12,'*char');p=p+12;
        data.file(idx).enddir=sprintf('%s',tmp);
        confine_filepos(fid,p);
        if 0
          fprintf('--------------\n IDX : %d\n--------------\n',idx);
          disp(data.file(idx));
        end
      end
      
    otherwise
      error(['Unknown Version : ' ver])
  end
catch
  fclose(fid);
  rethrow(lasterror);
end

fclose(fid);
