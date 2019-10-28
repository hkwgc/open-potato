function s1=struct_merge0(s1,s2,mode)
% Merge Function of Struct (to set Struct-array)
%  
% Syntax :
%  s=struct_merge0(s1,s2,mode)
%   where s1,s2, s is single structure.
%   fieldname(s) is equal to fieldname(s1).
%   Value of s.(fieldC)=s2.(fieldC),
%   where fieldC is common field with s1 & s2.
% 
%  if mode=0
%      other filed-value is equal to s1.
%      (default)
%  if mode=1
%      other filed-value is empty.
%  if mode=2
%      NaN/''
%   
% Example:
%  s1 = struct('a',1,'b',2,'c',3);
%  s2 = struct(      'b',1,      'bb',2);
%  struct_merge0(s1,s2)

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original auther : Masanori Shoji
% create : 2008.04.03
% $Id: struct_merge0.m 180 2011-05-19 09:34:28Z Katura $
%

if nargin<3
  mode=0;
end

fn1=fieldnames(s1);
fn2=fieldnames(s2);
fn =intersect(fn1,fn2);
for idx=1:length(fn)
  s1.(fn{idx})=s2.(fn{idx});
end

% Modify
if mode==0,return;end

efn=setdiff(fn1,fn2);
switch mode
  case 1
    % Empty
    for idx=1:length(efn)
      tmp=s1.(efn{idx});
      tmp(:)=[];
      s1.(efn{idx})=tmp;
    end
  case 2
    % NaN
    for idx=1:length(efn)
      if isnumeric(s1.(efn{idx}))
        s1.(efn{idx})=NaN;
      else
        s1.(efn{idx})='';
      end
    end
  otherwise
    error('Undefined Mode');
end

return;
