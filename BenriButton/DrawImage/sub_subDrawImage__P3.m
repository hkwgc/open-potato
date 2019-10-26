function sub_subDrawImage__P3(figh)

data = getappdata(figh,'data');
hdata = getappdata(figh,'hdata');

%- get val from input text
try
	val= eval(['[' get(findobj(gcbf,'Tag','edit1'),'String') ']']);
catch
	errordlg(sprintf('Input error.\nPlease check your text.\nText must be Evaluable'));
	return;
end
%- check val
if length(val) ~= size(data,2)
	errordlg(sprintf('Input error.\nPlease check size of your text.\nValue length must be the same as selected file''s channel size.'));
	return;
end
data = nan(size(data));
data(1,:,1) = val;

load('LAYOUT_ImageView_Bennri.mat')
P3_view(LAYOUT,hdata,data);