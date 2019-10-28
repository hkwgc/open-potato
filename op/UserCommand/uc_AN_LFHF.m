function [hdata]=uc_AN_LFHF(data,hdata)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%LF
[b, a] = ot_butter(0.05, 0.14, 1000/hdata.samplingperiod,	5, 'bpf');
data=ot_filtfilt(data,a,b,1);
F=abs(fft(data));F=F(1:round(end/2),:,:).^2;
P_LF=squeeze(sum(F,1));

%HF
[b, a] = ot_butter(0.25, 0.40, 1000/hdata.samplingperiod,	5, 'bpf');
data=ot_filtfilt(data,a,b,1);
F=abs(fft(data));F=F(1:round(end/2),:,:).^2;
P_HF=squeeze(sum(F,1));

hdata.TAGs.LFHF.LF=P_LF;
hdata.TAGs.LFHF.HF=P_HF;

