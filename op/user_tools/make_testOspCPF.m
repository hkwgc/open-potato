function make_testOspCPF(bc,saveid)
% make ExampleFile of OSP Color Property File
%  Set Base Color of Main Controller
%
%  See also SetColor OSP



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




%  prop_data.default = struct([]);   % Do nothing
%  prop_data.signal_preprocessor = struct([]);
%  prop_data.signal_viewer = struct([]);

  if nargin<1,  bc=[1 1 1]; end
  if nargin<2,  saveid=1; end
  style={'pushbuton', 'togglebutton', ...
	 'radiobutton', 'checkbox', ...
	 'edit', 'text', ...
	 'slider', 'frame' ...
	 'listbox', 'popupmenu'};
  
  % ===== Default ======
  % figs
  cmap.figs(1) = getFigs1(bc);

  % findobj
  % -- style --
  cmap.findobj = getFindobj1(bc,{style{[3 4 5 6 7 8 9 10]}});
  
  prop_data.default = cmap;


  % ====== OSP ===
  % figs
  cmap.figs(1) = getFigs1(bc);

  % findobj
  % -- style --
  cmap.findobj = getFindobj1(bc,{style{[4 5 6 7 9 10]}});

  % handles
  cmap.handles = getHandles1(bc,{'frm_filedata'});  

  prop_data.OSP = cmap;

  % == Get Handles(hs) ==
  mc=OSP_DATA('GET','MAIN_CONTROLLER');
  hs=mc.handles; clear mc;

  % ====== signal_preprocessor ===
  bc = get(hs.psb_sp,'BackgroundColor');
  % figs
  cmap.figs(1) = getFigs1(bc);

  % findobj
  % -- style --
  cmap.findobj = getFindobj1(bc,{style{[3 4 5 6 7 8 9 10]}});

  % handles
  cmap.handles = getHandles1(bc,{'frm_filedata'});  

  prop_data.signal_preprocessor = cmap;


  
  % saving
  OSP_DATA('SET','OSP_COLOR',1);
  gui_colorFile = ...
      [ OSP_DATA('GET','OSPPATH') filesep ...
	'ospData' filesep ...
	'GUI_COLOR_FILE1.mat'];
  disp(gui_colorFile);
  save(gui_colorFile,'prop_data');

  
  % Calling
  mc=OSP_DATA('GET','MAIN_CONTROLLER');
  SetColor(mc.hObject,'OSP');
return;


% Set Figure Color
function data=getFigs1(bc)
  data.prop='Color';
  data.value=bc;
return

function data=getFindobj1(bc, istyle)
  data0.FindProperty='Style';
  data0.SetProperty='BackgroundColor';
  data0.SetValue=bc;
  data0.FindValue=istyle{1};
  data(1)=data0;
  for id=2:length(istyle)
    data0.FindValue=istyle{id};
    data(end+1)=data0;
  end
  
return;

function data=getHandles1(bc,tags)
  data0.prop='BackgroundColor';
  data0.value=bc;
  data0.tagname=tags{1};
  data(1)=data0;
  
  for ii=2:length(tags)
    data0.tagname=tags{ii};
    data(end+1)=data0;
  end

return;    
