function P3_hiPOTX_IO(varargin)
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%============================
% Get Arguments
%============================
error(nargchk(1, 5, nargin));

% get Path
osppath=OSP_DATA('GET','OSPPATH');
if isempty(osppath)
  osppath=fileparts(which('P3'));
end

% Default Value Setting
fname=varargin{1};  % Target-Data-File Nmae
Recipe='hiPOTXdefaultRecipe.mat';
Layout='hiPOTXdefaultLAYOUT.mat';

% GetARGS
idx=2;
while (idx<length(varargin))
  opt=varargin{idx};
  if length(opt)>=2 && opt(1)=='-'
    switch opt(2)
      case 'r'
        % Read Recipe
        try
          Recipe=varargin{idx+1};
          idx=idx+1;
        catch
          fprintf(2,'[W] Bad argument for  -r\n');
        end
      case 'l'
        % Read Layout
        try
          Layout=varargin{idx+1};
          idx=idx+1;
        catch
          fprintf(2,'[W] Bad argument for  -l\n');
        end
      otherwise
        fprintf(2,'[W] Unknown Option %s\n',opt);
    end
  end
  % update
  idx=idx+1;
end

if ~exist(fname,'file')
  h=errordlg(sprintf('Bad argument : No such File or Directory %s',fname),...
    'Launtch P3 Error');
  waitfor(h);
  return;
end

%============================
% Read Data-Files (List)
%============================
try
  [n, sf, df] = readKTTargetFileNameFile(fname);
catch
  h=errordlg(sprintf('Bad Target File : %s',lasterr),...
    'Read TagetFile');
  waitfor(h);
  return;
end

%=============
% Read Recipe
%=============
%myrecipe=readRecipe(Recipe);
myrecipe=load(Recipe);

%================
% Make Filter
%================
myscript=makestr(myrecipe,osppath);

%=============
% Read Layout
%=============
%mylayout =readLayout(Layout,myrecipe);
mylayout =load(Layout);


%============================
% Execution Loop
%============================
for idx=1:n
  %==========
  % Read Data
  %==========
  % Input : sf, sf
  % Output hdata,data
  sdata=readKTSettingFile(sf{idx}(:)');
  [hdata,data]=readKTMeasureFile(df{idx}(:)',sdata); %#ok
  clear sdata

  %===================
  % * Try-to IMPORT! *
  %===================
  % ProjectOpen
  % P3_gui_SimpleMode('OpenProject',false);
  % DataDef2_RawData('save',hdata,data);

  %=================
  % Execute Recipe
  %=================
  % Input  : hdata, data
  % Output : chdata, cdata, bhdata, bdata
  eval(myscript);
  
  %=============
  % Draw
  %=============
  if ~exist('bhdata','var')
    P3_view(mylayout.LAYOUT,chdata,cdata);
  else
    P3_view(mylayout.LAYOUT,chdata,cdata,'bhdata',bhdata,'bdata',bdata);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nfiles, settingfiles, datafiles]=readKTTargetFileNameFile(filename)
% Read: Target-File-Name File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,msg]=fopen(filename,'r');
if fid==-1, error(msg); end

% Read Version
ver0=fread(fid,8,'*char');
ver0=sprintf('%s',ver0);
try
  switch ver0
    case '1.00.00'
      ofst=8;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Version 1.00.00 Reader
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      key=sprintf('%s',fread(fid,16,'*char'));
      ofst = ofst + 16; confine_filepos(fid,ofst);
      if ~strcmp(key,'_$KT_TDATAFIL$_')
        error('[E] File Keyword Error.');
      end
      
      % Endian Check (in file-specification :: this keyword must be ignore)
      Endian=fread(fid,1,'long');
      if 0, disp(Endian); end  % !!- Donot Use -!!
      ofst = ofst + 4; confine_filepos(fid,ofst);
      
      % Number of Files
      tmp=fread(fid,4,'*char');
      ofst = ofst + 4; confine_filepos(fid,ofst);
      data.n=str2double(tmp');
      
      %-----------------
      % Load File Names
      %-----------------
      nfiles=data.n; % !!OUTPUT!!
      settingfiles=cell([1,nfiles]);
      datafiles   =cell([1,nfiles]);

      for idx=1:nfiles
        settingfiles{idx}=fread(fid,260,'*char');
        ofst = ofst + 260; confine_filepos(fid,ofst);

        datafiles{idx}   =fread(fid,260,'*char');
        ofst = ofst + 260; confine_filepos(fid,ofst);
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myscript=makestr(myrecipe,osppath)
% Make Scirp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make tmp File
fname0=[osppath filesep];
fname=[fname0 'wot_' datestr(now,30) '.m'];
tmp   ='x';
while exist(fname,'file')
  fname = [fname0 'wot_' datestr(now,30) tmp '.m'];
  tmp(end+1)='x'; %#ok
end
try
  [fid, fname] = make_mfile('fopen', fname,'w');
  P3_FilterData2MfileXX(myrecipe.Filter_Manager);
catch
  try
    make_mfile('fclose');
  catch
    fclose(fid);
  end
  h=errordlg(sprintf('Bad Recipe: %s',lasterr),'Make M-file');
  waitfor(h);
  return;
end
make_mfile('fclose');

%!! for !!
[fid,msg]=fopen(fname,'r');
if(msg), 
  h=errordlg(sprintf('Recipe: %s',msg),'Make M-file');
  waitfor(h);
  return;
end
myscript = fread(fid,inf,'*char');
fclose(fid);

% delete
try
  delete(fname);
catch
end

%%%
function P3_FilterData2MfileXX(fmd, stimtype, stimkind)
% Make M-File from FilterData (P3)
% Original :: P3_FilterData2Mfile.m

% ==== Argument Check =========
% if no argument Read HB Data
msg = nargchk(1,4,nargin);
if ~isempty(msg), error(msg); end

% == Continuous Data Loop Start. ==
if exist('stimtype','var'),
  make_mfile('with_indent', ...
    '% Stimulation Data Setting');
  make_mfile('with_indent', { ...
    '% Block - Stimulation - Marking',  ...
    sprintf('hdata = uc_makeStimData(hdata,%d);', stimtype), ...
    ' '});
end

if isfield(fmd,'HBdata'),
  % -- Set Filter --
  for fidx=1:length(fmd.HBdata),
    try
      if isfield(fmd.HBdata{fidx},'enable') && ...
          strcmpi(fmd.HBdata{fidx}.enable,'off'),
        continue;
      end
      str = ...
        feval(fmd.HBdata{fidx}.wrap,'write', ...
        'HBdata', fmd.HBdata{fidx});
      if ~isempty(str),
        make_mfile('with_indent', str);
      end
    catch
      make_mfile('with_indent', ...
        sprintf('warning(''write error: at %s'');', fmd.HBdata{fidx}.name));
      warning(lasterr);
    end % try-catch
  end % filter output
  make_mfile('code_separator', 2);
end, % HBdata?

make_mfile('with_indent',{' ' ...
  'cdata = {data};  chdata = {hdata};', ' '});


%==================================
%% Blocking
%==================================
% No - Blocking
if ~isfield(fmd,'BlockPeriod'),
  return;
end
if isfield(fmd,'block_enable') && fmd.block_enable==0,
  return;
end

% Bugfix : B070622A
if isfield(fmd,'TimeBlocking'),
  blocking=fmd.TimeBlocking{1};
  if isfield(blocking,'enable') && ...
      strcmpi(blocking.enable,'off'),
    return;
  end
  str = feval(blocking.wrap,'write', 'BlockData', blocking);
  if ~isempty(str),
    make_mfile('with_indent', str);
  end  
else
  if exist('stimkind','var') && ~isempty(stimkind),
    stimkind_str=stimkind(:)';
    stimkind_str=num2str(stimkind_str);
    if length(stimkind)>=2,
      stimkind_str=['[' stimkind_str ']'];
    end
    make_mfile('with_indent', ...
      {'% === Time Blocking === ', ...
      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f,%s);', ...
      fmd.BlockPeriod(1), fmd.BlockPeriod(2), stimkind_str), ...
      ' '});
  else
    make_mfile('with_indent', ...
      {'% === Time Blocking === ', ...
      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f);', ...
      fmd.BlockPeriod(1), fmd.BlockPeriod(2)), ...
      ' '});
  end
end

% == Block Data Loop Start. ==
if isfield(fmd,'BlockData'),
  make_mfile('code_separator', 2);
  make_mfile('with_indent','% === To Block Data === ');
  % -- Set Filter --
  for fidx=1:length(fmd.BlockData),
    try
      if isfield(fmd.BlockData{fidx},'enable') && ...
          strcmpi(fmd.BlockData{fidx}.enable,'off'),
        continue;
      end
      str = ...
        feval(fmd.BlockData{fidx}.wrap,'write', ...
        'BlockData', fmd.BlockData{fidx});
      if ~isempty(str),
        make_mfile('with_indent', str);
      end
    catch
      make_mfile('with_indent', ...
        sprintf('warning(''write error: at %s'');', fmd.BlockData{fidx}.name));
      warning(lasterr);
    end % try-catch
  end % filter output
  make_mfile('code_separator', 2);
end, % BlockData?

% rename :
% Recode of OSP-v1.5 9th-Meeting of on 27-Jun-2005.
% Change on 28-Jun-2005 by Shoji.
make_mfile('with_indent', ...
  {'% Rename', ...
  'bdata  = data;', ...
  'bhdata = hdata;', ...
  ' '});
make_mfile('code_separator', 1);
make_mfile('with_indent',' ');
return;





