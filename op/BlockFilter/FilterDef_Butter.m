function varargout = FilterDef_Butter(mode, varargin)
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
% Original author : Masanori Shoji
% create : 2005.01.30
% $Id: FilterDef_Butter.m 180 2011-05-19 09:34:28Z Katura $
%


  % butter worth function Check

  if ~exist('butter','file') && ~strcmpi(mode,'write'),
    error(sprintf('%s\n%s',...
		  '-- Butter Worth Need Function, BUTTER --', ...
		  '    butter is in Signal Precessing Toolbox'));
    return;
  end

  switch mode
    % ================
   case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data
    filttype=data0.name(13:15);

    if isfield(data0, 'argData')
      data = data0.argData;
    else
      data =[];
    end


    % Set Prompt
    prompt={}; def={};
    if filttype(1)~='l'
      prompt{end+1} = ['Enter : High-Pass Filter' ...
		       '(cutting low Frequency) [Hz]'];
      if isstruct(data) && isfield(data,'HighpathFilter')
	def{end+1}=num2str(data.HighpathFilter);
      else
	def{end+1}='0.02';
      end
    end
    if filttype(1)~='h'
      prompt{end+1} = ['Enter : Low-Pass Filter' ...
		       '(cutting low Frequency) [Hz]'];
      if isstruct(data) && isfield(data,'LowpathFilter')
	def{end+1}=num2str(data.LowpathFilter);
      else
	def{end+1}='0.8';
      end
    end


    while 1
      answer = inputdlg(prompt, data0.name, 1, def);

      % Cancel?
      if isempty(answer)
        data=[]; break;% while
      end

      % Degree OK? 
      pat = '^(\s*[0-9.]+\s*[,;]*)';
      styleck=regexp(answer{1}, pat);
      if ~isempty(styleck)
	a0 =str2num(answer{1});
	if filttype(1)~='l'
	  data= struct('HighpathFilter',a0);
	else
	  data= struct('LowpathFilter', a0);
	end

	if min(a0)<=0
	  errordlg({' Input Error : ', ...
		    '   Degree must be Positivet.'});
	  def = answer; continue;
	end

      else
	errordlg({' Input Error : ', ...
		  '   Your input Path Filter is outof Format.'});
	def = answer; continue;
      end

      if length(answer)==1, break; end

      styleck=regexp(answer{2}, pat);
      if ~isempty(styleck)
	a0 =str2num(answer{2});
	data.LowpathFilter = a0;

	if min(a0)<=0 || ...
			length(data.LowpathFilter)~=length(data.HighpathFilter)
	  errordlg({' Input Error : ', ...
		    '   Degree must be Positivet.'});
	  def = answer; continue;
	end

      else
	errordlg({' Input Error : ', ...
		  '   Your input Path Filter is outof Format.'});
	def = answer; continue;
      end

      break; % while

    end

    if isempty(data)
      data0=[];
    else
      data0.argData=data;
    end
    varargout{1}=data0;

    % ================
   case 'write'
    % ================
    region   = varargin{1};
    fdata    = varargin{2};

    filttype=fdata.name(13:15);
    fdata0 = fdata.argData;

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.4 ']);

    make_mfile('with_indent', 'if ~exist(''butter'',''file''),');
    make_mfile('indent_fcn', 'down');
    make_mfile('with_indent', 'warning('' * No butter exist'')');
    make_mfile('indent_fcn', 'up');
    make_mfile('with_indent', 'else, % block data');
    make_mfile('indent_fcn', 'down');

    if filttype(1)=='l'
      make_mfile('with_indent', ...
		 {['lpath = [' num2str(min(fdata0.LowpathFilter)) '];']});
	  %     'for i=length(lpath),'});
      % make_mfile('indent_fcn', 'down');
      make_mfile('with_indent', ...
		 {'[b, a] = ot_butter([], lpath, ...'});
    elseif  filttype(1)=='h'
      make_mfile('with_indent', ...
		 {['hpath = [' num2str(max(fdata0.HighpathFilter)) '];']});
	  %        'for i=length(hpath),'});
      % make_mfile('indent_fcn', 'down');
      make_mfile('with_indent', ...
		 {'[b, a] = ot_butter(hpath, [], ...'});
    else
      make_mfile('with_indent', ...
		 {['lpath = [' num2str(min(fdata0.LowpathFilter)) '];'], ...
		  ['hpath = [' num2str(max(fdata0.HighpathFilter)) '];']});
	  %        'for i=length(hpath),'});
      % make_mfile('indent_fcn', 'down');
      make_mfile('with_indent', ...
		 {'[b, a] = ot_butter(hpath, lpath, ...'});
    end
    make_mfile('with_indent', ...
	       {'          1000/hdata.samplingperiod, ...', ...
		['            5, ''' filttype ''');']});
    % 'if ndims(data)==3,  % continuous?'});
    %make_mfile('indent_fcn', 'down');
    if strcmpi(region, 'HBdata') || strcmpi(region, 'Raw')
      make_mfile('with_indent', 'data=ot_filtfilt(data,a,b,1);');
    else
      %make_mfile('indent_fcn', 'up');
      %make_mfile('with_indent', 'else, % block data');
      %make_mfile('indent_fcn', 'down');
      make_mfile('with_indent', 'sz=size(data);');
      make_mfile('with_indent', {'sz2=sz; sz2(1)=[];', ...
		    'if length(sz2)<1, sz2(end+1)=1;, end'});
      make_mfile('with_indent', {'% block loop', ...
		    'for bid = 1:sz(1),'});
      make_mfile('indent_fcn', 'down');
      
      make_mfile('with_indent', ...
		 {'% NaN period removing', ...
		  ['[data_tmp, flg]=' ...
		   ' nanmat_formatting(reshape(data(bid,:,:,:),sz2),' ...
		   ' ''CutOff'',1);']});

      make_mfile('with_indent', ...
		 'data(bid,find(flg==0),:,:)=ot_filtfilt(data_tmp,a,b,1);');
      make_mfile('indent_fcn', 'up');
      make_mfile('with_indent', 'end, % block loop');
      %make_mfile('indent_fcn', 'up');
    end
    %make_mfile('with_indent', 'end, % end if datatype');
	
    % make_mfile('indent_fcn', 'up');
    % make_mfile('with_indent', 'end, % path - loop');
    make_mfile('indent_fcn', 'up');
    make_mfile('with_indent', {'end, % butter execute', ' '});

    if nargout>=1, varargout{1} = []; end
  end

return;
