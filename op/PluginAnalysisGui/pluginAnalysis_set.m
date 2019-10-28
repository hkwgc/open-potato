function varargout = pluginAnalysis_set(varargin)
% PLUGINANALYSIS_SET M-file for pluginAnalysis_set.fig
%      PLUGINANALYSIS_SET, by itself, creates a new PLUGINANALYSIS_SET or raises the existing
%      singleton*.
%
%      H = PLUGINANALYSIS_SET returns the handle to a new PLUGINANALYSIS_SET or the handle to
%      the existing singleton*.
%
%      PLUGINANALYSIS_SET('Property','Value',...) creates a new PLUGINANALYSIS_SET using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to pluginAnalysis_set_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PLUGINANALYSIS_SET('CALLBACK') and PLUGINANALYSIS_SET('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PLUGINANALYSIS_SET.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pluginAnalysis_set

% Last Modified by GUIDE v2.5 09-Dec-2005 14:45:56


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pluginAnalysis_set_OpeningFcn, ...
                   'gui_OutputFcn',  @pluginAnalysis_set_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before pluginAnalysis_set is made visible.
function pluginAnalysis_set_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for pluginAnalysis_set
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.figure1, 'Color',    [0.703 0.763 0.835]);
set(handles.psb_ok,  'Enable', 'on', 'Visible', 'on');

% --- Outputs from this function are returned to the command line.
function varargout = pluginAnalysis_set_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

function figure1_KeyPressFcn(hObject, eventdata, handles)
% Key Pres Function
%  OSP Default Key-bind.
  osp_KeyBind(hObject, eventdata, handles,mfilename);
return; % KeyPressFcn

function figure1_DeleteFcn(hObject, eventdata, handles)
% Delete Function:
%  Change view of OSP-Main-Controller.
try,
  osp_ComDeleteFcn;
end

% --- Executes on button press in psb_ok.
function psb_ok_Callback(hObject, eventdata, handles)
   % Get information
   fname = get(handles.edit_name, 'String');     % name of wrapfile 
   type  = get(handles.pop_type,  'Value');      % type number ==
                                                 % popmenu Value
   [curpath, psname]=fileparts(which('pluginAnalysis_set'));
   %[mfile mpath] = uiputpluginfile;
   [mfile mpath] = uiputpluginfile(3, fname);    % 3:Analysis Plugin
   mfname = [mpath filesep mfile];               % OSP/APluginGuiDir/PluginGui_fname.m

   %if isempty(mfile),
   if mfile==0,return;end

   %  -- Create M-file
   wfid = fopen(mfname, 'w');
   try
     create_pluginwrap_analysis1(fname, wfid, type);
   catch
     fclose(wfid);
     rethrow(lasterror);
   end
   fclose(wfid);
   %  -- Copy Fig-file
   ffile     = strrep(mfile,'.m','.fig');
   ffname    = [mpath filesep ffile]; 
   basefname = [curpath filesep 'PluginGui_base.fig']; 
   command=['cp ' basefname ' ' ffname];
   unix(command);

   % -- Check M-file
   edit(mfname);

return;


function create_pluginwrap_analysis1(fname, wfid, type)

   %  -- Open GUI template file

   rfid = fopen('PluginGui_base.m','r');
   try

     while 1,
       aline = fgetl(rfid);
       if ~ischar(aline), break;end
       aline = strrep(aline, 'PluginGui_base', ['PluginGui_' fname]);
       aline = strrep(aline, 'Display Name', fname );
       aline = strrep(aline, 'Type Number', num2str(type));

       fprintf(wfid, '%s\n', aline);
     end
     fprintf(wfid, '\n');
   catch
     fclose(rfid);
     rethrow(lasterror);
   end
   fclose(rfid);

return;

