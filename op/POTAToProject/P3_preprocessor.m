function varargout = P3_preprocessor(varargin)
% P3_PREPROCESSOR Application M-file for P3_preprocessor.fig
%    FIG = P3_PREPROCESSOR launch P3_preprocessor GUI.
%    P3_PREPROCESSOR('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 24-May-2007 18:11:56
% $Id: P3_preprocessor.m 211 2011-06-16 07:02:21Z Katura $
%
% Revision 1.1  : Import from prepro.
% Revision 1.9  : Add Progress Bar
% Revision 1.15 : Typo, Blush-up
%                 Modify Progress-Text


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



if nargin == 0  % LAUNCH GUI
  fig = openfig(mfilename,'reuse');

  %==================================
  %% ==== Opening Function of SP ===
  %==================================
  OSP_DATA('SET','SP_ANONYMITY',true); % since 1.15
  OSP_DATA('SET','SP_Rename','-'); % since 1.16

  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  handles.figure1=fig;
  guidata(fig, handles);
  % since 2.6 : Load-Plugin Setting
  pop_OpenMode_Callback(handles.pop_OpenMode, true, handles);
  
  % ==> Move Options
  pop_RenameOption_Callback(handles.pop_RenameOption, [], handles);


  %=== Moving Figure ===>>>>
  % Figue Size
  p=get(fig,'Position');
  if p(3)>= 601
    p(3)=590;
    set(fig,'Position',p);
    % Rename Option
    hx=[handles.chk_Rename,handles.pop_Rename,handles.edit_Rename];
    for idx=1:length(hx),
      p0=get(hx(idx),'Position');
      p0(1)=p0(1)-300;
      set(hx(idx),'Position',p0)
    end
    % Meeting on 20-Apr-2007
    psb_ltlt_Callback(handles.psb_ltlt,[],handles);
  end
  %<<<======================
  
  %===============================================>>>>
  % Tell Meeting at 2007.09.05 11:40 with TK & Shoji
  %   * Mail at 2007/09/05 11:09:38
  %     from Shoji to TK : Mission No X.
  %<<<===============================================
  p=fileparts(which(mfilename));
  mytext=[p filesep 'P3_preprocessor.txt'];
  if exist(mytext,'file')
    try
      str=get(handles.pop_PreproFunction,'String');
      % Save Last PreproFunction
      fid=fopen(mytext,'r');
      try
        tline=fgetl(fid);
      catch
        % I must close..
      end
      fclose(fid);
      
      myid=find(strcmp(tline,str));
      if ~isempty(myid)
        set(handles.pop_PreproFunction,'Value',myid(1));
        pop_PreproFunction_Callback(handles.pop_PreproFunction,[],handles);
      end
    catch
      % do nothing for function set error
    end
  else
    pop_PreproFunction_Callback(handles.pop_PreproFunction,[],handles);
  end
  
  % to Progres Bar
  set(handles.txt_Status,'UserData',0); % since 1.19

  if nargout > 0
    varargout{1} = fig;
  end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  %==================================
  %% Launch Children
  %==================================
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
      feval(varargin{:}); % FEVAL switchyard
    end
  catch
    disp(lasterr);
  end
end

%==================================
%% figure 
%==================================
function main_strns_fig_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function main_strns_fig_DeleteFcn(hObject, eventdata, handles)
try
  OSP_DATA('SET','SP_ANONYMITY',false); % since 1.15
  OSP_DATA('SET','SP_Rename','-'); % since 1.16
  %osp_ComDeleteFcn;
catch
  disp('[W] Rename Option Reset Error.');
  disp(lasterr);
end


function main_strns_fig_KeyPressFcn(hObject, eventdata, handles)
% Key Bind
osp_KeyBind(hObject, eventdata, handles,mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==== (File Select) ====
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ================================
function file_select_psb_Callback(h, eventdata, handles, varargin)
% Execute on press File Open Push button.
% File Open
% ================================
persistent mypath;
% -----
% Check existing Preprocessor Function
% -----
funcs=get(handles.lbx_PreproFunction, 'UserData');
if isempty(funcs),
  errordlg('No  Preprocessor Opration Function Selected.');
  return;
end

%---------------------
%   File Select
%---------------------
% Set Working-Directory for "uigetfiles"

% Backup "current working directory" to recover
pwdtmp=pwd;

% Default Directory of 'uigetfiles'
%  == Project Directory
pj=OSP_DATA('GET','PROJECT');        % Open Project Data
if isempty(pj)
  % if there is no Project --> Error
  errordlg({'P3 Error!!', ...
    '  There is no Current-Project (Data-Directory).', ...
    '  Open Project at first!', ...
    '    :: Open OSP Main-Controller --> ', ...
    '       Select File-Menu : Project -->', ...
    ['       I/O -> "New Project"/' ...
    '"Open Project"/"ImportProject"'], ...
    '        "Search Project"'});
  return;
end
if isempty(mypath) || ~isdir(mypath)
  openpath=pj.Path;
else
  openpath=mypath;
end
cd(openpath);
try
  %===============================================>>>>
  % Tell Meeting at 2007.09.05 11:40 with TK & Shoji
  %   * Mail at 2007/09/05 11:09:38
  %     from Shoji to TK : Mission No 1.
  filterspec='';
  % File Select
  try
    if length(funcs)==1
      filterspec=feval(funcs{1}, 'getFilterSpec');
    end
  catch
    filterspec='';
  end
  
  if isempty(filterspec)
    % Error / auto : defult filter spec
    %  '*.dat; *.mea; *.csv; s_*.mat; RAW_*.mat; HB_*.mat;
    %  *.txt;*.airMeasure; *.asimtable;*.airmset', ...
    if 0
      filterspec={...
        '*.dat; *.mea; *.csv; s_*.mat; RAW_*.mat; HB_*.mat; *.txt;*.airMeasure;*.airmset;*.ktmset', ...
        'P3 Known Files';...
        '*_Probe[0-9]+_Oxy.csv','HB Data';...
        's_*.mat', 'VER0.x Signal Data'; ...
        'HB_*.mat', 'VER1.0 Signal Data'; ...
        'RAW_*.mat', 'P3 Data'; ...
        '*.asimtable','AIR System';...
        '*.airmset','AIR Single-Data';...
        '*.ktmset','WOT:Setting-File'; ...
        '*.dat', 'Dat Files'; ...
        '*.mea', 'Mea Files'; ...
        '*.csv', 'CSV Files'; ...
        '*.txt', 'Shimadzu-Format or Text'};
      % '*_Probe1_Oxy.csv','HB Data(Probe1)';...
    else
      filterspec={...
        '*.dat; *.mea; *.csv; s_*.mat; RAW_*.mat; HB_*.mat;*.ktmset', ...
        'P3 Known Files';...
        '*_Probe[0-9]+_Oxy.csv','HB Data';...
        's_*.mat', 'VER0.x Signal Data'; ...
        'HB_*.mat', 'VER1.0 Signal Data'; ...
        'RAW_*.mat', 'P3 Data'; ...
        '*.dat', 'Dat Files'; ...
        '*.mea', 'Mea Files'; ...
        '*.ktmset','WOT:Setting-File'; ...
        '*.csv', 'CSV Files'};
    end
  end
  %<<<===============================================
  [fn pn]=uigetfiles(filterspec, ...
    'Import Files');
  %			'CD_*.mat', 'VER2.0 Continuous Data'; ...
catch
  cd(pwdtmp);
  error('File Select Error');
end
% Recover Current Working Directory
cd(pwdtmp);

% -----------------
%  Check And Store
%     : Open File
% ------------------
% Check Cancel : Added by Shoji, 12-Oct-2004
if isequal(fn,0) || isequal(pn,0), return;end
if isdir(pn), mypath=pn; end
% Get Current FileList Information
filelist = get(handles.drnm_strns_lsb, 'String');
funclist = get(handles.drnm_strns_lsb, 'UserData');
for id=1: length(fn)
  % Make File Name with Full-Path.
  fullpath=[pn filesep fn{id}];

  % - check Same Name - Added by Shoji, 12-Oct-2004
  cmp= strcmp(filelist(:),fullpath);
  if sum(cmp)>0
    % If Selected File in uigetfiles is already Listed.
    msg=sprintf('Following File is already listed!\n\n\t%s',fn{id});
    errordlg(msg);
    continue;
  end

  % ================================================
  % File Check & Add
  % - Add file to the list & Change Selected File -
  % Preprocessor Function (Conversion Function )
  %  List-Loop
  %  Modified : Reversion 1.17
  % ================================================
  flg = false;
  % Search Evaluate Function
  for fidx=1: length(funcs)
    % Check :
    %   Function 'funcs{fidx}' is available?
    [flg, msg] = feval(funcs{fidx}, 'CheckFile', fullpath);
    if flg==true,
      % Available :
      %   Add to the List
      %   with Preprocessor loop
      if isempty(funclist),
        filelist{1}=fullpath;
        funclist{1}=funcs{fidx};
      else
        filelist{end+1}=fullpath;
        funclist{end+1}=funcs{fidx};
      end                            %
      break; % exit : Function Loop
    end % Available
  end % Function Loop ( Function List)

  if (flg==false),
    %===============================================>>>>
    % Tell Meeting at 2007.09.05 11:40 with TK & Shoji
    %   * Mail at 2007/09/05 11:09:38
    %     from Shoji to TK : Mission No 4.
    %<<<===============================================
    if length(funcs)==1
      errordlg({'Improper File, Named, ',...
        ['   ' fn{id}],...
        msg},'Improper File Format');
    else
      % No Available Preprocessor Function exist.
      % Add : 28-Dec-2005
      warndlg({'No Available Preprocessor-Functions!', ...
        ['   File Name : ' fn{id}]});
    end
  end
end % File List(Uigetfiles)

if ~isempty(filelist),
  % Update File-List
  set(handles.drnm_strns_lsb, ...
    'String',  filelist, ...
    'Value',   length(filelist), ...
    'UserData',funclist);
  % ==> get file infomation
  drnm_strns_lsb_Callback(h, eventdata, handles, varargin);
end
return;


% ================================
%  File Remove
% ================================
function file_remove_psb_Callback(h, eventdata, handles, varargin)
%file remove
st=get(handles.drnm_strns_lsb, 'String');
tg=get(handles.drnm_strns_lsb, 'Value');
ud=get(handles.drnm_strns_lsb, 'UserData');    % function name

if isempty(st), errordlg(' No file to remove');return; end
try
  st(tg)=[]; ud(tg)=[];
catch
  errordlg('Cannot remove');return;
end
val=tg(1)-1;

set(handles.drnm_strns_lsb, ...
  'Value', val+(val==0), ...
  'String', st,...
  'UserData', ud);
set(handles.outvar_strns_lsb,...
  'Value',1,'String','- Removed -');  % Added by Shoji 13-Oct-2004

% Redraw File Information,
if ~isempty(st)
  drnm_strns_lsb_Callback(h, eventdata, handles, varargin);
else
  OSP_DATA('SET','ActiveData',[]);
end


%============================
function exec_strns_psb_Callback(h, eventdata, handles, varargin)
% === Execute Conversion ===
% Date : 28-Dec-2005
%============================

% --- get Translation List ---
filelist=get(handles.drnm_strns_lsb, 'String');
funclist=get(handles.drnm_strns_lsb, 'UserData');
listsz=length(filelist);
if isempty(funclist),
  errordlg(' No files to convert!');return;
end

% --- Start Lock  ---
gui_buttonlock('lock',gcf,h);
set(h,'Enable','inactive');
actFlag = OSP_DATA('GET','ACTIVE_FLAG');
OSP_DATA('SET','ACTIVE_FLAG',bitset(actFlag,2));
try
  % Transrate each of file in the list
  last_file=[];
  make_tmp_pplugin(handles);
  
  % to Progres Bar
  set(handles.txt_Status,'UserData',0); % since 1.19
  exestat=zeros(listsz,1);
  
  set(handles.figure1,'CurrentAxes',handles.axe_Status);
  cla;
  px=linspace(0,1,listsz+1);
  pxx=[px(1:end-1) px(1:end-1), ;px(2:end) px(2:end);px(1:end-1) px(2:end)];
  
  c=ones([3, listsz*2,3]);
  %py=[0 0 1; 1 1 0]';
  %pyy=repmat(py,1,listsz);
  pyy=[repmat([0 0 1]',1,listsz), repmat([1 1 0]',1,listsz)];
  ph=patch(pxx,pyy,c);
  set(ph,'LineStyle','none');drawnow;

  c0=ones([3,2,3])*0.8;
  ce=c0;ce(:,:,1)=0.9;
  co=c0;c0(:,:,2)=0.9;
  cw=ce;ce(:,:,3)=0.9;
  
  nOKfile=0;
  for i0=1:listsz
    exestat(i0)=1; % Start
    c(:,[i0, i0+listsz],:)=c0;
    set(ph,'CData',c);drawnow;
    
    set(handles.drnm_strns_lsb, 'value', i0)
    setActiveData(filelist{i0});
    acd = OSP_DATA('get', 'ActiveData');

    % Ignore Converted Data.
    % ( If Same-Named Data exist in the list,
    %   Continue..)
    sp_rename=OSP_DATA('GET','SP_Rename'); % since 1.16
    if strcmp(sp_rename,'-') && ~isempty(acd)
      warndlg({' ==== Data may be  already exist ====', ...
        '  Same-name File exist in the Project', ...
        '     Case 1 : The file already converted.',  ...
        '       if you want to remake, remove at first' ,...
        '     Case 2 : Same Name File, but different data',...
        '       Change File-Name to unique-name'}, ...
        [' Saving ' filelist{i0}]);
      last_file=filelist{i0};
      exestat(i0)=-1; % Error: Same Name
      c(:,[i0, i0+listsz],:)=cw;
      set(ph,'CData',c);drawnow;
      continue;
    end

    try
      endflg=preprocessor_otsigtrnschld2(filelist{i0},funclist{i0});
      % endflg=otsigtrnschld(filelist{i0});
      last_file=filelist{i0};
      exestat(i0)=2; % Succes
      c(:,[i0, i0+listsz],:)=co;
      set(ph,'CData',c);drawnow;
    catch
      msg=sprintf('Convert Error : %s\n\n%s\n', ...
        filelist{i0}, ...
        lasterr);
      errordlg(msg);
      exestat(i0)=-2; % Error: Same Name
      c(:,[i0, i0+listsz],:)=ce;
      set(ph,'CData',c);drawnow;
      continue;
    end
    if endflg==true, break; end    % To Stop translation

    
    %-----------------------
    % Progress Text update
    % Meeting on 25-Jan-2008
    %------------------------
    nOKfile=nOKfile+1; % Include, Number of OK Files
    set(handles.txt_Status,...
      'String',sprintf('%d/%d',nOKfile,listsz),...
      'UserData',nOKfile);
  end

  setActiveData(last_file);
catch
  errordlg({'Error : ', ...
    ['  ' lasterr]})
end

% --- Unlock ---
OSP_DATA('SET','ACTIVE_FLAG',bitset(actFlag,2,0));
gui_buttonlock('unlock',handles.main_strns_fig);
unlock_local(handles);

okid=find(exestat==2);
if length(okid)==listsz
  %----------
  % Delete Now
  % since r1.34 :
  %    mail from TK at  Wed, 28 Jun 2006 15:43:04
  %----------
  OSP_DATA('SET','SP_ANONYMITY',false); % since 1.15
  OSP_DATA('SET','SP_Rename','-'); % since 1.16
  delete(handles.main_strns_fig);
else
  if ~isempty(okid)
    set(handles.drnm_strns_lsb, 'Value',okid);
    file_remove_psb_Callback(handles.file_remove_psb, eventdata, handles);
  end
  set(0,'CurrentFigure',handles.figure1);
  set(handles.figure1,'CurrentAxes',handles.axe_Status);
  set(ph,'CData',c);drawnow;
  cla
  % Stat Modify ::
  set(handles.txt_Status,...
    'String',sprintf('%d/%d',nOKfile,listsz),...
    'UserData',nOKfile);
end
return;

% --------------------------------------------------------------------
function drnm_strns_lsb_Callback(h, eventdata, handles, varargin)
%file list box
%When you click a file from this file list box, the file information is
%displayed on file information list box.??

filelist = get(handles.drnm_strns_lsb, 'String');
id       = get(handles.drnm_strns_lsb, 'Value');
funclist = get(handles.drnm_strns_lsb, 'UserData');
if id<1, return;end
if isempty(funclist) || isempty(filelist), return; end
fullname = filelist{id(1)};

[pathname, filename]=pathandfilename(fullname);

% Add Error case display by Shoji 14-Oct-2004
try
  str = feval(funclist{id(1)}, 'getFileInfo', fullname);
  %%  [hdata, data] = feval(funclist{id(1)}, 'Execute', fullname);
  %%   OSP_DATA('SET','OSP_LocalData',ldata);
  if isempty(str),
    str ={ 'No information about this file : may be bat file.'};
  end
  set(handles.outvar_strns_lsb,'Value',1,'String',str);
catch
  msg=sprintf('--- Selected file is Out-of-ETG-format ---\n\n%s\n  File :%s',...
    lasterr,filename);
  errordlg(msg);
  set(handles.outvar_strns_lsb,'Value',1,'String',msg);
  return;
end

setActiveData(fullname);

% Progres-Bar
a=get(handles.txt_Status,'UserData');
b=length(filelist);
% Meeting on B070601B (by Tsuzuki)
%set(handles.txt_Status,'String',sprintf('Conver : %d/%d',a,b));
set(handles.txt_Status,'String',sprintf('%d/%d',a,b));
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==== Fileter Option ====
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Removed Following Functions
% Date : 28-Dec-2005
%  function varargout = cbxMovingAverage_Callback(h, eventdata, handles, varargin)
%  function varargout = cbxFitting_Callback(h, eventdata, handles, varargin)
%  function varargout = frqflt_valu_Callback(h, eventdata, handles, varargin)
%  function varargout = outvar_strns_lsb_Callback(h, eventdata, handles, varargin)


%%%%%%%%%%%%%%%%%
% Edit HB Data
%%%%%%%%%%%%%%%%%
function psb_HB_EDIT_Callback(hObject, eventdata, handles)
% Edit HB Data
% 05-Jan-2006 ,  M. Shoji

% Read Active Data
actdata = OSP_DATA('GET','ACTIVEDATA');
if isempty(actdata)
  warndlg({' No files to Edit!', ...
    '  Select Convert Data'}, ...
    '  HB Edit Button : Warning ');
  return;
end
[header, data]=DataDef2_RawData('load',actdata);
% --- Start Lock  ---
gui_buttonlock('lock',handles.main_strns_fig,hObject);
set(hObject,'Enable','inactive');
af = OSP_DATA('GET','ACTIVE_FLAG');
OSP_DATA('SET','ACTIVE_FLAG',bitset(af,2));

% === Edit HB Data  ===
try
  idx_chb=[1:length(header.TAGs.DataTag)];
  idx_chb(3)=[];   % Total Clean up

  [data DataTag]= ...
    OSP_DataEdit('Data',data(:,:,idx_chb), ...
    'Tag', {'Time','Channel', 'Data-Kind'},...
    'TagDim3', {header.TAGs.DataTag{idx_chb}},...
    'EditNum',16);
catch
  OSP_LOG('err',lasterr);
end
% --- End Lock ---
OSP_DATA('SET','ACTIVE_FLAG',af);
gui_buttonlock('unlock',handles.main_strns_fig)
unlock_local(handles);

% == Remake Total ==
if size(data,3) > 2
  data(:,:,4:end+1)=data(:,:,3:end);
  header.TAGs.DataTag{4:length(DataTag)+1} = ...
    DataTag{3:end}
end
data(:,:,3)=data(:,:,1)+data(:,:,2); % Make Total

% == Save Data ==
DataDef2_RawData('save_ow',header,data,2,actdata);
return;

%% when unlock, re lock if grouping-Data exist
function unlock_local(handles)
% cbxFitting_Callback(handles.cbxFitting, [], handles);
% cbxMovingAverage_Callback(handles.cbxMovingAverage, [], handles);
% frqflt_valu_Callback(handles.frqflt_valu, [], handles);
return;


% --- Executes during object creation, after setting all properties.
function outvar_strns_lsb_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'FontName','FixedWidth');


function comment = setActiveData(fullpath)
% Set Active Data from Filename
% --- SetActiveData --
% And

% Clear Current Acitevke Data.
comment=[];
OSP_DATA('SET','ACTIVEDATA',[]);

%Input Check
if isempty(fullpath)
  comment='No File Selected';
  return;
end
% get filename
[pathname, filename]=pathandfilename(fullpath);

% Get File List Data
file_list = DataDef2_RawData('loadlist');
if isempty(file_list)
  comment=' No correspondding Raw Data in Current-Project.';
  return;
end
fnames = {file_list.filename};

rslt = find(strcmp(fnames, filename));
if isempty(rslt)
  comment=' No Converted Data ';
  return;
end

if length(rslt)~=1
  error('File List is broken');
end

actdata.fcn = @DataDef2_RawData;
actdata.data = file_list(rslt(1));
OSP_DATA('SET','ACTIVEDATA',actdata);

function chk_anonymity_Callback(hObject, eventdata, handles)
% Set Anonymity
v = get(hObject,'Value');
OSP_DATA('SET','SP_ANONYMITY',logical(v));



function chk_Rename_Callback(hObject, eventdata, handles)
% Renane Option
%  Use/ not use
set(handles.edit_Rename,'Visible','off');
if get(hObject,'Value'),
  str={'InputName', ...
    'OriginalName', ...
    'Date', ...
    'DataLength', ...
    'ID'};
  v = get(handles.pop_Rename,'UserData');
  if isempty(v), v=1; end
  OSP_DATA('SET','SP_Rename',str{v});
  set(handles.pop_Rename, ...
    'Value', v, ...
    'String', str, ...
    'Enable','on');
  if v==1,
    edit_Rename_Callback(handles.edit_Rename,[],handles);
  end
else
  OSP_DATA('SET','SP_Rename','-');
  set(handles.pop_Rename,...
    'Value', 1, ...
    'String',{'-'}, ...
    'Enable','off');
end

function edit_Rename_CreateFcn(hObject, eventdata, handles)
% Set Default String of Input --- Rename --
set(hObject,'String',date)

function edit_Rename_Callback(hObject, eventdata, handles)
% Set Input-Name
set(hObject,'Visible','on');
% My Input Name
in0.str=get(hObject,'String');
in0.id =0;
OSP_DATA('SET','SP_Rename_IN',in0);


function pop_Rename_Callback(hObject, eventdata, handles)
set(hObject,'UserData',get(hObject,'Value'));
chk_Rename_Callback(handles.chk_Rename, [], handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Signal Preprocessor
%    Execute Functions
%    22-Dec-2005
%    since r1.16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - - - - - - - - -
% Create Functions
%  == Reset Mode ==
% - - - - - - - - -

function pop_OpenMode_CreateFcn(hObject, eventdata, handles)
% Execute during Opne-Mode-Popupmenu Creation,
%    after setting all properties in figure.
%
% Open File Mode is Mode used in
%    file_select_psb_Callback
% Now we have only one-mode.
%
% See also : file_select_psb_Callback
% Date : 22-Dec-2005
set(hObject,'String',{'1'});

function pop_PreproFunction_CreateFcn(hObject, eventdata, handles)
% Start with Opne File Mode 1.
% Date : 22-Dec-2005
pop_PreproFunction_Callback(hObject, [], handles,1);

function lbx_PreproFunction_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% And Call from pop_OpenMode_Callback, when refresh Data.
% See also : pop_OpenMode_Callback
% Date : 22-Dec-2005
set(hObject,...
  'Value',1, ...
  'String',{'----'}, ...
  'UserData',[]);
if ~isempty(handles) && isstruct(handles) && ...
    isfield(handles,'lbx_InfoPreproFunction') && ...
    ishandle(handles.lbx_InfoPreproFunction)
  set(handles.lbx_InfoPreproFunction,'String',{'--- No Function Selected ---'});
end
function lbx_InfoPreproFunction_CreateFcn(hObject, eventdata, handles)
% Executes during object creation, after setting all properties.
% And Call from pop_OpenMode_Callback, when refresh Data.
% See also : pop_OpenMode_Callback
% Date : 22-Dec-2005
set(hObject,'Value',1,'String',{'--- No Function Selected ---'});

% - - - - - - - - -
% Mode Selected
% - - - - - - - - -
function pop_OpenMode_Callback(hObject, eventdata, handles)
% Execute when OpenMode is changed.
% Change Open Mode : Refresh
% Date : 22-Dec-2005
vl = get(hObject,'Value');
% Change Mode ( Function List )
set(handles.pop_PreproFunction, 'Visible','on');
pop_PreproFunction_Callback(handles.pop_PreproFunction, [], handles,vl);
% Reset List Box : 10-Jan-2006 Change
%chk_AutoPreproFunction_Callback(handles.chk_AutoPreproFunction,[],handles);
if isempty(eventdata)
  pop_PreproFunction_Callback(handles.pop_PreproFunction, [], handles);
end
return;

function chk_AutoPreproFunction_Callback(hObject, eventdata, handles)
% Execute when check-box : Auto P3_preprocessor-Function OpenMode is clicked.
%  or OpenMode is call back
% Change Open Mode : Refresh
% Date : 10-Jan-2006
lbx_PreproFunction_CreateFcn(handles.lbx_PreproFunction,...
  [], handles);
lbx_InfoPreproFunction_CreateFcn(handles.lbx_InfoPreproFunction,...
  [], handles);
v =get(hObject,'Value');
h2= handles.pop_PreproFunction;
if v==1,
  % get Defalut-Value.
  id =get(h2,'Value');
  % Get Function List
  fnc=get(h2,'UserData');

  % Set All Function Available..
  for idx=1:length(fnc),
    try
      set(h2,'Value',idx);
      pop_PreproFunction_Callback(h2,[],handles);
    end
  end
  set(h2,'Visible','off','Value',id);
  set(handles.lbx_PreproFunction,'Value',1);
  % Set InfoPreproFunction
  lbx_PreproFunction_Callback(handles.lbx_PreproFunction, [], ...
    handles);
else
  set(h2,'Visible','on');
end

function lbx_PreproFunction_Callback(hObject, eventdata, handles)
% Execute When Selected Prepro-Execution-Function Change.
id =get(hObject,'Value');
fnc=get(hObject,'UserData');
if length(fnc)<id,
  return;
end
try
  str = feval(fnc{id},'getFunctionInfo');
  set(handles.lbx_InfoPreproFunction,...
    'Value', 1, ...
    'String',str);
catch
  set(handles.lbx_InfoPreproFunction,...
    'Value', 1, ...
    'String',...
    {'Error Occur : ', ...
    '  No Information Exist.', ...
    ['  ' lasterr]});
end


function lbx_InfoPreproFunction_Callback(hObject, eventdata, handles)
% ... Sorry : Do nothing now::--> remove Callback from .fig
% Date : 22-Dec-2005


function pop_PreproFunction_Callback(hObject, eventdata, handles, id)
% Execute When Popupmenu-PreproFunction Change.
%              Create-Function, Mode..

% Preprocessor Function (Back-Up)
persistent myPreproFile;

if nargin==4,
  ospPath=OSP_DATA('GET','OSPPATH');
  path0 = pwd;
  %path1 = [ospPath filesep '..' filesep 'preprocessor' filesep];
  [pp ff] = fileparts(ospPath);
  if( strcmp(ff,'WinP3')~=0 )
    path1 = [ospPath filesep '..' filesep 'preprocessor' filesep];
  else
    path1 = [ospPath filesep 'preprocessor' filesep];
  end

  fnc   = {'Auto Select'};
  str   = {'Auto'};
  try
    cd(path1);
    % --- Search Files ---
    % Old-Code : Replase find_file at 2006.10.3

		files=find_file('^prepro\w+.[mp]$', path1,'-i','-n',2); %090311 TK

    for idx=1:length(files),
      [p,f,e]=fileparts(files{idx});       %090311 TK
      %f=files{idx};
      try
        if strcmpi(f,'preproAIR_System'),continue;end
        %cd(p);
        fnc0 = eval(['@' f]);
        bi   = feval(fnc0,'createBasicInfo');
        if (id==bi.OpenKind),
          if isempty(find(strcmp(str, bi.DispName))),
            str{end+1}=bi.DispName;
            fnc{end+1}=fnc0;
          end
        end
      catch
        errordlg({'P3 Error!!', ...
          ['Function : ' f], ...
          '    createBasicInfo Error', ...
          ['    ' lasterr]});
      end
    end
    % for auto mode
    %disp(fnc{1});
    fnc{1}=fnc(2:end);
  catch
    errordlg({'P3 Error!!',lasterr});
  end
  cd(path0);
  if isempty(str),
    str = {'-- No Function Exist --'};
  end
  set(hObject,...
    'Value',1, ...
    'String', str, ...
    'UserData',fnc);
else
  vl  = get(hObject,'Value');
  str = get(hObject,'String');
  fnc = get(hObject,'UserData');
  if isempty(eventdata)  && vl~=1
    % Selecting One
    vl2=1;
    str2=str(vl);
    fnc2=fnc(vl);
  else
    % :: for auto mode ::
    % ==>Old code : 
    %   add Listbox
    vl2=1;
    fnc2=fnc{1};
    str2=str(2:end);
%     str2 = get(handles.lbx_PreproFunction,'String');
%     fnc2 = get(handles.lbx_PreproFunction,'UserData');
%     if isempty(fnc2)
%       vl2=1;
%       str2={str};
%       fnc2={fnc};
%     else
%       if isempty(find(strcmp(str2, str))),
%         str2{end+1}=str;
%         fnc2{end+1}=fnc;
%       end
%       vl2 = length(str2);
%     end
  end
  set(handles.lbx_PreproFunction,...
    'Value', vl2, ...
    'String', str2, ...
    'UserData', fnc2);
  lbx_PreproFunction_Callback(handles.lbx_PreproFunction,...
    [], handles)
  
  %===============================================>>>>
  % Tell Meeting at 2007.09.05 11:40 with TK & Shoji
  %   * Mail at 2007/09/05 11:09:38
  %     from Shoji to TK : Mission No X.
  %<<<===============================================
  if isempty(myPreproFile)
    p=fileparts(which(mfilename));
    myPreproFile=[p filesep 'P3_preprocessor.txt'];
  end
  
  % Save Last PreproFunction
  fid=fopen(myPreproFile,'w');
  try
    fprintf(fid,str{vl});
  catch
    % I must close..
  end
  fclose(fid);
end

function psb_delPreproFunction_Callback(hObject, eventdata, handles)
% Delete Preprocessor Function From list

% Handle of Function List-Box
h_fl = handles.lbx_PreproFunction;
id =get(h_fl,'Value');
fnc=get(h_fl,'UserData');
str=get(h_fl,'String');
if length(fnc)<id,
  return;
end

% Remove Selecting Function from the List.
fnc(id)=[];
str(id)=[];
if isempty(fnc),
  % Show -> Empty
  lbx_PreproFunction_CreateFcn(h_fl,[],handles);
else
  % ID Check.. not to select overfllow data.
  if (id>length(fnc)), id = length(fnc); end
  % Update Function-List
  set(h_fl,'Value',id,'UserData',fnc, 'String',str);
  % Change Information of selecting function
  lbx_PreproFunction_Callback(h_fl,[],handles);
end


function tgb_advanced_mode_Callback(hObject, eventdata, handles)
% Get Advanced mode
state=get(hObject,'Value');

if state == get(hObject, 'Max'),
  %-- Show --
  set(handles.chk_AutoPreproFunction, 'Visible', 'on', 'Enable', 'on');
  set(handles.pop_PreproFunction,     'Visible', 'on', 'Enable', 'on');
  set(handles.psb_delPreproFunction,  'Visible', 'on', 'Enable', 'on');
  set(handles.lbx_PreproFunction,     'Visible', 'on', 'Enable', 'on');
  set(handles.lbx_InfoPreproFunction, 'Visible', 'on', 'Enable', 'on');
elseif state == get(hObject, 'Min'),
  %-- Hide --
  set(handles.chk_AutoPreproFunction, 'Visible', 'off', 'Enable', 'off');
  set(handles.pop_PreproFunction,     'Visible', 'off', 'Enable', 'off');
  set(handles.psb_delPreproFunction,  'Visible', 'off', 'Enable', 'off');
  set(handles.lbx_PreproFunction,     'Visible', 'off', 'Enable', 'off');
  set(handles.lbx_InfoPreproFunction, 'Visible', 'off', 'Enable', 'off');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Sub-Data-Read Plugin :: Control Functions
%                      Last Modify : M. Shoji
%                      Last Data   : 2007.01.30
%                           since  : 1.5
%
% dbgmode : ture  : Debugmode is running.
%           false : Debugmode is not running.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%//////////////////////////////////
% Basic Function List :
%
% 1.  Get Poupumenu Data
%    data=getPluginFunction(handles,flag)
%     flag 1 : get Function
%     flag 2 : Plugin-Object-Data
%  2. Redraw  Filter Data
%   redraw_lbx_FiltData(handles);
%//////////////////////////////////
function data=getPluginFunction(handles,flag)
% 
if nargin<=1,flag=1;end
id = get(handles.pop_FilterList,'Value');
ud = get(handles.pop_FilterList,'UserData');
fnc=ud.wrapper{id};
if ~ischar(fnc)
  fnc=func2str(fnc);
end

switch flag,
  case 1,
    data=fnc;
  case 2,
    data.name=ud.dispname{id};
    data.wrap=fnc;
  otherwise,
    error('Invalid Usage.');
end

function redraw_lbx_FiltData(hs)
% Draw Listbox of Plugin Data
ud=get(hs.lbx_FiltData,'UserData');
list=ud.list;
mk  =ud.enable;
if isempty(list)
  str={'== No Optional Data =='};
else
  str={'== Plugin List =='};
end

for idx=1:length(list)
  % Function Nmae
  if mk(idx),
    str{end+1}=sprintf(' o %s',list{idx}.name);
  else
    str{end+1}=sprintf(' x %s',list{idx}.name);
  end
  if ~isfield(list{idx},'argData'),
    str{end+1}='  L No Argument';
  else
    argstrct = list{idx}.argData;
    argchr='  L ';
    argname = fieldnames(argstrct);
    % Argument List Loop
    for agid = 1:length(argname)
      argvar = getfield(argstrct,argname{agid});
      if isnumeric(argvar)
        % Numeric?
        argvar = argvar(:);
        tmp = num2str(argvar');
        if length(argvar)~=1
          tmp = [ '[' tmp ']'];
        end
        argvar = tmp;
      elseif isstruct(argvar),
        % Structure?
        tmp=fieldnames(argvar);
        argvar='struct(';
        for idx2=1:length(tmp),
          argvar=[argvar tmp{idx2} ', '];
        end
        if isempty(tmp),
          argvar='Empty-Structure';
        else
          argvar(end-1)=')';
        end
      elseif iscell(argvar),
        tmp = '{';
        for tmpsz=size(argvar),
          tmp = [num2str(tmpsz(1)) 'x'];
        end
        tmp(end) = '}';
        argvar = tmp;
      end
      argchr =[argchr argname{agid} ':' ...
        argvar ', '];
    end % Argument Data Loop
    str{end+1}=argchr;
  end
end
vl=get(hs.lbx_FiltData,'Value');
if vl>=length(str),vl=length(str);end
set(hs.lbx_FiltData,'String',str,'Value',vl);


%//////////////////////////////////
%  Startup
%//////////////////////////////////
% ================================
function pop_FilterList_CreateFcn(hObject, ev, handles)
% Make Plugin-List 
%
%   String   : Name of Plugin
%   UserData : Name of Plugin-Wrapper
% ================================

% Setting of this function.
osp_path=OSP_DATA('GET','OspPath');
%plugin_path = [osp_path filesep '..' filesep 'PluginDir'];
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  plugin_path = [osp_path filesep '..' filesep 'PluginDir'];
else
  plugin_path = [osp_path filesep 'PluginDir'];
end
pat = '^PlugInWrapPP_\w+.[mp]$';
dbgmode=false;

% Initialize...
dispname  ={}; % Output :==> String
wrapper   ={}; % Output :==> UserData 
dispkind  =[];
logmsg    ={}; % for message
if dbgmode,
  fprintf('=================================================\n');
  fprintf('[DBG] Creating Plugin\n');
  fprintf('      Current Plugin Dire : %s\n',plugin_path);
  fprintf('      Search Pattern : %s\n',pat);
  fprintf('      at %s\n',C__FILE__LINE__CHAR);
  fprintf('-------------------------------------------------\n');
end

% ==================================================
% Search Plugin
% ==================================================
tmpdir = pwd; % Backup Directory
try
  cd(plugin_path);
  % Search Plugin
  files=find_file(pat, plugin_path,'-i','-n',2);
  %============================================
  % Checkin  Plugin-File
  %============================================
  for idx=1:length(files),
    try
      % -- Get Function  - Name --
      [pth, nm] = fileparts(files{idx});
      % In the Directory ..
      cd(pth);
      % --- Wrapper ---
      % Get Function Pointer
      nm2 = eval(['@' nm]);

      % -----------------
      % Get Basic Infor!
      % -----------------
      bi = feval(nm2,'createBasicInfo');
      % Check data
      if ~isfield(bi,'name'),
        error([nm ...
          ': Return-val of createBasicInfo'...
          ': Too few field']);
      end

      % -------------------
      % Display Name
      % -------------------
      % Modify Display Name (Rename)
      x=find(strcmp(dispname,bi.name));
      if ~isempty(x),
        rnmid=0;
        while 1,
          rnmid=rnmid+1;
          rname=sprintf('%s (%d)',bi.name,rnmid);
          x=find(strcmp(dispname,rname));
          if isempty(x), break;end
        end
        logmsg{end+1} =sprintf('Rename : %s to %s', bi.name, rname);
        bi.name=rname;
      end

      %---------------
      % Add to List
      % (If no error)
      %---------------
      idxX = length(dispkind)+1;
      dispname{idxX}   = bi.name;
      wrapper{idxX}    = nm2;
      if isfield(bi,'DispKind')
        dispkind(idxX)   =bi.DispKind;
      else
        dispkind(idxX)   =0;
      end
    catch
      warning(lasterr);
      fprintf(2,'File : %s\n',files{idx});
    end
  end
catch
  cd(tmpdir);
  rethrow(lasterror);
end
cd(tmpdir);
if ~isempty(logmsg),warndlg(logmsg);end

% ==================================================
% Output Data
% ==================================================
ud.dispname = dispname;
ud.wrapper  = wrapper;
ud.dispkind = dispkind;
if isempty(dispkind),dispname={'No Plugin'};end
set(hObject,'String',dispname,'UserData',ud);

% ==================================================
% Change Status ==> Disp Kind
% ==================================================
% now : Do nothing
function pop_FilterList_Callback(hObject, eventdata, handles)
% Do nothing

%//////////////////////////////////
%  Plugin I/O
%//////////////////////////////////
function psb_addFiltData_Callback(hObject, eventdata, handles)
% Add Object
data=getPluginFunction(handles,2);
data=feval(data.wrap,'getArgument',data);
if isempty(data),return;end
% Add Plugin Update
ud=get(handles.lbx_FiltData,'UserData');
if isempty(ud),
  ud.enable = true;
  ud.list   = {data};
else
  ud.enable(end+1) = true;
  ud.list{end+1}   = data;
end
set(handles.lbx_FiltData,'UserData',ud);

% List Box Update
redraw_lbx_FiltData(handles);

function psb_changeFiltData_Callback(h, ev, hs)
%
ud=get(hs.lbx_FiltData,'UserData');
vl  =get(hs.lbx_FiltData,'Value');
idx = ceil((vl-1)/2); % Index of List
tmp=feval(ud.list{idx}.wrap,'getArgument',ud.list{idx});
if isempty(tmp),return;end
ud.list{idx}=tmp;
set(hs.lbx_FiltData,'UserData',ud);
% List Box Update
redraw_lbx_FiltData(hs);

function psb_removeFiltData_Callback(h, ev, hs)
%
ud=get(hs.lbx_FiltData,'UserData');
vl  =get(hs.lbx_FiltData,'Value');
idx = ceil((vl-1)/2); % Index of List
if idx==0,
  errordlg('[E] Cannot Remove This Comment');
end
ud.list(idx)=[];ud.enable(idx)=[];
set(hs.lbx_FiltData,'UserData',ud);
redraw_lbx_FiltData(hs);

function lbx_FiltData_Callback(h, ev, hs)
% Do Nothing

function psb_upFiltData_Callback(h, ev, hs)
% Upbutton
ud=get(hs.lbx_FiltData,'UserData');
vl  =get(hs.lbx_FiltData,'Value');
idx = ceil((vl-1)/2); % Index of List
if idx>=2,
  tmplist        = ud.list{idx};
  ud.list{idx}   = ud.list{idx-1};
  ud.list{idx-1} = tmplist;
  
  tmpenable        = ud.enable(idx);
  ud.enable(idx)   = ud.enable(idx-1);
  ud.enable(idx-1) = tmpenable;
end  
set(hs.lbx_FiltData,'UserData',ud,'Value',vl-2);
redraw_lbx_FiltData(hs);

function psb_downFiltData_Callback(h, ev, hs)
% Down Button
ud=get(hs.lbx_FiltData,'UserData');
vl  =get(hs.lbx_FiltData,'Value');
idx = ceil((vl-1)/2); % Index of List
if idx<length(ud.list),
  tmplist        = ud.list{idx};
  ud.list{idx}   = ud.list{idx+1};
  ud.list{idx+1} = tmplist;
  
  tmpenable        = ud.enable(idx);
  ud.enable(idx)   = ud.enable(idx+1);
  ud.enable(idx+1) = tmpenable;
end  
set(hs.lbx_FiltData,'UserData',ud,'Value',vl+2);
redraw_lbx_FiltData(hs);

function psb_Suspend_Callback(h, ev, hs)
%
ud=get(hs.lbx_FiltData,'UserData');
vl  =get(hs.lbx_FiltData,'Value');
idx = ceil((vl-1)/2); % Index of List
ud.enable(idx)= ~ud.enable(idx);
set(hs.lbx_FiltData,'UserData',ud);
redraw_lbx_FiltData(hs);


function psb_saveFiltData_Callback(h, ev, hs)
%
ud=get(hs.lbx_FiltData,'UserData');
DataDef2_PreproPluginData('NewFilter',ud);

function psb_loadFilterData_Callback(hObject, eventdata, handles)
% Load Filter Data
ini_actdata = OSP_DATA('GET','ACTIVEDATA'); % swapping.
set(handles.figure1,'Visible','off');
try
  fs_h = uiFileSelect('DataDef',{'PreproPluginData'});
  waitfor(fs_h);
catch
  set(handles.figure1,'Visible','on');
  rethrow(lasterror);
end
set(handles.figure1,'Visible','on');
actdata = DataDef2_PreproPluginData('load');
set(hs.lbx_FiltData,'UserData',actdata.data);
OSP_DATA('SET','ACTIVEDATA',ini_actdata);
% Cancel Check
if isempty(actdata), return; end
%TODO


return;


function psb_HelpFiltData_Callback(h,e,hs)
%  Show Help by OspHelp
OspHelp(getPluginFunction(hs));

%========================================================
%  Make Mfile/Execute Evaluation
%========================================================
function fname=makemfile(h,e,hs,fname)
ud=get(hs.lbx_FiltData,'UserData');
if nargin<4,
  fname = fileparts(which('OSP'));
  fname0= [fname filesep 'ospData' filesep];
  fname = [fname0 'sd_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'sd_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
end
[fid,fname]=make_mfile('fopen',fname,'w');
try
  for idx=find(ud.enable)'
    ud.list{idx}=feval(ud.list{idx}.wrap,'getArgument',ud.list{idx});
    try
    catch
      make_mfile('with_indent','%error');
    end
  end
catch
  make_mfile('fclose');
  rethow(lasterr);
end
make_mfile('fclose');
return;

function make_tmp_pplugin(hs)
% Make Prepro Plugi function
ud=get(hs.lbx_FiltData,'UserData');

fname = fileparts(which(mfilename));
p=fileparts(fname);
fname = [p filesep 'tmp_pplugin.m'];
[fid,fname]=make_mfile('fopen',fname,'w');
make_mfile('with_indent','function [hdata,data]=tmp_pplugin(hdata,data)');
try
  if ~isempty(ud)
    for idx=find(ud.enable)'
      try
        str=feval(ud.list{idx}.wrap,'write',0,ud.list{idx});
        if ~isempty(str),
          make_mfile('with_indent',str);
        end
      catch
        make_mfile('with_indent','%error');
      end
    end
  end
catch
  make_mfile('fclose');
  rethrow(lasterr);
end
make_mfile('fclose');
%rehash TOOLBOX
rehash



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rename Options ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edt_script_Callback(hObject, eventdata, handles)
function pop_RenameOption_Callback(hObject, eventdata, handles)
set(hObject,'Visible','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View Change..
%  Meeting on 20-Apr-2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_gtgt_Callback(hObject, eventdata, handles)
set(hObject,'Visible','off');
p=get(handles.chk_anonymity,'Position');p(1)=p(1)+300;
set(handles.chk_anonymity,'Position',p);
p=get(handles.exec_strns_psb, 'Position');p(1)=p(1)+300;
set(handles.exec_strns_psb, 'Position',p);

p=get(handles.figure1,'Position');p(3)=590;
set(handles.figure1,'Position',p);

function psb_ltlt_Callback(hObject, eventdata, handles)
%
set(handles.psb_gtgt,'Visible','on');
p=get(handles.chk_anonymity,'Position');p(1)=p(1)-300;
set(handles.chk_anonymity,'Position',p);
p=get(handles.exec_strns_psb, 'Position');p(1)=p(1)-300;
set(handles.exec_strns_psb, 'Position',p);

p=get(handles.figure1,'Position');p(3)=295;
set(handles.figure1,'Position',p);

