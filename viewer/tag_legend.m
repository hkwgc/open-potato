function [h, objh, outh, outm, id]=tag_legend(axhs,varargin)
% Set Graph Legend, according to Axes Children Tag name
%
% Syntax :
%   [h, objh, outh, outm, id]=tag_legend(axhs, 'PropName',PropValue, ...);
%   whre texporp, and output-variable could omit.
%
% Input Variable
%   axhs      : handles of axes to add Legend.
%   PropName  : Property Name of Text
%   PropValue : Value  Correspond to PropName
%
% Output Variable
%   h         : axes handle of Legend
%   objh      : object handles
%   outh      : lines and patches 
%   outm      : Cell-String of Legend
%   ---> ID and outputvalue <---
%    h, objh, outh, outm is as same as legend.
%    where This function allow Vector axhs.
%    so result will be adding.
%    to recozinize there handles, id is available.
%    original axhs idx are included in the filed, respectively.
%
%  Example :
%    % Make plot data ..
%    x=[0:0.02:1]'; ps=pi/8;
%    s1 = sin(x*2*pi);
%    s2 = sin(x*2*pi+ps);
%    c1 = cos(x*2*pi);
%    c2 = cos(x*2*pi+ps);
%
%    % plot
%    figure;
%    axhs(1)=subplot(1,2,1); hold on
%    h=plot(x,s2,'g'); set(h,'TAG','sin_2')
%    h=plot(x,s1,'b'); set(h,'TAG','sin_1')
%    axhs(2)=subplot(1,2,2); hold on
%    h=plot(x,c2,'g'); set(h,'TAG','cos_2')
%    h=plot(x,c1,'b'); set(h,'TAG','cos_1')
%    
%    %==> Add Legend <==
%    % Take1
%    tag_legend(axhs);
%    % Take2
%    tag_legend(axhs,'Interpreter','none');
%    % Take 3
%    [h, objh, outh, outm, id]=tag_legend(axhs);
%    char(outm{find(id.outm==2)})
%
% See also LEGEND.
%
% $Revision: 1.7 $


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


% Data 15-Mar-2006
%   Change Interpreter

if nargin<1, axhs=gca;end

h=[];objh=[]; outh=[];outm={};
id.h   =[];
id.objh=[];
id.outh=[];
id.outm=[];
for idx=1:length(axhs),
	ax_h=axhs(idx);
	if ~ishandle(ax_h), continue; end
	cld_h = get(ax_h,'children');
	if isempty(cld_h), continue; end
  
	tags = get(cld_h, 'Tag');
	if ~iscell(tags), tags={tags};end 
	
	% Untitled Tag Setting
	d = cellfun('isempty',tags);
	d = find(d==1);
	if ~isempty(d)
		[tags{d}] = deal('Untitled');
	end
	
	 [h0, objh0, outh0, outm0] = legend(cld_h,tags{:});
	 h           = [h; h0]; 
	 id.h        = [id.h; idx];
	 objh        = [objh; objh0];
	 id.objh     = [id.objh; ones(size(objh0))*idx];
	 outh        = [outh; outh0];
	 id.outh     = [id.outh; ones(size(outh0))*idx];
	 outm        = {outm{:}, outm0{:}};
	 id.outm     = [id.outm, ones(size(outm0))*idx];
	 
	 if ~isempty(varargin),
		 tmp=findobj(h0,'type','text');
		 try,
			 if ~isempty(tmp),
				 set(tmp,varargin{:});
			 end
		 catch,
			 warning(lasterr);
		 end
	 end
 end
