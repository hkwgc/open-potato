function [data,varargout]=ot_filtfilt(data,a,b,dim,varargin)
%[data,varargout]=ot_bandpass(data,hpf,lpf,smp,dim,typ,varargin)
%   
%   input:
%           data: data matrix: data must be time-domain
%           a: [vector]:the coefficient of designed filter
%           b: [vector]:the coefficient of designed filter
%           %pairnum: the number of pairs of hpf and lph: 
%           %smp: sampling period [sec]
%           dim: dimension for filter 
%           %typ: the type of data 'time' or 'fft'
%   output:
%           data: bandpassed or high-passed or low-passed data
%           
%
% May 03, 2003, Maki


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%Set data
y=data;

%Set filter
%[b,a] = butter(5,[10/500 100/500]);

%Set permute order
ororder=[1:length(size(y))];
diforder=setdiff(ororder,dim);
modorder=[dim,diforder];

%Permute y
y=permute(y,modorder);

%Check loop number
% loopnum=length(modorder);
% for ii=1:loopnum,loopc(ii)=size(y,ii);end
% 
% 
% prestr='';endstr='';midstr1='yy=squeeze(y(:';midstr2='y(:';
% for ii=2:loopnum,
%     lj=' j';
%     for iii=2:ii,lj=strcat(lj,'j');end %Make string of jj***
%     prestr=strcat(prestr,'for',lj,'=1:loopc(',num2str(ii),'),');
%     midstr1=strcat(midstr1,',',lj);
%     midstr2=strcat(midstr2,',',lj);
%     endstr=strcat('end;',endstr);    
% end
% 
% %Evaluation
% eval(strcat(prestr,strcat(midstr1,'));'),strcat(midstr2,')=filtfilt(b,a,yy);'),endstr));
%
% -> it can be simplyfy by shoji 19-Oct-2004
% -- Replase Code start --
loopnum=size(y);
%iloopnum=loopnum; iloopnum(1)=[];
%yy=reshape(y,loopnum(1),prod(iloopnum));
yy=y(:,:);
for ii=1:size(yy,2);
	yy(:,ii)=filtfilt(b,a,yy(:,ii));
end
y=reshape(yy,loopnum);
% -- Replase Code end --

%Ipermute
data=ipermute(y,modorder);


% === Grep Result 27-Dec-2004 ===
% BlockFilter/block_controller.m
%    :203:        [data]=ot_filtfilt(data,a,b,1);
%    ( -- Motion Check -- )
%    :805:%       [data]=ot_filtfilt(data,a,b,1);
%    :806:        data=ot_filtfilt(signal.chb(:,:,3),a,b,1);
%
%
% preprocessor/plot_prepro.m
%    :255:        [data]=ot_filtfilt(data,a,b,1);
% 
% viewer/plot_stat1.m
%    :246:        [data]=ot_filtfilt(data,a,b,1);
% 
% viewer/plot_stat2.m
%    :258:        [data(iii,:,:,:)]=ot_filtfilt(dumdata,a,b,1);
% 
% viewer/plot_view2.m
%    :253:        [data]=ot_filtfilt(data,a,b,1);
% 
