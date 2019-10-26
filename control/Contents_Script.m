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
DirID  = DIRID_CONTROL;
GroupID = GROUPID_CONTROL; 

% control  
Contents_function('SetData',TypeID, DirID,GroupID, 'gui_buttonlock');
Contents_function('SetData',TypeID, DirID,GroupID, 'OSP_About');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ComDeleteFcn');
Contents_function('SetData',TypeID, DirID,GroupID, 'OSP_STIMPERIOD_DIFF_LIMIT')
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ini_fin');
Contents_function('SetData',TypeID, DirID,GroupID, 'OSP_LOG');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_logo');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_set_colormap');
Contents_function('SetData',TypeID, DirID,GroupID, 'SetColor');
Contents_function('SetData',TypeID, DirID,GroupID, 'Multi_file_Mfile_Out');

TypeID = TYPEID_USERCOMMAND;
% Contents_function('SetData',TypeID, DirID,GroupID, '');
