function varargout=PlugInWrap_MarkAdd(fnc,varargin)
% Filter Plug-in
%
                                                                             
% Edit the above text to modify the response to help PlugInWrap_BlockGrouping
                                                                             
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
bi.name='Mark CLEAR';
bi.Version=1.0;
bi.region=[2,3];
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)
% get Argument of this Filter
%     fdata.name    : defined in createBasicInfo
%     fdata.wrap    :  Pointer of this Function,
%     fdata.argData : Argument of Plug in Function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data.ver = 1.00;
  fdata.argData=data;
  return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform BlockGrouping
% Fdata is as same as getArgument's fdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str='';
bi=createBasicInfo;

% **************************************
%   Header Area
% **************************************
make_mfile('code_separator', 3);
make_mfile('with_indent', ['% == ' fdata.name ' ==' sprintf('%%  ver. %0.2f',bi.Version)]);

make_mfile('with_indent', '[hdata]=P3P_MarkCLEAR(hdata);');

make_mfile('code_separator', 3);

return;
