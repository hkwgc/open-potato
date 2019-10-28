function [bdata, bheader, data, header]=example_bach(fn, datapath)
% Example for Bach operation of OSP version 1.50
%
%--  Example Function : Do following process --
%  1. Read ETG file
%  2. Block Filter
%  3. Filter
%  4. Make Block
%
% Syntax:
%   [bdata, bheader, data, header]=example_bach(fn, datapath)
%
%  -- Input --
%  fn       : Filename List ( Cell ) 
%  datapath : Path of data files
%
%  -- output --
%　bdata    : Block Data
%  bheader  : Block Header Data
%  data     : Continuous Data
%  Header   : Continuous Header Data
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2005.04.07
% $Id: example_bach.m 180 2011-05-19 09:34:28Z Katura $

  % 0. Argument Checking
  osppath = fileparts(which('OSP'));
  if isempty(osppath)
    error('[E] Can not Find OSP Functions.');
  end
  
  if nargin < 1
    fn = {'t0.dat', 't1.dat'};
  end

  if nargin < 2
    datapath=[osppath filesep 'UserCommand' filesep 'example' filesep];
  end

  % OSP Path Setting
  setOspPath;

  % --- Howdy ---
  disp('--------------------------------');
  disp(' Howdy, OSP Command base World!');
  disp('--------------------------------');
  

  % === Loop for Files ( One data ) ===
  for fid = 1:length(fn),
    fnm = fn{fid};  % Select a File

    % ***** 1. Read ETG file *****
    % --- HB data get --- 
    [data{fid}, header{fid}] = uc_dataload(fnm, datapath);

    % ***** 2. Block Filter  *****
    %       *  2.1  Block Make
    header{fid} = uc_makeStimData(header{fid},2); % Change Event->Block

    %       *  2.2  Motion Check
    % --- Motion Check ---  ( for UserCommand Data)
    %      Warning!!
    %        Check 3sigma is not normal motioncheck
    header{fid} = uc_motioncheck(data{fid}, 3, header{fid}, 0.1, ...
				 1.5, '3sigma');
    
    % ***** 3. Filter        *****
    %       * 3.1 Local Fitting
    % -- Filtering --- 
    % Local Fitting ( Polyfit-Deff)
    data{fid} = osp_Local_Fitting(data{fid}, [1 2], 1, 2);

    %       * 3.2 Band Path 
    if exist('butter','file')
      [b,a]=ot_butter(0.02,0.8,1000/header{fid}.samplingperiod, 5,'bpf');
      data{fid} = ot_filtfilt(data{fid},a,b,1);
    else
      warning('No function : butter');
    end

    % * -- (Plot Here) --
    uc_plot_data(header{fid}, data{fid}, 'STIMPLOT', 'on');
  end
  % === End of Loop for Files  ===

  % ***** 4. Make Block    *****
  % == Data Blocking ==
  % Last argument is using-StimKind,
  % if there is no StimKind, use 1-10, for default.
  [bdata, bheader] = uc_blocking(data, header, 10, 10, 1);

  % * -- (Plot Here) --
  uc_plot_data(bheader, bdata);
  % * -- (Image Loock) --
  uc_plot_data(bheader, bdata);

  % OSP Path Removing
  if 0
    cwd = pwd;
    try
      cd(osppath); undostartup; cd(cwd);
    catch
      cd(cwd); rethrow(lasterror);
    end 
  end
  
return;
