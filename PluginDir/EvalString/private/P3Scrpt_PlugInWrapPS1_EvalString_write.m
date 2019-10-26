% [Syntax] function str = write(region, fdata) %#ok



% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Input Variable
region	= vin1;
fdata	= vin2;

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
make_mfile('with_indent', '[data, hdata]=P3_PluginEvalScript(''P3Scrpt_uc_EvalString'',[],data, hdata,A);');
		case 'open'
			make_mfile('with_indent', [fdata.argData.A ';']);
	end
else %- for version 1.0
	make_mfile('with_indent', sprintf('A = ''%s'';', t_arg ));
make_mfile('with_indent', '[data, hdata]=P3_PluginEvalScript(''P3Scrpt_uc_EvalString'',[],data, hdata,A);');
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

% Output Variable
vout1	= str;

return;

% Output Variable
vout1	= str;

