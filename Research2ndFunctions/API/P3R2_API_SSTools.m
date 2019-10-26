function varargout=P3R2_API_SSTools(fcn,varargin)
% Statistical Test :: Key SElect API
%Function Version 2.0 (2013-04)
%
% == History ==
%$Id: P3R2_API_SSTools.m 364 2013-06-26 01:12:45Z Katura $
%##########################################################################
% Launcher
%##########################################################################
if nargin==0, fcn='help'; end

switch fcn
	case {'getDataInformation','expand2data','merge','textout','mergeKeys'...
			'deployCell2Mat','deployCell2Cell','replaceString2Index'...
			'deploySKCell2Mat','deploySKCell2Cell',...
			'expandSKCell2Mat',...
			'getSKeybyHeaderTag','SelectWithCondition'...
			'makeSKCell2Num',...
			}
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
%return;

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
function varargout=replaceString2Index(SS)

Key=SS{1}.SummarizedKey;

for k=1:size(Key,2)
	Key(:,k)=sub_replaceString2Index(Key(:,k));
end
SS{1}.SummarizedKey=Key;
varargout{1}=SS;
function varargout=sub_replaceString2Index(d)

if iscell(d)
	%TODO:
end
if ~ischar(d{1})
	varargout{1}=d;
	return;
end

tgch=cellfun(@isnumeric,d);
if any(tgch)
	d(tgch)=cellfun(@num2str,d(tgch),'uniform',0);
end
% tgch=cellfun(@isempty,d);
% if any(tgch)
% 	d(tgch)={'nan'};
% end
m=unique(d);

d0=d;
for k=1:length(m)
	d(strmatch(m{k},d0))={k};
end
varargout{1}=d;
%==========================================================================
function varargout=deploySSCell2Mat(SS,num,depIDTag)
%- depIDTag: A header name for deployed the num is stored in.
S0=SS{1}.SumuarizedKey;
idTg=strmatch(depIDTag,SS{1}.Header);
if isempty(idTg)
	idTg=size(S0,2)+1;
	S0=cat(2,S0,cell(size(S0,1),1));
	SS{1}.Header{end+1}=depIDTag;%- not in use, but.
end
varargout=deployCell2Mat(S0,num,idTg);
varargout{2}=SS{1}.Header;

function varargout=deploySKCell2Mat(SS,num,newTag)
S0=SS{1}.SummarizedKey;
H0=SS{1}.Header;

flag=false;
for k=1:length(S0(:))
	tmp=recurCell2Mat(S0(k));
	f=length(tmp)==num;
	flag=flag | f;
	if flag, break;end
end
if ~flag,
	varargout{1}=SS;
	return;
end
%-------------------------

S=zeros(0,size(S0,2));
IDX=[];
flag=false;
for k=1:size(S0,1)
	tmp=nan(num,size(S0,2));
	for kk=1:size(S0,2)
		s=S0{k,kk};
		if iscell(s)
			s=s{:};
			if isnumeric(s) && length(s)==num
				for ch=1:num
					tmp(ch,kk)=s(ch);
				end
			else
				tmp(1:num,kk)=repmat(s,[num,1]);
			end
		elseif isnumeric(s) && ~isempty(s)
			if length(s)==num
				tmp(:,kk)=s;
			else
				tmp(:,kk)=repmat(s,[num 1]);
			end
		else
			try
				tmp(1:num,kk)=str2double(s);
			catch
				tmp(1:num,kk)=nan(num,1);
			end
		end
	end
	% 	if size(tmp,1)==num
	% 		tmp(:,end+1)=1:num;
	% 		falg=true;
	% 	end
	S=cat(1,S,tmp);
	IDX=cat(1,IDX,[1:size(tmp,1)]');
end
if size(S0,1)~=size(S,1)
	H=cat(2,H0,newTag);
	S=cat(2,S,IDX);
end

SS{1}.SummarizedKeyMAT=S;
SS{1}.SummarizedKeyMAT_Header=H;

varargout{1}=SS;
function varargout=expandSKCell2Mat(SS,num,newTag,varTag)
S0=SS{1}.SummarizedKey;
H0=SS{1}.Header;

flag=false;
for k=1:length(S0(:))
	tmp=recurCell2Mat(S0(k));
	f=length(tmp)==num;
	flag=flag | f;
	if flag, break;end
end
if ~flag,
	varargout{1}=SS;
	return;
end
%-------------------------

S=zeros(size(S0,1),0);
H={};
IDX=[];
for k=1:size(S0,2)
	%tmp=nan(num,size(S0,2));
	tg=false(size(S0,1),1);
	%- find expand targets
	%- if the 1st item maches, all items will do too, ...
	tmp=[];
	for kk=1:size(S0,1)
		tmp(end+1)=length(S0{kk,k});
	end
	if length(unique(tmp))>1
		h=errordlg(sprintf('Size of "%s" is not identical.',newTag),'modal');
		uiwait(h);
		return;
	end
	
	if length(recurCell2Mat(S0{1,k}))==num
		tmp=nan(size(S0,1),num);
		tmpH=cell(1,num);
		for k1=1:size(S0,1)
			s=recurCell2Mat(S0{k1,k});
			if size(s,1)==num, s=s';end
			tmp(k1,:)=s;
		end
		for k1=1:num
			tmpH{1,k1}=sprintf('%s_%s%03d',H0{k},varTag,k1);
		end
	else
		if iscell(S0{1,k})
			tmp=cellfun(@cell2mat,S0(:,k));
		else
			tmp=double(cell2mat(S0(:,k)));
		end
		tmpH=H0{1,k};
	end
	S=cat(2,S,tmp);
	H=cat(2,H,tmpH);
	
end

%-
SS{1}.SummarizedKeyMAT=S;
SS{1}.SummarizedKeyMAT_Header=H;

varargout{1}=SS;

function b=subGetLength(a)
if isstruct(a)
	if isfield(a,'Data')
		b=length(a.Data);
	end
else
	b=length(a);
end
%==========================================================================
function SS=deploySKStruct2Cell(SS,num)
	if num~=1
		%TODO
		error('TODO');
	end
	
	for k=1:size(SS{1}.SummarizedKey,2)
		if isstruct(SS{1}.SummarizedKey{1,k})
			if length(SS{1}.SummarizedKey{1,k}.Data)==num;
				for kk=1:size(SS{1}.SummarizedKey,1)
					SS{1}.SummarizedKey{kk,k}=SS{1}.SummarizedKey{kk,k}.Data{1};
				end
			end
		end
	end
					
%==========================================================================
function varargout=deploySKCell2Cell(SS,num,newTag)
%- S0: Summarizedkey
%- num: if a member in Summarizedkey is Cell and the length is
%-      equall to the num, the member is depolyed from cell to matrix.
%- depIDTag: If there is, a field name which tag numbers for deployed is stored in.

if num==1
	SS=deploySKStruct2Cell(SS,num);
	varargout{1}=SS;
	return;
end

subCheckSS(SS,1);

S0=SS{1}.SummarizedKey;

%-check size of each cells
flag=false;
for k=1:length(S0(:))
	tmp=recurCell2Mat(S0(k));
	flag=flag | subGetLength(tmp)==num;
	if length(tmp)==num
		%TODO: ?
	end
	if flag, break;end
end
if ~flag,
	varargout{1}=SS;
	return;
end
%-------------------------

%- check string value
for k=1:size(S0,2)
	if ischar(S0{1,k})
		s0=S0(:,k);
		tmp=unique(s0);
		id=1:length(tmp);
		for kk=1:length(tmp)
			S0(strmatch(tmp{kk},s0),k)={id(kk)};
		end
	end
end
%---

idTg=strmatch(newTag,SS{1}.Header);
if isempty(idTg)
	idTg=size(S0,2)+1;
	S0=cat(2,S0,cell(size(S0,1),1));
	SS{1}.Header{end+1}=newTag;%- not in use, but.
	deployMode=true;
else
	if length(recurCell2Mat(S0(1,idTg)))==1
		deployMode=false;
	else
		deployMode=true;
	end
	%-check
	%b=cell2mat(S0(:,idTg));
	%tg=find(diff(b)<0);
end

if deployMode
	S=cell(0,size(S0,2));
	for k=1:size(S0,1)
		tmp=cell(num,size(S0,2));
		for kk=1:size(S0,2)
			s=S0{k,kk};
			if kk==idTg
				tmp(1:num,kk)=num2cell(1:num);
				
			elseif iscell(s)
				if length(s)==num
					for ch=1:num
						tmp(ch,kk)=s(ch);
					end
				elseif length(s)==1
					if length(s{1})==num
						for ch=1:num
							tmp(ch,kk)={s{1}(ch)};
						end
					else
						tmp(:,kk)=repmat(s,[num 1]);
					end
				else
					tmp(:,kk)=repmat({s},[num 1]);
				end
				
			elseif isnumeric(s) && ~isempty(s)
				tmp(:,kk)=num2cell(repmat(s,[num 1]));
				
			elseif isstruct(s)
				if strcmpi(s.Type,'numericB')
					stmp=recurCell2Mat(s.Data);
					if length(stmp)==num
						for ch=1:num
							tmp(ch,kk)={stmp(ch)};
						end
					end
				elseif strcmpi(s.Type,'cellB')
					if length(s.Data)==num
						for ch=1:num
							tmp(ch,kk)={s.Data(ch)};
						end
					end
				else
					warndlg(sprintf('unknown type. [%s]',s.Type));
					return;
				end
				%
			elseif ischar(s)
				1
			elseif isempty(s)
				
			else
				try
					tmp(1:num,kk)=str2double(S0{k,kk});
				catch
					tmp(1:num,kk)=repmat({nan},[num 1]);
				end
			end
		end
		S=cat(1,S,tmp);
	end
	SS{1}.SummarizedKey=S;
	
else %- deploy into existing position
	for k=1:size(S0,1)
		id=SS{1}.SummarizedKey{k,idTg};
		for kk=1:size(S0,2)
			s=SS{1}.SummarizedKey{k,kk};
			if kk==idTg, continue;end
			if subGetLength(s)~=num, continue;end
			if isstruct(s)
				SS{1}.SummarizedKey(k,kk)={recurCell2Mat(s.Data(id))};
			elseif iscell(s)
				SS{1}.SummarizedKey(k,kk)=s(id);
			elseif isnumeric(s)
				SS{1}.SummarizedKey(k,kk)={s(id)};%-TODO ???
			end
		end
	end
end
varargout{1}=SS;
%==========================================================================

%==
function rr=recurCell2Mat(r)
	rr=[];
if iscell(r)
	if length(r)==1
		rr=recurCell2Mat(r{1});
	else
		r1=recurCell2Mat(r{1});
		rr=zeros(length(r),size(r1));
		for k=1:length(r)
			tmp=recurCell2Mat(r{k});
			if isstruct(tmp)
				tmp=tmp.Data;
			end
			rr(k,:)=tmp(:);
		end
		rr=reshape(rr,[length(r) size(r1)]);
	end
else
	rr=r;
end
%==========================================================================
function varargout=deployCell2Mat(S0,num,varargin)
%- S0: Summarizedkey
%- num: if a member in Summarizedkey is cell and the length is
%-      equall to the num, the member is depolyed from cell to matrix.

% if nargin>2
% 	conterIDX=varargin{1};
% else
% 	S0=cat(2,S0,cell(size(S0,1),1));
% 	counterIDX=size(S0,2);
% end

%-check size of each cells
flag=false;
for k=1:length(S0(:))
	tmp=recurCell2Mat(S0(k));
	f=length(tmp)==num;
	flag=flag | f;
	if flag, break;end
end
if ~flag, varargout{1}=S0;return;end
%-------------------------

S=zeros(0,size(S0,2));
for k=1:size(S0,1)
	tmp=nan(num,size(S0,2));
	for kk=1:size(S0,2)
		s=S0{k,kk};
		if iscell(s)
			s=s{:};
			if isnumeric(s) && length(s)==num
				for ch=1:num
					tmp(ch,kk)=s(ch);
				end
			else
				tmp(1:num,kk)=repmat(s,[num,1]);
			end
		elseif isnumeric(s) && ~isempty(s)
			if length(s)==num
				tmp(:,kk)=s;
			else
				tmp(:,kk)=repmat(s,[num 1]);
			end
		else
			try
				tmp(1:num,kk)=str2double(s);
			catch
				tmp(1:num,kk)=nan(num,1);
			end
		end
	end
	if size(tmp,1)==num
		tmp(:,counterIDX)=1:num;
	end
	S=cat(1,S,tmp);
end

varargout{1}=S;
%==========================================================================

%==========================================================================
function varargout=deployCell2Cell(SS,num,depIDTag)
%- S0: Summarizedkey
%- num: if a member in Summarizedkey is cell and the length is
%-      equall to the num, the member is depolyed from cell to matrix.
%- depIDTag: If there is, a field name which tag numbers for deployed is stored in.

subCheckSS(SS,1);

S0=SS{1}.SummarizedKey;

%-check size of each cells
flag=false;
for k=1:length(S0(:))
	tmp=recurCell2Mat(S0(k));
	flag=flag | length(tmp)==num;
	if flag, break;end
end
if ~flag, varargout{1}=S0;varargout{2}=SS{1}.Header;return;end
%-------------------------

%- check string value
for k=1:size(S0,2)
	if ischar(S0{1,k})
		s0=S0(:,k);
		tmp=unique(s0);
		id=1:length(tmp);
		for kk=1:length(tmp)
			S0(strmatch(tmp{kk},s0),k)={id(kk)};
		end
	end
end
%---

idTg=strmatch(depIDTag,SS{1}.Header);
if isempty(idTg)
	idTg=size(S0,2)+1;
	S0=cat(2,S0,cell(size(S0,1),1));
	SS{1}.Header{end+1}=depIDTag;%- not in use, but.
end

S=cell(0,size(S0,2));
for k=1:size(S0,1)
	tmp=cell(num,size(S0,2));
	for kk=1:size(S0,2)
		s=S0{k,kk};
		if kk==idTg
			tmp(1:num,kk)=num2cell(1:num);
			
		elseif iscell(s)
			if length(s)==num
				for ch=1:num
					tmp(ch,kk)=s(ch);
				end
			else
				tmp(:,kk)=repmat(s,[num 1]);
			end
			
		elseif isnumeric(s) && ~isempty(s)
			tmp(:,kk)=num2cell(repmat(s,[num 1]));
			
		elseif isstruct(s)
			if strcmpi(s.Type,'numericB')
				if length(s.Data{1})==num
					for ch=1:num
						tmp(ch,kk)={s.Data{1}(ch)};
					end
				end
			elseif strcmpi(s.Type,'cellB')
				if length(s.Data)==num
					for ch=1:num
						tmp(ch,kk)={s.Data(ch)};
					end
				end
			else
				warndlg(sprintf('unknown type. [%s]',s.Type));
				return;
			end
			%
		elseif ischar(s)
			1
		else
			try
				tmp(1:num,kk)=str2double(S0{k,kk});
			catch
				tmp(1:num,kk)=repmat({nan},[num 1]);
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
%return;
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
%%
function varargout=getSKeybyHeaderTag(SS,tag)

subCheckSS(SS,1);

tg=find(strcmp(SS{1}.Header,tag));
if length(tg)~=1
	warndlg(sprintf('%d tag(s) found.',length(tg)));
	tg=tg(1);
	%return
end

varargout{1}=SS{1}.SummarizedKey(:,tg);

function varargout = mergeKeys(SS)

R=SS{1};
R.mergegKeyIDX=1:length(R.Header);
for k=2:length(SS)
	R.Header=cat(2,R.Header,SS{k}.Header);
	R.SummarizedKey=cat(2,R.SummarizedKey,SS{k}.SummarizedKey);
	R.mergegKeyIDX=cat(2,R.mergegKeyIDX,1:length(SS{k}.Header));
end

varargout{1}={R};

function varargout=makeSKCell2Num(SS)

tg=find(cellfun(@iscell,SS{1}.SummarizedKey));

for k=tg'
	d=SS{1}.SummarizedKey{k};
	d=cell2mat(d);
	SS{1}.SummarizedKey{k}=d(1);
end

varargout{1}=SS;


