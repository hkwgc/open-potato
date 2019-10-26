function varargout=P3R2_API_groupingByKey(fcn,varargin)
	% Statistical Test :: Key SElect API
	
	% == History ==
	%  2011.02.03 : New!!
	%  2011.04.26 : Add Modify Button.
	
	%##########################################################################
	% Launcher
	%##########################################################################
	if nargin==0, fcn='help'; end
	
	switch fcn
		case {'CreateGUI',...
				'Activate','Suspend',...
				'UpdateRequest',...
				'MakeArgData','SetArgData',...
				'execute',...
				'psb_addkey_Callback',...
				'psb_removekey_Callback',...
				'psb_Modify_Callback',...
				'psb_info_Callback'}
			if nargout,
				[varargout{1:nargout}] = feval(fcn, varargin{:});
			else
				feval(fcn, varargin{:});
			end
		case {'myhandles','psb_Callback0'}
			% for debug
			disp('Debug Path');
			disp(C__FILE__LINE__CHAR);
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
function mydata=createMydata(hs,tagname)
	% Get mydata
	%##########################################################################
	mydata.handle  = hs.(mytag(tagname,5)); % Listbox is most important
	mydata.tagname = tagname;
	mydata.fcn     = mfilename;    % Function-Name
	%##########################################################################
function mydata=createMydata2(hs,h)
	% Get mydata
	%##########################################################################
	tagname=get(h,'Tag');
	tagname(1:9)=[];
	mydata=createMydata(hs,tagname);
	
	%##########################################################################
	% GUI Control
	%##########################################################################
function tag=mytag(tagname,id)
	% Tool : make unique tagname.
	tag=['R2apiGK' num2str(id) '_' tagname];
function h=myhandle(hs,h0,id)
	% Tool : get handle
	tg=get(h0,'Tag');
	tg(8)=num2str(id);
	h=hs.(tg);
	
	%==========================================================================
function [hs, mydata]=CreateGUI(hs,tagname,pos,APIdata)
	% Create Related GUI
	%==========================================================================
	error(nargchk(4, 4, nargin, 'struct'));
	
	% Make GUI
	% Position --
	pos0=pos; % start
	ix=1;iy=1;
	x1=pos(3)-2*ix; x2=(pos(3)-4*ix)/3;
	y1=20; y2=pos(4)-4*iy-2*y1;
	
	% Other Prop
	prop={'Units','pixels','Visible','off'};
	c=get(hs.figure1,'Color');
	prop_b={'style','pushbutton',prop{:}};
	
	pos0(1)=pos(1)+ix;
	pos0(3)=x1;
	pos0(2)=pos(2)+pos(4)-y1-iy-3;
	pos0(4)=y1;
	newhandles=[];
	%- - - -  - - - - -
	% Title
	%- - - -  - - - - -
	tag=mytag(tagname,1);
	newhandles(end+1)=uicontrol(hs.figure1,prop{:},...
		'TAG',tag,...
		'HorizontalAlignment','left',...
		'backgroundcolor',c,...
		'style','text',...
		'Position',pos0);
	hs.(tag)=newhandles(end);
	
	% is there Default Value?
	if isfield(APIdata,'Title')
		set(hs.(tag),'String',APIdata.Title);
	else
		set(hs.(tag),'String','Key-Selector');
	end
	
	%- - - -  - - - - -
	% Push-Buttons
	%- - - -  - - - - -
	pos0(2)=pos0(2)-y1-iy+3;
	pos0(3)=x2;
	tag=mytag(tagname,2);
	newhandles(end+1)=uicontrol(hs.figure1,prop_b{:},...
		'TAG',tag,...
		'Position',pos0,...
		'String','Add',...
		'Callback',[mfilename '(''psb_addkey_Callback'',gcbo);']);
	hs.(tag)=newhandles(end);
	
	pos0(1)=pos0(1)+ix+pos0(3);
	tag=mytag(tagname,3);
	newhandles(end+1)=uicontrol(hs.figure1,prop_b{:},...
		'TAG',tag,...
		'Position',pos0,...
		'String','Remove',...
		'Callback',[mfilename '(''psb_removekey_Callback'',gcbo);']);
	hs.(tag)=newhandles(end);
	
	pos0(1)=pos0(1)+ix+pos0(3);
	tag=mytag(tagname,4);
	newhandles(end+1)=uicontrol(hs.figure1,prop_b{:},...
		'TAG',tag,...
		'Position',pos0,...
		'String','Info',...
		'Enable','off',...
		'UserData',APIdata,...
		'Callback',[mfilename '(''psb_info_Callback'',gcbo);']);
	hs.(tag)=newhandles(end);
	
	try
		if 0%feval(APIdata.Upper,'enableInfoButton')
			set(hs.(tag),'Enable','on');
		else
			% add 2011.04.25
			tag=mytag(tagname,6);
			newhandles(end+1)=uicontrol(hs.figure1,prop_b{:},...
				'TAG',tag,...
				'Position',pos0,...
				'String','Modify',...
				'Callback',[mfilename '(''psb_Modify_Callback'',gcbo);']);
			hs.(tag)=newhandles(end);
			
		end
	catch
		% do nothing
	end
	
	%- - - -  - - - - -
	% Listbox
	%- - - -  - - - - -
	pos0(1)=pos(1)+ix;
	pos0(2)=pos0(2)-y2-iy;
	pos0(3)=x1;
	pos0(4)=y2;
	tag=mytag(tagname,5);
	newhandles(end+1)=uicontrol(hs.figure1,prop{:},...
		'style','listbox',...
		'backgroundcolor',[1 1 1],...
		'TAG',tag,...
		'Position',pos0,...
		'String','No Group');
	hs.(tag)=newhandles(end);
	
	if isfield(APIdata,'PRMs')
		fn=fieldnames(APIdata.PRMs);
		for k=1:length(fn);
			set(newhandles,fn{k},APIdata.PRMs.(fn{k}));
		end
	end			
	
	% make data
	mydata=createMydata(hs,tagname);
	
	% Update String
	%==========================================================================
function h=myhandles(hs,tagname)
	% My Handle List
	%==========================================================================
	h=zeros([1,5]);
	for i=1:6
		h(i)=[hs.(mytag(tagname,i))];
	end
	
	%==========================================================================
function h=Activate(hs,mydata)
	% My GUI Visible On
	%==========================================================================
	h=myhandles(hs,mydata.tagname);
	APIdata=get(h(4),'UserData');
	try
		if ~feval(APIdata.Upper,'enableInfoButton')
			h(4)=[];
		else
			h(6)=[];
		end
	catch
	end
	set(h,'Visible','on');
	
	%==========================================================================
function h=Suspend(hs,mydata)
	% My GUI Visible Off
	%==========================================================================
	h=myhandles(hs,mydata.tagname);
	set(h,'Visible','off');
	
	%##########################################################################
	% Execution
	%##########################################################################
	%==========================================================================
function Data=UpdateRequest(mydat,Data)
	% Update relational-GUI.
	%  if need Output-Function... too late
	% Input :
	%     mydat : return-value of CreateGUI
	%               (See alos createMyData)
	%     Data  : Cell of Real-Part of Summary-Statistics Data
	%==========================================================================
	h=mydat.handle;hs=guidata(h);
	
	h2=myhandle(hs,h,2); % Add
	if isempty(Data)
		set(h2,'Enable','off');
	else
		set(h2,'Enable','on');
	end
	if ~iscell(Data),Data={Data};end
	
	if 0
		% get Key-List
		ngroup=length(Data);
		keys=datakeys;
		for ii=1:ngroup
			keys=union(keys,Data{ii}.Header);
		end
	end
	if 0
		% Remove bad-key
		h5=myhandle(hs,h,5); % Listbox
		gd=get(h5,'UserData');
		v=get(h5,'Value');
		g={};
		for ii=1:length(gd)
			g{end+1}=gd{ii}.Name;
		end
		if v<length(g), v=length(g);end
		if isempty(g)
			set(h5,'Value',1,'String','No Keys','UserData',[]);
		else
			set(h5,'Value',v,'String',g,'UserData',gd);
		end
	end
	
	%============================
	% No out put?
	%============================
	if nargout<1,  return; end
	% Execution
	ArgData0=MakeArgData(mydat);
	Data=execute(Data,ArgData0);
	
	%==========================================================================
function cellSS=execute(cellSS0,ArgData0)
	% Update Cell of Summarized-Statistics Data
	%
	% cellSS={datar,...} : cell of Summarized Statistics
	%       datar: Real-part of Summarized Statistics.
	%       datar.nfile    : --(undefined here.)--
	%       datar.Anafiles : --(undefined here.)--
	%       datar.ExeData  : --(undefined here.)--
	%       datar.Header        : Cell Header of Summarized Data
	%       datar.SummarizedKey : Cell Summarized Data (Key-part)
	%       datar.SummarizedData: Cell Summarized Data (Data-part)
	% ArgData0: Data maid by sub-function MakeArgData
	%   that is...
	%   ArgData0.Group={gd, gd,...} : Cell of Group-Data-Struct
	%      gd.Name : Group-Name
	%      gd.inv  : bool : if true, use complement
	%      gd.keys : cell-of group-filter {gf, gf,..}
	%         gf.key     : name of key
	%         gf.type    : 'list' or 'equation'
	%       -- if gf type is 'list'  --
	%         gf.value   : list of selected value
	%       -- if gf type is 'equation'  --
	%         gf.equation : string for evaluation
	%==========================================================================
	
	n=length(ArgData0.Group);
	% Argument Check...
	if n==0
		cellSS=cellSS0;
		return; % do noting
	end
	
	%---------------------
	% Input : One SS Data
	%---------------------
	if length(cellSS0)>1
		try
			cellSS0=P3R2_API_SSTools('merge',cellSS0);
		catch
			% --> (TOOD) <--
			result.error='Too many Summarized Statistics Input';
			return;
		end
	end
	
	%------------------
	% Group - Loop
	%------------------
	cellSS={};
	for ii=1:n
		SS=cellSS0{1}; % Sumarized-Statistics
		gd=ArgData0.Group{ii};
		
		SS.GroupName=gd.Name; % save history...
		[shiboFlag, shiboFlagData]=getFlag(SS,gd.keys);
		nn=size(SS.SummarizedKey,1);
		if gd.inv
			for jj=1:nn
				if shiboFlag(jj)
					shiboFlag(jj)=false;
					shiboFlagData{jj}(:)=false;
				else
					shiboFlagData{jj}=~shiboFlagData{jj};
				end
			end
			shiboFlag(:)=false;
		end
		for jj=1:nn
			tmp=shiboFlagData{jj};
			tmp=all(all(tmp,1),3);
			SS.SummarizedData{jj,1}(shiboFlagData{jj})=[];
			SS.SummarizedData{jj,2}(tmp)=[];
			if isempty(SS.SummarizedData{jj,1})
				shiboFlag(jj)=true;
			end
		end
		
		SS.SummarizedKey(shiboFlag,:)=[];
		SS.SummarizedData(shiboFlag,:)=[];
		
		if isempty(SS), continue;end
		if isempty(SS.SummarizedKey), continue;end
		% save.
		cellSS{end+1}=SS;
	end % end of Group - loop
	
	
	%==========================================================================
function [shiboFlag, shiboFlagData]=getFlag(SS,keys)
	% Make delete flag
	%- modified by TK@CAL 2012-12-18
	%==========================================================================
	dkeys=ss_datakeys;
	nn=size(SS.SummarizedKey,1);
	% init flag
	shiboFlag     = false(1,nn);
	shiboFlagData = cell([1,nn]);
	for jj=1:nn
		shiboFlagData{jj}=false(size(SS.SummarizedData{jj}));
	end
	
	%-------------
	% Key Loop
	%-------------
	n=length(keys);
	conditionFlag=false(1,n);
	for k=1:n
		conditionFlag(k) = strcmpi(keys{k}.condition,'and');
	end
	
	for ii=1:n
		gf=keys{ii};
		% key
		kid=find(strcmp(dkeys,gf.key));
		if isempty(kid)
			mid=find(strcmp(SS.Header,gf.key));
			if isempty(mid), continue;end
			flag0=getflag_head(SS,gf,mid);
			if conditionFlag(ii)
				shiboFlag = shiboFlag | flag0; %- condition (displayed as AND but or eval)
			else
				shiboFlag = shiboFlag & flag0; %- additional select (displayed as OR but and eval)
			end
		else
			shiboFlagData0=getflag_data(SS,gf,kid);
			if conditionFlag(ii)
				for jj=1:nn
					shiboFlagData{jj}= shiboFlagData{jj} | shiboFlagData0{jj};
				end
			else
				for jj=1:nn
					shiboFlagData{jj}= shiboFlagData{jj} & shiboFlagData0{jj};
				end
			end
		end
	end % end of key loop
	
	%--------------------------------------------------------------------------
function  shiboFlag=getflag_head(SS,gf,mid)
	%--------------------------------------------------------------------------
	n=size(SS.SummarizedKey,1);
	shiboFlag=false(1,n);
	% SS filtering
	switch lower(gf.type)
		case 'list'
			% Header / List
			% remove non-listup data
			if isnumeric(gf.value)
				% Numeric
				for ii=1:n
					if ~any(SS.SummarizedKey{ii,mid}==gf.value)
						shiboFlag(ii)=true;
					end
				end
			else
				% Other
				for ii=1:n
					try
						if ~any(strcmp(SS.SummarizedKey(ii,mid),gf.value))
							shiboFlag(ii)=true;
						end
					catch
					end
				end
			end
		case 'equation'
			% Header / Equation
			% remove non-listup data
			if isnumeric(SS.SummarizedKey{1,mid})
				shiboFlag0=eval(['[SS.SummarizedKey{:,mid}] ' gf.equation]);
				shiboFlag(:)=~shiboFlag0(:);
			else
				try
					tmp=regexp(SS.SummarizedKey(:,mid),gf.equation);
					shiboFlag0=cellfun('isempty',tmp);
					shiboFlag(:)=shiboFlag0(:);
				catch
				end
			end
		otherwise
			error('Unknown type');
	end
	
	%--------------------------------------------------------------------------
function   shiboFlagData=getflag_data(SS,gf,kid)
	%--------------------------------------------------------------------------
	n=size(SS.SummarizedKey,1);
	
	shiboFlagData = cell([1,n]);
	for jj=1:n
		shiboFlagData{jj}=true(size(SS.SummarizedData{jj}));
	end
	
	if isfield(SS,gf.key)
		% SS filtering
		switch lower(gf.type)
			case 'list'
				% Data / List
				% remove non-listup data
				[SS.(gf.key),tmp]=intersect(SS.(gf.key),gf.value);
				for ii=1:n
					try
						switch kid
							case 1
								shiboFlagData{ii}(tmp,:,:)=false;
							case 2
								shiboFlagData{ii}(:,tmp,:)=false;
							case 3
								shiboFlagData{ii}(:,:,tmp)=false;
						end
					catch
						disp('[W] filter Error occru');
						dips(C__FILE__LINE__CHAR);
					end
				end
			case 'equation'
				% Header / Equation
				% remove non-listup data
				tmp=SS.(gf.key);  %#ok
				tmp=eval(['tmp ' gf.equation]);
				for ii=1:n
					try
						switch kid
							case 1
								shiboFlagData{ii}(tmp,:,:)=false;
							case 2
								shiboFlagData{ii}(:,tmp,:)=false;
							case 3
								shiboFlagData{ii}(:,:,tmp)=false;
						end
					catch
						disp('[W] filter Error occru');
						dips(C__FILE__LINE__CHAR);
					end
				end
			otherwise
				error('Unknown type');
		end
	else
		% SS filtering
		switch lower(gf.type)
			case 'list'
				% Data / List
				% remove non-listup data
				for ii=1:n
					tmp=gf.value;
					tmp(tmp>size(SS.SummarizedData{ii,1},kid))=[];
					try
						switch kid
							case 1
								shiboFlagData{ii}(tmp,:,:)=false;
							case 2
								shiboFlagData{ii}(:,tmp,:)=false;
							case 3
								shiboFlagData{ii}(:,:,tmp)=false;
						end
					catch
						disp('[W] filter Error occru');
						dips(C__FILE__LINE__CHAR);
					end
				end
			case 'equation'
				% Header / Equation
				% remove non-listup data
				for ii=1:n
					tmp=1:size(SS.SummarizedData{ii,1},kid); %#ok
					tmp=eval(['tmp ' gf.equation]);
					try
						switch kid
							case 1
								shiboFlagData{ii}(tmp,:,:)=false;
							case 2
								shiboFlagData{ii}(:,tmp,:)=false;
							case 3
								shiboFlagData{ii}(:,:,tmp)=false;
						end
					catch
						disp('[W] filter Error occru');
						dips(C__FILE__LINE__CHAR);
					end
				end
			otherwise
				error('Unknown type');
		end
	end
	
	%##########################################################################
	% GUI <--> ArgData
	%##########################################################################
	%==========================================================================
function ArgData0=MakeArgData(mydata)
	% Get Parameter's of 1st-Level-Analysis Execution
	%==========================================================================
	h=mydata.handle;hs=guidata(h);
	h5=myhandle(hs,h,5); % Listbox
	ArgData0.Group=get(h5,'UserData');
	
	%==========================================================================
function r=SetArgData(mydata,ArgData0)
	% Set Parameter's of 1st-Level-Analysis Execution
	%==========================================================================
	r=0;
	h=mydata.handle;
	hs=guidata(h);
	try
		gd=ArgData0.Group;
		g={};
		for ii=1:length(gd)
			g{end+1}=gd{ii}.Name;
		end
		h5=myhandle(hs,h,5);
		if isempty(g)
			set(h5,'Value',1,'String','No Keys','UserData',[]);
		else
			set(h5,'Value',1,'String',g,'UserData',gd);
		end
	catch
		r=1;
	end
	
	%##########################################################################
	% GUI Callbacks
	%##########################################################################
function str=getKeyString(gd)
	% Make List String
	%str=[gd.Name 'sample str'];
	str=gd.Name;
	
function psb_Modify_Callback(h)
	%
	hs=guidata(h);
	h5=myhandle(hs,h,5); % listbox
	v=get(h5,'Value');
	glist=get(h5,'String');
	gd=get(h5,'UserData');
	if length(gd)<v
		beep;
		return;
	end
	
	%--------------------------
	% Open Grouping GUI &
	%     get Add Group
	%--------------------------
	gh=P3R2_subAPI_groupingByKey; % private GUI
	ghs=guidata(gh);
	% setArguments
	msg=P3R2_subAPI_groupingByKey('setArgument',gh,hs,ghs,gd{v});
	if msg
		try
			errordlg(msg,'Add Group');
		catch
		end
		return;
	end
	
	if 1
		set(gh,'WindowStyle','modal')
	else
		disp('debug : non modal gui');
		disp(C__FILE__LINE__CHAR);
	end
	waitfor(gh,'Visible','off')
	
	if ~ishandle(gh)
		% closed
		return;
	end
	gdadd=get(ghs.psb_OK,'UserData');
	delete(ghs.figure1);
	if isempty(gdadd)
		% cancel
		return;
	end
	
	%--------------------------
	% Update Group-List
	%--------------------------
	h5=myhandle(hs,h,5); % Group-List
	gd{v}   =gdadd{1};
	glist{v}=getKeyString(gdadd{1});
	set(h5,'String',glist,'UserData',gd); % update
	return;
	
	
	%==========================================================================
function psb_addkey_Callback(h)
	% Add Key
	%==========================================================================
	hs=guidata(h);
	
	%--------------------------
	% Open Grouping GUI &
	%     get Add Group
	%--------------------------
	gh=P3R2_subAPI_groupingByKey; % private GUI
	ghs=guidata(gh);
	% setArguments
	msg=P3R2_subAPI_groupingByKey('setArgument',gh,hs,ghs);
	if msg
		try
			errordlg(msg,'Add Group');
		catch
		end
		return;
	end
	
	set(gh,'WindowStyle','modal')
	waitfor(gh,'Visible','off')
	
	if ~ishandle(gh)
		% closed
		return;
	end
	gdadd=get(ghs.psb_OK,'UserData');
	delete(ghs.figure1);
	if isempty(gdadd)
		% cancel
		return;
	end
	
	%--------------------------
	% Update Group-List
	%--------------------------
	h5=myhandle(hs,h,5); % Group-List
	glist=get(h5,'String'); % get default group-data-name
	gd=get(h5,'UserData'); % get default group-data
	if isempty(gd)
		glist={};
		gd=gdadd;
	else
		gd(end+1:end+length(gdadd))=gdadd(:);
	end
	for ii=1:length(gdadd)
		glist{end+1}=getKeyString(gdadd{ii});
	end
	set(h5,'String',glist,'UserData',gd); % update
	
	return;
	%==========================================================================
function psb_removekey_Callback(h)
	% Remove
	%==========================================================================
	hs=guidata(h);
	h5=myhandle(hs,h,5); % listbox
	v=get(h5,'Value');
	glist=get(h5,'String');
	gd=get(h5,'UserData');
	if length(gd)<v
		beep;
		return;
	end
	glist(v)=[];
	gd(v)=[];
	if length(gd)<v, v=length(gd);end
	if isempty(gd)
		set(h5,'Value',1,'String','No Group','UserData',[]);
	else
		set(h5,'Value',v,'String',glist,'UserData',gd);
	end
	return;
	
	%==========================================================================
function psb_info_Callback(h)
	% show information
	%==========================================================================
	hs=guidata(h);
	h5=h;                % me: info
	mydat=createMydata2(hs,h);
	APIdata=get(h5,'UserData');
	feval(APIdata.Upper,'InfoButton',APIdata,mydat);
	
	
	%##########################################################################
	% Old code ::: too complicate
	%  --- TODO: delete
	% even though, it might be faster than current one.
	%##########################################################################
	%==========================================================================
function SS=exe_normal(SS,keys)
	% !!! TODO: Delete !!!
	% Filterking
	%   each keys are or operation
	%      keys : cell-of group-filter {gf, gf,..}
	%         gf.key     : name of key
	%         gf.type    : 'list' or 'equation'
	%       -- if gf type is 'list'  --
	%         gf.value   : list of selected value
	%       -- if gf type is 'equation'  --
	%         gf.equation : string for evaluation
	%==========================================================================
	n=length(keys);
	dkeys=ss_datakeys;
	%-------------
	% Key Loop
	%-------------
	for ii=1:n
		gf=keys{ii};
		% key
		kid=find(strcmp(dkeys,gf.key));
		if isempty(kid)
			mid=find(strcmp(SS.Header,gf.key));
			if isempty(mid), continue;end
			SS=exe_normal_head(SS,gf,mid);
		else
			SS=exe_normal_data(SS,gf,kid);
		end
		if isempty(SS), break;end
		if isempty(SS.SummarizedKey), break;end
	end % end of key loop
	
	%--------------------------------------------------------------------------
function  SS=exe_normal_head(SS,gf,mid)
	%--------------------------------------------------------------------------
	n=size(SS.SummarizedKey,1);
	shiboFlag=false(1,n);
	% SS filtering
	switch lower(gf.type)
		case 'list'
			% Header / List
			% remove non-listup data
			if isnumeric(gf.value)
				% Numeric
				for ii=1:n
					if ~any(SS.SummarizedKey{ii,mid}==gf.value)
						shiboFlag(ii)=true;
					end
				end
			else
				% Other
				for ii=1:n
					try
						if ~any(strcmp(SS.SummarizedKey(ii,mid),gf.value))
							shiboFlag(ii)=true;
						end
					catch
					end
				end
			end
		case 'equation'
			% Header / Equation
			% remove non-listup data
			if isnumeric(SS.SummarizedKey{1,mid})
				shiboFlag=eval(['[SS.SummarizedKey{:,mid}] ' gf.equation]);
				shiboFlag=~shiboFlag;
			else
				try
					tmp=regexp(SS.SummarizedKey(:,mid),gf.equation);
					shiboFlag=cellfun('isempty',tmp);
				catch
				end
			end
		otherwise
			error('Unknown type');
	end
	SS.SummarizedKey(shiboFlag,:)=[];
	SS.SummarizedData(shiboFlag,:)=[];
	
	%--------------------------------------------------------------------------
function  SS=exe_normal_data(SS,gf,kid)
	%--------------------------------------------------------------------------
	n=size(SS.SummarizedKey,1);
	shiboFlag=false(1,n);
	if isfield(SS,gf.key)
		% SS filtering
		switch lower(gf.type)
			case 'list'
				% Data / List
				% remove non-listup data
				[SS.(gf.key),tmp]=intersect(SS.(gf.key),gf.value);
				if isempty(tmp)
					shiboFlag(:)=true;
				else
					for ii=1:n
						try
							switch kid
								case 1
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(tmp,:,:);
								case 2
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,tmp,:);
									SS.SummarizedData{ii,2}=SS.SummarizedData{ii,2}(:,tmp);
								case 3
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,:,tmp);
							end
						catch
						end
					end
				end
			case 'equation'
				% Header / Equation
				% remove non-listup data
				tmp=SS.(gf.key);  %#ok
				tmp=eval(['tmp ' gf.equation]);
				if all(tmp==false)
					shiboFlag(:)=true;
				else
					for ii=1:n
						try
							switch kid
								case 1
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(tmp,:,:);
								case 2
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,tmp,:);
									SS.SummarizedData{ii,2}=SS.SummarizedData{ii,2}(:,tmp);
								case 3
									SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,:,tmp);
							end
						catch
						end
					end
				end
			otherwise
				error('Unknown type');
		end
	else
		% SS filtering
		switch lower(gf.type)
			case 'list'
				% Data / List
				% remove non-listup data
				for ii=1:n
					tmp=gf.value;
					tmp(tmp>size(SS.SummarizedData{ii,1},kid))=[];
					%SS.(gf.key)=tmp;
					switch kid
						case 1
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(tmp,:,:);
						case 2
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,tmp,:);
							SS.SummarizedData{ii,2}=SS.SummarizedData{ii,2}(:,tmp);
						case 3
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,:,tmp);
					end
				end
			case 'equation'
				% Header / Equation
				% remove non-listup data
				for ii=1:n
					tmp=1:size(SS.SummarizedData{ii,1},kid); %#ok
					tmp=eval(['tmp ' gf.equation]);
					switch kid
						case 1
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(tmp,:,:);
						case 2
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,tmp,:);
							SS.SummarizedData{ii,2}=SS.SummarizedData{ii,2}(:,tmp);
						case 3
							SS.SummarizedData{ii,1}=SS.SummarizedData{ii,1}(:,:,tmp);
					end
				end
			otherwise
				error('Unknown type');
		end
	end
	SS.SummarizedKey(shiboFlag,:)=[];
	SS.SummarizedData(shiboFlag,:)=[];
