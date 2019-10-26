function h = P3_waitbar(X,addlog,title,varargin)
%  P3_WAITBAR Display wait bar.
%
%    H = P3_WAITBAR(X,'log','titel' property, value, property, value, ...)
%    creates and displays a waitbar of fractional length X. 
%    The handle to the waitbar figure is returned in H.
%    X should be between 0 and 1.  
%    Optional arguments property and
%    value allow to set corresponding waitbar figure properties.
%    Property can also be an action keyword 'CreateCancelBtn', in
%    which case a cancel button will be added to the figure, and
%    the passed value string will be executed upon clicking on the
%    cancel button or the close figure button.
% 
%    P3_WAITBAR(X) will set the length of the bar in the most recently
%    created waitbar window to the fractional length X.
% 
%    P3_WAITBAR(X,'add log') will update the title text in
%    the waitbar figure, in addition to setting the fractional
%    length to X.
%
%    P3_waitbar Window-Style is modal, so be careful.
%
% See also waitbar

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

persistent myh;
if isempty(myh) || ~ishandle(myh)
  myh=P3_waitbar0();
end


%=======================
% Update X:Data
%=======================
hs=guidata(myh);
if (X<0), X=0; end
if (X>1), X=1; end
set(hs.patch,'XData',[0 X 0 X; X 1 X 1; 0 X X 1]);

if (X>=1)
  set(hs.psb_OK,'Visible','on');
end

%=======================
% Update Log
%=======================
if nargin>=2
  log=get(hs.lbx_log,'String');
  if ~iscell(addlog),
    addlog={addlog};
  end
  if isempty(log)
    log=addlog;
  else
    log={log{:} addlog{:}};
  end
  set(hs.lbx_log,'String',log,'Value',length(log));
end

%=======================
% Update Title
%=======================
if nargin >=3
  set(myh,'Name',title);
end

if nargin>=4
  set(myh,varargin{:});
end
set(0,'CurrentFigure',myh);drawnow;
% Output
if nargout, h=myh; end

