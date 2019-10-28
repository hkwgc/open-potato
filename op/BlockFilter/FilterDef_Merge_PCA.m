function varargout = FilterDef_Merge_PCA(mode, varargin)
% Definition of MergePCA
%
%  FilterData = FilterDef_Merge_PCA('getArgument',FilterData)
%     Make FilterData of Butter Worth Calculation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data,stim] = FilterDef_Merge_PCA('exe', ...
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
%   filterData.name    : Name of Filter
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
% author : Masanori Shoji
% create : 2005.02.03
% $Id: FilterDef_Merge_PCA.m 180 2011-05-19 09:34:28Z Katura $
%


switch mode
  case 'createBasicInfo'
    bi.Description='PCA : Add-New-Data-Kind & set Eigen-Value,Vector.';
    varargout{1}=bi;
    % ================
  case'getArgument'
    % ================
    varargout{1}=[];
    % Set Data
    data0    = varargin{1}; % Filter Data
    mfile_in = varargin{2}; % M-File to make data

    % No argData
    data0.argData.mode='';

    varargout{1}=data0;

    % ================
  case 'exe'
    % ================
    % If Error Occur : We must send err
    % region   = varargin{1};
    error('Cannot use exe-method, from OSP ver 1.10')

    % ================
  case 'write',
    % ================
    region   = varargin{1};
    fdata    = varargin{2};
    % == Print 'Head Comment' ==
    make_mfile('code_separator', 3);   % Level  3, code sep
    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.0 ']);
    make_mfile('code_separator', 3);   % Level  3, code sep

    make_mfile('with_indent', '[hdata, data]=merge_PCA(hdata,data);');
    if nargout>=1, varargout{1} =[]; end

end % switch

return;
