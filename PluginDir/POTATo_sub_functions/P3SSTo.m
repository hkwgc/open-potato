function varargout=P3R2_API_SSTools(fcn,varargin)
% Statistical Test :: Key SElect API

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
%  2011.01.26 : New!

%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
	case {'getDataInformation','expand2data','merge','textout','deployCell2Mat','SelectWithCondition'}
		if nargout,
			[varargout{1:nargout}] = feval(fcn, varargin{:});
		else
			feval(fcn, varargin{:});
		end
	case {'help'}
		POTATo_Help(mfilename);
	otherwise
		error('Not Implemented Function : %s',fcn);
end

%##########################################################################
% Get Data Infromation
%##########################################################################
function info=getDataInformation(Data)
% show Data Information
if isempty(Data)
	info={'No Data'};return;
end

if iscell(Data)
	% CellSS  Data
	info=getDataInfo_CellSS(Data);
	return;
end

if isstruct(Data)
	if isfield(Data,'SummarizedKey')
		info=getDataInfo_SS(Data);
		return;
	end
	% is Raw Data
	if isfield(Data,'shead') && isfield(Data,'skey') && isfield(Data,'sdata')
		info=getDataInfo_rsd(sd);
		return;
	end
end

% no type
info={'Unknown Data Type'};
return;

%==========================================================================
function info=getDataInfo_CellSS(CellSS)
% information of Cell SS
%  * Upper -->P3_gui_Resaerch_2nd/lbx_R2nd_SummarizedDataList_Update
%  * Lower --> getDataInfo_SS(CellSS)
%==========================================================================

n=length(CellSS);
info={sprintf('Number of Group : %d',n)};
for ii=1:n
	info0=getDataInfo_SS(CellSS{ii});
	info ={info{:}, ...
		sprintf('Group(%d).......................',ii),...
		info0{:}};
end

%==========================================================================
function info=getDataInfo_SS(SS)
% information of Cell SS
%  * Upper --> getDataInfo_CellSS(CellSS)
%==========================================================================
ds=0;
dl=size(SS.SummarizedData,1);
for dd=1:dl
	ds=ds+numel(SS.SummarizedData{dd,1});
end
info={sprintf('Data Size : %d', ds)};
if 1
	info{end+1}='Original files:';
	k=DataDef2_Analysis('getIdentifierKey');
	for ii=1:SS.nfile
		info{end+1}=['    ' SS.AnaFiles{ii}.(k)];
	end
end


%==========================================================================
function info=getDataInfo_rsd(sd)
% information of sd raw-SS (OLD-CODE?)
%==========================================================================

try
	nblock=size(sd.skey,1);
	[a b c]=cellfun(@size,sd.sdata(:,1));
	mch  =[min(b(:)), max(b(:))];
	mkind=[min(c(:)), max(c(:))];
	ndata=sum(a.*b.*c);
	[a2 b2]=cellfun(@size,cellfun(@find,sd.sdata(:,2),'UniformOutput', false));
	%nflag0=sum(a2.*b2);
	nflag=sum(a2.*b2.*a.*c);
	if isnumeric(nflag)
		ndata=ndata-nflag;
	end
catch
	if ~exist('nblock','var')
		nblock=NaN;
	end
	if ~exist('ndata','var')
		ndata=NaN;
	end
	if ~exist('mch','var')
		mch=[NaN,NaN];
	end
	if ~exist('mkind','var')
		mkind=[NaN, NaN];
	end
	if ~exist('nflag','var')
		nflag=NaN;
	end
end

info={'Selected Summary Stastic Data Information',...
	'* Data Size',...
	sprintf('  Number of Data    : %d',ndata),...
	sprintf('    (Flag Data)       %d',nflag),...
	sprintf('  Number of Block   : %d',nblock),...
	sprintf('  Number of Channel : [%d-%d]',mch),...
	sprintf('  Number of Kind    : [%d-%d]',mkind),...
	};

info{end+1}='* Key List';
for ii=1:length(sd.shead)
	info{end+1}=['  ' sd.shead{ii}];
end

%##########################################################################
% Data Transfer --> MAT
%##########################################################################
function mat=expand2data(Data)
% Expand Data 2 mat
if isempty(Data)
	mat=[];return;
end

if isnumeric(Data)
	mat=Data;
	return;
end

if iscell(Data)
	% CellSS  Data
	mat=expand2data_CellSS(Data);
	return;
end

if isstruct(Data)
	if isfield(Data,'SummarizedKey')
		mat=expand2data_SS(Data);
		return;
	end
	%   % is Raw Data
	%   if isfield(Data,'shead') && isfield(Data,'skey') && isfield(Data,'sdata')
	%     mat=expand2data_rsd(sd);
	%     return;
	%   end
end
% no type
error('Unknown Data Type');

%==========================================================================
function mat=expand2data_CellSS(CellSS)
% Expand CellSS
%==========================================================================
n=length(CellSS);
mat=[];
for ii=1:n
	mat=[mat, expand2data_SS(CellSS{ii})];
end

%==========================================================================
function mat=expand2data_SS(SS)
% Expand SS
%==========================================================================
mat=[];
dl=size(SS.SummarizedData,1);
for dd=1:dl
	try
		tmp=SS.SummarizedData{dd,1};
		% aply flag
		tmp(:,SS.SummarizedData{dd,2}>=1,:)=[];
		mat=[mat, tmp(:)'];
	catch
		disp('Aply Flag Error');
	end
end

%==========================================================================
function varargout=deployCell2Mat(SS,num,depIDTag)
%- S0: Summarizedkey
%- num: if a member in Summarizedkey is cell and the length is
%-      equall to num, the member is depolyed from cell to matrix.
%- depIDTag: Indecies for deployed members are stored to there.

subCheckSS(SS,1);

S0=SS{1}.SummarizedKey;
idTg=strmatch(depIDTag,SS{1}.Header);
if isempty(idTg)
	idTg=size(S0,2)+1;
	S0=cat(2,S0,cell(size(S0,1),1));
	SS{1}.Header{end+1}=depIDTag;%- not in use, but.
end

S=zeros(0,size(S0,2));
for k=1:size(S0,1)
	tmp=nan(num,size(S0,2));
	for kk=1:size(S0,2)
		if kk==idTg
			tmp(1:num,kk)=1:num;
		elseif iscell(S0{k,kk})
			s=S0{k,kk};s=s{:};
			if isnumeric(s) && length(s)==num
				for ch=1:num
					tmp(ch,kk)=s(ch);
				end
			else
				tmp(1:num,kk)=repmat(s,[num,1]);
			end
		elseif isnumeric(S0{k,kk}) && ~isempty(S0{k,kk})
			tmp(1:num,kk)=repmat(S0{k,kk},[num 1]);
		else
			try
				tmp(1:num,kk)=str2num(S0{k,kk});
			catch
				tmp(1:num,kk)=nan(num,1);
			end
		end
	end
	S=cat(1,S,tmp);
end

varargout{1}=S;
varargout{2}=SS{1}.Header;
%==========================================================================

%##########################################################################
% Textout
%##########################################################################
function emsg=textout(Data)
% show Data Information
emsg='';
if isempty(Data)
	return;
end

if iscell(Data)
	% cellSS->SS
	Data=merge(Data);
	Data=Data{1};
end

if isstruct(Data)
	if isfield(Data,'SummarizedKey')
		emsg=textout_SS(Data);
		return;
	end
end

% no type
emsg='Unknown DataType';
return;
%==========================================================================
function emsg=textout_SS(SS)
% Text-Out SS
%==========================================================================
emsg='';

keys=ss_datakeys;
[fname, pname] = osp_uiputfile('*.csv', 'Output File Name');
if isequal(fname,0) || isequal(pname,0)
	return;
end
fname=[pname filesep fname];
try
	fid=fopen(fname,'w');
	if fid==-1
		errordlg('File open error.','P3R2_API_SSTools (textout_SS)','modal');
		return;
	end
	fprintf(fid,'Summary Statistics Data Output File\n');
	fprintf(fid,',,POTATo Versin %s\n',OSP_DATA('GET','POTAToVersion'));
	fprintf(fid,'Data,');
	for ii=1:length(keys)
		fprintf(fid,'%s,',keys{ii});
	end
	fprintf(fid,'Flag,');
	for ii=1:length(SS.Header)
		fprintf(fid,'%s,',SS.Header{ii});
	end
	fprintf(fid,'\n');
	
	for ii=1:size(SS.SummarizedKey,1) % Block-Data Loop
		d=SS.SummarizedData{ii,1};
		
		% Data (key)
		%keystr='';
		keystr=cell(1,size(d,2)); %- {1, channel}
		for jj=1:size(SS.SummarizedKey,2)
			kdat=SS.SummarizedKey{ii,jj};
			if iscell(kdat) && length(kdat)==size(d,2)
				kdat0=kdat;
			else
				kdat0=repmat({kdat},[1 size(d,2)]);
			end
			for cc=1:size(d,2) %- channel loop
				try
					if isnumeric(kdat0{1,cc})
						keystr{1,cc}=[keystr{1,cc} ',' num2str(kdat0{1,cc})];
					else
						keystr{1,cc}=[keystr{1,cc} ',' kdat0{1,cc}];
					end
				catch
					keystr{1,cc}=[keystr{1,cc} ',***'];
				end
			end % keystr
		end
		
		for tm=1:size(d,1)
			for ch=1:size(d,2)
				for kd=1:size(d,3)
					fprintf(fid,'%f,%d,%d,%d,%d%s\n',...
						d(tm,ch,kd),tm,ch,kd,SS.SummarizedData{ii,2}(1,ch),keystr{1,ch});
				end
			end
		end
	end
catch
	fclose(fid);
	emsg=lasterr;
	return;
end
fclose(fid);

%##########################################################################
% Textout
%##########################################################################
function cellSS=merge(cellSS0)
%
if isempty(cellSS0)
	return;
end
% Argument check
if ~iscell(cellSS0)
	error('Bad Data format');
end
n=length(cellSS0);
if n==1
	cellSS=cellSS0;
	return;
end

SS=cellSS0{1};
for ii=2:n
	SSin=cellSS0{ii};
	SS.nfile = SS.nfile + SSin.nfile;
	SS.AnaFiles = [SS.AnaFiles SSin.AnaFiles];
	SS.SummarizedData=[SS.SummarizedData; SSin.SummarizedData];
	shead0=SS.Header;
	shead =union(shead0,SS.Header);
	[x i0o i0i]=intersect(shead, shead0); %#ok x is not use
	[x ido idi]=intersect(shead, SSin.Header); %#ok x is not use
	SS.Header=shead;
	% Update Key
	rown=size(SS.SummarizedData,1);
	coln=length(shead);
	tmp=cell([rown, coln]);
	tmp(1:size(SS.SummarizedKey,1)    ,i0o) = SS.SummarizedKey(:,i0i);
	tmp(size(SS.SummarizedKey,1)+1:end,ido) = SSin.SummarizedKey(:,idi);
	SS.SummarizedKey=tmp;
end
cellSS={SS};


function ret=subCheckSS(SS,n)
s=[];ret=false;
if ~iscell(SS)
	s='SS should be a cell.';return;
elseif length(SS)~=n
	s=sprintf('Size of SS should be %d.');return;
end

if ~isempty(s)
	errordlg(['SS should be a cell.',C__FILE__LINE__CHAR(inf)]);return;
end

ret=true;


function V=SelectWithCondition(SS,targetTag,conditionScript)
V=[];

if ~subCheckSS(SS,1)
	return;
end

tg=ismember(SS{1}.Header,targetTag);
if ~any(tg)
	warndlg(sprintf('Taget tag:[%s] not found in SS data.\n%s',targetTag,C__FILE__LINE__CHAR(1)));
	return;
end

V=SS{1}.SummarizedKey(:,tg);
cnd=true(length(V),1);
conditionScript=cat(2,'& ',conditionScript);
for k=1:(length(conditionScript)+1)/3
	cs=conditionScript((k-1)*3+1:(k-1)*3+3);
	tg=strcmp(cs{2},SS{1}.Header);
	if ~any(tg)
		warndlg(sprintf('Condition tag:[%s] not found in SS data.\n%s',cs{2},C__FILE__LINE__CHAR(1)));
		continue;
	end
	if k==1, LOP='&';else LOP=cs{1};end
	
	try
		t=P3R2_API_SSTools('expand2data',SS{1}.SummarizedKey(:,tg));
		%t=cell2mat(SS{1}.SummarizedKey(:,tg));
	catch
		warndlg(sprintf('Condition tag:[%s] is not a cell vector.\n\n%s',cs{2},C__FILE__LINE__CHAR));
		continue;
	end
	
	cnd=eval(sprintf('cnd %s t %s;',LOP, cs{3}));
end
V=V(cnd,:);





