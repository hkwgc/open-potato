function varargout=POTATo_sub_DrawChButton(Pos, r, r_ratio)
%
% test draw of 2D ch spatial pattern
% usage: POTATo_sub_DrawChPatch(Pos, Val,r, clim(optional),Flags(optional))
%
%   Pos: position data
%   Val: value vector for each channel
%   r  : size of each patch
%   r_ratio: 
%                     2011/01/28 TK@HARL
%
%                    *2011/09/01 Bugfix: color bar

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


H.btnH=[];
A=POTATo_sub_MakeGUI(gcf);
A.UIType='Button';
A.NextX=0;A.NextY=0;
%pos0=get(gca,'position');
A.Unit=get(gca,'units');
A.PRMs.Visible='on';
A.PRMs.Units='normalized';
A.handles.gca=gca;

%=== size adjust 
A.SizeX=r;
p=get(gca,'position');
A.SizeY=r;%/(p(4)/p(3));
%===

for k=1:2
	Pos.D2.P(:,k)=normalization(Pos.D2.P(:,k))/4;
	Pos.D2.P(:,k)=Pos.D2.P(:,k)-min(Pos.D2.P(:,k));
end

for k=1:size(Pos.D2.P,1)
	A.PosX=Pos.D2.P(k,1);
	A.PosY=Pos.D2.P(k,2);
	A.Name=sprintf('tagBtn%d',k);
	A.Label=sprintf('%d',k);
	A=POTATo_sub_makeGUI(A);
	H.btnH(end+1)=A.newHS;
end

%== debug
assignin('base','H',H);
%==

if nargout>0
	varargout{1}=H;
end



