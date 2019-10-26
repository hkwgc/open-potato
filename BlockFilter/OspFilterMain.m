function [data, stim, ecode] = OspFilterMain(data, stim ,...
					     fdm, stop_region)
% OSP Filter Function : main-routine
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
% -------------------------------------
%
%  This function will be removing soon. 
%	Use GroupData2Mfile instead of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OspFilterMain
%    Apply Filter to OSP_DATA 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [data, stim] = OspFilterMain(data, stim ,fdm, stop_region)
% data is HB data matrix
%     Time x Channel x HB Kind
% 
% stim is Structure of Stimulation Data 
%    
% fdm is Structure of Filtering Region
%   fdm.Raw       : structure array of FilterData, for RawData
%   fdm.BlockPeriod : [prestim, poststim] in unit [sec].
%   fdm.HBdata    : structure array of FilterData, for HB Data
%   fdm.BlockData : structure array of FilterData, for Blocked Data
%
%  Filter Data is
%   filterData.name    : filter name
%   filterData.wrap    : filter Wrapperr name
%   filterData.argData : Arguments of filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Lower Link :
%  Filter Function :
% See also OSPFILTERDATAFCN, 
%          FILTERDEF_MOVINGAVERAGE,
%          FILTERDEF_LOCALFITTING,
%          FILTERDEF_BUTTER,
%          FILTERDEF_FFT.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2004.12.28
% $Id: OspFilterMain.m 180 2011-05-19 09:34:28Z Katura $
%





  ecode.Tag = ' Filter Data ErrorCode 1:Error, 0: Normal';
  warning([mfilename ' will be removing soon. ' ...
	  'GroupData2Mfile can be available .']);
  
  % ==== Argument Check =========
  % if no argument Read HB Data
  if nargin <= 0
    % Error : 06-Jan-2005
    error('Too few Argument');
    ldata = OSP_DATA('Get', 'OSP_LocalData');
    data = ldata.HBdata;
    if isfield(ldata, 'StimInfo')
      stim = ldata.StimInfo;
    else
      stim = ldata.info.stim;
    end
    if isfield(ldata, 'Filter')
      fdm = OSP_DATA('GET','FILTER_MANAGER');
    else
      error('No Filter Data');
    end
    clear ldata;
  elseif nargin <= 3
    error('Too few Argument');
  end
  
  if nargin<4
    stop_region = 'none';
  end


  % == RAW DATA FILTERING ==
  if isfield(fdm,'Raw')
    warning('Raw Data Filter is not allowed!');
    if nargin==0
      % Question Continue? 
      ans0 = questdlg('Do you want to Transfer?', ...
		      'Raw-Data Filter', ...
		      'Yes','No','Yes');
      if strcmp(ans0,'No'), return;  end

      % Load Raw Data ( if need )
      if nargin==0
	% Error : 06-Jan-2005
	error('Too few Argument');
	data = OSP_DATA('GET','OSP_LocalData');
	data = data.info;
	try 
	  wavelength = data.wavelength;
	  data=data.data;
	catch
	  errordlg(' No Raw Data exist ');
	  return;
	end
      end

      % OSP Filter
      ecodeRaw=[];
      for filterData = fdm.Raw
	try
	  data= ...
	      feval(filterData.wrap,'exe',...
		    'Raw', ...
		    filterData, data); % stimulation not in use
	  ecodeRaw(end+1)=0;
	catch
	  errordlg({['- Filtering Error : ' filterData.name], ...
		    ['   Error : ' lasterr]});
	  ecodeRaw(end+1)=1;
	end % try/catch
      end % Raw Filter
      ecode.Raw = ecodeRaw;

      if strcmp(stop_region,'Raw'), return; end
      % Raw -> HB Translation
      % !! Last argument is not used. See also osp_chbtrans2
      data = osp_chbtrans(data,wavelength,0); 
    end
  end  % Raw Filtering
  if strcmp(stop_region,'Raw'), return; end


  % == HB DATA FILTERING ==
  if isfield(fdm,'HBdata')
    % OSP Filter
    ecodeHB=[];
    for filterData = fdm.HBdata
      try
	data= ...
	    feval(filterData.wrap,'exe',...
		  'HBdata', ...
		  filterData, data); % stimulation not in use
	ecodeHB(end+1)=0;
      catch
	errordlg({['- Filtering Error : ' filterData.name], ...
		  ['   Error : ' lasterr]});
	ecodeHB(end+1)=1;
      end % try/catch
    end % HB Data Filter
    ecode.HBdata = ecodeHB;
  end % HBdata Filtering
  if strcmp(stop_region,'HBdata'), return; end

  % === Block Filter ===
  OSP_LOG('perr', ...
	  'Not Defined : Block Filter in OspFilterMain ', ...
	  ' Use datablocking');

  % Make Stimulation Data
  if ~isempty(stim) && ~isstruct(stim) && isnumeric(stim) 
    % Default Stimulation
    %   -> (Stimulation is ETG format) -> Change 
    stim=makeStimData(stim(:),2,[1000 1500]);  
  end
  stimData=stim.StimData;
  clear stim;

  stim = stimData;

return;

