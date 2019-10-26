function hdata=P3P_M_CorrSearchItems(hdata, data, strSearchItem, strEval)
% hdata=P3P_M_CorrSearchItems(hdata, data, strSearchItem, strEval)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

n=length(hdata);
V1=zeros(1,n);
X=V1;
k=1;
try
	tmp=eval(strEval);
catch
	warndlg('Erro in EvalStr','CorrSearchItems');
	return;
end


for k=1:n	
	V1(k)=hdata{k}.Results.SearchIDX.(strSearchItem);
	%X(k)=hdata{k}.Results.SearchIDX.date;
end

%== mode signle value ==
if length(tmp)==1
	V2=zeros(1,n);
	for k=1:n
		V2(k)=eval(strEval);
	end
	%---
	cc=sub_calcCorrelation(V1,V2);
	%---
	figure;
	subplot(2,2,1);plot(V1,V2,'ok');
	xlabel(strSearchItem);ylabel(strEval);
	axis square;
	
%== mode loop ==
else
	n2=length(tmp);
	V2=zeros(n,n2);
	for k=1:n
		V2(k,:)=eval(strEval);
	end
	%---	
	cc=zeros(1,n2);
	for k=1:n2
		cc(1,k)=sub_calcCorrelation(V1,V2(:,k));
	end
	%---
	%--draw
% 	figure;
% 	for k=1:n2
% 		subplot(ceil(sqrt(n2)),round(sqrt(n2)),k);
% 		plot(V1,V2(:,k),'ok');
% 		title(sprintf('ch%02d(%0.2f)',k,cc(k)));
% 	end
end

if ~isfield(hdata{1}.Results,'MULTI')
	hdata{1}.Results.MULTI={};
end
hdata{1}.Results.MULTI{end+1}.cc=cc;
hdata{1}.Results.MULTI{end}.V1=V1;
hdata{1}.Results.MULTI{end}.V2=V2;



function cc=sub_calcCorrelation(V1,V2)

tmp=corrcoef(V1,V2);
cc=tmp(1,2);
