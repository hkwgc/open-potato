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

GroupID = GROUPID_VAOBJ;
TypeID  = TYPEID_OSP_PLUGIN;
DirID   = DIRID_VIEWERAXES;
% AxesObject-Plugin
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewAxesObj_AxisRange');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewAxesObj_2DImage');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewAxesObj_PlotTest');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewAxesObj_background');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewAxesObj_TimeLine');

% Plugin Using
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_vao_2Dimage_getargument');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_vao_background_getargument');

