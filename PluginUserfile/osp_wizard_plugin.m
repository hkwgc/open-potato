function varargout = osp_wizard_plugin(varargin)
% OSP_WIZARD_PLUGIN M-file for osp_wizard_plugin.fig
%      OSP_WIZARD_PLUGIN('CALLBACK', ...) calls the local function named
%      CALLBACK in OSP_WIZARD_PLUGIN.M with the given input arguments.

%      Plugin Set output PlugInWrap M-file to OSP/PluginDir directory.
%      Cannot create  the PlugInWrap M-file without PlugIn M-file.   

% Last Modified by GUIDE v2.5 22-Jun-2006 13:45:05


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @osp_wizard_plugin_OpeningFcn, ...
                   'gui_OutputFcn',  @osp_wizard_plugin_OutputFcn, ...
                   'gui_LayoutFcn',  @osp_wizard_plugin_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before osp_wizard_plugin is made visible.
function osp_wizard_plugin_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for osp_wizard_plugin
handles.output = hObject;
handles.figure1= hObject;

pid=getappdata(handles.figure1, 'PageID');
if ~isempty(pid), return; end

% Update handles structure
guidata(hObject, handles);

%  Set window's size
set(handles.figure1, 'Position', [100, 30, 75, 25]); 
set(handles.figure1, 'Color',    [0.703 0.763 0.835]);

set(handles.psb_back, 'Enable', 'off', 'Visible', 'off');
set(handles.psb_next, 'Enable', 'on' , 'Visible', 'on');

set(handles.frm_page0, 'Visible', 'on');
set(handles.frm_page1, 'Visible', 'off');
set(handles.frm_page1, 'Visible', 'off');
set(handles.frm_page2, 'Visible', 'off');
set(handles.frm_page3, 'Visible', 'off');
set(handles.frm_page4, 'Visible', 'off');

%page 1   -- check button
set(handles.rdb_block,     'Visible', 'on', 'Value', 1);
set(handles.rdb_signalpre, 'Visible', 'on', 'Enable', 'off');
set(handles.rdb_analysis,  'Visible', 'on', 'Enable', 'off');
hp1=[];
hp1=[handles.rdb_block, handles.rdb_signalpre, ...
     handles.rdb_analysis, ...
     handles.text_plugin_position];
setappdata(handles.figure1, 'Page1', hp1);

%page 2
set(handles.text_name, 'Visible', 'off');
set(handles.edit_name, 'Visible', 'off');
set(handles.edit_name, 'UserData', []);
set(handles.text_dirName, 'Visible', 'off');
set(handles.edit_dirName, 'Visible', 'off');
set(handles.text_setFilterDispKind, 'Visible', 'off');
set(handles.psb_setFilterDispKind, 'Visible', 'off');
set(handles.text_region, 'Visible', 'off');
set(handles.chb_2, 'Visible', 'off');
set(handles.chb_3, 'Visible', 'off');
hp2=[];
hp2=[handles.text_name, handles.edit_name, ...
     handles.psb_setFilterDispKind, handles.text_setFilterDispKind, ...
     handles.text_region, ...
     handles.chb_2,     handles.chb_3];
setappdata(handles.figure1, 'Page2', hp2);

%page 3
set(handles.text_exp, 'Visible', 'off');
set(handles.edit_exp, 'Visible', 'off');
example='[hdata, data]=FunctionName(hdata, data, arg1,..)';
set(handles.edit_exp, 'TooltipString', example);
set(handles.text_explan1, 'Visible', 'off');
set(handles.text_explan2, 'Visible', 'off');
hp3=[];
hp3=[handles.text_exp, handles.edit_exp, ...
     handles.text_explan1, handles.text_explan2];
setappdata(handles.figure1, 'Page3', hp3);

%page 4
set(handles.text_argtype,   'Visible', 'off');
set(handles.lbx_arglist,    'Visible', 'off');
set(handles.text_in_argtype,'Visible', 'off');
set(handles.pop_in_argtype, 'Visible', 'off');
set(handles.text_in_argnote,'Visible', 'off');
set(handles.edit_in_note,   'Visible', 'off');
set(handles.text_in_arginit,'Visible', 'off');
set(handles.edit_in_init,   'Visible', 'off');
set(handles.psb_set_ok,     'Visible', 'off', 'Enable', 'off');
hp4=[];
hp4=[handles.text_argtype,    handles.lbx_arglist,... 
     handles.text_in_argtype, handles.pop_in_argtype,...
     handles.text_in_arginit, handles.edit_in_init,...
     handles.text_in_argnote, handles.edit_in_note,...
     handles.psb_set_ok];
setappdata(handles.figure1, 'Page4', hp4);


% Set Page information
setappdata(handles.figure1, 'PageID',1);
setappdata(handles.figure1, 'PageMax',4);
guidata(hObject, handles);

% show Page1  
show_ps_page(handles);
return;

% --- Outputs from this function are returned to the command line.
function varargout = osp_wizard_plugin_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
return;

function figure1_KeyPressFcn(hObject, eventdata, handles)
% Key Pres Function
%  OSP Default Key-bind.
  osp_KeyBind(hObject, eventdata, handles,mfilename);
return; % KeyPressFcn

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Function:
%  Change view of OSP-Main-Controller.
try,
  osp_ComDeleteFcn;
end

% --- Executes on button press in psb_back.
function psb_back_Callback(hObject, eventdata, handles)
pageid = getappdata(handles.figure1, 'PageID');

try
  hide_ps_page(handles);
  setappdata(handles.figure1, 'PageID', pageid-1);
  show_ps_page(handles);
catch
  errordlg({' Back page :',['  '  lasterr]});
end
return;


% --- Executes on button press in psb_next.
function psb_next_Callback(hObject, eventdata, handles)
pageid = getappdata(handles.figure1, 'PageID');

try

  if ~check_ps_page(handles) return;end

  hide_ps_page(handles);
  setappdata(handles.figure1, 'PageID', pageid+1);
  show_ps_page(handles);
catch
  errordlg({' Next page :',['  '  lasterr]});
end
return;

% --- Executes on button press in psb_next.
function psb_ok_Callback(hObject, eventdata, handles)
  % Check data
  ch_flag=0;
  set(handles.psb_ok, 'Enable', 'off');
  block = get(handles.rdb_block, 'Value');
  fname = get(handles.edit_name, 'String');
  %dirname = get(handles.edit_dirName, 'String');
  regs  = get(handles.edit_name, 'UserData');
  fexp  = get(handles.edit_exp, 'String');
  alist = get(handles.lbx_arglist, 'UserData');

  if  block ==1 &...
      ~isempty(fname) & ~isempty(regs) & ...
      ~isempty(fexp),
      try
	%  --- Create m-file
	create_pluginwrap_mfile(handles);
	set(handles.psb_ok,   'Enable', 'on',  'Visible', 'on');

      catch
	errordlg({' Create pluginwrap :',['  '  lasterr]});
    return;
      end
  else
      errordlg({'The description is incomplete. :',['  '  lasterr]});
      return;
  end
  delete(handles.figure1);
return;

% --- Check go or not
function flag =check_ps_page(handles)
flag=0;
pageid  = getappdata(handles.figure1, 'PageID');
switch (pageid),
  case 1,
      if get(handles.rdb_block, 'Value')== 1,
	flag=1;
      end

  case 2,
      fname = get(handles.edit_name, 'String');
      treg=[];
      if get(handles.chb_2, 'Value')==1,treg(end+1)=2; end
      if get(handles.chb_3, 'Value')==1,treg(end+1)=3; end

      set(handles.edit_name, 'UserData', treg);
      if ~isempty(fname) &   ~isempty(treg),
	if isvarname(fname),
	  flag=1;
	else
	  errordlg('The description of Function is wrong.');
	end
      else
	errordlg('Function''s name and region are needed.');
      end


  case 3,
      fexp =get(handles.edit_exp, 'String');

      % Check expression
      if isempty(fexp),
	errordlg('Expression is needed.');
	return;
      else

	try
	  [fret, flg]          = get_function_return(fexp);
	  if ~flg return;end
	  [fname, frem, flg]   = get_function_name(fexp);
	  if ~flg return;end
	  [arglist, flg]       = get_function_arglist(frem);
	  if ~flg return;end
	catch
	  flag=0;
	  rethrow([' expression is wrong:' lasterror]);
	end
	
	if ~isempty(arglist),
	  set(handles.lbx_arglist, 'Value', 1);
	  set(handles.lbx_arglist, 'String', arglist);
	else
	  set(handles.lbx_arglist, 'Value', 0);
	  set(handles.lbx_arglist, 'String', '');
	end

	set(handles.edit_exp, 'UserData', [fret ' = ' fname]);

	flag=1;  
      end
	
  case 4,
      flag=1; 
     
  otherwise,
        
end

return;

% --- Executes on button press in psb_back.
function psb_setFilterDispKind_Callback(hObject, eventdata, handles)
 % create Figure setting FilterDispKind 
  fh=figure('MenuBar','none', ... 
	    'Name','Filter Kind Set',...
            'Color',[0.723 0.783 0.855],...
            'Units','Characters');
  p=get(fh,'Position');
  p(3:4)=[40,25];
  set(fh,'Position',p);
  set(fh,'Units','Normalized');
  set(fh,'DeleteFcn','error(''Push OK / Cancel'');');
  % Title
  th = uicontrol('Style','Text', ...
		 'BackgroundColor',[0.723 0.783 0.855],...
                 'Units','Normalized', ...
                 'Position',[5,75,90,10]/ 100, ...
                 'FontSize',12, ...
                 'String','Select Filter-Kind setting to Filter Menu.', ...
                 'HorizontalAlignment','left');

  % List Box
  DefineOspFilterDispKind;
  kindlist=who;
  ff=regexp(kindlist, '^F_\w*[a-zA-Z]$');
  for i=length(ff):-1:1,
      if isempty(ff{i}),
            kindlist(i)=[];
      end
  end
  if ~isempty(kindlist), val=1; end
  lh = uicontrol('Style','listbox', ...
                 'Units','Normalized', ...
                 'BackgroundColor',[1 1 1], ...
                 'Position',[10,30,80,40]/ 100, ...
                 'FontSize',12, ...
                 'String', kindlist, ...
                 'Max', 2, ...
                 'Value', val);

  % OK button
  oh = uicontrol('Units','Normalized', ...
                 'Position',[30,10,20,10]/ 100, ...
                 'BackgroundColor',[1 1 1], ...
                 'FontSize',12, ...
                 'String', 'OK', ...
                 'Callback', ...
                 ['set(gcbf,''DeleteFcn'','''');'...
                  'set(gcbf,''UserData'',true);']);
  ch = uicontrol('Units','Normalized', ...
                 'Position',[60,10,20,10]/ 100, ...
                 'BackgroundColor',[1 1 1], ...
                 'FontSize',12, ...
                 'String', 'Cancel', ...
                 'Callback', ...
                 ['set(gcbf,''DeleteFcn'','''');'...
                  'set(gcbf,''UserData'',false);']);
  waitfor(fh,'DeleteFcn','');
  if ishandle(fh),
    flg = get(fh,'UserData');
    % Cancel
    if flg,
      idx=get(lh,'Value');
      set(handles.psb_setFilterDispKind, 'UserData', {kindlist, get(lh,'Value')});
    else,
      set(handles.psb_setFilterDispKind, 'UserData', []);
    end
    delete(fh);
  else,
    set(handles.psb_setFilterDispKind, 'UserData', []);
  end

return;

function [fret, flg]= get_function_return(fexp)
   flg=0;
   p     = findstr(fexp, '=');
   if isempty(p),
      fret=[];
   else,
      %fret  = fexp(1:p-1);
      [s e]  = regexp(fexp(1:p-1), '[a-zA-Z\[][\w:(){},\]\s]*');
      if length(s)== 1 & length(e)==1,
	fret   = fexp(s(1):e(1));
      else
	errordlg('The description of Return  is wrong.');
	return;
      end
   end
   flg=1;
return;


function [fname, frem, flg]= get_function_name(fexp)
    flag=0;
    frem=[];
    p     = findstr(fexp, '=');
    if ~isempty(p),
      fname = fexp(p+1:length(fexp));
    else
      fname = fexp;
    end
    p     = findstr(fname, '(');
    if ~isempty(p),
      if p~=1,
	fname = fname(1:p-1);
      else
	errordlg('The description of Function''s name  is lack.');
	return;
      end
    %else
    end
      %  Delete ' , ),;
      [s e]  = regexp(fname, '[a-zA-Z]\w*');
      if ~isempty(s),
	fname   = fname(s(1):e(1));
      else
	errordlg('The description of Function''s name  is lack.');
	return;
      end
    %end

    if isvarname(fname)==0,
     fname=[];   
     errordlg('The description of Function''s name  is wrong.');
      return;
    end

    ind = findstr(fexp, fname);
    frem = fexp(ind+length(fname):length(fexp));
    flg=1;
return;


function [arglist, flg]= get_function_arglist(frem)
   flag=0;
   arglist={};

   p     = findstr(frem, '(');

   if ~isempty(p),        %% with arguments
     fargs = frem(p:length(frem));
     % ()check
     op = findstr(fargs, '(');
     cl = findstr(fargs, ')');
     if length(op) ~= length(cl),
       errordlg('Can''t count arguments.');
       return;
     end
     ap=findstr(fargs, '''');
     if ~isempty(ap),
       for i=length(ap):-2:2
	 fargs = strcat(fargs(1:ap(i-1)-1),...
			fargs(ap(i)+1:length(fargs)));
       end
     end
     [s e]=regexp(fargs, '[a-zA-Z]\w*');
     %  Set list
     if ~isempty(s),
       for i=1:length(s),
	 arg1=[];
	 arg1=fargs(s(i):e(i));
	 if isvarname(arg1)==1 &...
	       strcmp('hdata', arg1)==0 &...     % delete 'hdata', 'data'
	       strcmp('data' , arg1)==0 &...
	       isempty(find(strcmp(arglist, arg1))),
	   arglist{end+1}=arg1;
	 end
       end

     end
   end
   flg=1;
return;


% --- Show current page
function show_ps_page(handles)

pageid  = getappdata(handles.figure1, 'PageID');
pagemax = getappdata(handles.figure1, 'PageMax');
if pageid<1 |  pageid>pagemax, 
  return; 
end 

set(handles.psb_back, 'Enable', 'on', 'Visible', 'on');
set(handles.psb_next, 'Enable', 'on', 'Visible', 'on');

switch (pageid),
  case 1,
   set(handles.psb_back, 'Enable', 'off', 'Visible', 'off');
 
  case 4,
     funcArg={}; %%% struct([]);
     mval=1;
     istr=''; note='';

     set(handles.pop_in_argtype, 'Enable', 'off');
     set(handles.edit_in_note,   'Enable', 'off');
     set(handles.edit_in_init,   'Enable', 'off');
     set(handles.psb_set_ok,     'Enable', 'off', 'Visible', 'off');

     argList = get(handles.lbx_arglist, 'String');
     backArg = get(handles.text_argtype, 'UserData');
    
     if ~isempty(argList),
        % Initialize 
	for i=1:length(argList),
	  funcArg(i,:)={argList{i}, 'character', 1, '', ''};
	end

        if ~isempty(backArg),
	  for i=1:length(argList),
	    id=0;
	    id = find(strcmp(backArg(:,1), argList(i)));
	    if isempty(id),
	      funcArg(i,:) = {argList{i}, 'character', 1, '', ''};
	    else,
	      funcArg(i,:) = backArg(id,:);
	    end
	  end
	end
	
	mval = funcArg{1,3};
	istr = funcArg{1,4};
	note = funcArg{1,5};
	if ~isempty(get(handles.lbx_arglist, 'Value')),
	  set(handles.pop_in_argtype, 'Enable', 'on');
	  set(handles.edit_in_note,   'Enable', 'on');
	  set(handles.edit_in_init,   'Enable', 'on');
	  set(handles.psb_set_ok,     'Enable', 'on', 'Visible', 'on');
	end
     end
     set(handles.lbx_arglist,    'UserData', funcArg);
     set(handles.pop_in_argtype, 'Value',    mval);
     set(handles.edit_in_init,   'String',   istr);
     set(handles.edit_in_note,   'String',   note);
     %%% case pagemax,
     pos = get(handles.psb_next, 'Position');
     set(handles.psb_next, 'Enable', 'off', 'Visible', 'off');
     set(handles.psb_ok,   'Enable', 'on',  'Visible', 'on' ,...
                           'Position',  pos);

  otherwise,
end

% Layout components 
pid = ['Page' num2str(pageid)];
whd =[];
whd = getappdata(handles.figure1, pid);
frmpos  = get(eval(['handles.frm_page' num2str(pageid)]), 'Position');
frm0pos = get(handles.frm_page0, 'Position');
moveX   = frmpos(1) - frm0pos(1);
moveY   = frmpos(2) - frm0pos(2);

for i=1:length(whd),
  pos = get(whd(i), 'Position');
  set(whd(i), 'Position', [pos(1)-moveX, pos(2)-moveY, pos(3), pos(4)]);
  set(whd(i), 'Visible', 'on');
end  

return;

% --- Hide current page
function hide_ps_page(handles)

pageid  = getappdata(handles.figure1, 'PageID');
pagemax = getappdata(handles.figure1, 'PageMax');

if pageid<1 |  pageid>pagemax, 
  return; 
end 
switch (pageid),
  case 1,
   set(handles.psb_back, 'Enable', 'off', 'Visible', 'off');

  case 4,
   % set text_argtype 'UserData' <= back up lbx_arglist 'UserData'
   set(handles.text_argtype, 'UserData', get(handles.lbx_arglist, 'UserData'));
   set(handles.psb_ok,   'Enable', 'off', 'Visible', 'off');
   set(handles.psb_next, 'Enable', 'on',  'Visible', 'on');

  otherwise,
end

pid = ['Page' num2str(pageid)];
whd =[];
whd = getappdata(handles.figure1, pid);
frmpos  = get(eval(['handles.frm_page' num2str(pageid)]), 'Position');
frm0pos = get(handles.frm_page0, 'Position');
moveX   = frmpos(1) - frm0pos(1);
moveY   = frmpos(2) - frm0pos(2);

for i=1:length(whd),
  pos = get(whd(i), 'Position');
  set(whd(i), 'Position', [pos(1)+moveX, pos(2)+moveY, pos(3), pos(4)]);
  set(whd(i), 'Visible', 'off');
end  
return;

function lbx_arglist_Callback(hObject, eventdata, handles)
val = get(handles.lbx_arglist, 'Value');
if isempty(val) return; end
set(handles.psb_set_ok, 'Enable', 'off');
% Get 
funcArg=get(handles.lbx_arglist, 'UserData');
if length(val)==1,
  set(handles.pop_in_argtype, 'Value',  funcArg{val,3});
  set(handles.edit_in_init,   'String', funcArg{val,4});
  set(handles.edit_in_note,   'String', funcArg{val,5});
else
  set(handles.pop_in_argtype, 'Value', 1);
  set(handles.edit_in_init,   'String', '');
  set(handles.edit_in_note,   'String', '');
end
set(handles.psb_set_ok, 'Enable', 'on');
return;

function psb_set_ok_Callback(hObject, eventdata, handles)
val  = get(handles.lbx_arglist, 'Value');
if isempty(val),
  set(handles.psb_set_ok, 'Enable', 'off');
  return;
end
% Get 
funcArg = get(handles.lbx_arglist,    'UserData');
mn_val  = get(handles.pop_in_argtype, 'Value');
argtype = get(handles.pop_in_argtype, 'String');
initstr = get(handles.edit_in_init,   'String');
note    = get(handles.edit_in_note,   'String');
for i=1:length(val),
 v=val(i);
 funcArg(v,2)  = argtype(mn_val); 
 funcArg(v,3)  = {mn_val};
 funcArg(v,4)  = {initstr};
 funcArg(v,5)  = {note};
end
% Set 

set(handles.lbx_arglist, 'UserData', funcArg);
return;

function create_pluginwrap_mfile(handles)

   % Get information 
   fname   = get(handles.edit_name, 'String');
   [curpath, psname]=fileparts(which('osp_wizard_plugin'));
   % Get directory name  under 'PluginDir'
   dirname = get(handles.edit_dirName, 'String');

   %[mfile mpath] = uiputpluginfile;
   %0622 [mfile mpath] = uiputpluginfile(2, fname);
   [mfile mpath] = uiputpluginfile(2, fname, dirname);
   mfname = [mpath filesep mfile];

   %if isempty(mfile),
   if mfile==0,return;end

   regs  = get(handles.edit_name, 'UserData');
   fexp  = get(handles.edit_exp, 'String');
   fexp_left  = get(handles.edit_exp, 'UserData');
   argsinfo  = get(handles.lbx_arglist, 'UserData');
   dispkindInfo  = get(handles.psb_setFilterDispKind, 'UserData');

   %  -- Open create file
   wfid = fopen(mfname, 'w');
   try
     create_pluginwrap_basic_base(fname, wfid, regs, argsinfo, dispkindInfo);
     create_pluginwrap_arg_base(fname, wfid, argsinfo);
     create_pluginwrap_write_base(fname, wfid, argsinfo, fexp);
   catch
     fclose(wfid);
     rethrow(lasterror);
   end
   fclose(wfid);

   %% Check M-File
   edit(mfname);
return;

function h=create_pluginwrap_functionH(name, argsinfo)

   %     filterData.name    : 'defined in createBasicInfo'
   %     filterData.wrap    :  Pointer of this Function,
   %                           that is @test1124_expl.
   %     filterData.argData : Argument of Plug in Function.
   %       now
   %        argData.arg1_int  : test1124_expl argument 1
   %        argData.arg2_char : test1124_expl argument 2
   argname =1;
   argnote =5;
   sp = ' ';  
   h=[];
   h{end+1} = '%     filterData.name    : ''defined in createBasicInfo''';
   h{end+1} = '%     filterData.wrap    :  Pointer of this Function,';
   h{end+1} = ['%                           that is @' name '.'];
   h{end+1} = '%     filterData.argData : Argument of Plug in Function.';
   h{end+1} = '%       now';

   dist=10;
   if ~isempty(argsinfo),
     for i=1:length(argsinfo(:,argname)),
       w=[];
       len =10 - (argsinfo{i,argname});
       if (len>0),
	 for l=1:len, w =[w sp];end
       end
       h{end+1} =['%        argData.' argsinfo{i,argname} w ': ' ...
	                          argsinfo{i,argnote} ];
     end
   end
   
return;

function create_pluginwrap_basic_base(name, wfid, regs, argsinfo, dkInfo)
   % Get information 

   rfid = fopen('PlugInWrap_basic_base.txt','r');
   try
     ind=make_indent(1);

     while 1,
       aline = fgetl(rfid);
       if ~ischar(aline), break;end
       aline = strrep(aline, 'PlugInWrap_TEST__NAME', name);
       aline = strrep(aline, 'Plug-in TEST__NAME', name);

       % --------------------------------------
       % Write The Header comments  of function
       % --------------------------------------
       p=strfind(aline, '%%%%%HEADER_FPRINTF');
       if ~isempty(p),
	 hcom=create_pluginwrap_functionH(name, argsinfo);
	 for i=1:length(hcom),
	   fprintf(wfid, '%s\n', hcom{i});
	 end
	 continue;
       end       
       % -------------------------------
       % Discription of region  
       % -------------------------------
       pr=strfind(aline, 'basicInfo.region');
       if ~isempty(pr),
	 aline=[ind 'basicInfo.region = [' num2str(regs) '];'];
       end
       % -------------------------------
       % Discription of FilterDispKind  
       % dkInfo{1}: FilterDispKind List
       % dkInfo{2}: FilterDispKind selected vals
       % -------------------------------
       pr=strfind(aline, 'basicInfo.DispKind');
       if ~isempty(pr) && ~isempty(dkInfo) && ~isempty(dkInfo{1}),
	 nline=[ind 'basicInfo.DispKind= ...'];
	 fprintf(wfid, '%s\n', nline);
	 ind=make_indent(2);
	 if length(dkInfo{2})>1,
	   for id=1:length(dkInfo{2})-1,
	     nline=[ind dkInfo{1}{dkInfo{2}(id)} ' + ...'];
	     fprintf(wfid, '%s\n', nline);
	   end
	 end
	 nline=[ind dkInfo{1}{dkInfo{2}(end)} ';'];
	 fprintf(wfid, '%s\n', nline);
	 ind=make_indent(1);
	 continue;
       end
       % -------------------------------
       % Output Discription
       % -------------------------------
       fprintf(wfid, '%s\n', aline);
     end
     fprintf(wfid, '\n');
   catch
     fclose(rfid);
     rethrow(lasterror);
   end
   fclose(rfid);

return;

function create_pluginwrap_arg_base(name, wfid, argsinfo)
   argname =1;
   argtype =2;
   argmnval=3;
   arginit =4;
   argnote =5;
   % Get information 
   indcnt=1;     
   ind=make_indent(indcnt);
   ind2=make_indent(indcnt+1);
   ind3=make_indent(indcnt+2);
   ind4=make_indent(indcnt+3);
   ind5=make_indent(indcnt+4);

   rfid = fopen('PlugInWrap_arg_base.txt','r');
   p=[];
   try
     while 1,
       aline = fgetl(rfid);
       if ~ischar(aline), break;end
       aline = strrep(aline, 'PlugInWrap_TEST__NAME', name);
       aline = strrep(aline, 'TEST__NAME', name);
       % Write The Header comments  of function
       p=strfind(aline, '%%%%%HEADER_FPRINTF');
       if ~isempty(p),
	 hcom=create_pluginwrap_functionH(name, argsinfo);
	 for i=1:length(hcom),
	   fprintf(wfid, '%s\n', hcom{i});
	 end
	 continue;
       end       
       p=strfind(aline, 'NEXT_FPRINTF');
       if ~isempty(p), break;end       
       fprintf(wfid, '%s\n', aline);
     end

     % ---Check argument existing 
     if isempty(argsinfo),
       fprintf(wfid, '%s%s\n', ind,  'if isempty(data)');
       fprintf(wfid, '%s%s\n', ind2, 'varargout{1}=varargin{1};');
       fprintf(wfid, '%s%s\n', ind2, 'return;');
       fprintf(wfid, '%s%s\n', ind,  'end');
     else
     %if ~isempty(argsinfo),
       % == Default Value
       fprintf(wfid, '%s%s\n', ind, '% Default Value for start');
       for i=1:length(argsinfo(:,argname)),      
	 fprintf(wfid, '%s%s\n', ind,...
		 ['if isempty(data) || ~isfield(data, '''  argsinfo{i,argname} '''),']);

	 switch (argsinfo{i,argmnval}),
	  case 1,   % character
	   if ~isempty(argsinfo{i,arginit}),
	     info = argsinfo{i,arginit};
	     info = strrep(info, '''', '''''');
	     fprintf(wfid, '%s%s\n', ind2,...
		     ['data.' argsinfo{i,argname} ' = ''' info ''';']);
	   else
	     fprintf(wfid, '%s%s\n', ind2, ['data.' argsinfo{i,argname} ' = '''' ;']);
	   end

	  case 4,   % cell array
	   if ~isempty(argsinfo{i,arginit}),
	     info = argsinfo{i,arginit};
	     info = strrep(info, '''', '''''');
	     fprintf(wfid, '%s%s\n', ind2,...
		     ['data.' argsinfo{i,argname} ' = ''' info ''';']);
	   else
	     fprintf(wfid, '%s%s\n', ind2, ['data.' argsinfo{i,argname} ' = '''' ;']);
	   end
	   
	  otherwise,
	   if ~isempty(argsinfo{i,arginit}),
	     fprintf(wfid, '%s%s\n', ind2,...
		     ['data.' argsinfo{i,argname} ' = ''' argsinfo{i,arginit} ''';']);
	   else
	     fprintf(wfid, '%s%s\n', ind2, ['data.' argsinfo{i,argname} ' = ''0'';']);
	   end

	 end
	 fprintf(wfid, '%s%s\n', ind, 'end');
       end
       fprintf(wfid, '\n');


       % == Display Prompt
       fprintf(wfid, '%s%s\n', ind, '% Display Prompt words');
       fprintf(wfid, '%s%s\n', ind, 'prompt = {...');
       for i=1:length(argsinfo(:,argname)),
	 fprintf(wfid, '%s%s\n', ind3,...
		 [''' Enter : ' argsinfo{i,argname} ' ( ' argsinfo{i,argtype} ' )'',...' ]);
       end
       fprintf(wfid, '%s%s\n', ind3, '};');

       % == Default value
       fprintf(wfid, '%s%s\n', ind, '% Default value');
       fprintf(wfid, '%s%s\n', ind, 'def = {...');
       for i=1:length(argsinfo(:,argname)),
	 %type = argsinfo{i,argtype};
	 fprintf(wfid, '%s%s\n', ind3, ['data.' argsinfo{i,argname} ',...' ]);
       end
       fprintf(wfid, '%s%s\n', ind3, '};');

       % == Open Input-Dialog
       fprintf(wfid, '%s%s\n', ind,  '% Open Input-Dialog');
       fprintf(wfid, '%s%s\n', ind,  'while 1,');
       fprintf(wfid, '%s%s\n', ind2,  '% input-dlg');
       fprintf(wfid, '%s%s\n', ind2, 'def = inputdlg(prompt, data0.name, 1, def);');
       fprintf(wfid, '%s%s\n', ind2, 'if isempty(def),');
       fprintf(wfid, '%s%s\n', ind3, 'data=[]; break; %while');
       fprintf(wfid, '%s%s\n', ind2, 'end');
       fprintf(wfid, '\n');
       fprintf(wfid, '%s%s\n', ind2, '% Check Argument');
       fprintf(wfid, '\n');
       
       for i=1:length(argsinfo(:,argname)),
	 aname = ['data.' argsinfo{i,argname}];
	 istr  = num2str(i);

	 switch (argsinfo{i,argmnval}),
	  case 1,   % character
% 	   fprintf(wfid, '%s%s\n', ind2, ['if ~isempty(def{' istr '}),']);
% 	   fprintf(wfid, '%s%s\n', ind5, [aname '= def{' istr '};']);
% 	   fprintf(wfid, '%s%s\n', ind2, 'else');
% 	   fprintf(wfid, '%s%s\n', ind3, [aname '= '''';']);
% 	   fprintf(wfid, '%s%s\n', ind2, 'end');
%-- commented out by TK 2011/05/09
	  case 4,   % cell array
	   fprintf(wfid, '%s%s\n', ind2, ['if ~isempty(def{' istr '}),']);
	   fprintf(wfid, '%s%s\n', ind3, 'try');
	   fprintf(wfid, '%s%s\n', ind4, ['if iscell(eval(def{' istr '})),']);
	   fprintf(wfid, '%s%s\n', ind5, [aname '= def{' istr '};']);
	   fprintf(wfid, '%s%s\n', ind4, 'else');
	   fprintf(wfid, '%s%s\n', ind5,...
		   ['errordlg([''' aname ':Enter correct descript.'' lasterr]);']);
	   fprintf(wfid, '%s%s\n', ind5,  'continue;');
	   fprintf(wfid, '%s%s\n', ind4, 'end');
	   fprintf(wfid, '%s%s\n', ind3, 'catch');
	   fprintf(wfid, '%s%s\n', ind4,...
		   ['errordlg([''' aname ':Enter correct descript.'' lasterr]);']);
	   fprintf(wfid, '%s%s\n', ind4,  'continue;');
	   fprintf(wfid, '%s%s\n', ind3, 'end');
	   fprintf(wfid, '%s%s\n', ind2, 'else');
	   fprintf(wfid, '%s%s\n', ind3, [aname '= '''';']);
	   fprintf(wfid, '%s%s\n', ind2, 'end');


	  otherwise,
	   fprintf(wfid, '%s%s\n', ind2, ['if ~isempty(def{' istr '}),']);
	   fprintf(wfid, '%s%s\n', ind3, 'try');
	   %fprintf(wfid, '%s%s\n', ind4, [aname '= eval(def{' istr '});']); 
	   % aname: Set just String because error occurred useing evaluation of ARRAY.
	   fprintf(wfid, '%s%s\n', ind4, ['eval(''def{' istr '};'');']);
	   fprintf(wfid, '%s%s\n', ind4, [aname '= def{' istr '};']);
	   fprintf(wfid, '%s%s\n', ind3, 'catch');
	   fprintf(wfid, '%s%s\n', ind4,...
		   ['errordlg([''' aname ':Enter correct descript.'' lasterr]);']);
	   fprintf(wfid, '%s%s\n', ind4,  'continue;');
	   fprintf(wfid, '%s%s\n', ind3, 'end');
	   fprintf(wfid, '%s%s\n', ind2, 'else');
	   fprintf(wfid, '%s%s\n', ind3, [aname '= ''0'';']);
	   fprintf(wfid, '%s%s\n', ind2, 'end');

	 end
	 fprintf(wfid, '\n');
       end

       % == While sentence end
       fprintf(wfid, '%s%s\n', ind2, 'break;');
       fprintf(wfid, '%s%s\n', ind,  'end');

       fprintf(wfid, '%s%s\n', ind,  'if isempty(data)');
       fprintf(wfid, '%s%s\n', ind2, 'data0=[]; %Not inputed ( cancel )');
       fprintf(wfid, '%s%s\n', ind,  'else');
       fprintf(wfid, '%s%s\n', ind2, 'data0.argData=data;');
       fprintf(wfid, '%s%s\n', ind,  'end');
       fprintf(wfid, '%s%s\n', ind,  'varargout{1}=data0;');
       fprintf(wfid, '%s\n', 'return;');
       fprintf(wfid, '\n');
     end            % argument existing ending
   catch
     fclose(rfid);
     rethrow(lasterror);
   end
   fclose(rfid);

return;


function create_pluginwrap_write_base(name, wfid, argsinfo, fexp)
   argname =1;
   argtype =2;
   argmnval=3;
   arginit =4;
   argnote =5;
   % Get information 
   indcnt=1;     
   ind=make_indent(indcnt);
   ind2=make_indent(indcnt+1);
   ind3=make_indent(indcnt+2);

   rfid = fopen('PlugInWrap_write_base.txt','r');
   try
     while 1,
       aline = fgetl(rfid);
       if ~ischar(aline), break;end
       aline = strrep(aline, 'PlugInWrap_TEST__NAME', name);
       aline = strrep(aline, 'TEST__NAME', name);
       % Write The Header comments  of function
       p=strfind(aline, '%%%%%HEADER_FPRINTF');
       if ~isempty(p),
	 hcom=create_pluginwrap_functionH(name, argsinfo);
	 for i=1:length(hcom),
	   fprintf(wfid, '%s\n', hcom{i});
	 end
	 continue;
       end       
       p=strfind(aline, 'NEXT_FPRINTF');
       if ~isempty(p), break;end       
       fprintf(wfid, '%s\n', aline);
     end

     % Description of aurgument
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''with_indent'', ''try'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''indent_fcn'', ''down'');']);
     fprintf(wfid, '\n');

     fprintf(wfid, '%s%s\n',   ind,  'try');
     fprintf(wfid, '%s%s\n',   ind,  't_arg=[];');
  
     if ~isempty(argsinfo),

     for i=1:length(argsinfo(:,argname)),
       switch(argsinfo{i,argmnval}),
	case 1,    %character
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['t_arg = fdata.argData.' argsinfo{i, argname} ';']);
	 % t_arg= strrep(t_arg, '''','''''');
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['t_arg = strrep(t_arg, '''''''','''''''''''');']);
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['make_mfile(''with_indent'', sprintf('''...
	 	 argsinfo{i, argname} ' = ''''%s'''';'', t_arg ));']);

	 %fprintf(wfid, '%s%s\n',   ind2,...
	 %      ['make_mfile(''with_indent'', sprintf('''...
	 %	 argsinfo{i, argname} ' = ''''%s'''';'', fdata.argData.' argsinfo{i, argname} '));']);

	case 2,    %integer
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['make_mfile(''with_indent'', sprintf('''...
	 	argsinfo{i, argname} ' = %d;'', str2num(fdata.argData.' argsinfo{i, argname} ')));']);

	case 3,    %float
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['make_mfile(''with_indent'', sprintf('''...
	 	argsinfo{i, argname} ' = %f;'', str2num(fdata.argData.' argsinfo{i, argname} ')));']);

	case 4,    %cell array
	   %  Write "arg='';" when isempty(arg)
	   fprintf(wfid, '%s%s\n',   ind2,...
	       ['if isempty(fdata.argData.' argsinfo{i, argname} '),']);
	   fprintf(wfid, '%s%s\n',   ind3,...
	       ['make_mfile(''with_indent'', ''' argsinfo{i, argname} ' = '''''''';'');']);
	   fprintf(wfid, '%s%s\n',   ind2, 'else');
	   fprintf(wfid, '%s%s\n',   ind3,...
	       ['make_mfile(''with_indent'', sprintf('''...
		argsinfo{i, argname} ' = %s;'', fdata.argData.' argsinfo{i, argname} '));']);
	   fprintf(wfid, '%s%s\n',   ind2, 'end');

	otherwise,
	 fprintf(wfid, '%s%s\n',   ind2,...
	       ['make_mfile(''with_indent'', sprintf('''...
		argsinfo{i, argname} ' = %s;'', fdata.argData.' argsinfo{i, argname} '));']);
       end

     end
     end   % ~isempty(argsinfo) 
     fprintf(wfid, '%s%s\n',  ind,   'catch');
     fprintf(wfid, '%s%s\n',  ind2,  'errordlg(lasterr);');
     fprintf(wfid, '%s%s\n',  ind,   'end');

     % Description of expression calling
     fprintf(wfid, '%s%s\n',   ind,...
	              ['make_mfile(''with_indent'', ''' fexp ';'');']);

     fprintf(wfid, '\n');
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''indent_fcn'', ''up'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''with_indent'', ''catch'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''indent_fcn'', ''down'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''with_indent'', ''errordlg(lasterr);'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''indent_fcn'', ''up'');']);
     fprintf(wfid, '%s%s\n',   ind,  ['make_mfile(''with_indent'', ''end'');']);
     fprintf(wfid, '\n');

     fprintf(wfid, '%s%s\n', ind, 'make_mfile(''with_indent'', '' '');');
     fprintf(wfid, '%s%s\n', ind, ['make_mfile(''code_separator'', 3);' ...
		                '  % Level 3, code sep .']);
     fprintf(wfid, '%s%s\n', ind, 'make_mfile(''with_indent'', '' '');');
     fprintf(wfid, '\n');
     fprintf(wfid, '%s%s\n', ind, 'str='''';');
     fprintf(wfid, '%s\n', 'return;');
   catch
     fclose(rfid);
     rethrow(lasterror);
   end
   fclose(rfid);

return;


function width=make_indent(cnt)
  ind = '   ';   %  indent size 3
  width=[];

  for i=1:cnt,
    width=[width ind];
  end

return;


% --- Creates and returns a handle to the GUI figure. 
function h1 = osp_wizard_plugin_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

h1 = figure(...
'Units','characters',...
'Color',[0.703 0.763 0.835],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','osp_wizard_plugin',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[103.8 29.1538461538461 75 130],...
'Renderer',get(0,'defaultfigureRenderer'),...
'RendererMode','manual',...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','figure1',...
'UserData',[]);

setappdata(h1, 'GUIDEOptions',struct(...
'active_h', [], ...
'taginfo', struct(...
'figure', 2, ...
'frame', 12, ...
'pushbutton', 3, ...
'radiobutton', 4, ...
'text', 7, ...
'edit', 4, ...
'checkbox', 3), ...
'override', 0, ...
'release', 13, ...
'resize', 'none', ...
'accessibility', 'callback', ...
'mfile', 1, ...
'callbacks', 1, ...
'singleton', 1, ...
'syscolorfig', 1, ...
'blocking', 0, ...
'lastSavedFile', '/home/shoji/yamada/OSP/Plugin_temp/osp_wizard_plugin.m'));


h23 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[9.83333333333333 29.25 65 18],...
'String',{  '' },...
'Style','frame',...
'Tag','frm_page1');


h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[6.5 4.66666666666667 65 18],...
'String',{  '' },...
'Style','frame',...
'Tag','frm_page0');


h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'Callback','osp_wizard_plugin(''psb_back_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[42.1666666666667 1 14 2.5],...
'String','<< back',...
'Tag','psb_back');


h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'Callback','osp_wizard_plugin(''psb_next_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[59.3333333333333 1 14 2.5],...
'String','next >>',...
'Tag','psb_next');


h6 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[9.83333333333333 50 64.3333333333333 18],...
'String',{  '' },...
'Style','frame',...
'Tag','frm_page2',...
'Visible','off');


h7 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[20.6666666666667 39.5 38.1666666666667 1.83],...
'String','Signal Preprocesser',...
'Style','radiobutton',...
'Tag','rdb_signalpre');


h8 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[20.6666666666667 36.5 36.1666666666667 1.83333333333333],...
'String','block',...
'Style','radiobutton',...
'Tag','rdb_block');


h9 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[20.6666666666667 33.5 43.1666666666667 1.83],...
'String','Statistical Analysis',...
'Style','radiobutton',...
'Tag','rdb_analysis');


h10 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[14.1666666666667 64 29.3333333333333 2],...
'String','Please input plugin name.',...
'Style','text',...
'HorizontalAlignment', 'left',...
'Tag','text_name',...
'Visible','off');


h11 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[13.3333333333333 61.75 52.5 2.5],...
'String','',...
'Style','edit',...
'HorizontalAlignment', 'left',...
'Tag','edit_name',...
'Visible','off');

% Text for set Filter directory name/not use
h34 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[14.1666666666667 59 52.5 2.5],...
'String',{'Please input plugin directory name.',...
	  'Case input is empty,the directory name is ''PluginDir''.'},...
'Style','text',...
'HorizontalAlignment', 'left',...
'Tag','text_dirName',...
'Visible','off');

% Edit for set Filter directory name/not use
h35 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[13.5 56.167 52.5 2.5],...
'String','',...
'Style','edit',...
'HorizontalAlignment', 'left',...
'Tag','edit_dirName',...
'Visible','off');


h12 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[14.16 58.3 27.6666666666667 2.25],...
'String','Please select region.',...
'HorizontalAlignment', 'left',...
'Style','text',...
'Tag','text_region',...
'Visible','off');


h13 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[13.5 57 20 1.667],...
'String','CONTINUOUS',...
'Style','checkbox',...
'Tag','chb_2',...
'Visible','off');


h14 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[33.8 57 19 1.667],...
'String','BLOCKDATA',...
'Style','checkbox',...
'Tag','chb_3',...
'Visible','off');

% Text for set FilterDispKind
h36 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[14.16 53.2 52.5 2.5],...
'String','Please click if you want to set Filter-Kind',...
'Style','text',...
'HorizontalAlignment', 'left',...
'Tag','text_setFilterDispKind',...
'Visible','off');

% PushButton for set FilterDispKind
h37 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'Callback','osp_wizard_plugin(''psb_setFilterDispKind_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[15 51.3 20.5 2.5],...
'String','Set Disp Kind',...
'Style','pushbutton',...
'HorizontalAlignment', 'center',...
'Tag','psb_setFilterDispKind',...
'Visible','off');


h15 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[24.5 42.75 35.1666666666667 1.91666666666667],...
'String','Please check plugin position.',...
'Style','text',...
'Tag','text_plugin_position');


h16 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[10.1666666666667 70 65 18],...
'String',{  '' },...
'Style','frame',...
'Tag','frm_page3',...
'Visible','off');


h17 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[12.3333333333333 84.0833333333333 30.5 1.91666666666667],...
'String','Please describe expression.',...
'Style','text',...
'Tag','text_exp',...
'Visible','off');


h18 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[13 80.8333333333333 60.3333333333333 2.5],...
'String','',...
'Style','edit',...
'HorizontalAlignment', 'left',...
'Tag','edit_exp',...
'TooltipString','[hdata, data=FunctionName(hdata, data,arg1,...)',...
'Visible','off');


h20 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[17 75.5 45.3333333333333 2.167],...
'HorizontalAlignment', 'left',...
'String','hdata : The Header of User Command',...
'Style','text',...
'Tag','text_explan1',...
'Visible','off');


h21 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[17 72.5 41.3333333333333 2.167],...
'HorizontalAlignment', 'left',...
'String','data  : The Data of User Command',...
'Style','text',...
'Tag','text_explan2',...
'Visible','off');


h19 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[10 90 65 18],...
'String',{  '' },...
'Style','frame',...
'Tag','frm_page4',...
'Visible','off');


h24 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'Callback','osp_wizard_plugin(''psb_ok_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[25.5 1 12.5 2.5],...
'String',' ok ',...
'Tag','psb_ok',...
'Visible','off','Enable','off');


h25 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'Callback','osp_wizard_plugin(''lbx_arglist_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[15.5 91.667 31.333 12.75],...
'Style','listbox',...
'Max',10.0,...
'Min',0.0,...
'String','',...
'Tag','lbx_arglist',...
'Visible','off');


h26 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[13.667 105.25 54.333 2],...
'String','Please set arguments and their type.',...
'Style','text',...
'Tag','text_argtype',...
'Visible','off');


h27 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[48.5 103.5 15 1.83333333333333],...
'String','Select type:',...
'Style','text',...
'Tag','text_in_argtype',...
'Visible','off');


h28 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[48.167 102 24.333 1.583],...
'String',{'character', 'integer', 'float', 'cell array'},...
'Style','popupmenu',...
'Tag','pop_in_argtype',...
'Visible','off');



h29 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[49.5 95.333 15.333 2],...
'String','Enter note:',...
'Style','text',...
'Tag','text_in_argnote',...
'Visible','off');


h30 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[47.833 93.917 25.5 1.917],...
'String','',...
'Style','edit',...
'HorizontalAlignment', 'left',...
'Tag','edit_in_note',...
'Visible','off');


h31 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'Callback','osp_wizard_plugin(''psb_set_ok_Callback'',gcbo,[],guidata(gcbo))',...
'FontSize',12,...
'Position',[59 91.25 12.833 1.667],...
'String',' set ',...
'Tag','psb_set_ok',...
'Visible','off','Enable','off');


h32 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[0.723 0.783 0.855],...
'FontSize',12,...
'Position',[49.5 99.333 15.333 2],...
'String','Enter initial:',...
'Style','text',...
'Tag','text_in_arginit',...
'Visible','off');


h33 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor','white',...
'FontSize',12,...
'Position',[47.833 98 25.5 1.917],...
'String','',...
'Style','edit',...
'HorizontalAlignment', 'left',...
'Tag','edit_in_init',...
'Visible','off');

hsingleton = h1;


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
                    'gui_Singleton'
                    'gui_OpeningFcn'
                    'gui_OutputFcn'
                    'gui_LayoutFcn'
                    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);        
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [getfield(gui_State, gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % OSP_WIZARD_PLUGIN
    % create the GUI
    gui_Create = 1;
elseif numargin > 3 & ischar(varargin{1}) & ishandle(varargin{2})
    % OSP_WIZARD_PLUGIN('CALLBACK',hObject,eventData,handles,...)
    gui_Create = 0;
else
    % OSP_WIZARD_PLUGIN(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = 1;
end

if gui_Create == 0
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    % Do feval on layout code in m-file if it exists
    if ~isempty(gui_State.gui_LayoutFcn)
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        end
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig 
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA
        guidata(gui_hFigure, guihandles(gui_hFigure));
    end
    
    % If user specified 'Visible','off' in p/v pairs, don't make the figure
    % visible.
    gui_MakeVisible = 1;
    for ind=1:2:length(varargin)
        if length(varargin) == ind
            break;
        end
        len1 = min(length('visible'),length(varargin{ind}));
        len2 = min(length('off'),length(varargin{ind+1}));
        if ischar(varargin{ind}) & ischar(varargin{ind+1}) & ...
                strncmpi(varargin{ind},'visible',len1) & len2 > 1
            if strncmpi(varargin{ind+1},'off',len2)
                gui_MakeVisible = 0;
            elseif strncmpi(varargin{ind+1},'on',len2)
                gui_MakeVisible = 1;
            end
        end
    end
    
    % Check for figure param value pairs
    for index=1:2:length(varargin)
        if length(varargin) == index
            break;
        end
        try, set(gui_hFigure, varargin{index}, varargin{index+1}), catch, break, end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if ishandle(gui_hFigure)
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Make figure visible
        if gui_MakeVisible
            set(gui_hFigure, 'Visible', 'on')
            if gui_Options.singleton 
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        rmappdata(gui_hFigure,'InGUIInitialization');
    end
    
    % If handle visibility is set to 'callback', turn it on until finished with
    % OutputFcn
    if ishandle(gui_hFigure)
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end    

function gui_hFigure = local_openfig(name, singleton)
try
    gui_hFigure = openfig(name, singleton, 'auto');
catch
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
end








