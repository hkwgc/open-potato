function varargout = nan_fcn(fcn, data,dim)
% NAN_FCN is wrapper for NAN Include Matrix
%
% NAN_FCN(FCN, DATA, DIM)
%    FCN is calculate function
%    DATA is NaN Include Matrix
%    Function along the dimension DIM of DATA
%    if there is no DIM, elements along
%    the first non-singleton dimension of
%    DATA
%
%    Available FCN:
%       'mean' : is as same as mean
%       'std0' : std, by (N -1 )
%       'std1' : std, by N
%
% -- Exanple --
% data=rand(3,6,2)
% data(data>0.5)=NaN
% nan_fcn('mean', data,3)


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: nan_fcn.m 180 2011-05-19 09:34:28Z Katura $

if nargin<2, error('Not enogh arguments');end

if nargin<3,
  dim = size(data);
  dim = find(dim~=1);
  if isempty(dim)
    dim=1;
  else
    dim = dim(1);
  end
end
sz = size(data);
if sz(dim) ==1, varargout{1}=data; return; end
if prod(sz)==0, varargout{1}=data; return; end

%== Check Data ==
dnan    = isnan(data);
datanum = sum(~dnan,dim);
% 2nd Output-Data is Number of Effective Data
if nargout>=2, varargout{2}=datanum;end
data2   = data;
data2(dnan)=0;

%== Average ==
mean_rslt=sum(data2,dim)./(datanum + (datanum==0));
mean_rslt(datanum==0)=NaN;

if strcmp(fcn,'mean'), varargout{1} = mean_rslt;return; end

% == Standerd devision ==
sz2=ones(size(sz)); sz2(dim)=sz(dim);
data3   = data - repmat(mean_rslt,sz2);
data3   = reshape(data3,sz); % for multiple

data3   = conj(data3).*data3;
data3(isnan(data3))   = 0;
data3   = sum(data3,dim);


switch fcn
  case 'std0'
    divtmp   = datanum -1;
    divtmp(divtmp<=0) = 1;
    std_rslt = sqrt( data3./divtmp );
    std_rslt(datanum==1) = 0;
    std_rslt(datanum==0) = NaN;
    varargout{1} = std_rslt; return;

  case 'std1'
    std_rslt = sqrt( data3./(datanum + (datanum==0) ) );
    std_rslt(datanum==1) = 0;
    std_rslt(datanum==0) = NaN;
    varargout{1} = std_rslt; return;

  otherwise,
    error(['Unknown fcn : ' fcn]);
end






