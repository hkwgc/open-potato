function msg=gui_buttonlock(tag,figh,varargin);
% GUI Button Lock/Unlock Function
%
% gui_buttonlock('lock',figh, not_ui_h, ..);
%  Lock Figure unicontrol
%
%  where figh     : Figure Handle figh
%
%  if there
%        not_ui_h : Not Changed unicontrol-handle
%
% gui_buttonlock('unlock',figh);
%  Unlock Figure unicontrol
%
% This function is OSP-Control.
% 
% if Argument are not in-place, 
% do nothing with no error.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2004.12.22
% $Id: gui_buttonlock.m 180 2011-05-19 09:34:28Z Katura $

% Revision 1.5 : 08-Apr-2006
%    Check Input argument not to Occur Error
%    Message's

persistent mystat;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument Check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Number of Arguments
msg=nargchk(2,10,nargin);
if ~isempty(msg), return; end 
% ---------------------------
% Check figure-handle
% ---------------------------
msgE='2nd Argument is not figure';
if isempty(figh) || ~ishandle(figh), msg=msgE;
else,
  % Where msg='';
  try,
    tmp=get(figh,'Type');
    if ~strcmpi(tmp,'figure'),msg=msgE; end
  catch,
    msg=msgE;
  end
end
if ~isempty(msg), return; end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------
% Check Tag ( Lock / Unlock )
% ---------------------------
switch tag
  case 'lock'
    set(figh,'Pointer','watch');
    prop   ='enable';
    setvalue='off';
    mlock;
    
  case 'unlock'
    set(figh,'Pointer','arrow');
    prop = 'enable';
    setvalue='on';

    % TODO:
  case 'lock2',
    set(figh,'Pointer','watch');
    prop   ='enable';
    setvalue='off';
    
  case 'unlock2',
    set(figh,'Pointer','arrow');
    prop = 'enable';
    setvalue='on';
    
  otherwise
    error([mfilename ': 1st argument ' tag ' Error']);
end

% ---------------------------
% Get Figure Object
% ---------------------------
hs=findobj(figh,'type','uicontrol');
for noid=1:nargin-2
    try
        hs(find(hs==varargin{noid}))=[];
    catch
        try
            OSP_LOG('warn',[mfilename, ' : ' lasterr]);
        end
    end
end

% ---------------------------
% Get Figure Object
% ---------------------------
% TODO SAVE<->LOAD
try
   set(hs,'enable',setvalue); %setvalue set M
end
