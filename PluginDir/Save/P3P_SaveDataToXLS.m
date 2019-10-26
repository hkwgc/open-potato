function P3P_SaveDataToXLS(data,hdata,Pth)
% Save to Xls file

%pth0=pwd;
%cd(Pth)

if ndims(data)==3
  % For Continuos
	subSaveCdata(data,hdata,Pth);
else
  % For Block
	subSaveBdata(data,hdata,Pth);
end

%cd(pth0);

function subSaveCdata(data,hdata,p0)
% Save Continuos Data
%--------------------------------------------------------------------------

% Make Saving "File Name"
fn=hdata.TAGs.filename;
if iscell(fn)
  fn=fn{1};
end
f=[p0 filesep fn];
% Clear Save File
try
  delete(f);
end

% Write now!
for k=1:length(hdata.TAGs.DataTag)
	xlswrite(f, data(:,:,k), hdata.TAGs.DataTag{k});
end
	
function subSaveBdata(data,hdata,p0)
% Save Blocked Data
%--------------------------------------------------------------------------
sz=size(data);
fn=hdata.TAGs.filename;

% Make Saving "File Name"
if iscell(fn)
	fn=fn{1};
end
tg=strfind(fn,'\');
if ~isempty(fn)
	fn=fn(tg(end)+1:end);
end
fn=[p0 filesep fn];

% Clear Save File
try
  delete(f);
end

% Write now!
for k=1:length(hdata.TAGs.DataTag)
	tmp=reshape(data(:,:,:,k),[sz(1)*sz(2) sz(3)]);
	m=reshape(repmat([1:sz(1)]',1,sz(2))',[sz(1)*sz(2) 1]);
	tmp=cat(2,m,tmp);
	xlswrite(fn, tmp, hdata.TAGs.DataTag{k});
end

data1=squeeze(nanmean(data,1));
for k=1:length(hdata.TAGs.DataTag)
	xlswrite(fn, data1(:,:,k), [hdata.TAGs.DataTag{k} '_Average']);
end

data1=squeeze(nanstd(data,0,1));
for k=1:length(hdata.TAGs.DataTag)
	xlswrite(fn, data1(:,:,k), [hdata.TAGs.DataTag{k} '_SD']);
end



