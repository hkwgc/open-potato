function hb=osp_chbtrans2(raw, wavelength, basetime);
%   function: Transfer to Continuous Hb
% May 23, 02 Maki
% mod. 030528 TK
%++++++++++++++++++++++++++++++++++++++++++++++++++
% hb=osp_chbtrans2(raw, wavelength, basetime);
%Input
% Raw(time,ch)         :Matrix: ch       = channel*2
% wavelength(wave-num) :Vector: wave-num = channel*2
% basetime :: sample point(s) !! basetime is not in use.
%Output
%Hb(1:3):1=oxy,2=deoxy;3=total
%


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%calculate base line of each wavelength
% baseline=mean(raw(basetime,:),1);
% baseline=baseline+(baseline==0);%--- if baseline==0 baseline=1
% 
% baseline=ones(1,48);
%load absorption coefficient

% Set Data-Size and Check
wv=length(wavelength);
tm=size(raw,1);
ch=size(raw, 2);
if wv~=ch
	errordlg('Data Size of Wavelength is not equal to that of Raw data');
	return;
end

% Read e_coef and Set e_coef correspond to the wavelength
load e_coef;
for ii=1:wv;
   dum=( e_coef(:,1)==wavelength(ii) );
   if sum(dum) == 0   % Added by Shoji 15-Oct-2004
	   msg=sprintf(' e_coef.mat Error\n No e_coef data for wavelength(%d[nm]).\n',wavelength(ii));
	   errordlg(msg);
   elseif sum(dum) > 1
	   msg=sprintf(' e_coef.mat Error\n Too many e_coef data for wavelength(%d[nm]).\n',wavelength(ii));
	   errordlg(msg);
   end
   wavenum(ii)=find(dum);
end
decoef=e_coef(wavenum,2);
oxcoef=e_coef(wavenum,3);
clear dum;

% Make Anser Box
kk=0;
dCr=zeros(tm, ceil((ch-1)/2), 3);
w=waitbar(0,'HB translation ... 0%', ...
	  'Name', 'HB Translation', ...
	  'Color',[.9 1 .9 ]);


% Make equation
A=zeros( ch, ch );
for i=1:2:ch
	A(i, i )=oxcoef(i);
	A(i, i+1)=decoef(i);
	A(i+1, i )=oxcoef(i+1);
	A(i+1, i+1)=decoef(i+1);
end
	
% Solve For a Time correspond to raw.

tminv = 1/tm; w_x=0;
for jj=1:tm
        w_x = w_x+tminv;
	waitbar(w_x,w, ...
		['HB translation ... ' ...
		 sprintf('%3.0f',w_x*100) '%']);

	B=raw(jj,:)';
	%B=B+(B==0);
	B=-log(B./mean(raw(1:5,:),1)');
	

	D=A\B;
	%D=D.*(D~=0);
	D=D.*(isfinite(D));
	D=reshape(D,[ 2 size(D,1)/2 ]);%([oxy,deoxy],ch)
	T=sum(D,1);% total
	H=[D;T];% [ (oxy,deoxy) ;total]
	dCr(jj,:,:)=H';
end

close(w)
hb=real(dCr);
