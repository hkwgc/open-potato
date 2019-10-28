function varargout = LayoutManager_LProperty(varargin)
% LAYOUTMANAGER_LPROPERTY M-file for LayoutManager_LProperty.fig
%      This function Set Line-Property of GroupData Object.
%      Line have name, color, style, mark Properties.
%
%      LAYOUTMANAGER_LPROPERTY, by itself, creates a new LAYOUTMANAGER_LPROPERTY or raises the existing
%      singleton*.
%
%      UD = LAYOUTMANAGER_LPROPERTY returns the Line-Property-Data Cell-Array to LAYOUTMANAGER
%
%      LAYOUTMANAGER_LPROPERTY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAYOUTMANAGER_LPROPERTY.M with the given input arguments.
%
%      LAYOUTMANAGER_LPROPERTY(varargin) creates a new LAYOUTMANAGER_LPROPERTY or raises the
%      existing singleton*.  
%      All inputs are passed to LayoutManager_LProperty_OpeningFcn via varargin.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LayoutManager_LProperty

% Last Modified by GUIDE v2.5 01-Feb-2006 09:21:08


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
                   'gui_OpeningFcn', @LayoutManager_LProperty_OpeningFcn, ...
                   'gui_OutputFcn',  @LayoutManager_LProperty_OutputFcn, ...
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI I/O Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LayoutManager_LProperty_OpeningFcn(hObject, eventdata, handles, varargin)
  handles.output = hObject;
  handles.LayoutManager_LProperty=hObject;
  handles.figure1=handles.LayoutManager_LProperty;

  %  Set window's size
  set(hObject, ...
      'Units', 'normalized', ...
      'Position', [0.50, 0.1, 0.28, 0.32], ...
      'Color',   [0.703 0.763 0.835]);
  % Update handles structure
  guidata(hObject, handles);

  % Copy Object Information
  if nargin>=4 && ~isempty(varargin{1}),
    LineProp = varargin{1};
    ud=LineProp;
    string={};
    for i=1:length(LineProp),
      vstr   = LineProp{i}.name;
      vmark  = LineProp{i}.mark;
      if strcmp(vmark,'none'),
	string{i}=['   ' vstr];
      else
	string{i}=[' ' vmark ' ' vstr];
      end
    end
    set(handles.lbx_line, 'Value', length(string));
    set(handles.lbx_line, 'String',   string);
    set(handles.lbx_line, 'UserData', ud);
  end
  lbx_line_Callback(handles.lbx_line,[],handles);
  set(handles.LayoutManager_LProperty,'WindowStyle','modal')
  uiwait(handles.LayoutManager_LProperty);
return;

function varargout = LayoutManager_LProperty_OutputFcn(hObject, eventdata, handles)
  % Update handles structure
  handles=guidata(hObject);
  varargout{1} = handles.output;
  delete(handles.LayoutManager_LProperty);
return;

function lbx_line_CreateFcn(hObject, eventdata, handles)

  udata={};

  udata{1}.use   = logical(0);
  udata{1}.name  = 'Oxy';
  udata{1}.color = [1 0 0];
  udata{1}.style = '-';
  udata{1}.mark  = 'none';

  udata{2}.use   = logical(0);
  udata{2}.name  = 'Deoxy';
  udata{2}.color = [0 0 1];
  udata{2}.style = '-';
  udata{2}.mark  = 'none';

  udata{3}.use   = logical(1);
  udata{3}.name  = 'Total';
  udata{3}.color = [0 0 0];
  udata{3}.style = '-';
  udata{3}.mark  = 'none';

  set(hObject,'String', {'   Oxy', '   Deoxy', '   Total'}, ...
              'UserData',udata, ...
              'Value',1);
return;

function lbx_line_Callback(hObject, eventdata, handles)
  val  = get(handles.lbx_line,'Value');
  str  = get(handles.lbx_line,'String');
  ud   = get(handles.lbx_line,'UserData');
  sstr = get(handles.pop_lineStyle,'String');
  mstr = get(handles.pop_lineMark,'String');

  if ~length(val)>1, 
    ud0=ud{val};
  else
    ud0=ud{val(1)};
  end
  mid  = find(strcmp(mstr, ud0.mark));
  sid  = find(strcmp(sstr, ud0.style));
  set(handles.pop_lineMark, 'Value', mid);
  set(handles.pop_lineStyle, 'Value', sid);
  set(handles.psb_colorSet,'BackgroundColor', ud0.color);
return;

function psb_colorChange_Callback(hObject, eventdata, handles)
  cl=uisetcolor(get(handles.psb_colorSet,'BackgroundColor'));

  if ~isequal(cl,0),
    vl=get(handles.lbx_line,'Value');
    ud=get(handles.lbx_line,'UserData');

    if ~length(vl)>1,
      ud0=ud{vl};
      ud0.color = cl;
      ud{vl}=ud0;
    else
      for i=1:length(vl),
	ud0=ud{vl(i)};
	ud0.color = cl;
	ud{vl(i)}=ud0;
      end
    end

    set(handles.lbx_line,'UserData',ud);
    set(handles.psb_colorSet,'BackgroundColor',cl);
  end
return;

function psb_colorSet_Callback(hObject, eventdata, handles)
  cl=uisetcolor(get(handles.psb_colorSet,'BackgroundColor'));

  if ~isequal(cl,0),
    vl=get(handles.lbx_line,'Value');
    ud=get(handles.lbx_line,'UserData');

    if ~length(vl)>1,
      ud0=ud{vl};
      ud0.color = cl;
      ud{vl}=ud0;
    else
      for i=1:length(vl),
	ud0=ud{vl(i)};
	ud0.color = cl;
	ud{vl(i)}=ud0;
      end
    end

    set(handles.lbx_line,'UserData',ud);
    set(handles.psb_colorSet,'BackgroundColor',cl);
  end
return;

function pop_lineMark_Callback(hObject, eventdata, handles)
  vl   = get(handles.lbx_line,'Value');
  lstr = get(handles.lbx_line,'String');
  ud   = get(handles.lbx_line,'UserData');
  mark = get(handles.pop_lineMark,'String');
  mark = mark{get(handles.pop_lineMark,'Value')};

  if ~length(vl)>1,
    ud0=ud{vl};
    ud0.mark = mark;
    ud{vl}=ud0;
    lstr{vl}=markUpdate(lstr{vl},mark);
  else
    for i=1:length(vl),
      ud0=ud{vl(i)};
      ud0.mark = mark;
      ud{vl(i)}=ud0;
      lstr{vl(i)}=markUpdate(lstr{vl(i)},mark);
    end
  end

  set(handles.lbx_line,'UserData',ud);
  set(handles.lbx_line,'String', lstr);
return;

function upstr=markPlus(str, mark)
  if strcmp(mark, 'none'),
    upstr = [ '   ' str];
  else
    upstr = [' ' mark ' ' str];
  end
return;

function upstr=markUpdate(str, mark)
  if strcmp(mark, 'none'),
    upstr = [ '   ' str(4:end)];
  else
    upstr = [' ' mark ' ' str(4:end)];
  end
 
return;

function pop_lineStyle_Callback(hObject, eventdata, handles)
  vl    = get(handles.lbx_line,'Value');
  ud    = get(handles.lbx_line,'UserData');
  style = get(handles.pop_lineStyle,'String');
  style = style{get(handles.pop_lineStyle,'Value')};
  
  if ~length(vl)>1
    ud0=ud{vl};
    ud0.style = style;
    ud{vl}=ud0;
  else
    for i=1:length(vl),
      ud0=ud{vl(i)};
      ud0.style = style;
      ud{vl(i)}=ud0;
    end
  end
  set(handles.lbx_line,'UserData',ud);
return;

function rt = addnameCheck(str, addname)
  rt =0;
  if strcmp(addname,'Untitled')==0,
    for i=1:length(str),
      if findstr(str{i},addname)==4,
	warndlg('Input Unique name.');
	rt=1;
	return;
      end
    end
  end

return;

function psb_add_Callback(hObject, eventdata, handles)
  addname = get(handles.edit_add, 'String');
  str   = get(handles.lbx_line, 'String');
  ud    = get(handles.lbx_line, 'UserData');
  mark  = get(handles.pop_lineMark,'String');
  style = get(handles.pop_lineStyle,'String');
  mark  = mark{get(handles.pop_lineMark, 'Value')};
  str{end+1}=markPlus(addname, 'none');
  val=length(str);
  ud{val}.name  = addname;
  ud{val}.mark  = mark;
  ud{val}.style = style{get(handles.pop_lineStyle,'Value')};
  ud{val}.color = [0.7,0.7,0.7];

  set(handles.lbx_line, 'String', str);
  set(handles.lbx_line, 'Value',  val);
  set(handles.lbx_line, 'UserData', ud);
return;

function psb_delete_Callback(hObject, eventdata, handles)
  val=get(handles.lbx_line, 'Value');
  if isempty(val) || ~isempty(find(1<=val&val<=3)),
    warndlg('Select one or more excluding No.1-3.');
    return;
  end

  str   = get(handles.lbx_line, 'String');
  ud    = get(handles.lbx_line, 'UserData');
  str(val)=[];
  ud(val) =[];
  set(handles.lbx_line, 'String', str);
  if (val <=length(str)),
    set(handles.lbx_line, 'Value', val);
  else
    set(handles.lbx_line, 'Value', length(str));
  end
  set(handles.lbx_line, 'UserData', ud);
return;

function edit_add_Callback(hObject, eventdata, handles)
  addname = get(handles.edit_add, 'String');
  val  = get(handles.lbx_line, 'Value');
  str  = get(handles.lbx_line, 'String');
  ud   = get(handles.lbx_line, 'UserData');
  mark = get(handles.pop_lineMark,'String');
  mark  = mark{get(handles.pop_lineMark, 'Value')};

  if ~isempty(val) && isempty(find(1<=val&val<=3)),
    for i=1:length(val),
      str{val(i)}=markPlus(addname, 'none');
      ud{val(i)}.name = addname;
    end
  else
    warndlg('Select one excluding No.1-3.');
    return;
  end
  
  set(handles.lbx_line, 'String', str);
  set(handles.lbx_line, 'UserData', ud);
return;

 
function psb_set_Callback(hObject, eventdata, handles)
  ud   = get(handles.lbx_line, 'UserData');
  % Set output
  handles.output = ud;
  guidata(hObject,handles);

  %  Resume 
  if isequal(get(handles.LayoutManager_LProperty, 'waitstatus'), 'waiting')
    uiresume(handles.LayoutManager_LProperty);
  else
    delete(handles.LayoutManager_LProperty);
  end

  %LayoutManager_LProperty_deleteFcn(handles.LayoutManager_LProperty, [],handles);
return;

function psb_cancel_Callback(hObject, eventdata, handles)
  handles.output = -1;
  guidata(hObject,handles);

  %  Resume 
  if isequal(get(handles.LayoutManager_LProperty, 'waitstatus'), 'waiting')
    uiresume(handles.LayoutManager_LProperty);
  else
    delete(handles.LayoutManager_LProperty);
  end
return;



