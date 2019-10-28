function  varargout = patch_stim(original, type, varargin),
% PATCH_STIM produce patched stimulation.
%
% PATCH_STIM takes data containing difference and applies those
% differences to original stimulation, producing patched
% stimulation.
%
% Syntax :
%   [kind, stimtiming, sflag, idx] =
%      patch_stim(original, type, sflag, stim_diff);
%
%  Input Value:
%
%   *** original **
%     Original Stimulation Data.
%      Size  : [stim_number, 2]
%        Row : Stimulation - Timing ID
%        Col : 1st : Kind of Stimulation 
%              2nd : Stimulation Timing
%
%   *** type **
%     Stimulation Type
%      Size  : [1, 1]
%        1 : Event Type.
%        2 : Block Type.
%
% Syntax :
%   [kind, stimtiming, sflag, idx] =
%      patch_stim(original, type, stim_diff_flg);


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



  msg = nargchk(3, 4, nargin);
  if ~isempty(msg),error(msg); end

  % if original is stimTC,
  % change StimTC
  if size(original,2)~=2 || ...
	( size(original,1)==1 && any(original==0) )
    % Stim TC
    stim0    = find(original>0); stim0=stim0(:);
	original = original(:);
    original = [original(stim0), stim0];
  end


  % Argument Change
  switch length(varargin),
   case 1,
    tmp       = varargin{1};

    % callock
    sflag = false([size(original,1), size(tmp,2)-2]);
    stim_diff = zeros(size(original,1), 1);

    sflag(tmp(:,1),:) = tmp(:,3:end);
    stim_diff(tmp(:,1)) = tmp(:,2);
    
   case 2,
    % data format 
    if isstruct(varargin{1}),
      tmp   = varargin{1};
      chnum = varargin{2};
      sflag = false([size(original,1), chnum]);
      stim_diff = zeros(size(original,1), 1);
      for id=1:length(tmp),
	if tmp(id).shift~=0,
	  stim_diff(tmp(id).stim_id) = tmp(id).shift;
	end
	if ~isempty(tmp(id).flag),
	  sflag(tmp(id).stim_id,tmp(id).flag(:)) = true;
	end
      end
    else,
      sflag     = varargin{1};
      stim_diff = varargin{2};
    end

   otherwise,
    % can not be occure because of nargchk.
    error('Unknown Program Error');
  end
  stim      = original(:,2) + stim_diff;
  stim_kind = original(:,1);
  clear original stim_diff;

  idx      = [];
  stim_out = [];
  flag_out = [];
  kind_out = [];
  switch type,
   case 1
    idx = [1:size(stim,1)]';
    idx = [idx, idx];
    stim_out = [stim(idx(:,1)), stim(idx(:,2))];
    flag_out = sflag(idx(:,1),:);
    kind_out = stim_kind(idx(:,1));

   case 2
    % Block
    end_flg=0;
    for id = 1:size(stim,1),
      % Ignore Delete Stim
      if all(sflag(id,:)), continue; end

      % Making Pair
      if end_flg,
        if st_kind~=stim_kind(id),
          continue;
        end
        end_flg=0;
      else,
        end_flg=1;
        id0 = id;
        st_kind = stim_kind(id);
        continue;
      end

      % Makde Result;
      idx(end+1,:) = [id0, id];

      stim_out(end+1,:) = [stim(id0), stim(id)];
      flag_out(end+1,:) = sflag(id0,:) | sflag(id,:);
      kind_out(end+1)   = stim_kind(id);
    end
	kind_out = kind_out(:);
   otherwise,
    error('Stimulation Mode Error');
  end
  

  % Out put;
  if nargout>=1,
    varargout{1} = kind_out;
    if nargout>=2,
      varargout{2} = stim_out;
      if nargout>=3,
	varargout{3} = flag_out;
	if nargout>=4,
	  varargout{4} = idx;
	end
      end
    end
  end
    
