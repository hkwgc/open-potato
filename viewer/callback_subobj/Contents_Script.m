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

GroupID = GROUPID_VCOBJ;
TypeID  = TYPEID_OSPFUNC;
DirID   = DIRID_VIEWERCALLB;
% AxesObject-Plugin
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_TimeRange');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_XAxisRange');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_YAxisRange');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageAuto');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageColorMap');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageMaskCh');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageMeanP');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageMode');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_2DImageTime');

Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallbackC_Channel');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallbackC_DataKind');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallbackC_Data');
Contents_function('SetData',TypeID, DirID,GroupID, 'p3_ViewCommCallback');

% Unused
TypeID  = bitset(TypeID,TYPEID_UNUSED);
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_ChannelPopup');
Contents_function('SetData',TypeID, DirID,GroupID, 'osp_ViewCallback_KindSelector');

