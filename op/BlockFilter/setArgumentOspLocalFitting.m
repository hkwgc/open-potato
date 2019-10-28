function varargout = setArgumentOspLocalFitting(varargin)
% SETARGUMENTOSPLOCALFITTING make Argument Data of LocalFitting.
% This function must be called from OSP. 
% Function need OSP_DATA.
%
% Upper FilterDef_LocalFitting.
%-------------------------------------------------
% Return Value.
%   if OK button press,Return value is argData,
%   or return empty value.
%
% Ref) Relating functions.
%   Set Default : OpeningFnc (now:empty),
%   Set argData : psb_ok_Callback,
%   Set Empty   : psb_cancel_Callback,
%-------------------------------------------------
%
% See also : OSP_DATA

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% original author : Masanori Shoji
% create : 2005.06.04
% $Id: setArgumentOspLocalFitting.m 180 2011-05-19 09:34:28Z Katura $

% Last Modified by GUIDE v2.5 10-Jun-2005 19:05:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setArgumentOspLocalFitting_OpeningFcn, ...
                   'gui_OutputFcn',  @setArgumentOspLocalFitting_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function setArgumentOspLocalFitting_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for setArgumentOspLocalFitting
handles.output = [];

% Update handles structure
guidata(hObject, handles);

isUFPdefault=true;

if(nargin > 3)
	for index = 1:2:(nargin-3),
		if nargin-3==index break, end
		switch lower(varargin{index})
			case 'title',
				set(hObject, 'Name', varargin{index+1});
			case 'string',
				set(handles.txt_title, 'String', varargin{index+1});
			case 'argdata',
				try
					argData = varargin{index+1};
					if ~isstruct(argData), continue; end
					if isfield(argData,'Degree'),
						set(handles.edt_deg,'String', num2str(argData.Degree));
					end
					if isfield(argData,'UnFitPeriod'),
						set(handles.edt_fitx, 'String',argData.UnFitPeriod);
						%set(handles.ckb_noreplace,'Value',1)
						isUFPdefault=false;
					end
				end % no catch for tyr
				
			case 'mfile_eval',
				try,
					mfile_eval = varargin{index+1};
					axes1_CreateFcn(handles.axes1, [],handles,mfile_eval);
				catch,
					errordlg(lasterr);
					return;
				end
				
		end % switch
	end % loop of argument
end % is there argument?

% ------------------------- By my research,(Linux, MATLAB Version 6.5.1
% (R13) ) :: axes1 CreateFcn might be not called,
%    when GUI already complied.(may be for fastness)
%
% So we need to call Create-Function for Axes, 
%  to refresh other variable.
%
% ( 'compile' is something wrong experssion.
%   'construct' is better expression? I do not know but something such kind
%   of words.)
% ------------------------- by M.Shoji at 10-Jun-2005.
if ~exist('mfile_eval', 'var'),
	axes1_CreateFcn(handles.axes1,[], handles);
end

if isUFPdefault,
	stm_rng      = getappdata(hObject,'StimulationRange');
	if isempty(stm_rng) , stm_rng=0; end
  if stm_rng<0.2
    edt_fitx_str = '[m1:m1+2.0]';
  else
    edt_fitx_str = '[m1:m2+5.0]';
  end
	%edt_fitx_str = [ '[0:' num2str(stm_rng+5.0) ']'];
	set(handles.edt_fitx, 'String',edt_fitx_str);
end
% UIWAIT makes setArgumentOspLocalFitting wait for user response (see
% UIRESUME)
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);
return;

function varargout = setArgumentOspLocalFitting_OutputFcn(hObject, eventdata, handles)
% Set Return Value.
%   if OK button press,Return value is argData, or return empty value.
%
% Ref) Default     : OpeningFnc (now:empty), Set argData : psb_ok_Callback,
% Empty       : psb_cancel_Callback,
varargout{1} = handles.output;
delete(handles.figure1);



function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Executes when user attempts to close figure1.
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
	uiresume(handles.figure1);
else
	delete(handles.figure1);
end


function figure1_KeyPressFcn(hObject, eventdata, handles)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
	% User said no by hitting escape
	handles.output = [];
	% Update handles structure
	guidata(hObject, handles);
	uiresume(handles.figure1);
end    

if isequal(get(hObject,'CurrentKey'),'return')
	uiresume(handles.figure1);
end    


function psb_ok_Callback(hObject, eventdata, handles)
% Executes on button press in 'OK'
%   Check OspLocalFitting argData. if argData is correct,
%     Return argData, and close figure.
%   else,
%     output warning dialog

% == Check & get argData == Degree
argData.Degree = edt_deg_Callback(handles.edt_deg,[],handles);
if isempty(argData.Degree),flg = true; return; end

% Filter X
argData.UnFitPeriod = edt_fitx_Callback(handles.edt_fitx,[],handles);
if isempty(argData.UnFitPeriod),flg = true; return; end

% -- Set Return Value, and close. --
handles.output = argData;
guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'), uiresume(handles.figure1);
else, delete(handles.figure1); end

return;

function psb_cancel_Callback(hObject, eventdata, handles)
% Executes on button press in 'Cancel'
%   Return Null, and close figure.
handles.output = []; guidata(hObject, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting'), uiresume(handles.figure1);
else, delete(handles.figure1); end

return;

function varargout=edt_fitx_Callback(hObject, eventdata, handles),
% Executes on change edit-texst 'Filter X'. check if Filter X is numerical.
%  if there is output-value, output  setting degree.

if nargout==1,  varargout{1}=[]; end
str = get(hObject,'String');
str0=str;  % Keep st/m1/m2/ed :mail 2010/12/15
if isempty(str),
	errordlg('Set Some value.');return;
end

% Replace ":" to  ":sampling_period/1000:"
%    Defalut SP...
%if get(handles.ckb_noreplace,'Value')~=1
if 1
  % No replace
  % Meeting on 2011.01.14:
  unitstr = getappdata(handles.figure1,'SamplingPeriod');
  unitstr = num2str(unitstr/1000);
  %unitstr0= 'hdata.samplingperiod/1000';
	if isempty(unitstr),
		unitstr = '0.1';
		warndlg('Cannot get Sampling Period.');
	end
	
	pos=strfind(str,':');
	for pi = pos(end:-1:1),
		str = [str(1:pi-1) ...
				':' unitstr ':' ...
				str((pi+1):end)];
  end

  if 0
    pos=strfind(str0,':');
    for pi = pos(end:-1:1),
      str0 = [str0(1:pi-1) ...
        ':' unitstr0 ':' ...
        str0((pi+1):end)];
    end
  end
end


% ==. 
timing = getappdata(handles.figure1,'Timing');
%  (st) : timeing(1)
str=strrep(str,'st',num2str(timing(1)));
%  (m1) : 0
str=strrep(str,'m1','0');
%  (m2) : timing(end-1)
str=strrep(str,'m2',num2str(timing(end-1)));
%  (ed) : timeing(end)
str=strrep(str,'ed',num2str(timing(end)));
% unit
unit0 = getappdata(handles.figure1,'SamplingPeriod');
str=strrep(str,'hdata.samplingperiod',num2str(unit0));

% get fitx
fitx = str2num(str);
if isempty(fitx), 
	errordlg('Filter Period : Set Numerical Value');
	return;
end
str=str0; % recover str: mail 2010/12/15 *

if 0
	timing = getappdata(handles.figure1,'Timing');
	max_x = max(fitx(:));
	if max_x>x(end),
		errordlg('Filter Period : Too Large value include');
		return;
	end
	if min_x<x(1),
		errordlg('Filter Period : Too little vale include');
		return;
	end
end

if nargout==1
	% varargout{1} = fitx;
	varargout{1} = str;
end


function varargout=edt_deg_Callback(hObject, eventdata, handles)
% Executes on change edit-texst 'Degree'. check if Degree is real positive
% integers.
%  if there is output-value,
%    output  setting degree.
if nargout==1
	varargout{1} = [];
end

str = get(hObject,'String');
if isempty(str),
	errordlg('Degree is empty.'); 
	return;
end

% Degree is Real-Positive-Integer?
styleck=regexp(str, '^\s*\d+\s*$');
if isempty(styleck),
	errordlg('Set Real-Positive-Integers for Degree.');
	return;
end

if nargout==1
	varargout{1} = round(str2double(str));
end
return;


function axes1_CreateFcn(hObject, eventdata, handles, mfile_eval)
% --- Executes during object creation, after setting all properties.

% no data exist
if nargin<=3,
	setappdata(handles.figure1,'StimulationRange',0);
	return;
end

% Read Block Data
[data, hdata] = scriptMeval(mfile_eval, 'bdata', 'bhdata');
if isempty(data), error('No Block Data exist'); end


% -- set unit --
setappdata(handles.figure1,'SamplingPeriod', hdata.samplingperiod);

% --- SET Block-Range --
blk_rng = [hdata.stim(1), size(data,2)-hdata.stim(2)+1];
blk_rng = blk_rng * hdata.samplingperiod/1000;

% --- SET Stimk-Range --
stm_rng = hdata.stim(2) - hdata.stim(1) + 1;
stm_rng = stm_rng *  hdata.samplingperiod/1000;
setappdata(handles.figure1,'StimulationRange',stm_rng);

% --- Ploting --
axes(hObject); cla;
x = [-blk_rng(1); 0; 0; stm_rng; stm_rng; stm_rng+blk_rng(2)];
setappdata(handles.figure1,'Timing',x);
y = [          0; 0; 1;       1;       0; 0]; 
h_line=plot(x,y,'b--');
set(hObject,'YTick',[]);
set(h_line,'LineWidth',3);
% X Tick
xtick  = [-blk_rng(1), 0, stm_rng, stm_rng+blk_rng(2)];
sz=xtick(end)-xtick(1);
text(xtick(1)+0.01*sz, 0.1, 'st'); 
text(xtick(2),         1.1, 'm1'); 
if (stm_rng>=5)
  text(xtick(3),         1.1, 'm2');
end
text(xtick(4)-0.1*sz,  0.1, 'ed'); 
set(hObject,'XTick',xtick);


xlabel('[sec]');
axis([x(1),x(end), -0.01, 1.2]);

return;

