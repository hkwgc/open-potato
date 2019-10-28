function varargout=P3_AdvTgl(fnc,varargin)
% P3 : Status Toggle-Button Control Function


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: P3_AdvTgl.m 180 2011-05-19 09:34:28Z Katura $
if isempty(fnc),OspHelp(mfilename);end
  
%======== Launch Switch ========
switch fnc,
  case 'ChangeTgl',
    ChangeTgl(varargin{:});
  case 'Create',
    varargout{1}=Create(varargin{:});
  case 'SuspendAll',
    SuspendAll(varargin{:});
  case 'MarkSetting',
    MarkSetting(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

function fncs=AdvTglList
% List Of Adv
fncs={...
  @P3_AdvTgl_status,...
  @P3_AdvTgl_1stLvlAna,...
  @P3_AdvTgl_2ndLvlAna};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hs=Create(hs)
% Make Advanced Tgl Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make Frame
hs.advfrm = ...
  subput_advbutton(2,1,2,'Tight',...
  'Tag','advfrm',...
  'Style','Frame');

% Function List
P3_AdvTgl = AdvTglList;
for idx=1:length(P3_AdvTgl)
  hs=feval(P3_AdvTgl{idx},'Create',hs);
end

function SuspendAll(hs)
% Suspend All
set(hs.advfrm,'Visible','off');
atd=getappdata(hs.figure1,'AdvancedToggleData');
hx=[atd.TglHandle];
suspendfnc = AdvTglList;
for idx=1:length(hx)
  if ishandle(hx(idx))
    feval(suspendfnc{idx},'Suspend',hx(idx),hs);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeTgl(h,hs)
% Suspend-Old Tgl & Activate Select Tgl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========
% Load Data
%==========
atd=getappdata(hs.figure1,'AdvancedToggleData');

v=get(hs.lbx_ProjectInfo,'Visible');
if strcmpi(v,'off'),
  % if not visible
  try
    for idx=1:length(atd)
      feval(atd(idx).Function,...
        'Suspend',atd(idx).TglHandle,hs);
      set(atd(idx).TglHandle,'Visible','off');
    end
  catch
    disp(C__FILE__LINE__CHAR);
    disp('   : SUSPEND Error');
    disp(['    ' lasterr]);
  end
  return;
end
  
set(hs.advfrm,'Visible','on');
set(atd(1).TglHandle,'Visible','on');

%=======================================
% Select Open-Function & Close Function
%======================================
set(h,'Value',1); % must be open operation.
% Close Current Tgl & Open Selection
hx=[atd.TglHandle];
myidx=find(hx==h);
currentfnc = atd(myidx).Function;
% Except MySelf
atd(myidx)=[];
hx(myidx) =[]; 

v = get(hx(:),'Value');
if iscell(v),v=cell2mat(v);end
h0=hx(v==1);
%if isempty(h0),return;end

suspendfnc = {atd(v==1).Function};
% if Open==Close
if isequal(currentfnc,suspendfnc),return;end
try
  for idx=1:length(h0)
    feval(suspendfnc{idx},'Suspend',h0(idx),hs);
  end
  feval(currentfnc,'Activate',h,hs);
catch
  errordlg({'Could not Change TAB.',...
    'Caluse : ', lasterr},'P3_Adv Tgl Error');
  set(h,'Value',0);
end  

function MarkSetting(hs)
% Modify File Set
vls      = get(hs.lbx_fileList,'Value');
datalist = get(hs.lbx_fileList,'UserData');
datalist = datalist(vls);

% Open Mark Setting
h0  = P3_MarkSetting;
hs0 = guidata(h0);

try
  for idx=1:length(datalist),
    rd=DataDef2_Analysis('load',datalist(idx));
    dname = DataDef2_RawData('getFilename',rd.data.name);
    [d, hd] = uc_dataload(dname);
    P3_MarkSetting('setContinuousData',h0,[],hs0,hd,d);
    set(hs0.psb_ok,'Visible','on');
    waitfor(hs0.psb_ok,'Visible','off');
    % cancel?
    if ~ishandle(h0),break;end
    [hd,d]=P3_MarkSetting('getContinuousData',h0,[],hs0);
    DataDef2_RawData('save_ow',hd,d,2);
  end
catch
  disp(lasterr);
end
if ishandle(h0),
  delete(h0);
end

% function varargout=P3_MarkSetting(varargin)
% % Debug - Code : before Linking P3_MarkSetting
% persistent fh hd d
% disp('Dumy Code Running');
% if isempty(fh) || ~ishandle(fh)
%   fh=figure;
%   h=uicontrol;
%   set(h,'Style','pushbutton','String','OK','Tag','psb_ok','Callback','set(gcbo,''Visible'',''off'')')
% end
% if nargin>=1,
%   disp(varargin{1});
%   switch varargin{1}
%     case 'setContinuousData'
%       hd=varargin{5};
%       d =varargin{6};
%       disp(hd);
%       hs=guihandles(fh);
%       set(hs.psb_ok,'Visible','on');
%     case 'setContinuousData'
%   end
% end
% if nargout==1, 
%   varargout{1}=fh; 
% end 
% if nargout==2, 
%   varargout{1}=hd; 
%   varargout{2}=d; 
% end 

