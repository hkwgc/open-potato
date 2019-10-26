
% code for ...
% Subplot routine 
% ETG-7000 4x4 mode
% time axis

%v_subplot_pos=[ 1.5 2.5 3.5, 5 6 7 8, 9.5 10.5 11.5, 13 14 15 16, 17.5 18.5 19.5, 21 22 23 24, 25.5 26.5 27.5];
% Can not use for Matlab version 7.0

%
% For Determined Position
%
% parea=0.8;                 % Plot Area : 80%
% sizex=4.; sizey=7.;        % Divide Number
% 
% sizex2=parea/sizex; sizey2=parea/sizey;  % Real Plot Size
% x(2,:) = 0:(sizex-1);
% x(2,:) = x(2,:)  + (1-parea); % Normal Size
% x(1,:)=x(2,:) + 0.5; 
% 
% y=(sizey-1):-1:0; y= y+(1-parea);
% 
% x=x./sizex; y=y./sizey;


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



sizex2=0.18; sizey2=0.08;
v_subplot_pos_x=[     ...
        0.1750    0.4250    0.6750    ...
        0.0500    0.3000    0.5500    0.8000 ...
        0.1750    0.4250    0.6750    ...
        0.0500    0.3000    0.5500    0.8000 ...
        0.1750    0.4250    0.6750    ...
        0.0500    0.3000    0.5500    0.8000 ...
        0.1750    0.4250    0.6750    ];
v_subplot_pos_y=[     ...
        0.8857    0.8857    0.8857    ...
        0.7429    0.7429    0.7429    0.7429 ...
        0.6000    0.6000    0.6000    ...
        0.4571    0.4571    0.4571    0.4571  ...
        0.3143    0.3143    0.3143    ...
        0.1714    0.1714    0.1714    0.1714    ...
        0.0286    0.0286    0.0286 ];
% ----- Upper Data is Input Data for new Plot Function -------
%  or will be exchanged by Reading function of File Format Definition 

if length(v_subplot_pos_y) ~= length(v_subplot_pos_x)
    error(' Input Axes Position Error');
end
% normalize  like following ... ( if more effective data);
% v_subplot_pos_y=v_subplot_pos_y./max(v_subplot_pos_y)


linidx=find(linenum(2:length(linenum)-1)==1);
linloop=length(linidx);
linidx2=find(linenum(2:length(linenum))==1);
linloop2=length(linidx2);

fig=initialize_subplot(lincol, linidx2, datinf, plttyp, linloop2); % initialization for subplot
titlename=['ETG-7000: 4x4 Mode  ' datinf{1,5} datinf{2,5}];set(gcf,'Name',titlename);

for i2=1:length(v_subplot_pos_y);
    %                    subplot(7,4,v_subplot_pos(i2));
    subplot('position',[ v_subplot_pos_x(i2) v_subplot_pos_y(i2), sizex2 sizey2]);
    set(gca,'FontSize',[6]);
    %min_x=min(vecaxisx);
    %max_x=max(vecaxisx);
    %set(gca,'XLim',[min_x max_x]);
    tag_chnum=strcat('ch',num2str(i2));
    set(gca,'Tag',tag_chnum);                   
    
    hold on;
    if strcmp(plttyp{1},'block-mean-value')
        % block mean value
        %						osp_g_ttest_bar( data(:, pltchn(ii), :) );
        osp_g_ttest_bar( data(:, pltchn(i2), :) );
    else
        for jj=1:linloop,                
            %This is for only hb plot
            plot(vecaxisx,reshape(data(:,pltchn(i2),linidx(jj)),...
                1,length(data(:,pltchn(i2),linidx(jj)))),lincol{linidx(jj)});
            axis tight
        end
        maxdat(jj)=max(data(:,pltchn(i2),linidx(jj)));
    end
    
    %%???                    if linloop>0,maxd=max(maxdat);,end;
    if linloop>0,maxd=max(data(:));end;
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
