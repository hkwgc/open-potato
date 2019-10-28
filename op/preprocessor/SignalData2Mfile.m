function varargout=SignalData2Mfile(sdata, fdata, varargin),
% Make M-File from SignalData.
% since 
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 2.10
% -------------------------------------
%
% Upper Link :
%   DataDef_SignalPreprocessor
% Lower Link :
%  Filter Function :
% See also OSPFILTERDATAFCN, 
%          FILTERDEF_MOVINGAVERAGE,
%          FILTERDEF_LOCALFITTING,
%          FILTERDEF_BUTTER,
%          FILTERDEF_FFT,
%          FILTERDEF_RESIZEBLOCK.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : January, 2005.
% $Id: SignalData2Mfile.m 398 2014-03-31 04:36:46Z katura7pro $
%
% Revision 1.3
%  Filter-Data-Manageer Data Format ::
%     Structure-Array to Cell-Array of Structure
%     (Filter - Type : Add )
% Revision 1.4 : Bug fix of 1.13
%     Apply Enable off :
%         (See also :  OspFilterCallbacks/get : r1.21 )
% Revision 1.5 : Bug fix of 1.14


  ecode.Tag = ' Filter Data ErrorCode 1:Error, 0: Normal';
  
  % ==== Argument Check =========
  % if no argument Read HB Data
  if nargin<2, error('Too few arguments'); end
  
  for idx=2:2:length(varargin),
	  switch lower(varargin{idx-1}),
		  case 'stimtype',
			  stimtype=varargin{idx};
	  end % switch
  end % argset
  
  
  % Header Comment
  make_mfile('code_separator', 1);   % Level  1, code sep
  make_mfile('with_indent', ['% === Make Continuous Data : ' sdata.filename ' ===']);
  make_mfile('with_indent', ['%        Create Date : ' datestr(now,0)]);
  make_mfile('with_indent', '%');
  myid = ' % $Id: SignalData2Mfile.m 398 2014-03-31 04:36:46Z katura7pro $';
  myid([4, end])=[];
  make_mfile('with_indent', myid);
  make_mfile('code_separator', 1);   % Level  1, code sep
  
  % Load Data
  fname = DataDef_SignalPreprocessor('getFilename',sdata.filename);
  
  make_mfile('with_indent', { ...
		  '% Load Signal-Data, See also UC_DATALOAD',  ...
		  sprintf('fname=''%s'';', fname), ...
		  '[data, hdata] = uc_dataload(fname);', ' '});

  %-- Raw Data Region Transfer --
  if exist('stimtype','var'),
    make_mfile('with_indent', { ...
	'% Block - Stimulation - Marking',  ...
	sprintf('hdata = uc_makeStimData(hdata,%d);', stimtype), ...
	' '});
  end  
  
  % Filter .
  make_mfile('code_separator', 1);
  make_mfile('with_indent',  '% Plugin-Filter : Continuous Data Region');
  make_mfile('code_separator', 1);
  if isfield(fdata,'HBdata'),
	  % -- Set Filter --
	  for fidx=1:length(fdata.HBdata),
	    try,
	      if isfield(fdata.HBdata{fidx},'enable') && ...
		    strcmpi(fdata.HBdata{fidx}.enable,'off'),
		continue;
	      end
	      str = ...
		  P3_PluginEvalScript(fdata.HBdata{fidx}.wrap,'write', ...
			'HBdata', fdata.HBdata{fidx});
	      if ~isempty(str),
		make_mfile('with_indent', str);
	      end
	    catch,
	      make_mfile('with_indent', ...
			 sprintf('warning(''write error: at %s'');', fdata.HBdata{fidx}.name));
	      warning(lasterr);
	    end % try-catch
	  end % filter output
  end, % HBdata?

  % rename :
  % Recode of OSP-v1.5 9th-Meeting of on 27-Jun-2005.
  % Change on 28-Jun-2005 by Shoji.
  make_mfile('with_indent', ...
             {'% Rename ', ...
              'cdata  = {data};', ...
              'chdata = {hdata};', ...
              'bdata  = [];', ...
              'bhdata = struct([]);', ...
              ' '});
  
return;

