function OpenCurrentAirData
% Open Air's Current Data
%
% Load : AirTargetDataFile.airtdf


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Current Air-Data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=fileparts(which('OpenP3fromAir'));
fname=[p filesep 'AirTargetDataFile.airtdf'];
if ~exist(fname,'file')
  error(' No Target Data File.');
end
data=readAirTargetDataFile(fname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Current Air-Data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  disp(data);
  return;
end
[e,msg]=LastAirProject('OPEN');
if msg,errordlg(msg,'Data Open Error');return;end

% --> Reopne 
% TODO : double air-loading....
h=OSP_DATA('GET','POTATOMAINHANDLE');
handles=guidata(h);
POTATo('ChangeProjectIO',h,[],handles);

% Try to Import Data
if 1
  % --> In Change Project IO
  %     Already reload last Data
  %     ... but If user select old data,
  %         Import once again...........
  %     I would like to delete this code.
  AirImportMain(data);
  if strcmpi(get(handles.lbx_fileList,'Visible'),'off')
    POTATo('ChangeProjectIO',h,[],handles);
    AirImportMain(data);
  end
end


ptn='';
for idx=1:length(data.MeasureFile)
  [p f]=fileparts(data.MeasureFile{idx});
  ptn=[ptn '(' f(1:end-4) ')|'];
end
if ~isempty(ptn)
  ptn(end)=[];
end
set(handles.edt_searchfile,'String',ptn);
POTATo('edt_searchfile_Callback',handles.edt_searchfile,[],handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=readAirTargetDataFile(fname)
fid=fopen(fname,'r');

try
  % Read Version
  ver=fread(fid,8,'*char');
  confine_filepos(fid,8);
  data.ver=sprintf('%s',ver); % Delete after \0

  % Key ( _$TARGETDATAF$_ )
  data.key=sprintf('%s',fread(fid,16,'*char'));
  confine_filepos(fid,24);
  
  % Number 
  data.num=str2double(sprintf('%s',fread(fid,4,'*char')));
  confine_filepos(fid,28);

  data.SettingFile=cell(data.num,1);
  data.MeasureFile=cell(data.num,1);
  num=28;
  for idx=1:data.num
    data.SettingFile{idx}=sprintf('%s',fread(fid,260,'*char'));
    num=num+260;
    confine_filepos(fid,num);
    data.MeasureFile{idx}=sprintf('%s',fread(fid,260,'*char'));
    num=num+260;
    confine_filepos(fid,num);
  end
  
catch
  fclose(fid);
  rethrow(lasterror);
end
fclose(fid);
