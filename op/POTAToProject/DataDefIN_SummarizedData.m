function varargout=DataDefIN_SummarizedData(fnc,varargin)
% POTATo's Summarized-Data Function.
%    Summarized-Data is result of 1st-level analysis 
%    in Research-Mode's. 
%
%
%  [id_fieldname] = DataDefIN_SummarizedData('getIdentifierKey')
%     Field Name that identify Summarized-Data.
%     Now id_fieldname is 'Name'
%
%
%  [filelists]  = DataDefIN_SummarizedData('loadlist')
%     Load File List
%
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Since 2011.


% (for Old Extended Search) :: DataDefIN is not use
%  Keys = DataDefIN_SummarizedData('getKeys')
%  [Keys, tag] = DataDefIN_SummarizedData('getKeys')
%     Keys  : Cell structure of Search Key of 
%             Analysis-Data
%     tag   : Example of Search keys with 
%             correspond to Keys
%
% (Other's not in use)
%  [info] = DataDefIN_SummarizedData('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a filelist information.
%
%  [header,data,ver] =  DataDefIN_SummarizedData('load')
%  [header,data,ver] =  DataDefIN_SummarizedData('load',key)
%     Load Raw-Data from File
%     if there is no-key, Read Current Data in Current-Project.
%
%  [filename] = DataDefIN_SummarizedData('make_mfile',key)
%      kye :
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%         kye.fname   is File-Name of make M-File. @since 1.13
%                  this field is omissible.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12
%
%  [filename] = DataDefIN_SummarizedData('make_mfile_useblock',key)
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
%  [header, data] = DataDefIN_SummarizedData('make_ucdata',key)
%      key : ( same as make_mfile )
%         key.actdata is Raw-Data
%         key.filterManage is Filter-Management-Data
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12
%
%  [strHBdata, plot_kind] =
%          DataDefIN_SummarizedData('make_timedata', key)
%      Make HBdata for plot, and using plot
%
%  DataDefIN_SummarizedData('save')
%     Save Current Data
%  DataDefIN_SummarizedData('save',header,data,OSP_SP_DATA_VER);
%     Save header, data as OSP_SP_VER
%
%  DataDefIN_SummarizedData('save_ow',header,data,OSP_SP_DATA_VER,actdata)
%     Save Current Data -> Over-Write Mode
%
%  DataDefIN_SummarizedData('UpdateDataKey',key) 
% 
%  DataDefIN_SummarizedData('reshapeName',name)


% == History ==
% original author : Masanori Shoji
% create : 2010.11.18
% $Id: DataDefIN_SummarizedData.m 346 2013-04-23 05:50:00Z Katura $
%
% 2010.11.18:
%   Import form DataDef2_Analysis
%   (2010_2_RA03)
% 2010.12.06 : Change term
%              Sumarized-Data -> Summary Stastic

%##########################################################################
% Launcher
%##########################################################################

%-------------------------
%  POTATo : Running Check
%-------------------------
if ~OSP_DATA('GET','isPOTAToRunning')
  errordlg({' POTATo is not runing!', ...
    '  please type "POTATo" at First!"'});
  return;
end

if nargin==0, fnc='help'; end
%-------------------------
% Switch
%-------------------------
switch fnc,
  case {'help'}
    help_SummarizedData;
  case {'save'}
    saveSummarizeData(varargin{:});
  case {'load'}
    [varargout{1:nargout}] = loadSummarizeData(varargin{:});
  case {'getIdentifierKey','loadlist','save_ow',...
      'deleteGroup','deleteData','update_comment'}
    if nargout,
      [varargout{1:nargout}] = feval(fnc, varargin{:});
    else
      feval(fnc, varargin{:});
    end
  otherwise
    error('Not Implemented Function : %s',fnc);
end
return;

%##########################################################################
% Definition Function
%##########################################################################
function key = Keys
% Definition of Search Keys,
%  (for Extended Search for future)
key={'Name','Comment','ExeFunction'};

function id=IdentifierID
% 'Name is Identifiled
id =1;                     % Identifier ID

function keyname=getIdentifierKey
% 
k = Keys;
keyname=k{IdentifierID};

%--------------------------------------------------------------------------
function fname=getDataListFileName
%  Get Data List File Name of Summarized Data
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  errordlg(' Open Project at First!');
  error(' Open Project at First!');
end

path0 =OSP_DATA('GET','PROJECTPARENT');
if ~strcmpi(path0,pj.Path),
  warndlg('Project Data might be broken','Summarized Data Warning');
  pj.Path=path0;OSP_DATA('SET','PROJECT',pj);
end

% Make File Name
fname = [path0 filesep pj.Name filesep ...
  'DataListIN_SummarizedData.mat'];
return;

%--------------------------------------------------------------------------
function fname=getDataFileName(data)
% Get Data File Name of Summarized Data
dfl=getDataListFileName;
p0 = fileparts(dfl); % get save path
nm=reshapeName(data.(getIdentifierKey));
% connect : OspProject rm_subjectname
fname = [nm '.mat'];
fname=[p0 filesep fname];
return;


%##########################################################################
% Tools
%##########################################################################
function help_SummarizedData
% Help
POTATo_Help(mfilename)

%##########################################################################
% Save
%##########################################################################
function saveSummarizeData(datax)
% Save Summarized Data 
%   Upper-Link : P3_gui_Research_1st/psb_R1st_Save_Callback
if isfield(datax,'Name')
  % datax is Data-Format
  dataf=datax;
else
  % datax is Active-Data Format
  dataf=datax.data;
end

%----------------
% Update List
%----------------
li=rmfield(dataf,'data'); % List Data
datalist = loadlist;
if ~isempty(datalist)
  % if exist Name ...
  if any(strcmp({datalist.(getIdentifierKey)},li.(getIdentifierKey)))
    error('Same Name-Data exist. Cannot Make Summarized Data');
  end
  datalist(end+1) =li;
else
  % New Data
  datalist =li;
end

%----------------
% Save
%----------------
% get Save File Name & Rename Variable
dfl=getDataListFileName;
SummarizedDataFileList = datalist;     %#ok save-name
% Save File
SummarizedData         = dataf;        %#ok save-name

fname=getDataFileName(dataf);
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'SummarizedDataFileList','-v6');
  save(fname,'SummarizedData','-v6');
else
  save(dfl,'SummarizedDataFileList');
  save(fname,'SummarizedData');
end

%----------------
% Create RelationFile
%----------------
addRelation(dataf);
return;  

function save_ow(datax)
% Over-Write Save Summarized Data 
%   Upper-Link : P3_gui_Research_1st/mnu_R1st_ANA2SMD_Callback
%                P3_gui_Research_1st/psb_R1st_Change_Callback
% 1. Update Data (with list)
% 2. Delete Relation of Ana-Summarized
% 3. Add    New Relation..

% Save Summarized Data 
%   Upper-Link : P3_gui_Research_1st/psb_R1st_Save_Callback
if isfield(datax,'Name')
  % datax is Data-Format
  dataf=datax;
else
  % datax is Active-Data Format
  dataf=datax.data;
end

%----------------
% Update List
%----------------
li=rmfield(dataf,'data'); % List Data
datalist = loadlist;
if ~isempty(datalist)
  % if exist Name ...
  myid=strcmp({datalist.(getIdentifierKey)},li.(getIdentifierKey));
  myid=find(myid);
  if length(myid)~=1
    error('No corresponding data');
  end
  datalist(myid) =li;
else
  % New Data
  error('No corresponding data');
end

%----------------
% Save
%----------------
% get Save File Name & Rename Variable
dfl=getDataListFileName;
SummarizedDataFileList = datalist;     %#ok save-name
% Save File
SummarizedData         = dataf;        %#ok save-name

fname=getDataFileName(dataf);
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'SummarizedDataFileList','-v6');
  save(fname,'SummarizedData','-v6');
else
  save(dfl,'SummarizedDataFileList');
  save(fname,'SummarizedData');
end

%----------------
% Create RelationFile
%----------------
changeRelation(dataf);
return;  

function update_comment(datax)
% Update Comment
%   Upper-Link : P3_gui_Research_1st/psb_R1st_ChangeComment_Callback
% 1. Update Data Comment

% Load Save Summarized Data 
%   Upper-Link : P3_gui_Research_1st/psb_R1st_Save_Callback
if isfield(datax,'Name')
  % datax is Data-Format
  dataf=datax;
else
  % datax is Active-Data Format
  dataf=datax.data;
end

%----------------
% Update List
%----------------
datalist = loadlist;
if ~isempty(datalist)
  % if exist Name ...
  myid=strcmp({datalist.(getIdentifierKey)},dataf.(getIdentifierKey));
  myid=find(myid);
  if length(myid)~=1
    error('No corresponding data');
  end
  datalist(myid).Comment=dataf.Comment;
else
  % New Data
  error('No corresponding data');
end

%----------------
% Save
%----------------
% get Save File Name & Rename Variable
dfl=getDataListFileName;
SummarizedDataFileList = datalist;     %#ok save-name
% Save File
SummarizedData=loadSummarizeData(datax);
SummarizedData.Comment=dataf.Comment;

fname=getDataFileName(dataf);
% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'SummarizedDataFileList','-v6');
  save(fname,'SummarizedData','-v6');
else
  save(dfl,'SummarizedDataFileList');
  save(fname,'SummarizedData');
end

return;  

%##########################################################################
% Load
%##########################################################################
function SummarizedDataFileList=loadlist(key)
% Key : When empty / noting
%       Load all File-List
% Key : Data-format
%       Load File-List correspond to key
% Key : Key Name
%       Load File-List correspond to key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dfl=getDataListFileName;
if exist(dfl,'file')
  load(dfl,'SummarizedDataFileList')
else
  % No Analysis-Data FileList
  SummarizedDataFileList={};
end

if ~exist('SummarizedDataFileList','var') || ...
    isempty(SummarizedDataFileList)
  % No Data : Exist
  SummarizedDataFileList={};
  return;
end
if (nargin==0), return;end
if isempty(key); return; end

% Load Key-Name
if isstruct(key)
  key=key.(getIdentifierKey);
end

SummarizedDataFileList = ...
  SummarizedDataFileList(strcmp({SummarizedDataFileList.(getIdentifierKey)},key));

function SummarizedData=loadSummarizeData(datax) %#ok (load)
% Load Summarized Data 
%  (Add Real-Data-field to Data-Format)

% reform: Get Data-Format
if isfield(datax,'Name')
  % if datax is Data-Format
  dataf=datax;
else
  % if datax is Active-Data Format
  dataf=datax.data;
end

% Get File Name
fname=getDataFileName(dataf);
% File check
if ~exist(fname,'file'),
  % Error No Data File exist:
  deleteData(dataf);
  OSP_LOG('perr', ...
    [ ' In Loading Data, File (' fname ') not exist']);
  error([' File Lost : ' fname]);
end

% ---------------
% Load Data
% ---------------
load(fname,'SummarizedData');
% TODO : Data Check
return;

%##########################################################################
% for Relation
%##########################################################################
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=reshapeName(key)
% Return : Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end
% try
% 	[p, dname, ext, ver] = fileparts(key);%#ok
% 	nm = [dname ext ver];
% catch
% 	[p, dname, ext] = fileparts(key);%- for upper MATLAB2011b
% 	nm = [dname ext];
% end
[p, dname, ext] = fileparts(key);%- for upper MATLAB2011b
nm = [dname ext];

nm = strrep(nm,'+','_');
nm = strrep(nm,'-','_');
nm = strrep(nm,':','_l_');
nm = strrep(nm,'&','A');
nm = strrep(nm,'.','_');
nm = strrep(nm,' ','');
nm = ['SMD_' nm];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  addRelation(dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
name0=getDataFileName(dt);
if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(dt.(getIdentifierKey));  % 'SMD_*'
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
  
  idkey2=DataDef2_Analysis('getIdentifierKey');
  for idx2=1:dt.data.nfile
		nm2=DataDef2_Analysis('reshapeName',dt.data.AnaFiles{idx2}.(idkey2));
		if isfield(Relation,nm2)
		  % Add Relation  
      snm.Parent{end+1}=nm2;
      Relation.(nm2).Children{end+1}=nm;
    else
		  % No Data Exist -
      try
        % Add...
        d0=DataDef2_Analysis('loadlist',dt.data.AnaFiles{idx2}.(idkey2));
        d.name=nm2;
        d.data=d0;
        d.fcn='DataDef2_Analysis';
        d.Parent={};
        d.Children={nm};
        Relation.(nm2)=d;
      catch
        % or delete me.
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

function changeRelation(dt)
% Change Relation
%   Delete Apper's
name0=getDataFileName(dt);
if exist(name0,'file'),
  % File Exist Make Relation Data
  nm=reshapeName(dt.(getIdentifierKey));  % 'SMD_*'

	% Get RelationData-File's name, Relation-Data
	fname = getRelationFileName;
  load(fname,'Relation');
  oldsnm=Relation.(nm); %#ok
  idkey2=DataDef2_Analysis('getIdentifierKey');
  % Delete Old Relation
  for ii=1:length(oldsnm.Parent)
    tmp=Relation.(oldsnm.Parent{ii});
    tmp.Children(strcmp(tmp.Children,nm))=[];
    Relation.(oldsnm.Parent{ii})=tmp;
  end
  snm=oldsnm;
  snm.Parent={};
  % Add Relation
  for idx2=1:dt.data.nfile
		nm2=DataDef2_Analysis('reshapeName',dt.data.AnaFiles{idx2}.(idkey2));
		if isfield(Relation,nm2)
		  % Add Relation  
      snm.Parent{end+1}=nm2;
      Relation.(nm2).Children{end+1}=nm;
    else
		  % No Data Exist -
      try
        % Add...
        d0=DataDef2_Analysis('loadlist',dt.data.AnaFiles{idx2}.(idkey2));
        d.name=nm2;
        d.data=d0;
        d.fcn='DataDef2_Analysis';
        d.Parent={};
        d.Children={nm};
        Relation.(nm2)=d;
      catch
        % or delete me.
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


%##########################################################################
% Delete Control (2010_2_RA04-5)
%##########################################################################
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteGroup(datax)
% Delete Summarized-Data, with Relation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------
% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

% reform: Get Data-Format
if isfield(datax,'Name')
  % if datax is Data-Format
  dataf=datax;
else
  % if datax is Active-Data Format
  dataf=datax.data;
end
nm=reshapeName(dataf.(getIdentifierKey));

% ===================================
% Load Relation & Get Children list
% ===================================
relfile=getRelationFileName;
try
  clist = FileFunc('getChildren', relfile, nm);
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
    ' Summarized-Data Children List:'...
    [ '      ' nm]};
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
clist{end+1}=nm;
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
  FileFunc('clearParent', relfile, nm);
catch
  % Error : Dialog
  errordlg(lasterr);
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteData(datax)
% Delete Summarized-Data, anyway
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------
% Argument Check
%----------------------------
msg=nargchk(1,1,nargin);
if ~isempty(msg), error(msg); end

% reform: Get Data-Format
if isfield(datax,'Name')
  % if datax is Data-Format
  dataf=datax;
else
  % if datax is Active-Data Format
  dataf=datax.data;
end

%----------------------------
% Delete Data from list ;
%----------------------------
datalist = loadlist;
if ~isempty(datalist)
  % if exist Name ...
  myid=strcmp({datalist.(getIdentifierKey)},dataf.(getIdentifierKey));
  myid=find(myid);
  if length(myid)~=1
    error('No corresponding data');
  end
  datalist(myid) =[];
else
  % New Data
  error('No corresponding data');
end

% get Save File Name & Rename Variable
dfl=getDataListFileName;
SummarizedDataFileList = datalist;     %#ok save-name

% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
if rver >= 14,
  save(dfl,'SummarizedDataFileList','-v6');
else
  save(dfl,'SummarizedDataFileList');
end

%----------------------------
% Delete Real-Data File
%----------------------------
delfname  = getDataFileName(dataf);
if exist(delfname, 'file'),
  delete(delfname);
end

return;

%function disconnectAnaData(datax) %#ok
% TODO: may be 
