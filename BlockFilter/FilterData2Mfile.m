function FilterData2Mfile(fmd, stimtype, stimkind,serialno),
% Make M-File from FilterData
% 
% ----------------------------------------------
%  Optical topography Signal Processor Platform
%                         Version 2.11
% ----------------------------------------------
%
% FilterData2Mfile(fmd),
%  Input    :
%   fmd : File Manage Data.
%  Outp Put : Mfile - Filter Area
%   ( Using MAKE_MFILE ( continue ))
%
% FilterData2Mfile(fmd,stimtype),
%  Input    :
%    stimtype : Stimulation-Type 1: Event
%                                2: Block
%
%  Outp Put : Mfile - Filter Area
%   ( Using MAKE_MFILE ( continue ))
%
% See also OSPFILTERDATAFCN, 
%          DATADEF_FILTERDATA,
%          MAKE_MFILE.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% Original author : Masanori Shoji
% create : 21-Nov--2005.
% $Id: FilterData2Mfile.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.3
%  Unknown file I/O Error on Flush.

  % ==== Argument Check =========
  % if no argument Read HB Data
  msg = nargchk(1,4,nargin);
  if ~isempty(msg), error(msg); end

  % No - Blocking
  if ~isfield(fmd,'BlockPeriod'),
	  error('Multi File Mfile Need Block Data');
  end
  
  % Header Comment
  make_mfile('code_separator', 1);
  make_mfile('with_indent', ['% === Data-Filtering ===']);
  make_mfile('with_indent', ['%  Create Date : ' datestr(now,0)]);
  make_mfile('with_indent', '%');
  make_mfile('with_indent', '%      Made by $Id: FilterData2Mfile.m 180 2011-05-19 09:34:28Z Katura $');  
  make_mfile('with_indent', '%');
  make_mfile('with_indent', ...
	  {'%  This Block Input :', ...
	  '%    sp : Cell-array of SignalPreprocessor File Name', ...
	  '%  This Block (principle) Output : ', ...
	  '%    cdata, chdata : Cell of Continuous Data', ...
	  '%    bdata, bhdata : Block Data'});
  make_mfile('code_separator', 1);
  
  % == Continuous Data Loop Start. ==
  make_mfile('with_indent', ...
	  {'% === Make Continuous Data ===', ...
	  'cdata ={};   % Cell continuous data', ...
	  'chdata={};   % Cell header of continuous data', ...
	  'for idx=1:length(datanames),'});
  make_mfile('indent_fcn', 'down');

  make_mfile('with_indent', { ...
	  '% Load Signal-Data, See also UC_DATALOAD',  ...
	  '[data, hdata] = uc_dataload(datanames{idx});', ' '});

  if exist('stimtype','var'),
	  make_mfile('with_indent', ...
		  '% Stimulation Data Setting');
	  make_mfile('with_indent', { ...
		  '% Block - Stimulation - Marking',  ...
		  sprintf('hdata = uc_makeStimData(hdata,%d);', stimtype), ...
		  ' '});
  end
  
  % -- Select Serial NO --
  if exist('serialno','var') && ~isempty(serialno),
  end

  if isfield(fmd,'HBdata'),
    % -- Set Filter --
	make_mfile('code_separator', 2);
	for fidx=1:length(fmd.HBdata),
		try,
		    if isfield(fmd.HBdata{fidx},'enable') && ...
			  strcmpi(fmd.HBdata{fidx}.enable,'off'),
		      continue;
		    end
		    str = ...
			feval(fmd.HBdata{fidx}.wrap,'write', ...
			      'HBdata', fmd.HBdata{fidx});
		    if ~isempty(str),
		      make_mfile('with_indent', str);
		    end
		catch,
		  make_mfile('with_indent', ...
			     sprintf('warning(''write error: at %s'');', fmd.HBdata{fidx}.name));
		  warning(lasterr);
		end % try-catch
	end % filter output
	make_mfile('code_separator', 2);
  end, % HBdata?
  
  make_mfile('with_indent',{' ' ...
	  'cdata{end+1} = data;  chdata{end+1} = hdata;', ' '});
  
  make_mfile('indent_fcn', 'up');
  make_mfile('with_indent',{'end,   % End of Continuous Data', ' '});
  
  if exist('stimkind','var') && ~isempty(stimkind),
	  stimkind_str=stimkind(:)';
	  stimkind_str=num2str(stimkind_str);
	  if length(stimkind)>=2,
		  stimkind_str=['[' stimkind_str ']'];
	  end
	  make_mfile('with_indent', ...
		     {'% === Make Block Data === ', ...
		      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f,%s);', ...
		  fmd.BlockPeriod(1), fmd.BlockPeriod(2), stimkind_str), ...
		      ' '});
  else,
    make_mfile('with_indent', ...
	       {'% === Make Block Data === ', ...
		sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f);', ...
			fmd.BlockPeriod(1), fmd.BlockPeriod(2)), ...
		' '});
  end
  
  % == Block Data Loop Start. ==
  if isfield(fmd,'BlockData'),
	  make_mfile('code_separator', 2);
	  make_mfile('with_indent','% === To Block Data === ');
	  % -- Set Filter --
	  for fidx=1:length(fmd.BlockData),
		  try,
		if isfield(fmd.BlockData{fidx},'enable') && ...
		      strcmpi(fmd.BlockData{fidx}.enable,'off'),
		  continue;
		end
		str = ...
		    feval(fmd.BlockData{fidx}.wrap,'write', ...
			  'BlockData', fmd.BlockData{fidx});
		if ~isempty(str),
		  make_mfile('with_indent', str);
		end
		  catch,
		    make_mfile('with_indent', ...
			       sprintf('warning(''write error: at %s'');', fmd.BlockData{fidx}.name));
		    warning(lasterr);
		  end % try-catch
	  end % filter output
      make_mfile('code_separator', 2);
  end, % BlockData?
  
  % rename :
  % Recode of OSP-v1.5 9th-Meeting of on 27-Jun-2005.
  % Change on 28-Jun-2005 by Shoji.
  make_mfile('with_indent', ...
	     {'% Rename', ...
	      'bdata  = data;', ...
	      'bhdata = hdata;', ...
	      ' '});
  make_mfile('with_indent','% End of Block Data');
  make_mfile('code_separator', 1);  
  make_mfile('with_indent',' ');
return;



