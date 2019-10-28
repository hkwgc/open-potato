function varargout=DataDef2_RawData(fnc,varargin)
%function varargout=DataDef2_RawData(mode, key)
% Data Definition of Raw-Data
%
%  Keys = DataDef2_RawData('getKeys')
%     return Cell structure of Search Key of Raw-Data
%
%  [Keys, tag] = DataDef2_RawData('getKeys')
%     tag is Example of Search keys
%     correspond to Keys
%          
%
%  [id_fieldname] = DataDef2_RawData('getIdentifierKey')
%     Identifier of the Data.
%     This Key must be unique
%
%  [filelists]  = DataDef2_RawData('loadlist')
%     Load File List
%
%  [info] = DataDef2_RawData('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%  [header,data,ver] =  DataDef2_RawData('load')
%  [header,data,ver] =  DataDef2_RawData('load',key)
%     Load Raw-Data from File
%     if there is no-key, Read Current Data in Current-Project.
%
%  [filename] = DataDef2_RawData('make_mfile',key)
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename : 
%         File-name of made M-File. 
%      This mehtod is added since reversion 1.12
%
%  [filename] = DataDef2_RawData('make_mfile_useblock',key)
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
%  [header, data] = DataDef2_RawData('make_ucdata',key)
%      key : ( same as make_mfile )
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%  [strHBdata, plot_kind] =
%          DataDef2_RawData('make_timedata', key)
%      Make HBdata for plot, and using plot
%
%  DataDef2_RawData('save')
%     Save Current Data
%  DataDef2_RawData('save',header,data,OSP_SP_DATA_VER);
%     Save header, data as OSP_SP_VER
%
%  DataDef2_RawData('save_ow',header,data,OSP_SP_DATA_VER,actdata)
%     Save Current Data -> Over-Write Mode
%
%  DataDef2_RawData('reshapeName',name)
%
%  DataDef2_RawData('ReplaceViewLayout',Layout, key);
%     Layout : ViewLayout cell-array Data
%     key    : active data
%
%000000000 For Air 00000000000000000
% loadAirList : Air File-List
% getAirDataListFilename : Filename of Air File-List
% saev_air    : save Air-File (Always Over-Write)


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
% $Id: DataDef2_RawData.m 398 2014-03-31 04:36:46Z katura7pro $ 

% Reversion 1.12
%  Add 'make_mfile',
%  Add 'make_ucdata'.
%  Mod : when use Matlab 7 or latter
%        save -v6.
%
% Revision 1.18
%   :: Add :: Air I/O

% ======================
%   POTATo : Running Check
% ======================
if ~OSP_DATA('GET','isPOTAToRunning')
  errordlg({' POTATo is not runing!', ...
	    '  please type "POTATo" at First!"'});
  return;
end
  
if nargin==0
  errordlg('DataDef2_RawData Need Arguments!');
  fnc='help';
end

switch fnc,
	case 'save',
		fnc='saveRawData';
	case 'make_mfile'
		fnc='make_mfile_RawData';
	case 'help',
		fnc='help_RawData';
    case 'load',
        fnc='load_RawData';
end

if nargout,
	[varargout{1:nargout}] = feval(fnc, varargin{:});
else
	feval(fnc, varargin{:});
end
return;

% ======================
%   Definition Function
% ======================
function key = Keys
key=Keys0;
key={key{:}, ...
  'measuremode', 'samplingperiod', 'StimMode'};
  
function key = Keys0
% Definition of Search Keys,
% Warning : filename is  using in POTAToProject/preprocessor!
%           Do not rename, without changing POTAToProject/preprocessor.
key={'filename', 'date', 'ID_number',...
		'age', 'sex', 'subjectname'}; % Search keys 

function example_struct=searchexampl
% Definition of Example of Keys
example_struct  = struct( ...
	'filename',    '^test(\w*).dat', ...
	'date',        '{''24-Jan-05'' datestr(now)}', ...
	'ID_number',   '_01$' ,...
	'age',         '[10 23]', ...
	'sex',         '''Female''',...
	'subjectname', 'Taro', ...
  'measureMode', '3x5', ...
  'samplingperiod', '100', ...
  'StimMode', 'Event',...
	'CreateDate',  ['''' date '''']); % Search key Example

function id=IdentifierID
% Donot Change  : since 1.17---> Fix::: Rename Option
id =1;                     % Identifier ID

function n=keylen
n = length(Keys);

function help_RawData(varargin)
% Ignore varargin now..
OspHelp(mfilename)
%   if nargin>0,  mode = varargin{1};end
%   if nargin>1,  key  = varargin{2};end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=reshapeName(key)
% Key to Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
nm=key;

nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');
nm = ['RAW_' nm];
return;

function nm=reshapeName2(fname)
% Data-Filename to  Relation-File Variable Name
% --> This function undo getDataFileName--> 
%     so if getDataFileName, modify also this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

%---------------------
% File-Name to Key
%---------------------
[p f e v]=fileparts(fname);
fname = [f e v];
% See also getDataFileName
%   ==> fname = ['RAW_' data.filename '.mat'];
key = fname(5:end-4); 

%------------------------------------
% Key to Relation-File Variable Name
%-----------------------------------
nm = reshapeName(key); 
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
  key=key.(keys{IdentifierID});
end
dname = reshapeName(key);
if isempty(dname),
	error('Data Name DataDef2_RawData is empty.');
end

%===============================
% Get Relation in the Project
%===============================
% Modify 070316 
%    (RelationFile is created  when 'save')
% -- Get RelationFile's name
relfile = getRelationFileName;
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

% ------------------------------------------
% Throw Quesion : Confine to delete
% ------------------------------------------
% Use uigetpref?
dflag=OSP_DATA('GET','ConfineDeleteDataRD');
if isempty(dflag),dflag=true;end
if dflag,
    cname={'Can I Delete Following Data-List?'...
	 ' '...
	 ' RawData Children List:'...
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
      OSP_DATA('SET','ConfineDeleteDataRD',false);
    end
end

% ==========================================
% -- Delete this key-file and this children's
% ==========================================
% -- Delete own file ,too
clist{end+1}=dname;
load(relfile,'Relation');
if ~exist('Relation','var'), Relation=struct([]);end
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
%  Never...--> clearParent function is needless
%  Must update Children.
%
% -----------------------------------
%   Me ---> Children (Delete)
%   A <---> Children (Delete)
%       so modify A.Children & Delete ..
%   and clean up Relation-Data..
% -----------------------------------
%       Modifyed at 2007.03.23 by shoji.
try
  FileFunc('clearParent', relfile, dname);
catch
  % Error : Dialog
  errordlg(lasterr);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteData(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% key : delete data
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isempty(data),
	error('Cannot Open Empty Raw-Data.');
end

% Delete Data File
delfname  = getDataFileName(data);
if exist(delfname, 'file'),
	delete(delfname); 
end
	
% delete name from list ;
listfname = getDataListFileName;
if exist(listfname, 'file'),
	load(listfname, 'rawDataFileList')
  rawDataFileList(strcmp({rawDataFileList.filename}, data.filename))=[];
  if isempty(rawDataFileList)
    delete(listfname);
    return;
  end
  
	% Save
	rver=OSP_DATA('GET','ML_TB');
	rver=rver.MATLAB;
	if rver >= 14,
		save(listfname, 'rawDataFileList','-v6');
  else
		save(listfname, 'rawDataFileList');
	end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function infoStr=showinfo(key)
% Initiarize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileData=key;   % Here Set Raw Data
if ~isstruct(fileData) || isempty(fileData)
	infoStr={' === No Information =='};
	return;
end
infoStr={' -- Raw-Data File Info --'};
    
% Get Data
c = OspDataFileInfo(0,1,fileData);
try
	[infoStr{2:length(c)+1}]=deal(c{:}); 
catch
	infoStr={[mfilename ' : ' lasterr ]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function rawDataFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Structure of Signal-Data :
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
dfl=getDataListFileName;
if exist(dfl,'file')
	load(dfl,'rawDataFileList')
else
	% No Raw-Data FileList
	rawDataFileList={};
	return;
end

if ~exist('rawDataFileList','var') || ...
		isempty(rawDataFileList)
	% No Data : Exist
	rawDataFileList={};
	return;
end
if nargin>=1 && ~isempty(key),
	% Search Select Key
  keys = Keys;
  iid = IdentifierID;
  kkk = {rawDataFileList.(keys{iid})}; % key name list
	if isstruct(key)
		pos = find(strcmp(kkk,key.(keys{iid})));
	else
		pos = find(strcmp(kkk,key));
	end
	rawDataFileList = rawDataFileList(pos);
	clear c f p pos;
end;

function Air_List=loadAirList
Air_List=[];
pj=OSP_DATA('GET','PROJECT');
if isempty(pj),return;end
fname=getAirDataListFilename;
if exist(fname,'file'),
  load(fname,'Air_List');
end

function saveAirList(Air_List)
fname=getAirDataListFilename;
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(fname,'Air_List','-v6');
else
  save(fname,'Air_List');
end
if 0,disp(Air_List);end


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

function inpdata = makeListData(header)
% make Raw-Data's List Data
%

try
  keys = Keys0;
  infodata = header.TAGs;
  %OSP_LOCALDATA.info; 
  inpdata.CreateDate=now;
  for field_id=1:length(keys),
    inpdata = setfield(inpdata,keys{field_id}, ...
      getfield(infodata,keys{field_id}));
  end
  % Since RAW Data
  % Sampling Period
  inpdata.samplingperiod=header.samplingperiod;
  % Measure Mode
  switch header.measuremode
    case -1,
      inpdata.measuremode = '  POTATo Position Data ';
    case 1,
      inpdata.measuremode = '  1  : ETG-100 24ch (3x3)x2 mode';
    case 2,
      inpdata.measuremode = '  2  : ETG-100 24ch (4x4) mode';
    case 3,
      inpdata.measuremode = '  3  : ETG-7000 3x5 mode';
    case 50,
      inpdata.measuremode = ' 50  : ETG-7000 8x8 mode';
    case 51,
      inpdata.measuremode = ' 51  : ETG-7000 4x4 mode';
    case 52,
      inpdata.measuremode = ' 52  : ETG-7000 3x5 mode';
    case 54,
      inpdata.measuremode = ' 54  : ETG-4000 3x11 mode';
    case 101,
      inpdata.measuremode = '101  : Shimadzu Format (24 ch)';
    case 102,
      inpdata.measuremode = '102  : Shimadzu Format (35 ch)';
    case 103,
      inpdata.measuremode = '103  : Shimadzu Format (45 ch)';
    case 199,
      inpdata.measuremode = '199  : Shimadzu Format (Free)';
    case 200,
      inpdata.measuremode = '200  : WOT (2x10)';
    case 201,
      inpdata.measuremode = '201  : WOT (2x8) == WOT Mode 2';
    case 202,
      inpdata.measuremode = '202  : WOT (2x4)x2 == WOT Mode 2';
    otherwise,
      inpdata.measuremode = '---  : Unknow Format';
  end % swich Measure Mode
  
  % Stim Mode
  try
    if header.StimMode==1
      inpdata.StimMode='Event';
    else
      inpdata.StimMode='Block';
    end
  catch
    %disp('Error : stimMode/StimMode');
    if header.stimMode==1
      inpdata.StimMode='Event';
    else
      inpdata.StimMode='Block';
    end
  end
catch
  inpdata=[];
  errordlg([' Cannot Save : '...
	    'Raw-Data '...
	    'may be not Made.' lasterr])
  return;
end
clear infodata;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_RawData(key)
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

% File Name Setting  : --> See save
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
load(fname,'OSP_SP_DATA_VER');
% Check Data Version & Transfer
if ~exist('OSP_SP_DATA_VER','var')
  % ===> Data Exchange :
  %        from OSP Version 1.5 to 2.0
  %      05-Jan-2006
  h=warndlg({'Read : Old - Signal Data.', ...
    '        o Transform --> Version 2...'});
  OSP_SP_DATA_VER=2; %%3;
  S=load(fname);
  if ~isfield(S,'OSP_LOCALDATA'),
    OSP_LOG('err','Raw-Data File-Format Error!');
    error(sprintf(['--- OSP Error!!! ---\n', ...
      ' Format of Raw-Data\n', ...
      ' File Name : %s\n', ...
      ' Read as OSP version 1.5\n', ...
      ' %s\n'],  ...
      fname, C__FILE__LINE__CHAR));
  end
  % OSP Version 1.50 : Position Data
  %  Position Data
  if isfield(S,'Position'),
    [data,header]=ot2ucdata(S.OSP_LOCALDATA,'Position',S.Position);
  else
    [data,header]=ot2ucdata(S.OSP_LOCALDATA);
  end
  clear S;
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(fname,'data','header','OSP_SP_DATA_VER','-v6');
  else
    save(fname,'data','header','OSP_SP_DATA_VER');
  end
  if ishandle(h), waitfor(h); end
end

% ---------------
% Set Output Data
% ---------------
switch OSP_SP_DATA_VER,
  case {2,3}, %%2,
    % OSP Version 2.0
    S=load(fname);

    if isfield(S,'header') && nargout>=1,
      varargout{1}=S.header;
    else
      error('Output Argument : Header : Error!');
    end

    if isfield(S,'data') && nargout>=2,
      varargout{2}=S.data;
    elseif nargout>=2,
      error('Output Argument Error: Data : Error!');
    end

    if isfield(S,'OSP_SP_DATA_VER') && nargout>=3,
      varargout{3}=S.OSP_SP_DATA_VER;
    end
  otherwise,
    error('OSP SP Version Error!');
end

% ------------------------------
% OSP Common Data Setting ::
% OSP Version 1.0 / before
% --> From 1.22 : Set Empty ::
% ------------------------------
OSP_DATA('SET','OSP_LOCALDATA',[]);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  varargout=saveRawData(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save OSP Raw - Data.
%   Data Version 2.0 = 
%      User-Command Data of Continuous Data
%
% This Function is Changed ::
%              since reversion 1.22
%  Last Modfy : 05-Jan-2006
%
%
%--- preprocessor Function IO_Kind : 0 --
%    Old format : OSP version 1.5 or before
%
%  Syntax : 
%    [header, data, version] = saveRawData
%       Save OSP_DATA('GET','OSP_LOCALDATA')
%
%    [header, data, version] = saveRawData(OST_LOCALDATA)
%       Save OSP_LOCALDATA
%
%--- preprocessor Function IO_Kind : 1 --
%  Syntax : preprocessor Function IO_Kind : 1
%    [header, data, version] = saveRawData(header,data,version)
%        Save  header and data with format-version version.
%
%    [header, data, version] = saveRawData(header,data)
%        Save  header and data with format-version 2.
%
% See also otsigtrnschld2

% For Rename Option :: My-Continuous-Number

%==================================
% Get Header And Data 
%==================================
% Output : data, header, inpdata
if nargin<=1,
  %=== Save from Old Data format : OSP Version 1.50 ===
  if nargin==0,
    OSP_LOCALDATA = OSP_DATA('GET','OSP_LOCALDATA');
  else
    OSP_LOCALDATA = varargin{1};
  end

  % Make Input Data ( named 'inpdata' )
  if ~isfield(OSP_LOCALDATA,'info') || ...
	~isfield(OSP_LOCALDATA,'HBdata') || ...
	~isfield(OSP_LOCALDATA,'HBdataTag') || ...
	~isfield(OSP_LOCALDATA,'HBdata3Tag')
    errordlg([' Cannot Save : ' ...
	      'Raw-Data ' ...
	      'is not exist.']);
  end

  [data,header]=ot2ucdata(OSP_LOCALDATA);
  OSP_SP_DATA_VER = 3;
else
  msg = nargchk(2,3,nargin);
  if ~isempty(msg), error(msg);end

  header = varargin{1};
  data   = varargin{2};
  if nargin>=3,
    OSP_SP_DATA_VER = varargin{3};
    %-- Version Check --
    % now accept onlys 2 :
    if OSP_SP_DATA_VER<3 || OSP_SP_DATA_VER>3,
      error('POTATo RAW-DATA Version Error');
    end
  else
    OSP_SP_DATA_VER = 3;
  end
end

%==================================
% Load - Data-List
%==================================
% Output : 
%    mykey : IdentifierKey
%    dfl   : Data-List FileName
%    rawDataFileList : (List temp)
%    namelist : data-list (key)
mykey           = getIdentifierKey;
dfl             = getDataListFileName;
rawDataFileList = loadlist;

if isempty(rawDataFileList)
  namelist={};
else
  namelist={rawDataFileList.(mykey)};
end

%===========================
% ----> Name Setting  <-----
%===========================
try
  %----------------------------
  % get Rename Option
  %----------------------------
  try
    rnmOpt=OSP_DATA('GET','SP_Rename');
  catch
    rnmOpt='-';
    OSP_DATA('SET','SP_Rename',rnmOpt);
  end
  if isempty(rnmOpt), rnmOpt='-';
  elseif iscell(rnmOpt), rnmOpt=rnmOpt{1}; end

  %----------------------------
  % make default FileName (Key)
  %----------------------------
  fname0 = header.TAGs.filename;
  switch rnmOpt,
    case 'Date',
      % Rename by date
      n2 = datestr(now,1);
      n2 = ['Date_' n2];
    case 'DataLength',
      % Rename by data-length
      n2 = num2str(size(data));
      n2 = ['DataSize_' n2];
    case 'ID',
      % Rename by ID
      try
        if ischar(header.TAGs.ID_number),
          n2 = header.TAGs.ID_number;
        elseif isnumeric(header.TAGs.ID_number),
          n2 = num2str(header.TAGs.ID_number);
        else
          n2='';
        end
      catch
        n2 = inputdlg({['OSP : ID Number is not defined in this file' ...
          ' : Input ID Number ']}, ...
          'ID Number');
        if isempty(n2), return; end
      end
      if isnumeric(n2), n2=num2str(n2); end
      n2 = ['ID_' n2];
    case 'OriginalName',
      % Rename by Original-Name
      n2 = fname0;
    case 'InputName'
      % Rename by Input-Name
      in0=OSP_DATA('GET','SP_Rename_IN');
      in0.id = in0.id +1; % Update
      n2 = sprintf('%s_%03d',in0.str,in0.id);
      if isfield(in0,'RN'),
        n2=[n2 in0.RN];
      end
      OSP_DATA('SET','SP_Rename_IN',in0);
    otherwise,
      fname=fname0; %default
  end % Switch Rename Potion : option

  % fname to variable name
  if exist('n2','var'),
    fname=n2;
  end
  fname = strrep(fname,' ','_');
  fname = strrep(fname,'-','_');
  fname = strrep(fname,'+','_');
  fname = strrep(fname,'%','_');
  fname = strrep(fname,'=','_');
  fname = strrep(fname,'/','_');
  fname = strrep(fname,'\','_Y_');
  fname = strrep(fname,'?','_');
  fname = strrep(fname,'@','_At_');
  fname = strrep(fname,'#','_No_');

  %------------------------------
  % Rename by id..
  %------------------------------
  if exist('rnmOpt','var') && ~strcmp(rnmOpt,'-'),
    % Rename Option : 'On'
    %  Keys{IdentifierID} : filename
    if any(strcmp(fname,namelist))
      rn_id = strmatch([fname '_RN'],namelist);
      rn_id = length(rn_id);
    end 
    fname0=fname;
    while any(strcmp(fname,namelist))
      if strcmp(rnmOpt,'InputName'),
        if in0.id==1,
          in0.RN=['_RN' num2str(rn_id+1)];
        else
          in0.RN=['_RNX' num2str(rn_id+1)];
        end
        fname = [fname0 in0.RN];
        OSP_DATA('SET','SP_Rename_IN',in0);
      else
        fname = [fname0 '_RN' num2str(rn_id+1)];
      end
      rn_id=rn_id+1;
    end
  end % end Rename

  %------------------------------
  % Change Too-Long File Name....
  %------------------------------
  if length(fname)>59
    % Mail from Katura at 2008/04/24 12:07:20
    % TODO: comment-out
    prompt={'Input new Data-Name :'};
    while any(strcmp(fname,namelist)) || length(fname)>59
      x=inputdlg(prompt,'Too Long Data-Name',1,{fname});
      if isempty(x),
        fname='';
        break;
      else
        fname=x{1};
      end
    end
  end

  header.TAGs.filename=fname;
catch
  warndlg({'P3 Warning : ' , ...
	   '  Error Occur About Rename Option' , ...
	   '  * Real Error Message : ', ...
	   '    ',  lasterr}, 'RawData');
  % '  * When RawData Version less than 1.7', ...
  % '    This Error occur Every-time...Check it.', ...
  try
    clear rnmOpt;
  end
end

%------------------------------
% Checking Data-Name
%------------------------------
if any(strcmp(fname,namelist)) 
  error('Data-Name Error : Same Data-Name');
end
if length(fname)>59
  error('Data-Name Error : Too long Data-Name');
end
if isempty(fname)
  error('Data-Name Error : Cancel');
end

%==================================
% Make Input Data ( named 'inpdata' )
%==================================
inpdata = makeListData(header);
if isempty(inpdata),return;end

%==================================
% Renew rawDataFileList
%==================================
if isempty(rawDataFileList)
  rawDataFileList        =inpdata;  %#ok use in save
else
  rawDataFileList(end+1) =inpdata;  %#ok use in save
end

%==================================
% Save Raw-Data Version 2.0
%==================================
% Data-File Name : fname
fname=getDataFileName(inpdata);
% Check version of MATLAB.
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  % MALTAB Release 13
  % Save Data with Version 6
  save(dfl,'rawDataFileList','-v6');
  save(fname,'data','header','OSP_SP_DATA_VER','-v6');
elseif rver >= 12,
  % Save Data with Version 6
  save(dfl,'rawDataFileList');
  save(fname,'data','header','OSP_SP_DATA_VER');
else
  % Can not save Structure ::: MATLAB 4
  error('Version of MATLAB is too old.');
end
%==================================
% Create RelationFile
%==================================
addRelation(inpdata);

%==================================
% Make Analysis-Data : 
%==================================
inpdata.TimeBlock='off';
inpdata.data.ver =1.0;
%inpdata.data.name=fname;
inpdata.data.name=inpdata.(mykey);
inpdata.data.filterdata.dumy='No Effective Data';
DataDef2_Analysis('save',inpdata);
varargout{1}=inpdata;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_ow(header,data,OSP_SP_DATA_VER,actdata) %#ok<DEFNU,INUSL> (Save)
% See also otsigtrnschld
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,4,nargin);
if ~isempty(msg),error(msg);end

if nargin==4,
  fname=getDataFileName(actdata.data);
else
  % :: search Same Data ::
  actdatadata.filename = header.TAGs.filename;
  fname=getDataFileName(actdatadata);
end

% Save Data List
sdl={'header','data','OSP_SP_DATA_VER'};
sdl=sdl(1:min(nargin,3));
% Save File
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
optnum=0;
if rver >= 14,
  % MALTAB Release 13
  % Save Data with Version 6
  sdl{end+1}='-v6';
  optnum=optnum+1;
end
if nargin<=2
  sdl{end+1}='-append';
  optnum=optnum+1;
end
if optnum<2
  save(fname,sdl{:});
else
  % -- -v6 + -append is error!!
  [h, d,ver]=load_RawData(actdatadata);
  if 0, disp(h);clear h;end
  if nargin<2,data=d; end %#ok<NASGU> (Save)
  if nargin<3,OSP_SP_DATA_VER=ver; end %#ok<NASGU> (Save)
  save(fname,'-v6','header','data','OSP_SP_DATA_VER');
end

%===============================
% Analysis-Data Modification
% Commentout 2008.07.30
%===============================
% try
%   anadata=DataDef2_Analysis('loadlist');
%   idkey  =DataDef2_Analysis('getIdentifierKey');
%   inpdata = makeListData(header);
%   wk=strcmp({anadata.(idkey)},inpdata.(getIdentifierKey));
%   %wk     = ['strcmp({anadata.' idkey '},getfield(inpdata, getIdentifierKey))'];
%   if isempty(anadata) || ~any(wk);
%     inpdata.TimeBlock='off';
%     inpdata.data.ver =1.0;
%     %inpdata.data.name=fname;
%     inpdata.data.name=inpdata.(getIdentifierKey);
%     inpdata.data.filterdata.dumy='No Effective Data';
%     DataDef2_Analysis('save',inpdata);
%   end
% catch
%   warndlg({'Could not make Analysis Data'},'Raw OW Warning:');
% end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  varargout=save_air(header,data,ftime)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save POTATo 3.1.4
%  Syntax : 
%    [header, data, version] = save_air(hdata,data)
%

% For Rename Option :: My-Continuous-Number

%==================================
% Get Header And Data 
%==================================
msg = nargchk(3,3,nargin);
if ~isempty(msg), error(msg);end
OSP_SP_DATA_VER = 3;

%==================================
% Make Input Data ( named 'inpdata' )
%==================================
inpdata = makeListData(header);
if isempty(inpdata),return;end
%==================================
% Renew rawDataFileList
%==================================
% Input : 
%    rnmOpt  : Rename Option
%    inpdata : Input Data to Save-List
%    header  : Continuous - Data (Header)
%    data    : Continuous - Data
% Lower Functions
%    getDataListFilename : INNER  : List File
%    Kyes                : INNER  : DATA-KEY 
dfl=getDataListFileName;
newflag=true;
if ~exist(dfl,'file')
  rawDataFileList(1)=inpdata;
else
  keys = Keys;
  if 0,rawDataFileList=[];end
  load(dfl,'rawDataFileList')
  
  % File Save -- Check File
  c = struct2cell(rawDataFileList);
  f = fieldnames(rawDataFileList);
  c = squeeze(c(strcmp(f,keys{IdentifierID}),:,:));
  % Check Save-Filen-Name
  myid=find(strcmp(c,getfield(inpdata,keys{IdentifierID})));
  if length(myid)==1
    newflag=false;
    rawDataFileList(myid)=inpdata;
  elseif length(myid)>1
    error('Same File-Name exist. Stop to Save');
  else
    rawDataFileList(end+1) =inpdata;
  end
  clear c f p;
  varargout{1}=inpdata;
end

%==================================
% Save Raw-Data Version 2.0
%==================================
% Data-File Name : fname
fname=getDataFileName(inpdata);
% Check version of MATLAB.
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if 0,
  % Save Data
  disp(rawDataFileList);
  disp(data);disp(header);disp(OSP_SP_DATA_VER);
end
if rver >= 14,
  % MALTAB Release 13
  % Save Data with Version 6
  save(dfl,'rawDataFileList','-v6');
  save(fname,'data','header','OSP_SP_DATA_VER','-v6');
elseif rver >= 12,
  % Save Data with Version 6
  save(dfl,'rawDataFileList');
  save(fname,'data','header','OSP_SP_DATA_VER');
else
  % Can not save Structure ::: MATLAB 4
  error('Version of MATLAB is too old.');
end
if newflag
  addRelation(inpdata);
end


%===========================
% Data List
%===========================
fname = header.TAGs.filename;

tmp.filename=fname;
tmp.time    =ftime; % Setting File Time-Stamp
%----> Checkin Data-List
% Air Data-List
Air_List=loadAirList;
if isempty(Air_List)
  Air_List=tmp;
else
  idx=strmatch(tmp.filename,{Air_List.filename});
  if isempty(idx)
    Air_List(end+1)=tmp;
  else
    Air_List(idx(1))=tmp;
  end
end
saveAirList(Air_List);


if newflag
  try
    anadata=DataDef2_Analysis('loadlist');
    idkey  =DataDef2_Analysis('getIdentifierKey');
    wk     = ['strcmp({anadata.' idkey '},inpdata.' getIdentifierKey ')'];
    if isempty(anadata) || ~any(eval(wk))
      inpdata.TimeBlock='off';
      inpdata.data.ver =1.0;
      %inpdata.data.name=fname;
      inpdata.data.name=getfield(inpdata, getIdentifierKey);
      inpdata.data.filterdata.dumy='No Effective Data';
      DataDef2_Analysis('save',inpdata);
    end
  catch
    warndlg({'Could not make Analysis Data'},'Raw OW Warning:');
  end
  return;
end


%==================================
% Additional Data : 
%==================================
varargout{1}=inpdata;
return;

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_RawData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(key,'fname'),
  varargout{1} = make_mfile_local(key.actdata.data, ...
				  key.filterManage, ...
				  key.fname);
else
  varargout{1} = make_mfile_local(key.actdata.data, key.filterManage);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_ucdata(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actdata    = key.actdata;
filterdata = key.filterManage;

% == Make M-File ==
fname = make_mfile_local(actdata.data, filterdata);
[cdata, chdata] = scriptMeval(fname, 'cdata', 'chdata');
delete(fname);

varargout{1} = cdata{1};
varargout{2} = chdata{1};

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
  % fname = [pj.Path ...
  fname =[path0 ...
      filesep pj.Name ...
	   ... %OSP_DATA('GET','PROJECT_DATA_DIR') ...
	   filesep 'DataListRawData.mat'];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataFileName(data)
%  Get Data File Name of 
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name Setting  : --> See save
% if you modify this code,
%  Change also reshapeName2.
  dfl=getDataListFileName;
  p0 = fileparts(dfl); % get save path

  % connect : OspProject rm_subjectname
  fname = ['RAW_' data.filename '.mat'];
  fname=[p0 filesep fname];
return;

function fname=getAirDataListFilename
% Air Data List File-Name
fname=fileparts(getDataListFileName);
fname=[fname filesep 'DataList_Air_In_RawData.mat'];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(data, filterdata, fname)
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == Open M-File ==
if nargin<3,
  fname = fileparts(which('OSP'));
  fname0= [fname filesep 'ospData' filesep];
  fname = [fname0 'raw_' datestr(now,30) '.m'];
  tmp   ='x';
  while exist(fname,'file')
    fname = [fname0 'raw_' datestr(now,30) tmp '.m'];
    tmp(end+1)='x';
  end
end
[fid, fname] = make_mfile('fopen', fname,'w');
try
  SignalData2Mfile(data, filterdata);
catch
  make_mfile('fclose');
  rethrow(lasterror);
end
% == Close M-File ==
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
    fname= [fn 'raw_' datestr(now,30) '.m'];
    tmp   ='x';
    while exist(fname,'file')
      fname = [fn 'raw_' datestr(now,30) tmp '.m'];
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

    
function ReplaceViewLayout(Layout, key)
%     Layout : ViewLayout cell-array Data
%     key    : active data
  msg=nargchk(2,2,nargin);
  if ~isempty(msg),error(msg);end

  % Load Original Data
  fname=getDataFileName(key.data);
  [header, data, OSP_SP_DATA_VER]=load_RawData(key);
  % Over write Layout
  header.VIEW.LAYOUT=Layout;
  
  % Save File
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    % MALTAB Release 13
    % Save Data with Version 6
    save(fname,'data','header','OSP_SP_DATA_VER','-v6');
  elseif rver >= 12,
    % Save Data with Version 6
    save(fname,'data','header','OSP_SP_DATA_VER');
  else
    % Can not save Structure ::: MATLAB 4
    error('Version of MATLAB is too old.');
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  addRelation(dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Relation-File when Save OSP Raw - Data.
%   Data Version 2.5 
%
% This Function is Added ::
%              since reversion 1.6
% Get Data-File's name
name0=getDataFileName(dt);
if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(dt.filename);  % 'RAW_*'
  snm.name=nm;
  snm.data.filename=dt.filename;
  snm.fcn=mfilename;
  snm.Parent={};
  snm.Children={};  

	% Get RelationData-File's name
  fname=getRelationFileName;
  % -- Save  to Relation.mat
	FileFunc('setVariable', snm, nm,fname); 
else
	 % If file is not exist --> remove!
	deleteData(dt);
end
