function varargout = FilterDef_FFT(mode, varargin)
% Definition of OSP Filter of Moving Average
%
%  FilterData = FilterDef_Butter('getArgument',FilterData)
%     Make FilterData of Butter Worth Calculation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_Butter('exe', ...
%                 FilterData, data, stimData);
%
% Execute Moving Average
%
% data is HB data matrix
%     Time x Channel x HB Kind
%
% stim is Structure of Stimulation Data ( not in use)
%
% filterData is Structure array of Filter Data
%   filterData.name    : Butter wortb  setting 
%   filterData.wrap    : Ppointer of the Function
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
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
% original author : Masanori Shoji
% create : 2005.02.03
% $Id: FilterDef_FFT.m 180 2011-05-19 09:34:28Z Katura $
%


  switch mode
    % ================
   case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data

    if isfield(data0, 'argData')
      data = data0.argData;
    else
      data = [];
    end

    frange_max=5;             % 10 [point/sec] /2 =5
    frange_min=0.0001;        % frange_max / point number = ??

    % Set Prompt
    prompt = {'Enter : High-Pass Filter [Hz]', ...
		     'Enter : Low-Pass  Filter [Hz]'};

    def={};
    if isstruct(data) && isfield(data,'HighpathFilter')
      def{end+1}=num2str(data.HighpathFilter);
    else
      def{end+1}='0.02';
    end
    if isstruct(data) && isfield(data,'LowpathFilter')
      def{end+1}=num2str(data.LowpathFilter);
    else
      def{end+1}='0.8';
    end

    while 1
      answer = inputdlg(prompt, data0.name, 1, def);
      def = answer;

      % Cancel?
      if isempty(answer)
        data=[]; break;% while
      end

      % Degree OK? 
      pat = '^(\s*[0-9.]+\s*[,;]*)';
      styleck=regexp(answer{1}, pat);
      if ~isempty(styleck)
	a0 =str2num(answer{1});
	data= struct('HighpathFilter',a0);

	if min(a0)<=0
	  errordlg({' Input Error : ', ...
		    '   PathFilter must be Positivet.'});
	  continue;
	end

      else
	errordlg({' Input Error : ', ...
		  '   Your input Path Filter is outof Format.'});
	continue;
      end

      styleck=regexp(answer{2}, pat);
      if ~isempty(styleck)
	a0 =str2num(answer{2});
	data.LowpathFilter = a0;

	if min(a0)<=max(data.HighpathFilter)
	  errordlg({' Input Error : ', ...
		    ['   Minimum of Low Path is smaller than' ...
		     ' Max of High path']});
	   continue;
	elseif length(data.LowpathFilter)~=length(data.HighpathFilter)
	  errordlg({' Input Error : ', ...
		    ['   Length of Low-Path and High path is different']});
	   continue;
	end

      else
	errordlg({' Input Error : ', ...
		  '   Your input Path Filter is outof Format.'});
	continue;
      end

      break; % while

    end

    if exist('work_h','var'), close(work_h);end;
    if isempty(data)
      data0=[];
    else
      data0.argData=data;
    end
    varargout{1}=data0;

    % ================
   case 'write',
    % ================
    region   = varargin{1};
    fdata    = varargin{2};

    hf = max(fdata.argData.HighpathFilter);
    lf = min(fdata.argData.LowpathFilter);

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.4 ']);

    if strcmpi(region, 'HBdata') || strcmpi(region, 'Raw'),
      make_mfile('with_indent', ...
		 {['data = ot_bandpass2(data, ' ...
		   num2str(hf) ',' num2str(lf) ', ...' ], ...
		  '       1, hdata.samplingperiod/1000,1,''time'');'});
    else
      make_mfile('with_indent', ...
		 {'sz=size(data);', ...
		  'sz2=sz; sz2(1)=[];', ...
		  'if length(sz2)<1, sz2(end+1)=1, end'});
      make_mfile('with_indent', {'% block loop', ...
		    'flg=zeros(sz(2),1);', ...
		    'datatmp=[];', ...
                    'for bid = 1:sz(1),'}); 
      make_mfile('indent_fcn', 'down');

      make_mfile('with_indent', ...
                 {'% NaN period removing', ...
                  ['[data_tmp, flg]=' ...
                   ' nanmat_formatting(reshape(data(bid,:,:,:), sz2), ' ...
		   '''CutOff'',1);']});

      make_mfile('with_indent', ...
		 {['data(bid,find(flg==0),:,:) = ot_bandpass2(data_tmp, ' ...
		   num2str(hf) ',' num2str(lf) ', ...' ], ...
		  '       1, hdata.samplingperiod/1000,1,''time'');'});
      
      make_mfile('indent_fcn', 'up');
      make_mfile('with_indent', 'end, % block loop');

      make_mfile('with_indent', 'clear datatmp flg;');
    end
    make_mfile('with_indent', ' ');
    if nargout>=1, varargout{1} =[]; end
  end % switch

return;
