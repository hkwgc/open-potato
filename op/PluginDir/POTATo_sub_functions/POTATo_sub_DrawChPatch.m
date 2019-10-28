function varargout=POTATo_sub_DrawChPatch(Pos, Val,r, varargin)
%
% test draw of 2D ch spatial pattern
% usage: POTATo_sub_DrawChPatch(Pos, Val,r, clim(optional),Flags(optional))
%
%   Pos: position data
%   Val: value vector for each channel
%   r  : size of each patch
%   clim : color limit. If empty, min and max.
%   Flags.colorbar: Defaut setting is 'on'.
%   Flags.text: Defaut setting is 'off'.
%
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

    
	if nargin>3
		clim=varargin{1};
	end
	if nargin>4
		Flags=varargin{2};
	end
	
	if nargin<4 | isempty(clim)
		colMin = nanmin(Val);
		colMax = nanmax(Val);
	else
		colMin = clim(1);
		colMax = clim(2);
	end
	if colMin==colMax
		colMax=colMax+1;
	end
	caxis([colMin colMax]);
	cm=colormap;
	nVal = (Val - colMin)/(colMax-colMin);
	nVal(isnan(nVal))=0;
	
	if nargin<5
		Flags.colorbar=true;
		Flags.text=false;
	end
	
	if isstruct(Pos) && isfield(Pos,'D2')
		Pos=Pos.D2.P;
	end
	
	% for k=1:32
	% 	cm(k,:)=[k/32 k/32 1];
	% end
	% for k=1:32
	% 	cm(k+32,:)=[1 1-k/32 1-k/32];
	% end
	H.patch=[];H.text=[];
			xm0=zeros(1,6);ym0=zeros(1,6);
		for kk=1:6
			xm0(kk)=cos(2*pi/6*kk)*r;
			ym0(kk)=sin(2*pi/6*kk)*r;
		end
	for k=1:length(Val)
		x=Pos(k,1);
		y=Pos(k,2);
		xm=x+xm0;ym=y+ym0;
		%- color map edge
		ctag = 1+fix((size(cm,1)-1)*nVal(k));
		if ctag <= 0, ctag = 1;end
		if ctag > size(cm,1), ctag = size(cm,1);end
		%
		h=patch(xm,ym,cm(ctag,:));
		if ~isnan(Val(k))
			set(h,'edgecolor','none');
		else
			set(h,'facecolor','none','lineStyle',':','edgecolor',[.7 .7 .7],'linewidth',0.1)
		end
		if Flags.text
			ht=text(x,y,num2str(k));
			H.text(end+1)=ht;
		end
		%set(h,'Markerfacecolor',cm(1+fix(63*(T.c(k)-min(T.c))/(max(T.c)-min(T.c))),:),'MarkerEdgeColor','none','MarkerSize',r);
		H.patch(end+1)=h;		
	end
	
	if isfield(Flags,'colorbar') & Flags.colorbar
		%-colorbar
		R = max(Pos(:,1));
		T = min(Pos(:,2));B = max(Pos(:,2));
		D=(B-T)/64;
		for k=1:64
			h=patch([ R+r*3 R+r*3 R+r*3.5 R+r*3.5],[T T+D T+D T]+(k-1)*D,cm(k,:));
			set(h,'edgecolor','none');
		end
		text(R+r*2.5, B+D*3, sprintf('%0.2f',colMax));
		text(R+r*2.5, T-D*3, sprintf('%0.2f',colMin));
		
	end
	
	axis off;axis equal;
	if nargout>0
		varargout{1}=H;
	end
	
		
	
