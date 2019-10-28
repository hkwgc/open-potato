function varargout=osp_distribute(fnc,varargin)
% OSP_DISTRIBUTE is Distribution Data.
%
% z=osp_distribute('qnorm',p);
%  is Standard-Normal-Distribution CDF.
%
% z=osp_distribute('pqnorm',qn);
%  is Standard-Normal-Distribution Parcent Point.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% no input : Hele
if nargin<1,
  help osp_distribute
  return;
end

% Launcher
if ~isnumeric(fnc)
  % Normal Subfunction
  if nargout,
    [varargout{1:nargout}] = feval(fnc, varargin{:});
  else
    feval(fnc, varargin{:});
  end
else
  % Test Function ::
  switch fnc,
    case 1,
      % Normal Distribute
      if nargin>=2,
        x=varargin{1};
      else
        x=0.3;
      end
      test_norm(x);
    case 2,
      if nargin>=2,
        x=varargin{1};
      else
        x=0.3;
      end
      if nargin>=3,
        n=varargin{2};
      else
        n=10;
      end
      test_tdist(x, n);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal Distribution I/O 
%   CDF   : qnorm
%         : pqnorm
%   Debug : test_norm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=test_norm(u)
% Test Function for Normal-Distribution !
x=logspace(-2,1,100);
x=[-x(end:-1:1) 0 x(1:end)];
x=x(:);
f=exp(-(x.^2)/2)/(2*pi);

h.figure1=figure;
h.axes1  = axes;

% Plot Sum-Area
id=find(x<u);
fu=exp(-(u.^2)/2)/(2*pi);
x2=[x(id);  u; u; x(1)];
y2=[f(id); fu; 0; f(1)];
h.fill=fill(x2,y2,[0.7 0.8, 1]);
hold on
%set(h.fill,'Mark','o');


% Normal-Deviation Line
h.line   = plot(x,f);

% Point : QNorm Check
u=u(1);
r=qnorm(u);
h.point= plot([u;u],[0;0.2],'r');
h.txt  = text(u+0.1,fu,...
  sprintf('qnorm(%7.5f) : %f?',u,r));

% PNorm Check
u2 = pnorm(r);
h.txt2 = text(u2+0.1,0.01,...
  sprintf('pnorm(%f) : %7.5f?',r,u2));

p=max(abs(u),5);
axis([-p, p, 0, 0.2]);
grid on

function r=qnorm(x)
% Normal CDF
r=zeros(size(x));

for id=1:length(x(:))
  u=x(id);
  if u==0, r(id)=0.5; continue; end
  y = u / 2.;
  if y < -3,r(id)=0;continue;end
  if y >  3,r(id)=1;continue;end

  if y < 0., y = - y; end
  if y < 1,
    w = y.*y;
    z = 1.24818987e-4;
    for c = [-1.075204047e-3, 5.198775019e-3, ...
        -0.019198292004, 0.059054035642, -0.151968751364,...
        0.319152932694,-0.5319230073, 0.797884560593],
      z = z * w + c;
    end
    z = z*y * 2.;
  else
    y = y- 2;
    z = -4.5255659e-5;
    for c = [1.5252929e-4,  -1.9538132e-5, ...
        -6.76904986e-4,  1.390604284e-3,-7.9462082e-4, ...
        -2.034254874e-3, 6.549791214e-3,-0.010557625006, ...
        0.011630447319,-9.279453341e-3, 5.353579108e-3, ...
        -2.141268741e-3, 5.35310549e-4, 0.999936657524],
      z = z * y + c;
    end
  end
  if u < 0,
    r(id)= (1 - z)/2;
  else
    r(id)= (1 + z)/2;
  end
end

function r=pnorm(q)
% %-Point
r=zeros(size(q));
c = [0.03706987906,-0.8364353589e-3, ...
  -0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5,...
  -0.104527497e-5,  0.8360937017e-7,-0.3231081277e-8, ...
  0.3657763036e-10,0.6936233982e-12];
for id=1:length(q(:))
  qn=q(id);
  if (qn < 0) || (1 < qn),
    error(' Input value : out-of-range : 0-1');
  end
  if qn == 0.5, r(id)=0.5;continue;end

  w1 = qn;
  if qn > 0.5, w1 = 1. - w1; end

  w3 = -log(4* w1 * (1 - w1));
  w1 = 1.570796288;
  for idx=1:length(c)
    w1 = w1 + c(idx) * power(w3, idx);
  end

  if qn > 0.5,
    r(id)=sqrt(w1 * w3);
  else
    r(id)=-sqrt(w1 * w3);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Test function for T distribution
%  u: x zahyo
%  n: degree of freedom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=test_tdist(u, n)
% Check not supported n
if (n<1),
  disp('error n<1');
  return;
end

x=logspace(-2,1,100);
x=[-x(end:-1:1) 0 x(1:end)];
x=x(:);
% --------------
% Gamma function
% --------------
gm= gamma((n+1)/2) / gamma(n/2);
% -----------------------------
% probability density function
% -----------------------------
%f=gm / (sqrt(n*pi) * ((1.0+(x^2)/n)^((n+1)/2)));
conf1=sqrt(n*pi);
pconf=(n+1)/2;
conf2=1.0+(x.^2)/n;
f=gm ./ (conf1 * conf2.^pconf);

% =============
% Create figure
% =============
h.figure1=figure;
h.axes1  = axes;

% -----------------------------
% probability density function
% -----------------------------
% Plot Sum-Area
id=find(x<u);
uconf2=1.0+(u^2)/n;
fu=gm / (conf1 * uconf2^pconf);

% ----------------------
% Draw under input-coord
% ----------------------
x2=[x(id);  u; u; x(1)];
y2=[f(id); fu; 0; f(1)];
h.fill=fill(x2,y2,[0.7 0.8, 1]);
hold on

% -----------------------------
% Plot T distribution Line 
% -----------------------------
h.line   = plot(x,f);

% Point : QNorm Check
u=u(1);
%disp(num2str(u));
% -----------------------------
%   Get T-distribution
% -----------------------------
a2=tdist(u, n);
h.point=plot([u;u],[0;0.4],'r');
h.txt  = text(u+0.1,fu+0.03,...
  sprintf('tdist(%4.2f,%d)=%f ?',u,n,a2));

% --------------------------------
%   Get Invert T-distribution %%
% --------------------------------
u2 = tinv(a2,n);
h.txt2 = text(u2+0.1,-0.02,...
  sprintf('tinv(%f,%d)= %4.2f ?',a2,n,u2));

% --------
% Set axis
% --------
p=max(abs(u),12);
%axis([-p, p, 0, 0.2]);
axis([-p, p, 0, 0.4]);
grid on
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  T distribution    (dist.c:qt())
%  u :x zahyo
%  n :jiyu-do
%  a2:percent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a2=tdist(x,n)
a2 =zeros(size(x));
w1=0.636619772284456;
t1=0.0;t2=0.0;w2=0.0;wq=0.0;

% Check
if (n < 1),
  fprintf('%s\n','Error: n<1 in tdist function');
  return;
end

% Calculation
for id=1:prod(size(x))
  xn = x(id);
  if (xn<0.0), xn=-xn; end
  t1=xn/sqrt(n);
  t2=1.0/(1.0+t1*t1);
  if (mod(n,2) ~= 0),
    wq=1.0-w1*atan(t1);
    if (n ~= 1),
      w2=w1*t1*t2; wq=wq-w2;
      if (n ~= 3), wq = qtsub(wq, n, w2, 0.0, t2);end
    end
    if (wq>0.0),
      a2(id)=wq;
    else
      a2(id)=0.0;
    end
    continue;
  end
  w2=t1*sqrt(t2); wq=1.0-w2;
  if (n ~= 2), wq = qtsub(wq, n, w2, 1.0, t2);end
  if (wq>0.0),
    a2(id)=wq;
  else
    a2(id)=0.0;
  end
end
return;

function q=qtsub(wq,n,w2,w3,t2)
q=wq;

j=(n-2)/2;
for i=1:j
  w=2.0*i-w3;
  w2=w2*(t2*w/(1.0+w));
  q=q-w2;
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  T Invert distribution    (dist.c:pt())
%  a2:percent
%  n :jiyu-do
%  x :x zahyo(percent point)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x=tinv(a2,n)
x =zeros(size(a2));
f =0.0;f1=0.0;f2=0.0;f3=0.0;f4=0.0;f5=0.0;
w0=0.0;w1=0.0;w2=0.0;w3=0.0;w4=0.0;
u =0.0;u2=0.0;

% Check
if (n < 1),
  fprintf('%s\n','Error: n<1 in pt');
  return;
end

% Calculation
for id=1:prod(size(a2))
  a2n = a2(id);
  if (a2n < 1.0e-5) || (a2n > 1.0),
    fprintf('%s\n','Error: Illigal parameter in pt');
    return;
  end

  if (n <= 5),
    x(id)=ptsub(a2n,n); continue;
  end
  if (a2n <=5.0e-3) && (n <=13),
    x(id)=ptsub(a2n,n); continue;
  end
  f =n;
  f1=4.0*f;
  f2=f^2.0*96.0;
  f3=f^3.0*384.0;
  f4=f^4.0*92160.0;
  f5=f^5.0*368640.0;
  % pnorm call
  u =pnorm(1.0-a2n/2.0);
  u2=u^2.0;
  w0=u^3.0;
  w1=u^5.0;
  w2=u^7.0;
  w3=u^9.0;
  w4=u^11.0;

  w =((w0+u)/f1);
  w =w+(( 5.0*w1+ 16.0*w0+   3.0*u)/f2);
  w =w+(( 3.0*w2+ 19.0*w1+  17.0*w0-  15.0*u)/f3);
  w =w+((79.0*w3+776.0*w2+1482.0*w1-1920.0*w0-945.0*u)/f4);
  w =w+((27.0*w4+339.0*w3+ 930.0*w2-1782.0*w1-765.0*w0+17995.0* ...
    u)/f5);

  x(id) = w+u;
end
return;

function w=ptsub(qn,n)
s=1000.0;
w=0.0;eps=0.0;qe=0.0;
f=true;

if (n == 1) && (0.001 <= qn) && (qn < 0.01),
  eps=1.0e-4;
elseif (n == 2) && (qn < 0.0001),
  eps=1.0e-4;
elseif (n == 1) && (qn < 0.001),
  eps=1.0e-2;
else
  eps=1.0e-5;
end

while f
  w=w+s;
  if (s<=eps),return; end
  % qt call
  qe=tdist(w,n)-qn;
  if (qe == 0.0), return; end
  if (qe < 0.0),
    w=w-s; s=s/10.0;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Others..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=GrabbsSmirnov(al,n)
% Grabbs-Sminov 
%al=0.05;n=3;
t=tinv(al/n*2,n-2);
g=(n-1)*sqrt(t^2/(n*(n-2+t^2)));
return;
