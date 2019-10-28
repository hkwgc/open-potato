function Pos_file_save(fid, User, RefPoints, ProbePos)

fprintf(fid,'[FileInfo]\n');
fprintf(fid,'ID=3DHeadShape\n');
fprintf(fid,'VER=2.00\n');
switch ProbePos{1,1}
  case {1, 2, 3}
    fprintf(fid,'ProductName=ETG100\n');
  case {4, 5, 6, 7}
    fprintf(fid,'ProductName=ETG400\n');
  case {8, 9, 10}
    fprintf(fid,'ProductName=WOT-System\n');
  otherwise
    fprintf(fid,'ProductName=Shimadzu\n');
end

[row col]=size(ProbePos);
fprintf(fid,'PROBE=%d\n',row);
fprintf(fid,'TYPE=0\n');
switch ProbePos{1,1}
  case {1, 2, 3, 4, 5, 6, 7}
    fprintf(fid,'MODE=ETG\n');
  case {8, 9, 10}
    fprintf(fid,'MODE=WOT-System\n');
  otherwise
    fprintf(fid,'MODE=Free\n');
end

%[User]
fprintf(fid,'[User]\n');
fprintf(fid,'Name=%s\n',User.subjectname);
fprintf(fid,'ID=%s\n',User.ID_number);
fprintf(fid,'Comment=%s\n',User.comment);
if(User.sex==0)
	fprintf(fid,'Sex=%s\n','Male');
else
	fprintf(fid,'Sex=%s\n','Female');
end
fprintf(fid,'Age=%3dy\n',User.age);

% Probe
probe_count=0;
for index=1:1:row
  mode_no = ProbePos{index,1};
  Positions = ProbePos{index,4};
  [pos_row pos_col]=size(Positions);
  probe_count=probe_count+1;
  switch mode_no
  case {1, 2, 3}
    mode = mode_no;
  case {4, 5, 6, 7}
    mode = mode_no+46;
  case {8, 9, 10}
    mode = mode_no+192;
  otherwise
    mode = 199;% free
  end
  fprintf(fid,'[Probe%d]\n',probe_count);
  fprintf(fid,'MODE=%d\n',mode);
  fprintf(fid,'ChNum=%d\n',pos_col);
end

%Ref Points in [mm]
fprintf(fid,'[LeftEar]\n');
fprintf(fid,'X=%.2f\n',RefPoints.LeftEar(1,1));
fprintf(fid,'Y=%.2f\n',RefPoints.LeftEar(1,2));
fprintf(fid,'Z=%.2f\n',RefPoints.LeftEar(1,3));
fprintf(fid,'[RightEar]\n');
fprintf(fid,'X=%.2f\n',RefPoints.RightEar(1,1));
fprintf(fid,'Y=%.2f\n',RefPoints.RightEar(1,2));
fprintf(fid,'Z=%.2f\n',RefPoints.RightEar(1,3));
fprintf(fid,'[Nasion]\n');
fprintf(fid,'X=%.2f\n',RefPoints.Nasion(1,1));
fprintf(fid,'Y=%.2f\n',RefPoints.Nasion(1,2));
fprintf(fid,'Z=%.2f\n',RefPoints.Nasion(1,3));
fprintf(fid,'[Back]\n');
fprintf(fid,'X=%.2f\n',RefPoints.Back(1,1));
fprintf(fid,'Y=%.2f\n',RefPoints.Back(1,2));
fprintf(fid,'Z=%.2f\n',RefPoints.Back(1,3));
fprintf(fid,'[Top]\n');
fprintf(fid,'X=%.2f\n',RefPoints.Top(1,1));
fprintf(fid,'Y=%.2f\n',RefPoints.Top(1,2));
fprintf(fid,'Z=%.2f\n',RefPoints.Top(1,3));

%Probe x ch
probe_count=0;
for index=1:1:row
  Positions = ProbePos{index,4};
  [pos_row pos_col]=size(Positions);
  probe_count=probe_count+1;
  for idx=1:1:pos_col
    pos=Positions{idx};
    fprintf(fid,'[Probe%d-ch%d]\n',probe_count,idx);
    fprintf(fid,'X=%.2f\n',pos(1));
    fprintf(fid,'Y=%.2f\n',pos(2));
    fprintf(fid,'Z=%.2f\n',pos(3));
  end
end


