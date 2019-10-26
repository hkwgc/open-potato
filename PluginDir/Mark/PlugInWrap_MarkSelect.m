function varargout=PlugInWrap_MarkSelect(fnc,varargin)
                                                                           

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
bi.name='Mark SELECT';
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

[cdata, chdata]=scriptMeval(mfile0, 'data', 'hdata');

data.ver = 1.01;

if isfield(fdata,'argData'),
  data=fdata.argData;
else
  data.MODE='Mark tag';
  data.TargetTag = 1;
  data.TargetIDX=[];
end

if strcmp(data.MODE,'Mark tag')
	IV_mode=1;
else
	IV_mode=2;
end
% **************************************
[sel,v]=listdlg('PromptString',...
	{'--- Setting for [Mark Select] --- (1/2)','','Select a method to select marks.'},...
    'SelectionMode','single','OKString','Next','ListSize',[200,40],...
    'ListString',{'Mark tag','Mark order'},'InitialValue',IV_mode);
% **************************************
%Cancel?
if v==0, fdata=[]; return;end
% **************************************
if sel == 1
	[data.TargetTag,v]=listdlg('PromptString',...
		{'--- Setting for [Mark Select] --- (2/2)','','Select a mark index(s).'},...
		'SelectionMode','multiple','OKString','OK','ListSize',[200,40],...
		'ListString',{num2str(unique(chdata.stim(:,1)))},'InitialValue',data.TargetTag);
	data.MODE='Mark tag';
else
	a={};for k=1:size(chdata.stim,1),a{k}=num2str(k);end;
	[data.TargetIDX,v]=listdlg('PromptString',...
		{'--- Setting for [Mark Select] --- (2/2)','','Select a mark in order.'},...
		'SelectionMode','multiple','OKString','OK','ListSize',[200,40],...
		'ListString',a,'InitialValue',data.TargetIDX);
	data.MODE='Mark order';
end
% **************************************
if v==0, fdata=[]; return;end
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

make_mfile('with_indent', '[hdata]=P3P_MarkSelect(hdata,A);');

make_mfile('code_separator', 3);

return;
