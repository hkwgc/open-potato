[hdata,data]=osp_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);
curdata.ylim=[min(min(min(data(:,:,curdata.kind)))),max(max(max(data(:,:,curdata.kind))))];