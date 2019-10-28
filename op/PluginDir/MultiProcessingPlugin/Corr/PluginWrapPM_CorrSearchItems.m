function  varargout = PluginWrapPM_CorrSearchItems(fcn, varargin)
% varargout = PluginWrapPM_CorrSearchItems(fcn, varargin)



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



%======== Launch Switch ========
switch fcn
  case 'createBasicInfo'
    varargout{1} = createBasicInfo;
  case 'getArgument',
    varargout{1} = getArgument(varargin{:});
  case 'write',
    varargout{1} = write(varargin{:});
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  bi = createBasicInfo
% Basic Information of this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--> mandatory <--
bi.name='Corrcoef SearchItems';
bi.version=0;
%--> suggested <--
bi.type  =0; % not defined now
bi.region=0; % not defined now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  data=getArgument(data, b_mfile)
% Set Data
%     data.name    : 'defined in createBasicInfo'
%     data.wrap    :  Pointer of this Function, 
%                           that is @PlugInWrap_Event_Reblock.
%     data.argData : Argument of Plug in Function.
%        argData.Format  : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

List=DataDef2_Analysis('loadlist'); % loading list of the Project. this list contain info for all files in the project.
ListItems=fieldnames(List);

if ~isfield(data,'argData')
	data.argData=[];
end

initialVal=1;
if isfield(data.argData,'ListItem')
	if ~isempty(data.argData.ListItem)
		initialVal=strmatch(data.argData.ListItem, ListItems);
	end
end
[ListIndex,OK] = listdlg('ListString',ListItems,...
	'SelectionMode','single', 'OKstring','Next','initialvalue',initialVal,...
	'PromptString',{'Select a search item','for calculation'});
if (OK==0), data=[];return;end

initialStr='max(hdata{k}.???)';
if isfield(data.argData,'EvalStr')
	initialStr=data.argData.EvalStr;
end
EvalStr=inputdlg(sprintf(['Eval string for calculation:\n',...
	'\n(If size of the value is larger than 1,',...
	'\ncalculation will be done in loop.\n)']),'',1,{initialStr});
if isempty(EvalStr), data=[];return;end

data.argData.ListItem=ListItems{ListIndex};
data.argData.EvalStr = EvalStr{:};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, data) 
% write make M-File to execute Multi-Plug-in of "Sample".
%  where data is as same as getArgument's data.
%
% There is two method to make M-File.
%   1. use function 'make_mfile'
%      make_mfile is opend at default, so you
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,disp(region);end
str='';

make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' data.name ' ==']);
make_mfile('with_indent', ['%    ' mfilename  ' v1.0 ']);
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent',...
  sprintf('[hdata]= P3P_M_CorrSearchItems(hdata, data,...\n\t''%s'',...\n\t''%s'');',...
  data.argData.ListItem, data.argData.EvalStr));
return;
