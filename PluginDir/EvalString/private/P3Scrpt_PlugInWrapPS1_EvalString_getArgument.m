% [Syntax] function varargout=getArgument(varargin) %#ok


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% Input Variable
varargin=cell(1,nin-1+1);
for ii=1:nin
  varargin{ii-1+1}=eval(sprintf('vin%d',ii));
end

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

% Output Variable
for ii=1:nout
  eval(sprintf('vout%d=varargout{ii-1+1};',ii));
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Output Variable
for ii=1:nout
  eval(sprintf('vout%d=varargout{ii-1+1};',ii));
end

