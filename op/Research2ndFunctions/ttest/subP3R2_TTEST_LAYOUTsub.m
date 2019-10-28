
ch=getappdata(gcf,'CHDATA');
v=ch{1}.Results.(curdata.ResultsString);
if n==1
	h=findobj(get(gcf,'children'),'Tag','UIControl_varValues');
else
	h=findobj(get(gcf,'children'),'Tag','UIControl_varValues2');
end
set(h,'max',100);
set(h,'String',v);