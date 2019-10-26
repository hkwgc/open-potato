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
bi.name='Mark ADD';
bi.Version=1.01;
bi.region=[2];%only for continious:2, not for block:3.
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

data.ver = 1.01;

if isfield(fdata,'argData'),
  data=fdata.argData;
else
  data.MODE=1;
  data.ST='';
  data.Dur='';
  data.Kind = '';
end

% **************************************
[data.MODE,v]=listdlg('PromptString',{'--- Setting for [Mark ADD] --- (1/2)','','Selece a type of mark'},...
    'SelectionMode','single','OKString','Next','ListSize',[200,40],...
    'ListString',{'Event','Block'},'InitialValue',data.MODE);
% **************************************

%Cancel?
if v==0
    fdata=[]; return;
end

% **************************************
%input dialog
if data.MODE == 2 %BLOCK
    prompt = {sprintf('--- Setting for [Mark ADD] --- (2/2)\n\nAbsolute time of onset of the task  (sec)'),...
        'Dulation of the task (sec)','Mark kind (index number)'};
    def    = {data.ST, data.Dur, data.Kind};
    ANS = inputdlg(prompt, fdata.name, 1, def);
    if isempty(ANS), fdata=[]; return;end %Cancel?
    data.ST=ANS{1};
    data.Dur=ANS{2};
    data.Kind = ANS{3};
else %EVENT
    prompt = {'Absolute time of onset of the task  (sec)','Mark kind (index number)'};
    def    = {data.ST, data.Kind};
    ANS = inputdlg(prompt, fdata.name, 1, def);
    if isempty(ANS), fdata=[]; return;end %Cancel?
    data.ST=ANS{1};
    data.Dur='-';
    data.Kind = ANS{2};
end
% **************************************

%Check answer
if isempty(str2num(data.ST))
    warndlg(sprintf('Value "%s" for \n[task onset time] was not numerical value.',data.ST));    
    fdata=[]; return;
end

%BUG: if data.MODE==2 && isnan(str2num(data.Dur)) %- BUG: 2012-03-12 
if data.MODE==2 && isempty(str2num(data.Dur))
    warndlg(sprintf('Value "%s" for \n[dulation] was not numerical value.',data.Dur));    
    fdata=[]; return;
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

sub_Plugin_Argument_Write(fdata.argData);

make_mfile('with_indent', '[hdata]=P3P_MarkADD(hdata,A);');

make_mfile('code_separator', 3);

return;
