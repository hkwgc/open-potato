function varargout=make_mfile(fcn, varargin)
% MAKE_MFILE make M-File for OSP M-Out function.
% -----------------------
%  How to use MAKE_MFILE
%   1. to open file
%      make_mfile('fopen',filename, permission);
%      where read-only permission is improper.
%      default permission is 'w'
%
%   2.set output stream
%      make_mfile('ver_date');
%        put return-code
%        (setend of line, that is \n(\n\r) write.
%
%      make_mfile('write', str);
%         push formated stream.
%         change noting.
%
%      make_mfile('with_indent', str);
%         set indent and write str.
%
%      make_mfile('as_comment', str);
%         Coment-String without '%'
%
%      make_mfile('code_separator', level);
%         Write Code-Separator.
%         level is 1: high : %%%%%%%%%%%%%%%%%%%
%                  2: midl : ===================
%                  3: low  : -------------------
%
%   3. setting Indent
%      make_file('indent_fcn', 'SetSize',indent_size);
%         set Indent size in space-character.
%             Default is 3.
%      indent = make_file('indent_fcn');
%         return indent-level.
%      indent = make_file('indent_fcn','up');
%         up indent level.
%      indent = make_file('indent_fcn','down');
%         down indent level.
%      indent_str = make_file('indent_fcn','getstr')
%         return Indent string.
%
%   4. to close
%      make_mfile('fclose');
%
%  (4-5) close with delete file
%      make_mfile('kill');
%
%  See also FPRINTF, REPMAT.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.06.15
% $Id: make_mfile.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion v1.3
%   Unknown flush error in MATLAB 7.0
%   >> Error on Flush... 
%   bad checking in fprintf & ferror?
%   No a serious probrem?

  
  switch lower(fcn),
   case {'fopen','fclose', 'getfileinfo','kill'},
    if nargout,
      [varargout{1:nargout}] = FILE_ID(fcn, varargin{:});
    else
      FILE_ID(fcn, varargin{:});
    end

   otherwise,
    % == check if file is open. ==
    fid=FILE_ID;
    if isempty(fid), error('No File Open');  end

    % Execute Inner Function
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else,
      feval(fcn, varargin{:});
    end
  end  % switch fcn

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% as tool.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rc=ReturnCode_str
% return code;
  rc=[];
  if ispc,
    rc = sprintf('\r\n');
  elseif isunix,
    rc = sprintf('\n');
  else,
    rc = sprintf('\r');
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1, 4 : File Open/Close           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [varargout]=FILE_ID(mode, fname_a, varargin)
% FILE_ID get or set File-ID
  persistent fid;
  persistent fname;

  msg=[];
  % get fid
  if nargin<1 || isempty(mode),  mode='getfileinfo';  end

  switch lower(mode),

   case 'fopen',
    if nargin<2, fname = tempname; 
    else, fname = fname_a;
    end

    permission0 = 'w';
    if nargin>= 3,
      permission0 = varargin{1};
    end

    if ~isempty(fid), 
		error(['File Already Opened : ' fname ...
				'If you want to reset this function, type : make_mfile(''kill'');']);
	end
    [fid, msg] = fopen(fname,permission0);
    if fid<0, error(msg); end
    indent_fcn('init');
    
    mlock;

   case 'fclose',
    if ~isempty(fid), fclose(fid); end
    fid=[]; % fname=[];
    munlock;

   case 'kill',
    try
       if ~isempty(fid),  fclose(fid); end
    catch
        warning(lasterr);
    end
    fid=[]; 
    delete(fname); fname=[];
    munlock;

   case 'getfileinfo',
   otherwise,
    warning(['undefined mode for make_osp_mfile : ' ...
	     mode]);
  end

  if nargout >= 1, varargout{1}=fid; end
  if nargout >= 2, varargout{2}=fname; end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3 : Indent function              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = indent_fcn(varargin)
  persistent indent;
  persistent indent_size;

  if isempty(indent), indent=0; end
  if isempty(indent_size), indent_size=3; end


  if nargin<1, 
    mode='get'; 
  else
    mode=varargin{1};
  end


  switch lower(mode),
   case 'get',
    varargout{1} = indent; % nargout must be lager than 1

   case 'up',
    if indent>=1, indent = indent-1; end
    if nargout>=1, varargout{1} = indent; end

   case 'down',
    if indent>=0, indent = indent+1;
    else indent=1; end
    if nargout>=1, varargout{1} = indent; end

   case 'init',
    indent=0;
    if nargout>=1, varargout{1} = indent; end

   case 'getstr',
    indent_str=repmat(' ',1,indent_size*indent);
    varargout{1} = indent_str;% nargout must be lager than 1

   case 'setsize'
    msg=nargchk(2,2,nargin);
    if ~isempty(msg), error(msg); end
    indent_size=varargin{2};
   otherwise,
    error(['improper mode for indent : ' mode]);
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Writing Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ver_date
% Write Version and Time-Stamp
  [fid, fname] = FILE_ID;
  fprintf(fid, ...
	  ['%% -- ' fname ' --' ReturnCode_str ...
	   '%%  Last Modifyed by ' mfilename '  v1.0, ' datestr(now) ReturnCode_str]);
return;

function str=write(str)
% Write str with no change
  [fid, fname] = FILE_ID;

  % if str is empty, 
  %  --> print only Return-Code.
  if isempty(str),
    fprintf(fid, ReturnCode_str);
    return; 
  end

  if iscell(str), str=char(str); end
  lineno = size(str, 1);
  str = [str, repmat(ReturnCode_str,lineno, 1)];
  % print ( with transpose )
  fprintf(fid, '%s',str');

return;

function str=with_indent(str)
% Write str with Indent

  [fid, fname] = FILE_ID;
  indent_str=indent_fcn('getstr');

  % if str is empty, 
  %  --> print only Return-Code.
  if isempty(str),
    fprintf(fid, [indent_str ReturnCode_str]);
    return; 
  end

  if iscell(str), str=char(str); end
  lineno = size(str, 1);
  str = [repmat(indent_str,lineno, 1), ...
	 str, ...
	 repmat(ReturnCode_str,lineno, 1)]; 

  % print ( with transpose )
  % new : check msg num
  % lnum = fprintf(1, '%s',str');
  lnum = fprintf(fid, '%s',str');
  if lnum < numel(str),
	  [msg, enum] = ferror(fid);
	  msg=sprintf('FPRINTF : to %s\n\n%s\n',fname, msg);
	  error(msg);
  end
return;


function str=as_comment(str)
%      make_mfile('as_comment', str);
%         Coment-String without '%'
  fid = FILE_ID;
  indent_str=indent_fcn('getstr');
  indent_str=[indent_str '%'];

  % if str is empty, 
  %  --> print no-commented % 
  if nargin<1 || isempty(str),
    fprintf(fid, [indent_str ReturnCode_str]);
    return; 
  end

  if iscell(str), str=char(str); end
  lineno = size(str, 1);
  str = [repmat(indent_str,lineno, 1), ...
	 str, ...
	 repmat(ReturnCode_str,lineno, 1)]; 

  % print ( with transpose )
  fprintf(fid, '%s',str');

function str=code_separator(level)
%      make_mfile('code_separator', level);
%         Write Code-Separator.
%         level is 1 to 3
  fid= FILE_ID;
  indent_str=indent_fcn('getstr');
  indent_str=[indent_str '%']; % indent with '%'   

  % Definition of Code Separator Cell
  csc={'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', ... % 1
       ' **************************************', ... % 2
       ' ======================================', ... % 3
       ' --*--*--*--*--*--*--*--*--*--*--*--*--', ... % 4
       ' --------------------------------------', ... % 5
       ' - - - - - - - - - - - - - - - - - - - ', ... % 6
       ' --v--v--v--v--v--v--v--v--v--v--v--v--', ... % 7
       ' --^--^--^--^--^--^--^--^--^--^--^--^--', ... % 8
       ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', ... % 9
       ' ______________________________________', ... %10
       ' (^-^)  (^-^)  (^-^)  (^-^)  (^-^)  (^-^) ', ...   %11
       ' (- -)zzz (- -)zzz (- -)zzz (- -)zzz (- -)', ...   %12
       ' **** Platform III **** Platform III ****', ... %13
       ' ** P3 ** P3 ** P3 ** P3 ** P3 ** P3 **'};

  % Change  3 to length(csc)
  % when csc is changed
  if level<1 
    error('Level is out of Rage, set 1 to 14');
  end
  if level > 14
	  level=10;
  end
  
  fprintf(fid, '%s%s%s',...
	  indent_str,csc{level}, ReturnCode_str);
  str =   sprintf('%s%s%s',...
	  indent_str,csc{level}, ReturnCode_str);
       
 return;
