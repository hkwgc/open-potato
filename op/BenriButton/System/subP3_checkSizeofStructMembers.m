function r=subP3_checkSizeofStructMembers(s,parentName)

if nargin < 2
	parentName='';
end

r=[];
mm = fieldnames(s);
for k=1:length(mm)
	if isstruct(s.(mm{k}))
		r0=subP3_checkSizeofStructMembers(s.(mm{k}),[parentName mm{k} ':']);
		r=cat(2,r,r0);
	else
		r=addMember(r,s.(mm{k}), [parentName mm{k}]);
	end
end

function r=addMember(r,d,name)

if ~iscell(d)
	str = [name ': '];
	
	s='[';
	for k=1:ndims(d)
		s=[s num2str(size(d,k)) ', ']; 
	end
	s=[s(1:end-2) ']'];
	r{end+1}=[str s];
else
	for k=1:length(d)
		if sum(size(d{k}))==0, continue;end
		r=addMember(r,d{k},sprintf('%s_CL%02d',name,k));
	end
end

