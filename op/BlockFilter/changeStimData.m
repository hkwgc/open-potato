function stimInfo = changeStimData(mode, stimInfo, varargin)
% Change Stimlation Data
%
%  stimInfo = changeStimData('Relaxing',stimInfo, st, ed, sz)
%    is change Relaxing period around Stimulation


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.02.15
% $Id: changeStimData.m 180 2011-05-19 09:34:28Z Katura $
%

  stimInfo = eval(['Local_' mode '(stimInfo, varargin{:})' ]);

return;

function stimInfo = Local_Relaxing(stimInfo,varargin)
  pre      = varargin{1};
  post     = varargin{2}; 
  time_len = varargin{3};

  if stimInfo.preStim ==pre && stimInfo.postStim ==post
    return;
  end

  stmdata = stimInfo.StimData;
  % StimKind
  for stkind = 1:length(stmdata)
    stt = stmdata(stkind).stimtime;
    % Stim Block
    for blk = 1:length(stt)
      % block start
      if stimInfo.preStim ~= pre
	stt(blk).iniBlock = stt(blk).iniStim -pre;
	if stt(blk).iniBlock < 1
	  stt(blk).iniBlock = 1;
	end
      end
      % block end
      if stimInfo.preStim ~= post
	stt(blk).finBlock = stt(blk).finStim + post;
	if stt(blk).finBlock > time_len
	  stt(blk).finBlock = time_len;
	end
      end
    end % Stim Block
    stmdata(stkind).stimtime=stt;
  end % StimKind

  stimInfo.StimData = stmdata;
  stimInfo.preStim =pre;
  stimInfo.postStim =post;
return;

  
