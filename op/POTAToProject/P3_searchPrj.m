function varargout = P3_searchPrj(varargin)
% P3_searchPrj is wizard to Import it to current.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% $Id: P3_searchPrj.m 180 2011-05-19 09:34:28Z Katura $

% Last Modified by GUIDE v2.5 21-Oct-2005 14:29:56


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code - DO NOT EDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_searchPrj_OpeningFcn, ...
  'gui_OutputFcn',  @P3_searchPrj_OutputFcn, ...
  'gui_LayoutFcn',  [] , ...
  'gui_Callback',   []);
if nargin && ischar(varargin{1})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
  [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
  gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI I/O Functioins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P3_searchPrj_OpeningFcn(hObject, ev, handles, varargin)
% Init this Wizard.

%===========================
% Checking Open
%===========================
if isfield(handles,'axes_1')
  % is figure already open?
  figure(hObject);
  return;
end

%===========================
% Draw : Background Image
%===========================
try
  ax=axes('position',[0, 0.15, 1, 0.85]);
  handles.axes_1  = ax;
  p=fileparts(which('searchPrj'));
  c=imread([p filesep 'searchPrj.bmp']);
  image(c);
  axis off
  set(hObject,'Color',[.8, .8, .8]);
catch
  disp(lasterr);
  warning('Warning : Error occur in drawing Background Image.');
end

try
  % ------------------
  % Set Page ID to  1
  % ------------------
  setappdata(handles.figure1,'PageID',1);
  OpenPage(handles);
catch
  disp(lasterr);
  disp(C__FILE__LINE__CHAR);
end

%==========================
% Update GUIDATA : 
%==========================
% Oupt put : Figure handles
handles.output = hObject;
guidata(hObject, handles);

function varargout = P3_searchPrj_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Request
% Noting in particuler now.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Page Control Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================
function psb_Back_Callback(h, ev, handles)
% Back to before Window : execute on 'Back' Push-Button
%=======================================================
pageid = getappdata(handles.figure1,'PageID');
if (pageid==1), return; end
if pageid~=3
  setappdata(handles.figure1,'PageID',pageid-1);
else
  % Projects loop?
  idx  =getappdata(handles.figure1,'ppathIDindex');
  if isempty(idx) || idx==1,
    % Normal loop.
    setappdata(handles.figure1,'PageID',pageid-1);
  else
    % Project loop : back to before project.
    setappdata(handles.figure1,'ppathIDindex',idx-1);
  end
end
% Re Open Project
OpenPage(handles);

%=======================================================
function psb_next_Callback(h, ev, handles)
% Exceed next Window : execute on 'Next' Push-Button
%=======================================================
pageid = getappdata(handles.figure1,'PageID');
setappdata(handles.figure1,'PageID',pageid+1);
% Open Project
OpenPage(handles);

%=======================================================
function OpenPage(handles)
% Change Page.  Control Function
%=======================================================

% ---------------------
% Set Default
% ---------------------
set(handles.psb_Back,'Enable', 'off');
set(handles.psb_next,'Enable', 'off');

% ----------------------
% Load Application Data
% ----------------------
% Page ID
pageid = getappdata(handles.figure1,'PageID');
% Working (Current ) Handles
whd    = getappdata(handles.figure1,'WorkHD');

% ----------------------
% Open Page
% ----------------------
switch (pageid),
  case 1,
    %**************************
    % Page 1
    %   Setting Search Path
    %*************************
    % I/O Data :
    % Application Data : SearchPath
    %   Search Path is Root path to Search Project.
    
    % Delete All Working Handles
    whd(~ishandle(whd))=[];
    if ~isempty(whd), delete(whd); end
    whd=[];

    % Load Search Path
    sp=getappdata(handles.figure1, 'SearchPath');
    % 
    if isempty(sp), 
      sp=pwd;
      setappdata(handles.figure1, 'SearchPath', sp);
    end

    % Display Page Status.
    set(0,'CurrentFigure',handles.figure1);
    set(handles.figure1,'CurrentAxes',handles.axes_1);
    whd(1)=text(120, 60, '1. Set Find Directory.');
    
    % Make Search-Path Edit-Text
    whd(2)=uicontrol(...
      'units','normalized', ...
      'position',[0.4, 0.6, 0.5, 0.1], ...
      'Style', 'edit', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'String', sp, ...
      'UserData', sp, ...
      'Callback','P3_searchPrj(''checkdir'',gcbo,[],guidata(gcbo))');
    
    % Make Search Path Browse Push Button
    whd(3)=uicontrol(...
      'units','normalized', ...
      'position',[0.80, 0.5, 0.1, 0.08], ...
      'Style', 'pushbutton', ...
      'String', '...', ...
      'Callback','P3_searchPrj(''browse'',gcbo,[],guidata(gcbo))');

    % Enable / Disable 'Page Change' Push Button
    set(handles.psb_Back,'Visible','off');
    set(handles.psb_next,'Enable', 'on');

  case 2,
    %***********
    % Page 2
    %    Search Project & Select Project
    %***********
    % Input  : SearchPath     (Search Path)
    %        : SearchPathOld  (Searched Path)
    %        : Current Project Parent
    % Output : ppath          (Path of Project)
    %        : ppathIDindex   (Current Path-ID : Initalize)
    %        : SearchPathOld  (Searched Path)

    % Delete All Working Handles
    whd(~ishandle(whd))=[];
    if ~isempty(whd), delete(whd); end
    whd=[];

    setappdata(handles.figure1,'ppathIDindex',[]);
    sp_o  = getappdata(handles.figure1, 'SearchPathOld');
    sp    = getappdata(handles.figure1, 'SearchPath');
    pdir  = OSP_DATA('get','PROJECTPARENT');
    if ~strcmp(sp, sp_o),
      % ----------------
      % Search Project!
      % ----------------
      h=text(120, 60,...
        'Searching Projict now .....');
      try
        files=find_file('^PROJECT_DATA\.mat$', sp,'-i');
        rslt={};
        % Checking Is
        for idx=1:length(files)
          s=load(files{idx});
          fp=fileparts(files{idx});
          fpup=fileparts(fp);
          if strcmpi(fpup,pdir),continue;end
          
          if isfield(s,'Project') && ...
              isfield(s.Project,'Ver')  && ...
              s.Project.Ver>1.9999
            rslt{end+1}=fp;
          end
        end
      catch
        % Error : Back to Pange-1
        errordlg({'Error Occur : ',...
          ['   ' lasterr]},'Search Error');
        %setappdata(handles.figure1,'PageID',1);
        %OpenPage(handles);
      end
      setappdata(handles.figure1, 'SearchPathOld', sp);
      setappdata(handles.figure1,'ppath',rslt);
      delete(h);
    else
      rslt = getappdata(handles.figure1,'ppath');
    end

    set(handles.psb_Back,...
      'Visible','on', ...
      'Enable', 'on');
    if isempty(rslt),
      whd(1)=text(120, 60,...
        'No Project exist.');
    else
      % Exceed to Select Proper Project
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
        'Callback','setappdata(gcf,''ppathID'', get(gcbo,''Value''));');
      whd(3)=text(140, 80,sp, ...
        'Interpreter','none');
      set(handles.psb_next,...
        'String', 'Next >', ...
        'Visible','on', ...
        'Enable', 'on');
    end

  case 3,
    %***********
    % Page 3
    %    Do you want to save?
    %***********
    % Input  : SearchPath     (Search Path)
    %        : SearchPathOld  (Searched Path)
    %        : ppath          (Path of Project)
    %        : ppathIDindex   (Current Path-ID)
    
    % Delete All Working Handles
    whd(~ishandle(whd))=[];
    if ~isempty(whd), delete(whd); end
    whd=[];

    % Select Project Index
    rslt=getappdata(handles.figure1,'ppath');
    val =getappdata(handles.figure1,'ppathID');
    idx =getappdata(handles.figure1,'ppathIDindex');
    if isempty(idx),
      idx=1;
      setappdata(handles.figure1,'ppathIDindex',1);
    end
    projectpath  = rslt{val(idx)};
    if ~isdir(projectpath)
      % Project is already Moved.
      whd(1)=text(120, 60, ...
        ' * Already Moved.');
    else
      % Move Project?
      p = POTAToProject('LoadData');
      p0 = POTAToProject('GetProjectDataInDir', projectpath);
      
      if isempty(p),
        id=[];
      else
        id= find(strcmp({p.Name}, p0.Name));
      end
      setappdata(handles.figure1,'ProjectID',id);
      
      % for direction
      whd(1)=text(120, 60, ...
        ' 3. Do you wat to move the Project Data to Current Project?');

      % Project Information
      whd(2)=uicontrol(...
        'units','normalized', ...
        'Position', [0.4, 0.3, 0.5, 0.35], ...
        'Style','listbox', ...
        'UserData',p0, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left');
      
      % Do you want to move? --> yes/no
      whd(3)=uicontrol(...
        'units','normalized', ...
        'Position', [0.5, 0.67, 0.1, 0.1], ...
        'Style','radiobutton', ...
        'String', 'Yes', ...
        'BackgroundColor',[1 1 1], ...
        'Value',1, ...
        'HorizontalAlignment','left',...
        'Callback',...
        ['h=get(gcbo,''UserData'');',...
        'set(h,''Value'',0);',...
        'set(gcbo,''Value'',1)']);
      whd(4)=uicontrol(...
        'units','normalized', ...
        'Position', [0.7, 0.67, 0.1, 0.1], ...
        'Style','radiobutton', ...
        'String', 'No', ...
        'BackgroundColor',[1 1 1], ...
        'UserData', whd(3), ...
        'HorizontalAlignment','left',...
        'Callback',...
        ['h=get(gcbo,''UserData'');',...
        'set(h,''Value'',0);',...
        'set(gcbo,''Value'',1)']);
      set(whd(3),'UserData',whd(4));

      try
        msg = POTAToProject('Info',p0);
        set(whd(2),'String',msg);
      catch
        msg = 'Error Occure';
      end
    end
    set(handles.psb_Back,...
      'Visible','on', ...
      'Enable', 'on');
    set(handles.psb_next,...
      'Visible','on', ...
      'Enable', 'on');

  case 4,
    %***********
    % Page 4
    %    Check Save/Not Move Operation
    %***********
    % (Do not delete working-handles
    isyes=false;
    if length(whd)>=3
      prj  =get(whd(2),'UserData');
      isyes=get(whd(3),'Value');
    end
    
    % Delete All Working Handles
    whd(~ishandle(whd))=[];
    if ~isempty(whd), delete(whd); end
    whd=[];

    if ~isyes
      % Not Save : Do Noting
      % Exceed Next
      setappdata(handles.figure1,'PageID',5);
      setappdata(handles.figure1,'WorkHD',whd);
      OpenPage(handles);
      return;
    end
      
    % Get Save Dir
    %mv_from = [prj.Path filesep prj.Name];
    mv_from = [prj.Path filesep prj.Name];
    whd(1)=text(120, 60, 'a');
    set(whd(1),...
      'Interpreter','none',...
      'String',[' * Move  ' mv_from],...
      'UserData',mv_from);
    whd(2)=uicontrol(...
      'units','normalized', ...
      'Position', [0.4, 0.5, 0.1, 0.1], ...
      'Style','text',...
      'String', ' * Name : ',...
      'UserData',prj,...
      'BackgroundColor',[1 1 1], ...
      'Value',1, ...
      'HorizontalAlignment','left');
    whd(3)=uicontrol(...
      'units','normalized', ...
      'Position', [0.5, 0.5, 0.4, 0.1], ...
      'Style','edit',...
      'String', prj.Name,...
      'BackgroundColor',[1 1 1], ...
      'Value',1, ...
      'HorizontalAlignment','left',...
      'Callback','P3_searchPrj(''checkprjname'',gcbo,[],guidata(gcbo))');    
    whd(4)=uicontrol(...
      'units','normalized', ...
      'Position', [0.4, 0.67, 0.5, 0.1], ...
      'Style','text',...
      'String', 'Please Change Name. (we have data, already)',...
      'HorizontalAlignment','left');
    checkprjname(whd(3),[],handles);
    % Try to Re Open
    if isempty(get(whd(3),'UserData'))
      % Can not move
      set(handles.psb_Back,...
        'Visible','on', ...
        'Enable', 'on');
      set(handles.psb_next,...
        'Visible','on', ...
        'Enable', 'off');
    else
      % Can be move
      setappdata(handles.figure1,'PageID',5);
      setappdata(handles.figure1,'WorkHD',whd);
      OpenPage(handles);
      return;
    end
  case 5
    %***********
    % Page 5
    %    Move Operation
    %***********
    % (Do not delete working-handles
    
    % Move now!
    if ~isempty(whd)
      % get Move Directorys
      mv_from = get(whd(1),'UserData');
      prj     = get(whd(2),'UserData');
      
      pdir  = OSP_DATA('get','PROJECTPARENT');
      prj.Path = pdir;
      prj.Name = get(whd(3),'UserData');
      mv_to    = [pdir filesep prj.Name];
      
      % Move Normaly
      if ~isdir(mv_to) && isdir(mv_from)
        [s,msg]=movefile(mv_from,mv_to);
      else
        s=false;
        msg='Could not save : No such file or Directory';
      end
      if ~s, 
        set(handles.figure1,'WindowStyle','modal')
        uiwait(errordlg(msg));
      else
        POTAToProject('Add2',prj);
      end
    end
    
    % Terminate
    val =getappdata(handles.figure1,'ppathID');
    idx  =getappdata(handles.figure1,'ppathIDindex');
    if isempty(idx) || idx==length(val),
      % if Finish?
      delete(handles.figure1);
      return;
    else
      % Exist Next Project
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Page 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkdir(hObject,ev,handles)
% Check if Search-Path is directory
p=get(hObject,'String');
if isdir(p),
  set(hObject,'UserData',p, ...
    'ForegroundColor',[0 0 0]);
  setappdata(handles.figure1, 'SearchPath', p);
else
  p2=get(hObject,'UserData');
  set(hObject,'String',p2, ...
    'ForegroundColor',[1 0 0]);
  errordlg('No such File or Directory!');
end
if 0, disp(ev); end

function browse(hObject,ev,handles)
% set Search-Project by uigetdir.
whd=getappdata(handles.figure1,'WorkHD');
try
  d=get(whd(2),'UserData');
  if isdir(d),
    d=uigetdir(d);
  else
    d=uigetdir(d);
  end
  if isequal(d,0), return; end
  set(whd(2),'String',d);
  checkdir(whd(2),[],handles);
catch
  errordlg({'Error in P3-Search Project :',lasterr},...
    'Browse Error');
  if 0
    get(hObject);
    disp(ev);
    disp(handles);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Page 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkprjname(h,ev,handles)
% Check Project Name
%  if ~isdir Project : set UserData

%whd=getappdata(handles.figure1,'WorkHD');
%prj=get(whd(2),'UserData');
pdir  = OSP_DATA('get','PROJECTPARENT');
name  = get(h,'String');
newprjpath = [pdir filesep name];
if ~isdir(newprjpath)
  set(h,'UserData',name);
  set(handles.psb_next,...
    'Visible','on', ...
    'Enable', 'on');
else
  set(h,'UserData',[]);
  set(handles.psb_next,...
    'Visible','on', ...
    'Enable', 'off');
end
