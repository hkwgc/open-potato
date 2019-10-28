function  [c, x, y] = POTATo_sub_MapImage(ydata, psn, v_interpstep, v_interpmethod)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% make cdata
if size(psn,1) == size(ydata,1)
	p = [psn, ydata];
else
	p = [psn, ydata'];
end %---mod by TK@harl

x=sort(p(:,1));
y=sort(p(:,2));

dx = x(end)-x(1);
dy = y(end)-y(1);
dx=dx*0.05; dy=dy*0.05;
x=round(x/dx);x=unique(x)*dx;
y=round(y/dy);y=unique(y)*dy;

% Make Mesh
x0 = linspace(x(1)-dx,x(end)+dx,length(x)*2+3)';
y0 = linspace(y(1)-dy,y(end)+dy,length(y)*2+3)';

dx = min(diff(x0)) * 0.5;
dy = min(diff(y0)) * 0.5;

x = linspace(x(1),x(end), round(length(x0)*v_interpstep));
df= x(2)-x(1);
x = [x(1)-df, x, x(end)+df];

y= linspace(y(1),y(end), round(length(y0)*v_interpstep));
df = y(2)-y(1);
y = [y(1)-df, y, y(end)+df];

[x3,y3]=meshgrid(x,y);
try
	c =griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod);
catch
	% -- Error in Relase 2006a ?
	c = griddata(p(:,1), p(:,2), p(:,3), x3, y3, v_interpmethod, ...
		{'Qt','Qbb','Qc','Qz'});
end

c = c';
return;
