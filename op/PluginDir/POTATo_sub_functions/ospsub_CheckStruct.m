function List=ospsub_CheckStruct(D,S,varargin)

% sub function
% check structure of D (struct) if there exist any fields with size of
% (1,S) or (S,1)
% Varargin is not used in general case.
% These variables are for internal use of this recursive func.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% check vararagin 
if ~isempty(varargin)
	List=varargin{1};
	Pname=varargin{2};
else
	List=[];
	Pname=[];
end

if ~isstruct(D), return;end

M=fieldnames(D);
for i=1:length(M)
	sD1=['D.' M{i}];
	if isstruct(eval(sD1))
		List=ospsub_CheckStruct(eval(sD1),S,List,[Pname sD1(2:end)]);
	elseif iscell(eval(sD1))
		for i2=1:length(eval(sD1))
			List=ospsub_CheckStruct(eval([sD1 sprintf('{%d}',i2)]),S,List,[Pname sD1]);
		end
	else
		sz=size(eval(sD1));
		if (sz(1)==1 && sz(2)==S) || (sz(1)==S && sz(2)==1)
			if isempty(Pname)
				List{end+1}=[sD1(3:end)];
			else
				List{end+1}=[Pname(2:end) sD1(2:end)];
			end
			
			%%% BUG ???
			tmp=List{end};			
			if strcmp(tmp(1),'.')
				tmp=tmp(2:end);
				List{end}=tmp;				
			end
			%%%%%%%%%
		end
	end
end

return;

			
		
		

