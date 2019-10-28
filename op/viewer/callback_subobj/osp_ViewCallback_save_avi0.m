function varargout=osp_ViewCallback_save_avi0(fcn,varargin)
% Common-Callback-Object, Change TimeRange, in Signal-ViewerII.
%
% This function is Common-Callback-Object of OSP-Viewer II.
%


% == History ==
% $Id: osp_ViewCallback_save_avi0.m 180 2011-05-19 09:34:28Z Katura $
%
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 05-Jun-2006


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
  varargout{1} = createBasicInfo;
  return;
end

if nargout,
  [varargout{1:nargout}] = feval(fcn, varargin{:});
else
  feval(fcn, varargin{:});
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%       Display-Name of the Plagin-Function.
%         'Channel Popup'
%       Myfunction Name
%         'vcallback_ChannelPopup'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   ='Save Movie (test)';
basicInfo.fnc    ='osp_ViewCallback_save_avi0';
% File Information
basicInfo.rver   ='$Revision: 1.6 $';
basicInfo.rver([1,end])   =[];
basicInfo.date   ='$Date: 2008/04/25 01:59:44 $';
basicInfo.date([1,end])   =[];

% Current - Variable Field-Name-List
basicInfo.cvfname={'vc_Play0'};
basicInfo.uicontrol={'listbox','popupmenu',...
  'menu','edit'};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getArgument(varargin),
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @PlugInWrap_SelectBlockChannel.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.arg1_int  : test argument 1
%        argData.arg2_char : test argument 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=varargin{1};
data.name='Save Movie (test)';
data.fnc ='osp_ViewCallback_save_avi0';

data.SelectedUITYPE='menu';
%=======================
% Set up of Input Dialog
%=======================
prompt={}; def={};

% Position
if ~strcmpi(data.SelectedUITYPE,'menu'),
  prompt{end+1}='Relative Position : ';
  if isfield(data,'pos'),
    def{end+1} = num2str(data.pos);
  else
    def{end+1} ='[0,  0,  0.1,  0.1]';
  end
end


%=======================
% Input Dialog Loop
%=======================
if isempty(prompt), flag=false;
else, flag=true; end

while flag,
  %-------------------
  % Open Input Dialog
  %-------------------
  def = inputdlg(prompt, 'Setting : Data-Kind Callback', 1,def);
  if isempty(def), data=[]; return; end % Cancel

  %-------------------
  % Data Loading..
  %-------------------
  flag=false;
  for idx=1:length(prompt),
    switch prompt{idx},
      case 'Relative Position : ',
        % -- Position --
        try,
          pos0=str2num(def{idx});
          if ~isequal(size(pos0),[1,4]),
            flag=true; % == ;continue;
            wh=warndlg('Number of Input Data must be 4-numerical!');
            waitfor(wh)
          end
          if ~isempty(find(pos0>1)) && ~isempty(find(pos0<0))
            flag=true; % == continue;
            wh=warndlg('Input Position Value between 0.0 - 1.0.');
            waitfor(wh);
          end
          data.pos=pos0;
        catch
          flag=true; % == ;continue;
          h=errordlg({'Input Proper Number:',lasterr});
          waitfor(h);
        end
      otherwise,
        % --- Error : Undefined Prompt ---
        errordlg({'==================== OSP : Program Error ======================', ...
          [' in ' mfilename ], ...
          '      in getArgument :: Undefined :: Prompt of Inputdlg ' , ...
          ['      Named : ' prompt{idx} ], ...
          '================================================================'});
        data=[]; return;
    end % End Switch
  end % End Prompt Loop
end % Input Dialog Loop

% OK
% Normal End
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str=['curdata=osp_ViewCallback_save_avi0(''make'',handles, abspos,' ...
  'curdata, cbobj{idx});'];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function curdata=make(hs, apos, curdata,obj,newflag),
% Execute on ViewGroupCallback 'exe' Function
% <-- evaluate by string of drawstr -->
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%========================
% Load TimeRange
%========================
size=osp_LayoutViewerTool('getCurrentSize',curdata);

%=====================
% Waring : Overwrite
%=====================
if isfield(curdata,'CCallback_Play0'),
  warndlg({'========= OSP Warning =========', ...
    ' Common Time-Range Callback : Over-Write', ...
    '  Confine your Layout.', ...
    '==============================='});
end

%---------------------
% (Need Time Axes now)
%---------------------
flg_old_timeslider=false;
if isfield(curdata,'Callback_2DImageTime') && ...
    isfield(curdata.Callback_2DImageTime,'handles') && ...
    ishandle(curdata.Callback_2DImageTime.handles)
  flg_old_timeslider=true;
end
% current Time Slider
flg_timeslider=[];
if isfield(curdata,'CommonCallbackData')
  for id1=1:length(curdata.CommonCallbackData)
    CCD=curdata.CommonCallbackData{id1};
    if strcmpi(CCD.Name,'TimePoint')
      flg_timeslider(end+1)=id1;
    end
  end
end
if flg_old_timeslider==false && isempty(flg_timeslider)
  % No Time-Slider
  return;
end

%===================
% Make Control GUI
%===================
switch lower(obj.SelectedUITYPE),
  case 'menu',
    % === Menu ===
    if flg_old_timeslider
      ud.h=curdata.Callback_2DImageTime.handles;
      fns=fieldnames(curdata);
      s=regexp(fns,'^Callback_2DImage');
      if iscell(s),
        a=find(cellfun('isempty',s)==0);
        for aidx=a(:)',
          ud.h(end+1)= ...
            eval(['curdata.' fns{aidx} '.handles;']);
        end
      end
      curdata.CCallback_save_avi0.handles=...
        uimenu(curdata.menu_callback,'Label','&Save as AVI (0)', ...
        'TAG', 'CCallback_save_avi0', ...
        'UserData',ud, ...
        'Callback', ...
        ['osp_ViewCallback_save_avi0(''ExeCallback'','...
        'gcbo,[],guidata(gcbo))']);
    end
    
    ud.h=[];
    for idx=1:length(flg_timeslider)
      ud.h(end+1)=...
        curdata.CommonCallbackData{flg_timeslider(idx)}.handle;
    end
    if ~isempty(ud.h)
      curdata.CCallback_save_avi0.handles=...
        uimenu(curdata.menu_callback,'Label','&Save as AVI (1)', ...
        'TAG', 'CCallback_save_avi1', ...
        'UserData',ud.h, ...
        'Callback', ...
        'osp_ViewCallback_save_avi0(''ExeCallback1'',gcbo)');
    end
    
  otherwise,
    errordlg({'====== OSP Error ====', ...
      ['Undefined Mode :: ' obj.SelectedUITYPE], ...
      ['  in ' mfilename], ...
      '======================='});
end % End Make Control GUI

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExeCallback(hObject,eventdata,handles)
% ---------------------------------------
% Save Image as AVI
%  This is make Movie, in the process
%   view Moview.
% ---------------------------------------
image_h = gcbf;

% -- Default Setting ---
userdata=get(hObject,'UserData');
hs=userdata.h;
t=1;
tmax = get(hs(1),'Max');
tbak = get(hs(1),'Value');

tmp=get(hs,'SliderStep')*tmax;
tinterval=tmp(1);

%========================
% Open Movie-File
%========================
% get save file name
[f p]=osp_uiputfile('*.avi', ...
  'Save AVI-File', ...
  'Untitled.avi');
% cancel ?
if isequal(f,0) || isequal(p,0),return; end
set(hs,'Visible','off');
% Open Movie
movF=avifile([p filesep f]);     % prepare for AVI file

% ========== Size Change ===============
% Ajust Image (image_h) Size for Movie
%   image_h is Figure-Handle of Ajust Image
%=================================================
% === Temporary Data Save ===
unttmp = get(image_h,'Units'); % Original Units
postmp = get(image_h,'Position'); % Original Position
set(image_h,'Units','pixels');
im_pos = get(image_h,'Position');
if im_pos(3) > 640, im_pos(3)=640; end
if im_pos(4) > 480, imup=im_pos(4)-480;im_pos(4)=480; end
im_pos(2) = im_pos(2);
set(image_h,'Position',im_pos);

%=================
% Waitbar Setting
%=================
timeidx0 =t:tinterval:tmax;
now_time=0; add_time = 1/length(timeidx0);
w_h=waitbar(0,sprintf('Time : %10d',0),...
  'Name','Making Movie',...
  'Color',[.8 1 .8]);

im_pos = get(image_h,'Position');
set(w_h,'Units', get(image_h,'Units'));
wb_pos = get(w_h,'Position');
wb_pos(1) = im_pos(1);
wb_pos(2) = im_pos(2)-wb_pos(4)-20;
wb_pos(3) = wb_pos(3)*1.3;
set(w_h,'Position',wb_pos);
% in MATLAB version 7.0.0.19920 (R14)
% Above command not run, but run in debugger
% Pause time may depend on PC.
pause(0.5);
uh1=uicontrol(w_h, ...
  'units','normalized','position',[10.5/13 0.1 2/13 0.3], ...
  'Style', 'pushbutton', 'String', 'Stop', ...
  'Callback','delete(gcbo);', ...
  'BackgroundColor',[.3 .7 .7]);
uh2=uicontrol(w_h, ...
  'units','normalized','position',[10.5/13 0.6 2/13 0.3], ...
  'Style', 'pushbutton', 'String', 'Pause', ...
  'Callback','set(gcbo,''String'',''Restart'');', ...
  'BackgroundColor',[.3 .7 .7]);
try
  for idx=t:tinterval:tmax,
    % Waitbar conumication..
    if ~ishandle(uh1), break; end
    str=get(uh2,'String');
    if ~strcmp(str,'Pause'),
      set(uh2,'Callback','set(gcbo,''String'',''Pause'');');
      waitfor(uh2,'String','Pause');
    end
    now_time=now_time+add_time;
    waitbar(now_time,w_h, ...
      sprintf('Time : %10d',idx));

    set(0,'CurrentFigure',image_h);
    set(hs(1),'Value',idx);
    osp_ViewCallback_2DImageTime('sld_time_Callback',hs(1),[],handles);
    mov1=getframe(image_h);
    drawnow;
    movF=addframe(movF,mov1);
  end
catch
  errordlg({'OSP Viewer II Callback Object, Save AVI 0 Error', lasterr});
end

%========================
% Reset Data
%========================
% close
close(w_h);
movF=close(movF);   % close AVI file
disp(movF);

% === Temporary Data Save ===
set(image_h,'Units',unttmp);
set(image_h,'Position',postmp);


set(hs(1),'Value',tbak);
osp_ViewCallback_2DImageTime('sld_time_Callback',hs(1),[],handles);
set(hs,'Visible','on');


function ExeCallback1(h)
% ---------------------------------------
% Save Image as AVI
%  This is make Movie, in the process
%   view Moview.
% ---------------------------------------
image_h = gcbf;

% -- Default Setting ---
hs=get(h,'UserData');

% Time loop is according to first-CO
t=1;
tmax = get(hs(1),'Max');
tbak=ones(1,length(hs));
for idx=1:length(hs)
  tbak(idx) = get(hs(idx),'Value');
end

tmp=get(hs,'SliderStep')*tmax;
tinterval=tmp(1);

%========================
% Open Movie-File
%========================
% get save file name
[f p]=osp_uiputfile('*.avi', ...
  'Save AVI-File', ...
  'Untitled.avi');
% cancel ?
if isequal(f,0) || isequal(p,0),return; end
set(hs,'Visible','off');

% Open Movie
movF=avifile([p filesep f]);     % prepare for AVI file

% ========== Size Change ===============
% Ajust Image (image_h) Size for Movie
%   image_h is Figure-Handle of Ajust Image
%=================================================
% === Temporary Data Save ===
unttmp = get(image_h,'Units'); % Original Units
postmp = get(image_h,'Position'); % Original Position
set(image_h,'Units','pixels');
im_pos = get(image_h,'Position');
if im_pos(3) > 640, im_pos(3)=640; end
if im_pos(4) > 480, imup=im_pos(4)-480;im_pos(4)=480; end
im_pos(2) = im_pos(2);
set(image_h,'Position',im_pos);

%=================
% Waitbar Setting
%=================
timeidx0 =t:tinterval:tmax;
now_time=0; add_time = 1/length(timeidx0);
w_h=waitbar(0,sprintf('Time : %10d',0),...
  'Name','Making Movie',...
  'Color',[.8 1 .8]);

im_pos = get(image_h,'Position');
set(w_h,'Units', get(image_h,'Units'));
wb_pos = get(w_h,'Position');
wb_pos(1) = im_pos(1);
wb_pos(2) = im_pos(2)-wb_pos(4)-20;
wb_pos(3) = wb_pos(3)*1.3;
set(w_h,'Position',wb_pos);
% in MATLAB version 7.0.0.19920 (R14)
% Above command not run, but run in debugger
% Pause time may depend on PC.
pause(0.5);
uh1=uicontrol(w_h, ...
  'units','normalized','position',[10.5/13 0.1 2/13 0.3], ...
  'Style', 'pushbutton', 'String', 'Stop', ...
  'Callback','delete(gcbo);', ...
  'BackgroundColor',[.3 .7 .7]);
uh2=uicontrol(w_h, ...
  'units','normalized','position',[10.5/13 0.6 2/13 0.3], ...
  'Style', 'pushbutton', 'String', 'Pause', ...
  'Callback','set(gcbo,''String'',''Restart'');', ...
  'BackgroundColor',[.3 .7 .7]);
try
  for idx=t:tinterval:tmax,
    % Waitbar conumication..
    if ~ishandle(uh1), break; end
    str=get(uh2,'String');
    if ~strcmp(str,'Pause'),
      set(uh2,'Callback','set(gcbo,''String'',''Pause'');');
      waitfor(uh2,'String','Pause');
    end
    now_time=now_time+add_time;
    waitbar(now_time,w_h, ...
      sprintf('Time : %10d',idx));


    set(hs,'Value',idx);
    set(0,'CurrentFigure',image_h);
    for idx2=1:length(hs)
      LAYOUT_CCO_TimePiont('sld_time_Callback',hs(idx2));
    end
    mov1=getframe(image_h);
    drawnow;
    movF=addframe(movF,mov1);
  end
catch
  errordlg({'OSP Viewer II Callback Object, Save AVI 0 Error', lasterr});
end

%========================
% Reset Data
%========================
% close
close(w_h);
movF=close(movF);   % close AVI file
disp(movF);

% === Temporary Data Save ===
set(image_h,'Units',unttmp);
set(image_h,'Position',postmp);


for idx2=1:length(hs)
  set(hs(idx2),'Value',tbak(idx2));
  LAYOUT_CCO_TimePiont('sld_time_Callback',hs(idx2));
end
set(hs,'Visible','on');
