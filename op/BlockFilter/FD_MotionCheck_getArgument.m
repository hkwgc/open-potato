function varargout = FD_MotionCheck_getArgument(varargin)
% FD_MOTIONCHECK_GETARGUMENT make Motion-Check Argument-Data.
%
%
% --- Function ----
% Syntax : 
%   argData = FD_MOTIONCHECK_GETARGUMENT('argData',argData,'Mflie',script);
%
% Input Value :
%    argData : Default Argument Data / or no..
%    script  : Test Plot Data for this GUI.
%
% Return Value : (argData)
%   --> if push-button OK :
%             argData of Filter-Data of Motion Check
%   --> if cancel or push-button Canncel or Delte by window(X):
%             empty.
%
% Using MAT-File :
%   LAYOUT_MotionCheck2.mat : Layout Data of Viewer II.
%
% See also: GUIDE, GUIDATA, GUIHANDLES,
%           UI_MOTIONCHECK, FILTERDEF_MOTIONCHECK,
%           OSP_LAYOUTVIEWER, OSP_VIEWAXESOBJ_L_MC.

% Last Modified by GUIDE v2.5 16-Jun-2006 19:50:07


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 2006.04.03
% $Id: FD_MotionCheck_getArgument.m 180 2011-05-19 09:34:28Z Katura $

% Revision 1.2
%   Change
% Revision 1.3
%   Bugfix : 
%     pointed out by T.K., Hitachi Advanced Research Laboratory,.
%   Modify : kind - Add, speed-up..
%
% Revition 1.4
%    Modify : Remove Channel Open GUI
%             To speed up.
%    Layout Data , LAYOUT_MotionCheck.mat to LAYOUT_MotionCheck2.mat

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FD_MotionCheck_getArgument_OpeningFcn, ...
                   'gui_OutputFcn',  @FD_MotionCheck_getArgument_OutputFcn, ...
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opening & Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FD_MotionCheck_getArgument_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
handles.output = [];
guidata(hObject, handles);

%==================
% Get Arguments
%==================
argData=[];mfile_pre='';
for idx=2:2:length(varargin),
  % Property Name ?
  if ~ischar(varargin{idx-1}),
    warning('Bad Property Name');
    continue;
  end
  switch(varargin{idx-1}),
   case {'argData'},
    argData=varargin{idx};
   case {'Mfile'},
    mfile_pre=varargin{idx};
   otherwise,
    warning(['No such a Property : ' varargin{idx}]);
    continue;
  end % Property Name Switch
end % Get Get Argument


%========================
%  Arg-Data Initiarized! 
%========================
%------------
% Filter Type
%------------
str= get(handles.pop_filtertype,'String');
if isempty(argData) || ~isfield(argData,'FilterType'),
  vl = get(handles.pop_filtertype,'Value');
  argData.FilterType=str{vl};
else,
  vl=find(strcmpi(str,argData.FilterType));
  if isempty(vl),
    warndlg('No Filter Type :: in your environment!');
    vl=1;
  end
  set(handles.pop_filtertype,'Value',vl(1));
end

%------------
% High- Pass 
%------------
hp=[];
% correct spell-miss....
if isfield(argData,'HighpathFilter'),
  argData.HighpassFilter = argData.HighpathFilter;
end
if isfield(argData,'HighpassFilter'),
  argData.HighpassFilter = argData.HighpassFilter;
end
if isfield(argData,'HighpassFilter') && ...
      ~isempty(argData.HighpassFilter),
  try,
    hp = num2str(argData.HighpassFilter(1));
  catch,
    warning(['Error : High Pass Filter Setting..' lasterr]);
  end
end
if isempty(hp),
  set(handles.edt_highpass,'String','0.02','UserData',0.02);
else,
  set(handles.edt_highpass,'String',hp, ...
		    'UserData',argData.HighpassFilter(1));
end

%------------
% low- Pass
%------------
lp=[]; 
% correct spell-miss....
if isfield(argData,'LowpassFilter'),
  argData.LowpassFilter = argData.LowpassFilter;
end
if isfield(argData,'LowpassFilter') && ...
      ~isempty(argData.LowpassFilter),
  try,
    lp = num2str(argData.LowpassFilter(1));
  catch,
    warning(['Error : Low Pass Filter Setting..' lasterr]);
  end
end
if isempty(lp),
  set(handles.edt_lowpass,'String','0.8','UserData',0.8);
else,
  set(handles.edt_lowpass,'String',lp, ...
		    'UserData',argData.LowpassFilter(1));
end

%------------
%  Creterion
%------------
cts=''; ud='';
if isfield(argData,'Criterion') && ...
      ~isempty(argData.Criterion),
  try,
    ud=argData.Criterion;
    if isnumeric(ud),
      cts=num2str(ud);
    else,
      sigma=0;
      cts=ud;
    end
  catch,
    warning(['Error in Creterion Setting..', lasterr]);
  end
end
if isempty(cts);
  set(handles.edt_criterion,'String','3*sigma', ...
		    'UserData', '3*sigma');
else,
  set(handles.edt_criterion,'String',cts, ...
		    'UserData', ud);
end

%-----------
% Data Kind 
%-----------
kind=[]; 
if isfield(argData,'DataKind') && ...
      ~isempty(argData.DataKind),
  try,
    k=argData.DataKind;
    if ~isnumeric(k), error('Bad-value : input DataKind');end
    k(find(k<=0))=[];
    argData.DataKind=k;
    kind = num2str(k);
  catch,
    warning(['Error : Data Kind : ' lasterr]);
  end
end
if isempty(kind),
  set(handles.edt_Kind,'String','3','UserData',3);
else,
  set(handles.edt_Kind,'String',kind,...
		    'UserData',argData.DataKind);
end
%-----------
% Data-Check Interval
%-----------
dcinterval=''; 
if isfield(argData,'DCInterval') && ...
        ~isempty(argData.DCInterval)
    try,
        c=argData.DCInterval;
        if ~isnumeric(c), error('Bad-value : input DataCheck Interaval');end
        k(find(c<=0))=[];
        argData.DCInterval=c;
        dcinterval = num2str(c);
    catch,
        warning(['Error : Data Kind : ' lasterr]);
    end
end
if isempty(dcinterval),
    set(handles.edt_dcinterval,'String','2','UserData',2);
else,
    set(handles.edt_dcinterval,'String',dcinterval,...
        'UserData',argData.DCInterval);
end

%=====================
% View!
%=====================
try,
  if ~isempty(mfile_pre),
    draw_init(handles,mfile_pre);
  else,
    error('No Previous Data Exist to print');
  end
catch,
  warning(lasterr);
end

%===========================
% Wait for user response 
% (if OK)
%===========================
if 1,
  set(handles.figure1,'WindowStyle','modal')
  uiwait(handles.figure1);
else
  % Debug Mode ..
  handles.output = 'debug';
  guidata(hObject, handles);
end

%------------------------------------
function pop_filtertype_CreateFcn(hObject, eventdata, handles)
% Get Available Filter Type and initiarize.
% If you want to add more Filter Type,
% Change also ui_motioncheck!
%------------------------------------
str={'none','bandpass2'};
if exist('butter','file'),
  str{end+1}='butter';
end
set(hObject,'String',str,'Value',length(str));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Output Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function varargout = FD_MotionCheck_getArgument_OutputFcn(hObject, eventdata, handles)
% Output Function :
% Get default command line output from handles structure
%   --> if push-button OK :
%             argData of Filter-Data of Motion Check
%   --> if cancel or push-button Canncel or Delte by window(X):
%             empty.
%------------------------------------
varargout{1} = handles.output;

% For Debug --> See Also Opting Function
if ischar(varargout{1}) && strcmp(varargout{1},'debug'),
  % This code run only if Debug Mode!
  warning(['FD_MotionCheck_getArgument: ' ...
	   'Runing in Debug Mode!']);
  varargout{1}=[];
  return;
end

% Delete Figure : When output
delete(handles.figure1);

%------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Close function with uiresume
%   Not Dete here
%------------------------------------
try,
  if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % --> back to Opening funcition : at uiwait
    %     --> Outup Function : Delete
    uiresume(handles.figure1);
  else,
    delete(hObject);
  end
end


%------------------------------------
function psb_OK_Callback(hObject, eventdata, handles)
% Set output Variables, and close.
% --> Output Data is argData of Filter-Data
%     Definition of argData is written in
%     FilterDef_MotionCheck!
%------------------------------------
fhs=handles;
% High-Path
d.HighpassFilter=get(fhs.edt_highpass,'UserData');
% Low-Path
d.LowpassFilter=get(fhs.edt_lowpass,'UserData');
% Criterion
d.Criterion=get(fhs.edt_criterion,'UserData');
% Filter-Type
ft=get(fhs.pop_filtertype,'String');
d.FilterType=ft{get(fhs.pop_filtertype,'Value')};
% Data-Kind of 
d.DataKind  =get(fhs.edt_Kind,'UserData');
d.DCInterval=get(fhs.edt_dcinterval,'UserData');
% --- Update GUI-Data ---
handles.output   = d;
guidata(hObject, handles);
% (not debug mode..)
% --> return to Opening-function at uiwait.
%      --> Output function.
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
else, delete(handles.figure1); end

%------------------------------------
function psb_cancel_Callback(hObject, eventdata, handles)
% Set output to Empty, and close.
%------------------------------------
handles.output   = []; guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'),
    uiresume(handles.figure1);
else, delete(handles.figure1); end

%------------------------------------
function psb_Help_Callback(hObject, eventdata, handles)
% Help of This Funciton
%------------------------------------
OspHelp('FD_MotionCheck_getArgument');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting Variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function pop_filtertype_Callback(hObject, eventdata, handles)
% Do notion in particular in this version.
% If you want to Add new Filter-Type for Motion Check
%   1. Chnage Create-Function of this popup-menu.
%   2. Change ui_motioncheck.
%------------------------------------

%------------------------------------
function edt_highpass_Callback(hObject, eventdata, handles)
%------------------------------------
%==> High- Pass %.. spell-miss..
%.. correct spell-miss..
str=get(hObject,'String');
try,
  num=str2num(str);
  if num<0,error('Highpass must be positive'); end
  if length(num)>1, error('Too many input data');end
  set(hObject,'ForegroundColor','black', ...
	      'UserData',num);
catch,
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',num2str(ud));
end
    
%------------------------------------
function edt_lowpass_Callback(hObject, eventdata, handles)
%------------------------------------
str=get(hObject,'String');
try,
  num=str2num(str);
  if num<0,error('Lowpass must be positive'); end
  if length(num)>1, error('Too many input data');end
  set(hObject,'ForegroundColor','black', ...
	      'UserData',num);
catch,
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',num2str(ud));
end


%------------------------------------
function edt_criterion_Callback(hObject, eventdata, handles)
%------------------------------------
try,
  str=get(hObject,'String');
  sigma=0;
  ct=eval(str);

  set(hObject,'ForegroundColor','black', ...
	      'UserData',str);
catch,
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',ud);
end

%------------------------------------
function edt_Kind_Callback(hObject, eventdata, handles)
%------------------------------------
str=get(hObject,'String');
try,
  % Kind Get (or not numerical check) 
  num=str2num(str);
  num=round(num);
  num(num<=0)=[];
  if isempty(num),error('Input effective Kind : positive'); end
  % Max Check
  kmn=getappdata(handles.figure1,'KindMaxNum');
  if isempty(find(num<=kmn)),
    error('Kind is too large');
  end
  if (max(num(:))>kmn), 
    warndlg('Kind mignt be too large');
  end
  set(hObject,'ForegroundColor','black', ...
	      'UserData',num, ...
	      'TooltipString', 'Good Kind');
catch,
  ud = get(hObject,'UserData');
  set(hObject,'ForegroundColor','red', ...
	      'String',num2str(ud), ...
	      'TooltipString', lasterr);
end

%------------------------------------
function edt_dcinterval_Callback(hObject, eventdata, handles)
%------------------------------------
str=get(hObject,'String');
try,
  % Kind Get (or not numerical check) 
  num=str2num(str);
  num=round(num);
  num(num<=0)=[];
  if isempty(num),error('Input effective Kind : positive'); end
  % Max Check
  set(hObject,'ForegroundColor','black', ...
      'UserData',num(1), ...
      'TooltipString', 'Good Data');
catch,
    ud = get(hObject,'UserData');
    set(hObject,'ForegroundColor','red', ...
        'String',num2str(ud), ...
        'TooltipString', lasterr);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Motion - Check!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function [hdata, data]=getCurentData(fh,ed,hs),
% Get Current Data
% Input ; is as same as other Callbacks.
% bug fh is handle of figure.
%
% Known Upper : 
%    osp_VieweAxesObje_L_mc(getCurentData)
%    exe_MotionCheck
%------------------------------------
hdata=getappdata(fh,'CHDATA');
data =getappdata(fh,'CDATA');
did  = 1; % TODO : Select Data
if iscell(data),  data=data{did}; end
if iscell(hdata), hdata=hdata{did}; end

%------------------------------------
function exe_MotionCheck(handles)
% Execute Motion Check, and Set Result to Application Data.
%   The Application-Data will be used in Ploting 
%   via "osp_ViewAxesObj_L_mc".
%
%   !! -- Warning -- !!
%     Execute This Object,
%     Before osp_ViewAxesObj_L_mc.
% 
% == List of APPLICATION DATA for OSP_VIEWAXESOJB_L_MC ==
%  I/O : NAME       : Info
%   I  : CHDATA     : Continuous Header Data
%   I  : CHDATA     : Continuous Data
%   O  : CheckData  : Check-Data in MotionCheck
%                     CheckData{kind}(time, channel)
%   O  : FlagData   : Motion-Flag Data by kind.
%                      FlagData{kind}(time, channel)
%   0  : MCResut    : Result(Flag) of MotionCheck
%------------------------------------
fhs=handles; 
hp=get(fhs.edt_highpass,'UserData');
lp=get(fhs.edt_lowpass,'UserData');
ct=get(fhs.edt_criterion,'UserData');
ft=get(fhs.pop_filtertype,'String');
ft=ft{get(fhs.pop_filtertype,'Value')};
kind=get(fhs.edt_Kind,'UserData');
[hdata, data]=getCurentData(fhs.figure1,[],handles);
[hdata, hs, chkdata, f0] = ...
    uc_motioncheck(data,kind,hdata, ...
		   hp,lp,ct,[],...
		   'FiltType', ft, ...
           'DCInterval', get(fhs.edt_dcinterval,'UserData'));

setappdata(handles.figure1,'CheckData',chkdata);
setappdata(handles.figure1,'FlagData',f0);
setappdata(handles.figure1,'MCResult',hdata.flag);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------
function draw_init(handles,mfile_pre)
% Motion Check Resutl-View Initialization.
% Make Continuous-Data
%------------------------------------
[cdata, chdata]=scriptMeval(mfile_pre,'cdata','chdata');
% Default Motion-Check Axes Object
%aobj_MotionCheck=osp_ViewAxesObj_L_mc('getArgument');
% Modify Axes-Object

% Load Layout-Data
p=fileparts(which(mfilename));
load([p filesep 'LAYOUT_MotionCheck2.mat'],'LAYOUT');
% Modify Layout Data
% --> If you want fix Clor --> Set Here!
if 0,
  % -- lkie.
  LAYOUT.FilugrProperty.Name=get(handles.figure1,'Name');
  LAYOUT.vgdata{1}.Object{1}.Object{1} = ...
      aobj_MotionCheck;
end
mx=-1;
for idx=1:length(cdata),
    tmp=size(cdata{idx},3);
    mx =max(mx,tmp);
end
setappdata(handles.figure1,'KindMaxNum',mx);
setappdata(handles.figure1,'CHDATA',chdata);
setappdata(handles.figure1,'CDATA',cdata);
exe_MotionCheck(handles);

% Launch View --> with Option
h=osp_LayoutViewer(LAYOUT, chdata,cdata,...
		   'figureh',handles.figure1, ...
		   'kind', 1, ...
		   'psb_mc_view',handles.psb_mc_view);


%----------------------
% --> Set Data for 
%     Axes Distribution
%  (Default Axes Position)
%----------------------
% Get Axes in 1_1_1.
% See also ViewGroupAxes
%  and LayoutData
% !Commnet Out :: since rivistion 1.4
if 0,
a=findobj(handles.figure1,'Type','axes');
idx=strmatch('P1_1_1',get(a,'TAG'));
a=a(idx); 
pa.handle=a(end:-1:1);
set(a,'Units','Normalized');
p=get(pa.handle,'Position');
pa.original=p;
p=cell2mat(p);
pa.lb=[min(p(:,1)),min(p(:,2))];
pa.rt=[max(p(:,1)),max(p(:,2))] + p(1,3:4);
pa.ln=size(p,1);

set(handles.pop_axes_dist,'UserDat',pa);
end

%------------------------------------
function psb_plotall_Callback(hObject, eventdata, handles)
% Plot Review..
%     Plot by 'Plot All' Push-Button
%------------------------------------
p=fileparts(which(mfilename));
load([p filesep 'LAYOUT_MotionCheck3.mat'],'LAYOUT');
% Modify Layout Data
% --> If you want fix Clor --> Set Here!
v=get(handles.pop_axes_dist,'Value');
switch v,
 case 1,
  nm='Normal0';
 case 2,
  nm='Square';
 case 3,
  nm='2Columns';
 otherwise,
  nm='Normal'
end
LAYOUT.vgdata{1}.DistributionMode=nm;

mx=getappdata(handles.figure1,'KindMaxNum');
chkdata=getappdata(handles.figure1,'CheckData');
f0=getappdata(handles.figure1,'FlagData');
flag=getappdata(handles.figure1,'MCResult');

chdata=getappdata(handles.figure1,'CHDATA');
cdata=getappdata(handles.figure1,'CDATA');
fh=figure;
setappdata(fh,'KindMaxNum',mx);
setappdata(fh,'CheckData',chkdata);
setappdata(fh,'FlagData',f0);
setappdata(fh,'MCResult',flag);

kind=get(handles.edt_Kind,'UserData');
% Launch View --> with Option
osp_LayoutViewer(LAYOUT, chdata,cdata,...
		 'figureh',fh, ...
		 'kind', kind);
return;



%------------------------------------
function psb_mc_view_Callback(hObject, eventdata, handles)
% Callback of Push button Apply!
% Do Motion-Check and set Result to Appdata.
% and Re-View Result.
%------------------------------------
exe_MotionCheck(handles);

ud=get(hObject,'UserData');
for idx=1:length(ud),
    try
        eval(ud{idx}.str);
    catch
        warning(lasterr);
    end
end
set(hObject,'UserData',ud);

%------------------------------------
function pop_axes_dist_Callback(hObject, eventdata, handles)
% Axes Distribution Change Popup-Menu
% This function change Axes Distribution 
% in Channgel Group-Axes
%------------------------------------
% Commnet Out :: since rivistion 1.4
if 0, % Comment out!
pa=get(hObject,'UserData');
vl=get(hObject,'Value');
posa=cell2mat(pa.original);
switch vl,
 case 1,
 case {2,3},
  if vl==2,
    cnum=ceil(sqrt(pa.ln));
  else,
    cnum=2;
  end
  % width
  pa_sz=pa.rt-pa.lb;
  c_sz   = pa_sz(1)/cnum;
  c_sp   = c_sz * 0.2; % space of col : 20%
  c_spp2 = c_sp/2;
  
  pos = pa.lb;
  cpos = pos(1)+c_spp2;
  for cid=2:cnum;
    cpos(cid)=cpos(cid-1)+c_sz;
  end
  % height
  rnum   = ceil(pa.ln/cnum);
  r_sz   = pa_sz(2)/rnum;
  r_spp2 = r_sz * 0.1; % space of col : 20%

  rpos = pos(2)+pa_sz(2) -(r_sz-r_spp2);
  for rid=2:rnum;
    rpos(rid)=rpos(rid-1)-r_sz;
  end

  posa=zeros(pa.ln,4);
  rid=1;
  ax_sz = [c_sz, r_sz] * 0.8;
  chid=1;
  for rid = 1: rnum
    for cid=1:cnum,
      posa(chid,:)=[cpos(cid), rpos(rid), ax_sz];
      chid=chid+1;
      if (chid>pa.ln) break; end
    end
  end
end

for idx=1:pa.ln,
  set(pa.handle(idx),'Position',posa(idx,:));
end
% Comment out!
end



