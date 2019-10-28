function LE_testdraw(hs)
% Test-Draw in Layout-Editor


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2007.02.22
%
% $Id: LE_testdraw.m 180 2011-05-19 09:34:28Z Katura $
%
%----------------------------------
%  1.2 : add Empty Layout Exception
%----------------------------------

%=======================
% Make Temp Layout-Data
%=======================
f=which(mfilename);
p=fileparts(f);
% F1 (Save-Data (5))
Lparts_Manager('saveLPO',hs);
layoutfile =[p filesep 'TestData' filesep 'tmplayout.mat'];
try
  LayoutEditor('AppLayout2LayoutFileIO',hs.figure1,[],hs, layoutfile);
catch
  % Might be Empty Layout Exception
  helpdlg({'Cound not Make Layout',...
      '   : Make Layout at First!',...
      '',...
      ['   : ' lasterr]},'No-Layout')
  return;
end

%=======================
% Make Draw-Data
%=======================
datafile   = [p filesep 'TestData' filesep 'data0.mat'];
[data, hdata] = uc_dataload(datafile);
[bdata, bhdata] = uc_blocking({data}, {hdata},5.000000,15.000000);

load(layoutfile,'LAYOUT');
%=================
% Load Layout Data
%=================
osp_LayoutViewer(LAYOUT,{hdata},{data}, ...
  'bhdata',bhdata, 'bdata', bdata);
