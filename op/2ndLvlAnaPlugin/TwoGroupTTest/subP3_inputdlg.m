function Answer=subP3_inputdlg(Prompt, Title, NumLines, DefAns, Resize)
%---
% sub function for inputdlg
%
% TK 2011/09/10
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


cellTag = [];
for k=1:length(DefAns)
	if iscell(DefAns{k})
		cellTag(end+1)=k;
		s0 = DefAns{k}{1};
		s=[];
		for k1=1:length(s0)
			s=[s sprintf('%d:%s / ',k1,s0{k1})];
		end
		s=s(1:end-2);
		Prompt{k} = sprintf('%s\n%s',Prompt{k}, s);
		DefAns{k} = num2str(DefAns{k}{2});
	end
end

if nargin < 5
	Answer = inputdlg(Prompt, Title, NumLines, DefAns);
else
	Answer = inputdlg(Prompt, Title, NumLines, DefAns, Resize);
end

if isempty(Answer)
	return;
end

for k=cellTag
	a{1}=str2num(Answer{k});
	a{2}=s0{a{1}};
	Answer{k}=a;
end