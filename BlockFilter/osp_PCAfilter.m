function data = osp_PCAfilter(data, usecmp)
% OSP PCA Filter : 
%  data is HB data


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


  % Check Data size
  sz = size(data);
  if ndims(data)==2
    sz(3)=1;
  end

  % --- usecomp check ----
  usecmp = round(usecmp);
  ov = find(usecmp>sz(2));
  if ~isempty(ov)
    error('Use Channel Number is so large');
  end
  ov = find(usecmp<= 0);
  if ~isempty(ov)
    error('Use Channel Number must be positive');
  end
  

  % HB Kind Loop
  % -- malloc
  b   = zeros(sz(2), sz(1));
  b2  = zeros(sz(2), sz(1));
  z   = zeros(sz(2),sz(2));
  PC  = zeros(sz(1),sz(2));
  PC2 = zeros(sz(1),sz(2));

  for kind = 1:sz(3)
    b = squeeze(data(:,:,kind))';
    mb = repmat(mean(b,2), 1,size(b,2)); % Mean-value of b2 
    b2 = b - mb;
    z=b2*b2';   % Variance-Covariance Matrix

    % Now U is sort by ascending order,
    %    so use flipud
    [w0 U]=eig(z);
    PC=w0'*b2;        % ?? I don't know reason of transpose,
    PC=flipdim(PC,1);

    PC2=zeros(size(PC));
    PC2(usecmp,:)=PC(usecmp,:);
    PC2=flipdim(PC2,1);
    
    data(:,:,kind) = (w0*PC2 + mb)';
  end
  

