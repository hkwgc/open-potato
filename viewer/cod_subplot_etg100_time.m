% code for ...
% Subplot routine 
% ETG-100 
% time axis


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%             switch datinf{2,5},%The number of plane
%             case '1',%Plane is 1
%                 graph24_1pn;
%             case '2',
%                 graph24_2pn;
%             end
switch datinf{2,8},         %Measurement mode;  1: 3x3, 2: 4x4, 3: 3x5
                                        %     (ETG-7000)    51:4x4, 52:3x5, 53:5x3, 50:8x8
 case '1',%3x3, 2plane
  graph24_2pn;
 case {'2', '51'},%4x4, 1plane
  graph24_1pn;
 case {'3', '52'},%3x5, 1plane
  graph24_3x5;
 case '50',%8x8, 1plane
  graph24_8x8;
end

set(gcf,'Tag','tempplot');
        
% === Draw legend ===
lgnd=findobj('Tag','lgd_plt');     
axes(lgnd(1));
hold on;
for jj=1:linloop2,
  plot([1:10],lincol{linidx2(jj)});
end

hold off;
legend(datinf{2,7}(linidx2));
        
title(plttyp{1},'FontName','Times New Roman','FontSize',10);        
xlabel(plttyp{3},'FontName','Times New Roman','FontSize',10);        
ylabel(plttyp{2},'FontName','Times New Roman','FontSize',10);
            
% === Draw legend ===
cnd=findobj('Tag','cnd_lsb');
lnum=size(datinf);
clear dum
for kk=1:lnum(2),
  dum{kk}=strcat(datinf{1,kk},datinf{2,kk});
end            
set(cnd,'String',{dum{1:lnum(2)-2}});            
clear dum lnum;     
            
for ii=1:length(pltchn),%channel loop            
  maxd=1;
  ftag='Axes';
  ftag=strcat(ftag,num2str(ii));                
  a=findobj('Tag',ftag);
  axes(a(1));hold on;
  if strcmp(plttyp{1},'block-mean-value')
    % block mean value
    osp_g_ttest_bar( data(:, pltchn(ii), :) );
  else
    for jj=1:linloop
      %This is for only hb plot
      plot(vecaxisx,reshape(data(:,pltchn(ii),linidx(jj)),...
			    1,length(data(:,pltchn(ii),linidx(jj)))),lincol{linidx(jj)});
    end
  end
  maxdat=max(data(:,pltchn(ii),:));
  if linloop>0,maxd=max(maxdat);,end;
  if (linenum(length(linenum))==1) & ~strcmp(plttyp{1},'block-mean-value')
    %hold on;
    plot(vecaxisx,reshape(maxd*stmdat/2,1,length(stmdat)),lincol{4});
  end
  hold off
end % loop ii end
