function info = getfcninfo(varargin)
% Get M-File Information for GUI
%  Plot Each subfunction Help
%
%  getfcninfo(filename)
%  getfcninfo filename
%     display Information of filename
% 
%  info = getfcninfo(filename)
%    return cell Information of filename
%
% Example
%  getfcninfo signal_viewer
%  getfcninfo signal_viewer.m
%  helpwin(getfcninfo('signal_viewer'),'signal view : Subfunctions');
% 
% Known Bugs :
%   function must be wrote in a line.
%      ( if there is '...' , help not output )
%   'function' must be ahead of the line
%
% See also PERL, REGEXP.
%            
%  $Id: getfcninfo.m 180 2011-05-19 09:34:28Z Katura $



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




osppath = which('OSP');
path0 = fileparts(osppath);

info={};
for id = 1:nargin
  try
    if 0
      fname = char(varargin{id});
      s = regexp(fname, '[.]m$');
      if isempty(s)
        fname = [fname '.m'];
      end
    else
      fname=which(varargin{id});
    end
    info{end+1} = perl([path0 filesep 'getfcn.perl'], fname);

    if nargout==0
      disp('------------------------------------');
      disp([' * File name : ' fname]);
      disp('');
      disp(info{end});
      disp('');
      disp('------------------------------------');
      disp('');
      disp('');
    end
  catch
    disp(['[E] ' lasterr]);
  end
end
