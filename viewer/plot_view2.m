function varargout = plot_view2(varargin)
% Plot Time-block from Statistical Analysis output data

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


hnd=guihandles;

idx=getappdata(hnd.main_strns_fig,'idx');
blksig=getappdata(hnd.main_strns_fig,'blksig');
STATP=getappdata(hnd.main_strns_fig,'STATP');
active_idx=getappdata(hnd.main_strns_fig,'active_idx');

active_blk=1:length(STATP(idx).activeblocks);

tmp=permute(blksig(idx,:,2:end-1,1:length(active_idx{idx}),:),[1,4,2,3,5]);

data=squeeze(mean(tmp,2));

% Set option data
h=zeros(1,25);
h(3)=findobj(gcf,'Tag','frqflt_valu');
h(4)=findobj(gcf,'Tag','flttyp_value');
h(5)=findobj(gcf,'Tag','frqrng_value');
h(11)=findobj(gcf,'Tag','oxy_chb');
h(12)=findobj(gcf,'Tag','deoxy_chb');
h(13)=findobj(gcf,'Tag','total_chb');
h(23)=findobj(gcf,'Tag','edtFitting');

wintyp='one'; 

%Initilize valuables
ch_num=length(data(1,:,1));
tm_num=length(data(:,1,1));% temporal data size number
hb_num=length(data(1,1,:)); % HB data variety
smpl_pld=STATP(idx).sampleperiod;% sampling period [ms]
datapara=STATP(idx).datapara; %-for function datapara(1)=sampling period, datapara(2)=data size,

% fix Matrix size
stmdat=STATP(idx).modstim;
vecaxisx=[0:datapara(1)/1000:(length(stmdat)-1)*datapara(1)/1000];
if size(data,1)>length(vecaxisx)
    data=data(1:length(vecaxisx),:,:);
elseif size(data,1)<length(vecaxisx)
    vecaxisx=vecaxisx(1:size(data,1));
end

%Set the value of the degree of local fitting curve
lfdgv=0;
if  get( hnd.cbxFitting, 'Value' )
    lfdgv=str2num(get(h(23),'String'));
end

%Set Bandpass filter
frflt=[];frtyp=get(h(4),'String');frtyp=frtyp(get(h(4),'Value'));

if get(h(3),'Value')~=0,   
    dum=get(h(5),'String');
    j1=find(dum=='(');j2=find(dum==',');j3=find(dum==')');    
    for ii=1:length(j1),
        frflt=[frflt,str2num(dum(j1(ii)+1:j2(ii)-1)),str2num(dum(j2(ii)+1:j3(ii)-1))]; 
    end
end

plttyp{1}='time-block';
plttyp{2}='dCHb [mM mm]';
plttyp{3}='time [s]';
pltchns='all'; 


%----------------------------
plttyp{1}='time-block';
datapara=STATP(idx).datapara;
%-----------------------------

pltchns='all';

%-----------------------------
% ---- USE HB DATA
 plttyp{2}='dCHb [mM mm]';plttyp{3}='time [s]';
        
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

% ----------------

% ------------------------------------------
% ---- Moving Average and Local Fitting
% ------------------------------------------

fflg=0;

%---- Moving Average
if get( hnd.cbxMovingAverage, 'Value' )
	fflg=1;
	mv=str2num( get( hnd.edtMovingAverage, 'String' ) );
    data=osp_Movingaverage(data, mv);
end % eo if

stm=find(STATP(idx).modstim);

%---- Loacal Fitting    
if  get( hnd.cbxFitting, 'Value' )
    deg=str2num( get(hnd.edtFitting, 'String') );
	fflg=2;

    st=datapara(3);
    rx=str2num( get(hnd.rlx_edt, 'String') )*1000/smpl_pld;
    ed=datapara(4);
    ast=abs(st);
	i=stm(1);
    if STATP(idx).mode==1
        i2=stm(1);
    else
        i2=stm(2);
    end

    data(i+st:i2+ed, :, :)=osp_Local_Fitting( data(i+st:i2+ed, :, :), [ast, ast+(i2-i)+rx], deg ,1);

end % eo if

% ------------------------------------------


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
datinf{1,1}='DATE  : ';datinf{2,1}=STATP(idx).date{1}(1:10);
datinf{1,2}='FILE  : ';datinf{2,2}=STATP(idx).filename;
datinf{1,3}='AGE   : ';datinf{2,3}=num2str(STATP(idx).age(1));
if STATP(idx).sex,
    datinf{1,4}='GENDER: ';datinf{2,4}='female';
else
    datinf{1,4}='GENDER: ';datinf{2,4}='male';
end
datinf{1,5}='PLANE : ';datinf{2,5}=num2str(STATP(idx).plnum);%The number of plane
datinf{1,6}='COMENT: ';datinf{2,6}=STATP(idx).comment;

if get(h(11),'Value') | get(h(12),'Value') | get(h(13),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'oxy','deoxy','total','stimli'};
elseif get(h(14),'Value') | get(h(15),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'780nm','830nm','stimli'};
elseif get(h(16),'Value')
    datinf{1,7}='KINDS : ';datinf{2,7}={'oxy','deoxy','total','stimli'};
end

datinf{1,8}='MEASUREMODE: ';datinf{2,8}=num2str(STATP(idx).measuremode);
 
frrth=1; % Dummy


%%---------------------------------------------------------------
%  The following is from the function plotsig.
%%---------------------------------------------------------------

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

%---- filtering
if ~isempty(frflt),
    if floor(length(frflt)/2)==ceil(length(frflt)/2),
        pairnum=length(frflt)/2;
        for ii=1:pairnum,hpf(ii)=frflt(ii*2-1);lpf(ii)=frflt(ii*2);end       
        
        frtyp=char(frtyp);
        switch frtyp,
        case {'box for fft'}
            switch plttyp{1},            
            case {'time','time-block'},
                typ='time';
            otherwise
                typ='fft';
            end

            data=real(ot_bandpass2(data,hpf,lpf,pairnum,datapara(1)/1000,1,typ));   
            
        case {'butterworth(bpf)','butterworth(bsf)','butterworth(hpf)','butterworth(lpf)'}
            filttyp=frtyp(13:15);        
            for ii=1:pairnum,
                hpf=frflt(ii*2-1);lpf=frflt(ii*2);
                [b,a]=ot_butter(hpf,lpf,1000/datapara(1),5,filttyp);%Use 5 degree
                [data]=ot_filtfilt(data,a,b,1);
            end
            
        end
        
    else 
        errordlg('The pair of HPF and LPH is insufficient !!');
        return;
    end
end
%----
    
linidx=find(linenum(2:length(linenum)-1)==1);
linloop=length(linidx);
linidx2=find(linenum(2:length(linenum))==1);
linloop2=length(linidx2);

stmdat=STATP(idx).modstim(:,1);


switch measuremode
% ----- ETG-7000 4x4 mode
case 51
    v_subplot_pos=[ 1.5 2.5 3.5, 5 6 7 8, 9.5 10.5 11.5, 13 14 15 16, 17.5 18.5 19.5, 21 22 23 24, 25.5 26.5 27.5];
    cod_subplot_etg7000_4x4_time
    
% ----- ETG-7000 3x5 mode
case 52
    v_subplot_pos=[ 1.5 2.5 3.5 4.5 6 7 8 9 10 11.5 12.5 13.5 14.5 16 17 18 19 20 21.5 22.5 23.5 24.5];
    cod_subplot_etg7000_3x5_time
       
% ------- ETG-7000 part (8x8 mode) --------- 
case 50        
    cod_subplot_etg7000_8x8_time
    
% ------------ ETG-100 part ---------------
case {1, 2, 3}
    cod_subplot_etg100_time

otherwise
    error(strcat('Measuremode [ ', int2str(measuremode), ']  is incorrect. '));
end % switch measuremode end



            
            



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
