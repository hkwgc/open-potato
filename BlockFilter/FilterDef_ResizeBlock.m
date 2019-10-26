function varargout = FilterDef_ResizeBlock(mode, varargin)
% Definition of OSP Filter of Resize Block
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FilterData = FilterDef_ResizeBlock('getArgument',FilterData)
%     Make FilterData of ResizeBlock
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varargout = FilterDef_ResizeBlock('exe', varargin)
%     is not defined.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [command_str] = FilterDef_ResizeBlock('write',region, fdata)
% Execute Resize Block
%
% region is Filtering Region.
%  In the function,
%  region is not effective, 
%  because Region of Filtering is BlockData.
%  So recommned a region, 'BlockData'.
%
% fdata is Structure array of Filter Data
%   filterData.name    : 'ResizeBlock(a)' / 'ResizeBlock'
%   filterData.wrap    : Ppointer of the Function
%   filterData.argData : Argument of LocalFilter
%
%  argData
%    BlockPeriod : Block Period [prestime, poststim]
%                  in [sec].
%                  prestim  is period-before Stimulation.
%                  poststim is period-after  Stimulation.
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
% create : 2005.06.10
% $Id: FilterDef_ResizeBlock.m 180 2011-05-19 09:34:28Z Katura $
%

  switch mode
    case 'createBasicInfo'
      bi.Description='Change Block Size';
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
      data.BlockPeriod = [];
    end

    % === Since 1.7 ==
    %   -- ResizeBlock Arguments --
    if ~isempty(data) && ...
	  isfield(data,'BlockPeriod')
      bp=data.BlockPeriod;
    else
      bp=[5,15];
    end
    bp = BlockPeriodInputdlg(bp);

    if isempty(bp)
      data0=[];
    else
      bpmin = OSP_DATA('GET','PREPOST_STIM');
      if bp(1)>bpmin(1),
	warning('Pretime must be less than before one!');
	bp(1) = bpmin(1);
      end
      if bp(2)>bpmin(2),
	warning('Posttime must be less than before one!');
	bp(2) = bpmin(2);
      end
      data.BlockPeriod = bp;
      data0.argData=data;
    end
    varargout{1}=data0;

    % ================
   case 'exe'
    % ================
    % Error -> OSP version 1.50
    error(['Resize Block is not defined exe command.', ...
	   'This is for OSP version 1.50']);

    % ================
   case 'write',
    % ================
    region   = varargin{1};
    fdata    = varargin{2};

    make_mfile('with_indent', ['% == ' fdata.name ' ==']);
    make_mfile('with_indent', ['%    ' mfilename  ' v1.4 ']);
    make_mfile('with_indent', ' ');

    make_mfile('with_indent', ...
	       sprintf('[data, hdata] = uc_resize(data,hdata,[%d, %d]);', ...
		       fdata.argData.BlockPeriod(1), ...
		       fdata.argData.BlockPeriod(2)));
    make_mfile('with_indent', ' ');

    if nargout>=1, varargout{1} =[]; end
  end

return;
