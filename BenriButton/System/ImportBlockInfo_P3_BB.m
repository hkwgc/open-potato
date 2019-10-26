function str=ImportBlockInfo_P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Import Block Info';
if nargin<=0,return;end

try

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  vls      = get(hs.lbx_fileList,'Value');
  if length(vls)>1, warndlg('please select one file.');return;end
  datalist = get(hs.lbx_fileList,'UserData');
  datalist = datalist(vls);
  
  an=DataDef2_Analysis('load',datalist(1));
  rd=DataDef2_RawData('loadlist',an.data.name);
  [hdata,data]=DataDef2_RawData('load',rd);
  
  if ~isfield(hdata,'BlockInfo')
	  hdata.BlockInfo = sub_Make_BlockInfo(hdata);
  end
    
  [f p] = uigetfile('*.csv','Export file name');
  fid=fopen([p f],'rt');
  s=fgetl(fid);
  if isempty(strfind(s, '--  POTATo Block Info File  --'))
	  warndlg('File is NOT for BlockInfo.');
	  fclose(fid);return;
  end
  
  s=fgetl(fid);
  strMode=sscanf(s,'<Mode>,%s');
  strMode=strrep(strMode,',','');
  tmp={'Event','Block'};
  if ~strcmp(strMode, tmp{hdata.StimMode})
	  warndlg(sprintf('%s\nOriginal: %s\nSelected file: %s','Mode is different.',tmp{hdata.StimMode}, strMode));
	  fclose(fid);return;
  end
  fgetl(fid);%skip 1 line
  
  ii=1;
  while 1
	  s=fgetl(fid);
	  if ~ischar(s), break;end
	  ctg=findstr(s,',');
	  s1=s(1:ctg(1)-1);
	  s2=s(ctg(1)+1:ctg(2)-1);
	  if strcmpi(s1,'numeric')
		  d1=sscanf(s(ctg(2)+1:end),'%f,');
	  elseif strcmpi(s1,'text')
		  d1=sscanf(s(ctg(2)+1:end),'%s,');%not checked!
	  end
	  
	  if length(d1)~=size(hdata.stim,1)
		  warndlg(sprintf('%s\nOriginal: %s\nSelected file: %s','Block number is different.',size(hdata,stim,1), length(d1)));
		  fclose(fid);return;
	  end
	  
	  for jj=1:length(d1)
		  eval('hdata.BlockInfo.Parameters.Data{jj,ii}=d1(jj);');
	  end
	  eval('hdata.BlockInfo.Parameters.DataKind{ii}=s1;');
	  eval('hdata.BlockInfo.Parameters.DataName{ii}=s2;');
	  
	  ii=ii+1;	  
  end
  fclose(fid);
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Save
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  DataDef2_RawData('save_ow',hdata,data);

catch  
  rethrow(lasterror);
end



function BlockInfo = sub_Make_BlockInfo(hdata)

blockNum=size(hdata.stim,1);

tmp={'Event','Block'};

BlockInfo.Mode = tmp(hdata.StimMode);
BlockInfo.Parameters.Data = cell(blockNum, 2);
for ii=1:blockNum
	BlockInfo.Parameters.Data{ii,1}=ii;
	BlockInfo.Parameters.Data{ii,2}=hdata.stim(ii,1);
end
BlockInfo.Parameters.DataName={'Serial No.','Mark kind'};
BlockInfo.Parameters.DataKind={'Numeric','Numeric'};




