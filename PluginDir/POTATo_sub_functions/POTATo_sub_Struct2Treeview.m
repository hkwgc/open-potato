function List=POTATo_sub_Struct2Treeview(D,sepStr,varargin)
% sub function
%- This function makes a tree-view text from structure variable.
%
%- ex.) ret=POTATo_sub_Struct2Treeview(D,'\t');sprintf(ret);
%
% Second variable is character for a separater.
%- TK@CRL 2012-02-28

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


List=[];
Pname=[];
if ~isempty(varargin)
	Pname=varargin{1};
	List=varargin{2};
end

if isempty(D),return;end

if isstruct(D)
	M=fieldnames(D);
	for i=1:length(M)
		sD1=M{i};
		E=D.(M{i});
		if isstruct(E)
			List=[List Pname sD1 '\n'];
			List=POTATo_sub_Struct2Treeview(E,sepStr,[Pname sepStr],List);
		elseif iscell(E)
			
			List=[List Pname sD1 '{}' '\n'];

		else
			List=POTATo_sub_Struct2Treeview(E,sepStr,[Pname M{i}],List);
		end
	end
else
	
	List=[List Pname '\n'];
	
	%%% BUG ???
% 	tmp=List{end};
% 	if strcmp(tmp(1),'.')
% 		tmp=tmp(2:end);
% 		List{end}=tmp;
% 	end
	%%%%%%%%%
end

return;





