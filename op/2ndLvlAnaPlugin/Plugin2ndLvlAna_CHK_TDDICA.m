function varargout=Plugin2ndLvlAna_CHK_TDDICA(fcn,varargin)
% Grubbs-Smirnov Test
%  :: This is Test-Function of 2nd-Level-Analysis.
%
%-----------------------
% $Id: Plugin2ndLvlAna_CHK_TDDICA.m 180 2011-05-19 09:34:28Z Katura $
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
basicInfo.type   ='2nd-Lvl-Ana'; % Fixes!
basicInfo.name   = 'Check TDD-ICA results'; % Print Name
basicInfo.wrap   =mfilename;
% ==> Version Setting
try
  % => (if this souce in CVS)
  rver         = '$Revision: 1.3 $';
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
  ' Check TDD-ICA results ',...
  ' ====================================================',...
  '  Number of Group : 1',...
  '',...
  '  -- Group 1 --',...
  '     1stLvlData of [SAVE_TDDICA]',...
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
999
group1.name     = 'Test';
group1.function = 'flafnc_SAVE_TDDICA'; % <- Basic
data0.group={group1};
return;

function Result=Execute(Group)
%   Group : Group-Data
%    Group(1).fdata{1};    : 1st-Group 1st-Lvl-Ana Data (1)
%    Group(1).fhdata{1};
%
%    Group(1).fdata{2};    : 1st-Group 1st-Lvl-Ana Data (2)
%    Group(1).fhdata{2};....
%
%    Group(2).fdata{1};    : 2nd-Group 1st-Lvl-Ana Data (1)
%    Group(2).fhdata{1};
%
%  Number of Groups/Number of 1st-Lvl-Ana Data  is 
%     depend on User-Setting..
%  So you must be carful for check input data.
% 
%  no Group is allowed in Design.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
  error('Make 1-Group at least.');
end

%==> Result is free format
%    "THIS" function's Result is true/false.

UI_CHK_TDDICA(Group);

Result=9999
return

Result=false;

% => Making All Data
d=[];
for gid=1:length(Group)
  for fla=1:length(Group(gid).fhdata)
    d=[d(:); Group(gid).fdata{fla}(:)];
  end
end

alp = 0.01;
ntmp= alp/length(d) * 2;
if ntmp< 1.0e-5
  error('Too large Data size for Grubbs-Smirnov in this Version');
end

isdraw=true;
if isdraw
  [c,v]=hist(d,round(length(d)/20+1));
  figure;
  h=axes;
  set(h,'Units','Normalized','Position',[0.13,0.11,0.6,0.7])
  plot(v,c,'-.b');
  hold on
  ylabel('Frequency');
  xlabel('Data');
  title('Grabbs-Smirnov (Test-Program of 2^{nd}-Lvl-Ana)');
end
% --> Checking max is OK?
[mx mxi]= max(d(:));
dmx=d;dmx(mxi)=[];
sd=std(dmx);
tmx=(mx -mean(dmx))/sd;
g=osp_distribute('GrabbsSmirnov',alp,length(dmx));
if isdraw
  plot([mx mx],[0, max(c)],'g-.');
  h=text(mx,max(c)/2,sprintf('T(%6.2f)=%6.2f',mx,tmx));
  set(h,'BackgroundColor',[0.7,0.9,0.7])
  if (g-dmx) < (mx-mean(dmx))*1.2
    plot([g g],[0, max(c)],'r-');
    h=text(g,max(c)*0.8,sprintf('G_{%d}(%4.2f)=%6.2f',length(dmx),alp,g));
  else
    h=text(mx,max(c)*0.8,sprintf('G_{%d}(%4.2f)=%6.2f',length(dmx),alp,g));
  end
  set(h,'BackgroundColor',[0.7,0.7,0.9])
end

if tmx<g,
  Result(1)=true;
else
  Result(1)=false;
end

% --> Checking min is OK?
[mn mni]= min(d(:));
dmn=d;dmn(mni)=[];
sd=std(dmn);
tmn=(mean(dmn)-mn)/sd;
if tmn<g,
  Result(2)=true;
else
  Result(2)=false;
end
if isdraw
  plot([mn mn],[0, max(c)],'g-.');
  h=text(mn,max(c)/2,sprintf('T(%6.2f)=%6.2f',mn,tmn));
  set(h,'BackgroundColor',[0.7,0.9,0.7])
  
  st={'Rejection','OK'};
  h=text(mx*1.2,max(c)*0.1,...
    sprintf('Result  Max : %s\n        Min : %s\n',...
    st{Result(1)+1},st{Result(2)+1}));
  set(h,'BackgroundColor',[0.9,0.7,0.7],...
    'FontName',get(0,'FixedWidthFontName'));
end














