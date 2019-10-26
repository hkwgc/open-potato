function varargout = PlugInWrap_MotionCheck_Wavelet(fcn, varargin)
% Title: Function for motion-artifact detection using wavelet analysis
% Originality: This function coded based on the study by Sato et al. 
% Related paper: ÅgWavelet analysis for detecting body-movement artifacts in optical topography signalsÅh, 
%                 NeuroImage 33 (2006) 580-587
% 
% 
% In order to exclude measured data which containing motion artifact from signal analysis, 
% this function set a flag when motion artifact were detected by calculations. 
% The detail of the calculations for detection of motion artifact using 
% wavelet analysis will be found in the related paper.
% 
% 
% Detailed Situations in the related paper:
%  Subject: Nine healthy neonates (four males and five females, 4.33 days old (SD=1.80) 
% Experimental design: 25 rest periods and 24 stimulation periods one after the other (Total 14-15 min). 
%                      The rest period were randomized between 20 and 30 s, and the stimulus periods were fixed at 10 s. 
% 					 In the stimulus periods, speech sounds were presented.
%  Measurement: OT system (modified version of model ETG-7000, Hitachi Medical Corporation, Japan) 
%             that can image a whole brain area with 72 measurement positions.
%             The system simultaneously irradiates light at wavelengths of 690 and 830 nm through 
%             an optical fiber to one point. Optical fibers were fixed onto a probe cap,
%             which was mounted at the head of the bed to enable it to be placed on the neonateÅfs head 
%             without awakening him or her. The transmitted light was detected every 100 ms with 
%             an avalanche photodiode through an optical fiber located 30 mm from the incident position. 
%             Optical fibers were used for both irradiating and detecting the lights. 
%             The average power of each light source was 1.5 mW, and each source was modulated 
%             at a distinctive frequency (1?10 kHz) to enable separation by using a lock-in amplifier after detection.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

%======== Launch Switch ========
  if strcmp(fcn,'createBasicInfo'),
    varargout{1} = createBasicInfo;
    return;
  end

  if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{:});
  else,
    feval(fcn, varargin{:});
  end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo,
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  basicInfo.name   = 'Motion Check [ Wavelet ]';
  basicInfo.region = [3];
  DefineOspFilterDispKind;
  basicInfo.DispKind=F_Flag;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data0=getArgument(varargin),
% % Do nothing in particular
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data0 = varargin{1}; % Filter Data
  if isfield(data0, 'argData')
    % Use Setting Value.
    % ( Change )
    data = data0.argData;
  else
    data = [];
  end

  % Default Value for start
  if isempty(data) || ~isfield(data,'arg1_int'),
    data.SC=7;
    data.TH =41;
	data.kind=1;
  end

  % Display Prompt words
  prompt = {' Enter : Scale  ( integer )', ' Enter : Threshold  ( integer )', ' Enter : Kind  ( integer )'};
  % Default value
  def    = {num2str(num2str(data.SC)), num2str(data.TH),num2str(data.kind)};
  def = inputdlg(prompt, data0.name, 1, def);
  if isempty(def),
	  data=[]; return; %while
  else
	  data.SC=str2num(def{1});
	  data.TH=str2num(def{2});
	  data.kind=str2num(def{3});
  end

  data.ver = 1.00;
  data0.argData=data;
  varargout{1}=data0;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) 
% Make M-File of PlugInWrap_AddRaw
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  A=fdata.argData;
  make_mfile('with_indent', ['% == ' fdata.name ' ==']);
  make_mfile('with_indent', sprintf('[hdata]=uc_MotionCheck_Wavelet(data,hdata,%d,%d,%d);',A.SC,A.TH,A.kind));
  make_mfile('code_separator', 3); % Level 12, code sep .
  make_mfile('with_indent', ' ');
  str='';

return;
