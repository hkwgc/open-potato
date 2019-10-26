function osp_ComDeleteFcn()
% OSP Common Delete Function : Principal GUI Common Delete Function
% DeleteFcn of 
%  * signal_preprocessor
%  * block_controller
%  *    sets_creator
%  * statistical_analysis
% ( Upper-Link is corresponding M-File )
%
% Lower Link  : OSP, OSP_DATA, OSP_LOG
%
% ===================== 
%   1. OSP Main-Controller View
%     -> Active Line Chaneg
% ===================== 
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original auther : Masanori Shoji
% create : 2004.12.21
% $Id: osp_ComDeleteFcn.m 180 2011-05-19 09:34:28Z Katura $
%

% Bugs : mail to shoji-masanori@hitachi-ul.co.jp


% ===================== 
%   1. OSP Main-Controller View
% ===================== 
try
    mc=OSP_DATA('GET','MAIN_CONTROLLER');
    if isempty(mc), return; end;
    OSP('reloadView', mc.hObject, mc.eventdata, mc.handles, 'rmAM');
catch
    % Print Error
    OSP_LOG('err',...
        {mfilename;...
            ' Error : Can not reload OSP MainController.';...
            lasterr});
end

