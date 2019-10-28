function f = uimenu_Osp_Graph_Option(fig_h, actdata)
% Add OSP Graph Option Menu to the Figure
%
%  uimenu_Osp_Graph_Option
%    Add OSP Graph Option Menu to GCF
%
%  uimenu_Osp_Graph_Option(fig_h)
%    Add OSP Graph Option Menu to fig_h.
%    Where fig_h is handle of figure.
%
%  uimenu_Osp_Graph_Option(fig_h,actdata)
%    Add OSP Graph Option Menu to fig_h.
%    Menu include 'Show Info'.
%    Show Info is Graph Information Print
%
%  f is added uimenu
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin<1
  fig_h = gcf;
end

%f = uimenu('Parent',fig_h,'Label','OSP-Graph');
f = uimenu('Parent',fig_h,'Label','Graph Menu');

% --- Menu : Show Info ---
axs=uimenu(f,'Label','Show Info');
if nargin>=2
  setappdata(fig_h, 'DataInfo', actdata);
  uimenu(axs,'Label','Show Information', ...
	 'Callback', 'uimenu_Osp_Graph_Callback(''ShowInformation'')');
end
% 
uimenu(axs,'Label','Legend', ...
       'Callback','uimenu_Osp_Graph_Callback(''Legend'')');

uimenu(f,'Label','Launch EditAxes', ...
       'Callback',['tmp.ax=gca;uiEditAxes(''arg_handle'',tmp);']);

% --- Menu : Axis ---
axs=uimenu(f,'Label','&Axis');

uimenu(axs,'Label','Apply GCA X-axis to all axes', ...
	'Callback','uimenu_Osp_Graph_Callback(''AP_X_AXIS'')');

uimenu(axs,'Label','Apply GCA Y-axis to all axes', ...
	'Callback','uimenu_Osp_Graph_Callback(''AP_Y_AXIS'')');

uimenu(axs,'Label','Apply GCA XY-axis to all axes', ...
	'Callback',['uimenu_Osp_Graph_Callback(''AP_X_AXIS'');', ...
		'uimenu_Osp_Graph_Callback(''AP_Y_AXIS'');']);

uimenu(axs,'Label','Tight', ...
	'Callback','uimenu_Osp_Graph_Callback(''AXIS_TIGHT'')', ...
	'Separator','on');

uimenu(axs,'Label','Reset', ...
	'Callback','uimenu_Osp_Graph_Callback(''AXIS_RESET'')');

% --- Menu : Line ---
l=uimenu(f, 'Label','&Line');
uimenu(l,'Label','Line &Color', ...
	'Callback','uimenu_Osp_Graph_Callback(''LINE_PROP'',''COLOR'')');
uimenu(l,'Label','Line &Style', ...
	'Callback','uimenu_Osp_Graph_Callback(''LINE_PROP'',''LineStyle'')');
uimenu(l,'Label','&Width', ...
	'Callback','uimenu_Osp_Graph_Callback(''LINE_PROP'',''LineWidth'')');
% All
uimenu(l,'Label','&All', ...
	'Callback','uimenu_Osp_Graph_Callback(''LINE_PROP'',''ALL'')', ...
	'Separator','on');

% --- Menu : Marker ---
m=uimenu(f, 'Label','&Marker');
uimenu(m,'Label','&Marker', ...
	'Callback','uimenu_Osp_Graph_Callback(''MARKER_PROP'',''Marker'')');
uimenu(m,'Label','Marker &Face Color', ...
	'Callback','uimenu_Osp_Graph_Callback(''MARKER_PROP'',''MarkerFaceColor'')');
uimenu(m,'Label','Marker &Edge Color', ...
	'Callback','uimenu_Osp_Graph_Callback(''MARKER_PROP'',''MarkerEdgeColor'')');
uimenu(m,'Label','Marker &Sizer', ...
	'Callback','uimenu_Osp_Graph_Callback(''MARKER_PROP'',''MarkerSize'')');
uimenu(m,'Label','&All', ...
	'Callback','uimenu_Osp_Graph_Callback(''MARKER_PROP'',''ALL'')', ...
	'Separator','on');

