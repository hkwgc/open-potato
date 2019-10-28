function [Y,I]=struct_sort(S, fld)
% struct_array_sort is Sort Struct Array along the Field
%
% [Y,I]=struct_array_sort(S, fld)
%    S   : Structure  Array
%    fld : Field Name
%
% See also SORT

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

% == History ==
% original auther : Masanori Shoji
% create : 2005.01.13
% $Id: struct_sort.m 180 2011-05-19 09:34:28Z Katura $
%
% Revision :1.3 (03-Apr-2008)
%  Blush-up

%------------------
% Argument Check
%------------------
if nargin ~= 2
  error([ ' Argument Number Error!' ...
	  'Number of argument must be 2' ]);
end

if ~isstruct(S)
  error('1st Argument must be Structure');
elseif length(S)==1
   Y=S;I=1;
   return;
end

if ~isfield(S,fld)
  error(['2nd Argument must be'...
	  'Field of Structure S']);
end

%----------------------------
% Make Sort-Index
%----------------------------
if isnumeric(S(1).(fld))
  c2 = [S.(fld)];
else
  c2 = {S.(fld)};
end
[y,I]=sort(c2);   % y is not use
I=reshape(I,size(S));

%----------------------------
% Sort Acording to Sort-Index
%----------------------------
if numel(S) == length(S)
  Y=S(I);
else
  Y=S;
  for ii=1:size(S,2)
    Y(:,ii) = S(I(:,ii),ii);
  end
end

return;
