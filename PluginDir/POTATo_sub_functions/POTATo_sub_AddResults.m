function [hdata]=POTATo_sub_AddResults(hdata,Tag,Val)
% ===
% add new value to hdata.Results.[Tag]
% if [Tag] exist, add as CELL.
%
% usage:[hdata]=POTATo_sub_AddResults(hdata,Tag,Val)
% input: 
%    Tag:(String) name of structure field
%    Val:(any) value to add. Structure is avalable.
%
% output:
%    hdata
% example:
%    [hdata]=ospsub_AddResults(hdata,'Test',999);
%
% create date: 2007.01.30
% coding: TK
% modified 2010.07.26
% 

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% saving results to struct:hdata.Results --------------------------

%- Tag check
Tag=POTATo_sub_CheckVarName(Tag);

%-
sFN=sprintf('hdata.Results.%s',Tag);

if ~isfield(hdata,'Results'), hdata.Results=[];end

if ~isfield(hdata.Results,Tag) % 1st time to add
	eval([sFN '=Val;']); 
elseif ~iscell(eval(sFN)) % there exist a previously added result
	TMP=eval(sFN);	
	eval([sFN '=[];']);
	eval([sFN '{1}=TMP;']);
	eval([sFN '{2}=Val;']);
else
	eval([sFN '{end+1}=Val;']); % there exist previously added results
end
