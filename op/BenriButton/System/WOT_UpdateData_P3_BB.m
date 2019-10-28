function str=WOT_UpdateData_P3_BB(hs)
% Load or Update WOT Data from special-directory
% Project-Management (Benri-Button System-Function)

persistent ddir; % Data-Directory (Save)
str='WOT: data update';
if nargin<=0,return;end

vb=true; % Verbose Option

try
  %------------
  % get project
  %------------
  pj=getProject;
  if isempty(pj)
    error('No Project');
  end
  tdir=uigetdir(ddir,'WOT Data Directory');
  if isequal(tdir,0)  
    % Cancel?
    return;
  end
  ddir=tdir;
  % get Load Data List
  %-------------------
  fs=find_file('ktmset',tdir,'-i');
  
  % Current Data-List
  %-------------------
  dl=DataDef2_RawData('loadlist');

  % SETTING
  %-------------------
  rnmOpt=OSP_DATA('GET','SP_Rename');
  ano   =OSP_DATA('GET','SP_ANONYMITY');
  OSP_DATA('SET','SP_Rename','-');
  OSP_DATA('SET','SP_ANONYMITY',true); % since 1.15

  if ~isempty(dl)
    fnames={dl.filename};
  else
    fnames={};
  end
  
  % Find WOT-Setting File (ktmset)
  for ii=1:length(fs)
    
    try
      [h d]=prepro_hiPOT_X('Execute',fs{ii});
      fname0 = h.TAGs.filename;
      if ~isempty(fnames) && any(strcmp(fnames,fname0))
        % Already read?
        if vb
          disp(['Ignore ' fname0]);
        end
        continue;
      end
      fnames{end+1}=fname0;
      DataDef2_RawData('save',h,d);
      if vb
        disp(['Update ' fname0]);
      end
    catch ME
      fprintf(2,'Read Error: %s\n\t%s\n',fs{ii},ME.message);
    end
  end
  
  % recover Setting
  try
    OSP_DATA('SET','SP_Rename',rnmOpt);
    OSP_DATA('SET','SP_ANONYMITY',ano);
  catch ME0
    % Donot care
    if vb
      disp(ME0);
    end
  end
  
  % get handles
  if isstruct(hs) && isfield(hs,'figure1') && ishandle(hs.figure1)
    hs0=hs;
  else
    hs0=guidata(OSP_DATA('GET','POTATOMAINHANDLE'));
  end
  
  % POTATo GUI Update (Change Project)
  set(0,'CurrentFigure',hs0.figure1);
  POTATo('ChangeProjectIO',hs0.figure1,[],hs0);
catch ME
  errordlg(ME.message);
end


%==========================================================================
function pj=getProject
% get Project
%==========================================================================

% Launch Check
if ~OSP_DATA,
  error('P3 is not running');
end
if ~OSP_DATA('GET','isPOTAToRunning')
  error('P3 is not running');
end

% Load Current Project..
pppt=OSP_DATA('GET', 'PROJECTPARENT'); %ParentProjectPath
if isempty(pppt) || ~exist(pppt,'dir')
  error('No Project-Directory');
end
pj=OSP_DATA('GET','PROJECT');
if isempty(pj)
  error('No Project');
end
