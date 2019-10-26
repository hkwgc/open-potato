function varargout=Plugin_SLA_SimpleTTest(fcn,varargin)
%  t-test between two groups
%
%-----------------------
% $Id: Plugin2ndLvlAna_TwoGroupTTest.m 180 2011-05-19 09:34:28Z Katura $
%-----------------------

if nargin==0
  ospHelp(mfilename);return;
end

switch fcn
  case 'createBasicInfo'
    % Return Basic-Information of this Plugin
    varargout{1} = createBasicInfo;
  case 'simlpleHelpText',
    % Return Simple Help-Text of this Plugin
    varargout{1}=simlpleHelpText;
  case {'help','Help','HELP'},
    % Help of this Function
    OspHelp(mfilename);
  case 'Execute'
    % --> no-varargin     : no-group
    %        varargin{1}  : group
    %        varargout{1} : result
    varargout{1}=Execute(varargin{:});
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%       DispKind :: Add Kind 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.type   ='2nd-Lvl-Ana'; % Fixed!
basicInfo.name   = 'Two groups t-test '; % Print Name
basicInfo.wrap   =mfilename;
% ==> Version Setting
try
  % => (if this souce in CVS)
  rver         = '$Revision: 0.1 $';
  rver(end)    =[];
  rver         = str2double(rver(14:end));
catch
  rver         = -1; % Unknow Version
end
basicInfo.Version =rver;
return;

function str=simlpleHelpText
% GUI's Simple-Information.
bi= createBasicInfo;
str={...
  ' t-test between two groups ',...
  ' ====================================================',...
  '  This function will test between selected 2 groups. ',...
  '',...
  '  Relation of data will be checked by their [Raw] file name.',...
  sprintf('     Version             : %6.2f',bi.Version),...
  '',...
};

function data0=getArgument
% % Do nothing in particular
%     data0.name    : 'defined in createBasicInfo'
%     data0.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     data0.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = createBasicInfo;
data0.name=basicInfo.name;
data0.wrap=mfilename;
group1.name     = 'Test';
group1.function = '??_'; % <- Basic
data0.group={group1};
return;

function Result=Execute(Group)
%   Group : Group-Data
%    Group(1).fdata{1};    : 1st-Group 1st-Lvl-Ana Data (1)
%    Group(1).fhdata{1};
%
%    Group(1).fdata{2};    : 1st-Group 1st-Lvl-Ana Data (2)
%    Group(1).fhdata{2};....
%
%    Group(2).fdata{1};    : 2nd-Group 1st-Lvl-Ana Data (1)
%    Group(2).fhdata{1};
%
%  Number of Groups/Number of 1st-Lvl-Ana Data  is 
%     depend on User-Setting..
%  So you must be carful for check input data.
% 
%  no Group is allowed in Design.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
  error('Make 1-Group at least.');
end

%==> Result is free format
%    "THIS" function's Result is true/false.

if length(Group)~=2
	error(sprintf('Make 2-groups. %d group(s) not acceptable.',length(Group)));
end


%% main code for two group ttest

% check structure for compare
s1=ospsub_CheckStruct(Group(1).fhdata{1},Group(1).fhdata{1}.chlen);
for i=2:length(Group(1).fhdata)
	s0=ospsub_CheckStruct(Group(1).fhdata{i},Group(1).fhdata{1}.chlen);
	tg=zeros(1,length(s1));
	for j=1:length(s1)
		tg(j)=any(strcmp(s1{j},s0));
	end
	s1=s1(find(tg));
end

s2=ospsub_CheckStruct(Group(2).fhdata{1},Group(2).fhdata{1}.chlen);
for i=2:length(Group(2).fhdata)
	s0=ospsub_CheckStruct(Group(2).fhdata{i},Group(2).fhdata{1}.chlen);
	tg=zeros(1,length(s2));
	for j=1:length(s2)
		tg(j)=any(strcmp(s2{j},s0));
	end
	s2=s2(find(tg));
end

if length(s1)<length(s2)
	s1=tmp;s1=s2;s2=s1;
end

tg=zeros(1,length(s1));
for i=1:length(s1)
	tg(i)=any(strcmp(s1{i},s2));
end
s1=s1(find(tg));

% chech if size of fdata are acceptable
tg=1;
for i=1:length(Group(1).fdata)
	if length(Group(1).fdata{i})==Group(1).fhdata{1}.chlen ...
			&& length(Group(2).fdata{i})==Group(2).fhdata{1}.chlen
	else
		tg=-1;
	end
end
if tg==1
	s1=['Data', s1];
end

if isempty(s1)
	error('no data found.');
end

def = subP3_inputdlg({'Threshold','tail','select a item'}, 'two group ttest: item selection', 1,{'0.05',{'both','right','left'},s1});
ItemStr=def{3}{2};
ItemThresh=def{1};
ItemTail=def{2}{2};

% prepare data
D1=zeros(length(Group(1).fhdata),Group(1).fhdata{1}.chlen);%[sbj, ch]
for i=1:length(Group(1).fhdata)
	if strcmp(ItemStr,'Data')
		D1(i,:)=Group(1).fdata{i};
	else
		D1(i,:)=eval(['Group(1).fhdata{i}.' ItemStr]);
	end
end

D2=zeros(length(Group(2).fhdata),Group(2).fhdata{1}.chlen);%[sbj, ch]
for i=1:length(Group(2).fhdata)
	if strcmp(ItemStr,'Data')
		D2(i,:)=Group(2).fdata{i};
	else
		D2(i,:)=eval(['Group(2).fhdata{i}.' ItemStr]);
	end
end

% main loop for channel
DATA=[];
for ch=1:Group(1).fhdata{1}.chlen

	[H,P,CI,STATS]=ttest2(D1(:,ch),D2(:,ch),str2num(ItemThresh),ItemTail);
	HDATA.Results.H(1,ch)=H;
	HDATA.Results.P(1,ch)=P;
	HDATA.Results.t(1,ch)=STATS.tstat;
	HDATA.Results.mean1(1,ch)=mean(D1(:,ch));
	HDATA.Results.mean2(1,ch)=mean(D2(:,ch));
	HDATA.Results.sd1(1,ch)=std(D1(:,ch));
	HDATA.Results.sd2(1,ch)=std(D2(:,ch));
	
end

D=[];
FN=fieldnames(HDATA.Results);
for i=1:length(FN)
	D=[D sprintf('%s\t',FN{i}) ...
		sprintf('%f\t',eval(['HDATA.Results.' FN{i}])) sprintf('\n')];
end

clipboard('copy',D); %To Clipboard!
msgbox('Resuls were pasted to Clipbord.');

if isfield(Group(1).fhdata{1},'Pos')
	
HDATA.measuremode=-1;
HDATA.Pos=Group(1).fhdata{1}.Pos;
load('LAYOUT_ImageofResults2.mat','LAYOUT');
osp_LayoutViewer(LAYOUT,HDATA,ones(1,Group(1).fhdata{1}.chlen,3));
	
end

%%

sprintf('2nd Lvl [Paired t-test] end.\n');
Result=1;
return











