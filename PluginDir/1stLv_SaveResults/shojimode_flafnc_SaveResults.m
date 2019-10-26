function varargout=flafnc_SaveResults(fcn,varargin)
% This is test 1st-Level-Analysis Function, Nmaed Mean..
%
% Syntax:  
%  [fhdata,fdata]=flafnc_SaveResults('make',bhdata,bdata,varagin)
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
basicInfo.name   = 'save .Results';
basicInfo.region = [2 3];
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

function [fhdata,fdata]=makedata(hdata,data,S)

if iscell(hdata), hdata=hdata{1};end % cell??

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make header
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fhdata=FLA_makeheader(hdata,data,mfilename,'PlugInWrap_FLA_SaveResults');

[t tt]=fileparts(hdata.TAGs.filename{1});
fhdata.name=tt;

fhdata.stim=hdata.stim;
fhdata.stimTC=hdata.stimTC;
fhdata.stimkind=hdata.stimkind;
fhdata.samplingperiod=hdata.samplingperiod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%
CHNUM=size(hdata.flag,3); %channel size
fdata=zeros(CHNUM,length(S));
%flg_Mark=zeros(1,length(fhdata.stimkind));

fhdata.DataTag=[];
fhdata.DataPos=[];
for i=1:length(S)
	%fdata(:,i)=eval(['hdata.Results.' S{i}])';
  fdata(:,i)=hdata.Results.(S{i});
	fhdata.DataTag{end+1}=S{i};
	fhdata.DataPos{end+1}=i; % data postion of DataTag in fdata.
end
fprintf('%s\n',fhdata.name);
%=====
% Mark Setting
% ==

% check exist of 'block'
S1=[];
for i=1:length(fhdata.stimkind)
    for ii=1:length(S)
      t1=strfind(S{ii},'.');
      t2=strfind(S{ii},'block');
      if isempty(t2), continue;end
      if t1(end)<t2
        %n=str2num(S{ii}(t2+5:end));
        n=str2double(S{ii}(t2+5:end));
      else
        t3=find(t1>t2);t3=t3(end);
        %n=str2num(S{ii}(t2+5:t3-1));
        n=str2double(S{ii}(t2+5:t3-1));
      end
      if n==i
        S1{end+1}=strrep(S{ii},sprintf('block%d',i),sprintf('Mark%d',fhdata.stimkind(i)));
      end
    end
end
if ~isempty(S1) % 
    [uS t]=unique(S1);
    [t tt]=sort(t);
    uS=uS(tt);
    for i=1:length(uS)
        fhdata.DataTag{end+1}=uS{i};
        fhdata.DataPos{end+1}=strmatch(uS{i},S1);
    end
end

% Inner key
% Results
fhdata.I.ResultsGroup=S;

function [fhdata,fdata]=SelectInnerData(fhdata,fdata,key,val)
% Select Inner Data by Key
% ==> This function is useful in ...
switch key
  case 'ResultsGroup',
	  tg=find(ismember(fhdata.DataTag, val));
	  fdata=fdata(:,tg);
	  fhdata.DataTag=fhdata.DataTag(tg);
	  
  otherwise
    error('Unnown Key %s',key);
end

