function varargout=POTATo_sub_SpatialSmoothing(v,Pos,th)
%-
%- v1=POTATo_sub_SpatialSmoothing(v,Pos,th)
%- Input data 'v', which is a vector of length=ch length,
%- will be smoothed in spatial cordinate based on channel position defined by
%- input var of "Pos".
%- Data will be averaged between channels which has shorter distance than
%- input var "th".
%- Tips: Using POTATo_sub_SpatialSmoothing(Pos), you can get a distance list.
%-
%-  TK@CRL ver. 0.0  2013-05-29
%-

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin==1
	v1=calcD(v);
else	
	d=calcD(Pos);
	for k=1:length(v)
		v1(k)=nanmean(v(d(k,:)<th));
		chlist{k}=find(d(k,:)<th);
	end
end

varargout{1}=v1;
if nargout==2
	varargout{2}=chlist;
end

function d=calcD(Pos)
if isstruct(Pos)
	Pos=getPos(Pos);
end
p=Pos;
x=p(:,1);
y=p(:,2);

x=repmat(x,[1 length(x)]);
x1=(x-x').^2;
y=repmat(y,[1 length(y)]);
y1=(y-y').^2;

d=sqrt(x1+y1);

function p=getPos(P)

if isfield(P,'D2')& isfield(P.D2,'P')
	p=P.D2.P;
else
	p=nan;
	%- TODO
end

