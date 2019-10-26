function suspend_comm(hs,pos,handles)
% Pribate Function for POTATO_win
%  This function move Grahics-Object to foreaway.
%
% hs  : handles of move-Grahics-Object
% pos : Move size.


% ======================================================================
% Copyright(c) 2019, 
% National Institute of Advanced Industrial Science and Technology
%
% Released under the MIT license 
% https://opensource.org/licenses/MIT 
% ======================================================================


p=get(hs,'Position');
p=cell2mat(p);
p(:,1:2)=p(:,1:2)-repmat(pos,size(p,1),1);
for idx=1:length(hs),
  set(hs(idx),'Position',p(idx,:));
end

%=============================
% Other Common Visible
%=============================
if nargin<=2,return;end
set(handles.frm_AnalysisArea,'Visible','off');
