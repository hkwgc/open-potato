function varargout=osp_FigureMapController(fnc,varargin)
%      Functions : Initialize  : Allocate to Figurehandle.FigureMapTemp
%                  AddMapData  : Add to Axis data(x, y),AxisID
%                  MakeMapData : Make figure Map(optical)
%                  GetMapData  : get to Axis ID from Figurehandle.FIgureMapTemp

% In no input : Help


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


if nargin==0,  OspHelp(mfilename); return; end

if nargout,
  [varargout{1:nargout}] = feval(fnc, varargin{:});
else,
  feval(fnc, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcode=Initialize(figh)

% Allocate FigureMapTemp
try,
	rcode=true;
	setappdata(figh,'FigureMapTemp',zeros(255,6));
catch,
	rcode=false;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AddMap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcode = AddMapData(figh, AxesID, xydata, chdata)

% Add Map Information to figh.FigureMapTemp
try,
	rcode=true;
	dat=getappdata(figh,'FigureMapTemp');
	ipos=min(find(dat(:,5) == 0));
	dat(ipos,1)=xydata(1);
	dat(ipos,2)=xydata(1)+xydata(3);
	dat(ipos,3)=xydata(2);
	dat(ipos,4)=xydata(2)+xydata(4);
	dat(ipos,5)=AxesID;
    dat(ipos,6)=chdata;
	setappdata(figh,'FigureMapTemp',dat);
catch,
	rcode=false;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rcode = MakeMapData(figh)

% Sort Map Data to figh.FigureMapTemp
try,
	rcode=true;
	dat=getappdata(figh,'FigureMapTemp');
	dat=sortrows(dat);
	setappdata(figh,'FigureMapTemp',dat);
catch,
	rcode=false;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GetAxesID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NowID, chdata] = GetMapData(figh, clkpos)

% Get AxesID from figh.FigureMaptemp
try,
	rcode=true;
	dat=getappdata(figh,'FigureMapTemp');
	
	iend=min(find(dat(:,5) == 0))-1;
	xind=(dat(1:iend,1)<clkpos(1)) + (dat(1:iend,2)>clkpos(1));
	yind=(dat(1:iend,3)<clkpos(2)) + (dat(1:iend,4)>clkpos(2));
    xad=find((xind+yind) == 4);
	NowID=dat(xad,5);
    chdata=dat(xad,6);
catch,
	rcode=false;
end
return;