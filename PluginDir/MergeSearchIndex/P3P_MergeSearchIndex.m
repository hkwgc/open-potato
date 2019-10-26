function hdata=P3P_MergeSearchIndex(hdata)

l=DataDef2_Analysis('loadlist'); % loading list of the Project. this list contain info for all files in the project.
%-------------
% Primary Key
%-------------
pkey=DataDef2_Analysis('getIdentifierKey');
pkeys={l.(pkey)};

%if ~isempty(findstr('\',hdata.TAGs.(pkey){:}))
if iscell(hdata.TAGs.(pkey))
	[tmp tmp1]=fileparts(hdata.TAGs.(pkey){:});
	myfid= find(strcmpi(tmp1,pkeys)); % find mykey index
else
	myfid= find(strcmpi(hdata.TAGs.(pkey),pkeys)); % find mykey index
end

hdata.Results.SearchIDX=l(myfid);


