function varargout = scriptMeval(fname,varargin)
% Evaluate Script M-File and gets variables.
%
% Syntax:
%  [val1, val2, ...] = scriptMeva(fname,valname1, valname2, ....);
%   valname1 : getting value name.
%   val1     : value correspond to valname1.
%   if there is no value correspond to valname,
%     return [] for the value.
%
% * Meaning of this Function.
%  When you execute a Script-M-File in the work space,
%  the script might have some variable conflict, and
%  the script rest some wasted memory-space 
%  in unnecessary variable.
%
%  So we confine to Variable I/O in this M-File.
%
% * Known Bugs:
%  This function is for M-File for Outputed by OSP.
%  In this version, we assume 
%  we have no input data to the script.
%
% In the script,  can not use.
% And variable named 
%    tmp_loop_index_shoji__,
%    tmp_pathname_shoji__0,
%    tmp_pathname_shoji__1,
%    varargin,
%    varargout,
%    who, 
%    exist,
%    warning,
%    sprintf,
%    and eval, 
% can not be get.
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.06.24
% $Id: scriptMeval.m 180 2011-05-19 09:34:28Z Katura $
%
global FOR_MCR_CODE;

if FOR_MCR_CODE
  if nargout
    [varargout{1:nargout}] = scriptMevalMCR(fname,varargin{:});
  else
    scriptMevalMCR(fname,varargin{:});
  end
  return;
end
  

if nargin<1,
	error('too few arguments');
end
[tmp_pathname_shoji__0 fname e] = fileparts(fname);
if ~strcmpi(e,'.m'),
	error('Not a Script M-File');
end
clear p n;

tmp_loop_index_shoji__=0;
tmp_pathname_shoji__1 = pwd;
% --> Always breke OSP_DATA in R2006a
%cd(tmp_pathname_shoji__0);
%rehash TOOLBOX
rehash

if length(fname)>=5 && strcmpi(fname(1:5),'mult_')
  multimode=true;
else
  multimode=false;
end

if 1,
	try
    if multimode
      [data,hdata]=eval([fname ';']);
    else
      eval(fname);
    end
  catch
		% Waiting MALTAB find Script M-File,
		tmp_loop_index_shoji__= tmp_loop_index_shoji__ +1;
		if (tmp_loop_index_shoji__ > 5),
			% --- Error ---
			cd(tmp_pathname_shoji__1);
			rethrow(lasterror);
		end
		
		% Tell matlab to path of Script-M-file.
		fnames = dir;
		fnames = {fnames.name};
		s=strcmp(fnames, fname);
		if ~any(s),
			s=strcmp(fnames, [fname '.m']);
		end
		if ~any(s),
			cd(tmp_pathname_shoji__1);
			rethrow(lasterror);
		end
		clear s fnames;		
	end
end
cd(tmp_pathname_shoji__1);


if multimode
  for tmp_loop_index_shoji__ = 1: length(varargin),
    if any(strcmpi(varargin{tmp_loop_index_shoji__},{'chdata','bhdata'}))
      varargout{tmp_loop_index_shoji__} = hdata;
      continue;
    end
    if any(strcmpi(varargin{tmp_loop_index_shoji__},{'cdata','bdata'}))
      varargout{tmp_loop_index_shoji__} = data;
      continue;
    end
    if exist(varargin{tmp_loop_index_shoji__},'var'),
      varargout{tmp_loop_index_shoji__} = ...
        eval(varargin{tmp_loop_index_shoji__});
    else
      warning(sprintf('%No value correspond to %s exist.', ...
        varargin{tmp_loop_index_shoji__}));
      varargout{tmp_loop_index_shoji__} = [];
    end
  end
else
  for tmp_loop_index_shoji__ = 1: length(varargin),
    if exist(varargin{tmp_loop_index_shoji__},'var'),
      varargout{tmp_loop_index_shoji__} = ...
        eval(varargin{tmp_loop_index_shoji__});
    else
      warning(sprintf('%No value correspond to %s exist.', ...
        varargin{tmp_loop_index_shoji__}));
      varargout{tmp_loop_index_shoji__} = [];
    end
  end
end


return;

