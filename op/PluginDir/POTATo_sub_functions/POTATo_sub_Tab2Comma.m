%

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================

[f p]=uigetfile('*.csv');
fid=fopen([p f]);
fid2=fopen([p '2_' f],'w+');
%
while 1
	t=fgetl(fid);
	if ~ischar(t), break;end
	t=strrep(t,sprintf('\t'),',');
	fprintf(fid2,'%s\n',t);
end
fclose all;
