function fname=getRelationFileName
%  Get Relation File Name of mine


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


path0 =OSP_DATA('GET','PROJECTPARENT');
pj=OSP_DATA('GET','PROJECT');
% Opening Check.
if isempty(path0) || isempty(pj)
  msg='Project is not Opened.';
  errordlg(msg);error(msg);
end
if ~strcmpi(path0,pj.Path),
  msg='Project Data might be broken';
  errordlg(msg);error(msg);
end

% fname = [pj.Path ...
fname =[path0 filesep pj.Name ...
  filesep 'Relation.mat'];
