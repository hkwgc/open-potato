function varargout=PlugInWrap_SaveMeanValueToTextFile2(fnc,varargin)
% Filter Plug-in
%
                                                                                        
% Edit the above text to modify the response to help PlugInWrap_SaveMeanValueToTextFile2
                                                                                        
% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                                    
%              at 05-Aug-2010                                                           

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
bi.name='Save Value to Text File';
bi.Version=1.1;
bi.region=[2 3];
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%      argData.A : A (Integer)
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
	data.A = P3P_saveMeanvalueTexFile2dlg(data.A,varargin{:});
else
	data.A = P3P_saveMeanvalueTexFile2dlg([],varargin{:});
end


% **************************************
% Output
% **************************************
if isempty(data) || ~isfield(data.A, 'filename')
  fdata=[]; % ( cancel )
else
  fdata.argData=data;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform Save Mean Value to Text File
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

% ======================================
%   Argument Setting
% ======================================
sub_Plugin_Argument_Write(fdata.argData.A);

% ======================================
%   Execute
% ======================================
make_mfile('with_indent',...
           '[hdata] = P3P_SaveMeanValuetoTextFile2(hdata,data,A);');

return;
