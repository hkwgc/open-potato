function [data]=uc_ttest3(data1,data2,TH)
% [data]=uc_ttest3(data1,data2,TH)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% ---- t - test ----
data1 = nan_fcn('mean', data1,2);
sz=size(data1); sz(2)=[]; data1=reshape(data1,sz);
data2 = nan_fcn('mean', data2,2);
sz=size(data2); sz(2)=[]; data2=reshape(data2,sz);
for ch = 1:size(data1, 2),     % ch data num (ex. 24 channel)
	for kind = 1:size(data1,3),  % HB data num (ex. 3 oxy,deoxy,total)
		
		% nan remove
		nanflg = isnan(data1(:,ch,kind)) | isnan(data2(:,ch,kind));
		nanflg = find(nanflg==0);
		if ~isempty(nanflg)
			data1tmp = data1(nanflg,ch,kind);
			data2tmp = data2(nanflg,ch,kind);
		end
		
		if ~isempty(nanflg) && exist('tcdf','file')
			try
				[h,pv,ci,stat]= ...
					ttest3(data2tmp, data1tmp, TH, 0);
			catch
				[h,pv,ci,stat]=ttest3([1,1],[1,2]);
				h=0;pv=0;stat.tstat=0;
			end
		else
			if isempty(nanflg) && kind==1,
				fprintf(['NaN Channel : ' num2str(ch)]);
			end
			if ch==1 && kind==1
				if ~exist('tcdf','file')
					fprintf('No TCDF(Statistics Toolbox)');
				end
			end
			stat.tstat = NaN;
			pv         = NaN;
			h          = NaN;
		end
		data(1, ch, kind)=stat.tstat;
		data(2, ch, kind)=pv;
		data(3, ch, kind)=h;
		data(4, ch, kind)= nan_fcn('mean', data2(:, ch, kind));
		data(5, ch, kind)= nan_fcn('std0', data2(:, ch, kind));
		data(6, ch, kind)= nan_fcn('mean', data1(:, ch, kind));
		data(7, ch, kind)= nan_fcn('std0', data1(:, ch, kind));
	end
end
