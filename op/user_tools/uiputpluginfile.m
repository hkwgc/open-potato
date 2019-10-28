function [filename, pathname]=uiputpluginfile(mode, name, dirname)
% put - Plugin - Filename

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Masanori Shoji
% create : 2005.11.29
% $Id: uiputpluginfile.m 180 2011-05-19 09:34:28Z Katura $

% Arguments Check
msg = nargchk(0,3,nargin);
if ~isempty(msg), error(msg); end

% ---
if nargin<=0
  mode=2;
end
if nargin<=1
  name='Untitled';
end


%osp_dir=which('OSP');
%[pathname, f] = fileparts(osp_dir);
pathname = fileparts(which('POTATo'));
pathname = [pathname filesep];

switch mode,
  case 2,
    tstr     = 'Filter Plugin';		% Title
    basename = 'PlugInWrap_';		% FileName Definition
    pluginpath = [pathname  'PluginDir'];	% Default Path
    pathname = [pathname  'PluginDir'];	% Default Path

    if 2<nargin
      if ~isempty(dirname),
        % Check input string
        if (strcmp(dirname,'.')),  dirname=[];end
        if (strcmp(dirname,'..')), dirname=[];end
        dirname=rename_as(dirname); % Same as
        % DataDef_SignalPreprocessor
      end
      if ~isempty(dirname),
        % Check directory and Make
        dirname = checkAndMake_as(dirname, pathname);
      end
      if ~isempty(dirname),
        pathname = [pathname filesep dirname];	% Path
      end
    end
  case 3,
    tstr     = 'Analysis Plugin';		% Title
    basename = 'PluginGui_';		% FileName Definition
    pathname = [pathname  'APluginGuiDir'];	% Path
  otherwise,
    error([ num2str(mode) ' : Undefined mode for ' mfilename]);
end

if ~exist(pathname,'dir'),
  error('No Plugin Directory Exist')
end

% Make Figure
%%pwd0=pwd;
%%cd(pathname);
%%[filename pathname] =uiputfile_osp({[basename '*.m'],'Plugin Dir'}, ...
%%			       tstr, [basename name '.m']);
%%cd(pwd0);
% 0622 Fixed version
%[filename pathname] =uiputfile_osp({[basename '*.m'],'Plugin Dir'}, ...
%			       tstr, [basename name '.m'], ...
%			       'FixedDirectory', pathname);
% 0626 UpperDir version
pwd0=pwd;
%cd(pluginpath);
cd(pathname);
[filename pathname] =uiputfile_osp({[basename '*.m'],'Plugin Dir'}, ...
  tstr, [basename name '.m'], ...
  'TopLevelDirectory', 'on', ...
  'MaximumDepth', 2);
cd(pwd0);
return;

function nstr = rename_as(str)
%     str    : check name of directory or file
%     nstr   : replace string

nstr = [];
if isempty(str), return; end

str = strrep(str,' ','_');
str = strrep(str,'-','_');
str = strrep(str,'+','_');
str = strrep(str,'%','_');
str = strrep(str,'=','_');

str = strrep(str,'/','_');
str = strrep(str,'\','_Y_');

str = strrep(str,'?','_');
str = strrep(str,'@','_At_');
str = strrep(str,'#','_No_');
nstr =str;
return;

function ndir = checkAndMake_as(dirname, curpath)
%     dirname  : Check directory name
%     curpath  : Searching directory
%     ndir   : replace string

ndir = [];
% Check
if isempty(dirname), return; end
rslt = find_dir(dirname, curpath);

if ~isempty(rslt),
  ndir = dirname;
  return;
end

% Make
pwd0=pwd;
try
  %%%cd(curpath);
  [status, msg]=mkdir(curpath, dirname);
  if status == 0,
    error(msg);
  end
  ndir=dirname;
catch
  disp(['Warning: Try to makedirectory ' dirname ' to ' curpath]);
  disp(['         ' lasterr]);
  % warning(lasterr);
  return;
end

return;


