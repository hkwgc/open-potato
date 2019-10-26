function osp_KeyBind(hObject, eventdata, handles,gui_tag)
% OSP Key-Bind  : Script M-File
%
%--------------------------------------------------
% osp_KeyBind(hObject, eventdata, handles,gui_tag)
% OSP GUI : Common Key-Bind Setting
%    This Key-Bind is ignore, 
%    when GUI Key-Bind is set.
%    used in OspHelp or SetColor
%     See also OspHelp, SetColor
%
% if no argument , use gcf for hObject, eventdata, handles
% gui_tag is a GUI-Tag that specify OSP GUI.
%
% Cording Example ( for GUI )
%  function figure1_KeyPressFcn(hObject, eventdata, handles)
%
%  % GUI Dependent Key-Bind set
%  if isequal(get(hObject),'CurrentKey'),'a'), a_Callback(handles.a,[],handles); end
%
%  try, osp_KeyBind; end
%  
%  % lower Key Bind in gui
%  if isequal(get(hObject),'CurrentKey'),'b'), b_Callback(handles.b,[],handles); end
% -----
% Cording Example Useage2 ( for GUI  ( local figure) )
%
% set(gcf,'KeyPressFcn','osp_KeyBind(gcbo,[],guidata(gcbo))')
% set(gcf,'KeyPressFcn','osp_KeyBind')  %
%
% -----
% Cording Example ( in this M-File )
% 
%  if isequal(get(hObject,'CurrentKey'),'return')
%     return;                                   % To ignore OSP Key-Bind
%  end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !! Change Information of This File
%    When you change Code or GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%
% Information  %
%%%%%%%%%%%%%%%%

% UpperLink
%
% LowerLink
%   OSP_DATA  ( Basic OSP Data I/O Function )

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2004.12.22
% $Id: osp_KeyBind.m 180 2011-05-19 09:34:28Z Katura $
%

%%%%%%%%%%%%%%%
% for UseAge2 ( Error Check )
%    Don't Edit
%%%%%%%%%%%%%%%
if nargin==0
    try
        hObject=gcf;
        eventdata=[];
        handles=guihandles(hObject);
    catch
        return;
    end
elseif nargin ~= 3 && nargin ~= 4
    error('Number of Arguments Error')     
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You Can Edit Key Bind               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warning : Be careful, when you Edit
%           & Change Information

% Order of Case 
%
try
    
    currentkey=get(hObject,'CurrentKey');
    
%    disp(currentkey);   % if you want to check Key
    switch currentkey
        
     case 'escape' % When escape Key Pushed 
            % Delete GCF
	    gui_buttonlock('unlock',hObject);
            try
                delete(hObject)
            end
            
        case 'home'   % When Home Key pushed
            % Main controller Open
            mc=OSP_DATA('GET','MAIN_CONTROLLER');
            figure(mc.handles.figure1);
            
        case 'end'   % When End Key pushed
            % Viewer Open
            mc=OSP_DATA('GET','MAIN_CONTROLLER');
            OSP('psb_view_Callback', ...
                mc.handles.psb_view , [], mc.handles);

         case 'h' % When Key push
%             disp(gui_tag);
%             disp(hObject);
             if exist('gui_tag')
                 OspHelp(gui_tag);
             else
                 OspHelp;
             end

     case 'f5'
      %%% temp : TODO setting method %%%
      OSP_DATA('SET','OSP_COLOR',1);
      % warning(' OSP_COLOR : SET 1 .. TODO');
      if exist('gui_tag','var')
	% disp(['Debug : Key = ' gui_tag]);
	SetColor(hObject, gui_tag);
	if strcmp(gui_tag,'OSP')
	  try
	    mc=OSP_DATA('GET','MAIN_CONTROLLER');
	    OSP('plotAxes', ...
		mc.handles.ax_logo, [],mc.handles);
	  end
	end
      else
	SetColor(hObject);
      end
            
    end  % Switch CurrentKey
end  % Try



