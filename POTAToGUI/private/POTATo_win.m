function varargout=POTATo_win(fcn,varargin)
% Default Function of POTATo_win


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% 2014.03.29 : Change for Exe

if ~strcmp(fcn,'DisConnectAdvanceMode') && ...
		~strcmp(evalin('caller','mfilename'),'POTATo_win_Empty') && ...
		~strcmp(evalin('caller','mfilename'),'POTATo_win')
	disp(['[Dumy] Call ''' fcn ''' in ' mfilename ' from ' evalin('caller','mfilename')]);
end

%======== Launch Switch ========
if nargout,
	[varargout{1:nargout}] = feval(fcn, varargin{:});
else
	feval(fcn, varargin{:});
end
return;
%====== End Launch Switch ======

% === POTATO_win Default Function ==
function Suspend(handles,varargin)
function Activate(handles,varargin)
function DisConnectAdvanceMode(handles,varargin)
av=OSP_DATA('GET','AdvanceButtonHandles');
if any(ishandle(av))
	set(av(ishandle(av)),'Visible','off')
end
P3_AdvTgl('ChangeTgl',handles.advtgl_status,handles);


function ConnectAdvanceMode(handles,varargin)
function msg=SaveData(handles)
msg='';
function [msg, f]=MakeMfile(handles)
msg='';f='';
function msg=Export2WorkSpace(hs)
msg='No Export Program in this mode.';
function ChangeLayout(handles)
% Change Layout Data
persistent fstr list;
global WinP3_EXE_PATH;


% Reset List
if nargin==0
	fstr={};list={};return;
end

hObject=handles.pop_Layout;
list0=get(hObject,'UserData');
if isempty(list0)
	lfile0='';
else
	lfile0=list0{get(hObject,'Value')}; % Layout-File (Default)
end

%---------------------------------
% Search LayoutFile for Single Ana
%---------------------------------
if isempty(fstr) || isempty(list)
	
	% SearchPath (1)
	osppath     = OSP_DATA('GET','OspPath');
	[pp ff] = fileparts(osppath);
	%searchPath  = [osppath filesep 'ospData'];
	%searchPath  = [osppath filesep 'LAYOUT'];
	%list=find_file('^LAYOUT\w+.mat$', searchPath,'-i');
	list={};
	% Meeting on 27-Apr-2007. !! Add LAYOUT Path!!
	%searchPath2 = [osppath filesep '..' filesep 'LAYOUT'];
	
	% SearchPath (2)
	if( strcmp(ff,'WinP3')~=0 )
		searchPath2 = [osppath filesep '..' filesep 'LAYOUT'];
	else
		searchPath2 = [osppath filesep 'LAYOUT'];
	end
	if exist(searchPath2,'dir')
		list2=find_file('^LAYOUT\w+.mat$', searchPath2,'-i');
		list={list{:},list2{:}};
		clear lsit2 searchPath2
	end

	idx000=length(list);
	
	%- Search in PluginDir
	if( strcmp(ff,'WinP3')~=0 )
		searchPath2 = [osppath filesep '..' filesep 'PluginDir'];
	else
		searchPath2 = [osppath filesep 'PluginDir'];
	end
	if exist(searchPath2,'dir')
		list2=find_file('^LAYOUT\w+.mat$', searchPath2,'-i');
		list={list{:},list2{:}};
		clear lsit2 searchPath2
	end
	
	idx001=length(list);
	
	% SearchPath (3)
	searchPath3 = [osppath filesep 'SimpleModeDir' filesep 'Recipe'];
	if exist(searchPath3,'dir')
		list3=find_file('^LAYOUT\w+.mat$', searchPath3,'-i');
		list={list{:},list3{:}};
		clear lsit3 searchPath3
	end
	
	idx002=length(list);
	
	% XX DIR XX
	if ~isempty(WinP3_EXE_PATH)
		list3=find_file('^LAYOUT\w+.mat$', WinP3_EXE_PATH,'-i');
		list={list{:},list3{:}};
		clear list3
	end

	% Set lbx_layoutfile LIST
	fstr=cell([1,length(list)]);
	for idx=1:idx000
		if 1,
			% for future..
			%   LAYOUT is too old...
			load(list{idx},'LAYOUT');
		end
		if exist('LAYOUT','var')  && ...
				isfield(LAYOUT,'FigureProperty') && ...
				isfield(LAYOUT.FigureProperty,'Name')
			fstr{idx}=LAYOUT.FigureProperty.Name;
		else
			[p f e]=fileparts(list{idx});
			if 0, f=[p filesep f e];end
			fstr{idx}=f;
		end
	end
	
	for idx=idx000+1:idx001
		if 1,
			% for future..
			%   LAYOUT is too old...
			load(list{idx},'LAYOUT');
		end
		if exist('LAYOUT','var')  && ...
				isfield(LAYOUT,'FigureProperty') && ...
				isfield(LAYOUT.FigureProperty,'Name')
			fstr{idx}=['[PLG] ' LAYOUT.FigureProperty.Name];
		else
			[p f e]=fileparts(list{idx});
			if 0, f=[p filesep f e];end
			fstr{idx}=f;
		end
	end
	
	% add (in recipe)
	for idx=idx001+1:idx002
		%   LAYOUT is too old...
		load(list{idx},'LAYOUT');
		if exist('LAYOUT','var')  && ...
				isfield(LAYOUT,'FigureProperty') && ...
				isfield(LAYOUT.FigureProperty,'Name')
			xx=strmatch(LAYOUT.FigureProperty.Name,fstr(1:idx-1));% Name Check
			if isempty(xx)
				fstr{idx}=['[Normal Mode] ' LAYOUT.FigureProperty.Name];
			else
				% Same name : donot care.
				fstr{idx}=['[Normal Mode] ' LAYOUT.FigureProperty.Name];
			end
		end
	end
	
	% add (in recipe)
	for idx=idx002+1:length(list),
		%   LAYOUT is too old...
		load(list{idx},'LAYOUT');
		if exist('LAYOUT','var')  && ...
				isfield(LAYOUT,'FigureProperty') && ...
				isfield(LAYOUT.FigureProperty,'Name')
			xx=strmatch(LAYOUT.FigureProperty.Name,fstr(1:idx-1));% Name Check
			if isempty(xx)
				fstr{idx}=['[Added] ' LAYOUT.FigureProperty.Name];
			else
				% Same name : donot care.
				fstr{idx}=['[Added] ' LAYOUT.FigureProperty.Name];
			end
		end
	end

	% Sort
	[fstr,idx]=sort(fstr);
	list=list(idx);
end
set(hObject, 'String', fstr);
set(hObject, 'UserData', list);
v=find(strcmpi(list,lfile0));
if isempty(v),v=1;end
set(hObject, 'Value', v);

function msg=DrawLayout(handles)
msg='';

