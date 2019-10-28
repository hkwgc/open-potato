function varargout=PlugInWrap_P3P_FlagClear(fnc,varargin)
% Filter Plug-in
%
                                                                             
% Edit the above text to modify the response to help PlugInWrap_P3P_FlagClear
                                                                             
% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                         
%              at 07-May-2013                                                

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


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
bi.name='Flag clear';
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% M-File to get Before Data
% (if you want : slow)
mfile0=varargin{1}; %#ok
% Example :
% [data, hdata]=scriptMeval(mfile0, 'data', 'hdata');

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform Flag clear
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
           'hdata=P3P_FlagClear(hdata);');


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
