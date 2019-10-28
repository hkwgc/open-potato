function varargout=otsigtrnschld(varargin)
% otsigtranschld is  Wrapper of Load OSP Data from ETG File
%   Set OSP_DATA's OSP_LocalData
%
% flag = otsigtrnschld(FullPath)
% flag = otsigtrnschld(path,fname)
%  
%  FullPath or  char({path,fname}) is
%      File name of Load-ETG-Data-File
%      ( File that can be read is depend on ot_dataload )
%
%  flag is
%    1 :  user want to Stop Convert
%    0 :  other case
%
% Upper Link : 
%  Signal-Preprocessor
% Lower Link : 
%  OSP_DATA
%  ot_dataload
%
% Now we return


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: otsigtrnschld.m 180 2011-05-19 09:34:28Z Katura $

% -- init  --
  if nargout== 1, varargout{1}=0;end % Set Default Return Value

  fullname=char(varargin);
  [pathname, filename]=pathandfilename(fullname);

  % --- File Check ---
  %   --> Move to signal preprocessor
  if 0
    svfnm = strcat(pathname, 's_', filename(1:end-3), 'mat');               
    if exist(svfnm, 'file') == 2
      ans0=questdlg(strcat(svfnm,' : File is already exist. Do you want to contuinue?'),...
		    'OverWrite?',....
		    'Yes','No','Yes');
      if strcmp(ans0,'No'), return; end
    end
  end

  %from medico rawdata->signal data

  old  = regexpi(filename,'^s_(.*)[.]mat$');
  old  = ~isempty(old); % Old-File Format : True
  old2 = regexpi(filename,'^HB_(.*)[.]mat$');
  old2 = ~isempty(old2); % OSP version 1.10 Format True
        
  %Check input-data type from suffix
  % Added by Atsumori,Hitachi,July 1 2004
  %      Chnage & -> &&, Add Old Vertion 
  %      Change strcmp -> strcmpi and reduction.
  if strcmpi(filename(end-2:end),'dat')    || ...
	strcmpi(filename(end-2:end),'mea') || ...
	strcmpi(filename(end-2:end),'csv') || ...
	old                                || ...
	old2, 
    % Version Change .. :  Data load from OT format
    [ldata]=ot_dataload( filename, pathname );
    OSP_DATA('SET','OSP_LocalData',ldata);
  else,
    try,
      % for test mode
      if strcmpi(filename(end-4:end),'.hoge'),
          ldata=sp_load(filename,pathname);
          OSP_DATA('SET','OSP_LocalData',ldata);
      else
          ldata = sz_format_load(filename, pathname);
          OSP_DATA('SET','OSP_LocalData',ldata);
      end
    catch,
      ldata=[]; 
    end

    % no special format.
    if isempty(ldata),
      ansn=questdlg(strcat('Input data does not seem OT format.==>',filename), ...
		    'Check data type from suffix', ...
		    'Skip this file', 'Stop process', 'Skip this file');
      switch ansn
       case 'Skip this file',
	return;
       case 'Stop process',
	if nargout== 1, varargout{1}=1;end
	return;
      end
    end % end check
  end % end special case.
  
						    
     
  % Make FFT Data & Add Field to signal
  %  -> FFT Data is not need
  if 0
    [signal.hbfrq,signal.hbfrqhlf,signal.hbfrqvax] = ...
	otfft1(ldata.HBdata ,...
	       1,ldata.info.sampleperiod);%get frequency data
    signal=setfield(signal,...
		    'hbfrqtag',...
		    {'a vector of shifted fft Hb value before any filtering',...
		     'time','channel','hb-kind(oxy,deoxy,total)'});
    signal=setfield(signal, ...
		    'hbfrqhlftag',...
		    {'a vector of shifted half-fft Hb value before any filtering',...
		     'time','channel','hb-kind(oxy,deoxy,total)'});
    signal=setfield(signal, ...
		    'hbfrqvaxtag',...
		    {['a vector of frequency values for shifted half-fft Hb'...
		      '=> numbers of x-axis for plot '], ...
		     'frequency [Hz]'});
  end
  
  % it is not effective if file is not last one.
  % -- there was a Reload File Data Information --
  % CUT by H.Atsumori July 13 2004
  
  % CUT by H.Atsumori July 12 2004
   
  %===========================
  % Marker Edit, if Number of Marker is Odd number
  %===========================
  % %Editmar mode
  % a = mod(length(find(signal.modstim>0.5)),2); 
  % 
  % if a
  %     kEdimark_mainsubchld(signal,'start','fig',hh(1));
  %     uiwait;
  %     signal=getappdata(hh(1),'signal');
  % end        
  %===========================
  % by TK 040722
  %===========================

        
  %file name
  %  Save New Version Data
  DataDef_SignalPreprocessor('save');

  % -- Remove : if Data is end --
  %  disp(' Save s_ data for olod version .. ') ;
  %  svfnm = strcat(pathname, 's_', filename(1:end-3), 'mat');
  %  signal=ldata.info;
  %  signal.chb = ldata.HBdata;
  %  save(svfnm,'signal');    

  % fclose all;
  
return;


