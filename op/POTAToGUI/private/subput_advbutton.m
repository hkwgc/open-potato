function h=subput_advbutton(m,n,p,mod,varargin)
% subput_advbutton make Advance-Button to POTATo GUI.
%   h=subput_advbutton(m,n,p)
%     make Advance-Button, like a subplot..
%
% now POTATO_win always use m=4, n=4.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



gcf0=OSP_DATA('GET','POTATOMAINHANDLE');
if nargin<4,mod='normal';end
%%%%%%%%%%%%%%%%%%%%
% Calculate Position
%%%%%%%%%%%%%%%%%%%%%
area = [17 15 363 126];
w = area(3)/n; % Width
h = area(4)/m; % Height

%--------------------
% Check Plot Position
%--------------------
pm   = floor(p/n-0.01);
pn   = p - pm*n-1;


%================
% Modify-Position
%================
switch lower(mod)
  case 'inner'
    pos  = ...
      [area(1) + (pn+0.02)*w, ...
      area(2) + area(4) - (pm+1-0.1)*h,...
      w*0.96, h*0.8];  % Put Inner
  case 'inner0'
    pos  = ...
      [area(1) + (pn+0.1)*w, ...
      area(2) + area(4) - (pm+1-0.1)*h,...
      w*0.8, h*0.75];  % Put Inner(xs)
  case 'tight'
    pos  = ...
      [area(1) + pn*w, ...
      area(2) + area(4) - (pm+1)*h,...
      w, h];  % Put Tight
  otherwise
    % Include normal
    pos  = ...
      [area(1) + pn*w, ...
      area(2) + area(4) - (pm+1)*h,...
      w*0.98, h*0.9];  % space is 2%
end

%  make button
h= uicontrol(gcf0,...
  'Position',pos,...
  'Style','pushbutton',...
  'BackgroundColor',get(gcf0,'Color'));
set(h,varargin{:});
