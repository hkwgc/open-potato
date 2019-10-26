function P3_FilterData2Mfile(fmd, stimtype, stimkind,serialno)
% Make M-File from FilterData (P3)
%
% -----------------------------------------------
%  Platform for Optical Topography Anaysis Tools
%                         since Revision 2.5.30.3
% -----------------------------------------------
%
% P3_FilterData2Mfile(fmd),
%  Input    :
%   fmd : File Manage Data.
%  Outp Put : Mfile - Filter Area
%   ( Using MAKE_MFILE ( continue ))
%
% P3_FilterData2Mfile(fmd,stimtype),
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
% original author : Masanori Shoji
% create : 07-Feb-2007.
% $Id: P3_FilterData2Mfile.m 397 2014-03-31 04:29:56Z katura7pro $
%
% Revision 1.0
%  Import from FilterData2Mfile

% ==== Argument Check =========
% if no argument Read HB Data
msg = nargchk(1,4,nargin);
if ~isempty(msg), error(msg); end

% Header Comment
make_mfile('code_separator', 1);
make_mfile('with_indent', '% Filtering Data');
% Recipe Information
P3_Write_Mfile_Comment('recipeInfo',fmd);
make_mfile('code_separator', 1);
make_mfile('with_indent', ['%  Create Date : ' datestr(now,0)]);
make_mfile('with_indent', '%');
make_mfile('with_indent', '%      Made by $Id: P3_FilterData2Mfile.m 397 2014-03-31 04:29:56Z katura7pro $');
make_mfile('with_indent', '%');
make_mfile('with_indent', ...
  {'%  Input :', ...
  '%    datanames : File Name of RawData', ...
  '%  Output (principle) : ', ...
  '%    data, hdata : P3 Data'});
make_mfile('code_separator', 1);

% == Continuous Data Loop Start. ==
make_mfile('code_separator', 2);
make_mfile('with_indent', ...
  {'% === Make Continuous Data ===', ...
  '% Load Signal-Data, See also UC_DATALOAD',  ...
  '[data, hdata] = uc_dataload(datanames);', ' '});

if exist('stimtype','var'),
  make_mfile('with_indent', ...
    '% Stimulation Data Setting');
  make_mfile('with_indent', { ...
    '% Block - Stimulation - Marking',  ...
    sprintf('hdata = uc_makeStimData(hdata,%d);', stimtype), ...
    ' '});
end

if isfield(fmd,'HBdata'),
  % -- Set Filter --
  for fidx=1:length(fmd.HBdata),
    try
      if isfield(fmd.HBdata{fidx},'enable') && ...
          strcmpi(fmd.HBdata{fidx}.enable,'off'),
        continue;
      end
      str = ...
        P3_PluginEvalScript(fmd.HBdata{fidx}.wrap,'write', ...
        'HBdata', fmd.HBdata{fidx});
      if ~isempty(str),
        make_mfile('with_indent', str);
      end
    catch
      make_mfile('with_indent', ...
        sprintf('warning(''write error: at %s'');', fmd.HBdata{fidx}.name));
      warning(lasterr);
    end % try-catch
  end % filter output
  make_mfile('code_separator', 2);
end, % HBdata?

make_mfile('with_indent',{' ' ...
  'cdata = {data};  chdata = {hdata};', ' '});


%==================================
%% Blocking
%==================================
% No - Blocking
if ~isfield(fmd,'BlockPeriod'),
  return;
end
if isfield(fmd,'block_enable') && fmd.block_enable==0,
  return;
end

% Bugfix : B070622A
if isfield(fmd,'TimeBlocking'),
  blocking=fmd.TimeBlocking{1};
  if isfield(blocking,'enable') && ...
      strcmpi(blocking.enable,'off'),
    return;
  end
  str = P3_PluginEvalScript(blocking.wrap,'write', 'BlockData', blocking);
  if ~isempty(str),
    make_mfile('with_indent', str);
  end  
else
  if exist('stimkind','var') && ~isempty(stimkind),
    stimkind_str=stimkind(:)';
    stimkind_str=num2str(stimkind_str);
    if length(stimkind)>=2,
      stimkind_str=['[' stimkind_str ']'];
    end
    make_mfile('with_indent', ...
      {'% === Time Blocking === ', ...
      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f,%s);', ...
      fmd.BlockPeriod(1), fmd.BlockPeriod(2), stimkind_str), ...
      ' '});
  else,
    make_mfile('with_indent', ...
      {'% === Time Blocking === ', ...
      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f);', ...
      fmd.BlockPeriod(1), fmd.BlockPeriod(2)), ...
      ' '});
  end
end

% == Block Data Loop Start. ==
if isfield(fmd,'BlockData'),
  make_mfile('code_separator', 2);
  make_mfile('with_indent','% === To Block Data === ');
  % -- Set Filter --
  for fidx=1:length(fmd.BlockData),
    try
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
    catch
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
make_mfile('code_separator', 1);
make_mfile('with_indent',' ');
return;



