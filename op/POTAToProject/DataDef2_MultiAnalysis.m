function varargout=DataDef2_MultiAnalysis(fnc,varargin)
% POTATo's MultiAnalysis-Data I/O Function.
%
%  Keys = DataDef2_MultiAnalysis('getKeys')
%     return 
%
%  [Keys, tag] = DataDef2_MultiAnalysis('getKeys')
%     Keys  : Cell structure of Search Key of 
%             MultiAnalysis-Data
%     tag   : Example of Search keys with 
%             correspond to Keys
%
%  [id_fieldname] = DataDef2_MultiAnalysis('getIdentifierKey')
%     Field Name to identify Data.
%     This Value must be unique in Poject.
%
%
%  [filelists]  = DataDef2_MultiAnalysis('loadlist')
%     Load File List
%
%
%  [info] = DataDef2_MultiAnalysis('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%  [header,data,ver] =  DataDef2_MultiAnalysis('load')
%  [header,data,ver] =  DataDef2_MultiAnalysis('load',key)
%     Load Raw-Data from File
%     if there is no-key, Read Current Data in Current-Project.
%
%  [filename] = DataDef2_MultiAnalysis('make_mfile',key)
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12
%
%  [filename] = DataDef2_MultiAnalysis('make_mfile_useblock',key)
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
%  [header, data] = DataDef2_MultiAnalysis('make_ucdata',key)
%      key : ( same as make_mfile )
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%  DataDef2_MultiAnalysis('save')
%     Save Current Data
%  DataDef2_MultiAnalysis('save',header,data,OSP_SP_DATA_VER);
%     Save header, data as OSP_SP_VER
%
%  DataDef2_MultiAnalysis('save_ow',header,data,OSP_SP_DATA_VER,actdata)
%     Save Current Data -> Over-Write Mode
%
%  DataDef2_MultiAnalysis('reshapeName',name)
%
%---------------------------------------------------------------
% uniqe-functions
%---------------------------------------------------------------
%   [ana, str, isblock]   = DataDef2_MultiAnalysis('get_ANA_info',key);
%       get Analysis-File-Information


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
% $Id: DataDef2_MultiAnalysis.m 398 2014-03-31 04:36:46Z katura7pro $

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
    fnc='saveMultiAnalysisData';
  case 'make_mfile'
    fnc='make_mfile_MultiAnalysisData';
  case 'help',
    fnc='help_MultiAnalysisData';
  case 'load',
    fnc='load_MultiAnalysisData';
end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of Multi Ana File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================
function id=IdentifierID
% Identifier Number
%================================
id =1;                     % Identifier ID

%================================
function key = Keys
% Definition of Search Keys,
% Warning : filename is  using in POTAToProject/preprocessor!
%           Do not rename, without changing POTAToProject/preprocessor.
%================================
key={'Tag', 'NumberOfFiles',...
  'ID_number','Comment'};

%================================
function keyname=getIdentifierKey
% return Identifier Data's field name
%================================
k = Keys;
keyname=k{IdentifierID};
%================================
function example_struct=searchexampl
% Definition of Example of Keys
% Call from uiFlieSelect
%================================
example_struct  = struct( ...
  'Tag',         'Group[AB][1-9]', ...
  'ID_number',   '1' ,...
  'Comment',     'Calculation', ...
  'CreateDate',  'now'); % Search key Example

%================================
function  [Keys2, se]=getKeys
% To Search keys.
% Call from uiFlieSelect
%================================
Keys2 = Keys;
Keys2{end+1}='CreateDate';
se = searchexampl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function help_MultiAnalysisData
% Help of this function
% See also OspHelp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OspHelp(mfilename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making Relation & Delete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=============================
function nm=reshapeName(key)
% Return : Relation-File Variable Name
%   Relation Data
%=============================
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
[p, dname, ext] = fileparts(key);
if 0, disp(p);end
nm = [dname ext ];

nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');

nm = ['MLT_' nm];
return;

%===========================
function  addRelation(dt)
% Update Relation-File when Save MultiAnalysis - Data.
%
% This Function is Added :: since reversion 1.1
%              
% Get Data-File's name
%===========================

name0=getDataFileName(dt);
if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(eval(['dt.' getIdentifierKey ';']));  % 'MLT_*'
  snm.name=nm;
  snm.data.(getIdentifierKey)=dt.(getIdentifierKey);
  snm.fcn=mfilename;
  snm.Parent={};
  snm.Children={};
  
  % Get Parent-Raw-Data
	% Get RelationData-File's name, Relation-Data
	fname = getRelationFileName;
  load(fname,'Relation');
  if ~exist('Relation','var'), Relation=struct([]);end

  msg={'------------------------',...
    ' [Platform Warning] : ',...
    '------------------------',...
    ' In Making Multi-Data-File, Ditect Some Relation Data was broken'};
	for idx2=1:length(dt.data.AnaKeys),
		nm2=DataDef2_Analysis('reshapeName',dt.data.AnaKeys{idx2});
		if isfield(Relation,nm2)
		  % Add Relation  
        snm.Parent{end+1}=nm2;
        Relation.(nm2).Children{end+1}=nm;
    else
		  % No Data Exist ---> Delete This Data::
		  %deleteData(dt);
      msg{end+1}=nm2;
		end
  end
  if length(msg)>4
    warndlg(msg,'Platform Warning (Make Mult)');
  end

  % -- Save  to Relation.mat
  Relation.(nm)=snm;
  FileFunc('saveRelation',Relation);  
else
	 % file is not exist
end


%============================
function deleteGroup(key)
% Delete Data & there children.
%
% key : delete name of top data
%============================

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
  error('Data Name of DataDef2_MultiAnalysisData is empty.');
end

%===============================
% Get RelationFile's name
%===============================
relfile=getRelationFileName;
% -- Get Children list:
%    clist : Children of "dname"
clist = FileFunc('getChildren', relfile, dname);
clear prjct;

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
    ' MultiAnalysis-Data Children List:'...
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
% Delete Data File (with children)
% ==========================================
clist{end+1}=dname;
load(relfile, 'Relation');
for i=1:length(clist),
  try
    % Load Relation Data of Delete-Data
		data = Relation.(clist{i}).data;
		fcn  = Relation.(clist{i}).fcn;
    % => Delete Children <=
    feval(fcn, 'deleteData', data);
  catch
    % Error : Dialog
    errordlg(lasterr);
    %return;
  end
end

% ==========================================
% Update RelationFile
% ==========================================
try
  FileFunc('clearParent', relfile, dname);
catch
  % Error : Dialog
  errordlg(lasterr);
end
return;

%============================
function deleteData(data)
% Delete MultiAnalysis-Data, anyway.
%  (Delete only my-self)
%   data :  delete data
%============================

%----------------------------
% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
if isempty(data),
  error('Cannot Open Empty MultiAnalysis-Data.');
end

%----------------------------
% Delete Data from list ;
%----------------------------
listfname = getDataListFileName;
idkey     = getIdentifierKey; %<- identfiler key
if exist(listfname, 'file'),
  load(listfname, 'MultiAnalysisDataFileList');
  ckeys = eval(['{MultiAnalysisDataFileList.' idkey '};']);
  mykey = eval(['data.' idkey ';']);
  myid  = find(strcmp(ckeys, mykey));
  if isempty(myid),
    fprintf(2,'No much file, : %s\n',mykey);
  end
  if length(myid)>2
    fprintf(2,'Data-List was broken.\nDelete All files named : %s\n',mykey);
  end
  MultiAnalysisDataFileList(myid)=[];
  % Save
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(listfname, 'MultiAnalysisDataFileList','-v6');
  else
    save(listfname, 'MultiAnalysisDataFileList');
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
function infoStr=showinfo(key)
% Show Information of MultiAnalysis-Data
%  Syntax : 
%   infoStr=showinfo(key);
%     key     : MultiAnalysis-Data
%     infoStr : Cell String of Information.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=====================
%% Initiarize
%=====================
fileData=key;   % Here Set MultiAnalysis Data
if ~isstruct(fileData) || isempty(fileData)
  infoStr={' === No Information =='};
  return;
end
infoStr={' -- Multi-Analysis File --'};

%% Get Data
c = OspDataFileInfo(0,1,fileData);
try
  [infoStr{2:length(c)+1}]=deal(c{:});
catch
  infoStr={[mfilename ' : ' lasterr ]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MultiAnalysisDataFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Structure of Signal-Data :
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dfl=getDataListFileName;
if exist(dfl,'file')
  load(dfl,'MultiAnalysisDataFileList')
else
  % No MultiAnalysis-Data FileList
  MultiAnalysisDataFileList={};
  return;
end

if ~exist('MultiAnalysisDataFileList','var') || ...
    isempty(MultiAnalysisDataFileList)
  % No Data : Exist
  MultiAnalysisDataFileList={};
  return;
end
keys = Keys;
iid = IdentifierID;
if nargin>=1 && ~isempty(keys),
  % Search Select Key
  c = struct2cell(MultiAnalysisDataFileList);
  f = fieldnames(MultiAnalysisDataFileList);
  c = squeeze(c(strcmp(f,keys{iid}),:,:));
  if isstruct(key)
    pos = find(strcmp(c,getfield(key,keys{iid})));
  else
    pos = find(strcmp(c,key));
  end
  MultiAnalysisDataFileList = MultiAnalysisDataFileList(pos);
  clear c f p pos;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_MultiAnalysisData(key)
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
  if ~isfield(key,'Tag') && ...
      isfield(key,'data')
    key=key.data;
  end
end

% Get File Name
fname=getDataFileName(key);

% File check
if ~exist(fname,'file'),
  % Error No Data File exist:
  deleteData(key);
  OSP_LOG('perr', ...
    [ ' In Loading Data, File (' fname ') not exist']);
  error([' File Lost : ' fname]);
end

% ---------------
% Load Data
% ---------------
load(fname,'MultiAnalysisData');

% TODO : Data Check
% TODO : Additional Infroamtion
%        (Old : Blocking..)

varargout{1}=MultiAnalysisData;
return;


function data=local_func2str(data)
% Function 2 Struct
%disp(data);
if ~isfield(data,'data') || isempty(data.data) || ~isfield(data.data(end),'Recipe'),return;end
rcp=data.data(end).Recipe;
if isfield(rcp,'default')
  for idx=1:length(rcp.default)
    if ~ischar(rcp.default{idx}.wrap)
      rcp.default{idx}.wrap=func2str(rcp.default{idx}.wrap);
    end
  end
end
data.data(end).Recipe=rcp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveMultiAnalysisData(key)
% Save MultiAnalysis-Data
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
  datalist(end+1) =struct_merge0(datalist(1),data_tmp,2);
else
  % New Data
  datalist =data_tmp;
end

%==========================
%% get Save File Name & Rename Variable
dfl=getDataListFileName;
MultiAnalysisDataFileList = datalist;
% Save File
MultiAnalysisData = local_func2str(data);
fname=getDataFileName(data);

%% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'MultiAnalysisDataFileList','-v6');
  save(fname,'MultiAnalysisData','-v6');
else
  save(dfl,'MultiAnalysisDataFileList');
  save(fname,'MultiAnalysisData');
end
% Create RelationFile
addRelation(data);
return;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow(key,fullflag)
% Save MultiAnalysis-Data Over Wirte
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
MultiAnalysisData = local_func2str(key);
fname=getDataFileName(key);

%======================================
% Save Files
%======================================
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,'MultiAnalysisData','-v6');
else
  save(fname,'MultiAnalysisData');
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow_old(key)
% Save MultiAnalysis-Data Over Wirte
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
  % get ID of Data-ID
  myid=find(strcmp(c,data.(keys{IdentifierID})));
  % if exist Cancel
  if length(myid)~=1
    error(['Can not Overwrite : ' , ...
      'Could not find Data in the List File']);
  end
  datalist(myid)=struct_merge0(datalist(myid),data_tmp);
  clear c f;
else
  % New Data
  error('Can not Overwrite : There is no List File.')
end

%==========================
%% get Save File Name & Rename Variable
dfl=getDataListFileName;
MultiAnalysisDataFileList = datalist;
% Save File
MultiAnalysisData = local_func2str(data);
fname=getDataFileName(data);

%% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'MultiAnalysisDataFileList','-v6');
  save(fname,'MultiAnalysisData','-v6');
else
  save(dfl,'MultiAnalysisDataFileList');
  save(fname,'MultiAnalysisData');
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
  '(DataDef2_MultiAnalysis:make_timedata) Called']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_MultiAnalysisData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(key,'actdata'),
  if isfield(key,'fname'),
    if isfield(key,'Recipe')
      varargout{1} = make_mfile_local(key.actdata.data, ...
        key.fname,key.Recipe);
    else
      % Make M-file With Filter Manage Data
      %   & File-Name
      varargout{1} = make_mfile_local(key.actdata.data, ...
        key.fname);
    end
  else
    % Make M-file With Filter Manage Data
    varargout{1} = make_mfile_local(key.actdata.data);
  end
else
  % Make M-file : Default
  varargout{1} = make_mfile_local(key);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(multdata, fname,recipe)
%  Make M-File of Multi-Analysis Data.
%     since 2007.04.24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% === Open M-File ===
if nargin<2 || isempty(fname)
  fname = fileparts(which('OSP'));
  fname0= [fname filesep 'ospData' filesep];
  fname = [fname0 'mult_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'mult_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
end
% Initialize
if nargin<3
  if isfield(multdata.data,'Recipe')
    recipe=multdata.data.Recipe;
  else
    recipe=[];
  end
end

[fid, fname] = make_mfile('fopen', fname,'w');
if 0,disp(fid);end
clear fid

try
  [p,fname0]=fileparts(fname);
  if 0,disp(p);end
  clear p
  %===========================
  % Header And Comment
  %  TODO: Thinking About I/O
  %===========================
  make_mfile('with_indent', ...
    ['function [data, hdata]=' fname0 '(varargin)']);
  make_mfile('with_indent', ...
    {'% Make P3 Data by Cell-array From Files.', ...
    ['% Syntax : [data, hdata]= ' fname0 ';'], ...
    '% data : ', ...
    '%   Cell Aray of P3 Data ',...
    '% hdata : ', ...
    '%   Cell Aray of Header of P3 Data'});
  make_mfile('with_indent','%');
  % Data Informaiton
  make_mfile('with_indent', '% == Multi Data-Information ==');
  % Project Information
  P3_Write_Mfile_Comment('projectInfo');
  make_mfile('with_indent', ['%   Name  : ' multdata.Tag]);
  make_mfile('with_indent', '% ');
  make_mfile('with_indent', ['% Date : ' datestr(now,0)]);
  make_mfile('with_indent', '% ');
  % Recipe Information
  P3_Write_Mfile_Comment('multiRecipeInfo',recipe);
  
  make_mfile('with_indent', '%');
  make_mfile('with_indent', '% $Id: DataDef2_MultiAnalysis.m 398 2014-03-31 04:36:46Z katura7pro $');
  make_mfile('with_indent', '');
  %====================
  % Initialize
  %  TODO: Thinking About I/O
  %====================
  make_mfile('code_separator',1)
	make_mfile('with_indent', '% Initialize Data');
	make_mfile('code_separator',1)
	make_mfile('with_indent', {'data={}; hdata={};', ' '});
	make_mfile('code_separator',3)
	make_mfile('with_indent', '% Arguments Check');

  isFileIOMode=false;
  if isstruct(recipe) && isfield(recipe,'FileIOMode')
    isFileIOMode=recipe.FileIOMode;
  end

  %================
  % Loading Data
  %   multdata : Multi-Data with data
  %   rawname  : Raw-Data File Name
  %   crcp     : Cell of Recipe (Filter-Manage-Data)
  %   rid      : Recipe ID used.
  % ----------------
  % --> I/O Image :==
  % [crcp, xxx, rid]=unique(cfmd);
  %================
  multdata=load_MultiAnalysisData(multdata);
  % -- Load Analysis Files --
  crcp={};
  if 0
    % --> since R7
    rid=zeros(1,length(multdata.data.AnaKeys),'uint16');
  else
    rid=zeros(1,length(multdata.data.AnaKeys));
  end
  
  rawname=cell(1,length(multdata.data.AnaKeys));
  ananame=cell(1,length(multdata.data.AnaKeys));
  for idx=1:length(multdata.data.AnaKeys)
    key=DataDef2_Analysis('loadlist',multdata.data.AnaKeys{idx});
    ana=DataDef2_Analysis('load',key);
    tmp=DataDef2_Analysis('reshapeName',key.filename);
    if length(tmp)>=5
      ananame{idx}=tmp(5:end);
    else
      ananame{idx}='';
    end
    fmd=ana.data(end).filterdata;
    tmp=0;
    for id=1:length(crcp)
      if isequal(crcp{id},fmd)
        tmp=id;break;
      end
    end
    if tmp==0
      tmp=length(crcp)+1;
      crcp{tmp}=fmd;
    end
    rid(idx)=tmp;
    rawname{idx}=DataDef2_RawData('getFilename',ana.data.name);
  end
  
  %===================
  % Raw Data File List
  %===================
  % !! length(rawname)>=2 !!
  make_mfile('with_indent', ...
    ['datanames={ ''' rawname{1} ''', ...']);
  for idx=2:length(rawname)-1,
    make_mfile('with_indent', ...
      ['            ''' rawname{idx} ''', ...']);
  end
  make_mfile('with_indent', ...
    ['            ''' rawname{end} '''};']);
  
  %===================
  % Save Data File List
  %===================
  if isFileIOMode
    % My Save Path
    mypath0=fileparts(rawname{1});
    mypath=[mypath0 filesep multdata.Tag filesep];
    make_mfile('with_indent', ...
      ['savefilenames={ ''' mypath ananame{1} '.mat' ''', ...']);
    for idx=2:length(ananame)-1,
      make_mfile('with_indent', ...
        ['            ''' mypath ananame{idx} '.mat' ''', ...']);
    end
    make_mfile('with_indent', ...
      ['            ''' mypath ananame{end} '.mat' '''};']);
    % Error for MATLAB 6.5.1
    make_mfile('with_indent', ...
      {['if ~isdir(''' mypath ''')'],...
      ['    mkdir(''' mypath0 ''',''' multdata.Tag ''');'],...
      'end'});
  end

  %====================
  % Correspond Recipe
  %====================
  make_mfile('with_indent', ...
    ['recp={ ''Recipe' num2str(rid(1)) ''', ...']);
  for idx=2:length(rawname)-1,
    make_mfile('with_indent', ...
      ['       ''Recipe' num2str(rid(idx)) ''', ...']);
  end
  make_mfile('with_indent', ...
    ['       ''Recipe' num2str(rid(end)) '''};']);

  
  %====================
  % Call Recipe
  %====================
  make_mfile('with_indent', ...
    'for idx=1:length(datanames),');
  make_mfile('indent_fcn', 'down');
  if isFileIOMode
    make_mfile('with_indent', ...
      {'d = datanames{idx};', ...
      '[data0, hdata0] = eval([recp{idx} ''(d);'']);',...
      'save(savefilenames{idx},''data0'',''hdata0'');'});
  else
    make_mfile('with_indent', ...
      {'d = datanames{idx};', ...
      '[data{end+1}, hdata{end+1}] = eval([recp{idx} ''(d);'']);'});
  end
	make_mfile('indent_fcn', 'up');
	make_mfile('with_indent', 'end');

  
  %============================
  % Set-up Mult-Analysis Mode 
  %  Plugin Function 
  % TODO : Make Plugin
	%============================
  make_mfile('code_separator',1)
  make_mfile('with_indent', ...
    {'% Make P3 Multi-Analysis Plugin Execute',...
    '% *** Warning ***',...
    '% This Area is depend on Plugin.', ...
    '% And there is no-check for Data-Type,',...
    '% So you must check-plugin yourself.'});
  if 0,
    make_mfile('with_indent', ...
      {'% ************** Error **************',...
      '%     TODO: --Unpopulated ---',...
      '% ***********************************'});
  end
  make_mfile('code_separator',1)
  
  if isfield(recipe,'default')
    % -- Set Filter --
    for fidx=1:length(recipe.default),
      try
        if isfield(recipe.default{fidx},'enable') && ...
            strcmpi(recipe.default{fidx}.enable,'off'),
          continue;
        end
        str = ...
          P3_PluginEvalScript(recipe.default{fidx}.wrap,'write', ...
          'Multi', recipe.default{fidx});
        if ~isempty(str),
          make_mfile('with_indent', str);
        end
      catch
        make_mfile('with_indent', ...
          sprintf('warning(''write error: at %s'');', recipe.default{fidx}.name));
        warning(lasterr);
      end % try-catch
    end % filter output
    make_mfile('code_separator', 2);
  end
  
  
  make_mfile('with_indent', 'return;');
  make_mfile('with_indent', '');
  make_mfile('with_indent', '');
  
  %====================
  % Make Recipe
  %====================
  for idx=1:length(crcp),
    %make_mfile('code_separator',1)
    make_mfile('with_indent', ...
      ['function [data, hdata]=Recipe' num2str(idx) '(datanames)']);
    %make_mfile('code_separator',1)
    P3_FilterData2Mfile(crcp{idx});
  end
  
catch
  make_mfile('fclose');
  rethrow(lasterror);
end
make_mfile('fclose');


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
end

% connect : OspProject rm_subjectname
fname = [path0 ...
  filesep pj.Name ...
  filesep 'DataListMultiAnalysisData.mat'];
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
k=eval(['data.' getIdentifierKey ';']);
fname = ['MLT_' k '.mat'];
fname=[p0 filesep fname];
return;

function [anadata, str, isblock]   = get_ANA_info(key)
%   [ana, str, isblock]   = DataDef2_MultiAnalysis('get_ANA_info',key);
%       get Analysis-File-Information
% ========================
%---> Show Recipes <---
%    include : Load Analysis Files --
%  Meeting on 20-Apr-2007
%  ** 2.2 **
% ========================
if ischar(key)
  key=loadlist(key);
  key=load_MultiAnalysisData(key);
elseif isstruct(key) && ~isfield(key,'data')
  key=load_MultiAnalysisData(key);
end
data0=key.data.AnaKeys;
anadata=cell(1,length(data0));
str    =cell(1,length(data0));
evstr  =['key.' DataDef2_Analysis('getIdentifierKey') ';'];
for idx=1:length(data0)
  key=DataDef2_Analysis('loadlist',data0{idx});
  str{idx}=sprintf('File #%d : %s',idx,eval(evstr));
  anadata{idx}=DataDef2_Analysis('load',key);
end

% ========================
% Checking Data .....
%   Meeting on 20-Apr-2007 
%   ** 2.4.1 **
% ========================
% --- init ---
isblock=false(1,length(anadata));
% --- check block/continuos ---
% See also : OspFilterCallbacks/psb_removeFiltData_Callback
for idx=1:length(anadata),
  fmd=anadata{idx}.data(end).filterdata;
  if isfield(fmd,'block_enable')
    isblock(idx)=isfield(fmd,'BlockPeriod') & fmd.block_enable;
  else
    isblock(idx)=isfield(fmd,'BlockPeriod');
  end
end

%==========================================================================
function UpdateDataKey(MultiAnalysisDataFileList) %#ok
% Update Data-Key List
%==========================================================================
dfl=getDataListFileName;
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'MultiAnalysisDataFileList','-v6');
else
  save(dfl,'MultiAnalysisDataFileList');
end

