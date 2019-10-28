function ret=Ref_file_save(Name, Id, Sex, Age, Comment,...
pos_Cz, pos_Nz, pos_Iz, pos_AR, pos_AL)

ret=1;
[fname, dpath, findex] = uiputfile('*.ref','Specify File Name','new.ref');
if findex~=0 
        fpath = fullfile(dpath, fname);
	try
	  fid=fopen(fpath,'w');
	catch
	    msgbox(lasterr);
	    msgbox(['.ref file save error. is ' fpath ' is writable?']);
	    ret=0;
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
else 
    msgbox('ref-data not saved');
    ret=0;
end;
