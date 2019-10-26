function varargout=PlugInWrap_SetZeroLevel(fnc,varargin)
% set zero level 
%
% author : TK
% create : 15-Apr-2008 20:12:58
                                                                            
% Edit the above text to modify the response to help PlugInWrap_SetZeroLevel
                                                                            
% Made by P3_wizard_plugin_createMF $Revision: 1.1 $                        
%              at 15-Apr-2008                                               

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
bi.name='Set zero level';
bi.Version=1.0;
bi.region=[2 3];
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%      argData.A : zero level period (point) (Integer)
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
if isempty(data) || ~isfield(data, 'A')
  data.A = '1:10';
end

% **************************************
% Display Prompt
% **************************************
prompt = {...
         'Enter : zero level period (point) [Integer]',...
         };

% **************************************
% Default Value
% **************************************
def    = {...
         data.A,...
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
  % Check : Is 'A' Integer?
  data.A = def{1};
  if isempty(def{1}),
    data.A= '[]';
  end
break;
  
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
% write M-Script to perform Set zero level
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
  make_mfile('with_indent', sprintf('A=%s;',fdata.argData.A));
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
           'data=P3P_SetZeroLevel(data,hdata,A);');


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
