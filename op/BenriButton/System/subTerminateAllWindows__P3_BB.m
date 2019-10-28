function str = subTerminateAllWindows__P3_BB(hs)

%- my name
str='Terminate all windows';
if nargin<=0,return;end
%- 

set(0,'ShowHiddenHandles','on')
h=get(0,'Children');
h=h(h~=hs.POTATo);
delete(h);
