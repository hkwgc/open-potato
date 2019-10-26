function plotsig_32in112(num,grph_mode);
% plot 32ch(one plobe area in 112ch)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


global ax; global dt; global ch; global lid; global lco; global lnum; global sdt;

idx_pro(1,:)=[1:4,8:11,16:19,23:26,31:34,38:41,46:49,53:56];
idx_pro(2,:)=[4:7,12:15,19:22,27:30,34:37,42:45,49:52,57:60];
idx_pro(3,:)=[53:56,61:64,68:71,76:79,83:86,91:94,98:101,106:109];
idx_pro(4,:)=[57:60,64:67,72:75,79:82,87:90,94:97,102:105,109:112];



if num==1 | num==4
    od=1/9;
    ev=0;
elseif num==2 | num==3
    od=0;
    ev=1/9;
end

fig=figure;
set(gcf,'Tag','tempplot');
name=strcat('Probe',num2str(num));
set(gcf,'NumberTitle','off');
set(gcf,'Name',name); 
set(gcf,'Color',[.75 .75 .5]);
%set(gcf,'UserData',idx_pro(num,:));

count=1;
for line=1:8
    if(mod(line,2))
        off_set=od;
    else
        off_set=ev;
    end
    left=off_set;
    for col=1:4
        ch_num=num2str(idx_pro(num,count));
        ch_num=strcat('CH:',ch_num);   
        subplot('position',[left+0.01 (8-line)/8+0.01 2/9-0.015 1/8-0.04]);
        set(gca,'FontSize',[6]);
        tag_chnum=strcat('fig2-ch',num2str(count));
        set(gca,'Tag',tag_chnum);
       
        hold on;
        for jj=1:length(lid),
            switch grph_mode,
            case {'t','f'},
                %This is for only hb plot
                plot(ax,reshape(dt(:,idx_pro(num,count),lid(jj)),...
                    1,length(dt(:,idx_pro(num,count),lid(jj)))),lco{lid(jj)});
                maxdat(jj)=max(dt(:,idx_pro(num,count),lid(jj)));
            case 'd-',
                plot(dt(:,count,2),dt(:,count,3),'b+');
                maxdat(jj)=max(dt(:,idx_pro(num,count),lid(jj)));
            case 'dv',
                plot(dt(:,count,2),dt(:,count,3),'b+');
                maxdat(jj)=max(dt(:,idx_pro(num,count),lid(jj)));

            end
        end
        if length(lid)>0,maxd=max(maxdat);,end;
        if lnum(length(lnum))==1,
            plot(ax,reshape(maxd*sdt/2,1,length(sdt)),lco{4});  
        end
        title(ch_num,'FontSize',[8],'FontWeight','Bold');
        hold off;
        left=left+2/9;
        count=count+1;
    end
end
            f = uimenu('Parent',fig,'Label','option');
            axs=uimenu(f,'Label','軸の操作');
            uimenu(axs,'Label','カレントのX軸を適用','Callback',['xlmd=get(gca,''XLimMode'');',...
                    'if ~strcmp(xlmd,''Auto'')',...
                        'xlim=get(gca,''XLim'');',...
                        'for ii=1:32;',...
                            'tag_ch=strcat(''fig2-ch'',num2str(ii));',...
                            'h=findobj(gcf,''Tag'',tag_ch);',...
                            'set(h,''XLim'',xlim);',...
                        'end;',...
                    'end']);
            uimenu(axs,'Label','カレントのY軸を適用','Callback',['ylmd=get(gca,''YLimMode'');',...
                    'if ~strcmp(ylmd,''Auto'')',...
                        'ylim=get(gca,''YLim'');',...
                        'for ii=1:32;',...
                            'tag_ch=strcat(''fig2-ch'',num2str(ii));',...
                            'h=findobj(gcf,''Tag'',tag_ch);',...
                            'set(h,''YLim'',ylim);',...
                        'end;',...
                    'end']);
            
            uimenu(axs,'Label','全ての軸をリセット','Callback',...
                    ['for ii=1:32;',...
                        'tag_ch=strcat(''fig2-ch'',num2str(ii));',...
                        'h=findobj(gcf,''Tag'',tag_ch);',...
                        'set(h,''XLimMode'',''Auto'',''YLimMode'',''Auto'');',...
                        'set(h,''XScale'',''Linear'',''YScale'',''Linear'');',...
                    'end;'],'Separator','on');
