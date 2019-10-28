function [hd, ecode] =uc_makeStimData(hd, mode)
% Change OSP UserCommand Stimulation Information
%
% Syntax :
%  [hd, ecode] =uc_makeStimData(hd, mode)
%
% -- Input --
%  hd      : Header of UserCommand Data-Type
%            stim is vector, that length is size(HB-Data,1)
%
%  mode    :  Stimulation mode (1: Event , 2: Block )
%
% -- Output --
%  hd      : Header of UserCommand Data-Type
%            that stim and StimMode is remake.
%            where stim     : Stimulation Start & End matrix
%                  StimMode : Stimulation mode
%
%  ecode    : bit 1 : Nunber of Sets Error
%             bit 2 : Block StimKind is differ
%                     Remove Some Data-Sets
%
% Example: if hd is UserCommand Header
%      hd = uc_makeStimData(hd,2)
%   Remake Event stim Data
%
% === Warning ==
% This function make header.stim
% ( header : header of Continuous User Command)
% from header.stimTC.
% but to Modify block, this function is not proper.
%
% So This function will be Removing soon.
% Use uc_changeStimData instead of this function.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : ?
% $Id: uc_makeStimData.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.3
%   I want to Removing soon, but I cannot...

%   msg = sprintf(['OSP version 1.50 Warning!!!\n' ...
% 		 ' >> This Function (%s) will be\n' ...
% 		 ' >>  Removing soon!\n' ...
% 		 ' >>  To see futer details,\n' ...
% 		 ' >>  open releace note\n'], ...
% 		mfilename);
%   warning(msg);

% Initialize
ecode=0;   % Continuable Error
if nargin < 2
  mode = hd.StimMode;
else
  hd.StimMode=mode;
end

% ========= Make Essence Data ===========
stim=hd.stimTC(:);     % Confine Vector
stim=[[1:length(stim)]' stim];

% Remove 0 Data
stim(stim(:,2)==0,:)=[];

if mode == 1  % Event
  if isempty(stim)
    error(' Cannot make Stimulation Data : No Stimulation exist!');
  end
  hd.stim = [stim(:,2), stim(:,1), stim(:,1)];
  return;
end

% ========= CHECK SET-CHECK ===========
if mode == 2  % Block Data
  % Number of Data Check
  if bitget(size(stim,1),1)==1, % Stim Number is Odd?
    stim(end,:)=[];
    ecode = bitset(ecode,1); % Ecode = 1
  end
  npair0 = diff(stim(:,2));     % Different StimKind Check
  npair0(2:2:size(npair0,1))=0; % Ignore neborhoot Block, set 0
  npair0 = find(npair0~=0);     % Find Different Kind Set Block
  if ~isempty(npair0)
    npair0 = [npair0; npair0+1]; % Error Block [start, end]
    stim_1=stim;
    stim(npair0(:),:)=[];
    ecode = bitset(ecode,2); % Ecode = bit 2 is 1
  end

  if ecode~= 0
    warning(' Stimulation Pair Error : Delete Some Pairs');

    if bitget(ecode,2)
      %   Print Ignore Data
      npair0 = sort(npair0);
      figure;
      ax_h = axes;
      hold on;grid on;
      h = plot(hd.stimTC(:),'b-');
      set(h,'Tag', 'Original Stimulation Point', ...
        'LineWidth', 0.1);
      if exist('stim_1','var'),
        h = plot(stim_1(npair0,1), stim_1(npair0,2),'rx');
        set(h,'Tag', ' Ignore Stimulation Point', ...
          'MarkerSize', 7);
      end
      axis tight
      legend(ax_h, ...
        ' Original Stimulation Point', ...
        ' Ignore Stimulation Point');
      title('  ---- Ignore Stimulation Data ----  ');
      xlabel(' Stimulation Timing [ sampling-time-unit]');
      ylabel(' Stimulation Kind');
      clear stim_1;
    end
  end
  clear npair0 stim0;

  % check
  if isempty(stim)
    error(' Cannot make Stimulation Data : No Stimulation exist!');
  end

  % ========== Make Stimdata =============
  % now,  stim is [timing, kind]
  hd.stim = [stim(1:2:end,2), stim(1:2:end,1), stim(2:2:end,1)];
  return;
end




