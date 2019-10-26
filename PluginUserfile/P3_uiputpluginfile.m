function [filename, pathname]=P3_uiputpluginfile(finfo, name, dirname)
% put - Plugin - Filename
%
% Extend from uiputpluginfile (r1.6)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.11.29
% $Id: P3_uiputpluginfile.m 180 2011-05-19 09:34:28Z Katura $

% Arguments Check
msg = nargchk(3,3,nargin);
if ~isempty(msg), error(msg); end

tstr='File-Name of Plugin-Wrapper';
[fullname,msg]=checkname(finfo,[dirname filesep name]);
if msg, 
  [dirname f0 e0]=fileparts(finfo.default);
  name=[f0 e0];
  if 0,disp(fullname);end
end
pathname = finfo.path;
basename = finfo.base;


if ~isdir(dirname)
  dirname=pathname;
end
pwd0=pwd;
cd(dirname);
[filename pathname] =uiputfile_osp({[basename '*.m'],'Plugin Dir'}, ...
  tstr, name, ...
  'TopLevelDirectory', pathname, ...
  'MaximumDepth', 2);
cd(pwd0);
[fullname,msg]=checkname(finfo,[pathname filesep filename]);
if msg, 
  disp(fullname);
  error(msg);
end

return;

function [str,msg]=checkname(ud,str)
%---------------------
% Confine Name
%---------------------
msg='';
[p,f,e] =fileparts(str);
idx=strmatch(ud.path,[p filesep]);
if isempty(idx), 
  str='';
  msg='File Path Error';
  return;
end
idx=strmatch(ud.base,f);
if isempty(idx), 
  str='';
  msg='Base Name Error';
  return;
end
if isempty(e)
  e='.m';
  str=[p filesep f e];
else
  idx=strcmpi('.m',e);
  if isempty(idx),
    str='';
    msg='Extension Error';
    return;
  end
end
