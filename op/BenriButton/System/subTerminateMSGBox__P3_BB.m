function str = subTerminateMSGBox__P3_BB(hs)

%- my name
str='Terminate message box';
if nargin<=0,return;end
%- 

set(0,'ShowHiddenHandles','on')
h=get(0,'Children');
for k=1:length(h)
	if ~isempty(strfind(get(h(k),'Tag'),'Msgbox_'))
		delete(h(k));
	end
end
