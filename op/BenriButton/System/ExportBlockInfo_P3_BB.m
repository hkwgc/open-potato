function str=ExportBlockInfo_P3_BB(hs)
% Project-Management (Benri-Button System-Function)
str='Export Block Info';
if nargin<=0,return;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lock —p
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  
  [f p] = uiputfile('*.csv','Export file name');
  fid=fopen([p f],'wt');
  fprintf(fid,'--  POTATo Block Info File  --\n');
  fprintf(fid,'<Mode>,%s\n\n',hdata.BlockInfo.Mode{1});
  for ii=1:length(hdata.BlockInfo.Parameters.DataName)
	  fprintf(fid,'%s,%s,',...
		  hdata.BlockInfo.Parameters.DataKind{ii},...
		  hdata.BlockInfo.Parameters.DataName{ii});
	  for jj=1:size(hdata.BlockInfo.Parameters.Data,1)
		  tmp = hdata.BlockInfo.Parameters.Data{jj,ii};
		  if isinteger(tmp)
			  str=sprintf('%d,',tmp);
		  elseif isfloat(tmp)
			  str=sprintf('%f,',tmp);
		  elseif ischar(tmp)
			  str = sprintf('%s,',tmp);
		  end
		  fprintf(fid,str);
	  end
	  fprintf(fid,'\n');
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





