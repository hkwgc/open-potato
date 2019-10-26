function rslt=find_dir(dirname, orgn_path,varargin),
% Look for Directory named 'dirname' in 'orgn_path'
%
% dirname_path = find_dir(dirname,orgn_path)



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% Main
  msg=nargchk(2,2,nargin);
  if ~isempty(msg),
    error(msg);
  end
  
  pwd0 = pwd;
  cd(orgn_path);
  try,
    rslt=find_dir2(dirname, '.', {}, varargin{:});
  catch,
    cd(pwd0);
    rethrow(lasterror);
  end
  cd(pwd0);

function rslt=find_dir2(dirname, in_dir, inpt, varargin),
% recursive function : directory check
  rslt=inpt;clear inpt;
  
  pwd0=pwd;
  try,
    cd(in_dir);
  catch,
    disp(['Warning: Try to change ''' pwd ''' to ''' in_dir '''']);
    disp(['         ' lasterr]);
    % warning(lasterr);
    return;
  end

  % get directory
  D=dir;
  id=find(strcmp({D.name},'.'));D(id)=[];
  id=find(strcmp({D.name},'..'));
  D(id)=[];
  id=find([D.isdir]==0); D(id)=[];

  id=find(strcmp({D.name},dirname));
  if ~isempty(id),
    rslt{end+1}=pwd;
    D(id)=[];
  end

  for id=1:length(D),
    rslt=find_dir2(dirname, D(id).name ,rslt, varargin{:});
  end
  
  cd(pwd0);

return;
