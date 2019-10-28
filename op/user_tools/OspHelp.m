function OspHelp(tag)
% Help Launcher of OSP
%
% OspHelp(tag)
%   If there is Special-HTML Display that
%   else display help of the function named 'tag'
%
% * Upper Link
%   osp_KeyBind ( if OSP GUI opened and typed 'h' key,
%                 run this program)
% * Lower Link
%   See also : OSP_DATA, helpview, helpwin

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% Create : 2005.01.17
% $Id: OspHelp.m 180 2011-05-19 09:34:28Z Katura $
global FOR_MCR_CODE;

if nargin==0, tag='Top'; end

% OSP Directory
osppath=OSP_DATA('GET','OspPath');
if isempty(osppath),
	osppath=which('OSP'); 
	if iscell(osppath), osppath=osppath{1}; end
	osppath=fileparts(osppath);
end

% Language  English / Japanese
%lang = ['en' filesep];
lang =[OSP_DATA('GET','HELP_LANG') filesep];
help_path=[ osppath filesep 'html' filesep lang];

switch tag
	% Special HTML
	case {'Top', 'top','Osp','OSP'} % Top Page of OSP help
    if FOR_MCR_CODE
      eval(['!start ' help_path 'index.html']);
    else
      helpview([help_path 'index.html']);
    end
		
	case {'uiFileSelect' 'uiFileSelect.m'} % File Selector
    if FOR_MCR_CODE
      eval(['!start ' help_path ...
        'man' filesep ...
        'AboutOsp' filesep ...
			  'file_select.html']);
    else    
      helpview([help_path ...
        'man' filesep ...
        'AboutOsp' filesep ...
			  'file_select.html']);
    end
		
	case {'setProbePosition' 'setProbePosition.m'}, % ProbePosition
    if FOR_MCR_CODE
      eval(['!start ' help_path ...
        'man' filesep ...
        'ProbePosition.html']);
    else
      helpview([help_path ...
        'man' filesep ...
        'ProbePosition.html']);
    end

	otherwise,
		flag=false;
		% 1st : local-HTML Directory.
		if exist(tag,'file'),
			try
				[p, f] =fileparts(which(tag));
				tmp_fname = [p filesep lang  'html' filesep f '.html'];
        if exist(tmp_fname,'file'),
          if FOR_MCR_CODE
            eval(['!start ' tmp_fname]);
          else
            helpview(tmp_fname); 
          end
          flag=true;
        end
      catch
        disp('HTML : could not found');
			end
		end
		% 2nd : HTML/Man Directory.
		if ~flag 
			tmp_fname = [help_path 'man' filesep tag '.html'];
			if exist(tmp_fname,'file'),
        if FOR_MCR_CODE
          eval(['!start ' tmp_fname]);
        else
          helpview(tmp_fname); 
        end
        flag=true;
			end
		end
		% 3rd : Help of the function
    if ~FOR_MCR_CODE
      if ~flag && exist(tag,'file'),
        helpwin(help(tag),[' Function : ' tag]);
        flag=true;
      end
    end
		
		% 4th : .. default 
		if ~flag,
      if FOR_MCR_CODE
        eval(['!start ' help_path 'index.html']);
      else
        helpview([help_path 'index.html']);
      end
		end
end

return;

