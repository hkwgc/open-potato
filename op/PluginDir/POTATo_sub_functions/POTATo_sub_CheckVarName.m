function str = POTATo_sub_CheckVarName(str)
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%- str check
str=strrep(str,'-','__');
str=strrep(str,'+','__');
str=strrep(str,'*','__');
str=strrep(str,'/','__');
str=strrep(str,'(','_');
str=strrep(str,')','_');
str=strrep(str,' ','_');
str=strrep(str,',','_');
str=strrep(str,';','');
str=strrep(str,':','__');
str=strrep(str,'{','l');
str=strrep(str,'}','l');
