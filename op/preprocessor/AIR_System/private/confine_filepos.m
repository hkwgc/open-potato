function confine_filepos(fid,pos)
% This function confile file position indicator.
%
% ------------
% Syntax:
% ------------
%  confine_filepos(fid,pos)
%    fid : File identifier.
%    pos : File position indicator to make sure.
%    
% ------------
% Behaved
% ------------
% If there is contradiction between pos and current
% file-position-indicator, CONFIINE_FILEPOS fix 
% file-position according to pos.
% This is as same as fseek(fid,pos,'bof'), 
% except check & warning.
%
%
% ------------
% Significance
% ------------
% In using MATLAB R2006a, fread sometime over-load a few bytes.
% This is occur when fread load (may-be) Uninitialized region
% as '*char'.
% I do not know why, but I must fix file-position.
%
% ------------
% Example
% ------------
% [fid,msg]=fopen('wk.bin','r');
% if fid==-1, error(msg); end
%
% c=fread(fid,30,'*char');fprintf('%s',c);
% confine_filepos(fid,30); % Confine File-Position is 30
%
% n=fread(fid,1,'int');
% c=fread(fid,n,'*char');fprintf('%s',c);
%
% fclose(fid)
%
% -------------------------------------
% See also FSEEK, FTELL, FREAD, FOPEN, FCLOSE.


p=ftell(fid);
if p~=pos,
  % Disp Warning
  fprintf(2,...
    ['[W] : Fread Error Occur!\n',...
    '      at File Position Indicator %d\n', ...
    '      Move ... %d\n'],pos,pos-p);
  fseek(fid,pos-p,0);
end
