function varargout = FilterDef_TimeBlocking(mode, varargin)
% Bloking is Plug-in Function of POTATo.
%    "Blocking" transform continuous-data to block-data.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Definition of OSP Filter of Moving Average
%
%  FilterData = FilterDef_TimeBlocking('getArgument',FilterData)
%     Make FilterData of LocalFitting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_TimeBlocking('exe', ...
%                 region, ...
%                 FilterData, data, stimData);%
% Execute Local-Fitting
%
% data is HB data matrix
%     Time x Channel x HB Kind
%
% stim is Structure of Stimulation Data ( not in use)
%
% filterData is Structure array of Filter Data
%   filterData.name    : 'LocalFitting(a)' / 'LocalFitting'
%   filterData.wrap    : Ppointer of the Function
%   filterData.argData : Argument of LocalFilter
%
%  argData
%    Degree    : Polyfit Degree
%    RelaxPre  : Relaxing Time of pre-Stimulation  [sec]
%    RelaxPost : Relaxing Time of post-Stimulation [sec]
%  -------->
% since 04-Jun-2005: ( reversion : 1.7 )
%   ( Confine : setArgumentOspLocalFiting)
%    Degree      : Polyfit Degree
%    UnFitPeriod : String of Unfit period,
%                  unit : [sec]
%                  Origin : Start time of Stimulation
%
%    Add new type of argData for LocalFitting.
%    new argData is as following
%
% See also OSPFILTERDATAFCN, OSPFILTERMAIN;

% == History ==
% original author : Masanori Shoji
% create : 2005.01.30
% $Id: FilterDef_TimeBlocking.m 293 2012-09-27 06:11:14Z Katura $
%
% 04-Jun-2005: ( reversion : 1.7 )
%   Change argData format
% 16-Jun-2005: ( reversion : 1.7 )
%   Add : write function.

switch mode
  case 'createBasicInfo'
    bi.Description='Time-Blocking';  
    varargout{1}=bi;
    % ================
  case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data
    if isfield(data0, 'argData')
      data = data0.argData;
      if ~isfield(data,'Marker')
        data.Marker='All';
      end
      if ~isfield(data,'Option')
        data.Option='';
      end
    else
      data.BlockPeriod=[5,15];
      data.Marker='All';
	  data.Option='';
    end
    
    [data.BlockPeriod,data.Marker,data.Option] ...
      = BlockPeriodInputdlg(data.BlockPeriod,'',data.Marker,data.Option);
    if isempty(data.BlockPeriod),
      varargout{1}=[];
    else
      data.wrap=mfilename;
      data0.argData=data;
      varargout{1}=data0;
    end

    % ================
  case 'write'
    % ================
    %region   = varargin{1};
    fdata    = varargin{2};

    fdata0   = fdata.argData;
    braketflag=false;
    if isfield(fdata0,'Marker')
      if isnumeric(fdata0.Marker)
        s=num2str(fdata0.Marker);
        if length(fdata0.Marker)>1
          braketflag=true;
        end
      else
        s=['''' fdata0.Marker ''''];
      end
    else
      s='''All''';
    end
	
  donormal=true;
	if isfield(fdata0,'Option') && ~isempty(fdata0.Option)
    switch lower(fdata0.Option)
      case 'autoperiodset',
        make_mfile('write', '');
        make_mfile('with_indent', ['% == ' fdata.name ' ==']);
        make_mfile('with_indent', ['%    ' mfilename  ' v1.5 beta ']);
        make_mfile('with_indent', sub_AutoPeriodSet);
        make_mfile('with_indent', ...
          {sprintf('[data, hdata] = uc_blocking(cdata, chdata,Period1,Period2,%s);',s)});
        make_mfile('write', '');
        donormal=false;
      otherwise
        warndlg('Unknown Option: Do Normal Blocking');
        donormal=true;
    end		
  end
  if donormal
    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.0 ']);
    if braketflag
      make_mfile('with_indent', ...
        {sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f,[%s]);', ...
        fdata0.BlockPeriod(1), fdata0.BlockPeriod(2),s), ...
        ' '});
    else
      make_mfile('with_indent', ...
        {sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f,%s);', ...
        fdata0.BlockPeriod(1), fdata0.BlockPeriod(2),s), ...
        ' '});
    end
  end
  
  varargout{1}='';

end % end swap

return;

function str=sub_AutoPeriodSet

str{1}='if size(hdata.stim,1)==1';
str{end+1}='  tmp.dur=(size(hdata.stimTC,2)-hdata.stim(1,3))/(1000/hdata.samplingperiod);';
str{end+1}='  tmp.per1=hdata.stim(1,2)/(1000/hdata.samplingperiod);';
str{end+1}='else';
str{end+1}='  tmp.dur=min(hdata.stim(2:end,2)-hdata.stim(1:end-1,3))/(1000/hdata.samplingperiod);';
str{end+1}='  tmp.per1=min([tmp.dur hdata.stim(1,2)/(1000/hdata.samplingperiod)]);';
str{end+1}='end';
str{end+1}='if tmp.dur>=10';
str{end+1}='  Period1=5;	Period2=tmp.dur-5;';
str{end+1}='else';
str{end+1}='  errordlg(sprintf(''Too short inter-stimuli interval (%0.2f sec).\n ISI must be longer than 10 seconds for this recipe.'',tmp.dur),''Auto-blocking'');';
str{end+1}='  return;';
str{end+1}='end; clear tmp';
	


