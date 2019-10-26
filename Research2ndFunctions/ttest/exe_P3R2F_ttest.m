function varargout = exe_P3R2F_ttest(varargin)
% P3R2_SUBAPI_GROUPINGBYKEY is window of POTATo Reserch-Mode.
%   This window select GROUP by key from SS Data.
%
%  exe_P3R2F_ttest_OpeningFcn('
% Upper link : P3R2F_ttest & myself(gui) ONLY.
% See also: P3R2F_ttest, GUIDE, GUIDATA, GUIHANDLES


% Initiarize Launcher ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Depend on GUIDE version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exe_P3R2F_ttest_OpeningFcn, ...
                   'gui_OutputFcn',  @exe_P3R2F_ttest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting Operation's
%-----------------------------------------------------------------
%  1. Opening Function, (from P3R2F_ttest)
%  2. Outupt  Function, (handle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function exe_P3R2F_ttest_OpeningFcn(h, ev, hs, varargin)
% This function has no output args, see OutputFcn.
% h        handle to figure
% ev       reserved - to be defined in a future version of MATLAB
% hs       structure with handles and user data (see GUIDATA)
% varargin command line arguments to exe_P3R2F_ttest (see VARARGIN)
%==========================================================================

% Output (return value) is handle.
hs.output = h;

for ii=1:2:length(varargin)
  name= varargin{ii};
  val = varargin{ii+1};
  setappdata(h,name,val);
end

try
  ArgData= getappdata(hs.figure1,'ArgData');
  switch ArgData.TTest.mode
    case 'OneSample'
      statstr='** One Sample T-Test **';
    case 'TwoSample'
      if ArgData.TTest.paired
        statstr='** Two Sample , Paired T-Test **';
      else
        statstr='** Two Sample T-Test **';
      end
    otherwise
  end

  set(hs.txt_state,'String',statstr);
catch
  % bad option
  hs.output=errordlg('Argument Error','T-Test Opening Function');
end

% Update handles structure
guidata(h, hs);


% --- Outputs from this function are returned to the command line.
function varargout = exe_P3R2F_ttest_OutputFcn(h, ev, hs) %#ok
% Output : Handles
varargout{1} = hs.output;
if 1 % set 0 when modify & test by guide
  if (h~=hs.output)
    delete(h);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI :: Execute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tail=getTail(hs)
%
if get(hs.rdb_tailboth,'Value')
  tail='both';return;
end
if get(hs.rdb_tailright,'Value')
  tail='right';return;
end
if get(hs.rdb_tailleft,'Value')
  tail='left';return;
end

function psb_execute_Callback(h, ev, hs) %#ok
% re-perform
persistent isrun;
if ~isempty(isrun) && isrun
  %errordlg('[E] Another calucation alread started.');
  %return;
end

try
  isrun=true; %#ok
  cellSS = getappdata(hs.figure1,'cellSS');
  ArgData= getappdata(hs.figure1,'ArgData');
  r=execute(hs,cellSS,ArgData);
  if (r.error)
    errordlg(r.error,'T-Test execute Error');
  end
catch
  isrun=false;
  errordlg(lasterr);
  return;
end

%-----------------------
%- Draw figure
if 1
	r.header = strrep(r.header,'-','_');
	r.header = strrep(r.header,' ','_');
	
	chlen=size(ArgData.RawDataForDrawing.hdata.flag,3);
	
	for k=1:length(r.header)
		tg(k)=~ischar(r.data{1,k}) & length(r.data(:,k))==chlen;
	end
	if any(tg)
		for k=find(tg)
			tmp=r.data(:,k);
			for kk=1:length(tmp)
				ArgData.RawDataForDrawing.hdata.Results.(r.header{k})(1,kk) = tmp{kk};
			end
		end
		load('LAYOUT_ImageofResults2')
		P3_view(LAYOUT,ArgData.RawDataForDrawing.hdata ,ArgData.RawDataForDrawing.dummydata);
	end
end
%-----------------------
%-----------------------

isrun=false;

%==========================================================================
function result=execute(hs,cellSS, ArgData)
% Perform T-Test
% Input : cellSS={datar,...} : cell of Summarized Statistics
%       datar: Real-part of Summarized Statistics.
%       datar.nfile    : --(undefined here.)--
%       datar.Anafiles : --(undefined here.)--
%       datar.ExeData  : --(undefined here.)--
%       datar.Header        : Cell Header of Summarized Data
%       datar.SummarizedKey : Cell Summarized Data (Key-part)
%       datar.SummarizedData: Cell Summarized Data (Data-part)
%==========================================================================
persistent iscancel;
if isempty(hs)
  iscancel=true;return;
end
iscancel=false;

% init...
result.error='';
f=get(0,'FixedWidthFontName');
set(hs.lbx_result,'Value',1,'String','Making group...','FontName',f);
drawnow;

%---------------------------
% Independent Keys Grouping
%---------------------------
api=ArgData.APIInfo.Stat{1}; % first API : independent key 
indepkey=ArgData.(api.fld).SelectedKeys;
cellSS=feval(api.fcn,'execute',cellSS,ArgData.(api.fld));
n=length(cellSS);

%debug print
%info=P3R2_API_SSTools('getDataInformation',cellSS);
%disp(char(info));
%commandwindow;

%---------------------------
% Setup Header
%---------------------------
switch ArgData.TTest.mode
  case 'OneSample'
    resulthead={'id','distribution','h','p' 'n1' , 'l-h1','l-p1'};
  case 'TwoSample'
    if ArgData.TTest.paired
      resulthead={'id', 'h','p', 'n1' , 'l-h1','l-p1', 'n2' , 'l-h2','l-p2'};
    else
      resulthead={'id', 'h','p','f-h','f-p','n1' , 'l-h1','l-p1', 'n2' , 'l-h2','l-p2'};
    end
  otherwise
end
resulthead(end+1:end+length(indepkey))=indepkey(:);
resultdata=cell([n, length(resulthead)]);

% localstr='';
% for ii=1:length(resulthead)
%   localstr=[localstr resulthead{ii} ', '];
% end
% localstr(end-1:end)=[];
localstr = getHeaderStr(resulthead);
resultstr={localstr};
resultstr{end+1} = getFormedSeparator(resulthead);

ginfostidx=find(strcmp(resulthead,'n1'));

%---------------------------
% Get parameter
%---------------------------
try
	alpha=str2double(get(hs.edt_threshold,'String'));
catch
	alpha=NaN;
end
if alpha<0 || alpha>1
	errordlg('please set proper threshold');
	return;
end
tail=getTail(hs);
%---------------------------
% Independent Key Loop
%---------------------------
j0=length(resulthead)-length(indepkey)+1;
je=length(resulthead);

%*****
dataSSViewFigHnd=figure;set(gcf,'ToolBar','none');
A=POTATo_sub_MakeGUI(dataSSViewFigHnd);
A.UIType='popupmenu';A.PosY=0;A.PosX=0;A.SizeX=50;A.Label='Data number';
A.String={};for k=1:n, A.String{k}=sprintf('%d',k);end
A.PRMs.Callback=[mfilename '(''Callback_dataSSViewFig'');'];A.PRMs.Visible='on';
A=POTATo_sub_MakeGUI(A);
%*****
  
for ii=1:n
	% ( cancel check )
	if (iscancel), return; end

	cellSS1=cellSS(ii); % Independent Group
	resultdata{ii,1}=ii; % set id

	% ****************
	% Make Target-Group
	% ****************
	api=ArgData.APIInfo.Stat{2}; % 2nd API : Grouping
	targetSS=feval(api.fcn,'execute',cellSS1,ArgData.(api.fld));

	%-----
	%- Averaging
	%-----
	if isfield(ArgData,'Averaging_Tag')
		for k=1:length(targetSS)
			%tg=strmatch(ArgData.Averaging_Tag,targetSS{k}.Header);
			tg=strmatch(ArgData.Averaging_Tag,targetSS{k}.Header,'exact'); %- bug fix 2012-08-29 TK
			tmpList=targetSS{k}.SummarizedKey(:,tg);

			%-------------------------------------
			if isnumeric(cell2mat(tmpList))
				for ktmp=1:length(tmpList)
					tmpList(ktmp)={num2str(tmpList{ktmp})};
				end
			end
			%--- bug fix 2012-08-29 TK  ---------

			tmpUQ=unique(tmpList);

			SData=[];
			SKey=[];
			for kk=1:length(tmpUQ)
				tg=strmatch(tmpUQ{kk},tmpList);%- identical tag's index
				%-check
				flag=0;
				sz=size(targetSS{k}.SummarizedData{tg(1),1});
				for kkk=1:length(tg)
					sz1=size(targetSS{k}.SummarizedData{tg(kkk),1});
					if all(sz~=sz1)
						flag=flag+1;
					end
				end
				if flag>0
					warndlg(sprintf('data size is different.[Averaging]\n%s',C__FILE__LINE__CHAR));
				end
				%-------
				d=targetSS{k}.SummarizedData{tg(1),1};
				d(:,targetSS{k}.SummarizedData{tg(1),2}>=1,:)=0;%-flag
				for kkk=2:length(tg)
					tmp=targetSS{k}.SummarizedData{tg(kkk),1};
					tmp(:,targetSS{k}.SummarizedData{tg(kkk),2}>=1,:)=0;%-flag
					d=d+tmp;
				end
				d=d / length(tg);
				SData{kk,1}=d;
				SData{kk,2}=0;
				SKey{kk,1}=targetSS{k}.SummarizedKey{tg(1),:};
			end
			targetSS{k}.SummarizedData=SData;
			targetSS{k}.SummarizedKey=SKey;
		end
	end
	%----
	
  % ***********************
  % Check Number of Group
  % ***********************
  ngroup=length(targetSS);
  switch ArgData.TTest.mode
    case 'OneSample'
      if (ngroup<1)
        % next..
        resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));
        disp(sprintf('[E% 4d] No enough goup.',ii));
        continue;
      end
      if (ngroup>1)
        disp(sprintf('[E% 4d] Ignore 2nd goup.',ii));
        commandwindow;
        ngroup=1;
      end
    case 'TwoSample'
      if (ngroup<2)
        % next..
        resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));
        disp(sprintf('[E% 4d] No enough goup.',ii));
        continue;
      end
      if (ngroup>2)
        disp(sprintf('[W% 4d] Ignore 3rd goup.',ii));
        commandwindow;
        ngroup=2;
      end
  end

  % ***********************
  % Get Independent key
  % ***********************
  for jj=j0:je
    try
      resultdata{ii,jj}=targetSS{1}.(indepkey{jj-j0+1});
    catch
      resultdata{ii,jj}='ERROR';
    end
  end

  % ***********************
  % Get Group & Check
  % ***********************
  tmpidx=ginfostidx;
  isNormalDist=true;
  x=cell([1,ngroup]);
  x0=x;
  for jj=1:ngroup
    try
      x{jj}=P3R2_API_SSTools('expand2data',targetSS{jj});
    catch
      resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));
      disp(sprintf('[E% 4d] Can not Expand Group.',ii));
      disp(['      ' lasterr]);
      continue;
	end
	x0{jj}=x{jj};
	%x{jj}=POTATo_sub_FiveNumberSummaries(x{jj},'Quartile');
	x{jj}=POTATo_sub_FiveNumberSummaries(x{jj},'ret_ol2');
	
    resultdata{ii,tmpidx}=length(x{jj});
    
    % ****************
    % Lilliefors-Test
    % ****************
    % null hypothesis : sample in vector x{jj} 
    %                   comes form a distribution in the normal family.
    try
      % TODO: ?? p & tail ... (ok??)
      [lh, lp]=lillietest(x{jj});
      if lh==1
        isNormalDist=false;
      end
    catch
      lh=NaN;lp=NaN;
      if (ii==1) && (jj==1)
        disp('[W] no statistic toolbox : ignore lillieforce-test');
      end
    end
    resultdata{ii,tmpidx+1}=lh;
    resultdata{ii,tmpidx+2}=lp;
    tmpidx=tmpidx+3;
  end
	
  if (isNormalDist==false)
		resultdata{ii,2} = '(?)';
		%resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));		
    %disp(sprintf('[W% 4d] the sample donot come fron a norma distribution.',ii));
    %continue;
	else
		resultdata{ii,2} = 'normal';
    
  end
  
  %=====  
  setappdata(dataSSViewFigHnd,sprintf('data_x%d',ii),x0);
  set(A.handles.ppm_tagNameexe_P3R2F_ttest,'value',ii);
  Callback_dataSSViewFig(A.handles.figure1,A.handles.ppm_tagNameexe_P3R2F_ttest);
  %=====
  X{ii}.x0=x0;
  X{ii}.x=x;
    
  % Execute T-Test
  % TODO: non statistics toolbox version
  switch ArgData.TTest.mode
    case 'OneSample'
      % ***********************
      % One-Sample T-Test
      % ***********************
      %resulthead={'id', 'h','p' 'n1' , 'l-h1','l-p1'};
			
			if isNormalDist
				%===============================
				%= statistics for samples come from normal distribution
				%===============================
				try
					[h,p]=ttest(x{1},0,alpha,tail); % mean value is 0?
				catch
					h=NaN;p=NaN;
				end
				resultdata{ii,3}=h;
				resultdata{ii,4}=p;
				
			else
				%===============================
				%= statistics for samples do NOT come from normal distribution
				%===============================
				try
					[p,h]=signrank(x{1},0,'alpha',alpha); % mean value is 0?
				catch
					h=NaN;p=NaN;
				end
				resultdata{ii,3}=h;
				resultdata{ii,4}=p;				
			end
			
    case 'TwoSample'
      if ArgData.TTest.paired
        % ***********************
        % Two-Sample Paired T-Test
        % ***********************
        if length(x{1}) ~= length(x{2})
          resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));
          disp(sprintf('[E% 4d] Length of samples must be same.',ii));
          continue;
        end
        tmp=x{1}-x{2};
        try
          [h,p]=ttest(tmp,0,alpha,tail);
        catch
          h=NaN;p=NaN;
        end
        resultdata{ii,2}=h;
        resultdata{ii,3}=p;
      else
        % ***********************
        % Two-Sample Not-Paired T-Test
        % ***********************
        % F-Test
        try
          % TODO: ?? p & tail ... (ok??)
          [h,p]=vartest2(x{1},x{2});
        catch
          h=NaN;p=NaN;
        end
        resultdata{ii,4}=h;
        resultdata{ii,5}=p;
        % T-Test
        try
          if (h==1)
            % not equal
            [h,p]=ttest2(x{1},x{2},alpha,tail,'unequal');
          else
            % equal;
            [h,p]=ttest2(x{1},x{2},alpha,tail,'equal');
          end
        catch
          h=NaN;p=NaN;
        end
        resultdata{ii,2}=h;
        resultdata{ii,3}=p;
      end
    otherwise
  end
  % *********************** 
  % Update result
  % *********************** 
  resultstr{end+1}=getResultStr(resulthead,resultdata(ii,:));
  if 0
    % first, but not natural
    if mod(ii,30)==0
      set(hs.lbx_result,'String',resultstr,'Value',length(resultstr));
      drawnow;
    end
  else
    % slow, but natural
    set(hs.lbx_result,'String',resultstr,'Value',length(resultstr));
    %set(hs.lbx_result,'ListboxTop',1+fix(length(resultstr)/30)*30);
    drawnow;
  end
end

result.data = resultdata;
result.header = resulthead;

set(hs.lbx_result,'String',resultstr,...
  'ListboxTop',1+fix(length(resultstr)/30)*30);
drawnow;
Res.result.Text=resultdata;
Res.result.tag=resulthead;
Res.X=X;
assignin('base','Res',Res);


function Callback_dataSSViewFig(varargin)
if nargin>0
	figH=varargin{1};
	objH=varargin{2};
else
	figH=gcf;
	objH=gcbo;
end

val=get(objH,'value');
x=getappdata(figH,sprintf('data_x%d',val));
x1=POTATo_sub_FiveNumberSummaries(cell2mat(x),'ret_olall');
subplot(2,2,1);cla;plot(x1,'.');
subplot(2,2,3);cla;hist(x1);%-DEBUG CODE
subplot(1,2,2);cla;
R=P3_subFiveNumberSummaries(cell2mat(x),gca);
title(sprintf('N=%d  ( OL1:%d  OL2:%d )',length(cell2mat(x)),length(R.outlier1),length(R.outlier2)));

	

function str = getFormedUnitStr(s)
spacer = repmat(' ',[1 20]);
if isempty(s)
	s=[' --- ' spacer];
elseif ischar(s)
	s=[s spacer];	
elseif (fix(s)-s)==0
	s=[sprintf('%5d',s) spacer];
else
	s=[sprintf('%5.4f',s) spacer];
end
str = sprintf('|%s',s(1:10));

function str = getFormedSeparator(resulthead)
str = repmat(['+' repmat('-',[1 10])],[1 length(resulthead)]);

function localstr = getHeaderStr(resulthead)
n=length(resulthead);
localstr='';
for k=1:n
	localstr = [localstr getFormedUnitStr([' ' resulthead{k}])];
end
	
function localstr=getResultStr(resulthead,resultdata)
% Make resultdata to String
n=length(resulthead);
localstr='';
for ii=1:n
	localstr = [localstr getFormedUnitStr(resultdata{ii})];
%   switch resulthead{ii}
%     otherwise
%       % Nornal 
%       if isempty(resultdata{ii})
%         % Unset value (not calculate)
%         localstr=[localstr ' --- '];
%       else
%         % for numeric
%         if isnumeric(resultdata{ii})
%           if round(resultdata{ii})==resultdata{ii}
%             % Integer
%             localstr=[localstr,sprintf('% 4d ',resultdata{ii})];
%           else
%             % Real
%             localstr=[localstr,sprintf('%4.2f ',resultdata{ii})];
%           end
%         else
%           try
%             % for string
%             localstr=[localstr,sprintf('%s',resultdata{ii})];
%           catch
%             % Mr misstta.
%             localstr=[localstr ' xxx '];
%           end
%         end
%       end
%   end
end


