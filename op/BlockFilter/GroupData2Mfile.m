function GroupData2Mfile(varargin)
% Make M-File from GroupData.
% since
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 2.10
% -------------------------------------
%
% Lower Link :
%  Filter Function :
% See also OSPFILTERDATAFCN,
%          OSPFILTERCALLBACKS,
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
% $Id: GroupData2Mfile.m 397 2014-03-31 04:29:56Z katura7pro $
%
% Revision 1.3
%  Unknown file I/O Error on Flush.
% Revision 1.13
%  Filter-Data-Manageer Data Format ::
%     Structure-Array to Cell-Array of Structure
%     (Filter - Type : Add )
% Revision 1.14 : Bug fix of 1.13
%     Apply Enable off :
%         (See also :  OspFilterCallbacks/get : r1.21 )
%
% Revision 1.17 :
%  Stimulation-Data-Set Version 1.0 : stim on/off flag only
%  Stimulation-Data-Set Version 1.5 : (stim diff)
%  Stimulation-Data-Set Version 2.0 : (stim diff) + (stim kind)
%  Stimulation-Data-Set Version 2.5 : (stim kind)
%
% Revision 1.21 :
%  Delete Continuous-Loop.
%  Modify Header of M-File.
%
% Revision 1.22 : BlushUp
% Revision 1.23 : Add Discription to Header

ecode.Tag = ' Filter Data ErrorCode 1:Error, 0: Normal';

%================
%% 0.Initialize
%================

%---------------------
% 0.1 Argument Check
%---------------------
% if no argument Read HB Data
msg = nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
gdata = varargin{1};

% Data Empty Check
data0 = gdata.data;
if isempty(data0),
  make_mfile('with_indent', 'warndlg(''No Data exist'');');
  error('Empty Cell-Group-Data!');
end
fdata = data0(end).filterdata; %Filter Data.

% -- Mfile Info --
[fid, fname]=make_mfile('getfileinfo');
if isempty(fid),
  errordlg('GroupData2Mfile : No File opened to write');
  return;
end
[p,f]=fileparts(fname); %#ok : p is not use

%--------------------
% 0.2 Header Comment
%--------------------
make_mfile('with_indent', sprintf('%% %s, make POTATo data.',upper(f)));
make_mfile('with_indent', '%');
make_mfile('with_indent', '% == Analysis-Data-Information ==');
% Project Information
P3_Write_Mfile_Comment('projectInfo');
% Data Information
if isfield(gdata,'Tag'),
  make_mfile('with_indent', ['%   Name  : ' gdata.Tag]);
elseif isfield(gdata,'filename'),
  make_mfile('with_indent', ['%   Name  : ' gdata.filename]);
end
make_mfile('with_indent', '% ');
make_mfile('with_indent', ['% Date : ' datestr(now,0)]);
make_mfile('with_indent', '% ');

% Recipe Information
P3_Write_Mfile_Comment('recipeInfo',fdata);
make_mfile('with_indent', '');
% File Version Information
make_mfile('code_separator',6); % - -
make_mfile('with_indent', '% Platform for Optical Topography Analysis Tools III');
make_mfile('with_indent', '% Function : GroupData2Mfile : $Revision: 1.24 $');
make_mfile('code_separator',6); % - -
make_mfile('with_indent', '');

%--------------------
% 0.3 Log Output
%--------------------
OSP_LOG('msg',['GroupData to M-File at ' datestr(now)]);
OSP_LOG('msg',['  File Name :' fname]);
if isfield(gdata,'Tag'),
  OSP_LOG('msg',['  Data Name :' gdata.Tag]);
elseif isfield(gdata,'filename'),
  OSP_LOG('msg',['  Data Name :' gdata.filename]);
end


%---------------------------
% 0.4 Select Continuous Data
%---------------------------
% Argument Setting. Load Continuous Data
% datanames= {data0.name};
make_mfile('code_separator',1); %%%
make_mfile('with_indent', '% Continuous Data Setting');
make_mfile('code_separator',1); %%%
make_mfile('with_indent','datanames = { ...');
make_mfile('indent_fcn', 'down');
for idx=1:length(data0)-1;
  if isfield(data0,'stim'),
    fname = DataDef_SignalPreprocessor('getFilename',data0(idx).name);
  else
    fname = DataDef2_RawData('getFilename',data0(idx).name);
  end
  make_mfile('with_indent',[ '''' fname ''' ...']);
end
if isempty(idx), idx=1; else idx=idx+1; end
if isfield(data0,'stim'),
  fname = DataDef_SignalPreprocessor('getFilename',data0(idx).name);
else
  fname = DataDef2_RawData('getFilename',data0(idx).name);
end
make_mfile('with_indent',[ '''' fname '''};']);
make_mfile('indent_fcn', 'up');
make_mfile('with_indent','');


%==================================
%% 1. Stimulation (Mark) Selection
%==================================
if isfield(data0,'stim'),
  make_mfile('code_separator',3); %==
  make_mfile('with_indent', ...
    ['% Make Difference List /', ...
    'Selection List of Stimulation']);
  make_mfile('code_separator',3); %==
  
  %-------------------------------------
  % 1.1 Getting Stimulation-Data-Version
  %-------------------------------------
  % Input Data   : data0
  %                = Group-Data : structure Array
  %
  % Output Data  : stim_verlist
  %                stim_ver1   : 1
  %                stim_ver1_5 : 1.5-2.0
  %                stim_ver2   : 2.0
  stim_verlist=ones(length(data0),1); %(Default : 1)
  tmp=[];
  for idx= 1:length(data0),
    if isfield(data0(idx).stim,'ver'),
      % Check Same Version ?
      if idx==1,
        tmp=data0(idx).stim.ver;
      elseif ~strcmp(tmp,data0(idx).stim.ver),
        warning('Error : Mixd Situmulation Version.'); %#ok
        % error('Error : Mixd Situmulation Version.');
      end
      stim_verlist(idx)=str2double(data0(idx).stim.ver);
    elseif idx~=2 && ~isempty(tmp),
      warning('Error : Mixd Situmulation Version.'); %#ok
      % error('Error : Mixed Situmulation Version.');
    end
  end

  % Index of StimVer
  stim_ver1  =find(stim_verlist<=1);
  stim_ver1  =stim_ver1(:)';

  % ver 1.5/2
  stim_ver1_5=find( (1.4<stim_verlist) & (stim_verlist<2.4));
  stim_ver1_5=stim_ver1_5(:)';

  % ver 2/2.5
  stim_ver2  =find( (1.9<stim_verlist) & (stim_verlist<2.9));
  stim_ver2  =stim_ver2(:)';

  %---------------------------------------
  % 1.2 M-File Setting of Stimulation Select!
  %----------------------------------------

  % Exist Stimulation Version 2.0 Data?
  if ~isempty(stim_ver2),
    % Make selected_stimkind
    make_mfile('code_separator',6); % - -
    make_mfile('with_indent', ...
      {'% Selected Stim-Kind ( GD Version 2.0 )', ...
      'selected_stimkind=cell(1,length(data0));'});
    make_mfile('code_separator',6); % - -
    for idx=stim_ver2
      make_mfile('with_indent', ...
        ['selected_stimkind(idx)=[' ...
        sprintf('%d ',data0(idx).stim.kind) ...
        '];']);
    end
  end

  % Exist Stimulation Version 1.0 Data?
  if ~isempty(stim_ver1),
    % Before Version 1.50..
    % Make cflag{fileid}=flags..
    make_mfile('code_separator',6); % - -
    make_mfile('with_indent', ...
      {'% Set un-used flag (for GD Version 1.0 )', ...
      ['cflg=cell(1,' num2str(length(data0)) ');']});
    make_mfile('code_separator',6); % - -
    for idx= 1:length(data0),
      flgstr = ['cflg{' num2str(idx) '}'];
      if isfield(data0(idx).stim,'StimData'),
        for aStimData = data0(idx).stim.StimData,
          for aStimTime = aStimData.stimtime,
            if any(aStimTime.chflg==false),
              tmp = aStimTime.chflg==0; tmp=tmp(:)';
              tmp = num2str(tmp);
              pts = strfind(tmp,' ');

              % reshape
              ptsp0   = 1;
              tmp2 = {};
              for ptsid=20:20:length(pts),
                tmp2{end+1} = ...
                  [tmp(ptsp0:pts(ptsid)) '...'];
                ptsp0 = pts(ptsid)+1;
              end
              if ptsp0 == length(tmp),
                tmp2{end} = [tmp2{end}(1:end-3) '];'];
              else
                tmp2{end+1}=[tmp(ptsp0:end) '];'];
              end

              make_mfile('with_indent', ...
                [flgstr ' = [ ' flgstr ';, ' ...
                num2str(aStimTime.iniStim) ' ...' ]);
              make_mfile('indent_fcn', 'down');
              make_mfile('with_indent', tmp2);
              make_mfile('indent_fcn', 'up');
            end % if there is Error Data
          end  % One Block Loop
        end % Stim Kind Loop
      end % Stim-Structure version..
    end  % File Loop
    if exist('tmp','var'), clear tmp; end
  end % End of Version 1.0 Data


  % Include Stimulation Version 1.5 Format- Data ?
  if ~isempty(stim_ver1_5),
    make_mfile('code_separator',6); % - -
    make_mfile('with_indent', '% GD Data 1.50');
    make_mfile('code_separator',6); % - -
    make_mfile('with_indent', sprintf('stim_diff=cell([1,%d]);',length(data0)));
  end
  for idx= stim_ver1_5,
    useflg = false;
    %Version 2?
    ver2flg=stim_verlist(idx)>1.9;

    for id = 1:length(data0(idx).stim.diff),
      % Different?
      if data0(idx).stim.diff(id)~=0 || ...
          any(data0(idx).stim.flag(id,:)~=0),
        % Check Difference..
        if all(data0(idx).stim.flag(id,:)==0),
          % Difference is Timing Shift only.
          make_mfile('with_indent', ...
            {'% Stimulation Shift Exist', ...
            ['tmp.stim_id = ' num2str(id) ';'], ...
            ['tmp.shift   = ' num2str(data0(idx).stim.diff(id)) ';'], ...
            'tmp.flag    = [];'});
        elseif all(data0(idx).stim.flag(id,:)),
          % Difference is
          % Don't use any Channel,
          if ~ver2flg || ...
              ~isempty(...
              find(data0(idx).stim.orgn(id,1)==...
              data0(idx).stim.kind(id,1))), %#ok : for MATLAB 6.5.1
            make_mfile('with_indent', ...
              {'% All Channel Removed', ...
              ['tmp.stim_id = ' num2str(id) ';'], ...
              'tmp.shift   = 0;', ...
              ['tmp.flag    = 1:' num2str(size(data0(idx).stim.flag,2)) ';']});
          end
        else
          % Difference is ..
          make_mfile('with_indent', ...
            {'% Differences', ...
            ['tmp.stim_id = ' num2str(id) ';'], ...
            ['tmp.shift   = ' num2str(data0(idx).stim.diff(id)) ';'], ...
            'tmp.flag    = [ '});
          flag_tmp = find( data0(idx).stim.flag(id,:));

          for id0=1:10:size(flag_tmp)-10,
            make_mfile('with_indent', ...
              [num2str(flag_tmp(id,id0:id0+9)) ' ...']);
          end
          make_mfile('with_indent', ...
            [num2str(data0(idx).stim.flag(id,id0+10:end)) '];']);
        end % if Check Flag;

        % Structure Setting
        if (useflg),
          flgstr = 'stim_diff_tmp(end+1)';
        else
          flgstr = 'stim_diff_tmp';
          useflg=true;
        end
        make_mfile('with_indent', [flgstr ' = tmp;']);

      end % if : Change noting?
    end % For Block Loop,
    if (useflg),
      flgstr = ['stim_diff{' num2str(idx) '}'];
      make_mfile('with_indent', ...
        {[flgstr ' = stim_diff_tmp;'],''});
    end
    if exist('tmp','var'), clear tmp; end
  end % Version 1.4 - 2.4 Loop
end % End Stimulation Setting

%==================================
%% 2. Continuous Data Loop Control
%==================================
make_mfile('with_indent','');
make_mfile('code_separator',1); %%%
make_mfile('with_indent','% Continuous Data Operation');
make_mfile('code_separator',1); %%%

%----------------------------------
% 2.1 Load Data
%----------------------------------
make_mfile('with_indent', { ...
    '% Load Signal-Data, See also UC_DATALOAD',  ...
    '[data, hdata] = uc_dataload(datanames{1});'});
make_mfile('with_indent','');
%--------------------------------------
% 2.2 Modify Stimulation along setting.
%--------------------------------------
if isfield(data0,'stim'),
  make_mfile('with_indent', ...
    '% Stimulation Data Setting');

  if ~isempty(stim_ver1_5),
    % Version 1.5 -- (Patch )
    %
    % Stimulation + Diff + Stim type
    
    % Index ?
    make_mfile('with_indent', ...
      'if ~isempty(stim_diff{1}),');
    make_mfile('indent_fcn', 'down');
    
    % Patch
    % Diff-Data + Original ==> New Stim!
    make_mfile('with_indent', { ...
      '[skind, tmp_stim, sflag] = ...', ...
      sprintf('patch_stim2(hdata.stimTC,%d,stim_diff{1},%d);',...
      gdata.data(1).stim.type,...
      size(gdata.data(1).stim.flag,2))});
    make_mfile('with_indent', ...
      'if isempty(skind), continue; end');
    %  Set to Hdata
    make_mfile('with_indent', { ...
      'hdata.stim = [skind, tmp_stim];', ...
      'hdata.flag(1,hdata.stim(:,2),:) = sflag;'});
    
    make_mfile('indent_fcn', 'up');
    make_mfile('with_indent', 'else,');
    make_mfile('indent_fcn', 'down');
  end

  % Difference between Stim Type :
  %  Change to Stimulation Time
  make_mfile('with_indent', { ...
    '% Confine Stimulation Type',  ...
    sprintf('hdata = uc_makeStimData(hdata,%d);', gdata.data(1).stim.type), ...
    ' '});

  if ~isempty(stim_ver1),
    % Versino 1.0 --
    make_mfile('with_indent', { ...
      '% Un-used Flag?',  ...
      'for cflgidx=1:size(cflg{idx},1),'});
    make_mfile('indent_fcn', 'down');
    make_mfile('with_indent', { ...
      'tmp = cflg{1};', ...
      'hdata.flag(1,tmp(cflgidx,1),:) = tmp(cflgidx,2:end);'});
    make_mfile('indent_fcn', 'up');
    make_mfile('with_indent',{'end,   % End of Un-Used Flag', ' '});
  end

  if ~isempty(stim_ver1_5),
    make_mfile('indent_fcn', 'up');
    make_mfile('with_indent', 'end');
  end
  
  % Version 2.0 --
  %  Selected Kind Mode:
  if ~isempty(stim_ver2)
    %'selected_stimkind=cell(1,length(data0));'});
    make_mfile('with_indent', { ...
      '% Selected Kind',  ...
      'hdata = uc_stimtool(''SelectKind'',hdata,selected_stimkind{1});', ...
      ' '});
  end
end % Stimulation Setting

%==================================
% 3. Filter ! : Continuous Data 
%==================================
if isfield(fdata,'HBdata'),
  % -- Set Filter --
  for fidx=1:length(fdata.HBdata),
    try
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
    catch
      make_mfile('with_indent', ...
        sprintf('warning(''write error: at %s'');', fdata.HBdata{fidx}.name));
      warning(lasterr);
    end % try-catch
  end % filter output
end, % HBdata?

% Revision 1.21 : Remove Continous-Loop
make_mfile('with_indent','');
make_mfile('with_indent','cdata = {data};  chdata = {hdata};');
make_mfile('with_indent','');

%==================================
%% 4. Blocking
%==================================
% No - Blocking
if ~isfield(fdata,'BlockPeriod'),
  return;
end
if isfield(fdata,'block_enable') && fdata.block_enable==0,
  return;
end
  
make_mfile('code_separator',1); %%%
make_mfile('with_indent','% Make Block Data');
make_mfile('code_separator',1); %%%
% == Data Blocking ==
if isfield(fdata,'TimeBlocking'),
  blocking=fdata.TimeBlocking{1};
  if isfield(blocking,'enable') && ...
      strcmpi(blocking.enable,'off'),
    return;
  end
  str = P3_PluginEvalScript(blocking.wrap,'write', 'BlockData', blocking);
  if ~isempty(str),
    make_mfile('with_indent', str);
  end
else
  make_mfile('with_indent', ...
    {sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f);', ...
    fdata.BlockPeriod(1), fdata.BlockPeriod(2)), ...
    ' '});
end

%==================================
% 5. Block Data Loop Start.
%==================================
if isfield(fdata,'BlockData'),
  make_mfile('code_separator',1); %%%
  make_mfile('with_indent','% Block Data Operation');
  make_mfile('code_separator',1); %%%
  % -- Set Filter --
  for fidx=1:length(fdata.BlockData),
    try
      if isfield(fdata.BlockData{fidx},'enable') && ...
          strcmpi(fdata.BlockData{fidx}.enable,'off'),
        continue;
      end
      str = ...
        feval(fdata.BlockData{fidx}.wrap,'write', ...
        'BlockData', fdata.BlockData{fidx});
      if ~isempty(str),
        make_mfile('with_indent', str);
      end
    catch
      make_mfile('with_indent', ...
        sprintf('warning(''write error: at %s'');', fdata.BlockData{fidx}.name));
      warning(lasterr);
    end % try-catch
  end % filter output
end, % BlockData?

make_mfile('indent_fcn', 'up');

%===============
% 6. At the end 
%===============
make_mfile('with_indent',' ');
make_mfile('code_separator',1); %%%
make_mfile('with_indent','% Output Formatting...');
make_mfile('code_separator',1); %%%
%-----------------------
% 6.1 Load LAYOUT Data 
% @since 1.10
%-----------------------
if isfield(gdata,'VLAYOUT') && ...
    ~isempty(gdata.VLAYOUT)
  % Group-Data FileName
  fname=DataDef_GroupData('getDataFileName', gdata);
  make_mfile('with_indent', ...
    {'% Load LAYOUT-DATA : FROM LIST', ...
     'try,', ...
     '   hdata.VIEW.LAYOUT= ...', ...
     '      DataDef_GroupData(''getLayoutFromFile'', ...', ...
     ['                        ''' fname ''');'], ...
     'catch', ...
     '   warning(''Couldn''''t Read Layout-Data'');', ...
     'end'});
end

%-----------------------
% 6.2 Rename Variable
%-----------------------
% Recode of OSP-v1.5 9th-Meeting of on 27-Jun-2005.
% Change on 28-Jun-2005 by Shoji.
make_mfile('with_indent', ...
  {'% Rename', ...
    'bdata  = data;', ...
    'bhdata = hdata;', ...
    ' '});
make_mfile('with_indent',{'% End of Block Data', ' '});

return;



