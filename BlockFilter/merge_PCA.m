function [header, data]=merge_PCA(header,data)
%  [header, data]=merge_PCA(header,data)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


sz = size(data);
if (size(sz,2)<=2),
	sz(3)=1;
end

try,
	tag = header.TAGs.DataTag;
catch,
	tag = {};
	for id=1:sz(3),
		tag{end+1}=num2str(id);
	end
end

% HB Kind Loop
lkind = sz(3);
PC=zeros(sz(2),sz(1));
PC2=zeros(sz(2),sz(1));
%for kind = lkind:-1:1, % for Allocate cost,
for kind=1:lkind
	b = squeeze(data(:,:,kind))';
	mb = repmat(mean(b,2), 1,size(b,2)); % Mean-value of b2
	b2 = b - mb;
	z=b2*b2';   % Variance-Covariance Matrix
	
	% Now U is sort by ascending order,
	%    so use flipud
	[w0 U]=eig(z);
	% Score
	PC=w0'*b2;        % as same as w0
	PC=flipdim(PC,1);
	
	% Change Output Format -->
	%   Mail 2006.02.21
	if 0,
		% output format (-- before 2006.02.21)
		for usecmp=sz(2):-1:1,
			PC2(:)=0;
			PC2(sz(2)-usecmp+1,:)=PC(usecmp,:);
			data(:,:,lkind+(kind-1)*sz(2)+usecmp) = (w0*PC2 + mb)';
			tag{lkind+(kind-1)*sz(2)+usecmp} = [num2str(usecmp) 'stPC ' tag{kind}];
		end
	else		
		% output format (-- since 2006.02.21)
		data(:,:,lkind+kind)=PC';
		tag{lkind+kind}=['PCA(Score) ' tag{kind}];
		S=POTATo_sub_CheckVarName(tag{kind});
		eval(sprintf('header.Results.PCA.Eigenvalues.%s=diag(U);',S));
		%header.Results.PCA.Eigenvector{kind}=w0;
		for k=1:size(w0,1)
			eval(sprintf('header.Results.PCA.Eigenvector.%s.PC%d=w0(:,k);',S,k));
		end
	end %
end

	try,
		header.TAGs.DataTag=tag;
	catch,
		header=[];
	end
