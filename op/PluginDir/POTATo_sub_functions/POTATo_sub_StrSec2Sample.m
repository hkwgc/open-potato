function str=POTATo_sub_StrSec2Sample(s,unit,deci)
% Example:
% s='st:ed+10 15:20'
% POTATo_sub_StrSec2Sample(s,10,0)
% ans =
%    st:ed+100 150:200
%
% POTATo_sub_StrSec2Sample(s,10,1)
% ans =
%    st:ed+100.0 150.0:200.0
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


n=regexp(s,'\d+','match');
tg=regexp(s,'\d+');
str=s(1:tg(1)-1);


for k=1:length(n)
	tf(k)=tg(k)+length(n{k})-1;
end

for k=1:length(n)
	
	if k==length(n)
		s2=s(tf(k)+1:end);
	else
		s2=s(tf(k)+1:min([tg(k+1)-1 length(s)]));
	end
	
	nn=subNum(n{k},unit,deci);
	str=[str nn s2];
end

function n=subNum(n,unit,deci)

if deci==0
	ss='%d';
else
	ss=sprintf('%%0.%df',deci);
end

n=sprintf(ss,eval(n)*unit);
