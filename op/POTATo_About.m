function [h,h2,h3]=POTATo_About(varargin)
% Launch About Window.
%  Tihs is
%
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata


global WinP3_EXE_PATH;
persistent h0 h02 h03 h04;

if nargin==1
	if strcmpi(varargin{1}, 'UPDATE')
		if ~ishandle(h04)
			return;
		end
		str=[OSP_DATA('GET','POTAToVersion') '   '];
		for k=1:length(str)
			set(h04,'string', sprintf(subString4VersionMessage,str(1:k)));
			drawnow;
			pause(0.05);
		end
		pause(0.25);
	end
end

if ~isempty(h0) && ishandle(h0)
	h=figure(h0);h2=h02;h3=h03;
	return;
end
h0=[];   %#ok for double launch
h02=[];  %#ok for double launch
h03=[];  %#ok for double launch
h3 =[];

% $Id: POTATo_About.m 398 2014-03-31 04:36:46Z katura7pro $

p=which(mfilename);
p=fileparts(p);


% set(0,'defaultFigureVisible', 'off');
f=[p filesep 'POTAToCREDIT.bmp'];
if ~exist(f,'file')
	f=[WinP3_EXE_PATH filesep 'POTAToCREDIT.bmp'];
	if ~exist(f,'file')
		fprintf(2,'File Error : %s\n',f);
		p=fileparts(fileparts(which('WinP3')));
		f=[p filesep 'POTAToCREDIT.bmp'];
		fprintf(2,'   -> %s\n',f);
	end
end
cdata1=imread(f,'BMP');

% Create figure
h = figure(...
	'Color',[1 1 1],...
	'IntegerHandle','off',...
	'Name','About P3',...
	'MenuBar','none',...
	'NumberTitle','off',...
	'Resize','off',...
	'Units','Pixels');

%p=get(h,'Position');
%p(3:4)=[356,102];
sz=size(cdata1);
wsz=get(0,'ScreenSize');  % Get Screan-Size
%wsz=get(0,'MonitorPositions');
%p(3:4)=sz([2,1])*1.1; % Same Size
%p(3:4)=sz([2,1])*0.8;
p=[fix(wsz(3)-sz(2))/2*.9 fix(wsz(4)-sz(1))/2*.9 sz([2 1])*1.1];
set(h,'Position',p);

% Create axes
axes1 = axes(...
	'Layer','top',...
	'Units','Normalized',...
	'Position',[0.05 0.05 0.9 0.9],...
	'Parent',h,...
	'Visible','off');

% Create image
h2 = image(cdata1,'Parent',axes1);
axis off
h4 = text(660,125,sprintf(subString4VersionMessage,OSP_DATA('GET','POTAToVersion')));
set(h4,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold','FontName','Arial');

set(0,'defaultFigureVisible', 'on');

for idx=1:2:length(varargin)
	switch upper(varargin{idx}),
		case 'STARTUP',
			r=1;r2=1/(1+r);
			p(3:4)=[356,102*(1+r)];
			%set(h,'Position',p);
			%set(axes1,'Position',[0.05, r+0.05*r2 0.9 0.9*r2]);
			uicontrol('Style','text',...
				'Units','Normalized',...
				'Position',[0.06,0.4,0.3,0.1],...
				'BackgroundColor',[1 1 1],...
				'HorizontalAlignment','Left',...
				'Tag','txt_status',...
				'String',varargin{idx+1});
			h3=uicontrol('Style','listbox',...
				'Units','Normalized',...
				'Position',[0.06,0.1,0.37,0.3],...
				'BackgroundColor',[1 1 1],...
				'HorizontalAlignment','left',...
				'Tag','lbx_status',...
				'String',{});
		case 'VER',
			% text(400,120,['Rev : ' varargin{idx+1}]);
			%xx=420;
			%xx=80;yy=130;
			xx=700;yy=155;
			try
				%myid=OSP_DATA('GET','CIRCULATION_ID');
				%th0=text(xx,yy,sprintf('ID: %d',round(myid)));
			catch
				%th0=text(xx,yy,['ID: ' varargin{idx+1}]);
			end
			%th=text(xx,yy+25,['Rev. ' varargin{idx+1}]);
			%set([th0 th],'Fontsize',16);
			%set(th0,'Fontsize',10,'FontWeight','Demi','FontName','Arial');
	end
end
set(h,'Visible','on');

h0=h;
h02=h2;
h03=h3;
h04=h4;

function s=subString4VersionMessage
matlabinfo = ver('MATLAB');
s=['Platform ver. %s\n (developed on MATLAB ' matlabinfo.Release ')'];