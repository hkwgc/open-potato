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

TypeID = TYPEID_OSPFUNC;
DirID  = DIRID_PREPRECESSOR;

GroupID = GROUPID_CONTROL;
Contents_function('SetData',TypeID, DirID,GroupID, 'SignalData2Mfile');

GroupID = GROUPID_PREPROCESSOR;
Contents_function('SetData',TypeID, DirID,GroupID, 'signal_preprocessor');
Contents_function('SetData',TypeID, DirID,GroupID, 'otsigtrnschld2');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_chbtrans');
Contents_function('SetData',TypeID, DirID,GroupID, 'DataDef_SignalPreprocessor');
Contents_function('SetData',TypeID, DirID,GroupID, 'default_OSP_LOCAL_DATA_v1');
Contents_function('SetData',TypeID, DirID,GroupID, 'ot2ucdata');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproETG7000');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproFVer2_02');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproFVer3_02');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproFVer4_04');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproOSP_SPDATAv1');
Contents_function('SetData',TypeID, DirID,GroupID, 'preproSZ');

% From here on : Un Used Functions.
TypeID = TYPEID_UNUSED;
Contents_function('SetData',TypeID, DirID,GroupID, 'OldDataLoad');
Contents_function('SetData',TypeID, DirID,GroupID, 'ot_dataload');
Contents_function('SetData',TypeID, DirID,GroupID, 'otsigtrnschld');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_chbtrans2');
Contents_function('SetData',TypeID, DirID,GroupID, 'sz_format_load');
Contents_function('SetData',TypeID, DirID,GroupID, 'sp_load');

GroupID = GROUPID_OTHER;
% Function to Get Multi-files 
Contents_function('SetData',TypeID, DirID,GroupID, 'groupingLoadFile');
Contents_function('SetData',TypeID, DirID,GroupID, 'getHBFiles');
Contents_function('SetData',TypeID, DirID,GroupID, 'getMultiFiles');
