function SetColor(h_fig, guiname, gui_colorFile)
% SetColor is Set Color of GUI in OSP 
%  
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
%  $Id : $
% -------------------------------------
%
%  SetColor(h_fig, guiname)
%    Apply GUI_COLOR_FILE to GUI
%    | h_fig is a GUI handle that Apply to 
%    | guiname is a GUI-Specify Name
%    | ( Correspond to Colormap field)
%
%  SetColor('help')
%    Show Help 
%
%  Definition of GUI_COLOR_FILE is 
%  as same as ApplyPropfile2Gui's Property File
%
%  See also ApplyPropfile2Gui


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.01.19
% $Id $
%

  % ****************************
  %    Argument Check           
  % ****************************

  % == Default Value ==
  if nargin<1,  h_fig=gcf; end

  % GUI Name
  if nargin<=1
    if isstr(h_fig) && strcmpi(h_fig,'help')
	OspHelp('SetColor');
    end
    guiname='default';
  end

  % Get Color ID
  if nargin<=2
    % Load OSP Data
    id = OSP_DATA('GET','OSP_COLOR');
    if isempty(id),  return; end  % No Name

    % Set GUI Color map
    gui_colorFile = ...
	[ OSP_DATA('GET','OSPPATH') filesep ...
	  'ospData' filesep ...
	  'GUI_COLOR_FILE' num2str(id) '.mat'];
  end

  if ~ishandle(h_fig)
    if isnumeric(h_fig ), h_fig=num2str(h_fg); end % for print
    error(['1st Argument must be handles.' ...
	   h_fig ' is not a handles']);
  end

  % ****************************
  %    Load GUI Color File      
  % ****************************

  % File exist Check ( never need)
  if ~exist(gui_colorFile,'file')
    error(['There is no GUI-Color-Map : ' gui_colorFile]);
  end

  ApplyPropfile2Gui(gui_colorFile, h_fig, guiname);

return;

% style={'pushbuton', 'togglebutton', ...
%        'radiobutton', 'checkbox', ...
%        'edit', 'text', ...
%        'slider', 'frame' ...
%        'listbox', 'popupmenu'};
