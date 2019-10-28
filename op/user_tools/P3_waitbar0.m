function varargout = P3_waitbar0(varargin)
%  P3_WAITBAR0 Display wait bar.
%   This function is for figure control.
%   Use P3_waitbar.
% See also: P3_waitbar.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @P3_waitbar0_OpeningFcn, ...
                   'gui_OutputFcn',  @P3_waitbar0_OutputFcn, ...
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


%##########################################################################
% Init Functions
%##########################################################################
function P3_waitbar0_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% Choose default command line output for P3_waitbar0
handles.output = hObject;

%--------------------
% Draw Patch
%--------------------
X=0;
%set(hObject,'CurrentAxes',handles.waitbar);
axes(handles.waitbar); %(bug?? upper code is not work well sometime??)
px = [0 X 0 X; X 1 X 1; 0 X X 1];
py = [0 0 1 1; 0 0 1 1; 1 1 0 0];
c  = ones([3,4,3]);c(:,[1,3],2:3)=0;
ph=patch(px,py,c);
set(ph,'LineStyle','none');
handles.patch=ph;
  
% Update handles structure
guidata(hObject, handles);

function varargout = P3_waitbar0_OutputFcn(hObject, eventdata, handles)  %#ok
% Output: Figure-Handle.
varargout{1} = handles.output;


%##########################################################################
% Create Fcn's
%##########################################################################
function waitbar_CreateFcn(hObject, eventdata, handles) %#ok
axis off;

%##########################################################################
% Callbacks
%##########################################################################
function psb_OK_Callback(hObject, eventdata, handles) %#ok
% Delete
delete(handles.figure1);

