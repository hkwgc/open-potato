% The Script File get Function Information in the Directory


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% #define,
Contents_Script_Header;

DirID  = DIRID_BLOCKFILTER;

% -- OSP use function --
TypeID = TYPEID_OSPFUNC;

% Control
GroupID = GROUPID_CONTROL;
Contents_function('SetData',TypeID, DirID,GroupID, 'GroupData2Mfile');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterData2Mfile');

% Blocking
GroupID = GROUPID_BLOCKING;
Contents_function('SetData',TypeID, DirID,GroupID, 'block_filter');
Contents_function('SetData',TypeID, DirID,GroupID, 'DataDef_GroupData');
Contents_function('SetData',TypeID, DirID,GroupID, 'makeStimData');
Contents_function('SetData',TypeID, DirID,GroupID, 'patch_stim');
Contents_function('SetData',TypeID, DirID,GroupID, 'patch_stim2');


% Filter
GroupID = GROUPID_FILTER;
Contents_function('SetData',TypeID, DirID,GroupID, 'OspFilterMain');
Contents_function('SetData',TypeID, DirID,GroupID, 'OspFilterDataFcn');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_Movingaverage');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_FFT');
Contents_function('SetData',TypeID, DirID,GroupID, 'motioncheck');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_PCA');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_Merge_PCA');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_MovingAverage');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_LocalFitting');
Contents_function('SetData',TypeID, DirID,GroupID, 'setArgumentOspLocalFitting');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_Butter');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_PCA');
Contents_function('SetData',TypeID, DirID,GroupID, 'merge_PCA');
Contents_function('SetData',TypeID, DirID,GroupID, 'changeStimData');
Contents_function('SetData',TypeID, DirID,GroupID, 'datablocking');
Contents_function('SetData',TypeID, DirID,GroupID, 'sizeOfStrctMultiBlock');
Contents_function('SetData',TypeID, DirID,GroupID, 'OspFilterCallbacks');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_FilterBookMark');
Contents_function('SetData',TypeID, DirID,GroupID, 'FilterDef_ResizeBlock');
Contents_function('SetData',TypeID, DirID,GroupID, 'BlockPeriodInputdlg');


% ==============================
% --  User Command --
% ==============================
TypeID = TYPEID_USERCOMMAND;
% Blocking
GroupID = GROUPID_BLOCKING;

% Filter
GroupID = GROUPID_FILTER;
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_Local_Fitting');
Contents_function('SetData',TypeID, DirID,GroupID, 'ot_filtfilt');
Contents_function('SetData',TypeID, DirID,GroupID, 'ot_bandpass2');
Contents_function('SetData',TypeID, DirID,GroupID, 'ot_butter');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_PCAfilter');

% ==============================
% --  Unuded Command --
% ==============================
TypeID = TYPEID_UNUSED;
% Blocking
GroupID = GROUPID_BLOCKING;
Contents_function('SetData',TypeID, DirID,GroupID, 'block_controller');
Contents_function('SetData',TypeID, DirID,GroupID, 'stmblk');

% Filter
GroupID = GROUPID_FILTER;
Contents_function('SetData',TypeID, DirID,GroupID, 'otfft1');

GroupID = GROUPID_VIEWER;
Contents_function('SetData',TypeID, DirID,GroupID, 'plot_bcw');


GroupID = GROUPID_VIEWER;
Contents_function('SetData',TypeID, DirID,GroupID, 'filter_function_demo');


% ==============================
% --  Unuded Command --
% ==============================
TypeID = TYPEID_MATLAB;
DirID  = DIRID_OTHER;
% Blocking
GroupID = GROUPID_BLOCKING;
Contents_function('SetData',TypeID, DirID,GroupID, 'permute');
