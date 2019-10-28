function varargout = osp_vao_background_getargument(varargin)
% osp_ViewerAxes_background make Axes-Object-Data of Background Image.
%
%   axesObject=osp_vao_background_getargument('AxesObject',axesObject);
%      Make Axes-Object-Data with Default Value axesObject.
%
% See also: GUIDE, GUIDATA, GUIHANDLES, UIWAIT, 
%           OSP_VIEWAXESOBJ_BACKGROUND, IMREAD, IMAGE, 
%           UIPUTFILE.

% Edit the above text to modify the response to help osp_vao_background_getargument

% Last Modified by GUIDE v2.5 03-Mar-2006 09:36:29

% == History ==
% original autohr : M Shoji., Hitachi-ULSI Systems Co.,Ltd.
% create : 02-Mar-2006


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @osp_vao_background_getargument_OpeningFcn, ...
                   'gui_OutputFcn',  @osp_vao_background_getargument_OutputFcn, ...
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
% End initialization code

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function osp_vao_background_getargument_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before osp_vao_background_getargument is made visible.
%   This function get Argument and set GUI-Application-Data.
%================================================================

% Choose default command line output for osp_vao_background_getargument
handles.output = [];
handles.figure1=hObject; % I love old-format.(to confine my-figure handle)
guidata(hObject, handles);

% Insert custom Axes Object and Title if specified by the user.
% Default Axes-Object (init)
axobj.str = 'Background Image';
axobj.fnc = @osp_ViewAxesObj_background;
axobj.ver = 1.00;
if(nargin > 3)
	for index = 1:2:(nargin-3),
		if nargin-3==index break, end
		switch lower(varargin{index})
			case 'title'
				set(hObject, 'Name', varargin{index+1});
			case 'axesobject'
				axobj=varargin{index+1};
			otherwise,
				warning(['Ignore Input Property: ' , ...
						varargin{index}]);
		end
	end
end
setappdata(handles.figure1,'InputAxesObject',axobj);
if isfield(axobj,'imgfile') && ~isempty(axobj.imgfile), 
	% save-format : Path
	set(handles.edit_path,'String',axobj.imgfile);
	edit_path_Callback(handles.edit_path,[],handles);
end
if isfield(axobj,'imgdata') && ~isempty(axobj.imgdata),
	% save-format : InnerData
	exe_preview(handles,'imagedata',axobj.imgdata);
end
				
% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
if 1,
	% delete if we it
	FigPos=get(0,'DefaultFigurePosition');
	OldUnits = get(hObject, 'Units');
	set(hObject, 'Units', 'pixels');
	OldPos = get(hObject,'Position');
	FigWidth = OldPos(3);
	FigHeight = OldPos(4);
	if isempty(gcbf)
		ScreenUnits=get(0,'Units');
		set(0,'Units','pixels');
		ScreenSize=get(0,'ScreenSize');
		set(0,'Units',ScreenUnits);
		
		FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
		FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
	else
		GCBFOldUnits = get(gcbf,'Units');
		set(gcbf,'Units','pixels');
		GCBFPos = get(gcbf,'Position');
		set(gcbf,'Units',GCBFOldUnits);
		FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
				(GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
	end
	FigPos(3:4)=[FigWidth FigHeight];
	set(hObject, 'Position', FigPos);
	set(hObject, 'Units', OldUnits);
end

% Show Preview
axes(handles.axes1);
title('previewe');


% waiting for OK/Cancel
set(handles.figure1,'WindowStyle','modal');
uiwait(handles.figure1);


function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Executes when user attempts to close figure1.
try
	if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
		% The GUI is still in UIWAIT, us UIRESUME
		uiresume(handles.figure1);
	else
		% The GUI is no longer waiting, just close it
		delete(handles.figure1);
	end
catch
	delete(gcbf); % Close!Close!
end


function figure1_KeyPressFcn(hObject, eventdata, handles)
% Executes on key press over figure1 with no controls selected.

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said Canncel by hitting escape
	% is as same as Default.
    uiresume(handles.figure1);
	return;
end    
%! This function is not use OSP-Default Keybind,
%! Because keybind make OSP difficault to edit OSP. 

function varargout = osp_vao_background_getargument_OutputFcn(hObject, eventdata, handles)
% Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
varargout{1} = handles.output;
delete(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Contents ( Uiresume )
%   : set Output Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psb_OK_Callback(hObject, eventdata, handles)
% 'OK' to set AxesObject to Ountut-Data.
% Executes on button pres in psb_OK.
handles.output = getAxesObject(handles);
guidata(hObject, handles);
uiresume(handles.figure1);

function psb_cancel_Callback(hObject, eventdata, handles)
% 'Cancel' to set empty to Ountut-Data.
% Executes on button pres in psb_Cancel.
handles.output = []; guidata(hObject, handles);
uiresume(handles.figure1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Contents ( Uiresume )
%   : set Output Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_SaveFormat_Callback(hObject, eventdata, handles)
function edit_path_Callback(hObject, eventdata, handles)
fname=get(hObject,'String');
exe_preview(handles,'File',fname);

function psb_brows_Callback(hObject, eventdata, handles)
% Change Path by Brows
%
% Usinge Application Data : None
% Lower : 
%    edit_path_Callback :
%
%    informats          : to get file-format
%    uigetfile, length, set, isequal, isempty, ...
%
% Get effective file format
fm=imformats;
filespce={};
for idx=1:length(fm),
	wk='';
	for idx2=1:length(fm(idx).ext),
		wk= [wk ';*.' fm(idx).ext{idx2}];
	end
	if isempty(wk), continue; end
	filespce{end+1,1}= wk(2:end);
	filespce{end,  2}= char(fm(idx).description);
end
[f, p]=uigetfile(filespce,'Backgroud Image');
if isequal(f,0),return;	end

set(handles.edit_path,'String',[p filesep f], ...
	'ForegroundColor','black');
try
	edit_path_Callback(handles.edit_path,[],handles);
	set(handles.edit_path,'UserData',[p filesep f]);
catch
	st=get(handles.edit_path,'UserData');
	set(handles.edit_path,'String',st, ...
		'Forgroundcolor','red');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI Contents ( Uiresume )
%   : set Output Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axobj=getAxesObject(handles);

axobj=getappdata(handles.figure1,'InputAxesObject');
imfile=get(handles.edit_path,'UserData');
imdata=getappdata(handles.figure1,'ImageData');
% get SaveMode
str=get(handles.pop_SaveFormat,'String');
axobj.SaveFormat=str{get(handles.pop_SaveFormat,'Value')};

flg=false;
if strcmp(axobj.SaveFormat,'Path') && ...
		~isempty(imfile) && ischar(imfile)
	% save-format : Path
	axobj.imfile = imfile;
	flg=true;
else,
	axobj.imfile = '';
end

if strcmp(axobj.SaveFormat,'InnerData') && ...
		~isempty(imdata)
	% save-format : InnerData
	axobj.imgdata = imdata;
	flg=true;
else
	axobj.imgdata = [];
end
% error check
if ~flg,
	error('Image Data is not set yet.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exe_preview(handles,mode,data)
% Preview plot
if nargin==1,
	mode='Reload';
end

% Change Data to Image Data.
emsg = 'OSP Error : osp_vao ./exe_preview : too few arguments';
switch mode,
	case 'Reload',
		if nargin<2,
			data=getappdata(handles.figure1,'ImageData');
		end
	case 'File',
		if nargin<2, error(emsg); end
		data=imread(data);
	case 'imagedata',
		if nargin<2, error(emsg); end
	otherwise,
		error(['OSP Error : Cannot Reload : undefined mode ' mode]);
end
axes(handles.axes1);
image(data); axis off;
setappdata(handles.figure1,'ImageData',data);
% Save Mode : OK
if ~isempty(data)
	v=get(handles.figure1,'Visible');
	set(handles.pop_SaveFormat,'Visible','on');
	if strcmp(mode,'imagedata'),
		set(handles.pop_SaveFormat,'Value',2);
	end
end


function axes1_CreateFcn(hObject, eventdata, handles)
% Not in use, but to avoid save original axes.
%   the GUIDE(v2.5) might save Figure after execute openingfunction.
%   So clear axes object at first, or default axes will rest forever.
% M. Shoji. 03-Mar-2006.
axes(hObject);cla; set(hObject,'Visible','off');


