function varargout = plot_bcw()
% plot_bcw


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Known Bugs : 
%  -- for Raw Data Plot : 
%          
hnd=guihandles;

%Make block data
block_controller('data_capture_psb_Callback',gcbo,[],guidata(gcbo))
BCW_MB=getappdata(gcf,'BCW_MB');
BCW_MBP=getappdata(gcf,'BCW_MBP');
data=zeros(size(BCW_MB,2),size(BCW_MB,3),size(BCW_MB,4));
data=squeeze(mean(BCW_MB,1));

% Set Filter option data
h=zeros(1,25);
h(3) =findobj(gcf,'Tag','frqflt_valu');
h(4) =findobj(gcf,'Tag','flttyp_value');
h(5) =findobj(gcf,'Tag','frqrng_value');
h(11)=findobj(gcf,'Tag','oxy_chb');
h(12)=findobj(gcf,'Tag','deoxy_chb');
h(13)=findobj(gcf,'Tag','total_chb');
h(14)=findobj(gcf,'Tag','r78_chb');
h(15)=findobj(gcf,'Tag','r83_chb');
h(16)=findobj(gcf,'Tag','mrk_chb');
h(23)=findobj(gcf,'Tag','edtFitting');

if get(h(11),'Value')==0 & get(h(12),'Value')==0 & get(h(13),'Value')==0 & get(h(14),'Value')==0 & get(h(15),'Value')==0 & get(h(16),'Value')==0;
    errordlg('Select data soruce !','Error !!!!');
    return;
end%1-on,0-off,

wintyp='one';

%Initilize valuables
ch_num=length(data(1,:,1));
tm_num=length(data(:,1,1));% temporal data size number
hb_num=length(data(1,1,:)); % HB data variety
smpl_pld=BCW_MBP.sampleperiod;% sampling period [ms]
datapara=BCW_MBP.datapara;; %-for function datapara(1)=sampling period, datapara(2)=data size,


%Set the value of the degree of local fitting curve
lfdgv=0;
if  get( hnd.cbxFitting, 'Value' )
    lfdgv=str2num(get(h(23),'String'));
end

%----------------------------
%switch get(hnd.plttype_value,'Value'), 
plttyp{1}='time-block';
plttyp{2}='dCHb [mM mm]';
plttyp{3}='time [s]';
pltchns='all'; 

%-----------------------------
linenum=[3,0,0,0,0];    
if get(h(11),'Value')==1,
    linenum(2)=1;
end
if get(h(12),'Value')==1,
    linenum(3)=1;
end    
if get(h(13),'Value')==1,
    linenum(4)=1;
end
if get(h(16),'Value')==1,
    linenum(5)=1;
end


%reshape stimulation mark from 0100... to 0111...
stmdat=BCW_MBP.modstim;

%Set parameter of pltchn that is ploting channel
if strcmp(pltchns,'all'), 
    pltchn=[1:ch_num];
elseif ~isempty(chkhi)&isempty(chkcom),
    minch=str2num(pltchns(1:chkhi(1)-1));maxch=str2num(pltchns(chkhi(1)+1:length(pltchns)));
    if maxch<minch,
        dum=minch;
        minch=maxch;
        maxch=dum;
    end
    pltchn=[minch:maxch];
elseif (isempty(chkhi)&~isempty(chkcom)) |(isempty(chkhi)&isempty(chkcom)&~isempty(str2num(pltchns))),
    pltchn=str2num(pltchns);
    if pltchn>ch_num,return;end
else
    errordlg('Check Input number in channel number !','Error !!!!');
end


%Graph infromations: Channel number(title), legend, X-label,Y-label,x-range, y-range,x-linear/log,y-linear/log
%Transfer chnum to cell array
%pltinfo_str=cell type;pltinfo_num:
%% Header of     signal = 
% 
%           default: 1
%       softversion: {'FVer 3.02  '}
%          filename: 'MEA00001.DAT'
%          pathname: 'C:\data\obatadata\raw\'
%         ID_number: '010427_03'
%       subjectname: 'obata'
%           comment: 'Visual '
%               age: [25 0 0 0]
%               sex: 1
%     operationmode: 1
%       analizemode: 2
%       measuremode: 2
%             adnum: 48
%             chnum: 24
%             plnum: 1
%              date: {'2001/04/27 14:16:49 '}
%      sampleperiod: 100

%Data info
%datinf{:,1}=measurement date
%datinf{:,2}=original filename
%datinf{:,3}=age
%datinf{:,4}=gender
%datinf{:,5}=plane number
%datinf{:,6}=comment
%datinf{:,7}={'oxy','deoxy','total','stimli'} or {'780nm','830nm','stimli'}
datinf{1,1}='DATE  : ';datinf{2,1}=BCW_MBP.date{1}(1:10);
datinf{1,2}='FILE  : ';datinf{2,2}=BCW_MBP.filename;
datinf{1,3}='AGE   : ';datinf{2,3}=num2str(BCW_MBP.age(1));
if BCW_MBP.sex,
    datinf{1,4}='GENDER: ';datinf{2,4}='female';
else
    datinf{1,4}='GENDER: ';datinf{2,4}='male';
end
datinf{1,5}='PLANE : ';datinf{2,5}=num2str(BCW_MBP.plnum);%The number of plane
datinf{1,6}='COMENT: ';datinf{2,6}=BCW_MBP.comment;

% Here Must be Change!! -- by Change HB-Data Kind-> make 
if get(h(11),'Value') | get(h(12),'Value') | get(h(13),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'oxy','deoxy','total','stimli'};
elseif get(h(14),'Value') | get(h(15),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'780nm','830nm','stimli'};
elseif get(h(16),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'oxy','deoxy','total','stimli'};
end

datinf{1,8}='MEASUREMODE: ';datinf{2,8}=num2str(BCW_MBP.measuremode);
 
frrth=1; % Dummy

%%---------------------------------------
% The following is from function plotsig
%%---------------------------------------


if isempty(find(linenum==1)),
    errordlg('Select data soruce !','Error !!!!');
    return;
elseif linenum(1)==1 & linenum(2)==0,
    errordlg('Select data soruce !','Error !!!!');
    return;
end
lincol={'r-','b-','k','k:','y:','m:'};

% Measure mode : cell to num
measuremode=str2num(datinf{2,8});

%Preparation for title in graphs
andate_str=date;
pltchn_ttl=(cellstr(strcat('CH ',num2str(pltchn'))))';
% CHeck the number of vargin
flag=0;
if nargin>8,
    flag=1;
end
  
vecaxisx=[0:datapara(1)/1000:(datapara(2)-1)*datapara(1)/1000];
    
linidx=find(linenum(2:length(linenum)-1)==1);
linloop=length(linidx);
linidx2=find(linenum(2:length(linenum))==1);
linloop2=length(linidx2);

stmdat=BCW_MBP.modstim(:,1);
vecaxisx=[0:datapara(1)/1000:(length(stmdat)-1)*datapara(1)/1000];

%============================== mod by tk 040721

switch measuremode
% ----- ETG-7000 4x4 mode
case 51
%     v_subplot_pos=[ 1.5 2.5 3.5, 5 6 7 8, 9.5 10.5 11.5, 13 14 15 16, 17.5 18.5 19.5, 21 22 23 24, 25.5 26.5 27.5];
     cod_subplot_etg7000_4x4_time
%    cod_subplot_etg100_time         %Changed by H.Atsumori July 2 2004
    
% ----- ETG-7000 3x5 mode
case 52
%    v_subplot_pos=[ 1.5 2.5 3.5 4.5 6 7 8 9 10 11.5 12.5 13.5 14.5 16 17 18 19 20 21.5 22.5 23.5 24.5];
    cod_subplot_etg7000_3x5_time
%    cod_subplot_etg100_time         %Changed by H.Atsumori July 2 2004
      
% ------- ETG-7000 part (8x8 mode) --------- 
case 50        
     cod_subplot_etg7000_8x8_time
    %cod_subplot_etg100_time         %Changed by H.Atsumori July 12 2004
    
% ------------ ETG-100 part ---------------
case {1, 2, 3}
    cod_subplot_etg100_time

otherwise
    error(strcat('Measuremode [ ', int2str(measuremode), ']  is incorrect. '));
end % switch measuremode end

% mod by tk 040721==============================


% ====================
% ===== Sub routines =====
% ====================

function fig=initialize_subplot(lincol, linidx2, datinf, plttyp, linloop2)
% 
% initialisation for subplot
%
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
% initialization for axis
function initialize_axis(f)

axs=uimenu(f,'Label','軸の操作');
uimenu(axs,'Label','カレントのX軸を適用','Callback',['xlmd=get(gca,''XLimMode'');',...
        'ylmd=get(gca,''YLimMode'');',...
        'if ~strcmp(xlmd,''Auto'')',...
            'xlim=get(gca,''XLim'');',...
            'for ii=1:112;',...
                'tag_ch=strcat(''ch'',num2str(ii));',...
                'h=findobj(''Tag'',tag_ch);',...
                'set(h,''XLim'',xlim);',...
            'end;',...
        'end']);
uimenu(axs,'Label','カレントのY軸を適用','Callback',['xlmd=get(gca,''XLimMode'');',...
        'ylmd=get(gca,''YLimMode'');',...
        'if ~strcmp(ylmd,''Auto'')',...
            'ylim=get(gca,''YLim'');',...
            'for ii=1:112;',...
                'tag_ch=strcat(''ch'',num2str(ii));',...
                'h=findobj(''Tag'',tag_ch);',...
                'set(h,''YLim'',ylim);',...
            'end;',...
        'end']);

uimenu(axs,'Label','全ての軸をリセット','Callback',...
        ['for ii=1:112;',...
            'tag_ch=strcat(''ch'',num2str(ii));',...
            'h=findobj(''Tag'',tag_ch);',...
            'reset(h);',...
            'set(h,''Tag'',tag_ch);',...
        'end;'],'Separator','on');

%-----------------------------------
