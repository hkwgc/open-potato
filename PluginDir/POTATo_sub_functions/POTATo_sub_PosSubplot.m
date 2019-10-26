function h=POTATo_sub_PosSubplot(Pos, Ch)
%---
% sub function for plotting data
% ex) h=POTATo_sub_PosSubplot(Pos, Ch);
% in:  Pos: position data in hdata.Pos.D2.P
%      Ch: channel number to make axes
%out: h: handle for axis
%---                        TK@HARL
%---                       ver 0 / 20110214

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


for k=1:2
	Pos(:,k)=normalization(Pos(:,k));
end
Pos=Pos/1.25+0.5-0.05;

h=axes('Position',[Pos(Ch,:) 1/length(unique(Pos(:,1)))*0.9 1/length(unique(Pos(:,2)))*0.9]);

%subplot('position',[Pos(Ch,:) 0.1 0.1]);
title(sprintf('ch%d',Ch))
