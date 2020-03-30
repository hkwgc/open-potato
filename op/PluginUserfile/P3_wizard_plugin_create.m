function P3_wizard_plugin_create(mydata,fname,mode)
% Create Plugin-Wrap Function
%
% Syntax :P3_wizard_plugin_create(mydata,fname, mode)
%
% 
% See also make_mfile, P3_wizard_plugin.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% author : Hiroshi Kawaguchi
% create : 2019-11-12
% 
% This fuction is based on the following Filter-Pllugin-Wrap 
% functions of POTATo 3.8.50. 
% - P3_wizard_plugin_create_M1.m % 1st-Level-Analysis Plug-in
% - P3_wizard_plugin_create_MA.m % Viewer Axis-Object
% - P3_wizard_plugin_create_MF.m % the others
% Masanori Shoji is the original auther of these files.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch mode
    case 'MA'; main_MA(fname,mydata)
    case 'MF'; main_MF(fname,mydata)
    case 'M1'; main_M1(fname,mydata)
    otherwise ; error('Invarid mode.')
end

% main for MA ===========
function main_MA(fname,mydata)
try
  [~,fname]=make_mfile('fopen', fname,'w');
  make_mfile('indent_fcn','setsize',2);
  
  makeHeader(fname,mydata);
  makeCreateBasicInfo_MA(mydata);
  makeGetArgument_MA(mydata);
  makeDraws(mydata);
catch
  make_mfile('fclose');
  rethrow(me);
end
make_mfile('fclose');

% main for MF ===========
function main_MF(fname,mydata)
try
  [~,fname]=make_mfile('fopen', fname,'w');
  make_mfile('indent_fcn','setsize',2);
  
  makeHeader(fname,mydata);
  makeCreateBasicInfo_MF(mydata);
  makeGetArgument_MF(mydata);
  makeWrite_MF(mydata);
catch me 
  make_mfile('fclose');
  rethrow(me);
end
make_mfile('fclose');

% main for M1  ===========
function main_M1(fname, mydata)
%--------------------
% Initialize
%--------------------
% ----> get Name of FLA Functiono
if ~isfield(mydata,'Name_1stLvlAna')
  % Make 1st-Level-Ana Data
  nlist={};
  myname=genvarname(['flafnc_' mydata.PluginName]);
  while ~isempty(which(myname))
    nlist{end+1}=myname;
    myname=genvarname(myname,nlist);
  end
  % use input dialog
  if 1
    myname0=myname;
    while 1
      a=inputdlg({'1st-LVL-Ana Function Name :'},...
        'Input 1st-LVL-Ana Function',...
        1,{myname});
      % Cancel
      if ~isempty(a),
        a={myname0};
        break;
      end
      % OK
      if ~isempty(which(a{1}))
        break;
      end
      % Comment
      s=questdlg('Do you want to overwrite?','1st-LVL-ANA Function','Yes','No','Yes');
      if strcmpi(s,'Yes'),break;end
    end
  end
  mydata.Name_1stLvlAna=a{1};
end

%--------------------
% PluginWrapP1_
%--------------------
try
  make_mfile('fopen', fname,'w');
  make_mfile('indent_fcn','setsize',2);
  
  makeHeader(fname,mydata);
  makeCreateBasicInfo_M1(mydata);
  makeGetArgument_M1(mydata);
  [p f]=fileparts(fname);
  makeWrite_M1(mydata,f);
catch
  make_mfile('fclose');
  edit(fname);
  rethrow(lasterror);
end
make_mfile('fclose');
%disp(C__FILE__LINE__CHAR);error('Unpopulated');

%--------------------
% flafnc_
%--------------------
fname2=[p filesep mydata.Name_1stLvlAna '.m'];
try
  make_mfile('fopen', fname2,'w');
  make_mfile('indent_fcn','setsize',2);
  
  makeHeader2(fname2);
  makeCreateBasicInfo2(mydata);
  makeMake(mydata);
catch
  make_mfile('fclose');
  edit(fname2);
  rethrow(lasterror);
end
make_mfile('fclose');
if get(mydata.P_Save.ckb_open,'Value')
  edit(fname2);
end
%disp(C__FILE__LINE__CHAR);error('Unpopulated');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Header 
% similar for MA, M1, MF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeHeader(fname,mydata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,f]=fileparts(fname);
if 0,disp(p);clear p;end
% Function Top
make_mfile('with_indent',['function varargout=' f '(fnc,varargin)']);
% Help Information
P3_wizard_plugin_P_Help('writeHelpTop',mydata);
make_mfile('with_indent',...
  {'',...
  ['% Edit the above text to modify the response to help ' f],...
  '',...
  ['% Made by ' mfilename ' $Revision: 1.0 $'],...
  ['%              at ' date]});
make_mfile('with_indent','');

make_mfile('with_indent',{...
  '%====================',...
  '% In no input : Help',...
  '%====================',...
  'if nargin==0,',...
  '  POTATo_Help(mfilename);',...
  '  return;',...
  'end'});
make_mfile('with_indent','');

% Launch
make_mfile('code_separator',1);
make_mfile('with_indent',{...
  'if nargout',...
  '  [varargout{1:nargout}] = feval(fnc, varargin{:});',...
  'else',...
  '  feval(fnc, varargin{:});',...
  'end'});
make_mfile('code_separator',1);
make_mfile('with_indent',{...
  '% Function List',...
  'if 0',...
  '  createBasicInfo;',...
  '  getArgument;',...
  '  drawstr;',...
  '  draw;',...
  'end',...
  'return;'});
make_mfile('with_indent','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for MA ===========
function makeCreateBasicInfo_MA(mydata)
make_mfile('code_separator',1);
make_mfile('with_indent','function bi=createBasicInfo');
% Help Information
make_mfile('with_indent',...
  {'% Basic Information to control this function'});
make_mfile('code_separator',1);

% ======================================
% Make Name
% ======================================
make_mfile('with_indent',sprintf('bi.MODENAME=''%s'';',mydata.PluginName));
make_mfile('with_indent','bi.fnc=mfilename;');
make_mfile('with_indent','bi.ver=1.0;');
make_mfile('with_indent','bi.ccb=''all'';');
make_mfile('with_indent','return;');
make_mfile('with_indent','');

% for MF ===========
function makeCreateBasicInfo_MF(mydata)

make_mfile('code_separator',1);
make_mfile('with_indent','function bi=createBasicInfo');
% Help Information
make_mfile('with_indent',...
  {'% Basic Information to control this function'});
make_mfile('code_separator',1);

% ======================================
% Make Name
% ======================================
make_mfile('with_indent',sprintf('bi.name=''%s'';',mydata.PluginName));
make_mfile('with_indent','bi.Version=1.0;');

% ======================================
% Make Region
% ======================================
s=' ';
if mydata.Region_Continuous
  s=[s '2 '];
end
if mydata.Region_Block
  s=[s '3 '];
end
if length(s)>=4
  s(1)='[';s(end)=']';
end
make_mfile('with_indent',['bi.region=' s ';']);


if isfield(mydata,'FilterOption')
  % ======================================
  % Filter Disp Kind
  % ======================================
  if isfield(mydata.FilterOption,'DispKind')
    make_mfile('with_indent','% Display-Kind');
    make_mfile('with_indent','DefineFilterDispKind;');
    s='';
    for idx=1:length(mydata.FilterOption.DispKind)
      s=[s mydata.FilterOption.DispKind{idx} '+'];
    end
    s(end)=';';
    make_mfile('with_indent',['bi.DispKind=' s]);
  else
    make_mfile('with_indent','bi.DispKind=0;');
  end
  
  % ======================================
  % Discription
  % ======================================
  if isfield(mydata.FilterOption,'Description')
    make_mfile('with_indent',sprintf('bi.Description=''%s'';',...
      mydata.FilterOption.Description));
  end
  
  % ======================================
  % Resize-Option
  % ======================================
  if isfield(mydata.FilterOption,'ResizeOption')
    fn=fieldnames(mydata.FilterOption.ResizeOption);
    for idx=1:length(fn)
      make_mfile('with_indent',sprintf('bi.ResizeOption.%s=''%s'';',...
        fn{idx},mydata.FilterOption.ResizeOption.(fn{idx})));
    end
  end
else
  make_mfile('with_indent','bi.DispKind=0;');
end
make_mfile('with_indent','return;');
make_mfile('with_indent','');

% for M1 ===========
function makeCreateBasicInfo_M1(mydata)
% Make createBasicInfo
make_mfile('code_separator',1);
make_mfile('with_indent','function bi=createBasicInfo');
% Help Information
make_mfile('with_indent',...
  {'% Basic Information to control this function'});
make_mfile('code_separator',1);

% ======================================
% Make Name
% ======================================
make_mfile('with_indent',sprintf('bi.name=''%s'';',mydata.PluginName));
make_mfile('with_indent','bi.Version=1.0;');

% ======================================
% Make Region
% ======================================
s=' ';
if mydata.Region_Continuous
  s=[s '2 '];
end
if mydata.Region_Block
  s=[s '3 '];
end
if length(s)>=4
  s(1)='[';s(end)=']';
end
make_mfile('with_indent',['bi.region=' s ';']);


% ======================================
% Filter Disp Kind
% ======================================
make_mfile('with_indent','% Display-Kind');
make_mfile('with_indent','DefineFilterDispKind;');
make_mfile('with_indent','bi.DispKind=F_1stLvlAna;');

if isfield(mydata,'FilterOption')
  % ======================================
  % Discription
  % ======================================
  if isfield(mydata.FilterOption,'Description')
    make_mfile('with_indent',sprintf('bi.Description=''%s'';',...
      mydata.FilterOption.Description));
  end
  
  % ======================================
  % Resize-Option
  % ======================================
  if isfield(mydata.FilterOption,'ResizeOption')
    fn=fieldnames(mydata.FilterOption.ResizeOption);
    for idx=1:length(fn)
      make_mfile('with_indent',sprintf('bi.ResizeOption.%s=''%s'';',...
        fn{idx},mydata.FilterOption.ResizeOption.(fn{idx})));
    end
  end
end
make_mfile('with_indent','return;');
make_mfile('with_indent','');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for MA ===========
function makeGetArgument_MA(mydata)
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function objdata=getArgument(objdata)')
% ********************************
% Help Information
% ********************************
make_mfile('with_indent','% get Argument of this Filter');
if isfield(mydata,'ArgumentProp')
  for idx=1:length(mydata.ArgumentProp)
    make_mfile('with_indent',...
      sprintf('%%      objdata.arg_%s : %s (%s)',...
      mydata.ArgumentProp(idx).name,...
      mydata.ArgumentProp(idx).note,...
      mydata.ArgumentProp(idx).type));
  end
end
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','bi=createBasicInfo;');
make_mfile('with_indent','objdata.str=bi.MODENAME;');
make_mfile('with_indent','objdata.fnc=bi.fnc;');
make_mfile('with_indent','objdata.ver=bi.ver;');

% ********************************
% No argument Check
% ********************************
if ~isfield(mydata,'ArgumentProp') || isempty(mydata.ArgumentProp)
  make_mfile('with_indent','return;');
  make_mfile('with_indent','');
  return;
end
make_mfile('with_indent','');

% ********************************
% Read Argument
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Reading Argument');
make_mfile('code_separator',2);
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    ['if ~isfield(objdata,''.arg_'  arg.name ''')']);
  switch arg.type
    case {'Character','Cell array'}
      wk=strrep(arg.val,'''','''''');
      make_mfile('with_indent',...
        ['  objdata.arg_' arg.name ' = ''' wk ''';']);
    otherwise
      make_mfile('with_indent',...
        ['  objdata.arg_' arg.name ' = ''' arg.val ''';']);
      if 0
        make_mfile('with_indent',...
          ['  objdata.arg_' arg.name ' = ' arg.val ';']);
      end
  end
  make_mfile('with_indent','end');
end
make_mfile('with_indent','');

% ********************************
% Display Prompt
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Display Prompt');
make_mfile('code_separator',2);
make_mfile('with_indent','prompt = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         ''Enter : %s [%s]'',...',arg.note,arg.type));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% Default Value
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Default Value');
make_mfile('code_separator',2);
make_mfile('with_indent','def    = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         objdata.arg_%s,...',arg.name));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% == Open Input-Dialog
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Open Input-Dialog');
make_mfile('code_separator',2);
make_mfile('with_indent','while 1,');
make_mfile('indent_fcn','down');
make_mfile('code_separator',3);
make_mfile('with_indent','% input-dlg');
make_mfile('code_separator',3);
make_mfile('with_indent','def = inputdlg(prompt, objdata.str, 1, def);');
make_mfile('with_indent','if isempty(def),');
make_mfile('with_indent','  objdata=[]; break; %while');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Check Argument
% ********************************
make_mfile('code_separator',3);
make_mfile('with_indent', '% Check Argument');
make_mfile('code_separator',3);
make_mfile('with_indent','emsg={};');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  
  make_mfile('with_indent',['% Check : Is ''' arg.name ''' ' arg.type '?']);
  aname  = ['objdata.arg_' arg.name];
  defstr = ['def{' num2str(idx) '}'];
  make_mfile('with_indent',[aname ' = ' defstr ';']);
  
  switch arg.type
    case 'Character'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname ' = '''''''''''';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',['  ' aname ' = ['''''''' ' aname ' ''''''''];']);
      make_mfile('with_indent', 'end');
    case 'Integer'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',['  s=regexp(' aname ',''^[0-9]+$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Integer Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Float'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',...
        ['  s=regexp(' aname ',''^[0-9]*[\.]?[0-9]*$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Float Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Cell array'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''{}'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent', '  try');
      make_mfile('with_indent',['    if ~iscell(eval(' defstr ')),']);
      make_mfile('with_indent', '      error(''Not Cell'');');
      make_mfile('with_indent', '    end');
      make_mfile('with_indent', '  catch');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Cell Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    otherwise
      make_mfile('with_indent','% TODO: ');
  end
end
make_mfile('code_separator',4);
make_mfile('with_indent','% Error Messange;');
make_mfile('code_separator',4);
make_mfile('with_indent','if isempty(emsg),break;end');
make_mfile('with_indent','eh=errordlg({''Input Data Error:'',emsg{:}},...');
make_mfile('with_indent','             [objdata.str '' : Argument'']);');
make_mfile('with_indent','waitfor(eh);');
make_mfile('with_indent','');

make_mfile('indent_fcn','up');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Output Process
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Output');
make_mfile('code_separator',2);
make_mfile('with_indent', 'if isempty(objdata)');
make_mfile('with_indent', '  objdata=[]; % ( cancel )');
make_mfile('with_indent', 'end');
make_mfile('with_indent', 'return;');
make_mfile('with_indent','');
return;

% for MF ===========
function makeGetArgument_MF(mydata)
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function fdata=getArgument(fdata,varargin)')
% ********************************
% Help Information
% ********************************
make_mfile('with_indent','% get Argument of this Filter');
make_mfile('with_indent',...
  '%     fdata.name    : defined in createBasicInfo');
make_mfile('with_indent',...
  '%     fdata.wrap    :  Pointer of this Function,');
make_mfile('with_indent',...
  '%     fdata.argData : Argument of Plug in Function.');
if isfield(mydata,'ArgumentProp') 
  for idx=1:length(mydata.ArgumentProp)
    make_mfile('with_indent',...
      sprintf('%%      argData.%s : %s (%s)',...
      mydata.ArgumentProp(idx).name,...
      mydata.ArgumentProp(idx).note,...
      mydata.ArgumentProp(idx).type));
  end
end
make_mfile('code_separator',1);
make_mfile('with_indent','');
% ********************************
% Information of M-File
% ********************************
make_mfile('with_indent','% M-File to get Before Data');
make_mfile('with_indent','% (if you want : slow)');
make_mfile('with_indent','mfile0=varargin{1}; %#ok');
make_mfile('with_indent','% Example :');
make_mfile('with_indent',...
  '% [data, hdata]=scriptMeval(mfile0, ''data'', ''hdata'');');
make_mfile('with_indent','');

% ********************************
% No argument Check
% ********************************
if ~isfield(mydata,'ArgumentProp') || isempty(mydata.ArgumentProp)
  make_mfile('with_indent','return;');
  return;
end

% ********************************
% Read Argument
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Reading Argument');
make_mfile('code_separator',2);
make_mfile('with_indent','if isfield(fdata,''argData''),');
make_mfile('with_indent','  data=fdata.argData;');
make_mfile('with_indent','else');
make_mfile('with_indent','  data=[];');
make_mfile('with_indent','end');
make_mfile('with_indent','% Default Value');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    ['if isempty(data) || ~isfield(data, '''  arg.name ''')']);
  switch arg.type
    case {'Character','Cell array'}
      wk=strrep(arg.val,'''','''''');
      make_mfile('with_indent',...
        ['  data.' arg.name ' = ''' wk ''';']);
    otherwise
      make_mfile('with_indent',...
        ['  data.' arg.name ' = ''' arg.val ''';']);
      if 0
        make_mfile('with_indent',...
          ['  data.' arg.name ' = ' arg.val ';']);
      end
  end
  make_mfile('with_indent','end');
end
make_mfile('with_indent','');

% ********************************
% Display Prompt
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Display Prompt');
make_mfile('code_separator',2);
make_mfile('with_indent','prompt = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         ''Enter : %s [%s]'',...',arg.note,arg.type));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% Default Value
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Default Value');
make_mfile('code_separator',2);
make_mfile('with_indent','def    = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         data.%s,...',arg.name));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% == Open Input-Dialog
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Open Input-Dialog');
make_mfile('code_separator',2);
make_mfile('with_indent','while 1,');
make_mfile('indent_fcn','down');
make_mfile('code_separator',3);
make_mfile('with_indent','% input-dlg');
make_mfile('code_separator',3);
make_mfile('with_indent','def = inputdlg(prompt, fdata.name, 1, def);');
make_mfile('with_indent','if isempty(def),');
make_mfile('with_indent','  data=[]; break; %while');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Check Argument
% ********************************
make_mfile('code_separator',3);
make_mfile('with_indent', '% Check Argument');
make_mfile('code_separator',3);
make_mfile('with_indent','emsg={};');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  
	make_mfile('with_indent','');
	make_mfile('with_indent',['% Check : Is ''' arg.name ''' ' arg.type '?']);
  aname  = ['data.' arg.name];
  defstr = ['def{' num2str(idx) '}'];
  make_mfile('with_indent',[aname ' = ' defstr ';']);
  
  switch arg.type
    case 'Character'
			make_mfile('with_indent','% No check for Characters');
%       make_mfile('with_indent',['if isempty(' defstr '),']);
%       make_mfile('with_indent',['  ' aname ' = '''''''''''';']);
%       make_mfile('with_indent', 'else');
%       make_mfile('with_indent',['  ' aname ' = ['''''''' ' aname ' ''''''''];']);
%       make_mfile('with_indent', 'end');
%=== comment out by TK 2011/05/09

    case 'Integer'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',['  s=regexp(' aname ',''^[0-9]+$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Integer Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Float'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',...
        ['  s=regexp(' aname ',''^[0-9]*[\.]?[0-9]*$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Float Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Cell array'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''{}'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent', '  try');
      make_mfile('with_indent',['    if ~iscell(eval(' defstr ')),']);
      make_mfile('with_indent', '      error(''Not Cell'');');
      make_mfile('with_indent', '    end');
      make_mfile('with_indent', '  catch');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Cell Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    otherwise
      make_mfile('with_indent','% TODO: ');
  end
end

make_mfile('with_indent','');
make_mfile('code_separator',4);
make_mfile('with_indent','% Error Messange;');
make_mfile('code_separator',4);
make_mfile('with_indent','if isempty(emsg),break;end');
make_mfile('with_indent','eh=errordlg({''Input Data Error:'',emsg{:}},...');
make_mfile('with_indent','             [fdata.name '' : Argument'']);');
make_mfile('with_indent','waitfor(eh);');
make_mfile('with_indent','');

make_mfile('indent_fcn','up');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Output Process
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Output');
make_mfile('code_separator',2);
make_mfile('with_indent', 'if isempty(data)');
make_mfile('with_indent', '  fdata=[]; % ( cancel )');
make_mfile('with_indent', 'else');
make_mfile('with_indent', '  fdata.argData=data;');
make_mfile('with_indent', 'end');
make_mfile('with_indent', 'return;');
make_mfile('with_indent','');
return;

% for M1 ===========
function makeGetArgument_M1(mydata)
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function fdata=getArgument(fdata,varargin)')
% ********************************
% Help Information
% ********************************
make_mfile('with_indent','% get Argument of this Filter');
make_mfile('with_indent',...
  '%     fdata.name    : defined in createBasicInfo');
make_mfile('with_indent',...
  '%     fdata.wrap    :  Pointer of this Function,');
make_mfile('with_indent',...
  '%     fdata.argData : Argument of Plug in Function.');
if isfield(mydata,'ArgumentProp') 
  for idx=1:length(mydata.ArgumentProp)
    make_mfile('with_indent',...
      sprintf('%%      argData.%s : %s (%s)',...
      mydata.ArgumentProp(idx).name,...
      mydata.ArgumentProp(idx).note,...
      mydata.ArgumentProp(idx).type));
  end
end
make_mfile('code_separator',1);
make_mfile('with_indent','');
% ********************************
% Information of M-File
% ********************************
make_mfile('with_indent','% M-File to get Before Data');
make_mfile('with_indent','% (if you want : slow)');
make_mfile('with_indent','mfile0=varargin{1}; %#ok');
make_mfile('with_indent','% Example :');
make_mfile('with_indent',...
  '% [data, hdata]=scriptMeval(mfile0, ''data'', ''hdata'');');
make_mfile('with_indent','');

% ********************************
% No argument Check
% ********************************
if ~isfield(mydata,'ArgumentProp') || isempty(mydata.ArgumentProp)
  make_mfile('with_indent','return;');
  return;
end

% ********************************
% Read Argument
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Reading Argument');
make_mfile('code_separator',2);
make_mfile('with_indent','if isfield(fdata,''argData''),');
make_mfile('with_indent','  data=fdata.argData;');
make_mfile('with_indent','else');
make_mfile('with_indent','  data=[];');
make_mfile('with_indent','end');
make_mfile('with_indent','% Default Value');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    ['if isempty(data) || ~isfield(data, '''  arg.name ''')']);
  switch arg.type
    case {'Character','Cell array'}
      wk=strrep(arg.val,'''','''''');
      make_mfile('with_indent',...
        ['  data.' arg.name ' = ''' wk ''';']);
    otherwise
      make_mfile('with_indent',...
        ['  data.' arg.name ' = ''' arg.val ''';']);
      if 0
        make_mfile('with_indent',...
          ['  data.' arg.name ' = ' arg.val ';']);
      end
  end
  make_mfile('with_indent','end');
end
make_mfile('with_indent','');

% ********************************
% Display Prompt
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Display Prompt');
make_mfile('code_separator',2);
make_mfile('with_indent','prompt = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         ''Enter : %s [%s]'',...',arg.note,arg.type));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% Default Value
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Default Value');
make_mfile('code_separator',2);
make_mfile('with_indent','def    = {...');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent',...
    sprintf('         data.%s,...',arg.name));
end
make_mfile('with_indent','         };');
make_mfile('with_indent','');

% ********************************
% == Open Input-Dialog
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Open Input-Dialog');
make_mfile('code_separator',2);
make_mfile('with_indent','while 1,');
make_mfile('indent_fcn','down');
make_mfile('code_separator',3);
make_mfile('with_indent','% input-dlg');
make_mfile('code_separator',3);
make_mfile('with_indent','def = inputdlg(prompt, fdata.name, 1, def);');
make_mfile('with_indent','if isempty(def),');
make_mfile('with_indent','  data=[]; break; %while');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Check Argument
% ********************************
make_mfile('code_separator',3);
make_mfile('with_indent', '% Check Argument');
make_mfile('code_separator',3);
make_mfile('with_indent','emsg={};');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  
  make_mfile('with_indent',['% Check : Is ''' arg.name ''' ' arg.type '?']);
  aname  = ['data.' arg.name];
  defstr = ['def{' num2str(idx) '}'];
  make_mfile('with_indent',[aname ' = ' defstr ';']);
  
  switch arg.type
    case 'Character'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname ' = '''''''''''';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',['  ' aname ' = ['''''''' ' aname ' ''''''''];']);
      make_mfile('with_indent', 'end');
    case 'Integer'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',['  s=regexp(' aname ',''^[0-9]+$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Integer Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Float'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''[]'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent',...
        ['  s=regexp(' aname ',''^[0-9]*[\.]?[0-9]*$''); %#ok']);
      make_mfile('with_indent', '  if isempty(s)');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Float Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    case 'Cell array'
      make_mfile('with_indent',['if isempty(' defstr '),']);
      make_mfile('with_indent',['  ' aname '= ''{}'';']);
      make_mfile('with_indent', 'else');
      make_mfile('with_indent', '  try');
      make_mfile('with_indent',['    if ~iscell(eval(' defstr ')),']);
      make_mfile('with_indent', '      error(''Not Cell'');');
      make_mfile('with_indent', '    end');
      make_mfile('with_indent', '  catch');
      make_mfile('with_indent',...
        ['    emsg{end+1}=''' aname ' : Is not Cell Descript.'';']);
      make_mfile('with_indent', '    emsg{end+1}=lasterr;');
      make_mfile('with_indent', '  end');
      make_mfile('with_indent', 'end');
    otherwise
      make_mfile('with_indent','% TODO: ');
  end
end
make_mfile('code_separator',4);
make_mfile('with_indent','% Error Messange;');
make_mfile('code_separator',4);
make_mfile('with_indent','if isempty(emsg),break;end');
make_mfile('with_indent','eh=errordlg({''Input Data Error:'',emsg{:}},...');
make_mfile('with_indent','             [fdata.name '' : Argument'']);');
make_mfile('with_indent','waitfor(eh);');
make_mfile('with_indent','');

make_mfile('indent_fcn','up');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ********************************
% Output Process
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','% Output');
make_mfile('code_separator',2);
make_mfile('with_indent', 'if isempty(data)');
make_mfile('with_indent', '  fdata=[]; % ( cancel )');
make_mfile('with_indent', 'else');
make_mfile('with_indent', '  fdata.argData=data;');
make_mfile('with_indent', 'end');
make_mfile('with_indent', 'return;');
make_mfile('with_indent','');
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Write
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for M1 ===========
function makeWrite_M1(mydata,fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function str=write(region,fdata)')
% ********************************
% Help Information
% ********************************
make_mfile('with_indent',['% write M-Script to perform ' mydata.PluginName]);
make_mfile('with_indent', '% Fdata is as same as getArgument''s fdata');
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','str='''';');
make_mfile('with_indent','if 0,disp(region);end');
make_mfile('with_indent','bi=createBasicInfo;');
make_mfile('with_indent','');

% ********************************
%  Header
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Header Area');
make_mfile('code_separator',2);

make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', ...
  'make_mfile(''with_indent'', [''% == '' fdata.name '' =='']);');
make_mfile('with_indent', ...
  'make_mfile(''with_indent'', sprintf(''%%  Version %f'',bi.Version));');
make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent','');

% ********************************
% Execute Area
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Exexute Area');
make_mfile('code_separator',2);
make_mfile('with_indent','make_mfile(''with_indent'', ''try'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
make_mfile('with_indent','');

% ======================================
% Argument Setting
% ======================================
if length(mydata.ArgumentProp)>1
  make_mfile('code_separator',3);
  make_mfile('with_indent','%   Argument Setting');
  make_mfile('code_separator',3);
  make_mfile('with_indent','try');
  make_mfile('indent_fcn','down');
  for idx=1:length(mydata.ArgumentProp)
    arg=mydata.ArgumentProp(idx);
    make_mfile('with_indent',sprintf(...
      'make_mfile(''with_indent'', sprintf(''%s=%%s;'',fdata.argData.%s));'...
      ,arg.name,arg.name));
  end
  make_mfile('indent_fcn','up');
  make_mfile('with_indent','catch');
  make_mfile('indent_fcn','down');
  make_mfile('with_indent','errordlg({[mfilename '': WRITE ''],lasterr});');
  make_mfile('with_indent',...
    'make_mfile(''with_indent'', [''error('''''' mfilename '' : Write Error'''');'']);');
  make_mfile('with_indent','make_mfile(''with_indent'', ''catch'');');
  make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
  make_mfile('with_indent','make_mfile(''with_indent'', ''errordlg(lasterr);'');');
  make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');
  make_mfile('with_indent','make_mfile(''with_indent'', ''end'');');
  make_mfile('indent_fcn','up');
  make_mfile('with_indent','end');
  make_mfile('with_indent','');
end

% ======================================
% Execute
% ======================================
make_mfile('code_separator',3);
make_mfile('with_indent','%   Execute');
make_mfile('code_separator',3);
fm=mydata.UiFunction;
if ~any(strcmpi(fm.argout,'fhdata'))
  make_mfile('with_indent','% Make Default Header of 1st-Level-Analysis');
  make_mfile('with_indent','make_mfile(''with_indent'',...');
  make_mfile('with_indent',[...
    '      ''fhdata=FLA_makeheader(hdata,data,'''''...
    mydata.Name_1stLvlAna ''''','...
    '''''' fname ''''');'');']);
end
s=strrep(fm.arg,'''','''''');
if ~strcmp(s(end),';'),s(end+1)=';';end
if ~isempty(s),       s(1)=[];  end
make_mfile('with_indent','make_mfile(''with_indent'',...');
make_mfile('with_indent',['           ''' fm.retValue '=' ...
  mydata.Name_1stLvlAna '(''''make'''',' s ''');']);
make_mfile('with_indent',...
  'make_mfile(''with_indent'',''DataDef2_1stLevelAnalysis(''''save'''',fhdata,fdata);'');');
make_mfile('with_indent','');
make_mfile('with_indent','');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');

% ********************************
% Error Area
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Error Area');
make_mfile('code_separator',2);
make_mfile('with_indent','make_mfile(''with_indent'', ''catch'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''errordlg(lasterr);'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''end'');');

% ********************************
% Footer
% ********************************
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent', 'return;');
return;

% for MF ===========
function makeWrite_MF(mydata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function str=write(region,fdata)')
% ********************************
% Help Information
% ********************************
make_mfile('with_indent',['% write M-Script to perform ' mydata.PluginName]);
make_mfile('with_indent', '% Fdata is as same as getArgument''s fdata');
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','str='''';');
make_mfile('with_indent','if 0,disp(region);end');
make_mfile('with_indent','bi=createBasicInfo;');
make_mfile('with_indent','');

% ********************************
%  Header
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Header Area');
make_mfile('code_separator',2);

make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', ...
  'make_mfile(''with_indent'', [''% == '' fdata.name '' =='']);');
make_mfile('with_indent', ...
  'make_mfile(''with_indent'', sprintf(''%%  Version %f'',bi.Version));');
make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent','');

% ********************************
% Execute Area
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Exexute Area');
make_mfile('code_separator',2);
make_mfile('with_indent','make_mfile(''with_indent'', ''try'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
make_mfile('with_indent','');

% ======================================
% Argument Setting
% ======================================
make_mfile('code_separator',3);
make_mfile('with_indent','%   Argument Setting');
make_mfile('code_separator',3);
make_mfile('with_indent','try');
make_mfile('indent_fcn','down');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
	switch lower(arg.type)
		case 'character'
			str = 'make_mfile(''with_indent'', sprintf(''%s=''''%%s'''';'',fdata.argData.%s));';
		otherwise
			str = 'make_mfile(''with_indent'', sprintf(''%s=%%s;'',fdata.argData.%s));';
	end
	%=== modified by TK 2011/05/09
  make_mfile('with_indent',sprintf(str, arg.name,arg.name));
end
make_mfile('indent_fcn','up');
make_mfile('with_indent','catch');
make_mfile('indent_fcn','down');
make_mfile('with_indent','errordlg({[mfilename '': WRITE ''],lasterr});');
make_mfile('with_indent',...
  'make_mfile(''with_indent'', [''error('''''' mfilename '' : Write Error'''');'']);');
make_mfile('with_indent','make_mfile(''with_indent'', ''catch'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''errordlg(lasterr);'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''end'');');
make_mfile('indent_fcn','up');
make_mfile('with_indent','end');
make_mfile('with_indent','');

% ======================================
% Execute
% ======================================
make_mfile('code_separator',3);
make_mfile('with_indent','%   Execute');
make_mfile('code_separator',3);
s=strrep(mydata.UiFunction.String,'''','''''');
make_mfile('with_indent','make_mfile(''with_indent'',...');
make_mfile('with_indent',['           ''' s ';'');']);
make_mfile('with_indent','');

% ======================================
% Result Draw Property
% ======================================
if isfield(mydata,'FilterOption') && ...
    isfield(mydata.FilterOption,'ResultPlugin')
  make_mfile('code_separator',3);
  make_mfile('with_indent','%   Add Result-Draw-Property');
  make_mfile('code_separator',3);
  for idx=1:length(mydata.FilterOption.ResultPlugin)
    if iscell(mydata.FilterOption.ResultPlugin)
      rdp=mydata.FilterOption.ResultPlugin{idx};
    else
      rdp=mydata.FilterOption.ResultPlugin(idx);
    end
    makeResultDrawProp(rdp);
  end
end

make_mfile('with_indent','');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');

% ********************************
% Error Area
% ********************************
make_mfile('code_separator',2);
make_mfile('with_indent','%   Error Area');
make_mfile('code_separator',2);
make_mfile('with_indent','make_mfile(''with_indent'', ''catch'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''down'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''errordlg(lasterr);'');');
make_mfile('with_indent','make_mfile(''indent_fcn'', ''up'');');
make_mfile('with_indent','make_mfile(''with_indent'', ''end'');');

% ********************************
% Footer
% ********************************
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent', 'make_mfile(''code_separator'', 3);');
make_mfile('with_indent', 'make_mfile(''with_indent'', '''');');
make_mfile('with_indent', 'return;');
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for MF  Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeResultDrawProp(rdp)
% Draw Result-Draw-Proprerty

% *******************
% Data-Setting
% *******************
if isfield(rdp,'DataName')
  fn=fieldnames(rdp.DataName);
  for idx=1:length(fn)
    s0=strrep(rdp.DataName.(fn{idx}),'''','''''');
    s1=sprintf('hdata.Results.%s.DataName.%s=''''%s'''';',rdp.name,fn{idx},s0);
    s1=strrep(s1,'''','''''');
    make_mfile('with_indent', ...
      sprintf('make_mfile(''with_indent'',''%s'');',s1));
  end
else
  s0=rdp.DataString; 
  s0=cellstr(s0);s0=[s0{:}];
  s0=strrep(s0,'''','''''''''');
  s1=sprintf('hdata.Results.%s.DataString=''''%s'''';',rdp.name,s0);
  make_mfile('with_indent', ...
    sprintf('make_mfile(''with_indent'',''%s'');',s1));
end

% *******************
% Data-Function
% *******************
if isfield(rdp,'DrawType')
  s1=sprintf('hdata.Results.%s.DrawType=''''%s'''';',rdp.name,rdp.DrawType);
  make_mfile('with_indent', ...
    sprintf('make_mfile(''with_indent'',''%s'');',s1));
else
  s0=rdp.DrawString; 
  s0=cellstr(s0);s0=[s0{:}];
  s0=strrep(s0,'''','''''''''');
  s1=sprintf('hdata.Results.%s.DrawString=''''%s'''';',rdp.name,s0);
  make_mfile('with_indent', ...
    sprintf('make_mfile(''with_indent'',''%s'');',s1));
end

% *******************
% Control
% *******************
if isfield(rdp,'Control')
  s0=sprintf('hdata.Results.%s.Control',rdp.name);
  myidx=0;
  for idx=1:length(rdp.Control)
    erflag=false;
    ctrl=rdp.Control{idx};
    make_mfile('with_indent', ...
      'make_mfile(''with_indent'',''clear xxctrl'');');
    
    % copy field
    fn={'varname','DefaultValueString','mode','Position'};
    for idx2=1:length(fn)
      if isnumeric(ctrl.(fn{idx2}))
        sx=num2str(ctrl.(fn{idx2}));
        make_mfile('with_indent', sprintf(...
          'make_mfile(''with_indent'',''xxctrl.%s=[%s];'');',...
          fn{idx2},sx));
      else
        sx=strrep(ctrl.(fn{idx2}),'''','''''''''');
        make_mfile('with_indent', sprintf(...
          'make_mfile(''with_indent'',''xxctrl.%s=''''%s'''';'');',...
          fn{idx2},sx));
      end
    end
    vs=ctrl.variable.str; s1='{';
    for idx2=1:length(vs)
      s1=[s1 '''''' vs{idx2} ''''' '];
    end
    s1(end)='}';

    if isfield(ctrl.variable,'tmp')
      s2=strrep(ctrl.variable.tmp,'''','''''');
    else
      vv=ctrl.variable.val; s2='{';
      for idx2=1:length(vv)
        if ischar(vv{idx2})
          s2=[s2 '''''' vv{idx2} ''''' '];
        elseif isnumeric(vv{idx2}) && size(vv{idx2},1)==1
          s2=[s2 '[' num2str(vv{idx2}) '] ']; %#ok
        else
          % Error (unsupported variable)
          erflag=true;
          disp(C__FILE__LINE__CHAR);
          disp('Unsupported variable format for make-M-File');
          break;
        end
      end
      s2(end)='}';
    end
    if ~erflag
      myidx=myidx+1;
      make_mfile('with_indent', sprintf(...
        'make_mfile(''with_indent'',''xxctrl.variable.str=%s;'');',s1));
      make_mfile('with_indent', sprintf(...
        'make_mfile(''with_indent'',''xxctrl.variable.val=%s;'');',s2));
   
      make_mfile('with_indent', sprintf(...
        'make_mfile(''with_indent'',''%s{%d}=xxctrl;'');',s0,myidx));
    else
      make_mfile('with_indent', ...
        '% Unsupported Data-Format : ignore this control')
    end

  end
  make_mfile('with_indent', ...
    'make_mfile(''with_indent'',''clear xxctrl'');');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for MA  Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeDraws(mydata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ********************************
% STR - Function
% ********************************
make_mfile('code_separator',1);
make_mfile('with_indent','function str=drawstr(varargin)')
make_mfile('with_indent',['% Execution-Format' mydata.PluginName]);
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','str=[mfilename,...');
make_mfile('with_indent','    ''(''''draw'''','' ...');
make_mfile('with_indent','    ''h.axes, curdata, obj{idx});''];');
make_mfile('with_indent','if 0,disp(varargin);end');
make_mfile('with_indent','return;');
make_mfile('with_indent','');

% ********************************
% Draw - Function
% ********************************
make_mfile('code_separator',1);
make_mfile('with_indent','function hout=draw(gca0, curdata, objdata, ObjectID)')
make_mfile('with_indent',['% perform ' mydata.PluginName]);
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','% Default Output Data');
make_mfile('with_indent','hout.h=[];');
make_mfile('with_indent','hout.tag={};');
make_mfile('with_indent','');

if mydata.AO_Replace
  make_mfile('with_indent','% Clear Axis-Objects');
  make_mfile('with_indent','cla');
  make_mfile('with_indent','');
end

% ********************************
% Dumy-Argument
% ********************************
make_mfile('with_indent','% Argument - List for the Function');
for idx=1:length(mydata.ArgumentProp)
  arg=mydata.ArgumentProp(idx);
  make_mfile('with_indent', sprintf('%s=eval(objdata.arg_%s);',...
    arg.name,arg.name));
end
make_mfile('with_indent','');


make_mfile('with_indent','% Argument - List for the Function');
make_mfile('with_indent',...
  '[hdata,data]=osp_LayoutViewerTool(''getCurrentDataRaw'',curdata.gcf,curdata);');


make_mfile('with_indent','');
make_mfile('with_indent','% Plot');
make_mfile('with_indent','set(curdata.gcf,''CurrentAxes'',gca0);');
s=mydata.UiFunction.String;
if ~isequal(s(end),';'),s(end+1)=';';end
make_mfile('with_indent',s);

make_mfile('with_indent','');
make_mfile('with_indent','');
make_mfile('with_indent','%======================================');
make_mfile('with_indent','%=      Common-Callback Setting       =');
make_mfile('with_indent','%======================================');
make_mfile('with_indent',...
  sprintf('myName=''AXIS_%s'';',genvarname(mydata.PluginName)));
make_mfile('with_indent','if exist(''ObjectID'',''var''),');
make_mfile('with_indent','  p3_ViewCommCallback(''Update'', ...');
make_mfile('with_indent','    hout.h, myName, ...');
make_mfile('with_indent','    gca0, curdata, objdata, ObjectID);');
make_mfile('with_indent','else');
make_mfile('with_indent','  p3_ViewCommCallback(''CheckIn'', ...');
make_mfile('with_indent','    hout.h, myName, ...');
make_mfile('with_indent','    gca0, curdata, objdata);');
make_mfile('with_indent','end');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for M1  Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeHeader2(fname)
% Make Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,f]=fileparts(fname);
if 0,disp(p);clear p;end
% Function Top
make_mfile('with_indent',['function varargout=' f '(fnc,varargin)']);
% Help Information
make_mfile('with_indent',...
  {['% ' f ' : 1st-LVL-Ana Function of Platform 3'],...
  '',...
  ['% Edit the above text to modify the response to help ' f],...
  '',...
  ['% Made by ' mfilename ' $Revision: 1.3 $'],...
  ['%              at ' date]});
make_mfile('with_indent','');

make_mfile('with_indent',{...
  '%====================',...
  '% In no input : Help',...
  '%====================',...
  'if nargin==0,',...
  '  OspHelp(mfilename);',...
  '  return;',...
  'end'});
make_mfile('with_indent','');

% Launch
make_mfile('code_separator',1);
make_mfile('with_indent',{...
  'if nargout',...
  '  [varargout{1:nargout}] = feval(fnc, varargin{:});',...
  'else',...
  '  feval(fnc, varargin{:});',...
  'end'});
make_mfile('code_separator',1);
make_mfile('with_indent',{...
  '% Function List',...
  'if 0',...
  '  createBasicInfo;',...
  '  make;',...
  'end',...
  'return;'});
make_mfile('with_indent','');

function makeCreateBasicInfo2(mydata)
% Make createBasicInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
make_mfile('with_indent','function bi=createBasicInfo');
% Help Information
make_mfile('with_indent',...
  {'% Basic Information to control this function'});
make_mfile('code_separator',1);

% ======================================
% Make Name
% ======================================
make_mfile('with_indent',sprintf('bi.name=''%s'';',mydata.PluginName));
make_mfile('with_indent','bi.Version=1.0;');

% ======================================
% Make Region
% ======================================
s=' ';
if mydata.Region_Continuous
  s=[s '2 '];
end
if mydata.Region_Block
  s=[s '3 '];
end
if length(s)>=4
  s(1)='[';s(end)=']';
end
make_mfile('with_indent',['bi.region=' s ';']);
make_mfile('with_indent','bi.refresh=2.0;');
make_mfile('with_indent','');

function makeMake(mydata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator',1);
fm=mydata.UiFunction;
make_mfile('with_indent',['function ' fm.retValue '=make(varargin)'])
% ********************************
% Help Information
% ********************************
make_mfile('with_indent',['% Make 1st-Level-Data of ' mydata.PluginName]);
make_mfile('code_separator',1);
make_mfile('with_indent','');
make_mfile('with_indent','bi=createBasicInfo;');
make_mfile('with_indent','');

make_mfile('code_separator',3);
make_mfile('with_indent','%   Execute');
make_mfile('code_separator',3);

make_mfile('with_indent',[ fm.retValue '=' ...
  fm.Function '(varargin{:});']);
make_mfile('with_indent','');
make_mfile('with_indent', 'return;');
return;



