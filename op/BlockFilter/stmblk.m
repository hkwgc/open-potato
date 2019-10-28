%stmdat=stmblk(stmdat,varargin)
%Input 
%1. stmdat: the data of like [00001000=signal.stim
%Output
%1. stmbk: the data of like [00001111=signal.stimblk
%Description
%1. The number of stimulation mark is even => 0 will be changed to 1 between each pair of 1.
%2. The number of stimulation mark is odd  => 0 will be changed to 1 between each pair of 1.
%    Moreover, last period after the last 1 will be changed to 1.
%August 1st,2002 A.Maki


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================




function [stmdat]=stmblk(stmdat,varargin)

if nargin==1,
    dum=find(stmdat > 0.5);
    dumnum=length(dum);
    modulusn=mod(dumnum,2);
    if dumnum>=2,
        switch modulusn,
        case 0,
            for ii=1:2:dumnum-1,
                stmdat(dum(ii):dum(ii+1))=1;
            end
        case 1,
            for ii=1:2:dumnum-2,
                stmdat(dum(ii):dum(ii+1))=1;
            end
            stmdat(dum(end):end)=1;
        end
    else
        return
    end
elseif nargin==2,
    return
end

% === Grep Result 27-Dec-2004 ===
% BlockFilter/oteditmark_mainsubchld.m
%    21: stimblk=stmblk(stim);
%   175: modstimblk=stmblk(modstim);
%   278: modstimblk=stmblk(modstim);
%   479: modstimblk=stmblk(modstim);
%   643: modstimblk=stmblk(modstim);
%
% preprocessor/ot_dataload.m
%   624: [stmdatblk]=stmblk(stim);
%
% preprocessor/ot_fileinfo.m
%   630:% [stmdatblk]=stmblk(stim);
%
% preprocessor/readEtgData.m:
%   71:% [stmdatblk]=stmblk(stim);




