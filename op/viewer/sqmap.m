function m=sqmap(sz)
% Make Image of Circle that center is 1 and edge is 0.
%
%==================
% Syntax:
%==================
%   m=sqmap(sz)
%
%   sz : Image size.
% 
%   m  : Image (Matrix that size [sz, sz] )
%
%==================
% Example: Result
%==================
%     c = sqmpa(100);
%     imagesc(c,[0 1]);
%
%==================
%  Example 2: relation to conv2
%==================
%   % Example Figure Plot
%   figure
%   load mri
%   D=squeeze(D(:,:,1,1));
%   image(D)
%   map
%   colormap(map)
%   % Convolustion Data Make.
%   c=sqmap(8);
%   figure; imagesc(c,[0,1]);
%   % Convolustion & make result
%   figure;
%   D2=conv2(c,D);
%   D2=D2/sum(c(:))
%   image(D2)
%   colormap(map)
%
%==================
% OSP Upper function: 
%==================
%     viewer/osp_chnl2image.m
%
%==================
%  In OSP.
%==================
%   This function is useful, when make Smooth point.
%   g=sqmap(14);
%   and exmapd channel data enoth to larger than 14.
%   r=[ 0 0 ...
%       ..
%       0 0 ..  0 0                0 ...0 0;...
%       0 0 ..  0 HBData(channel1) 0 ...0 0;...
%       0 0 ..  0 0                0 ...0 0;...
%       ..
%                   ... 0 0]
%   -> And convolution
%   c = conv2(r,g);
%    so peak is HBData and that max is HBData(channel1);
%       because (1*HBData(channel1)+ 0*0.9 + *0*0.9 ...) 
%
%  See also SQRT, ZEROS.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% $Id: sqmap.m 180 2011-05-19 09:34:28Z Katura $

% Reversion 1.2
%  Help Comment Add.

m=zeros(sz,sz);
r=sz/2;
r2=r^2;
for x=1:sz
    for y=1:sz
        p=(x-r)^2+(y-r)^2 ;
        m(x,y)= ( p  < r2 )*( sqrt(1 - p/r2) );
    end
end

% 
% xc=0;
% for x=-1:2/sz:1
%     xc=xc+1;
%     yc=0;
%     for y=-1:2/sz:1
%         yc=yc+1;
%         m(xc,yc)=(1-y^4)*(1-x^4);
%     end
% end
% 
%     

% -- Moemo --
% M. Shoji
%
% Result of grep : 27-Dec-04
%
%
