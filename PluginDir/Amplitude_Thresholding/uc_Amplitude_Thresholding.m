function [data,hdata] = uc_add_FinoData(data,hdata,AmpMax,kind)
%
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% == History ==
% coding : TK
% create : 2005.12.12
% $Id: uc_Amplitude_Thresholding.m 180 2011-05-19 09:34:28Z Katura $
%
%   No check..

% data(Block,Time,Ch,Kind) & data(Time ,Ch, Kind) also available

if ndims(data)==3
	% continuous
	%tmp=abs(data);    
	%M1=squeeze(max(tmp(:,:,kind),[],1));%[1,ch]
	%M2=squeeze(min(tmp(:,:,kind),[],1));%[1,ch]% comment out by TK 090803
    
	M1=squeeze(max(data(:,:,kind),[],1));%[1,ch]
	M2=squeeze(min(data(:,:,kind),[],1));%[1,ch]
	M=M1-M2;% Amp-data to check
	MT=(M>AmpMax);	

	% 	%これはかなり強引な処理です！ 060307 TK
	% 	data(:,find(MT),:)=0;
	% 	hdata.TAGs.CHFLAG=find(MT);
	% 	hdata.TAGs.CHAMP=M(find(MT));
	
	% ちゃんとFLAGを使うことにします。060407TK
	hdata.flag(1,:,find(MT))=1;
	
elseif ndims(data)==4
	% block
	%data=abs(data);
	M1=squeeze(max(data(:,:,:,kind),[],2));%[block,ch]
	M2=squeeze(min(data(:,:,:,kind),[],2));%[block,ch]
	M=M1-M2;% Amp-data to check
	MT=(M>AmpMax);
	
	hdata.flag(1,:,:)=(squeeze(hdata.flag(1,:,:)) | MT);
	
else
	errordlg('data size error in Amplitude thretholding');
end