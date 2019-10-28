function varargout=etg_pos_dataread(mode,varargin),
%
%

% ======================================================================
% Copyright(c) 2019,
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license
% https://opensource.org/licenses/MIT
% ======================================================================


if nargout,
    [varargout{1:nargout}] = feval(mode,varargin{:});
else,
    feval(mode,varargin{:});
end
return;

function [x, y, z, ChNum] = getXYZ(pos,ProbeID),
x=[]; y=[]; z=[];
eval(['ChNum=pos.Probe' num2str(ProbeID) '.ChNum;']);
for idx=1:ChNum
    x(idx)=eval(['pos.Probe' num2str(ProbeID) '.ch' num2str(idx) '.X']);
    y(idx)=eval(['pos.Probe' num2str(ProbeID) '.ch' num2str(idx) '.Y']);
    z(idx)=eval(['pos.Probe' num2str(ProbeID) '.ch' num2str(idx) '.Z']);
end
return;
