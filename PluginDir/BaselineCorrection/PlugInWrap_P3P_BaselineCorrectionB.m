function varargout=PlugInWrap_P3P_BaselineCorrectionB(fnc,varargin)
% Filter Plug-in
%
                                                                                       
% Edit the above text to modify the response to help PlugInWrap_P3P_BaselineCorrectionB
           
% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                                   
%              at 04-Nov-2014                                                          

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
bi.name='Baseline correction (Block)';
bi.Version=1.0;
bi.region= 3 ;
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%      argData.Deg : Deg (Character)
%      argData.IgP : IgP (Character)
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
if isempty(data) || ~isfield(data, 'Deg')
  data.Deg = '1';
end
if isempty(data) || ~isfield(data, 'IgP')
  data.IgP = '';
end

% **************************************
% Display Prompt
% **************************************
prompt = {...
	sprintf('Degree of polynomial fitting for baseline estimation.\n(0: mean value  1: Linear  <1: Nonlinear'),...
	sprintf('Period to be ignored in baseline estimation (point)\n(You can use "m1", "m2" and "ed".) \n Ex.) m1:m2)'),...
	};

% **************************************
% Default Value
% **************************************
def    = {...
         data.Deg,...
         data.IgP,...
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
  
  % Check : Is 'Deg' Character?
  data.Deg = def{1};
  % No check for Characters
  
  % Check : Is 'IgP' Character?
  data.IgP = def{2};
  % No check for Characters
  
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
% write M-Script to perform Baseline correction (Block)
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
  make_mfile('with_indent', sprintf('Deg=''%s'';',fdata.argData.Deg));
  make_mfile('with_indent', sprintf('IgP=''%s'';',fdata.argData.IgP));
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
           'data=P3P_BaselineCorrectionB(data,hdata, Deg, IgP);');


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
