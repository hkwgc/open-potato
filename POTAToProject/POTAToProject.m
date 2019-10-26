function Project=POTAToProject(mode,varargin)
% OSP Project Data I/O
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
%  $Id: POTAToProject.m 285 2012-06-15 08:02:54Z Katura $
% -------------------------------------
%
% Project=POTAToProject('Add', ProjectData):
%  Check in new Project to , and Set POTATo Current Project
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

% == History ==
% original auther : Masanori Shoji
% create : 2005.01.11
% $Id: POTAToProject.m 285 2012-06-15 08:02:54Z Katura $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Date 28-Nov-2005
%   Add Refresh Project
%disp(mode);

Project=[];                           % if Error occur, Project is Empty
projectDataFile=getProjectFileName;   % Get Project FileName

rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;

% Load Project Data ( All )
try
	load(projectDataFile,'ProjectData');
catch
	clear ProjectData
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
		owflag=false;
		idx=0;
		for pj = ProjectData
			idx=idx+1;
			if strcmp(pj.Name, projectInp.Name)
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
						owflag=true;
					otherwise,
						return; % Not overwrite
				end % End of Switch
			end % Check if
		end
		
		% == Set Data ==
		if isfield(projectInp,'index'),
			projectInp = rmfield(projectInp,'index');
		end
		try
			if setplace==1
				if isempty(ProjectData),
					ProjectData=projectInp;
				elseif length(ProjectData)==1
					clear ProjectData;
					ProjectData(setplace)=projectInp;
				else
					ProjectData(setplace)=projectInp;
				end
			else
				ProjectData(setplace)=projectInp;
			end
		catch
			warning(lasterr);
		end
		setCurrentProject(projectInp, setplace);
		Project = projectInp; % OK
		
		if strcmp(mode,'Add'),
			%% Remove *** Remove ***
			dirname=[projectInp.Path filesep projectInp.Name];
			if ~owflag && exist(dirname,'dir'),
				qans = questdlg({' Directory already exist.', ...
					dirname ']. ',...
					'Can I remove Directory?'}, ...
					['Delete Project Data : ' dirname],...
					'Yes', 'No', 'Yes');
				if strcmp(qans,'No'),
					OSP_DATA('SET','PROJECT',[]);
					Project=[];
					return;
				end
			end
			
			%- check new project name 
			if strcmp(projectInp.Name, 'ProjectExp_tmp_0x00')
				h=warndlg({'Project name [ProjectExp_tmp_0x00] is used in P3 system.',...
					'Please change the name.'});
				waitfor(h);
				Project=[];return;
			end
			
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
			% 			[cdir, msg]=mkdir(projectInp.Path,OSP_DATA('GET', ...
			% 				'PROJECT_DATA_DIR'));
			[cdir, msg]=mkdir(projectInp.Path,projectInp.Name);
			P3_Project_History('new');
			
			if cdir == 0
				OSP_DATA('SET','PROJECT',[]);
				error(msg);
			end
		end
		POTAToProject('SetProjectDataInDir',Project);
		
		
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
		catch
			code=-2;
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
		
		% Check Project-name and Move project-data
		rtn=0;
		if ~strcmp(projectInp.Name, ProjectData(idx).Name),
			rtn=moveProjectData(ProjectData(idx), projectInp);
		end
		if rtn==0,
			ProjectData(idx)=projectInp;
			setCurrentProject(projectInp, idx);
			Project = projectInp; % OK
			POTAToProject('SetProjectDataInDir',Project);
		end
		% --------------------
	case 'Export'
		% --------------------
		
		if length(varargin)<2,
			error([mfilename ': Export Argument Error']);
		end
		idx   = varargin{1};
		ProjectInp    = ProjectData(idx);
		fname = varargin{2};
		if length(varargin)<3,
			rm_name = 1;
		else
			rm_name = varargin{3};
		end
		
		tmp_dir = pwd;
		try
			cd(ProjectInp.Path);
			if rver >= 14,
				save('Export_Project.mat','ProjectData','-v6');
			else
				save('Export_Project.mat','ProjectData');
			end
			%%dirname = [ProjectData.Path OSP_DATA('GET','PROJECT_DATA_DIR')]; 1204
			dirname = ProjectInp.Name;
			if 1
				% Copy
				%%dirname2 = [dirname '_tmp'];
				dirname2 = 'ProjectExp_tmp_0x00';    %%  named  for zip-project-data
				
				%- check existing folder : TK@CRL 2012-05-15
				if exist(dirname2)==7
					rmdir(dirname2,'s');
				end
				
				[s,m] = copyfile(dirname,dirname2);
				if ~all(s),
					warning(m);
				end
				dirname = dirname2;
			end
			if rm_name==1,
				%%rm_subjectname(dirname); %% commentout for test without DataList,on
			end
			zip(fname,{dirname, 'Export_Project.mat'});
			%Delete
			cd (ProjectInp.Path);  % added 1204
			delete('Export_Project.mat');
			rmdir(dirname2,'s'); %- TK@CRL 2012-05-15
			
			if rm_name==1,
				[s, m, id]=rmdir(dirname,'s');
				if ~s, warning(m); end
			end
			
		catch
			try
				delete('Export_Project.mat');
				rmdir(dirname2,'s'); %- TK@CRL 2012-05-15
			end
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
		try
			cd(pj.Path);
			%%dirname = [pj.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
			dirname = pj.Name;
			%%dirname2 = [dirname '_tmp'];
			dirname2 = 'ProjectExp_tmp_0x00';    %%  named  for zip-project-data
			[s, m]=rmdir(dirname,'s');
			if ~s, warning(m); end
			
			% Expand
			unzip(impfile);
			if isdir(dirname2),
				[s,m]= movefile(dirname2, dirname);
				if ~all(s), error(m);  end
			end
			
			%Delete
			delete('Export_Project.mat');
			
		catch
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
		else
			pj=varargin{1};
		end
		if isempty(pj)
			Project={'--- Not Opened ---'};
		else
			%' --- Information of Project ---', ...
			try
				noad=length(DataDef2_Analysis('loadlist'));
			catch
				noad=0;
			end
			Project={ ...
				[ 'Name         : ' pj.Name], ...
				[ 'Comment      : ' pj.Comment],...
				[ 'Ana-Data Num : ' num2str(noad)],...
				[ 'Create Date  : ' datestr(pj.CreateDate)],...
				[ 'Operator     : ' pj.Operator], ...
				[ 'Path         : ' pj.Path]};
		end
		return;
		
		% --------------------
	case 'SetProjectDataInDir'
		% --------------------
		% OspProject('SetProjectDataInDir',Project);
		if isempty(varargin)
			error([mfilename ': Set Additional Project Data']);
		end
		projectInp=varargin{1};
		% 		ppath=[projectInp.Path OSP_DATA('GET','PROJECT_DATA_DIR')];
		ppath=[projectInp.Path filesep projectInp.Name];
		
		if ~exist(ppath,'dir'),
			[s, msg]=mkdir(ppath);
			if ~s, error(msg); end
		end
		pfile=[ppath filesep 'PROJECT_DATA.mat'];
		Project=projectInp;
		if rver >= 14,
			save(pfile,'Project','-v6');
		else
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
		try
			% 		   ppath2=[ppath OSP_DATA('GET','PROJECT_DATA_DIR')]; delete by y
			ppath2=ppath;
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
			Project.Path=p;
			Project.CreateDate=now;
			Project.Operator='somebody';
			Project.Comment='Searched Data';
		else
			% Replase Path!
			Project.Path=fileparts(ppath);
		end
		return;
		
	otherwise,
		OSP_LOG('err',[mfilename ' : undefined Mode ' mode]);
		error([mfilename ' : undefined Mode ' mode]);
end

% Save Project
if rver >= 14,
	save(projectDataFile,'ProjectData','-v6');
else
	save(projectDataFile,'ProjectData');
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function projectDataFile=getProjectFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==  Get Project Data File Name ==
POTAToPParentPath=OSP_DATA('GET','PROJECTPARENT');
if isempty(POTAToPParentPath)
	% If there is no ProjectPath
	error('No Parent Project Selected!');
end
projectDataFile=[POTAToPParentPath filesep ...
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
dirname = [pj.Path filesep pj.Name];

if ~exist(dirname,'dir')
	code = -1;  % No Match Data
	return;
end

if ispc && strcmpi(dirname,pwd),
	% Move to upper Dir
	cd(pj.Path);
end
try
	[cd0, msg]=rmdir(dirname,'s');
	if cd0==0,
		error(msg);
	end
	code = 0;
catch
	% Windows 98, Millennium?.
	msg=[lasterr, ...
		'(Remove : ', ...
		'OS Windws 98/Millennium ' ...
		'is not suppot RMDIR)'];
	error(msg);
end
return;


function rm_subjectname(dirname)
tmp_dir = pwd;
try
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
			try
				OSP_LOCALDATA.info.subjectname='somebody';
			end
			if rver >= 14,
				%save(fname2,'OSP_LOCALDATA','-v6','-APPEND');
				load(fname2);
				save(fname2,'-v6',fieldnames(S));
			else
				save(fname2,'OSP_LOCALDATA','-append');
			end
		elseif isfield(S,'header'),
			header=S.header;
			try
				header.TAGs.subjectname='somebody';
			end
			if rver >= 14,
				%save(fname2,'header','-v6','-APPEND');
				load(fname2);
				save(fname2,'-v6',fieldnames(S));
			else
				save(fname2,'header','-append');
			end
		end
	end
	if rver >= 14,
		save(fname,'signalProcessorFileList','-v6');
	else
		save(fname,'signalProcessorFileList');
	end
	
catch
	cd(tmp_dir);
	rethrow(lasterror);
end
cd(tmp_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function code=moveProjectData(src_prj, dest_prj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arg1: source project
% arg2: destination project
% Code -2 : Error
%      -1 : Dir Not Exist
%       0 : Normal End
%       1 : Refused by user

code=-2;    % Error ( Default )

% Get Directory Name
if isempty(src_prj) || isempty(dest_prj),
	error('Set Project Data at First!');
end
src_dirname = [src_prj.Path filesep src_prj.Name];
dest_dirname= [dest_prj.Path filesep dest_prj.Name];
if ~exist(src_dirname,'dir')
	code = -1;  % No Match Data
	return;
end

qans = questdlg([' Move the ProjectData Directory : ', ...
	src_dirname ' to ' dest_dirname  '. ',...
	'Are you sure?'], ...
	['Delete Project Data : ' src_dirname],...
	'Yes', 'No', 'Yes');
if strcmp(qans,'No'),
	code = 1;
	return;
end

tmp_dir = pwd;
try
	cd(src_prj.Path);
	[cd0, msg]=movefile(src_prj.Name, dest_prj.Name);
	if cd0==0,
		error(msg);
	end
	code = 0;
catch
	% Windows 98, Millennium?.
	msg=[lasterr, ...
		'(Move : ', ...
		'OS Windws 98/Millennium ' ...
		'is not suppot RMDIR)'];
	cd(tmp_dir);
	error(msg);
end
cd(tmp_dir);
return;
