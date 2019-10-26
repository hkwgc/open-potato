function r = uiTtest2_ttest(data1, data2, th, hdata)
% T-Test for UITTEST2
%
% Syntax :
%  r=uiTtest2_ttest(period1, period2, threshold);
%
% Syntax : (available since revision 1.3)
%  r=uiTtest2_ttest(period1, period2, threshold,hdata);


% Last Modified by GUIDE v2.5 15-Feb-2006 18:39:04

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2006.02.15
% $Id: uiTtest2_ttest.m 304 2013-01-25 09:44:55Z Katura $

r=sub_ttest(data1, data2, th, hdata);

if length(unique(hdata.stimkind))==1
	return;
end

kd=unique(hdata.stimkind)';
for k=kd
	tmp=sub_ttest(data1(hdata.stimkind==k,:,:,:), data2(hdata.stimkind==k,:,:,:), th, hdata);
	r.(sprintf('stim%d',k))=tmp;
end



function r = sub_ttest(data1, data2, th, hdata)
% ---- t - test ----
data1 = nan_fcn('mean', data1,2);
sz=size(data1); sz(2)=[]; data1=reshape(data1,sz);
data2 = nan_fcn('mean', data2,2);
sz=size(data2); sz(2)=[]; data2=reshape(data2,sz);
nanflag2=false(1,size(data1,2));
for ch = 1:size(data1, 2),     % ch data num (ex. 24 channel)
  
  for kind = 1:size(data1,3),  % HB data num (ex. 3 oxy,deoxy,total)

    % nan remove
    nanflg = isnan(data1(:,ch,kind)) | isnan(data2(:,ch,kind));
    nanflg = find(nanflg==0);
    if ~isempty(nanflg)
      data1tmp = data1(nanflg,ch,kind);
      data2tmp = data2(nanflg,ch,kind);
    end

    if ~isempty(nanflg) % && exist('tcdf','file')
      try
        [h,pv,ci,stat]= ...
          ttest3(data2tmp, data1tmp, th, 0);
        if 0,disp(ci);end
      catch
        %[h,pv,ci,stat]=ttest3([1,1],[1,2]);
        h=0;pv=0;stat.tstat=0;
      end
    else
      if isempty(nanflg) && kind==1,
        nanflag2(ch)=true;
      end
%       if ch==1 && kind==1
%         if ~exist('tcdf','file')
%           errordlg('No TCDF(Statistics Toolbox)');
%         end
%       end
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

nanch=find(nanflag2);
if ~isempty(nanch)
  errordlg({'There is NaN Channel : ',...
    ['    ' num2str(nanch)]},'T-Test');
end

if nargin>=4
  kindstr=hdata.TAGs.DataTag;
  n=min(length(kindstr),size(data,3));
  for i=1:n
    n2 = kindstr{i};
    n2 = strrep(n2,' ','_');
    n2 = strrep(n2,'-','_');
    n2 = strrep(n2,'+','_');
    n2 = strrep(n2,'%','_');
    n2 = strrep(n2,'=','_');
    
    n2 = strrep(n2,'/','_');
    n2 = strrep(n2,'\','_Y_');
    
    n2 = strrep(n2,'?','_');
    n2 = strrep(n2,'@','_At_');
    n2 = strrep(n2,'#','_No_');
    if isvarname(n2)
      kindstr{i} = n2;
    elseif isvarname(['Data_' n2])
      kindstr{i} = ['Data_' n2];
    else
      kindstr{i} = sprintf('Data_%d',i);
    end
  end
else
  kindstr={'Oxy','Deoxy','Total'};
  n=3;
end
fieldstr={'t','p','h','mean2','sd2','mean1','sd1'};
d=[];

for i=1:n
  for j=1:length(fieldstr)
    eval(sprintf('d.%s.%s=data(j,:,i);',kindstr{i},fieldstr{j}));
  end
end

for i=1:n
  for j=1:size(data2,1)
    eval(sprintf('d.%s.period2.block%d=data2(j,:,i);',kindstr{i},j));
    eval(sprintf('d.%s.period1.block%d=data1(j,:,i);',kindstr{i},j));
  end
end

r=d;
