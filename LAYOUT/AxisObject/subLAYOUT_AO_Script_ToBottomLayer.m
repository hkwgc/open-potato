hndl=(get(curdata.gcf,'children'));
tg = hndl~=gca;
hndl=hndl(tg);
hndl(end+1)=gca;
set(curdata.gcf,'children',hndl);