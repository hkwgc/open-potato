function varargout=dev3dpos_patriot(cmd,varargin)
% serial I/O handling for ISO TRAK II 3D measure device 
% dev3dpos_isotrack(cmd, s)
% cmd : 'ini2click', 'go2ini', 'hold', 'click2point', 'point2click', 'GetPoint'
%   'ini2click' : transit initial-mode to stylus-click mode
%   'go2ini' : reset 3D-device to initialte it
%   'hold' : hold 3D-device mode ; no-operation
%   'click2point' : transit from stylus-click mode to point mode
%     * point mode is used as auto-mode in Navigation 
%   'point2click' : transit from point mode to stylus-click mode
%   'getpoint' : get point by sending 'P' command
%   'readpos' : read 3D-device position
% s : serial port
%
persistent pos01; % stylusÇÃç¿ïW
persistent pos01_updated_flag; %

[dum nargin] = size(varargin);

if( (nargin ~=1 ) )
    error('dev3dpos_isotrack() : specify 2 input argments\n');
end

s=varargin{1};%com port handle
set(s,'terminator','CR');      
switch lower(cmd)
case 'ini2click'
      fprintf(s,'Y');%reset
	  fprintf(s,'F0');%set output format to ascii
	  fprintf(s,'L1,1');%set click-output mode for Device1
	  fprintf(s,'L2,1');%set click-output mode for Device2
      fprintf(s,'U1');%Unit centimeter
      
	  fprintf(s,'P');%signel mode

case 'go2ini'
      CtrlY=char(25);
      fprintf(s,CtrlY);

case 'hold'
      ;

case 'click2point'
      fprintf(s,'Y');%reset
      fprintf(s,'C');% continuous mode

case 'point2click'
      fprintf(s,'Y');%reset
      fprintf(s,'C');% continuous mode

case 'getpoint'
      fprintf(s,'P');
      
case 'readpos'
      if( (nargout~=2 ) )
          error('dev3dpos_isotrack() : specify 2 output argments for ''readpoint'' \n');
	  end
	  
	  v{1}=-1;v{2}=[];
	  r=fgetl(s);
	  r1=sscanf(r,'%02d %f %f %f %f %f %f');
	  if isempty(r1) || isempty(r1) || length(r1) ~= 7
		  return;
	  elseif r1(1)==1
		  v{1}=1;
		  v{2}=r1(2:end);%[x,y,z,a,e,r]
		  pos01=v{2};
		  pos01_updated_flag=1;
	  elseif r1(1)==2 && pos01_updated_flag==1
		  pos01_updated_flag=0;
		  v{1}=2;
		  r1=r1(2:end);%[x,y,z,a,e,r]
		  M=makeRot(pos01(4),pos01(5),pos01(6));
		  v{2}=M*(r1(1:3)-pos01(1:3));
		  v{2}=v{2}';
		  v{2}=v{2}*10;%Unit cm to mm
		  sound(sin(1:1000)/6*2,15000);pause(0.5);sound(sin(1:1000)/6*2,10000);
		  %fprintf(sprintf('%0.2f, %0.2f, %0.2f\n',r1(1),r1(2),r1(3)));
		  %fprintf(sprintf('%0.2f, %0.2f, %0.2f\n',pos01(1),pos01(2),pos01(3)));
	  end
	  varargout=v;
end

function v=getPosData(s)
if ~exist('pos01_updated_flag','var')
	pos01_updated_flag=0;
end
v{1}=-1;v{2}=[];
r=fgetl(s);
r1=sscanf(r,'%02d %f %f %f %f %f %f');
if isempty(r1) || isempty(r1) || length(r1) ~= 7
	return;
elseif r1(1)==1
	v{1}=1;
	v{2}=r1(2:end);%[x,y,z,a,e,r]
	pos01=v{2};
	pos01_updated_flag=1;
elseif r1(1)==2 && pos01_updated_flag==1
	pos01_updated_flag=0;
	v{1}=2;
	M=makeRot(pos01(4),pos01(5),pos01(6));
	v{2}=M*(r1(1:3)-pos01(1:3))';
end
			
			
function ret=makePos(s)
V=[1,0,0;0,1,0;0,0,1];
while 1
	r=[];st1=[];st2=[];
	r{1}=fgetl(s);
	r{2}=fgetl(s);
	for k1=1:2
		r1=sscanf(r{k1},'%02d %f %f %f %f %f %f');
		if isempty(r1) || isempty(r1) || length(r1) ~= 7
			continue;
		elseif r1(1)==1
			st1=r1;
			P=st1(2:4);
			R=st1(5:7);
			M=makeRot(R(1),R(2),R(3));
			V1(:,1)=M*V(:,1);V1(:,2)=M*V(:,2);V1(:,3)=M*V(:,3);
		else
			st2=r1;
			P2=st2(2:4);
			R2=st2(5:7);
			M=makeRot(R2(1),R2(2),R2(3));
			V2(:,1)=M*V(:,1);V2(:,2)=M*V(:,2);V2(:,3)=M*V(:,3);
		end
	end
	if (length(st1)==7) && (length(st2)==7)
		break;
	end
end

M=makeRot(R(1),R(2),R(3));
ret=M*(P2-P);

	
function M=makeRot(A,E,R)

a = A*pi/180.0;
e = E*pi/180.0;
r = R*pi/180.0;
ca=cos(a);ce=cos(e);cr=cos(r);
sa=sin(a);se=sin(e);sr=sin(r);

M=[[ca*ce sa*ce -se]; ...
	[ca*se*sr-sa*cr ca*cr+sa*se*sr ce*sr]; ...
	[ca*se*cr+sa*sr sa*se*cr-ca*sr ce*cr]];

