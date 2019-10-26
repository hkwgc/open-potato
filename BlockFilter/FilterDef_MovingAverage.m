function varargout = FilterDef_MovingAverage(mode, varargin)
% Moving Average is Plug-in Function of POTATo.

% Definition of OSP Filter of Moving Average
%
%  FilterData = FilterDef_MovingAverage('getArgument',FilterData)
%     Make FilterData of Movingaverage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_MovingAverage('exe', ...
%                 region, ...
%                 FilterData, data, stimData);
% Execute Moving Average
%
% region is Region of Filtering, but not in use 
%
% data is HB data matrix
%     Time x Channel x HB Kind
%
% stim is Structure of Stimulation Data ( not in use)
%
% filterData is Structure array of Filter Data
%   filterData.name    : 'Moving Average'
%   filterData.wrap    : Ppointer of the Function
%   filterData.argData : Argument
%
%   argData.DataPoints : Mean Period to execute MovingAverage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
% See also OSPFILTERDATAFCN,
%          OSPFILTERMAIN,
%          OSP_MOVINGAVERAGE,
%          INPUTDLG.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.01.30
% $Id: FilterDef_MovingAverage.m 293 2012-09-27 06:11:14Z Katura $
%

  switch mode
    case 'createBasicInfo'
      bi.Description='Moving Average';
      varargout{1}=bi;    
    % ================
   case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data
    if isfield(data0,'argData')
      data = data0.argData;
    else
      data =struct([]);
    end

    % Set
    prompt = {'Data points for averaging (point)'};

    if isfield(data,'DataPoints')
      def={num2str(data.DataPoints)};
    else
      def={'10'};
    end
    while 1
      answer = inputdlg(prompt, data0.name, 1, def);

      % Cancel?
      if isempty(answer)
        data=[]; break;% while
      end

      % OK ? 
      styleck=regexp(answer{1}, '^\s*\d+\s*$');
      if ~isempty(styleck)
        data = struct('DataPoints',str2num(answer{1}));
        break; % while
      else
	errordlg({' Input Error : ', ...
		  '   Your inputerror is outof Format.', ...
		  '   Argument must be integer'});
	def = answer;
      end
    end
    if isempty(data)
      data0=[];
    else
      data0.argData=data;
    end
    varargout{1}=data0;

    % ================
   case 'exe'
    % ================
    % If Error Occur : We must send err
    filtdata = varargin{2};
    data = varargin{3};
    varargout{1} =osp_Movingaverage(data,...
				    filtdata.argData.DataPoints);
    if length(varargin) >= 4
      varargout{2}=varargin{4};
    else
      varargout{2}=[];
    end

    % ================
   case 'write'
    % ================
    % Now no debug. OK
    % warning('Moving Average Write : not debugd');

    region   = varargin{1};
    fdata    = varargin{2};

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.3 ']);
    
		if ~isfield(fdata.argData,'DataPoints')
			fdata.argData.DataPoints = fdata.argData.MeanPeriod;
		end
    mnperiod = num2str(fdata.argData.DataPoints);

    make_mfile('with_indent', ...
	       ['data =osp_Movingaverage(data, ' mnperiod ');']);
    make_mfile('with_indent', ' ');
    if nargout>=1, varargout{1} =[]; end

  end % end swap

return;
