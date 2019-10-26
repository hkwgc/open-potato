function P3_confirm
% P3_CONFIRM : Persistent.

% $Id: P3_confirm.m 180 2011-05-19 09:34:28Z Katura $

% Verify Persistent-Save.
% measures  : MALTAB R2006a for Windows.
bug_r2006a;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Verify Persistent-Save.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bug_r2006a
% To Escape Bug for MATLAB R2006a
%
% In-My-Research.
%
% --- Status ---
%  * Persistent will clear,
%    when I Change-Directory at the first time,
%    even thouh Function is in a PATH.
%    (Launch MATLAB -> only first-time.)
%
% -- More Research --
%  * I could not understand, help of addpath?
%    FROZEN Option was not effective.
%
%  * This is Occure when Different Path-Name.
%    Pathname is (Large/Small), and there is external pathsep.
%    (Windows only)
%
% ======================================
% So, play the bug, when my system open.
%
% See also STARTUP, BUG_R2006a_SUB
%          PERSISTENT, ADDPATH, CD.
%
% Mlock & Delete

% 15-Feb-2007

tmpdir=pwd;
f=which(mfilename);
p=fileparts(f);
cd(p);
%addpath(p,'-FROZEN');

% OK
bug_r2006a_sub('Set 1st');
cd(p);
%disp(bug_r2006a_sub);
bug_r2006a_sub;

% NG
if 1
  px=p;
  px(1)=upper(p(1));
  px(end+1)=filesep;
  bug_r2006a_sub('Set 2nd');
  cd(px);
  %disp(bug_r2006a_sub);
  bug_r2006a_sub;
end

cd(tmpdir);


% =================> 
%  if you make new M-File by copying under source,
%  you can verify what I want to do in MATLAB R2006a
% <=================
function a=bug_r2006a_sub(b)
% Mlock & Delete
if nargin>=1,
  a=hoge(b);
else
  a=hoge;
end

return;

function a=hoge(b)
% ==> PERSISTENT Function
persistent data;
if nargin>=1, 
  mlock;
  data=b; 
else
  if isempty(data),data=0;end
  munlock;
end
a=data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
