function varargout=PlugInWrap_BlockGrouping(fnc,varargin)
%-------------------------------------
%BlockGrouping
%-------------------------------------
                                                                             
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
bi.name='BlockGrouping';
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
%      argData.blockA : blockA (Integer)
%      argData.blockB : blockB (Integer)
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
if isempty(data) || ~isfield(data, 'blockA')
  data.blockA = '[]';
end
if isempty(data) || ~isfield(data, 'blockB')
  data.blockB = '[]';
end
if isempty(data) || ~isfield(data, 'Apply')
  data.Apply{1} = {'Yes','No'};
  data.Apply{2} = 2;
end


% **************************************
% Display Prompt
% **************************************
prompt = {...
         'Enter : blockA [Integer]',...
         'Enter : blockB [Integer]',...
         'Apply block-group to stim-mark?',...
         };

% **************************************
% Default Value
% **************************************
def    = {...
         data.blockA,...
         data.blockB,...
         data.Apply
         };

% **************************************
% Open Input-Dialog
% **************************************
  % ======================================
  % input-dlg
  % ======================================
  def = subP3_inputdlg(prompt, fdata.name, 1, def);
  if isempty(def),
    data=[]; 
  end
  
  % ======================================
  % Check Argument
  % ======================================
  if ~isempty(def{1})
      data.blockA = def{1};
  else
      data.blockA = '[]';
  end
  
  if ~isempty(def{2})
      data.blockB = def{2};
  else
      data.blockB = '[]';
  end
  
  data.Apply{2} = def{3}{1};

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
% write M-Script to perform BlockGrouping
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
  make_mfile('with_indent', sprintf('blockA=%s;',fdata.argData.blockA));
  make_mfile('with_indent', sprintf('blockB=%s;',fdata.argData.blockB));
  make_mfile('with_indent', sprintf('flagApplyToStimMark=%d;%1:Yes, 2:No',fdata.argData.Apply{2}));
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
           '[hdata]=P3P_SetBlockGrouping(hdata,blockA, blockB,flagApplyToStimMark);');


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
