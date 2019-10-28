function varargout = PlugInWrap_EvalString(fcn, varargin)
% EvalString is Plug-in Function of POTATo.
%   "EvalString" execute given-string in Analysis M-File.
%    In the string, POTATo-Data, hdata & data, is available.

% TEST__NAME Function of Wrapper of Plag-In Function
%
% You may use  At least we use 3-internal-function.
%  That is 'createBasicInfo', 'getArgument', and
%  'write'.
%
% ** CREATE BASIC INFORMATION **
% Syntax:
%  basic_info = EvalString('createBasicIno');
%
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%     if allowed Region-Number  is either Continuos and Blocks
%        set basic_info.region=[2, 3];
%
% ** Set Arguments of Plug-in Function **
% Syntax:
%  filterData = EvalString('getArgument',filterData, mfilename);
%
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @EvalString.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.A: Input evaluatable strings
%
%     mfilename : M-File, before PlugInWrap-TEST__NAME.
%
% ** write **
% Syntax:
%  str = EvalString('createBasicIno',region, fdata)
%
%  Make M-File, correspond to Plug-in function.
%  by usinge make_mfile.
%  if str, out-put by str.
%
% See also OSPFILTERDATAFCN.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% == History ==
% Reversion : 1.00
%

%======== Launch Switch ========
if strcmp(fcn,'createBasicInfo'),
	varargout{1} = createBasicInfo;
	return;
end

if nargout,
	[varargout{1:nargout}] = feval(fcn, varargin{:});
else
	feval(fcn, varargin{:});
end
return;
%===============================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%======= Data to Add list ======
function  basicInfo= createBasicInfo
%    basic_info.name :
%       Display-Name of the Plagin-Function.
%    basic_info.region :
%       Set Execute allowed Region.
%       Region indicate by number,
%         CONTINUOUS   : 2
%         BLOCKDATA    : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basicInfo.name   = 'EvalString';
basicInfo.region = [2  3];
% Display Kind :
% <- Filter Display Mode Variable :: Load
DefineOspFilterDispKind;
basicInfo.DispKind=0;
basicInfo.Version=2.0;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=getArgument(varargin) %#ok
% Set Data
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @EvalString.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.A: Input evaluatable strings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data0 = varargin{1}; % Filter Data
if isfield(data0, 'argData')
	% Use Setting Value.
	% ( Change )
	data = data0.argData;
	
	if ~isfield(data,'Mode')
		data.Mode='close';
	end
	
else
	data = [];
end

% Default Value for start
if isempty(data) || ~isfield(data, 'A'),
	data.A = '' ;
	data.Mode='close';
end

% Display Prompt words
prompt = {...
	' String for ''eval''',...
	' Mode ( open/close [default:close] )',...
	};
% Default value
def = {...
	data.A,...
	data.Mode,...
	};
% Open Input-Dialog
while 1,
	% input-dlg
	def = inputdlg(prompt, data0.name, 1, def);
	if isempty(def),
		data=[]; break; %while
	end
	
	% Check Argument
	if ~isempty(def{1}),
		data.A= def{1};
	else
		data.A= '';
	end
	
	if strcmpi(def{2},'open') || strcmpi(def{2},'close')
		data.Mode=def{2};
	else
		data.Mode='close';
	end
	
	break;
end
if isempty(data)
	data0=[]; %Not inputed ( cancel )
else
	data0.argData=data;
end
varargout{1}=data0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = write(region, fdata) %#ok
% Make M-File of EvalString
%     filterData.name    : 'defined in createBasicInfo'
%     filterData.wrap    :  Pointer of this Function,
%                           that is @EvalString.
%     filterData.argData : Argument of Plug in Function.
%       now
%        argData.A: Input evaluatable strings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_mfile('code_separator', 3);   % Level  3, code sep
make_mfile('with_indent', ['% == ' fdata.name ' ==']);
make_mfile('with_indent', '%     EvalString   v1.0 ');
make_mfile('code_separator', 3);  % Level  3, code sep .
make_mfile('with_indent', ' ');


make_mfile('with_indent', 'try');
make_mfile('indent_fcn', 'down');

t_arg=[];
t_arg = fdata.argData.A;
t_arg = strrep(t_arg, '''','''''');

if isfield(fdata.argData,'Mode')
	switch lower(fdata.argData.Mode)
		case 'close'
			make_mfile('with_indent', sprintf('A = ''%s'';', t_arg ));
			make_mfile('with_indent', '[data, hdata]=uc_EvalString(data, hdata,A);');
		case 'open'
			make_mfile('with_indent', [fdata.argData.A ';']);
	end
else %- for version 1.0
	make_mfile('with_indent', sprintf('A = ''%s'';', t_arg ));
	make_mfile('with_indent', '[data, hdata]=uc_EvalString(data, hdata,A);');
end

make_mfile('indent_fcn', 'up');
make_mfile('with_indent', 'catch');
make_mfile('indent_fcn', 'down');
make_mfile('with_indent', 'errordlg(lasterr);');
make_mfile('indent_fcn', 'up');
make_mfile('with_indent', 'end');

make_mfile('with_indent', ' ');
make_mfile('code_separator', 3);  % Level 3, code sep .
make_mfile('with_indent', ' ');

str='';
return;
