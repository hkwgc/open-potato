function P3P_saveMeanValasTextFile(data,hdata,period,filename)

%- prepare data
if ndims(data)==3 %- continuous
	%- apply flag
	for k=1:size(hdata.flag,3) %- ch loop
		data( hdata.flag(1,:,k)==1, k, :) = nan;
	end	
	%- calc mean
	mdata=squeeze(nan_fcn('mean',data(period, :,:), 1));%- [ch,kind]
	%- make tag strings [Kind_Ch%d], and Val
	tagStr={'Save Mean Results'};
    [f1 f2]=fileparts(hdata.TAGs.filename);
    Val{1} = f2(:);
	for k=1:length(hdata.TAGs.DataTag)
		for k1=1:size(mdata,1)%ch loop
			tagStr{end+1} = sprintf('%s_ch%d',hdata.TAGs.DataTag{k},k1);
            Val{end+1} = mdata(k1, k);
		end
    end
    %% - wirte to text file
    fid=fopen(filename,'a+');
	if fid==-1
		warndlg('File open error.','Save mean value to file');
		return;
	end	
    frewind(fid);
    tagInFile =fgetl(fid);
	fseek(fid,0,'eof');
    if ~strcmp(tagInFile,sprintf('%s\t',tagStr{:}))
		fprintf(fid,'%s\t',tagStr{:});
		fprintf(fid,'\n');
    end
    fprintf(fid,'%s\t',Val{1});
    fprintf(fid,'%f\t',Val{2:end});
    fprintf(fid,'\n');
    fclose(fid);
    
elseif ndims(data)==4 %- block
	%- apply flag to data
	blkNum=size(data,1);
	for k=1:blkNum %-block num loop
        data(k,:,hdata.flag(1,k,:)==1,:)=NaN;
    end
	%- calc mean value
	mdata=reshape(nan_fcn('mean', data(:, period, :,:),2),[size(data,1) size(data,3) size(data,4)]); %- [block, ch, kind]
	
	%- make tag string [Kind_B%d_Ch%d]
	tagStr={'Save Mean Results (Blocked)'};
	tagStr{2} = 'Block num';
    tagStr{3} = 'stim kind';
    
	[f1 f2]=fileparts(hdata.TAGs.filename{:});
	Val=[];
	for k=1:size(mdata,1)
		Val{k}{1} = sprintf('%s',f2);
		Val{k}{2} = k;
		Val{k}{3} = hdata.stimkind(k);
	end
    for k=1:length(hdata.TAGs.DataTag)%-kind
		for k1=1:size(mdata,2)%- ch loop
			tagStr{end+1} = sprintf('%s_ch%d',hdata.TAGs.DataTag{k},k1);
			for k2=1:size(mdata,1)
				Val{k2}{end+1} = mdata(k2,k1,k);
			end
		end
	end
	%% - wirte to text file	
	fid=fopen(filename,'a+');
	if fid==-1
		warndlg('File open error.','Save mean value to file');
		return;
	end
	frewind(fid);
	tagInFile =fgetl(fid);
	fseek(fid,0,'eof');
	if ~strcmp(tagInFile,sprintf('%s\t',tagStr{:}))
		fprintf(fid,'%s\t',tagStr{:});
		fprintf(fid,'\n');
	end
	for k=1:blkNum %- block loop
		fprintf(fid,'%s\t',Val{k}{1});
		fprintf(fid,'%f\t',Val{k}{2:end});
		fprintf(fid,'\n');
	end
    fclose(fid);
else
	warndlg('size of data is not supported.','Save Mean');
	return;
end
