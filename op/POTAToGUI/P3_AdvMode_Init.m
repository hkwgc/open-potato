function varargout=P3_AdvMode_Init(fnc,varargin)
% POTATo Window : Advanced Mode Initiarlzation Program.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% $Id: P3_AdvMode_Init.m 404 2014-04-16 02:29:23Z katura7pro $

if isempty(fnc),OspHelp(mfilename);end
  
%======== Launch Switch ========
switch fnc,
  case 'make',
    varargout{1}=MakeAdvModeButton_CreateFcn(varargin{:});
  otherwise,
    [varargout{1:nargout}]=feval(fnc,varargin{:});
end
%====== End Launch Switch ======
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [handles,av]=MakeAdvModeButton_CreateFcn(handles)
% Make Advanced Mode Button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global WinP3_EXE_PATH;
%=====================================
% Init Data
%=====================================
OSP_DATA('SET','AdvanceButtonHandles',[]);
% Check double..
if isfield(handles,'advpsb_SetPosition')
  error('There is Advance Mode Button''s');
end

%=====================================
% Make Button's
%=====================================
%---------------------
% Position Setting
%---------------------
handles.advpsb_SetPosition = ...
  subput_advbutton(4,4,1,'Normal',...
  'Tag','advpsb_SetPosition',...
  'String','Position Setting',...
  'Callback',...
  ['hs=guidata(gcbo);',...
  'P3_AdvTgl_status(''Logging'',hs,',...
  '''[Position Setting] : Open & waiting....'');',...
  'h=setProbePosition;', ...
  'waitfor(h);',...
  'setappdata(gcbf,''CurrentSelectFile'',true);', ...
  'P3_AdvTgl_status(''Logging'',hs,',...
  '''[Position Setting] : Done'');',...
  'POTATo(''ChangeProject_IO'',gcbf,[],guidata(gcbf));']);

%---------------------
% Marker Setting
%---------------------
handles.advpsb_SetMark = ...
  subput_advbutton(4,4,2,'Normal',...
  'Tag','advpsb_SetMark',...
  'String','Mark Setting',...
  'Callback',...
  'P3_AdvTgl(''MarkSetting'',guidata(gcbf))');

%---------------------
% Benri-Button
%---------------------
handles.advpsb_BenriButton = ...
  subput_advbutton(4,4,3,'Normal',...
  'Tag','advpsb_BenriButton',...
  'Enable','off',...
  'String','----');
p=OSP_DATA('get','OSPPATH');
%f=find_file('_P3_BB\.[pm]$',[p filesep '..' filesep 'BenriButton'],'-i');
[pp ff] = fileparts(p);
if( strcmp(ff,'WinP3')~=0 )
  f=find_file('_P3_BB\.[pm]$',[p filesep '..' filesep 'BenriButton'],'-i');
else
  f=find_file('_P3_BB\.[pm]$',[p filesep 'BenriButton'],'-i');
end


myid=0;
if ~isempty(f)
  for idx=1:length(f)
    [p,fname]=fileparts(f{idx});
    try
      str=feval(fname);
    catch
      continue;
    end
    myid=idx;break;
  end
end

if ~isempty(WinP3_EXE_PATH)
	% ’Ç‰Á
	try
		f2=find_file('_P3_BB\.[pm]$',[WinP3_EXE_PATH filesep 'BenriButton'],'-i');	
		%--- Check Function List
		[f, f2]=sub_CheckList(f, f2);
	catch
	end
end

if myid~=0
  if length(f)>=myid+1
    set(0,'CurrentFigure',handles.figure1);
    hcm=uicontextmenu;
    msg={'----------------------------------------',...
        ' P3 Warning : Bad Benri-Button Function',...
        '-----------------------------------------'};
    fnameall={};
    for idx=1:length(f)
      [p,fname]=fileparts(f{idx});
      if any(strcmp(fname,fnameall)),continue;end
      fnameall{end+1}=fname;
      if 0,disp(p);end
      try
        str=feval(fname);
        uimenu(hcm,'Label',str,...
          'UserData',fname,...
          'Callback',...
          ['fname=get(gcbo,''UserData'');',...
            'hs=guidata(gcbf);h=hs.advpsb_BenriButton;',...
            'lbl=get(gcbo,''Label'');',...
            'set(h,''String'',lbl,',...
            '''Callback'',[fname ''(guidata(gcbf));'']);',...
            'OSP_DATA(''SET'',''P3_BENRIBUTTON_FUNCTION'',fname);']);
      catch
        msg{end+1}=[' x ' fname ',' lasterr];
        continue;
      end
		end
		fnameInit=fname;
		if ~isempty(WinP3_EXE_PATH)
			for idx=1:length(f2)
				[p,fname]=fileparts(f2{idx});
				if any(strcmp(fname,fnameall)),continue;end
				fnameall{end+1}=fname;
				if 0,disp(p);end
				try
					str=P3_PluginEvalScript(fname,[]);
					if isempty(str)
						continue;
					end
					str=['* ' str];
					uimenu(hcm,'Label',str,...
						'UserData',fname,...
						'Callback',...
						['fname=get(gcbo,''UserData'');',...
						'hs=guidata(gcbf);h=hs.advpsb_BenriButton;',...
						'lbl=get(gcbo,''Label'');',...
						'set(h,''String'',lbl,',...
						'''Callback'',[''P3_PluginEvalScript('''''' fname '''''',[],guidata(gcbf));'']);',...
						'OSP_DATA(''SET'',''P3_BENRIBUTTON_FUNCTION'',fname);']);
					%'''Callback'',[fname ''(guidata(gcbf));'']);',...
				catch
					msg{end+1}=[' x ' fname ',' lasterr];
					continue;
				end
			end
		end
    set(handles.advpsb_BenriButton,'uicontextmenu',hcm);
    if length(msg)~=3
      warndlg(msg,'P3 BBB Function Warning','replace');
    end
	end
	
	
  % Set Default Benributton.
  try
    fname0=OSP_DATA('GET','P3_BENRIBUTTON_FUNCTION');
  catch
    fname0='';
  end
  if isempty(fname0),
    if any(strcmp('Project_Manage_P3_BB',fnameall)),
      fname0='Project_Manage_P3_BB';
    end
  end
  if ~isempty(fname0),
    fname=fname0;
  end
  try
      set(handles.advpsb_BenriButton,...
          'Enable','on',...
          'String',feval(fnameInit),...
          'Callback',...
          [fnameInit '(guidata(gcbf));']);
  catch
      % error : do nothing
      set(handles.advpsb_BenriButton,...
          'Enable','on',...
          'String','---',...
          'Callback',...
          'helpdlg(''Select Function by right-click.'')');
  end
end

%---------------------
% 2nd-Lvl-Ana
%---------------------
if 0
  % Comment Outed
  % Meeting at 2007.03.09 (Fri).
  handles.advpsb_2ndLvlAna = ...
    subput_advbutton(4,4,4,'Normal',...
    'Tag','advpsb_2ndLvlAna',...
    'String','To 2nd-Lvl-Ana',...
    'Callback',...
    ['h=gcbo;',...
    'set(h,''UserData'',true);',...
    'POTATo(''ChangeAnalysisModeIO'',gcbf,[],guidata(gcbf));',...
    'set(h,''UserData'',false);']);
end

%---------------------
% Multi-Ana
%---------------------
handles.advpsb_MultiAna = ...
  subput_advbutton(4,4,4,'Normal',...
  'Tag','advpsb_MultiAna',...
  'String','Make Mult-File',...
  'UserData',false,...
  'Callback',...
  ['h=gcbo;',...
  'set(h,''UserData'',true);',...
  'try,',...
  '  POTATo(''ChangeAnalysisModeIO'',gcbf,[],guidata(gcbf));',...
  'end;',...
  'set(h,''UserData'',false);']);

%= = = = = = = = = = = = = = = = = =
% Difference Recipes
%= = = = = = = = = = = = = = = = = =
handles.advpsb_ForceBatch = ...
  subput_advbutton(4,4,1,'Normal',...
  'Tag','advpsb_EditParentFile',...
  'String','Clear Recipes',...
  'Callback',...
  ['hs=guidata(gcbo);',...
  'POTATo_win_Make_MultiAnalysis(''FoceBatch'',hs);']);

%---------------------
% Edit Parent-Files
%---------------------
handles.advpsb_EditParentFile = ...
  subput_advbutton(4,4,1,'Normal',...
  'Tag','advpsb_EditParentFile',...
  'String','Modify Recipe',...
  'Callback',...
  ['hs=guidata(gcbo);',...
  'POTATo_win_MultiAnalysis(''EditParentFile'',hs);']);

%=====================================
% Make Frame Control Advanced Button
%=====================================
handles=P3_AdvTgl('Create',handles);

%====================
% Save GUI-Data
%====================
guidata(handles.figure1,handles);

%====================
% Set Application Data 
% (for Disable)
%====================
av=OSP_DATA('GET','AdvanceButtonHandles');
av=[av(:);...
  handles.advpsb_SetPosition; ...
  handles.advpsb_SetMark;...
  handles.advpsb_BenriButton;...
  handles.advpsb_MultiAna;...
  handles.advpsb_ForceBatch;...
  handles.advpsb_EditParentFile];
  % handles.advpsb_2ndLvlAna

set(av,'Visible','off');
OSP_DATA('SET','AdvanceButtonHandles',av);
return;

function [fr,f2]=sub_CheckList(f, f2)
fr={};
a=strfind(f2, 'SWITCH_ListAllFuncs___P3_BB');
%if ~isempty(cell2mat(a))
aid=find(~cellfun(@isempty,a));
if ~isempty(aid)
  fr=f;
  f2(aid)=[];
	return;
end

LST={...
	'ImportBrainHeadFile__P3_BB',...
	'subDrawImage__P3_BB',...
	'CopyStimData_P3_BB',...
	'ExportBlockInfo_P3_BB',...
	'ImportBlockInfo_P3_BB',...
	'InstallNewPlugin__P3_BB',...
	'Merge_DataFile_P3_BB',...
	'Project_Manage_P3_BB',...
	'subTerminateAllWindows__P3_BB',...
	'subTerminateMSGBox__P3_BB',...
};

for k=1:length(f)
	[t tt ]=fileparts(f{k});
	if ~isempty(cell2mat(strfind(LST,tt)))
		fr{end+1}=f{k};
	end
end





