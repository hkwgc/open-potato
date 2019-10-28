function varargout=preprocessor_otsigtrnschld2(fname, pfunc,pplugin),
% otsigtranschld2 is  Wrapper of Load OSP Data from File
%   Set OSP_DATA's OSP_LocalData
%
% Sytnax :
%   flag = otsigtrnschld(fname, pfunc);
%
% Input :
%    fname : Filename of load data
%    pfunc : Pointer of Preprocessor Function.
% Output :
%  flag2 is
%    1 :  user want to Stop Convert
%    0 :  other case
%
% Upper Link :  Signal-Preprocessor
% Lower Link : OSP_DATA, ot_dataload,
%
% Now we return

% $Id: preprocessor_otsigtrnschld2.m 180 2011-05-19 09:34:28Z Katura $
% Reversion 1.0:
%   23-Dec-2005
%   Inport from
%       :: otsigtrnschld.m,v 1.8 2005/12/13 02:40:59 shoji Exp


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




%%%%%%%%%%%%%%%
% Initialize
%%%%%%%%%%%%%%%

if nargout== 1, varargout{1}=false;end % Set Default Return Value
fullname=char(fname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Preprocessing Function Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Basic Information
basic_info = feval(pfunc, 'createBasicInfo');
% Accept the file? :
%   File Check
[flg,msg]   = feval(pfunc, 'CheckFile',fullname);
if flg==false,
  error(['Can not preprocessing: ' msg]);
end

% Select File I/O by basic_info.
switch (basic_info.IO_Kind),
  case 0,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  I/O Mode 0 :
    % Exist ExecuteOld : Save as OSP version 1.5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
      OT_LOCAL_DATA = feval(pfunc,'ExecuteOld',fullname);
      OSP_DATA('SET','OSP_LocalData',OT_LOCAL_DATA);
    catch
      ansn=questdlg(strcat('Input data does not seem OT format.==>',filename), ...
        'Check data type from suffix', ...
        'Skip this file', 'Stop process', 'Skip this file');
      switch ansn
        case 'Skip this file',
          return;
        case 'Stop process',
          if nargout== 1, varargout{1}=1;end
          return;
      end % switch question
    end % try-catch
    
    %==> This is old code : cannot reload
    disp('Preprocessor MODE 0 : Error');
    disp('                      Cannot Select Mode 0');
    DataDef2_RawData('save');	% OLD-MODE

  case 1,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % I/O Mode 1 :
    % Exist Execute : Save as OSP version 1.8
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
      [hdata, data] = feval(pfunc,'Execute',fullname);
    catch
      [p, f, e]=fileparts(fullname);
      filename=[f e];
      ansn=questdlg(strcat('Input data does not seem OT format.==>',filename), ...
        'Check data type from suffix', ...
        'Skip this file', 'Stop process', 'Skip this file');
      switch ansn
        case 'Skip this file',
          return;
        case 'Stop process',
          if nargout== 1, varargout{1}=1;end
          return;
      end % switch question
    end % try-catch
    
    %==================================
    % Execute Preprocessor Plugin!!
    %==================================
    try
      if exist('tmp_plugin','file')
        [hdata,data]=tmp_pplugin(hdata,data);
      end
    catch
      warning(['Pre-Processor Plugin Error : ' lasterr]);
    end
    
    %==================================
    % Save Data as RawData
    %==================================
    DataDef2_RawData('save',hdata,data);

  otherwise,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Undefined I/O Kind
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error(['Undefined : I/O Kind : ' func2str(pfunc)]);
end % Switch I/O Kind

return;


