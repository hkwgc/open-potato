function  varargout = patch_stim2(original, type, varargin),
% PATCH_STIM2 produce patched stimulation and reduce.
%
% PATCH_STIM2 takes data containing difference and applies those
% differences to original stimulation, producing patched
% stimulation. After that, PATCH_STIM2 reduce stimmulation.
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



  [kind, stimtiming, sflag, idx] = patch_stim(original, type, varargin{:});
  use_idx=find(sum(sflag,2)~=size(sflag,2)); % remove index
  
  % Out put;
  if nargout>=1,
	  varargout{1} = kind(use_idx,:);
	  if nargout>=2,
		  varargout{2} = stimtiming(use_idx,:);
		  if nargout>=3,
			  varargout{3} = sflag(use_idx,:);
			  if nargout>=4,
				  varargout{4} = idx(use_idx,:);
			  end
		  end
	  end
  end
  
return;
