function patriot_test(s,NN)
%%



set(s,'terminator','CR');      

fprintf(s,'F0');
fprintf(s,'C');
fprintf(s,'U1');

figure(1);clf;
ax1=subplot(2,1,1);hold on;
axis equal;box on;grid on;view([50 25])
xlim([-50 50]);xlabel('x');ylim([-50 50]);ylabel('y');zlim([-50 50]);zlabel('z');
ax2=subplot(2,1,2);hold on;
hndls=plot(rand(100,3));
ylim([-50 50]);
%axis equal;box on;grid on;view([50 25])
%xlim([-50 50]);xlabel('x');ylim([-50 50]);ylabel('y');zlim([-50 50]);zlabel('z');

V=[1,0,0;0,1,0;0,0,1];
for k=1:NN
		
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
	
	set(gcf,'CurrentAxes',ax1);
	cla;
	h=vecpoint(P);set(h,'linestyle','none','marker','o','markerfacecolor','r');
	h1(1)=vecline(st1(2:4),[0 st1(3) st1(4)]);
	h1(2)=vecline(st1(2:4),[st1(2) 0 st1(4)]);
	h1(3)=vecline(st1(2:4),[st1(2) st1(3) 0]);
	h1(4)=vecline(st1(2:4),[0 0 0]);
	set(h1,'Color','r');
	h1=plot3(0,0,0,'ko');	set(h1,'markerfacecolor','k');
	vecline(P, P+V1(:,1)*10);
	vecline(P, P+V1(:,2)*10);
	vecline(P, P+V1(:,3)*10);

	h2=plot3(st2(2),st2(3),st2(4),'og');
	set(h2,'MarkerFaceColor','g');
	h2(1)=vecline(st2(2:4),[0 st2(3) st2(4)]);
	h2(2)=vecline(st2(2:4),[st2(2) 0 st2(4)]);
	h2(3)=vecline(st2(2:4),[st2(2) st2(3) 0]);
	h2(4)=vecline(st2(2:4),[0 0 0]);
	set(h2,'Color','g');
	vecline(P2, P2+V2(:,1)*10);
	vecline(P2, P2+V2(:,2)*10);
	vecline(P2, P2+V2(:,3)*10);

	drawnow;
	
 	%ret=translate(st1,st2);
	M=makeRot(R(1),R(2),R(3));
	ret=M*(P2-P);
	set(gcf,'CurrentAxes',ax2);
	for kkk=1:3
		tmp=get(hndls(kkk),'YData');
		tmp=tmp(2:end);
		tmp(end+1)=ret(kkk);
		set(hndls(kkk),'YData',tmp);
	end
% 	cla
% 	ds=st2-st1;
% 	h2=plot3(st2(1),st2(2),st2(3),'sm');
% 	h2=plot3(ret(1),ret(2),ret(3),'og');
% 	h2(1)=line([ret(1) 0],[ret(2) ret(2)],[ret(3) ret(3)]);
% 	h2(2)=line([ret(1) ret(1)],[0 ret(2)],[ret(3) ret(3)]);
% 	h2(3)=line([ret(1) ret(1)],[ret(2) ret(2)],[0 ret(3)]);
% 	h2(4)=line([0 ret(1)],[0 ret(2)],[0 ret(3)]);
% 	set(h2,'Color','g');
% 	h2=plot3(0,0,0,'ko');set(h2,'markerfacecolor','k');
 	title(sprintf('%d',k));
 	drawnow;

	
end

fclose(s);


function [ret]=translate(st1,st2)

pos01=st1;
pos02=st2;
A = pos01(5);
E = pos01(6);
R = pos01(7);

pos=pos02(2:4)-pos01(2:4);

% %A: Azimuth, E: Elevation, R: Roll
A = A*pi/180.0;
E = E*pi/180.0;
R = R*pi/180.0;
CA = cos(A);   CE = cos(E);    CR = cos(R);
SA = sin(A);   SE = sin(E);    SR = sin(R);
result=[0.0,0.0,0.0];
result(1)=CA*CE*pos(1) + (CA*SE*SR-SA*CR)*pos(2) + (CA*SE*CR+SA*SR)*pos(3);
result(2)=SA*CE*pos(1) + (CA*CR+SA*SE*SR)*pos(2) + (SA*SE*CR-CA*SR)*pos(3);
result(3)=-SE*pos(1) + CE*SR*pos(2) + CE*CR*pos(3);

ret=result;

% a = A*pi/180.0;
% e = E*pi/180.0;
% r = R*pi/180.0;
% ca=cos(a);ce=cos(e);cr=cos(r);
% sa=sin(a);se=sin(e);sr=sin(r);
% 
% M=[[ca*ce sa*ce -se]; ...
% 	[ca*se*sr-sa*cr ca*cr+sa*se*sr ce*sr]; ...
% 	[ca*se*cr+sa*sr sa*se*cr-ca*sr ce*cr]];
% 
% %ret=M*st1(2:4);
% %ret=M'*st1(2:4);
% %M=inv(M);
% ret=M*pos;

function M=makeRot(A,E,R)

a = A*pi/180.0;
e = E*pi/180.0;
r = R*pi/180.0;
ca=cos(a);ce=cos(e);cr=cos(r);
sa=sin(a);se=sin(e);sr=sin(r);

M=[[ca*ce sa*ce -se]; ...
	[ca*se*sr-sa*cr ca*cr+sa*se*sr ce*sr]; ...
	[ca*se*cr+sa*sr sa*se*cr-ca*sr ce*cr]];




function h=vecline(p,q)

h=line([p(1) q(1)],[p(2) q(2)],[p(3) q(3)]);

function h=vecpoint(p)
h=plot3(p(1),p(2),p(3));
