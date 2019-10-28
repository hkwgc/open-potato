function data=P3P_BaselineCorrectionB(data,hdata, Deg, IgP)
% data=P3P_BaselineCorrectionB(data,hdata, Deg, IgP)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



IgP=subParseIgP(IgP,data,hdata);

if isempty(IgP)
	IgP=[];
else
	IgP=eval(IgP);
end

Deg=eval(Deg);

x=1:size(data,2);
for k0=1:size(data,4) %- kind
	for k1=1:size(data,3) %- ch
		for k2=1:size(data,1) %- epoch
			x1=x;
			x1(IgP)=0;
			x1(hdata.flag(1,k2,k1)~=0)=0;
			if all(x1==0), continue;end
			p=polyfit(x1(x1>0),data(k2,x1>0,k1,k0),Deg);
			pv=polyval(p,x);
			data(k2,:,k1,k0)=data(k2,:,k1,k0)-pv;
		end
	end
end

function s=subParseIgP(s,data,hdata)

if ~isempty(findstr(s,'ed'))
	s=strrep(s,'ed',num2str(size(data,2)));
end

if ~isempty(findstr(s,'m1'))
	s=strrep(s,'m1',num2str(hdata.stim(1)));
end

if ~isempty(findstr(s,'m2'))
	s=strrep(s,'m2',num2str(hdata.stim(2)));
end
 