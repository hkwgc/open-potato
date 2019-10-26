function fig=initialize_subplot(lincol, linidx2, datinf, plttyp, linloop2)
%
% initialisation for subplot
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

%Draw legend
figure('MenuBar','none');
[pos]=get(gcf,'position');
axes('position',[.2 .2 .6 .6])
hold on;
for jj=1:linloop2,
    plot([1:10], [1:jj:10*jj], lincol{linidx2(jj)});
end
hold off;
legend(datinf{2,7}(linidx2));
title(plttyp{1},'FontName','Times New Roman','FontSize',10);
xlabel(plttyp{3},'FontName','Times New Roman','FontSize',10);
ylabel(plttyp{2},'FontName','Times New Roman','FontSize',10);
set(gcf,'Position',[pos(1)-210 pos(2) 200 200]);
set(gcf,'Tag','tempplot');set(gcf,'NumberTitle','off'); set(gcf,'Name','Legend');
set(gcf,'Color',[.75 .75 .5]);

%Setup Subplot
ln=size(datinf);
for kk=1:ln(2),
    dum{kk}=strcat(datinf{1,kk},datinf{2,kk});
end
fig=figure;
set(gcf,'Tag','tempplot');set(gcf,'NumberTitle','off');
set(gcf,'UserData',{dum{1:ln(2)-1}}); % measurement conditions
set(gcf,'Color',[.75 .75 .5]);
%-----------------------------------
