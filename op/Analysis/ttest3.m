function [h,p,ci,stats] = ttest3(x,y,alpha,tail)
%
%paired t-test
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if nargin < 2, 
    error('Requires at least two input arguments'); 
end

[m1 n1] = size(x);
[m2 n2] = size(y);
if (m1 ~= 1 && n1 ~= 1) || (m2 ~= 1 && n2 ~= 1)
  error('Requires vector first and second inputs.');
end
x = x(~isnan(x));
y = y(~isnan(y));
 
if nargin < 4, 
    tail = 0; 
end 

if nargin < 3, 
    alpha = 0.05; 
end 

if (prod(size(alpha))>1), error('ALPHA must be a scalar.'); end
if (alpha<=0 || alpha>=1), error('ALPHA must be between 0 and 1.'); end

df = length(x) -1; % block=df

%s=zeros(1,df);

s=x-y;

difference = mean(s);
pooleds    = sqrt(std(s)^2/df);

ratio = difference / pooleds;

if (nargout>3), stats = struct('tstat', ratio, 'df', df); end

% Find the p-value for the tail = 1 test.
  
p = osp_distribute('tdist',abs(ratio),df)/2.;

% Adjust the p-value for other null hypotheses.
if (tail == 0)
    p = 2 * min(p, 1-p);
    spread = osp_distribute('tinv',alpha,df) * pooleds;
    if (nargout>2), ci = [(difference - spread) (difference + spread)]; end
else
    spread = tinv(1 - alpha,df) * pooleds;
    if (tail == 1)
       if (nargout>2), ci = [(difference - spread), Inf]; end
    else
       p = 1 - p;
       if (nargout>2), ci = [-Inf, (difference + spread)]; end
    end
end

% Determine if the actual significance exceeds the desired significance
h = 0;
if p <= alpha, 
    h = sign(ratio); 
end 

if isnan(p), 
    h = NaN; 
end
