function h=subuicontrol(gcf0,m,n,pm,pn,mod,varargin)
% subput_advbutton make Advance-Button to POTATo GUI.
%   h=subput_advbutton(m,n,p)
%     make Advance-Button, like a subplot..
%
% now POTATO_win always use m=4, n=4.

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init
%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent area
if isempty(area),area=[286 9 330 391];end
if nargin==1, area=gcf0; return;end

if nargin<4,mod='normal';end

%!! == !! Default Unit==
set(gcf0,'Units','pixels');
%%%%%%%%%%%%%%%%%%%%
% Calculate Position
%%%%%%%%%%%%%%%%%%%%%
w = area(3)/n; % Width
h = area(4)/m; % Height

%--------------------
% Check Plot Position
%--------------------
%pm   = floor(p/n-0.01);
%pn   = p - pm*n-1;
pm   = pm-1;
pn   = pn-1;

%================
% Modify-Position
%================
switch lower(mod)
  case 'inner'
    pos  = ...
      [area(1) + (pn+0.02)*w, ...
      area(2) + area(4) - (pm+1-0.02)*h,...
      w*0.96, h*0.96];  % Put Inner
  case 'inner0'
    pos  = ...
      [area(1) + (pn+0.1)*w, ...
      area(2) + area(4) - (pm+1-0.1)*h,...
      w*0.8, h*0.75];  % Put Inner
  case 'tight'
    pos  = ...
      [area(1) + pn*w, ...
      area(2) + area(4) - (pm+1)*h,...
      w, h];  % Put Tight
  otherwise
    % Include normal
    pos  = ...
      [area(1) + pn*w, ...
      area(2) + area(4) - (pm+0.05)*h,...
      w*0.98, h*0.95];  % space is 2%
end

if nargin==6
  %----------
  % Hide Option
  %-----------
  switch varargin{1},
    case 'getposition'
      h  = pos;
      return;
  end
end

%  make button
h= uicontrol(gcf0,'Units','pixels','Position',pos);

%---------
% set Property
%---------
set(h,varargin{:});
