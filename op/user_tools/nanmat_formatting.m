function [matout, varargout]=nanmat_formatting(matin,method,varargin)
% NaN Include Matrix formatting function
%
% -----------------------
%  [MATOUT, FLG] = nanmat_formatting(MATIN, 'CutOff', N)
%      Cut off NaN-include Matrix data from MANIN along 
%      N dimension. 
%      Return value, MATOUT is result of formatting.
%      FLG is FLAG of CutOff data-index along N dimension.
%
%      example:
%         tmp = [  0,   1,   2, NaN; 
%                  1,   2,   3,   4; 
%                  2, NaN,   4, NaN];
%
%         [tmp1, flg]= nanmat_formatting(tmp,'CutOff',1);
%
%         Returns
%            tmp1 = [1,   2,   3,   4];
%            flg  = [1;
%                    0;
%                    1];
% 
%         [tmp1, flg]= nanmat_formatting(tmp,'CutOff',2);
%
%         Returns
%            tmp1 = [0, 2;
%                    1, 3;
%                    2, 4];
%            flg  = [0; 1; 0; 1];
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: nanmat_formatting.m 180 2011-05-19 09:34:28Z Katura $

  msg = nargchk(2,100,nargin);
  if ~isempty(msg), error(msg);end

  switch method
   case 'CutOff'
    % ************** Cut Off **************
    if nargin<3
      N=1;
    else
      N=varargin{1}; N=round(N);
    end
    if ~isnumeric(N) || length(N)~=1 || ...
	  0>N || N>ndims(matin)
      error('Input Argument N must be Numerical scololarr')
    end
    nandata=isnan(matin);

    sz=size(matin);
    matout=matin; clear matin;

    % make exe and check  command
    %
    % if ndims(matin)==3 and N=2, then
    % 
    %   exe =      'matout(:,idx,:)=[];';
    %   chk = 'any(nandata(:,idx,:))';
    exe=[ 'matout(' ];
    chk=[ 'any(nandata(' ];
    for idim = 1:size(sz,2),
      if idim==N,
	exe=[exe 'idx, '];
	chk=[chk 'idx, '];
      else
	exe=[exe ':, '];
	chk=[chk ':, '];
      end
    end
    chk(end-1)=')';chk(end)=')';
    exe(end-1)=')';
    exe = [exe '= [];'];

    % removing 
    flg = repmat(logical(0),sz(N),1);
    for idx = sz(N):-1:1,
      if eval(chk), eval(exe);  flg(idx)=logical(1); end
    end
    if nargout>=1
      varargout{1}=flg;
    end
    
   otherwise
    error([method ' is an invalid method.']);
  end
