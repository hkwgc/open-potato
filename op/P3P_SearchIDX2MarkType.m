if ~isfield(hdata.Results,'SearchIDX')
	errordlg('SearchIndex to Mark type: add "Merge Search-Index" first.');
	return;
end

try
	mtp=str2num(hdata.Results.SearchIDX.BlockID.Data{1});
catch
	errordlg({'SearchIndex to Mark type: Data casting error. Please check input data.',C__FILE__LINE__CHAR(1)});
	return;
end

% if length(mtp)~=size(hdata.stim,1)
% 	errordlg('SearchIndex to Mark type: Block number is different. Please check the lenght of input data.');
% 	return;
% end

hdata.stim(:,1)=mtp;
clear mtp;
