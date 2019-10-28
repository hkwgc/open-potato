function colorbar2(varargin)
% Setting COLORBAR Position
%   Default Layout ofCOLORBAR is something wrong,
%   when using SUBPLOT in Matlab 7.0.0.
%   
%   This function sets colorbar position.
%   Now version is as same as colorbar.
%   If you want to position of COLORBAR,
%    change variable, named pdif.
%   If you want to change rait of Axes and colorbar,
%    change variables, named AXES_AREA and COLORBAR_WIDTH.
%
%  See also COLORBAR, SET, AXES, GCA. 



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original auther : Masanori Shoji
% create : 2005.05.09
% $Id: colorbar2.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.4
%  Bug fix : handles check

% Default Position
  AXES_AREA      = 0.80;     % Axes Area : 80%
  COLORBAR_WIDTH = 0.05;     % Colorbar width : 5%
  % upper variable change by argument?
  % !! here
  
  if ~isempty(varargin) && all(ishandle(varargin{1}))
    handles.ax = varargin{1};
  else
    handles.ax = gca;
  end
  p0=get(handles.ax, 'Position');
  
  handles.cb=colorbar(varargin{:});
  p1=get(handles.ax, 'Position');
  
  
  % Anyway East,
  % -- here is setting Position of Colorbar--
  if 0
	  % ordinaly
	  pdif = p0 - p1;
  else
	  % Colorbar Position is Fix;
	  % --> change by argument?
	  % if East/West, set pdif(3) > 0
	  % if North/South, set pdif(4) > 0
	  % if West, set pdif(1) < 0
	  % if South, set pdif(2) < 0
	  pdif = [0, 0, p0(3), 0];
  end
  pord = p0 * 0.0001; % order of Position
  
  pout = p0;
  pout_cb = get(handles.cb, 'Position');
  
  
  % Check Position ( Setting Index )
  if pdif(3) >= pord(3), % East / West
	  % Width Change
	  widx=3;
  elseif pdif(4) >= pord(4), % North / South
	  % Height Change
	  widx=4;
  else, % Inside ( Do not change )
	  widx=0;
  end
  pidx = widx - 2; % Index of Position ( X/Y )
  
  % Setting of Position 
  if widx~=0, % Change Axes?
	  pout(widx) = pout(widx) * AXES_AREA;
	  pout_cb(widx) = COLORBAR_WIDTH * pout(widx);    
	  if pdif(pidx) <= -pord(pidx), % South/West ( Change Axes Position)
		  pout(pidx) = pout(pidx) + pout(widx) * (1-AXES_AREA);
	  else, % North/East ( Change Colorbar Position )
		  pout_cb(pidx) = pout(pidx) + p0(widx) *(1-COLORBAR_WIDTH);
	  end
  end
  
  % Warning !!
  % Change Colorbar at first,
  % or Axes Position is not pout
  set(handles.cb, 'Position', pout_cb);
  set(handles.ax, 'Position', pout);
  if 0
    disp([p0; pout_cb; pout]);
  end
		  
return;
