function r = uiTtest2_signrank(data1, data2,th,hdata)
% T-Test for UITTEST2
%
% Syntax :
%   argData = UITTEST2(period1, period2, threshold);

% $Date: 2014-11-05 15:17:36 +0900 (水, 05 11 2014) $

% $Id: uiTtest2_ranksum.m 180 2011-05-19 09:34:28Z Katura $

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% ---- Wilcoxon rank-sum test ----

% Make [ block*time ch hb]
s=size(data1);
data1=reshape(data1,[s(1)*s(2) s(3) s(4)]);
s=size(data2);
data2=reshape(data2,[s(1)*s(2) s(3) s(4)]);


for ch = 1:size(data1, 2),     % ch data num (ex. 24 channel)
	for kind = 1:size(data1,3),  % HB data num (ex. 3 oxy,deoxy,total)
		if exist('signrank','file'),
			d1=squeeze(data1(:,ch,kind));
			d1(isnan(d1))=[];
			d2=squeeze(data2(:,ch,kind));
			d2(isnan(d2))=[];
			[pv,h,stat]= signrank(d1,d2,th);
		else
			if ch==1 && kind==1
				errordlg('No function for "SIGNRANK" found. (Is Statistics Toolbox not installed?)');
			end
			stat.zval= NaN;
			h        = NaN;
			pv       = NaN;
		end
		if isfield(stat,'zval')
			data(1, ch, kind)=stat.zval;
		end
		dat(2, ch, kind)=pv;
		dat(3, ch, kind)=h;
		dat(4, ch, kind)= nan_fcn('mean', data2(:, ch, kind));
		dat(5, ch, kind)= nan_fcn('std0', data2(:, ch, kind));
		dat(6, ch, kind)= nan_fcn('mean', data1(:, ch, kind));
		dat(7, ch, kind)= nan_fcn('std0', data1(:, ch, kind));
		
	end
end

h=[];
kindstr=hdata.TAGs.DataTag;
n=min(length(kindstr),size(data,3));
fieldstr={'t','p','h','mean2','sd2','mean1','sd1'};
for k1=1:n
	for k=1:7
		h=POTATo_sub_AddResults(h,[kindstr{k1} '_' fieldstr{k}],dat(k,:,k1));
	end
end

for i=1:n
  for j=1:size(data2,1)
    eval(sprintf('h.Results.%s.period2.block%d=data2(j,:,i);',kindstr{i},j));
    eval(sprintf('h.Results.%s.period1.block%d=data1(j,:,i);',kindstr{i},j));
  end
end

r=h.Results;
