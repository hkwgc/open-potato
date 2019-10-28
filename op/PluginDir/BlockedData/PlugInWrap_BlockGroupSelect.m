function varargout=PlugInWrap_BlockGroupSelect(fnc,varargin)
% Filter Plug-in
%
                                                                                
% Edit the above text to modify the response to help PlugInWrap_BlockGroupSelect
                                                                                
% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                            
%              at 23-Jun-2009                                                   

%====================    
% In no input : Help     
%====================    
if nargin==0,            
  POTATo_Help(mfilename);
  return;                
end                      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargout                                         
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else                                               
  feval(fnc, varargin{:});                         
end                                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function List   
if 0              
  createBasicInfo;
  getArgument;    
  write;          
end               
return;           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bi=createBasicInfo
% Basic Information to control this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bi.name='BlockGroupSelect';
bi.Version=1.0;
bi.region= 2 ;
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%      argData.group : group (Character)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% M-File to get Before Data
% (if you want : slow)
mfile0=varargin{1}; %#ok
% Example :
% [data, hdata]=scriptMeval(mfile0, 'data', 'hdata');

% **************************************
% Reading Argument
% **************************************
if isfield(fdata,'argData'),
  data=fdata.argData;
else
  data=[];
end
% Default Value
if isempty(data) || ~isfield(data, 'group')
  data.group = 'A';
end

% **************************************
% Display Prompt
% **************************************
prompt = {...
         'Enter : group [Character]',...
         };

% **************************************
% Default Value
% **************************************
def    = {...
         data.group,...
         };

% **************************************
% Open Input-Dialog
% **************************************
while 1,
  % ======================================
  % input-dlg
  % ======================================
  def = inputdlg(prompt, fdata.name, 1, def);
  if isempty(def),
    data=[]; break; %while
  end
  
  % ======================================
  % Check Argument
  % ======================================
  emsg={};
  % Check : Is 'group' Character?
  data.group = def{1};
  if isempty(def{1}),
    data.group = [];
  else
    data.group = [ data.group ];
  end
  % --*--*--*--*--*--*--*--*--*--*--*--*--
  % Error Messange;
  % --*--*--*--*--*--*--*--*--*--*--*--*--
  if isempty(emsg),break;end
  eh=errordlg({'Input Data Error:',emsg{:}},...
               [fdata.name ' : Argument']);
  waitfor(eh);
  
end

% **************************************
% Output
% **************************************
if isempty(data)
  fdata=[]; % ( cancel )
else
  fdata.argData=data;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform BlockGroupSelect
% Fdata is as same as getArgument's fdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str='';
if 0,disp(region);end
bi=createBasicInfo;

% **************************************
%   Header Area
% **************************************
make_mfile('code_separator', 3);
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', sprintf('%%  Version %f',bi.Version));
make_mfile('code_separator', 3);
make_mfile('with_indent', '');

% **************************************
%   Exexute Area
% **************************************
make_mfile('with_indent', 'try');
make_mfile('indent_fcn', 'down');

% ======================================
%   Argument Setting
% ======================================
try
  make_mfile('with_indent', sprintf('group=''%s'';',fdata.argData.group));
catch
  errordlg({[mfilename ': WRITE '],lasterr});
  make_mfile('with_indent', ['error(''' mfilename ' : Write Error'');']);
  make_mfile('with_indent', 'catch');
  make_mfile('indent_fcn', 'down');
  make_mfile('with_indent', 'errordlg(lasterr);');
  make_mfile('indent_fcn', 'up');
  make_mfile('with_indent', 'end');
end

% ======================================
%   Execute
% ======================================
make_mfile('with_indent',...
           '[hdata]=P3P_BlockGroupSelect(hdata,group);');


make_mfile('indent_fcn', 'up');
% **************************************
%   Error Area
% **************************************
make_mfile('with_indent', 'catch');
make_mfile('indent_fcn', 'down');
make_mfile('with_indent', 'errordlg(lasterr);');
make_mfile('indent_fcn', 'up');
make_mfile('with_indent', 'end');
make_mfile('with_indent', '');
make_mfile('code_separator', 3);
make_mfile('with_indent', '');
return;
