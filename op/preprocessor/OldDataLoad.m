function OSP_LOCALDATA = OldDataLoad(fulpath, flag)
% Load Old-format Signal-Preprocessor Data


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.02.10
% $Id: OldDataLoad.m 180 2011-05-19 09:34:28Z Katura $
%

  % If no input or Empty 
  if ~exist(fulpath) || isempty(fulpath)
    [fn pn] = uigetfile('s_*.mat');
    if isequal(fn,0) || isequal(pn,0)
      return; % Pressed Cancel
    end
    fulpath = [pn filesep fn];
  end

  % Load Data
  load(fulpath,'signal')
  if ~exist('signal','var')
    error([' Old Data is Out of format :'...
	   ' No valuable named ''signal''']);
  end

  % Translate
  OSP_LOCALDATA.HBdata     = signal.chb;
  OSP_LOCALDATA.HBdataTag  =  {'a vector of Hb value before any filtering',...
                    'time','channel',...
		    'hb-kind(Describe HBdata3Tag)'};
  OSP_LOCALDATA.HBdata3Tag =  {'Oxy','Deoxy','Total'};
  % Default Color of Plot: red, blur, black
  OSP_LOCALDATA.HBcolor    =  [ 1 0 0; 0 0 1; 0 0 0]; 
  OSP_LOCALDATA.info  =  rmfield(signal,'chb');
  clear signal;

  try
	  tmpdate = OSP_LOCALDATA.info.date;
      if isnumeric(tmpdate)
          % Do noting
      elseif regexp(tmpdate,'^\d\d\d\d/')
		  % Syle 1 ( like 2005/01/24 16:20 )
		  date0=[0 0 0 0 0 0];
		  tmpdate=strrep(tmpdate,'/',' ');
          tmpdate=strrep(tmpdate,':',' ');
		  tmpdate=str2num(char(tmpdate));
		  date0(1:length(tmpdate))=tmpdate(:);
		  tmpdate= datenum(date0);
	  else
		  tmpdate = datenum(date);
	  end
	  OSP_LOCALDATA.info.date  =  datenum(tmpdate);
  catch
	  warning(['Date(' OSP_LOCALDATA.info.date ') is not a Date format']);
	  OSP_LOCALDATA.info.date  =  now;
  end
  try
	  OSP_LOCALDATA.info.age  =  OSP_LOCALDATA.info.age(1);
  end

  % Save To File, with Search Key
  if ~exist('flag','var')  || flag==1
    % Save Data
    OSP_DATA('SET','OSP_LocalData',OSP_LOCALDATA);
    DataDef_SignalPreprocessor('save');
  end

return;
