function varargout=PlugInWrap_StoreMeanValueToEResults(fnc,varargin)
% Filter Plug-in
%
                                                                                           
% Edit the above text to modify the response to help PlugInWrap_StoreMeanValueTo0x2EResults
                                                                                           
% Made by P3_wizard_plugin_createMF $Revision: 1.3 $                                       
%              at 29-Jul-2008                                                              

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
bi.name='Store Mean value to .Results';
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
%      argData.st : period start time (sec) (Float)
%      argData.ed : period end time (sec) (Float)
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
if isempty(data) || ~isfield(data, 'st')
  data.st = '0.0';
end
if isempty(data) || ~isfield(data, 'ed')
  data.ed = '1.0';
end

% **************************************
% Display Prompt
% **************************************
prompt = {...
         sprintf('period start time (sec) \n("0.0" means start point of data. NOT stimuli onset!)'),...
         'period end time (sec) [Float]',...
         };

% **************************************
% Default Value
% **************************************
def    = {...
         data.st,...
         data.ed,...
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
  % Check : Is 'st' Float?
  data.st = def{1};
  if isempty(def{1}),
	  data.st= '[]';
  else
	  s=regexp(data.st,'^[0-9]*[\.]?[0-9]*$'); %#ok
	  if isempty(s)
		  emsg{end+1}='data.st : Is not Float Descript.';
		  emsg{end+1}=lasterr;
	  end
  end
  % Check : Is 'ed' Float?
  data.ed = def{2};
  if isempty(def{2}),
	  data.ed= '[]';
  else
	  s=regexp(data.ed,'^[0-9]*[\.]?[0-9]*$'); %#ok
	  if isempty(s)
		  emsg{end+1}='data.ed : Is not Float Descript.';
		  emsg{end+1}=lasterr;
	  end
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
% write M-Script to perform Store Mean value to .Results
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
  make_mfile('with_indent', sprintf('st=%s;',fdata.argData.st));
  make_mfile('with_indent', sprintf('ed=%s;',fdata.argData.ed));
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
           '[hdata]=P3P_StoreMeanValueToResults(hdata,data,st,ed);');


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
