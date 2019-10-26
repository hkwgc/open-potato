% Script Filte that Define
%   Display Mode of Filter | Plugin
%
% example : 
%   When you make Filter-Plugin Function,
%   and that function is "Primary" and
%   Adding Some Kind of Data.
%
%   You might be use in createBasicInfo, as following.
%
% function basicInfo=createBasicInfo,
% % setting Display-Kind sample
% basicInfo.name   ='test';
% basicInfo.region = [2:3];
%
% DefineOspFilterDispKind; % Definition of Display Kind.
% % Set Display-Kind 
% basicInfo.DispKind = F_PRIMARYL+F_ADDKIND; 



% $Id: DefineOspFilterDispKind.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



F_BOOKMARK = bitshift(1,4); % Book Mark : Do not use in Plugin

F_General    = bitshift(1,5);
F_TimeSeries = bitshift(1,6);
F_Flag       = bitshift(1,7);
F_DataChange = bitshift(1,8);
F_Control    = bitshift(1,9);

F_TIMESERIES = bitset(0,10);

% ====* POTATo only *====
%  Thoes Filter was not appear,
%  if some Condition was sutticefied.
F_NOTALL     = bitset(0,11);
F_Blocking0  = bitset(0,12);
F_1stLvlAna0  = bitset(0,13);
F_MultAna     = bitset(0,14);

F_Blocking   = bitset(F_NOTALL,12);
F_1stLvlAna  = bitset(F_NOTALL,13);


