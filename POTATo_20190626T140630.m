% ANA_20190626T140634, make POTATo data.
%
% == Analysis-Data-Information ==
% Project : Z:\Desktop\Potato\P3_files\P38\Projects
%           Sample project
% Operator: POTATo User
%   Name  : sample_LT1
% 
% Date : 26-Jun-2019 14:06:34
% 
% == Recipe Information ==
% * Time-Blocking

% - - - - - - - - - - - - - - - - - - - 
% Platform for Optical Topography Analysis Tools III
% Function : GroupData2Mfile : $Revision: 1.24 $
% - - - - - - - - - - - - - - - - - - - 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous Data Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datanames = { ...
   'Z:\Desktop\Potato\P3_files\P38\Projects\Sample project\RAW_sample_LT1.mat'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous Data Operation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Signal-Data, See also UC_DATALOAD  
[data, hdata] = uc_dataload(datanames{1});


cdata = {data};  chdata = {hdata};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Block Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == Blocking ==
%    FilterDef_TimeBlocking v1.0 
[data, hdata] = uc_blocking(cdata, chdata,5.000000,15.000000,'All');
                                                                    
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Formatting...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rename       
bdata  = data; 
bhdata = hdata;
               
% End of Block Data
                   
