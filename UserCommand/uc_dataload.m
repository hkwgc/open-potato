function [data, header] = uc_dataload(varargin)
% Read OT data and make User-Command-Data.
%   Getting User-Command-Data is Continuous one.
%
% Syntax: Read from OT-Data, Signal-Data, before version 1.0
%  [data, header] = uc_dataload(filename, datapath);
%    Input:
%     filename : File name of read-function.
%     datapath : Path to the File.
%    Output:
%    data      : User-Command Continuous Data.
%    header    : Header of User-Command Continuous Data.
%
% See also OT_DATALOAD.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.04.14
% $Id: uc_dataload.m 180 2011-05-19 09:34:28Z Katura $

msg = nargchk(1,2,nargin);
if ~isempty(msg), error(msg); end

% Load Signal-Data from..
if nargin==2,   % Now always, See also NARGCK.
  % from File
  fname    = varargin{1};
  datapath = varargin{2};
  data = ot_dataload(fname, datapath,7);
  sz = size(data.HBdata);
elseif nargin==1, % Load - OSP version 1.0 Signal Data,
  fname    = varargin{1};
  % we accept Position,
  % load(fname,'OSP_LOCALDATA');
  load(fname);
  if ~exist('OSP_LOCALDATA','var'),
    switch OSP_SP_DATA_VER,
      case 1,
      case 2,
        % OSP Version 2
        % There is header & data
        return;
      case 3,
        return;
    end % End Switch
  end % End if
  data=OSP_LOCALDATA; clear OSP_LOCALDATA;
  sz=size(data.HBdata);
end

% Stim Information
stim0 = data.info.stim;
stimI = find(stim0~=0);
header.stim     = [stim0(stimI), stimI, stimI];
header.stimTC   = stim0';
header.StimMode = 1;

% Using Flag, (kind, time, channel)
header.flag     = false([1, sz(1), sz(2)]);

% other using Data
header.measuremode    = data.info.measuremode;
header.samplingperiod = data.info.sampleperiod;

header.TAGs          = data.info;
header.TAGs.DataTag  = data.HBdata3Tag;

data = data.HBdata;

% Member Info
MemberInfo = struct( ...
  'stim', ['Stimulation Data, ' ...
  '(Number of Stimulation, ' ...
  '[kind, start, end])'], ...
  'stimTC', ['Stimulation Timeing, ' ...
  '(1, time)'], ...
  'StimMode', ['Stimulation Mode, ' ...
  '1:Event, 2:Block'], ...
  'flag',    ['Flags, (kind, time, ch),  ' ...
  ' Now kind is only one, if 1, then Motion occur'], ...
  'measuremode', ' Measure Mode of ETG', ...
  'samplingperiod', 'sampling period [msec]', ...
  'TAGs', 'Other Data', ...
  'MemberInfo', 'This Data, Header fields Information');
header.MemberInfo = MemberInfo;

if exist('Position','var'),
  header.Pos = Position;
end

return;
