function varargout = P3R2_subAPI_groupingByKey(varargin)
% P3R2_SUBAPI_GROUPINGBYKEY is window of POTATo Reserch-Mode.
%   This window select GROUP by key from SS Data.
%
% Upper link : P3R2_API_groupingByKey & myself(gui) ONLY.
% See also: P3R2_API_groupingByKey, GUIDE, GUIDATA, GUIHANDLES

% == History ==
%  2011.02.07 : New! 
%  2011.04.26 : Add Interface for Modification.


% Edit the above text to modify the response to help P3R2_subAPI_groupingByKey

% Last Modified by GUIDE v2.5 18-Dec-2012 17:16:57

% Initiarize Launcher ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Depend on GUIDE version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3R2_subAPI_groupingByKey_OpeningFcn, ...
                   'gui_OutputFcn',  @P3R2_subAPI_groupingByKey_OutputFcn, ...
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
%  1. Opening Function, (from P3R2_API_groupingByKey)
%  2. Outupt  Function,
%  3. setArguments:: real opening, (from P3R2_API_groupingByKey)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
function P3R2_subAPI_groupingByKey_OpeningFcn(h,ev,hs, varargin) %#ok
% Opning : do noting
%==========================================================================
hs.output = h;
set(hs.rdbOR,'value',0); % HK 2023-03-27
set(hs.rdbAND,'value',1);% HK 2023-03-27
guidata(h, hs);

%==========================================================================
function varargout = P3R2_subAPI_groupingByKey_OutputFcn(h,ev,hs) %#ok
% varargout{1} : handle of GUI
%==========================================================================
varargout{1} = hs.output;

%==========================================================================
function isok=setArgument(h,ev,hs,GD) %#ok
% varargout{1} : handle of GUI
%==========================================================================
isok=false;
phs=ev; % Handles of POTATo
cellSS=P3_gui_Research_2nd('loadCellSS',phs); % Load CSS
setappdata(h,'cellSS',cellSS);

% get Key-List
ngroup=length(cellSS);
keys=ss_datakeys;
for ii=1:ngroup
  keys=union(keys,cellSS{ii}.Header);
end
% Update Key-List
set(hs.pop_key,'String',keys);
pop_key_Callback(hs.pop_key,[],hs);
if nargin>=4
  % undo psb_ok
  if ~isempty(GD.Name)
    set(hs.edt_GroupName,'String',GD.Name);
  end

  % ds : Display String
  dsl=cell([1,length(GD.keys)]);
  for ii=1:length(GD.keys)
    gf=GD.keys{ii};
    switch gf.type
      case 'list'
        ds=sprintf('%s:',gf.key);
        try
          if length(gf.value)<4
            % short
            if isnumeric(gf.value)
              for jj=1:length(gf.value)
                ds=[ds ' ' num2str(gf.value(jj))];
              end
            else
              for jj=1:3
                ds=[ds ' ' gf.value{jj}];
              end
            end
          else
            % long
            if isnumeric(gf.value)
              for jj=1:3
                ds=[ds ' ' num2str(gf.value(jj))];
              end
            else
              for jj=1:3
                ds=[ds ' ' gf.value{jj}];
              end
            end
            ds=[ds '...'];
          end
        catch
          % err
        end
      case 'equation';
        ds=sprintf('%s: %s',gf.key,gf.equation);
    end
    if strcmpi(gf.condition,'and')
			ds=['cond: ' ds];
		end
    dsl{ii}=ds;
  end
  %--------
  set(hs.lbx_info, 'UserData',GD.keys);
  if (length(GD.keys)>0)
    set(hs.lbx_info, 'String',dsl);
  end
  set(hs.ckb_usecomplement,'Value',0);
  %set(hs.ckb_usecomplement,'Enable','inactive','UserData',GD.inv);
  set(hs.ckb_usecomplement,'Enable','off');
  if (GD.inv)
    set(hs.txt_inv,'Visible','on');
  end
  set(h,'UserData',{GD});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ending Operation's (visible off : close)
%-----------------------------------------------------------------
%  1. OK     : Make output data --> 
%  2. Cancel : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_OK_Callback(h,ev,hs) %#ok
%
GD.Name=get(hs.edt_GroupName,'String');
if isempty(GD.Name)
  errordlg('Please input Group-Name','Error');
  return;
end
GD.inv=strcmpi(get(hs.txt_inv,'Visible'),'on');

GD.keys=get(hs.lbx_info, 'UserData');

GroupData={GD};
if get(hs.ckb_usecomplement,'Value')
  GD.Name=get(hs.edt_GroupName2,'String');
  if isempty(GD.Name)
    errordlg('Please input Group-Name(complement)','Error');
    return;
  end
  GD.inv=true;
  %GD.keys=get(hs.lbx_info, 'UserData');
  GroupData{end+1}=GD;
end
set(h,'UserData',GroupData);
set(hs.figure1,'Visible','off');
function psb_cancel_Callback(h,ev,hs) %#ok
delete(hs.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Key box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hl=lisths(hs)
% Handle list of Listbox-select
hl=hs.lbx_key;

function hl=eqhs(hs)
% Handle list of equation-select
hl=[hs.edt_equation, hs.txt_equation_help];

function rdb_list_Callback(h,ev,hs) %#ok
% change visible
if ~get(h,'Value'), set(h,'Value',1); end % for matlab bug??
set(lisths(hs),'Visible','on');
set(eqhs(hs),'Visible','off');
% callback 
pop_key_Callback(hs.pop_key,ev,hs);

function rdb_eq_Callback(h,ev,hs) %#ok
% change visible
if ~get(h,'Value'), set(h,'Value',1); end % for matlab bug??
set(lisths(hs),'Visible','off');
set(eqhs(hs),'Visible','on');
% callback 
pop_key_Callback(hs.pop_key,ev,hs);

function lbx_key_Callback(h,ev,hs) %#ok
% do noting
function edt_equation_Callback(h,ev,hs) %#ok
% do noting

%==========================================================================
function pop_key_Callback(h,ev,hs) %#ok
% Key popup
%==========================================================================
keys=get(h,'String');
key=keys{get(h,'Value')};
cellSS=getappdata(hs.figure1,'cellSS');

% %%%%%%%%%%%%%%%%%%%%%
% Select from listbox
% %%%%%%%%%%%%%%%%%%%%%
if get(hs.rdb_list,'Value')
  n=length(cellSS);
  kk={};
  xx=ss_datakeys;
  kid=find(strcmp(xx,key));
  %===========
  % Make Key
  %===========
  if isempty(kid)
    % in Header
    for ii=1:n
      myid=find(strcmp(cellSS{ii}.Header,key));
      if ~isempty(myid)
        if isnumeric(cellSS{ii}.SummarizedKey{1,myid})
          if iscell(kk), kk=[];end
          kk=union(kk,[cellSS{ii}.SummarizedKey{:,myid}]);
        else
          try
            kk=union(kk,cellSS{ii}.SummarizedKey(:,myid));
          catch
          end
        end % type (numeric or no)
      end % empty myid
    end
  else
    % time or channel or kind
    kk0=[];
    mx=0;
    for ii=1:n
      if isfield(cellSS{ii},key)
        kk0=union(kk0,cellSS{ii}.(key));
      else
        for jj=1:size(cellSS{ii}.SummarizedData,1)
          mx=max(mx,size(cellSS{ii}.SummarizedData{jj,1},kid));
        end
      end
    end
    if (mx~=0)
      kk=union(1:mx,kk0);
    end
  end
 
  %===========
  % Display 
  %===========
  if isempty(kk)
    s='Non supported Key';
  else
    if isnumeric(kk)
      s={};
      for ii=1:length(kk)
        if isequal(kk(ii),round(kk(ii)))
          s{end+1}=sprintf('%d',kk(ii));
        else
          s{end+1}=sprintf('%f',kk(ii));
        end
      end
    else 
      % non-numeric
      s={};
      for ii=1:length(kk)
        if ischar(kk{ii})
          s{end+1}=sprintf('%s',kk{ii});
        else
          s{end+1}=sprintf('???');
        end
      end
    end
  end
  % setup
  if isempty(s), s='no-data';end
  set(hs.lbx_key,'Value',1,'String',s,'UserData',kk);
end

% %%%%%%%%%%%%%%%%%%%%%
% Select by equation
% %%%%%%%%%%%%%%%%%%%%%
if get(hs.rdb_eq,'Value')
  % check type
  xx=ss_datakeys;
  type='unknown';
  if any(strcmp(xx,key))
    % time or chanel or block
    type='numeric';
  else
    n=length(cellSS);
    for ii=1:n
      myid=find(strcmp(cellSS{ii}.Header,key));
      if ~isempty(myid)
        break;
      end
    end
    if isempty(myid), return;end
    
    if isnumeric(cellSS{ii}.SummarizedKey{1,myid})
      type='numeric';
    else
      if ischar(cellSS{ii}.SummarizedKey{1,myid}) 
        type='char';
      end
    end
  end

  switch type
    case 'numeric'
      helpstr={...
        'Hint: Numerical',...
        '  please input one relational oparation and value',...
        '  supported operations are >, <, >=, <=, ==, ~='};
      examplestr='>10';
    case 'char'
      helpstr={...
        'Hint: Charactor',...
        '  please input regular expression.',...
        'See also : regexp'};
      examplestr='(flieA)|(fileD)';
    otherwise
      helpstr={'Unsuported key-type'};
      examplestr='';
  end
  set(hs.txt_equation_help,'String',helpstr);
  if ~isempty(examplestr)
    set(hs.edt_equation,'String',examplestr,'Enable','on','UserData',type);
  else
    set(hs.edt_equation,'String','Unsupported','Enable','off');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Group-Filter-Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_into_Callback(h,ev,hs) %#ok
% Make Filter for make-group
keys=get(hs.pop_key,'String');

% ds : Display String
% gf : Group-Filter
gf.key=keys{get(hs.pop_key,'Value')};
if get(hs.rdb_list,'Value')
  gf.type='list';
  vl=get(hs.lbx_key,'Value');
  st=get(hs.lbx_key,'String');
  kk=get(hs.lbx_key,'UserData');
  st=st(vl);
  gf.value=kk(vl);
  ds=sprintf('%s:',gf.key);
  if length(gf.value)<4
    for ii=1:length(gf.value)
      ds=[ds ' ' st{ii}];
    end
  else
    for ii=1:3
      ds=[ds ' ' st{ii}];
    end
    ds=[ds '...'];
  end

elseif get(hs.rdb_eq,'Value')
  % for equatio
  gf.type='equation';
  gf.equation=get(hs.edt_equation,'String');
  if strcmp(get(hs.edt_equation,'Enable'),'off')
    errordlg('Uneffective equation');
    return;
  end
  try
    % try to test..
    type0=get(hs.edt_equation,'UserData');
    switch type0
      case 'numeric'
        xx=eval([' rand(4) ' gf.equation]);
        if ~isequal(size(xx),[4,4])
          errordlg('Bad equation');
        end
      case 'char'
        ii=regexp({'hoge','hage'},gf.equation);
        if ~isequal(size(cellfun('isempty',ii)),[1,2])
          errordlg('Bad equation');
        end
      otherwise
        error('Unknown type');
    end
  catch
    % if error
    errordlg('Bad Equation');
    return;
  end
  ds=sprintf('%s: %s',gf.key,gf.equation);
else
  % never occur
  error('Unknown radiobox selected');
end

if get(hs.rdbAND,'value')==1
	gf.condition = 'and';
	ds=['cond:' ds];
else
	gf.condition = 'or';
	ds=['' ds];
end

%------------
% update
%------------
lgf=get(hs.lbx_info,'UserData');
lds=get(hs.lbx_info,'String');
if isempty(lgf)
  lgf={gf};
  lds={ds};
else
  lgf{end+1}=gf;
  lds{end+1}=ds;
end
set(hs.lbx_info,'String',lds,'UserData',lgf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Base Group (set)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edt_GroupName_Callback(h,ev,hs) %#ok
% do noting
function lbx_info_Callback(h,ev,hs) %#ok
% do noting
function psb_remove_Callback(h,ev,hs) %#ok
% remove group-filter
lds=get(hs.lbx_info,'String');
if isempty(lds)
  beep;return;
end
lgf=get(hs.lbx_info,'UserData');
vl =get(hs.lbx_info,'Value');
lgf(vl)=[];lds(vl)=[];
if isempty(lds)
  lds='Empty';
end
if vl>length(lds), vl=length(lds);end
set(hs.lbx_info,'Value',vl,'String',lds,'UserData',lgf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ckb_usecomplement_Callback(h,ev,hs) %#ok
v=get(h,'Value');
if v
  set(hs.edt_GroupName2,'Visible','on');
else
  set(hs.edt_GroupName2,'Visible','off');
end

function edt_GroupName2_Callback(h,ev,hs) %#ok
% do noting



% --- Executes on button press in rdbAND.
function rdbAND_Callback(hObject, eventdata, handles)
set(handles.rdbOR,'value',0);
set(handles.rdbAND,'value',1);

% --- Executes on button press in rdbOR.
function rdbOR_Callback(hObject, eventdata, handles)
set(handles.rdbAND,'value',0);
set(handles.rdbOR,'value',1);


