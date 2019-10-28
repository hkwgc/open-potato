function [fileName, pathName, filtID]=osp_uigetfile(varargin)
% uigetfile from OSP-WORK_DIRECTORY.
%  OSP_UIGETFILE is modification of uigetfile.  
%  The default directory will be change to OSP Working Directory.
%  or current directory of matlab. 
%  
%  Syntax
%  [fileName, pathName, filtID]=osp_uigetfile;
%  [fileName, pathName, filtID]=osp_uigetfile(filter);
%  [fileName, pathName, filtID]=osp_uigetfile(filter, title);
%
%  The other syntax for uigetfile is not permitted.
% 
% See also UIGETFILE, OSP_DATA.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% author : Hiroshi KAWAGUCHI
% create : 2019.10.22

narginchk(0,2)

% get OSP Working Directory
try
    wDir = OSP_DATA('GET','WORK_DIRECTORY');
catch
    wDir = '';
end
if isempty(wDir) || ~isfolder(wDir)
    wDir = pwd;
end
tmpDir = pwd;

switch nargin
    case 0
        str_filter ='';
        str_title  ='';
    case 1
        str_filter =varargin{1};
        str_title  ='';
    case 2
        str_filter =varargin{1};
        str_title  =varargin{2};
end

try
  [fileName, pathName, filtID] = uigetfile(str_filter, str_title, wDir);
  if ~isequal(pathName,0) && isfolder(pathName)
    cd(pathName);
    wDir = pwd; % Not to save relative path
    cd(tmpDir);
  end
catch ME
  rethrow(ME);
end

% Setup WORK_DIRECTORY
OSP_DATA('SET','WORK_DIRECTORY', wDir);

return;
