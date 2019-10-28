function varargout = FilterDef_PCA(mode, varargin)
% Definition of OSP Filter of PCA
%
%  FilterData = FilterDef_PCA('getArgument',FilterData)
%     Make FilterData of Butter Worth Calculation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_PCA('exe', ...
%                 FilterData, data, stimData);
%
% Execute PCA
%
% data is HB data matrix
%     Time x Channel x HB Kind
%
% stim is Structure of Stimulation Data ( not in use)
%
% filterData is Structure array of Filter Data
%   filterData.name    : Butter wortb  setting 
%   filterData.wrap    : Ppointer of the Function
%   filterData.argData : Argument Data
%
%   argData            : is return value of osp_PCA,
%                        Useing Compornent of HBdata 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% $Id: FilterDef_PCA.m 180 2011-05-19 09:34:28Z Katura $
%


  switch mode
    case 'createBasicInfo'
      bi.Description='PCA Filter: reassembled in Principle Component (1-x)';
      varargout{1}=bi;
    % ================
   case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0    = varargin{1}; % Filter Data
    mfile_in = varargin{2}; % M-File to make data

    if isfield(data0, 'argData')
      data = osp_PCA('InitData',data0.argData,'Mfile',mfile_in);
    else
      data = osp_PCA('Mfile',mfile_in);
    end

    % Check Cancel or not
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
    % region   = varargin{1};
    if 0,
      fdata    = varargin{2};
      data     = varargin{3};
      if nargin >4
	stim     = varargin{4};
      else
	stim=[];
      end

      data = osp_PCAfilter(data, fdata.argData.UseComps);

      varargout{1} = data;
      varargout{2}=  stim;
    else,
      error('Cannot use exe-method, from OSP ver 1.10')
    end
    
    % ================
   case 'write',
    % ================
    region   = varargin{1};
    fdata    = varargin{2};

    % Argument to String
    % ( Using Principle-Compornent )
    useComps = [ '[' num2str(fdata.argData.UseComps) ']' ];

    % == Print 'Head Comment' ==
    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.4 ']);


    % == Print 'Execute Command' ==
    if strcmpi(region, 'HBdata') || strcmpi(region, 'Raw'),
      % - for Continuous Data -
      make_mfile('with_indent', ...
                 ['data = osp_PCAfilter(data, ' useComps ');']);
    else
      % - for Block Data -
      % == Block Loop ==
      make_mfile('with_indent', ...
                 {'sz=size(data);', ...
                  'sz2=sz; sz2(1)=[];', ...
                  'if length(sz2)<1, sz2(end+1)=1, end'});
      make_mfile('with_indent', {'% block loop', ...
                    'flg=zeros(sz(2),1);', ...
                    'datatmp=[];', ...
                    'for bid = 1:sz(1),'});
      make_mfile('indent_fcn', 'down');
      
      % == NaN include Time-Components Removing ==
      make_mfile('with_indent', ...
                 {'% NaN period removing', ...
                  ['[data_tmp, flg] = ' ...
                   'nanmat_formatting(reshape(data(bid,:,:,:),  sz2), ' ...
		   '''CutOff'',1);']});

      % Execute
      make_mfile('with_indent', ...
                 {'data(bid, find(flg==0),:,:) = ...' ...
		 ['      osp_PCAfilter(data_tmp,[' useComps ']);']});

      make_mfile('indent_fcn', 'up');
      make_mfile('with_indent', 'end, % block loop');
      make_mfile('with_indent', 'clear datatmp flg;');
    end % Data type - Difference Path -
    
    make_mfile('with_indent', ' ');
    if nargout>=1, varargout{1} =[]; end

  end % switch
  
return;
