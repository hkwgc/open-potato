input_file = 'HeadSurfEdge.mat';
if(~exist(input_file,'file'))
    return;
end

output_file_vertex = 'HeadSurfVertex.txt';

output_file_edge = 'HeadSurfEdge.txt';

s=load(input_file);
if( isfield(s,'x')&&isfield(s,'y')&&isfield(s,'z') )
    x=s.x(1:1:end);
    y=s.y(1:1:end);
    z=s.z(1:1:end);
    dt = DelaunayTri(x(:),y(:),z(:));

    [lines cols] = size(dt.X);
    fid=fopen(output_file_vertex,'w');
    fprintf(fid,'%8.3f,%8.3f,%8.3f\n',[dt.X(:,1) dt.X(:,2) dt.X(:,3)]');
    fclose(fid);

    [lines cols] = size(dt.Triangulation);
    fid=fopen(output_file_edge,'w');
    fprintf(fid,'%6d,%6d,%6d,%6d\n',[dt.Triangulation(:,1) dt.Triangulation(:,2) dt.Triangulation(:,3) dt.Triangulation(:,4)]');
    fclose(fid);
end
