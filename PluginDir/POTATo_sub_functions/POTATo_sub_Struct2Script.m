function [List ListName]=POTATo_sub_Struct2Script(D,varargin)
	
% sub function
%- This function makes a script text from structure variable.
%- TK@CRL 2012-02-28

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

    
	List=[];ListName={};
	Pname=[];
	if ~isempty(varargin)
		Pname=varargin{1};
		if nargin>2
			List=varargin{2};
			ListName=varargin{3};		
		end
	end
	
	if isempty(D),return;end
	
	if isstruct(D)
		M=fieldnames(D);
		for i=1:length(M)
			sD1=M{i};
			E=D.(M{i});
			if isstruct(E)
				[List ListName]=POTATo_sub_Struct2Script(E,[Pname '.' sD1],List,ListName);
			elseif iscell(E)
				for i2=1:length(E)
					Pname2 = sprintf('%s.%s{%d}',Pname,M{i},i2);
					[List ListName]=POTATo_sub_Struct2Script(E{i2},Pname2,List,ListName);
				end
			else
				[List ListName]=POTATo_sub_Struct2Script(E,[Pname '.' M{i}],List,ListName);
			end
		end
	else
		S=Pname;

		if ischar(D)
			S=sprintf('%s = ''%s'';',S,strrep(D,'''',''''''));
		elseif isnumeric(D)
			if length(D)==1
				S=sprintf('%s = %s;',S,num2str(D));
			elseif isvector(D)
				if size(D,1)==1
					S=sprintf('%s = [%s];',S,num2str(D));
				else
					S=sprintf('%s = [%s]'';',S,num2str(D));
				end
			else
				S=sprintf('%s = nan;%-Marix is not supported.',S,num2str(D));
			end
		elseif islogical(D)
			if D
				S=sprintf('%s = true'';',S);
			else
				S=sprintf('%s = false'';',S);
			end
		end
		
		List{end+1}=S;
		ListName{end+1}=Pname(2:end);
		
		%%% BUG ???
		tmp=List{end};
		if strcmp(tmp(1),'.')
			tmp=tmp(2:end);
			List{end}=tmp;
		end
		%%%%%%%%%
	end
	
	return;
	
	
	
	
	
