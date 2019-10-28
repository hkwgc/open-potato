function varargout=DataDef_FilterData(mode, key)
% Data Definition of Block Filter Data Result
%
%  Keys = DataDef_FilterData('getKeys')
%     return Cell structure of Search Key of FilterData Data
%  [Keys, tag] = DataDef_FilterData('getKeys')
%     tag is Example of Search keys
%     correspond to Keys
%          
%
%  [id_fieldname] = DataDef_FilterData('getIdentifierKey')
%     Identifier of the Data.
%     This Key must be unique
%
%  [filelists]  = DataDef_FilterData('loadlist')
%     Load File List
%
%  [info] = DataDef_FilterData('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a file-list information.
%
%  [FilterData ] = DataDef_FilterData('load')
%  [FilterData ] = DataDef_FilterData('load',activedata)
%     Load File List from Active Data.
%       -> and set corresponding data.
%
%  DataDef_FilterData('save')
%     Save Current Data.
%
%  DataDef_FilterData('save_ow')
%     Save Current Data -> Over-Write Mode.
%
%  [filename] = DataDef_FilterData('make_mfile',key)
%      key :
%        ( case 1)
%         key.actdata is Group-Data.
%         key.filterManage is Filter-Management-Data.
%         kye.fname   is File-Name of make M-File. @since 1.12
%                 this field is omissible.
%       (case 2)
%         Group-Data.
%      filename :
%         File-name of made M-File.
%      This mehtod is added since reversion 1.12.
%
%  [data, header] = DataDef_FilterData('make_ucdata',key)
%      kye : ( same as make_mfile )
%         key.actdata is Group-Data.
%         key.filterManage is Filter-Management-Data.
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12.
%
%  [strHBdata, plot_kind] =
%          DataDef_FilterData('make_timedata', key)
%      Make HBdata for plot, and using plot
%
% ---> Special Key
%  groupdata = DataDef_FilterData('NewFilter', key)
%      Make New Group-Data
%      key : Save FilteData
%
%  [info linfo kindlist] = DataDef_FilterData('showblocks',key)
%      get Information of each-Block Data 
%       &  line-information


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original author : Masanori Shoji
% create : 2005.02.04
% $Id: DataDef_FilterData.m 180 2011-05-19 09:34:28Z Katura $
%
% Reversion 1.10
%    * Change Print Unit of time.
%    * (Easter egg)
%      BasicData for DataDef_FilterData.
%    * Use M-File of OSP ver 1.10.
%      For Filtering, do not use OspFilterMain, but M-File
%
% Reversion 1.11
%  remove BasicData
%  Add 'make_mfile',
%  Add 'make_ucdata'.
%  Mod : when use Matlab 7 or latter
%        save -v6.
%
% Reversino 1.12
%  Mod : 'make_file'
%    add filename for an input argument.
  if nargin==0
    OspHelp(mfilename)
    return;
  end

  % =================
  %   Definition
  % =================
  % Warning : filename is  using in signal_preprocessor!
  %           Do not rename, without changing signal_preprocessor.
  Keys={'Tag', 'ID_number',...
	'Comment'}; % Search keys 
  
  searchexampl  = struct( ...
      'Tag',         'FILTER_[AB][1-9]', ...
      'ID_number',   '1' ,...
      'Comment',     'Mode', ...
      'CreateDate',  'now'); % Search key Example
  IdentifierID=1;                     % Identifier ID

  keylen = length(Keys);

  % =================
  %   Argument Check
  % =================
  if OSP_DATA==0
    error(' OSP is not runing!');
  end

  % =================
  %   Definition
  % =================

  switch mode

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'showinfo'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize
    fileData=key;   % Here Set Group Data
    if ~isstruct(fileData),
      varargout{1}={' === No Information =='};
      return;
    end
    if isfield(fileData,'data'),
      fileData=rmfield(fileData,'data');   % Here Set Group Data
    end
    infoStr={' -- Filter Data File Info --'};
    % Get Data
    c = OspDataFileInfo(0,1,fileData);
    try
      [infoStr{2:length(c)+1}]=deal(c{:});
    catch
      vargout{1}={[mfilename ' : ' lasterr ]};
    end
    clear c;
    varargout{1}=infoStr;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'loadlist'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    dfl=getDataListFileName;
    if exist(dfl,'file')
      load(dfl,'FilterDataFileList')
    end
    if exist('FilterDataFileList','var')
      varargout{1}=FilterDataFileList;
    else
      varargout{1}={};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'getKeys'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Keys{end+1}='CreateDate';
    varargout{1}=Keys;
    varargout{2}=searchexampl;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'getIdentifierKey'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    varargout{1}=Keys{IdentifierID};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'NewFilter'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('key','var')
      error('No Saving Data');
    end
    
    % === Setting Information ===
    Keys{end+1}='CreateDate';
    prompt=Keys;
    def={};
    for ii=1:length(Keys)
      switch Keys{ii}
       case 'Tag'
	def{end+1}='Untitled';
       case 'ID_number'
	def{end+1}='1';
       case 'CreateDate'
	def{end+1}=datestr(now);
       otherwise
	def{end+1} = '';
      end
    end
    
    ng_flag=1;
    while(ng_flag),
      ans0 = inputdlg(prompt, 'Filter Data Setting', 1, def);
      if isempty(ans0)
	varargout{1}=[]; return;
      end
      
      for ii=1:length(Keys)
	switch Keys{ii}
	 case 'Tag'
	  gdata.Tag = ans0{ii};
	 case 'ID_number'
	  gdata = setfield(gdata, Keys{ii}, str2num(ans0{ii}));
	 case 'CreateDate'
	  gdata = setfield(gdata, Keys{ii}, datenum(ans0{ii}));
	 otherwise
	  gdata = setfield(gdata, Keys{ii}, ans0{ii});         
	end
      end
	  
      gdata.data=key;

      % -- Check Unique Indent Filer Key
      try,
	DataDef_FilterData('save', gdata);
	ng_flag=0;
      catch,
	waitfor(errordlg(lasterr));
	def=ans0;
      end
    end

    % --- Out Put ---
    varargout{1}=gdata;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'save'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also otsigtrnschld
    if ~exist('key','var')
      error('No Saving Data');
    end
    gdata = key;
	
    gdatalist = DataDef_FilterData('loadlist');
    if ~isempty(gdatalist)
      c = struct2cell(gdatalist);
      f = fieldnames(gdatalist);
      p = find(strcmp(f,Keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(gdata,Keys{IdentifierID}))) ~=0
	error('Same Tag File exist. Cannot Make Filter Data');
      end
      clear c f p;
      gdatalist(end+1) =gdata;
    else
      gdatalist =gdata;
    end
	
    % 
    dfl=getDataListFileName;
    FilterDataFileList = gdatalist;
    % Save File

    % Save : 
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(dfl,'FilterDataFileList','-v6');
    else,
      save(dfl,'FilterDataFileList');
    end

		
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'load'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do nothing..
    % See also save
    if ~exist('key','var')
      actdata = OSP_DATA('GET','ACTIVEDATA');
      if isempty(actdata )
	OSP_LOG('perr','No ''Active Data'' exist');
	error('No ''Active Data'' exist');
      end
    else
      actdata.data = key;
    end
    varargout{1} = actdata;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'save_ow'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also otsigtrnschld
    if ~exist('key','var')
      error('Can not use save for FilterData');
    end
    gdata = key;
    gdatalist = DataDef_FilterData('loadlist');
	
    % File Save -- Check File
    if ~isempty(gdatalist)
      c = struct2cell(gdatalist);
      f = fieldnames(gdatalist);
      p = find(strcmp(f,Keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(gdata,Keys{IdentifierID}))) ~=1
	error('Can not Overwrite. Can not determine original file');
      end
      id = find(strcmp(c,getfield(gdata,Keys{IdentifierID}))==1);
      clear c f p;
    else
      error('Can not Overwrite, There is no original file');
    end
    
    % Save File
    FilterData = gdata;
    gdatalist(id)=FilterData;
    FilterDataFileList = gdatalist;
    dfl=getDataListFileName;
    % Save File
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(dfl,'FilterDataFileList','-v6');
    else,
      save(dfl,'FilterDataFileList');
    end
    if nargout>=1,
      varargout{1} = FilterData;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'make_mfile'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('No M-File to Make');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'make_ucdata'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('No Data correspond to Out-put');
   otherwise
    error([' Argument Error : ' mode ' is not defined']); 
  end


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataListFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get Data List File Name of 
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  isrun=OSP_DATA('GET','isPOTAToRunning');
  if isempty(isrun),isrun=false;end
catch
  isrun=false;
end

if isrun,
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    errordlg(' Open Project at first!');
    error(' Open Project at first!');
  end

  path0 =OSP_DATA('GET','PROJECTPARENT');
  if ~strcmpi(path0,pj.Path),
    warning('Project Data might be broken');
  end

  % connect : OspProject
  fname =[path0 ...
    filesep pj.Name ...
    filesep 'DataListFilterData.mat'];
else
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    errordlg(' Open Project at first!');
    error(' Open Project at first!');
  end
  
  fname = [pj.Path ...
    OSP_DATA('GET','PROJECT_DATA_DIR') ...
    filesep 'DataListFilterData.mat'];
end
return;

function fname = make_mfile_local(groupdata, filterdata, fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make M-File of FilterData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  error('No M-File to Make');
return;
