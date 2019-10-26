function kid=subKmeansTool(d,knum,distID,Repli,varargin)
%---
%- distID: 1:sqEuclidean
%- distID: 2:cityblock
%- distID: 3:cosine
%- distID: 4:correlation
%- distID: 5:Hamming
%-
%- Option: 'FigH',gcf

% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


distStr={'sqEuclidean','cityblock','cosine','correlation','Hamming'};

if mod(nargin,2)==1
	error('input variables are not correct.');
end

for k=1:2:length(varargin)
	if ischar(varargin{k+1})
		eval([varargin{k} '=' varargin{k+1} ';']);
	else		
		eval([varargin{k} '=varargin{k+1};']);
	end
end

kid=kmeans(d,knum,'Distance',distStr{distID},'Replicates',Repli);

if exist('FigH','var')
	figure(FigH);
	for k=1:knum
		subplot(knum,1,k);cla;hold on;
		d1=d(kid==k,:);
		%md=mean(d(kid==k,:),1);
		md=median(d(kid==k,:),1);
		plot(d1', 'k');
		plot(md, 'r','linewidth',3);
		
		if exist('evalStr','var')
			for kk=1:length(evalStr)
				eval(evalStr{kk});
			end
		end
		
	end
end



	