function varargout=DataDef_SignalPreprocessor(fnc,varargin)
%function varargout=DataDef_SignalPreprocessor(mode, key)
% Data Definition of Signal Processor
%
%  Keys = DataDef_SignalPreprocessor('getKeys')
%     return Cell structure of Search Key of Signal Processor Data
%
%  [Keys, tag] = DataDef_SignalPreprocessor('getKeys')
%     tag is Example of Search keys
%     correspond to Keys
%          
%
%  [id_fieldname] = DataDef_SignalPreprocessor('getIdentifierKey')
%     Identifier of the Data.
%     This Key must be unique
%
%  [filelists]  = DataDef_SignalPreprocessor('loadlist')
%     Load File List
%
%  [info] = DataDef_SignalPreprocessor('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%  [header,data,ver] =  DataDef_SignalPreprocessor('load')
%  [header,data,ver] =  DataDef_SignalPreprocessor('load',key)
%     Load Signal-Preprocessor Data from File
%     if there is no-key, Read Current Data in OSP.
%
%  [filename] = DataDef_SignalPreprocessor('make_mfile',key)
%      kye :
%         key.actdata is Signal-Processor-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename : 
%         File-name of made M-File. 
%      This mehtod is added since reversion 1.12
%
%  [filename] = DataDef_SignalPreprocessor('make_mfile_useblock',key)
%     make_mfile : Use-Block 
%     (To bug fix : Multi-Block : Use Blocking )
%      kye :
%         key.actdata is Signal-Processor-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename : 
%         File-name of made M-File. 
%      This mehtod is added since reversion 1.12
%
%  [header, data] = DataDef_SignalPreprocessor('make_ucdata',key)
%      key : ( same as make_mfile )
%         key.actdata is Signal-Processor-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%  [strHBdata, plot_kind] =
%          DataDef_SignalPreprocessor('make_timedata', key)
%      Make HBdata for plot, and using plot
%
%  DataDef_SignalPreprocessor('save')
%     Save Current Data
%  DataDef_SignalPreprocessor('save',header,data,OSP_SP_DATA_VER);
%     Save header, data as OSP_SP_VER
%
%  DataDef_SignalPreprocessor('save_ow',header,data,OSP_SP_DATA_VER,actdata)
%     Save Current Data -> Over-Write Mode
%
%  DataDef_SignalPreprocessor('reshapeName',name)
%
%  DataDef_SignalPreprocessor('ReplaceViewLayout',Layout, key);
%     Layout : ViewLayout cell-array Data
%     key    : active data


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
% $Id: DataDef_SignalPreprocessor.m 180 2011-05-19 09:34:28Z Katura $

% Reversion 1.12
%  Add 'make_mfile',
%  Add 'make_ucdata'.
%  Mod : when use Matlab 7 or latter
%        save -v6.
%
% Reversion 1.13
%  Mod : 'make_mfile'
%    add filename  for an input argument. 
%
% Reversion 1.16
%  Add : Read Digital-Gain as  field of Header.TAGS.d_gain
%  Date: 31-Oct-2005
%
% Reversion 1.17
%  Add : Rename Option
%  Date: 19-Nov-2005
%
% Reversion 1.18
%  Bug fix : Rename option
%  Date: 25-Nov-2005
%
% Reversion 1.21
% Date : 27-Dec-2005
%  New Save Mode ::->
%   Save As Continuous Data
%
% Revision 1.27
% Date : 27-Jan-2006
%  To Bug fix of Multi-Block-Mfile
%   :: Add :: make_mfile_useblock
% ======================
%   OSP : Running Check
% ======================
if OSP_DATA==0
  errordlg({' OSP is not runing!', ...
	    '  please type "OSP" at First!"'});
  return;
end
  
if nargin==0
  errordlg('DataDef_SignalPreprocessor Need Arguments!');
  fnc='help';
end

switch fnc,
	case 'save',
		fnc='saveSignalData';
	case 'make_mfile'
		fnc='make_mfile_SignalData';
	case 'help',
		fnc='help_SignalData';
    case 'load',
        fnc='load_SignalData';
end

if nargout,
	[varargout{1:nargout}] = feval(fnc, varargin{:});
else,
	feval(fnc, varargin{:});
end
return;

% ======================
%   Definition Function
% ======================
function key = Keys,
% Definition of Search Keys,
% Warning : filename is  using in signal_preprocessor!
%           Do not rename, without changing signal_preprocessor.
key={'filename', 'date', 'ID_number',...
		'age', 'sex', 'subjectname'}; % Search keys 

function example_struct=searchexampl,
% Definition of Example of Keys
example_struct  = struct( ...
	'filename',    '^test(\w*).dat', ...
	'date',        '{''24-Jan-05'' datestr(now)}', ...
	'ID_number',   '_01$' ,...
	'age',         '[10 23]', ...
	'sex',         '''Female''',...
	'subjectname', 'Taro', ...
	'CreateDate',  ['''' date '''']); % Search key Example

function id=IdentifierID,
% Donot Change  : since 1.17---> Fix::: Rename Option
id =1;                     % Identifier ID

function n=keylen,
n = length(Keys);

function help_SignalData(varargin)
% Ignore varargin now..
OspHelp(mfilename)
%   if nargin>0,  mode = varargin{1};end
%   if nargin>1,  key  = varargin{2};end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=reshapeName(key),
% Return : Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
[p, dname] = fileparts(key);
nm = dname;
% s = regexp(nm(1),'[a-zA-Z]');
% if isempty(s),
% 	nm = ['D' nm];
% end
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');
nm = ['HB_' nm];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteGroup(key),
% key : delete name of top data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

dname = reshapeName(key);
if isempty(dname),
	error('lack name of DataDef_GroupData.');
end

% -- Reset project:
% prjct  : Project
% refile : Relation File
[prjct, relfile] = resetProject;
% -- Get Children list:
%    clist : Children of "dname"
clist = FileFunc('getChildren', relfile, dname);

% ------------------------------------------
% Throw Quesion : Confine to delete
% ------------------------------------------
% Use uigetpref?
dflag=OSP_DATA('GET','ConfineDeleteDataSV');
if dflag,
  cname={'Can I Delete Following Data-List?'...
	 ' '...
	 ' SignalPreprocessor Children List:'...
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
for i=1:length(clist),
	try,
		% Load Relation of
		% Clist from 
		% Relation file(relfile)
		load(relfile, clist{i});
		data = eval([clist{i} '.data']);
		fcn  = eval([clist{i} '.fcn']);
		feval(fcn, 'deleteData', data);
	catch,
		% Error : Dialog
		errordlg(lasterr);
	end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteData(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% key : delete data
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

if isempty(data),
	error('Cannot Open Empty Signal-Data.');
end

% Delete Data File
delfname  = getDataFileName(data);
if exist(delfname, 'file'),
	delete(delfname);   
end
	
% delete name from list ;
listfname = getDataListFileName;
if exist(listfname, 'file'),
	load(listfname, 'signalProcessorFileList')
	bdata=find(strcmp({signalProcessorFileList.filename}, ...
		data.filename)==1);
	signalProcessorFileList(bdata)=[];
	% Save
	rver=OSP_DATA('GET','ML_TB');
	rver=rver.MATLAB;
	if rver >= 14,
		save(listfname, 'signalProcessorFileList','-v6');
	else,
		save(listfname, 'signalProcessorFileList');
	end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function infoStr=showinfo(key)
% Initiarize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileData=key;   % Here Set Signal Processing Dataa
if ~isstruct(fileData) || isempty(fileData)
	varargout{1}={' === No Information =='};
	return;
end
infoStr={' -- Signal Preprocessor File Info --'};
    
% Get Data
c = OspDataFileInfo(0,1,fileData);
try
	[infoStr{2:length(c)+1}]=deal(c{:}); 
catch
	infoStr={[mfilename ' : ' lasterr ]};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function signalProcessorFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Structure of Signal-Data :
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
dfl=getDataListFileName;
if exist(dfl,'file')
	load(dfl,'signalProcessorFileList')
else,
	% No Signal-Preprocessor FileList
	signalProcessorFileList={};
	return;
end

if ~exist('signalProcessorFileList','var') || ...
		isempty(signalProcessorFileList)
	% No Data : Exist
	signalProcessorFileList={};
	return;
end
keys = Keys;
iid = IdentifierID;
if nargin>=1 && ~isempty(keys),
	% Search Select Key
	c = struct2cell(signalProcessorFileList);
	f = fieldnames(signalProcessorFileList);
	p = find(strcmp(f,keys{iid}));
	c = squeeze(c(p,:,:));
	if isstruct(key)
		pos = find(strcmp(c,getfield(key,keys{iid})));
			
	else
		pos = find(strcmp(c,key));
	end
	signalProcessorFileList = signalProcessorFileList(pos);
	clear c f p pos;
end
varargout{1}=signalProcessorFileList;

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=load_SignalData(key)
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
  OSP_SP_DATA_VER=2;
  S=load(fname);
  if ~isfield(S,'OSP_LOCALDATA'),
    OSP_LOG('err','Signal-Data File-Format Error!');
    error(sprintf(['--- OSP Error!!! ---\n', ...
		   ' Format of Signal-Preprocessor\n', ...
		   ' File Name : %s\n', ...
		   ' Read as OSP version 1.5\n', ...
		   ' %s\n'],  ...
		  fname, C_FILE_LINE_CHAR));
  end
  % OSP Version 1.50 : Position Data
  %  Position Data
  if isfield(S,'Position'),
    [data,header]=ot2ucdata(S.OSP_LOCALDATA,'Position',S.Position);
  else,
    [data,header]=ot2ucdata(S.OSP_LOCALDATA);
  end
  clear S;
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    save(fname,'data','header','OSP_SP_DATA_VER','-v6');
  else,
    save(fname,'data','header','OSP_SP_DATA_VER');
  end	
  if ishandle(h), waitfor(h); end
end

% ---------------
% Set Output Data
% ---------------
switch OSP_SP_DATA_VER,
 case 2,
  % OSP Version 2.0 
  S=load(fname);
  fldname={'','data','OSP_SP_DATA_VER'}; % Out Put Arguments
  d_def  ={struct,'data','OSP_SP_DATA_VER'}; % Default Value

  if isfield(S,'header') && nargout>=1,
    varargout{1}=S.header;
  else,
    error('Output Argumetn : Header : Error!');
  end

  if isfield(S,'data') && nargout>=2,
    varargout{2}=S.data;
  elseif nargout>=2,
    error('Output Argumetn Error: Data : Error!');
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

if 0
  load(fname,'OSP_LOCALDATA'); 
  % Data Check (but so simple... )
  if ~isfield(OSP_LOCALDATA,'info') || ...
	~isfield(OSP_LOCALDATA,'HBdata') || ...
	~isfield(OSP_LOCALDATA,'HBdataTag') || ...
	~isfield(OSP_LOCALDATA,'HBdata3Tag')
    OSP_LOG('err',['File' fname ' was broken']);
    errordlg([' Cannot Load : ' ...
	      'Broken Data File : ' fname]);
    return;
  end
  OSP_DATA('SET','OSP_LOCALDATA',OSP_LOCALDATA);
else,
  OSP_DATA('SET','OSP_LOCALDATA',[]);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  varargout=saveSignalData(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save OSP Signal - Data.
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
%    [header, data, version] = saveSignalData
%       Save OSP_DATA('GET','OSP_LOCALDATA')
%
%    [header, data, version] = saveSignalData(OST_LOCALDATA)
%       Save OSP_LOCALDATA
%
%--- preprocessor Function IO_Kind : 1 --
%  Syntax : preprocessor Function IO_Kind : 1
%    [header, data, version] = saveSignalData(header,data,version)
%        Save  header and data with format-version version.
%
%    [header, data, version] = saveSignalData(header,data)
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
  else,
    OSP_LOCALDATA = varargin{1};
  end

  % Make Input Data ( named 'inpdata' )
  if ~isfield(OSP_LOCALDATA,'info') || ...
	~isfield(OSP_LOCALDATA,'HBdata') || ...
	~isfield(OSP_LOCALDATA,'HBdataTag') || ...
	~isfield(OSP_LOCALDATA,'HBdata3Tag')
    errordlg([' Cannot Save : ' ...
	      'Signal Preprocessor Data ' ...
	      'is not exist.']);
  end

  [data,header]=ot2ucdata(OSP_LOCALDATA);
  OSP_SP_DATA_VER = 2;
else,
  msg = nargchk(2,3,nargin);
  if ~isempty(msg), error(msg);end

  header = varargin{1};
  data   = varargin{2};
  if nargin>=3,
    OSP_SP_DATA_VER = varargin{3};
    %-- Version Check --
    % now accept onlys 2 :
    if OSP_SP_DATA_VER<2 || OSP_SP_DATA_VER>2,,
      error('OSP SP DATA Version Error');
    end
  else
    OSP_SP_DATA_VER = 2;
  end

end

%===========================
% ----> Rename Option <-----
%===========================
try,
  % get Rename Option
  try
    rnmOpt=OSP_DATA('GET','SP_Rename');
  catch,
    rnmOpt='-';
    OSP_DATA('SET','SP_Rename',rnmOpt);
  end
  if isempty(rnmOpt), rnmOpt='-';
  elseif iscell(rnmOpt), rnmOpt=rnmOpt{1}; end
  
  fname0 = header.TAGs.filename;
  switch rnmOpt,
   case 'Date',
    n2 = datestr(now,1);
    n2 = ['Date_' n2];
   case 'DataLength',
    n2 = num2str(size(data));
    n2 = ['DataSize_' n2];
   case 'ID',
    try,
      if ischar(header.TAGs.ID_number),
	n2 = header.TAGs.ID_number;
      elseif isnumeric(header.TAGs.ID_number),
	n2 = num2str(header.TAGs.ID_number);
      else,
	n2='';
      end
    catch,
      n2 = inputdlg({['OSP : ID Number is not defined in this file' ...
		      ' : Input ID Number ']}, ...
		    'ID Number');
      if isempty(n2), return; end
    end
    if isnumeric(n2), n2=num2str(n2); end
    n2 = ['ID_' n2];
   case 'OriginalName', 
    n2 = fname0;
   case 'InputName'
    in0=OSP_DATA('GET','SP_Rename_IN');
    in0.id = in0.id +1; % Update
    n2 = sprintf('%s_%03d',in0.str,in0.id);
    if isfield(in0,'RN'),
        n2=[n2 in0.RN];
    end
    OSP_DATA('SET','SP_Rename_IN',in0);
   otherwise,
    fname=fname0;
  end % Switch Rename Potion : option
  
  if exist('n2','var'),
    n2 = strrep(n2,' ','_');
    n2 = strrep(n2,'-','_');
    n2 = strrep(n2,'+','_');
    n2 = strrep(n2,'%','_');
    n2 = strrep(n2,'=','_');
    
    n2 = strrep(n2,'/','_');
    n2 = strrep(n2,'\','_Y_');
    
    n2 = strrep(n2,'?','_');
    n2 = strrep(n2,'@','_At_');
    n2 = strrep(n2,'#','_No_');
    fname =n2;
  end
  header.TAGs.filename=fname;
  
catch,
  warndlg({'OSP Warning : ' , ...
	   '  Error Occur About Rename Option' , ...
	   '  * Real Error Message : ', ...
	   '    ',  lasterr}, 'SignalPreprocessor');
  % '  * When SignalPreprocessor Version less than 1.7', ...
  % '    This Error occur Every-time...Check it.', ...
  try,
    clear rnmOpt;
  end
end

%==================================
% Make Input Data ( named 'inpdata' )
%==================================
try
  keys = Keys;
  infodata = header.TAGs;
  %OSP_LOCALDATA.info; 
  inpdata.CreateDate=now;
  for field_id=1:keylen
    inpdata = setfield(inpdata,keys{field_id}, ...
			       getfield(infodata,keys{field_id}));
  end
catch
  errordlg([' Cannot Save : '...
	    'Signal Preprocessor Data '...
	    'may be not Made.' lasterr])
  return;
end
clear infodata;

%==================================
% Renew SignalProcessorFileList
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
if ~exist(dfl,'file')
  signalProcessorFileList(1)=inpdata;
else
  keys = Keys;
  load(dfl,'signalProcessorFileList')
  
  % File Save -- Check File
  c = struct2cell(signalProcessorFileList);
  f = fieldnames(signalProcessorFileList);
  p = find(strcmp(f,keys{IdentifierID}));
  c = squeeze(c(p,:,:));
  % Check Save-Filen-Name
  if sum(strcmp(c,getfield(inpdata,keys{IdentifierID}))) ~=0
    % Exist File
    if exist('rnmOpt','var') && ~strcmp(rnmOpt,'-'),
      % Rename Option : 'On'
      %  Keys{IdentifierID} : filename
      rn_id = strmatch([inpdata.filename '_RN'],c);
      if strcmp(rnmOpt,'InputName'),
          if in0.id==1,
              in0.RN=['_RN' num2str(length(rn_id)+1)];
          else,
              in0.RN=['_RN' num2str(length(rn_id)+1) 'XX'];
          end
          inpdata.filename = [inpdata.filename in0.RN];
          OSP_DATA('SET','SP_Rename_IN',in0);
      else,
          inpdata.filename = [inpdata.filename ...
                  '_RN' num2str(length(rn_id)+1)];
      end
      header.TAGs.filename=inpdata.filename;
    else,
      % Rename Option : 'Off'
      error('Same File-Name exist. Stop to Save');
    end
  end
  clear c f p;
  signalProcessorFileList(end+1) =inpdata;
  varargout{1}=inpdata;
end

%==================================
% Save Signal-Data Version 2.0
%==================================
% Data-File Name : fname
fname=getDataFileName(inpdata);
% Check version of MATLAB.
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  % MALTAB Release 13
  % Save Data with Version 6
  save(dfl,'signalProcessorFileList','-v6');
  save(fname,'data','header','OSP_SP_DATA_VER','-v6');
elseif rver >= 12,
  % Save Data with Version 6
  save(dfl,'signalProcessorFileList');
  save(fname,'data','header','OSP_SP_DATA_VER');
else
  % Can not save Structure ::: MATLAB 4
  error('Version of MATLAB is too old.');
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=save_ow(header,data,OSP_SP_DATA_VER,actdata)
% See also otsigtrnschld
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg=nargchk(3,4,nargin);
  if ~isempty(msg),error(msg);end

  if nargin==4,
	  fname=getDataFileName(actdata.data);
  else,
	  % :: search Same Data :: 
	  actdatadata.filename = header.TAGs.filename;
	  fname=getDataFileName(actdatadata);
  end
  
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
       '(DataDef_SignalPreprocessor:make_timedata) Called']);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_SignalData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(key,'fname'),
  varargout{1} = make_mfile_local(key.actdata.data, ...
				  key.filterManage, ...
				  key.fname);
else,
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
function nm=getFilename(key),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
if ischar(key),
	key2.filename=key;
else,
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

  % connect : OspProject rm_subjectname
  fname = [pj.Path ...
	   OSP_DATA('GET','PROJECT_DATA_DIR') ...
	   filesep 'DataListSignalProcessor.mat'];

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
  fname = ['HB_' data.filename '.mat'];
  fname=[p0 filesep fname];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname = make_mfile_local(data, filterdata, fname)
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% == Open M-File ==
if nargin<3,
  fname = fileparts(which('OSP'));
  fname = [fname filesep 'ospData' filesep];
  t0=clock;t0=round((t0(end)-fix(t0(end)))*1000);
  fname = [fname 'sd_' datestr(now,30) '_' num2str(t0) '.m'];
end
[fid, fname] = make_mfile('fopen', fname,'w');
try,
  SignalData2Mfile(data, filterdata);
catch,
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
  else,
    fn= fileparts(which('OSP'));
    fn= [fn filesep 'ospData' filesep];
    fn= [fn 'sd_' datestr(now,30) '.m'];
  end

  [fid, fn] = make_mfile('fopen', fn,'w');
  try,
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
	   try,
	     str = ...
		 feval(fdata.BlockData(fidx).wrap,'write', ...
		       'BlockData', fdata.BlockData(fidx));
	     if ~isempty(str),
	       make_mfile('with_indent', str);
	     end
	   catch,
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
  catch,
    make_mfile('fclose');
    rethrow(lasterror);
  end
  % == Close M-File ==
  make_mfile('fclose');

    
function ReplaceViewLayout(Layout, key),
%     Layout : ViewLayout cell-array Data
%     key    : active data
  msg=nargchk(2,2,nargin);
  if ~isempty(msg),error(msg);end

  % Load Original Data
  fname=getDataFileName(key.data);
  [header, data, OSP_SP_DATA_VER]=load_SignalData(key);
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
