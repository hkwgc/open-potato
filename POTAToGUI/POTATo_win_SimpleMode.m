function varargout=POTATo_win_SimpleMode(fnc,varargin)
% POTATo Window : Signal-Analysis Mode Control GUI
%  -- for SIMPLE-MODE (WINDOW 30) CONTROL--


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% 2010.10.20:
%   Bugfix : B101020B.

%======== Launch Switch ========
%global FOR_MCR_CODE;
switch fnc
  case {'DisConnectAdvanceMode','SaveData','Export2WorkSpace','ConnectAdvanceMode'},
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end
  case 'Suspend',
    Suspend(varargin{:});
  case 'Activate',
    Activate(varargin{:});
  case 'MakeMfile',
    varargout{1}=MakeMfile(varargin{:});
  case 'DrawLayout',
    varargout{1}=DrawLayout(varargin{:});
  case 'ChangeLayout',
    ChangeLayout(varargin{:});
    
    %=========================
    % Unseting Function List
    %=========================
  otherwise
    try
      % sub Function
      if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
      else
        feval(fnc, varargin{:});
      end
    catch
      % --> Undefined Function : Use Default Function
      if nargout,
        [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
      else
        POTATo_win(fnc,varargin{:});
      end
    end
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make GUI & Handle Control
function [h,pos]=myHandles(hs)
pos=[0 0]; % Donot Move
  
h=[hs.pop_SIMPLEM_recipe,...
  hs.txt_SIMPLEM_recipe,...
  hs.txt_SIMPLEM_discription,...
  hs.lbx_SIMPLEM_discription,...
  hs.psb_SIMPLEM_help,...
  hs.psb_SIMPLEM_InstallRecipe];

function Suspend(hs,varargin)
% Suspend Window : Visible off
h=myHandles(hs);
set(h,'Visible','off');
if ~isempty(varargin)
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for Suspend');
end

function hs=create_win(hs)
% Make Help button
tag='psb_SIMPLEM_help';
hs.(tag)=uicontrol(hs.figure1,'TAG',tag,...
  'Units','pixels',...
  'style','pushbutton',...
  'String','Help',...
  'Visible','off',...
  'Enable','off',...
  'Callback',['P3_gui_SimpleMode(''' tag '_Callback'',guidata(gcbo));'],...
  'Position',[637 391 114 21]);

% Bugfix :: 101020A
set(hs.txt_SIMPLEM_discription,'String','Description :');
guidata(hs.figure1,hs); % save handles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Activate(hs)
% Activate Single-Analysis Mode!

if ~isfield(hs,'psb_SIMPLEM_help') || ~ishandle(hs.psb_SIMPLEM_help)
  hs=create_win(hs);
elseif 0
  % debug
  try  %#ok
    delete(hs.psb_SIMPLEM_help);
  end
  hs=create_win(hs);
  disp(C__FILE__LINE_CHAR);
end

%=============================
% Move GUI : Current Position
%=============================
h=myHandles(hs);
set(h,'Visible','on');

%=============================
% Recipe Search...
%=============================
%P3_gui_SimpleMode('pop_SIMPLE_recipe_rehash',handles);
P3_gui_SimpleMode('pop_SIMPLEM_recipe_Callback',hs.pop_SIMPLEM_recipe,[],hs);

%-----------------------
% Make Local-Active-Data
%-----------------------
% get DataDef (II) Function
fcn=get(hs.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  actdata.fcn=fcn{get(hs.pop_filetype,'Value')};
  clear fcn;
end
% get Data-File
filedata=get(hs.lbx_fileList,'UserData');
if isempty(filedata),
  error('No File-Data Selected');
else
  actdata.data=filedata(get(hs.lbx_fileList,'Value'));
  clear filedata;
end
setappdata(hs.figure1, 'LocalActiveData',actdata); % XX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [msg, fnametmp]=MakeMfile(handles)
% get File List
msg='';

% fdata=get(handles.lbx_fileList,'UserData');
% fdata=fdata(get(handles.lbx_fileList,'Value'));

dfnc=get(handles.pop_filetype,'UserData');
dfnc=dfnc{get(handles.pop_filetype,'Value')};

actdata=getappdata(handles.figure1, 'LocalActiveData');
rcp=P3_gui_SimpleMode('getRecipe',handles);

key.actdata=actdata;
key.filterManage=rcp.Filter_Manager;

% -- File name Get --
if nargout<=1,
  % == Get M-File Name==
  [f p] = osp_uiputfile('*.m', ...
    'Output M-File Name', ...
    ['POTATo_' datestr(now,30) '.m']);
  if (isequal(f,0) || isequal(p,0)), return; end % cancel
  fname = [p filesep f];
end
% Make M-File
try
  fnametmp=feval(dfnc,'make_mfile',key);
  if nargout<=1,
    movefile(fnametmp,fname);
  end
catch
  msg=lasterr;return;
end

%------------------------------
% add Viewer
%  mail 2007.05.14
%------------------------------
wk=get(handles.ckb_Draw,'Value');
wk2=get(handles.ckb_Draw,'Visible');
if nargout<=1 && wk && strcmpi(wk2,'on')
  % --> get Layout-File
  layoutfile=get(handles.pop_Layout,'UserData');
  layoutfile=layoutfile{get(handles.pop_Layout,'Value')};
  
  make_mfile('fopen',fname,'a');
  try
    make_mfile('code_separator',1);
    make_mfile('with_indent','% Viewer');
    make_mfile('code_separator',1);
    make_mfile('with_indent',...
      sprintf('load(''%s'',''LAYOUT'');',layoutfile));
    make_mfile('with_indent',...
      {'if ~exist(''bhdata'',''var'') || isempty(bhdata)',...
      '  P3_view(LAYOUT,chdata,cdata);',...
      'else',...
      '  P3_view(LAYOUT,chdata,cdata, ...',...
      '           ''bhdata'',bhdata, ''bdata'', bdata);',...
      'end'});
  catch
    make_mfile('fclose');rethrow(lasterror);
  end
  make_mfile('fclose');
end

% Editor
%  mail 2007.05.14
if nargout<=1,edit(fname);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg=DrawLayout(handles)
% Get Layout File
layoutfile=get(handles.pop_Layout,'UserData');
layoutfile=layoutfile{get(handles.pop_Layout,'Value')};

[msg, fname]=MakeMfile(handles);
if msg,return;end

%[p f e]=fileparts(fname);
%eval(f);
try
  [chdata, cdata, bhdata, bdata] = ...
    scriptMeval(fname,...
    'chdata', 'cdata', ...
    'bhdata', 'bdata');
catch
  if 0
    errordlg({'Error in Making Data : ',...
      ['   ' lasterr]},'Error : Make Data');
  else
    msg={'Error in Making Data : ',['   ' lasterr]};
    return;
  end
end

load(layoutfile,'LAYOUT');

if OSP_DATA('GET','POTATO_HIPOTXMODE')
  xx={'AxesMenuFlag',false,'InfoMenuFlag',false,'FigureMenuFlag',false};
else
  xx={};
end
if isempty(bhdata)
  P3_view(LAYOUT,chdata,cdata,xx{:});
else
  P3_view(LAYOUT,chdata,cdata, ...
    'bhdata',bhdata, 'bdata', bdata,xx{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeLayout(hs)
% Search And 
hObject=hs.pop_Layout;
list0=get(hObject,'UserData');
v0 = get(hObject,'Value');
try
  lfile0=list0{v0}; % Layout-File (Default)
catch
  lfile0='';
end
%---------------------------------
% Search LayoutFile for Single Ana
%---------------------------------
list=P3_gui_SimpleMode('getLAYOUTs',hs);
% Empty :: default
if isempty(list)
  POTATo_win('ChangeLayout',hs);
  return;
end

fstr={};
for idx=1:length(list),
  if 1,
    % for future..
    %   LAYOUT is too old...
    load(list{idx},'LAYOUT');
  end
  if exist('LAYOUT','var')  && ...
      isfield(LAYOUT,'FigureProperty') && ...
      isfield(LAYOUT.FigureProperty,'Name')
    fstr{end+1}=LAYOUT.FigureProperty.Name;
  else
    [p f]=fileparts(list{idx}); %#ok
    fstr{end+1}=f;
  end
end

% Sort
[fstr,idx]=sort(fstr);
list=list(idx);

set(hObject, 'String', fstr);
set(hObject, 'UserData', list);
v=find(strcmpi(list,lfile0));
if isempty(v),v=1;end
set(hObject, 'Value', v);


