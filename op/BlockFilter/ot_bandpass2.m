function [data,varargout]=ot_bandpass2(data,hpf,lpf,pairnum,smp,dim,typ,varargin)
%[data,varargout]=ot_bandpass(data,hpf,lpf,smp,dim,typ,varargin)
%   input:
%           data: data matrix
%           hpf: [vector]:high-pass filter(low frequency) [Hz]:9999=>no hpf
%           lpf: [vector]:low-pass filter(high frequency) [Hz]:9999=>no lpf
%           pairnum: the number of pairs of hpf and lph: 
%           smp: sampling period [sec]
%           dim: dimension for fft
%           typ: the type of data 'time' or 'fft'
%   output:
%           data: bandpassed data
%           
%
% Oct 31, 2002, Maki


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%Set fftshift data
switch typ,
case{'time','Time','TIME'}
    y=fft(data,[],dim);
case{'fft','Fft','FFT'}
    y=data;
end

%Set permute order
ororder=[1:length(size(y))];
diforder=setdiff(ororder,dim);
modorder=[dim,diforder];

%Permute y
y=permute(y,modorder);

% Set the unit of frequency
funit=1/(size(y,1)*smp);  % Add ';'  by Shoji 19-Oct-2004
n=size(y,1);

%Set frequency array
%[1:ceil(n/2)]; [ceil(n/2)+1:ceil(n/2)+floor(n-1)/2]
ldum=([1:ceil(n/2)]-1)*funit;
%rdum=-sort(-[1:floor(n-1)/2]*funit);
rdum=-sort(-[1:round((n-1)/2)]*funit);  % Change : OK -> 07-Feb-2005
freqvec=[ldum,rdum];

for ii=1:pairnum
    %Set band-pass filter index
    if hpf(ii)~=9999,hpfidx=find(freqvec<hpf(ii));end
    if lpf(ii)~=9999,lpfidx=find(freqvec>lpf(ii));end
    
    %band pass filter
    if hpf(ii)~=9999,y(hpfidx,:,:,:,:,:,:,:,:,:,:,:,:)=0;end
    if lpf(ii)~=9999,y(lpfidx,:,:,:,:,:,:,:,:,:,:,:,:)=0;end
end

%Ipermute
y=ipermute(y,modorder);

%IFFT
data=real(ifft(y,[],dim));