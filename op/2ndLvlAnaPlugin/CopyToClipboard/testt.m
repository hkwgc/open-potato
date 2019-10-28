function [tv, pv] = testt(x1,x2,tst,alpha,tail)
%Student's t test for unpaired or paired samples.
%This file is applicable for equal or unequal sample sizes for unpaired
%samples
%
% Syntax: 	TESTT(X1,X2,TST,ALPHA,TAIL)
%      
%     Inputs:
%           X1 and X2 - data vectors. 
%           TST - unpaired (0) or paired (1) test (default = 0).
%           ALPHA - significance level (default = 0.05).
%           TAIL - 1-tailed test (1) or 2-tailed test (2). (default = 2).
%     Outputs:
%           - t value.
%           - degrees of freedom.
%           - Confidence interval of means difference (for paired test)
%           - Critical value
%           - p-value
%
%      Example: 
%
%           X1=[77 79 79 80 80 81 81 81 81 82 82 82 82 83 83 84 84 84 84 85 ...
%           85 86 86 87 87];
%
%           X2=[82 82 83 84 84 85 85 86 86 86 86 86 86 86 86 86 87 87 87 88 ...
%           88 88 89 90 90];
%
%           Calling on Matlab the function: testt(X1,X2) - unpaired test
%
%           Answer is:
%
%           t value: 5.2411
%           Degrees of freedom: 48
%           Critical value at 95% (2-tailed test): 2.0106
%           Probability (p-value) that the observed difference is accidental: 3.53e-006
%
%           Created by Giuseppe Cardillo
%           CEINGE - Advanced Biotechnologies
%           Via Comunale Margherita, 482
%           80145
%           Napoli - Italy
%           cardillo@ceinge.unina.it


%Input Error handling
switch nargin
    case 1 %only one vector
        error('Warning: two input vectors are required')
    case 2
        tst=0; %default unpaired test
        alpha=0.05; %default value of alpha
        tail=2; %default 2-tailed test
        checkv(x1,x2); %check if x1 and x2 are vectors
    case 3
        alpha=0.05; %default value of alpha
        tail=2; %default 2-tailed test
        checkv(x1,x2); %check if x1 and x2 are vectors
        checkt(tst); %check tst
        if tst==1
            checkp(x1,x2) %check paired condition
        end
    case 4
        tail=2; %default 2-tailed test
        checkv(x1,x2); %check if x1 and x2 are vectors
        checkt(tst); %check tst
        if tst==1
            checkp(x1,x2) %check paired condition
        end
        checka(alpha); %check alpha
    case 5
        checkv(x1,x2); %check if x1 and x2 are vectors
        checkt(tst); %check tst
        if tst==1
            checkp(x1,x2) %check paired condition
        end
        checka(alpha); %check alpha
        checkta(tail); %check tail
end
%check if x1 and x2 are row vectors
[rowx1, colx1] = size(x1);
[rowx2, colx2] = size(x2);
if colx1 == 1
   x1 = x1';
end
if colx2 == 1
   x2 = x2';
end
clear rowx1 rowx2 colx1 colx2 %clear unnecessary variables

switch tst
    case 0 %unpaired test
        n=[length(x1) length(x2)]; %samples sizes
        gl=sum(n)-2; %degrees of freedom
        m=[mean(x1) mean(x2)]; %samples means
        ds=[std(x1) std(x2)];  %samples standard deviations
        s=sum((n-1).*ds.^2)/(sum(n)-2); %combined standard deviation
        dm=diff(m); %Difference of means
        denom=sqrt(sum(s./n));
        clear n m ds s %clear unnecessary variables
    case 1 %paired test
        n=length(x1); %samples size
        gl=n-1; %degrees of freedom
        d=x1-x2; %samples difference
        dm=mean(d); %mean of difference
        denom=sqrt((sum((d-dm).^2))/(n*(n-1))); %standard error of difference
        clear n d %clear unnecessary variables
end
%t=abs(dm)/denom; %t value
t=(dm)/denom; %t value
vc=tinv(1-alpha/tail,gl); %critical value
lf=num2str((1-alpha)*100); %fiducial level
%%
if t > 0
	p=(1-tcdf(t,gl))*tail; %t-value associated p-value
else
	p=(tcdf(t,gl))*tail; %t-value associated p-value
end
%%070105
tv = t;
pv = p;

%display results
if tst==1
%     disp(['Mean of difference: ' num2str(abs(dm))])
    ic=[abs(dm)-vc abs(dm)+vc]; %Confidence interval
%     disp(['Mean of difference confidence interval at ' lf '% : ' num2str(ic(1)) ' ' num2str(ic(2))])
end
% disp(['t value: ' num2str(t)])
% disp(['Degrees of freedom: ' num2str(gl)])
% disp(['Critical value at ' lf '% (' num2str(tail) '-tailed test): ' num2str(vc)])
% disp(['Probability (p-value) that the observed difference is accidental: ' num2str(p)])	
return

function checkv(x1,x2) %check if x1 and x2 are vectors
if (min(size(x1)) > 1 || min(size(x2)) > 1)
   error('TESTT requires vector rather than matrix data.');
end 
return

function checkt(tst) 
if (numel(tst)>1)%check if tst is a scalar
    error('Warning: it is required a scalar TST value.');
end
if (isnan(tst) || (tst ~= 0 && tst ~= 1))%check if tst is 0 or 1
    error('Warning: TST must be 0 for unpaired test or 1 for paired test.')
end
return

function checka(alpha)
if (numel(alpha)>1)%check if alpha is a scalar
    error('Warning: it is required a scalar ALPHA value.');
end
if (isnan(alpha) || alpha <= 0 || alpha >= 1)%check if alpha is between 0 and 1
    error('Warning: ALPHA must be comprised between 0 and 1.')
end        
return

function checkta(tail)
if (numel(tail)>1)%check if tail is a scalar
    error('Warning: it is required a scalar TAIL value.');
end
if (isnan(tail) || (tail ~= 1 && tail ~= 2))%check if tail is 1 or 2
    error('Warning: TAIL must be 1 for 1-tailed test or 2 for 2-tailed test.')
end
return

function checkp(x1,x2)
if ((numel(x1) ~= numel(x2))),
   error('Warning: for paired test TESTT requires the data vectors to have the same number of elements.');
end
return
