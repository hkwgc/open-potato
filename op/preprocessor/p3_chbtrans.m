function hb=p3_chbtrans(raw, wavelength, avtime)
% function: Transfer to Continuous Hb
%
% May 23, 02 Maki
% mod. 030528 TK
% mod, 051219 TK : in Meeting.
% mod, 060106 MS : Brash up 
%                  Waitbar : off :
% mod, change name & add avtime
%++++++++++++++++++++++++++++++++++++++++++++++++++
% Syntax :
%   hb=p3_chbtrans(raw, wavelength,avtime);
%
% Input  :
%   Raw(time,ch)         :Matrix: ch       = channel*2
%   wavelength(wave-num) :Vector: wave-num = channel*2
%   avtime(time)         :Vector(boolean): : averaging time
%
% Output :
%   Hb(1:3):1=oxy,2=deoxy;3=total
%
% Other Input :
%  e_coef : Mat-File : e_coef
%           where ecoef is 
%                 1st col : Wave-Length
%                 2nd col : molecular absorption coefficient of Deoxy
%                 3rd col : molecular absorption coefficient of Oxy


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




%======================================
% Argument check
%======================================
if nargin<3 || isempty(avtime)
  avtime=1:5;
end
%======================================
% Initialize
%======================================
% Set Data-Size and Check
wv=length(wavelength); % Length of WaveLength
tm=size(raw,1);        % Time points 
ch=size(raw, 2);       % Channel number ( x 2)
if wv~=ch
  msg = 'Data Size of Wavelength is not equal to that of Raw data';
  errordlg(msg);
  error(msg);   % To stop processing.
  %return;
end

%======================================
% Get molecular absorption coefficient
%======================================
% Read e_coef 
load e_coef;
wavenum=zeros([1,wv]);
for ii=1:wv;
  % Find match wavelength
  dum=find( e_coef(:,1)==wavelength(ii) );
  if isempty(dum),
    diff=1;
    while isempty(dum),
      dum=find( (e_coef(:,1)>wavelength(ii) -diff) &&...
		(e_coef(:,1)<wavelength(ii) +diff) );
      diff=diff+1;
    end
    msg=sprintf([' e_coef.mat Error\n' ...
		 ' No match e_coef data for wavelength(%d[nm]).\n'...
		 ' Select wavelength : %d[nm]\n'], ...
		wavelength(ii), ecoef(dum(1),1));
    warndlg(msg);
  end
  wavenum(ii)=dum(1);
end
% Set Correspond e_coef
decoef=e_coef(wavenum,2);
oxcoef=e_coef(wavenum,3);
clear dum;

%======================================
% Conversion : Raw to HB
%======================================
% Make Anser Box
dCr=zeros(tm, ceil((ch-1)/2), 3);

% Make equation
A=zeros( ch, ch );
for i=1:2:ch
  A(i, i )=oxcoef(i);
  A(i, i+1)=decoef(i);
  A(i+1, i )=oxcoef(i+1);
  A(i+1, i+1)=decoef(i+1);
end
A=sparse(A);

% Solve For a Time correspond to raw.
m=mean(raw(avtime,:),1);
bc    = (raw./repmat(m+(m==0),tm,1))';
bc    = bc + (bc==0);
for jj=1:tm
  B = -log(bc(:,jj));
  D = A\B;
  D=full(D);
  dCr(jj,:,1:2)=(reshape(D,[2,ch/2]))';
end
dCr(~isfinite(dCr(:,:,:)))=0;
dCr(:,:,3)  = sum(dCr(:,:,1:2),3);

hb=real(dCr);
