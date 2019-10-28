
% code for ...
% Subplot routine 
% ETG-7000 3x5 mode
% time axis


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



v_subplot_pos=[ 1.5 2.5 3.5 4.5 6 7 8 9 10 11.5 12.5 13.5 14.5 16 17 18 19 20 21.5 22.5 23.5 24.5];

fig=initialize_subplot(lincol, linidx2, datinf, plttyp, linloop2); % initiarisation for subplot
titlename=['ETG-7000: 3x5 Mode  ' datinf{1,5} datinf{2,5}];set(gcf,'Name',titlename);

for i2=1:22
  subplot(5,5,v_subplot_pos(i2));
  set(gca,'FontSize',[6]);
  %min_x=min(vecaxisx);
  %max_x=max(vecaxisx);
  %set(gca,'XLim',[min_x max_x]);
  tag_chnum=strcat('ch',num2str(i2));
  set(gca,'Tag',tag_chnum);
  
  hold on;
  if strcmp(plttyp{1},'block-mean-value')
    % block mean value
    osp_g_ttest_bar( data(:, pltchn(ii), :) );
  else
    for jj=1:linloop,                
      %This is for only hb plot
      plot(vecaxisx,reshape(data(:,pltchn(i2),linidx(jj)),...
                            1,length(data(:,pltchn(i2),linidx(jj)))),lincol{linidx(jj)});
      axis tight
    end
  end
  maxdat=max(data(:,pltchn(i2),:));
  
  if linloop>0,maxd=max(maxdat);,end;
  if (linenum(length(linenum))==1) & ~strcmp(plttyp{1},'block-mean-value')
    %hold on;
    plot(vecaxisx,reshape(maxd*stmdat/2,1,length(stmdat)),lincol{4});  
  end
  hold off;
  title(['ch. ' int2str(i2)])
  
end
            
% データ引渡しのためのグローバル変数
global ax; global dt; global ch; global lid; global lco; global lnum; global sdt;
ax=vecaxisx; dt=data; ch=pltchn; lid=linidx; lco=lincol; lnum=linenum; sdt=stmdat;

f = uimenu('Parent',fig,'Label','option');
initialize_axis(f);
