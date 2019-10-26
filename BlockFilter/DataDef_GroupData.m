function varargout=DataDef_GroupData(fnc, varargin)
%function varargout=DataDef_GroupData(mode, key)
% Data Definition of Block Filter Data Result
%
%  Keys = DataDef_GroupData('getKeys')
%     return Cell structure of Search Key of GroupData Data
%  [Keys, tag] = DataDef_GroupData('getKeys')
%     tag is Example of Search keys
%     correspond to Keys
%          
%
%  [id_fieldname] = DataDef_GroupData('getIdentifierKey')
%     Identifier of the Data.
%     This Key must be unique
%
%  [filelists]  = DataDef_GroupData('loadlist')
%     Load File List
%
%  [info] = DataDef_GroupData('showinfo',key)
%     info is 'Cell Array of  string'.
%             strings is a file-list information.
%
%  [GroupData ] = DataDef_GroupData('load')
%  [GroupData ] = DataDef_GroupData('load',activedata)
%     Load File List from Active Data.
%       -> and set corresponding data.
%
%  DataDef_GroupData('save')
%     Save Current Data.
%
%  DataDef_GroupData('save_ow')
%     Save Current Data -> Over-Write Mode.
%
%  [filename] = DataDef_GroupData('make_mfile',key)
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
%  [data, header] = DataDef_GroupData('make_ucdata',key)
%      kye : ( same as make_mfile )
%         key.actdata is Group-Data.
%         key.filterManage is Filter-Management-Data.
%      data, header :
%         Continuous data of UserCommand.
%      This mehtod is added since reversion 1.12.
%
%  [strHBdata, plot_kind] =
%          DataDef_GroupData('make_timedata', key)
%      Make HBdata for plot, and using plot
%
% ---> Special Key
%  groupdata = DataDef_GroupData('NewGroup')
%      Make New Group-Data
%
%  [info linfo kindlist] = DataDef_GroupData('showblocks',key)
%      get Information of each-Block Data 
%       &  line-information
%
%  DataDef_GroupData('ReplaceViewLayout',Layout, key);
%     Replace View-Layout Data
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
% orignal author : Masanori Shoji
% create : 2005.02.04
% $Id: DataDef_GroupData.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision 1.10
%    * Change Print Unit of time.
%    * (Easter egg)
%      BasicData for DataDef_GroupData.
%    * Use M-File of OSP ver 1.10.
%      For Filtering, do not use OspFilterMain, but M-File
%
% Revition 1.11
%  remove BasicData
%  Add 'make_mfile',
%  Add 'make_ucdata'.
%  Mod : when use Matlab 7 or latter
%        save -v6.
%
% Revistion 1.12
%  Mod : 'make_file'
%    add filename for an input argument.
%
% Revision 1.24
%  Add : 'ReplaceViewLayout '
%        for Signal-Viewer II
%  Date : 10-Feb-2006

  % =================
  %   Argument Check
  % =================
  if OSP_DATA==0
        errordlg({' OSP is not runing!', ...
                        '  please type "OSP" at first."'});
        return;
  end

  if nargin==0
        errordlg('DataDef_GroupData Need Arguments!');
        fnc='help';
  end

  switch fnc,
        case 'load',
                fnc='loadGroupData';
        case 'save',
                fnc='saveGroupData';
        case 'make_mfile'
                fnc='make_mfile_GroupData';
        case 'help'
                fnc='help_GroupData';
  end

  if nargout,
        [varargout{1:nargout}] = feval(fnc, varargin{:});
  else,
        feval(fnc, varargin{:});
  end
return;

% =================
%   Definition
% =================
function key = Keys,
% Definition of Setrch Keys,
% Warning : filename is  using in GroupData
%           Do not rename, without changing GroupData.
  key={'Tag', 'ID_number',...
	'Comment'}; % Search keys 
return;
  
function exampl_struct = searchexampl,
% Definition of ExampleKeys
  exampl_struct  = struct( ...
      'Tag',         'Group[AB][1-9]', ...
      'ID_number',   '1' ,...
      'Comment',     'Calculation', ...
      'CreateDate',  'now'); % Search key Example
return;

function id = IdentifierID,
  id=1;                     % Identifier ID
return;

function n = keylen,
  n = length(Keys);
return;

function help_GroupData(varargin)
% Ignore varargin now..
  OspHelp(mfilename)
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm=reshapeName(key),
% Return : Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg=nargchk(1,1,nargin);
  if ~isempty(msg), error(msg); end

  [path, dname, ext, ver] = fileparts(key);
  if ~strcmp(ext ,'.mat'),      % delete '.mat'
    dname = key;
  end
  nm = dname;
  s = regexp(nm(1),'[a-zA-Z]');
  if isempty(s),
    nm = ['D' nm];
  end
  nm = strrep(nm,'.','_');
  nm = strrep(nm,' ','');
  nm = ['GD_' nm];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteGroup(key),
% Return : Relation-File Variable Name
%   Relation Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg=nargchk(1,1,nargin);
  if ~isempty(msg), error(msg); end

  dname = reshapeName(key);
  if isempty(dname),
      error('lack name of DataDef_GroupData.');
  end   
    
  % -- Reset project
  [prjct, relfile] = resetProject;
  % -- Get Children list
  clist = FileFunc('getChildren', relfile, dname);
    
  % -- Delete this file and this children's
  % Use uigetpref?
  dflag=OSP_DATA('GET','ConfineDeleteDataGD');
  if dflag,
    cname={'Are you sure ?'...
	   ' '...
	   'Children List:'...
	   [ '      ' dname]};
    for i=1:length(clist),
      cname{end+1} = [ '      ' clist{i}];
    end
    btn = questdlg(cname, ...
		   'GroupData Children List',...
		   'Yes', 'No', 'Always','Yes');
	
    if strcmp(btn, 'No'),return; end
    if strcmp(btn,'Always'),
      OSP_DATA('SET','ConfineDeleteDataGD',false);
    end
  end

  % -- Delete own file ,too
  clist{end+1}=dname;
  for i=1:length(clist),
    try,
      % Load Relation of Clist(clist) from
      % Relation file(relfile)
      load(relfile, clist{i});
      data = eval([clist{i} '.data']);
      fcn  = eval([clist{i} '.fcn']);
      %%
      feval(fcn, 'deleteData', data);
    catch,
      % Error : Dialog
      errordlg(lasterr);
    end
  end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deleteData(key),
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % varargin{2}: delete data 
  msg=nargchk(1,1,nargin);
  if ~isempty(msg), error(msg);end

  %%%%delete_DataFile(varargin{2});
  %if isempty(key),
  %  error('Cannnot Open Empty GroupData.');
  %end

  %delfname  = getDataFileName(data);
  delfname  = getDataFileName(key);
  listfname = getDataListFileName;
      
  if exist(delfname, 'file'),
    delete(delfname);
  end
  
  % delete name from list and update list;   %%%%SignalProcessor
  if exist(listfname, 'file'),
	load(listfname, 'GroupDataFileList')
	bdata=find(strcmp({GroupDataFileList.Tag},key.Tag)==1);
	GroupDataFileList(bdata)=[];
	% Save
	rver=OSP_DATA('GET','ML_TB');
	rver=rver.MATLAB;
	if rver >= 14,
	  save(listfname,'GroupDataFileList','-v6');
	else,
	  save(listfname,'GroupDataFileList');
	end
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function infoStr=showinfo(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Initialize
  infoStr={};
  fileData=key;   % Here Set Group Data
  if ~isstruct(fileData)
    varargout{1}={' === No Information =='};
    return;
  end
  try
        if isfield(fileData,'data')
            addInfo = DataDef_GroupData('showblocks', ...
					fileData);
	    addInfo = {' ' ' -- Using Blocks --' addInfo{:}};
	    fileData  = rmfield(fileData,'data');
        end
  end
  infoStr={' -- Group Data File Info --'};
    
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
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function GroupDataFileList= loadlist(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  GroupDataFileList={};
  dfl=getDataListFileName;
  if exist(dfl,'file')
    load(dfl,'GroupDataFileList')
  else
    return;
  end

  if ~exist('GroupDataFileList','var')|| ...
    isempty(GroupDataFileList)
    GroupDataFileList={};
    return;
  end
  
  keys = Keys;
  iid = IdentifierID;
  if nargin>=1 && ~isempty(keys),
        % Search Select Key
        c = struct2cell(GroupDataFileList);
        f = fieldnames(GroupDataFileList);
        p = find(strcmp(f,keys{iid}));
        c = squeeze(c(p,:,:));
        if isstruct(key)
                pos = find(strcmp(c,getfield(key,keys{iid})));

        else
                pos = find(strcmp(c,key));
        end
        GroupDataFileList = GroupDataFileList(pos);
        clear c f p pos;
  end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Keys2, se]=getKeys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Keys2 = Keys;
  Keys2{end+1}='CreateDate';
  se    = searchexampl;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function keyname=getIdentifierKey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  k = Keys;
  keyname=k{IdentifierID};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gdata=NewGroup(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  keys = Keys;	
  % === Setting Information ===
  keys{end+1}='CreateDate';
  prompt=keys;
  def={};
  for ii=1:length(keys)
      switch keys{ii}
       case 'Tag'
	if length(varargin)>=1,
	  def{end+1}=varargin{1};
	else,
	  def{end+1}='Untitled';
	end
       case 'ID_number'
	def{end+1}='1';
       case 'CreateDate'
	def{end+1}=datestr(now);
       otherwise
	def{end+1} = '';
      end
  end
  ans0 = inputdlg(prompt, 'Group Data Setting', 1, def);
  % Cancel ?
  if isempty(ans0),gdata=[]; return;end
  
  for ii=1:length(keys)
      switch keys{ii}
       case 'Tag'
	gdata.Tag = ans0{ii};
       case 'ID_number'
	gdata = setfield(gdata, keys{ii}, str2num(ans0{ii}));
       case 'CreateDate'
	gdata = setfield(gdata, keys{ii}, datenum(ans0{ii}));
       otherwise
	gdata = setfield(gdata, keys{ii}, ans0{ii});         
      end
  end
  gdata.data=[];
  % -- Check Unique Indent Filer Key --
  saveGroupData(gdata);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveGroupData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also otsigtrnschld
	
    if ~exist('key','var')
      error('Can not use save for Group Data');
    end
    gdata = key;
	
    gdatalist = DataDef_GroupData('loadlist');
	
    % File Save -- Check File
    gdata_tmp = rmfield(gdata,'data');

    if ~isempty(gdatalist)
      keys = Keys;
      c = struct2cell(gdatalist);
      f = fieldnames(gdatalist);
      p = find(strcmp(f,keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(gdata,keys{IdentifierID}))) ~=0
		  error('Same Tag File exist. Cannot Make Group Data');
      end
      clear c f p;
      gdatalist(end+1) =gdata_tmp;
    else
      gdatalist =gdata_tmp;
    end
	
    % 
    dfl=getDataListFileName;
    GroupDataFileList = gdatalist;
    % Save File
    GroupData = gdata;
	fname=getDataFileName(gdata);

    % Save : 
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(dfl,'GroupDataFileList','-v6');
      save(fname,'GroupData','-v6');
    else,
      save(dfl,'GroupDataFileList');
      save(fname,'GroupData');
    end
return;
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=loadGroupData(key)
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
        fname ') not exist']);
      error([' File Lost : ' fname]);
    end

    % 
    load(fname,'GroupData');

    % Data Check (but so simple... )
    if ~exist('GroupData','var') || ...
	  ~isfield(GroupData,'data') || ...
	  ~isfield(GroupData,'Tag') || ...
	  ~isfield(GroupData,'ID_number')
      OSP_LOG('perr',['File' fname ' was broken']);
      errordlg([' Cannot Load : ' ...
		'Broken Data File : ' fname]);
      return;
    end

    % new 04-Jul-2005
    if isfield(GroupData,'BasicData'),
      GroupData=rmfield(GroupData,'BasicData');
    end
    if ~isempty(GroupData.data),
      fdata = GroupData.data(end).filterdata;
      if ~isfield(fdata,'BlockPeriod'),
	% set default value for BlockPeriod
	% Setting
	bp = [5, 15];
	try,
	  tt = [' : ' GroupData.Tag];
	catch,
	  tt = ' -- Err -- Unknown-File '; 
	end
	while 1,
	  bp = BlockPeriodInputdlg(bp,tt);
	  if isempty(bp),
	    warndlg('Group Data need block period');
	  else,
	    break;
	  end
	end % end while
	fdata.BlockPeriod = bp;
	GroupData.data(end).filterdata = fdata;
      end % Block Period exist?
    end % Data exist?
    varargout{1} = GroupData;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=save_ow(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See also otsigtrnschld
    if ~exist('key','var')
       error('Can not use save for GroupData');
    end
    gdata = key;
	
    gdatalist = DataDef_GroupData('loadlist');
	
    % File Save -- Check File
    if ~isempty(gdatalist),
      keys =Keys;
      c = struct2cell(gdatalist);
      f = fieldnames(gdatalist);
      p = find(strcmp(f,keys{IdentifierID}));
      c = squeeze(c(p,:,:));
      % if exist Cancel
      if sum(strcmp(c,getfield(gdata,keys{IdentifierID}))) ~=1
		  error('Can not Overwrite. Can not determine original file');
      end
      clear c f p;
    else
		  error('Can not Overwrite, There is no original file');
    end

    % Save File
    GroupData = gdata;
	% new 04-Jul-2005
	if ~isempty(GroupData.data),
		fdata = GroupData.data(end).filterdata;
		if ~isfield(fdata,'BlockPeriod'),
			while 1,
				bp = BlockPeriodInputdlg;
				if isempty(bp),
					warndlg('Group Data need block period');
				else,
					break;
				end
			end % end while
			fdata.BlockPeriod = bp;
			GroupData.data(end).filterdata = fdata;
		end % Block Period exist?
	end % Data exist?

    fname=getDataFileName(gdata);
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(fname,'GroupData','-v6');
    else,
      save(fname,'GroupData');
    end
	if nargout>=1,
		varargout{1} = GroupData;
	end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=showblocks(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  [info linfo] = DataDef_GroupData('showblocks',key)
%      get Information of each-Block Data 
%       &  line-information
    data0 = key.data;
    if isempty(data0)
      varargout{1}={'No Data in Groupdata'};
      if nargout>=2, varargout{2}=[]; end
      if nargout>=3, varargout{3}=[]; end
      return;      
    end  

    % Make Information;
    st={}; linedata=[]; kind_list=[];
       
    for did = 1:length(data0)
      data = data0(did);
      % File Name Print
      st{end+1}=['* ' data.name];
      linedata(end+1,:)=[did 0 0];

	  % No Stim Data::
	  if isempty(data.stim), 
		  continue;
	  end

      if isfield(data.stim,'ver'),
		  switch data.stim.ver
			  case '1.50',
				   [kind_list, rstim, sflag, idx] = ...
					   patch_stim(data.stim.orgn, data.stim.type, ...
					   data.stim.flag, data.stim.diff);
				   for id = 1:length(kind_list),
					   % Ignore Unused Block
					   if all(sflag(id,:)),
						   continue;
					   end
					   st{end+1} = ...
						   sprintf(['   kind<%03d>%5d - %5d [point]'], ...
						   kind_list(id), rstim(id,1), rstim(id,2));
					   linedata(end+1,:) = [did, idx(id,1), idx(id,2)];
				   end
			  otherwise,
				  msg = sprintf(['<< OSP v1.5 Error!!          >>\n' ...
						         '<< Unknown Stim-Data Version >>\n']);
				  error(msg);
		  end
      elseif ~isempty(data.stim), 
		  %=========================
		  % Group Data : 
		  %  OSP ver 1.0 to 1.17
		  %=========================
		  % Chaneg Stimulation KindC
		  stimData = data.stim.StimData;
		  for kid=1:length(stimData)
			  astimdata = stimData(kid);
			  kindstr = sprintf('%03d', astimdata.kind);
			  
			  kindaddflg = find(kind_list==astimdata.kind);
			  if isempty(kindaddflg)
				  kind_list=[kind_list astimdata.kind];
			  end
			  
			  
			  % Change Block
			  for bid = 1: length(astimdata.stimtime)
				  astimtime = astimdata.stimtime(bid);
				  if any(astimtime.chflg)==0
					  continue;  %Ignor Not Effective Data
				  end
				  linedata(end+1,:)=[did kid bid];
				  st{end+1} =[ '   kind<' kindstr '>  ' , ...
						  sprintf('% 4d - % 4d [point]', ...
						  astimtime.iniStim , ...
						  astimtime.finStim )];
			  end % Block Timing End
		  end % Kind End
	  end %  if GroupData Mode Select
	  

    end % File End
    
    varargout{1}=st;
    if nargout >= 2
      varargout{2}=linedata;
    end
    if nargout >= 3
      varargout{3}=kind_list;
    end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_timedata(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    actdata    = key.actdata;
    filterdata = key.filterManage;
    kind       = key.plot_kind;
    if isfield(key, 'plotstimkind') 
      plotstimkind = key.plotstimkind;
    end


    % == Load  Group Data ==
    if ~isfield(actdata.data,'data')
        actdata.data = DataDef_GroupData('load', actdata.data);
    end
    groupdatalist = actdata.data.data;

    %  Get Plot Kind
    plotkind =  []; plotkind2=[];
    try
      if kind.oxy,   plotkind=[plotkind, 1]; end
      if kind.deoxy, plotkind=[plotkind, 2]; end
      if kind.total, plotkind=[plotkind, 3]; end
    end

	% Minimum relax get
	[relax] =  datablocking('getMinRelax', ...
		actdata.data);
	if isfield(key, 'relax')
		for ii= length(relax),   % Now, relax is 1 x 2 vector
			if key.relax(ii) < relax(ii)
				relax(ii) = key.relax(ii);
			end
		end
	end
	
	% Data Blocking
	[block bkind tag astimtimes] = datablocking('getMultiBlock', ...
		groupdatalist, relax);
	
	% Plot Kind Selected : Plot only First Kind 
	%                 -> Clear Other Data
	outkind = find(bkind~=bkind(1));
	if ~isempty(outkind)
		block(outkind,:,:,:)=[];
		astimtimes(outkind) =[];
	end
	if size(block,1) > 1
		mean_block = nan_fcn('mean', block, 1);
		% -- Error Area Setting  --
		try
			std_block  = nan_fcn('std0', block, 1);
			sz=size(std_block); sz(1)=[];
			if length(sz)==1, sz(2)==1; end
			std_block=reshape(std_block,sz);
		end
	else
		mean_block = block;
	end
	clear block;
	sz=size(mean_block); sz(1)=[];
	if length(sz)==1, sz(2)==1; end
	mean_block=reshape(mean_block,sz);
	
	% Make Stimtime
	stimData.kind     =  bkind(1);
	stimData.stimtime = astimtimes(1);
	stimInfo = groupdatalist(1).stim;
	stimInfo.StimData =  stimData;
	
	strHBdata.tag  = tag;
	strHBdata.stim = stimInfo;
	strHBdata.data = mean_block; clear mean_block;
	% -- Error Area Setting  --
	if exist('std_block','var')
		strHBdata.std = std_block; clear std_block;
	end
    
    varargout{1} = strHBdata;
    varargout{2} = plotkind;
return;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_mfile_GroupData(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(key,'actdata'),
      if isfield(key,'fname'),
	varargout{1} = make_mfile_local(key.actdata.data, ...
					key.filterManage, ...
					key.fname);
      else,
	varargout{1} = make_mfile_local(key.actdata.data, key.filterManage);
      end
    else,
      varargout{1} = make_mfile_local(key);
    end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=make_ucdata(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    actdata    = key.actdata;

    % == Load  Group Data ==
    if ~isfield(actdata.data,'data')
      actdata.data = DataDef_GroupData('load', actdata.data);
    end

    % (if there) Overwrite filterdata 
    if isfield(key,'filterManage') && ~isempty(key.filterManage),...
      actdata.data.data(end).filterdata = key.filterManage;
    elseif isfield(key,'filterManage'),
      % Remove Filter
      if isfield(actdata.data.data(end).filterdata,'HBdata'),
	actdata.data.data(end).filterdata.HBdata=[];
      end
      if isfield(actdata.data.data(end).filterdata,'BlockData'),
	actdata.data.data(end).filterdata.BlockData=[];
      end
    end
    
    % == Make M-File ==
    fname = make_mfile_local(actdata.data);
    try,
        if isfield(key,'filterManage') && ...
            ~isfield(key.filterManage,'BlockPeriod'),
            [data, hdata] = scriptMeval(fname, 'cdata', 'chdata');
            if ~isempty(data) && ...
                (~isfield(key,'outputtype') || ...
                ~strcmpi(key.outputtype,'cell') )
              data=data{1}; hdata=hdata{1};
            end
        else,
            [data, hdata] = scriptMeval(fname, 'bdata', 'bhdata');
        end
    catch,
        delete(fname);
        errordlg(lasterr); 
        return;
    end
    delete(fname);
    
    varargout{1} = data;
    varargout{2} = hdata;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nm = getFileName(key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(key),
      key2.filename=key;
    else,
      key2=key;
    end
    nm = getDataFileName(key2);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getDataListFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get Data List File Name of 
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    errordlg(' Open Project at first!');
    error(' Open Project at first!');
  end

  fname = [pj.Path ...
	   OSP_DATA('GET','PROJECT_DATA_DIR') ...
	   filesep 'DataListGroupData.mat'];

return;

function fname=getDataFileName(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get Data File Name of 
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Name Setting  : --> See save
  dfl=getDataListFileName;
  [p0, n1] = fileparts(dfl); % get save path
  fname = ['GD_' data.Tag '.mat'];
  fname = [p0 filesep fname];
return;

function fname = make_mfile_local(groupdata, filterdata, fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make M-File of GroupData
%     Group Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % == Load  Group Data ==
  if ~isfield(groupdata,'data')
    groupdata = DataDef_GroupData('load', groupdata);
  end
  if isempty(groupdata.data),
	  msg = sprintf('\n OSP Error!!!\n<< No-Data to Filter int the group\n');
      error(msg);
  end
  if nargin>=2,
    groupdata.data(end).filterdata = filterdata;
  end
  
  % == Open M-File ==
  if nargin<3,
    fname = fileparts(which('OSP'));
    fname = [fname filesep 'ospData' filesep];
    fname = [fname 'gd_' datestr(now,30) '.m'];
  end
  
  try,
      [fid, fname] = make_mfile('fopen', fname,'w');
	  GroupData2Mfile(groupdata);
  catch,
	  make_mfile('fclose');
	  rethrow(lasterror);
  end
  % == Close M-File ==
  make_mfile('fclose');
return;

function ReplaceViewLayout(Layout, key),
%     Layout : ViewLayout cell-array Data
%     key    : active data
  msg=nargchk(2,2,nargin);
  if ~isempty(msg),error(msg);end

  % Load Original Data
  fname=getDataFileName(key.data);
  GroupData=loadGroupData(key.data);
  % Over write Layout
  GroupData.VLAYOUT=Layout;

  % Save File
  rver=OSP_DATA('GET','ML_TB');
  rver=rver.MATLAB;
  if rver >= 14,
    % MALTAB Release 13
    % Save Data with Version 6
    save(fname,'GroupData','-v6');
  elseif rver >= 12,
    % Save Data with Version 6
    save(fname,'GroupData');
  else
    % Can not save Structure ::: MATLAB 4
    error('Version of MATLAB is too old.');
  end

function vlayout=getLayoutFromFile(fname),
%     fname   : Filename of Group-Data
%     vlayout : ViewLayout cell-array Data
  msg=nargchk(1,1,nargin);
  if ~isempty(msg),error(msg);end

  % Load Original Data
  % fname=getDataFileName(actdata.data);
  load(fname,'GroupData');
  if ~isfield(GroupData,'VLAYOUT'),
    error(['No Layout Informaion in File : ' fname]);
  end
  % Over write Layout
  vlayout=GroupData.VLAYOUT;
