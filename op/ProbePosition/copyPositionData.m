function varargout = copyPositionData(varargin)
% COPYPOSITIONDATA M-file for copyPositionData.fig
%      COPYPOSITIONDATA, by itself, creates a new COPYPOSITIONDATA or raises the existing
%      singleton*.
%
%      error_code = COPYPOSITIONDATA returns the handle to a new COPYPOSITIONDATA or the handle to
%      the existing singleton*.
%      errorcode :
%            errorcode : Null      : Cancel
%                        0         : Normal End
%                        1         : I/O Error
%
%      COPYPOSITIONDATA('Property','Value',...) creates a new
%      COPYPOSITIONDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before copyPositionData_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to copyPositionData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% $Id: copyPositionData.m 180 2011-05-19 09:34:28Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% Last Modified by GUIDE v2.5 05-Sep-2007 19:16:51

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code
% Depend on GUIDE version
% ======== Change for Debugging ============
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @copyPositionData_OpeningFcn, ...
  'gui_OutputFcn',  @copyPositionData_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End initialization code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == -- GUI Fundamental Functions-- ==
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function copyPositionData_OpeningFcn(hObject, ev, handles, varargin)
% Executes just before copyPositionData is made visible.
% In Opting Function :
%    Check (Startup) Arguments and Store
if 0,disp(ev);end
sflag=true;

% Cancel or //
handles.output = [];
% Update handles structure
guidata(hObject, handles);

%========================
% Set Basic Data-Function
%========================
if OSP_DATA('GET','isPOTAToRunning'),
  ddf=@DataDef2_RawData;
else
  ddf=@DataDef_SignalPreprocessor;
end
setappdata(hObject, 'DataDefFunction', ddf);


%========================
% get Arguments
%========================
try
  for idx = 2:2:length(varargin),
    switch varargin{idx-1},
      case 'CopySource';
        setCopySource(handles,varargin{idx});
      otherwise,
        errrordlg({'Unknow Propertty : ', ...
          ['  ' varargin{idx-1}]}, ...
          'Copy Position Data : Opening Function');
    end
  end
catch
  % error : Could not open
  errordlg('Bad Arguments for Copy-Position Data');
  sflag=false;
end

% -- now we do not have operation --
set(handles.psb_copysource,'Visible','off');

%========================
% wait for user responce
%========================
if sflag
  set(handles.lsb_copyobject,'String','','Value',1,'UserData',{});
  set(handles.figure1,'WindowStyle','modal')
  uiwait(handles.figure1);
else
  if 0
    % Debug Mode : In Waiting State is too deficult to debug.
    %              so not waiting
    handles.output = 'debug';
    guidata(hObject, handles);
    warndlg('Debug Mode : Now not waiting for Debug');
  end
end

%========================
% Callback Function
%========================
if 0
  psb_copysource_Callback;
  lsb_copyobject_Callback;
  psb_copyobject_Callback;
  psb_rmcopyobject_Callback;
  psb_cannel_Callback;
  psb_copy_Callback;
  ckb_replace_Callback;
  ckb_autonaming_Callback
end

function varargout = copyPositionData_OutputFcn(hObject, ev, handles)
% Output Data :
%    Null      : cancel!   -> Default / Cancel Button
%    errorcode : 0 : Normal End
%                1 : I/O Error
if 0,disp(ev);end
% 2nd Output : Arugment
try
  if nargout==2,
    if isempty(handles.output)
      varargout{2}= 'Canceled!';
    end
    switch handles.output,
      case 0,
        varargout{2}= 'Success : Copy Position Data';
      otherwise,
        % Get Message
        msg=get(handles.figure1,'ERROR_MESSAGE');
        if isempty(msg),
          msg='I/O Error : Copy Position Data';
        end
        varargout{2}= msg;
    end % end Switch (message)
  end % if 2nd Arguments exist?
catch % try - catch
  varargout{2}='';
end % try - catch

try
  varargout{1} = handles.output;
  if ~strcmp(handles.output,'debug')
    delete(hObject);
  end
catch
  warning(lasterr);
  if ishandle(hObject)
    delete(hObject);
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy Sorce Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_copysource_Callback(h, e, handles)
% Executes on button press in psb_copysource.
%
% Set Copy Source
if 1
  errordlg('Now We Cannot Change Copy Source!');
else
  disp(h);disp(e);
  setCopySource(handles,SourceName);
end
return;


function setCopySource(handles,SourceName)
% Set Copy Source
key.filename=SourceName;
header=feval(getappdata(handles.figure1, 'DataDefFunction'),'load',key);

if ~isfield(header,'Pos'),
  errordlg('No Position-Data in Copy Source!');
  setappdata(handles.figure1,'Position',[]);
end
setappdata(handles.figure1,'Position',header.Pos);
set(handles.edt_copysource,'String',SourceName);
set(handles.edt_copysource,'UserData',key);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy Object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lsb_copyobject_Callback(h, e, hs)
% Do noting Now:
if 0,disp(h);disp(e);disp(hs);end
function psb_copyobject_Callback(h, e, handles)
% Add Copy Object
if 0,disp(h);disp(e);end

%===================
% Get Copy-Object
%===================
%  -- Lock --
set(handles.figure1, 'Visible', 'off');
try
  % Return Value is Cell-Data :
  actdata=uiFileSelectPP('MultiSelect',true);
catch
  set(handles.figure1,'Visible','on');
  rethrow(lasterror);
end
% -- Unlock --
set(handles.figure1,'Visible','on');
% Cancel
if isempty(actdata), return; end

%===================
% Set User-Data
%===================
ud=get(handles.lsb_copyobject,'UserData');
if isempty(ud),
  ud{1}=actdata(1);
else
  ud{end+1}=actdata(1);
end
for idx=2:length(actdata),
  ud{end+1}=actdata(idx);
end

%===================
% Change String
%===================
st={};
for idx=1:length(ud),
  try
    ac=ud{idx};
    ac=ac{1};
    st{idx}=ac(1).data.filename;
  catch
    st{idx}=['Name Error: ' lasterr];
  end
end

%===================
% Update
%===================
set(handles.lsb_copyobject,'String',st,'Value',idx,'UserData',ud);


function psb_rmcopyobject_Callback(h, e, handles)
% Remove Copy Object
if 0,disp(h);disp(e);end

%===================
% Load Data
%===================
ud=get(handles.lsb_copyobject,'UserData');
vl=get(handles.lsb_copyobject,'Value');
st=get(handles.lsb_copyobject,'String');
%===================
% Remove User-Data
%===================
if length(ud)<vl
  errordlg('Select Effective Copy Object!');
  return;
end
if vl==0
  return;
end
ud(vl)=[];

%===================
% Change String
%===================
st(vl)=[];
idx=length(ud);

%===================
% Update
%===================
set(handles.lsb_copyobject,'String',st,'Value',idx,'UserData',ud);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_cannel_Callback(hObject, e, handles)
% Canncel : Output Data == Empty!
if 0,disp(h);disp(e);end
handles.output=[];
guidata(hObject,handles);
if isequal(get(handles.figure1,'waitstatus'),'waiting'),
  uiresume(handles.figure1);
else
  % if no wait::
  delete(handles.figure1);
end
return;

%--------------------------------------------
function psb_copy_Callback(hObject, e, handles)
% Copy Execution
%--------------------------------------------
if 0,disp(e);end
%==================
% Set Variable
%==================
% errorcode : 0 : Normal End
%             1 : I/O Error
% Default Error Code : 0
ecode=0;
% for save
OSP_DATA('SET','ConfineDeleteDataRD',true);


% Get Copy Object
co=get(handles.lsb_copyobject,'UserData');
if length(co)<=0
  errordlg('No Copy Object Exist.');
  return;
end
% Get Copy-Souce Position
cspos = getappdata(handles.figure1, 'Position');
if isempty(cspos),
  % Set Output Message
  set(handles.figure1, ...
    'ERROR_MESSAGE', ...
    'No Copy Source Position');
  % Set Error Code==1
  ecode=1; co=[];
end

%=====================
% Copy-Loop :
%  = Copy Object Loop
%=====================
n=sprintf('\n');
st=get(handles.lsb_copyobject,'String');
for idx=1:length(co),
  % Change
  set(handles.lsb_copyobject,'Value',idx);
  try
    % Copy cspos to Copy Object
    [ecode0, msg] =copyOne(co{idx},cspos,handles);
    if ecode0>1,
      if ecode0>ecode, ecode=ecode0;end
      error(msg);
    end
  catch
    %=======
    % Error : Copy Object
    %=======
    % Ecode Update
    if ecode<1,
      ecode=2; %Program Error:
      msg0 = ['Program Error : ' st{idx} ':' lasterr];
    else
      msg0 = ['Error : ' st{idx} ':' lasterr];
    end
    errordlg(msg0);
    try
      msg=getappdata(handles.figure1, 'ERROR_MESSAGE');
      msg = [msg n msg0];
    catch
      msg = msg0;
    end
    setappdata(handles.figure1, 'ERROR_MESSAGE',msg);
  end
end

%==================
% Terminate
%==================
% Set Out-put Data
handles.output=ecode;
guidata(hObject, handles);
% Delete This Figure
if isequal(get(handles.figure1,'waitstatus'),'waiting'),
  uiresume(handles.figure1);
else
  % if no wait::
  delete(handles.figure1);
end
return;

function [ecode, msg] =copyOne(co,pos,handles)
% Copy One Data

ecode=0;msg='';
% Check Data Depned
if isempty(co),
  ecode=1;
  msg = 'Copy Source is empty.';
  return;
end
co=co{1};
[header,data]=feval(getappdata(handles.figure1, 'DataDefFunction'),'load',co(1));
% Read First Data
%=======================================
%==== Copy Source have Position Data ===
%=======================================
if header.measuremode==-1,
  try
    
    %<--> read some -1 file in the 1 file.
    if length(co)>1,
      % if bug of upFilegetPP ::
      if 0,
        error('Too many Copy Object!');
      else
        for idx=1:length(co),
          [ecode0, msg0] =copyOne(co{idx},pos);
          if ecode<ecode0,
            ecode=ecode0;
            msg=[msg ';' msg0];
          end
        end
      end
      return;
    end

    pos0=header.Pos;
    if ~isequal(pos.Group.mode,pos0.Group.mode),
      error('Position Mode : Not equal.');
    end

    new_info = header.TAGs;
    usech=[];
    for idx2 = 1: length(pos.Group.ChData)
      did  = pos0.Group.ChData{idx2};
      ch   = pos.Group.OriginalCh{idx2};
      ch0  = pos0.Group.OriginalCh{idx2};
      for idx3=1:length(ch),
        t=find(ch(idx3)==ch0);
        if isempty(t),
          error('Read File : Lack of Channel Data');
        end
        usech(end+1)=did(t(1));
      end
    end
    usech2=usech*2; usech2=[usech2 (usech2-1)];
    usech2=sort(usech2);
    % * Info Change..
    try
      new_info.plnum = ...
        length(pos.Group.ChData);
    end
    try
      new_info.adnummeasnum = ...
        new_info.adnummeasnum(1,usech2);
    end
    try
      new_info.wavelength = ...
        new_info.wavelength(1,usech2);
    end
    try
      new_info.adrange = ...
        new_info.adrange(1,usech2);
    end
    try
      new_info.ampgain = ...
        new_info.ampgain(1,usech2);
    end
    try
      new_info.d_gain = ...
        new_info.d_gain(1,usech2);
    end
    try
      new_info.data    = new_info.data(:, ...
        usech2);
    end
    header.flag=header.flag(:,:,usech);
    % stim, stimTC, StimMode, samplingperiod Must be Same!!;
    header.TAGs=new_info;
    header.Pos=pos;
    data = data(:,usech,:);
    feval(getappdata(handles.figure1, 'DataDefFunction'),'save_ow',header, ...
      data,2,co(1));
  catch
    ecode=2;
    msg=lasterr;
  end
  %==== End of Copy Source have Position Data ===
  return;
end


%==============================================
%==== Copy Source do not have Position Data ===
%=============================================
try
  % Read First Data
  % [header,data]=feval(getappdata(handles.figure1, 'DataDefFunction'),'load',co{1});
  % First Data Load
  if isfield(pos.Group,'MakeGroup') && pos.Group.MakeGroup
    [header,data]=make_newdata_Grp(handles,co,pos);
  else
    [header,data]=make_newdata_Nrm(handles,co,pos);
  end
  
  %========================================================================
  % === Data Save ===
  %========================================================================
  prompt ={'File Name :', 'ID : '};
  name0=co(1).data.filename;
  if length(co)>=1
    s=regexpi(name0,'Probe[0-9]');
    if ~isempty(s), name0=name0(1:s);end
  end
  
  def    ={name0,...
    ['POS' co(1).data.ID_number]};

  % Make New Active-Data
  msg =sprintf(['[ Platform ] Warning!!\n' ...
    '<< In Saving Signal-Data>>\n']);
  % auto name option
  san=get(handles.ckb_autonaming,'Value');
  while 1,
    if san~=1
      def = inputdlg(prompt, ...
        'Save as SignalData', ...
        1, def);
      % Cancel
      if isempty(def),
        ecode=1;
        msg='User Cancel';
        set(handles.figure1,'Visible','on'); return;
      end

      % File Check
      fname = feval(getappdata(handles.figure1, 'DataDefFunction'),'getFilename',def{1});
      if get(handles.ckb_replace,'Value')==0
        if exist(fname,'file'),
          warndlg([msg 'Same File Name exist']);
          san=-1; % rename..
          continue;
        end
      end
    end
    header.TAGs.filename  = def{1};
    header.TAGs.ID_number = def{2};

    OSP_DATA('SET','SP_Rename','-'); % Confine Rename Option!
    if san==1
      OSP_DATA('SET','SP_Rename','OriginalName'); % Confine Rename Option!
      fnc=getappdata(handles.figure1, 'DataDefFunction');
      if get(handles.ckb_replace,'Value')==1
        %OSP_DATA('SET','ConfineDeleteDataRD',true);
        for id0=1:length(co)
          try
            feval(fnc,'deleteGroup',co(id0).data.filename);
          catch
            disp(co(id0).data);
            warning('could not delete file');
          end
        end
      end
      if isequal(fnc,@DataDef2_RawData)
        feval(fnc,'save',header,data,3);
      else
        feval(fnc,'save',header,data,2);
      end
      OSP_DATA('SET','SP_Rename','-'); % Confine Rename Option!
    else
      fnc=getappdata(handles.figure1, 'DataDefFunction');
      feval(fnc,'save',header,data,3,co(1));
      feval(fnc,'save',header,data,3);
    end
    %     if ~exist(fname,'file'),
    %       % if not succes to save
    %       error([msg ...
    %         '[ Platform ]  Error : Could not make Signal Data']);
    %     end
    break; % Success
  end

 catch
  ecode=2;
  msg=lasterr;
end

%==========================================================================
function [hdata,data]=make_newdata_Grp(handles,co,pos)
% Make New Data From Grouped Data
%==========================================================================
if length(co)~=1
  error('Could not Copy Data');
end
fcn=getappdata(handles.figure1, 'DataDefFunction');
%key=get(handles.edt_copysource,'UserData');
%[header,data]=feval(fcn,'load',key);

for idx=1:length(pos.Group.ChData)
  [h,d]=feval(fcn,'load',co(1));
  if idx==1
    hdata=h;
    hdata.measuremode=-1;
    hdata.Pos=pos;
    hdata.TAGs.filename=h.TAGs.filename;
    data=d;
  end

  ch    = pos.Group.OriginalCh{idx};
  cidx2 = pos.Group.ChData{idx};
  % get Channel (for raw-Data);
  ch2=ch*2; ch2=[(ch2-1);ch2];
  ch2=ch2(:)';
  cidx22=cidx2*2;cidx22=[(cidx22-1);cidx22];
  cidx22=cidx22(:)';

  % Add new data
  data(:,cidx2,:) = d(:,ch,:);
  hdata.flag(:,:,cidx2)   = h.flag(:,:,ch);
  % stim, stimTC, StimMode, samplingperiod Must be Same!!;

  % * Info Change..
  try
    hdata.TAGs.adnummeasnum(1,cidx22) = h.TAGs.adnummeasnum(1,ch2);
  end
  try
    hdata.TAGs.wavelength(1,cidx22) = h.TAGs.wavelength(1,ch2);
  end
  try
    hdata.TAGs.adrange(1,cidx22) = h.TAGs.adrange(1,ch2);
  end
  try
    hdata.TAGs.ampgain(1,cidx22) = h.TAGs.ampgain(1,ch2);
  end
  try
    hdata.TAGs.d_gain(1,cidx22) = h.TAGs.d_gain(1,ch2);
  end
  try
    hdata.TAGs.data(1,cidx22) = h.TAGs.data(1,ch2);
  end
end

%==========================================================================
function [header,data]=make_newdata_Nrm(handles,co,pos)
% Make New Data From Normal Data
%==========================================================================
cidx2 =0;
idx2  =0;
for idx=1:length(co)
  idx2=idx2+1;
  % Load Data
  fcn=getappdata(handles.figure1, 'DataDefFunction');
  [header,data]=feval(fcn,'load',co(idx));

  % Renew Channel Index(not masking),
  cidx = cidx2+1;
  ch   = pos.Group.OriginalCh{idx2};
  if pos.Group.mode==1,
    idx2=idx2+1;
    ch=[ch pos.Group.OriginalCh{idx2}];
  end
  cidx2 = cidx + length(ch)-1;
  % get Channel (for raw-Data);
  ch2=ch*2; ch2=[ch2 (ch2-1)];
  ch2=sort(ch2);
  % Ignore un msked channel
  if isempty(ch), continue; end

  % Add new data
  new_hdata = header;
  new_info = header.TAGs;
  new_data = data(:,ch,:);

  % * Info Change..
  try
    new_info.plnum = length(pos.Group.ChData);
  end
  try
    new_info.adnummeasnum = new_info.adnummeasnum(1,ch2);
  end
  try
    new_info.wavelength = new_info.wavelength(1,ch2);
  end
  try
    new_info.adrange = new_info.adrange(1,ch2);
  end
  try
    new_info.ampgain = new_info.ampgain(1,ch2);
  end
  try
    new_info.d_gain = new_info.d_gain(1,ch2);
  end
  try
    new_info.data    = new_info.data(:,ch2);
  end
  new_hdata.flag = header.flag(:,:,ch);
  new_hdata.measuremode = -1;
  break;
end

% after,
for idx=idx+1:length(co),
  idx2=idx2+1;
  % Load Data
  [header,data]=feval(getappdata(handles.figure1, 'DataDefFunction'),'load',co(idx));

  cidx = cidx2+1;
  st_size = size(new_data,2);
  ch   = pos.Group.OriginalCh{idx2};
  cidx2 = cidx + length(ch)-1;
  % get Channel (for raw-Data);
  ch2=ch*2; ch2=[ch2 (ch2-1)];
  ch2=sort(ch2);

  if pos.Group.mode==1,
    idx2=idx2+1;
    ch=[ch pos.Group.OriginalCh{idx2}];
  end
  % Renew Channel Index(not masking),
  % Ignore un msked channel
  if isempty(ch), continue; end


  % Add new data
  new_data(:,cidx:cidx2,:) = data(:,ch,:);
  new_hdata.flag(:,:,cidx:cidx2)   = header.flag(:,:,ch);
  % stim, stimTC, StimMode, samplingperiod Must be Same!!;

  % * Info Change..
  try
    new_info.adnummeasnum = ...
      [new_info.adnummeasnum, header.TAGs.adnummeasnum(1,ch2)];
  end
  try
    new_info.wavelength = ...
      [new_info.wavelength, header.TAGs.wavelength(1,ch2)];
  end
  try
    new_info.adrange = ...
      [new_info.adrange, header.TAGs.adrange(1,ch2)];
  end
  try,
    new_info.ampgain = ...
      [new_info.ampgain, header.TAGs.ampgain(1,ch2)];
  end
  try
    new_info.d_gain = ...
      [new_info.d_gain, header.TAGs.d_gain(1,ch2)];
  end
  try
    new_info.data(:,cidx*2-1:cidx2*2)   = header.TAGs.data(:,ch2);
  end
end % end after copy

% Data size change,
new_info.adnum = size(new_data,2)*2;
new_info.chnum = size(new_data,2);

% Other Data change
new_info.ospsoftversion=2;
new_info.measuremode   = -1; % new defined!

% == Make OSP LOCAL DATA ==
data         = new_data; clear new_data;
header       = new_hdata;
header.TAGs  = new_info; clear new_info;
header.Pos    = pos;

%==========================================================================
% Save Option
%==========================================================================
function ckb_replace_Callback(h,e,hs)
if 0,disp(h);disp(e);disp(hs);end
function ckb_autonaming_Callback(h,e,hs)
if 0,disp(h);disp(e);disp(hs);end
