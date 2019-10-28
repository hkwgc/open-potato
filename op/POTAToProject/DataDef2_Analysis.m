function varargout=DataDef2_Analysis(fnc,varargin)
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
%  DataDef2_Analysis('UpdateDataKey',key) 
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
% $Id: DataDef2_Analysis.m 398 2014-03-31 04:36:46Z katura7pro $

% Reversion 1.01
% Date : 11-Dec-2006
%  Import form DataDef2_Raw.m and
%              DataDef_GroupData.m
%
% Revision 1.13 :
%   Add : UpdateDataKey

% ======================
%%  POTATo : Running Check
% ======================
if ~OSP_DATA('GET','isPOTAToRunning')
  errordlg({' POTATo is not runing!', ...
	    '  please type "POTATo" at First!"'});
  return;
end

% ======================
%% Launcher
% ======================
if nargin==0, fnc='help'; end

switch fnc,
  case 'save',
    fnc='saveAnalysisData';
  case 'make_mfile'
    fnc='make_mfile_AnalysisData';
  case 'help',
    fnc='help_AnalysisData';
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
%% Definition Function
% ======================
function key = Keys
% Definition of Search Keys,
% Warning : filename is  using in POTAToProject/preprocessor!
%           Do not rename, without changing POTAToProject/preprocessor.
key=DataDef2_RawData('Keys');
key{end+1}='TimeBlock';

function example_struct=searchexampl
% Definition of Example of Keys
example_struct  = DataDef2_RawData('searchexampl');
example_struct.TimeBlock='on';


function id=IdentifierID
% Donot Change  : since 1.17---> Fix::: Rename Option
id =1;                     % Identifier ID

function help_AnalysisData
% Ignore varargin now..
OspHelp(mfilename)
%   if nargin>0,  mode = varargin{1};end
%   if nargin>1,  key  = varargin{2};end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=reshapeName(key)
% Return : Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
%[p, dname, ext, ver] = fileparts(key);
%nm = [dname ext ver];
%- The above lines has been commented and changed as below because of higher compatibility.
[p, dname, ext] = fileparts(key);
nm = [dname ext];

nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');
nm = ['ANA_' nm];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteGroup(key)
% key : delete name of top data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
dname = reshapeName(key);
if isempty(dname),
  error('Data Name of DataDef2_AnalysisData is empty.');
end

%===============================
% Make Relation in the Project
%===============================
% Modify 070316 
%    (RelationFile is created  when 'save')
% -- Get RelationFile's name
relfile=getRelationFileName;
% -- Get Children list:
%    clist : Children of "dname"
try
  clist = FileFunc('getChildren', relfile, dname);
catch
  a= questdlg({
    'Could not find proper relation.',...
    ' Do you want to delete this file?'},'Error File');
  if strcmpi(a,'No')
    rethrow(lasterror);
  end
  clist={};
end

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
    ' Analysis-Data Children List:'...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteData(data)
% Delete Analysis-Data, anyway
%   data :  delete data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------
%% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isempty(data),
  error('Cannot Open Empty Analysis-Data.');
end

%----------------------------
%% Delete Data from list ;
%----------------------------
listfname = getDataListFileName;
if exist(listfname, 'file'),
  load(listfname, 'AnalysisDataFileList')
  bdata=find(strcmp({AnalysisDataFileList.filename}, ...
    data.filename)==1);
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
%% Delete Real-Data File
%----------------------------
delfname  = getDataFileName(data);
if exist(delfname, 'file'),
  delete(delfname);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function infoStr=showinfo(key)
% Show Information of Analysis-Data
%  Syntax : 
%   infoStr=showinfo(key);
%     key     : Analysis-Data
%     infoStr : Cell String of Information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=====================
%% Initiarize
%=====================
fileData=key;   % Here Set Analysis Data
if ~isstruct(fileData) || isempty(fileData)
  infoStr={' === No Information =='};
  return;
end

% Get Data
c = OspDataFileInfo(0,1,fileData);
try
  %infoStr={' -- Analysis-Data File Info --'};
  %[infoStr{2:length(c)+1}]=deal(c{:});
  infoStr=c;
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
  if 1
    mykey={AnalysisDataFileList.(keys{iid})};
    if isstruct(key)
      pos=strmatch(key.(keys{iid}),mykey,'exact');
    else
      pos=strmatch(key,mykey,'exact');
    end
  else  
    c = struct2cell(AnalysisDataFileList);
    f = fieldnames(AnalysisDataFileList);
    p = find(strcmp(f,keys{iid}));
    c = squeeze(c(p,:,:));
    if isstruct(key)
      pos = find(strcmp(c,getfield(key,keys{iid})));
    else
      pos = find(strcmp(c,key));
    end
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

function adata=NewAnalysisData(varargin)
%TODO : if you need :-->
%       copy, rename, .. and so on.
adata=varargin{1};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_AnalysisData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See also save

% ---------------
%% Load Data Check
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

function data=local_func2str(data)
% Function 2 Struct

if ~isfield(data,'data') || isempty(data.data) || ~isfield(data.data(end),'filterdata'),return;end
fd=data.data(end).filterdata;
if isfield(fd,'HBdata')
  for idx=1:length(fd.HBdata)
    if ~ischar(fd.HBdata{idx}.wrap)
      fd.HBdata{idx}.wrap=func2str(fd.HBdata{idx}.wrap);
    end
  end
end
if isfield(fd,'BlockData')
  for idx=1:length(fd.BlockData)
    if ~ischar(fd.BlockData{idx}.wrap)
      fd.BlockData{idx}.wrap=func2str(fd.BlockData{idx}.wrap);
    end
  end
end
if isfield(fd,'TimeBlocking')
  for idx=1:length(fd.TimeBlocking)
    if ~ischar(fd.TimeBlocking{idx}.wrap)
      fd.TimeBlocking{idx}.wrap=func2str(fd.TimeBlocking{idx}.wrap);
    end
  end
end
data.data(end).filterdata=fd;

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
  if any(strcmp(c,data.(keys{IdentifierID})))
    error('Same Tag File exist. Cannot Make Group Data');
  end
  clear c f;
  datalist(end+1) =struct_merge0(datalist(1),data_tmp,2); % merge (default NaN)
else
  % New Data
  datalist =data_tmp;
end

%==========================
%% get Save File Name & Rename Variable
dfl=getDataListFileName;
AnalysisDataFileList = datalist;
% Save File
AnalysisData = local_func2str(data);
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
function save_ow(key,fullflag)
% Save Analysis-Data Over Wirte
% (light-overwrite)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=====================
% Check Argument
%=====================
if ~exist('key','var')
  error('No Data to save.');
end

%=====================
% Full Version
%=====================
if nargin==2 && fullflag==true
  save_ow_old(key);
  return;
end

%======================================
% get Save File Name & Rename Variable
%======================================
AnalysisData = local_func2str(key);
fname=getDataFileName(key);
%======================================
% Save Files
%======================================
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,'AnalysisData','-v6');
else
  save(fname,'AnalysisData');
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow_old(key)
% Save Analysis-Data Over Wirte
%  (Full-Overwrite)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  % get ID of data-ID.
  myid=find(strcmp(c,data.(keys{IdentifierID})));
  % if exist Cancel
  if length(myid)~=1
    error(['Can not Overwrite : ' , ...
      'Could not find Data in the List File']);
  end
  datalist(myid)= struct_merge0(datalist(myid),data_tmp);
  clear c f;
else
  % New Data
  error('Can not Overwrite : There is no List File.')
end

%==========================
%% get Save File Name & Rename Variable
dfl=getDataListFileName;
AnalysisDataFileList = datalist;
% Save File
AnalysisData = local_func2str(data);
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
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function make_timedata(varargin)
% Make Time x HB data
% Read Plot Key
% This Function :: Removed
%                  05-Jan-2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OSP_LOG('perr', 'Removed Function(make_timedata) Called');
error(['Removed Function' ...
  '(DataDef2_Analysis:make_timedata) Called']);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function make_ucdata(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error('Too Old I/O');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  pj.Path=path0;OSP_DATA('SET','PROJECT',pj);
end

% connect : OspProject rm_subjectname
%fname = [pj.Path ...
fname = [path0 ...
  filesep pj.Name ...
  ... %OSP_DATA('GET','PROJECT_DATA_DIR') ...
  filesep 'DataListAnalysisData.mat'];

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
fname = ['ANA_' data.filename '.mat'];
fname=[p0 filesep fname];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(anadata, filterdata, fname)
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global WinP3_EXE_PATH;
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
	if isempty(WinP3_EXE_PATH)
  fname = fileparts(which('OSP'));
  fname0= [fname filesep 'ospData' filesep];
	else
		fname=WinP3_EXE_PATH;
		fname0=[fname filesep 'tmp' filesep];
	end
  fname = [fname0 'ana_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'ana_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
end

%% Make Mfile
%=====================
% Open M-File
%=====================
[fid, fname] = make_mfile('fopen', fname,'w');
% clear compiled function
try
	clear(fname)
end

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
  fname= [fn 'ana_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fn 'ana_' datestr(now,30) tmp '.m'];
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
  nm=reshapeName(dt.filename);  % 'ANA_*'
  snm.name=nm;
  snm.data.filename=dt.filename;
  snm.fcn=mfilename;
  snm.Parent={};
  snm.Children={};
  
  % Get Parent-Raw-Data  
	% Get RelationData-File's name, Relation-Data
	fname = getRelationFileName;
  load(fname,'Relation');
  if ~exist('Relation','var'), Relation=struct([]);end
  
	for idx2=1:length(dt.data),
		nm2=DataDef2_RawData('reshapeName',dt.data(idx2).name);
		if isfield(Relation,nm2)
		  % Add Relation  
      snm.Parent{end+1}=nm2;
      Relation.(nm2).Children{end+1}=nm;
    else
		  % No Data Exist ---> Delete This Data::
      try
        d0=DataDef2_RawData('loadlist',dt.data(idx2).name);
        d.name=nm2;
        d.data=d0;
        d.fcn='DataDef2_RawData';
        d.Parent={};
        d.Children={nm};
        Relation.(nm2)=d;
      catch
        deleteData(dt);
      end
		end
  end

  % -- Save  to Relation.mat
  Relation.(nm)=snm;
  FileFunc('saveRelation',Relation);
else
	 % file is not exist
end

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

