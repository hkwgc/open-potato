function varargout=POTATo_sub_CheckStruct(D,S,varargin)

% sub function
% check structure of D (struct) if there exist any fields with size of
% (1,S) or (S,1)
% Varargin is not used in general case.
% These variables are for internal use of this recursive func.
% check vararagin
%
%--- version 2.0 (2013-05/01)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if ~isempty(varargin)
    List=varargin{1};
    Pname=varargin{2};
else
    List=[];
    Pname=[];
end
varargout{1}=List;

if ~isstruct(D), return;end

M=fieldnames(D);
for i=1:length(M)
    sD1=['D.' M{i}];
    flag=false;
    %if length(eval(sD1))==S
    %	flag=true;
    %else
    if isstruct(eval(sD1))
        List=POTATo_sub_CheckStruct(eval(sD1),S,List,[Pname sD1(2:end)]);
    elseif iscell(eval(sD1))
        for i2=1:length(eval(sD1))
            List=POTATo_sub_CheckStruct(eval([sD1 sprintf('{%d}',i2)]),S,List,...
                sprintf('%s%s{%d}',Pname,sD1(2:end),i2) );
        end
    else
        sz=size(eval(sD1));
        if (sz(1)==1 && sz(2)==S) || (sz(1)==S && sz(2)==1)
            flag=true;
        end
        %end
    end
    if flag
        if isempty(Pname)
            List{end+1}=[sD1(3:end)];
        else
            List{end+1}=[Pname(2:end) sD1(2:end)];
        end
    end
    
    %%% BUG ???
    if ~isempty(List)
        tmp=List{end};
        if strcmp(tmp(1),'.')
            tmp=tmp(2:end);
            List{end}=tmp;
        end
    end
    %%%%%%%%%
end

r=[];
if nargout==1
    varargout{1}=List;
elseif nargout ==2
    varargout{1}=List;
    for k=1:length(List)
        eval(['r.' POTATo_sub_CheckVarName(List{k}) '=D.' List{k}]);
    end
    varargout{2}=r;
end

return





