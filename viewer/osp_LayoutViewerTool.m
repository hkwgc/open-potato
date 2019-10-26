function varargout=osp_LayoutViewerTool(fnc,varargin),
% OSP Layout Viewer Tool
%
% --- Data I/O Function ---
% size=osp_LayoutViewerTool('getCurrentSize',curdata);
%   Get Current Data Size.
%     size=[block-size,time-size, channel-size, data-kind-size];
%     if current is continuous, block-size=0;
%
% [hdata,data]=osp_LayoutViewerTool('getCurrentData',figh,curdata);
%   get Current User-Data : when block Do "Block-Mean" for data
%
% [hdata,data]=osp_LayoutViewerTool('getCurrentDataRaw',figh,curdata);
%   get Current User-Data : (Not Modify)
%
% --- Tag setting ---
%  osp_LayoutViewerTool('setPathTag',handle,curdata);
%    set Tag (from path) to handle.
%
% --- Add menu ---
%  osp_LayoutViewerTool('addMenu_Edit_Axes0',curdata);
%     Add Edit-Axes-Menu to CurrentData menu.
%
%  osp_LayoutViewerTool('addMenu_Edit_Line',curdata);
%     Add Line to CurrentData menu.
%
% ---- Window Control ---
%
% -- Inner sub function --
% ------------------------
%  strt=osp_LayoutViewerTool('make_pathstr',pathidx_vector);
%      Make String of Path-Index
%      This function is to make TAG
%      Example:
%         str=osp_LayoutViewerTool('make_pathstr',[1:3]);
% ------------------------

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original author : Masanori Shoji
% create : 2006.04.05
% $Id: osp_LayoutViewerTool.m 395 2014-03-13 03:48:22Z katura7pro $
%
% Revision 1.4
%   Add I/O of Current Data Size
%   Window Control

if nargin==0,
	% to avoid compile error 
	% when OspHelp is out of MATLAB-path
	eval(['OspHelp ' mfilename]);return;
end

if nargout,
	[varargout{1:nargout}] = feval(fnc, varargin{:});
else,
	feval(fnc, varargin{:});
end

function s=info
s={mfilename};
s{end+1}='$Revision: 1.13 $';
s{end+1}='$Date: 2010/03/02 13:57:26 $';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mh=addMenu_EditAllAxis(mode,nowmenu,curdata),
% get path_Key and get Axes handle
tagkey=make_pathstr(curdata.path);
switch mode
    case 1
        mh=uimenu(nowmenu,'Label','Apply GCA X-axis to axes',...
            'Callback',...
            ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
            char(tagkey) ''');'...
            'osp_LayoutViewerTool(''addMenu_EditAxisProperty'',1,a0);']);
        mh=uimenu(nowmenu,'Label','Apply GCA Y-axis to axes',...
            'Callback',...
            ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
            char(tagkey) ''');'...
            'osp_LayoutViewerTool(''addMenu_EditAxisProperty'',2,a0);']);
        mh=uimenu(nowmenu,'Label','Apply GCA XY-axis to axes',...
            'Callback',...
            ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
            char(tagkey) ''');'...
            'osp_LayoutViewerTool(''addMenu_EditAxisProperty'',3,a0);']);
        mh=uimenu(nowmenu,'Label','Tight Axis',...
            'Separator','on',...
            'Callback',...
            ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
            char(tagkey) ''');'...
            'osp_LayoutViewerTool(''addMenu_EditAxisProperty'',4,a0);']);
        mh=uimenu(nowmenu,'Label','Reset Axis',...
            'Callback',...
            ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
            char(tagkey) ''');'...
            'osp_LayoutViewerTool(''addMenu_EditAxisProperty'',5,a0);']);
otherwise,
    warning(['Not Define Mode : ' str2num(mode) ' :' C__FILE__LINE__CHAR]);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axis Setting2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addMenu_EditAxisProperty(mode,a0),
% Change All Axis (get gca)
% mode == 1
%   X-Axis Only
% mode == 2
%   Y-Axis Only
% mode == 3
%   XY-Axis
% mode == 4
%   Tight
% mode == 5
%   Reset All Axis

switch mode
    case 1
% X-Axis Setting
        try,
            XX=get(gca,'Xlim');
            for idx=1:length(a0),
                set(a0(idx),'XLim',XX);
            end
        catch,
        end
% Y-Axis Setting
    case 2
        try,
            YY=get(gca,'Ylim');
            for idx=1:length(a0),
                set(a0(idx),'YLim',YY);
            end
        catch,
        end
% XY-Axis Setting
    case 3
        try,
            XX=get(gca,'Xlim');
            YY=get(gca,'Ylim');
            for idx=1:length(a0),
                set(a0(idx),'XLim',XX);
                set(a0(idx),'YLim',YY);
            end
        catch,
        end
% Tight
    case 4
        axis(a0(:),'tight');
% Reset
    case 5
        for idx=1:length(a0),
            set(a0(idx),'XLimMode','auto');
            set(a0(idx),'YLimMode','auto');
        end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axes Font Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addMenu_AxesFont(mode,gcbf),
% Add "Edit Connected Axes" Menu
% mode == 1
%   Axes Title Font Setting
% mode == 2
%   Axes Font Setting

a0=findobj(gcbf,'Type','Axes');
switch mode
    case 1
        try,
            a0=get(a0,'Title');
            a0=cell2mat(a0);
            s=uisetfont(a0(1));
            pn = fieldnames(s);
            vl = struct2cell(s);
            set(a0(:),pn',vl');
        catch,
        end
    case 2
        try,
            s=uisetfont(a0(1));
            pn = fieldnames(s);
            vl = struct2cell(s);
            set(a0(:),pn',vl');
        catch,
        end
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Menu Axes Title
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mh=addMenu_AxesTitle(curdata),
% Add "Edit Connected Axes" Menu
if ~isfield(curdata,'menu_current') || ~ishandle(curdata.menu_current)
  return;
end
tagkey=make_pathstr(curdata.path);

curdata.menu_current=uimenu(curdata.menu_current,...
  'Label','Ch Title Setting', ...
  'TAG', 'menu_chtitle');
mh=uimenu(curdata.menu_current,...
  'Label','Ch Label Visible', ...
  'TAG', 'menu_chtitle');
set(mh,'Checked','on');
set(mh,'Callback',...
    ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
    char(tagkey) ''');' ...
    'osp_LayoutViewerTool(''addMenu_AxesTitleSetting'',1,a0);'...
    ]);

mh=uimenu(curdata.menu_current,...
    'Label','Ch String Setting', ...
    'TAG', 'menu_chstring');
set(mh,'Callback',...
    ['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
    char(tagkey) ''');' ...
    'osp_LayoutViewerTool(''addMenu_AxesTitleSetting'',2,a0);'...
    ]);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VGC Axes Title Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addMenu_AxesTitleSetting(mode,a0),
% VGC Axes Title Setting
% mode == 1
%   Title Visible on/off
% mode == 2
%   Title Header String Setting
% else
%   not used

th=get(a0,'Title');
mth=[th{:}]';
switch mode
    case 1
        if (strcmp(get(gcbo,'Checked'),'off') == 1),
            set(gcbo,'Checked','on');
            set(mth,'Visible','on');
        elseif (strcmp(get(gcbo,'Checked'),'on') == 1),
            set(gcbo,'Checked','off');
            set(mth,'Visible','off');
        end
    case 2
        try,
            str=get(mth(1),'String');
            chptr=min(find(48 <= double(str) & double(str) <= 57));
            hdstr=str(1:chptr-1);
            hdstr=inputdlg({'Title Prefix:'},'Input Dialog',1,{hdstr});
            hdstr=hdstr{:};
            strcheck=find(48 <= double(hdstr) & double(hdstr) <= 57);
            if ~isempty(strcheck),
                errordlg('Please input [a-z], [A-Z] or Symbols.','Input Error!!');
            else,
                for idx=1:length(mth),
                    lpstr=get(mth(idx),'String');
                    set(mth(idx),'String',[hdstr,char(lpstr(chptr:end))]);
                end
            end
        catch,
        end
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Menu Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=addMenu_Edit_Axes0(curdata),
% Add "Edit Connected Axes" Menu
tagkey=make_pathstr(curdata.path);
h=uimenu(curdata.menu_current, ...
	'Label','Edit Connected &Axes',...
	'Callback', ...
	['a0=osp_LayoutViewerTool(''findAxes'',gcbf,''' ...
		char(tagkey) ''');' ...
		'propedit(a0);']);

function h=addMenu_Line(curdata),
% Add "Line" Menu
tagkey=make_pathstr(curdata.path);
h=uimenu(curdata.menu_current, ...
	'Label','&Line');
% --- Menu : Line ---
uimenu(h,'Label','Line &Color', ...
	'Callback',...
	['osp_LayoutViewerTool(''lineprop'', gcbf, ''' ...
		char(tagkey) ''', ''Color'', gca);']);
uimenu(h,'Label','Line &Style', ...
	'Callback',...
	['osp_LayoutViewerTool(''lineprop'', gcbf, ''' ...
		char(tagkey) ''', ''LineStyle'', gca);']);
uimenu(h,'Label','&Width', ...
	'Callback',...
	['osp_LayoutViewerTool(''lineprop'', gcbf, ''' ...
		char(tagkey) ''', ''LineWidth'', gca);']);
uimenu(h,'Label','&All', ...
	'Callback',...
	['osp_LayoutViewerTool(''lineprop'', gcbf, ''' ...
		char(tagkey) ''', ''All'', gca);'], ...
	'Separator','on');

function h=addMenu_Marker(curdata),
% Add "Marker" Menu
tagkey=make_pathstr(curdata.path);
h=uimenu(curdata.menu_current, ...
	'Label','&Marker');
% --- Menu : Marker ---
uimenu(h,'Label','&Marker', ...
	'Callback',...
	['osp_LayoutViewerTool(''MarkerProp'', gcbf, ''' ...
		char(tagkey) ''', ''Marker'', gca);']);
uimenu(h,'Label','&Edge Color', ...
	'Callback',...
	['osp_LayoutViewerTool(''MarkerProp'', gcbf, ''' ...
		char(tagkey) ''', ''MarkerEdgeColor'', gca);']);
uimenu(h,'Label','&Face Color', ...
	'Callback',...
	['osp_LayoutViewerTool(''MarkerProp'', gcbf, ''' ...
		char(tagkey) ''', ''MarkerFaceColor'', gca);']);
uimenu(h,'Label','&Size', ...
	'Callback',...
	['osp_LayoutViewerTool(''MarkerProp'', gcbf, ''' ...
		char(tagkey) ''', ''MarkerSize'', gca);']);
uimenu(h,'Label','&All', ...
	'Callback',...
	['osp_LayoutViewerTool(''MarkerProp'', gcbf, ''' ...
		char(tagkey) ''', ''All'', gca);'], ...
	'Separator','on');

function h=addMenu_Legend(curdata),
% Add "Legend" Menu
tagkey=make_pathstr(curdata.path);
h=uimenu(curdata.menu_current, ...
	'Label','Legend');
% --- Menu : Legend ---
uimenu(h,'Label','on', ...
	'Callback',...
	['osp_LayoutViewerTool(''Legend'', gcbf, ''' ...
		char(tagkey) ''', ''on'');']);
uimenu(h,'Label','off', ...
	'Callback',...
	['osp_LayoutViewerTool(''Legend'', gcbf, ''' ...
		char(tagkey) ''', ''off'');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Property Change Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lineprop(fig_h, key, prop, axs_h)
lh  = findLinePropObj(axs_h); % GCA plop
ax  = findAxes(fig_h,key);   % Selected Axes
fnc = @findLinePropObj;
switch lower(prop),
	case 'all',
		props={'EdgeColor','Color','LineStyle','LineWidth'};
	case 'color',
		props={'EdgeColor','Color'};
	otherwise,
		props={prop};
end

for idx=1:length(props),
	setProp(lh, ax, props, fnc);
end

function MarkerProp(fig_h, key, prop, axs_h)
% Set Marker Property
lh  = findobj(axs_h); % GCA plop
fnc = @findobj;
ax  = findAxes(fig_h,key);   % Selected Axes

switch lower(prop),
	case 'all',
		props={'Marker', 'MarkerEdgeColor', 'MarkerFaceColor', 'MarkerSize'};
	otherwise,
		props={prop};
end

for idx=1:length(props),
	setProp(lh, ax, props,fnc);
end

function setProp(lh, ax,props,fnc),
% lh    : Local-Handles ( Copy source )
% ax    : Target Axes
% props : Target Properties (Cell
% fnc   : pointer of original-findobj
Tags =get(lh,'Tag');  % Tag of Target Line
Types=get(lh,'Type'); % Type of Target Line(/patch?)
ntag=length(Tags); % Copy source Number

ax = ax(:)';
for iax=ax
	% get Target Handles
	lh2 = feval(fnc,iax);
	% Copy source TAGS ( Target TAGS)
	Tags2=get(lh2,'Tag');
	% Loop for Copy-Source-Number
	for idx=1:ntag,
		idx02=find(strcmp(Tags2,Tags(idx)));
		% Copy Target is exist
    for idx2=idx02(:)'
      if strcmp(get(lh2(idx2),'Type'),Types{idx}),
        for iprop=1:length(props),
          prop=props{iprop};
          try
            set(lh2(idx2),prop,get(lh(idx),prop));
          end
        end
      end
    end
  end
end

function Legend(fig_h, key,prop)
% Legend On/ Off
ax  = findAxes(fig_h,key);
if strcmpi(prop,'on'),
	tag_legend(ax,'Interpreter','none');
else,
	for idx=1:length(ax),
		legend(ax(idx),'off');
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Search Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ax = findAxes(fig_h,key)
% Search Axes from Key..
% Change key to tagkey
if ischar(key),
	tagkey=char(key);
elseif isnumeric(key),
	tagkey=make_pathstr(key);
elseif isstruct(key),
	error('not support key : Structure');
else,
	error('Undefined key ');
end

ax0  = findobj(fig_h, 'Type', 'axes');
% Tag Search
tags = get(ax0,'Tag');
idx  = strmatch(tagkey,tags);
ax  = ax0(idx);
return;

function lh = findLinePropObj(ax_h)
lh1=findobj(ax_h,'Type','line');
lh2=findobj(ax_h,'Type','patch');
lh =[lh1; lh2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path - Tag Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=================================
function setPathTag(handle,data),
% Set Tag ::: 
%=================================
if isstruct(data) && isfield(data,'path'),
	pidx=data.path;
elseif isnumeric(data),
	pidx=data(:)';
else,
	error('2nd Argument Error : Can not get Index of Axes.');
end
set(handle,'Tag',make_pathstr(pidx));

%=================================
function str=make_pathstr(path0)
% to make TAG in Layout View
%=================================
str='P';
path0=path0(:)';
for ip=path0,
    str = [str num2str(ip) '_'];
end
str(end)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data I/O Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=================================
function sz=getCurrentSize(curdata);
%   Get Current Data Size.
%     sz=[block-size,time-size, channel-size, data-kind-size];
%=================================
  switch lower(curdata.region)
   case 'continuous',
    sz=[0, curdata.csize];
   case 'block',
    sz=curdata.bsize;
   otherwise,
    error(['Unknown DataString : ' datastr]);
  end
%=================================
function curdata=setCurrentSize(figh,curdata);
%   Set Correct Current Data Size to curdata.
%     sz=[block-size,time-size, channel-size, data-kind-size];
%=================================
  switch lower(curdata.region)
   case 'continuous',
    cdata = getappdata(figh,'CDATA');
    curdata.cidxmax=length(cdata);
    if curdata.cidxmax<curdata.cid0,
      curdata.cid0=curdata.cidxmax;
    end
    curdata.csize  =csize(cdata{curdata.cid0});
   case 'block',
    bdata = getappdata(figh,'BDATA');
    curdata.bidmax= size(bdata,1);
    if curdata.bidxmax < curdata.bid0,
      curdata.bid0 = curdata.bidxmax;
    end
    curdata.bsize = size(bdata);
   otherwise,
    error(['Unknown DataString : ' datastr]);
  end


%=================================
function [hdata,data]=getCurrentData(figh,curdata)
% Get Current Data :: 
%   and Respahe (time, Channel, kind)
%=================================
data=[];
%curdata.region='continuous';
switch lower(curdata.region)
	case 'continuous',
		hdata = getappdata(figh,'CHDATA');
		if iscell(hdata),
			if length(curdata.cid0)<=length(hdata),
				hdata=hdata{curdata.cid0};
			else
				hdata=hdata{1};
			end
		end
		if nargout>=2,
			data  = getappdata(figh,'CDATA');
			if iscell(data),
				if length(curdata.cid0)<=length(data),
					data = data{curdata.cid0};
				else
					data = data{1};
				end
			end
		end
	case 'block',
		hdata = getappdata(figh,'BHDATA');
    if nargout>=2,
      if isfield(curdata,'stimkind')
				stimkind = curdata.stimkind;
      else
				stimkind = [];
      end
			
      if ~isfield(curdata,'flag') || ~isfield(curdata.flag,'MarkAveraging')
        %- (default) Averaging mode
        data = sub_MakeDataAveraging(hdata,stimkind,figh);
      elseif (isfield(curdata,'flag') && (isfield(curdata.flag,'MarkAveraging')) && curdata.flag.MarkAveraging)
        %- Averaging mode
				data = sub_MakeDataAveraging(hdata,stimkind,figh);
			else %- No-averaging mode
				data = getappdata(figh,'BDATA');
				% bugfix TK@CRL 21-Jan-2014
				%=== apply flags
				if size(data,1)<size(data,3)
					for k=1:size(data,1)%- loop Block
						data(k,:,hdata.flag(1,k,:)==1,:)=nan;
					end
				else
					for k=1:size(data,3)%- loop Ch
						data(hdata.flag(1,:,k)==1,:,k,:)=nan;
					end
				end
				%===
        % bugfix
        if length(stimkind)==1
          data=data(hdata.stimkind==stimkind,:,:,:);
        elseif length(stimkind)>=2
          data2=[];
          for ii=1:length(stimkind)
            data2=[data2;data(hdata.stimkind==stimkind(ii),:,:,:)];
          end
          data=data2;
        end
      end
    end
  case 'summary'
    hdata = getappdata(figh,'SSHDATA');
    data  = getappdata(figh,'SSDATA');
	otherwise
		error(['Unknown DataString : ' datastr]);
end
	
function [data]=sub_MakeDataAveraging(hdata,stimkind,figh)
if ~isempty(stimkind)
	try
		tmp=sprintf('%d', sort( stimkind ));
		appdname=sprintf('GrandAverage%s_VT',tmp);
	catch
		appdname='GrandAverage_VT';
	end
else
	appdname='GrandAverage_VT';
end

data  = getappdata(figh,appdname);

if isempty(data)
	data  = getappdata(figh,'BDATA');
	if strcmp(appdname,'GrandAverage_VT')
		data  = uc_blockmean(data,hdata);
	else
		data  = uc_blockmean(data,hdata,stimkind);
	end
	setappdata(figh,appdname,data);
end


function [hdata,data]=getCurrentDataRaw(figh,curdata)
% Get Current Data :: 
%   Not Modify
%=================================
data=[];
switch lower(curdata.region)
    case 'continuous',
        hdata = getappdata(figh,'CHDATA');
        if iscell(hdata),
	  if length(curdata.cid0)<=length(hdata),
	    hdata=hdata{curdata.cid0};
	  else,
	    hdata=hdata{1};
	  end
        end
	if nargout>=2,
	  data  = getappdata(figh,'CDATA');
	  if iscell(data),
            if length(curdata.cid0)<=length(data),
	      data = data{curdata.cid0};
            else,
	      data = data{1};
            end
	  end
	end
    case 'block',
        hdata = getappdata(figh,'BHDATA');
	if nargout>=2,
	  data  = getappdata(figh,'BDATA');
	end
 otherwise,
  error(['Unknown DataString : ' datastr]);
end
	
