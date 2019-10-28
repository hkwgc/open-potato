function [User RefPoints] = Ref_file_read(fid)

User = struct('filename',[],'ID_number',[],'subjectname',[],'comment',[],'age',[],'sex',[],'date',[]);
RefPoints = struct('LeftEar',[],'RightEar',[],'Nasion',[],'Back',[],'Top',[]);

pos_Cz=[]; pos_Nz=[]; pos_Iz=[]; pos_AR=[]; pos_AL=[];
Name=''; Id=''; Sex=''; Age=''; Comment='';

line=fgetl(fid);
[rows colms]=size(line);
while(line~=-1)
	if(line(1,1)=='[')
		last_idx=findstr(line,']');
		read_mode = line(1,2:(last_idx-1));
	else
		split_idx=findstr(line,'=');
		[size_row size_col]=size(split_idx);
		if(size_col<=0), continue, end;
		split_idx=split_idx(1,1);
		Param_Name = line(1,1:(split_idx-1));
    if(colms<=split_idx)
      Param_Value=' ';
    else
		  Param_Value = line(1,(split_idx+1):end);
    end

		switch read_mode
		case 'User'
			switch lower(Param_Name)
			case 'name'
				Name=Param_Value;
			case 'id'
				Id=Param_Value;
			case 'sex'
				Sex=Param_Value;
			case 'age'
				y_idx=findstr(Param_Value,'y');
				Age=Param_Value(1:(y_idx-1));
			case 'comment'
				Comment=Param_Value;
			end
		otherwise
			switch lower(Param_Name)
			case 'x'
				xyz_index = 1;
			case 'y'
				xyz_index = 2;
			case 'z'
				xyz_index = 3;
			end
			switch lower(read_mode)
			case 'leftear'
				pos_AL(1,xyz_index)=str2num(Param_Value);
			case 'rightear'
				pos_AR(1,xyz_index)=str2num(Param_Value);
			case 'nasion'
				pos_Nz(1,xyz_index)=str2num(Param_Value);
			case 'back'
				pos_Iz(1,xyz_index)=str2num(Param_Value);
			case 'top'
				pos_Cz(1,xyz_index)=str2num(Param_Value);
			end
		end
    end
    line=fgetl(fid);
    [rows colms]=size(line);
end

User.ID_number=Id;
User.subjectname=Name;
User.comment=Comment;
User.age=str2num(Age);
if(Sex=='Male')
  User.sex=0;
else
  User.sex=1;
end
RefPoints.LeftEar=pos_AL;
RefPoints.RightEar=pos_AR;
RefPoints.Nasion=pos_Nz;
RefPoints.Back=pos_Iz;
RefPoints.Top=pos_Cz;
