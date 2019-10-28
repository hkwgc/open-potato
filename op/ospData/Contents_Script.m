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
DirID  = DIRID_OSPDATA;

% control  
GroupID = GROUPID_CONTROL; 
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_KeyBind');
% other
GroupID = GROUPID_OTHER;


