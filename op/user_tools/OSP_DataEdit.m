function varargout = OSP_DataEdit(varargin)
% OSP_DATAEDIT M-file for OSP_DataEdit.fig
%      OSP_DATAEDIT, by itself, creates a new OSP_DATAEDIT or raises the existing
%      singleton*.
%
%      H = OSP_DATAEDIT returns the handle to a new OSP_DATAEDIT or the handle to
%      the existing singleton*.
%
%      OSP_DATAEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OSP_DATAEDIT.M with the given input arguments.
%
%      OSP_DATAEDIT('Property','Value',...) creates a new OSP_DATAEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OSP_DataEdit_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OSP_DataEdit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OSP_DataEdit

% Last Modified by GUIDE v2.5 06-Jan-2005 17:35:37

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original auther : Masanori Shoji
% create : 2005.01.11
% $Id $

%  Application-defined Data
%     'DataInp'   : Input Data
%     'DataOut'   : Output Data
%     'EditPoint' : Edit Point( in Dimention 1 )
%     'EditNum'   : Number of Edit Data

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OSP_DataEdit_OpeningFcn, ...
    'gui_OutputFcn',  @OSP_DataEdit_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT







% ====================================================
%  GUI Function
% ====================================================

%~~~~~~~~~~~~~~~~~~~~~~~~
% Opening Function
%~~~~~~~~~~~~~~~~~~~~~~~~
function OSP_DataEdit_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for OSP_DataEdit
% 23-Dec-2004 M. Shoji

%% == Set Output Data == %%
handles.output = 'Error';    % To save Memory : Return->EditData
guidata(hObject, handles);

%% == Read Arguments == %%
flg=0;      % Check Argument
emsg={};    % Error Message
editnum=10; % Edit Number in One Data
if mod(length(varargin),2)==1
    OSP_LOG('err',...
        {[myfilename ': Argument Error'],...
            ['No Property Data exist']}); % Inner Message
    error('No Property Data');
end
data=[];
for ii=1:2:length(varargin)
    switch varargin{ii}
        case 'Data'
            flg=bitor(flg,1);  % bit : 0001 
            data=varargin{ii+1};
            if ndims(data)~=3
                error('Dimention of data must be 3');
            end
            setappdata(hObject,'DataInp',data);
            try
                dim2str=cell(size(data,2),1);
                for ii2=1:size(varargin{ii+1},2)
                    dim2str{ii2}=num2str(ii2);
                end
                set(handles.pop_Dim2,'String',dim2str);
                clear ii2 dim2str;
            end
        case 'Tag'
            flg=bitor(flg,2);  % bit : 0010
            %            setappdata(hObject,'Tag',varargin{ii+1});
            try
                set(handles.txt_Dim2,'String',varargin{ii+1}{2});
            end
            try
                set(handles.txt_dim3,'String',varargin{ii+1}{3});
            end
            try
                axes(handles.axes1);
                set(handles.axes1,'Box','on');
                xlabel(varargin{ii+1}{1});
            end
            
        case 'TagDim3'
            flg=bitor(flg,4);  % bit : 0100
            try
                set(handles.pop_Dim3,'String',varargin{ii+1});
            end
            
        case 'EditNum'
            try
                editnumtmp=varargin{ii+1};
                if ~isnumeric(editnumtmp)
                    error('EditNum must be integer'); % no effect
                end
                editnum = editnumtmp(1);
                clear editnumtmp;
            end
            
        otherwise
            emsg{end+1}=[mfilename, ': Unknown Property', varargin{ii}];
            warning(emsg{end});
    end
end
if ~isempty(emsg)
    OSP_LOG('warn',emsg); % Inner Message
end

% No Tag
if bitand(flg,2)==0
    flg = flg +2;
    % warning('No Tag : Use Default Tag');
end

if flg~=7
    OSP_LOG('err',...
        {['Imput argument Error : Too few Argument for' mfilename],...
            ['    Argument Flag : ' num2str(flg)]});
    error(['Imput argument Error : Too few Argument for' mfilename]);
end

setappdata(hObject,'EditNum',editnum); %% Define
clear emsg flg;

% === Argument Check ==
tag_dim3=get(handles.pop_Dim3,'String');
if length(tag_dim3)~=size(data,3)
    warndlg(' 3Dimension Tag  Size Error : Set Default');
    tag2=cell(size(data,3),1);
    untId=1;
    for ii=1:size(data,3)
        try
            tag2{ii}=tag_dim3{ii};
        catch
            tag2{ii}=['Untitled(' num2str(untId) ')'];
            untId = untId+1;
        end
    end
    set(handles.pop_Dim3,'String',tag2);
    clear tag2 untId;
end
clear tag_dim3;

%% == Data-Edit Form == %%
setappdata(hObject,'EditPoint',1); %% Define
setappdata(hObject,'DataOut',data);
if size(data,1)==1
    set(handles.sld_Dim1,'Visible','off');
else
    set(handles.sld_Dim1,'Min',-size(data,1));
    set(handles.sld_Dim1,'Max',-1);
    set(handles.sld_Dim1,'Value',-1);
end

loadEditData(handles);

% == Ploat =-
axes(handles.axes1);
axes1_Data(handles);
axes1_Range(handles);

% == Common Color =-
bc = [1 1 1]; % Basic Corlor
set(hObject,'Color','white');
% txth=findobj(hObject,'Style','text');
% for ii=1:length(txth)
%     set(txth(ii),'BackgroundColor',bc);
% end


% UIWAIT makes OSP_DataEdit wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);

return;




% --- Outputs from this function are returned to the command line.
function varargout = OSP_DataEdit_OutputFcn(hObject, eventdata, handles)
varargout{1} = getappdata(handles.figure1,'DataOut');  % name
varargout{2} = get(handles.pop_Dim3,'String');         % Tag
delete(handles.figure1);
return;




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        uiresume(handles.figure1);
    else
        delete(handles.figure1);
    end
catch
    delete(hObject);   % fig - open;
end
% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)

curKey=get(hObject,'CurrentKey');
switch curKey
    case 'uparrow'
        idxx = get(handles.listbox1,'Value');     % Display Data Index
        idxx = idxx-1;
        if idxx > 0
            set(handles.listbox1,'Value',idxx);
        end
        return;
        
    case 'downarrow'
        strx = get(handles.listbox1, 'String');   % Display Data
        idxx = get(handles.listbox1,'Value');     % Display Data Index
        idxx = idxx+1;
        if size(strx,1)>= idxx
            set(handles.listbox1,'Value',idxx);
        end
        return;
        
    case 'pageup'
        ep=get(handles.sld_Dim1,'Value') + getappdata(handles.figure1,'EditNum');
        if get(handles.sld_Dim1,'MAX') < ep
            ep = get(handles.sld_Dim1,'MAX');
        end
        set(handles.sld_Dim1,'Value',ep);
        sld_Dim1_Callback(handles.sld_Dim1,[],handles);
        
    case 'pagedown'        
        ep=get(handles.sld_Dim1,'Value') - getappdata(handles.figure1,'EditNum');
        if get(handles.sld_Dim1,'MIN') > ep
            ep = get(handles.sld_Dim1,'MIN');
        end
        set(handles.sld_Dim1,'Value',ep);
        sld_Dim1_Callback(handles.sld_Dim1,[],handles);
        
    case 'escape'
        psb_cancel_Callback(handles.psb_cancel, eventdata, handles);
    case 'return'
        return;

 otherwise
  % == OSP Common KeyBind ==
  try, osp_KeyBind(hObject, eventdata, handles); end

end

return;




% ====================================================
% Create Function
% ====================================================
function pop_Dim2_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
return;

function pop_Dim3_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
return;

function listbox1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
return;

function sld_Dim1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[.9 .9 .9]);

function etxt_importName_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

function etxt_editData_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');


% ====================================================
% Callback Function
% ====================================================

% == Reload Only ==

% ----------- Dim 1 ------------
function sld_Dim1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
setappdata(handles.figure1,'EditPoint',-round(get(hObject,'Value')));
loadEditData(handles);   % Reload Data
axes1_Range(handles);


% ----------- Dim 2 ------------
function pop_Dim2_Callback(hObject, eventdata, handles)
loadEditData(handles);   % Reload Data
axes1_Data(handles);
return;

% ----------- Dim 3 ------------
function pop_Dim3_Callback(hObject, eventdata, handles)
loadEditData(handles);   % Reload Data
axes1_Data(handles);
return;

% ----------- Selected Point ------------
function listbox1_Callback(hObject, eventdata, handles)
%
% Warning : Do not Use "loadEditData" In this function!
% 
contents = get(hObject,'String');
try
    set(handles.etxt_editData, 'String', contents{get(hObject,'Value')});
catch
    set(handles.etxt_editData, 'String', ' -- Out of Range --');
end
return;

% ----------- Import Function -------------
function etxt_importName_Callback(hObject, eventdata, handles)
% psb_import_Callback(handles.psb_import, [], handles);

function psb_import_Callback(hObject, eventdata, handles)

data=getappdata(handles.figure1, 'DataOut');
tag =get(handles.pop_Dim3,'String');
sz=size(data);
basename=get(handles.etxt_importName,'String');
if isempty(basename), basename='';end
S=uiimport('-file');
if isempty(S)
    return;
end
name=fieldnames(S);
for nid=1:length(name)
    x=getfield(S,name{nid});
    sz2=size(x);
    try
        if sz2(1:2) == sz(1:2)
            flg=0;
            if length(sz2)==3
                for ii=1:sz2(3)
                    data(:,:,end+1)=squeeze(x(:,:,ii));
                    tag{end+1}=[basename name{nid} '(' num2str(ii) ')'];
                end
                flg=1;
            elseif length(sz2)==2
                data(:,:,end+1)=x;
                tag{end+1}=[basename name{nid}];
                flg=1;
            end
            OSP_LOG('note',[' Add Variable named ' name{nid}]);
            msgbox([' Add Variable named ' name{nid}]);
        end
    catch
        lasterr
    end
end

% Save
setappdata(handles.figure1, 'DataOut',data);
set(handles.pop_Dim3,'String',tag);
return;


% ----------- Edit Function (1) -------------
function etxt_editData_Callback(hObject, eventdata, handles)
% psb_editData_Callback(handles.psb_editData, [], handles);

function psb_editData_Callback(hObject, eventdata, handles)

% ==== Get Editing Data ==== 
try
    edtData0 = get(handles.etxt_editData, 'String');        % Get Edited Data
    edtData  = str2num(edtData0);

%     if ~isnumeric(edtData)
%         try, edtData=eval(edtData0); end
%     end

    if isempty(edtData) || ~isnumeric(edtData)
        error(' Edit Data must be Numerical');
    end

catch
    edtData  = NaN;
%    error(' Edit Data must be Numerical');
end


% ==== ListBox Renew ====
contents              = get(handles.listbox1, 'String');   % Display Data
contentsIdx           = get(handles.listbox1,'Value');     % Display Data Index
contents{contentsIdx} = edtData0;                          % Change Display Data
set(handles.listbox1, 'String',contents);

% ==== Save : DataOut ====
data=getappdata(handles.figure1, 'DataOut');
st=max(1,getappdata(handles.figure1,'EditPoint'));        % StartPoint of Display Data
st = st + contentsIdx - 1;                                % Display Point Add;

if st > size(data,1)
    OSP_LOG('perr',[mfilename ': Data was Broken : Overflow']);
    error([mfilename ': Data was Broken']);
elseif st <= 0
    OSP_LOG('perr',[mfilename ': Data was Broken : Underflow']);
    error([mfilename ': Data was Broken']);
end

data(st,...
    get(handles.pop_Dim2,'Value'),...
    get(handles.pop_Dim3,'Value'))...
    = edtData;
setappdata(handles.figure1, 'DataOut',data);

% ==== Next Data ====
strx = get(handles.listbox1, 'String');   % Display Data
idxx = get(handles.listbox1,'Value');     % Display Data Index
idxx = idxx+1;
if size(strx,1)< idxx
    idxx=1;
end
set(handles.listbox1,'Value',idxx);
axes1_Data(handles);
return;


% ----------- Edit Function (2) -------------
% Do not use : WorkSpace I/O : 
function psb_openvar_Callback(hObject, eventdata, handles)
editData=loadEditData(handles);
sz=editData;
x=openvar('editData',hObject');

sz2=size(x);

if sz2==sz
    data=getappdata(h,'DataOut');
    sz1=size(data,1);
    st=max(1,getappdata(h,'EditPoint'));
    ed=min(sz1,st+getappdata(h,'EditNum')-1);
    
    data(st:ed,get(handles.pop_Dim2,'Value'),get(handles.pop_Dim3,'Value')) =editData(:);
else
    errordlg(' Edit Error : Data Size is changed : Save to OSP_ErrorEditHB.mat');
    save('OSP_ErrorEditHB.mat','editData');
end
return;

% -------------- Reset ---------------------
function psb_reset_Callback(hObject, eventdata, handles)
h=handles.figure1;

% Reset ViewPoint
setappdata(h,'EditPoint',1);
set(handles.pop_Dim2,'Value',1);
set(handles.pop_Dim3,'Value',1);

% Reset Data
data=getappdata(h,'DataInp');
setappdata(h,'DataOut',data);
sz3=size(data,3);
clear data;

% Reset Tag
% Overflow Check
id =get(handles.pop_Dim3,'Value');
if id > sz3
    set(handles.pop_Dim3,'Value',sz3);
end

tag=get(handles.pop_Dim3,'String');
if length(tag)~=sz3
    tag2=cell(sz3,1);
    %     disp(['Sz3 : ' num2str(sz3)] );
    %     disp('Tag  : ');
    %     disp(tag);
    %     disp([' size : ' num2str(size(tag)));
    
    for ii=1:sz3
        tag2{ii}=tag{ii};
    end
    %     disp('Tag 2: ');
    %     disp(tag2);
    
    set(handles.pop_Dim3,'String',tag2);
end

loadEditData(handles);
axes1_Data(handles);

% === Exit ===
% ------- Aplly ---------
function psb_aplly_Callback(hObject, eventdata, handles)
% handles.output =getappdata(handles.figure1,'DataOut');    % End with Chaneg Aplly

guidata(handles.figure1, handles);
uiresume(handles.figure1);
return;


% -------- Cancel --------
function psb_cancel_Callback(hObject, eventdata, handles)
% handles.output =getappdata(handles.figure1,'DataInp');     % End with no chaneg
psb_reset_Callback(handles.psb_reset, eventdata, handles)
guidata(handles.figure1, handles);
uiresume(handles.figure1);
return;


% == Othrer ==
% -------- Save As Mat-File --------
function psb_SaveData_Callback(hObject, eventdata, handles)
data= getappdata(handles.figure1,'DataOut');  % name
tag= get(handles.pop_Dim3,'String');         % Tag
% for ii=1:length(tag)
% 	eval([ tag{ii} '= data(:,:,ii);']);
% end
% uisave(tag);
uisave({'data','tag'});


% ====================================================
% Local Function
% ====================================================

%-----------------------
function varargout=loadEditData(handles)
h=handles.figure1;
% Load Edit Data & Reload listbox1
data=getappdata(h,'DataOut');
sz1=size(data,1);
st=max(1,getappdata(h,'EditPoint'));
ed=min(sz1,st+getappdata(h,'EditNum')-1);

dataedit=data(st:ed,...
    get(handles.pop_Dim2,'Value'),...
    get(handles.pop_Dim3,'Value'));
clear st ed data;

dataedit=squeeze(dataedit);

% Only Want to get editing data
if nargout == 1
    varargout{1}=dataedit;
    return;
end

% Not to Overfllow
if length(dataedit) < get(handles.listbox1,'Value');
    set(handles.listbox1,'Value',length(dataedit));
end


str0=cell(length(dataedit),1);
for ii=1:length(dataedit)
    try
        str0{ii}=num2str(dataedit(ii));
    catch
        str0{ii}=dataedit(ii);
    end
end

set(handles.listbox1,'String',str0);
% Warning : Check Inifinity - Loop !!
listbox1_Callback(handles.listbox1, [], handles); % Reload
return;

%======================
% Axes Function
%======================
%~~~~~~~~~~~~
% Data Print 
%~~~~~~~~~~~~
function axes1_Data(handles)
h=handles.figure1;
% Load Edit Data & Reload listbox1
data=getappdata(h,'DataOut');

y=data(:,...
    get(handles.pop_Dim2,'Value'),...
    get(handles.pop_Dim3,'Value'));
clear data;
y=squeeze(y);


h=handles.axes1;

axes(h);
hold on;
x=[1:length(y)]';

dataH=findobj(h,'Tag','Data');
if isempty(dataH)
    dataH=plot(x,y,'b.');
    set(dataH,'Tag','Data');
else
    set(dataH,'XData',x);
    set(dataH,'YData',y);
end
hold off;

% Range ReDraw
rangeLineHandle=findobj(h,'Tag','Range');
delete(rangeLineHandle);
axis tight;	
axes1_Range(handles);
return;

%~~~~~~~~~~~~
% Data Propaty
%~~~~~~~~~~~~
% == Set Marker
function pop_marker_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
function pop_marker_Callback(hObject, eventdata, handles)
data_h=findobj(handles.axes1,'Tag','Data');
mrk=get(handles.pop_marker,'String');
if ~isempty(data_h)
    set(data_h, ...
        'Marker',mrk{get(handles.pop_marker,'Value')});
end


% == Set Color ==
function pop_color_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
function pop_color_Callback(hObject, eventdata, handles)
data_h=findobj(handles.axes1,'Tag','Data');
clr=get(hObject,'String');
if ~isempty(clr)
    set(data_h, 'Color',clr{get(hObject,'Value')});
end

% == Set Line ==
function pop_line_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
function pop_line_Callback(hObject, eventdata, handles)
data_h=findobj(handles.axes1,'Tag','Data');
clr=get(hObject,'String');
if ~isempty(clr)
    set(data_h, 'LineStyle',clr{get(hObject,'Value')});
end

%~~~~~~~~~~~~
% Range Print
%~~~~~~~~~~~~
function axes1_Range(handles,mode)
h=handles.axes1;
if nargin == 1
	mode=0;
end

% -- Butiful Mode --
if mode
	rangeLineHandle=findobj(h,'Tag','Range');
	delete(rangeLineHandle);
end

axes(h);
hold on;
% axis tight;
rng0=axis;

% Make X
x(1)=max(1,getappdata(handles.figure1,'EditPoint'));
x(2)=min(rng0(2),x(1)+getappdata(handles.figure1,'EditNum')-1);

% Make Y
rng1=rng0(4)-rng0(3);
y(1) = rng0(3) + rng1*0.1;


%% Modify x,y ( new)
if rng0(2)-rng0(1) < 500
    y(2) = y(1);
else
    x=x([1 1 2 2])';
    y(2) = rng0(3) + rng1*0.9;
    y=y([2 1 1 2])';
end

if mode
	rangeLineHandle=[];
else
	rangeLineHandle=findobj(h,'Tag','Range');
end

if isempty(rangeLineHandle)
	rangeLineHandle=plot(x,y,'r-');
	set(rangeLineHandle, ...
		'Tag','Range',...
		'LineWidth',1);
else
	set(rangeLineHandle,...
		'XData',x,...
		'YData',y);
end
hold off;
return;
