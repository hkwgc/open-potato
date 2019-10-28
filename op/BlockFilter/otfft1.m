% function varargout=otfft1(data,dim,smpl_prd)
% This function return fftdata and the half of shifted fftdata and the frequency data for x-axis
% You have to input precessing data as 1st input, you cna input up to 10 dimensions
% You have to input dimension for fft in processing data
% You have to input sampling-period
% Out put: 1 fft data, 2 half of fft data, 3 frequnecy data for x axis 
% You can choice the numbers of output from 1 to 3
% by A. Maki July 28, 2002


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


function varargout=otfft1(data,dim,smpl_prd)

%Initialize
data_num=size(data,dim);
% Change order by Shoji 15-Oct-2004 
% If you use 'vaxhlf' or 'fftv' in other calculation
% The line that calculate those value can put follwing line.

% Make ffdata_hlf
fft_dat=fftshift(fft(data,[],dim),dim);%fft dat

% Make fftdata_hlf ( fft_data will be not change.) 
fftdat_dim=ndims(fft_dat);%get dimension
cnv_dim=[1:fftdat_dim];cnv_dim=[dim,setdiff(cnv_dim,dim)]; % To operate "dim"
fftdat_hlf=permute(fft_dat,cnv_dim);
fftv=[floor(size(data,dim)/2)+1:size(data,dim)];%extraction vector from fftdata to half fft_data
fftdat_hlf=fftdat_hlf(fftv,:,:,:,:,:,:,:,:,:);%Half of shift data
fftdat_hlf=ipermute(fftdat_hlf,cnv_dim);

% Make vaxhlf
vaxhlf=[0:1000/((data_num-1)*smpl_prd):1000/(smpl_prd*2)];%((size(data,dim)-floor(size(data,dim)/2))-1)*1000/((data_num-1)*smpl_prd)];%Axis-x of half

varargout(1)={fft_dat};
varargout(2)={fftdat_hlf};
varargout(3)={vaxhlf};

% === Grep Result 27-Dec-2004 ===
%  preprocessor/otsigtrnschld.m
%      :56:[signal.hbfrq,signal.hbfrqhlf,signal.hbfrqvax]...
%            = otfft1(signal.chb,1,signal.sampleperiod);%get frequency data
