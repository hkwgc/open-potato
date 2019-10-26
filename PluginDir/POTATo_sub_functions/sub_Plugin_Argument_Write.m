function ret=sub_Plugin_Argument_Write(A)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


ret=1;

fld=fieldnames(A);

make_mfile('with_indent', 'clear A;');

for k=1:length(fld)
	
	B=eval(['A.' fld{k}]);
	if ~iscell(B)
		str=['A.' fld{k} ' = ' subGetStr(B)];
		make_mfile('with_indent', str);
	else
		for kk=1:length(B)
			str=['A.' fld{k} sprintf('{%d} = ',kk) subGetStr(B{kk})];
			make_mfile('with_indent', str);
		end
	end
end

function str = subGetStr(B)
	if isempty( B )
		str=[' [];'];
	elseif ischar( B )
		str=[ '''' B ''';'];
	elseif isnumeric( B )
		
		if ndims(B)>2 || min(size(B))>1
			warndlg(sprintf('error in sub_Plugin_Argument_Write.m\n Dim>2 or Size>1.'));
			ret=-1;
			return;
		end
		
		if length(B) == 1, str1='';str2='';
		else str1='[';str2=']';end
		
		str=[ str1];
		for j=1:length(B)
			if (fix(B)-B)~=0 % float
				strF=' %f';
			else % int
				strF=' %d';
			end
			str = [str sprintf(strF, B(j))];
		
		end
		str=[str str2 ';'];		
	else
		str='???';
		ret=-1;
	end
