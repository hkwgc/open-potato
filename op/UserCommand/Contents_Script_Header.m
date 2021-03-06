% The Script File get Function Information in the Directory
% Initialize Input Data

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%================================
% #define,( enum Like )
%          CONSTANCE
% TYPE ID : 
%================================
TYPEID_ANY          =    0;
TYPEID_OSPFUNC      =    1; % bitshift( 1,  0); 
TYPEID_USERCOMMAND  =    3; % bitshift( 1,  1) + OSPFUNC; 
TYPEID_MATLAB       =    4; % bitshift( 1,  2)
TYPEID_UNUSED       =    8; % bitshift( 1,  3)
TYPEID_SPM99        =   16; % bitshift( 1,  4)
% since : 12-Aug-2005
% Change + OSP Function
TYPEID_OSP_PLUGIN  =    bitset(TYPEID_OSPFUNC,6); % bitshift( 1,  5)

TypeStr = {'Any Function', ...
	   'OSP Function', ...
	   'User Command', ...
	   'MATLAB General Function', ...
	   'SPM99', ...
	   'Unused', ...
	   'Plug-In'};
TypeIDX =[...
    TYPEID_ANY         , ...
    TYPEID_OSPFUNC     , ...
    TYPEID_USERCOMMAND , ...
    TYPEID_MATLAB      , ...
    TYPEID_SPM99       , ...
    TYPEID_UNUSED      , ...
    TYPEID_OSP_PLUGIN];

%================================
% #define,( enum Like )
%          CONSTANCE
% Directory ID : 
%
% memo : how to make
%  cd(fileparts(which('OSP')));
%  S=dir; flg=[S.isdir]; dirname={S.name};
%  Dirname = upper(char({dirname{find(flg)}}));
%  Dirname =[repmat('DIRID',size(Dirname,1),1), Dirname] 
%   cut & add 
%================================
DIRID_ANY          =    0;
DIRID_ANALYSIS     =    1; % bitshift( 1,  0); 
DIRID_BLOCKFILTER  =    2; % bitshift( 1,  1); 
DIRID_DATAGROUP    =    4; % bitshift( 1,  2); % not in use  
DIRID_SPMTRANSFER  =    8; % bitshift( 1,  3); 
DIRID_USERCOMMAND  =   16; % bitshift( 1,  4); 0x10
DIRID_CONTROL      =   32; % bitshift( 1,  5); 
DIRID_FILEMANAGE   =   64; % bitshift( 1,  6); 
DIRID_OSPDATA      =  128; % bitshift( 1,  7); 
DIRID_PREPRECESSOR =  256; % bitshift( 1,  8); 0x100
DIRID_USER_TOOLS   =  512; % bitshift( 1,  9); 
DIRID_VIEWER       = 1024; % bitshift( 1, 10); 
DIRID_OSP          = 2048; % bitshift( 1, 11); 
DIRID_OTHER        = 4096; % bitshift( 1, 12); 
DIRID_PROBEPOSITION= 8192; % bitshift( 1, 13); 
DIRID_PLUGINDIR    =16384; % bitshift( 1, 14); 
DIRID_VIEWERAXES   =bitset(DIRID_VIEWER,16);
DIRID_VIEWERCALLB  =bitset(DIRID_VIEWER,17);

%DirStr = {};
DirIDX =[...
    DIRID_ANY         , ...
    DIRID_ANALYSIS    , ...
    DIRID_BLOCKFILTER , ...
    DIRID_DATAGROUP   , ...
    DIRID_SPMTRANSFER , ...
    DIRID_USERCOMMAND , ...
    DIRID_CONTROL     , ...
    DIRID_FILEMANAGE  , ...
    DIRID_OSPDATA     , ...
    DIRID_PREPRECESSOR, ...
    DIRID_USER_TOOLS  , ...
    DIRID_VIEWER      , ...
    DIRID_OSP         , ...
    DIRID_OTHER       , ...
    DIRID_PROBEPOSITION , ...
    DIRID_PLUGINDIR   , ...
    DIRID_VIEWERAXES  , ...
    DIRID_VIEWERCALLB];


%================================
% #define,
%          CONSTANCE
% Group ID :
%   GROUPID_ + upper
%
% memo : how to make
%  get uc_help pop_group_CreateFcn, groupStr,
%
%  upper(char(groupStr))
%  Copy & paset
%  in emacs copy & past command
%    -> (Ctrl+x, r, k) & (Ctrl+x, r, y)
%================================
GROUPID_ANY          =    0;
GROUPID_CONTROL	     =    1; % bitshift( 1,  0); 
GROUPID_PREPROCESSOR =    2; % bitshift( 1,  1); 
GROUPID_BLOCKING     =    4; % bitshift( 1,  2); 
GROUPID_FILTER	     =    8; % bitshift( 1,  3); 
GROUPID_VIEWER	     =   16; % bitshift( 1,  4); 0x10
GROUPID_TOOLS        =   32; % bitshift( 1,  5); 
GROUPID_ANALYSIS     =   64; % bitshift( 1,  6); 
GROUPID_OTHER        =  128; % bitshift( 1,  7); 
GROUPID_POSSET       =  256; % bitshift( 1,  8); 
GROUPID_VIEWER_I     =  bitset(GROUPID_VIEWER,10);
GROUPID_VIEWER_II    =  bitset(GROUPID_VIEWER,11);
GROUPID_VGOBJ        =  bitset(GROUPID_VIEWER_II,12);
GROUPID_VAOBJ        =  bitset(GROUPID_VIEWER_II,13);
GROUPID_VCOBJ        =  bitset(GROUPID_VIEWER_II,14);


GroupStr = {...
    'Control'     , ...
    'Preprocessor', ...
    'Blocking'    , ...
    'Filter'      , ...
    'Viewer'      , ...
    'Viewer I'    , ...
    'Viewer II'   , ...
    'Viewer Group Object', ...
    'Viewer Axes Object', ...
    'Viewer Callback Object', ...
    'Tools'       , ...
    'Analysis'    , ...
    'Other'       , ...
    'Any Group'   , ...
    'Position Set'};

GroupIDX =[...
    GROUPID_CONTROL     , ...
    GROUPID_PREPROCESSOR, ...
    GROUPID_BLOCKING    , ...
    GROUPID_FILTER	, ...
    GROUPID_VIEWER	, ...
    GROUPID_VIEWER_I	, ...
    GROUPID_VIEWER_II	, ...
    GROUPID_VGOBJ	, ...
    GROUPID_VAOBJ	, ...
    GROUPID_VCOBJ	, ...
    GROUPID_TOOLS       , ...
    GROUPID_ANALYSIS    , ...
    GROUPID_OTHER       , ...
    GROUPID_ANY         , ...
    GROUPID_POSSET];




