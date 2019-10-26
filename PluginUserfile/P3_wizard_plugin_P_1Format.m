function varargout = P3_wizard_plugin_P_1Format(fnc,varargin)
% P3_WIZARD_PLUGIN : Wizard for making Plugin
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% $Id: P3_wizard_plugin_P_1Format.m 180 2011-05-19 09:34:28Z Katura $

% In no input : Help
if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else
  feval(fnc, varargin{:});
end

if 0
  % Sub function List
  createBasicInfo;
  OpenPage;
  ClosePage;
end

function data=createBasicInfo
data.islast=false;

function mydata=OpenPage(hs,mydata)
% Open Page

% Debugmode
if 0
  disp('------- Debug Mode is Running -----');
  disp(C__FILE__LINE__CHAR);
  if isfield(mydata,'P1_Fformat')
    fn=fieldnames(mydata.P1_Fformat);
    for idx=1:length(fn)
      try
        delete(mydata.P1_Fformat.(fn{idx}));
      catch
        disp(lasterr);
      end
    end
    mydata=rmfield(mydata,'P1_Fformat');
  end
end

if ~isfield(mydata,'P1_Fformat')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.7,0.05],...
    'HorizontalAlignment','left',...
    'String','Execution Format',...
    'BackgroundColor',[1 1 1]);
  myhs.edt_format=uicontrol(hs.figure1,...
    'Style','edit',...
    'Units','Normalized','Position',[0.22, 0.68, 0.64,0.1],...
    'HorizontalAlignment','left',...
    'FontSize',11,...
    'String','',...
    'BackgroundColor',[1 1 1]);
  myhs.txt_example  =uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.22, 0.58, 0.64,0.1],...
    'HorizontalAlignment','left',...
    'String','ex.) fdata = max(data);',...
    'BackgroundColor',[1 1 1]);
  myhs.frm_legend  =uicontrol(hs.figure1,...
    'Style','Frame',...
    'Units','Normalized','Position',[0.29, 0.16, 0.58,0.43]);
  myhs.txt_legend  =uicontrol(hs.figure1,...
    'Style','Text',...
    'Units','Normalized','Position',[0.3, 0.18, 0.56,0.4],...
    'HorizontalAlignment','left',...
    'MAX',10,...
    'String',{'==Reserved-Word==',...
    '  hdata, data  : POTATo Data ',...
    '  fhdata, data : 1st-LVL-ANA POTATo Data',...
    });  
  mydata.P1_Fformat=myhs;
else
  set([mydata.P1_Fformat.txt_title;...
    mydata.P1_Fformat.edt_format;...
    mydata.P1_Fformat.txt_example;...
    mydata.P1_Fformat.txt_legend;...
    mydata.P1_Fformat.frm_legend;...
    ],'Visible','on');
end

function mydata=ClosePage(hs,mydata)
% 
set([mydata.P1_Fformat.txt_title;...
  mydata.P1_Fformat.edt_format;...
  mydata.P1_Fformat.txt_example;...
  mydata.P1_Fformat.txt_legend;...
  mydata.P1_Fformat.frm_legend;...
  ],'Visible','off');

if mydata.page_diff<0,return;end

% Execution Format
[mydata, emsg]=get_Functions(mydata,...
  get(mydata.P1_Fformat.edt_format,'String'));
if emsg
  mydata.emsg=emsg;
  error(emsg);
end
if 0,disp(hs);end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mydata,emsg]=get_Functions(mydata,fexp)
% Get Function-Format
emsg='';
fformat.String=fexp;
%---------------------------
% get Return Variable
%---------------------------
p     = findstr(fexp, '=');
if isempty(p),
  emsg='Need fdata for return value.';
  return;
else
  fformat.retValue = fexp(1:p-1);
  fformat.argout   = {};
  [s e]  = regexp(fexp(1:p-1), '[a-zA-Z]\w*');
  fdflag=false;
  for i=1:length(s),
    arg1=fexp(s(i):e(i));
    if s(i)>1 && strcmp(fexp(s(i)-1),'.'),continue;end
    if isvarname(arg1)==1
      if any(strcmp(fformat.argout, arg1)),continue;end
      fformat.argout{end+1}=arg1;
      if strcmp('fdata', arg1)==1
        fdflag=true;
      end
    end
  end
  if ~fdflag
    emsg='Need fdata for return value.';
    return;
  end
  % function part
  f = fexp(p+1:length(fexp));
end

%---------------------------
% get Evaluae Function Name.
%---------------------------
p     = findstr(f, '(');
if ~isempty(p),
  if p~=1,
    fname = f(1:p-1);
    farg  = f(p:end);
  else
    emsg='The description of Function''s name  is lack.';
    return;
  end
else
  fname = f;
  farg  = '';
end
fformat.Function = fname;
fformat.arg      = farg;

% Empty Function : Error
if isempty(fname)
  emsg='No Function to execute.';
  return;
end

fformat.arglist={};
fformat.reserved_arglist={};
if ~isempty(farg)
  %-----------------
  % Blacket Check ()
  %-----------------  
  op = findstr(farg, '(');
  cl = findstr(farg, ')');
  if length(op) ~= length(cl),
    emsg='Syntax Error : in argument ().';
    return;
  end
  
  %-----------------
  % Single-Quotation Check ''
  %-----------------  
  ap=findstr(farg, '''');
  if ~isempty(ap),
    for i=length(ap):-2:2
      farg = strcat(farg(1:ap(i-1)-1),...
        farg(ap(i)+1:length(farg)));
    end
  end
  [s e]=regexp(farg, '[a-zA-Z]\w*');
  %  Set list
  if ~isempty(s),
    for i=1:length(s),
      arg1=farg(s(i):e(i));
      if isvarname(arg1)==1
        if any(strcmp(fformat.arglist, arg1)),continue;end
        if strcmp('hdata', arg1)==0 &&...     % delete 'hdata', 'data'
            strcmp('data' , arg1)==0 &&...
            strcmp('fhdata', arg1)==0 &&...
            strcmp('fdata', arg1)==0
          fformat.arglist{end+1}=arg1;
        elseif ~any(strcmp(fformat.reserved_arglist,arg1))
          fformat.reserved_arglist{end+1}=arg1;
        end      
      end
    end
  end
end
mydata.UiFunction=fformat;
% Debugmode
if 0
  disp('------- Debug Mode is Running -----');
  disp(C__FILE__LINE__CHAR);
  if isfield(mydata,'P1_Fformat')
    fn=fieldnames(mydata.P1_Fformat);
    for idx=1:length(fn)
      try
        delete(mydata.P1_Fformat.(fn{idx}));
      catch
        disp(lasterr);
      end
    end
    mydata=rmfield(mydata,'P1_Fformat');
  end
end

return;

