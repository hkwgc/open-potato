function rcode=osp_FigureEnlarge(figh,pos,clicktype)

% In no input : Help


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if(strcmp(clicktype,'normal') == 0),
    return;
end
try
  rcode=true;
  %----------------
  % Get Axes-Handle
  %----------------
  AxesID=osp_FigureMapController('GetMapData',figh,pos);
  if isempty(AxesID)
    % --> 2007.11.16
    AxesID=gca;
   if ~strcmpi(get(gcbo,'type'),'uimenu'),return;end
   if get(AxesID,'Parent')~=figh, return;end
  else
    AxesID=AxesID(end);
  end


  figh2=figure;
  set(figh2,'Color',get(figh,'Color'));
  figtitle=get(get(AxesID,'Title'),'String');
  set(figh2,'Name',figtitle);
  set(figh2,'NumberTitle','off');
  set(figh2,'Visible','on');
  if 0
    % Copy : Children only
    ah   = axes;
    copyobj(get(AxesID,'Children'),ah);
    axis tight
  else
    % Copy : Title, Axis and so on..
    ah=copyobj(AxesID,figh2);
    set(ah,'Units','Normalized','Position',[0.1 0.1 0.8 0.8]);
  end
catch
  rcode=false;
end
return;