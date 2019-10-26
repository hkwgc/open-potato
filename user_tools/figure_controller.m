function varargout = figure_controller(varargin)
% FIGURE_CONTROLLER M-file for figure_controller.fig
%      FIGURE_CONTROLLER, by itself, creates a new FIGURE_CONTROLLER or raises the existing
%      singleton*.
%
%      H = FIGURE_controller returns the handle to a new FIGURE_controller or the handle to
%      the existing singleton*.
%
%      FIGURE_controller('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE_controller.M with the given input arguments.
%
%      FIGURE_controller('Property','Value',...) creates a new FIGURE_controller or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figure_controller_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figure_controller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure_controller

% Last Modified by GUIDE v2.5 13-Dec-2005 13:49:27



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
                   'gui_OpeningFcn', @figure_controller_OpeningFcn, ...
                   'gui_OutputFcn',  @figure_controller_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before figure_controller is made visible.
function figure_controller_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for figure_controller
handles.output = hObject;
handles.figure1 =hObject;

ud=get(handles.lbx_figlist, 'UserData');
if isempty(ud)
	set(handles.lbx_figlist, 'String',{},'Value',[]);   
end
lbx_figlist_Callback(handles.lbx_figlist, [], handles);
% Update handles structure
guidata(hObject, handles);
set(handles.figure1, 'Color', [1.0, 0.937, 0.711]);

% --- Outputs from this function are returned to the command line.
function varargout = figure_controller_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

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

% --- Executes on selection change in lbx_figlist.
function lbx_figlist_Callback(hObject, eventdata, handles)

val = get(handles.lbx_figlist, 'Value');
ud  = get(handles.lbx_figlist, 'UserData');
ud2 = ud(val);
ud2(find(~ishandle(ud2)))=[];
%%% number of selected figures

mode = get(handles.pop_mode,'String');
mode = mode{get(handles.pop_mode,'Value')};
% -- Check mode and set property of enable
if strcmp(mode, 'Tile'),
  set(handles.edit_position,  'Enable', 'on');
else,
  set(handles.edit_position,  'Enable', 'off');
end
 
bk=getappdata(handles.figure1,'AX_BACKGROUND_HANDLE');
if isempty(bk) || ~ishandle(bk),
    axes(handles.axes1); cla;
    c=imread('desktp.jpg');
    s=size(c);
    x=linspace(0,1,s(1));
    y=linspace(1,0,s(2));
    axes(handles.axes1);    
    bk=image(x,y,c); clear x y c;
    set(handles.axes1,'YDir','normal');
    setappdata(handles.figure1,'AX_BACKGROUND_HANDLE',bk);
    axis off;
end

if  length(ud2)>0 ,
  figpos=get_figure_position(handles, mode, length(ud2));

  hold on;
  imgh=getappdata(handles.figure1,'AX_img_handle');
  imgh(find(ishandle(imgh)==0))=[];
  if ~isempty(imgh), delete(imgh); end
  imgh=[];
  axes(handles.axes1);
  for id=1:length(ud2),
      p=figpos(id,:);
      col=[.8 .9]*id/length(ud2);
      col=[1,col];
	  imgh(id)= fill([p(1);p(1)+p(3);p(1)+p(3);p(1)], ...
		  [p(2); p(2); p(2)+p(4);p(2)+p(4)],col);
  end
  set(imgh,...
      'EdgeColor',[0 .7 .3], ...
      'LineWidth',3);
  setappdata(handles.figure1,'AX_img_handle',imgh);
else,
  imgh=getappdata(handles.figure1,'AX_img_handle');
  imgh(find(ishandle(imgh)==0))=[];
  if ~isempty(imgh), delete(imgh); end
end

return;

% --- Executes on button press in psb_reset.
function psb_reset_Callback(hObject, eventdata, handles)
%% Get Handles of Root
figs_handles=get(0, 'Children');

flag=logical(1);

figNameList={};     
handleList=[];      
hl=[];
if length(figs_handles)>0,
    %% Clear figure's list
    set(handles.lbx_figlist, ...
		'String', {}, ...
		'UserData', [], ...
		'Value',[]);
    
    for idx=length(figs_handles):-1:1
        try
            fl = setFigureHandle(figs_handles(idx), [], handles);
        catch
            if (flag),
				flag=logical(0);
				errordlg(['Error occurred in setFigureHandleist function.',...
						lasterr]);
            end
        end
    end
end
lbx_figlist_Callback(handles.lbx_figlist, [], handles);
return;

% --- Executes on button press in psb_delete.
function psb_delete_Callback(hObject, eventdata, handles)
val=get(handles.lbx_figlist, 'Value');
if  length(val)>0, 
  figNameList=get(handles.lbx_figlist, 'String');
  handleList =get(handles.lbx_figlist, 'UserData');
  tmp=handleList(val);
  tmp=tmp(find(ishandle(tmp)));
  delete(tmp);
  figNameList(val)=[];
  handleList(val)=[];
  set(handles.lbx_figlist, 'Value', []);
  set(handles.lbx_figlist, 'String',  figNameList);
  set(handles.lbx_figlist, 'UserData',handleList);
  lbx_figlist_Callback(handles.lbx_figlist, [], handles);
else
  errordlg('Please select figures.');
end

return;

% --- Executes on button press in psb_up.
function psb_up_Callback(hObject, eventdata, handles)
swap_row(-1, handles);
return;

% --- Executes on button press in psb_down.
function psb_down_Callback(hObject, eventdata, handles)
swap_row(1, handles);
return;


% --- Executes on button press in psb_tile.
function psb_tile_Callback(hObject, eventdata, handles)
%% Get value of selected figures
val=get(handles.lbx_figlist, 'Value');
%Set position figure
ud=get(handles.lbx_figlist, 'UserData');
ud2 = ud(val);
ud2(find(~ishandle(ud2)))=[];

if  length(ud2)>0 ,
    %%% number of selected figures
    mode = get(handles.pop_mode,'String');
    mode = mode{get(handles.pop_mode,'Value')};
    figpos=get_figure_position(handles, mode, length(ud2));
    for id=length(ud2):-1:1,
        lfigpos=figpos(id,:);
        %disp(['return of get_figure_pos:' num2str(lfigpos)])
        set(ud2(id), ...
            'Units', 'normalized', ...
            'Position', lfigpos, ...
            'Visible', 'on');
    end
else
    warndlg('Please select effective figures.');
end
return;


%% Add fig_handle to figure's list(ListBox)
function figNameList=setFigureHandle(fig_handle, eventdata, handles)

% check is handle
if isempty(fig_handle), return; end
figNameList=get(handles.lbx_figlist, 'String');   
handleList =get(handles.lbx_figlist, 'UserData'); 

% Check Input Data
if isempty(fig_handle) || ...
        ~ishandle(fig_handle),
    return;
end
fig_handle = fig_handle(1);

% ignore listed handle
if  ~isempty(handleList) && ...
    any(handleList == fig_handle),
    return;
end

fhstr=num2str(fig_handle);
if ~isempty(strfind(fhstr,'.')), return; end
figname=get(fig_handle, 'Name');
if  isempty(figname),
    figname='untitled';
end
figNameList{end+1}=[fhstr ' : ' figname];
handleList(end+1)=fig_handle;
set(handles.lbx_figlist, 'String',   figNameList); 
set(handles.lbx_figlist, 'UserData', handleList);

return;

%% Add fig_handle to figure's list(ListBox)
function swap_row(dir, handles)

%  Check value 
val = get(handles.lbx_figlist, 'Value');
if length(val)<1,  return; end
if length(val)>1,  return; end
figNameList=get(handles.lbx_figlist, 'String');   
handleList =get(handles.lbx_figlist, 'UserData');  
if dir==-1,      new=val-1;end
if dir==1,    new=val+1;end
if new<1,          return;end
if new>length(handleList), return;end

% Swap list
tmpString=figNameList{val};
tmpUdata =handleList(val);

figNameList{val}=figNameList{new};
handleList(val) =handleList(new);
figNameList{new}=tmpString;
handleList(new) =tmpUdata;

set(handles.lbx_figlist, 'String',   figNameList); 
set(handles.lbx_figlist, 'UserData', handleList);  
set(handles.lbx_figlist, 'Value',    new); 

return;


%% Calculate the displaying position
function psn = get_figure_position(handles, mode, chnum)
  % -- Get position value from 'UserData'   %% added 
  pos_val = get(handles.edit_position, 'UserData'); 
  pa_sz   = [pos_val(3), pos_val(4)];
  pos     = [pos_val(1), pos_val(2)];

  switch mode,
   case 'Square'
    cnum = ceil(sqrt(chnum));
   case '2Colums'
    cnum = 2;
    % for this figure,
   case 'Tile',
    cnum = ceil(sqrt(chnum));
   case 'Overlap',
    chnum=max(chnum(:));
    sz=[0.5, 0.5];
    sp=[0.4, -0.4]/chnum;
    pos = [0.01,(0.98-sz(2))];
    psn=zeros(chnum, 4);
    for idx=1:chnum,
      psn(idx,:)= [pos, sz];
      pos = pos + sp;
    end
    return;
   otherwise,
    error(['Undefined mode : ' mode '!']);
  end

  % Setting Space
  sp =[0, 0];
  % width
  c_sz   = pa_sz(1)/cnum;
  c_sp   = c_sz * sp(2); % space of Column
  c_spp2 = c_sp/2;

  cpos = pos(1)+c_spp2;
  for cid=2:cnum;
    cpos(cid)=cpos(cid-1)+c_sz;
  end

  % height
  rnum   = ceil(chnum/cnum);
  r_sz   = pa_sz(2)/rnum;
  r_spp2 = r_sz * sp(1); % space of Row

  rpos = pos(2)+pa_sz(2) -(r_sz-r_spp2);
  for rid=2:rnum;
    rpos(rid)=rpos(rid-1)-r_sz;
  end

  psn=zeros(chnum,4);
  rid=1;
  %ax_sz = [c_sz, r_sz] * 0.8;
  ax_sz = [c_sz, r_sz];
  chid=1;
  for rid = 1: rnum
    for cid=1:cnum,
      psn(chid,:)=[cpos(cid), rpos(rid), ax_sz];
      chid=chid+1;
      if (chid>chnum) break; end
    end
  end

return;


% --- Executes on selection change in pop_mode.
function pop_mode_Callback(hObject, eventdata, handles)
lbx_figlist_Callback(handles.lbx_figlist, eventdata, handles)


function edit_position_CreateFcn(hObject, eventdata, handles)
  set(hObject, 'BackgroundColor','white');
  set(hObject, 'Foreground', 'black');
  init=['[0.05 0.05 0.9 0.9]'];
  set(hObject, 'String', init);
  init_val=str2num(init);
  set(hObject, 'UserData', init_val);
return;


function edit_position_Callback(hObject, eventdata, handles)
  set(hObject, 'Foreground', 'black');
  pos_list = (get(hObject, 'String'));
  try,
    pos_val  = str2num(pos_list);
  catch,
    set(hObject, 'Foreground', 'red');
    errordlg('Enter correct description.');
    return;
  end
  msg=[];

  if length(pos_val) ~=4,
    msg='lack of position values.';
  end
  if isempty(msg),
    for i=1:length(pos_val),
      if ~isnumeric(pos_val(i)) || pos_val(i)<0.0,
	msg='Enter correct number within range.';
	break;
      end
    end
  end
  if isempty(msg),
    if	pos_val(1) + pos_val(3)>1.0 || ...
	  pos_val(2) + pos_val(4)>1.0,
	msg='Enter correct number within range.';
    end
  end
  % -- Check error message
  if ~isempty(msg)
      set(hObject, 'Foreground', 'red');
      errordlg(msg);
      return;
  end

  % -- Set position value to 'UserData'
  set(hObject, 'UserData', pos_val);
  % -- Show axes1  
  lbx_figlist_Callback(handles.lbx_figlist, eventdata, handles)
return;

