function ApplyPropfile2Gui(propfile, h_fig, guiname)
% ApplyPropfile2Gui apply Property  File to GUI
%  
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
%  $Id : $
% -------------------------------------
%
% ApplyPropfile2Gui(propfile, h_fig, guiname)
%   is apply Property  File to GUI
%   | 'propfile' is a Filename of Property File
%   | 'h_fig' is a handle of GUI-figure 
%   | 'guiname' is a Name of GUI (defined in 'propfile')
%
% ApplyPropfile2Gui(propfile, h_fig)
%   is as same as guiname=='default'
%
% -------------------------------------
%
% Property file is Mat-File that contain 'prop_data'
%
%  * 'prop_data' must have a field named 'default'.
%    This field will be used, 
%          if there is no guiname in prop_data,
%                      or guiname is default
%
%  * Each  fields in 'prop_data' is structure
%     the structure have a field named 'figs',
%                                      'findobj',
%                                      'handles',
%      if there is no field, we don't do nothing about the field
%
%  -- Set figure property -- 
%  * the field 'figs' is structure array
%     that field is 'prop','value'
%     This is a set Property & value of the GUI-figure(h_fig)
%     (See  also set)
%
%  -- Set grouping  property -- 
%  * the field 'findobj' is structure array
%     that field is 'FindProperty','FindValue' , 
%                   'SetProperty' and 'SetValue'.
%     Find** is use in findobj ( See also findobj)
%     Find** is use in set ( See also set)
%
%  -- Set unique  property -- 
%  * the field 'handles' is structure array
%     that field is 'prop','value', 'tagname'
%     This is a set Property & value of the figure tag
%     (See  also set)
%     This field have a priority.
%
  


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2005.01.19
% $Id $
%


  %****************************************
  %  Argument Check & Set Default Value    
  %****************************************
  if nargin<1
    help(mfilename)
    error('so few arguments');
    return;
  end

  if nargin<=1,  h_fig=gcf; end

  % GUI Name
  if nargin<=2
    guiname='default';
  end

  % *************************
  %    Load Property File   
  % *************************
  load(propfile,'prop_data');
  if ~exist('prop_data','var')
    error([ propfile ' is not a Property File.'...
	    ' No prop_data error.']);
  end

  % ****************
  %    Select GUI   
  % ****************
  if isfield(prop_data,guiname)
    prop=getfield(prop_data,guiname);
  else
    try
      prop=getfield(prop_data,'default');
    catch
      error(['No GUI(' guiname ')' ...
	     'Color in file' gui_colorFile]);
    end
  end
  clear prop_data;
  
  % ***********************
  %    Set Figure Property 
  % ***********************
  if isfield(prop,'figs')
    for data = prop.figs
      set(h_fig, data.prop, data.value);
    end
    clear data;
  end


  % ****************
  %    Findobj      
  % ****************
  if isfield(prop,'findobj')
    for data=prop.findobj
      try
	h = findobj(h_fig, data.FindProperty, data.FindValue);
	set(h, data.SetProperty, data.SetValue);
      catch
	warning(lasterr);
      end % catch
    end % findobj
    clear data;
  end % end of findobj

  % ****************
  %     handles     
  % ****************
  if isfield(prop,'handles') 
    hs = guihandles(h_fig);
    for data=prop.handles
      if isfield(hs,data.tagname)
	try
	  h=getfield(hs,data.tagname);
	  set(h,data.prop, data.value);
	catch
	warning(lasterr);
	end % catch
      end % endif
    end % for
  end % handles


  return;
  
%   style={'pushbuton', 'togglebutton', ...
%           'radiobutton', 'checkbox', ...
%           'edit', 'text', ...
%           'slider', 'frame' ...
%           'listbox', 'popupmenu'};
%   
%   h(1) = findobj(h_fig, 'Style','');
%   h() = findobj(h_fig, 'Style','text');
%   h(3) = findobj(h_fig, 'Style','text');
%   
%   if isfield(gui_color,'Special')
%       special=gui_color.Special;     % Special Color Map
%       rmfield(gui_color,'Special');  % Remove
%   else
%       special=[]
%   end
%   
%   return;
  
