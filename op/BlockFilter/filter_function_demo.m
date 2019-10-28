% Demo of filter functions 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% -- Moving Average --
t=[0:0.01:1]';
y=10*sin(t*pi*5) + rand(size(t));
y2=osp_Movingaverage(y,10);
plot(t,y);
hold on
plot(t,y2,'r');

% -- Polyfit Diff --
t=[0:0.01:1]';
y=sin(t*pi*5) + 2+3*t;
y2=osp_Local_Fitting(y,[1:2],1,2);
figure
plot(t,y)
hold on
plot(t,y2,'r')


% -- Local Fit --
t=[0:0.01:1]';
t2 = zeros(size(t));
t2(31:71) = [0.3:0.01:0.7]';
y=2+3*t + ...
    sin(t2*pi*10) ...
    .*(t2-0.3).*(t2-0.7)*10;
y2=osp_Local_Fitting(y,[31:71],1,2);
figure
plot(t,y)
hold on
plot(t,y2,'r')
