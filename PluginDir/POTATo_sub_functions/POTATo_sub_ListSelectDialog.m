function [str tg]=POTATo_sub_ListSelectDialog(stringList)
%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



A=POTATo_sub_MakeGUI(figure);
p=get(A.handles.figure1,'position');
set(A.handles.figure1,'position',[p(1:2) 375 300],'numberTitle','off',...
'DockControls','off',	'MenuBar','none','Resize','off','windowstyle','modal');
A.SizeX=350;
A.SizeY=200;
A.PosY=10;
A.NextX=0;
A.NextY=220;
A.Label = 'Select files';

A.String=stringList;
A.UIType='Listbox';
A=POTATo_sub_MakeGUI(A);
A.Label='Ok';
A.UIType='button';
A.SizeY=50;
A.String = 'uiresume(gcbf)';
A=POTATo_sub_MakeGUI(A);

uiwait(A.handles.figure1);
str=get(A.handles.lbx_tagName_PTTSubMakeGUI,'String');
tg=get(A.handles.lbx_tagName_PTTSubMakeGUI,'Value');

close(A.handles.figure1);