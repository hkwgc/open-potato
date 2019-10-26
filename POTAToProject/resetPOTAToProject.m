function [prj,fnm]=resetPOTAToProject(varargin)
% To Reset Project, make Relation and.....
%
% 
% Reset POTATo Project:
%   Syntax :
%     resetProject;
%       Reset Current Project Data.
%
%     resetProjcet(prj);
%        Reset given Project-Data.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%%%%%%%%%%%%%%%%%%
%% Check Argument 
%%%%%%%%%%%%%%%%%%
msg=nargchk(0,1,nargin);
if ~isempty(msg),
	warning(msg);
end

if nargin>=1,
	Project = varargin{1}; % Opearte Project
	pj0    = OSP_DATA('GET','PROJECT'); % Back-up
  OSP_DATA('SET','PROJECT',Project);
else
	Project= OSP_DATA('GET','PROJECT');
end

if isempty(Project) || ~exist(Project,'dir'),
  error('No Project to Reset.');
end

%%%%%%%%%%%%%%%%%%
%% Make Relation
%%%%%%%%%%%%%%%%%%
% --> Start Here <--
try
	st={}; % List of Makindg Data

  % ==========================
  %% About Raw - Data
  % ==========================

  % ==========================
  %% About Analysis - Data
  % ==========================
	lst = DataDef_GroupData('loadlist');
	for idx=1:length(lst),
		dt = lst(idx);
		name0=DataDef_GroupData('getFileName',dt);
		if exist(name0,'file'),
		  % File Exist ::
		  nm=DataDef_GroupData('reshapeName',dt.Tag);
		  % nm=reshapename(dt.Tag); nm=['GD_' nm];
		  st{end+1}=nm;
		  eval([nm '.data=dt;']);
		  eval([nm '.fcn=@DataDef_GroupData;']);
		  eval([nm '.Parent={};']);
		  eval([nm '.Children={};']);
		  gd = DataDef_GroupData('load',dt);
		  for idx2=1:length(gd.data),
		    nm2=DataDef_SignalPreprocessor('reshapeName',gd.data(idx2).name);
		    if exist(nm2,'var'),
		      % Add Relation 
		      eval([nm '.Parent{end+1}=''' nm2 ''';']);
		      eval([nm2 '.Children{end+1}=''' nm ''';']);
        else
		      % No Data Exist ---> Delete This Data::
		      DataDef_GroupData('deleteData',dt);
		    end
		  end
    else % file is not exist
      disp(['[W] : Lost File : ' name0]);
		end
	end % GroupData List Loop
	
	% who
	%   fnm = [Project.Path  filesep 'Relation.mat'];
	prjpath = OSP_DATA('GET', 'PROJECTPARENT');   % '/OspDataDir'
	fnm = [prjpath ospdatadir filesep 'Relation.mat'];
	
	% -- Save st{} to Relation.mat
  for i=1:length(st),
    FileFunc('setVariable', fnm, eval(st{i}), st{i});
  end
	
catch
	if nargin>=1,
		OSP_DATA('SET','PROJECT',pj0);
	end
	rethrow(lasterror);
end

prj=Project;
