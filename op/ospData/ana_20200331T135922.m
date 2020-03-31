% ANA_20200331T135922, make POTATo data.
%
% == Analysis-Data-Information ==
% Project : /Users/kwgc/Desktop/PoTATo_Project
%           Data
% Operator: P3 User
%   Name  : sample_LT1
% 
% Date : 31-Mar-2020 13:59:22
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
   '/Users/kwgc/Desktop/PoTATo_Project/Data/RAW_sample_LT1.mat'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continuous Data Operation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Signal-Data, See also UC_DATALOAD  
[data, hdata] = uc_dataload(datanames{1});


cdata = {data};  chdata = {hdata};

