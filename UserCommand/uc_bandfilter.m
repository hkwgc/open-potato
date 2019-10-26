function [data, hdata] = uc_bandfilter(data,  hdata, ...
  highpath, lowpath, varargin)
% BANDFILTER call Buttorworth
%               from OSP HB-Raw Data
%
% == Syntax ==
% header = uc_bandfilter(data, hb_kind, ...
%			       highpass, lowpass )
%			       
%   --- Input Data --
%   data   : 3 dimensional HB Data
%            time x channel x HB-Kind
%
%  header   : header of data
%
%  highpass  : High-Pass for Band-pass filter
%              Input by [Hz]
%
%  lowpass   : High-Pass for Band-pass filter
%              Input by [Hz]
%
%
% - -- Output Data --
%  header :  Changed header
%             If we detect motion at Channel in each block,
%             change Using Flag in stimInfo zero.
%
%
% Detecting Method : 
%   1. smothing by using Band-Pass-Filter
%
% == Syntax ==
% @since 1.7
% [header, hs, cdata0, f0] = uc_bandfilter(data, stimInfo, hb_kind, ...
%			        highpath, lowpath, ...
%                   'PropertyName', PropertyValue, ....);
%
%  Propert-Name | Variable-Type| explain
%   FiltType    'fft'
%               'bpf'          BandPassFilter
%               'bsf'          Band StopFilter
%               'hpf'          HighPassFilter
%               'lpf'          LowPassFilter
%
%   Add More Properties.
%   
%
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% == History ==
% Original
%  -> Import uc_motioncheck , 2006.11.24


%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===== Initiarize =======
%%%%%%%%%%%%%%%%%%%%%%%%%%
%=========================
% ===== Read Argument ====
%=========================
% Read Value
msg=nargchk(4,20,nargin);
if ~isempty(msg), error(msg);end
% sampling period
smpl_pld = hdata.samplingperiod;
highpath = max(highpath(:));
lowpath  = min(lowpath(:));
ff       = '';
filttype='fft'; % Default Value
dim=5;          % Default Value

% Set Optional Data
for idx=2:2:length(varargin),
  % Property Name ?
  if ~ischar(varargin{idx-1}),
    warning('Bad Property Name');
    continue;
  end
  % Property Name Switch
  switch lower(varargin{idx-1})
    case 'filterfunction'
      ff=varargin{idx};
    case 'filttype',
      % Filter Type Check
      tmp=varargin{idx};
      if iscell(tmp),tmp=tmp{1};end
      if ~ischar(tmp),
        warning('Bad Value for FilterType');continue;
      end
      ftstr={'fft','bpf','bsf','hpf','lpf'};
      s=find(strcmpi(ftstr,varargin{idx}));
      if ~isempty(s),
        filttype=ftstr{s(1)};
      else,
        warning('Bad Value for FilterType');
      end
    case 'dimension',
        dim=varargin{idx};
    otherwise,
      warning(['No such a Property : ' varargin{idx-1}]);
  end % Property Name Switch
end % Read Argument

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===== Band Filtering ==========
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(ff,'FFT')
  filttype='fft';
end
switch filttype
  case 'fft',
    % === Preprocessing : FFT Filtering ===
    data = ot_bandpass2(data, highpath, lowpath, ...
      1, smpl_pld/1000, 1,'time');
  case {'bpf', 'bsf', 'hpf', 'lpf'},
    % === Preprocessing : Butter worth Distal Filtering ===
    if ~exist('butter', 'file'),
      warning(' * No butter exist');
    else
      [b,a]=ot_butter(highpath(1), lowpath(1), ...
        1000/smpl_pld, dim, filttype);
      data=ot_filtfilt(data, a , b, 1);
    end 
  otherwise,
    % === Never Occure..
    error('No such a Filter Type!');
end

return;
