function tss=osp_vao_TimeSereiseSetting(figh,curdata,reloadflag)
% To Select Time-SeriesSetting (Version 00 )
%
% Syntax :
%  tss = osp_vao_TimeSereiseSetting(figh,curdata,reloadflag);
%
%  (reload flag can be ignore (defalt = false);
%
%  figh    : Viewer II Figure-Handle
%  curdata : Viewer II Current Data


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



msg=nargchk(1,3,nargin);
if ~isempty(msg),error(msg); end

if nargin<3,
    reloadflag=false;
end
% There is Tss Setting ?
tss=getappdata(figh, 'TimeSereiseSettingVer00');
if ~isempty(tss) && ~reloadflag, return; end


%=====================
% Get Time-Series Data
%=====================
[hdata, data]=osp_LayoutViewerTool('getCurrentDataRaw',figh,curdata);
dsize =size(data); clear data;
if ~isstruct(hdata), return; end
if ~isfield(hdata,'TimeSeries'), return; end
tsd=fieldnames(hdata.TimeSeries);

if length(dsize)==3,
  AssignList0 = {'Time','Channel','Kind'};
elseif length(dsize)==4,
  AssignList0 = {'Block', 'Time','Channel','Kind'};
else,
  warning('Un - Defined Data-Type');
  return;
end

%-- Data Check --
TimeSeriesData=[]; 
for itsd=1:length(tsd),
  mydata=getfield(hdata.TimeSeries,tsd{itsd});
  % Check Format 
  if ~isstruct(mydata) || ...
	~isfield(mydata,'Data') || ...
	~isfield(mydata,'TimeAxis'),
    msg={'OSP Warning : Ignore Following Time-Series ', ...
	 ' :: OUT-OF-FORMAT in this version'}
    warndlg(msg);
    continue;
  end
  if isempty(TimeSeriesData),
    TimeSeriesData = struct( tsd{itsd},    mydata);
  else,
    TimeSeriesData = setfield(TimeSeriesData, tsd{itsd}, mydata);
  end 
end

%==========================
% Time Series Setting init:
%==========================
% Version 00
tss0.ver=0; % Version
tss0.TimeSeriesName=fieldnames(TimeSeriesData); % Data
tss0.TimeSeriesData=struct2cell(TimeSeriesData); % Data
tss0.Selected      = 1; % Selected Data
tss0.DataFunction  = '';
tss0.LinePropList  = {};

% No Effective Data
if isempty(TimeSeriesData), return; end

%=====================
% Input GUI
%=====================
f=figure('menuBar','none','Units','Characters');
posf = get(f,'Position');

set(f,'Units','Characters');
p=get(f,'Position');
p(4)=3*4;set(f,'Position',p);

pid=1; % Page Number
pidh=uicontrol('Visible','off','UserData',1);
nexth=uicontrol('Units','Normalized', ...
		'Position', [0.6, 0.01, 0.3, 0.2], ...
		'String', 'Next', ...
		'UserData', pidh, ...
		'Callback', ...
		['pid=get(get(gcbo,''UserData''),''UserData'');', ...
		 'set(get(gcbo,''UserData''),''UserData'',pid+1);']);
backh=uicontrol('Units','Normalized', ...
		'Position', [0.2, 0.01, 0.3, 0.2], ...
		'String', 'Back', ...
		'UserData', pidh, ...
		'Callback', ...
		['pid=get(get(gcbo,''UserData''),''UserData'');', ...
		 'set(get(gcbo,''UserData''),''UserData'',pid-1);']);

% Wizard Loop
while pid>=1,
  pid0 = pid;
  switch pid,
   case 1,
    % Selecte Confine Data
    set(nexth,'Visible','on','String','Next');
    set(backh,'Visible','off');

    hs(1)=uicontrol('Units','Normalized', ...
		    'Style','Text', ...
            'HorizontalAlignment','left', ...
		    'Position', [0.1, 0.7, 0.8, 0.2], ...
		    'String', 'Plot : Time-Series Data is ');
    hs(2)=uicontrol('Units','Normalized', ...
		    'Style','Popupmenu', ...
		    'Position', [0.2, 0.5, 0.6, 0.2], ...
		    'String', tss0.TimeSeriesName, ...
		    'Value', tss0.Selected);
   case 2,
    % Select View Data (Asine Data)
    set(nexth,'Visible','on','String','OK');
    set(backh,'Visible','on');
    % --> Setting ::
    mydata = tss0.TimeSeriesData{tss0.Selected};
    sz=size(mydata.Data);

    % Dimension Loop
    % GetData
    clear tdset;
    wk0.Name = 'Untitled';
    wk0.val  = 1;
    wk0.AssignList={'FreeFormat'};
    wk0.String = '1';
    wk=wk0;
    
    % AssingList0 = {'Time','Channel','Kind'};
    for did=1:length(sz),
        wk(did)=wk0;
        if isfield(mydata,'AxisTag') && ...
                length(mydata.AxisTag)>=did
            wk(did).Name=mydata.AxisTag{did};
        end
        % if Time Axis : Fix
        if mydata.TimeAxis(1)==did,
            wk(did).Name='Time';
            wk(did).AssignList={'Time'};
            continue;
        end
        
        dimok=find(dsize==sz(did));
        if ~isempty(dimok),
            wk(did).val=2;
            a = find(strcmpi(AssignList0{dimok}, mydata.AxisTag{did}));
            if isempty(a), wk0.val=a(1)+1; end
            wk(did).AssignList={wk(did).AssignList{1}, ...
                    AssignList0{dimok}};
        end
    end

    
    hs(1)=uicontrol('Style','PopupMenu',...
		    'Units','Normalized', ...
		    'Position', [0.1, 0.7, 0.8, 0.2], ...
		    'String' , {wk.Name}, ...
		    'Value', 1, ...
		    'Callback', ...
		    ['data= get(gcbo,''UserData'');' ...
		     'vl  = get(gcbo,''Value'');' ...
		     'hs  = data.hs;' ...
		     'wk  = data.wk(vl);' ...
		     'set(hs(2), ' ...
		     '   ''Value'',  wk.val, ' ...
		     '   ''String'', wk.AssignList);' ...
		     'if ' ...
		     '   strcmp(wk.AssignList(wk.val), ' ...
		     '          ''FreeFormat''),' ...
		     '   set(hs(3), ' ...
		     '      ''String'', wk.String, ' ...
		     '      ''Visible'',''on'');' ...
		     'else,' ...
		     '   set(hs(3), ' ...
		     '      ''Visible'',''off'');' ...
		     'end;']);
    % Callback : Save (Pop up )
    hs(2) = uicontrol('Style','PopupMenu',...
		      'Units','Normalized', ...
		      'Position', [0.1, 0.4, 0.3, 0.2], ...
		      'Value', wk(1).val, ...
		      'String',wk(1).AssignList, ...
		      'Callback', ...
		      ['hs  =get(gcbo,''UserData''); ' ...
		       'data= get(hs(1),''UserData'');' ...
		       'vl  = get(hs(1),''Value'');' ...
		       'wk  = data.wk(vl); ' ...
		       'wk.val =get(hs(2),''Value''); ' ...
		       'if ' ...
		       '   strcmp(wk.AssignList(wk.val), ' ...
		       '          ''FreeFormat''),' ...
		       '   set(hs(3), ' ...
		       '      ''String'', wk.String, ' ...
		       '      ''Visible'',''on'');' ...
		       'else,' ...
		       '   set(hs(3), ' ...
		       '      ''Visible'',''off'');' ...
		       'end;' ...
		       'data.wk(vl)=wk;' ...
		       'set(hs(1),''UserData'',data);']);
    % Edit Change String
    hs(3) = uicontrol('Style', 'edit', ...
		      'Units','Normalized', ...
		      'Position', [0.5, 0.4, 0.5, 0.2], ...
		      'String', wk(1).String, ...
		      'Visible', 'off', ...
		      'Callback', ...
		      ['hs  =get(gcbo,''UserData''); ' ...
		       'data= get(hs(1),''UserData'');' ...
		       'vl  = get(hs(1),''Value'');' ...
		       'data.wk(vl).String=' ...
		       '   get(hs(3), ''String'');' ...
		       'set(hs(1),''UserData'',data);']);
    
    if strcmp(wk(1).AssignList(wk(1).val),'FreeFormat'),
      set(hs(3), 'Visible', 'on');
    end
    
    datax.wk=wk;
    datax.hs=hs;
    set(hs(1),'UserData',datax);
    set(hs(2),'UserData',hs);
    set(hs(3),'UserData',hs);
    
   otherwise, % Breake!
    errordlg('Unknow Page ID');
    pid=-1; break;
  end

  waitfor(pidh,'UserData');
  if ishandle(pidh),
    pid=get(pidh,'UserData');
  else,
    pid=-1;
  end

  % Get Data & Delete
  switch pid0,
   case 1,
    % Selecte Confine Data
    tss0.Selected= get(hs(2),'Value');
    try,
        delete(hs);hs=[];
    end
   case 2,
    wk = get(hs(1),'UserData');
    try,
        delete(hs); hs=[];
    end
    if pid~=3, continue; end
    wk = wk.wk;
    tmp='data(';
    for did=1:length(wk)
      as = wk(did).AssignList{wk(did).val};
      switch as,
       case {'FreeFormat'},
	tmp = [tmp wk(did).String ','];
       case {'Block'},
	tmp = [tmp 'curdata.bid0,'];
       case {'Time'}, 
	tmp = [tmp 't0,'];
       case {'Channel'}, 
	tmp = [tmp 'curdata.ch(1),'];
       case {'Kind'},
	tmp = [tmp 'curdata.kind(1),'];
      end

    end
    tmp(end)=')';tmp(end+1)=';';
    tss0.DataFunction    = tmp;
    break;
   otherwise, % Breake!
    errordlg('Unknow Page ID');
    pid=-1; break;
  end
end

if ishandle(f), delete(f);end
% Error Check
if pid<0,
  tss=[]; 
  return;
end

%===================
% Set Data & Return;
%===================
setappdata(figh, 'TimeSereiseSettingVer00',tss0);
tss=tss0;
