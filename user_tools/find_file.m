function rslt=find_file(ptn, orgn_path,varargin)
% Look for file  matching 'PTN' under 'SEARCH_PATH'
%
% Syntax :
%    FS = find_file(PTN, SEARCH_PATH);
%      PTN : Pattern for find file.
%            Definition of Pattern is as same as REGEXP
%      SEARCH_PATH : Search Path
%
%      FS : Cell-Array of Fullpath.
%
%  Option : '-i' : Ignore Case.
%                  in Windows, it is better to set -i
%                  (regardless of Large/Small charactor)
%         : '-n' : Indicate Following Argument is Max-Depth.
%                  This function Descend at most Max-Depth.
%                  (integer 1-20)
%
% Example:
%   1. Search pdf file and list
%       FS = find_file('\.pdf$', pwd, '-i');
%       for idx=1:length(FS),
%          [p n f] = fileparts(FS{idx});
%          disp(n); % Display
%       end
%
%
% See also REGEXP, REGEXPI, PWD, FILEPARTS,
%          FILD_DIR.



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% Revision 1.3 :
%    Bugfix      : Regexp
%    Add Comment :

%----------------
% Read Argument
%----------------
msg=nargchk(1,7,nargin);
if ~isempty(msg), error(msg); end

% Default Search-Path
if nargin<2, orgn_path=pwd; end

% Option : Initialized
regexpfnc=@regexp; % Regular Expression Function
n0= get(0,'RecursionLimit'); % from R2006a
n = n0;

stepflg=false;
% Read Options
for idx=1:length(varargin),
  if stepflg,stepflg=false;continue;end
  switch(varargin{idx}),
    case '-i',
      regexpfnc=@regexpi; % Regular Expression : Ignore Case

    case '-n',
      % Read Max Depth
      if idx+1>=length(varargin),
        % idx=idx+1; % no effect...
        stepflg=true;
        n=varargin{idx+1};
        if isnumeric(n),
          if n<1,
            n=1;
            disp(' Max-Depth : Negative Value:: Change n=1');
          end
          if n>n0,
            set(0,'RecursionLimit',n);
          end
        else
          n=20;
          disp('Max-Depth : must a numeric');
        end
      end
    otherwise,
      disp('Ignore Undefined Option');
  end
end
%pwd0 = pwd;

%======================
% Serach Here!
%======================
if ~isdir(orgn_path)
  error('[E] : No such a file or directory. %s',orgn_path);
end
%rslt={};
try
  rslt=find_file2(ptn, orgn_path, {}, regexpfnc,n);
catch
  rethrow(lasterror);
end
%======================
% End
%======================

function rslt=find_file2(ptn, in_dir, inpt, regexpfnc, n)
% recursive function : Find Files
rslt=inpt;clear inpt;
n=n-1; if n<0, return; end

% get directory
D=dir(in_dir);
D(strcmp({D.name},'.')) =[];
D(strcmp({D.name},'..'))=[];

s=feval(regexpfnc,{D.name},ptn);
if ~iscell(s),s={s};end
idx0=find(~cellfun('isempty',s));
for idx=idx0(:)'
  %full path
  rslt{end+1}=[in_dir filesep D(idx).name];
end

D([D.isdir]==0)=[];
for id=1:length(D),
  next_dir = [in_dir filesep D(id).name];
  rslt=find_file2(ptn, next_dir, rslt, regexpfnc, n);
end
return;
