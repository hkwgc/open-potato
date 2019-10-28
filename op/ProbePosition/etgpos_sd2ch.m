function varargout = etgpos_sd2ch(varargin)
% ETGPOS_SD2CH M-file for etgpos_sd2ch.fig
%      ETGPOS_SD2CH, by itself, creates a new ETGPOS_SD2CH or raises the existing
%      singleton*.
%
%      H = ETGPOS_SD2CH returns the handle to a new ETGPOS_SD2CH or the handle to
%      the existing singleton*.
%
%      ETGPOS_SD2CH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETGPOS_SD2CH.M with the given input arguments.
%
%      ETGPOS_SD2CH('Property','Value',...) creates a new ETGPOS_SD2CH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etgpos_sd2ch_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etgpos_sd2ch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etgpos_sd2ch

% Last Modified by GUIDE v2.5 31-Mar-2006 19:49:07


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
  'gui_OpeningFcn', @etgpos_sd2ch_OpeningFcn, ...
  'gui_OutputFcn',  @etgpos_sd2ch_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Opening Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etgpos_sd2ch_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% Opening Function of etgpos_sd2ch!:
%    1. Initialize
%    2. Open Position File
%    3. Wait
handles.output = [];
guidata(hObject, handles);

set(hObject,'Color','black');
% Add Menu;
uimenu_Osp_Graph_Option(handles.figure1);

% Open Position File
pos=psb_dbg_ReadPos_Callback(handles.psb_dbg_ReadPos,[],handles);
if isempty(pos), return; end

% Add Help Menu
if 0
  if ~isfield(handles,'menu_myHelp')
    p=fileparts(which('POTATo'));
    fs=filesep;
    lang =OSP_DATA('GET','HELP_LANG');
    s=[p fs 'html' fs lang fs 'man' fs 'ProbePosition' fs 'ReadPosFile.html'];
    handles.menu_myHelp= uimenu(hObject,'Label','Platform-Help',...
      'Callback',sprintf('helpview(''%s'')',s));
    guidata(hObject, handles);
  end
end
% --> Waiting for user response
if 1,
  uiwait(handles.figure1);
else
  % Debug Mode..
  disp(C__FILE__LINE__CHAR);
  handles.output = 'dumy';
  guidata(hObject, handles);
end

function axes1_CreateFcn(hObject, eventdata, handles) %#ok
%--> Axis
set(hObject,'Color','none');

% --> Reload
function pos=psb_dbg_ReadPos_Callback(hObject, eventdata, handles)  %#ok
% Reload Position Data
pos=[];
pwdtmp = pwd;
pj=OSP_DATA('GET','PROJECT');        % Open Project Data
if isempty(pj)
  errordlg('Open Project at First!');return;  % No Project Data
end
cd(pj.Path);
try
  [fn, pn] = uigetfile('*.pos');
catch
  cd(pwdtmp);rethrow(lasterr);
end
cd(pwdtmp);
% Canncel ?
if isequal(fn,0) ||  isequal(pn,0),return;end
% --> etg_pos_fread must be newer than 30-Mar-2006!!
pos = etg_pos_fread([pn filesep fn]);
setappdata(handles.figure1,'SDPosFile',[pn filesep fn]);
setappdata(handles.figure1,'SDPosition',pos);
setsdpos(handles,pos);

function figure1_WindowButtonDownFcn(hObject, eventdata, handles)  %#ok
% Renderer --> Open GL ...
%  Alpha --> OK
%  To write correctry : initial renderer is Doublbuffer..
r=get(handles.figure1, 'Renderer');
if ~strcmpi(r,'OpenGL'),
  refresh(handles.figure1);
  set(handles.figure1, 'Renderer','OpenGL');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = etgpos_sd2ch_OutputFcn(hObject, eventdata, handles) %#ok
varargout{1} = handles.output;
if ishandle(handles.figure1),
  delete(handles.figure1);
end

function psb_ok_Callback(hObject, eventdata, handles)  %#ok
handles.output   = getappdata(handles.figure1,'Position');
try
  if OSP_DATA('GET','ETGPOS_FWRITE')==true
    [f, p] = uiputfile('*.pos', 'Save (CHANNEL-Result) as POS-File');
    pf=getappdata(handles.figure1,'SDPosFile');
    etg_pos_fwrite([p filesep f],handles.output,pf);
  end
catch
  errordlg('Write Error');
end

guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
  uiresume(handles.figure1);
else
  delete(handles.figure1); 
end

function psb_cancel_Callback(hObject, eventdata, handles)  %#ok
% Close
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
  uiresume(handles.figure1);
else
  delete(handles.figure1); 
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)  %#ok
% Resume..
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
  uiresume(handles.figure1);
else
  delete(handles.figure1); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  GUI Axes Object Control Function!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Convert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_conv_Callback(hObject, eventdata, handles)  %#ok
% Convert Button ::
setsdpos(handles);

function setsdpos(handles,sdpos)
% --> Position Reset <--
if nargin<2,sdpos = getappdata(handles.figure1,'SDPosition');end
if isempty(sdpos),error('No Data to Convert'); end


% Initiarized Pos
pos.ver              = 2;
pos.Group.ChData     = {};
pos.Group.OriginalCh = {};
pos.Group.mode       = sdpos.Group.mode;
pos.D3.P             = [];
pos.D3.Base          = sdpos.D3.Base;

% === Plot Cube ===
set(0,'CurrentFigure',handles.figure1);
set(handles.figure1,'CurrentAxes',handles.axes1);
cla;axis image;hold on
try
  set(handles.figure1,'CurrentAxes',handles.axes1);
  ah.Base =fill3( ...
    [pos.D3.Base.Nasion(1); ...
    pos.D3.Base.LeftEar(1); ...
    pos.D3.Base.RightEar(1)], ...
    [pos.D3.Base.Nasion(2); ...
    pos.D3.Base.LeftEar(2); ...
    pos.D3.Base.RightEar(2)], ...
    [pos.D3.Base.Nasion(3); ...
    pos.D3.Base.LeftEar(3); ...
    pos.D3.Base.RightEar(3)],[.8 .8 .8]);
  set(ah.Base,'LineStyle','none', ...
    'Marker','o', ...
    'MarkerEdgeColor','white', ...
    'MarkerFaceColor',[.8,.8,.8], ...
    'Tag','Base');
  alpha(ah.Base,0.5);
catch
  disp('Draw Current-Axes Base Error');
end

str=cell(1,length(sdpos.Group.ChData));
chid=1;
% Probe Loop
for pid=1:length(sdpos.Group.ChData)
  str{pid}=['Probe' num2str(pid)];
  mode=sdpos.Group.mode(pid);
  x  = sdpos.D3.P(sdpos.Group.ChData{pid},1);
  y  = sdpos.D3.P(sdpos.Group.ChData{pid},2);
  z  = sdpos.D3.P(sdpos.Group.ChData{pid},3);
  %---> Confine Prompt <--- (Meeting on 2008.08.04)
  switch mode,
    case {2,51}, % 4x4
      strmode='4x4';
    case {1}, % 3x3
      strmode='3x3';
    case {3,52}, % 3x5
      strmode='3x5';
    case {53}, % 5x3
      strmode='5x3';
    case {201}
      strmode='2x8';
    case {203}
      strmode='2x4';
    case {204}
      strmode='2x6';
    otherwise,
      strmode='';
  end % End Switch
  if ~isempty(strmode)
    n=questdlg(...
      sprintf(['This pos file can be identified as "%s" holder''s probe data. If it''s not ', ...
      'problem, just press ''Yes'' to proceed. Otherwise, if you need manual handling, ', ...
      'press ''No'' to enter the structural information of the holder.'],strmode),...
      sprintf('Confine Probe[%d] Mode',pid),...
      'Yes','No','Yes');
    if isequal(n,'No')
       sdpos.Group.mode(pid)=199; % Unknown-Mode
       mode = 199;
    end
  end
  %------------------------------------------------
  switch mode,
    case {2,51}, % 4x4
      pos.Group.ChData{pid}=chid:chid+23;
      pos.Group.OriginalCh{pid} = 1:24;
      [x, y, z]=local_reshape(x,y,z,4,4);
      p        = sd2p(x,y,z);
      pos.D3.P(chid:chid+23,:)  = p;
      chid = chid+24;
    case {1}, % 3x3
      pos.Group.ChData{pid}=chid:chid+11;
      %if sdpos.Group.OriginalCh{pid}(1)==1,
      if 1
        pos.Group.OriginalCh{pid} = 1:12;
      else
        pos.Group.OriginalCh{pid} = 13:24;
      end
      [x, y, z]=local_reshape(x,y,z,3,3);
      p        = sd2p(x,y,z);
      pos.D3.P(chid:chid+11,:)  = p;
      chid = chid+12;

    case {3,52}, % 3x5
      pos.Group.ChData{pid}=chid:chid+21;
      pos.Group.OriginalCh{pid} = 1:22;
      %-------->
      % Bugfix : 2007.11.21
      % Check Vector
      ip = my_InnerProduct(x,y,z,3,4);
      if ip>0
        [x, y, z]=local_reshape(x,y,z,5,3);
      else
        [x, y, z]=local_reshape(x,y,z,3,5);
      end
      %<---------
      p        = sd2p(x,y,z);
      pos.D3.P(chid:chid+21,:)  = p;
      chid = chid+22;
    case {53}, % 5x3
      pos.Group.ChData{pid}=chid:chid+21;
      pos.Group.OriginalCh{pid} = 1:22;
      ip = my_InnerProduct(x,y,z,3,4);
      if ip>0
        [x, y, z]=local_reshape(x,y,z,5,3);
      else
        [x, y, z]=local_reshape(x,y,z,3,5);
      end
      p        = sd2p(x,y,z);
      pos.D3.P(chid:chid+21,:)  = p;
      chid = chid+22;
    case {201,203,204}
      pos.Group.ChData{pid}=chid:chid+21;
      pos.Group.OriginalCh{pid} = 1:22;
      ip = my_InnerProduct(x,y,z,2,3);
      if ip>0
        [x, y, z]=local_reshape(x,y,z,8,2);
      else
        [x, y, z]=local_reshape(x,y,z,2,8);
      end
      p        = sd2p(x,y,z);
      hipotxch = [8 1 16 9 2 17 10 3 18 11 4 19 12 5 20 13 6 21 14 7 22 15];
      idx = p(:,1); idy = p(:,2); idz = p(:,3);
      p = [idx(hipotxch) idy(hipotxch) idz(hipotxch)];
      pos.D3.P(chid:chid+21,:)  = p;
      chid = chid+22;
    otherwise,
      %========================
      % Unknown Probe-Mode
      %========================
      %--------------------------------------
      % Input-Dialog to get Probe-Information
      %--------------------------------------
      prmpt={sprintf('Enter : Source Number of Raw (mode %d)',mode), ...
        sprintf('Enter : Source Number of Column (mode %d)',mode)};
      nn=length(sdpos.Group.ChData{pid});
      r={'1',num2str(nn)};
      tit=sprintf('Input Measure-Mode(%d) Information.',mode);
      while 1
        r=inputdlg(prmpt,tit,1,r);
        if isempty(r), % cancel
          error('Unknown Measure-Mode %d.',mode);
        end
        try
          n=str2num(r{1});n=round(n); %#ok
          if length(n)~=1
            error('N must be a integer');
          end
          m=str2num(r{2});m=round(m); %#ok
          if length(m)~=1
            error('M must be a integer');
          end
          if (n*m)~=nn
            error('N*M must be a %d',nn);
          end
          break;
        catch
          waitfor(errordlg(lasterr));
        end
      end
      %--------------------------------------
      % Input-Dialog to get Probe-Information
      %--------------------------------------
      if n==1 || n==nn,
        ip=1;
      else
        ip = my_InnerProduct(x,y,z,n,n+1);
      end
      if ip>0
        [x, y, z]=local_reshape(x,y,z,m, n);
      else
        [x, y, z]=local_reshape(x,y,z,n, m);
      end
      p        = sd2p(x,y,z);
      psz      = size(p,1);
      pos.Group.ChData{pid}=chid:chid+psz-1;
      pos.Group.OriginalCh{pid} =1:psz;
      pos.D3.P(chid:chid+psz-1,:)  = p;
      chid = chid+psz;
      % error(sprintf('Unknown Measure-Mode %d.',mode));
  end % End Switch

  % Plot
  try
    set(0,'CurrentFigure',handles.figure1);
    set(handles.figure1,'CurrentAxes',handles.axes1);
    % S-D
    tg = ['SD' num2str(pid)];
    h=surf(x,y,z);
    ah.(tg)=h;
    set(h, ...
      'FaceColor','none', ...
      'LineStyle','-', ...
      'LineWidth', 1, ...
      'EdgeColor',[0, 0.8, 1], ...
      'MarkerFaceColor',[0, 0.502,1], ...
      'MarkerEdgeColor', [0, 0.502,1], ...
      'Marker','o', ...
      'MarkerSize',6, ...
      'Tag',tg);
    % Position
    tg = ['P' num2str(pid)];
    h=plot3(p(:,1), p(:,2),p(:,3));
    ah.(tg)=h;
    set(h,'LineStyle','none', ...
      'Marker','o', ...
      'MarkerSize',10, ...
      'MarkerFaceColor',[1, 0.6, 0.2], ...
      'MarkerEdgeColor',[1, 0.6, 0.2], ...
      'Tag', tg);
  catch
    disp('S-D Write Error');
  end
end
view(3);
axis image
if isempty(str),
  set(handles.pop_probe,'String',{'No Probe'});
  return;
end
setappdata(handles.figure1,'Position',pos);
set(handles.pop_probe,'String',str,'Value',1);
pop_probe_Callback(handles.pop_probe,[],handles);
return;

%============================================
function [x, y, z]=local_reshape(x,y,z,n,m)
%    rehshape x,y,z to [n,m];
%     x, y , z is vector of S-D position.
%     n, m is S-D Probe shape.
%
%    when length of x is not n*m,
%     warning and ..
%============================================
sz=n*m;
% Data Check
if size(x,1) > sz,
  x=x(1:sz);y=y(1:sz);z=(1:sz);
  warning('Too many Souce-Detector Position Data.');
elseif size(x,1) < sz,
  warning('Too few Souce-Detector Position Data.');
  x(end+1:sz)=0;y(end+1:sz)=0;z(end+1:sz)=0;
end
% is as  same as
x=reshape(x,n,m);y=reshape(y,n,m);z=reshape(z,n,m);
x=x';y=y';z=z';

%============================================
function p = sd2p(x,y,z)
% p=sd2p(x,y,z)
%     Change S-D map to position vecotr.
%     X, Y, Z is matrix that discribe [n,m].
%     P is matrix of 3-D Position.
%============================================
x=x/2;y=y/2;z=z/2;
x1=conv2(x,[1 1],'valid'); x2=conv2(x,[1 1]','valid');
y1=conv2(y,[1 1],'valid'); y2=conv2(y,[1 1]','valid');
z1=conv2(z,[1 1],'valid'); z2=conv2(z,[1 1]','valid');
s1 = size(x1,2)+size(x2,2);
s2 = size(x2,1);
p  = zeros(s2 * s1 + size(x1,2),3);
idx0 = 1;
for idx=1:s2,
  p(idx0:idx0+s1-1,:) = ...
    [[x1(idx,:)'; x2(idx,:)'],  ...
    [y1(idx,:)'; y2(idx,:)'], ...
    [z1(idx,:)'; z2(idx,:)']];
  idx0 = idx0+s1;
end
p(idx0:end,:) = [x1(end,:)', y1(end,:)', z1(end,:)'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Convert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_probe_Callback(hObject, eventdata, handles) %#ok
% When Probe ID Change!
%  --> Refresh Listbox
pid   = get(hObject,'Value');
pos   = getappdata(handles.figure1,'Position');
sdpos = getappdata(handles.figure1,'SDPosition');
if length(pos.Group.ChData)<pid || ...
    length(sdpos.Group.ChData)<pid,
  error('Too long Probe ID');
end

%------------
% SD Data!
%------------
sdp = sdpos.D3.P(sdpos.Group.ChData{pid},:);
try
  h=findobj(handles.axes1,'Tag',['SD' num2str(pid)]);
  if length(h)~=1,
    warning(['Multi definition for SD Tag..' num2str(pid)]);
    h=h(1); % confine
  end
  x = get(h,'XData');
  if size(sdp,1)~=numel(x),
    x=x';x=x(:);
    y=get(h,'YData');y=y';y=y(:);
    z=get(h,'YData');z=z';z=z(:);
    sdp=[x,y,z];
  end
catch
  disp('SD-Data Draw refresh');
end
s =cell(1,size(sdp,1));
for cid=1:size(sdp,1),
  s{cid}=sprintf('ID%3d. [%8.2f,%8.2f,%8.2f]',...
    cid, sdp(cid,1),sdp(cid,2),sdp(cid,3));
end
if isempty(s), s={'No Data'}; end
set(handles.lbx_sdpos,'String',s,'Value',1);
lbx_sdpos_Callback(handles.lbx_sdpos, [], handles);
%------------
% Probe Data!
%------------
p   = pos.D3.P(pos.Group.ChData{pid},:);
s =cell(1,size(p,1));
for cid=1:size(p,1),
  s{cid}=sprintf('Ch%3d. [%8.2f,%8.2f,%8.2f]',...
    cid, p(cid,1),p(cid,2),p(cid,3));
end
if isempty(s), s={'No Data'}; end
set(handles.lbx_pos,'String',s,'Value',1);
lbx_pos_Callback(handles.lbx_pos, [], handles);

%-----------------------------
function lbx_sdpos_Callback(hObject, eventdata, handles) %#ok
%-----------------------------
pid   = get(handles.pop_probe,'Value'); % Probe ID
cid   = get(handles.lbx_sdpos,'Value'); % Channel ID(sd)
sdpos = getappdata(handles.figure1,'SDPosition');

% Error Check..
if length(sdpos.Group.ChData)<pid,
  error('Probe ID Error!');
end
if length(sdpos.Group.ChData{pid})<cid,
  error('Channel ID Error!');
end
id=sdpos.Group.ChData{pid}(cid);
p=sdpos.D3.P(id,:); p=round(p*100)/100;
s  =sprintf('[%.2f, %.2f, %.2f]',p(1),p(2),p(3));
set(handles.edit_sdpos,...
  'ForegroundColor',[0 0 0], ...
  'String',s, ...
  'UserData',p);

%-----------------------------
function lbx_pos_Callback(hObject, eventdata, handles) %#ok
%-----------------------------
pid   = get(handles.pop_probe,'Value'); % Probe ID
cid   = get(handles.lbx_pos,'Value'); % Channel ID
pos   = getappdata(handles.figure1,'Position');

% Error Check..
if length(pos.Group.ChData)<pid,
  error('Probe ID Error!');
end
if length(pos.Group.ChData{pid})<cid,
  error('Channel ID Error!');
end
id=pos.Group.ChData{pid}(cid);
p =pos.D3.P(id,:); p =round(p*100)/100;
s  =sprintf('[%.2f, %.2f, %.2f]',p(1),p(2),p(3));
set(handles.edit_pos, ...
  'ForegroundColor',[0 0 0], ...
  'String',s, ...
  'UserData',p);

%--> Channel Text
set(handles.tgl_chtxt,'Value',0);
tgl_chtxt_Callback(handles.tgl_chtxt,[],handles);

%-----------------------------
function edit_sdpos_Callback(hObject, ev, handles) %#ok
%-----------------------------
p=ck_editpos(hObject); if isempty(p), return; end

pid   = get(handles.pop_probe,'Value'); % Probe ID
cid   = get(handles.lbx_sdpos,'Value'); % Channel ID(sd)
sdpos = getappdata(handles.figure1,'SDPosition');

% Error Check..
if length(sdpos.Group.ChData)<pid,
  error('Probe ID Error!');
end
if length(sdpos.Group.ChData{pid})<cid,
  error('Channel ID Error!');
end
id=sdpos.Group.ChData{pid}(cid);
sdpos.D3.P(id,:)=p;
setappdata(handles.figure1,'SDPosition',sdpos);
str = get(handles.lbx_sdpos,'String'); % Channel ID(sd)
str{cid}=sprintf('ID%4d. [%8.2f,%8.2f,%8.2f]',cid, p(1),p(2),p(3));
set(handles.lbx_sdpos,'String',str); % Channel ID(sd)

% Axes Data Change
try
  tg=['SD' num2str(pid)];
  h=findobj(handles.axes1,'Tag',tg);
  if numel(h)==1,
    x = get(h,'XData');
    sz=size(x);sz=sz([2,1]);
    x=x';x=x(:);x(cid)=p(1);
    x=reshape(x,sz);set(h,'XData',x');
    y = get(h,'YData');y=y';y=y(:);y(cid)=p(2);
    y=reshape(y,sz);set(h,'YData',y');
    z = get(h,'ZData');z=z';z=z(:);z(cid)=p(3);
    z=reshape(z,sz);set(h,'ZData',z');
  end
catch
  disp('Axes-Data Refresh Error');
end

%-----------------------------
function edit_pos_Callback(hObject, ev, handles) %#ok
%-----------------------------
p=ck_editpos(hObject); if isempty(p), return; end

pid   = get(handles.pop_probe,'Value'); % Probe ID
cid   = get(handles.lbx_pos,'Value'); % Channel ID
pos   = getappdata(handles.figure1,'Position');

% Error Check..
if length(pos.Group.ChData)<pid,
  error('Probe ID Error!');
end
if length(pos.Group.ChData{pid})<cid,
  error('Channel ID Error!');
end
id=pos.Group.ChData{pid}(cid);
pos.D3.P(id,:)=p;
setappdata(handles.figure1,'Position',pos);
str = get(handles.lbx_pos,'String'); % Channel ID
str{cid}=sprintf('Ch%4d. [%8.2f,%8.2f,%8.2f]',cid, p(1),p(2),p(3));
set(handles.lbx_pos,'String',str); % Channel ID

% Axes Data Change
try
  tg=['P' num2str(pid)];
  h=findobj(handles.axes1,'Tag',tg);
  if numel(h)==1,
    x = get(h,'XData');x(cid)=p(1);set(h,'XData',x);
    y = get(h,'YData');y(cid)=p(2);set(h,'YData',y);
    z = get(h,'ZData');z(cid)=p(3);set(h,'ZData',z);
  end
catch
  disp('Axes-Data Refresh Error');
end
tgl_chtxt_Callback(handles.tgl_chtxt,[],handles);
%-----------------------------
function pos=ck_editpos(hObject)
% Check String of Position Edit-Text
%-----------------------------
str=get(hObject,'String');
set(hObject,'ForegroundColor',[0 0 0]);
try
  pos=eval(str);
  if ~isnumeric(pos) || numel(pos)~=3
    set(hObject,'ForegroundColor','red');
    pos = get(hObject,'UserData');
    set(hObject,'String', ...
      sprintf('[%.2f, %.2f, %.2f]',pos(1),pos(2),pos(3)));
    pos=[];
  else
    set(hObject,'UserData',pos);
  end
catch
  pos=[];
end

function tgl_chtxt_Callback(hObject, eventdata, handles) %#ok
pid   = get(handles.pop_probe,'Value'); % Probe ID
pos   = getappdata(handles.figure1,'Position');
% Error Check..
if length(pos.Group.ChData)<pid,
  error('Probe ID Error!');
end
p=pos.D3.P(pos.Group.ChData{pid},:);
h=get(hObject,'UserData');
if ~isempty(h),
  try
    %idx=find(ishandle(h));
    %delete(h(idx));
    delete(h(ishandle(h)));
  catch
  end
end
if ~get(hObject,'Value'), return; end
set(0,'CurrentFigure',handles.figure1);
set(handles.figure1,'CurrentAxes',handles.axes1);
h=size(p,1);
for idx=1:size(p,1)
  h(idx)=text(p(idx,1),p(idx,2),p(idx,3),sprintf('%d',idx));
  set(h(idx),'Tag',['Txt' num2str(idx)])
  %sprintf('Ch %d',idx));
end
%set(h,'Color',[.824 .392 .392]);
set(h,'Color',[.8 .95 .8],'FontWeight','bold');
set(hObject,'UserData',h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now not in use..
%  I want axes object editor..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popupmenu2_Callback(hObject, eventdata, handles) %#ok


function ip=my_InnerProduct(x,y,z,p1,p2)
% Inner Product of vec(->p1) . vec(->p2)
% To check return
ip = (x(p1-1)-x(p1))*(x(p2-1)-x(p2)) ...
  + (y(p1-1)-y(p1))*(y(p2-1)-y(p2)) ...
  + (z(p1-1)-z(p1))*(z(p2-1)-z(p2));
return
