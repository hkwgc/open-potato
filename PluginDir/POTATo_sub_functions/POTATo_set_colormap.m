function POTATo_set_colormap(num,axh)
% set colormap
% In: num colormap mode
% 1: default
% 2: hot
% 3: gray
% 4: blue-red
% 5: inverse-gray
%
%030703 TK
%060228 MS
%110127 TK
%  --> Axes Select

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin==2 && ishandle(axh)
  % sory to bad code..
  % MS
  switch num
   case 1%default
    colormap(axh,'default');
   case 2%hot

   case 3%gray
    colormap(axh,'gray');
   case 4 % red-blue
    a=0:1/31:1;
    m1=repmat(a',1,3);
    m1(:,3)=1;
    m2=1-m1;
    m2(:,3)=m2(:,2);
    m2(:,1)=1;
    q=cat(1,m1,m2);
    colormap(axh,q);
   case 5 % inv-gray
    cm=colormap(gray);
    colormap(axh,cm(end:-1:1,:));
  end
else,
  switch num
   case 1%default
    colormap default
   case 2%hot
    colormap hot
   case 3%gray
    colormap gray
   case 4 % red-blue
    a=0:1/31:1;
    m1=repmat(a',1,3);
    m1(:,3)=1;
    m2=1-m1;
    m2(:,3)=m2(:,2);
    m2(:,1)=1;
    q=cat(1,m1,m2);
    colormap(q);
   case 5 % inv-gray
    cm=colormap(gray);
    colormap(cm(end:-1:1,:));
  end
  
end

