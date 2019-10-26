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
DirID  = DIRID_PROBEPOSITION;
GroupID = GROUPID_POSSET;

Contents_function('SetData',TypeID, DirID,GroupID, 'setProbePosition');
Contents_function('SetData',TypeID, DirID,GroupID, 'copyPositionData');
Contents_function('SetData',TypeID, DirID,GroupID, 'uiFileSelectPP');
Contents_function('SetData',TypeID, DirID,GroupID, 'etg_pos_fread');
Contents_function('SetData',TypeID, DirID,GroupID, 'etg_pos_dataread');
Contents_function('SetData',TypeID, DirID,GroupID, 'getDefault_ch_pos3');

TypeID = TYPEID_UNUSED;
GroupID = GROUPID_OTHER;
% Function to Get Multi-files 

