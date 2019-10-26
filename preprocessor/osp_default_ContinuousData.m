function [hdata,data]=osp_default_ContinuousData(varargin)
% get Default OSP - Continuous Data
% 
% Syntax :
%   [hdata,data]=default_OSP_UD_ContinuousDat


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% --> Argument Get <--
if mod(nargin,2)~=0,  error('Argument Error : Argument Must be ..'); end
for idx=2:2:nargin,
  eval([varargin{idx-1} '=varargin{idx};']);
end
% Data
if ~exist('data','var')
  data=zeros([0, 0, 3]);
end

% Stimulation Mark's
minfo.stim        = 'Stimulation Data, (Number of Stimulation, [kind, start, end])';
hdata.stim        = zeros([0,3]);
minfo.stimTC      = 'Stimulation Timeing, (1, time)';
hdata.stimTC      = zeros([0,3]);
minfo.stimMode    = 'Stimulation Mode, 1:Event, 2:Block';
minfo.StimMode    = 'Stimulation Mode, 1:Event, 2:Block';
hdata.StimMode    = 1;

% User/Unuse Flag
minfo.flag        = 'Flags, (kind, time, ch),   Now kind is only one, if 1, then Motion occur';
hdata.flag        = false([1,size(data,1),size(data,2)]);

% Position 
minfo.measuremode = ' ID of Shape of Probe. See Also time_axes_position.';
hdata.measuremode = 199; % unknown :: %Use -1 for special when you have Pos Data

%  Sampling Period
minfo.samplingperiod = 'sampling period [msec]';
hdata.samplingperiod = 100;

% Other
minfo.TAGs= 'Other Data';
hdata.TAGs.pathname     = '';
hdata.TAGs.pathnametag  = {'path name of original data in this PC'  'strings'};
hdata.TAGs.filename     = '';
hdata.TAGs.filenametag  = {'file name of original data in OT system'  'strings'};
hdata.TAGs.ID_number    = '';
hdata.TAGs.ID_numbertag = {'ID number'  'strings'};
hdata.TAGs.age          = -1;
hdata.TAGs.agetag       = {'a vector of age'  'age-number'};
hdata.TAGs.sex          = 0;
hdata.TAGs.sextag       = {'sex-1:female,2:male'  'number'};
hdata.TAGs.DataTag      = {'Oxy','Deoxy','Total'};

% Date
hdata.TAGs.date = now;
hdata.TAGs.datetag        = {'measurement date', 'Date Number'};
% Subject Name
hdata.TAGs.subjectname	  = 'somebody';
hdata.TAGs.subjectnametag	  = {'subject name', 'strings'};
  

% Member Info
minfo.MemberInfo= 'This Data, Header fields Information';
hdata.MemberInfo= minfo;

