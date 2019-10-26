function str=POTATo_subPluging_ChannelNum2String(num)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if length(num)==1
	str=num2str(num);
	return;
end

d=diff(num);
tg=[find(d>1) length(num)];
n=1;str=[];
for k=1:length(tg)
	if n==tg(k)
		str=[str sprintf('%d ',num(tg(k)))];
	else
		str=[str sprintf('%d:%d ',num(n),num(tg(k)))];
	end
	n=tg(k)+1;
end

if length(tg)>1
	str=['[' str(1:end-1) ']'];
else
	str=str(1:end-1);
end