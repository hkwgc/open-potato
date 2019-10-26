function varargout = searchPrj(varargin)
% SEARCHPRJ M-file for searchPrj.fig
%      SEARCHPRJ, by itself, creates a new SEARCHPRJ or raises the existing
%      singleton*.
%
%      H = SEARCHPRJ returns the handle to a new SEARCHPRJ or the handle to
%      the existing singleton*.
%
%      SEARCHPRJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEARCHPRJ.M with the given input arguments.
%
%      SEARCHPRJ('Property','Value',...) creates a new SEARCHPRJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before searchPrj_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to searchPrj_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help searchPrj


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Last Modified by GUIDE v2.5 21-Oct-2005 14:29:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @searchPrj_OpeningFcn, ...
                   'gui_OutputFcn',  @searchPrj_OutputFcn, ...
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


function searchPrj_OpeningFcn(hObject, eventdata, handles, varargin)

  handles.output = hObject;

  try,
    ax=axes('position',[0, 0.15, 1, 0.85]);
    handles.axes_1  = ax; 
    c=imread('searchPrj.bmp');
    image(c);
    axis off
    a=axis;
    set(hObject,'Color',[.8, .8, .8]);
    setappdata(handles.figure1,'PageID',1);
  end

  guidata(hObject, handles);
  try
      OpenPage(handles);
  end

function varargout = searchPrj_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Request
try,
	% disp('Delete');
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close Request
pageid = getappdata(handles.figure1,'PageID');
if pageid<=3,
   a=questdlg('Do your want to stop loading Project?', ...
       'Closing...','Yes','No','Yes');
   if strcmp('No',a),
       return;
   end
end
delete(hObject);

% --- Executes on button press in psb_Back.
function psb_Back_Callback(hObject, eventdata, handles)
  pageid = getappdata(handles.figure1,'PageID');
  if (pageid==1), return; end
  idx  =getappdata(handles.figure1,'ppathIDindex');
  if isempty(idx) || idx==1,
	  setappdata(handles.figure1,'PageID',pageid-1);
  else,
	  setappdata(handles.figure1,'ppathIDindex',idx-1);
  end
  OpenPage(handles);
  
function psb_next_Callback(hObject, eventdata, handles)
  pageid = getappdata(handles.figure1,'PageID');
  setappdata(handles.figure1,'PageID',pageid+1);
  OpenPage(handles);
  
function OpenPage(handles)
  set(handles.psb_Back,'Enable', 'off');
  set(handles.psb_next,'Enable', 'off');

  pageid = getappdata(handles.figure1,'PageID');
  whd = getappdata(handles.figure1,'WorkHD');

  switch (pageid),
	  case 1,
		  whd(find(~ishandle(whd)))=[];
		  if ~isempty(whd), delete(whd); end
		  whd=[];
          
		  set(handles.psb_Back,'Visible','off');
          axes(handles.axes_1);
          whd(1)=text(120, 60,...
              '1. Set Find Directory.');
		  sp=getappdata(handles.figure1, 'SearchPath');
		  if isempty(sp), sp=pwd; end
		  whd(2)=uicontrol(...
              'units','normalized', ...
              'position',[0.4, 0.6, 0.5, 0.1], ...
              'Style', 'edit', ...
              'BackgroundColor',[1 1 1], ...
              'HorizontalAlignment','left', ...
              'String', sp, ...
              'UserData', sp, ...
              'Callback',['searchPrj(''checkdir'',gcbo,[],guidata(gcbo))']);
          setappdata(handles.figure1, 'SearchPath', sp);
          whd(3)=uicontrol(...
              'units','normalized', ...
              'position',[0.80, 0.5, 0.1, 0.08], ...
              'Style', 'pushbutton', ...
              'String', '...', ...
              'Callback',['searchPrj(''browse'',gcbo,[],guidata(gcbo))']);
          set(handles.psb_next,'Enable', 'on');
          
	  case 2,
		  setappdata(handles.figure1,'ppathIDindex',[]);
		  whd(find(~ishandle(whd)))=[];
          if ~isempty(whd), delete(whd); end
          whd=[];

          sp_o  = getappdata(handles.figure1, 'SearchPathOld');
          sp    = getappdata(handles.figure1, 'SearchPath');
          if ~strcmp(sp, sp_o),
              whd(1)=text(120, 60,...
                  'Searching Projict now .....');
          
              drawnow;
              rslt=find_dir('OspDataDir',sp);
              setappdata(handles.figure1, 'SearchPathOld', sp);
              setappdata(handles.figure1,'ppath',rslt);
              delete(whd); whd=[];
          else,
              rslt = getappdata(handles.figure1,'ppath');
          end

          set(handles.psb_Back,...
              'Visible','on', ...
              'Enable', 'on');
          if isempty(rslt),
              whd(1)=text(120, 60,...
                  'No Project exist.');
          else,
              spsz=length(sp);
              setappdata(handles.figure1,'ppath',rslt);
              setappdata(handles.figure1,'ppathID',1);
              for idx=1:length(rslt),
                  rslt{idx}(1:spsz)=[];
                  rslt{idx}=['./' rslt{idx}];
              end
              whd(1)=text(120, 60, ...
                  '2. Select Project Dir');
              whd(2)=uicontrol(...
                  'units','normalized', ...
                  'Position', [0.4, 0.3, 0.5, 0.35], ...
                  'Style','listbox', ...
                  'BackgroundColor',[1 1 1], ...
                  'String', rslt, ...
				  'Max',10, ...
                  'HorizontalAlignment','left', ...
                  'Callback',['setappdata(gcf,''ppathID'', get(gcbo,''Value''));']);
              whd(3)=text(140, 80,sp, ...
				  'Interpreter','none');
              set(handles.psb_next,...
				  'String', 'Next >', ...
                  'Visible','on', ...
                  'Enable', 'on');
          end
          
      case 3,
          whd(find(~ishandle(whd)))=[];
          if ~isempty(whd), delete(whd); end
          whd=[];

          rslt=getappdata(handles.figure1,'ppath');
          val =getappdata(handles.figure1,'ppathID');
		  idx =getappdata(handles.figure1,'ppathIDindex');
		  if isempty(idx), 
			  idx=1; 
			  setappdata(handles.figure1,'ppathIDindex',1);
		  end
          projectpath  = rslt{val(idx)};
          
          p = OspProject('LoadData');
		  if isempty(p),
			  id=[];
		  else,
			  id= find(strcmp({p.Path}, projectpath));
		  end
		  setappdata(handles.figure1,'ProjectID',id);
		  
		  p0 = OspProject('GetProjectDataInDir', projectpath);

		  if isempty(id),
              whd(1)=text(120, 60, ...
                  ' * Project Data:');
			  
              whd(2)=uicontrol(...
                  'units','normalized', ...
                  'Position', [0.4, 0.3, 0.5, 0.45], ...
                  'Style','listbox', ...
				  'UserData',p0, ...
				  'BackgroundColor',[1 1 1], ...
                  'HorizontalAlignment','left');
			  
          else,
              whd(1)=text(120, 60, ...
                  ' 3. Select Project Data');
              whd(2)=uicontrol(...
                  'units','normalized', ...
                  'Position', [0.4, 0.3, 0.5, 0.35], ...
                  'Style','listbox', ...
				  'UserData',p0, ...
                  'BackgroundColor',[1 1 1], ...
                  'HorizontalAlignment','left');
			  whd(3)=uicontrol(...
                  'units','normalized', ...
				  'Position', [0.4, 0.67, 0.2, 0.1], ...
				  'Style','radiobutton', ...
				  'String', 'Load', ...
				  'BackgroundColor',[1 1 1], ...
				  'Value',1, ...
				  'UserData', p0, ...
				  'HorizontalAlignment','left', ...
                  'Callback','searchPrj(''selectProj'',gcbo,[],guidata(gcbo))');
			  whd(4)=uicontrol(...
                  'units','normalized', ...
				  'Position', [0.7, 0.67, 0.2, 0.1], ...
				  'Style','radiobutton', ...
				  'String', 'Original', ...
				  'BackgroundColor',[1 1 1], ...
				  'UserData', p(id), ...
				  'HorizontalAlignment','left', ...
                  'Callback','searchPrj(''selectProj'',gcbo,[],guidata(gcbo))');
          end
		  try,
			  msg = OspProject('Info',p0);
			  set(whd(2),'String',msg);
		  catch,
			  msg = 'Error Occure';
		  end
          set(handles.psb_Back,...
              'Visible','on', ...
              'Enable', 'on');
		  if length(val)==idx,
			  set(handles.psb_next,...
				  'String', 'Finish', ...
				  'Visible','on', ...
				  'Enable', 'on');
		  else,
			  set(handles.psb_next,...
				  'String', 'Save', ...
				  'Visible','on', ...
				  'Enable', 'on');
		  end
		  
	  case 4,
		  pj=get(whd(2),'UserData');
          whd(find(~ishandle(whd)))=[];
          if ~isempty(whd), delete(whd); end
          whd=[];
		  
		  % Save Operation
		  id=getappdata(handles.figure1,'ProjectID');
		  whd(1)=text(120, 60, ...
			  ' * Saveing Project ....');
		  if isempty(id),
			  OspProject('Add2',pj);
		  else,
			  OspProject('Replace',id, pj);
		  end

		  % Terminate
		  val =getappdata(handles.figure1,'ppathID');
		  idx  =getappdata(handles.figure1,'ppathIDindex');  
		  if isempty(idx) || idx==length(val),
			  % if Finish?
			  delete(handles.figure1);
			  return;
		  else,
			  % Exist Next Probe 
			  setappdata(handles.figure1,'ppathIDindex',idx+1);
			  setappdata(handles.figure1,'PageID',3);
			  setappdata(handles.figure1,'WorkHD',whd);
			  OpenPage(handles);
			  return;
		  end
      otherwise,
		  delete(handles.figure1);
		  return;
  end
  setappdata(handles.figure1,'WorkHD',whd);
return;

%=================
% For Page 1
%=================
function checkdir(hObject,eventdata,handles),

p=get(hObject,'String');
if isdir(p),
    set(hObject,'UserData',p, ...
        'ForegroundColor',[0 0 0]);
    setappdata(handles.figure1, 'SearchPath', p);
else,
    p2=get(hObject,'UserData');
    set(hObject,'String',p2, ...
        'ForegroundColor',[1 0 0]);
    errordlg('No such File or Directory!');
end

function browse(hObject,eventdata,handles),
whd=getappdata(handles.figure1,'WorkHD');
try,
    d=get(whd(2),'UserData');
    if isdir(d),
        d=uigetdir(d);
    else,
        d=uigetdir(d);
    end
    if isequal(d,0), return; end
    set(whd(2),'String',d);
    checkdir(whd(2),[],handles);
end

function selectProj(hObject,eventdata,handles),
whd=getappdata(handles.figure1,'WorkHD');
pj=get(hObject,'UserData');
setappdata(whd(2),'UserData',pj);
msg = OspProject('Info',pj);
set(whd(2),'String',msg);
if hObject==whd(3),
	set(whd(3),'Value', 1);
	set(whd(4),'Value', 0);
else,
	set(whd(3),'Value', 0);
	set(whd(4),'Value', 1);
end

return;
