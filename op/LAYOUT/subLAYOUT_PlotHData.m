[hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);tmp=hdata.TAGs.filename;if iscell(tmp), [tmpp tmpn]=fileparts(tmp{1});else tmpn=tmp;end;set(curdata.gcf,'name',tmpn);
set(gcf,'numbertitle','off');

str=POTATo_sub_CheckStruct(hdata,size(data,1));
A = POTATo_sub_MakeGUI(gcf);

A.UIType = 'Listbox';
A.Name = 'lbxPlot';
A.String = str;
A.Value = 1;
A.Label = '';
%A.Unit = 'pixels';
A.Unit = 'normalized';
A.PosX = 0.; A.PosY = 0.; A.SizeX = 0.2; A.SizeY=.5;
%A.PosX = 0; A.PosY = 0; A.SizeX = 100; A.SizeY=500;
A.invertY=1;A.PRMs.Visible='on';
A=POTATo_sub_MakeGUI(A);

h=subplot('Position',[A.SizeX+0.05 0.1 0.9-A.SizeX 0.9-0.05]);
setappdata(gcf,'AxisHandle',h);

cbstr='hdata = getappdata(gcbf,''CHDATA'');hdata=hdata{1};';
cbstr=[cbstr 'S=get(gcbo,''string'');v=get(gcbo,''value'');d=[];'];
cbstr=[cbstr 'for k=v,	d=cat(1,d,eval([''hdata.'' S{k}]));end;'];
cbstr=[cbstr 'x=1:hdata.samplingperiod/1000:size(d,2);x=x(1:size(d,2));'];
cbstr=[cbstr 'h=getappdata(gcf,''AxisHandle'');plot(h,x,d'');xlabel(''time (sec)'');'];
set(A.handles.lbx_lbxPlotsubLAYOUT_PlotHData,'callback',cbstr);