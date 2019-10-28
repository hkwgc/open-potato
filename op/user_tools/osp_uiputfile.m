function varargout=osp_uiputfile(varargin)
% uiputfile from OSP-WORK_DIRECTORY.
%  Arguments of OSP_UIPUTFILE is as same as UIPUTFILE.
%  Only Difference is default Directory.
%
% See also UIPUTFILE, OSP_DATA.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% $Id: osp_uiputfile.m 180 2011-05-19 09:34:28Z Katura $
% Create 17-Jun-2005.
% Masanori Shoji.
%
% Revision : 1.2
%  Change : nargout Control
%  Bugfix : OSP_DATA Path Confuse...(depend on Version of MATLAB)

msg = nargoutchk(2,10,nargout);
if ~isempty(msg),error([ 'osp_uiputfile:' msg ]); end

% get OSP Working Directory
try
  wd = OSP_DATA('GET','WORK_DIRECTORY');
catch
  wd = '';
end
if isempty(wd) || ~isdir(wd), wd=pwd; end
tmpdir = pwd;
cd(wd);

try
  % == Execute uiputfile ==
  [f p fidx] = uiputfile(varargin{:});
  if ~isequal(p,0) && isdir(p),
    cd(p); wd=pwd; % Not to save relative path
  end
catch
  cd(tmpdir); % recover present-working-directory.
  rethrow(lasterror);
end
cd(tmpdir); % recover present-working-directory.

% Output
if nargout>=1, varargout{1}=f;end
if nargout>=2, varargout{2}=p;end
if nargout>=3, varargout{3}=fidx;end

% Setup Working Directory
if exist('wd','var')
  OSP_DATA('SET','WORK_DIRECTORY',wd);
end
return;


