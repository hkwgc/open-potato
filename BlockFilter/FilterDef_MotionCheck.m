function varargout=FilterDef_MotionCheck(mode, varargin)
%[Title] Function for motion-artifact detection by checking amplitude of signal changes
%[Originality] This function coded based on the study by Pena, et al. 
%[Related paper] gSounds and silence: An optical topography study of language recognition at birthh, Proc.Nat. Sci. 100 (2003) 11702-11705
% 
%In order to exclude measured data which containing motion artifact from signal analysis, this function set a flag when motion artifact were detected by checking amplitudes of signal changes. In the related paper, they set a flag when a difference of amplitude between two consecutive samples was higher than 0.1 mmol mm.
% 
%[Detailed Situations in the related paper]
%Participants:
%Fourteen healthy neonates (Italian, 2 to 5 days old)
%
%Experimental design: 
%Tests consisted of 10 blocks per condition, presented in random order: FW, BW, and silent control condition (see Fig. 1 in the related paper). 
%Each block contained 15 s of FW followed by 25-35 s of silence, 15 s of BW followed by 25-35 s of silence, or 15 s of silence followed by 25-35 s of silence. 
%The varying durations of the silent periods were introduced to avoid synchronization between stimuli occurrences and spontaneous oscillations.
%
%Measurement: 
%The Hitachi ETG-100 OT device records simultaneously from 24 channels on the cortex. 
%Channels mostly measure vascular changes from the surface of the cortex, that is, 2-3 cm below the scalp. 
%The ETG-100 emits infrared light at two wavelengths, 780 and 830 nm, through the fibers. 
%The intensity of each wavelength is modulated at different frequencies ranging from 1 to 6.5 kHz, and the total power output per fiber is 0.7 mW. 
%The reflected light is sampled once every 100 ms and is separated into two modulated signals, one for each wavelength, by a number of corresponding lock-in amplifiers. 
%After analog-to-digital conversion, the signals are transferred to a computer.


% Definition of OSP Filter of Motion-Check
%
%  FilterData = FilteDef_MotionCheck('getArgument',FilterData)
%     set Arguments of MotionCheck,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilteDef_MotionCheck('exe', ...
%                 FilterData, data, stimData);
%
% --- not defined -- in this version.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilteDef_MotionCheck('write', ...
%                 region, FilterData);
%
% region is write region
%   'Raw', 'HBdata' for continuous data.
%   'BlockData' for Block Data.
%
% filterData is Structure array of Filter Data
%   filterData.name    : Butter wortb  setting 
%   filterData.wrap    : Ppointer of the Function
%   filterData.argData : data of arguments 
%    argData
%          .HighpathFilter : Highpath filter for 
%                             Bandpath-Filter
%          .LowpathFilter  : Lowpath filter for
%                             Bandpath-Filter
%          .Criterion      : Criterion of Motion-Detect
%          .FilterType     : Filter-Type of MotionCheck
%          .DataKind       : Kind to use Motion-Check
%   where Bandpath perform check-data-temp.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
% See also FILTER_DEF_MOVINGAVERAGE, UC_MOTIONCHECK.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2005.06.20
% $Id: FilterDef_MotionCheck.m 333 2013-03-12 05:48:58Z Katura $
%


  switch mode
    case 'createBasicInfo'
      bi.Description='Motion-Check: cf) "Sounds and silence: An optical topography study of language recognition at birth", Proc Nat Sci 100(2003)11702-11706';
      varargout{1}=bi;
    % ================
   case 'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data
    if nargin>=3 && exist(varargin{2},'file'),
      mfile_pre = varargin{2};
    else,
      mfile_pre = '';
    end
    
    if isfield(data0, 'argData')
      data = data0.argData;
    else
      data =[];
    end

    % getArgument
    data = FD_MotionCheck_getArgument('argData',data, ...
				      'Mfile',mfile_pre);
    if isempty(data),
      data0=[];
    else,
      data0.argData=data;
    end
    varargout{1}=data0;

    % ================
   case 'exe'
    % ================
    error(['MotionCheck is not defined exe command.', ...
           'FilterDef_MotionCheck is for OSP version 1.50']);

    % ================
   case 'write',
    % ================
    region   = varargin{1};
    fdata    = varargin{2};
    data     = fdata.argData;

    % Header
    make_mfile('code_separator', 3);   % Level  3, code sep
    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' $Revision: 1.11 $']);
    make_mfile('code_separator', 3);  % Level  3, code sep .
    make_mfile('with_indent', ' ');

    if isnumeric(data.Criterion),
      crtrn = num2str(data.Criterion);
    else,
      crtrn = ['''' data.Criterion ''''];
    end

    %.. correct spell-miss..
    if isfield(data,'HighpathFilter'),
      data.HighpassFilter = data.HighpathFilter;
    end
    if isfield(data,'LowpathFilter'),
      data.LowpassFilter = data.LowpathFilter;
    end
    
    if isfield(data,'DataKind'),
      try,
	if isempty(data.DataKind(:)),
	  strkind='3';
	else,
	  strkind='[';
	  for k=data.DataKind(:)',
	    strkind=[strkind num2str(k) ' '];
	  end
	  strkind(end)=']';
	end
      catch
	strkind='3';
      end
    else,
      strkind='3';
    end

    % -- Main --
    make_mfile('with_indent', ...
	       sprintf('hdata = uc_motioncheck(data, %s, hdata, ...',strkind));
    d                        ='        ';
    d=sprintf('%5.2f,%5.2f,%s,[]', ...
        data.HighpassFilter, ...
        data.LowpassFilter, ...
        crtrn);
    
    if isfield(data,'FilterType') && ischar(data.FilterType)
        d = [d ',''FiltType'', ''' data.FilterType ''''];
    end
    if isfield(data,'DCInterval'),
        d = [d ',''DCInterval'', ' num2str(data.DCInterval) ];
    end
    d = [d ');'];
    make_mfile('with_indent', d);

    % -- Footer --
    make_mfile('with_indent', ' ');
    varargout{1}='';

   otherwise,
    error('Input Fnction is out-of-format.');
 
  end % switch

return;
