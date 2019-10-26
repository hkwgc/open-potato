% The Script File get Function Information in the Directory

% #define,
Contents_Script_Header;

TypeID = TYPEID_OSPFUNC;
DirID  = DIRID_OSP;

% control  
GroupID = GROUPID_CONTROL; 
Contents_function('SetData',TypeID, DirID,GroupID, 'OSP');
Contents_function('SetData',TypeID, DirID,GroupID, 'OSP_DATA');
Contents_function('SetData',TypeID, DirID,GroupID, 'startup');
Contents_function('SetData',TypeID, DirID,GroupID, 'undostartup');

TypeID = TYPEID_USERCOMMAND;
Contents_function('SetData',TypeID, DirID,GroupID, 'setOspPath');
% Contents_function('SetData',TypeID, DirID,GroupID, '');
