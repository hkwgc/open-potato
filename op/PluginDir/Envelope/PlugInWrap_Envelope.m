function varargout=PlugInWrap_Envelope(fnc,varargin)
% Filter Plug-in
%
                                                                        
% Edit the above text to modify the response to help PlugInWrap_Envelope
                                                                        
% Made by P3_wizard_plugin_createMF $Revision: 1.3 $                    
%              at 13-May-2008                                           

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
bi.name='Envelope';
bi.Version=1.0;
bi.region= 2 ;
bi.DispKind=0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fdata=getArgument(fdata,varargin)

if isfield(fdata, 'argData')
	% Use Setting Value.
	% ( Change )
	data = fdata.argData;
else
	data = [];
end

[cdata, chdata] = scriptMeval(varargin{1},'cdata','chdata');
% Default Value for start
if isempty(data) || ~isfield(data, 'kind'),
	data.kind = 1;
	if size(cdata{1},3)<3, data.kind=size(cdata,3);end
end
% Display Prompt words
prompt = {'Select a target data type.'};
% Default value
str = chdata{1}.TAGs.DataTag;
% Open Input-Dialog
while 1,
	% input-dlg
	def = listdlg('PromptString',prompt,'Name', 'input dialog',...
		'SelectionMode','single', 'ListString',str, 'InitialValue',data.kind);
	if isempty(def)
		data=[]; break; %while
	end
	% Check Argument
	data.kind= def; % will be chacked in Main routine.
	break;
end
fdata.argData=data;
   
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=write(region,fdata)
% write M-Script to perform Envelope
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
make_mfile('with_indent', sprintf('kindNUM = %d;', fdata.argData.kind));

% ======================================
%   Execute
% ======================================
make_mfile('with_indent',...
           '[data,hdata]=P3P_Envelope(data,hdata,kindNUM);');


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
