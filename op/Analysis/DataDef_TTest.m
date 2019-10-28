function varargout=DataDef_TTest(mode, key,varargin)
% Data Definition of T-Test Ana lying
%
%  Keys = DataDef_TTest('getKeys')
%     return Cell structure of Search Key of T-Test
%  [Keys, tag] = DataDef_TTest('getKeys')
%     tag is Example of Search keys
%     correspond to Keys
%          
%
%  [id_fieldname] = DataDef_TTest('getIdentifierKey')
%     Identifier of the Data.
%     This Key must be unique
%
%  [filelists]  = DataDef_TTest('loadlist')
%     Load File List
%
%  [info] = DataDef_TTest('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a file-list information.
%
%  [AnalysingResult ] = DataDef_TTest('load')
%  [AnalysingResult ] = DataDef_TTest('load',activedata)
%     Load File List from Active Data
%       -> and set corresponding data
%
%  [data] = DataDef_TTest('new',key)
%     data is full set of data, 
%     key is result of ttest
%
%  DataDef_TTest('save')
%     Save Current Data
%
%  [strHBdata, plot_kind] =
%          DataDef_TTest('make_timedata', key)
%      Make HBdata for plot, and using plot
%


% ===================================================================================
% Copyright(c) 2019, National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ===================================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.03.04
% $Id: DataDef_TTest.m 180 2011-05-19 09:34:28Z Katura $

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
      'Tag',         'Group[AB][1-9]', ...
      'ID_number',   '1' ,...
      'Comment',     'Calculation', ...
      'CreateDate',  'now'); % Search key Example
  IdentifierID=1;                     % Identifier ID

  keylen = length(Keys);

  % =================
  %   Argument Check
  % =================
  if OSP_DATA==0
    error(' OSP is not ruining!');
  end

  % =================
  %   Definition
  % =================

  switch mode

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'showinfo'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize
    fileData=key;   % Here Set T Test Data
    if ~isstruct(fileData)
      varargout{1}={' === No Information =='};
      return;
    end

    % Additional Data
    try
      if isfield(fileData,'data')
	addInfo = {' ', ' -- Test Type --'};
	try
	  addInfo{end+1} = fileData.data.TestMode;
	end
	try
	  addInfo{end+1} = ['Measure Mode  ; ' ...
			    num2str(fileData.data.MeasureMode)];
	end
	fileData  = rmfield(fileData,'data');
      end
    end

    infoStr={' -- T Test Info --'};
    
    % Get Data
    c = OspDataFileInfo(0,1,fileData);
    try
      [infoStr{2:length(c)+1}]=deal(c{:}); 
    catch
      vargout{1}={[mfilename ' : ' lasterr ]};
    end
    clear c;
        
    if exist('addInfo','var')
      infoStr = {infoStr{:} addInfo{:}};
    end
    varargout{1}=infoStr;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   case 'loadlist'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    dfl=getDataListFileName;
    if exist(dfl,'file')
      load(dfl,'TTestFileList')
    end
    if exist('TTestFileList','var')
      varargout{1}=TTestFileList;
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
   case 'New'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~exist('key','var')
      key=[];
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
    ans0 = inputdlg(prompt, 'T Test Data Setting', 1, def);
    if isempty(ans0)
      % varargout{1}=struct([]); return;
      % for Matlab Relase 7.0 or later.
      varargout{1}=[]; return;
    end
    for ii=1:length(Keys)
      switch Keys{ii}
       case 'Tag'
	data.Tag = ans0{ii};
       case 'ID_number'
	data = setfield(data, Keys{ii}, str2num(ans0{ii}));
       case 'CreateDate'
	data = setfield(data, Keys{ii}, datenum(ans0{ii}));
       otherwise
	data = setfield(data, Keys{ii}, ans0{ii});         
      end
    end
	  
    data.data=key;
    % -- Check Unique Indent Filer Key
    DataDef_TTest('save', data);

    % --- Out Put ---
    varargout{1}=data;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'save'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also 'New'
	
    if ~exist('key','var')
      error('Can not save T Test Result');
    end
    data = key;
	
    datalist = DataDef_TTest('loadlist');
	
    % File Save -- Check File
    if isfield(data, 'data')
      data_tmp = rmfield(data,'data');
    end
    if ~isempty(datalist)
      c = struct2cell(datalist);
      f = fieldnames(datalist);
      p = find(strcmp(f,Keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(data,Keys{IdentifierID}))) ~=0
		  error('Same Tag File exist. Cannot Make T-Test Data');
      end
      clear c f p;
      datalist(end+1) =data_tmp;
    else
      datalist =data_tmp;
    end
	
    % 
    dfl=getDataListFileName;
    TTestFileList = datalist;
    save(dfl,'TTestFileList');

    % Save File
    TTestData = data;
    fname=getDataFileName(data);
    save(fname,'TTestData');
		
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'load'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    % File Name Setting  : --> See save
    fname=getDataFileName(actdata.data);

    % File check
    if ~exist(fname,'file')
      OSP_LOG('perr', ...
	      [ ' In Loading Data, File (' ...
		dfl ') not exist']);
      error([' File Lost : ' dfl]);
    end

    % 
    load(fname,'TTestData');
    % Data Check (but so simple... )
    if ~exist('TTestData','var') || ...
	  ~isfield(TTestData,'data') || ...
	  ~isfield(TTestData,'Tag') || ...
	  ~isfield(TTestData,'ID_number')
      OSP_LOG('perr',['File' fname ' was broken']);
      errordlg([' Cannot Load : ' ...
		'Broken Data File : ' fname]);
      return;
    end

    varargout{1} = TTestData;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'save_ow'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also otsigtrnschld

    if ~exist('key','var')
      error('Can not use save for GroupData');
    end
    data = key;
    
    datalist = DataDef_TTest('loadlist');
	
    % File Save -- Check File
    if ~isempty(datalist)
      c = struct2cell(datalist);
      f = fieldnames(datalist);
      p = find(strcmp(f,Keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(data,Keys{IdentifierID}))) ~=1
		  error('Can not Overwrite. Can not determine original file');
      end
      clear c f p;
    else
      error('Can not Overwrite, There is no original file');
    end

    % Save File
    TTestData = data;
    fname=getDataFileName(data);
    save(fname,'TTestData');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'make_timedata'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    actdata    = key.actdata;
    kind       = key.plot_kind;

    % == Load  T-Test Data ==
    if ~isfield(actdata.data,'data')
      actdata.data = DataDef_TTest('load', actdata.data);
    end
    ttestdata = actdata.data.data;

    %  Get Plot Kind
    plotkind =  []; plotkind2=[];
    try
      if kind.oxy,   plotkind=[plotkind, 1]; end
      if kind.deoxy, plotkind=[plotkind, 2]; end
      if kind.total, plotkind=[plotkind, 3]; end
    end

    % Make Stimtime
    [tag{1:length(plotkind)}] = deal(ttestdata.Tag{plotkind});
    plotkind = 1:length(plotkind);

    plotdata.testmoode   = ttestdata.TestMode;
    plotdata.measuremode = ttestdata.MeasureMode;
    plotdata.data = ttestdata.Data(:,:,plotkind);
    plotdata.tag  = tag;
    plotdata.stim = [];
    
    varargout{1} = plotdata;
    varargout{2} = plotkind;

   otherwise
    error([' Argument Error : ' mode ' is not defined']); 
  end


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataListFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get Data List File Name of 
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    errordlg(' Open Project at first!');
    error(' Open Project at first!');
  end

  fname = [pj.Path ...
	   OSP_DATA('GET','PROJECT_DATA_DIR') ...
	   filesep 'DataListTTest.mat'];

return;

function fname=getDataFileName(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get Data File Name of 
%     SignalProcessor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name Setting  : --> See save
  dfl=getDataListFileName;
  [p0, n1] = fileparts(dfl); % get save path
  fname = ['TT_' data.Tag '.mat'];
  fname=[p0 filesep fname];
return;
