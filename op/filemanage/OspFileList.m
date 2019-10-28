function vargout=OspFileList(mode,varargin)
% OSP File I/O in the Project
%
% -------------------------------------
%  Optical topography Signal Processor
%                         Version 1.00
%  $Id: OspFileList.m 180 2011-05-19 09:34:28Z Katura $
% -------------------------------------
%
% See also OspProject      : Similar source Code
%          OspFileSave     : Save New File List
%          uiOspFileSelect : File Selector GUI


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================



% == History ==
% original author : Masanori Shoji
% create : 2005.01.13
% $Id $
%

% Load File List
fListFile=fname;
try
    load(fListFile,'FileList');
end
if ~exist('FileList','var')
  FileList=struct([]);
end

switch mode
  % ------------
 case 'LoadData'
  % ------------
  
  % Type Specified Data
  if ~isempty(varargin)
    for type=varargin
      type_val=struct2cell_field(FileList,type.field);
      
      if isfield(type,'From') % Numerical Choice
	rng=find(type.From<type_val && type_val<type.To);
	FileList = FileList( rng ); clear rng;
      elseif isfield(type, 'Expression') % String Filter
	rng = find( feval(type.method,typ_val, type.Expression));
	FileList=FileList(rng); clear rng;
      else   % Sort 
	FileList = struct_sort(FileList, type.field); 
      end

    end
  end % End of Search List

  varargout{1}=FileList;
  return;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c2=struct2cell_field(S, Field)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Charge  Field of the Struct to Cell
c = struct2cell(S);         % Cell
f = fieldnames(S);          % Field name
p = find(strcmp(f, fld));
c2=squeeze(c(p,:,:));
if isnumeric(getfield(S(1),fld))
  c2 = cell2mat(c2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fname=getOspDataFileName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==  Get Project Data File Name ==

  fname=[]; % Error (Default )

  % Get Directory Name
  pj=OSP_DATA('GET','PROJECT');
  if isempty(pj)
    error('Set Project Data at First!');
  end
  dirname = [pj.Path OSP_DATA('GET','PROJECT_DATA_DIR')];

  % Set OSP Data File Name in the Project
  fname = [dirname filesep 'OspFileList.mat'];
return;
