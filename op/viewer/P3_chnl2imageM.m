function [c, x, y] = P3_chnl2imageM(ydata, header, image_mode, v_interpstep, v_interpmethod)
% function [c, x, y] = P3_chnl2imageM(ydata, header, image_mode,smooth,smooth method)
% IN:
%    ydata: (1, ch)
%    header: Header of OSP User Command Data
%    image_mode: 1=point, 2=interp, 3=smooth point
%    smooth: smoothing pxiel size
%    smooth method: 'linear', 'cubic', 'nearest', 'v4' ('invdist')
% OUT:
%     c{ProbeNum}( x, y ) : Color Data
%     x{ProbeNum}         : x axis data
%     y{ProbeNum}         : y axis data
%
% See also OSP_CHNL2IMAGE.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.08.12
% $Id: P3_chnl2imageM.m 352 2013-05-08 02:42:56Z Katura $

probe_mode = header.measuremode;
switch probe_mode,
  case -1,
    c={}; x={}; y={};
    flag=true;
    % TODO:
    if flag,
      % Ordinary
      for idx=1:length(header.Pos.Group.ChData),
        ch_lst    = header.Pos.Group.ChData{idx}; % use channel list.
        ydata_tmp = ydata(ch_lst);
        if 0,
          % Normal Order
          psn       = header.Pos.D2.P(ch_lst,:);
        else
          % 
          psn       = time_axes_position(header);
          psn   = psn(ch_lst,[1,2]);
        end
        % B061205C : Error 's
        if isempty(psn),continue;end
        [c{end+1}, x{end+1}, y{end+1}] = ...
          ch2image(ydata_tmp, psn, image_mode, v_interpstep, v_interpmethod);
      end
    else
      % One Image-Mode
      ch_lst=[];
      for idx=1:length(header.Pos.Group.ChData),
        ch_lst    = [ch_lst, header.Pos.Group.ChData{idx}]; % use channel list.
      end
      ydata_tmp = ydata(ch_lst);
      psn       = header.Pos.D2.P(ch_lst,:);
      [c{end+1}, x{end+1}, y{end+1}] = ...
        ch2image(ydata_tmp, psn, image_mode, v_interpstep, v_interpmethod);
    end

  case 1,
    ydata=P3_chnl2image(ydata,probe_mode, image_mode, ...
      v_interpstep, v_interpmethod);
    sz = size(ydata,1)/2;
    c{1} = ydata(1:sz,:);
    x{1} = 1:size(c{1},1);
    y{1} = size(c{1},2):-1:1;
    c{2} = ydata(sz+1:end,:);
    x{2} = size(c{1},1)+2:size(c{2},1)+size(c{1},1)+1;
    y{2} = size(c{2},2):-1:1;
    % x{1}=x{1}/x{2}(end);x{2}=x{2}/x{2}(end);
    [maxlen,idx] = max([x{2}(end),y{2}(1),y{1}(1)]);
    if idx==1
      y{1}=y{1}+(x{2}(end)-y{1}(1));
      y{2}=y{2}+(x{2}(end)-y{2}(1));
    end
    maxlen=maxlen+1;
    x{1}=x{1}/maxlen;x{2}=x{2}/maxlen;
    y{1}=y{1}/maxlen;y{2}=y{2}/maxlen;
    if image_mode==3
      v_interpstep=12;
    elseif image_mode~=2
      v_interpstep=1;
    end
    tmp = x{1}(v_interpstep)/2;
    x{1}=x{1}-tmp;x{2}=x{2}-tmp;
    
    tmp = (y{1}(end-v_interpstep)-y{1}(end));
    y{1}=y{1}-tmp;y{2}=y{2}-tmp;
    
  otherwise,
    ydata=P3_chnl2image(ydata,probe_mode, image_mode, ...
      v_interpstep, v_interpmethod);
    c{1} = ydata;
    x{1} = 1:size(c{1},1);
    y{1} = size(c{1},2):-1:1;
    if y{1}(1)>x{1}(end)
      maxlen=y{1}(1)+1;
    else
      maxlen=x{1}(end)+1;
      y{1}=y{1}+(x{1}(end)-y{1}(1));
    end

    x{1}=x{1}/maxlen;
    y{1}=y{1}/maxlen;

    if image_mode==3
      v_interpstep=12;
    elseif image_mode~=2
      v_interpstep=1;
    end
    tmp = x{1}(v_interpstep)/2;
    x{1}=x{1}-tmp;
    
    tmp = (y{1}(end-v_interpstep)-y{1}(end))/2;
    y{1}=y{1}-tmp;
end

return;


function  [c, x, y] = ch2image(ydata, psn, image_mode, v_interpstep, v_interpmethod)
% Single Image Plot


% Delete improper data
% B070427B : Error's
if 0
  tmp = find(isnan(ydata));
  if ~isempty(tmp),
    ydata(tmp)=[]; psn(tmp,:)=[];
  end
end


% make cdata
if size(psn,1) == size(ydata,1)
	p = [psn, ydata];
else
	p = [psn, ydata'];
end %---mod by TK@harl

x=sort(p(:,1));
y=sort(p(:,2));

%if isempty(x) || isempty(y)
% Delete same x and y
dx = x(end)-x(1);
dy = y(end)-y(1);
dx=dx*0.05; dy=dy*0.05;
if 0
  x= x([1; find(abs(diff(x))> (dx) )+1]); % diff max=5%
  y= y([1; find(abs(diff(y))> (dy) )+1]); % diff max=5%
else
  x=round(x/dx);x=unique(x)*dx;
  y=round(y/dy);y=unique(y)*dy;
end

% Make Mesh
x0 = linspace(x(1)-dx,x(end)+dx,length(x)*2+3)';
y0 = linspace(y(1)-dy,y(end)+dy,length(y)*2+3)';

dx = min(diff(x0)) * 0.5;
dy = min(diff(y0)) * 0.5;

switch image_mode % switch Image Mode
  case 1 % Image Mode = POINTS
    x = x0; y = y0;
    %[x3,y3]=meshgrid(x0,y0);
    c=zeros(length(y0),length(x0));
    c(:)=NaN; % for MATLAB 6.5.1
    %c=NaN(length(y0),length(x0));
    for index=1:size(p,1),
      xtmp = find(p(index,1)-dx <x0 & x0<p(index,1)+dx);
      ytmp = find(p(index,2)-dy <y0 & y0<p(index,2)+dy);
      % ytmp = size(c,1) - (ytmp-1);
      if ~isempty(xtmp) && ~isempty(ytmp),
        c(ytmp(1),xtmp(1)) = p(index,3);
      else
        %warning('Not Proper Position found');
        fo=get(0,'CurrentFigure');
        warndlg('There is inproper Position.','Making Image','replace');
        set(0,'CurrentFigure',fo);
      end
    end
    % error(sprintf('Image Plot does not support measuremode %d.',probe_mode));

    %============================
    %============================
  case 2 % Image Mode = INTERPED

    x = linspace(x(1),x(end), round(length(x0)*v_interpstep));
    df= x(2)-x(1);
    x = [x(1)-df, x, x(end)+df];

    y= linspace(y(1),y(end), round(length(y0)*v_interpstep));
    df = y(2)-y(1);
    y = [y(1)-df, y, y(end)+df];

    % [x3,y3]=meshgrid(x,y(end:-1:1));
    [x3,y3]=meshgrid(x,y);
    try
      c =griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod);
    catch
      % -- Error in Relase 2006a ?
      c = griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod, ...
        {'Qt','Qbb','Qc','Qz'});
    end
    % error(sprintf('Image Plot does not support measuremode %d.',probe_mode));

    %============================
    %============================
  case 3 % Image Mode = smooth POINTS
    g=sqmap(14);
    %[x3,y3]=meshgrid(x0,y0);
    unit = [x0(2) - x0(1), y0(2) - y0(1)];

    sz = 10;       % unit change
    sz_o = -sz/2;  % origin chaneg

    %c=zeros(size(x3));
    %c=zeros(size(x3) * sz);
    c=zeros(length(y0)*sz,length(x0)*sz);
    for index=1:size(p,1),
      xtmp = find(p(index,1)-dx <x0 & x0<p(index,1)+dx);
      ytmp = find(p(index,2)-dy <y0 & y0<p(index,2)+dy);
      % ytmp = size(x3,1) - (ytmp-1);
      if ~isempty(xtmp) && ~isempty(ytmp),
        c(sz_o+sz*ytmp(1),sz_o+sz*xtmp(1)) = p(index,3);
      else
        warning('Not Proper Position found');
      end
    end
    c= conv2(c, g);

    unit = unit./sz;

    % convolution area is +- 7,
    %   ( size(g)=[14, 14] )
    if 0
      x = linspace(x(1)-7.5,x(end)-7*unit(1), ...
        size(c,2));
      y = linspace(y(1)-7.5,y(end)+7*unit(2), ...
        size(c,1));
    else
      x = linspace(x0(1)-7.5*unit(1),x0(end)+7.5*unit(1),size(c,2));
      y = linspace(y0(1)-7.5*unit(2),y0(end)+7.5*unit(2),size(c,1));
    end

  otherwise,
    % ===== Error message add =====
    % 2005.08.25
    % @since 1.3
    if image_mode==4,
      errordlg({'Image Mode 4 is special value,', ...
        ' there is no image to plot'});
    end
    error(['Image Mode(' num2str(image_mode) ')' ...
      ' is out of range (1, 2, 3)']);
end % end of switch Image Mode

c = c';
return;
