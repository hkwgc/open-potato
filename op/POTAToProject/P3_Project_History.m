function P3_Project_History(mod)
% Make history of Project..


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin<=0, mod='open';end
mod=lower(mod);

p=fileparts(which(mfilename));
fname=[p filesep 'P3_Project_History.mat'];
p3hist=[];
if exist(fname,'file')
  load(fname,'p3hist');
else
  p3hist=[];
end

switch mod
  case 'disp'
    makehtml(p3hist);return;
  case {'open','new'},  
    % Load Project
    prj=OSP_DATA('GET', 'PROJECT');
    wk.Name=[prj.Path filesep prj.Name];
    wk.Date=date;
    wk.Mode=mod;
    if isempty(p3hist)
      p3hist=wk;
    else
      idx =find(strcmpi({p3hist.Name},wk.Name));
      p3hist(idx(strcmpi({p3hist(idx).Mode},'open')))=[];
      p3hist(end+1)=wk;
    end
    % Save
    rver=OSP_DATA('GET','ML_TB');
    rver=rver.MATLAB;
    if rver >= 14,
      save(fname, 'p3hist','-v6');
    else
      save(fname, 'p3hist');
    end
    % Display : Debug Information
    if 0,makehtml(p3hist);end
end


function makehtml(p3hist)
% Draw Hist File by html
p=fileparts(which(mfilename));
fname=[p filesep 'P3_Project_History.html'];
fid=fopen(fname,'w');
try
  %-----------
  % Header
  %-----------
  fprintf(fid,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n');
  fprintf(fid,'<html><head>\n');
  fprintf(fid,'  <title>P3 History of Project</title>');
  fprintf(fid,'<LINK REL="stylesheet" HREF="./P3_Project_History.css" TYPE="text/css">');
  fprintf(fid,'</head>\n\n');
  fprintf(fid,'<body>\n');
  fprintf(fid,'<Table border=0 width="100%%">\n');
  fprintf(fid,'  <thead>\n');
  fprintf(fid,'    <td>Mode</td>\n');
  fprintf(fid,'    <td>Date</td>\n');
  fprintf(fid,'    <td>Path</td>\n');
  fprintf(fid,'  </thead>\n');
  for idx=length(p3hist):-1:1
    fprintf(fid,'  <tr>\n');
    fprintf(fid,'    <td>%s</td>\n',p3hist(idx).Mode);
    %fprintf(fid,'    <td>%s</td>\n',datestr(p3hist(idx).Date,0));
	fprintf(fid,'    <td>%s</td>\n',p3hist(idx).Date);
    fprintf(fid,'    <td>%s</td>\n',p3hist(idx).Name);
    fprintf(fid,'  </tr>\n');
  end
  fprintf(fid,'</Table>');
  
  %--------------
  % Footer
  %--------------
  fprintf(fid,'<div  COLSPAN="2" align="right"><cite>');
  fprintf(fid,'<font size="2">&copy; 2019 National Institute of Advanced Industrial Science and Technology</font>\n');
  fprintf(fid,'<br><font size="2"> %s $</font>',date);
  fprintf(fid,'</cite></div>');
  
  fprintf(fid,'</body></html>\n');
catch
  fclose(fid);
  rethrow(lasterr)
end
fclose(fid);

%--> Open Help View
helpview(fname);
