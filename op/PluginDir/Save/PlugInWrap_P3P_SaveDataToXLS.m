function varargout=PlugInWrap_P3P_SaveDataToXLS(fnc,varargin)
%==========================
% -- Plugin for exporting data to xls file ---
% This function is for exporting "continuous" and "blocked(segmented)" data to a file. Each kind (data type: oxy, dexoy and total) will be exported into a sheet separately. If the data is continuous, data row indicates channel and each colum indicates time point. If the data is blocked, data row indicates channel and each colum indicates time point of each blocks, and blocks are exported continuously. For each time point, the first colum indicates the number of block.
% (PDF help is available)
%==========================

% Edit the above text to modify the response to help PlugInWrap_P3P_SaveDataToXLS
                                                                                 
% Made by P3_wizard_plugin_createMF $Revision: 1.4 $                             
%              at 08-May-2013                                                    
% $id$
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
bi.name='Save Data to XLS file';
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
%      argData.Pth : Pth (Character)
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
if isempty(data) || ~isfield(data, 'Pth')
  data.Pth = '';
end

data.Pth=uigetdir(data.Pth);
  
if data.Pth==0
	data=[];
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
% write M-Script to perform Save Data to XLS file
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
  make_mfile('with_indent', sprintf('Pth=''%s'';',fdata.argData.Pth));
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
           'P3P_SaveDataToXLS(data,hdata,Pth);');


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
