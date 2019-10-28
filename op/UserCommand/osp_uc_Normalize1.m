function data=osp_uc_Normalize1(data)
% Normalize data
% max(data)-min(data)=1

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



sz=size(data);

if ndims(data)==3 % continuous
	for i=1:sz(3)
		% data=data-mean(data)
		data(:,:,i)=data(:,:,i)-repmat(mean(data(:,:,i),1),[sz(1) 1 1]);
		% data=data/(max(data)-min(data))
		data(:,:,i)=data(:,:,i)./ ... 
			(repmat(max(data(:,:,i),[],1),[sz(1) 1 1])-repmat(min(data(:,:,i),[],1),[sz(1) 1 1]));
	end
	
elseif ndims(data)==4 % block
	for i=1:sz(4)
		% data=data-mean(data)
		data(:,:,:,i)=data(:,:,:,i)-repmat(mean(data(:,:,:,i),1),[sz(1) 1 1]);
		% data=data/(max(data)-min(data))
		data(:,:,:,i)=data(:,:,:,i)./ ... 
			(repmat(max(data(:,:,:,i),[],1),[sz(1) 1 1])-repmat(min(data(:,:,:,i),[],1),[sz(1) 1 1]));
	end
end
