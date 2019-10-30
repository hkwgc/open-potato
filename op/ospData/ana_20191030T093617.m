% ANA_20191030T093617, make POTATo data.
%
% == Analysis-Data-Information ==
% Project : /Users/kwgc/Desktop/Potato/release-3.9.0/op/Projects
%           Sample project
% Operator: POTATo User
%   Name  : sample_LT1
% 
% Date : 30-Oct-2019 09:36:17
% 
% == Recipe Information ==

% - - - - - - - - - - - - - - - - - - - 
% Platform for Optical Topography Analysis Tools III
% Function : GroupData2Mfile : $Revision: 1.24 $
% - - - - - - - - - - - - - - - - - - - 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous Data Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datanames = { ...
   '/Users/kwgc/Desktop/Potato/release-3.9.0/op/Projects/Sample project/RAW_sample_LT1.mat'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous Data Operation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Signal-Data, See also UC_DATALOAD  
[data, hdata] = uc_dataload(datanames{1});


cdata = {data};  chdata = {hdata};

