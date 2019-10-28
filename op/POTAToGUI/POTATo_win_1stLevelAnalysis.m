function varargout=POTATo_win_1stLevelAnalysis(fnc,varargin)
% POTATo Window : 1st-Level-Analysis Data Display Mode: Control GUI


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: POTATo_win_1stLevelAnalysis.m 180 2011-05-19 09:34:28Z Katura $

%======== Launch Switch ========
switch fnc
  case {'DisConnectAdvanceMode'},
    if nargout,
      [varargout{1:nargout}]=POTATo_win(fnc,varargin{:});
    else
      POTATo_win(fnc,varargin{:});
    end

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

function [hs,pos]=myHandles(h)
% Return Entry Handle
pos0=get(h.frm_AnalysisArea,'Position');
pos1=get(h.frm_1stAnaArea,'Position');
pos=pos0(1:2)-pos1(1:2);
hs=[...
    h.txt_FLA_title,...
    h.txt_FLA_name,...
    h.txt_FLA_HST,...
    h.lbx_FLA_HST,...
    h.txt_FLA_FSK,...
    h.lbx_FLA_FSK,...
    h.txt_FLA_ISK,...
    h.lbx_FLA_ISK];

function Suspend(handles,varargin)
[hs,pos]=myHandles(handles);
suspend_comm(hs,pos,handles);
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','on');

%--> back-->
set(handles.pop_fileinfo,'Callback',...
  'POTATo(''pop_fileinfo_Callback'',gcbo,[],guidata(gcbf));');

function [header,data,serachkey]=loadFLA(handles)
% Load Current FLA Data
fcn=get(handles.pop_filetype,'UserData');
if isempty(fcn),
  error('No Data Function Selected');
else
  fcn=fcn{get(handles.pop_filetype,'Value')};
end

%--> Modify :: Meeting on 27-Apr-2007 <--
% Select 1st-Lvl-Ana by fileinfo-popupmenu
id  = get(handles.pop_fileinfo,'UserData');
id   =id(get(handles.pop_fileinfo,'Value'));

filedata=get(handles.lbx_fileList,'UserData');
if length(filedata)<id
  error('No File-Data Selected');
else
  %d0=filedata(get(handles.lbx_fileList,'Value'));
  d0=filedata(id);
  clear filedata;
end
[header,data,serachkey]=feval(fcn,'load',d0);

function Activate(handles,varargin)
% Activate 1st-Lvl-Ana Display-Mode

%=============================
% Move GUI : Current Position
%=============================
[hs,pos]=myHandles(handles);
activate_comm(hs,pos,handles);

% ==> 
% TODO:
h0=POTATo('getViewerGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');
h0=POTATo('getOutGUI_IO',handles.figure1,[],handles);
set(h0,'Visible','off');

set(handles.pop_fileinfo,'Callback',...
  'POTATo_win_1stLevelAnalysis(''pop_fileinfo_Callback'',gcbo,[],guidata(gcbf));');
if 0
  pop_fileinfo_Callback(handles.pop_fileinfo,[],handles);
end

function pop_fileinfo_Callback(h,e,handles)
%========================
% Load Data-File
%========================
% get 1st-Lvel-Analysis Data
[header,data,serachkey]=loadFLA(handles);

%========================
% Change Text Flag
%========================
set(handles.txt_FLA_name,'String',header.function);
if iscell(header.filename)
	str={'Original Raw-Data File : ',header.filename{1},''};
else
	str={'Original Raw-Data File : ',header.filename,''};
end
info = OspFilterDataFcn('getInfo',header.FilterData);
str={str{:},info{:}};
set(handles.lbx_FLA_HST,'Value',1,'String',str);

%------------------
% File Search Key
%------------------
str={};
if isfield(serachkey,'F')
  k=serachkey.F;
  fn=fieldnames(k);
else
  fn={};
end
for idx=1:length(fn)
  val=eval(['k.' fn{idx}]);
  if isempty(val),continue;end
  if ischar(val) || isnumeric(val)
    s0=P3_ldisp0(val);
  else
    s0=P3_ldisp0(val(1));
  end
  dum=fn{idx};dum(:)=' ';
  str{end+1}=sprintf('%s\t: %s',fn{idx},char(s0(1)));
  if iscell(s0),
    for i0=2:length(s0)
      str{end+1}=sprintf('%s\t| %s',dum,char(s0(i0)));
    end
  end
  if ischar(val) || isnumeric(val)
    continue;
  end
  for i1=2:length(val)
    s0=P3_ldisp0(val(i1));
    str{end+1}=sprintf('%s\t| %s',dum,char(s0(1)));
    for i0=2:length(s0)
      str{end+1}=sprintf('%s\t| %s',dum,char(s0(i0)));
    end
  end
end
if isempty(str),str={'== None =='};end
set(handles.lbx_FLA_FSK,'Value',1,'String',str);

%------------------
% Inner Search Key
%------------------
str={};
if isfield(serachkey,'I')
  k=serachkey.I;
  fn=fieldnames(k);
else
  fn={};
end
for idx=1:length(fn)
  val=eval(['k.' fn{idx}]);
  if isempty(val),continue;end
  if ischar(val) || isnumeric(val)
    s0=P3_ldisp0(val);
  else
    s0=P3_ldisp0(val(1));
  end
  dum=fn{idx};dum(:)=' ';
  str{end+1}=sprintf('%s\t: %s',fn{idx},char(s0(1)));
  if iscell(s0),
    for i0=2:length(s0)
      str{end+1}=sprintf('%s\t| %s',dum,char(s0(i0)));
    end
  end
  if ischar(val) || isnumeric(val)
    continue;
  end
  for i1=2:length(val)
    s0=P3_ldisp0(val(i1));
    str{end+1}=sprintf('%s\t| %s',dum,char(s0(1)));
    for i0=2:length(s0)
      str{end+1}=sprintf('%s\t| %s',dum,char(s0(i0)));
    end
  end
end
if isempty(str),str={'== None =='};end
set(handles.lbx_FLA_ISK,'Value',1,'String',str);


% ( move .fig)
fn=get(0,'FixedWidthFontName');
set(handles.lbx_FLA_FSK,'FontName',fn);
set(handles.lbx_FLA_ISK,'FontName',fn);
POTATo('pop_fileinfo_Callback',h,e,handles);

function ChangeLayout(handles)
% Change Layout Data
%---------------------------------
% Search LayoutFile for Single Ana
%---------------------------------
osppath     = OSP_DATA('GET','OspPath');
searchPath  = [osppath filesep 'ospData'];
list = {[searchPath filesep 'fla_layout.mat']};
% Set lbx_layoutfile LIST
fstr = {'1st-Lvel-Ana Layout'};

%----------------------------
% Add Special Layout
%----------------------------
% TODO:
%header=loadFLA(handles);

%----------------------------
% Update GUI
%----------------------------
set(handles.pop_Layout,...
  'Value', 1,...
  'String', fstr,...
  'UserData', list);

function ConnectAdvanceMode(handles,varargin)
%
% Default : ADV-Mode
% ==> Deleted

% Meeting at 2007.03.09 (Fri).
%  --> Comment Out
%%%hs=handles.advpsb_2ndLvlAna;
%set(hs,'Visible','on');

