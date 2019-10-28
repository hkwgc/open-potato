function [pathname,filename]=pathandfilename(fullname)

% pathandfilename : separate a path name and a file name from full path
% Syntax: 
%  [PATHNAME,FILENAME]=pathandfilename(FULLNAME)
%    FULLNAME is Windows-fullpath that filename is longer than 5
%    PATHNAME is path of the file
%    FILENAME is filename
%   
%  This function is useful for special case only,
%  because there is two hypothesises.
%    1. we take '\' for a separator of path.
%    2. Filename is longer than 5.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

%
%  if you want to ignore those hypotesise, you can use following code
% ---- Code A ----
%[pathname,f1,f2,v]=fileparts(fullname); 
%- The above line has commented and changed as below because of higher compatibility.
[pathname,f1,f2]=fileparts(fullname);
pathname=[pathname filesep];
filename=[f1 f2];
return;
% ---- end of code A ---
% or change Setting like following
%  sprtr=filesep
%  ignorenum=0;

%  version 1.0.1
%  Date : 2004/10/13
sprtr='\';
ignornum=5;

% -- Add argument check --
fullname=char(fullname);
tmp1=length(fullname);
if tmp1 ~= prod(size(fullname))
	errordlg(' File name input Error. FULLNAME must be vector');
	return;
end
tmp1=tmp1-ignornum;
if tmp1<=0
	errordlg('File-name must be longer than 5');
	return;
end
tmp2=fullname(tmp1);

while tmp2~=sprtr
    tmp1=tmp1-1;
    if tmp1==0
        tmp2=sprtr;
    else
        tmp2=fullname(tmp1);
    end
end

if tmp1==0
    pathname=[];
else
    pathname=fullname(1:tmp1);
end
filename=fullname(tmp1+1:length(fullname));
