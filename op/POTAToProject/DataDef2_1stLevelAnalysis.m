function varargout=DataDef2_1stLevelAnalysis(fnc,varargin)
% P3 1stLevelAnalysis-Data I/O Function.
%
%  1st-Level-Analysis Data have Many-Kind-of Search-Key.
%  So This Function is differente from ordinary "DataDef2" Function.
%
%
%--------------------------------------------------------------------
% Syntax :
%  Keys        = DataDef2_1stLevelAnalysis('getKeys')
%  [Keys, tag] = DataDef2_1stLevelAnalysis('getKeys')
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Keys  : Cell structure of Search Key of
%             1stLevelAnalysis-Data
%     tag   : Example of Search keys with
%             correspond to Keys
%
%  [id_fieldname] = DataDef2_1stLevelAnalysis('getIdentifierKey')
%     Field Name to identify Data.
%     This Value must be unique in Poject.
%
%--------------------------------------------------------------------
% Syntax :
%  [filelists]  = DataDef2_1stLevelAnalysis('loadlist')
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Load File List
%
%--------------------------------------------------------------------
% Syntax :
%  [info] = DataDef2_1stLevelAnalysis('showinfo',key)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%--------------------------------------------------------------------
% Syntax :
%  [header,data,SK] =  DataDef2_1stLevelAnalysis('load',key)
%  [header,data,SK] =  DataDef2_1stLevelAnalysis('load',key,innerkey)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Load Raw-Data from File
%     if there is no-key, Read Current Data in Current-Project.
%
%--------------------------------------------------------------------
% Syntax :
%  [filename] = DataDef2_1stLevelAnalysis('make_mfile',key)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12
%
%--------------------------------------------------------------------
% Syntax :
%  [filename] = DataDef2_1stLevelAnalysis('make_mfile_useblock',key)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     make_mfile : Use-Block
%     (To bug fix : Multi-Block : Use Blocking )
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12
%
%--------------------------------------------------------------------
% Syntax :
%  [header, data] = DataDef2_1stLevelAnalysis('make_ucdata',key)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      key : ( same as make_mfile )
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%--------------------------------------------------------------------
% Syntax :
%  [strHBdata, plot_kind] =
%          DataDef2_1stLevelAnalysis('make_timedata', key)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%      Make HBdata for plot, and using plot
%
%--------------------------------------------------------------------
% Syntax :
%  DataDef2_1stLevelAnalysis('save',header,data);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Save header, data.
%
%--------------------------------------------------------------------
% Syntax :
%  DataDef2_1stLevelAnalysis('save_ow',header,data);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Save Current Data -> Over-Write Mode
%
%--------------------------------------------------------------------
% Syntax :
%  DataDef2_1stLevelAnalysis('reshapeName',name)
%
%--------------------------------------------------------------------
% See also POTATO, DATADEF2_RAW.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% orignal author : Masanori Shoji
% create : 2005.01.20
% $Id: DataDef2_1stLevelAnalysis.m 293 2012-09-27 06:11:14Z Katura $

% Reversion 1.01
% Date : 19-Feb-2007
%  Import form DataDef2_Analysis.m and


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROGRAMING Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Relating File :
%   Data-List-File : (All-Files)
%
%---------------------------------------
% Cording Memo :
%   A. Total-Control   : Based-on DataDef2
%   B. Special-Control :
%---------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Launch Box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ======================
%  POTATo : Running Check
% ======================
if ~OSP_DATA('GET','isPOTAToRunning')
  errordlg({' POTATo is not runing!', ...
    '  please type "POTATo" at First!"'});
  return;
end

% ======================
% Launcher
% ======================
if nargin==0, fnc='help'; end

switch fnc,
  case 'save',
    fnc='saveFLA_Data';
  case 'make_mfile'
    fnc='make_mfile_FLA_Data';
  case 'help',
    OspHelp(mfilename)
  case 'load',
    fnc='load_FLA_Data';
end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definition Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key = Keys
% Definition of Search Keys,
% Warning : filename is  using in POTAToProject/preprocessor!
%           Do not rename, without changing POTAToProject/preprocessor.
key={'name','ID','localID','function','wrapper',...
  'filename','ID_number','measuremode','age','sex','date'};

function example_struct=searchexampl
% Definition of Example of Keys
example_struct  = struct( ...
  'name',        'test',...
  'ID',          '[1 4]', ...
  'localID',     '[1 4]', ...
  'function',    'flafnc_m',...
  'wrapper',     'PluginWrap_A',...
  'filename',    '^test(\w*).dat', ...
  'ID_number',   '_01$' ,...
  'measuremode', '0',...
  'age',         '[10 23]', ...
  'sex',         '''Female''',...
  'date',        '{''24-Jan-05'' datestr(now)}');

function id=IdentifierID
% Donot Change
id =1;                     % Identifier ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To Delete
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================
function nm=reshapeName(key)
% Return : Relation-File Variable Name
%   Relation Data
%=======================================
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
[path, dname, ext, ver] = fileparts(key);
nm = dname;
% s = regexp(nm(1),'[a-zA-Z]');
% if isempty(s),
%   nm = ['D' nm];
% end
nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');

nm = ['FLA_' nm];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteGroup(key)
% key : delete name of top data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
if isstruct(key)
  % To Ordinary Format.
  keys = Keys;
  key=eval(['key.' keys{IdentifierID} ';']);
end
dname = reshapeName(key);
if isempty(dname),
	error('lack name of DataDef2_1stLevelAnalysis.');
end
%===============================
%% Make Relation in the Project
%===============================
% -- Reset project:
% prjct  : Project
% refile : Relation File
%%[prjct, relfile] = resetPOTAToProject;
%% Modify 070316 
%%    (RelationFile is created  when 'save')
% -- Get RelationFile's name
relfile = getRelationFileName;
% -- Get Children list:
%    clist : Children of "dname"
clist = FileFunc('getChildren', relfile, dname);

% ------------------------------------------
% Throw Quesion : Confine to delete
% ------------------------------------------
% Use uigetpref?
dflag=OSP_DATA('GET','ConfineDeleteDataSV');
if isempty(dflag),dflag=true;end
if dflag,
    cname={'Can I Delete Following Data-List?'...
	 ' '...
	 ' 1stLevelAnalysis-Data Children List:'...
	 [ '      ' dname]};
    for i=1:length(clist),
      cname{end+1} = [ '      ' clist{i}];
    end
    btn = questdlg(cname, ...
		 'Delete Data',...
		 'Yes', 'No','Always', 'Yes');
    % if user selection is  "No", do nothing
    if strcmp(btn, 'No'), return; end
    if strcmp(btn, 'Always'),
      OSP_DATA('SET','ConfineDeleteDataSV',false);
    end
end

% -- Delete this key-file and this children's
% -- Delete own file ,too
clist{end+1}=dname;
load(relfile, 'Relation');
for i=1:length(clist),
	try
		% Load Relation of
		% Clist from 
		% Relation file(relfile)
		%load(relfile, clist{i});
		data = Relation.(clist{i}).data;
		fcn  = Relation.(clist{i}).fcn;
		feval(fcn, 'deleteData', data);
  catch
		% Error : Dialog
		errordlg(lasterr);
    return;
	end
end
% Update RelationFile
try
  FileFunc('clearParent', relfile, dname);
catch
  % Error : Dialog
  errordlg(lasterr);
end
return;

%=======================================
function deleteData(data)
% Delete 1stLevelAnalysis-Data, anyway
%   data :  delete data
%=======================================

%----------------------------
% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isempty(data),
  error('Cannot Open Empty 1stLevelAnalysis-Data.');
end
if 0,
  error('Unpopulated Bord');
end
%----------------------------
% Delete Data from list ;
%----------------------------
listfname = getDataListFileName;
if exist(listfname, 'file'),
  load(listfname, 'FLA_DataFileList')
  id=find(strcmp(eval(['{FLA_DataFileList.' getIdentifierKey '}']), ...
    data.(getIdentifierKey))==1);
  FLA_DataFileList(id)=[];
  % Save
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(listfname, 'FLA_DataFileList','-v6');
  else
    save(listfname, 'FLA_DataFileList');
  end
end

%----------------------------
% Delete Real-Data File
%----------------------------
delfname  = getDataFileName(data);
if exist(delfname, 'file'),
  delete(delfname);
end

%----------------------------
% Delete SearchKey
%----------------------------
fnc=data.function;
id =data.ID;
fname=DataDef2_1stLevelAnalysis('getLocalSearchKeyFileName',fnc);
load(fname,'SearchKey');
if isfield(SearchKey,'F')
  fk=fieldnames(SearchKey.F);
  for idx=1:length(fk)
    cid=eval(['SearchKey.F.' fk{idx} '.ID;']);
    for idx2=1:length(cid)
      cid{idx2}=setdiff(cid{idx2},id);
    end
    del=cellfun('isempty',cid);
    cid(del)=[];
    eval(['SearchKey.F.' fk{idx} '.ID=cid;']);
    eval(['SearchKey.F.' fk{idx} '.key(del)=[];']);
  end
end

if isfield(SearchKey,'I')
  ik=fieldnames(SearchKey.I);
  for idx=1:length(ik)
    cid=eval(['SearchKey.I.' ik{idx} '.ID;']);
    for idx2=1:length(cid)
      cid{idx2}=setdiff(cid{idx2},id);
    end
    del=cellfun('isempty',cid);
    cid(del)=[];
    eval(['SearchKey.I.' ik{idx} '.ID=cid;']);
    eval(['SearchKey.I.' ik{idx} '.key(del)=[];']);
  end
end

if rver >= 14,
  save(fname,'SearchKey','-v6');
else
  save(fname,'SearchKey');
end



return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function infoStr=showinfo(key)
% Show Information of 1stLevelAnalysis-Data
%  Syntax :
%   infoStr=showinfo(key);
%     key     : 1stLevelAnalysis-Data
%     infoStr : Cell String of Information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=====================
% Initiarize
%=====================
fileData=key;   % Here Set 1stLevelAnalysis Data
if ~isstruct(fileData) || isempty(fileData)
  infoStr={' === No Information =='};
  return;
end
infoStr={' -- 1st-Lvl-Ana File Info --'};

% Get Data
c = OspDataFileInfo(0,1,fileData);
try
  [infoStr{2:length(c)+1}]=deal(c{:});
catch
  infoStr={[mfilename ' : ' lasterr ]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FLA_DataFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Structure of Signal-Data :
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dfl=getDataListFileName;
if exist(dfl,'file')
  load(dfl,'FLA_DataFileList')
else
  % No 1stLevelAnalysis-Data FileList
  FLA_DataFileList={};
  return;
end

if ~exist('FLA_DataFileList','var') || ...
    isempty(FLA_DataFileList)
  % No Data : Exist
  FLA_DataFileList={};
  return;
end
keys = Keys;
iid = IdentifierID;
if nargin>=1 && ~isempty(keys),
  % Search Select Key
  c = struct2cell(FLA_DataFileList);
  f = fieldnames(FLA_DataFileList);
  c = squeeze(c(strcmp(f,keys{iid}),:,:));
  if isstruct(key)
    pos = find(strcmp(c,getfield(key,keys{iid})));
  else
    pos = find(strcmp(c,key));
  end
  FLA_DataFileList = FLA_DataFileList(pos);
  clear c f p pos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Keys2, se]=getKeys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Keys2 = Keys;
%Keys2{end+1}='CreateDate';
se = searchexampl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function keyname=getIdentifierKey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = Keys;
keyname=k{IdentifierID};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_FLA_Data(key,Innerkey,FLA_DataFileList)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------
% Load Data Check
% ---------------
if ~exist('key', 'var')
  error('No Input Key Exist');
end
if nargin<3
  dfl=getDataListFileName;     %<-- Data-List-File Name
  if exist(dfl,'file')
    load(dfl,'FLA_DataFileList');
  else
    error('No Data List Exist');
  end
end


if isstruct(key)
  key=key.name;
end

if isempty(FLA_DataFileList)
  error('No Data List Exist');
end

%=========================
% Make Local File Key
%=========================
namelist = {FLA_DataFileList.name};
a=find(strcmp(namelist,key));
fhdata=FLA_DataFileList(a(1));
fname0=getDataFileName(fhdata);
load(fname0,'fhdata','fdata');


%=========================
% Filter!
%=========================
if nargin>=2 && ~isempty(Innerkey)
  try
    [fhdata,fdata]=feval(fhdata.function,...
      'SelectInnerData',fhdata,fdata,Innerkey.Key,Innerkey.Val);
  catch
    disp('-------------------------------------');
    disp('In Selecting Inner Data : Error Occur');
    disp(['  Function : ' fhdata.function]);
    disp(lasterr);
    disp('-------------------------------------');
  end
end

%=========================
% Out put!
%=========================
if nargout>=1
  varargout{1}=fhdata;
end
if nargout>=2
  varargout{2}=fdata;
end

if nargout<3,return;end
% Special Key
mykey.dumy='';
if isfield(fhdata,'F')
  mykey.F =fhdata.F;
end
if isfield(fhdata,'I')
  mykey.I =fhdata.I;
end
varargout{3}=mykey;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveFLA_Data(fhdata,fdata)
% Save 1stLevelAnalysis-Data

% *************************************************************************
% Buffering Mode (2008.07.31)
% *************************************************************************
persistent bufmode;
persistent FLA_DataFileList;
persistent sk_data0;
persistent sk_filename0;
persistent sk_n;
if nargin==1
  if fhdata==0
    %---------------
    % Start Buffering
    %---------------
    bufmode=true;
    sk_n=0;
   
    dfl=getDataListFileName;     %<-- Data-List-File Name
    if exist(dfl,'file')
      load(dfl,'FLA_DataFileList');
    else
      FLA_DataFileList={};
    end
  elseif fhdata==1
    %---------------
    % Start Flush
    %---------------
    bufmode=false;
    
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    % Save List
    dfl=getDataListFileName;     %<-- Data-List-File Name
    if rver >= 14,
      save(dfl,'FLA_DataFileList','-v6');
    else
      save(dfl,'FLA_DataFileList');
    end
    % Save SearchKey
    if rver >= 14,
      for idx=1:sk_n
        SearchKey=sk_data0{idx}; %#ok
        save(sk_filename0{idx},'SearchKey','-v6');  
      end
    else
      for idx=1:sk_n
        SearchKey=sk_data0{idx}; %#ok
        save(sk_filename0{idx},'SearchKey');  
      end
    end
  else
    error('No Such Mode::');
  end
  return;
end
if ~isequal(bufmode,true)
  error('Not a Buffer-Mode');
end

% *************************************************************************
% Ordinary
% *************************************************************************
%=====================
% Check Argument
%=====================
msg=nargchk(2,2,nargin);
if msg,error(msg);end

%=====================
% Initialize
%=====================
% Getting POTATo Handles
h=OSP_DATA('GET','POTATOMAINHANDLE');
hs=guidata(h);

% Checking Save Mode ??
wk=get(hs.advpsb_1stLvlAna_Exe,'UserData');
if isempty(wk),return;end

%dfl=getDataListFileName;     %<-- Data-List-File Name

%=====================
% List-File Update!
%=====================
%---------------------------
% Choise (Basic-Header Data)
%---------------------------
fhdata_tmp.name        = fhdata.name;
fhdata_tmp.ID          = fhdata.ID;
fhdata_tmp.localID     = fhdata.localID;
fhdata_tmp.function    = fhdata.function;
fhdata_tmp.wrapper     = fhdata.wrapper;
fhdata_tmp.filename    = fhdata.filename;
fhdata_tmp.ID_number   = fhdata.ID_number;
fhdata_tmp.measuremode = fhdata.measuremode;
fhdata_tmp.age         = fhdata.age;
fhdata_tmp.sex         = fhdata.sex;
fhdata_tmp.date        = fhdata.date;

%----------------------------
% Load Current Data List
%----------------------------
%if exist(dfl,'file')
%  load(dfl,'FLA_DataFileList');
%end
% => Data List <=
if exist('FLA_DataFileList','var')
  datalist=FLA_DataFileList; %#ok<NODEF>
else
  datalist={};
end

%----------------------------
% Interpretation
%----------------------------
if ~isempty(datalist)
  namelist = {datalist.name};
  lastID   = datalist(end).ID;
  fnclist  = datalist(strcmpi({datalist.function},fhdata.function));
  if isempty(fnclist)
    lastLID  = 0;
  else
    lastLID  = fnclist(end).localID;
  end
else
  % New Data
  namelist = {};
  lastID   = 0;
  lastLID  = 0;
end
fhdata_tmp.ID          = lastID  + 1;
fhdata_tmp.localID     = lastLID + 1;
fhdata.ID              = fhdata_tmp.ID;     
fhdata.localID         = fhdata_tmp.localID;

%-----------------------------
% Name Update! ==> 
%-----------------------------
rnopts=get(hs.advpop_1stLvlAna_Rename,'String');
opt=rnopts{get(hs.advpop_1stLvlAna_Rename,'Value')};
switch lower(opt)
  case 'inputname'
    name0=get(hs.advedt_1stLvlAna_Rename,'String');
  case 'date'
    name0 = ['Date_' datestr(now,1)];
  case 'id'
    a=fhdata_tmp.ID_number;
    if iscell(a),a=char(a);end
    name0 = ['ID_' a];
  otherwise
    %case 'follows plugin',
    if ~strcmpi(opt,'follows plugin'),
      disp(C__FILE__LINE__CHAR);
      disp('Un-Defined Input Rename Option : %s',opt);
    end
    name0 = fhdata_tmp.name;
    if isempty(name0),
      name0='Untitled';
    end
end % Rename OPT Switch

s=regexpi(namelist,['^' name0 '(_[0-9]+)?$']);
if ~iscell(s) && ~isempty(s), s={s};end % for Before R14.
if ~isempty(s) && ~all(cellfun('isempty',s))
  tmp=char(namelist(~cellfun('isempty',s)));
  % Rename by +ID
  if size(tmp,2)>length(name0),
    rnid=str2num(tmp(:,length(name0)+2:end));
    rnid=max(rnid(:))+1;
  else
    rnid=1;
  end
  name0=sprintf('%s_%d',name0,rnid);
end
fhdata_tmp.name= name0;
fhdata.name    = name0;

%------------------------
% Add List to New FHDATA(Basic)
%------------------------
if ~isempty(datalist)
  datalist(end+1) = struct_merge0(datalist(1),fhdata_tmp,2);
else
  % New Data
  datalist = fhdata_tmp;
end

%-------------------------------------
% get Save File Name & Rename Variable
%-------------------------------------
FLA_DataFileList = datalist; %<-- Save Data (List0)
clear datalist;

%=========================
% Make Local File Key
%=========================
% Load Local-SearchKey File
key.key={};key.ID={}; % Default Key
fname=getLocalSearchKeyFileName(fhdata.function);
sk_id=find(strcmpi(fname,sk_filename0(1:sk_n)));
if isempty(sk_id)
  sk_n=sk_n+1;
  sk_id=sk_n;sk_filename0{sk_n}=fname;
  if exist(fname,'file'),
    load(fname,'SearchKey');
  else
    SearchKey.F.measuremode = key;
    SearchKey.F.age         = key;
    SearchKey.F.sex         = key;
    %SearchKey.F.date        = key;
    %SearchKey.F.timelen     = key;
    SearchKey.F.chlen       = key;
    %SearchKey.F.kindlen     = key;
    %SearchKey.F.DataTag     = key;
    SearchKey.F.FilterData  = key;
    % Add Special Key (File)
    if isfield(fhdata,'F')
      fs=fieldnames(fhdata.F);
      for idx=1:length(fs)
        if strcmpi(fs,'dumy'),continue;end
        str=sprintf('SearchKey.F.%s=key;',fs{idx});
        eval(str);
      end
    end
    % Add Special Key (Inner)
    if isfield(fhdata,'I')
      fs=fieldnames(fhdata.I);
      for idx=1:length(fs)
        if strcmpi(fs,'dumy'),continue;end
        str=sprintf('SearchKey.I.%s=key;',fs{idx});
        eval(str);
      end
    end
  end
else
  % Load from buffer
  SearchKey=sk_data0{sk_id};
end

% Special Key
%fks=feval(fhdata.function,'filekey');
%fki=feval(fhdata.function,'innerkey');


%------------------------
% Add Special Key (File)
%------------------------
mykey=fhdata;
if isfield(fhdata,'F')
  fs=union(fieldnames(fhdata.F),{'FLA_Timestamp'});
else
  fs={'FLA_Timestamp'};
end

for idx=1:length(fs)
  if strcmpi(fs{idx},'dumy'),continue;end
  if strcmp(fs{idx},'FLA_Timestamp')
    mykey.FLA_Timestamp=getappdata(hs.figure1,'FastLevelAna_StartTime');
  else
    mykey.(fs{idx})=fhdata.F.(fs{idx});
  end
  % Add new Key
  if ~isfield(SearchKey.F,fs{idx})
    SearchKey.F.(fs{idx}) = key;
  end
end
SearchKey.F=addkey(SearchKey.F,mykey);
clear mykey;

%------------------------
% Add Special Key (Inner)
%------------------------
if isfield(SearchKey,'I')
  mykey=fhdata.I;
  mykey.ID=fhdata.ID;
  fs=fieldnames(mykey);
  % Add new Key
  for idx=1:length(fs)
    if ~isfield(SearchKey.I,fs{idx})
      SearchKey.I.(fs{idx}) = key;
    end
  end
  SearchKey.I=addkey(SearchKey.I,mykey);
end
clear mykey;

%------------------------
% Need Reset
%------------------------
% TODO:

% Save Files

%=========================
% File Search-Key 
%=========================
% Save File
fname0=getDataFileName(fhdata);

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  %save(dfl,'FLA_DataFileList','-v6');
  %save(fname,'SearchKey','-v6');
  save(fname0,'fhdata','fdata','-v6');
else
  %save(dfl,'FLA_DataFileList');
  %save(fname,'SearchKey');
  save(fname0,'fhdata','fdata');
end
sk_data0{sk_id}=SearchKey;
% Create RelationFile
addRelation_buf(fhdata);



%=========================
% Affter update....
%=========================
% Loging
P3_AdvTgl_status('Logging',hs,...
  [' --> FLA : Save named ''' fhdata.name '''']);
return;


function saveFLA_Data_old(fhdata,fdata)
% Save 1stLevelAnalysis-Data
%=====================
% Check Argument
%=====================
msg=nargchk(1,2,nargin);
if msg,error(msg);end

%=====================
% Initialize
%=====================
% Getting POTATo Handles
h=OSP_DATA('GET','POTATOMAINHANDLE');
hs=guidata(h);

% Checking Save Mode ??
wk=get(hs.advpsb_1stLvlAna_Exe,'UserData');
if isempty(wk),return;end

dfl=getDataListFileName;     %<-- Data-List-File Name

%=====================
% List-File Update!
%=====================
%---------------------------
% Choise (Basic-Header Data)
%---------------------------
fhdata_tmp.name        = fhdata.name;
fhdata_tmp.ID          = fhdata.ID;
fhdata_tmp.localID     = fhdata.localID;
fhdata_tmp.function    = fhdata.function;
fhdata_tmp.wrapper     = fhdata.wrapper;
fhdata_tmp.filename    = fhdata.filename;
fhdata_tmp.ID_number   = fhdata.ID_number;
fhdata_tmp.measuremode = fhdata.measuremode;
fhdata_tmp.age         = fhdata.age;
fhdata_tmp.sex         = fhdata.sex;
fhdata_tmp.date        = fhdata.date;

%----------------------------
% Load Current Data List
%----------------------------
if exist(dfl,'file')
  load(dfl,'FLA_DataFileList');
end
% => Data List <=
if exist('FLA_DataFileList','var')
  datalist=FLA_DataFileList; %#ok<NODEF>
else
  datalist={};
end

%----------------------------
% Interpretation
%----------------------------
if ~isempty(datalist)
  namelist = {datalist.name};
  lastID   = datalist(end).ID;
  fnclist  = datalist(strcmpi({datalist.function},fhdata.function));
  if isempty(fnclist)
    lastLID  = 0;
  else
    lastLID  = fnclist(end).localID;
  end
else
  % New Data
  namelist = {};
  lastID   = 0;
  lastLID  = 0;
end
fhdata_tmp.ID          = lastID  + 1;
fhdata_tmp.localID     = lastLID + 1;
fhdata.ID              = fhdata_tmp.ID;     
fhdata.localID         = fhdata_tmp.localID;

%-----------------------------
% Name Update! ==> 
%-----------------------------
rnopts=get(hs.advpop_1stLvlAna_Rename,'String');
opt=rnopts{get(hs.advpop_1stLvlAna_Rename,'Value')};
switch lower(opt)
  case 'inputname'
    name0=get(hs.advedt_1stLvlAna_Rename,'String');
  case 'date'
    name0 = ['Date_' datestr(now,1)];
  case 'id'
    a=fhdata_tmp.ID_number;
    if iscell(a),a=char(a);end
    name0 = ['ID_' a];
  otherwise
    %case 'follows plugin',
    if ~strcmpi(opt,'follows plugin'),
      disp(C__FILE__LINE__CHAR);
      disp('Un-Defined Input Rename Option : %s',opt);
    end
    name0 = fhdata_tmp.name;
    if isempty(name0),
      name0='Untitled';
    end
end % Rename OPT Switch

s=regexpi(namelist,['^' name0 '(_[0-9]+)?$']);
if ~iscell(s) && ~isempty(s), s={s};end % for Before R14.
if ~isempty(s) && ~all(cellfun('isempty',s))
  tmp=char(namelist(~cellfun('isempty',s)));
  % Rename by +ID
  if size(tmp,2)>length(name0),
    rnid=str2num(tmp(:,length(name0)+2:end));
    rnid=max(rnid(:))+1;
  else
    rnid=1;
  end
  name0=sprintf('%s_%d',name0,rnid);
end
fhdata_tmp.name= name0;
fhdata.name    = name0;

%------------------------
% Add List to New FHDATA(Basic)
%------------------------
if ~isempty(datalist)
  datalist(end+1) = struct_merge0(datalist(1),fhdata_tmp,2);
else
  % New Data
  datalist = fhdata_tmp;
end

%-------------------------------------
% get Save File Name & Rename Variable
%-------------------------------------
FLA_DataFileList = datalist; %<-- Save Data (List0)
clear datalist;

%=========================
% Make Local File Key
%=========================
% Load Local-SearchKey File
fname=getLocalSearchKeyFileName(fhdata.function);
% Special Key
%fks=feval(fhdata.function,'filekey');
%fki=feval(fhdata.function,'innerkey');

key.key={};key.ID={}; % Default Key
if exist(fname,'file'),
  load(fname,'SearchKey');
else
  SearchKey.F.measuremode = key;
  SearchKey.F.age         = key;
  SearchKey.F.sex         = key;
  %SearchKey.F.date        = key;
  %SearchKey.F.timelen     = key;
  SearchKey.F.chlen       = key;
  %SearchKey.F.kindlen     = key;
  %SearchKey.F.DataTag     = key;
  SearchKey.F.FilterData  = key;
  % Add Special Key (File)
  if isfield(fhdata,'F')
    fs=fieldnames(fhdata.F);
    for idx=1:length(fs)
      if strcmpi(fs,'dumy'),continue;end
      str=sprintf('SearchKey.F.%s=key;',fs{idx});
      eval(str);
    end
  end
  % Add Special Key (Inner)
  if isfield(fhdata,'I')
    fs=fieldnames(fhdata.I);
    for idx=1:length(fs)
      if strcmpi(fs,'dumy'),continue;end
      str=sprintf('SearchKey.I.%s=key;',fs{idx});
      eval(str);
    end
  end
end

%------------------------
% Add Special Key (File)
%------------------------
mykey=fhdata;
if isfield(fhdata,'F')
  fs=union(fieldnames(fhdata.F),{'FLA_Timestamp'});
else
  fs={'FLA_Timestamp'};
end

for idx=1:length(fs)
  if strcmpi(fs{idx},'dumy'),continue;end
  if strcmp(fs{idx},'FLA_Timestamp')
    mykey.FLA_Timestamp=getappdata(hs.figure1,'FastLevelAna_StartTime');
  else
    mykey.(fs{idx})=fhdata.F.(fs{idx});
  end
  % Add new Key
  if ~isfield(SearchKey.F,fs{idx})
    SearchKey.F.(fs{idx}) = key;
  end
end
SearchKey.F=addkey(SearchKey.F,mykey);
clear mykey;

%------------------------
% Add Special Key (Inner)
%------------------------
if isfield(SearchKey,'I')
  mykey=fhdata.I;
  mykey.ID=fhdata.ID;
  fs=fieldnames(mykey);
  % Add new Key
  for idx=1:length(fs)
    if ~isfield(SearchKey.I,fs{idx})
      SearchKey.I.(fs{idx}) = key;
    end
  end
  SearchKey.I=addkey(SearchKey.I,mykey);
end
clear mykey;

%------------------------
% Need Reset
%------------------------
% TODO:

% Save Files

%=========================
% File Search-Key 
%=========================
% Save File
fname0=getDataFileName(fhdata);

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'FLA_DataFileList','-v6');
  save(fname,'SearchKey','-v6');
  save(fname0,'fhdata','fdata','-v6');
else
  save(dfl,'FLA_DataFileList');
  save(fname,'SearchKey');
  save(fname0,'fhdata','fdata');
end
% Create RelationFile
addRelation_buf(fhdata);

%=========================
% Affter update....
%=========================
% Loging
P3_AdvTgl_status('Logging',hs,...
  [' --> FLA : Save named ''' fhdata.name '''']);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow(varargin)
% Save 1stLevelAnalysis-Data Over Wirte
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error('Can not Over-Write!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_FLA_Data(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1,
  error('Unpopulated Bord');
end
if isfield(key,'actdata'),
  if isfield(key,'fname'),
    % Make M-file With Filter Manage Data
    %   & File-Name
    varargout{1} = make_mfile_local(key.actdata.data, ...
      key.filterManage, ...
      key.fname);
  else
    % Make M-file With Filter Manage Data
    varargout{1} = make_mfile_local(key.actdata.data, key.filterManage);
  end
else
  % Make M-file : Default
  varargout{1} = make_mfile_local(key);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=getFilename(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1,
  error('Unpopulated Bord');
end
if ischar(key),
  key2.filename=key;
else
  key2 = key;
end
nm=getDataFileName(key2);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataListFileName
%  Get Data List File Name of
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' Open Project at First!');
  error(' Open Project at First!');
end

path0 =OSP_DATA('GET','PROJECTPARENT');
if ~strcmpi(path0,pj.Path),
  warning('Project Data might be broken');
end

% connect : OspProject rm_subjectname
%fname = [pj.Path ...
fname = [path0 ...
  filesep pj.Name ...
  ... %OSP_DATA('GET','PROJECT_DATA_DIR') ...
  filesep 'DataListFLA_Data.mat'];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataFileName(data)
%  Get Data File Name of
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name Setting  : --> See save
dfl=getDataListFileName;
p0 = fileparts(dfl); % get save path

% connect : OspProject rm_subjectname
fname = ['FLA_' data.name '.mat'];
fname=[p0 filesep fname];
return;

function fname=getLocalSearchKeyFileName(fnc)
% Get Function specific Search-Key-File name
dfl=getDataListFileName;
p0 = fileparts(dfl); % get save path
% connect : OspProject rm_subjectname
fname = ['FLASKF_' fnc '.mat'];
fname=[p0 filesep fname];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(anadata, filterdata, fname)
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================
%% Check Argument
%======================
% == Load  1stLevelAnalysis Data ==
if ~isfield(anadata,'data')
  anadata = load_FLA_Data(anadata);
end
if isempty(anadata.data),
  error('\n POTATo Error!!\n<< No-Data to Filter in the 1stLevelAnalysis-Data >>\n');
end

% Change Filter Data (if there)
if nargin>=2,
  anadata.data.filterdata=filterdata;
end

% get File Name
if nargin<3,
  fname = fileparts(which('OSP'));
  fname0 = [fname filesep 'ospData' filesep];
  fname = [fname0 'fla_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'fla_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
end

%% Make Mfile
%=====================
% Open M-File
%=====================
[fid, fname] = make_mfile('fopen', fname,'w');

%=====================
% Make Mfile
%=====================
try
  % ? Can I use GD2MF ?
  GroupData2Mfile(anadata);
catch
  make_mfile('fclose');
  rethrow(lasterror);
end

%=====================
% Close M-File
%=====================
make_mfile('fclose');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Addvance Key for 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function skey=addkey(skey,fhdata)
% Addkey
fn=fieldnames(skey);
for idx=1:length(fn)
  if ~isfield(fhdata,fn{idx}),
    disp(C__FILE__LINE__CHAR);
    disp(['Undifiend Key : ' fn{idx}]);
    continue;
  end
  getval = sprintf('val=fhdata.%s;',fn{idx});
  getkey = sprintf('key=skey.%s;',fn{idx});
  setkey = sprintf('skey.%s=key;',fn{idx});
  eval(getval);
  if ischar(val),val={val};end
  for i2=1:length(val)
    % Make Default Value (key.key)
    if iscell(val),
      val0 = val{i2};
    else
      val0 = val(i2);
    end
    
    % Update key!
    eval(getkey);
    vals=key.key;
    setflag=false;
    for i1=1:length(vals)
      if isequal(vals{i1},val0)
        % Set Current Key;
        key.ID{i1}=[key.ID{i1},fhdata.ID];
        setflag=true;
        break;
      end
    end  % end vals-loop (key.key loop)
    
    % if now key : Make New Key
    if ~setflag
      key.key{end+1}=val0;
      key.ID{end+1} =fhdata.ID;
    end
    eval(setkey);

  end % end val loop
end % end Field(Key) Loop



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  addRelation(dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Relation-File when Save OSP 1stLevelAnalysis - Data.
%   Data Version 2.5 
%
% This Function is Added ::
%              since reversion 1.4
% Get Data-File's name
name0=getDataFileName(dt);

if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(dt.name);  % 'FLA_*'
  snm.name=nm;
  snm.data.(getIdentifierKey)=dt.(getIdentifierKey);
  snm.data.function=dt.function;
  snm.data.ID=dt.function;
  snm.fcn=mfilename;
  snm.Parent={};
  snm.Children={};
  
  % Get Parent-Raw-Data
	% Get RelationData-File's name, Relation-Data
	fname = getRelationFileName;
  load(fname,'Relation');
  if ~exist('Relation','var'), Relation=struct([]);end
  if iscell(dt.RawDataFileName),
	  for idx2=1:length(dt.RawDataFileName),
      nm2 =DataDef2_RawData('reshapeName2',dt.RawDataFileName);
      if isfield(Relation,nm2)
        % Add Relation
        snm.Parent{end+1}=nm2;
        Relation.(nm2).Children{end+1}=nm;
      else
        % No Data Exist ---> Delete This Data::
        error('Los Corresponding Raw-Data.');
      end
		end
  else
		nm2 =DataDef2_RawData('reshapeName2',dt.RawDataFileName);
    if isfield(Relation,nm2)
      % Add Relation
      snm.Parent{end+1}=nm2;
      Relation.(nm2).Children{end+1}=nm;
    else
		  % No Data Exist ---> Delete This Data::
      error('Lost Corresponding Raw-Data.');
    end  
  end

  % -- Save  to Relation.mat
  Relation.(nm)=snm;
  FileFunc('saveRelation',Relation);
else
	 % file is not exist
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  addRelation_buf(dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addRelation for Buffering Mode
name0=getDataFileName(dt);

if ~exist(name0,'file'), return; end

% File Exist Make Relation Data
nm=reshapeName(dt.name);  % 'FLA_*'
snm.name=nm;
snm.data.(getIdentifierKey)=dt.(getIdentifierKey);
snm.data.function=dt.function;
snm.data.ID=dt.function;
snm.fcn=mfilename;
snm.Parent={};
snm.Children={};

% Get Parent-Raw-Data
% Get RelationData-File's name, Relation-Data
bufnames={};
bufvals ={};
if iscell(dt.RawDataFileName),
  for idx2=1:length(dt.RawDataFileName),
    nm2 =DataDef2_RawData('reshapeName2',dt.RawDataFileName);
    % Add Relation
    snm.Parent{end+1}=nm2;
    bufnames{end+1}=nm2;
    bufvals{end+1}=struct('Children',{nm});
    %Relation.(nm2).Children{end+1}=nm;
  end
else
  nm2 =DataDef2_RawData('reshapeName2',dt.RawDataFileName);
  % Add Relation
  snm.Parent{end+1}=nm2;
  bufnames{end+1}=nm2;
  bufvals{end+1}=struct('Children',{nm});
end

% -- Save  to Relation.mat
bufnames{end+1}=nm;
bufvals{end+1} =snm;
FileFunc('StreamRelation',bufnames,bufvals);
%Relation.(nm)=snm;
%FileFunc('saveRelation',Relation);


%=======================================
function nm2=reshapeName2(name)
% RawDatFileName ('RAW_*') ->RawDataName
%   Relation Data
%=======================================
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
[p, nm2] = fileparts(name);  
s=findstr(nm2, '.');
if ~isempty(s),nm2=nm2(1:s(1)-1);end
return;

%==========================================================================
function UpdateDataKey(FLA_DataFileList) %#ok
% Update Data-Key List
%==========================================================================
dfl=getDataListFileName;
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'FLA_DataFileList','-v6');
else
  save(dfl,'FLA_DataFileList');
end

