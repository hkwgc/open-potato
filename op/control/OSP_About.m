function varargout = OSP_About(varargin)
% About OSP : show OSP Information
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
% -------------------------------------
%
% OSP_ABOUT M-file for OSP_About.fig
% 
%  OSP_ABOUT('Property','Value',...) 
%    creates a new OSP_ABOUT or raises the existing singleton*.
%  + Property : {'Version','Ver','version'}
%       show Value as a Version (numerical)
%  + Property : {'AddInfo'}
%       show Value as a Additional Information
%  + Property : {'BgC'}
%       Set Background Color
%  + Close    : 
%       Value
%
% -----------------------------------------
% You can change this Figure & GUI as you like
%  See also: GUIDE, GUIDATA, GUIHANDLES

% -- Information -
%   If your Version of Matlab is 
%
% Bugs : mail-to : shoji-masanori@hitachi-ul.co.jp
% 


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% Original Author : Masanori Shoji
% create : 2004.10.14
% $Id: OSP_About.m 180 2011-05-19 09:34:28Z Katura $
%

% Last Modified by GUIDE v2.5 16-Nov-2004 23:15:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OSP_About_OpeningFcn, ...
                   'gui_OutputFcn',  @OSP_About_OutputFcn, ...
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


% --- Executes just before OSP_About is made visible.
function OSP_About_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OSP_About (see VARARGIN)

% Choose default command line output for OSP_About
handles.output = hObject;
guidata(hObject, handles);

%  Print Additional 'Property','Value'
bg_color=[1 1 1];     % Basic BackGround Color
for vargID=1:2:length(varargin)
    % Argument Transform
    prptyName  = varargin{vargID};
    prptyValue = varargin{vargID+1};
    if isempty(prptyValue), continue; end
    
    switch prptyName
        
        case {'Version','Ver','version'}  % Version Set
            if isstr(prptyValue)
                try, prptyValue=str2num(prptyValue);end
            end
            try
                set(handles.txt_version, ...
                    'String',sprintf('Version : %4.2f',prptyValue), ...
                    'Visible','on');
            end % Not Catch 
            
        case {'AddInfo'}  % Module Information or Additional Data
            try
                set(handles.txt_addinfo, ...
                    'String',prptyValue, ...
                    'Visible','on');
            end % Not Catch 
            
        case {'BgC'}       % BackGroudn Color
            if isnumeric(prptyValue) && length(prptyValue(:))==3
                bg_color=prptyValue(:)';     % Basic BackGround Color
                lbc=find(bg_color < 0); bg_color(lbc)=0;
                hbc=find(bg_color > 1); bg_color(hbc)=1;
                clear lbc hbc;
            end
            
        case {'Close'}   % Close
            close;

        otherwise
            errordlg(' About OSP Input Error');
            return;
    end % Switch
end % Argument Loop
clear prptyName prptyValue;

% Set Color & Text-Property
set(hObject,'Color',bg_color);
text_h0=findobj(hObject,'Style','text');
for tid=1:length(text_h0);
    set(text_h0(tid),'BackgroundColor',bg_color);
%     try
%         set(text_h0(tid),'BackgroundColor','none');
%     catch
%         set(text_h0(tid),'BackgroundColor',bg_color);
%     end
end
clear tet_h0 tid;

% If Waiting Responce
if isempty(getappdata(handles.figure1, 'Run'))
    setappdata(handles.figure1, 'Run',1);
else
    figure(hObject);  return; % for saving time
end

% -- Plot Matlab Log --
%set(hObject,'Renderer','OpenGL');
lo=load('logo.mat');
axes(handles.matlab_logo);
set(handles.matlab_logo,...
    'DrawMode', 'fast', ...
    'CameraPosition', [-193.4013 -265.1546  220.4819],...
    'CameraTarget',[26 26 10], ...
    'CameraUpVector',[0 0 1], ...
    'CameraViewAngle',9.5, ...
    'DataAspectRatio', [1 1 .9],...
    'Visible','off', ...
    'XLim',[1 51], ...
    'YLim',[1 51], ...
    'ZLim',[-13 40]);
lo_obj=surf(lo.L,lo.R);colormap(lo.M);
set(lo_obj,'LineStyle','none');axis off;


% UIWAIT makes OSP_About wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OSP_About_OutputFcn(hObject, eventdata, handles)
try
    varargout{1} = handles.output;
end
% delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
%uiresume(handles.figure1);
close;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
%     uiresume(handles.figure1);
% else
%     delete(hObject);
% end
delete(hObject);

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp=get(hObject,'CurrentKey');
if isequal(tmp,'escape') || ...
        isequal(tmp,'return')        
    close;
    % uiresume(handles.figure1);
end    

