function varargout=DataDef2_2ndLevelAnalysis(fnc,varargin)
% POTATo's Analysis-Data I/O Function.
%
%  Keys = DataDef2_Analysis('getKeys')
%     return 
%
%  [Keys, tag] = DataDef2_Analysis('getKeys')
%     Keys  : Cell structure of Search Key of 
%             Analysis-Data
%     tag   : Example of Search keys with 
%             correspond to Keys
%
%  [id_fieldname] = DataDef2_Analysis('getIdentifierKey')
%     Field Name to identify Data.
%     This Value must be unique in Poject.
%
%
%  [filelists]  = DataDef2_Analysis('loadlist')
%     Load File List
%
%
%  [info] = DataDef2_Analysis('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%  [header,data,ver] =  DataDef2_Analysis('load')
%  [header,data,ver] =  DataDef2_Analysis('load',key)
%     Load Raw-Data from File
%     if there is no-key, Read Current Data in Current-Project.
%
%  [filename] = DataDef2_Analysis('make_mfile',key)
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12
%
%  [filename] = DataDef2_Analysis('make_mfile_useblock',key)
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
%  [header, data] = DataDef2_Analysis('make_ucdata',key)
%      key : ( same as make_mfile )
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%  [strHBdata, plot_kind] =
%          DataDef2_Analysis('make_timedata', key)
%      Make HBdata for plot, and using plot
%
%  DataDef2_Analysis('save')
%     Save Current Data
%  DataDef2_Analysis('save',header,data,OSP_SP_DATA_VER);
%     Save header, data as OSP_SP_VER
%
%  DataDef2_Analysis('save_ow',header,data,OSP_SP_DATA_VER,actdata)
%     Save Current Data -> Over-Write Mode
%
%  DataDef2_Analysis('reshapeName',name)


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2005.01.20
% $Id: DataDef2_2ndLevelAnalysis.m 398 2014-03-31 04:36:46Z katura7pro $

% Reversion 1.01
% Date : 11-Dec-2006
%  Import form DataDef2_Raw.m and
%              DataDef_GroupData.m

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
    fnc='saveAnalysisData';
  case 'make_mfile'
    fnc='make_mfile_AnalysisData';
  case 'help',
    OspHelp(mfilename);
  case 'load',
    fnc='load_AnalysisData';
end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end
return;

% ======================
% Definition Function
% ======================
function key = Keys
% Definition of Search Keys,
% Warning : filename is  using in POTAToProject/preprocessor!
%           Do not rename, without changing POTAToProject/preprocessor.
key={'Name','Date','ID_number','Comment'};

function example_struct=searchexampl
% Definition of Example of Keys
%--> for uiFileSelect
%   (Never run in this version.)
example_struct  = struct(...
	'Name',     '^test(\w*).dat', ...
	'Date',        '{''24-Jan-05'' datestr(now)}', ...
  'Comment',     'Calculation', ...
	'ID_number',   '_01$');

function id=IdentifierID
% Indentifiler is key{1} == Name
id =1;                     % Identifier ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete / Control Relation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================================
function nm=reshapeName(key)
% Return : Relation-File Variable Name
%   Relation Data
%================================
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
[p, dname] = fileparts(key);
nm = dname;
s = regexp(nm(1),'[a-zA-Z]');
if isempty(s),
  nm = ['D' nm];
end
nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');
nm = ['SLA_' nm];
return;

%================================
function deleteGroup(key)
% key : delete name of top data
%================================

%==================
% Argument Check
%==================
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isstruct(key)
  % To Ordinary Format.
  keys = Keys;
  key=eval(['key.' keys{IdentifierID} ';']);
end
% --> input data : key.Name
dname = reshapeName(key);

if isempty(dname),
  error('Name of 2nd-Lvl-Ana is empty.');
end

%===============================
% Make Relation in the Project
%===============================
% Get Relation File
relfile = getRelationFileName;
%    clist : Children of "dname"
clist = FileFunc('getChildren', relfile, dname);

% ==========================================
% Throw Quesion : Confine to delete
%   (with uigetpref )
% ==========================================
% Flag :: Use uigetpref?
dflag=OSP_DATA('GET','ConfineDeleteDataSV');
if isempty(dflag),dflag=true;end
if dflag,
  cname={'Can I Delete Following Data-List?'...
    ' '...
    ' Delete-Data List:'...
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

% ==========================================
% Delete key-file and children's
% ==========================================
clist{end+1}=dname;
load(relfile, 'Relation');
for i=1:length(clist),
  try
    % Load Relation of
    % Clist from
    % Relation file(relfile)
		data = Relation.(clist{i}).data;
		fcn  = Relation.(clist{i}).fcn;    
    feval(fcn, 'deleteData', data);
  catch
    % Error : Dialog
    errordlg(lasterr);
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

%===============================
function deleteData(data)
% Delete Analysis-Data, anyway
%   data :  delete data
%===============================

%----------------------------
% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isempty(data),
  error('Cannot Open Empty Analysis-Data.');
end

%----------------------------
% Delete Data from list ;
%----------------------------
listfname = getDataListFileName;
if exist(listfname, 'file'),
  load(listfname, 'AnalysisDataFileList')
  bdata=find(strcmp({AnalysisDataFileList.Name}, ...
    data.Name)==1);
  AnalysisDataFileList(bdata)=[];
  % Save
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(listfname, 'AnalysisDataFileList','-v6');
  else
    save(listfname, 'AnalysisDataFileList');
  end
end

%----------------------------
% Delete Real-Data File
%----------------------------
delfname  = getDataFileName(data);
if exist(delfname, 'file'),
  delete(delfname);
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  addRelation(dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Relation-File when Save OSP Analysis - Data.
%   Data Version 2.5 
%
% This Function is Added ::
%              since reversion 1.2
% Get Data-File's name
name0=getDataFileName(dt);
if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(dt.Name);  % 'SLA_*'
  snm.name=nm;
  snm.data.Name=dt.Name;
  snm.fcn=mfilename;
  snm.Parent={};
  snm.Children={};
  
  nm2s={};
  % Get Parent-Raw-Data  
	% Get RelationData-File's name, Relation-Data
	fname = getRelationFileName;
  load(fname,'Relation'); %load(fname);
  if ~exist('Relation','var'), Relation=struct([]);end
	for gid=1:length(dt.data.Group),
    tmp0=dt.data.Group{gid}.groups;
    if ~isfield(tmp0,'Files'),continue;end
    for idx0=1:length(tmp0),
      tmp=tmp0(idx0);
      for idx=1:length(tmp.Files)
        nm2=DataDef2_1stLevelAnalysis(...
          'reshapeName',tmp.Files(idx).name);
        if isfield(Relation,nm2)
          % Add Relation
          snm.Parent{end+1}=nm2;
          Relation.(nm2).Children{end+1}=nm;
        else
          % No Data Exist ---> Delete This Data::
          warning('--> Broken 1st-Lvl-Ana Relation.');
        end
      end
    end
  end
  % -- Save  to Relation.mat
  Relation.(nm)=snm;
  FileFunc('saveRelation',Relation);  
else
  % file is not exist
  error('Data Save Error');
end

%=============================
function infoStr=showinfo(key)
% Show Information of Analysis-Data
%  Syntax : 
%   infoStr=showinfo(key);
%     key     : Analysis-Data
%     infoStr : Cell String of Information.
%=============================

%=====================
% Initiarize
%=====================
fileData=key;   % Here Set Analysis Data
if ~isstruct(fileData) || isempty(fileData)
  infoStr={' === No Information =='};
  return;
end
infoStr={' -- 2nd-Lvl-Ana File Info --'};

%% Get Data
c = OspDataFileInfo(0,1,fileData);
try
  [infoStr{2:length(c)+1}]=deal(c{:});
catch
  infoStr={[mfilename ' : ' lasterr ]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AnalysisDataFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Structure of Signal-Data :
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dfl=getDataListFileName;
if exist(dfl,'file')
  load(dfl,'AnalysisDataFileList')
else
  % No Analysis-Data FileList
  AnalysisDataFileList={};
  return;
end

if ~exist('AnalysisDataFileList','var') || ...
    isempty(AnalysisDataFileList)
  % No Data : Exist
  AnalysisDataFileList={};
  return;
end
keys = Keys;
iid = IdentifierID;
if nargin>=1 && ~isempty(keys),
  % Search Select Key
  c = struct2cell(AnalysisDataFileList);
  f = fieldnames(AnalysisDataFileList);
  c = squeeze(c(strcmp(f,keys{iid}),:,:));
  if isstruct(key)
    pos = find(strcmp(c,getfield(key,keys{iid})));
  else
    pos = find(strcmp(c,key));
  end
  AnalysisDataFileList = AnalysisDataFileList(pos);
  clear c f p pos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Keys2, se]=getKeys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Keys2 = Keys;
Keys2{end+1}='CreateDate';
se = searchexampl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function keyname=getIdentifierKey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = Keys;
keyname=k{IdentifierID};

function adata=NewData(varargin)
% Make New 2nd-Level-Analys Data
%  since : 2007.03.17
if length(varargin)>0
  disp(C__FILE__LINE__CHAR);
  disp('Too many Input Data for New 2nd-Lvel-Ana');
end
%-------------------
% Initialize
%-------------------
keys=Keys;
adata=[]; % Default : empty == cancel
data.data.ANALISE_STATUS = 0; % Non Analyse
data.data.Function       = ''; % Default is empty.
data.data.Group          = {}; % Group's for Analysis
data.data.Result         = {}; % Result

% --------------------
% Making Input Dialog
% --------------------
prompt={'Name','ID_number','Comment'};
% Making Default Value
def={'Untitled','1',''};

% ------------------
% Run Input Dialog
% ------------------
flg=true;
while flg
  def = inputdlg(prompt,'2nd-Lvl-Ana Setting',1,def);
  % Cancel?
  if isempty(def),return;end
  
  % Setting Data
  for ii=1:length(keys)
    switch keys{ii},
      case 'Name',
        data.Name=def{1};
      case 'ID_number'
        data.ID_number=str2double(def{2});
      case 'Comment',
        data.Comment  = def{3};
      case 'Date',
        date.Date     = now;
      otherwise
        error('Program Error : Missmutch Keys')
    end
  end
  
  % ==> Saving
  try
    saveAnalysisData(data);
    flg=false;
  catch
    % Same Name?
    h=helpdlg(lasterr,'Error on saving');
    waitfor(h);
  end
end

% --> Output Setting
adata=data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_AnalysisData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See also save

% ---------------
% Load Data Check
% ---------------
if ~exist('key', 'var')
  actdata = OSP_DATA('GET','ACTIVEDATA');
  if isempty(actdata )
    OSP_LOG('perr','No ''Active Data'' exist');
    error('No ''Active Data'' exist');
  end
  key = actdata.data;
else
  % Active Data Check
  if ~isfield(key,'filename') && ...
      isfield(key,'data')
    key=key.data;
  end
end

%% Get File Name
fname=getDataFileName(key);

%% File check
if ~exist(fname,'file'),
  % Error No Data File exist:
  deleteData(key);
  OSP_LOG('perr', ...
    [ ' In Loading Data, File (' fname ') not exist']);
  error([' File Lost : ' fname]);
end

% ---------------
%% Load Data
% ---------------
load(fname,'AnalysisData');

% TODO : Data Check
% TODO : Additional Infroamtion
%        (Old : Blocking..)

varargout{1}=AnalysisData;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveAnalysisData(key)
% Save Analysis-Data
%
% See also otsigtrnschld

%=====================
%% Check Argument
%=====================
if ~exist('key','var')
  error('No Data to save.');
end
%---------------
% Make Save Data
%---------------
data = key;
data_tmp = rmfield(data,'data');	
	
%==========================
%% Modify List File
%==========================
%---------------
% Load List Data
%---------------
datalist = loadlist;
if ~isempty(datalist)
  keys = Keys;
  c = struct2cell(datalist);
  f = fieldnames(datalist);
  c = squeeze(c(strcmp(f,keys{IdentifierID}),:,:));
  % if exist Cancel
  if sum(strcmp(c,getfield(data,keys{IdentifierID}))) ~=0
    error('Same Tag File exist. Cannot Make Group Data');
  end
  clear c f;
  datalist(end+1) =struct_merge0(datalist(1),data_tmp,2);
else
  % New Data
  datalist =data_tmp;
end

%==========================
%% get Save File Name & Rename Variable
dfl=getDataListFileName;
AnalysisDataFileList = datalist;
% Save File
AnalysisData = data;
fname=getDataFileName(data);

%% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'AnalysisDataFileList','-v6');
  save(fname,'AnalysisData','-v6');
else
  save(dfl,'AnalysisDataFileList');
  save(fname,'AnalysisData');
end

% Create RelationFile
addRelation(data);
return;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow(key)
% Save Analysis-Data Over Wirte
%  * Delete Current Relation.
%  * Save Data & Make New Relation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=============================
% Initialize :: 
% getting Data correspond to Relation...
%=============================
% Get Relation File
relfile = getRelationFileName;
% Getting Current Name
keys = Keys;
dname = reshapeName(eval(['key.' keys{IdentifierID} ';']));

%=============================
%  * Delete Current Relation.
%=============================
% !!! Warning !!!
% We can available the function,
% only when there is no-children.
% == because "2nd-Lvl-Ana Data-Format"
% 
% But if there is children,
%   you must improbe something..
%   (Donot Clear But Modify children Parent)
try
  FileFunc('clearParent', relfile, dname);
catch
  % Error : Dialog
  a=questdlg({'Crlear Relation Error :', ...
      '-------------------------',...
      lasterr,...
      '-------------------------',...
      'Do you want to Continue Saving?'},...
    'Continue to save?','Yes','No','Yes');
  if strcmp(a,'No'), return; end
end

%=============================
%   Save Over-Write ::: 
%   Modify Only "Data-Parts"
%=============================
AnalysisData = key;
fname=getDataFileName(key);

% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,'AnalysisData','-v6');
else
  save(fname,'AnalysisData');
end

%=============================
% Set New RelationFile
%=============================
addRelation(key);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_AnalysisData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=getFilename(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  filesep 'DataList_2ndLvelData.mat'];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataFileName(data)
%  Get Data File Name of
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name Setting  : --> See save
dfl=getDataListFileName;
[p0, n1] = fileparts(dfl); % get save path

% connect : OspProject rm_subjectname
fname = ['SLD_' data.Name '.mat'];
fname=[p0 filesep fname];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(anadata, filterdata, fname)
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================
%% Check Argument 
%======================
% == Load  Analysis Data ==
if ~isfield(anadata,'data')
  anadata = load_AnalysisData(anadata);
end
if isempty(anadata.data),
  error('\n POTATo Error!!\n<< No-Data to Filter in the Analysis-Data >>\n');
end

% Change Filter Data (if there)
if nargin>=2,
  anadata.data.filterdata=filterdata;
end

% get File Name
if nargin<3,
  fname = fileparts(which('OSP'));
  fname0 = [fname filesep 'ospData' filesep];
  fname = [fname0 'slv_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'slv_' datestr(now,30) tmp '.m'];
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

function fn=make_mfile_useblock(key)
% Revision 1.27
% Date : 27-Jan-2006
%  To Bug fix of Multi-Block-Mfile
%   :: Add :: make_mfile_useblock
actdata=key.actdata;
fdata=key.filterManage;
if isfield(key,'fname'),
  fn=key.fname;
else
  fn= fileparts(which('OSP'));
  fn= [fn filesep 'ospData' filesep];
  fname= [fn 'slv_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fn 'slv_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
  fn = fname;
end

[fid, fn] = make_mfile('fopen', fn,'w');
try
  SignalData2Mfile(actdata.data, fdata);
  if isfield(fdata,'BlockPeriod'),
    % == Data Blocking ==
    make_mfile('with_indent', ...
      {'% === Make Block Data === ', ...
      sprintf('[data, hdata] = uc_blocking(cdata, chdata,%f,%f);', ...
      fdata.BlockPeriod(1), fdata.BlockPeriod(2)), ...
      ' '});
    % == Block Data Loop Start. ==
    make_mfile('with_indent','% === To Block Data === ');

    if isfield(fdata,'BlockData'),
      % -- Set Filter --
      for fidx=1:length(fdata.BlockData),
        try
          str = ...
            P3_PluginEvalScript(fdata.BlockData(fidx).wrap,'write', ...
            'BlockData', fdata.BlockData(fidx));
          if ~isempty(str),
            make_mfile('with_indent', str);
          end
        catch
          make_mfile('with_indent', ...
            sprintf('warning(''write error: at %s'');', ...
            fdata.BlockData(fidx).name));
          warning(lasterr);
        end % try-catch
      end % filter output
    end, % if BlockData?

    % rename :
    % Recode of OSP-v1.5 9th-Meeting of on 27-Jun-2005.
    % Change on 28-Jun-2005 by Shoji.
    make_mfile('with_indent', ...
      {'% Rename', ...
      'bdata  = data;', ...
      'bhdata = hdata;', ...
      ' '})
    make_mfile('with_indent',{'% End of Block Data', ' '});

  end % if BlockPeriod?
catch
  make_mfile('fclose');
  rethrow(lasterror);
end
% == Close M-File ==
make_mfile('fclose');


function UpdateDataKey(AnalysisDataFileList) %#ok
% Update-Data-Key List
dfl = getDataListFileName;
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'AnalysisDataFileList','-v6');
else
  save(dfl,'AnalysisDataFileList');
end
