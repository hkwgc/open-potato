function varargout = plot_view1(varargin)
% Plot Time-block-mean 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


hnd=guihandles;
hndgcf=gcf;

tdata=getappdata(hndgcf,'tdata');
STATP=getappdata(hndgcf,'STATP');
idx=getappdata(hndgcf,'idx');

data=zeros(size(tdata,2),size(tdata,3),size(tdata,4));
data(:,:,:)=tdata(idx,:,:,:);

%Initilize valuables
ch_num=length(data(1,:,1));% channel number
tm_num=length(data(:,1,1));% temporal data size number
hb_num=length(data(1,1,:)); % HB data variety
smpl_pld=STATP(idx).sampleperiod;% sampling period [ms]
datapara=STATP(idx).datapara; %-for function datapara(1)=sampling period, datapara(2)=data size,

plttyp{1}='block-mean-value';
measuremode=STATP(idx).measuremode;    
datapara=[STATP(idx).datapara 0.05 1 -100 50 0];

pltchns='all'; 
linleg={'oxy-Hb','deoxy-Hb','total-Hb','stim mark'};
lincol={'r-','b-','k','k:','y:','m:'};
plttyp{2}='dCHb [mM mm]';plttyp{3}='condition'; 
        
    linenum=[3,0,0,0,0];    
    if get(hnd.oxy_chb,'Value')==1,
        linenum(2)=1;
    end
    if get(hnd.deoxy_chb,'Value')==1,
        linenum(3)=1;
    end    
    if get(hnd.total_chb,'Value')==1,
        linenum(4)=1;
end


pltchn=[1:ch_num];


%Graph infromations: Channel number(title), legend, X-label,Y-label,x-range, y-range,x-linear/log,y-linear/log
%Transfer chnum to cell array
%pltinfo_str=cell type;pltinfo_num:
%% Header of     STATP(idx) = 
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

datinf{1,7}='KINDS : ';datinf{2,7}={'oxy','deoxy','total','stimli'};


datinf{1,8}='MEASUREMODE: ';datinf{2,8}=num2str(STATP(idx).measuremode);

   
linidx=find(linenum(2:length(linenum)-1)==1);
linloop=length(linidx);
linidx2=find(linenum(2:length(linenum))==1);
linloop2=length(linidx2);

t=1/datapara(1)*1000;
s1=datapara(3)*t;
e1=datapara(4)*t;

stmdat=[1 0];
vecaxisx=[1:7]; % use data( 1:7, :, :)

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
