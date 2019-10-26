function ret = Ref_file_save_current(path, fname, Name, Id, Sex, Age, Comment,...
pos_Cz, pos_Nz, pos_Iz, pos_AR, pos_AL)

current_dir = pwd;
osp_path=OSP_DATA('GET','OspPath');
if isempty(osp_path)
  osp_path=fileparts(which('POTATo'));
end
[pp ff] = fileparts(osp_path);
if( strcmp(ff,'WinP3')~=0 )
  dpath = ['WinP3_mcr\' path];
else
  dpath = path;
end

fpath = fullfile(dpath, fname);
try
  fid=fopen(fpath,'w');
catch
  cd(current_dir);
  error(['file open error for : ' fpath ': current is ' current_dir]);
end
cd(current_dir);
if(fid==-1)
  ret = 0;
  error(['file open error for : ' fpath ': current is ' current_dir]);
  return;
end

	fprintf(fid,'[User]\n');
	fprintf(fid,'Name=%s\n',Name);
	fprintf(fid,'ID=%s\n',Id);
	fprintf(fid,'Comment=%s\n',Comment);
	fprintf(fid,'Sex=%s\n',Sex);
	fprintf(fid,'Age=%3dy\n',str2num(Age));

% in [mm]
	fprintf(fid,'[LeftEar]\n');
	fprintf(fid,'X=%.2f\n',pos_AL(1,1));
	fprintf(fid,'Y=%.2f\n',pos_AL(1,2));
	fprintf(fid,'Z=%.2f\n',pos_AL(1,3));
	fprintf(fid,'[RightEar]\n');
	fprintf(fid,'X=%.2f\n',pos_AR(1,1));
	fprintf(fid,'Y=%.2f\n',pos_AR(1,2));
	fprintf(fid,'Z=%.2f\n',pos_AR(1,3));
	fprintf(fid,'[Nasion]\n');
	fprintf(fid,'X=%.2f\n',pos_Nz(1,1));
	fprintf(fid,'Y=%.2f\n',pos_Nz(1,2));
	fprintf(fid,'Z=%.2f\n',pos_Nz(1,3));
	fprintf(fid,'[Back]\n');
	fprintf(fid,'X=%.2f\n',pos_Iz(1,1));
	fprintf(fid,'Y=%.2f\n',pos_Iz(1,2));
	fprintf(fid,'Z=%.2f\n',pos_Iz(1,3));
	fprintf(fid,'[Top]\n');
	fprintf(fid,'X=%.2f\n',pos_Cz(1,1));
	fprintf(fid,'Y=%.2f\n',pos_Cz(1,2));
	fprintf(fid,'Z=%.2f\n',pos_Cz(1,3));
fclose(fid);
ret = 1;
end