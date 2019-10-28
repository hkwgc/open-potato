function varargout=POTATo_win_Empty(fnc,varargin)
% POTATo Window : Signal-Analysis Mode Control GUI
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
switch fnc,
  otherwise
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
end
%====== End Launch Switch ======
return;
