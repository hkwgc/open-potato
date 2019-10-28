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

TypeID  = TYPEID_OSPFUNC;
DirID   = DIRID_FILEMANAGE;
GroupID = GROUPID_CONTROL; 

% control  
Contents_function('SetData',TypeID, DirID,GroupID, 'OspDataFileInfo');
Contents_function('SetData',TypeID, DirID,GroupID, 'OspFileList');
Contents_function('SetData',TypeID, DirID,GroupID, 'OspProject');
Contents_function('SetData',TypeID, DirID,GroupID, 'uiFileSelect');
Contents_function('SetData',TypeID, DirID,GroupID, 'uiOspProject');
Contents_function('SetData',TypeID, DirID,GroupID, 'searchPrj')
Contents_function('SetData',TypeID, DirID,GroupID, 'FileFunc')

TypeID = TYPEID_UNUSED;
Contents_function('SetData',TypeID, DirID,GroupID, 'pathandfilename');







