function hdata=uc_SimpleT_Test(data,hdata,chdata,tm,T_Mean,T_Alpha,T_Tail)
%
% osp statistical function
% this function uses matlab function of 'ttest'
% usage: hdata=uc_SimpleT_Test(data,hdata,tm,T_Mean,T_Alpha,T_Tail)
% input: 
%    data,hdata: see osp data format
%    tm: time period for t-test (unit is data point. not sec.) 
%    T_Mean: hypothesys value
%    T_Alpha: test threshold
%    T_Tail: see ttest help for detail info.
%
% 2006/02/13 TK
% Version 1.0
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


a=squeeze(mean(data(:,tm,:,:),2));
a_std=squeeze(std(data(:,tm,:,:),[],2));
sz=size(a);

for i=1:sz(3)
	sK{i}=hdata.TAGs.DataTag{i};
	if strcmp(sK{i},'TDDICA Reconstruncted')
		sK{i}='TDD_RECON';
	elseif strcmp(sK{i},'TDDICA all ICs')
		sK{i}='TDD_ICs';
	end
end

for i1=1:sz(3) % loop for kind
	for i2=1:sz(2) % loop for ch
		tg=find(squeeze(hdata.flag(1,:,i2))==0);
		if size(tg,2)>1
			x=a(tg,i2,i1);
			x_std=squeeze(a_std(tg,i2,i1));
			[H,P,CI,STAT]=ttest(x, T_Mean, T_Alpha, T_Tail);
            x_mn=mean(x);
		else
			H=0;P=0;STAT.tstat=0;
			x=[];x_std=[];x_mn=NaN;
		end
		sK{i1}=strrep(sK{i1},' ','_');
		sK{i1}=strrep(sK{i1},'(','_');
		sK{i1}=strrep(sK{i1},')','_');
		
		eval(['RES.' sK{i1} '.t(1,i2)=STAT.tstat;']);
		eval(['RES.' sK{i1} '.p(1,i2)=P;']);
		eval(['RES.' sK{i1} '.h(1,i2)=H;']);
		eval(['RES.' sK{i1} '.data{i2}=x;']);
		eval(['RES.' sK{i1} '.data_sd{i2}=x_std;']);
		eval(['RES.' sK{i1} '.mean(1,i2)=x_mn;']);
		eval(['RES.' sK{i1} '.sd(1,i2)=std(x);']);
		eval(['RES.' sK{i1} '.BlockNumber(1,i2)=size(tg,2);']);
	end
end

[hdata]=POTATo_sub_AddResults(hdata,'SimpleT_Test',RES);


