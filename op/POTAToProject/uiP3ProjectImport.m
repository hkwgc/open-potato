function varargout = uiP3ProjectImport(varargin)
% UIP3PROJECTIMPORT : Import Data
%      UIP3PROJECTIMPORT, by itself, creates a new UIP3PROJECTIMPORT or raises the existing
%      singleton*.
%
%      H = UIP3PROJECTIMPORT returns the handle to a new UIP3PROJECTIMPORT or the handle to
%      the existing singleton*.
%
%      UIP3PROJECTIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIP3PROJECTIMPORT.M with the given input arguments.
%
%      UIP3PROJECTIMPORT('Property','Value',...) creates a new UIP3PROJECTIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uiP3ProjectImport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uiP3ProjectImport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uiP3ProjectImport

% Last Modified by GUIDE v2.5 11-Mar-2009 19:54:30


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%=========================================
% Begin initialization code
%=========================================
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiP3ProjectImport_OpeningFcn, ...
                   'gui_OutputFcn',  @uiP3ProjectImport_OutputFcn, ...
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
%=========================================
% End initialization code
%=========================================


% --- Executes just before uiP3ProjectImport is made visible.
function uiP3ProjectImport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to uiP3ProjectImport (see VARARGIN)

% Choose default command line output for uiP3ProjectImport
handles.output = hObject;
for ii=2:2:length(varargin)
  prop=varargin{ii-1};
  value=varargin{ii};
  switch prop
    case 'Project'
      handles.Project=value;
    case 'ImportFile'
      handles.ImportFile=value;
  end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes uiP3ProjectImport wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = uiP3ProjectImport_OutputFcn(hObject, eventdata, handles)
%set(handles.psb_OK,'Visible','off');
set(handles.text1,'String',{'Importing new Project....','Please wait for a minute'});
figure(handles.figure1);% Confine display figure (MATLAB Version 7.2)
POTAToProject('Import', handles.Project,...
  handles.ImportFile.fname, ...
  handles.ImportFile.path);
%set(handles.psb_OK,'Visible','on');
varargout{1} = handles.output;
close(hObject);

%===============================================
% Close
%===============================================
function psb_OK_Callback(hObject, eventdata, handles)
% Close Figure
close(handles.figure1);

