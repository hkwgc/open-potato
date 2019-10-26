function varargout=Plugin_SLA_Copy2CB(fcn,varargin)
% Copy to Clipboard
%  
%
%-----------------------
% $Id: Plugin2ndLvlAna_Copy2CB.m 180 2011-05-19 09:34:28Z Katura $
%-----------------------

if nargin==0
  ospHelp(mfilename);return;
end

switch fcn
  case 'createBasicInfo'
    % Return Basic-Information of this Plugin
    varargout{1} = createBasicInfo;
  case 'simlpleHelpText',
    % Return Simple Help-Text of this Plugin
    varargout{1}=simlpleHelpText;
  case {'help','Help','HELP'},
    % Help of this Function
    OspHelp(mfilename);
  case 'Execute'
    % --> no-varargin     : no-group
    %        varargin{1}  : group
    %        varargout{1} : result
    varargout{1}=Execute(varargin{:});
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%       DispKind :: Add Kind 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.type   ='2nd-Lvl-Ana'; % Fixed!
basicInfo.name   = 'Copy data ( .Results) to Clipboard'; % Print Name
basicInfo.wrap   =mfilename;
% ==> Version Setting
try
  % => (if this souce in CVS)
  rver         = '$Revision: 0.1 $';
  rver(end)    =[];
  rver         = str2double(rver(14:end));
catch
  rver         = -1; % Unknow Version
end
basicInfo.Version =rver;
return;

function str=simlpleHelpText
% GUI's Simple-Information.
bi= createBasicInfo;
str={...
  ' Copy data ( .Results) to Clipboard ',...
  ' ====================================================',...
  '  This function output selected data to clipboard. ',...
  '  Please make a group from 1st Lv. Ana "save .Results". ',...
  '  ',...
  sprintf('     Version             : %6.2f',bi.Version),...
  '',...
};

function data0=getArgument
% % Do nothing in particular
%     data0.name    : 'defined in createBasicInfo'
%     data0.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_AddRaw.
%     data0.argData : Argument of Plug in Function.
%       now
%        argData.ver     : version of the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = createBasicInfo;
data0.name=basicInfo.name;
data0.wrap=mfilename;
group1.name     = 'Test';
group1.function = '??_'; % <- Basic
data0.group={group1};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Result=Execute(Group)
if nargin==0
  error('Make 1-Group at least.');
end

%==> Result is free format
%    "THIS" function's Result is true/false.

if length(Group)~=1, 
	warndlg('Please select [ 1 groups ].');
	return;
end

GPD=[];
GPD.FileNum=length(Group.fdata);

GPD.DataTags=[];
GPD.DataPoss=[];
%make new DataTag
for j0=1:GPD.FileNum
    str=Group.fhdata{j0}.DataTag(:);
    for j=1:length(str)
        GPD.DataTags{end+1}=sprintf('FILE%d.%s',j0,str{j});
        GPD.DataPoss{end+1}.FileNum=j0;
        GPD.DataPoss{end}.DataPos=Group.fhdata{j0}.DataPos{j};
    end
end

UI_INNERKEY_Cp2CB(Group,GPD); % Selector GUI

% % make strings for clipboard
% D=[];
% for i=GPD.Selected
%     F=GPD.DataPoss{i}.FileNum;
%     P=GPD.DataPoss{i}.DataPos;
%     for j=1:length(P)
%         D=[D sprintf('%s\t',GPD.DataTags{i}) ...
%             sprintf('%f\t',Group.fdata{F}(:,P(j))) sprintf('\n')];
%     end
% end
% 
% clipboard('copy',D);

Result=1;
return











