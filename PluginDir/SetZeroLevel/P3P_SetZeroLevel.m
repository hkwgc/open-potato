function data=P3P_SetZeroLevel(data,hdata,A)

if ndims(data)==4
	for i=1:size(data,1)
		for i1=1:size(data,4)
			% data(i,:,:,i1)=data(i,:,:,i1)-repmat(mean(data(i,A,:,i1)),[1 size(data,2) 1 1]);
      mv=nan_fcn('mean', data(i,A,:,i1),2);
      mv(isnan(mv))=0;
      data(i,:,:,i1)=data(i,:,:,i1)-repmat(mv,[1 size(data,2) 1 1]);
		end
	end
else
	for i1=1:size(data,3)
    %data(:,:,i1)=data(:,:,i1)-repmat(mean(data(A,:,i1)),[size(data,1) 1 1]);
    mv=nan_fcn('mean', data(A,:,i1),1);
    mv(isnan(mv))=0;
		data(:,:,i1)=data(:,:,i1)-repmat(mv,[size(data,1) 1 1]);
	end
end
