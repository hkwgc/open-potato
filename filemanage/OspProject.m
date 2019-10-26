function Project=OspProject(mode,varargin)
% OSP Project Data I/O
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
%  $Id: OspProject.m 180 2011-05-19 09:34:28Z Katura $
% -------------------------------------
%
% Project=OspProject('Add', ProjectData):
%  Check in new Project to OSP, and Set OSP Current Project
%   ProjectData is a Project Structure to Add
%   Project  is Added Project, 
%   if Project is null command is aborted by the user.
%
% Project=OspProject('LoadData');
%   Load All Project that checked in.
%
% Project=OspProject('Remove',idx);
%    Remove Project,index is 'idx', from OSP
%    and return rest Project in OSP
%
% Project=OspProject('Replace',idx,ProjectData);
%    Replace Project, index is 'idx', to 'ProjectData'
%    Project  is Replace Project, 
%    if Project is null command is aborted by the user.
%
% Project=OspProject('Select',idx);
%    Set OSP Current Project, index is 'idx', to 'ProjectData'
%    Project  is Replace Project, 
%    if Project is null command is aborted by the user.
%
% OspProject('SetProjectDataInDir',Project);
%
% Project=OspProject('GetProjectDataInDir',directoryname);
%
% Lower Link : 
%   OSP_DATA    : Data I/O
%   OSP_LOG     : Log output


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original auther : Masanori Shoji
% create : 2005.01.11
% $Id: OspProject.m 180 2011-05-19 09:34:28Z Katura $

% Date 28-Nov-2005
%   Add Refresh Project
Project=[];                           % if Error occur, Project is Empty
projectDataFile=getProjectFileName;   % Get Project FileName

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;

% Load Project Data ( All )
try
    load(projectDataFile,'ProjectData');
end
if ~exist('ProjectData','var')
    ProjectData=struct([]);
end

if OSP_DATA== 0
    error(' OSP is not Running');
end

switch mode
       % --------------------
    case {'Add', 'Add2'}
        % --------------------
        % Check Argument
        if isempty(varargin)
            error([mfilename ': Set Additional Project Data']); 
        end
        projectInp=varargin{1};
        try projectInp = projectInp(1); end;
        try 
            projectInp.CreateDate = now;  % Set Create Time 
        catch
            error([mfilename ': 2nd Argument of Add must be Project Data' ...
                    lasterr]);
        end
        
        % Get Add Place & Check all path is differnt
        setplace=length(ProjectData)+1;
        idx=0;
        for pj = ProjectData
            idx=idx+1;
            if strcmp(pj.Path, projectInp.Path)
                % Overwrite ?
                buttonName = questdlg([' there is same path Project.' ...
                        'Do you want to overwrite ?'], ...
                    ' Confirmation of  Overwrite ',...
                    'Yes','No','Yes');
                switch buttonName,
                    case 'Yes',
                        setplace=idx;
                        projectInp.CreateDate = pj.CreateDate;
                        OSP_LOG('note', ...
                            [' Project' num2str(setplace) ' is overwrite']);
                    otherwise,
                        return; % Not overwrite
                end % End of Switch 
            end % Check if
            
        end  % Project Loop
        
        % == Set Data ==        
        try projectInp = rmfield(projectInp,'index'); end
        if setplace==1
            clear ProjectData;
            ProjectData(setplace)=projectInp;
        else
            ProjectData(setplace)=projectInp;
        end
        setCurrentProject(projectInp, setplace);
        Project = projectInp; % OK
		if strcmp(mode,'Add'),
			% Reset OSP Data Derectory  
			try
				code=removeProjectData;
			end
			switch code
				case -2
					OSP_DATA('SET','PROJECT',[]);
					rethrow(lasterror);
				case 1
					OSP_DATA('SET','PROJECT',[]);
                    return;
			end
			pj=OSP_DATA('GET','PROJECT');
			if isempty(pj)
				error('Set Project Data at First!');
			end
			[cdir, msg]=mkdir(projectInp.Path,OSP_DATA('GET', ...
				'PROJECT_DATA_DIR'));
			if cdir == 0
				OSP_DATA('SET','PROJECT',[]);
				error(msg);
			end
		end     
		OspProject('SetProjectDataInDir',Project);
        
        
        % --------------------
    case 'LoadData'
        % --------------------
        if isempty(varargin)
            Project=ProjectData;  % Load All Project
            return;
        end
        
        % --------------------  
    case 'Remove'
        % --------------------
        idx=varargin{1};
        
        % ReMove OSP Data Derectory  
        setCurrentProject(ProjectData(idx), idx); % for Remove Setting
        try
            code=removeProjectData;
        end
        switch code
            case -2
                OSP_DATA('SET','PROJECT',[]);
                rethrow(lasterror);
        end
        
        % Remove from list
        ProjectData(idx)=[];
        Project = ProjectData;
        OSP_DATA('SET','PROJECT',[]);
        
        % --------------------  
    case 'Replace'
        % --------------------
        if length(varargin)~=2
            error([mfilename ': Set Replace Project Data']); 
        end
        
        idx=varargin{1};
        
        projectInp=varargin{2};
        try projectInp = projectInp(1); end;
        try projectInp=rmfield(projectInp,'index'); end
        
        % Get Add Place & Check all path is differnt
        setplace=length(ProjectData);
        idx0=0;
        for pj = ProjectData
            idx0=idx0+1;
            if idx == idx0
                continue;
            end
            if strcmp(pj.Path, projectInp.Path)
                errordlg([' Can not replace, becase there is same Path' ...
                        ' Project']);
                return;
            end % Check if
            
        end  % Project Loop
        ProjectData(idx)=projectInp;
        setCurrentProject(projectInp, idx);
        Project = projectInp; % OK
		OspProject('SetProjectDataInDir',Project);
		        
	% --------------------  
    case 'Export'
        % --------------------

        if length(varargin)<2,
	  error([mfilename ': Export Argument Error']); 
        end
        idx   = varargin{1};
	ProjectData    = ProjectData(idx);
	fname = varargin{2};
	if length(varargin)<3,
	  rm_name = 1;
	else,
	  rm_name = varargin{3};
	end
        
	tmp_dir = pwd;
	try,
	  cd(ProjectData.Path);
	  if rver >= 14,
	    save('Export_Project.mat','ProjectData','-v6');
	  else,
	    save('Export_Project.mat','ProjectData');
	  end
	  dirname = [ProjectData.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
	  if rm_name==1,
	    % Copy
	    dirname2 = [dirname '_tmp'];
	    if 0,
	      if ispc,
		eval(['!copy ' dirname ' ' dirname2]);
	      else,
		eval(['!cp -r ' dirname ' ' dirname2]);
	      end
	    else,
	      [s,m] = copyfile(dirname,dirname2);
	      if ~all(s),
		warning(m);
	      end
	    end
	    dirname = dirname2;
	    rm_subjectname(dirname);
	  end
	  zip(fname,{dirname, 'Export_Project.mat'});
	  %Delete 
	  delete('Export_Project.mat');
	  if rm_name==1,
	    [s, m, id]=rmdir(dirname,'s');
	    if ~s, warning(m); end
    	  end

	catch,
	  try,delete('Export_Project.mat');end
	  cd(tmp_dir);
	  rethrow(lasterror);
	end
	cd(tmp_dir);
		
	% --------------------  
    case 'Import'
        % --------------------
        if length(varargin)<3,
	  error([mfilename ': Export Argument Error']); 
        end
        pj        = varargin{1};
	ifname    = varargin{2};
	ipathname = varargin{3};
	impfile   =[ipathname filesep ifname];

	tmp_dir = pwd;
	try,
	  cd(pj.Path);
	  dirname = [pj.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
	  dirname2 = [dirname '_tmp'];

	  [s, m, id]=rmdir(dirname,'s');
	  if ~s, warning(m); end

	  % Expand
	  unzip(impfile);
	  if isdir(dirname2),
	    [s,m]= movefile(dirname2, dirname);
	    if ~all(s), error(m);  end
	  end

	  %Delete 
	  delete('Export_Project.mat');

	catch,
	  try,delete('Export_Project.mat');end
	  cd(tmp_dir);
	  rethrow(lasterror);
	end
	cd(tmp_dir);
		
        
        % --------------------  
    case 'Select'
        % --------------------
        idx=varargin{1};
        setCurrentProject(ProjectData(idx), idx);
        Project = ProjectData(idx);
        
        % --------------------  
    case 'Info'
        % --------------------
		if isempty(varargin)
			pj = OSP_DATA('GET','PROJECT');
		else,
			pj=varargin{1};
		end
        Project={ ...
                ' --- Information of Project ---', ...
                pj.Comment, ...
                '',...
                [ 'Path         : ' pj.Path], ...
                [ 'Create Date  : ' datestr(pj.CreateDate)],...
                [ 'Operator     : ' pj.Operator]};
        return;

		% -------------------- 
	case 'SetProjectDataInDir'
		% -------------------- 
		% OspProject('SetProjectDataInDir',Project);
		if isempty(varargin)
			error([mfilename ': Set Additional Project Data']); 
		end
		projectInp=varargin{1};
		ppath=[projectInp.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
        if ~exist(ppath,'dir'),
            [s, msg]=mkdir(ppath);
            if ~isempty(msg),
                error(msg);
            end
        end
		pfile=[ppath filesep 'PROJECT_DATA.mat'];
		Project=projectInp;
		if rver >= 14,
		  save(pfile,'Project','-v6');
		else,
		  save(pfile,'Project');
		end
		return;
		
		% -------------------- 
   case 'GetProjectDataInDir'
       % -------------------- 
	   % Project=OspProject('GetProjectDataInDir',directoryname);
	   if isempty(varargin)
		   error([mfilename ': Set Load Directory']); 
	   end
	   ppath=varargin{1};
	   if ~exist(ppath),
		   error(['No such a file or directory:' ppath]);
	   end
	   try,
		   ppath2=[ppath OSP_DATA('GET','PROJECT_DATA_DIR')];
		   pfile=[ppath2 filesep 'PROJECT_DATA.mat'];
		   if exist(pfile),
			   load(pfile,'Project');
		   end
	   end
	   if ~exist('Project','var') || isempty(Project),
		   clear Project;
		   warning('No Project Data exist in Dir.');
		   [p, f]=fileparts(ppath);
		   Project.Name=f;
		   Project.Path=ppath;
		   Project.CreateDate=now;
		   Project.Operator='somebody';
		   Project.Comment='Searched Data';
       else,
           % Replase Path!
           Project.Path=ppath;
	   end
	   return;
	   
    otherwise,
        OSP_LOG('err',[mfilename ' : undefined Mode ' mode]);
        error([mfilename ' : undefined Mode ' mode]);
end
    
% Save Project
if rver >= 14,
  save(projectDataFile,'ProjectData','-v6');
else,
  save(projectDataFile,'ProjectData');
end

    
return;
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function projectDataFile=getProjectFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==  Get Project Data File Name ==
  ospPath=OSP_DATA('GET','OspPath');
  if isempty(ospPath)   % If Dont open OSP_DATA
    ospPath=which('OSP'); % - Get OSP path -
    if iscell(ospPath)
      ospPath=ospPath{1};
    end  
    ospPath=fileparts(ospPath);
    if isempty(ospPath)   % OSP Path Error
      error(' Cannot Find OSP path in the ''Matlab path''');
    end
  end
  projectDataFile=[ospPath filesep 'ospData' filesep ...
		   'ProjectData.mat'];
return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setCurrentProject(pj,idx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set OSP Current Project
  pj.index = idx;
  OSP_DATA('SET','PROJECT',pj);
  return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function code=removeProjectData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !! Warning : Set PROJECT at First!
% Set OSP Current Project
%
% Code -2 : Error
%      -1 : Dir Not Exist
%       0 : Normal End
%       1 : Refused by user
    
  code=-2;    % Error ( Default )
  
  % Get Directory Name
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    error('Set Project Data at First!');
  end
  dirname = [pj.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
    
    
  if ~exist(dirname,'dir')
    code = -1;  % No Match Data
    return;
  end
    
  qans = questdlg([' Remove the ProjectData Directory : ', ...
		   dirname '. ',...
		   'Are you sure?'], ...
		  ['Delete Project Data : ' dirname],...
		  'Yes', 'No', 'Yes');
  if strcmp(qans,'No'),
    code = 1;
    return;
  end

  if ispc && strcmpi(dirname,pwd),
      % Move to upper Dir
      cd(pj.Path);
  end
  try,
      [cd0, msg]=rmdir(dirname,'s');
      if cd0==0,
          error(msg);
      end
      code = 0;
  catch,
      % Windows 98, Millennium?.
      msg=[lasterr, ...
              '(Remove : ', ...
              'OS Windws 98/Millennium ' ...
              'is not suppot RMDIR)'];
      error(msg);
  end
return;


function rm_subjectname(dirname),
  tmp_dir = pwd;
  try,
    cd(dirname);
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;

    % -- see also DataDef_SignalPreprocessor,
    fname = 'DataListSignalProcessor.mat';
    load(fname,'signalProcessorFileList');
    % [signalProcessorFileList.subjectname]=deal('Unknown');
    % save(fname,'signalProcessorFileList');
    for id=1:length(signalProcessorFileList),
      signalProcessorFileList(id).subjectname='somebody';
      fname2 = ['HB_' signalProcessorFileList(id).filename '.mat'];
      S=load(fname2);
      if isfield(S,'OSP_LOCALDATA'),
	OSP_LOCALDATA=S.OSP_LOCALDATA;
	try,
	  OSP_LOCALDATA.info.subjectname='somebody';
	end
	if rver >= 14,
	  save(fname2,'OSP_LOCALDATA','-v6','-APPEND');
	else,
	  save(fname2,'OSP_LOCALDATA','-APPEND');
	end
      elseif isfield(S,'header'),
	header=S.header;
	try,
	  header.TAGs.subjectname='somebody';
	end
	if rver >= 14,
	  save(fname2,'header','-v6','-APPEND');
	else,
	  save(fname2,'header','-APPEND');
	end
      end
    end
    if rver >= 14,
      save(fname,'signalProcessorFileList','-v6');
    else,
      save(fname,'signalProcessorFileList');
    end
    
  catch,
    cd(tmp_dir);
    rethrow(lasterror);
  end
  cd(tmp_dir);
