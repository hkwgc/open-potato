function [data, header] = ot2ucdata(data,varargin);
%
% Syntax: Read from OT-Data, Signal-Data, before version 1.0
%  [data, header] = uc_dataload(OT_LOCAL_DATA),
%    Input:
%     OT_LOCAL_DATA : OT format data
%    Output:
%    data      : User-Command Continuous Data.
%    header    : Header of User-Command Continuous Data.
%
% See also OT_DATALOAD, UC_DATALOAD.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.12.21
% $Id: ot2ucdata.m 180 2011-05-19 09:34:28Z Katura $


% Reversion 1.2
%   Add Position.
%
% Revision 1.3
%   Nostimulation Data to set Dummy code
%
% Revision 1.4
%   Add StimMode

  % data=OSP_LOCALDATA; clear OSP_LOCALDATA;
  sz=size(data.HBdata);

  % Stim Information
  stim0 = data.info.stim;
  stimI = find(stim0~=0);
  if isempty(stimI),
	  warning('No Stimulation Data, set dumy stimulation at start and end');
	  stim0([1,end])=1;
	  stimI=[1; size(stim0,1)];
  end
  header.stim     = [stim0(stimI), stimI, stimI];

  header.stimTC   = stim0';
  header.StimMode = 1;
  %-----------------------
  % Stim Transfer : Block 
  %    since Revision 1.4
  %-----------------------
  % since Revision 1.4
  if isfield(data.info,'StimMode') && ...
          data.info.StimMode==2,
      [header, ecode] = uc_makeStimData(header,2);
  end

  % Using Flag, (kind, time, channel)
  header.flag     = false([1, sz(1), sz(2)]);

  % other using Data
  header.measuremode    = data.info.measuremode;
  header.samplingperiod = data.info.sampleperiod;

  header.TAGs          = data.info;
  header.TAGs.DataTag  = data.HBdata3Tag;

  % --> Change data-->data
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
      'measuremode', [' Measure Mode of ETG'], ...
      'samplingperiod', 'sampling period [msec]', ...
      'TAGs', ['Other Data'], ...
      'MemberInfo', ['This Data, Header fields Information']);
  header.MemberInfo = MemberInfo;

  %============================
  % From Here : Extend Properties
  %============================
  
  for id=2:length(varargin),
    tmp = varargin{id-1};
    dt  = varargin{id};
    switch tmp,
      case 'Position',
       % --- Position ----
       % if exist('Position','var'),
       %   header.Pos = Position;
       % end
       header.Pos=dt;
       header.MemberInfo.Pos='Position of Channel';
     otherwise,
      warning(sprintf(['OT2UCDATA : %s\n' ...
		       '   Input Property(%s) is Undefined\n'], tmp));
    end
  end

  % == View ==
  if ~isfield(header,'VIEW'),
    % set Deafult View Data == ::: ==
    % TODO: 05-Jan-2006 : require
    %       See also Signal-Viewer
    % --> Change View Option
    %     :: 
  end
  

return;
