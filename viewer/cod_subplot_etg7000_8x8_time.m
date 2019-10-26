
% code for ...
% Subplot routine 
% ETG-7000 8x8 mode
% time axis


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



fig=initialize_subplot(lincol, linidx2, datinf, plttyp, linloop2); % initiarisation for subplot
titlename='ETG-7000: 8x8 Mode';set(gcf,'Name',titlename);
            
count=1;
for line=1:15
  if(mod(line,2))
    off_set=1/16;
  else
    off_set=0;
  end
  left=off_set;
  while(left <= 7/8)
    subplot('position',[left+0.01 (15-line)/15+0.01 1/8-0.015 1/15-0.015]);
    set(gca,'FontSize',[6]);
    %min_x=min(vecaxisx);
    %max_x=max(vecaxisx);
    %set(gca,'XLim',[min_x max_x]);
    tag_chnum=strcat('ch',num2str(count));
    set(gca,'Tag',tag_chnum);                   
    
    if strcmp(plttyp{1},'block-mean-value')
      % block mean value
      osp_g_ttest_bar( data(:, pltchn(count), :) );
    else
      %This is for only hb plot
      hold on;
      for jj=1:linloop,                
	plot(vecaxisx,reshape( data(:,pltchn(count),linidx(jj)), 1, length(data(:,pltchn(count),linidx(jj))) ), lincol{linidx(jj)});
	axis tight
	maxdat(jj)=max(data(:,pltchn(count),linidx(jj)));
      end
      
      if linloop>0,maxd=max(maxdat);,end;
      if linenum(length(linenum))==1,
	%hold on;
	plot(vecaxisx,reshape(maxd*stmdat/2,1,length(stmdat)),lincol{4});  
      end
    end
    
    hold off;
    left=left+1/8;
    count=count+1;
  end
end
            
% データ引渡しのためのグローバル変数
global ax; global dt; global ch; global lid; global lco; global lnum; global sdt;
ax=vecaxisx; dt=data; ch=pltchn; lid=linidx; lco=lincol; lnum=linenum; sdt=stmdat;

f = uimenu('Parent',fig,'Label','option');
g = uimenu(f,'Label','各プローブの表示');
uimenu(g,'Label','Probe1','Callback',['plotsig_32in112(1,''t'')']);
uimenu(g,'Label','Probe2','Callback',['plotsig_32in112(2,''t'')']);
uimenu(g,'Label','Probe3','Callback',['plotsig_32in112(3,''t'')']);
uimenu(g,'Label','Probe4','Callback',['plotsig_32in112(4,''t'')']);

initialize_axis(f);
