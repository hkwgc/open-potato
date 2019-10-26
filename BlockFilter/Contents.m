% Optical Topography Signal Processing : BlockFilter tools & Filter tools
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Main Controle
%   block_filter            - Block Filter GUI
%   OspFilterMain           - Fileter Main Function
%   OspFilterCallbacks      - GUI of Filter Setting
%   GroupData2Mfile         - Make M-File of GroupData.
%   FilterData2Mfile        - Make M-File of FilterData.
%   osp_FilterBookMark      - I/O of Filter Book-Marking 
%
% Data Definision.
%   makeStimData            - Make Stimulation Data
%   patch_stim              - produce patched stimulation
%   patch_stim2             - reduce stimulation of pathed stim
%   DataDef_GroupData       - Definition of Group Data 
%   OspFilterDataFcn        - Filter Data Definition & Control
%   FilterDef_Butter        - Wrapper of Butter
%   FilterDef_FFT           - Wrapper of FFT
%   FilterDef_LocalFitting  - Wrapper of LocalFitting
%   setArgumentOspLocalFitting - Set Local Fitting argument
%   FilterDef_MovingAverage - Wrapper of MovingAverage
%   FilterDef_PCA           - Wrapper of PCA 
%   FilterDef_Merge_PCA     - Wrapper of Merge PCAa
%   FilterDef_ResizeBlock   - Wrapper of Resize
%   BlockPeriodInputdlg     - Block Period Input dialog
%
% Filtering Function.
%   osp_Local_Fitting       - fit Polynomial for Localized position
%   osp_Movingaverage       - Moving Average for HB-Data
%   ot_bandpass2            - FFT Filter
%   ot_butter               - Wrapper of Butterworth
%   ot_filtfilt             - bandpass
%   otfft1                  - FFT 
%   motioncheck             - Motion Check
%   osp_PCA                 - GUI of PCA
%   osp_PCAfilter           - PCA for Channel
%   merge_PCA               - Add PCA result 
%   filter_function_demo    - sample in user-manual
%
% Blocking Function.
%   changeStimData          - Stimulation Change
%   datablocking            - Blocking
%   sizeOfStrctMultiBlock   - Block Structure Size Check
%

% Removed functions .
%   oteditmark_geted        - For otsigtrns.fig: Find objfect
%   oteditmark_mainsubchld  - For otsigtrns.fig: Set Modified Stimlation
%   ot_blocksep2            - Make block time-series data
%   block_controller        - Old GUI   
%   plot_bcw                - plot function of Block Data
%   stmblk                  - (stimulation block)

% $Id: Contents.m 180 2011-05-19 09:34:28Z Katura $

