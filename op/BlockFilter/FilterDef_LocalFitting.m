function varargout = FilterDef_LocalFitting(mode, varargin)
% Polyfit-Diff or Baseline Correction is Plug-in Function of POTATo.
%   this function execute baseline fitting. 

% Definition of OSP Filter of Moving Average
%
%  FilterData = FilterDef_LocalFitting('getArgument',FilterData)
%     Make FilterData of LocalFitting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_LocalFitting('exe', ...
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


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% author : Masanori Shoji
% create : 2005.01.30
% $Id: FilterDef_LocalFitting.m 293 2012-09-27 06:11:14Z Katura $
%
% 04-Jun-2005: ( reversion : 1.7 )
%   Change argData format
% 16-Jun-2005: ( reversion : 1.7 )
%   Add : write function.

switch mode
  case 'createBasicInfo'
    bi.Description='Polyfit & remove Polyfits result.';
    varargout{1}=bi;
    % ================
  case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data
    if isfield(data0, 'argData')
      data = data0.argData;
    else
      data =struct([]);
    end

    if strcmp(data0.name,'Polyfit-Difference'),
      % Set get value
      prompt = {'Enter : Degree of Polyfit'};
      if isfield(data,'Degree')
        def={num2str(data.Degree)};
      else
        def={'1'};
      end

      while 1
        answer = inputdlg(prompt, data0.name, 1, def);
        def = answer;  % For continue;

        % Cancel?
        if isempty(answer), data=[]; break;end

        % Degree OK?
        styleck=regexp(answer{1}, '^\s*\d+\s*$');
        if ~isempty(styleck)
          data = struct('Degree',str2num(answer{1}));

          if data.Degree<0
            errordlg({' Input Error : ', ...
              '   Degree must be Positive.'});
            continue;
          end
        else
          errordlg({' Input Error : ', ...
            '   Your input Degree is outof Format.', ...
            '   Argument must be integer'});
          continue;
        end
        break;
      end % while

      if isempty(data)
        data0=[];
      else
        data0.argData=data;
      end
      varargout{1}=data0;
      return;
    end

    % === Since 1.7 ==
    %   -- LocalFitting Arguments
    data = setArgumentOspLocalFitting('argData',data,'Mfile_eval', varargin{2});
    if isempty(data)
      data0=[];
    else
      data0.argData=data;
      data0.ver=2.0;
    end
    varargout{1}=data0;

    % ================
  case 'write'
    % ================
    region   = varargin{1};
    fdata    = varargin{2};

    fdata0   = fdata.argData;

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.9 ']);

    % Mode Select ( character )
    if strcmp(region,'Raw')
      mode='1';         % For Row-Data ( divide by Polyfit data)
    else
      mode='2';         % sub fitting by Polyfit data
    end

    degree = num2str(round(fdata0.Degree));

    % other
    unit = '1000/hdata.samplingperiod';

    % ** permute ** ( for Block Data )
    if ~strcmpi(region,'Raw') && ~strcmpi(region,'HBdata'),
      make_mfile('with_indent', ...
        {'% *** rearrange the dimensions of data ***', ...
        'data = permute(data, [2,1,3,4]);'});
    end


    % Set Neglect Period
    if strcmp(fdata.name,'Polyfit-Difference')
      neg = '[2 3]'; % Use All
      unfit ='';     % Dummy
    elseif  isfield(fdata0,'RelaxPre'),
      % For old Local-Fitting Arguments.

      % Local Fitting must be Block Data,
      % so header.stim is
      %   [start time of stimulation, end time of stimulation]
      % See also definition of Header-Data of Block.
      neg = 'round(hdata.stim)';
      %neg = ['round(hdata.stim * ' unit ')'];
      unfit ='';     % Dummy
    else,
      % Local Fitting must be Block Data,
      %  UnFitPeriod unit is sec, origin is start time of stimulation
      % See also setArgumentOspLocalFitting.
      neg = '[2 3]'; % Dummy ( use fixt )
      unfit =',unfit';
      % : to sampling period
      unitstr0= 'hdata.samplingperiod/1000';
      unfitstr=fdata0.UnFitPeriod;
      pos=strfind(unfitstr,':');
      if isfield(fdata,'ver')
        for pi = pos(end:-1:1),
          unfitstr = [unfitstr(1:pi-1) ...
            ':' unitstr0 ':' unfitstr((pi+1):end)];
        end
      else
        p2=strfind(unfitstr,'samplingperiod');
        if isempty(p2)
          for pi = pos(end:-1:1),
            unfitstr = [unfitstr(1:pi-1) ...
              ':' unitstr0 ':' unfitstr((pi+1):end)];
          end
        end
      end
      make_mfile('with_indent', ...
        {'tm=[1, hdata.stim(1), hdata.stim(2), size(data,1)];',...
        ['tm=(tm-hdata.stim(1)) / (' unit ');'],...
        'st=tm(1);m1=tm(2);m2=tm(3);ed=tm(4);',...
        ['unfit=round(' unfitstr ' * ' unit ')+hdata.stim(1);']});
    end

    % Local Fitting
    make_mfile('with_indent', ...
      ['data = osp_Local_Fitting(' ...
      'data, ' neg ', ' degree ', ' mode unfit ');']);

    % **  re-permute **
    if ~strcmpi(region,'Raw') && ~strcmpi(region,'HBdata'),
      make_mfile('with_indent', ...
        {'% *** rearrange the dimensions of data ***', ...
        'data = ipermute(data, [2,1,3,4]);'});
    end
    make_mfile('with_indent', ' ');
    if nargout>=1, varargout{1} =[]; end

end % end swap

return;
