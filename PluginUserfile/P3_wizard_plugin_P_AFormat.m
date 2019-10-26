function varargout = P3_wizard_plugin_P_AFormat(fnc,varargin)
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

% $Id: P3_wizard_plugin_P_AFormat.m 180 2011-05-19 09:34:28Z Katura $

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
if ~isfield(mydata,'P_Aformat')
  %-------
  % Create 
  %-------
  myhs.txt_title    = uicontrol(hs.figure1,...
    'Style','text',...
    'Units','Normalized','Position',[0.2, 0.78, 0.3,0.05],...
    'HorizontalAlignment','left',...
    'String','Execution Format',...
    'BackgroundColor',[1 1 1]);
  myhs.ckb_ezmode   = uicontrol(hs.figure1,...
    'Style','checkbox',...
    'Units','Normalized','Position',[0.5, 0.78, 0.3,0.05],...
    'HorizontalAlignment','left',...
    'Value',1,...
    'String','Replace',...
    'Callback','P3_wizard_plugin_P_AFormat(''ckb_ezmode_Callback'',gcbo,gcbf)',...
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
    'String','ex.) [hdata, data] = ui_myplugin(hdata, data, a, b)',...
    'BackgroundColor',[1 1 1]);
  myhs.frm_legend  =uicontrol(hs.figure1,...
    'Style','Frame',...
    'Units','Normalized','Position',[0.29, 0.21, 0.58,0.38]);
  myhs.txt_legend  =uicontrol(hs.figure1,...
    'Style','Text',...
    'Units','Normalized','Position',[0.3, 0.23, 0.56,0.35],...
    'HorizontalAlignment','left',...
    'MAX',10,...
    'String',{'==Reserved-Word==',...
    '  hdata  : POTATo Data (Header)',...
    '  data   : POTATo Data ',...
    '  curdata: Current-Status-Data',...
    '  objdata: Object-Data'});
  
  mydata.P_Aformat=myhs;
else
  set([mydata.P_Aformat.txt_title;...
    mydata.P_Aformat.ckb_ezmode;...
    mydata.P_Aformat.edt_format;...
    mydata.P_Aformat.txt_example;...
    mydata.P_Aformat.frm_legend;...
    mydata.P_Aformat.txt_legend],'Visible','on');
end


function mydata=ClosePage(hs,mydata)
% 
set([mydata.P_Aformat.txt_title;...
  mydata.P_Aformat.ckb_ezmode;...
  mydata.P_Aformat.edt_format;...
  mydata.P_Aformat.txt_example;...
  mydata.P_Aformat.frm_legend;...
  mydata.P_Aformat.txt_legend],'Visible','off');

if mydata.page_diff<0,return;end
[mydata, emsg]=get_Functions(mydata,...
  get(mydata.P_Aformat.edt_format,'String'));
if emsg
  mydata.emsg=emsg;
  error(emsg);
end
mydata.AO_Replace=get(mydata.P_Aformat.ckb_ezmode,'Value');
if 0,disp(hs);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ckb_ezmode_Callback(h,fh)
% Change Replace Check-Box
mydata=getappdata(fh,'SettingInfo');
if get(h,'Value')
  set(mydata.P_Aformat.txt_legend,...
    'String',{'==Reserved-Word==',...
    '  hdata  : POTATo Data (Header)',...
    '  data   : POTATo Data ',...
    '  curdata: Current-Status-Data',...
    '  objdata: Object-Data'});
else
  set(mydata.P_Aformat.txt_legend,...
    'String',{'==Reserved-Word==',...
    '  hdata  : POTATo Data (Header)',...
    '  data   : POTATo Data ',...
    '  curdata: Current-Status-Data',...
    '  objdata: Object-Data',...
    '----------------------',...
    '  hout   : Draw-Object-Handles'});
end

function [mydata,emsg]=get_Functions(mydata,fexp)
% Get Function-Format
emsg='';
fformat.String=fexp;
%---------------------------
% get Return Variable
%---------------------------
p     = findstr(fexp, '=');
if isempty(p),
  fformat.retValue='';
  % function part
  f = fexp; 
else
  [s e]  = regexp(fexp(1:p-1), '[a-zA-Z\[][\w:(){},\]\s]*');
  if length(s)== 1 && length(e)==1,
    fformat.retValue = fexp(s(1):e(1));
  else
    emsg='The description of Return-Value is wrong.';
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

% Empty Function : Error
if isempty(fname)
  emsg='No Function to execute.';
  return;
end

fformat.Function = fname;

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
      if s(i)>1 && strcmp(farg(s(i)-1),'.'),continue;end
      if isvarname(arg1)==1
        if any(strcmp(fformat.arglist, arg1)),continue;end
        if strcmp('hdata', arg1)==0 &&...     % delete 'hdata', 'data'
            strcmp('data' , arg1)==0 &&...
            strcmp('curdata' , arg1)==0 &&...
            strcmp('objdata' , arg1)==0 &&...
            strcmp('hout' , arg1)==0
          fformat.arglist{end+1}=arg1;
        elseif ~any(strcmp(fformat.reserved_arglist,arg1))
          fformat.reserved_arglist{end+1}=arg1;
        end
      end
    end
  end
end
mydata.UiFunction=fformat;
return;

