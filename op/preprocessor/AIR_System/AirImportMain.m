function [msg,slog]=AirImportMain(importdata,hs,renameflag)
% Main Function to Import Air to Project.
%  !! To use function, Open Project at Fast, !!
%
%------------------------------------------
% Syntax : 
%  [msg,slog]=AirImportMain(importdata,hs,renameflag)
%------------------------------------------
%  Input Data :
%    importdata : Data to Import.
%        if importdata is directory, Load Data Under the Directory.
%
%     hs        : Handles of AirData2P3Project,
%                 This argument needless.
%
%     renameflag : (Option )
%                  Use Rename/not
%   Output Data :
%      msg    : Error Messages.
%      slog   : Log Message.
%
% Example:
%   [emsg,slog] =AirImportMain('C:\AirControlCenterDataBase\SaveData');
%   if msg,errordlg(msg);end
%   if slog,helpdlb(slog);end


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin <2
  hs=[];
end
if nargin <3
  renameflag=false;
end

airsetfs=AirFiles(importdata);
Air_List=DataDef2_RawData('loadAirList');
% No Rename
if ~renameflag
  OSP_DATA('SET','SP_Rename','-');
end

%------------------
% Wait Bar Setting
%-----------------
flen=length(airsetfs);
if ~isempty(hs)
  set(hs.figure1,'CurrentAxes',hs.axes_waitbar);
  cla
  px=linspace(0,1,flen+1);
  c=ones([3,flen*2,3])*0.7;
  pxx=[px(1:end-1) px(1:end-1) ;px(2:end) px(2:end);px(1:end-1) px(2:end)];
  pyy=[repmat([0 0 1]',1,flen), repmat([1 1 0]',1,flen)];
  ph=patch(pxx,pyy,c);
  set(ph,'LineStyle','none');drawnow;


  % Color Setting
  c0=ones([3,2,3])*0.7;
  co=c0;co(:,:,3)=0.97; % OK
  ce=c0;ce(:,:,1)=0.9;  % Error
  cw=ce;cw(:,:,:)=0.9;  % Warning
end

%------------------
% Execute!!
%-----------------
msg={};
slog={};
for idx=1:flen
  %-------------------
  % Check Directory
  %-------------------
  ftime0 = dir(airsetfs{idx});
  ftime0 = datenum(ftime0.date);
  p=fileparts(airsetfs{idx});
  mesfile0=dir([p filesep '*.airMeasure']);
  if length(mesfile0)~=1
    % Message
    msg{end+1}=sprintf('No-File Measure-File : %s',airsetfs{idx});
    % Log
    slog{end+1}=sprintf('x, ------, No-File Measure-File');
    % Status Bar
    if ~isempty(hs)
      c(:,[idx, idx+flen],:)=ce; % Error
      set(ph,'Cdata',c);drawnow;
    end
    continue;
  end
  mesfile=[p filesep mesfile0.name];
    
  %-------------------
  % Load Setting File
  %-------------------
  try
    sdata=readAirSettingFile(airsetfs{idx});
  catch
    % Message
    msg{end+1}=sprintf('Load Error : %s',airsetfs{idx});
    msg{end+1}=sprintf('             %s',lasterr);
    % Log
    slog{end+1}=sprintf('x, %s, Setting-File LoadError',mesfile);
    % Status Bar
    if ~isempty(hs)
      c(:,[idx, idx+flen],:)=ce; % Error
      set(ph,'Cdata',c);drawnow;
    end
    continue
  end

  %-----------------------
  % Determine Raw-FileName
  %------------------------
  rname=sprintf('%s_%02d_%s',...
    sdata.MeasureID,sdata.CometID,...
    sdata.USERINFO.cName);
  contflag=false;
  if ~isempty(Air_List) 
    x=strmatch(rname,{Air_List.filename},'exact');
    if length(x)==1 && (Air_List(x).time + 1/24/60/30 > datenum(ftime0))
      contflag=true;
    end
  end
  if contflag
    % Message
    % Log
    slog{end+1}=sprintf('-, %s, found in the Project',mesfile);
    % Status Bar
    if ~isempty(hs)
      c(:,[idx, idx+flen],:)=cw; % Warning
      set(ph,'Cdata',c);drawnow;
    end
    continue;
  end

  %-----------------------
  % Load Measure-File
  %------------------------
  try
    [hdata,data]=readAirSaveMeasureFile(mesfile,sdata);
    hdata.TAGs.filename=rname;
  catch
    % Message
    msg{end+1}=sprintf('Load Error : %s',mesfile);
    msg{end+1}=sprintf('             %s',lasterr);
    % Log
    slog{end+1}=sprintf('x, %s, Measure-File LoadError',mesfile);
    % Status Bar
    if ~isempty(hs)
      c(:,[idx, idx+flen],:)=ce; % Error
      set(ph,'Cdata',c);drawnow;
    end
    continue
  end
  
  %-----------------------
  % Save as Raw-Data
  %------------------------
  try
    DataDef2_RawData('save_air',hdata,data,ftime0);
  catch
    % Message
    msg{end+1}=sprintf('Save Error : %s',mesfile);
    msg{end+1}=sprintf('             %s',lasterr);
    % Log
    slog{end+1}=sprintf('x, %s, Save Error',mesfile);
    % Status Bar
    if ~isempty(hs)
      c(:,[idx, idx+flen],:)=ce; % Error
      set(ph,'Cdata',c);drawnow;
    end
    continue
  end
  
  %-----------------------
  % Logging
  %------------------------
  % Log
  slog{end+1}=sprintf('o, %s, Load',mesfile);
  % Status Bar
  if ~isempty(hs)
    c(:,[idx, idx+flen],:)=co; % Error
    set(ph,'Cdata',c);drawnow;
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Air - File Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function airsetfs=AirFiles(impdata)
% Get Air-Files Name List

%--> Air Save-Data Path
p0=OSP_DATA('GET','PROJECTPARENT');
p1=OSP_DATA('GET','PROJECT');
fname=[p0 filesep p1.Name filesep 'AirSaveDataPath.txt'];

% --> From 'OpenCurrentAirData'
if ~ischar(impdata)
  airsetfs=impdata.SettingFile;
  fid=fopen(fname,'w');
  try
    if ~isempty(impdata.SettingFile)
      [s,e]=regexpi(impdata.SettingFile{1},'SaveData');
      if iscell(e),e=e{end};end
      if 0,disp(s);end
      airpath=impdata.SettingFile{1}(1:e(end));
      fprintf(fid,'%s',airpath);
    end
  catch
   fclose(fid); rethrow(lasterror);
  end
  fclose(fid);
  return;
end

fid=fopen(fname,'w');
try
  fprintf(fid,'%s',impdata);
catch
  fclose(fid); rethrow(lasterror);
end
fclose(fid);


%get Air Setting-Files
% (Old : Search All files)
if 0
  airsetfs=find_file('\.airmset$',impdata,'-i');
  return;
end

%===================================
% Current :
%  Pick-up Correct Files
%===================================
%dbgmode=true;
dbgmode=false;
cwd    = pwd;

% Open Debug File
if dbgmode
  p=fileparts(which(mfilename));
  fname=[p filesep 'AirDirectory.csv'];
  fid=fopen(fname,'w');
end

airsetfs={};
try
  % Top Directory
  cd(impdata); % SaveD
  topdir=dir;
  topdir([topdir.isdir]==false)=[]; % Only Directory

  % Exprerimental ID Direcoty Loop
  for eidx=1:length(topdir)
    % Ignore '.' / '..' / '.*'
    if strcmpi(topdir(eidx).name(1),'.'),continue;end
    cd(topdir(eidx).name)
    
    edir=dir;
    edir([edir.isdir]==false)=[]; % Only Directory
    % Terminal (Comet) Directory Loop
    for tidx=1:length(edir)
      if ~strcmpi(edir(tidx).name(1),'T'),continue;end
      cd(edir(tidx).name);

      tdir=dir;
      tdir([tdir.isdir]==false)=[]; % Only Directory
      % Subdirecotry (Copy Directory Loop)
      addfile=[];
      for sidx=1:length(tdir)
        if strcmpi(tdir(sidx).name(1),'.'),continue;end
        if dbgmode
          fprintf(fid,'%s,%s,%s,',...
            topdir(eidx).name,edir(tidx).name,tdir(sidx).name);
        end
        
        asfile=dir([tdir(sidx).name filesep '*.airmset']);
        amfile=dir([tdir(sidx).name filesep '*.airMeasure']);
        if length(asfile)~=1 || length(amfile)~=1
          warning([' [E] Save-Directory might be broken at ' pwd]);
          if dbgmode, fprintf(fid,'ERROR\n'); end
          continue; %Escape Sub-Directory
        end
        tmp.name=asfile(1).name;
        tmp.path=tdir(sidx).name;
        tmp.ispc=strcmpi(amfile(1).name(end-12:end-11),'PC');
        tmp.date= datenum(asfile(1).date);
        
        if isempty(addfile) 
          addfile=tmp;
          if dbgmode, fprintf(fid,'Add\n'); end
        else
          if tmp.ispc 
            if ~addfile.ispc || addfile.date<tmp.date
              addfile=tmp;
              if dbgmode, fprintf(fid,'Update\n'); end
            end
          else
            if ~addfile.ispc && addfile.date<tmp.date
              addfile=tmp;
              if dbgmode, fprintf(fid,'Update\n'); end
            end
          end
        end % Addfile Check
        
      end % Sub func
      if ~isempty(addfile)
        airsetfs{end+1}=[pwd filesep addfile.path filesep addfile.name];
        if dbgmode, fprintf(fid,'-->%s\n',airsetfs{end}); end
      end
      cd('..');
    end % Terminal
    cd('..');
  end % Experimental
catch
  cd(cwd);
  if dbgmode, fclose(fid); edit(fname);end
  rethrow(lasterror);
end

cd(cwd);
if dbgmode, fclose(fid); edit(fname);end





