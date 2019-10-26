function r = uiTtest2_ranksum(data1, data2,th)
% T-Test for UITTEST2
%
% Syntax :
%   argData = UITTEST2(period1, period2, threshold);

% Last Modified by GUIDE v2.5 15-Feb-2006 18:39:04

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
      if exist('ranksum','file'),
        d1=squeeze(data1(:,ch,kind));
        d1(isnan(d1))=[];
        d2=squeeze(data2(:,ch,kind));
        d2(isnan(d2))=[];
	[pv,h,stat]= ...
      ranksum(d1,d2,th);
	    %ranksum(data1(:, ch, kind), data2(:, ch, kind), th);
      else
	if ch==1 && kind==1
	  errordlg('No RANKSUM(Statistics Toolbox)');
	end
	stat.zval= NaN;
	h        = NaN;
	pv       = NaN;
      end
      data(1, ch, kind)=stat.zval;
      data(2, ch, kind)=pv;
      data(3, ch, kind)=h;
      data(4, ch, kind)= nan_fcn('mean', data2(:, ch, kind));
      data(5, ch, kind)= nan_fcn('std0', data2(:, ch, kind));
      data(6, ch, kind)= nan_fcn('mean', data1(:, ch, kind));
      data(7, ch, kind)= nan_fcn('std0', data1(:, ch, kind));
    end
  end
    
  r=data;
