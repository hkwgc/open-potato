function varargout = P3_ExtendedSearch(varargin)
% P3_EXTENDEDSEARCH M-file for P3_ExtendedSearch.fig
%      P3_EXTENDEDSEARCH, by itself, creates a new P3_EXTENDEDSEARCH or raises the existing
%      singleton*.
%
%      H = P3_EXTENDEDSEARCH returns the handle to a new P3_EXTENDEDSEARCH or the handle to
%      the existing singleton*.
%
%      P3_EXTENDEDSEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in P3_EXTENDEDSEARCH.M with the given input arguments.
%
%      P3_EXTENDEDSEARCH('Property','Value',...) creates a new P3_EXTENDEDSEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before P3_ExtendedSearch_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to P3_ExtendedSearch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 17-Jan-2011 15:37:39


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2008.03.25
% $Id: P3_ExtendedSearch.m 393 2014-02-03 02:19:23Z katura7pro $
%
% 2010.11:
%   * Bugfix (And Xor Not)
%   * Add Search-Key for Block (2010_2_RA06)
%
% 2011.01: Meeting 2010.12.07
%    * Close Control
%    * Key-popupmenu work in conjuction with POTATo's key-popupmenu


%##########################################################################
% Design
%##########################################################################
%
% ###################################
%  List of Apprication Data
% ###################################
%   "DataDefFcn"  :  Data Defined Function
%   "DataList"    :  Data List ( File List )
%   "SearchKey"   :  SearchKeys ( Structure of key & word)
%##########################################################################

% -- Open Main Controller --
% Check if OSP_Main Controller is opened
try
  isrun=OSP_DATA('GET','isPOTAToRunning');
catch
  isrun=false;
end
if ~isrun
  warndlg('Please Open P3 at First!','Cannot OPEN');
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @P3_ExtendedSearch_OpeningFcn, ...
  'gui_OutputFcn',  @P3_ExtendedSearch_OutputFcn, ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Window-Control Functions
%  1. Opening-Function
%  2. Output-Function
%  3. Close-Request/Delete Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function P3_ExtendedSearch_OpeningFcn(hObject, ev, handles, varargin) %#ok
% Open P3_EXTENDEDSEARCH
%  1. Transrate Varargin
%  2. Change Position
%  3. Load Data Correspond to pop_FilteType of P3
%==========================================================================

% try means that
try
  %------------------------------------
  % Output Setting : Handle of Figure
  %------------------------------------
  handles.output = hObject;
  guidata(hObject, handles);

  %---------------------------------------------
  %  1. Transrate Varargin
  %     ** Variable Argument Setting **
  %     In this version, there is nothing to do
  %---------------------------------------------
  for argid=2:2:length(varargin)
    prop = varargin{argid-1};
    val  = varargin{argid}; %#ok
    switch prop
      otherwise,
        error('Unknown Arguments');
    end
  end
  
  %---------------------------------------------
  %  2. Change Position & Color
  %---------------------------------------------
  try
    % Get P3 Handles
    pmh =OSP_DATA('GET','POTATOMAINHANDLE');
    pmhs=guidata(pmh);
    set(hObject,'Units','pixels');
    try
      p=get(hObject,'OuterPosition');
    catch
      p=get(hObject,'Position');
    end
    p00=p;
    % Modify Position
    set(pmhs.figure1,'Units','pixels');
    try
      p0=get(pmhs.figure1,'OuterPosition');
    catch
      p0=get(pmhs.figure1,'Position');
    end
    p(1)=max(0,p0(1)-p(3));
    p(2)=max(0,p0(2)+p0(4)-p(4));
    % Set Position
    try
      set(hObject,'OuterPosition',p);
    catch
      set(hObject,'Position',p);
    end
    %set(hObject,'Resize','on'); %?? figure...

    % Set Color
    c=get(pmhs.figure1,'Color');
    changeColor(hObject,c,handles);
  catch
    set(ud.figh,'Position',p00);
  end
  
  %--------------------------------------------------
  %  3. Load Data Correspond to pop_FilteType of P3
  %     Load Data Correspond to pop_FileType
  %--------------------------------------------------
  changeDataCategoly(hObject,'',handles);

catch
  errordlg([ 'In Extend Search Opening Function :' lasterr]);
end

%==========================================================================
function varargout = P3_ExtendedSearch_OutputFcn(hObject, eventdata, handles) %#ok
% Output is Figure-Handle  (See also Opening Fucntion)
%==========================================================================
try
  varargout{1} = handles.output;
catch
  varargout{1} = [];
end

%==========================================================================
function figure1_KeyPressFcn(h, e, hs) %#ok
% Key-Press Function
%   * Current :: Debug
%==========================================================================
currentkey=get(h,'CurrentKey');
switch currentkey
  case 'escape' % When escape Key Pushed
    % Delete GCF
    gui_buttonlock('unlock',h);
    delete(hObject)

  case 'home'   % When Home Key pushed
    % Main controller Open
    mc=OSP_DATA('GET','POTATOMAINHANDLE');
    figure(mc.handles.figure1);

  case 'h' % When Key push
    psb_Help_Callback(hs.psb_Help,[],hs);

  case 'f5'
    %%% temp : TODO setting method %%%
    search_and_refresh(hs)
end  % Switch CurrentKey



%==========================================================================
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok
% Close File
%==========================================================================
try
  pmh =OSP_DATA('GET','POTATOMAINHANDLE');
  pmhs=guidata(pmh);
  set(pmhs.menu_data_Selector,'Checked','on');
  POTATo('menu_data_Selector_Callback',pmhs.menu_data_Selector,[],pmhs);
catch
  delete(gcbf);
end

%==========================================================================
function figure1_CloseRequestFcn(h,ev,hs) %#ok
% Close Request
%==========================================================================
try
  pmh =OSP_DATA('GET','POTATOMAINHANDLE');
  as=getappdata(pmh,'AnalysisSTATE');
  switch as.mode
    case 54, % POTATo_win_Research_1st (Summary Stastistic Computation)
      errordlg(...
        {...
        '"Summary Stastistic Computation Status"',...
        '              might want "Extended-Search".'},'Close Error');
      return;
    otherwise
      delete(h);
  end
catch
  delete(h);
end

%==========================================================================
function psb_Close_Callback(h, ev, hs) %#ok
% Close File --> DeleteFcn will be called
%==========================================================================
figure1_CloseRequestFcn(hs.figure1,ev,hs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data-File Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_Reset_Callback(h, ev, hs)%#ok
changeDataCategoly(h,[],hs);

function changeDataCategoly(h,Category,hs) %#ok
% h : is not use
% Change Data-Categoly

%==========================================================================
% Get P3 Situation
%==========================================================================
% Get P3 Handle
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);

% Category Name-List
str=get(pmhs.pop_filetype,'String');
if ~isempty(Category)
  if isnumeric(Category)
    val=round(Category);
  else
    val=find(strcmp(Category,str));
  end
else
  % Default Value
  val=get(pmhs.pop_filetype,'Value');
end
if val>length(str),val=length(str);end

%==========================================================================
% Data Update
%==========================================================================
%----------------------------
% Update Data-Define-Function
%----------------------------
gui_buttonlock('lock',hs.figure1);
ddf=get(pmhs.pop_filetype,'UserData');
if length(ddf)>=val && exist(ddf{val},'file')
  fcn=eval(['@' ddf{val}]);
else
  if length(ddf)>=val
    error([' Not Defined Data-format.' ...
      ' Function ' ddf{val} ' is not exist.'...
      'Select another Data or Press Escape-Key.']);
  else
    % Close Extended Search
    %psb_Close_Callback(hs.psb_Close,[],hs);
    delete(hs.figure1);
    return;
    %     error([' Not Defined Data-format.' ...
    %       ' Function ------- is not exist.'...
    %       'Select another Data or Press Escape-Key.']);
  end
end
setappdata(hs.figure1,'DataDefFcn',ddf{val});
%-----------------------------
% Load DataList
%-----------------------------
data = feval(fcn,'loadlist');
if isempty(data)
  % helpdlg({'No Data in this Data type'},'External Search');
  return;
end
gui_buttonlock('unlock',hs.figure1);

%-----------------------------
% Reset File List
%-----------------------------
setappdata(hs.figure1,'DataList', data);

%-----------------------------
% Reset Search & Sort Key
%-----------------------------
P3_refresh(0); 
setappdata(hs.figure1,'SearchKeys', {});

% Search-Key Update
[keylist, searchKeyExpl]=feval(fcn,'getKeys'); %#ok
keylist=fieldnames(data); % Change KeyList::
set(hs.pop_SOkey,'Value', 1, 'String',keylist);       % search
set(hs.pop_SOkey, 'UserData',searchKeyExpl);
pop_SOkey_Callback(hs.pop_SOkey,[],hs,false);
rdb_SOand_Callback(hs.rdb_SOand,[],hs);

showSearchKey(hs); % Search-Option Update


%==========================================================================
function P3_refresh(data,fcn,hs)
% POTATo List Change
%==========================================================================
persistent mydata;
if isequal(data,1)
  if isempty(mydata)
    search_and_refresh(hs);return;
  end
  data=mydata; % No Search & Refresh (by pop_SOkey_Callback)
elseif isequal(data,0)
  % Initialize
  mydata=[];return;
else
  mydata=data;
end

% Get Main-Key
if isempty(data)
  % No data to Plot
  mkeylist.data={};
  mkeylist.str ={'No Match Files (dumy)'};
  ke='';
else
  % Reset File List
  mainkey = feval(fcn,'getIdentifierKey');
  mkeylist.data = {data.(mainkey)};   % Get main KeyList
  ke=get(hs.pop_SOkey,'String');
  if iscell(ke),ke=ke{get(hs.pop_SOkey,'Value')}; end
  kt=get(hs.txt_SOkeytype,'String');
  mkeylist.str = cell(size(data));
  switch lower(kt)
    case 'text'
      for idx=1:length(data)
        mkeylist.str{idx}=sprintf('%-40s : %s',data(idx).(mainkey),...
          data(idx).(ke));
      end
    case 'gender'
      for idx=1:length(data)
        if isequal(data(idx).(ke),0)
          mkeylist.str{idx}=sprintf('%-40s : Male',data(idx).(mainkey));
        else
          mkeylist.str{idx}=sprintf('%-40s : Female',data(idx).(mainkey));
        end
      end
    case 'numeric'
      for idx=1:length(data)
        if isequal(round(data(idx).(ke)),data(idx).(ke)),
          mkeylist.str{idx}=sprintf('%-40s : %d',data(idx).(mainkey),...
            round(data(idx).(ke)));
        else
          mkeylist.str{idx}=sprintf('%-40s : %f',data(idx).(mainkey),...
            data(idx).(ke));
        end
      end
    case 'date'
      if 1
        % Meeting on 2011.01.14: speed up 
        % when length(data)==67
        %    OLD-CODE :0.072 sec
        %    NEW-CODE :0.046 sec (TOTAL-TIME)
        % see also datestr
        d0=[data.(ke)];
        d0(~isfinite(d0))=0;
        tmstr=datestr(d0);
        for idx=1:length(data)
          mkeylist.str{idx}=sprintf('%-40s : %s',data(idx).(mainkey),tmstr(idx,:));
        end
      else
        for idx=1:length(data)
          mkeylist.str{idx}=sprintf('%-40s : %s',data(idx).(mainkey),...
            datestr(data(idx).(ke)));
        end
			end
		case {'textb','numericb'}
			for idx=1:length(data)
				mkeylist.str{idx}=sprintf('%-40s : %s',data(idx).(mainkey),...
					data(idx).(ke).Data{:});
      end
	
    otherwise
      for idx=1:length(data)
        mkeylist.str{idx}=sprintf('%-40s : ------',data(idx).(mainkey));
      end
  end
end
% P3 Update
pmh =OSP_DATA('GET','POTATOMAINHANDLE');
pmhs=guidata(pmh);
POTATo('searchfile_ext_Callback',pmhs.figure1,mkeylist,pmhs)
%set(pmhs.txt_ExtendedSearchKey,'String',['Key: ' ke]);
str=get(hs.pop_SOkey,'String');
vl=get(hs.pop_SOkey,'Value');
set(pmhs.txt_ExtendedSearchKey,'String',str,'Value',vl);

%==========================================================================
function pop_SOkey_Callback(h, ev, hs, exeflag)
% Set Search-Key
%==========================================================================
if nargin<4
  exeflag=true;
end
%------------
% Make Key
%------------
keyexamples=get(h, 'UserData');
keys=get(h,'String');
key = keys{get(h,'Value')}; clear keys;

%------------
% Make Key-Type
%------------
data=getappdata(hs.figure1,'DataList');
keytype=getKeytype(key,data);
set(hs.txt_SOkeytype,'String',keytype);

%-----------------------
% Disalbe/Enabel Control
%-----------------------
hh=[hs.psb_SOadd,hs.psb_SOmodify,hs.psb_SOdelete,...
  hs.psb_sorta,hs.psb_sortd,hs.edt_SO];
if any(strcmpi(keytype,{'Cell','unknown','NumericB','TextB'}))
  set(hh,'Enable','off');
else
  set(hh,'Enable','on');
end

%------------
% Set Example 
%-------------
if isempty(ev)
  switch keytype
    case 'Date'
      example='{''24-Jan-05'' datestr(now)}';
    case 'Gender'
      example='Female';
    case 'Numeric'
      if rand(1)>0.8
        example='[10 40]';
      else
        example='>10.84';
      end
    case {'Cell','unknown','NumericB','TextB'};
      example='-- Disable ---';
    case 'Text'
      example='^RegularExpression[0-9]$';
    otherwise
      example='No example';
  end

  % Overwrite (if there is Example)
  if ~strcmpi(keytype,'Cell')
    try
      if isfield(keyexamples,key);
        example = keyexamples.(key);
      end
    catch
      %example='No example';
    end
  end
  set(hs.edt_SO,'String',example);
end

%---------------------------
% Refresh --> for search-key
%---------------------------
fcn = getappdata(hs.figure1,'DataDefFcn');
if exeflag
  P3_refresh(1,fcn,hs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Search-Option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================================================
function search_and_refresh(hs)
% Search & Refresh P3
%==========================================================================

%-------------------------
% Load 
%-------------------------
% Load Data Defined  Function
fcn = getappdata(hs.figure1,'DataDefFcn');
% Load DataList
data = getappdata(hs.figure1,'DataList');
% Load Search-Keys
skey=getappdata(hs.figure1,'SearchKeys');

bl   = searchMe(skey,data);

P3_refresh(data(bl),fcn,hs);

function bl = searchMe(keylist,data)
% Search Key
bl=true(size(data));

for lid=1:length(keylist)
  so=keylist{lid};
  switch so.Type
    case 'Bracket'
      bll=searchMe(so.list,data);
    case 'SearchOption'
      bll=applaySO(so,data);
    otherwise
      error('Unknown Search-Key Type')
  end
  % <-- Update -->
  if so.Not
    bll=~bll;
  end
  if lid==1
    bl=myrelop(bl,'and',bll);
  else
    bl=myrelop(bl,so.Relop,bll);
  end
end

%==========================================================================
function bl=myrelop(b1,r,b2)
% Relational Operator
%==========================================================================
r=strrep(r,' ','');
switch lower(r)
  case 'notand'
    bl=b1 & ~b2;
  case {'notor'}
    bl=b1 | ~b2;
  case {'xor'}
    bl=xor(b1,b2);
  case 'and'
    bl=b1 & b2;
  case 'or'
    bl=b1 | b2;
  otherwise
    error('No Relational Operator, Named %s',r);
end
%==========================================================================
function bl=applaySO(so,data)
% Apply Search Option
%==========================================================================

switch lower(so.SortType)
  case 'range'
    KeyData=[data.(so.key)];
    bl= (so.SortValue(1)<= KeyData) & (so.SortValue(2)>= KeyData);
  case 'greater';
    KeyData=[data.(so.key)];
    bl= KeyData > so.SortValue(1);
  case 'less'
    KeyData=[data.(so.key)];
    bl= KeyData < so.SortValue(1);
  case 'equal'
    KeyData=[data.(so.key)];
    bl= so.SortValue(1)== KeyData;
  case 'regexp'
    %--------------------------------
    % Regular Expression (Text Type)
    %--------------------------------
    KeyData={data.(so.key)};
    if isempty(so.SortValue)
      bl=true(size(data));
    else
      rslt = regexp(KeyData, so.SortValue);
      if length(KeyData)==1
        if ~isempty(rslt),
          bl=true;
        else
          bl=false;
        end
      else
        bl=cellfun('isempty',rslt)==0;
      end
    end
  otherwise
    disp(so);
    error('Unknown Sort-Type!');
end

%==========================================================================
function keytype=getKeytype(key,data)
% Get-KeyType
%==========================================================================
keytype='unknown';
if ~isempty(data)
  data=data(1).(key);
  if isnumeric(data)
    % Special Key
    switch lower(key)
      case {'date','createdate'}
        keytype='Date';
      case {'sex','gender'}
        keytype='Gender';
      otherwise
        keytype='Numeric';
    end
  elseif iscell(data)
    keytype='Cell';
  elseif ischar(data)
    keytype='Text';
	elseif isstruct(data)
		keytype=data.Type;
  end
end

function [stat,str]=getCurrentSearchKey(hs)
% get Current SearchKey String
ud=get(hs.lbx_SO,'UserData');
if isempty(ud),
  stat=0;str='';return;
end
vl=get(hs.lbx_SO,'Value');
stat=ud.Status(vl);
if nargout>=2
  % String
  p=ud.path{vl};
  if length(p)>=1
    str=sprintf('skey{%d}',p(1));
  else
    str='skey';
  end
  for idx=2:length(p)
    str=sprintf('%s.list{%d}',str,p(idx));
  end
end

%==========================================================================
function lbx_SO_Callback(h,ev,hs) %#ok
% Execute on (Search-Option) Listbox Down
%==========================================================================

%--------------
% Check Status
%--------------
[stat,str]=getCurrentSearchKey(hs);

%--------------------
% Bind Context-Menu
%-------------------
if stat>=3
  % 3, 4 : SearchOption
  set(h,'UiContextMenu',hs.cmenu_searchoption);
elseif stat>=1
  % 1, 2 : Bracket
  set(h,'UiContextMenu',hs.cmenu_bracket);
end

%-------------------
% Change by Status
%-------------------
switch stat
  case {0,2}
    %-------------------
    % * Do Noting 
    %-------------------
    % 0 : Top
    % 2: Bracket End
    
  case {1,3}
    %-----------------------------
    % * Mod : Relational Operator
    %-----------------------------
    % 1: Bracket Start
    % 3: Search-Option (relop)
    skey=getappdata(hs.figure1,'SearchKeys'); %#ok : evaluate in str
    me=eval(str);
    % Load Update
    a=strfind(me.Relop,'And');
    if isempty(a),
      rdb_SOor_Callback(hs.rdb_SOor,[],hs);
    else
      rdb_SOand_Callback(hs.rdb_SOand,[],hs);
    end
    %     a=strfind(me.Relop,'Not');
    %     if isempty(a),
    %       set(hs.chk_SOnot,'Value',false);
    %     else
    %       set(hs.chk_SOnot,'Value',true);
    %     end
    set(hs.chk_SOnot,'Value',me.Not);
  case 4
    %-----------------------------
    % * Mod : Relational Operator
    % * Mod : Search-Key
    %-----------------------------
    % Search-Option (string)
    skey=getappdata(hs.figure1,'SearchKeys'); %#ok : evaluate in str
    me=eval(str);
    % Load : Relational-Operator
    a=strfind(me.Relop,'And');
    if isempty(a),
      rdb_SOor_Callback(hs.rdb_SOor,[],hs);
    else
      rdb_SOand_Callback(hs.rdb_SOand,[],hs);
    end

    %     a=strfind(me.Relop,'Not');
    %     if isempty(a),
    %       set(hs.chk_SOnot,'Value',false);
    %     else
    %       set(hs.chk_SOnot,'Value',true);
    %     end
    set(hs.chk_SOnot,'Value',me.Not);
    
    % Load : Search-Key
    s=get(hs.pop_SOkey,'String');
    id=find(strcmp(s,me.key));
    if length(id)==1
      set(hs.pop_SOkey,'Value',id);
      pop_SOkey_Callback(hs.pop_SOkey,[],hs);
    end
    set(hs.edt_SO,'String',me.String)
  otherwise
    %-----------------------------
    % Error 
    %  Unknown Status
    %-----------------------------
    errordlg('Unknown List-Box Status');
    disp(C__FILE__LINE__CHAR); % Never Call!!
end
return;

function varargout=addSearchKey(hs)
% 
varargout{1}=[];

so.Type  = 'SearchOption';
% Relational-Operator
so.Relop =getappdata(hs.figure1,'RelationalOperator');
% if get(hs.chk_SOnot,'Value');
%   so.Relop = ['Not ' so.Relop];
% end
so.Not=get(hs.chk_SOnot,'Value');

% String
so.String=get(hs.edt_SO,'String');
data=getappdata(hs.figure1,'DataList');
% key-Type
key  =get(hs.pop_SOkey,'String');
key  =key{get(hs.pop_SOkey,'Value')};
so.key=key;
so.KeyType=getKeytype(key,data);
% Sort-Type & Sort-Value
switch lower(so.KeyType)
  case 'date'
    %- - - - - - - -
    % Date Format
    %- - - - - - - -
    so.SortType='Range';
    try
      cnd =eval(so.String);
      if iscell(cnd)
        t=[datenum(cnd(1)), datenum(cnd(2))];
        so.SortValue=[min(t),max(t)];
      else
        % From 0:00 to 24:00
        so.SortValue=datenum(cnd);
        so.SortValue(2)=so.SortValue+1.0;
      end
    catch
      errordlg({'Date Search-Format : ', ...
        ['Data Input format like follows '...
        '{''23-Jan-01'', ''24-Jan-01''}'],...
        ' or ',...
        '''24-Jan-01'''},...
        'Add Search Key : Format Error');
      return;
    end
  case 'gender'
    %- - - - - - - -
    % Gender Format
    %- - - - - - - -
    so.SortType='Equal';
    switch lower(so.String)
      case {'male','''male'''}
        so.SortValue=0;
      case {'female','''female'''}
        so.SortValue=1;
      otherwise
        errordlg({'Gender Search-Format :', ...
          ' ''Male'' or ''Female'''},...
          'Add Search Key : Format Error');
        return;
    end
  case 'numeric'
    %- - - - - - - -
    % Numeric Format
    %- - - - - - - -
    try
      s=strrep(so.String,'<','');
      s=strrep(s,'>','');
      s=strrep(s,'=','');
      cnd =eval(s);
      if length(cnd)==2
        so.SortType='Range';
        so.SortValue=[min(cnd(:)), max(cnd(:))];
      elseif length(cnd)==1
        s=strrep(so.String,' ','');
        % 1st Relop --> 2nd Relop
        if ~isempty(strfind('<>=',s(1)))
          s([1,end])=s([end,1]); % Exchange
          if strcmp(s(end),'>')
            s(end)='<';
          elseif strcmp(s(end),'<')
            s(end)='>';
          end
        end
        % check Relop
        switch s(end)
          case '<'
            so.SortType='Greater';
          case '>'
            so.SortType='Less';
          case '='
            so.SortType='Equal';
          otherwise
            so.SortType='Equal';
        end
        so.SortValue=cnd;
      else
        error('Dumy');
      end
    catch
      errordlg({'Numeric Search-Format :', ...
        '     10> ',...
        ' or  10< ',...        
        ' or  >10 ',...
        ' or  <10 ',...
        ' or  10= ',...
        ' or  =10 ',...
        ' or  [10 20]'},...
        'Add Search Key : Format Error');
      return;
    end
  case 'text'
    %- - - - - - - -
    % Text Format
    %- - - - - - - -
    so.SortType='Regexp';
    so.SortValue=so.String;
  otherwise
    %case 'cell'
    error('Unknown Format');
end

% For Modify
if nargout==1
  varargout{1}=so;return;
end

skey=getappdata(hs.figure1,'SearchKeys');
if isempty(skey)
  stat=0;
  skey={};
else
  [stat,str]=getCurrentSearchKey(hs);
end

%--> in Bracket <--
if 0
  bk.Type  = 'Bracket';
  bk.Relop=so.Relop;
  bk.list={so};
  so=bk;
end

switch stat
  case 0
    % 0 : Top
    % Make Default Bracket
    bk.Type  = 'Bracket';
    so.Relop = 'And';
    bk.Relop = so.Relop;
    bk.Not   = 0;
    bk.list  ={so};
    skey={bk,skey{:}};
    
  case 1
    % 1: Bracket Start
    % Add SO to top
    bk=eval(str);
    if ~isempty(bk.list)
      bk.list{1}.Relop=so.Relop; % Confine
    end
    so.Relop='And';
    bk.Relop=so.Relop;
    bk.Not  = 0;
    bk.list={so, bk.list{:}};
    eval([str '=bk;']);
  case 2
    % 2: Bracket End
    % Add Bracket 

    %--->
    % Get upper String
    ud=get(hs.lbx_SO,'UserData');
    vl=get(hs.lbx_SO,'Value');
    p=ud.path{vl}; 
    mypoint=p(end);
    p(end)=[];
    if length(p)>=1
      str=sprintf('skey{%d}',p(1));
    else
      str='skey';
    end
    for idx=2:length(p)
      str=sprintf('%s.list{%d}',str,p(idx));
    end
    %<---
    bk=eval(str);
    bk2.Type  = 'Bracket';
    bk2.Relop = so.Relop; so.Relop='And';
    bk2.Not   = so.Not;   so.Not   =0;
    bk2.list={so};
    if iscell(bk)
      bk={bk{1:mypoint},bk2,bk{mypoint+1:end}}; %#ok : Evaluate-->
    else
      bk.list={bk.list{1:mypoint},bk2,bk.list{mypoint+1:end}};
    end
    eval([str '=bk;']);
  case {3,4}
    % 3: Search-Option (relop)
    % 4: Search-Option (string)
    
    %--->
    % Get upper String
    ud=get(hs.lbx_SO,'UserData');
    vl=get(hs.lbx_SO,'Value');
    p=ud.path{vl}; 
    mypoint=p(end);
    p(end)=[];
    if length(p)>=1
      str=sprintf('skey{%d}',p(1));
    else
      str='skey';
    end
    for idx=2:length(p)
      str=sprintf('%s.list{%d}',str,p(idx));
    end
    %<---
    bk=eval(str);
    if iscell(bk)
      bk={bk{1:mypoint},so,bk{mypoint+1:end}}; %#ok : Evaluate-->
    else
      bk.list={bk.list{1:mypoint},so,bk.list{mypoint+1:end}};
    end    
    eval([str '=bk;']);
  otherwise
    errordlg('Unknown List-Box Status');
end

setappdata(hs.figure1,'SearchKeys',skey);

function showSearchKey(hs)
skey=getappdata(hs.figure1,'SearchKeys');

ud.Env.Indent='';
ud.Env.path=[];
ud.Status=0;
ud.path  ={[]};
ud.String={'-- Top --'};
ud=ssk(skey,ud);
vl=get(hs.lbx_SO,'Value');
if vl>length(ud.String),vl=length(ud.String);end
set(hs.lbx_SO,'String',ud.String,'UserData',ud,'Value',vl);
lbx_SO_Callback(hs.lbx_SO,[],hs);
search_and_refresh(hs); % Search!!

function ud=ssk(skey,ud)
% Search-Key
for idx=1:length(skey)
  switch skey{idx}.Type
    case 'Bracket',
      % Bracket Start
      if idx~=1
        if skey{idx}.Not
          ud.String{end+1}=sprintf('%s~%s (',ud.Env.Indent,skey{idx}.Relop);
        else
          ud.String{end+1}=sprintf('%s%s (',ud.Env.Indent,skey{idx}.Relop);
        end
      else
        ud.String{end+1}=sprintf('%s(',ud.Env.Indent);
      end
      ud.path{end+1}=[ud.Env.path, idx];
      ud.Status(end+1)=1;
      % Inner
      env=ud.Env;
      ud.Env.Indent= [ud.Env.Indent '   '];
      ud.Env.path  = [ud.Env.path, idx];
      ud=ssk(skey{idx}.list,ud);
      ud.Env=env;
      % Bracket End
      ud.String{end+1}=[ud.Env.Indent ')'];
      ud.path{end+1}=[ud.Env.path, idx];
      ud.Status(end+1)=2;
    case 'SearchOption'
      if idx~=1
        ud.String{end+1}=sprintf('%s %s ',ud.Env.Indent,skey{idx}.Relop);
        ud.path{end+1}=[ud.Env.path, idx];
        ud.Status(end+1)=3;
      end
      if skey{idx}.Not
        ud.String{end+1}=sprintf('%s~***%s*** : %s',ud.Env.Indent,...
          skey{idx}.key,skey{idx}.String);
      else
        ud.String{end+1}=sprintf('%s ***%s*** : %s',ud.Env.Indent,...
          skey{idx}.key,skey{idx}.String);
      end
      ud.path{end+1}=[ud.Env.path, idx];
      ud.Status(end+1)=4;
    otherwise
      error('Unknown Search-Key-Type');
  end
end


function psb_SOadd_Callback(h,ev,hs) %#ok
addSearchKey(hs);
showSearchKey(hs);

function psb_SOmodify_Callback(h,ev,hs) %#ok
so=addSearchKey(hs);

[stat,str]=getCurrentSearchKey(hs);
switch stat
  case {0,2}
    % 0 : Top
    % 2: Bracket End
  case 1
    % 1: Bracket Start
    skey=getappdata(hs.figure1,'SearchKeys');
    me=eval(str);
    me.Relop=so.Relop;
    me.Not  =so.Not;
    %if length(me.list)>=1
    %  me.list{1}.Relop=so.Relop;
    %end
    eval([str '=me;']);
    setappdata(hs.figure1,'SearchKeys',skey);
  case {3,4}
    % 3: Search-Option (relop)
    % 4: Search-Option (string)
    skey=getappdata(hs.figure1,'SearchKeys');
    eval([str '=so;']);
    setappdata(hs.figure1,'SearchKeys',skey);
  otherwise
    errordlg('Unknown List-Box Status');
end

showSearchKey(hs);


function edt_SO_Callback(h,ev,hs) %#ok
% Do Nothing

%==========================================================================
function rdb_SOand_Callback(h,ev,hs) %#ok
% Radio Button Control
%==========================================================================
setappdata(hs.figure1,'RelationalOperator','And');
set(h,'Value',1);
set(hs.rdb_SOor,'Value',0);
%==========================================================================
function rdb_SOor_Callback(h,ev,hs) %#ok
% Radio Button Control
%==========================================================================
setappdata(hs.figure1,'RelationalOperator','Or');
set(h,'Value',1);
set(hs.rdb_SOand,'Value',0);

%==========================================================================
function chk_SOnot_Callback(h,ev,hs) %#ok
% Do Nothing
%==========================================================================
function psb_SOdelete_Callback(h,ev,hs) %#ok
% Delete Sobject
[stat,str]=getCurrentSearchKey(hs);
a=strfind(str,'}');
if length(a)>=1
  str(a(end))=')';
  a=strfind(str,'{');str(a(end))='(';
  skey=getappdata(hs.figure1,'SearchKeys');
  eval([str '=[];']);
else
  skey={};
end

setappdata(hs.figure1,'SearchKeys',skey);
showSearchKey(hs);

%==========================================================================
function menu_DeleteBrackets_Callback(h, ev, hs) %#ok
% Delete Brakets
%==========================================================================
skey=getappdata(hs.figure1,'SearchKeys');

% Get Upper Search-Key
ud=get(hs.lbx_SO,'UserData');
vl=get(hs.lbx_SO,'Value');
p=ud.path{vl};
if length(p)<=1,return;end
mypoint=p(end);
p(end)=[];
if length(p)>=1
  str=sprintf('skey{%d}',p(1));
else
  str='skey';
end
for idx=2:length(p)
  str=sprintf('%s.list{%d}',str,p(idx));
end
upkey=eval(str);

% Get Current Search-Key
[stat,str0]=getCurrentSearchKey(hs);
bk=eval(str0);

% Move to Upper
upkey.list={upkey.list{1:mypoint-1},bk.list{:},upkey.list{mypoint+1:end}};

% Update
eval([str '=upkey;']);
setappdata(hs.figure1,'SearchKeys',skey);
showSearchKey(hs);

%==========================================================================
function menu_PutInBrackets_Callback(h, ev, hs) %#ok
% Make Brackets
%==========================================================================

% Get Current Search-Key
[stat,str]=getCurrentSearchKey(hs);
if stat<3,return;end
skey=getappdata(hs.figure1,'SearchKeys');
so=eval(str);

% Make New Braket
bk.Type  = 'Bracket';
bk.Relop = so.Relop;
bk.Not   = 0;
so.Relop = 'And';
bk.list={so};

% Update
eval([str '=bk;']);
setappdata(hs.figure1,'SearchKeys',skey);
showSearchKey(hs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serch Option File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_Save_Callback(h,ev,hs) %#ok
% Save SearchKeys

% Put File-Name
name=['ExtendedSearchOption_'  datestr(now,'dd_mmm_yyyy') '.mat'];
[f,p]=osp_uiputfile(name,'Make : Extended-Search-Option');
if isequal(f,0),return;end

% Save Files
rver=OSP_DATA('GET','ML_TB');
rver=rver.MATLAB;
fname=[p filesep f];
SearchKeys=getappdata(hs.figure1,'SearchKeys'); %#ok save-data
if rver >= 14,
  save(fname,'SearchKeys','-v6');
else
  save(fname,'SearchKeys');
end

function UpdateSearchKey(h,skey,hs)
% Upper Link : P3_gui_Research_1st/pop_R1st_SammarizedDataList_Callback

% Check Data
try
  msg=checkSearchKeys(skey,'',hs);
catch
  error('Search Key Format Error');  
end
if msg,error(msg);end

% Apply to Window
setappdata(h,'SearchKeys',skey);
showSearchKey(hs);

function psb_Load_Callback(h, ev,hs)
%

% Open File
[f,p]=osp_uigetfile({'*.mat','Read : Extended-Search-Option,'},...
  'Extended Search-Option File');
if isequal(f,0),return;end
fname=[p filesep f];

% Load Data
s=load(fname);
if ~isfield(s,'SearchKeys')
  error('Format Error: Not an Extended Search Option File');
end
skey=interpNot(s.SearchKeys);
% Check Data
try
  msg=checkSearchKeys(skey,'',hs);
catch
  error('Search Key Format Error');
end
if msg,error(msg);end

% Apply to Window
setappdata(hs.figure1,'SearchKeys',skey);
showSearchKey(hs);

function skey=interpNot(skey)
% Modify 
% OLD version : Relop
%  so.Relop =getappdata(hs.figure1,'RelationalOperator');
%  if get(hs.chk_SOnot,'Value');
%   so.Relop = ['Not ' so.Relop];
%  end
% Now : 
%  so.Relop =getappdata(hs.figure1,'RelationalOperator');
%  so.Not=get(hs.chk_SOnot,'Value');

for idx=1:length(skey)
  switch skey{idx}.Type
    case 'Bracket',
      skey{idx}.list=interpNot(skey{idx}.list);
      if ~isfield(skey{idx},'Not')
        skey{idx}.Not  =0;
      end
    case 'SearchOption'
      if ~isfield(skey{idx},'Not')
        if strfind(skey{idx}.Relop,'Not ')
          skey{idx}.Relop=skey{idx}.Relop(5:end);
          skey{idx}.Not  =1;
        else
          skey{idx}.Not  =0;
        end
      end
    otherwise
      error('Unknown Search-Key-Type');
  end
end

function msg=checkSearchKeys(skey,msg,hs)
% Check Search Key

% Load Key
keys=get(hs.pop_SOkey,'String');
data=getappdata(hs.figure1,'DataList');

for idx=1:length(skey)
  if msg,return;end % There is Message : Exist
  switch skey{idx}.Type
    case 'Bracket',
      % Bracket Start
      msg=checkSearchKeys(skey{idx}.list,msg,hs);
    case 'SearchOption'
      %disp(skey{idx});
      kid=find(strcmp(skey{idx}.key,keys));
      if length(kid)~=1,
        msg=['Unknown Serach Key : ' skey{idx}.key];
        return;
      end
      keytype=getKeytype(keys{kid},data);
      if ~strcmpi(keytype,skey{idx}.KeyType)
        msg=['Miss Match Key Type for ' skey{idx}.key];
        return;
      end
    otherwise
      error('Unknown Search-Key-Type');
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Sort-Option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function psb_sorta_Callback(h,ev,hs) %#ok
% Arrange in Ascending order.
%==========================================================================
key=get(hs.pop_SOkey, 'String');  % Get SortKey
data = getappdata(hs.figure1,'DataList'); % GetOriginalData
data=struct_sort(data, key{get(hs.pop_SOkey, 'Value')});
setappdata(hs.figure1,'DataList',data); % Modify OriginalData
try
  % Get Data-Define-Function
  fcn=getappdata(hs.figure1,'DataDefFcn');
  if isempty(fcn)
    error('No Data Categoly');
  end
  if isa(fcn, 'function_handle')
    fcn=func2str(fcn);
  end
  feval(fcn,'UpdateDataKey',data);        % Update Sort Result
catch
  warndlg({'Data Update Error Occur:',lasterr},...
    'Extended-Search: Search');
end

% refresh
showSearchKey(hs)
return;
%==========================================================================
function psb_sortd_Callback(h,ev,hs) %#ok
% Arrange in descending order.
%==========================================================================
key=get(hs.pop_SOkey, 'String');  % Get SortKey
data=getappdata(hs.figure1,'DataList'); % GetOriginalData
data=struct_sort(data, key{get(hs.pop_SOkey, 'Value')});
data=data(end:-1:1);
setappdata(hs.figure1,'DataList',data); % Modify OriginalData
try
  % Get Data-Define-Function
  fcn=getappdata(hs.figure1,'DataDefFcn');
  if isempty(fcn)
    error('No Data Categoly');
  end
  if isa(fcn, 'function_handle')
    fcn=func2str(fcn);
  end
  feval(fcn,'UpdateDataKey',data);        % Update Sort Result
catch
  warndlg({'Data Update Error Occur:',lasterr},...
    'Extended-Search: Search');
end

% refresh
showSearchKey(hs)
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  File I/O
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function psb_Import_Callback(h, ev, hs) %#ok
% Import Data-Search-Key from CSV
%==========================================================================

%---------------
% Get Data-Define-Function
%---------------
fcn=getappdata(hs.figure1,'DataDefFcn');
if isempty(fcn)
  errordlg({'No Data Categoly.',' Reset Extended-Search.'},...
    'Extended-Search: Import Error 1');return;
end
if isa(fcn, 'function_handle')
  func2str(fcn);
end

%-----------------
% Open File
%-----------------
name=['Export_' fcn '_DataList.csv'];
[f,p]=osp_uigetfile(name,'Import Data List File');
if isequal(f,0),return;end
[fid msg]=fopen([p filesep f],'r');
if ~isempty(msg)
  errordlg({' File-Open Error :',msg,f},...
    'Extended-Search: Import Error 2');
  return;
end

%-----------------
% Load File
%-----------------
% ==== Input ====
%  fid : File - Pointer
%
% ==== Output ====
%  finfo : structure
%
% === Error ===
%  * errordlog &
try
  %-----------------
  % Header
  %-----------------
  tline = fgetl(fid); %#ok dumy
  % Function
  try
    tline = fgetl(fid);
    sep=strfind(tline,',');
    if length(sep)>5
      fcn2=strrep(tline(sep(4)+1:sep(5)-1),' ','');
    else
      fcn2=strrep(tline(sep(4)+1:end),' ','');
    end
  catch
    error('Data-Define-Function Error');
  end
  if ~strcmpi(fcn,fcn2)
    error('Missmatch Data-Define-Function');
  end
  % Date
  tline = fgetl(fid); %#ok dumy

  %-----------------
  % Key-Name & Key-Type
  %-----------------
  try
    % Key Name
    lkn = fgetl(fid); 
    skn = strfind(lkn,',');
    kn  ={};
    ikn =1;
    % Key Type
    lkt = fgetl(fid); 
    skt = strfind(lkt,',');
    kt  ={};
    ikt =1;
    
    idx0=1;
    for idx=1:length(skn)
      kn{idx0}=strrep(lkn(ikn:skn(idx)-1),' ',''); %#ok
      kt{idx0}=strrep(lkt(ikt:skt(idx)-1),' ',''); %#ok
      ikn=skn(idx)+1;
      ikt=skt(idx)+1;
      if isempty(kn{idx0}),continue;end
      idx0=idx0+1;
    end
    tmp=strrep(lkn(ikn:end),' ','');
    if ~isempty(tmp)
      kn{idx0}=tmp;
      kt{idx0}=strrep(lkt(ikt:end),' ','');
    end
  catch
    error('Key-Name / Key-Type Error');
  end

  %-----------------
  % Make Format
  %-----------------
  fmt=repmat('% ',[1,length(kt)]);
  for idx=1:length(kt)
    switch lower(kt{idx})
      case 'date'
        fmt(2*idx)='n';
      case 'gender'
        fmt(2*idx)='d';
      case {'numeric'}
        fmt(2*idx)='f';
      case {'text','cell','textb','numericb'}
        fmt(2*idx)='s';
      otherwise
        error('Undefined Key-Type %s',kt{idx});
    end
  end
  %-----------------
  % Load Data
  %-----------------
  %d = textscan(fid,fmt,'delimiter',',','headerLines',5);
  d = textscan(fid,fmt,'delimiter',','); % with Format Check!!
  
  %----------------
  % Output formatting...
  %----------------
  finfo.KeyName=kn;
  finfo.KeyType=kt;
  finfo.data=d;
catch
  fclose(fid);
  errordlg({' File-Load Error :',lasterr},...
    'Extended-Search: Import Error 3');
  %edit([p filesep f]);
  return;
end
fclose(fid);

%-----------------
% Data-Check!
%-----------------
% !! Main-Key Check !!
mainkey   = feval(fcn,'getIdentifierKey');
mainkeyid = find(strcmp(finfo.KeyName,mainkey));
if length(mainkeyid)~=1
  errordlg({' File-Format Error :',' Primary-Key Dislocate Error'},...
    'Extended-Search: Import Error 4','Same key name was found!');
  return;
end
data = feval(fcn,'loadlist');
mykeys    = {data.(mainkey)};   % Get main KeyList
if length(unique(finfo.data{mainkeyid}))~=length(mykeys)
  errordlg({' File-Format Error :',' Primary-Key Dislocate Error'},...
    'Extended-Search: Import Error 4');
  return;
end

x=setxor(mykeys,finfo.data{mainkeyid});
if ~isempty(x)
  errordlg({' File-Format Error :',' Primary-Key Dislocate Error (not match)'},...
    'Extended-Search: Import Error 5');
  return;
end

%---------------
% Exchange Data 
%---------------
try
  [KeyName, i0, j0]=unique(finfo.KeyName);
  klen=length(KeyName);
  [nouse ix]=sort(i0); %#ok
  KeyName=KeyName(ix);
  dlen=length(finfo.data{1});
  ctmp=cell([1,klen]);
  for didx=1:dlen
    for ii=1:length(i0) % Length KeyName
      kidx=i0(ii);
      switch lower(finfo.KeyType{kidx})
        case 'cell'
          strtmp=finfo.data{kidx}{didx};
          ctmp{ii}=eval(strtmp);
        case {'numericb','textb'}
          idx2 = find(j0==ii);
          tmp=cell([1,length(idx2)]);
          for jj=1:length(idx2)
            kidx2=idx2(jj);
            if iscell(finfo.data{kidx2}(didx))
              tmp(jj)=finfo.data{kidx2}(didx);
            else
              tmp{jj}=finfo.data{kidx2}(didx);
            end
          end
          tmp0.Type=finfo.KeyType{kidx};
          tmp0.Data=tmp;
          ctmp{ii}=tmp0;
        otherwise
          if iscell(finfo.data{kidx}(didx))
            ctmp(ii)=finfo.data{kidx}(didx);
          else
            ctmp{ii}=finfo.data{kidx}(didx);
          end
      end
    end
    ctmp=ctmp(ix);
    newdata(didx)=cell2struct(ctmp,KeyName,2);
  end
catch
  errordlg({' File-Format Error :',' Excahnge Data Error',lasterr},...
    'Extended-Search: Import Error 6');
  return;
end

%---------------
% Update GUI
%---------------
try
  feval(fcn,'UpdateDataKey',newdata);
catch
  disp(fcn);
  disp(newdata);
  disp(C__FILE__LINE__CHAR);
  errordlg({' Data-Define Function Error :',' May be unpopulated',lasterr},...
    'Extended-Search: Import Error 7');
  return;
end
% initialize Refresh-Key
changeDataCategoly(h,[],hs);
%========> Error
if 0
  errordlg({'Unpopulated Code.',C__FILE__LINE__CHAR(1)},...
    'Extended-Search: Import Error 0');
  disp(C__FILE__LINE__CHAR);
end
return;


%==========================================================================
function psb_Export_Callback(h, ev, hs)
% Export Data-Search-Key to CSV
%==========================================================================

% Get Data-Define-Function
fcn=getappdata(hs.figure1,'DataDefFcn');
if isempty(fcn)
  errordlg({'No Data Categoly.',' Reset Extended-Search.'},...
    'Extended-Search: Export Error 1');return;
end
if isa(fcn, 'function_handle')
  func2str(fcn);
end

%==========================================================================
% Load DataList
%==========================================================================
if 1
  data = feval(fcn,'loadlist');
else
  % sort data
  data = getappdata(hs.figure1,'DataList');
end
name=['Export_' fcn '_DataList.csv'];
[f,p]=osp_uiputfile(name,'Export Data List File');
if isequal(f,0),return;end
[fid msg]=fopen([p filesep f],'w');
if ~isempty(msg)
  errordlg({' File-Open Error :',msg,f},...
    'Extended-Search: Export Error 2');
  return;
end
try
  %-----------------
  % Header
  %-----------------
  fprintf(fid,'List of %s''s Search-Key\n',fcn);
  fprintf(fid,'      ,   ,    ,Data-Function:,%s\n',fcn);
  fprintf(fid,'      ,   ,    ,Date:,%s\n',datestr(now));
  oh=fieldnames(data); % Header
  fmt='';
  typ='';

  %--------------------------------------------
  % Key-Name & make Key-Type & Reformat-Data
  %---------------------------------------------
  od=squeeze(struct2cell(data)); % Data
  for id=1:length(oh)
    fprintf(fid,'%s,',oh{id});
    keytype=getKeytype(oh{id},data);
    switch lower(keytype)
      case 'date'
        fmt=[fmt '%18.16g,'];
      case 'gender'
        fmt=[fmt '%d,'];
      case 'numeric'
        fmt=[fmt '%f,'];
      %case 'text'
      case {'text','textb','numericb'}
        fmt=[fmt '%s,'];
      case {'textb','numericb'}
          fmt=[fmt '%s,'];
          for rid=1:size(od,2)
            tmp='{';
            for cid=1:length(od{id,rid})
                tmp=[tmp ''''  od{id,rid}{cid} ''','];
            end
            tmp(end)='}';
            od{id,rid} =tmp;
        end
      case 'cell'
        fmt=[fmt '%s,'];
        for rid=1:size(od,2)
          tmp='{';
          for cid=1:length(od{id,rid})
            tmp=[tmp ''''  od{id,rid}{cid} ''','];
          end
          tmp(end)='}';
          od{id,rid} =tmp;
				end
				

      otherwise
        %error('Unknown Format');
				disp(sprintf('Unknown format: %s',keytype));
				disp(c__FILE__LINE__CHAR);
				%continue;
				fmt=[fmt '%s,'];        
    end
    typ=[typ keytype ','];
  end
  fprintf(fid,'\n');
  fprintf(fid,'%s\n',typ);
  fmt =[fmt '\n'];
  
  for idx=1:size(od,2)
		s={};
		for k=1:length(od(:,idx))
			if ~isstruct(od{k,idx})
				s{k}=od{k,idx};
			else
				s{k}=od{k,idx}.Data{:};
			end
            % bug fix
            if strcmpi(getKeytype(oh{k},data),'numeric') && ...
                    ~isnumeric(od{k,idx})
                try
                    s{k}=str2num(od{k,idx});
                catch
                    s{k}=NaN;
                end
            end
		end
    fprintf(fid,fmt,s{:});
  end
catch
  fclose(fid);
  edit([p filesep f]);
  rethrow(lasterror);
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_Help_Callback(h,ev,hs) %#ok
% Open Help
POTATo_Help(mfilename);

function changeColor(h,cl,hs) %#ok
% Change Color

% Find Uicontrol (Color Change)
h0=findobj(h,'style','text');
h1=findobj(h,'style','frame');
h2=findobj(h,'style','Checkbox');
h3=findobj(h,'style','radiobutton');
% set Color
set([h0(:);h1(:);h2(:);h3(:)],'BackgroundColor',cl);
set(h,'Color',cl);
set(hs.txt_SOkeytype,'BackgroundColor',[0.9 0.9 1]);





