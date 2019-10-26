function pos2=etg_pos_fread(fname)
% Read ETG .pos file
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%
% original author : Masanori Shoji(Hitachi ULSI Systems Co.,Ltd.)
% $Id: etg_pos_fread.m 180 2011-05-19 09:34:28Z Katura $

% Modify : 2006.03.20
% M. Shoji.
%   Pos File format...
%     Ver 2.000 <- ( ? +)
%     Ver 1.200

if nargin~=1,error(nargchk(1,1,nargin)); end
if ~exist(fname,'file'), error('No such a file or directory');end
fid = fopen(fname,'r');

% Position Initialize..
pos.version = 1.01;


% Read Setting : Initialize..
nline       = 0;
pos_level   = 1;
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
      s=regexp(data_tmp, '^\s*\-?\d*\.?\d*$'); %#ok !!for old MATLAB Version!!
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

% ===============================
% Convaert File Data to Pos Data
% ===============================
pos.ver=2;

% == Get 3D-Base Position ==
try
  pos2.D3.Base.Nasion= ...
    [pos.Nasion.X; pos.Nasion.Y; pos.Nasion.Z];
catch
  warning(['No Nasion detected in ' fname]);
end
try
  pos2.D3.Base.LeftEar= ...
    [pos.LeftEar.X; pos.LeftEar.Y; pos.LeftEar.Z];
catch
  warning(['No LeftEar detected in ' fname]);
end
try
  pos2.D3.Base.RightEar=...
    [pos.RightEar.X; pos.RightEar.Y; pos.RightEar.Z];
catch
  warning(['No RigheEar detected in ' fname]);
end
try
  pos2.D3.Base.Back=...
    [pos.Back.X; pos.Back.Y; pos.Back.Z];
catch
end
try
  pos2.D3.Base.Top=...
    [pos.Top.X; pos.Top.Y; pos.Top.Z];
catch
end

% == Get 3D Position ==
pos2.Group.ChData={};
pos2.Group.OriginalCh={};chid0=1;
pos2.Group.mode=[];
pos2.D3.P=[];
if ~isfield(pos,'FileInfo') || ~isfield(pos.FileInfo,'VER')
  error('No Version in the pos file.');
end
if pos.FileInfo.VER>=1.99999
  for pid=1:pos.FileInfo.PROBE,
    pstr=['pos.Probe' num2str(pid)];
    ChNum=eval([pstr '.ChNum']);
    pos2.Group.mode(end+1)=eval([pstr '.MODE']);

    % for Mode 1
    if (pos2.Group.mode(end)==1) && ChNum==18
      pos2.Group.ChData{end+1}=chid0:8+chid0;
      pos2.Group.ChData{end+1}=chid0+9:17+chid0;
      pos2.Group.OriginalCh{end+1}=1:9;
      pos2.Group.OriginalCh{end+1}=1:9;
      pos2.Group.mode(end+1)=1;
    else
      pos2.Group.ChData{end+1}=chid0:ChNum+chid0-1;
      pos2.Group.OriginalCh{end+1}=1:ChNum(1);
    end

    chid0=ChNum+chid0;
    for chid=1:ChNum,
      cstr = eval([pstr '.ch' num2str(chid)]);
      pos2.D3.P=[pos2.D3.P; cstr.X,cstr.Y,cstr.Z];
    end
  end
else
  ChNum = pos.FileInfo.ProbeNum;
  pos2.Group.mode=pos.FileInfo.MODE;
  % for Mode 1
  if (pos2.Group.mode==1) && ChNum==18
    pos2.Group.ChData={1:9,10:18};
    pos2.Group.OriginalCh={1:9,1:9};
    pos2.Group.mode=[1 1];
  else
    pos2.Group.ChData={1:ChNum};
    pos2.Group.OriginalCh={1:ChNum};
  end
  
  for chid=1:ChNum,
    cstr=eval(['pos.Probe' num2str(chid)]);
    pos2.D3.P=[pos2.D3.P; cstr.X,cstr.Y,cstr.Z];
  end
end
%pos2.Group.ChData=pos2.Group.OriginalCh;

if 1, return; end
%=== Debug Print ===
if 1,
  header.Pos=pos2;
  ydata=ones(size(pos2.D3.P,1),1);
  ydata(2:2:end)=-1;
  img_handle=Cube_Plot([], ydata, header,'BRAIN_TYPE',1);
  delete(colorbar);
end

if 0,
  hs=etg_pos_plot2(pos2,'ProbeID',1:length(pos2.Group.ChData));
end