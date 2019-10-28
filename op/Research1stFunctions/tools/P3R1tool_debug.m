function varargout=P3R1tool_debug(fcn,varargin)
% POTATo : Research Mode 1st-Level-Analysis tool, Debug function
%
%  P3R1tool_debug('redraw',P3R1F);
%      redraw P3R1F GUI

% == History ==
%  2010.12.08 : New! (for testing....)

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
  case {'redraw'}
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
  otherwise
    error('Not Implemented Function : %s',fcn);
end


function redraw(p3r1f)
%
 h=OSP_DATA('GET','POTAToMainHandle');
 hs=guidata(h);
 
% delete all
h0=feval(p3r1f,'myhandles',hs);
h0=h0(ishandle(h0));
if ~isempty(h0)
	v=get(h0(1),'Visible');
else
	v=0;
end

try
  delete(h0);
catch
end

% create
hs=feval(p3r1f,'CreateGUI',hs);
guidata(h,hs);

% Activate
if strcmpi(v,'on')
  feval(p3r1f,'Activate',hs);
else
  feval(p3r1f,'Suspend',hs);
end
