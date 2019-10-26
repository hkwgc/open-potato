function pos2=etg_pos_fwrite(fname,posCH,posfile)
% Write ETG .pos file
%
% $Id: etg_pos_fwrite.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji(Hitachi ULSI Systems Co.,Ltd.)
% Import from etg_pos_fread(1.5)
%
%--------------------------------
% Rivition 1.1 , M. Shoji.
%     New

error(nargchk(2,3,nargin));
%if ~exist(fname,'file'), error('No such a file or directory');end



%==========================================================
% Making Default Version
%==========================================================
pos.FileInfo.ID='';
pos.FileInfo.VER=2;
pos.FileInfo.PROBE=0;
pos.FileInfo.TYPE=0; % ??
pos.User.Name='Somebody';
pos.User.ID =0;
pos.User.Comment='';
pos.User.Sex='Male';
pos.User.Age='0y';

ORG.X=0;ORG.Y=0;ORG.Z=0;
pos.LeftEar=ORG;
pos.RightEar=ORG;
pos.Nasion=ORG;
pos.Back=ORG;
pos.Top =ORG;
pos.Angle=ORG;

try
  %==========================================================
  % Update Header by SD-File
  %==========================================================
  if nargin>=3
    % Read Original-SD-File
    fid   = fopen(posfile,'r');
    % Read Setting : Initialize..
    nline       = 0;
    fieldname = 'unknown';
    while 1
      % ========= File Read ========
      tline = fgetl(fid);
      nline       = nline+1;
      % End ?
      if ~ischar(tline), break; end
      if isempty(tline),continue;end

      % ========= Parse ============
      try
        [s, e, t] =regexp(tline, '\[([\W\w]*)\]');
        if ~isempty(t),  % --> Make New Filed ?
          %======> Make New Structure <=======
          %  [FileInfo]/[User]/[Probe1], [LeftEar], ....
          %   and so on ..
          fieldname = tline(t{1}(1):t{1}(2));
          fieldname = strrep(fieldname,'-','.');
        else
          %======> Add Field <=======
          % Add Data
          eq_pos = strfind(tline,'=');
          if numel(eq_pos)~= 1,
            warning(sprintf([ ...
              '[Platform] Warning:!!!\n' ...
              '<<%s\n' ...
              '<< in %s(%d) :\n' ...
              '<< Syntax error before "="'],...
              C__FILE__LINE__CHAR, fname, nline));
            continue;
          end
          data_tmp = tline(eq_pos(1)+1:end);
          s=regexp(data_tmp, '^\s*\-?\d*\.?\d*$'); %#ok<RGXP1> for old MATLAB version
          if isempty(s),
            data_tmp = ['''' data_tmp ''''];
          end
          try
            eval(['pos.' fieldname '.'  tline(1:eq_pos(1)) data_tmp ';']);
          catch
            warning(sprintf([ ...
              '[Platform] Warning:!!!\n' ...
              '<<%s\n' ...
              '<< in %s(%d) :\n' ...
              '<< Unknown Error!'],...
              C__FILE__LINE__CHAR, nline));
          end
        end
      catch
        % TODO;
        disp(tline);
        warning(lasterr);
      end
    end
    fclose(fid);
  end
catch
  warning('Ignore SD-Pos-File, becase error');
end

fid   = fopen(fname,'w');
try
  % ===============================
  % Write Headder
  % ===============================

  % Update by Position
  pos.FileInfo.PROBE=length(posCH.Group.ChData);
  pos.FileInfo.VER=2;
  % Base Position
  fn=fieldnames(posCH.D3.Base);
  for id=1:length(fn)
    if length(posCH.D3.Base.(fn{id}))==3
      pos.(fn{id}).X=posCH.D3.Base.(fn{id})(1);
      pos.(fn{id}).Y=posCH.D3.Base.(fn{id})(2);
      pos.(fn{id}).Z=posCH.D3.Base.(fn{id})(3);
    end
  end

  my_strwrite(fid,pos,'FileInfo');
  my_strwrite(fid,pos,'User');
  my_strwrite(fid,pos,'LeftEar');
  my_strwrite(fid,pos,'RightEar');
  my_strwrite(fid,pos,'Nasion');
  my_strwrite(fid,pos,'Back');
  my_strwrite(fid,pos,'Top');


  %=============================
  % Write Probe
  %=============================
  for pid=1:length(posCH.Group.ChData)
    % Probe Header
    fprintf(fid,'[Probe%d]\n',pid);
    fprintf(fid,'MODE=%d\n',posCH.Group.mode(pid));
    fprintf(fid,'ChNum=%d\n',length(posCH.Group.OriginalCh{pid}));
    % Each Channel
    for cid=1:length(posCH.Group.OriginalCh{pid})
      ci=posCH.Group.ChData{pid}(cid);
      fprintf(fid,'[Probe%d-ch%d]\n',pid,cid);
      fprintf(fid,'X=%f\nY=%f\nZ=%f\n', posCH.D3.P(ci,1),posCH.D3.P(ci,2),posCH.D3.P(ci,3));
      fprintf(fid,'A=0.000000\nE=0.000000\nR=0.000000\n');
      fprintf(fid,'NX=0.000000\nNY=0.000000\nNZ=0.000000\n');
    end
  end
  my_strwrite(fid,pos,'Angle');
catch
  fclose(fid);
  error('Write Error');
end
fclose(fid);

function my_strwrite(fid,pos,fld)
fprintf(fid,'[%s]\n',fld);
s=pos.(fld);
fn=fieldnames(s);
for id=1:length(fn)
  fprintf(fid,'%s=',fn{id});
  a=s.(fn{id});
  if isnumeric(a)
    if (a-round(a))==0
      fprintf(fid,'%d\n',a);
    else
      fprintf(fid,'%f\n',a);
    end
  else
    fprintf(fid,'%s\n',a);
  end
end
