function varargout=flafnc_sd(fcn,varargin)
% This is test 1st-Level-Analysis Function, Nmaed sd..
%
% Syntax:  
%  [fhdata,fdata]=FLA_sd('make',bhdata,bdata,varagin)
% 
%       bdata  : Block-Time Data
%       bhdata : Header of Block-Time Data 
%
%       fdata  : 1st-Level-Analysied Data
%       fhdata : Header of 1st-Level-Analysied Data
%
%       varargin : test input data (not in use)
%                  ==> if you need you can add.

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


%======== Launch Switch ========
switch fcn,
  case 'createBasicInfo',
    varargout{1}=createBasicInfo;
  case 'make',
    [varargout{1:nargout}] = makedata(varargin{:});
%  case 'filekey',
%    varargout{1}=filekey;
%  case 'innerkey',
%    varargout{1}=innerkey;
  otherwise
    if nargout,
      [varargout{1:nargout}] = feval(fcn, varargin{:});
    else
      feval(fcn, varargin{:});
    end
end
return;
%===============================

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
basicInfo.name   = 'sd (test)';
basicInfo.region = 3;
% ==> Version : Must be
ver = '$Revision: 1.3 $';
ver([1:13,end])=[];
try
  basicInfo.Version = str2double(ver);
catch
  basicInfo.Version =1;
end
% Search-Key refresh?
% When Version is update.
%   Include 1:
basicInfo.refresh=2.0;
return;

function [fhdata,fdata]=makedata(bhdata,bdata,hoge)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make default Search Key
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=3
  disp('Test Input Data is : ');
  disp(hoge);
else
  hoge=3;
end
fhdata=FLA_makeheader(bhdata,bdata,mfilename,'PlugInWrap_sd');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==> to modify 
fhdata.stimkind = bhdata.stimkind;
fdata = squeeze(nan_fcn('std0',bdata,2)); % sd alongthe time-dimension.
% Apply Flag
sz=size(fdata);if length(sz)==2, sz=[1 sz(:)'];end
fdata=reshape(fdata,prod(sz(1:2)),sz(3));
fdata(squeeze(sum(bhdata.flag,1))>=1,:)=NaN;
fdata=reshape(fdata,sz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add-Special-Search-Key
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adding Special Data
fhdata.F.MY_TIME= datestr(now,13);
% Marker
fhdata.I.Mark=unique(fhdata.stimkind);

function [fhdata,fdata]=SelectInnerData(fhdata,fdata,key,val)
% Select Inner Data by Key
% ==> This function is useful in ...
switch key
  case 'Mark',
    v=cell2mat(val); % Getting Marks
    % ==> Select Only v's Block!
    fdata=fdata(ismember(fhdata.stimkind,v),:,:);
  otherwise
    error('Unnown Key %s',key);
end


