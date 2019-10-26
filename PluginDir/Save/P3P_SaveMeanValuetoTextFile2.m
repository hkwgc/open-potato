function hdata = P3P_SaveMeanValuetoTextFile2(hdata,data,A)
%-
%- version 1.1
%- 2011/02/02
%


%- open file
fid=fopen(A.filename,'a+');
if fid==-1
	warndlg(sprintf('Can not open the file, \n%s\nIs the file closed?',A.filename),'Save mean value to file');
	return;
end
frewind(fid);
tagInFile =fgetl(fid);
fseek(fid,0,'eof');

%- prepare data
if ndims(data)==3 %- continuous
	%- select kind
	data = data(:,:,A.kind);
	%- apply flag
	for k=1:size(hdata.flag,3) %- ch loop
		data( hdata.flag(1,:,k)==1, k) = nan;
	end	

	%- make data value
	tagStr={'Save Mean Results ver. 1.0'};
	[f1 f2]=fileparts(hdata.TAGs.filename);
	Val{1} = f2(:);
	for k_List = 1:length(A.periodList)
		%- calc mean
		MPeriod = subLst2Vec(A.periodList{k_List},hdata);
		mdata=squeeze(nan_fcn('mean',data(MPeriod, :), 1));%- [ch]
		%- change channel order?
		if (A.cbxChOrder)
			cho=eval(A.ChOrderVal{1});
		else
			cho=1:length(mdata);%ch loop
		end
		%- make tag strings [ch%d], and Val
		for k1=cho
			tagStr{end+1} = sprintf('ch%d [%s]',k1,A.periodList{k_List});
			Val{end+1} = mdata(k1);
		end
		tagStr{end+1}='';		Val{end+1} = '';
	end
	% - wirte to text file
	subWriteToFile(fid, Val, tagStr, tagInFile);
	fclose(fid);

%===============****************************
elseif ndims(data)==4 %- block
	%- select kind
	data = data(:,:,:,A.kind);
	%- apply flag to data
	blkNum=size(data,1);
	for k=1:blkNum %-block num loop
		data(k,:,hdata.flag(1,k,:)==1)=NaN;
	end
	
	%TODO: check STIM KIND! !!!!!

	%- change channel order?
	if (A.cbxChOrder)
		cho=eval(A.ChOrderVal{1});
	else
		cho=1:size(data,3);
	end
	
	%- make tag string [_Ch%d]
	tagStr={'Save Mean Results (Blocked) ver. 1.0'};
	tagStr{2} = 'Block num';
    tagStr{3} = 'stim kind';
	tagStr{4} ='ID';
	for k=cho
		tagStr{end+1}=sprintf('ch%d',k);
	end

	if (length(hdata.TAGs.filename)>1)
		f2='Multi files';
	else
		[f1 f2]=fileparts(hdata.TAGs.filename{:});%- make tag
	end
	
	%- loop start ---
	ValALL=[];
	for k_List =1:length(A.periodList) %- first loop: period list
		
		%- make cell array
		Val=[];
		if (A.cbxAOT) %- average over trials
			Val{1,1} = sprintf('%s: %s',f2,A.periodList{k_List});
			Val{1, 2} = sprintf('Ave. over %d trials',blkNum);
			Val{1, 3} = 'all';
			Val{1, 4} = hdata.TAGs.ID_number{1};
		else
			for k=1:blkNum
				Val{k, 1} = sprintf('%s: %s',f2, A.periodList{k_List});
				Val{k, 2} = k;
				Val{k, 3} = hdata.stimkind(k);
				Val{k, 4} = hdata.TAGs.ID_number{1};
			end
		end
		
		if (A.cbxOption)
			if (A.ppmOption == 1) %- SD( AVE(trial) time)
				s = 'SD( AVE(trial) time)';				
			else %- SD( AVE(time) trial)
				s = 'SD( AVE(time) trial)';
			end
			Val{end+1,1}=cell(1,4);
			Val{end, 1} = sprintf('%s:[SD] %s',f2, A.periodList{k_List});
			Val{end, 2} = s;
			Val{end, 3} = 'all';
			Val{end, 4} = hdata.TAGs.ID_number{1};
		end
	
		%- make Value
		%- calc mean value
		MPeriod = subLst2Vec(A.periodList{k_List},hdata);
		mdata=nan_fcn('mean', data(:, MPeriod, :),2);
		mdata=reshape(mdata, [size(data,1) size(data,3) ]); %- [trial, ch]
		
		if  (A.cbxAOT) %- average over trials***
			mdata = nan_fcn('mean', mdata, 1); %- ave (trial)			
			for k1=cho%- ch loop
				Val{1, 4+k1}=mdata(1,k1);
			end
		else %- each trials***
			for k1=cho%- ch loop
				for k2=1:blkNum%- trial loop
					Val{k2, 4+k1} = mdata(k2,k1);
				end
			end			
		end
	
		%- calc SD check
		if (A.cbxOption)
			if (A.ppmOption == 1)  %- SD( AVE(trial) time)
				tmp=nan_fcn('mean', data(:, MPeriod, :),1); %- AVE(trial)
				tmp=squeeze(tmp);%-[time ch]		
				v = nan_fcn('std0', tmp, 1); %- SD( time )
			else %- SD( AVE(time) trial)				
				tmp=nan_fcn('mean', data(:, MPeriod, :),2); %- AVE(time)
				tmp=squeeze(tmp);%-[trial ch]		
				v = nan_fcn('std0', tmp, 1);%- SD( AVE(time) trial)
			end
			for k1=cho%- ch loop
				Val{end, 4+k1}=v(k1);
			end
		end
		
		if isempty(ValALL)
			ValALL=Val;
		else
			ValALL = cat(1,ValALL, Val);
		end
	end
	
	
	
% 	----------------------------
% 	% Ave oer Trial
% 	if (A.cbxAOT) && (A.cbxOption) && (A.ppmOption == 1 ) %- std(ave(trial) time)
% 			data = nan_fcn('mean',data, 1); %- [1 time ch]
% 	end
% 			
% 	%- make tag
% 	[f1 f2]=fileparts(hdata.TAGs.filename{:});
% 	Val=[];
% 	for k=1:size(data,1)
% 		Val{k}{1} = sprintf('%s',f2);
% 		Val{k}{2} = k;
% 		Val{k}{3} = hdata.stimkind(k);		
% 		Val{k}{4} = hdata.TAGs.ID_number{1};
% 	end
% 	if (A.cbxAOT) && (A.cbxOption)
% 		Val{k+1}{1} = sprintf('%s',f2);
% 		Val{k+1}{2} = 'SD';
% 		str={'SD ( Ave ( trila ) time )',' SD ( Ave (time) trial)'};
% 		Val{k+1}{3} = str{A.ppmOption};
% 		Val{k+1}{4} = '';
% 	end
% 	
% 	%- make Val
% 	for k_List =1:length(A.periodList)
% 		%- calc mean value
% 		MPeriod = subLst2Vec(A.periodList{k_List},hdata);		
% 		mdata=nan_fcn('mean', data(:, MPeriod, :),2);
% 		mdata=reshape(mdata, [size(data,1) size(data,3) ]); %- [block, ch]
% 		
% 		if  (A.cbxAOT) 
% 			if ~(A.cbxOption) || (A.ppmOption == 2) %- std(ave(time ) trial)
% 				%mdata = nan_fcn('mean', mdata, 1); %- ave (trial)
% 				sdata = nan_fcn('std0',nan_fcn('mean', mdata, 1),1); %- [1 ch]
% 			else %- std(ave(trial) time)
% 				sdata = nan_fcn('std0',data(:, MPeriod, :),2); %- [1 1 ch]
%                 sdata = reshape(sdata,[1 length(sdata)]); %- [1 ch]
% 			end
% 		end
% 
% 		%- change channel order?
% 		if (A.cbxChOrder)
% 			cho=eval(A.ChOrderVal{1});
% 		else
% 			cho=1:size(mdata,2);
% 		end
% 		for k1=cho%- ch loop
% 			tagStr{end+1} = sprintf('ch%d',k1);
% 			for k2=1:size(mdata,1)%- block loop
% 				Val{k2}{end+1} = mdata(k2,k1);
% 			end
% 			if (A.cbxAOT) && (A.cbxOption) 
% 				Val{k2+1}{end+1} = sdata(k1);
% 			end
% 		end
% 		%- separater
% 		tagStr{end+1}='';	
% 		for k2=1:length(Val)
% 			Val{k2}{end+1} = '';
% 		end
% 	end
	
% 	%- Option] Average over trials?
% 	if (A.cbxAOT)
% 		tmp=zeros(length(Val), size(mdata,2));
% 		for k=1:length(Val)
% 			tmp(k,:) = cell2mat(Val{k}(4:4+21));
% 		end
% 		tmp=cat(1,Val{:}{2:end});
% 		Val = nan_fcn('mean', tmp, 1);
% 	end
	% - wirte to text file
	%subWriteToFile(fid, Val, tagStr, tagInFile)
    subWriteToFile(fid, ValALL, tagStr, tagInFile)
    fclose(fid);
	
else
	warndlg('size of data is not supported.','Save Mean');
	return;
end

%===============================
function n=subLst2Vec(s,hdata)

n0=sscanf(s,'%f to %f');
n0 = n0 * 1000/ hdata.samplingperiod;
n0=round(n0);
if max(n0) > size(hdata.stimTC,2)
	errordlg(sprintf('Function: %s\nERROR: %s','Save Mean Value to File 2','Averagin period is too long.'),'Plugin function error');
	return;
end	
if n0(1)==0
	n0(1)=1;
end

n=n0(1):n0(2);


%
function subWriteToFile(fid, Val, tagStr, tagInFile)
if ~strcmp(tagInFile,sprintf('%s\t',tagStr{:}))
	fprintf(fid,'%s\t',tagStr{:});
	fprintf(fid,'\n');
end
if ndims(Val)==1
	fprintf(fid,'%s\t',Val{1});
	fprintf(fid,'%f\t',Val{2:end});
	fprintf(fid,'\n');
else
	for k=1:size(Val,1) %- block loop
		for k1=1:size(Val,2)
			if ischar(Val{k, k1})
				fprintf(fid,'%s\t',Val{k, k1});
			else
				fprintf(fid,'%f\t',Val{k, k1});
			end
		end
		fprintf(fid,'\n');
	end
end

