% The Script File get Function Information in the Directory

% #define,
Contents_Script_Header;

TypeID = TYPEID_USERCOMMAND;
DirID  = DIRID_USERCOMMAND;

% control  
GroupID = GROUPID_CONTROL; 

% prepro
GroupID = GROUPID_PREPROCESSOR;
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_dataload');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_makeStimData');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_addraw');

% block
GroupID = GROUPID_BLOCKING;
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_blocking');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_blockmean');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_resize');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_blknanset');

% filter
GroupID = GROUPID_FILTER;	 
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_motioncheck');

% viewer
GroupID = GROUPID_VIEWER;  
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_plot_data');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_image');
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_image_plot');

% tool
GroupID = GROUPID_TOOLS;
Contents_function('SetData',TypeID, DirID,GroupID, 'uc_help');

% Contents_function('SetData',TypeID, DirID,GroupID, '');

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

