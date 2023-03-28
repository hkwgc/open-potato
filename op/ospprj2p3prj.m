function ospprj2p3prj(dir)
% OSP �v���W�F�N�g�� P3 �v���W�F�N�g�ɃC���|�[�g����֐��ł��B
%
% Syntax : 
%    ospprj2p3prj(dir)
% �ϐ��F
%    dir : OSP-Project �����p Directory
% -------------------------------------------------------------------------
% �ڍׂȎg������ �ʃt�@�C���w�v���W�F�N�g�̈��p��.ppt�x�����Q�Ƃ��������B
% -------------------------------------------------------------------------
% Known Bugs:
%    �f�[�^���������ꍇ, �܂��Signal-Data�̓Ǎ��݂����s����B
%      �����̏���:
%       1�b�ȓ��Ƀ��[�h�E�ۑ������s�ł��A
%       rand���Q��A�����čs��������, �����_�ȉ���2�ʂ܂ň�v�����Ƃ��B
%
% -------------------------------------------------------------------------
% See also : OSPPROJECT, POTATOPROJECT,
%            DATADEF_GROUPDATA,
%            DATADEF2_RAWDATA,
%            DATADEF2_ANSLYSIS.
%
% * OSP�͍������p��������Ă��Ȃ����� ���{�� �R�����g�ɂ��Ă���܂��B
%

 
% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Original author : Masanori Shoji
% create : 2007.04.11
% $Id: ospprj2p3prj.m 180 2011-05-19 09:34:28Z Katura $

% �o�O�C�������F
% ----------------
% Revision 1.01: Shoji 2007/04/12
% ----------------
% 2007.04.10 �̓d�b�^���[�����璅��:
% OSP�v���W�F�N�g��P3�Ɉڂ��d�g�݁B
%
% �@���V�s�iFilterData)�̃R�s�[
% �AGroupData ��Raw�{Ana
%
% �����t�@�C������Ȃ� GroupData��MultiMode �ɂđΉ�����B
%  ����͕ۗ� �Ł@�Y: 2007.04.13 (���̑ō����܂�)
%
% ----------------
% Revision 1.02: Shoji  2007/04/12
% ----------------
% Signal-Data�̓Ǎ��ݒǉ�
%
% ----------------
% Revision 1.03: Shoji  2007/04/23
% ----------------
% GroupData�Ǎ��ݎ��s�ŏI������o�O���C���B
%  (Tsuzuki�w�E�o�O�C��)
%
% ----------------
% Revision 1.04: Shoji 2007/05/17
% ----------------
% �����t�@�C������Ȃ� GroupData�� Multi Mode�ɂēǍ��݁B
% �w���v�R�����g�ύX
% 
%


%%%%%%%%%%%%%%%%%%%%
% P3 �̋N�� 
%  ���݂�Project Directory�擾
%  �p�X/�֐��̏�����
%%%%%%%%%%%%%%%%%%%
h      =P3;
handles=guidata(h);
pdir  = OSP_DATA('get','PROJECTPARENT');
if isempty(pdir)
  %=======================
  % Project Parent �̐ݒ�
  % (�����Ȃ���΁j
  %=======================
  if isempty(pdir),pdir=pwd;end
  pdir = uigetdir(pdir,'Select Project Directory');

  % Cancel Check
  if isequal(pdir,0),return;end
  % Change Project-Parent-Directory
  POTATo('ChangeProjectParentIO',h,pdir,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Searching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------
% Open Search Files
%-------------------
if nargin<1 || ~exist(dir,'dir')
  dir=uigetdir(pwd,'Search Directory');
  if isequal(dir,0),return;end
end

%-------------------
% Search OspDir
%-------------------
rslt=find_file('^OspDataDir$',dir,'-i');

%-------------------
% Loging A
%-------------------
fname=[pwd filesep 'ospprj2p3prj_find.html'];
fp=openhtml(fname);
fprintf(fp,'<H1>Find Files</H1><br>\n');
fprintf(fp,'&nbsp;<H2>Search Dirs:</H2><br>\n');
fprintf(fp,'&nbsp;&nbsp;%s<br>\n',dir);
fprintf(fp,'&nbsp;<H2>Found Project:</H2><br>\n');
rslt_bk=rslt;
for id=1:length(rslt)
  rslt{id}(end-10:end)=[];
  fprintf(fp,'&nbsp;&nbsp;%s<br>\n',rslt{id});
end
closehtml(fp);
web(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Each Dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> �������炪�{�ԂŁ[���B
for id=1:length(rslt)
  prj0=OspProject('GetProjectDataInDir',rslt{id});
  %===================================
  % TODO : �I������Ă��� Project�̕\���F
  %===================================
  % �Ƃ肠�����A�ׂ���ƕW���o�͂�
  disp('Import P-3 Project from..');
  s=OspProject('Info',prj0);
  disp(char(s));
  disp('');

  %===================================
  % �V Project�̍쐬 (������̍쐬�j
  %===================================
  uiPOTAToProject('Action','New');
  % Change Project!
  prj=OSP_DATA('GET','PROJECT');
  % Cancel : �Ƃ΂��܁[���B
  if isempty(prj), continue;end
  % TODO : �R�s�[��̕\��
  %        ... GUI������H (�H�� 2 hour���炢�Ō��ς���\�����Ȃ�)
  disp('Import Project :');
  s=POTAToProject('Info',prj);
  disp(char(s));
  disp('');
  
  %===================================
  % �K�v�ȏ����Ƃ��Ă��Ă���
  %===================================
  cp_from= rslt_bk{id};
  cp_to  = [prj.Path filesep prj.Name];
  
  %===================================
  % �ꂵ��(Filter Data)�̂��ҁ[
  %===================================
  f=[filesep 'DataListFilterData.mat'];
  if exist([cp_from f],'file')
    [r,msg]=copyfile([cp_from f],[cp_to f]);
    if ~r ,
      fprintf('  XXX Could not Import Filter Data : %s\n',msg);
    else
      fprintf('  ==> Import Filter Data\n');
    end
  else
    fprintf('  --- No Filter Data\n');
  end
  
  %===================================
  % Group Data �̓o�^
  %===================================
  % + + + + + + + + + + + + + + 
  % ��U�AOSP�̃v���W�F�N�g���Z�b�g
  % + + + + + + + + + + + + + + 
  OSP_DATA('SET','PROJECT',prj0);
  gdlist = DataDef_GroupData('loadlist');
  % �ۑ����̃t�@�C�������K���F(�x���������Ȃ�����)
  OSP_DATA('SET','SP_Rename','-');
  namelist={}; % GD�ŕۑ�����閼�O���X�g
  
  for gid=1:length(gdlist)
    % + + + + + + + + + + + + + + 
    % ��U�AOSP�̃v���W�F�N�g���Z�b�g
    % + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj0);

    try
      gd=DataDef_GroupData('load',gdlist(gid));
      fprintf(' * try to Import Group Data Named : %s\n',gd.Tag);
	catch
      disp(['  XXX GD-Load Error Named : ' gdlist(gid).Tag]);
    end
    
    %--------------------
    % Check Single File? 
    %--------------------
    if length(gd.data)~=1,
      %--------------------------------------------------------------------
      % Multi Data�Ƃ��ĕۑ�!
      %--------------------------------------------------------------------
      namelist=group2multi(gd,prj,h,handles,namelist);
    else
      %--------------------------------------------------------------------
      % Ana Data�Ƃ��ĕۑ�!
      %--------------------------------------------------------------------
      namelist=group2ana(gd,prj,h,handles,namelist);
    end
    
    %---------------------------------
    % ���̑��F
    %---------------------------------
    if 0
      % --> �{���̓e�X�g�����Ƃ�����Ƃ����e�X�g�V�i���I���ق����B
      %     Project Viewer �݂����̂��̂��ɍ��ׂ�?
      %
      % �f�o�b�O�p�F���ʂ� POTATo�ɔ��f������B
      OSP_DATA('SET','PROJECT',prj);
      POTATo('ChangeProjectIO',h,[],handles);
      % ���̂������� ��肭�����Ă���Ƃ������Ƃ������l�A����
      disp('�ł΂������[�ǎ��s���F <- Break���Ă�ӏ�');
    end
  end
  
  %===================================
  % Signal Data �̓o�^
  %===================================
  %==> SD���s�v�ȏꍇ if 0 �� if 1 �ɕύX
  if 0,continue;end
  % + + + + + + + + + + + + + + 
  % ��U�AOSP�̃v���W�F�N�g���Z�b�g
  % + + + + + + + + + + + + + + 
  OSP_DATA('SET','PROJECT',prj0);
  splist = DataDef_SignalPreprocessor('loadlist');
  for sid=1:length(splist)
    % + + + + + + + + + + + + + + 
    % ��U�AOSP�̃v���W�F�N�g���Z�b�g
    % + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj0);
    
    % GD�ł��łɕۑ����ꂽ?
    if any(strcmpi(namelist,splist(sid).filename)),continue;end
    sp=splist(sid);
	try
		sp.data=DataDef_SignalPreprocessor('load',sp);
	catch
		fprintf(' XXX Could not Load Data \n');continue;
	end
	fprintf(' * try to Import Signal Data Named : %s\n',sp.filename);
	
    %---------------------------------
    % Make Raw-Data with Stimulation
    %---------------------------------
    key.actdata.data=sp;
    key.filterManage.HBdata=[]; % No Filter bad stim
    [data,hdata]=DataDef_SignalPreprocessor('make_ucdata',key);
    
    % + + + + + + + + + + + + + + + + + + + + + + + + + 
    % Project�̏�Ԃ� P-3 �̐V�K�쐬�������̂ɖ߂��Ă����B
    % + + + + + + + + + + + + + + + + + + + + + + + + + 
    OSP_DATA('SET','PROJECT',prj);
    POTATo('ChangeProjectIO',h,[],handles);
    try
      % --> Raw & Ana �̕ۑ�
      %  !! -- Ana �������ۑ�����邱�Ƃɒ��� -- !!
      DataDef2_RawData('save',hdata,data);
      fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
      fprintf('  ==> Save Ana Data : Named : %s\n',hdata.TAGs.filename);
    catch
      fprintf('  XXX Could not Save Raw Data\n');
    end    
  end

  
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  % Project�̏�Ԃ� P-3 �̐V�K�쐬�������̂ɖ߂��Ă����B
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  OSP_DATA('SET','PROJECT',prj);
  POTATo('ChangeProjectIO',h,[],handles);
end

disp('*************** Done **************');

function fp=openhtml(fname)
% Open HTML
fp=fopen(fname,'w');
fprintf(fp,'<HTML language="ja">\n<HEAD>\n');
fprintf(fp,'\t<TITLE> OSP Project 2 P-3Project</TITLE>\n');
fprintf(fp,'</HEAD>\n<BODY>\n');

function closehtml(fp)
% Close HTML
fprintf(fp,'</BODY>\n</HTML>');
fclose(fp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function namelist=group2ana(gd,prj,h,handles,namelist)
% (OSP) Group-Data to (P3) Ana-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------
% Make Raw-Data with Stimulation
%---------------------------------
key.actdata.data=gd;
key.filterManage.HBdata=[]; % No Filter bad stim
[data,hdata]=DataDef_GroupData('make_ucdata',key);

% + + + + + + + + + + + + + + + + + + + + + + + + +
% Project�̏�Ԃ� P-3 �̐V�K�쐬�������̂ɖ߂��Ă����B
% + + + + + + + + + + + + + + + + + + + + + + + + +
OSP_DATA('SET','PROJECT',prj);
POTATo('ChangeProjectIO',h,[],handles);

% --------------------------------------------------
% 
% --------------------------------------------------
if isempty(hdata),
	fprintf('  XXX Could not Save Ana Data\n');
	return;
end
if any(strcmpi(namelist,hdata.TAGs.filename))
  % Raw-Data is already saved,
  % Make Ana File Only
  try
    ana = DataDef2_Analysis('loadlist',hdata.TAGs.filename);
    ana = DataDef2_Analysis('load',ana);
    % Rename
    s=regexpi(namelist,[hdata.TAGs.filename '$']);
    if ~iscell(s),s={s};end
    s=~cellfun('isempty',s);s=sum(s(:));
    ana.filename=sprintf('RCP%d_%s',s,hdata.TAGs.filename);
    % Change Recipe
    ana.data(end).filterdata = gd.data(end).filterdata;
    DataDef2_Analysis('save',ana);
    namelist{end+1}=ana.filename;
  catch
    fprintf('  XXX Could not Save Ana Data\n');
  end
else
  try
    % --> Raw & Ana �̕ۑ�
    %  !! -- Ana �������ۑ�����邱�Ƃɒ��� -- !!
    rd=DataDef2_RawData('save',hdata,data);
    fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
    namelist{end+1}=hdata.TAGs.filename; % GD�ŕۑ�����閼�O���X�g�ɒǉ�
  catch
    fprintf('  XXX Could not Save Raw Data\n');
  end
  
  %---------------------------------
  % Make ANA-Data : ���V�s�̕ҏW
  %---------------------------------
  try
    % �����ۑ����ꂽ Ana Data �̃L�[�����擾
    % ==> �������͎d�l���ς�邩������Ȃ��̂�
    %     �ׂ������s�B
    ifk=DataDef2_RawData('getIdentifierKey');
    if 0,k=rd.name;end
    k  = eval(['rd.' ifk ';']);
    % �����ۑ����ꂽ Aan �̓Ǎ���
    ana = DataDef2_Analysis('loadlist',k);
    ana = DataDef2_Analysis('load',ana);
    % ���V�s�X�V
    ana.data(end).filterdata = gd.data(end).filterdata;
    % Save : Over-Write
    DataDef2_Analysis('save_ow',ana);
    fprintf('  ==> Save Ana Data : Named : %s\n',k);
  catch
    fprintf('  XXX Could not Save Ana Data\n');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function namelist=group2multi(gd,prj,h,handles,namelist)
% (OSP) Group-Data to (P3) Mulit-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------
% Make Raw-Data with Stimulation
%---------------------------------
try
  key.actdata.data=gd;
  key.filterManage.HBdata=[]; % No Filter bad stim
  key.outputtype='cell';
  [cdata,chdata]=DataDef_GroupData('make_ucdata',key);
  
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  % Project�̏�Ԃ� P-3 �̐V�K�쐬�������̂ɖ߂��Ă����B
  % + + + + + + + + + + + + + + + + + + + + + + + + +
  OSP_DATA('SET','PROJECT',prj);
  POTATo('ChangeProjectIO',h,[],handles);
  
  %------------------------
  % Make Default Multi Data
  %------------------------
  multdata.Tag=gd.Tag;
  multdata.NumberOfFiles=length(cdata);
  multdata.ID_number=1;
  multdata.Comment='';
  multdata.CreateDate=now;
  multdata.data.AnaKeys={};
  %--> Add Rename
  wk={struct('name','Sample','type',8192,...
    'region',0,'version',0,'wrapper','PluginWrapPM_Sample',...
    'wrap','PluginWrapPM_Sample','argData',struct('Format','TmpFile'),...
    'enable','on')};
  %--> Add Blocking
  wk{2}=struct('name','Blocking','wrap','FilterDef_TimeBlocking',...
    'argData',...
    struct('BlockPeriod',[5 15],'Marker',1,'wrap','FilterDef_TimeBlocking'),...
    'enable','on');
  if isfield(gd.data(end).filterdata,'BlockData')
    multdata.data.Recipe.default={wk{:}, gd.data(end).filterdata.BlockData{:}};
  else
    multdata.data.Recipe.default=wk;
  end
  
  try,
	  fmd0.HBdata = gd.data(end).filterdata.HBdata;
  catch
	  fmd0.dummmy=0;
  end

  for idx=1:length(cdata)
    data=cdata{idx};hdata=chdata{idx};

    if any(strcmpi(namelist,hdata.TAGs.filename))
      % Raw-Data is already saved,
      % Make Ana File Only
      try
        ana = DataDef2_Analysis('loadlist',hdata.TAGs.filename);
        ana = DataDef2_Analysis('load',ana);
        % Rename
        s=regexpi(namelist,[hdata.TAGs.filename '$']);
        if ~iscell(s),s={s};end
        s=~cellfun('isempty',s);s=sum(s(:));
        ana.filename=sprintf('RCP%d_%s',s,hdata.TAGs.filename);
        % Change Recipe
        ana.data(end).filterdata = fmd0;
        DataDef2_Analysis('save',ana);
        namelist{end+1}=ana.filename;
        multdata.data.AnaKeys{end+1}=ana.filename;
      catch
        fprintf('  XXX Could not Save Ana Data\n');
      end
    else
      try
        % --> Raw & Ana �̕ۑ�
        %  !! -- Ana �������ۑ�����邱�Ƃɒ��� -- !!
        rd=DataDef2_RawData('save',hdata,data);
        fprintf('  ==> Save Raw Data : Named : %s\n',hdata.TAGs.filename);
        namelist{end+1}=hdata.TAGs.filename; % GD�ŕۑ�����閼�O���X�g�ɒǉ�
        multdata.data.AnaKeys{end+1}=hdata.TAGs.filename;
      catch
        fprintf('  XXX Could not Save Raw Data\n');
      end

      %---------------------------------
      % Make ANA-Data : ���V�s�̕ҏW
      %---------------------------------
      try
        % �����ۑ����ꂽ Ana Data �̃L�[�����擾
        % ==> �������͎d�l���ς�邩������Ȃ��̂�
        %     �ׂ������s�B
        ifk=DataDef2_RawData('getIdentifierKey');
        if 0,k=rd.name;end
        k  = eval(['rd.' ifk ';']);
        % �����ۑ����ꂽ Aan �̓Ǎ���
        ana = DataDef2_Analysis('loadlist',k);
        ana = DataDef2_Analysis('load',ana);
        % ���V�s�X�V
        ana.data(end).filterdata = fmd0;
        % Save : Over-Write
        DataDef2_Analysis('save_ow',ana);
        fprintf('  ==> Save Ana Data : Named : %s\n',k);
      catch
        fprintf('  XXX Could not Save Ana Data\n');
      end
    end
  end
  DataDef2_MultiAnalysis('save',multdata);
catch
  fprintf('   XXX TODO: Multi-Data Save\n');
end
    
    
