function varargout = FilterDef_BandFilter(mode, varargin)
% Band Filter is Plug-in Function of POTATo.
%   "Band Filter" execute Band pass Filter.

% Definition of OSP Band-Filters (fft,butterworth)
%
%  FilterData = FilterDef_BandFilter('getArgument',FilterData)
%     Make FilterData of BandFilters Calculation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilteDef_BandFilter('write', ...
%                 region, FilterData);
%
% region is write region
%   'Raw', 'HBdata' for continuous data.
%   'BlockData' for Block Data.
%
% FilterData is Structure array of Filter Data
%   FilterData.name    : Butter wortb  setting
%   FilterData.wrap    : Pointer of the Function
%   FilterData.argData : data of arguments
%    argData
%          .FilterType     : 'FFT','BandPassFilter','BandStopFilter',
%                          : 'HighPassFilter','LowPassFilter'
%          .HighpassFilter : Highpass filter for
%                             Bandpass-Filter
%          .LowpassFilter  : Lowpass filter for
%                             Bandpass-Filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% $Id: FilterDef_BandFilter.m 293 2012-09-27 06:11:14Z Katura $
%


switch mode
  case 'createBasicInfo'
    bi.Description='Bandpass Filter';
    varargout{1}=bi;
    % ================
  case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0 = varargin{1}; % Filter Data

    % check
    if nargin>=3 && exist(varargin{2}, 'file'),
      mfile_pre = varargin{2};
    else
      mfile_pre = '';
    end

    if isfield(data0, 'argData')
      data = data0.argData;
    else
      data = [];
    end

    % open GUI for get Arguments, draw
    data = FD_BandFilter_getArgument('argData', data, ...
      'Mfile',   mfile_pre);
    if isempty(data),
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

    if isfield(fdata.argData,'FilterFunction'),
      filt_func = fdata.argData.FilterFunction;
    else
      warndlg({'Too old Data-Format : Band-Filter.',...
        ' Try to use Butterworth for Filter-Function'});
      filt_func = 'Butterworth';
    end

    if isfield(fdata.argData,'FilterType')
      filt_type = fdata.argData.FilterType;
      % convert to butterworth filter name
      idx = regexp(filt_type, '[A-Z]'); % Get Large letter
      filt_type = lower(filt_type(idx));
    else
      warndlg({'Too old Data-Format : Band-Filter.',...
        ' Use bpf to filtering'});
      filt_type ='bpf';
    end
    
    argData0   = fdata.argData;
    if isfield(argData0,'HighPassFilter')
      hf = max(argData0.HighPassFilter);
    elseif isfield(argData0,'HighpathFilter')
      hf = max(argData0.HighpathFilter);
    else
      if ~strcmp(filt_type(1),'l')
        warndlg({'Too old Data-Format : Band-Filter.',...
            ' Use 0 for Highpass-Filter'});
      end
      hf = 0;
    end
    
    if isfield(argData0,'LowPassFilter')
      lf = min(argData0.LowPassFilter);
    elseif isfield(argData0,'LowpathFilter')
      lf = min(argData0.LowpathFilter);
    elseif isfield(argData0,'LowpaThFilter')
      lf = min(argData0.LowpaThFilter);
    else
      if ~strcmp(filt_type(1),'h')
        warndlg({'Too old Data-Format : Band-Filter.',...
            ' Use 5 for Lowpass-Filter'});
      end
      lf = Inf;
    end

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', '% $Id : $ ');

    switch lower(filt_func),
      case 'fft',
        % --------------------------------
        % FFT
        % --------------------------------
        if strcmpi(region, 'HBdata') || strcmpi(region, 'Raw'),
          % For Continuous Data
          make_mfile('with_indent', ...
            {['data = ot_bandpass2(data, ' ...
            num2str(hf) ',' num2str(lf) ', ...' ], ...
            '       1, hdata.samplingperiod/1000,1,''time'');'});
        else
          % For Time-Blocking Data
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
        %% end FFT
      case 'butterworth',
        % --------------------------------
        % BUTTER WORTH FUNCTION
        % --------------------------------
        if isfield(argData0,'butterworthDim')
          dimstr=num2str(argData0.butterworthDim);
        else
          dimstr='5';
        end
        make_mfile('with_indent', 'if ~exist(''butter'',''file''),');
        make_mfile('indent_fcn', 'down');
        make_mfile('with_indent', 'warndlg('' * No butter exist'')');
        make_mfile('indent_fcn', 'up');
        make_mfile('with_indent', 'else');
        make_mfile('indent_fcn', 'down');

        if filt_type(1)=='l'
          make_mfile('with_indent', ...
            {['lpass = [' num2str(lf) '];']});
          make_mfile('with_indent', ...
            {'[b, a]  = ot_butter([], lpass, ...'});
        elseif  filt_type(1)=='h'
          make_mfile('with_indent', ...
            {['hpass = [' num2str(hf) '];']});
          %        'for i=length(hpath),'});
          % make_mfile('indent_fcn', 'down');
          make_mfile('with_indent', ...
            {'[b, a] = ot_butter(hpass, [], ...'});
        else
          make_mfile('with_indent', ...
            {['lpass = [' num2str(lf) '];'], ...
            ['hpass = [' num2str(hf) '];']});
          %        'for i=length(hpath),'});
          % make_mfile('indent_fcn', 'down');
          make_mfile('with_indent', ...
            {'[b, a] = ot_butter(hpass, lpass, ...'});
        end
        make_mfile('with_indent', ...
          {'          1000/hdata.samplingperiod, ...', ...
          ['            ' dimstr ', ''' filt_type ''');']});
        % 'if ndims(data)==3,  % continuous?'});
        %make_mfile('indent_fcn', 'down');
        if strcmpi(region, 'HBdata') || strcmpi(region, 'Raw')
          make_mfile('with_indent', 'data=ot_filtfilt(data,a,b,1);');
        else
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
        end
        make_mfile('indent_fcn', 'up');
        make_mfile('with_indent', {'end, % butter execute', ' '});

        if nargout>=1, varargout{1} = []; end
      otherwise
        errordlg({['Unknow Filter Type : ' filt_func]},'Cannot Execute Function');
        make_mfile('with_indent', ['% Unknow Filter Type : ' filt_func]);
        make_mfile('with_indent', '%  Could not output M-File');
    end % end switch / Filter-Function
end % switch (CreateBasicFunction/GetArgument/Write)

return;
