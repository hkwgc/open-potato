function flg=POTATo_Help(tag,ck)
% Help Launcher of POTATo
%
% POTATo_Help
%
% POTATo_Help(topics)
%
% flg=POTATo_Help(topics,ck)
%   check only if tere is document.
%
% * Upper Link
%   osp_KeyBind ( if POTATo-Window opened and typed 'h' key,
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
% original author : MS
% Create : 2008.02.19
% $Id: POTATo_Help.m 404 2014-04-16 02:29:23Z katura7pro $
%
% Revision 1.1:
%   Copy from OspHelp
% 2014.03.29  : Change for Exe
global WinP3_EXE_PATH;
%================================
% Only Check Mode
%================================
if nargin<2
  ck=false;
end
flg=false;

%================================
% P3 Directory
%  out  ; lang, help_path
%================================
osppath=OSP_DATA('GET','OspPath');
if isempty(osppath),
  osppath=which('OSP');
  if iscell(osppath), osppath=osppath{1}; end
  osppath=fileparts(osppath);
end
if ~isempty(WinP3_EXE_PATH)
	%osppath=[osppath filesep '..'];
	osppath=[WinP3_EXE_PATH filesep 'doc'];
end


% Language  English / Japanese
%lang = ['en' filesep];
lang =[OSP_DATA('GET','HELP_LANG') filesep];
help_path=[ osppath filesep 'html' filesep lang];

%================================
%  help_path : 
%================================
if nargin==0
  if ck, flg=true;return;  end % Check only
  view_toppage(help_path);
  return;
end

%================================
% PDF or HTML
%================================
if exist(tag,'file') 
  [p, f, e ] = fileparts(tag);
  if (strcmpi(e,'.pdf') || strcmpi(e,'.html'))
    if ck, flg=true;return;  end % Check only
    view_file(tag);
    return;
  end
end


switch tag
  %==============================
  % for Special TAG
  %==============================
  case {'Top', 'top','POTATo','P3'} 
    if ck, flg=true;return;  end % Check only
    view_toppage(help_path);
    return;

  otherwise,
    %----------------------------
    % ProbePosition
    %----------------------------
    if exist(tag,'file'),
      % M-file or P-file
      try
        [p, f] =fileparts(which(tag));
        % XX/XX.pdf
        tmp_fname = [p filesep lang  f '.pdf'];
        if exist(tmp_fname,'file'),
          if ck, flg=true;return;  end % Check only
          view_file(tmp_fname); 
          return;
        end
        % XX/X.html
        tmp_fname = [p filesep lang  f '.html'];
        if exist(tmp_fname,'file'),
          if ck, flg=true;return;  end % Check only
          view_file(tmp_fname); 
          return;
        end
        % XX.pdf
        tmp_fname = [p filesep f '.pdf'];
        if exist(tmp_fname,'file'),
          if ck, flg=true;return;  end % Check only
          view_file(tmp_fname); 
          return;
        end
        % X.html
        tmp_fname = [p filesep f '.html'];
        if exist(tmp_fname,'file'),
          if ck, flg=true;return;  end % Check only
          view_file(tmp_fname); 
          return;
        end
        % (original)
        tmp_fname = [p filesep lang  'html' filesep f '.html'];
        if exist(tmp_fname,'file'),
          if ck, flg=true;return;  end % Check only
          view_file(tmp_fname);
          return;
        end
      catch
        rethrow('cannot find help-document.');
      end
    end

    % no help :: toppage
    if ck, flg=false;return;  end % Check only
    view_toppage(help_path);
    return;
end


%======================================================
% Select Help-Page
%======================================================
function view_toppage(help_path)
%helpview([help_path 'index.html']);

% s=POTATo_MessageString('Help_Dialog_BetaVerNoticeMessage_JP');
% uiwait(msgbox(s,'Notice!','help','modal'));

% HK comment out
% if ispc
%   view_file([help_path 'index.html"']);
% else
%   view_file([help_path 'menu_man.html']);
% end

view_file([help_path 'index.html']);

%======================================================
% View Execution
%======================================================
function view_file(myfile)
% global FOR_MCR_CODE;

web(myfile)

% HK comment out
% if ispc || FOR_MCR_CODE
%   eval(['!start "POTATo" "' myfile '"']);
% else
%   helpview(myfile);
% end
