function [hdata,h_fig] = uc_motioncheck_Wavelet(data,hdata,SC,TH,kind,varargin)
% [hdata,h_fig] = uc_motioncheck_Wavelet(data,hdata,SC,TH,kind,varargin)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Hiroki Sato
% coding : TK
% create : 2005.09.05
% $Id: uc_MotionCheck_Wavelet.m 352 2013-05-08 02:42:56Z Katura $
%
% Reversion 1.00, Date 09.05
%   No check..

wv = 'haar';
%%%%%%%%%%%%%%%%%%%%wavelet filter%%%%%%%%%%%%%%%%%%%%ST
sz=size(data);
%data = (Blk, Count, ch, Hb)

if nargin<6
  
	%     for mm = 1:sz(3)
	%          for k = 1:sz(1)
	%             ex = data(k,:, mm, kind);
	%             ex2 =cwt(ex, SC, wv);
	%             ex2 =ex2.^2;
	%             ttl = median(ex2(11:(end-10)));
	%             ttl=ttl+(ttl==0);
	%             ex2=ex2./ttl;
	%             if max(ex2(1,10:end-10),[],2) > TH
	%                 hdata.flag(1,k,mm) = 1;
	%             end
	%          end
	%      end
         
 
	data=data(:,:,:,kind);
	data=permute(data,[2 1 3]);%[time block ch]
	data=reshape(data,[1 sz(1)*sz(2)*sz(3)]);
	data=cwt(data,SC, wv);
	data=data.^2;
	data=reshape(data,[sz(2) sz(1) sz(3)]);
	data=permute(data,[2 1 3]);
	ttl=repmat(median(data,2),[1 sz(2) 1]);% median of the sauare of Wavelet coeff for normalization
	ttl=ttl+(ttl==0);
	data=data./ttl;
	data=sum(data(:,10:end-10,:)>TH,2);
	hdata.flag=(hdata.flag | permute(data,[2 1 3]));


else
	%TEST
	data=data(:,:,:,kind);
	data=permute(data,[2 1 3]);%[time block ch]
	data=reshape(data,[1 sz(1)*sz(2)*sz(3)]);
	testSC=varargin{1};
	data=cwt(data,testSC, wv);
	data=data.^2;
	data=reshape(data,[length(testSC) sz(2) sz(1) sz(3)]);
	data=permute(data,[1 3 2 4]);%[SC block time ch]
	ttl=repmat(median(data,3),[1 1 sz(2) 1]);% median of the sauare of Wavelet coeff for normalization
	ttl=ttl+(ttl==0);
	data=data./ttl;
    h_fig=[];
	
	if varargin{2}==1
		str={'[Block]','[Channel]'};
		evstr={'sz(1)','sz(3)','data(ii,m,10:sz(2)-10,k)'};		
	else
		str={'[Channel]','[Block]'};
		evstr={'sz(3)', 'sz(1)','data(ii,k,10:sz(2)-10,m)'};
	end
	
	for ii=1:length(testSC)%sc
		h_fig(end+1)=figure;
		set(h_fig(end),'Name',sprintf('Wavelet Results Scale %d',testSC(ii)),'Numbertitle','off','Tag','MotionCheckWavelet');
		for m=1:eval(evstr{1})
			
			for k=1:eval(evstr{2})
				
				subplot(eval(evstr{1}),eval(evstr{2}),(m-1)*eval(evstr{2})+k)
				if k==1, ylabel(m);end					
				
				h=patch([hdata.stim hdata.stim(1,[2 1])],[0 0 50 50],[0.75 1 0.75]);
				set(h,'LineStyle','none');hold on
				plot(10:sz(2)-10,squeeze(eval(evstr{3})));ylim([0 50]);
				box on;
				xlim([0 sz(2)]);
				title(k);
				h=line([0 sz(2)],[TH TH]);set(h,'LineStyle','-','color','r');
                %if (k<sz(1)) & (i>1), axis off;end
			end
		end

		h=axes('position',[0.12 0 0.001 1]);axis off;h=ylabel(str{1});set(h,'visible','on')
		h=axes('position',[0 0.1 1 0.01]);axis off;h=xlabel(str{2});set(h,'visible','on')	
	end

end
		



% %ex2=zeros(sz(1),sz(3),sz(2));
% for m = 1:sz(3) %roop for CH
% 	if nargin==6,% TEST MODE
% 		h=figure;set(h,'Name',sprintf('Wavelet Results Ch.%d',m),'Numbertitle','off','Tag','MotionCheckWavelet');
% 	end
% 	for k = 1:sz(1) % roop for BLOCK
% 		tmp =cwt(data(k,:,m,kind),SC, wv); % Wavelet coefficients, scale: 1-30
% 		ex2(k,m,:)=tmp(:,:);
% 
% 		if nargin==6,% TEST MODE
% 			d=(tmp.^2./repmat((median(tmp.^2,2)+(median(tmp.^2,2)==0)),[1 size(tmp,2)]))';
% 			for i=1:30
% 				subplot(sz(1),30,i+(k-1)*30)
% 				h=patch([hdata.stim hdata.stim(1,[2 1])],[0 0 50 50],[0.9 1 0.9]);set(h,'LineStyle',':');hold on
% 				plot(d(:,i));ylim([0 50]);xlim([0 size(d,1)]);title(i)
% 				h=line([0 size(d,1)],[TH TH]);set(h,'LineStyle',':','color','r');
% 			end
% 		end
% 		
% 	end
% end
% ex3 = ex2.^2; % square of Wavelet coefficients
% ttl=repmat(median(ex3,3),[1 1 sz(2)]);% median of the sauare of Wavelet coeff for normalization
% ttl=ttl+(ttl==0);
% ex4=ex3./ttl;
% ex5=sum(ex4(:,:,10:end-10)>TH,3);
% 
% hdata.flag=(hdata.flag | reshape(ex5,[1 sz(1) sz(3)]));
% 
